--=================================================================================================
--= Loot Drops tests
--= ===============================================================================================
--= Run from the plugin root with a desktop Lua:
--=
--=     lua tests/run.lua
--=
--= These are NOT loaded by the game -- nothing imports them from Main.lua, so the folder is
--= inert in the client. They exist because every rule in the loot feature was derived from
--= captured chat, and a rule derived from evidence should fail loudly when someone edits it
--= back to what it "obviously" ought to be.
--=
--= Every sample below is real, captured through /lootlogs probe. Provenance for each is in
--= docs/design/loot-drops/reference/chat-samples.txt.
--=================================================================================================

local passed, failed = 0, 0

local function check(name, got, want)
    if got == want then
        passed = passed + 1
    else
        failed = failed + 1
        print(string.format("  FAIL  %s\n          got:  %s\n          want: %s",
            name, tostring(got), tostring(want)))
    end
end

local function section(title)
    print("\n" .. title)
end

-- ------------------------------------------------------------------------------------------------
-- enough Turbine to load the real files

local CLOCK = 0
local printed = {}

Turbine = {
    Engine = {
        GetGameTime  = function() return CLOCK end,
        GetLocalTime = function() return 1000000 end,
    },
    UI = {
        Control = function() return { SetWantsUpdates = function() end } end,
    },
    Shell = { WriteLine = function(s) printed[#printed + 1] = s end },
}

_G.Settings   = { lootWindowBackTenths = 10, lootWindowFwdTenths = 40, printAlerts = true }
_G.name       = "Beorwyn"
_G.CM         = function() return "" end
_G.CMR        = ""
_G.Sep        = " - "
_G.PrintAlert = function(s) printed[#printed + 1] = s end
_G.Instances  = { [51] = { name = "Pagru-kirit, the Garden of Corpses", content = 11 } }
_G.Events     = {
    [546] = { name = "Kishasu",  tier = "T1", instance = 51, order = 1 },
    [545] = { name = "Khardamu", tier = "T1", instance = 51, order = 2 },
    [544] = { name = "Sudugul",  tier = "T1", instance = 51, order = 3 },
}
import = function() end

dofile("Logs/Drops/English.lua")
dofile("LootDrops.lua")

-- ------------------------------------------------------------------------------------------------
section("Item shortcut data  (dragged onto the row quickslot, live client)")

-- LL item  row: Enhancement Rune +1  type: 2  data: 0x034500025967C53A,0x700713ED  name: ?
--
-- The payload is a PAIR: the live instance GUID of the specific item in the bag, then the item
-- id itself. The second half is the same id the chat link carries --
--   <Examine:IIDDID:0x0000000000000000:0x700713ED>[Enhancement Rune +1, Lvl 151]
-- and CONFIRMED IN THE CLIENT: a shortcut built with the instance half zeroed resolves, so the
-- item id alone draws a real icon and tooltip, even for an item nobody owns. `name` came back
-- nil, so a Shortcut does not answer GetName here.
local SHORTCUT_DATA = "0x034500025967C53A,0x700713ED"
local SHORTCUT_TYPE = 2

local instanceGuid, itemId = string.match(SHORTCUT_DATA, "^(0x%x+),(0x%x+)$")

check("shortcut data splits into two hex halves", instanceGuid ~= nil and itemId ~= nil, true)
check("instance guid half",                      instanceGuid, "0x034500025967C53A")
check("item id half",                            itemId,       "0x700713ED")
check("shortcut type is Item(2)",                SHORTCUT_TYPE, 2)

-- The point of the whole exercise: the id the client uses in a shortcut is the id we already
-- store from chat. If someone edits that id in the drops table, this fails.
local rune = nil
for _, drop in ipairs(_G.Drops[546]) do
    if drop.item == "Enhancement Rune +1" then rune = drop end
end
check("drops table holds the same item id", string.format("0x%08X", rune.id), "0x700713ED")

-- The stored form ZEROES the instance half. A string captured verbatim from a drag works too,
-- but only until that exact item leaves the bag, so it is never what gets stored.
local data = _G.LootDrops.ShortcutData(rune)
check("shortcut zeroes the instance half", data, "0x0000000000000000,0x700713ED")
check("shortcut carries the item id",
    string.match(data, ",(0x%x+)$"), string.format("0x%08X", rune.id))

-- the item half of a real captured payload is the id we store, which is why zeroing works
check("captured payload's item half is the stored id",
    string.match(SHORTCUT_DATA, ",(0x%x+)$"), string.format("0x%08X", rune.id))

local serpent = nil
for _, drop in ipairs(_G.Drops[546]) do
    if drop.item == "Silver Serpent" then serpent = drop end
end
check("any id yields a shortcut",
    _G.LootDrops.ShortcutData(serpent), "0x0000000000000000,0x70073138")

-- a row with no id offers nothing rather than a malformed string; it just shows an empty slot
local necklace = nil
for _, drop in ipairs(_G.Drops[546]) do
    if drop.item == "Ornate Conscript's Necklace" then necklace = drop end
end
check("no id yields nil",    _G.LootDrops.ShortcutData(necklace), nil)
check("nil drop yields nil", _G.LootDrops.ShortcutData(nil),      nil)
check("shortcut type constant",           _G.LootDrops.SHORTCUT_ITEM,          SHORTCUT_TYPE)

-- ------------------------------------------------------------------------------------------------
section("Display label  (renames the item on screen, never the key)")

local labelled = { item = "Blighted Shoulder-guards of Shadows",
                   label = "Burglar Red Shoulders", id = 0x700713ED }
local plainRow = { item = "Toll Copper" }

check("label replaces the shown name",
    _G.LootDrops.DisplayName(labelled, labelled.item), "Burglar Red Shoulders")
check("no label falls back to the client name",
    _G.LootDrops.DisplayName(plainRow, plainRow.item), "Toll Copper")
check("nil drop falls back",
    _G.LootDrops.DisplayName(nil, "Silver Serpent"), "Silver Serpent")
check("empty label is not a rename",
    _G.LootDrops.DisplayName({ item = "x", label = "" }, "x"), "x")

-- the key is untouched: the label must not affect matching, or a rename would silently stop
-- the parser recognising the item
check("label does not become a lookup key", _G.LootDrops.Canonical("Burglar Red Shoulders"), nil)
check("catalogued name still resolves",
    _G.LootDrops.Canonical("Toll Copper"), "Toll Copper")

-- a labelled row still keys its shortcut off the real id
check("label does not disturb the shortcut",
    _G.LootDrops.ShortcutData(labelled), "0x0000000000000000,0x700713ED")

-- ------------------------------------------------------------------------------------------------
section("Loot line patterns  (both link forms, from the live client)")

local function parse(message)
    local raw = string.match(message, _G.LootDrops.P.lootSelf)
    if raw ~= nil then return "you", raw end
    local player, other = string.match(message, _G.LootDrops.P.lootOther)
    if other ~= nil then return player, other end
    return nil, nil
end

-- Examine link: an item you do NOT hold, or your own while still (pending)
local who, raw = parse(
    "You have acquired: <Examine:IIDDID:0x0000000000000000:0x700713ED>" ..
    "[Enhancement Rune +1, Lvl 151]<\\Examine> (pending).")
check("self, Examine link, looter", who, "you")
check("self, Examine link, item",   raw, "Enhancement Rune +1, Lvl 151")

-- ExamineItemInstance link: an item now in your bags. Opaque blob, no id, no "(pending)".
who, raw = parse(
    "You have acquired: <ExamineItemInstance:ItemInfo:\196\128\196\128\197\140\198\156" ..
    "\197\163\197\160>[Enhancement Rune +1, Lvl 141]<\\ExamineItemInstance>.")
check("self, ItemInstance link, looter", who, "you")
check("self, ItemInstance link, item",   raw, "Enhancement Rune +1, Lvl 141")

who, raw = parse(
    "Rior has acquired <Examine:IIDDID:0x0000000000000000:0x700713ED>" ..
    "[Enhancement Rune +1, Lvl 151]<\\Examine>.")
check("fellow, looter", who, "Rior")
check("fellow, item",   raw, "Enhancement Rune +1, Lvl 151")

-- a hyphen-and-digit name, which is why the pattern uses %S+ and not %a+
who = parse("Bofurr-1 has acquired <Examine:IIDDID:0x0:0x1>[Silver Serpent]<\\Examine>.")
check("fellow, non-alphabetic name", who, "Bofurr-1")

-- currency shares the SelfLoot channel but uses a different verb and has no bracket
who = parse("You looted 95 silver pieces and 87 copper coins.")
check("currency is not a loot line", who, nil)

-- ------------------------------------------------------------------------------------------------
section("Normalise  (quantity prefix, level suffix, plural)")

local function norm(s)
    local base, level, qty = _G.LootDrops.Normalise(s)
    return base .. "|" .. tostring(level) .. "|" .. qty
end

check("level suffix split",   norm("Enhancement Rune +1, Lvl 151"), "Enhancement Rune +1|151|1")
check("no level suffix",      norm("Minor Essence of Will"),        "Minor Essence of Will|nil|1")
check("quantity prefix",      norm("3 Damaged Murai Artifacts"),    "Damaged Murai Artifacts|nil|3")
check("quantity and level",   norm("5 Silver Serpents"),            "Silver Serpents|nil|5")

-- the plural is resolved from the data, never by a rule: "Badges of Forgotten Rank" puts the
-- plural on the head noun, so no trailing-s heuristic could work
check("plural resolves to singular",
    _G.LootDrops.Canonical("Damaged M\195\187rai Artifacts"), "Damaged M\195\187rai Artifact")
check("singular resolves to itself",
    _G.LootDrops.Canonical("Damaged M\195\187rai Artifact"),  "Damaged M\195\187rai Artifact")
check("uncatalogued item is unknown",
    _G.LootDrops.Canonical("Forgotten Traveller's Digit"),    nil)

-- ------------------------------------------------------------------------------------------------
section("Attribution  (asymmetric window, no dedupe, no double-claim)")

local function loot(t, player, item)
    CLOCK = t
    _G.LootDrops.Update()
    local message = (player == "you")
        and ("You have acquired: <Examine:IIDDID:0x0:0x1>[" .. item .. "].")
        or  (player .. " has acquired <Examine:IIDDID:0x0:0x1>[" .. item .. "].")
    _G.LootDrops.HandleChat(player == "you" and 36 or 37, message)
end

local function chest(t, index)
    CLOCK = t
    _G.LootDrops.Update()
    _G.LootDrops.OnChestEvent(index, "x")
end

local function settle(t)
    CLOCK = t
    _G.LootDrops.Update()
end

local function itemsOf(n)
    return _G.LootDrops.currentRun.chests[n].items
end

local function countIn(n, base)
    local total = 0
    for _, item in ipairs(itemsOf(n)) do
        if item.base == base then total = total + 1 end
    end
    return total
end

-- Quest rewards land ~4.5s BEFORE the chest line and must not be absorbed; real chest loot was
-- seen 2.88s AFTER it and must be. Both measured on a six-man run.
loot(100.0, "Kust", "Silver Serpent")            -- quest reward, 4.5s early: excluded
chest(104.5, 546)
loot(104.6, "you", "Enhancement Rune +1")
loot(107.4, "Kust", "Toll Copper")               -- +2.9s straggler: included
settle(120)

check("straggler at +2.9s is included",   countIn(1, "Toll Copper"),         1)
check("quest reward at -4.5s is excluded", countIn(1, "Silver Serpent"),      0)
check("chest one total",                   #itemsOf(1),                       2)

-- Repeats are real. One looter took the same item seven times in six seconds on the captured
-- run, and the handover's (player, item, +/-10s) dedupe would have recorded one.
chest(200, 545)
for _ = 1, 7 do loot(200.5, "Ansgarius", "Toll Copper") end
settle(210)
check("seven genuine repeats are seven", countIn(2, "Toll Copper"), 7)

-- Two chests back to back: the second must not re-claim what the first already took, which a
-- timestamp cut-off alone does not prevent -- a chest's forward window reaches past its own
-- timestamp.
chest(300.0, 546)
loot(300.3, "Kust", "Toll Copper")
chest(300.7, 545)                                 -- settles the first immediately
loot(300.9, "Kadett", "Silver Serpent")
settle(320)

check("first of two chests keeps its line",  countIn(3, "Toll Copper"),    1)
check("second chest does not re-claim it",   countIn(4, "Toll Copper"),    0)
check("second chest takes only its own",     #itemsOf(4),                  1)

-- ------------------------------------------------------------------------------------------------
section("Popup filter  (display only -- stats still count everything)")

chest(400, 546)
loot(400.1, "you", "Toll Copper")                 -- catalogued, not popup-flagged
loot(400.2, "Kust", "3 Damaged M\195\187rai Artifacts")   -- the accented name, as chat sends it
settle(410)
local barterChest = _G.LootDrops.currentRun.chests[5]

check("barter is still recorded",        #barterChest.items,                          2)
check("barter chest opens no popup",     _G.LootDrops.HasPopupItems(barterChest),     false)

chest(500, 544)
loot(500.1, "you", "Ord\195\162khai Scout's Boots")
loot(500.2, "Kust", "Silver Serpent")
settle(510)
local gearChest = _G.LootDrops.currentRun.chests[6]

check("gear chest opens a popup",        _G.LootDrops.HasPopupItems(gearChest),       true)
check("gear is shown",                   _G.LootDrops.IsPopupItem(544, "Ord\195\162khai Scout's Boots"), true)
check("barter is recorded but hidden",   _G.LootDrops.IsPopupItem(544, "Silver Serpent"),               false)
check("barter still counted in chest",   #gearChest.items,                            2)

-- ------------------------------------------------------------------------------------------------
section("Drops data integrity")

local names = {}
for eventIndex, drops in pairs(_G.Drops) do
    check("event " .. eventIndex .. " exists in _G.Events", _G.Events[eventIndex] ~= nil, true)
    for _, drop in ipairs(drops) do
        check("row has an item name", type(drop.item) == "string" and drop.item ~= "", true)
        if drop.chance ~= nil then
            check("chance " .. drop.item .. " is 0..1",
                drop.chance >= 0 and drop.chance <= 1, true)
        end
        -- a plural must not collide with another item's singular
        if drop.plural ~= nil then
            check("plural differs from singular for " .. drop.item, drop.plural ~= drop.item, true)
        end
        names[drop.item] = true
    end
end

-- ------------------------------------------------------------------------------------------------
print(string.format("\n%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
