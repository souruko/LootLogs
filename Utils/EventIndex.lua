--=================================================================================================
--= Event index
--= ===============================================================================================
--= Two lookups over _G.Events, both built once and both replacing a full walk of the table.
--=
--=   Scan(message, handler)   which events a chat line could match
--=   ForInstance(instanceId)  which events belong to one instance
--=
--= WHY THIS EXISTS. _G.Events is ~600 rows and every one of them carries a Lua pattern. The chat
--= hook used to run all ~600 patterns against every line the client printed -- 200us per line on
--= a desktop Lua, and the client runs plugin Lua on the frame thread, so a busy channel spends
--= that time not drawing. The window rebuild had the same shape: half a dozen helpers each
--= walking all ~600 rows looking for one instance, called once per tier per instance per redraw.
--=
--= Neither answer changes between messages, so neither is computed per message any more.
--=================================================================================================

_G.EventIndex = {}

-- ------------------------------------------------------------------------------------------------
-- required literals
--
-- A Lua pattern that matches a string implies literal text that string MUST contain. For these
-- patterns that text is most of them -- "Naruhel's Silver Chest", "Completed Umbar instances" --
-- and a plain substring is something a hash table can be keyed on where a pattern is not.
--
-- WHAT COUNTS AS REQUIRED, and every one of these is a case the data actually contains:
--
--   %d %a %s ...     a class matches text we cannot predict, so it ends the run
--   %( %. %%         an ESCAPED punctuation mark is a literal, and stays in the run
--   .                matches anything, so it ends the run -- "Agath.kali's" is two runs, which
--                    is the whole point of the dot there (it absorbs whichever dash the client
--                    printed)
--   [^ ]             a set is unpredictable text, so it ends the run
--   x* x- x?         the atom may be absent, so it is dropped AND ends the run
--   x+               at least one, so the atom is kept -- but what follows it is not contiguous
--                    with the run, so the run ends after it. "Tier 3+" requires "Tier 3".
--   ( )              a capture consumes nothing; ended anyway, because being conservative here
--                    only ever shortens a key, and a shorter key is still correct
--
-- Anything shorter or more optional than the truth would be a bug -- a key the message does not
-- contain means the event is never dispatched. Anything longer is safe. So every doubtful case
-- above breaks the run rather than extending it, and tests/run.lua checks the result against
-- strings generated from the real patterns.
local function LiteralRuns(pattern)

    local runs, run = {}, {}
    local length    = #pattern
    local position  = 1

    local function Flush()
        if #run > 0 then
            runs[#runs + 1] = table.concat(run)
            run = {}
        end
    end

    while position <= length do

        local char    = string.sub(pattern, position, position)
        local literal = nil
        local size    = 1

        if char == "%" then

            local escaped = string.sub(pattern, position + 1, position + 1)
            if escaped == "" then break end
            size = 2
            -- %a %d %s %w %x ... are classes; %( %. %% are the punctuation they escape
            if string.find(escaped, "^%a") == nil then literal = escaped end

        elseif char == "[" then

            local close = position + 1
            if string.sub(pattern, close, close) == "^" then close = close + 1 end
            if string.sub(pattern, close, close) == "]" then close = close + 1 end
            while close <= length and string.sub(pattern, close, close) ~= "]" do
                if string.sub(pattern, close, close) == "%" then close = close + 1 end
                close = close + 1
            end
            size = close - position + 1

        elseif char == "." or char == "(" or char == ")" then
            size = 1

        elseif char == "^" and position == 1 then
            size = 1

        elseif char == "$" and position == length then
            size = 1

        else
            literal = char

        end

        local quantifier = string.sub(pattern, position + size, position + size)

        if quantifier == "*" or quantifier == "-" or quantifier == "?" then
            Flush()
            position = position + size + 1
        elseif quantifier == "+" then
            if literal ~= nil then run[#run + 1] = literal end
            Flush()
            position = position + size + 1
        else
            if literal ~= nil then run[#run + 1] = literal else Flush() end
            position = position + size
        end

    end

    Flush()

    return runs

end

-- The longest run, which is the most selective key available. Exported for the tests.
function _G.EventIndex.RequiredLiteral(pattern)

    local best = nil

    for _, run in ipairs(LiteralRuns(pattern)) do
        if best == nil or #run > #best then best = run end
    end

    return best

end

-- ------------------------------------------------------------------------------------------------
-- the chat index
--
-- Keyed on the FIRST N BYTES of an event's required literal, and a message is looked up by every
-- N-byte window in it. That is what makes the lookup exact rather than heuristic: if the pattern
-- matches, the message contains the literal, so it contains the literal's first N bytes at some
-- offset, so one of the message's own windows IS the key.
--
-- Six was measured, not guessed: 3 leaves buckets of 46 and costs 13us a line, 6 leaves 28 and
-- costs 5.9us, and past 6 the curve flattens while more literals fall short of the key length.
-- A literal shorter than the key cannot be indexed and goes in `always` instead, which is simply
-- the old behaviour for those few rows.
local KEY = 6

local buckets    = nil      -- key -> { eventIndex, ... }
local always     = nil      -- events with no literal long enough to key on
local stamp      = {}       -- eventIndex -> generation, so one event is tested once per message
local generation = 0
local matched    = {}       -- reused, so a scan allocates nothing
local found      = 0        -- how much of `matched` this scan filled

-- `matched` outlives the scan, so hits are inserted in order rather than sorted at the end:
-- table.sort would see whatever a longer previous scan left behind them. A line matching more
-- than one event is rare and never matches many, so the insertion costs nothing.
--
-- File scope rather than a closure inside Scan, because a closure would be one allocation per
-- chat line -- which is the cost this whole file exists to remove.
local function Remember(eventIndex)

    local slot = found

    while slot >= 1 and matched[slot] > eventIndex do
        matched[slot + 1] = matched[slot]
        slot = slot - 1
    end

    matched[slot + 1] = eventIndex
    found = found + 1

end

local function Build()

    buckets, always = {}, {}

    if _G.Events == nil then return end

    for eventIndex, event in ipairs(_G.Events) do

        local literal = event.match ~= nil and _G.EventIndex.RequiredLiteral(event.match) or nil

        if literal ~= nil and #literal >= KEY then

            local key    = string.sub(literal, 1, KEY)
            local bucket = buckets[key]
            if bucket == nil then
                bucket       = {}
                buckets[key] = bucket
            end
            bucket[#bucket + 1] = eventIndex

        else

            always[#always + 1] = eventIndex

        end

    end

end

-- _G.Events is data loaded before this file, but a language switch or a live edit should not
-- need a plugin restart.
function _G.EventIndex.Rebuild()
    buckets, always = nil, nil
    _G.EventIndex.ClearInstances()
end

-- Every event whose pattern matches `message`, handed to `handler(message, event, eventIndex)`.
--
-- IN EVENT-INDEX ORDER, exactly as the linear scan produced them. One line matching two events
-- is rare but real, and the two alerts it prints should not swap places depending on where in
-- the line each chest name happened to sit.
function _G.EventIndex.Scan(message, handler)

    if buckets == nil then Build() end

    local events = _G.Events
    if events == nil then return end

    found      = 0
    generation = generation + 1

    for position = 1, #message - KEY + 1 do

        local bucket = buckets[string.sub(message, position, position + KEY - 1)]

        if bucket ~= nil then
            for slot = 1, #bucket do

                local eventIndex = bucket[slot]

                -- the same key can occur twice in one line, and a bucket holds several events;
                -- the stamp is what keeps either from testing an event twice
                if stamp[eventIndex] ~= generation then
                    stamp[eventIndex] = generation
                    if string.find(message, events[eventIndex].match) ~= nil then
                        Remember(eventIndex)
                    end
                end

            end
        end

    end

    for slot = 1, #always do
        local eventIndex = always[slot]
        if string.find(message, events[eventIndex].match) ~= nil then
            Remember(eventIndex)
        end
    end

    -- NOT RE-ENTRANT, and that is the price of the reused table: a handler that called Scan
    -- again would refill `matched` under this loop. Nothing does -- the only caller is the chat
    -- hook, and the only handler is ProcessMatch.
    for slot = 1, found do
        handler(message, events[matched[slot]], matched[slot])
    end

end

-- ------------------------------------------------------------------------------------------------
-- the instance index
--
-- "which events belong to this instance" is asked by the tier bands, the column headers, the
-- carry-over marker, the reset caption and the sidebar squares -- each of them once per tier per
-- instance, and all of them inside one window rebuild. Every one of those used to walk the whole
-- table.

local byInstance = nil

-- returned for an instance with no events, so callers can iterate without a nil check
local EMPTY = {}

local function BuildInstances()

    byInstance = {}

    if _G.Events == nil then return end

    for eventIndex, event in pairs(_G.Events) do
        local list = byInstance[event.instance]
        if list == nil then
            list                    = {}
            byInstance[event.instance] = list
        end
        list[#list + 1] = eventIndex
    end

    -- pairs() has no order, so the lists are sorted to keep every consumer deterministic
    for _, list in pairs(byInstance) do
        table.sort(list)
    end

end

-- The event indices of one instance, ascending. Shared and cached: TREAT IT AS READ-ONLY.
function _G.EventIndex.ForInstance(instanceId)

    if byInstance == nil then BuildInstances() end

    return byInstance[instanceId] or EMPTY

end

function _G.EventIndex.ClearInstances()
    byInstance = nil
end
