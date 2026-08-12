--=================================================================================================
--= Loot drops
--= ===============================================================================================
--= Parse loot lines, buffer them, and bind them to the chest event that ProcessMatch already
--= identified. This file adds the ONLY genuinely new parsing in the feature: boss, tier and
--= instance all come from _G.Events via the existing matcher.
--=
--= The shape of this file is set by what the M0 probe found on a six-man run
--= (docs/design/loot-drops/reference/chat-samples.txt). Four things differ from the original
--= design, and each is load-bearing:
--=
--=   1. NO DEDUPE. The plan collapsed repeats of (player, item) inside 10s, to guard against a
--=      "(pending)" line being confirmed and counted twice. That confirmation does not exist --
--=      63 pending lines, 0 confirmations -- while genuine repeats absolutely do: one looter
--=      took the same item seven times in six seconds. The guard only ever destroyed data.
--=   2. THE WINDOW IS ASYMMETRIC. Real chest loot was seen 2.88s AFTER the chest line, so the
--=      old single 2.0s window would have dropped it. But quest-completion rewards land ~4.5s
--=      BEFORE it, so a window that wide in both directions would swallow them. Back 1.0s,
--=      forward 4.0s.
--=   3. STACKS CARRY A COUNT AND A PLURAL. "[3 Damaged Mûrai Artifacts]" is the same item as
--=      "[Damaged Mûrai Artifact]". The count is stripped here; the plural spelling is data,
--=      not a rule (see Logs/Drops/English.lua).
--=   4. THE BUFFER IS PRUNED BY AGE. Six people looting trash overrun any small fixed count in
--=      well under a second.
--=================================================================================================

--= ------------------------------------------------------------------------------------------
--= _G.Drops IS INPUT, NEVER OUTPUT.
--=
--= This plugin reads the drops database and does not fill it. Cataloguing -- discovering item
--= names, ids, slots, chances, which drops are worth a popup -- belongs to a separate plugin
--= that will produce these tables. Anything here that "learns" data and writes it back would
--= be a second source of truth for the same table, and the two would disagree.
--=
--= So: no backpack scanning, no id harvesting, no drop targets. If a row is missing an id it
--= shows an empty slot; if an item is missing from the table it is ignored. Both are the
--= authoring plugin's job to fix, and both must fail quietly here.
--=
--= What this plugin DOES own is its own observations and the player's own choices --
--= _G.LootObserved, _G.LootAcquired and _G.LootWishlist. Those are per-player state, not
--= catalogue, and they are saved from here.
--=
--= _G.LootDrops.RebuildIndex() exists so the authoring plugin can replace _G.Drops at runtime
--= and have the lookups pick it up.
--= ------------------------------------------------------------------------------------------

import "LootLogs.Utils.Functions"

_G.LootDrops = {}

-- Memory backstop only. Age is what actually bounds the buffer; this stops a pathological
-- farming session from growing it without limit.
local BUFFER_MAX = 200

-- Both link forms wrap the name in markup the plan did not know about --
--   <Examine:IIDDID:0x<64>:0x<32>>[Name]<\Examine>          an item you do NOT hold
--   <ExamineItemInstance:ItemInfo:<blob>>[Name]<\...>       an item now in your bags
-- so ".-" before the bracket is doing real work. It is safe: a name cannot contain "[", and
-- the blob is built from high codepoints whose UTF-8 bytes are all >= 0x80, so no raw 0x5B
-- can appear inside it either.
local P = {
    lootSelf  = "^You have acquired: .-%[(.-)%]",
    lootOther = "^(%S+) has acquired .-%[(.-)%]",
}
_G.LootDrops.P = P

-- Only ever present on the "not yours" link form, so this is a bonus for the icon route in
-- M4, never a key. See chat-samples.txt, RESOLVED question A.
local EXAMINE_ID = "Examine:%w+:0x%x+:0x(%x+)"

-- ------------------------------------------------------------------------------------------------
-- settings

local function BackWindow()
    return (_G.Settings.lootWindowBackTenths or 10) / 10
end

local function ForwardWindow()
    return (_G.Settings.lootWindowFwdTenths or 40) / 10
end

-- ------------------------------------------------------------------------------------------------
-- item index

-- alias:   every spelling (singular and plural) -> the canonical item name
-- events:  canonical name -> { eventIndex, ... }, the "where does this drop" lookup
-- dropOf:  eventIndex -> canonical name -> the _G.Drops row
local alias, events, dropOf = nil, nil, nil

local function BuildIndex()

    alias, events, dropOf = {}, {}, {}

    if _G.Drops == nil then return end

    for eventIndex, drops in pairs(_G.Drops) do

        dropOf[eventIndex] = {}

        for _, drop in ipairs(drops) do

            alias[drop.item] = drop.item
            if drop.plural ~= nil then
                alias[drop.plural] = drop.item
            end

            local list = events[drop.item]
            if list == nil then
                list = {}
                events[drop.item] = list
            end
            list[#list + 1] = eventIndex

            dropOf[eventIndex][drop.item] = drop

        end

    end

end

-- nil when the item is not catalogued, which is the O(1) gate that implements
-- "ignore items not in the database"
local function Canonical(name)

    if alias == nil then BuildIndex() end

    return alias[name]

end

-- Resolves any spelling -- singular or plural -- to the name _G.Drops is keyed on, or nil when
-- the item is not catalogued. Exported because the icon harvest has to match a backpack name
-- against the same table.
function _G.LootDrops.Canonical(name)
    return Canonical(name)
end

function _G.LootDrops.KnowsItem(name)
    return Canonical(name) ~= nil
end

function _G.LootDrops.ItemEvents(name)

    local canonical = Canonical(name)
    if canonical == nil then return {} end

    return events[canonical] or {}

end

-- ------------------------------------------------------------------------------------------------
-- item shortcuts

-- Turbine.UI.Lotro.ShortcutType.Item, read off a live drag rather than assumed.
_G.LootDrops.SHORTCUT_ITEM = 2

-- The icon and tooltip route, and the answer to the one thing the plan could not settle.
--
-- A quickshot shortcut's payload is a pair:
--
--   0x034500025967C53A,0x700713ED
--   `------- instance GUID        `--- item id
--
-- The instance half names ONE item in ONE bag, so a string captured from a real drag goes
-- stale as soon as that item is gone -- useless as stored data.
--
-- But a ZEROED instance half resolves. That is the form the chat link already uses for items
-- nobody holds (<Examine:IIDDID:0x0000000000000000:0x700713ED>), and it is confirmed working
-- in the client. So the item id alone is enough to build a shortcut, which means:
--
--   * every catalogued item with an `id` draws its real icon and its real tooltip
--   * including gear nobody in the group owns, which is most of what the browser lists
--   * and nothing about it has to be captured, stored per character, or refreshed
--
-- Cataloguing an id is therefore the whole job. Chat hands them over for items you do not
-- hold; for anything else, drag it onto a row and read the id off the printed line.
function _G.LootDrops.ShortcutData(drop)

    if drop == nil or drop.id == nil then return nil end

    return string.format("0x%016X,0x%08X", 0, _G.LootDrops.ItemId(drop.id))

end

-- An id may arrive as a number from the drops data or as a hex string from a captured drag.
-- Both are the same id; only one of them can be formatted.
function _G.LootDrops.ItemId(id)

    if type(id) == "string" then
        return tonumber((string.gsub(id, "^0[xX]", "")), 16)
    end

    return id

end

-- ------------------------------------------------------------------------------------------------
-- item links

-- The clickable item link, in the client's own chat form:
--
--   <Examine:IIDDID:0x0000000000000000:0x700713ED>[Enhancement Rune +1]<\Examine>
--   `----------------------------------'          `----------------'
--    the tag the client turns into a link           what it reads as
--
-- Note the closing tag takes a BACKSLASH, not a forward slash. That is not a typo -- it is what
-- the live client prints, captured in docs/design/loot-drops/reference/chat-samples.txt.
--
-- THE INSTANCE HALF IS ZEROED, and that is the whole reason this works for a catalogued item
-- nobody is holding. The client zeroes it itself for other people's loot, which is where our
-- ids came from in the first place, and a zeroed shortcut is already proven to resolve.
--
-- The link TEXT is the display name, so a row with a `label` reads as "Burglar Red Shoulders"
-- while the link still resolves to the real item -- the id does that, not the words.
--
-- Without an id there is nothing to link to, so it falls back to the plain bracketed name. That
-- is the same shape, just not clickable, so a chest with a mix of the two still lines up.
function _G.LootDrops.ItemLink(drop, shown)

    local name = shown or (drop ~= nil and (drop.label or drop.item)) or "?"
    local id   = drop ~= nil and _G.LootDrops.ItemId(drop.id) or nil

    if id == nil then
        return "[" .. name .. "]"
    end

    return string.format("<Examine:IIDDID:0x%016X:0x%08X>[%s]<\\Examine>", 0, id, name)

end

-- the link for one item at one chest, when only the base name is to hand
function _G.LootDrops.ItemLinkAt(eventIndex, base)

    local drop = _G.LootDrops.DropRow(eventIndex, base)

    return _G.LootDrops.ItemLink(drop, _G.LootDrops.DisplayName(drop, base))

end

-- ------------------------------------------------------------------------------------------------
-- groups

-- Some items are one thing wearing many names. Every character gets a tracery from a chest, but
-- it is class-specific and rolled, so it arrives as "Stealth Movement Speed" or "Crit Chain
-- Skill Critical Chance" or one of dozens of others. Catalogued individually they read as a
-- pile of rare drops, when what actually happened is "a tracery dropped", near enough always.
--
-- So a row may declare `group = "Tracery"`. Grouping is DISPLAY AND STATISTICS, never matching:
-- every name still needs its own row or the parser will not recognise the drop at all. What
-- changes is that the popup and the browser show one line for the group, and the observed rate
-- sums its members -- which is the number that means something, because any member dropping is
-- the event "a tracery dropped".
-- TWO KINDS OF GROUP, and the difference is whether the members are worth naming.
--
--   "collapse"  the members are placeholders. Traceries: every character gets one, the name is
--               a class-specific roll out of dozens, and nobody wants a list of them. One row,
--               everywhere, and the individual names exist only so the parser recognises a drop
--               at all. This is the DEFAULT, because it is what grouping was built for.
--
--   "expand"    the members are real, wantable items that happen to share a bucket. Armour: the
--               chart gives one rate for "Fallen armour", but which piece dropped is exactly
--               what you care about. The browser shows a foldable row; the popup does not
--               collapse them at all, because "Fallen armour" is not what you just looted.
--
-- Declared per group in the drops data (_G.DropGroups), not per row: it is a property of the
-- group, and repeating it on every member is how the two halves drift apart.
function _G.LootDrops.GroupMode(group)

    if group == nil or group == "" then return nil end

    local declared = _G.DropGroups ~= nil and _G.DropGroups[group] or nil

    if declared ~= nil and declared.mode == "expand" then return "expand" end

    return "collapse"

end

function _G.LootDrops.GroupExpands(group)
    return _G.LootDrops.GroupMode(group) == "expand"
end

-- What to CALL a group on screen. Display only, exactly like an item's `label`: the key stays
-- whatever the data says, so `group = "Group 1"` on every member row goes on working and giving
-- a group a real name is one line in _G.DropGroups:
--
--     ["Group 1"] = { mode = "expand", label = "Fallen Armour" },
--
-- The label is per KEY, so it renames that group at every chest that uses the key. The export
-- numbers its groups per chest, which means one chest's "Group 1" is not another's -- so a name
-- that only fits one of them wants a new key on those rows rather than a label here.
function _G.LootDrops.GroupLabel(group)

    if group == nil or group == "" then return group end

    local declared = _G.DropGroups ~= nil and _G.DropGroups[group] or nil

    if declared ~= nil and declared.label ~= nil and declared.label ~= "" then
        return declared.label
    end

    return group

end

-- Everything a row can be found under, lowered ONCE at build time so a keystroke costs a find
-- and nothing else. A drop answers to the name the client prints AND to its label, because
-- whoever is searching knows it by one or the other and has no way to tell which this build
-- stores -- and for a group row, `item` is the key and `label` the name on screen, so both find
-- it either way.
function _G.LootDrops.SearchText(drop)

    if drop == nil then return "" end

    local text = string.lower(drop.item or "")

    if drop.label ~= nil and drop.label ~= "" then
        text = text .. "\0" .. string.lower(drop.label)
    end

    return text

end

-- Plain find, not a pattern: an item name may hold an apostrophe or a dash, and neither is a
-- search operator to anyone typing it.
local function Hit(text, search)
    return text ~= nil and string.find(text, search, 1, true) ~= nil
end

-- WHICH ROWS A SEARCH LEAVES STANDING. Pure, and about grouping rather than pixels, which is
-- why it lives here beside GroupMode: the rule is that a group answers for its members.
--
-- `rows` is the list the browser has already built, in display order, each entry carrying:
--
--   kind        "header" for a boss heading, anything else for a row
--   text        the row's own searchable names, from SearchText
--   memberText  a group's members' names, joined -- a group folded shut is the only row
--               standing in for them, so a member's name must find it
--   parent      index of a child's group entry -- a group matched by NAME keeps all its
--               children, and a child matched on its own pulls its group back in
--   header      index of the boss heading above the row, which shows only if something under
--               it survived
--
-- Returns a map of index -> shown. An empty search shows everything but the empty headings.
function _G.LootDrops.SearchFilter(rows, search)

    local show, named = {}, {}

    search = search or ""

    for index, entry in ipairs(rows) do

        if entry.kind == "header" then

            -- cleared on the way past, and lit again below by the first row under it that
            -- shows. One pass does it, because a heading is always built before its rows.
            show[index] = false

        elseif search == "" then

            show[index] = true

        elseif entry.isGroup then

            named[index] = Hit(entry.text, search)
            show[index]  = named[index] or Hit(entry.memberText, search)

        elseif entry.parent ~= nil then

            show[index] = Hit(entry.text, search) or named[entry.parent] == true

        else

            show[index] = Hit(entry.text, search)

        end

        if show[index] and entry.header ~= nil then
            show[entry.header] = true
        end

    end

    return show

end

function _G.LootDrops.GroupOf(eventIndex, base)

    local drop = _G.LootDrops.DropRow(eventIndex, base)

    if drop ~= nil and drop.group ~= nil and drop.group ~= "" then
        return drop.group
    end

    return nil

end

-- Every catalogued row of one group at one chest.
function _G.LootDrops.GroupMembers(eventIndex, group)

    local members = {}

    if _G.Drops == nil or group == nil then return members end

    for _, drop in ipairs(_G.Drops[eventIndex] or {}) do
        if drop.group == group then
            members[#members + 1] = drop
        end
    end

    return members

end

-- ------------------------------------------------------------------------------------------------
-- catalogue queries

-- The distinct tiers of one instance that actually have drops, LOWEST FIRST -- so the highest,
-- which is the one the browser opens on, is simply the last of them.
--
-- Data rather than window furniture, which is why it lives here: the answer comes out of
-- _G.Drops and _G.Events, the browser only draws pills for it.
function _G.LootDrops.TiersFor(instanceId)

    local seen, list = {}, {}

    if _G.Drops ~= nil then
        for eventIndex in pairs(_G.Drops) do
            local event = _G.Events[eventIndex]
            if event ~= nil and event.instance == instanceId then
                local tier = tostring(event.tier)
                if not seen[tier] then
                    seen[tier] = true
                    list[#list + 1] = tier
                end
            end
        end
    end

    table.sort(list, function(a, b)
        local orderA = (_G.TierOrder and _G.TierOrder[a]) or 99
        local orderB = (_G.TierOrder and _G.TierOrder[b]) or 99
        if orderA ~= orderB then return orderA < orderB end
        return a < b
    end)

    return list

end

-- How many distinct ITEMS one chest catalogues, which is what the table now shows: the rows
-- are entries, and a chest listing 308 of them for 91 items must not say 308 anywhere.
function _G.LootDrops.ItemCount(eventIndex)

    local seen, count = {}, 0

    for _, drop in ipairs((_G.Drops or {})[eventIndex] or {}) do
        -- the same two exclusions the table itself makes: a bucket row is the pool, and a
        -- collapse group is one row however many placeholder names it holds
        if not drop.bucket then
            local group = drop.group
            local key   = drop.item
            if group ~= nil and group ~= "" and _G.LootDrops.GroupMode(group) == "collapse" then
                key = group
            end
            if not seen[key] then
                seen[key] = true
                count     = count + 1
            end
        end
    end

    return count

end

-- ------------------------------------------------------------------------------------------------
-- chances

-- ONE NAME, SEVERAL CHANCES. A chest does not roll once: it rolls several tables, and an item
-- that sits in more than one of them is catalogued once per table it sits in. "Bright
-- Conscript's Necklace" has six rows at Kishâsu because six of that chest's rolls can produce
-- it, at 1.06%, 1.03%, 1.00%, 0.38%, 0.37% and 0.36%. Those are six separate chances, not one
-- repeated -- which is why they are printed as a series and why CombinedChance folds them.
--
-- Ungrouped items duplicate too, and that is the half that is easy to miss: "Silver Serpent" is
-- two rows at Kishâsu, so the key here is the NAME, never the group.
--
-- Sorted biggest first, which is the order both windows read them in.
local function ByChanceDescending(a, b)

    -- an unknown chance is not a small one, but it has to land somewhere: last, so the figures
    -- that ARE known lead. nil == nil returns false, which keeps the order weak and table.sort
    -- from throwing.
    if a.chance == b.chance then return false end
    if a.chance == nil then return false end
    if b.chance == nil then return true end

    return a.chance > b.chance

end

-- A BUCKET ROW IS THE POOL, NOT A THING IN IT. "?? Group 4" carries the rate of the whole
-- roll -- "gear: 5%" -- matches no chat line and has no id, so it is not an item and never
-- becomes one.
--
-- Which cuts two ways, and the second way is why this is a function rather than a `not
-- drop.bucket`:
--
--   asked about an ITEM   the pool's rate is not the item's, and adding it would hand every
--                         piece inside the pool the category's chance
--   asked about the POOL  the pool's rate IS the answer -- "Tracery" is exactly the category
--                         "?? Tracery" names, and its 100% is the number both windows show
--
-- So the entries of a group prefer its bucket rows where it has them, and fall back to its
-- members' own rates where it does not.
local function EntriesFor(eventIndex, canonical, groupKey)

    local own, pooled = {}, {}

    for _, drop in ipairs((_G.Drops or {})[eventIndex] or {}) do

        local isName  = (canonical ~= nil and drop.item == canonical)
        local isPool  = (groupKey  ~= nil and groupKey ~= "" and drop.group == groupKey)

        if isName or isPool then
            local entry = { chance = drop.chance, group = drop.group }
            if drop.bucket then
                -- only where the question WAS the pool; a bucket row asked about by its own
                -- name is still not an item
                if isPool then pooled[#pooled + 1] = entry end
            else
                own[#own + 1] = entry
            end
        end

    end

    local entries = (#pooled > 0) and pooled or own

    table.sort(entries, ByChanceDescending)

    return entries

end

-- Every entry one item has at one chest, biggest first.
--
-- A COLLAPSE GROUP ANSWERS FOR ITS MEMBERS. "Tracery" is not an item, has no row of its own and
-- no id; the entries it stands for are the category's, which is the same rule that gives it one
-- line in both windows. So a name that is a group key is answered with the group's entries.
function _G.LootDrops.ItemEntries(eventIndex, itemName)

    if _G.Drops == nil or itemName == nil then return {} end

    return EntriesFor(eventIndex, Canonical(itemName) or itemName, itemName)

end

-- The chance AT LEAST ONE entry hits: 1 - Π(1 - chance).
--
-- Not the sum: 70% and 10% is 73%, and adding them would put a six-pool item past 100% while
-- claiming a certainty the tables never gave. Not the biggest either: an item in six pools is
-- likelier than an item in one, and that difference is the whole point of the column.
--
-- nil when NOTHING is known, because an absent chance means "drops, rate not established" and
-- must never print as 0%. A nil among known ones is simply left out of the product.
--
-- Takes entries as ItemEntries returns them, or bare numbers, so a caller with a list of
-- chances does not have to dress them up first.
function _G.LootDrops.CombinedChance(entries)

    local product, known = 1, false

    for _, entry in ipairs(entries or {}) do

        local chance = entry
        if type(entry) == "table" then chance = entry.chance end

        if chance ~= nil then
            known   = true
            product = product * (1 - chance)
        end

    end

    if not known then return nil end

    return 1 - product

end

-- HOW A RATE IS WRITTEN, in one place, because the player sees the same number in two windows
-- and two spellings of it would read as two different figures.
--
-- Precision follows the size, not a fixed decimal count: 70% wants no decimals, 8.1% wants one,
-- and 0.76% is meaningless rounded to either. Three bands, and nothing under a tenth of a
-- percent has to be told apart from anything else -- the bar does that job.
--
-- nil in, nil out: an unknown rate is the caller's to draw as a dash. Never "0%", which would
-- claim knowledge the tables do not have.
function _G.LootDrops.FormatChance(chance)

    if chance == nil then return nil end

    local value = chance * 100

    if value >= 10 then return math.floor(value + 0.5) .. "%" end
    if value >= 1  then return string.format("%.1f%%", value) end

    return string.format("%.2f%%", value)

end

-- The series printed behind the lead figure: every entry, biggest first, without the per-cent
-- sign -- the column heading says what they are, and six "%" in a row is noise.
--
-- nil FOR A SINGLE ENTRY. One entry is the lead figure itself, and printing it twice on the
-- same line says nothing; the column simply stays empty, which is also how a row with no rate
-- at all draws.
function _G.LootDrops.EntrySeries(entries)

    if entries == nil or #entries < 2 then return nil end

    local parts = {}

    for _, entry in ipairs(entries) do
        local chance = entry
        if type(entry) == "table" then chance = entry.chance end
        if chance ~= nil then
            local value = chance * 100
            -- two decimals below ten, none above: the small ones are only distinguishable by
            -- their decimals, and "100.00" beside them is a column of noughts
            parts[#parts + 1] = (value >= 10) and tostring(math.floor(value + 0.5))
                                or string.format("%.2f", value)
        end
    end

    if #parts == 0 then return nil end

    return table.concat(parts, _G.Sep)

end

-- ONE ROW PER NAME, for one chest. The browser's table is built from this.
--
-- What comes out of the drops data is the game's own loot tables, near enough verbatim: one row
-- per (item, table it appears in). Listed that way a chest reads as three hundred rows for
-- ninety items, the same cloak eight lines apart at eight different rates, and no way to tell
-- from any one of them how likely the cloak actually is.
--
-- So the rows fold by NAME -- the same key the wishlist and the stats already use -- and each
-- surviving row carries:
--
--   entries   every chance that name had here, biggest first
--   any       those combined: the chance the item drops AT ALL from this chest
--
-- A COLLAPSE group still folds to one row under its own key, because its members are
-- placeholder names nobody wants listed -- that is a display rule about the group and it
-- survives the dedupe. An EXPAND group does not: its members are real, wantable items, and with
-- one row per name they no longer need a fold to stop repeating themselves.
--
-- Bucket rows follow EntriesFor's rule: dropped where they are a pool over listed items, kept
-- where the pool IS the row -- a collapsed "Tracery" is the category "?? Tracery" names, and
-- 100% is the honest figure for it.
--
-- Ordered for display: `any` descending, then the name as drawn. File order was never
-- meaningful, and a sorted table is what makes a wall of sub-1% rows readable.
function _G.LootDrops.Dedupe(rows)

    local out, byKey = {}, {}

    for _, drop in ipairs(rows or {}) do

        local group     = drop.group
        local collapsed = group ~= nil and group ~= ""
                          and _G.LootDrops.GroupMode(group) == "collapse"
        local key       = collapsed and group or drop.item

        -- a bucket row is a row of its own only where the pool IS the row it would make
        if not drop.bucket or collapsed then

            local seen = byKey[key]

            if seen == nil then

                -- The key is what everything else asks about this row: the wishlist, the
                -- observed rate, the search. For a group that is the group's own name, and it
                -- deliberately has no id and no quality -- a group is not an item and must not
                -- borrow one member's identity.
                seen = { item = key, entries = {} }

                if collapsed then
                    seen.isGroup     = true
                    seen.group       = group
                    seen.label       = _G.LootDrops.GroupLabel(group)
                    -- what the search has to find this row by: a folded group is the only row
                    -- standing in for its members, so a member's name must reach it
                    seen.memberNames = {}
                end

                byKey[key]    = seen
                out[#out + 1] = seen

            end

            if collapsed then
                seen.memberNames[#seen.memberNames + 1] = drop.item
            else
                -- the generated data repeats these on every entry of the same item, so the
                -- first non-nil one seen is the answer
                if seen.label   == nil then seen.label   = drop.label   end
                if seen.quality == nil then seen.quality = drop.quality end
                if seen.slot    == nil then seen.slot    = drop.slot    end
                if seen.id      == nil then seen.id      = drop.id      end
                if seen.plural  == nil then seen.plural  = drop.plural  end
                if seen.popup   == nil then seen.popup   = drop.popup   end
                if seen.group   == nil then seen.group   = drop.group   end
            end

            local entry = { chance = drop.chance, group = drop.group }

            if drop.bucket then
                -- EntriesFor's rule, kept in step: where a collapsed group has the pool's own
                -- rate, that rate is the group's -- the members' individual ones are its share
                -- of the same roll and would be counted twice
                seen.pooled = seen.pooled or {}
                seen.pooled[#seen.pooled + 1] = entry
            else
                seen.entries[#seen.entries + 1] = entry
            end

        end

    end

    for _, drop in ipairs(out) do

        if drop.pooled ~= nil then
            drop.entries = drop.pooled
            drop.pooled  = nil
        end

        table.sort(drop.entries, ByChanceDescending)
        drop.any = _G.LootDrops.CombinedChance(drop.entries)

    end

    table.sort(out, function(a, b)
        if a.any ~= b.any then
            -- an unknown rate sorts below every known one rather than above every small one
            if a.any == nil then return false end
            if b.any == nil then return true end
            return a.any > b.any
        end
        return _G.LootDrops.DisplayName(a, a.item) < _G.LootDrops.DisplayName(b, b.item)
    end)

    return out

end

-- ------------------------------------------------------------------------------------------------
-- display names

-- What the UI should call this item. `label` in the drops data replaces the client's own name
-- wherever the item is shown -- "[Blighted Shoulder-guards of Shadows]" reading as
-- "Burglar Red Shoulders", which is what people actually call it.
--
-- Display ONLY. Matching, _G.Drops keys, the wishlist and every stat still use the name the
-- client prints, because that is the only thing chat gives us to match on. Renaming the key
-- would break the lookup the moment the label was edited.
function _G.LootDrops.DisplayName(drop, fallback)

    if drop ~= nil and drop.label ~= nil and drop.label ~= "" then
        return drop.label
    end

    return fallback

end

-- the display name for one item at one chest, when only the base name is to hand
function _G.LootDrops.DisplayNameAt(eventIndex, base)

    return _G.LootDrops.DisplayName(_G.LootDrops.DropRow(eventIndex, base), base)

end

-- ------------------------------------------------------------------------------------------------
-- item kinds

-- WHAT SORT OF THING THIS IS. The numbers are an order -- jewellery, armour, currency, tracery,
-- rune -- written out rather than left to ipairs over a list.
--
-- THE POPUP NO LONGER SORTS ON IT. It did, and the order was wrong for the window: a ring and a
-- coat are told apart by looking at them, while how lucky either was is exactly what cannot be
-- seen, so the rows go rarest first (SortLoot). This stays because `/lootlogs kinds` reports it
-- and because the category half is how an unknown client category gets noticed and added.
_G.LootDrops.KIND = {
    JEWELLERY = 1,
    ARMOUR    = 2,
    CURRENCY  = 3,
    TRACERY   = 4,
    RUNE      = 5,
}

local KIND = _G.LootDrops.KIND

-- THE CLIENT KNOWS WHAT SLOT AN ITEM IS FOR, and it is a better answer than any reading of the
-- name: it is the game's own record, it does not care what language the name is in, and it does
-- not care what the name says. A barter token called "Blighted Warding Charm" is category 178
-- whatever a word list would make of "charm".
--
-- ItemInfo:GetCategory() is a number. The mapping of number to meaning is not in any published
-- API doc; these come from PrimePlugins/Bags/ItemCategories.lua, which carries a full dump of
-- them (its author's, read off a live client), and only the ones that land in one of OUR five
-- kinds are listed. Anything else -- essences, lootboxes, quest pieces, crafting mats -- is left
-- out ON PURPOSE and falls through to the name scan below, then to currency.
local CATEGORY_KIND = {

    [49]  = KIND.JEWELLERY,     -- Jewelry: ring, necklace, earring, bracelet, pocket

    -- armour, by the slot it goes in
    [3]   = KIND.ARMOUR,        -- Chest
    [5]   = KIND.ARMOUR,        -- Hands
    [6]   = KIND.ARMOUR,        -- Shoulders
    [7]   = KIND.ARMOUR,        -- Head
    [15]  = KIND.ARMOUR,        -- Legs
    [18]  = KIND.ARMOUR,        -- Armor
    [23]  = KIND.ARMOUR,        -- Feet
    [33]  = KIND.ARMOUR,        -- Shield
    [45]  = KIND.ARMOUR,        -- Back

    -- weapons ride with armour: the same answer to "can I wear this", and a sword filed under
    -- currency would read as a mistake where a sword among the gear does not
    [1]   = KIND.ARMOUR,        -- Bow
    [10]  = KIND.ARMOUR,        -- Dagger
    [12]  = KIND.ARMOUR,        -- Axe
    [24]  = KIND.ARMOUR,        -- Hammer
    [29]  = KIND.ARMOUR,        -- Crossbow
    [30]  = KIND.ARMOUR,        -- Mace
    [34]  = KIND.ARMOUR,        -- Staff
    [36]  = KIND.ARMOUR,        -- Halberd
    [40]  = KIND.ARMOUR,        -- Club
    [42]  = KIND.ARMOUR,        -- Weapon
    [44]  = KIND.ARMOUR,        -- Sword
    [46]  = KIND.ARMOUR,        -- Spear
    [110] = KIND.ARMOUR,        -- Javelin

    -- the class slot is worn too
    [4]   = KIND.ARMOUR,        -- Minstrel
    [13]  = KIND.ARMOUR,        -- Captain
    [17]  = KIND.ARMOUR,        -- Hunter
    [19]  = KIND.ARMOUR,        -- Loremaster
    [22]  = KIND.ARMOUR,        -- Champion
    [26]  = KIND.ARMOUR,        -- Guardian
    [48]  = KIND.ARMOUR,        -- Burglar
    [105] = KIND.ARMOUR,        -- Warden
    [106] = KIND.ARMOUR,        -- Runekeeper
    [288] = KIND.ARMOUR,        -- Brawler

    [178] = KIND.CURRENCY,      -- Barter

}

_G.LootDrops.CATEGORY_KIND = CATEGORY_KIND

-- The client's own record for a catalogued id, or nil.
--
-- Every step is pcall'd and every one of them may fail: an id may resolve to nothing, and OUT OF
-- THE GAME (the test suite) there is no Turbine.UI.Lotro to build a shortcut with at all. Nil is
-- the answer in every one of those cases, and every caller has a fallback, because an
-- uncatalogued or unresolvable id is common and is not an error.
--
-- The way in is Shortcut:GetItem() with the instance half of the payload ZEROED -- see
-- ShortcutData above -- which is what makes this work for an item nobody in the group owns.
function _G.LootDrops.ClientInfo(id)

    local number = _G.LootDrops.ItemId(id)
    if number == nil then return nil end

    local built, shortcut = pcall(function()
        return Turbine.UI.Lotro.Shortcut(_G.LootDrops.SHORTCUT_ITEM,
            string.format("0x%016X,0x%08X", 0, number))
    end)
    if not built or shortcut == nil then return nil end

    local gotItem, item = pcall(function() return shortcut:GetItem() end)
    if not gotItem or item == nil then return nil end

    local gotInfo, info = pcall(function() return item:GetItemInfo() end)
    if not gotInfo or info == nil then return nil end

    return info

end

-- The client's category NUMBER for an id, or nil when it could not be asked. Nil means "no
-- answer", never "no category" -- the difference decides whether a name-derived kind is worth
-- caching, so the two must not be collapsed.
local function CategoryOf(id)

    local info = _G.LootDrops.ClientInfo(id)
    if info == nil then return nil end

    local got, category = pcall(function() return info:GetCategory() end)
    if not got then return nil end

    return category

end

-- WHEN THE CLIENT HAS NOTHING TO SAY, read the name. That is the case for a row with no id, for
-- a group's own name (a group is not an item and has no id at all), and for anything the client
-- files somewhere our five kinds do not reach.
--
-- Which makes this half ENGLISH-SHAPED, and knowingly so. Item names are what the client prints,
-- so they are language-specific (Logs/Drops/German.lua and French.lua exist to translate them,
-- and are empty). A translated catalogue will need its own words here; until one exists, nothing
-- regresses, because a client with no drops data opens no popup -- and the category half above
-- needs no translating at all, which is the other reason it goes first.
--
-- Matched on WHOLE WORDS, first one that is known wins, left to right. That is what keeps the
-- suffixes out of it: "Blighted Gauntlets of Tempered Blades" is gauntlets, not blades, because
-- the head noun comes first -- and it is why no word that only ever appears in a suffix
-- ("guard", "storm", "hand") is listed, however armour-ish it sounds.
--
-- CURRENCY IS THE FALLBACK, not a list. Tokens, relics, coffers, essence boxes, trophies, worm
-- hides, quest pieces -- everything a chest hands over that is not worn and not slotted lands
-- here together, which is where a reader looks for it anyway.
local KIND_WORDS = {

    -- jewellery: the slots that are not armour
    ring        = KIND.JEWELLERY, rings       = KIND.JEWELLERY,
    necklace    = KIND.JEWELLERY, necklaces   = KIND.JEWELLERY,
    earring     = KIND.JEWELLERY, earrings    = KIND.JEWELLERY,
    bracelet    = KIND.JEWELLERY, bracelets   = KIND.JEWELLERY,
    bauble      = KIND.JEWELLERY, baubles     = KIND.JEWELLERY,
    amulet      = KIND.JEWELLERY, pendant     = KIND.JEWELLERY,
    brooch      = KIND.JEWELLERY, choker      = KIND.JEWELLERY,
    locket      = KIND.JEWELLERY, torc        = KIND.JEWELLERY,
    band        = KIND.JEWELLERY,   -- "Oasis Ghost's Band" is a ring by another name

    -- armour, and weapons with it: they are the same answer to "can I wear this", and a sword
    -- filed under currency would read as a mistake where a sword among the gear does not
    helm        = KIND.ARMOUR, helmet      = KIND.ARMOUR, hood      = KIND.ARMOUR,
    mask        = KIND.ARMOUR, circlet     = KIND.ARMOUR, cap       = KIND.ARMOUR,
    coat        = KIND.ARMOUR, shirt       = KIND.ARMOUR, robe      = KIND.ARMOUR,
    jacket      = KIND.ARMOUR, hauberk     = KIND.ARMOUR, armour    = KIND.ARMOUR,
    breastplate = KIND.ARMOUR, plate       = KIND.ARMOUR, harness   = KIND.ARMOUR,
    leggings    = KIND.ARMOUR, greaves     = KIND.ARMOUR, trousers  = KIND.ARMOUR,
    breeches    = KIND.ARMOUR, skirt       = KIND.ARMOUR, fauld     = KIND.ARMOUR,
    boots       = KIND.ARMOUR, shoes       = KIND.ARMOUR, sandals   = KIND.ARMOUR,
    gloves      = KIND.ARMOUR, gauntlets   = KIND.ARMOUR, mitts     = KIND.ARMOUR,
    cuffs       = KIND.ARMOUR, bracers     = KIND.ARMOUR, vambraces = KIND.ARMOUR,
    cops        = KIND.ARMOUR, pauldrons   = KIND.ARMOUR, spaulders = KIND.ARMOUR,
    shoulder    = KIND.ARMOUR, shoulders   = KIND.ARMOUR, mantle    = KIND.ARMOUR,
    cloak       = KIND.ARMOUR, cape        = KIND.ARMOUR, shield    = KIND.ARMOUR,
    targe       = KIND.ARMOUR, buckler     = KIND.ARMOUR, belt      = KIND.ARMOUR,
    sash        = KIND.ARMOUR, girdle      = KIND.ARMOUR,
    sword       = KIND.ARMOUR, blade       = KIND.ARMOUR, axe       = KIND.ARMOUR,
    hammer      = KIND.ARMOUR, mace        = KIND.ARMOUR, club      = KIND.ARMOUR,
    dagger      = KIND.ARMOUR, spear       = KIND.ARMOUR, halberd   = KIND.ARMOUR,
    javelin     = KIND.ARMOUR, bow         = KIND.ARMOUR, crossbow  = KIND.ARMOUR,
    staff       = KIND.ARMOUR,

    tracery     = KIND.TRACERY, traceries = KIND.TRACERY,

    rune        = KIND.RUNE,    runes     = KIND.RUNE,

}

-- Names repeat across chests and the popup re-sorts on every rebuild, so the scan is done once
-- per name. Keyed on the name itself: the table is bounded by the catalogue.
local kindOf = {}

-- The kind of one item: THE CLIENT'S SLOT FIRST, the name only when it has nothing to say.
--
-- `id` is the drops row's item id and is optional -- pass it whenever there is one, because it
-- is the half that is actually authoritative. Given a group's NAME and no id it answers for the
-- group ("Tracery" is a tracery), which is what the popup needs: a collapsed group is one line
-- under its own name, and a group is not an item.
function _G.LootDrops.ItemKind(name, id)

    if name == nil or name == "" then return KIND.CURRENCY end

    local cached = kindOf[name]
    if cached ~= nil then return cached end

    -- ASKED FIRST, and it wins outright. The client is describing the item; the words below are
    -- describing the label on it.
    local category = (id ~= nil) and CategoryOf(id) or nil
    local kind     = (category ~= nil) and CATEGORY_KIND[category] or nil

    -- WHETHER THIS ANSWER IS WORTH KEEPING. An id the client could not answer for is not the
    -- same as an item it places outside our kinds: the first can happen because the item table
    -- is not ready yet -- early in a session -- and caching a name-derived kind then would keep
    -- the wrong answer for the rest of the session.
    local settled = (id == nil) or (category ~= nil)

    if kind == nil then

        local lowered = string.lower(name)

        -- A rune-keeper's rune-stone is a weapon, and it is the one name where the word "rune"
        -- means something other than the levelling item. Asked before the scan, because the scan
        -- reads left to right and "rune" comes first.
        if string.find(lowered, "rune%-stone") ~= nil then

            kind = KIND.ARMOUR

        else

            for word in string.gmatch(lowered, "%a+") do
                kind = KIND_WORDS[word]
                if kind ~= nil then break end
            end

        end

        kind = kind or KIND.CURRENCY

    end

    if settled then kindOf[name] = kind end

    return kind

end

-- The client's category number for an id, and the kind it maps to (nil where it maps to none).
-- For the `kinds` probe, which is how the table above gets extended: the numbers are documented
-- nowhere, so the only way to add one is to read it off a live client.
function _G.LootDrops.ItemCategory(id)

    local category = CategoryOf(id)

    return category, category ~= nil and CATEGORY_KIND[category] or nil

end

-- HOW THE POPUP ORDERS ITS ROWS. Pure and testable, which is why it lives here rather than in
-- the window: the rule is about what the items ARE, and the window only draws the result.
--
-- Sorted in place. Each entry is { item = { base, player, ... }, logIndex = <chest> }, the shape
-- LootPopup:SelectedItems builds.
--
-- Three blocks, in this order, and inside every one of them the same two keys:
--
--   1. WISHLISTED. The popup opens on its own and is read in a second; the one thing it must
--      never do is put what you have been waiting for below the fold.
--   2. YOURS. What you walked away with is the second question anyone asks of a chest, and
--      hunting for it among five other people's rows is what the block is there to stop.
--   3. EVERYONE ELSE'S.
--
-- then, within each block:
--
--   a. RAREST FIRST, by the same combined chance the row prints. Chat order is arrival order,
--      which is near-random within a frame and tells the reader nothing, and kind -- what this
--      sorted by before -- answers a question nobody asks of a chest: you know a ring is a ring
--      by looking at it. How lucky it was is the thing you cannot see, it is the reason the
--      window is worth reading at all, and it puts the 0.8% drop above the 100% one instead of
--      four rows below it.
--   b. A-Z on the name as drawn, so a pool of items sharing one rate reads the same way every
--      time -- six rings at 1.5% would otherwise be dealt in a different order per rebuild.
--
-- AN UNKNOWN RATE SORTS LAST in its block, never first: "no rate established" is not evidence of
-- rarity, and leading the window with it would promise something the tables never said.
--
-- WHOSE IT IS SEPARATES THE BLOCKS; WHAT THEIR NAME IS ORDERS NOTHING. "Yours" is one bit, and
-- it earns its place. Sorting the rest by looter name -- at any depth, including to break a tie
-- -- is a different thing, and it interleaved six people's names where the items should have
-- been. Ties fall to arrival order instead.
-- WHICH LOOT A POPUP SEARCH LEAVES STANDING. Pure, and beside the sort for the same reason: the
-- rule is about the items, and the window only draws the result.
--
-- Matched against the NAME AS DRAWN and the LOOTER, because those are the two columns on a row
-- and either is a thing you would type. "ring" finds the rings; "ramor" finds what Ramor took.
-- Plain find, not a pattern -- an item name holds apostrophes and dashes, and neither is a
-- search operator to anyone typing one.
--
-- Returns a NEW list, in the order it was given. An empty search returns everything.
function _G.LootDrops.FilterLoot(items, search)

    search = string.lower(search or "")

    if search == "" then return items end

    local out = {}

    for _, entry in ipairs(items) do

        local name   = _G.LootDrops.DisplayNameAt(entry.logIndex, entry.item.base)
        local player = entry.item.player or ""

        if string.find(string.lower(name), search, 1, true) ~= nil
        or string.find(string.lower(player), search, 1, true) ~= nil then
            out[#out + 1] = entry
        end

    end

    return out

end

function _G.LootDrops.SortLoot(items)

    -- Decorated first: the comparator runs O(n log n) times, and both the name and the kind are
    -- lookups. Sorting on fields the entry already carries also keeps the comparator readable.
    for index, entry in ipairs(items) do

        -- The row for the name as CAPTURED. A collapsed group has no row of its own and answers
        -- by its name, which is why the chance is asked for by NAME rather than read off a row.
        local drop = _G.LootDrops.DropRow(entry.logIndex, entry.item.base)

        entry.sortName   = _G.LootDrops.DisplayName(drop, entry.item.base)
        -- the number the row prints, so the list is sorted by what the player can see
        entry.sortChance = _G.LootDrops.CombinedChance(
            _G.LootDrops.ItemEntries(entry.logIndex, entry.item.base))
        entry.wished     = _G.LootDrops.IsWished(entry.logIndex, entry.item.base)
        entry.sortIndex  = index    -- arrival order, kept only to break a tie
    end

    table.sort(items, function(a, b)

        if a.wished ~= b.wished then
            return a.wished
        end

        -- the second block. isSelf may be nil on a row nobody claimed, so it is compared as a
        -- boolean rather than passed through -- nil and false must not sort apart.
        local mine, theirs = a.item.isSelf == true, b.item.isSelf == true
        if mine ~= theirs then
            return mine
        end

        -- rarest first, and an unknown rate at the back of its block
        if a.sortChance ~= b.sortChance then
            if a.sortChance == nil then return false end
            if b.sortChance == nil then return true end
            return a.sortChance < b.sortChance
        end

        if a.sortName ~= b.sortName then
            return a.sortName < b.sortName
        end

        -- WHO LOOTED IT IS NOT A SORT KEY, at any depth. Two people taking the same item are
        -- two identical rows but for a name in the last column, and ordering those by that name
        -- is the looter sort creeping back in through the tie.
        --
        -- The tie still has to be broken by SOMETHING, or table.sort -- which is not stable --
        -- deals them differently on every rebuild and the block flickers. Arrival order does it:
        -- it is what chat already showed, and it is not a judgement about anybody.
        return a.sortIndex < b.sortIndex

    end)

    return items

end

-- THE POPUP'S THREE BLOCKS, decided here rather than in the window: it is a rule about whose
-- loot a row is, the same question SortLoot already asks, and it is the one the flat list got
-- wrong. Returns three lists in the order they are drawn, each keeping the order it was given.
--
--   starred      on the wishlist, WHOEVER WON IT
--   yours        what you took
--   fellowship   everyone else's
--
-- Starred wins over yours, so an item is in exactly one block and never listed twice. The case
-- that matters is the one the old window buried: a drop you had been waiting for going to
-- somebody else was sorted below your own loot, in the same colour as everyone's trash, when it
-- is the single most interesting line the chest can produce.
function _G.LootDrops.PartitionLoot(items)

    local starred, yours, fellowship = {}, {}, {}

    for _, entry in ipairs(items or {}) do

        if _G.LootDrops.IsWished(entry.logIndex, entry.item.base) then
            starred[#starred + 1] = entry
        elseif entry.item.isSelf then
            yours[#yours + 1] = entry
        else
            fellowship[#fellowship + 1] = entry
        end

    end

    return starred, yours, fellowship

end

-- Is this drop worth showing in the popup? The `popup` flag lives in the drops data so the
-- answer is per item per chest, and it is a DISPLAY filter only -- LootStats still counts
-- every catalogued drop, so filtering here cannot skew an observed rate.
function _G.LootDrops.IsPopupItem(eventIndex, name)

    local drop = _G.LootDrops.DropRow(eventIndex, name)

    return drop ~= nil and drop.popup == true

end

-- A chest with nothing flagged opens no popup at all. Showing an empty window on every chest
-- is exactly the noise the flag exists to remove.
function _G.LootDrops.HasPopupItems(chest)

    for _, item in ipairs(chest.items) do
        if _G.LootDrops.IsPopupItem(chest.logIndex, item.base) then
            return true
        end
    end

    return false

end

-- Is this drop on the wishlist, EITHER by its own name or by the group it belongs to?
--
-- Both count, and the group half is the one that is easy to forget: a tracery's name is a
-- rolled detail nobody wishes for, so starring "Tracery" has to mean starring every tracery.
-- One helper because three places ask the question -- whether to open the popup, whether to
-- draw the star on a row, and where that row sorts -- and they must never disagree.
function _G.LootDrops.IsWished(eventIndex, base)

    if _G.LootStats == nil then return false end

    if _G.LootStats.IsWished(base) then return true end

    local group = _G.LootDrops.GroupOf(eventIndex, base)

    return group ~= nil and _G.LootStats.IsWished(group)

end

-- Three gates, narrowing: the popup is on at all, this chest dropped something flagged, and --
-- if the player asked for it -- one of those was on their wishlist.
function _G.LootDrops.ShouldShowPopup(chest)

    if _G.Settings.showLootPopup == false then return false end
    if not _G.LootDrops.HasPopupItems(chest) then return false end

    if _G.Settings.lootPopupWishOnly ~= true then return true end

    -- wishlist-only, and the wishlist lives in LootStats
    if _G.LootStats == nil then return false end

    for _, item in ipairs(chest.items) do
        if _G.LootDrops.IsPopupItem(chest.logIndex, item.base)
            and _G.LootDrops.IsWished(chest.logIndex, item.base) then
            return true
        end
    end

    return false

end

-- the _G.Drops row for one item at one chest, or nil
function _G.LootDrops.DropRow(eventIndex, name)

    if alias == nil then BuildIndex() end

    local canonical = alias[name] or name
    local byName    = dropOf[eventIndex]

    return byName and byName[canonical] or nil

end

-- data files are loaded before this one, but a reload of the drops table during development
-- should not need a full plugin restart
function _G.LootDrops.RebuildIndex()
    alias, events, dropOf = nil, nil, nil
end

-- ------------------------------------------------------------------------------------------------
-- name normalisation

-- "3 Damaged Mûrai Artifacts"      -> "Damaged Mûrai Artifacts", nil, 3
-- "1,000 Ancient Script"           -> "Ancient Script",          nil, 1000
-- "Enhancement Rune +1, Lvl 151"   -> "Enhancement Rune +1",     151, 1
--
-- The level is display metadata: the same drop reads a different level on another character,
-- so the drops table keys on the name alone. The count is real information and is returned to
-- the caller rather than thrown away -- three artifacts are three.
--
-- A COUNT OVER 999 IS GROUPED. The client prints "[1,000 Ancient Script]", so a bare "%d+"
-- stops at the "1" and the separator keeps the name from ever matching -- the stack is silently
-- read as one of an item called "1,000 Ancient Script", which is catalogued nowhere. Both the
-- comma and the full stop are accepted, because which one a client uses is a language setting
-- (Loot_20260810_1.txt). The separators are then stripped and the digits read as one number.
--
-- The leading run must be digits and separators ONLY, and must be followed by a space, so a
-- name that merely starts with a digit is left alone: "1st Age ..." fails at the "s".
--
-- Plural is NOT resolved here. It cannot be done by rule (the plural falls on the head noun,
-- "Badges of Forgotten Rank") and any rule would be language-specific. Canonical() resolves it
-- from the data instead.
function _G.LootDrops.Normalise(raw)

    if raw == nil then return nil, nil, 1 end

    local quantity = 1

    local count, rest = string.match(raw, "^(%d[%d,%.]*)%s+(.+)$")
    if count ~= nil then
        quantity = tonumber((string.gsub(count, "[^%d]", ""))) or 1
        raw      = rest
    end

    local base, level = string.match(raw, "^(.-), Lvl (%d+)$")

    return base or raw, tonumber(level), quantity

end

-- ------------------------------------------------------------------------------------------------
-- the buffer, and the chest waiting on its window

local buffer  = {}
local pending = nil
local newRun  = false       -- a run started; the next resolved chest opens a fresh one

local ticker  = nil         -- only runs while a chest is pending

local function Now()
    return Turbine.Engine.GetGameTime()
end

-- Age, not count. A 40-entry cap held well under a second of a six-man run, which would have
-- let the forward window read a buffer that had already discarded what it wanted.
local function Prune(now)

    local horizon = now - BackWindow() - 2

    local kept = {}
    for _, item in ipairs(buffer) do
        if item.t >= horizon then
            kept[#kept + 1] = item
        end
    end

    while #kept > BUFFER_MAX do
        table.remove(kept, 1)
    end

    buffer = kept

end

-- Unclaimed loot from the buffer at or after `since`.
--
-- `claimed` is what stops two chests counting one line twice. A timestamp cut-off is not
-- enough: a chest's FORWARD window reaches past its own timestamp, so a second chest opened
-- half a second later would find those lines sitting in the buffer, later than the first
-- chest's time, and take them as well.
local function Since(since)

    local items = {}

    for _, item in ipairs(buffer) do
        if item.t >= since and not item.claimed then
            items[#items + 1] = item
        end
    end

    return items

end

local function Claim(items)

    for _, item in ipairs(items) do
        item.claimed = true
    end

    return items

end

-- ------------------------------------------------------------------------------------------------
-- chat

-- Called from ChatParsing for SelfLoot (36) and FellowLoot (37) only. Those types are
-- discarded by the filter below the call site; this runs before it.
function _G.LootDrops.HandleChat(chatType, message)

    local player, raw, isSelf

    raw = string.match(message, P.lootSelf)
    if raw ~= nil then
        player = _G.name
        isSelf = true
    else
        player, raw = string.match(message, P.lootOther)
        isSelf = false
    end

    if raw == nil then return end

    local base, level, quantity = _G.LootDrops.Normalise(raw)

    -- everything not in the drops database is dropped silently, by design. This is also what
    -- keeps trash loot out: one run produced 240 sightings of a single uncatalogued item.
    local canonical = Canonical(base)
    if canonical == nil then return end

    local entry = {
        base     = canonical,
        level    = level,
        quantity = quantity,
        player   = player,
        isSelf   = isSelf,
        id       = string.match(message, EXAMINE_ID),
        t        = Now(),
    }

    buffer[#buffer + 1] = entry
    Prune(entry.t)

    -- A chest is open and this line landed inside its forward window, so it belongs to that
    -- chest. Assigning here rather than re-reading the buffer at resolve time means the
    -- buffer only ever has to outlive the BACKWARD window.
    if pending ~= nil and entry.t <= pending.deadline then
        entry.claimed = true
        pending.items[#pending.items + 1] = entry
    end

end

-- ------------------------------------------------------------------------------------------------
-- chest resolution

local function StopTicker()

    if ticker ~= nil then
        ticker:SetWantsUpdates(false)
        ticker = nil
    end

end

-- THE ITEM LIST IS THE POPUP'S JOB WHEN THE POPUP OPENS.
--
-- Chat has already printed every one of these lines once -- the game itself prints "X has
-- acquired [Y]", which is where this data came from -- so an itemised re-print is the same
-- text a third time when a window is showing it too.
--
-- What is NOT redundant is the header: which chest, which boss, which tier, how much of it
-- was yours. The game never says that, and chat scrollback outlives the popup, so it stays
-- either way.
--
-- The list is still printed when no popup opened -- the popup switched off, nothing in this
-- chest flagged worth one, or the wishlist filter held it back. Then chat is the only place
-- the plugin's view of the chest exists, and silence would read as "nothing was recorded".
local function Announce(chest, popupShown)

    local event    = chest.event
    local instance = _G.Instances[chest.instance]

    local mine = 0
    for _, item in ipairs(chest.items) do
        if item.isSelf then mine = mine + 1 end
    end

    _G.PrintAlert(
        _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
        " " .. event.name ..
        " " .. _G.CM("DIM") .. "(" .. tostring(event.tier) .. ")" .. _G.CMR ..
        "  " .. #chest.items .. " " .. (#chest.items == 1 and "drop" or "drops") ..
        "  " .. _G.CM("ACCENT") .. mine .. " yours" .. _G.CMR
    )

    if popupShown then return end

    for _, item in ipairs(chest.items) do
        local quantity = item.quantity > 1 and (item.quantity .. "x ") or ""
        local who      = item.isSelf and (_G.CM("ACCENT") .. "you" .. _G.CMR)
                                     or  (_G.CM("DIM") .. item.player .. _G.CMR)
        _G.PrintAlert(
            _G.CM("DIM") .. "· " .. _G.CMR ..
            quantity .. _G.LootDrops.ItemLinkAt(chest.logIndex, item.base) ..
            "  " .. who
        )
    end

end

local function Resolve()

    if pending == nil then return end

    local chest = pending
    pending = nil
    StopTicker()

    -- A run is one VISIT to an instance, not every visit to it. Entering starts a new one --
    -- otherwise running the same instance twice, which is the normal thing to do with a daily
    -- lockout, appends the second run's chests to the first: "Full run" would list both, and a
    -- boss chip would show loot from the previous clear.
    local run = _G.LootDrops.currentRun
    if run == nil or newRun or run.instance ~= chest.instance then
        run = { instance = chest.instance, tier = chest.tier, t0 = chest.t, chests = {} }
        _G.LootDrops.currentRun = run
    end
    newRun = false
    run.tier = chest.tier
    run.chests[#run.chests + 1] = chest

    if _G.LootStats ~= nil then
        _G.LootStats.RecordChest(chest)
    end

    -- decided BEFORE announcing, because it is what the announcement leaves out
    local popupShown = _G.LootPopupWindow ~= nil and _G.LootDrops.ShouldShowPopup(chest)

    Announce(chest, popupShown)

    if popupShown then
        _G.LootPopupWindow:ShowChest(chest)
    end

end

-- An instance was entered. Called from ChatParsing when a line matches an _G.InstanceEntries
-- row -- every instance gives out a quest on entry, and that quest is specific to the instance
-- and the tier, so the row supplies both.
--
-- This is the only signal that a run BEGAN, as opposed to that a chest was looted, and without
-- it a second visit to the same instance silently continues the first one's run.
--
-- The arguments are recorded but not acted on: the run's instance and tier come from the chest
-- event, which is authoritative. They are here for the caller that wants to know where it is
-- before anything has been looted.
function _G.LootDrops.OnRunStart(instance, tier)

    newRun = true

    _G.LootDrops.enteredInstance = instance
    _G.LootDrops.enteredTier     = tier

end

-- Called from ProcessMatch once the chest event is known. logIndex indexes _G.Events, which
-- already carries the boss name, the tier and the instance -- there is no detection to do.
function _G.LootDrops.OnChestEvent(logIndex, message)

    local event = _G.Events[logIndex]
    if event == nil then return end

    -- nothing catalogued for this chest: no popup, no error, no noise
    if _G.Drops == nil or _G.Drops[logIndex] == nil then return end

    -- two chests looted back to back: settle the first now
    if pending ~= nil then Resolve() end

    local now = Now()

    pending = {
        logIndex = logIndex,
        event    = event,
        instance = event.instance,
        tier     = event.tier,
        t        = now,
        deadline = now + ForwardWindow(),
        items    = Claim(Since(now - BackWindow())),
    }

    if ticker == nil then
        ticker = Turbine.UI.Control()
        ticker.Update = function()
            _G.LootDrops.Update()
        end
        ticker:SetWantsUpdates(true)
    end

end

-- Driven from the update tick, which only runs while a chest is pending.
function _G.LootDrops.Update()

    if pending == nil then
        StopTicker()
        return
    end

    if Now() >= pending.deadline then
        Resolve()
    end

end

-- Settle anything still open, so a chest looted a second before /plugins unload is not lost.
function _G.LootDrops.Flush()

    if pending ~= nil then
        Resolve()
    end

end
