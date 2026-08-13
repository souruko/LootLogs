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
import = function() end

-- The REAL event table, not a stub of it. The drops file is keyed on _G.Events indices, so a
-- hand-written stub means the integrity checks below only ever see the handful of events
-- somebody remembered to copy -- and a drops row pointing at a chest that does not exist is
-- exactly the mistake they are here to catch.
dofile("Logs/English.lua")
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

-- TWO INDEPENDENT SOURCES AGREEING ON AN ID. Silver Serpent's id was read off a live chat link
-- during a run; the drops table now comes from the game's own exported loot tables, which never
-- saw that capture. They produce the same number, which is what says the CSV's first column
-- really is the item id -- the thing every icon and item link is built from.
local serpent = nil
for _, drop in ipairs(_G.Drops[546]) do
    if drop.item == "Silver Serpent" then serpent = drop end
end
check("drops table holds the id captured from chat",
    string.format("0x%08X", serpent.id), "0x70073138")

-- The stored form ZEROES the instance half. A string captured verbatim from a drag works too,
-- but only until that exact item leaves the bag, so it is never what gets stored.
local data = _G.LootDrops.ShortcutData(serpent)
check("shortcut zeroes the instance half", data, "0x0000000000000000,0x70073138")
check("shortcut carries the item id",
    string.match(data, ",(0x%x+)$"), string.format("0x%08X", serpent.id))

-- the item half of a real captured payload is an id of the same shape, which is why zeroing works
check("captured payload splits to an item id",
    string.match(SHORTCUT_DATA, ",(0x%x+)$"), "0x700713ED")

-- A guaranteed reward has NO id in the export -- the file simply does not give one -- so the
-- row must offer nothing rather than a malformed string, and shows an empty slot.
local given = nil
for _, drop in ipairs(_G.Drops[546]) do
    if drop.item == "Enhancement Rune +1" then given = drop end
end
check("a guaranteed reward has no id",  given.id, nil)
check("no id yields nil",    _G.LootDrops.ShortcutData(given), nil)
check("nil drop yields nil", _G.LootDrops.ShortcutData(nil),      nil)
check("shortcut type constant",           _G.LootDrops.SHORTCUT_ITEM,          SHORTCUT_TYPE)

-- ------------------------------------------------------------------------------------------------
section("Display label  (a description under the name, never the name itself)")

local labelled = { item = "Blighted Shoulder-guards of the Endless Flame",
                   label = "Runekeeper shoulders red", id = 0x700713ED }
local plainRow = { item = "Silver Serpent" }

-- THE LABEL NO LONGER REPLACES THE NAME. The row draws the client's own name and puts the
-- label under it as a small description, so the row, the tooltip and the chat link all say
-- the same thing about the same item.
check("the shown name is the client's own",
    _G.LootDrops.DisplayName(labelled, labelled.item),
    "Blighted Shoulder-guards of the Endless Flame")
check("the label is the description",
    _G.LootDrops.DisplayNote(labelled), "Runekeeper shoulders red")
check("no label falls back to the client name",
    _G.LootDrops.DisplayName(plainRow, plainRow.item), "Silver Serpent")
check("no label is no description",     _G.LootDrops.DisplayNote(plainRow), nil)
check("nil drop falls back",
    _G.LootDrops.DisplayName(nil, "Silver Serpent"), "Silver Serpent")
check("nil drop has no description",    _G.LootDrops.DisplayNote(nil), nil)
check("empty label is not a rename",
    _G.LootDrops.DisplayName({ item = "x", label = "" }, "x"), "x")
check("empty label is not a description",
    _G.LootDrops.DisplayNote({ item = "x", label = "" }), nil)

-- THE TWO ROWS THAT HAVE NO NAME OF THEIR OWN keep the label as their name: a group is keyed on
-- the plugin's word for a set and a bucket on the export's numbering, and neither key is
-- something to read out. Their label is therefore not a description and must not be drawn twice.
local groupRow  = { item = "Group 1",    label = "Fallen Armour", isGroup = true }
local bucketRow = { item = "?? Group 1", label = "Group 1",       bucket  = true }

check("a group is named by its label",
    _G.LootDrops.DisplayName(groupRow, groupRow.item), "Fallen Armour")
check("and has no description under it",  _G.LootDrops.DisplayNote(groupRow),  nil)
check("a bucket is named by its label",
    _G.LootDrops.DisplayName(bucketRow, bucketRow.item), "Group 1")
check("and has no description either",    _G.LootDrops.DisplayNote(bucketRow), nil)

-- the key is untouched: the label must not affect matching, or a description would silently
-- stop the parser recognising the item
check("label does not become a lookup key",
    _G.LootDrops.Canonical("Runekeeper shoulders red"), nil)
check("catalogued name still resolves",
    _G.LootDrops.Canonical("Silver Serpent"), "Silver Serpent")

-- a labelled row still keys its shortcut off the real id
check("label does not disturb the shortcut",
    _G.LootDrops.ShortcutData(labelled), "0x0000000000000000,0x700713ED")

-- THE LINK READS AS THE ITEM IT EXAMINES. A link whose text was one player's nickname for the
-- thing, pasted into fellowship chat, is a link nobody else can place.
check("the item link reads as the client's name",
    _G.LootDrops.ItemLink(labelled, nil),
    "<Examine:IIDDID:0x0000000000000000:0x700713ED>" ..
    "[Blighted Shoulder-guards of the Endless Flame]<\\Examine>")

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

-- Real line: "Lifala has acquired [1,000 Ancient Script]." A bare "%d+" stops at the "1" and
-- leaves the separator glued to the name, so the stack reads as ONE of an item called
-- "1,000 Ancient Script" -- unmatchable, and silently wrong. Both separators are accepted
-- because which one the client prints is a language setting.
check("grouped count, comma",  norm("1,000 Ancient Script"),        "Ancient Script|nil|1000")
check("grouped count, period", norm("1.000 Ancient Script"),        "Ancient Script|nil|1000")
check("grouped count, millions", norm("1,000,000 Ancient Script"),  "Ancient Script|nil|1000000")

-- and a name that merely begins with a digit is NOT a count
check("leading digit is not a count", norm("1st Age Symbol"),       "1st Age Symbol|nil|1")

-- The plural is resolved from the DATA, never by a rule: "Badges of Forgotten Rank" puts the
-- plural on the head noun, so no trailing-s heuristic could work. The export carries no plural
-- column either, so a stacked drop is only recognised once someone fills one in from a capture
-- (LootScribe's PLURALS table) -- and until they do, the whole line resolves to nothing and the
-- drop is not even counted. That is what hid six Silver Serpents on 08/11.
check("singular resolves to itself",
    _G.LootDrops.Canonical("Badge of Forgotten Rank"),  "Badge of Forgotten Rank")
check("a filled-in plural resolves to the singular",
    _G.LootDrops.Canonical("Badges of Forgotten Rank"), "Badge of Forgotten Rank")
check("a stacked barter line resolves too",
    _G.LootDrops.Canonical("Silver Serpents"),          "Silver Serpent")
check("a plural nobody has filled in yet does NOT",
    _G.LootDrops.Canonical("Sun-kissed Essence Boxes"), nil)
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
loot(100.0, "Kust", "Enhancement Rune +1")       -- quest reward, 4.5s early: excluded
chest(104.5, 546)
loot(104.6, "you", "?? Group 1")
loot(107.4, "Kust", "Silver Serpent")            -- +2.9s straggler: included
settle(120)

check("straggler at +2.9s is included",    countIn(1, "Silver Serpent"),      1)
check("quest reward at -4.5s is excluded", countIn(1, "Enhancement Rune +1"), 0)
check("chest one total",                   #itemsOf(1),                       2)

-- Repeats are real. One looter took the same item seven times in six seconds on the captured
-- run, and the handover's (player, item, +/-10s) dedupe would have recorded one.
chest(200, 545)
for _ = 1, 7 do loot(200.5, "Ansgarius", "Silver Serpent") end
settle(210)
check("seven genuine repeats are seven", countIn(2, "Silver Serpent"), 7)

-- Two chests back to back: the second must not re-claim what the first already took, which a
-- timestamp cut-off alone does not prevent -- a chest's forward window reaches past its own
-- timestamp.
chest(300.0, 546)
loot(300.3, "Kust", "Silver Serpent")
chest(300.7, 545)                                 -- settles the first immediately
loot(300.9, "Kadett", "Enhancement Rune +1")
settle(320)

check("first of two chests keeps its line",  countIn(3, "Silver Serpent"),    1)
check("second chest does not re-claim it",   countIn(4, "Silver Serpent"),    0)
check("second chest takes only its own",     #itemsOf(4),                  1)

-- ------------------------------------------------------------------------------------------------
section("Popup filter  (display only -- stats still count everything)")

chest(400, 546)
loot(400.1, "you", "Silver Serpent")                 -- catalogued, not popup-flagged
loot(400.2, "Kust", "Silver Serpent")                -- and a genuine repeat of it
settle(410)
local barterChest = _G.LootDrops.currentRun.chests[5]

check("barter is still recorded",        #barterChest.items,                          2)
check("barter chest opens no popup",     _G.LootDrops.HasPopupItems(barterChest),     false)

chest(500, 544)
loot(500.1, "you", "Sun-kissed Essence Box")
loot(500.2, "Kust", "Silver Serpent")
settle(510)
local gearChest = _G.LootDrops.currentRun.chests[6]

check("a flagged drop opens a popup",    _G.LootDrops.HasPopupItems(gearChest),       true)
check("the flagged one is shown",        _G.LootDrops.IsPopupItem(544, "Sun-kissed Essence Box"), true)
check("barter is recorded but hidden",   _G.LootDrops.IsPopupItem(544, "Silver Serpent"),         false)
check("barter still counted in chest",   #gearChest.items,                            2)

-- ------------------------------------------------------------------------------------------------
section("Grouped drops  (many names, one thing)")

-- Traceries are class-specific and rolled, so a chest hands six people six different names for
-- the same event: "a tracery dropped".
check("a tracery reports its group",
    _G.LootDrops.GroupOf(544, "?? Tracery"), "Tracery")
check("an ungrouped catalogued item does not",
    _G.LootDrops.GroupOf(544, "Sun-kissed Essence Box"), nil)
check("an ungrouped item reports nothing",
    _G.LootDrops.GroupOf(544, "Silver Serpent"), nil)
check("an unknown item reports nothing",
    _G.LootDrops.GroupOf(544, "Not An Item"), nil)

-- Counted from the data rather than hard-coded, because the catalogue grows every run and a
-- literal here would fail on the next one -- which teaches people to edit the number instead
-- of reading the test.
local expected = 0
for _, drop in ipairs(_G.Drops[544]) do
    if drop.group == "Tracery" then expected = expected + 1 end
end

local members = _G.LootDrops.GroupMembers(544, "Tracery")
check("the group gathers every member", #members, expected)

-- Deliberately NOT "more than one". The chart names no individual tracery -- one category row is
-- the whole group until real names are catalogued from a run, and a group of one is a legitimate
-- state, not a broken one.
check("a group of one is still a group", expected >= 1, true)

-- GROUPING MUST NOT AFFECT MATCHING. Each name still needs its own row, or the drop is not
-- recognised at all -- the group is display and statistics only.
check("each member still resolves on its own name",
    _G.LootDrops.Canonical("?? Tracery"), "?? Tracery")
check("the group name is NOT a lookup key",
    _G.LootDrops.Canonical("Tracery"), nil)

-- and every member is still individually catalogued, so a chest of them is fully recorded
for _, member in ipairs(members) do
    check("member is catalogued: " .. member.item,
        _G.LootDrops.KnowsItem(member.item), true)
end

-- ------------------------------------------------------------------------------------------------
section("Run boundaries  (entering an instance starts a new run)")

-- Self-contained: an entry signal first, so this does not depend on what the sections above
-- left in currentRun.
_G.LootDrops.OnRunStart(51, "T1")
chest(600, 546)
loot(600.1, "you", "Enhancement Rune +1")
settle(610)
local firstRun = _G.LootDrops.currentRun
check("a fresh run holds one chest", #firstRun.chests, 1)

-- The same instance again with NO entry signal. This is the pre-existing behaviour and it is
-- what the signal exists to correct: two clears reading as one.
chest(700, 546)
loot(700.1, "you", "Silver Serpent")
settle(710)
check("without an entry signal the run continues", #_G.LootDrops.currentRun.chests, 2)
check("and it is still the same run",              _G.LootDrops.currentRun, firstRun)

-- with it
_G.LootDrops.OnRunStart(51, "T1")
chest(800, 546)
loot(800.1, "you", "Silver Serpent")
settle(810)
check("entering starts a fresh run",   #_G.LootDrops.currentRun.chests, 1)
check("and it is a different run",     _G.LootDrops.currentRun ~= firstRun, true)

-- consumed, not sticky: the next boss of the SAME run must not reset it again
chest(900, 545)
loot(900.1, "you", "Silver Serpent")
settle(910)
check("the signal lasts exactly one chest", #_G.LootDrops.currentRun.chests, 2)

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
section("Instance entry quests  (data, not a New-Quest pattern)")

-- Loaded LAST and on purpose: it replaces the stub _G.Events with the real 644 rows, so nothing
-- above may depend on it.
dofile("Logs/English.lua")

local function EntryFor(line)
    if _G.InstanceEntryPrefix == nil then return nil end
    if not string.find(line, _G.InstanceEntryPrefix) then return nil end
    for _, entry in ipairs(_G.InstanceEntries) do
        if string.find(line, entry.match) then return entry end
    end
    return nil
end

-- the real captured entry lines
local entry = EntryFor("New Quest: Pagru-kir\195\173t, The Garden of Corpses -- Tier 1")
check("entry line resolves an instance", entry ~= nil and entry.instance, 51)
check("entry line resolves a tier",      entry ~= nil and entry.tier,     "T1")

entry = EntryFor("New Quest: Pagru-kir\195\173t, The Garden of Corpses -- Solo/Duo")
check("solo entry resolves the Solo tier", entry ~= nil and entry.tier, "Solo")

-- THE REGRESSION THIS EXISTS FOR. Matching "New Quest:" alone would make every quest in the
-- game reset the loot run.
check("an ordinary quest is not an instance entry",
    EntryFor("New Quest: A Farmer's Errand"), nil)
check("a quest naming an instance but not its entry is not one either",
    EntryFor("New Quest: Return to Pagru-kir\195\173t"), nil)
check("a quest completion is not an entry",
    EntryFor("Completed: Pagru-kir\195\173t, The Garden of Corpses -- Tier 1"), nil)

-- every seeded row must be well formed, or it silently never fires
for _, row in ipairs(_G.InstanceEntries) do
    check("entry names a real instance: " .. row.match,
        _G.Instances[row.instance] ~= nil, true)
    check("entry match has no raw dash (it would be a quantifier): " .. row.match,
        string.find(row.match, "%-") == nil, true)
end

-- ------------------------------------------------------------------------------------------------
section("Group modes  (collapse hides its members, expand lists them)")

check("an undeclared group collapses -- the safe default",
    _G.LootDrops.GroupMode("Not A Declared Group"), "collapse")
check("traceries collapse",        _G.LootDrops.GroupMode("Tracery"), "collapse")
check("a numbered group expands",  _G.LootDrops.GroupMode("Group 1"), "expand")
check("an undeclared one does not", _G.LootDrops.GroupMode("Barter"), "collapse")
check("no group, no mode",         _G.LootDrops.GroupMode(nil), nil)
check("and an empty one is not a group either", _G.LootDrops.GroupMode(""), nil)

check("GroupExpands agrees, tracery",  _G.LootDrops.GroupExpands("Tracery"), false)
check("GroupExpands agrees, a group",  _G.LootDrops.GroupExpands("Group 1"), true)

-- A group's NAME is display only, the same as an item's label: renaming one must never move
-- the key the members, the wishlist and the stats are all keyed on.
_G.DropGroups["Renamed Group"] = { mode = "expand", label = "Fallen Armour" }
_G.DropGroups["Blank Label"]   = { mode = "expand", label = "" }

check("a labelled group shows its label",
    _G.LootDrops.GroupLabel("Renamed Group"), "Fallen Armour")
check("an unlabelled one shows its key",  _G.LootDrops.GroupLabel("Group 1"), "Group 1")
check("an empty label is not a name",     _G.LootDrops.GroupLabel("Blank Label"), "Blank Label")
check("an undeclared group is its own name",
    _G.LootDrops.GroupLabel("Not A Declared Group"), "Not A Declared Group")
check("no group, no name",                _G.LootDrops.GroupLabel(nil), nil)
check("renaming does not change the mode",
    _G.LootDrops.GroupExpands("Renamed Group"), true)

-- put the table back before the every-declared-group-has-members sweep below sees these
_G.DropGroups["Renamed Group"] = nil
_G.DropGroups["Blank Label"]   = nil

-- ------------------------------------------------------------------------------------------------
section("Combined chance  (one item, several pools, one number)")

local combined = _G.LootDrops.CombinedChance

-- The rolls are independent, so the chance of at least one hitting is 1 - Π(1 - chance).
-- ADDING THEM IS THE MISTAKE THIS EXISTS TO PREVENT: 70 + 10 is 80, which is wrong, and a
-- six-pool item would add up past 100% while claiming a certainty the tables never gave.
local function pct(value)
    if value == nil then return nil end
    return math.floor(value * 10000 + 0.5) / 100
end

check("nothing to fold is not a rate",     combined({}),                         nil)
check("one entry is its own answer",       pct(combined({ { chance = 0.7 } })),  70)
check("70% and 10% is 73%, not 80%",
    pct(combined({ { chance = 0.7 }, { chance = 0.1 } })),                       73)
check("six small pools still beat one",
    pct(combined({ { chance = 0.010606 }, { chance = 0.010294 }, { chance = 0.01 },
                   { chance = 0.003788 }, { chance = 0.003676 }, { chance = 0.003571 } })), 4.12)
check("a guaranteed entry carries the rest",
    pct(combined({ { chance = 1 }, { chance = 0.7 } })),                         100)
check("an unknown chance is left out, not counted as zero",
    pct(combined({ { chance = 0.7 }, { chance = nil } })),                       70)
check("all unknown is unknown, never 0%",
    combined({ { chance = nil }, { chance = nil } }),                            nil)
check("bare numbers fold the same way",    pct(combined({ 0.7, 0.1 })),          73)

-- ------------------------------------------------------------------------------------------------
section("Item entries  (a chest rolls several tables, so one name has several chances)")

-- Kishâsu T2. Counted from the data rather than written down, because the catalogue is
-- regenerated from the game's own tables and a literal here would teach people to edit the
-- number instead of reading the test.
local KISHASU_T2 = 543

local function EntriesInData(eventIndex, name)
    local count = 0
    for _, drop in ipairs(_G.Drops[eventIndex]) do
        if drop.item == name and not drop.bucket then count = count + 1 end
    end
    return count
end

local necklace = _G.LootDrops.ItemEntries(KISHASU_T2, "Bright Conscript's Necklace")
check("an item in six pools reports six chances",
    #necklace, EntriesInData(KISHASU_T2, "Bright Conscript's Necklace"))
check("and there really are six",  #necklace, 6)
check("biggest first",             necklace[1].chance > necklace[#necklace].chance, true)
check("each entry remembers its pool", necklace[1].group ~= nil, true)

-- THE HALF THAT IS EASY TO MISS. Ungrouped items duplicate too, so the key is the NAME and
-- never the group -- "collapse the groups" would leave this one at two rows.
check("an ungrouped item duplicates as well",
    #_G.LootDrops.ItemEntries(KISHASU_T2, "Silver Serpent"),
    EntriesInData(KISHASU_T2, "Silver Serpent"))

check("an uncatalogued name has no entries",
    #_G.LootDrops.ItemEntries(KISHASU_T2, "Not An Item"), 0)

-- A bucket row is the pool itself: it matches no chat line, has no id, and its rate belongs to
-- the category rather than to anything in it.
local bucketName = nil
for _, drop in ipairs(_G.Drops[KISHASU_T2]) do
    if drop.bucket then bucketName = drop.item break end
end
check("this chest has bucket rows to exclude", bucketName ~= nil, true)
check("and a bucket row is not an item with entries",
    #_G.LootDrops.ItemEntries(KISHASU_T2, bucketName), 0)

-- A collapse group is not an item and has no row of its own, so it answers with its members'.
check("a collapse group answers for its members",
    #_G.LootDrops.ItemEntries(544, "Tracery"), #_G.LootDrops.GroupMembers(544, "Tracery"))

-- ------------------------------------------------------------------------------------------------
section("Dedupe  (one row per name per chest)")

local function Chance(row)  return pct(row.any) end

local function Find(rows, name)
    for _, row in ipairs(rows) do
        if row.item == name then return row end
    end
    return nil
end

-- Hand-built, so the rules are visible: two entries of one ungrouped item, a bucket row and
-- its expand-group members, a collapse group of two, and an item nobody has a rate for.
local sample = {
    { item = "Silver Serpent",   chance = 1.00 },
    { item = "Silver Serpent",   chance = 0.70 },
    { item = "?? Group 1",       chance = 0.15, group = "Group 1", bucket = true },
    { item = "Fallen Helm",      chance = 0.05, group = "Group 1", id = 7, quality = "rare" },
    { item = "Fallen Helm",      chance = 0.04, group = "Group 1" },
    { item = "Fallen Gauntlets", chance = 0.05, group = "Group 1" },
    { item = "?? Tracery A",     chance = 0.50, group = "Tracery" },
    { item = "?? Tracery B",     chance = 0.50, group = "Tracery" },
    { item = "Mystery Trophy" },
}

local deduped = _G.LootDrops.Dedupe(sample)

check("nine rows become five",             #deduped, 5)
check("a name repeated is one row",        Find(deduped, "Silver Serpent") ~= nil, true)
check("carrying both its chances",         #Find(deduped, "Silver Serpent").entries, 2)
check("folded into one figure",            Chance(Find(deduped, "Silver Serpent")), 100)
check("a bucket row is not a row",         Find(deduped, "?? Group 1"), nil)

-- An EXPAND group's members are real, wantable items: with one row per name they no longer
-- repeat themselves, so there is nothing left for a fold to hide.
check("an expand group's members stay themselves",
    Find(deduped, "Fallen Helm") ~= nil and Find(deduped, "Fallen Gauntlets") ~= nil, true)
check("and are not a group row",           Find(deduped, "Fallen Helm").isGroup, nil)
check("the first non-nil id survives",     Find(deduped, "Fallen Helm").id, 7)
check("so does the first quality",         Find(deduped, "Fallen Helm").quality, "rare")

-- A COLLAPSE group still folds. Its members are placeholder names -- nobody wants a list of
-- traceries -- and that is a display rule about the group, not about duplication.
local tracery = Find(deduped, "Tracery")
check("a collapse group is one row",       tracery ~= nil, true)
check("under the group's own key",         tracery.isGroup, true)
check("carrying its members' entries",     #tracery.entries, 2)
check("and combining them",                Chance(tracery), 75)
check("its members are not listed",        Find(deduped, "?? Tracery A"), nil)
check("but are still findable by name",    #tracery.memberNames, 2)
check("a group has no id to borrow",       tracery.id, nil)

-- An absent chance means "drops, rate not established". It must never become 0%.
check("no chance anywhere is no rate",     Find(deduped, "Mystery Trophy").any, nil)

-- Ordered for display, because file order was never meaningful and a wall of sub-1% rows is
-- only readable sorted.
check("the likeliest leads",               deduped[1].item, "Silver Serpent")
check("and the unknown sinks to the end",  deduped[#deduped].item, "Mystery Trophy")

-- Against the real table: 308 rows, 91 names, and every entry accounted for.
local real = _G.LootDrops.Dedupe(_G.Drops[KISHASU_T2])
local folded = 0
for _, row in ipairs(real) do folded = folded + #row.entries end

local nonBucket, collapsedHere = 0, false
for _, drop in ipairs(_G.Drops[KISHASU_T2]) do
    if not drop.bucket then nonBucket = nonBucket + 1 end
    if drop.group == "Tracery" then collapsedHere = true end
end

-- the entry count below is "every non-bucket row survives", which only holds where no pool row
-- stands in for its members -- this chest has none, and the assertion is worth stating
check("this chest has no collapsed pool to stand in", collapsedHere, false)

check("a real chest folds to far fewer rows", #real < #_G.Drops[KISHASU_T2], true)
check("and loses nothing on the way",         folded, nonBucket)
check("the six-entry item is one row of six", #Find(real, "Bright Conscript's Necklace").entries, 6)
check("with the combined figure the browser prints",
    Chance(Find(real, "Bright Conscript's Necklace")), 1.54)

-- The same item one tier up, which is the row the design was drawn from: six pools again, and
-- 4.12% is the number on the mockup.
local t3 = _G.LootDrops.Dedupe(_G.Drops[540])
check("Kishâsu T3 prices the same necklace at 4.12%",
    Chance(Find(t3, "Bright Conscript's Necklace")), 4.12)
check("and the cloak beside it at 8.11%",
    Chance(Find(t3, "Game Hunter's Cloak")), 8.11)

-- THE POOL IS THE ROW, for a collapse group. "?? Tracery" is a bucket row -- it matches no chat
-- line and is the only thing the tables say about traceries -- so dropping every bucket row
-- would take the tracery line out of the browser altogether.
local tracery3 = Find(t3, "Tracery")
check("a collapsed pool survives as its category", tracery3 ~= nil, true)
check("carrying the pool's own rate",              Chance(tracery3), 100)
check("and the placeholder name is not a row",     Find(t3, "?? Tracery"), nil)

-- The other kind of bucket row, at the same chest: a pool over items that ARE listed. Its rate
-- belongs to the roll, not to any piece, so it is dropped.
check("an expand group's pool is not a row",       Find(t3, "?? Group 1"), nil)

-- ------------------------------------------------------------------------------------------------
section("Catalogued tiers  (the browser opens on the highest)")

-- Lowest first, so the highest is simply the last -- which is what the browser selects, because
-- a chest is farmed at the top tier and Solo is where nobody was looking.
local tiers = _G.LootDrops.TiersFor(51)
check("Pagru-kirít catalogues four tiers", #tiers, 4)
check("lowest first",                      tiers[1], "Solo")
check("so the highest is the last",        tiers[#tiers], "T3")

-- An instance with one catalogued tier picks that one, not nothing: the rule is "the last of
-- them", and a list of one has a last.
local only = { "T1" }
check("one tier is still the highest",     only[#only], "T1")

check("an uncatalogued instance has no tiers", #_G.LootDrops.TiersFor(-1), 0)

-- ------------------------------------------------------------------------------------------------
section("Browser search  (it filters the selection, and a group answers for its members)")

check("search text carries the client's name", _G.LootDrops.SearchText({ item = "Silver Serpent" }),
    "silver serpent")
check("and the label too, so either finds it",
    _G.LootDrops.SearchText({ item = "Blighted Shoulders", label = "Burglar Red Shoulders" }),
    "blighted shoulders\0burglar red shoulders")

-- The rows one boss produces: a heading, a plain drop, and a group whose fold is open, so its
-- members are listed under it as children. Indices are what the filter answers in.
local function Rows()
    return {
        [1] = { kind = "header" },
        [2] = { text = _G.LootDrops.SearchText({ item = "Silver Serpent" }), header = 1 },
        [3] = { isGroup = true, header = 1,
                text = _G.LootDrops.SearchText({ item = "Group 1", label = "Fallen Armour" }),
                memberText = "fallen gauntlets\0fallen helm" },
        [4] = { text = "fallen gauntlets", parent = 3, header = 1 },
        [5] = { text = "fallen helm",      parent = 3, header = 1 },
    }
end

local all = _G.LootDrops.SearchFilter(Rows(), "")
check("no search, every row shows", all[2] and all[3] and all[4] and all[5], true)
check("and the heading with them",  all[1], true)

local serpent = _G.LootDrops.SearchFilter(Rows(), "serpent")
check("a plain drop matches on its own name", serpent[2], true)
check("its heading comes with it",            serpent[1], true)
check("an unrelated group drops out",         serpent[3], false)
check("and so do that group's children",      serpent[4] or serpent[5], false)

-- THE RULE THIS IS ALL FOR: a match on a member has to bring the group back, or searching an
-- armour piece would come back empty on the chest that actually drops it.
local helm = _G.LootDrops.SearchFilter(Rows(), "helm")
check("a member's name shows its group",   helm[3], true)
check("and the member itself",             helm[5], true)
check("but not its unmatched siblings",    helm[4], false)
check("nor an unrelated drop",             helm[2], false)
check("the heading stays, something is under it", helm[1], true)

-- A group matched by its own name keeps everything inside it: you asked for the category.
local armour = _G.LootDrops.SearchFilter(Rows(), "fallen armour")
check("a group matches on its label",      armour[3], true)
check("and keeps all of its children",     armour[4] and armour[5], true)
check("the key finds it too",
    _G.LootDrops.SearchFilter(Rows(), "group 1")[3], true)

local nothing = _G.LootDrops.SearchFilter(Rows(), "mithril")
check("no match, no rows",    nothing[2] or nothing[3] or nothing[4] or nothing[5], false)
check("and no empty heading", nothing[1], false)

-- a name with a dash or an apostrophe is text, not a pattern
check("punctuation is matched literally",
    _G.LootDrops.SearchFilter({ { text = "durin's bane" } }, "durin's")[1], true)
check("and a pattern character finds nothing of its own",
    _G.LootDrops.SearchFilter({ { text = "durin's bane" } }, "d.rin")[1], false)

-- EVERY DECLARED GROUP MUST HAVE MEMBERS, or the declaration is a typo nobody will notice --
-- a misspelled group name silently reverts its rows to collapse.
for name in pairs(_G.DropGroups) do
    local members = 0
    for eventIndex, rows in pairs(_G.Drops) do
        for _, drop in ipairs(rows) do
            if drop.group == name then members = members + 1 end
        end
    end
    check("declared group has rows: " .. name, members > 0, true)
end

-- ...and every group a ROW names must be declared or deliberately defaulted. Both directions
-- matter: this one catches a member whose group was renamed out from under it.
local undeclared = {}
for eventIndex, rows in pairs(_G.Drops) do
    for _, drop in ipairs(rows) do
        if drop.group ~= nil and _G.DropGroups[drop.group] == nil then
            undeclared[drop.group] = true
        end
    end
end
local names = {}
for name in pairs(undeclared) do names[#names + 1] = name end
check("no row names an undeclared group", table.concat(names, ", "), "")

-- A bucket row carries a CATEGORY's rate, so it has to belong to a declared group -- in either
-- mode. An expand group folds its members under it; a collapse group shows the bucket alone and
-- that is the point (one "Tracery" line at 100%, whatever name the roll lands on).
for eventIndex, rows in pairs(_G.Drops) do
    for _, drop in ipairs(rows) do
        if drop.bucket then
            check("bucket row names a declared group: " .. drop.item,
                _G.DropGroups[drop.group] ~= nil, true)
        end
    end
end

-- The popup rule. A collapse group folds to its group name; an expand group must NOT, because
-- nobody looted "Fallen armour" -- they looted a specific piece, and that is what to show.
check("a group bucket expands",
    _G.LootDrops.GroupExpands(_G.LootDrops.GroupOf(544, "?? Group 1")), true)
check("while a tracery's group does not",
    _G.LootDrops.GroupExpands(_G.LootDrops.GroupOf(544, "?? Tracery")), false)

-- An expand group starts as its bucket alone. That is the honest state for a category the source
-- table gives a rate for and no names: the browser shows "Fallen armour 2%" with an empty fold,
-- and pieces appear underneath as they are catalogued.
local armour = _G.LootDrops.GroupMembers(544, "Group 1")
check("the bucket is there",              #armour >= 1, true)

local bucketRows = 0
for _, member in ipairs(armour) do
    if member.bucket then bucketRows = bucketRows + 1 end
end
check("exactly one row is the category itself", bucketRows, 1)

-- ------------------------------------------------------------------------------------------------
section("Wishlist  (one question, asked the same way everywhere)")

-- LootStats is optional -- the row must not require it -- so the helper answers false rather
-- than erroring when it is not loaded.
check("no LootStats, nothing is wished",
    _G.LootDrops.IsWished(544, "Silver Serpent"), false)

-- a stand-in for the real LootStats, which the tests do not load
_G.LootStats = { IsWished = function(name) return _G.LootWishlist[name] == true end }
_G.LootWishlist = {}

check("an unstarred item is not wished",
    _G.LootDrops.IsWished(544, "Silver Serpent"), false)

_G.LootWishlist["Silver Serpent"] = true
check("a starred item is",
    _G.LootDrops.IsWished(544, "Silver Serpent"), true)

-- THE HALF THAT IS EASY TO LOSE. A tracery's name is a rolled detail nobody wishes for, so
-- starring the GROUP has to star every member -- and the popup, the row's star and the sort all
-- have to agree about it, which is why they all call this one function.
_G.LootWishlist = { ["Tracery"] = true }
check("starring the group stars its members",
    _G.LootDrops.IsWished(544, "?? Tracery"), true)
check("and leaves everything else alone",
    _G.LootDrops.IsWished(544, "Silver Serpent"), false)

-- put it back: the sections below run without LootStats, and a half-built stand-in left in
-- place would be answered instead of skipped
_G.LootWishlist = {}
_G.LootStats    = nil

-- ------------------------------------------------------------------------------------------------
section("Item kinds  (read off the name, because the data has no type column)")

local KIND = _G.LootDrops.KIND

local function kind(name) return _G.LootDrops.ItemKind(name) end

-- Every one of these is a real name out of Logs/Drops/English.lua.
check("a ring is jewellery",      kind("Keen Conscript's Ring"),        KIND.JEWELLERY)
check("so is a bauble",           kind("Ornate Conscript's Bauble"),    KIND.JEWELLERY)
check("and an earring",           kind("Subtle Conscript's Earring"),   KIND.JEWELLERY)
check("and a band, which is a ring by another name",
    kind("Oasis Ghost's Band"), KIND.JEWELLERY)

check("a coat is armour",         kind("Ordâkhai Explorer's Coat"),     KIND.ARMOUR)
check("so is a hooded helm",      kind("Fallen Sage's Hooded Helm"),    KIND.ARMOUR)
check("and a shoulder-guard",     kind("Ordâkhai Explorer's Shoulder-guard"), KIND.ARMOUR)
check("and a cloak",              kind("Gate-warden's Cloak"),          KIND.ARMOUR)
check("and a targe, which is a shield",
    kind("Skald's Targe"), KIND.ARMOUR)

check("a tracery is a tracery",   kind("Cracked Mûrai Tracery"),        KIND.TRACERY)
check("including the odd one out",
    kind("Tracery, Lvl 151 Legendary"), KIND.TRACERY)
check("and the group's own name, which is what a collapsed row is shown as",
    kind("Tracery"), KIND.TRACERY)

check("an enhancement rune is a rune", kind("Enhancement Rune +1"),     KIND.RUNE)

-- CURRENCY IS THE FALLBACK. Tokens, coffers, trophies and anything unrecognised land together,
-- which is the bucket a reader looks in for them anyway.
check("a coffer is currency",     kind("Decorated Coffer of Ancient Script"), KIND.CURRENCY)
check("so is a token",            kind("Blighted Skull Token"),         KIND.CURRENCY)
check("and a trophy",             kind("The Blighted Cold-worm Hide"),  KIND.CURRENCY)
check("and something nobody has catalogued",
    kind("Some Item Nobody Named"), KIND.CURRENCY)
check("and nothing at all",       kind(nil),                            KIND.CURRENCY)

-- THE SUFFIX IS NOT THE ITEM. Names run "<what it is> of <what it does>", so the first known
-- word wins -- otherwise "of Tempered Blades" would file a pair of gauntlets under weapons.
check("the head noun wins over the suffix",
    kind("Blighted Gauntlets of Tempered Blades"), KIND.ARMOUR)
check("even when the suffix is a slot word",
    kind("Blighted Gauntlets of the Royal Guard"), KIND.ARMOUR)

-- THE CLIENT'S OWN SLOT, which is the half that is authoritative. The category numbers come
-- from ItemInfo:GetCategory() and are mapped in _G.LootDrops.CATEGORY_KIND.
local CATEGORY = _G.LootDrops.CATEGORY_KIND

check("Jewelry(49) is jewellery", CATEGORY[49],  KIND.JEWELLERY)
check("Chest(3) is armour",       CATEGORY[3],   KIND.ARMOUR)
check("Shield(33) is armour",     CATEGORY[33],  KIND.ARMOUR)
check("Sword(44) rides with it",  CATEGORY[44],  KIND.ARMOUR)
check("Barter(178) is currency",  CATEGORY[178], KIND.CURRENCY)
check("a category we do not map has no kind", CATEGORY[235], nil)   -- Essences

-- The whole point of asking the client: the name can lie, the slot cannot. This "ring" is a
-- barter token, and it sorts as one.
local clientInfo = _G.LootDrops.ClientInfo
_G.LootDrops.ClientInfo = function(id)
    if id == nil then return nil end
    return { GetCategory = function() return id end }      -- the id IS the category, for the test
end

check("the client's slot beats the name",
    _G.LootDrops.ItemKind("Ring of the Merchant", 178), KIND.CURRENCY)
check("and places an item the words would miss",
    _G.LootDrops.ItemKind("Blighted Divination Shell", 3), KIND.ARMOUR)

-- a category outside our five is not an answer, so the name still gets its turn
check("an unmapped category falls back to the name",
    _G.LootDrops.ItemKind("Keen Ordâkhai Bracelet", 235), KIND.JEWELLERY)

-- AN UNANSWERABLE ID IS NOT A CATEGORY OF "NONE". The client's item table may not be ready yet,
-- and a name-derived kind cached then would be wrong for the rest of the session -- so it is
-- not cached, and the next ask gets the real answer.
_G.LootDrops.ClientInfo = function() return nil end
check("no answer yet, so the name decides for now",
    _G.LootDrops.ItemKind("Sturdy Ordâkhai Ring", 178), KIND.JEWELLERY)

_G.LootDrops.ClientInfo = function(id) return { GetCategory = function() return id end } end
check("and the answer is asked for again once there is one",
    _G.LootDrops.ItemKind("Sturdy Ordâkhai Ring", 178), KIND.CURRENCY)

_G.LootDrops.ClientInfo = clientInfo

-- ------------------------------------------------------------------------------------------------
section("Popup sort  (wishlisted, then yours, then rarest first)")

-- Sudûgul T1, whose real rates spread far enough to sort by: a coat at 1.1%, the rings at 1.5%,
-- an essence box at 29%, a rune and a serpent at 100%, and several names the tables give no rate
-- for at all.
local SORT_CHEST = 544

local function loose(names)

    local items = {}

    for index, name in ipairs(names) do
        items[#items + 1] = {
            item     = { base = name, player = "Player" .. index },
            logIndex = SORT_CHEST,
        }
    end

    return items
end

local function ordered(items)

    local names = {}

    for _, entry in ipairs(_G.LootDrops.SortLoot(items)) do
        names[#names + 1] = entry.item.base
    end

    return table.concat(names, ", ")
end

-- RAREST FIRST. Chat order in, luck order out -- the 1.1% coat above the ring above the box
-- above the two certainties.
check("the rarest drop leads",
    ordered(loose({
        "Enhancement Rune +1",              -- 100%
        "Sun-kissed Essence Box",           -- 29%
        "Keen Conscript's Ring",            -- 1.5%
        "Ordâkhai Explorer's Coat",         -- 1.1%
    })),
    "Ordâkhai Explorer's Coat, Keen Conscript's Ring, "
    .. "Sun-kissed Essence Box, Enhancement Rune +1")

-- KIND ORDERS NOTHING any more. A ring and a coat are told apart by looking at them; how lucky
-- either was is the thing the window is read for, so the coat goes above the ring on its rate
-- rather than below it on its category.
check("a rarer armour piece beats a commoner ring",
    ordered(loose({ "Keen Conscript's Ring", "Ordâkhai Explorer's Coat" })),
    "Ordâkhai Explorer's Coat, Keen Conscript's Ring")

-- Items sharing a rate share a pool, and there are six rings at 1.5% in this chest. A-Z decides
-- between them, so the same chest reads the same way every time it is reopened.
check("one rate, then A-Z",
    ordered(loose({
        "Sturdy Conscript's Ring",
        "Bright Conscript's Ring",
        "Keen Conscript's Ring",
    })),
    "Bright Conscript's Ring, Keen Conscript's Ring, Sturdy Conscript's Ring")

-- A COLLAPSED GROUP IS ONE ROW UNDER THE GROUP'S NAME, so the group's name is what has to be
-- placed -- there is no item there to ask. "Tracery" answers with its pool's own rate, 100%.
check("a collapsed group sorts on its pool's rate",
    ordered(loose({
        "Ordâkhai Explorer's Coat",
        "Tracery",
        "Keen Conscript's Ring",
    })),
    "Ordâkhai Explorer's Coat, Keen Conscript's Ring, Tracery")

-- AN UNKNOWN RATE IS NOT A RARE ONE. "Drops, rate not established" says nothing about luck, so
-- it goes to the back of its block rather than leading the window on a promise the tables never
-- made.
check("an unrated drop sinks to the bottom",
    ordered(loose({
        "Badge of Forgotten Rank",          -- no rate at this chest
        "Enhancement Rune +1",              -- 100%
        "Ordâkhai Explorer's Coat",         -- 1.1%
    })),
    "Ordâkhai Explorer's Coat, Enhancement Rune +1, Badge of Forgotten Rank")

-- TWO LOOTERS, ONE ITEM: the looter does NOT decide, not even here. Sorting the tie by name
-- would be the looter sort creeping back in through the back door, so the tie keeps the order
-- chat gave it -- which is also what stops an unstable table.sort reshuffling the block on
-- every rebuild.
check("same item keeps the order chat gave it",
    (function()
        local items = {
            { item = { base = "Keen Conscript's Ring", player = "Wren" }, logIndex = SORT_CHEST },
            { item = { base = "Keen Conscript's Ring", player = "Ada"  }, logIndex = SORT_CHEST },
        }
        _G.LootDrops.SortLoot(items)
        return items[1].item.player .. ", " .. items[2].item.player
    end)(),
    "Wren, Ada")

-- and the same list sorted twice comes out the same way, which is the point of the tie-break
check("and sorting it again does not reshuffle it",
    (function()
        local items = {
            { item = { base = "Keen Conscript's Ring", player = "Wren" }, logIndex = SORT_CHEST },
            { item = { base = "Keen Conscript's Ring", player = "Ada"  }, logIndex = SORT_CHEST },
            { item = { base = "Keen Conscript's Ring", player = "Bo"   }, logIndex = SORT_CHEST },
        }
        _G.LootDrops.SortLoot(items)
        _G.LootDrops.SortLoot(items)
        local names = {}
        for _, entry in ipairs(items) do names[#names + 1] = entry.item.player end
        return table.concat(names, ", ")
    end)(),
    "Wren, Ada, Bo")

-- THREE BLOCKS: wishlisted, then yours, then everyone else's -- and the rate order runs inside
-- each of them, not across them. Your own certainty is above someone else's rare drop.
local function blocks(rows)

    local items = {}

    for _, row in ipairs(rows) do
        items[#items + 1] = {
            item     = { base = row[1], player = row[2], isSelf = row[3] },
            logIndex = SORT_CHEST,
        }
    end

    local names = {}
    for _, entry in ipairs(_G.LootDrops.SortLoot(items)) do
        names[#names + 1] = entry.item.base
    end

    return table.concat(names, ", ")
end

check("yours comes before everyone else's, however common",
    blocks({
        { "Ordâkhai Explorer's Coat", "Ada",  false },   -- 1.1%, theirs
        { "Enhancement Rune +1",      "you",  true  },   -- 100%, yours
    }),
    "Enhancement Rune +1, Ordâkhai Explorer's Coat")

check("and the rate order runs inside each block",
    blocks({
        { "Sun-kissed Essence Box",   "Wren", false },   -- 29%
        { "Ordâkhai Explorer's Coat", "you",  true  },   -- 1.1%
        { "Keen Conscript's Ring",    "Ada",  false },   -- 1.5%
        { "Enhancement Rune +1",      "you",  true  },   -- 100%
    }),
    "Ordâkhai Explorer's Coat, Enhancement Rune +1, "
    .. "Keen Conscript's Ring, Sun-kissed Essence Box")

-- an unclaimed row carries no isSelf at all, and nil must sort with false rather than apart
check("no looter is not your loot",
    blocks({
        { "Ordâkhai Explorer's Coat", "Wren", nil  },   -- 1.1%, but not yours
        { "Enhancement Rune +1",      "you",  true },   -- 100%, and yours
    }),
    "Enhancement Rune +1, Ordâkhai Explorer's Coat")

-- WISHLISTED FIRST, above your own loot and above the rate order. The popup opens unbidden and
-- is read in a second; what you have been waiting for must never be below the fold.
_G.LootStats    = { IsWished = function(name) return _G.LootWishlist[name] == true end }
_G.LootWishlist = { ["Enhancement Rune +1"] = true }

check("a wished item comes first however common it is",
    ordered(loose({
        "Keen Conscript's Ring",
        "Enhancement Rune +1",
        "Ordâkhai Explorer's Coat",
    })),
    "Enhancement Rune +1, Ordâkhai Explorer's Coat, Keen Conscript's Ring")

check("even when it is somebody else's and yours is not",
    blocks({
        { "Keen Conscript's Ring", "you",  true  },
        { "Enhancement Rune +1",   "Wren", false },
    }),
    "Enhancement Rune +1, Keen Conscript's Ring")

_G.LootWishlist = {}
_G.LootStats    = nil

-- ------------------------------------------------------------------------------------------------
section("Popup blocks  (starred, then yours, then the fellowship's)")

_G.LootStats    = { IsWished = function(name) return _G.LootWishlist[name] == true end }
_G.LootWishlist = {}

local function partition(rows)

    local items = {}

    for _, row in ipairs(rows) do
        items[#items + 1] = {
            item     = { base = row[1], player = row[2], isSelf = row[3] },
            logIndex = 544,
        }
    end

    local starred, yours, fellowship = _G.LootDrops.PartitionLoot(items)

    local function names(list)
        local out = {}
        for _, entry in ipairs(list) do out[#out + 1] = entry.item.base end
        return table.concat(out, ", ")
    end

    return names(starred), names(yours), names(fellowship)

end

local blockRows = {
    { "Sun-kissed Essence Box", "you",  true  },
    { "Keen Conscript's Ring",  "Wren", false },
    { "Silver Serpent",         "Ada",  false },
}

local starred, yours, fellowship = partition(blockRows)
check("nothing starred, nothing in the first block", starred,    "")
check("your own loot is yours",                      yours,      "Sun-kissed Essence Box")
check("and the rest is the fellowship's",            fellowship,
    "Keen Conscript's Ring, Silver Serpent")

-- THE CASE THE OLD WINDOW BURIED. A drop you had starred that went to somebody else was sorted
-- below your own loot and drawn in everyone-else's colours; now it leads, and it is in ONE
-- block -- listed under Starred and NOT again under Fellowship.
_G.LootWishlist = { ["Silver Serpent"] = true }

starred, yours, fellowship = partition(blockRows)
check("someone else's starred drop leads",           starred,    "Silver Serpent")
check("and is not listed again below",               fellowship, "Keen Conscript's Ring")
check("your own loot is untouched by it",            yours,      "Sun-kissed Essence Box")

-- starred AND yours is one row, in the block that leads
_G.LootWishlist = { ["Sun-kissed Essence Box"] = true }

starred, yours, fellowship = partition(blockRows)
check("starred wins over yours",                     starred,    "Sun-kissed Essence Box")
check("so it is not in both",                        yours,      "")

-- a starred group stars every member, so a tracery row lands in the first block under the
-- group's name -- the same question IsWished answers everywhere else
_G.LootWishlist = { ["Tracery"] = true }

starred = partition({ { "?? Tracery", "Wren", false } })
check("a starred group carries its members up",      starred,    "?? Tracery")

_G.LootWishlist = {}
_G.LootStats    = nil

-- ------------------------------------------------------------------------------------------------
section("Printed rates  (one spelling, in both windows)")

local shown = _G.LootDrops.FormatChance

check("a big rate has no decimals",       shown(0.70),     "70%")
check("nor does a certainty",             shown(1.00),     "100%")
check("the middle band keeps one",        shown(0.0811),   "8.1%")
check("and rounds rather than truncates", shown(0.0456),   "4.6%")
check("under one per cent keeps two",     shown(0.0076),   "0.76%")
check("and so does a very small one",     shown(0.000357), "0.04%")
check("an unknown rate has no spelling",  shown(nil),      nil)

-- The series behind it: no per-cent signs, because the column heading already says what they
-- are and six of them in a row is noise.
local series = _G.LootDrops.EntrySeries

check("six entries print biggest first",
    series({ { chance = 0.021212 }, { chance = 0.020588 }, { chance = 0.02 },
             { chance = 0.007576 }, { chance = 0.007353 }, { chance = 0.007143 } }),
    "2.12" .. _G.Sep .. "2.06" .. _G.Sep .. "2.00" .. _G.Sep
    .. "0.76" .. _G.Sep .. "0.74" .. _G.Sep .. "0.71")

check("a guaranteed entry prints whole",
    series({ { chance = 1 }, { chance = 0.7 } }), "100" .. _G.Sep .. "70")

-- ONE ENTRY IS THE LEAD FIGURE. Printing it again beside itself says nothing, so the column
-- stays empty -- which is also how a row with no rate at all draws.
check("one entry has no series",          series({ { chance = 0.7 } }), nil)
check("and neither has none",             series({}),                   nil)
check("nor a nil list",                   series(nil),                  nil)
check("unknown chances are not printed",
    series({ { chance = nil }, { chance = nil } }), nil)

-- ------------------------------------------------------------------------------------------------
section("Popup search  (narrows what is shown, never what was recorded)")

local function chestLoot()
    return {
        { item = { base = "Keen Conscript's Ring",     player = "Ramor" }, logIndex = 544 },
        { item = { base = "Ordâkhai Explorer's Coat",  player = "Ada"   }, logIndex = 544 },
        { item = { base = "Bright Conscript's Ring",   player = "Ramor" }, logIndex = 544 },
        { item = { base = "Sun-kissed Essence Box",    player = "Wren"  }, logIndex = 544 },
    }
end

local function found(search)

    local names = {}

    for _, entry in ipairs(_G.LootDrops.FilterLoot(chestLoot(), search)) do
        names[#names + 1] = entry.item.base
    end

    return table.concat(names, ", ")
end

check("an empty search keeps everything",  #_G.LootDrops.FilterLoot(chestLoot(), ""),  4)
check("and so does no search at all",      #_G.LootDrops.FilterLoot(chestLoot(), nil), 4)

check("a name matches",
    found("ring"), "Keen Conscript's Ring, Bright Conscript's Ring")
check("case does not matter",
    found("RING"), found("ring"))
check("a match anywhere in the name counts",
    found("essence"), "Sun-kissed Essence Box")

-- THE LOOTER IS SEARCHABLE EVEN THOUGH IT IS NOT SORTABLE. "What did Ramor get" is a question
-- the popup is opened for; it is the ordering by name that was unwanted, not the name.
check("a looter matches too",
    found("ramor"), "Keen Conscript's Ring, Bright Conscript's Ring")

-- THE DESCRIPTION UNDER THE NAME IS SEARCHABLE TOO, and it has to be: it is what people call
-- the item in their own words, and typing that used to find the row only because the label was
-- drawn AS the name. Set on the row here rather than hunted for in the data, because no
-- generated row carries a label yet and the rule has to hold the day one does.
local described = _G.LootDrops.DropRow(544, "Sun-kissed Essence Box")
described.label = "Runekeeper shoulders red"

check("a description matches",
    found("runekeeper"), "Sun-kissed Essence Box")
check("case does not matter there either",
    found("RUNEKEEPER"), "Sun-kissed Essence Box")
check("and the name it describes still matches",
    found("essence"), "Sun-kissed Essence Box")

described.label = nil       -- the data is shared with every test below this one

check("nothing matching is nothing shown", found("mithril"), "")

-- Plain find, not a pattern: item names hold apostrophes and dashes, and a search box is not a
-- place anyone expects to escape anything.
check("a dash is a dash",         found("sun-kissed"), "Sun-kissed Essence Box")
check("an apostrophe is one too", found("conscript's"),
    "Keen Conscript's Ring, Bright Conscript's Ring")
check("a magic character finds nothing rather than erroring",
    found("%a"), "")

-- The filter does not re-order: sorting happens before it, and a narrowed list keeps the order
-- it was given -- rows 1 and 3 here, with 2 dropped out from between them.
check("the surviving rows keep their order",
    found("conscript"), "Keen Conscript's Ring, Bright Conscript's Ring")

-- ------------------------------------------------------------------------------------------------
section("Item links  (the clickable form, byte for byte the client's own)")

-- The captured line, verbatim from the live client. The link we BUILD has to be the same shape
-- as the link we PARSE, or one of the two is wrong -- and the parser's is the one proven right.
local CAPTURED =
    "<Examine:IIDDID:0x0000000000000000:0x700713ED>[Enhancement Rune +1]<\\Examine>"

check("a catalogued item builds the client's own link",
    _G.LootDrops.ItemLink({ item = "Enhancement Rune +1", id = 0x700713ED }),
    CAPTURED)

-- THE CLOSING TAG TAKES A BACKSLASH. Not a typo, and not what anyone would guess.
check("the closing tag is <\\Examine>, as captured",
    string.sub(CAPTURED, -10), "<\\Examine>")

-- The instance half is zeroed, which is what makes a link possible for an item nobody holds --
-- the same trick the quickslot shortcut relies on.
check("the instance half is zeroed",
    string.match(_G.LootDrops.ItemLink({ item = "x", id = 0x70073138 }),
        "Examine:IIDDID:(0x%x+):"), "0x0000000000000000")

-- No id, nothing to link to. Same shape so a mixed chest still lines up, just not clickable.
check("no id falls back to a plain bracketed name",
    _G.LootDrops.ItemLink({ item = "Ornate Conscript's Necklace" }),
    "[Ornate Conscript's Necklace]")
check("nil drop still renders something",
    _G.LootDrops.ItemLink(nil, "Silver Serpent"), "[Silver Serpent]")

-- The link TEXT is the display name -- the client's own name for the item, which is what the
-- id resolves to and what the tooltip will say. A row's `label` is a description drawn under
-- the name and is deliberately not what the link reads as: a link pasted into chat has to name
-- the thing it examines.
check("the link reads as the client's name, not the label",
    _G.LootDrops.ItemLink({ item = "Blighted Shoulder-guards of Shadows",
                            label = "Burglar Red Shoulders", id = 0x700713ED }),
    "<Examine:IIDDID:0x0000000000000000:0x700713ED>" ..
    "[Blighted Shoulder-guards of Shadows]<\\Examine>")

-- A group has no name but its label, so there the label IS what the link would read -- except
-- a group carries no id, so it falls back to the plain bracketed form.
check("a group still reads as its label",
    _G.LootDrops.ItemLink({ item = "Group 1", label = "Fallen Armour", isGroup = true }),
    "[Fallen Armour]")

-- ItemId is load-bearing twice over: the link and the layered icon both format an id, and
-- neither can do it to a string.
check("a number id passes through",   _G.LootDrops.ItemId(0x700713ED), 0x700713ED)
check("a hex string becomes a number", _G.LootDrops.ItemId("700713ED"), 0x700713ED)
check("a 0x-prefixed string too",      _G.LootDrops.ItemId("0x700713ED"), 0x700713ED)
check("nil stays nil",                 _G.LootDrops.ItemId(nil), nil)
check("nonsense is not an id",         _G.LootDrops.ItemId("not an id"), nil)

-- An id captured from a drag arrives as a hex STRING; from the data file as a number. Same id.
check("a hex-string id links the same as a number",
    _G.LootDrops.ItemLink({ item = "x", id = "700713ED" }),
    _G.LootDrops.ItemLink({ item = "x", id = 0x700713ED }))
check("and a 0x-prefixed string too",
    _G.LootDrops.ItemLink({ item = "x", id = "0x700713ED" }),
    _G.LootDrops.ItemLink({ item = "x", id = 0x700713ED }))

-- THE ROUND TRIP. A link we print, dropped into a loot line, must come back out of our own
-- parser as the item it names. If the two ever drift apart this fails.
local link = _G.LootDrops.ItemLinkAt(546, "Silver Serpent")
local backOut = string.match("You have acquired: " .. link .. " (pending).",
    _G.LootDrops.P.lootSelf)
check("our own link parses back as a loot line", backOut, "Silver Serpent")

-- and the id survives the trip, which is what the icon route reads
check("and the id comes back out of it",
    string.match(link, "Examine:%w+:0x%x+:0x(%x+)"), "70073138")

-- ------------------------------------------------------------------------------------------------
section("Announce  (the popup owns the item list when it opens)")

local shownChest = nil
_G.LootPopupWindow = { ShowChest = function(_, chest) shownChest = chest end }

local function announced(t, index, items)

    shownChest = nil
    for i = #printed, 1, -1 do printed[i] = nil end

    _G.LootDrops.currentRun = nil
    _G.LootDrops.OnRunStart(51, "T1")

    chest(t, index)
    for i, name in ipairs(items) do
        loot(t + i * 0.1, i == 1 and "you" or ("Player" .. i), name)
    end
    settle(t + 10)

    return #printed
end

-- Enhancement Rune +1 is flagged popup=true, so the window opens and chat gets the HEADER ONLY.
-- The game already printed "You have acquired [...]" itself; a third copy is noise.
check("popup-worthy chest opens the popup",
    announced(500, 546, { "Enhancement Rune +1", "Enhancement Rune +1" }) and shownChest ~= nil,
    true)
check("and chat is the one header line, not the item list",
    announced(600, 546, { "Enhancement Rune +1", "Enhancement Rune +1" }), 1)

-- Silver Serpent is catalogued but NOT flagged, so no popup opens -- and then chat is the only
-- record there is, so the full list must still be printed.
check("filler-only chest opens no popup",
    announced(700, 546, { "Silver Serpent", "Silver Serpent" }) and shownChest, nil)
check("and chat gets the header plus one line per drop",
    announced(800, 546, { "Silver Serpent", "Silver Serpent" }), 3)

-- The same must hold when the popup is switched OFF: the list comes back to chat rather than
-- the chest going unreported.
_G.Settings.showLootPopup = false
check("popup disabled falls back to the full chat list",
    announced(900, 546, { "Enhancement Rune +1", "Enhancement Rune +1" }), 3)
check("and no popup was opened", shownChest, nil)
_G.Settings.showLootPopup = nil

_G.LootPopupWindow = nil

-- ------------------------------------------------------------------------------------------------
print(string.format("\n%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
