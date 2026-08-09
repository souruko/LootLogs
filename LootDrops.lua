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

    return string.format("0x%016X,0x%08X", 0, drop.id)

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
            and _G.LootStats.IsWished(item.base) then
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
-- "Enhancement Rune +1, Lvl 151"   -> "Enhancement Rune +1",     151, 1
--
-- The level is display metadata: the same drop reads a different level on another character,
-- so the drops table keys on the name alone. The count is real information and is returned to
-- the caller rather than thrown away -- three artifacts are three.
--
-- Plural is NOT resolved here. It cannot be done by rule (the plural falls on the head noun,
-- "Badges of Forgotten Rank") and any rule would be language-specific. Canonical() resolves it
-- from the data instead.
function _G.LootDrops.Normalise(raw)

    if raw == nil then return nil, nil, 1 end

    local quantity = 1

    local count, rest = string.match(raw, "^(%d+)%s+(.+)$")
    if count ~= nil then
        quantity = tonumber(count) or 1
        raw      = rest
    end

    local base, level = string.match(raw, "^(.-), Lvl (%d+)$")

    return base or raw, tonumber(level), quantity

end

-- ------------------------------------------------------------------------------------------------
-- the buffer, and the chest waiting on its window

local buffer  = {}
local pending = nil

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

local function Announce(chest)

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

    for _, item in ipairs(chest.items) do
        local quantity = item.quantity > 1 and (item.quantity .. "x ") or ""
        local who      = item.isSelf and (_G.CM("ACCENT") .. "you" .. _G.CMR)
                                     or  (_G.CM("DIM") .. item.player .. _G.CMR)
        _G.PrintAlert(
            _G.CM("DIM") .. "· " .. _G.CMR ..
            quantity .. _G.LootDrops.DisplayNameAt(chest.logIndex, item.base) ..
            "  " .. who
        )
    end

end

local function Resolve()

    if pending == nil then return end

    local chest = pending
    pending = nil
    StopTicker()

    -- A run is one visit to one instance. A different instance starts a new one.
    local run = _G.LootDrops.currentRun
    if run == nil or run.instance ~= chest.instance then
        run = { instance = chest.instance, tier = chest.tier, t0 = chest.t, chests = {} }
        _G.LootDrops.currentRun = run
    end
    run.tier = chest.tier
    run.chests[#run.chests + 1] = chest

    if _G.LootStats ~= nil then
        _G.LootStats.RecordChest(chest)
    end

    Announce(chest)

    if _G.LootPopupWindow ~= nil and _G.LootDrops.ShouldShowPopup(chest) then
        _G.LootPopupWindow:ShowChest(chest)
    end

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
