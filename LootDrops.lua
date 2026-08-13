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
-- so the name has to be FOUND rather than sat at a known offset. It is safe to look for the
-- bracket: a name cannot contain "[", and the blob is built from high codepoints whose UTF-8
-- bytes are all >= 0x80, so no raw 0x5B can appear inside it either.
--
-- Only the two verbs are patterns now. Locating the bracketed name used to be part of them --
-- ".-%[(.-)%]" -- and that lazy run is the single most expensive thing in the loot path: it
-- re-enters the pattern matcher once per byte of link markup, and an ExamineItemInstance blob
-- is a hundred-odd bytes of it, on every loot line six people generate. ParseLootLine finds
-- the brackets with plain finds instead, which is memchr and not a matcher at all.
local P = {
    lootSelf  = "^You have acquired: ",
    lootOther = "^(%S+) has acquired ",
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
-- searching

-- Everything a row can be found under, lowered ONCE at build time so a keystroke costs a find
-- and nothing else. A drop answers to the name the client prints AND to its label, because
-- whoever is searching knows it by one or the other and has no way to tell which this build
-- stores -- and a category row ("?? Tracery") is only ever seen as its label, so the label is
-- the half that has to find it.
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

-- WHICH ROWS A SEARCH LEAVES STANDING. Pure, and about names rather than pixels, which is why
-- it lives here rather than in the window.
--
-- `rows` is the list the browser has already built, in display order, each entry carrying:
--
--   kind     "header" for a heading, anything else for a row
--   text     the row's own searchable names, from SearchText
--   header   index of the heading above the row, which shows only if something under it survived
--
-- ONE ROW PER ITEM, so there is nothing to answer for anything else: a row shows when its own
-- names match. The drops data used to bucket items into pools and a pool's row had to be found
-- by its members' names; the pools are folded away at build time now.
--
-- Returns a map of index -> shown. An empty search shows everything but the empty headings.
function _G.LootDrops.SearchFilter(rows, search)

    local show = {}

    search = search or ""

    for index, entry in ipairs(rows) do

        if entry.kind == "header" then

            -- cleared on the way past, and lit again below by the first row under it that
            -- shows. One pass does it, because a heading is always built before its rows.
            show[index] = false

        else

            show[index] = (search == "") or Hit(entry.text, search)

        end

        if show[index] and entry.header ~= nil then
            show[entry.header] = true
        end

    end

    return show

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

-- How many ITEMS one chest catalogues, which is what every count in the browser says. The drops
-- data is one row per item, so this is simply how many rows it has -- the fold that used to make
-- 308 table entries into 91 items happens when the file is built, not here.
function _G.LootDrops.ItemCount(eventIndex)
    return #((_G.Drops or {})[eventIndex] or {})
end

-- How many of the game's own table entries one item stands for: the rates behind its figure,
-- and 1 for a row that has only the one. The browser sums this over what it is showing, which
-- is why the total is counted there and not here -- the still-needed filter takes rows out.
function _G.LootDrops.EntrySpan(drop)
    return drop == nil and 0 or math.max(1, #(drop.chances or {}))
end

-- ------------------------------------------------------------------------------------------------
-- chances

-- ONE NAME, SEVERAL CHANCES -- ALREADY FOLDED. A chest does not roll once: it rolls several
-- tables, and an item sitting in more than one of them has a separate chance in each. "Bright
-- Conscript's Necklace" is in six of Kishâsu's pools, at 1.06%, 1.03%, 1.00%, 0.38%, 0.37% and
-- 0.36%.
--
-- The drops file carries that fold: every row is one item, with `chance` -- the chance it drops
-- AT ALL, 1 - Π(1 - c) -- and `chances`, the individual rates behind it, biggest first and
-- absent where there is only one. So there is nothing to compute here, and nothing to cache:
-- both windows read the row.
--
-- `chance` may be nil, which means "drops, rate not established" and must never print as 0%.

-- The rates behind one item's figure at one chest, biggest first, or an empty list. A row with a
-- single entry has no `chances`: its `chance` IS that entry, which is what the caller gets.
function _G.LootDrops.ItemChances(eventIndex, itemName)

    local drop = _G.LootDrops.DropRow(eventIndex, itemName)

    if drop == nil then return {} end

    if drop.chances ~= nil then return drop.chances end

    return drop.chance ~= nil and { drop.chance } or {}

end

-- The chance one item drops at all from one chest, or nil where it is uncatalogued or the
-- tables give no rate. THE BROWSER'S NUMBER, read off the same row the browser draws, so a rate
-- seen in the popup and looked up in the browser cannot disagree.
function _G.LootDrops.ItemChance(eventIndex, itemName)

    local drop = _G.LootDrops.DropRow(eventIndex, itemName)

    return drop and drop.chance or nil

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
function _G.LootDrops.EntrySeries(chances)

    if chances == nil or #chances < 2 then return nil end

    local parts = {}

    for _, chance in ipairs(chances) do
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

        -- The row for the name as CAPTURED, which is the one row this item has at this chest.
        local drop = _G.LootDrops.DropRow(entry.logIndex, entry.item.base)

        entry.sortName   = _G.LootDrops.DisplayName(drop, entry.item.base)
        -- the number the row prints, so the list is sorted by what the player can see
        entry.sortChance = drop and drop.chance or nil
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

-- Is this drop on the wishlist?
--
-- The wishlist is keyed on the item name, which is also what the browser's star sets and what
-- the drops data is keyed on -- one name, one row, one star. One helper because three places
-- ask the question -- whether to open the popup, whether to draw the star on a row, and where
-- that row sorts -- and they must never disagree.
--
-- `eventIndex` is not read today. It stays in the signature because the question is asked about
-- a drop AT A CHEST, and taking it away would have every caller stop passing it.
function _G.LootDrops.IsWished(eventIndex, base)

    if _G.LootStats == nil then return false end

    return _G.LootStats.IsWished(base) == true

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

-- THE BUFFER IS A RING, not a list that is rebuilt.
--
-- Pruning used to allocate a fresh table and copy every survivor into it on EVERY loot line,
-- then shift the whole thing down with table.remove(kept, 1) once the cap was reached -- which
-- is exactly when a six-man run is at its busiest. Both costs are per line, and both are gone:
-- entries only ever leave from the front, so a head index removes them in constant time.
--
-- `head`..`tail` are live; everything outside is nil. The table is compacted back to 1 when it
-- empties (any pause in looting longer than the window does it) or when the head has walked
-- past a bufferful, so the array part cannot grow with the length of the session.
local buffer  = {}
local head    = 1
local tail    = 0

local pending = nil
local newRun  = false       -- a run started; the next resolved chest opens a fresh one

local ticker  = nil         -- only runs while a chest is pending

local function Now()
    return Turbine.Engine.GetGameTime()
end

-- Age, not count. A 40-entry cap held well under a second of a six-man run, which would have
-- let the forward window read a buffer that had already discarded what it wanted. The count
-- below is only a memory backstop.
--
-- Stopping at the first entry young enough relies on the buffer being in time order, which it
-- is: entries are appended as chat prints them and game time does not run backwards.
local function Prune(now)

    local horizon = now - BackWindow() - 2

    while head <= tail and buffer[head].t < horizon do
        buffer[head] = nil
        head         = head + 1
    end

    while tail - head + 1 > BUFFER_MAX do
        buffer[head] = nil
        head         = head + 1
    end

    if head > tail then

        head, tail = 1, 0

    elseif head > BUFFER_MAX then

        -- Amortised: the head has to walk a whole bufferful before this runs again, so the
        -- shift costs O(1) per line. Writing down before reading up is safe because what is
        -- left is at most BUFFER_MAX entries and the head is already past that.
        local slot = 0
        for index = head, tail do
            slot          = slot + 1
            buffer[slot]  = buffer[index]
            buffer[index] = nil
        end
        head, tail = 1, slot

    end

end

-- Unclaimed loot from the buffer at or after `since`.
--
-- `claimed` is what stops two chests counting one line twice. A timestamp cut-off is not
-- enough: a chest's FORWARD window reaches past its own timestamp, so a second chest opened
-- half a second later would find those lines sitting in the buffer, later than the first
-- chest's time, and take them as well.
local function Since(since)

    local items = {}

    for index = head, tail do
        local item = buffer[index]
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

-- Who looted what, out of one chat line: looter, the raw bracketed name, and whether it was
-- you. nil for anything that is not a loot line -- currency shares the channel and has no
-- bracket at all.
--
-- The whole of the loot path's parsing lives here so there is one answer to "is this a loot
-- line", and the order it asks in is the order the old pair of patterns asked in: yours first,
-- then anybody's.
function _G.LootDrops.ParseLootLine(message)

    -- CHEAPEST TEST FIRST. Every loot line has a bracketed name; most lines on this channel are
    -- not loot lines, and this rules them out with one memchr rather than two pattern runs.
    local open = string.find(message, "[", 1, true)
    if open == nil then return nil end

    local close = string.find(message, "]", open + 1, true)
    if close == nil then return nil end

    if string.find(message, P.lootSelf) ~= nil then
        return _G.name, string.sub(message, open + 1, close - 1), true
    end

    local player = string.match(message, P.lootOther)
    if player == nil then return nil end

    return player, string.sub(message, open + 1, close - 1), false

end

-- Called from ChatParsing for SelfLoot (36) and FellowLoot (37) only. Those types are
-- discarded by the filter below the call site; this runs before it.
function _G.LootDrops.HandleChat(chatType, message)

    local player, raw, isSelf = _G.LootDrops.ParseLootLine(message)

    if raw == nil then return end

    local base, level, quantity = _G.LootDrops.Normalise(raw)

    -- everything not in the drops database is dropped silently, by design. This is also what
    -- keeps trash loot out: one run produced 240 sightings of a single uncatalogued item.
    local canonical = Canonical(base)
    if canonical == nil then return end

    -- Gated on a plain find, because the id is a bonus and most lines do not carry one: the
    -- ExamineItemInstance form has no id, and an unanchored pattern would still have walked the
    -- whole line looking for one. A match can only begin at the literal the pattern opens with,
    -- so starting there loses nothing.
    local id      = nil
    local examine = string.find(message, "Examine:", 1, true)
    if examine ~= nil then
        id = string.match(message, EXAMINE_ID, examine)
    end

    local entry = {
        base     = canonical,
        level    = level,
        quantity = quantity,
        player   = player,
        isSelf   = isSelf,
        id       = id,
        t        = Now(),
    }

    tail         = tail + 1
    buffer[tail] = entry
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
