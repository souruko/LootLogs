-- Loot browser: a SEPARATE window listing the drops database.
--
-- Left pane is a content pack -> instance -> boss tree built from _G.Content, _G.Instances and
-- _G.Events, filtered to instances that actually have _G.Drops rows. Right pane is the item
-- table for the selection, at the selected tier, FOR ONE CLASS.
--
-- ONE CHEST, ONE CLASS, ONE ROW PER ITEM. The loot tables are filtered by class, so a chest listed
-- for everybody was mostly rows nobody reading it could get -- 217 of them at Badharál T3 against
-- 32 for a Warden. The class strip picks whose table this is; every count on screen is that
-- class's, and all of them come out of _G.LootDrops.RowsFor so they cannot drift apart.
--
-- FAVOURED AND COMMON ARE TWO LOCKOUTS, never one blended figure: a row is tagged for the tables
-- it sits in and carries a chance per lock, and the hover on that chance shows the rolls the
-- figure was folded from (_G.LootDrops.RollLines).
--
-- The tier segment is derived from the distinct tier values of the selected instance's events,
-- ordered by _G.TierOrder -- so it is always right per instance, including the ones that carry
-- Solo on top of T1-T5, with no list maintained here.
--
-- SEARCHING NARROWS THE SELECTION, it does not leave it. Either search box filters the chest and
-- tier already on screen, and it does it without building anything: BuildRows() makes the rows
-- of the selection once, ApplyFilter() decides which of them the list shows.

import "LootLogs.UI.Window.PanelWindow"
import "LootLogs.UI.Window.LootRow"

local PAD, GAP, SEP_W, ROW_H, TREE_ROW_H, HEAD_H, TREE_W, PILL_H, SEARCH_H
local STAR, INDENT, SLOT, MARK, NAME_X, ICON, FIND
local HEADER_H, CLASS_H, CLASS_CELL, CLASS_ICON, CLASS_LABEL_W, TAG_H, SECTION_H, CELL_W, SOURCE_W
local COL_TABLE, COL_CHANCE, COL_BAR, BAR_H, COL_ROLLS, COL_YOURS, COL_STAR
local MIN_WIDTH, MIN_HEIGHT

local function Metrics()
    SEP_W      = 1
    PAD        = _G.Scaled(8)
    GAP        = _G.Scaled(8)
    SLOT       = _G.LootSlotSize
    -- the group mark's own size. It is a plugin .tga and stays the size it was drawn at, so it
    -- is centred in the slot rather than stretched to it (Ressources/ICONS.md).
    MARK       = 32
    -- item rows seat a 36px item slot, and item art does not scale with the Font Size setting;
    -- tree nodes carry only text and stay at the compact height, so the left pane does not turn
    -- into a ladder
    ROW_H      = _G.LootRowHeight()
    TREE_ROW_H = _G.Scaled(24)
    NAME_X     = PAD + 3 + math.floor(GAP / 2) + SLOT + GAP
    HEAD_H     = _G.Scaled(20)
    PILL_H     = _G.Scaled(20)
    SEARCH_H   = _G.Scaled(24)
    TREE_W     = _G.Scaled(212)
    INDENT     = _G.Scaled(12)
    STAR       = 12
    -- the .tga is clipped to its control rather than scaled, so the glyph stays 16px at every
    -- font size and only the button around it has room to spare (Ressources/ICONS.md)
    ICON       = 16
    FIND       = 18
    -- the boss line needs air around a 20px segment, and the sub-line under it is the only
    -- place the per-class counts are said
    HEADER_H   = _G.Scaled(46)
    -- 12 classes x 26 = 312px, which still fits the 840px minimum beside its label
    CLASS_H       = _G.Scaled(30)
    CLASS_CELL    = _G.Scaled(26)
    CLASS_ICON    = 20
    CLASS_LABEL_W = _G.Scaled(48)
    -- one cell of a segmented control: three of them and their frame make the tier picker
    CELL_W     = _G.Scaled(34)
    SOURCE_W   = _G.Scaled(60)
    TAG_H      = _G.Scaled(16)
    SECTION_H  = _G.Scaled(22)
    -- WHICH TABLE THE ROW CAME OUT OF, as a FAV/COM chip. It is paid for by the old ENTRIES
    -- column: a row of bare per-entry rates is what the hover now explains properly, and 140px
    -- of them bought this column, a wider CHANCE and 12px back for the name.
    COL_TABLE   = _G.Scaled(76)
    COL_CHANCE  = _G.Scaled(64)
    -- Art, not text, so both stay put at every font size -- the same rule as the 36px item
    -- icon and the 12px star.
    COL_BAR     = 60
    BAR_H       = 4
    COL_ROLLS  = _G.Scaled(40)
    COL_YOURS  = _G.Scaled(78)
    COL_STAR   = _G.Scaled(24)
    MIN_WIDTH  = _G.Scaled(840)
    -- the class strip and the taller heading cost 38px, and the table under them still has to
    -- show more than a row and a half
    MIN_HEIGHT = _G.Scaled(470)
end

_G.RegisterMetrics(Metrics)

-- Below this many opens a measured rate is noise, so it is shown in DIM. The sample size is
-- printed either way -- a 1-of-1 drop reading "100%" beside a database value of 12% destroys
-- trust in the whole window.
local CONFIDENT_OPENS = 10

-- A row whose chance is this or better is a certainty rounded, and leads the table under ALWAYS
-- DROPS rather than being read off a page of percentages.
local ALWAYS = 0.999

-- The twelve playable classes, in the order the client's own character panel lists them. The ids
-- are read off the enum rather than written down here, and _G.ClassIcons is not the list: it also
-- carries the monster-play classes, which no chest has a table for.
local PLAYABLE = { "Beorning", "Brawler", "Burglar", "Captain", "Champion", "Guardian",
                   "Hunter", "LoreMaster", "Mariner", "Minstrel", "RuneKeeper", "Warden" }

-- the two the enum spells without the hyphen the game shows
local CLASS_WORDS = { LoreMaster = "Lore-master", RuneKeeper = "Rune-keeper" }


_G.LootBrowser = class(_G.PanelWindow)

-- The strip's cells, built once: the enum does not change while the client is running, and the
-- window rebuilds its strip every time the table does.
local classes = nil

function _G.LootBrowser.Classes()

    if classes ~= nil then return classes end

    classes = {}

    for _, key in ipairs(PLAYABLE) do
        local id = Turbine.Gameplay.Class[key]
        if id ~= nil and _G.ClassIcons[id] ~= nil then
            classes[#classes + 1] = { id = id, name = CLASS_WORDS[key] or key }
        end
    end

    return classes

end

function _G.LootBrowser:Constructor()

    _G.PanelWindow.Constructor(self, {
        resizable  = true,
        min_width  = MIN_WIDTH,
        min_height = MIN_HEIGHT,
    })

    self.selectedInstance = nil
    self.selectedEvent    = nil     -- nil = whole instance, grouped by boss
    self.selectedTier     = nil
    self.search           = ""
    self.searchText       = ""      -- as typed; self.search is the lowered form matched against
    self.headSearchOpen   = false
    self.tierCells        = {}
    self.sourceCells      = {}
    self.classCells       = {}

    -- WHOSE TABLE THIS IS. Your own class to begin with -- it is the answer nine times in ten --
    -- and the last one you picked after that, because comparing what a chest gives your alt is
    -- exactly what the strip is for and re-picking it on every open would be a chore.
    self.yourClass     = _G.localPlayer ~= nil and _G.localPlayer:GetClass() or nil
    self.selectedClass = _G.Settings.lootBrowser.class or self.yourClass

    -- All / Favoured / Common. It changes what EXISTS in the table rather than what is shown of
    -- it, so it lives in BuildRows and not in ApplyFilter.
    self.source = "all"

    self:SetTitleText(_G.CM("ACCENT") .. "Loot Browser" .. _G.CMR)

    -- left pane -----------------------------------------------------------------------------
    self.treePane = Turbine.UI.Control()
    self.treePane:SetParent(self.client)
    self.treePane:SetBackColor(_G.Theme.PANEL)

    self.searchBg = Turbine.UI.Control()
    self.searchBg:SetParent(self.treePane)
    self.searchBg:SetBackColor(_G.Theme.BG)

    self.searchIcon = Turbine.UI.Control()
    self.searchIcon:SetParent(self.searchBg)
    self.searchIcon:SetSize(16, 16)
    self.searchIcon:SetBackground("LootLogs/Ressources/search.tga")
    self.searchIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.searchIcon:SetMouseVisible(false)

    self.searchBox = Turbine.UI.TextBox()
    self.searchBox:SetParent(self.searchBg)
    self.searchBox:SetMultiline(false)
    self.searchBox:SetFont(_G.Font(12))
    self.searchBox:SetBackColor(_G.Theme.BG)
    self.searchBox:SetForeColor(_G.Theme.TEXT)
    self.searchBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.searchBox:SetText("")

    self.searchHint = Turbine.UI.Label()
    self.searchHint:SetParent(self.searchBg)
    self.searchHint:SetMultiline(false)
    self.searchHint:SetFont(_G.Font(12))
    self.searchHint:SetFontStyle(_G.Theme.FONT_STYLE)
    self.searchHint:SetForeColor(_G.Theme.DIM)
    self.searchHint:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.searchHint:SetText(_G.L("searchPlaceholder"))
    self.searchHint:SetMouseVisible(false)

    self.searchBox.TextChanged = function()
        self:SetSearch(self.searchBox:GetText())
    end

    self.treeHost = Turbine.UI.ListBox()
    self.treeHost:SetParent(self.treePane)
    self.treeHost:SetBackColor(_G.Theme.PANEL)

    self.treeScroll = Turbine.UI.Lotro.ScrollBar()
    self.treeScroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.treeScroll:SetParent(self.treePane)
    self.treeScroll:SetWidth(10)
    self.treeHost:SetVerticalScrollBar(self.treeScroll)

    -- right pane ----------------------------------------------------------------------------
    -- The tier sits on the heading line, immediately right of the boss it belongs to: a chest is
    -- one (boss, tier) pair, and reading them apart -- the boss here, its tier over in the tree --
    -- was asking the eye to join two halves of one fact back together.
    self.tierStrip = Turbine.UI.Control()
    self.tierStrip:SetParent(self.client)
    self.tierStrip:SetMouseVisible(false)

    self.sourceStrip = Turbine.UI.Control()
    self.sourceStrip:SetParent(self.client)
    self.sourceStrip:SetMouseVisible(false)

    self.classStrip = Turbine.UI.Control()
    self.classStrip:SetParent(self.client)
    self.classStrip:SetMouseVisible(false)

    self.classLabel = Turbine.UI.Label()
    self.classLabel:SetParent(self.classStrip)
    self.classLabel:SetMultiline(false)
    self.classLabel:SetFont(_G.Font(10))
    self.classLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.classLabel:SetForeColor(_G.Theme.DIM)
    self.classLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.classLabel:SetText(_G.Spaced(_G.Upper(_G.L("classLabel"))))
    self.classLabel:SetMouseVisible(false)

    -- THE BOSS, not the instance: the instance is the branch the chest hangs off and it is
    -- already lit in the tree, while what every rate on the page belongs to is one chest -- and
    -- the tier segment sits against this name because a chest is one (boss, tier) pair.
    self.bossLabel = Turbine.UI.Label()
    self.bossLabel:SetParent(self.client)
    self.bossLabel:SetMultiline(false)
    self.bossLabel:SetFont(_G.Font(14))
    self.bossLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.bossLabel:SetForeColor(_G.Theme.TEXT)
    self.bossLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.bossLabel:SetMouseVisible(false)

    self.countLabel = Turbine.UI.Label()
    self.countLabel:SetParent(self.client)
    self.countLabel:SetMultiline(false)
    self.countLabel:SetFont(_G.Font(10))
    self.countLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.countLabel:SetForeColor(_G.Theme.DIM)
    self.countLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.countLabel:SetMouseVisible(false)

    self.tableHead = Turbine.UI.Control()
    self.tableHead:SetParent(self.client)
    self.tableHead:SetBackColor(_G.Theme.HEADER)
    self.tableHead:SetMouseVisible(false)

    self.headLabels = {}
    for _, spec in ipairs({ { "colItem",   Turbine.UI.ContentAlignment.MiddleLeft },
                            { "colTable",  Turbine.UI.ContentAlignment.MiddleLeft },
                            { "colChance", Turbine.UI.ContentAlignment.MiddleRight },
                            { "colRolls",  Turbine.UI.ContentAlignment.MiddleRight },
                            { "colYours",  Turbine.UI.ContentAlignment.MiddleRight } }) do
        local label = Turbine.UI.Label()
        label:SetParent(self.tableHead)
        label:SetMultiline(false)
        label:SetHeight(HEAD_H)
        label:SetFont(_G.Font(10))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.DIM)
        label:SetTextAlignment(spec[2])
        label:SetText(_G.Spaced(_G.Upper(_G.L(spec[1]))))
        label:SetMouseVisible(false)
        self.headLabels[#self.headLabels + 1] = label
    end

    -- Search from the item column itself. It drives the same filter as the left-pane box --
    -- one search, two ways in -- because "is this thing in here" is asked while reading the
    -- item list, not while reading the tree. The button is mouse-visible inside a header that
    -- is not; a child is hit-tested on its own, the same way the tier pills are.
    self.headSearchBtn = Turbine.UI.Control()
    self.headSearchBtn:SetParent(self.tableHead)
    self.headSearchBtn:SetSize(FIND, FIND)
    self.headSearchBtn:SetBackColor(_G.Theme.HEADER)
    self.headSearchBtn:SetMouseVisible(true)

    local findIcon = Turbine.UI.Control()
    findIcon:SetParent(self.headSearchBtn)
    findIcon:SetSize(ICON, ICON)
    findIcon:SetPosition(math.floor((FIND - ICON) / 2), math.floor((FIND - ICON) / 2))
    findIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    findIcon:SetBackground("LootLogs/Ressources/search.tga")
    findIcon:SetMouseVisible(false)

    self.headSearchBtn.MouseEnter = function()
        self.headSearchBtn:SetBackColor(_G.Theme.FRAME)
    end
    self.headSearchBtn.MouseLeave = function()
        self.headSearchBtn:SetBackColor(_G.Theme.HEADER)
    end
    self.headSearchBtn.MouseClick = function() self:ShowHeadSearch(true) end

    -- the field takes the item column's place in the header while it is open
    self.headSearchBg = Turbine.UI.Control()
    self.headSearchBg:SetParent(self.tableHead)
    self.headSearchBg:SetBackColor(_G.Theme.BG)
    self.headSearchBg:SetVisible(false)

    self.headSearchIcon = Turbine.UI.Control()
    self.headSearchIcon:SetParent(self.headSearchBg)
    self.headSearchIcon:SetSize(ICON, ICON)
    self.headSearchIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.headSearchIcon:SetBackground("LootLogs/Ressources/search.tga")
    self.headSearchIcon:SetMouseVisible(false)

    self.headSearchBox = Turbine.UI.TextBox()
    self.headSearchBox:SetParent(self.headSearchBg)
    self.headSearchBox:SetMultiline(false)
    self.headSearchBox:SetFont(_G.Font(12))
    self.headSearchBox:SetBackColor(_G.Theme.BG)
    self.headSearchBox:SetForeColor(_G.Theme.TEXT)
    self.headSearchBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headSearchBox:SetText("")

    self.headSearchHint = Turbine.UI.Label()
    self.headSearchHint:SetParent(self.headSearchBg)
    self.headSearchHint:SetMultiline(false)
    self.headSearchHint:SetFont(_G.Font(12))
    self.headSearchHint:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headSearchHint:SetForeColor(_G.Theme.DIM)
    self.headSearchHint:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headSearchHint:SetText(_G.L("searchPlaceholder"))
    self.headSearchHint:SetMouseVisible(false)

    self.headSearchBox.TextChanged = function()
        self:SetSearch(self.headSearchBox:GetText())
    end

    -- Closing clears: a filter still running behind a folded-away field would read as a table
    -- that has lost half its rows for no reason.
    self.headSearchClear = Turbine.UI.Control()
    self.headSearchClear:SetParent(self.headSearchBg)
    self.headSearchClear:SetSize(FIND, FIND)
    self.headSearchClear:SetBackColor(_G.Theme.BG)
    self.headSearchClear:SetMouseVisible(true)

    local clearIcon = Turbine.UI.Control()
    clearIcon:SetParent(self.headSearchClear)
    clearIcon:SetSize(ICON, ICON)
    clearIcon:SetPosition(math.floor((FIND - ICON) / 2), math.floor((FIND - ICON) / 2))
    clearIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    clearIcon:SetBackground("LootLogs/Ressources/cross.tga")
    clearIcon:SetMouseVisible(false)

    self.headSearchClear.MouseEnter = function()
        self.headSearchClear:SetBackColor(_G.Theme.FRAME)
    end
    self.headSearchClear.MouseLeave = function()
        self.headSearchClear:SetBackColor(_G.Theme.BG)
    end
    self.headSearchClear.MouseClick = function()
        self:SetSearch("")
        self:ShowHeadSearch(false)
    end

    self.tableHost = Turbine.UI.ListBox()
    self.tableHost:SetParent(self.client)
    self.tableHost:SetBackColor(_G.Theme.BG)

    self.tableScroll = Turbine.UI.Lotro.ScrollBar()
    self.tableScroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.tableScroll:SetParent(self.client)
    self.tableScroll:SetWidth(10)
    self.tableHost:SetVerticalScrollBar(self.tableScroll)

    self.footLabel = Turbine.UI.Label()
    self.footLabel:SetParent(self.client)
    self.footLabel:SetMultiline(false)
    self.footLabel:SetFont(_G.Font(10))
    self.footLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.footLabel:SetForeColor(_G.Theme.DIM)
    self.footLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.footLabel:SetMouseVisible(false)

    self.hintLabel = Turbine.UI.Label()
    self.hintLabel:SetParent(self.client)
    self.hintLabel:SetMultiline(false)
    self.hintLabel:SetFont(_G.Font(10))
    self.hintLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.hintLabel:SetForeColor(_G.Theme.DIM)
    self.hintLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    -- the text is chosen in OnLayout, where the room it has is known
    self.hintLabel:SetMouseVisible(false)

    self:SetWantsKeyEvents(true)
    self.KeyDown = function(sender, args)
        if args.Action == Turbine.UI.Lotro.Action.Escape then
            self:CloseWindow()
        end
    end

    -- open on the first catalogued instance, so the window is never empty on first sight
    local catalogued = self:CataloguedInstances()
    if #catalogued > 0 then
        self:SelectInstance(catalogued[1].id)
    end

    local settings = _G.Settings.lootBrowser
    self:SetPosition(settings.left, settings.top)
    self:SetSize(math.max(MIN_WIDTH,  settings.width),
                 math.max(MIN_HEIGHT, settings.height))

    self:SetVisible(false)

end

-- ------------------------------------------------------------------------------------------------
-- data

-- instances that have at least one catalogued chest, in content pack order
function _G.LootBrowser:CataloguedInstances()

    local seen = {}

    if _G.Drops ~= nil then
        for eventIndex in pairs(_G.Drops) do
            local event = _G.Events[eventIndex]
            if event ~= nil then seen[event.instance] = true end
        end
    end

    local list = {}
    for instanceId in pairs(seen) do
        local instance = _G.Instances[instanceId]
        if instance ~= nil then
            list[#list + 1] = { id = instanceId, instance = instance,
                                content = instance.content or 0 }
        end
    end

    -- newest content first, matching how the sidebar orders its packs
    table.sort(list, function(a, b)
        if a.content ~= b.content then return a.content > b.content end
        return a.instance.name < b.instance.name
    end)

    return list

end

-- distinct tiers of one instance that actually have drops, lowest first. The answer is data,
-- so it lives in LootDrops and is tested there; this is only the window asking.
function _G.LootBrowser:TiersFor(instanceId)
    return _G.LootDrops.TiersFor(instanceId)
end

-- catalogued bosses of one instance at one tier, in boss order
function _G.LootBrowser:BossesFor(instanceId, tier)

    local list = {}

    if _G.Drops ~= nil then
        for eventIndex in pairs(_G.Drops) do
            local event = _G.Events[eventIndex]
            if event ~= nil and event.instance == instanceId
                and tostring(event.tier) == tostring(tier) then
                list[#list + 1] = { index = eventIndex, event = event }
            end
        end
    end

    table.sort(list, function(a, b)
        return (a.event.order or 99) < (b.event.order or 99)
    end)

    return list

end

-- ------------------------------------------------------------------------------------------------
-- search

-- One filter, two fields. Either box may be typed in and the other is set to match: two search
-- fields showing different text while a single filter runs would be worse than having one.
--
-- Typing does NOT rebuild the table. The rows of the current selection are already built and
-- kept (see BuildRows); a keystroke only decides which of them the list shows, which is why
-- searching stays instant on a chest with a few hundred catalogued rows.
function _G.LootBrowser:SetSearch(text)

    -- setting the other box below fires its own TextChanged; this makes that arrival a no-op
    if self._syncing then return end

    text = text or ""
    if text == self.searchText then return end

    self.searchText = text
    self.search     = string.lower(text)

    self._syncing = true
    if self.searchBox:GetText() ~= text     then self.searchBox:SetText(text)     end
    if self.headSearchBox:GetText() ~= text then self.headSearchBox:SetText(text) end
    self._syncing = false

    self.searchHint:SetVisible(self.search == "")
    self.headSearchHint:SetVisible(self.search == "")

    -- typing in the left box opens the header field, so the column always shows what is
    -- filtering it. Emptying it does not close it -- the field must not vanish out from
    -- under whoever is backspacing in it.
    if self.search ~= "" then self:ShowHeadSearch(true) end

    -- the tree lists instances and their catalogued totals, neither of which the search touches
    self:ApplyFilter()

end

function _G.LootBrowser:ShowHeadSearch(open)

    if self.headSearchOpen == open then return end
    self.headSearchOpen = open

    self.headSearchBg:SetVisible(open)
    self.headSearchBtn:SetVisible(not open)
    self.headLabels[1]:SetVisible(not open)

    -- clicking the magnifier should leave the caret in the field, not one click away from it
    if open and self.headSearchBox.Focus ~= nil then
        self.headSearchBox:Focus()
    end

end

-- The chest to show for an instance at a tier: the one whose boss you were already reading if
-- that boss exists here, else the first.
--
-- KEPT BY NAME, because the event index is not the chest -- it is one (boss, tier) pair, so
-- Kishâsu at T2 and Kishâsu at T3 are two different indices. Changing tier is a question about
-- the same boss ("and what does it give at T3?"), and answering it by jumping back to the first
-- chest in the instance makes the tier pills unusable for the one thing they are for.
function _G.LootBrowser:BossAt(instanceId, tier, preferred)

    local bosses = self:BossesFor(instanceId, tier)

    if preferred ~= nil then
        for _, boss in ipairs(bosses) do
            if boss.event.name == preferred then return boss.index end
        end
    end

    return bosses[1] and bosses[1].index or nil

end

-- What the table is showing: the name of the selected chest's boss, or nil when nothing is.
function _G.LootBrowser:SelectedBossName()

    local event = self.selectedEvent and _G.Events[self.selectedEvent]

    return event and event.name or nil

end

function _G.LootBrowser:SelectInstance(instanceId)

    local wasBoss = self:SelectedBossName()

    self.selectedInstance = instanceId

    -- THE HIGHEST TIER, not the lowest. TiersFor returns them lowest first, so this is the last
    -- of them -- and it is the one people are looking at: a chest is farmed at the top tier, and
    -- opening on Solo showed the smallest table in the instance to someone who came to compare
    -- the biggest.
    local tiers = self:TiersFor(instanceId)
    self.selectedTier = tiers[#tiers]

    -- ONE CHEST AT A TIME. An instance is where its chests live, not a table of its own: the
    -- three of them share most of their pools, so listing them together was the same eight
    -- hundred rows three times over with a heading between them, and no rate on the page meant
    -- anything until you had found which boss you were under.
    self.selectedEvent = self:BossAt(instanceId, self.selectedTier, wasBoss)

    self:RebuildTree()
    self:RebuildTable()

end

-- ------------------------------------------------------------------------------------------------
-- left pane

-- One tree node. `kind` drives the indent and the type size, so packs, instances and bosses
-- read as three levels without three near-identical builders.
function _G.LootBrowser:MakeNode(kind, text, count, selected, onClick)

    local row = Turbine.UI.Control()
    row:SetHeight(TREE_ROW_H)
    row:SetBackColor(selected and _G.Theme.CHIP_FAV_BG or _G.Theme.PANEL)
    row:SetMouseVisible(onClick ~= nil)

    local indent = PAD + (kind == "pack" and 0 or (kind == "instance" and INDENT or INDENT * 2))

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetMultiline(false)
    label:SetPosition(indent, 0)
    label:SetHeight(TREE_ROW_H)
    label:SetFont(_G.Font(kind == "pack" and 10 or 12))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetMouseVisible(false)

    if kind == "pack" then
        label:SetForeColor(_G.Theme.DIM)
        label:SetText(_G.Spaced(_G.Upper(text)))
    else
        label:SetForeColor(selected and _G.Theme.CHIP_FAV_TEXT or _G.Theme.TEXT)
        label:SetText(text)
    end

    row.label  = label
    row.indent = indent

    if count ~= nil then
        local countLabel = Turbine.UI.Label()
        countLabel:SetParent(row)
        countLabel:SetMultiline(false)
        countLabel:SetHeight(TREE_ROW_H)
        countLabel:SetFont(_G.Font(10))
        countLabel:SetFontStyle(_G.Theme.FONT_STYLE)
        countLabel:SetForeColor(_G.Theme.DIM)
        countLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
        countLabel:SetText(tostring(count))
        countLabel:SetMouseVisible(false)
        row.countLabel = countLabel
    end

    if onClick ~= nil then
        row.MouseEnter = function()
            if not selected then row:SetBackColor(_G.Theme.FRAME) end
        end
        row.MouseLeave = function()
            if not selected then row:SetBackColor(_G.Theme.PANEL) end
        end
        row.MouseClick = onClick
    end

    row.SizeChanged = function()
        local width = row:GetWidth()
        local right = row.countLabel and _G.Scaled(28) or PAD
        label:SetWidth(math.max(0, width - row.indent - right))
        if row.countLabel then
            row.countLabel:SetPosition(math.max(0, width - _G.Scaled(28)), 0)
            row.countLabel:SetWidth(_G.Scaled(24))
        end
    end

    return row

end

function _G.LootBrowser:RebuildTree()

    self.treeHost:ClearItems()

    local lastContent = nil

    for _, entry in ipairs(self:CataloguedInstances()) do

        local content = _G.Content and _G.Content[entry.content]
        local packName = content and content.name or "?"

        if entry.content ~= lastContent then
            lastContent = entry.content
            self.treeHost:AddItem(self:MakeNode("pack", packName, nil, false, nil))
        end

        -- How many ROWS this instance draws for the selected class, across every tier. Not table
        -- entries and not every class's rows: both told the sidebar a number the table beside it
        -- could not show -- 308 where the table shows 91 -- and the figure that disagrees with
        -- what can be seen is the one that gets believed.
        local total = 0
        for eventIndex in pairs(_G.Drops or {}) do
            local event = _G.Events[eventIndex]
            if event ~= nil and event.instance == entry.id then
                total = total + _G.LootDrops.ItemCount(eventIndex, self.selectedClass)
            end
        end

        local instanceId = entry.id
        -- the OPEN instance is lit, not a selection of its own: what is selected is always one
        -- of its chests, and the instance line is the branch that chest is under
        local selected   = (self.selectedInstance == instanceId)

        self.treeHost:AddItem(self:MakeNode("instance", entry.instance.name, total, selected,
            function() self:SelectInstance(instanceId) end))

        -- bosses, only under the open instance, and only at the tier being shown
        if self.selectedInstance == instanceId then
            for _, boss in ipairs(self:BossesFor(instanceId, self.selectedTier)) do
                local eventIndex = boss.index
                local bossCount  = _G.LootDrops.ItemCount(eventIndex, self.selectedClass)
                self.treeHost:AddItem(self:MakeNode("boss", boss.event.name, bossCount,
                    self.selectedEvent == eventIndex,
                    function()
                        -- NO TOGGLE OFF. There is always a chest on screen, so clicking the one
                        -- you are already reading does nothing rather than emptying the table.
                        self.selectedEvent = eventIndex
                        self:RebuildTree()
                        self:RebuildTable()
                    end))
            end
        end

    end

end

-- ------------------------------------------------------------------------------------------------
-- the pickers: tier, table, class

-- ONE FRAME, SEVERAL CELLS. The tiers of a chest are one question with one answer, and three
-- separate pills said three separate questions; a segment says "pick one of these". The frame is
-- the host's own ground showing through 1px gaps, so it is one control with cells in it rather
-- than three controls that have to be kept looking related.
function _G.LootBrowser:MakeSegment(host, previous, specs)

    for _, cell in ipairs(previous or {}) do
        cell:SetParent(nil)
    end

    host:SetBackColor(_G.Theme.FRAME)

    local cells, x = {}, SEP_W

    for _, spec in ipairs(specs) do

        local selected = spec.selected
        local width    = spec.width or CELL_W

        local cell = Turbine.UI.Control()
        cell:SetParent(host)
        cell:SetPosition(x, SEP_W)
        cell:SetSize(width, PILL_H - 2 * SEP_W)
        cell:SetBackColor(selected and _G.Theme.CHIP_FAV_BG or _G.Theme.BG)
        cell:SetMouseVisible(true)

        local label = Turbine.UI.Label()
        label:SetParent(cell)
        label:SetMultiline(false)
        label:SetSize(width, PILL_H - 2 * SEP_W)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(_G.Font(10))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(selected and _G.Theme.CHIP_FAV_TEXT or _G.Theme.DIM2)
        label:SetText(spec.text)
        label:SetMouseVisible(false)

        cell.MouseEnter = function()
            if not selected then cell:SetBackColor(_G.Theme.HOVER) end
        end
        cell.MouseLeave = function()
            if not selected then cell:SetBackColor(_G.Theme.BG) end
        end
        cell.MouseClick = spec.onClick

        x = x + width + SEP_W
        cells[#cells + 1] = cell

    end

    -- the host is exactly its cells wide, so the frame never runs on past the last one
    host:SetSize(x, PILL_H)

    return cells

end

function _G.LootBrowser:RebuildTierSegment()

    local specs = {}

    for _, tier in ipairs(self:TiersFor(self.selectedInstance)) do

        local pick = tier

        specs[#specs + 1] = {
            text     = tier,
            selected = (tostring(self.selectedTier) == tier),
            onClick  = function()
                -- The selection belongs to the old tier -- a chest is one (boss, tier) pair -- so
                -- it is re-resolved rather than kept: the SAME BOSS at the new tier, which is the
                -- question the segment exists to answer, or this tier's first chest if that boss
                -- is not among them.
                local boss = self:SelectedBossName()
                self.selectedTier  = pick
                self.selectedEvent = self:BossAt(self.selectedInstance, pick, boss)
                self:RebuildTree()
                self:RebuildTable()
            end,
        }

    end

    self.tierCells = self:MakeSegment(self.tierStrip, self.tierCells, specs)

end

-- All / Favoured / Common. Two lockouts means two figures per row, and the segment says which of
-- them the table is ABOUT -- Favoured hides the rows that only ever come out of the common table,
-- which is the difference between a list of what you can win this week and a list of everything.
function _G.LootBrowser:RebuildSourceSegment()

    local specs = {}

    for _, spec in ipairs({ { "all", "sourceAll" }, { "fav", "sourceFavoured" },
                            { "com", "sourceCommon" } }) do

        local source = spec[1]

        specs[#specs + 1] = {
            text     = _G.L(spec[2]),
            width    = SOURCE_W,
            selected = (self.source == source),
            onClick  = function()
                if self.source == source then return end
                self.source = source
                self:RebuildTable()
            end,
        }

    end

    self.sourceCells = self:MakeSegment(self.sourceStrip, self.sourceCells, specs)

end

-- The class strip: the client's own class art, at its native size.
--
-- NO RING AND NO PLATE. The icons are round and already framed, so anything drawn behind one
-- shows at its corners -- CharacterItem.lua draws them bare for the same reason and marks the
-- selection with a bar under it. That bar is the whole selected treatment, with the unselected
-- icons at 60%: tinting the art would recolour a portrait the player knows by sight.
function _G.LootBrowser:RebuildClassStrip()

    for _, cell in ipairs(self.classCells) do
        cell:SetParent(nil)
    end
    self.classCells = {}

    local x = CLASS_LABEL_W + GAP

    for _, entry in ipairs(_G.LootBrowser.Classes()) do

        local classId  = entry.id
        local selected = (self.selectedClass == classId)
        local yours    = (self.yourClass == classId)

        local cell = Turbine.UI.Control()
        cell:SetParent(self.classStrip)
        cell:SetPosition(x, 0)
        cell:SetSize(CLASS_CELL, CLASS_H)
        cell:SetMouseVisible(true)
        _G.LootTooltip.Attach(cell, yours and (entry.name .. " (" .. _G.L("yourClass") .. ")") or entry.name)

        local left = math.floor((CLASS_CELL - CLASS_ICON) / 2)

        local icon = Turbine.UI.Control()
        icon:SetParent(cell)
        icon:SetSize(CLASS_ICON, CLASS_ICON)
        icon:SetPosition(left, 2)
        icon:SetBackground(_G.ClassIcons[classId])
        icon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
        icon:SetOpacity(selected and 1.0 or 0.6)
        icon:SetMouseVisible(false)

        -- and the logged-in class keeps a mark of its own, one step quieter, so "yours" can still
        -- be found while you are reading somebody else's table
        local mark = Turbine.UI.Control()
        mark:SetParent(cell)
        mark:SetSize(CLASS_ICON, 2)
        mark:SetPosition(left, 2 + CLASS_ICON + 2)
        mark:SetBackColor(selected and _G.Theme.ACCENT
                          or (yours and _G.Theme.CHIP_FAV_FRAME or _G.Theme.BG))
        mark:SetMouseVisible(false)

        cell.MouseEnter = function()
            if not selected then icon:SetOpacity(0.85) end
        end
        cell.MouseLeave = function()
            if not selected then icon:SetOpacity(0.6) end
        end
        cell.MouseClick = function()
            if self.selectedClass == classId then return end
            self:SelectClass(classId)
        end

        x = x + CLASS_CELL
        self.classCells[#self.classCells + 1] = cell

    end

    self.classStrip:SetSize(x, CLASS_H)

end

-- The pick survives /logout, because comparing a chest against your alt is exactly what the strip
-- is for and re-picking it every session would be a chore.
function _G.LootBrowser:SelectClass(classId)

    self.selectedClass = classId

    _G.Settings.lootBrowser.class = classId
    _G.SaveSettings()

    -- the tree counts what one class can get, so it moves with the strip
    self:RebuildTree()
    self:RebuildTable()

end

-- ------------------------------------------------------------------------------------------------
-- table

-- A band over the rows under it: ALWAYS DROPS, then ROLLED. It is a row in the list like any
-- other, so the search can hide it with the items it named -- ApplyFilter already has that rule
-- for headings and _G.LootDrops.SearchFilter implements it.
function _G.LootBrowser:MakeSectionRow(text, count)

    local row = Turbine.UI.Control()
    row:SetHeight(SECTION_H)
    row:SetBackColor(_G.Theme.HEADER)
    row:SetMouseVisible(false)

    local rule = Turbine.UI.Control()
    rule:SetParent(row)
    rule:SetHeight(SEP_W)
    rule:SetPosition(0, 0)
    rule:SetBackColor(_G.Theme.FRAME)
    rule:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetMultiline(false)
    label:SetPosition(PAD, 0)
    label:SetHeight(SECTION_H)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM2)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetText(_G.Spaced(_G.Upper(text)))
    label:SetMouseVisible(false)

    local countLabel = Turbine.UI.Label()
    countLabel:SetParent(row)
    countLabel:SetMultiline(false)
    countLabel:SetHeight(SECTION_H)
    countLabel:SetFont(_G.Font(10))
    countLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    countLabel:SetForeColor(_G.Theme.DIM)
    countLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    countLabel:SetText(count .. " " .. _G.L(count == 1 and "itemsOne" or "items"))
    countLabel:SetMouseVisible(false)

    row.Layout = function()
        local width = row:GetWidth()
        rule:SetWidth(width)
        label:SetWidth(math.max(0, width - PAD * 2))
        countLabel:SetPosition(0, 0)
        countLabel:SetWidth(math.max(0, width - _G.Scaled(12)))
    end

    row.SizeChanged = row.Layout

    return row

end

-- Which lock the CHANCE column is showing. In the All view that is whichever the row leads with
-- (nil, and _G.LootDrops.Chance decides per row); with a lock picked it is that one, so the
-- column is comparable down the page.
function _G.LootBrowser:SourceKind()

    if self.source == "fav" then return "fav" end
    if self.source == "com" then return "com" end

    return nil

end

-- A row is drawn as loot YOU can get unless the export says it came from a table nobody was
-- filtered out of. An old-shape chest cannot say either way, so it is never dimmed -- silence is
-- not the same answer as "everybody gets this".
local function FromClassTable(drop)
    return drop.classRow == true or drop.rate ~= nil
end

-- One catalogued item. Not a LootRow: that one is built around a looter and a level, which a
-- database row has neither of. What they share is the icon and quality vocabulary.
--
-- ONE ROW PER ITEM, FOR ONE CLASS -- what _G.LootDrops.RowsFor hands over. The row leads with the
-- chance the item drops at all from this chest for the lock it belongs to, tags the tables it
-- came out of, and hangs the rolls behind that figure off the hover rather than printing them.
function _G.LootBrowser:MakeItemRow(eventIndex, drop, alt)

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetMouseVisible(true)

    local wished = _G.LootStats ~= nil and _G.LootStats.IsWished(drop.item)

    -- A group row is a HEADING over items, not an item, so it takes the header ground the
    -- table's own column strip uses and stays out of the striping. Only an old-shape chest still
    -- has them: a class-filtered export lists the members themselves.
    local function Ground()
        if wished then return _G.Theme.CHIP_FAV_BG end
        if drop.isGroup then return _G.Theme.HEADER end
        return alt and _G.Theme.ROW_ALT or _G.Theme.BG
    end
    row:SetBackColor(Ground())

    -- Which side of the stripe a row falls on depends on what is above it, and the search
    -- changes that without rebuilding anything. So the row can be restriped in place rather
    -- than thrown away and built again for a colour.
    row.SetAlt = function(value)
        alt = value
        row:SetBackColor(Ground())
    end

    -- quality bar; the icon sits beside it, so rarity stays readable at a glance. A group has
    -- no one quality either, so it gets the accent strip instead of a colour borrowed from
    -- whichever member happened to be listed first.
    local bar = Turbine.UI.Control()
    bar:SetParent(row)
    bar:SetSize(3, SLOT)
    bar:SetPosition(PAD, math.floor((ROW_H - SLOT) / 2))
    bar:SetBackColor(drop.isGroup and _G.Theme.STRIP or _G.LootQualityColor(drop.quality))
    bar:SetMouseVisible(false)

    -- The item's own art, in the client's own item slot, drawn from its catalogued id. Not a
    -- quickslot: that one paints the stack count from YOUR bags over a listing about the world.
    -- See UI/Window/LootRow.lua for what an ItemInfoControl does instead.
    local iconHost = Turbine.UI.Control()
    iconHost:SetParent(row)
    iconHost:SetSize(SLOT, SLOT)
    iconHost:SetPosition(PAD + 3 + math.floor(GAP / 2), math.floor((ROW_H - SLOT) / 2))
    -- The slot has a tooltip and so must take the mouse, which means the host cannot shadow it.
    -- A group's mark has nothing to say and stays out of the way entirely.
    iconHost:SetMouseVisible(not drop.isGroup)

    local icon = nil

    if drop.isGroup then

        -- A GROUP HAS NO ART, because it has no id: "Tracery" is the plugin's word for a set,
        -- and borrowing a member's icon would make the row look like the one item it is not.
        -- The fixed group mark instead (a plugin glyph, Overlay over the row's ground, see
        -- Ressources/ICONS.md).
        --
        -- CENTRED AT ITS OWN SIZE, not stretched to the slot: the .tga is 32px and the slot is 36,
        -- and Turbine clips art to its control rather than scaling it -- sized to SLOT it would
        -- lose its bottom-right corner instead of growing.
        local mark = Turbine.UI.Control()
        mark:SetParent(iconHost)
        mark:SetSize(MARK, MARK)
        mark:SetPosition(math.floor((SLOT - MARK) / 2), math.floor((SLOT - MARK) / 2))
        mark:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        mark:SetBackground("LootLogs/Ressources/group.tga")
        mark:SetMouseVisible(false)

    else
        icon = _G.MakeItemIcon(iconHost, drop.id, SLOT)
    end

    -- THE STACK RIDES ON THE SLOT. "x3" belongs to the picture of the thing, the way the client
    -- draws it in a bag, and not in a column of its own that would be empty on every other row.
    if (drop.qty or 1) > 1 then

        local stack = Turbine.UI.Label()
        stack:SetParent(iconHost)
        stack:SetMultiline(false)
        stack:SetSize(SLOT - 2, _G.Scaled(12))
        stack:SetPosition(0, SLOT - _G.Scaled(12))
        stack:SetFont(_G.Font(9))
        stack:SetFontStyle(_G.Theme.FONT_STYLE)
        stack:SetForeColor(_G.Theme.TEXT)
        stack:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
        stack:SetText("\195\151" .. drop.qty)                          -- multiplication sign
        stack:SetMouseVisible(false)

    end

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetMultiline(false)
    nameLabel:SetFont(_G.Font(12))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

    -- WHAT THE ITEM IS, under its name: "Warden - Hands - Blue" is what people call the thing,
    -- and the client's own name for it says none of that. Display only -- `item` stays the key,
    -- and RowText is what knows whether this row's label is a name or a description.
    local name, note = _G.LootDrops.RowText(drop)

    local noteLabel = nil

    if note ~= nil then

        nameLabel:SetHeight(math.floor(ROW_H / 2))

        noteLabel = Turbine.UI.Label()
        noteLabel:SetParent(row)
        noteLabel:SetMultiline(false)
        noteLabel:SetHeight(math.floor(ROW_H / 2))
        noteLabel:SetFont(_G.Font(10))
        noteLabel:SetFontStyle(_G.Theme.FONT_STYLE)
        noteLabel:SetForeColor(_G.Theme.DIM2)
        noteLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        noteLabel:SetMouseVisible(false)

    else
        nameLabel:SetHeight(ROW_H)
    end

    if drop.isGroup then

        -- NOT A LINK. A group name is the plugin's own word for a set -- editable in the drops
        -- data, and answering to no item id -- so linking it would examine whichever member the
        -- row borrowed, which is not what the name says. Plain text, in the accent the other
        -- headings use, and markup stays OFF: a "<" in a hand-written group name would be eaten
        -- as a tag.
        nameLabel:SetForeColor(_G.Theme.ACCENT)
        nameLabel:SetMouseVisible(false)

    else

        -- an item link: markup to draw it, the mouse to click it. See UI/Window/LootRow.lua.
        -- A row EVERY class gets recedes a step: it is still loot, but it is not what the player
        -- came to this class's table to read.
        nameLabel:SetForeColor(FromClassTable(drop) and _G.LootQualityColor(drop.quality)
                                                     or _G.Theme.DIM2)
        nameLabel:SetMarkupEnabled(true)
        nameLabel:SetMouseVisible(true)

    end

    -- WHICH TABLE IT CAME OUT OF. Two lockouts, so up to two chips: they are separate rolls
    -- against separate locks and an item in both is in both, which one blended figure could
    -- never say. The theme keeps one cool chip and one warm one, so the pair never reads as a
    -- pair of the same thing.
    local tags = {}

    for _, spec in ipairs({ { "fav", "tagFavoured", "CHIP_FAV_" }, { "com", "tagCommon", "CHIP_USED_" } }) do

        if drop[spec[1]] ~= nil then

            local chip = Turbine.UI.Control()
            chip:SetParent(row)
            chip:SetHeight(TAG_H)
            chip:SetBackColor(_G.Theme[spec[3] .. "FRAME"])
            chip:SetMouseVisible(false)

            local inner = Turbine.UI.Control()
            inner:SetParent(chip)
            inner:SetPosition(SEP_W, SEP_W)
            inner:SetBackColor(_G.Theme[spec[3] .. "BG"])
            inner:SetMouseVisible(false)

            local label = Turbine.UI.Label()
            label:SetParent(inner)
            label:SetMultiline(false)
            label:SetFont(_G.Font(9))
            label:SetFontStyle(_G.Theme.FONT_STYLE)
            label:SetForeColor(_G.Theme[spec[3] .. "TEXT"])
            label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
            label:SetText(_G.L(spec[2]))
            label:SetMouseVisible(false)

            chip.inner = inner
            chip.label = label
            tags[#tags + 1] = chip

        end

    end

    -- THE CHANCE, THE BAR AND THE ROLL COUNT ARE ONE HOVER TARGET, because they are one fact
    -- said three ways. What they are made of is the tooltip: every roll that can produce the
    -- item and the fold that turns them into this figure, built once from _G.LootDrops.RollLines
    -- so the popup cannot show a different derivation of the same number.
    local oddsHost = Turbine.UI.Control()
    oddsHost:SetParent(row)
    oddsHost:SetHeight(ROW_H)
    oddsHost:SetMouseVisible(true)

    local kind   = self:SourceKind()
    local chance = _G.LootDrops.Chance(drop, kind)
    local shown  = _G.LootDrops.FormatChance(chance)

    local odds = _G.LootDrops.OddsTooltip(drop, name)
    if odds ~= nil then _G.LootTooltip.Attach(oddsHost, odds) end

    local chanceLabel = Turbine.UI.Label()
    chanceLabel:SetParent(oddsHost)
    chanceLabel:SetMultiline(false)
    chanceLabel:SetFont(_G.Font(12))
    chanceLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    chanceLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    chanceLabel:SetMouseVisible(false)

    -- The OTHER lockout's figure, under the leading one and one step quieter. Only where there
    -- are two of them and only in the All view: with a lock picked, the column is that lock.
    local otherLabel = nil
    local other      = (kind == nil and drop.fav ~= nil and drop.com ~= nil)
                       and _G.LootDrops.Chance(drop, "com") or nil

    if shown ~= nil then
        chanceLabel:SetForeColor(chance >= ALWAYS and _G.Theme.CHIP_FAV_TEXT or _G.Theme.TEXT)
        chanceLabel:SetText(shown)
    else
        chanceLabel:SetForeColor(_G.Theme.DASH)
        chanceLabel:SetText("\226\128\148")                  -- em dash
    end

    if other ~= nil then

        chanceLabel:SetHeight(math.floor(ROW_H / 2) + _G.Scaled(4))

        otherLabel = Turbine.UI.Label()
        otherLabel:SetParent(oddsHost)
        otherLabel:SetMultiline(false)
        otherLabel:SetHeight(math.floor(ROW_H / 2))
        otherLabel:SetFont(_G.Font(10))
        otherLabel:SetFontStyle(_G.Theme.FONT_STYLE)
        otherLabel:SetForeColor(_G.Theme.DIM2)
        otherLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
        otherLabel:SetText(string.lower(_G.L("tagCommon")) .. " "
            .. (_G.LootDrops.FormatChance(other) or ""))
        otherLabel:SetMouseVisible(false)

    else
        chanceLabel:SetHeight(ROW_H)
    end

    -- The same number as a length, because a table of "0.76%" and "3.2%" is unsortable by eye
    -- however carefully it is written. TWO CONTROLS, BUILT ONCE: only their positions move in
    -- Layout, so a resize costs nothing.
    --
    -- Square root, not linear: at this width a linear scale puts everything under 5% in the
    -- first three pixels, which is most of the table. Rooted, 0.5% and 3% are still visibly
    -- different, and the eye reads the bar as "roughly how rare" rather than as a measurement.
    local barTrack, barFill = nil, nil

    if chance ~= nil then

        barTrack = Turbine.UI.Control()
        barTrack:SetParent(oddsHost)
        barTrack:SetSize(COL_BAR, BAR_H)
        barTrack:SetBackColor(_G.Theme.CHIP_USED_BG)
        barTrack:SetMouseVisible(false)

        barFill = Turbine.UI.Control()
        barFill:SetParent(oddsHost)
        barFill:SetSize(math.max(1, math.floor(math.sqrt(chance) * COL_BAR)), BAR_H)
        barFill:SetBackColor(chance >= 0.40 and _G.Theme.CHIP_USED_TEXT or _G.Theme.STRIP)
        barFill:SetMouseVisible(false)

    end

    -- HOW MANY WAYS THIS CHEST CAN GIVE IT, across both tables. The column the old row of bare
    -- percentages became: the rates themselves are the hover, and what is worth seeing at a
    -- glance is that an item has four chances at it rather than one.
    local rolls      = _G.LootDrops.RollCount(drop)
    local rollsLabel = Turbine.UI.Label()
    rollsLabel:SetParent(oddsHost)
    rollsLabel:SetMultiline(false)
    rollsLabel:SetHeight(ROW_H)
    rollsLabel:SetFont(_G.Font(10))
    rollsLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    rollsLabel:SetForeColor(_G.Theme.DIM2)
    rollsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    rollsLabel:SetText(rolls > 1 and ("\195\151" .. rolls) or "")
    rollsLabel:SetMouseVisible(false)

    -- Your own measured rate, with its sample size always beside it.
    local yoursLabel = Turbine.UI.Label()
    yoursLabel:SetParent(row)
    yoursLabel:SetMultiline(false)
    yoursLabel:SetHeight(ROW_H)
    yoursLabel:SetFont(_G.Font(12))
    yoursLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    yoursLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    yoursLabel:SetMouseVisible(false)

    local sampleLabel = Turbine.UI.Label()
    sampleLabel:SetParent(row)
    sampleLabel:SetMultiline(false)
    sampleLabel:SetHeight(ROW_H)
    sampleLabel:SetFont(_G.Font(10))
    sampleLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    sampleLabel:SetForeColor(_G.Theme.DIM)
    sampleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    sampleLabel:SetMouseVisible(false)

    -- Keyed on drop.item, which for a group row is the group's own name -- the same key the
    -- wishlist and the observed rate are stored under, so a collapsed "Tracery" reports how
    -- often a tracery dropped rather than how often one particular rolled name did.
    local count, opens = 0, 0
    if _G.LootStats ~= nil then
        count, opens = _G.LootStats.Observed(eventIndex, drop.item)
    end

    if opens > 0 then
        yoursLabel:SetForeColor(opens >= CONFIDENT_OPENS and _G.Theme.TEXT or _G.Theme.DIM)
        yoursLabel:SetText(math.floor(count / opens * 100 + 0.5) .. "%")
        sampleLabel:SetText("n" .. opens)
    else
        yoursLabel:SetForeColor(_G.Theme.DASH)
        yoursLabel:SetText("\226\128\148")
        sampleLabel:SetText("")
    end

    -- star, art rather than a glyph
    local star = Turbine.UI.Control()
    star:SetParent(row)
    star:SetSize(STAR, STAR)
    star:SetPosition(0, math.floor((ROW_H - STAR) / 2))
    star:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    star:SetBackground(wished and "LootLogs/Ressources/star_on.tga"
                              or  "LootLogs/Ressources/star_off.tga")
    star:SetMouseVisible(true)

    star.MouseClick = function()
        if _G.LootStats == nil then return end
        wished = _G.LootStats.ToggleWish(drop.item)
        star:SetBackground(wished and "LootLogs/Ressources/star_on.tga"
                                  or  "LootLogs/Ressources/star_off.tga")
        row:SetBackColor(Ground())
    end

    row.MouseEnter = function() row:SetBackColor(_G.Theme.FRAME) end
    row.MouseLeave = function() row:SetBackColor(Ground()) end

    -- An item's name label takes the mouse so its link can be clicked, and the odds host takes it
    -- so the derivation can be hovered -- which means the row stops seeing the pointer over both,
    -- and the row highlight would drop out exactly where you are looking. So they drive it too.
    nameLabel.MouseEnter = row.MouseEnter
    nameLabel.MouseLeave = row.MouseLeave

    -- And the icon, for the same reason: the item slot takes the mouse to carry its tooltip, so
    -- without this the row goes dark the moment the pointer reaches the art -- which is the first
    -- thing it crosses coming in from the left.
    iconHost.MouseEnter = row.MouseEnter
    iconHost.MouseLeave = row.MouseLeave

    if icon ~= nil then
        icon.MouseEnter = row.MouseEnter
        icon.MouseLeave = row.MouseLeave
    end

    -- oddsHost already carries Attach's own MouseEnter/MouseLeave (the rolls tooltip) when there
    -- is more than one roll behind the figure -- overwriting them the way nameLabel's are copied
    -- would silently drop the tooltip, so the row highlight is composed onto them instead.
    local tipEnter, tipLeave = oddsHost.MouseEnter, oddsHost.MouseLeave
    oddsHost.MouseEnter = function()
        row.MouseEnter()
        if tipEnter ~= nil then tipEnter() end
    end
    oddsHost.MouseLeave = function()
        row.MouseLeave()
        if tipLeave ~= nil then tipLeave() end
    end

    -- Named, because a rebuilt row cannot rely on SizeChanged alone: a fresh row whose width
    -- already matches the list never fires one, and then it draws with every column at zero.
    -- RebuildTable calls this directly once the row is in the list and sized.
    --
    -- The columns are placed FROM THE RIGHT, so the name -- the one thing whose length is not
    -- known -- takes whatever is left rather than pushing anything off the edge.
    row.Layout = function()

        local width   = row:GetWidth()
        local starX   = width - PAD - COL_STAR
        local yoursX  = starX - COL_YOURS
        local rollsX  = yoursX - GAP - COL_ROLLS
        local barX    = rollsX - GAP - COL_BAR
        local chanceX = barX - GAP - COL_CHANCE
        local tableX  = chanceX - COL_TABLE

        nameLabel:SetPosition(NAME_X, note ~= nil and _G.Scaled(2) or 0)
        nameLabel:SetWidth(math.max(0, tableX - NAME_X - GAP))

        local glyph = _G.GlyphWidth(12)

        if drop.isGroup then
            -- plain text, so the full width is the text's own -- no brackets to pay for
            nameLabel:SetText(_G.Truncate(name, nameLabel:GetWidth(), glyph))
        else
            -- truncate the visible name, then wrap it; the tag is markup and has no width, the
            -- brackets do
            nameLabel:SetText(_G.LootDrops.ItemLink(drop,
                _G.Truncate(name, nameLabel:GetWidth() - glyph * 2, glyph)))
        end

        if noteLabel ~= nil then
            noteLabel:SetPosition(NAME_X, math.floor(ROW_H / 2))
            noteLabel:SetWidth(nameLabel:GetWidth())
            -- Turbine cannot measure a label and will not clip one, so the sub-line is cut to
            -- the column here rather than left to run under the chips beside it
            noteLabel:SetText(_G.Truncate(note, noteLabel:GetWidth(), _G.GlyphWidth(10)))
        end

        local tagW = math.floor(3 * _G.GlyphWidth(9)) + _G.Scaled(10)
        local tagX = tableX

        for _, chip in ipairs(tags) do
            chip:SetPosition(tagX, math.floor((ROW_H - TAG_H) / 2))
            chip:SetWidth(tagW)
            chip.inner:SetSize(tagW - 2 * SEP_W, TAG_H - 2 * SEP_W)
            chip.label:SetSize(tagW - 2 * SEP_W, TAG_H - 2 * SEP_W)
            tagX = tagX + tagW + math.floor(GAP / 2)
        end

        oddsHost:SetPosition(chanceX, 0)
        oddsHost:SetSize(math.max(0, rollsX + COL_ROLLS - chanceX), ROW_H)

        chanceLabel:SetPosition(0, otherLabel ~= nil and _G.Scaled(2) or 0)
        chanceLabel:SetWidth(COL_CHANCE)

        if otherLabel ~= nil then
            otherLabel:SetPosition(0, math.floor(ROW_H / 2) + _G.Scaled(4))
            otherLabel:SetWidth(COL_CHANCE)
        end

        if barTrack ~= nil then
            local barY = math.floor((ROW_H - BAR_H) / 2)
            barTrack:SetPosition(barX - chanceX, barY)
            barFill:SetPosition(barX - chanceX, barY)
        end

        rollsLabel:SetPosition(rollsX - chanceX, 0)
        rollsLabel:SetWidth(COL_ROLLS)

        -- rate and sample share the column: the rate right-aligned against the sample, and
        -- the sample right-aligned against the star
        local sampleW = _G.Scaled(26)
        yoursLabel:SetPosition(yoursX, 0)
        yoursLabel:SetWidth(math.max(0, COL_YOURS - sampleW))
        sampleLabel:SetPosition(yoursX + COL_YOURS - sampleW, 0)
        sampleLabel:SetWidth(sampleW)

        star:SetPosition(starX + math.floor((COL_STAR - STAR) / 2),
            math.floor((ROW_H - STAR) / 2))

    end

    row.SizeChanged = row.Layout

    return row

end

-- Add a row and lay it out NOW.
--
-- A ListBox sizes its items, but only ever tells a row about it through SizeChanged -- and a
-- freshly built row whose width already matches the list never gets one. Nothing then positions
-- its columns, so it draws with everything stacked at zero. That is why switching tier or boss
-- left rows looking unsized: it depended on whether the new row happened to differ in width from
-- the default.
--
-- Setting the width explicitly and calling the layout makes it deterministic either way.
function _G.LootBrowser:AddRow(row)

    self.tableHost:AddItem(row)

    local width = self.tableHost:GetWidth()
    if width ~= nil and width > 0 then
        row:SetWidth(width)
    end

    if row.Layout ~= nil then
        row.Layout()
    end

    return row

end

-- Is this row in the table the lock segment is asking for?
--
-- A row from an old-shape chest belongs to no named lockout, so no lock filter may exclude it:
-- hiding it under Favoured would claim the export said something it never said.
function _G.LootBrowser:InSource(drop)

    if drop.fav == nil and drop.com == nil then return true end

    if self.source == "fav" then return drop.fav ~= nil end
    if self.source == "com" then return drop.com ~= nil end

    return true

end

-- the word for a class id, for the sub-line and the strip's tooltips
function _G.LootBrowser.ClassName(classId)

    for _, entry in ipairs(_G.LootBrowser.Classes()) do
        if entry.id == classId then return entry.name end
    end

    return nil

end

-- The rows of the SELECTED CHEST for the SELECTED CLASS, built once and kept in self.rows.
--
-- ONE CHEST, ONE CLASS. The tables are class-filtered, so a chest listed for everybody was mostly
-- rows the reader could never get -- 217 at Badharál T3 against 32 for a Warden. Both come out of
-- _G.LootDrops.RowsFor, which is also what every count on screen is measured from.
--
-- Building is the expensive half: every item row resolves its art through a shortcut lookup into
-- the client's own item table. None of that depends on the search text, so it happens when the
-- selection changes -- instance, tier, boss, class, the lock segment, the still-needed filter --
-- and not when a key is pressed. ApplyFilter then decides which of these rows the list shows.
--
-- Each entry carries what the search needs to judge it, lowered here rather than per keystroke.
-- The shape and the rule are _G.LootDrops.SearchFilter's, which is where the entry fields --
-- text, memberText and header -- are documented.
function _G.LootBrowser:BuildRows()

    self.rows   = {}
    self.counts = { items = 0, fav = 0, com = 0, classRows = 0 }

    self.bossName = self:SelectedBossName()

    local instance = self.selectedInstance and _G.Instances[self.selectedInstance]
    self.bossLabel:SetText(self.bossName or (instance and instance.name) or "")

    local eventIndex = self.selectedEvent
    if eventIndex == nil then return end

    -- AN OLD-SHAPE CHEST HAS NO CLASSES AND NO LOCKS, so it is offered neither picker: a control
    -- that cannot change what is on screen reads as a broken one. The strip's row keeps its
    -- height either way, so the table below does not jump as you move between chests.
    self.classed = _G.LootDrops.IsCatalogued(eventIndex)
    self.classStrip:SetVisible(self.classed)
    self.sourceStrip:SetVisible(self.classed)

    -- Which of this chest's rows survive the filters that change what EXISTS here. Neither is
    -- the search: the search decides what is SHOWN of what exists, and it must not rebuild.
    local visible = {}

    for _, drop in ipairs(_G.LootDrops.RowsFor(eventIndex, self.selectedClass)) do

        if self:InSource(drop) then

            visible[#visible + 1] = drop

            self.counts.items = self.counts.items + 1
            if drop.fav ~= nil        then self.counts.fav       = self.counts.fav + 1 end
            if drop.com ~= nil        then self.counts.com       = self.counts.com + 1 end
            if drop.classRow == true  then self.counts.classRows = self.counts.classRows + 1 end

        end

    end

    -- ALWAYS DROPS, THEN ROLLED. A guaranteed row and a 0.4% one are not two ends of one scale --
    -- one is a reward and the other is a hope -- and reading a page of percentages to find the
    -- four certainties in it is work the band does once.
    local always, rolled = {}, {}

    for _, drop in ipairs(visible) do
        local chance = _G.LootDrops.Chance(drop, self:SourceKind())
        if chance ~= nil and chance >= ALWAYS then
            always[#always + 1] = drop
        else
            rolled[#rolled + 1] = drop
        end
    end

    local function AddSection(key, list)

        if #list == 0 then return end

        self.rows[#self.rows + 1] = { kind = "header",
                                      row  = self:MakeSectionRow(_G.L(key), #list) }

        local header = #self.rows
        local alt    = false

        for _, drop in ipairs(list) do

            local entry = {
                kind    = "item",
                row     = self:MakeItemRow(eventIndex, drop, alt),
                drop    = drop,
                isGroup = drop.isGroup == true,
                header  = header,
                text    = _G.LootDrops.SearchText(drop),
            }

            self.rows[#self.rows + 1] = entry
            alt = not alt

            -- A COLLAPSED GROUP IS THE ONLY ROW STANDING IN FOR ITS MEMBERS, so a member's name
            -- has to find it: searching for a tracery you were promised must not come back empty
            -- because the row is called "Tracery". Only an old-shape chest still has them.
            if drop.memberNames ~= nil then
                local names = {}
                for _, name in ipairs(drop.memberNames) do
                    names[#names + 1] = string.lower(name)
                end
                entry.memberText = table.concat(names, "\0")
            end

        end

    end

    AddSection("sectionAlways", always)
    AddSection("sectionRolled", rolled)

end

-- Show the rows the search leaves standing. No control is built here -- the list is emptied and
-- refilled from rows that already exist, which is what makes typing cheap.
function _G.LootBrowser:ApplyFilter()

    if self.rows == nil then return self:RebuildTable() end

    local search = self.search
    local show   = _G.LootDrops.SearchFilter(self.rows, search)

    self.tableHost:ClearItems()

    local shown, starred = 0, 0
    local alt = false

    for index, entry in ipairs(self.rows) do
        if show[index] then
            if entry.kind == "header" then
                -- a band restarts the striping under it, so the first row of every section
                -- lands on the same side of it
                alt = false
            else
                -- restripe: which side of the stripe a row lands on depends on what the search
                -- left above it
                if entry.row.SetAlt ~= nil then entry.row.SetAlt(alt) end
                alt   = not alt
                shown = shown + 1
                if _G.LootStats ~= nil and _G.LootStats.IsWished(entry.drop.item) then
                    starred = starred + 1
                end
            end
            self:AddRow(entry.row)
        end
    end

    -- THE SUB-LINE IS THE CLASS AND ITS COUNTS. The heading above it is the boss and its tier,
    -- so what is left to say is whose table this is -- and every figure in it comes from the
    -- rows that were just built, never from a second count path that could disagree with them.
    local parts = {}

    if self.classed then
        parts[#parts + 1] = _G.LootBrowser.ClassName(self.selectedClass) or ""
    end

    if search == "" then

        parts[#parts + 1] = shown .. " " .. _G.L(shown == 1 and "itemsOne" or "items")

        if self.counts.fav > 0 or self.counts.com > 0 then
            parts[#parts + 1] = self.counts.fav .. " " .. _G.L("countFavoured")
            parts[#parts + 1] = self.counts.com .. " " .. _G.L("countCommon")
            parts[#parts + 1] = self.counts.classRows .. " " .. _G.L("countClassTable")
        end

    else
        parts[#parts + 1] = _G.L("searchItems")
        parts[#parts + 1] = shown .. " " .. _G.L(shown == 1 and "itemsOne" or "items")
    end

    self.countLabel:SetText(table.concat(parts, _G.Sep))

    self.footLabel:SetText(shown .. " " .. _G.L("items")
        .. _G.Sep .. starred .. " " .. _G.L("starred"))

    self:LayoutRows()

end

-- Build the selection, then show what matches. Every caller that changes WHAT IS IN the table
-- goes through here; the search goes straight to ApplyFilter.
function _G.LootBrowser:RebuildTable()

    self:RebuildTierSegment()
    self:RebuildSourceSegment()
    self:RebuildClassStrip()
    self:BuildRows()
    self:ApplyFilter()

    -- the boss name is only known once the rows are built, and the tier segment stands against it
    self:LayoutHeading()

end

-- ListBox does not size its children, so every row is set to the viewport width by hand.
function _G.LootBrowser:LayoutRows()

    local width = self.tableHost:GetWidth()

    for index = 1, self.tableHost:GetItemCount() do
        local row = self.tableHost:GetItem(index)
        if row ~= nil then row:SetWidth(width) end
    end

    local treeWidth = self.treeHost:GetWidth()
    for index = 1, self.treeHost:GetItemCount() do
        local row = self.treeHost:GetItem(index)
        if row ~= nil then row:SetWidth(treeWidth) end
    end

end

-- ------------------------------------------------------------------------------------------------

-- THE HEADING IS ONE FACT: this boss, at this tier. So the tier segment sits against the name
-- rather than out at the edge -- which means it moves when the name does, and the name changes
-- with the selection rather than with the window. Both callers go through here.
function _G.LootBrowser:LayoutHeading()

    if self.tableW == nil then return end

    local bossW = _G.Truncate(self.bossLabel:GetText() or "", self.tableW, _G.GlyphWidth(14))

    local nameW = math.min(math.max(0, self.tableW - _G.Scaled(300)),
                           math.floor(_G.Glyphs(bossW) * _G.GlyphWidth(14)) + _G.Scaled(4))

    self.bossLabel:SetPosition(self.tableLeft, PAD)
    self.bossLabel:SetSize(nameW, _G.Scaled(24))

    self.tierStrip:SetPosition(self.tableLeft + nameW + _G.Scaled(10),
        PAD + math.floor((_G.Scaled(24) - PILL_H) / 2))

end

function _G.LootBrowser:OnLayout(width, height)

    if self.treePane == nil then return end

    local bodyH = math.max(0, height - 2 * PAD)

    self.treePane:SetPosition(PAD, PAD)
    self.treePane:SetSize(TREE_W, bodyH)

    self.searchBg:SetPosition(PAD, PAD)
    self.searchBg:SetSize(math.max(0, TREE_W - 2 * PAD), SEARCH_H)
    self.searchIcon:SetPosition(4, math.floor((SEARCH_H - 16) / 2))
    self.searchBox:SetPosition(24, 1)
    self.searchBox:SetSize(math.max(0, TREE_W - 2 * PAD - 28), SEARCH_H - 2)
    self.searchHint:SetPosition(24, 0)
    self.searchHint:SetSize(math.max(0, TREE_W - 2 * PAD - 28), SEARCH_H)

    local treeTop = PAD + SEARCH_H + GAP
    local treeH   = math.max(0, bodyH - treeTop - PAD)

    self.treeHost:SetPosition(PAD, treeTop)
    self.treeHost:SetSize(math.max(0, TREE_W - 2 * PAD - 10), treeH)
    self.treeScroll:SetPosition(TREE_W - PAD - 10, treeTop)
    self.treeScroll:SetHeight(treeH)

    local tableLeft = PAD + TREE_W + GAP
    local tableW    = math.max(0, width - tableLeft - PAD)

    -- kept, because the heading is laid out again whenever the boss changes and not only when
    -- the window does -- the tier segment sits against a name whose length is the boss's
    self.tableLeft, self.tableW = tableLeft, tableW

    self:LayoutHeading()

    self.countLabel:SetPosition(tableLeft, PAD + _G.Scaled(24))
    self.countLabel:SetSize(math.max(0, tableW - _G.Scaled(240)), _G.Scaled(16))

    -- the lock segment hugs the right edge
    local sourceW  = 3 * (SOURCE_W + SEP_W) + SEP_W
    local sourceX  = math.max(tableLeft, tableLeft + tableW - sourceW)

    self.sourceStrip:SetPosition(sourceX, PAD)

    -- the class strip is its own line under the heading, because twelve portraits do not fit
    -- beside a boss name at any window width worth having
    self.classStrip:SetPosition(tableLeft, PAD + HEADER_H)
    self.classStrip:SetHeight(CLASS_H)
    self.classLabel:SetPosition(0, 0)
    self.classLabel:SetSize(CLASS_LABEL_W, CLASS_H)

    local headTop = PAD + HEADER_H + CLASS_H + _G.Scaled(6)
    self.tableHead:SetPosition(tableLeft, headTop)
    self.tableHead:SetSize(tableW, HEAD_H)

    -- The header is as wide as the table, but its COLUMNS are measured against the rows' width
    -- -- the list gives 10px to a scrollbar that is always there, and a header laid out over the
    -- full width would sit ten pixels right of every figure it names.
    local rowsW    = math.max(0, tableW - 10)

    local starX   = rowsW - PAD - COL_STAR
    local yoursX  = starX - COL_YOURS
    local rollsX  = yoursX - GAP - COL_ROLLS
    local barX    = rollsX - GAP - COL_BAR
    local chanceX = barX - GAP - COL_CHANCE
    local tableX  = chanceX - COL_TABLE

    -- the item column runs from the name to the table column, and the search button sits at
    -- its right edge -- so the header text stops short of it rather than running underneath
    local itemX  = NAME_X
    local itemW  = math.max(0, tableX - GAP - itemX)
    local findY  = math.floor((HEAD_H - FIND) / 2)

    self.headLabels[1]:SetPosition(itemX, 0)
    self.headLabels[1]:SetWidth(math.max(0, itemW - FIND - GAP))

    self.headSearchBtn:SetPosition(itemX + math.max(0, itemW - FIND), findY)

    self.headSearchBg:SetPosition(itemX, 0)
    self.headSearchBg:SetSize(itemW, HEAD_H)
    self.headSearchIcon:SetPosition(2, math.floor((HEAD_H - ICON) / 2))
    self.headSearchBox:SetPosition(ICON + 6, 1)
    self.headSearchBox:SetSize(math.max(0, itemW - ICON - 6 - FIND - 2), HEAD_H - 2)
    self.headSearchHint:SetPosition(ICON + 6, 0)
    self.headSearchHint:SetSize(math.max(0, itemW - ICON - 6 - FIND - 2), HEAD_H)
    self.headSearchClear:SetPosition(math.max(0, itemW - FIND), findY)

    self.headLabels[2]:SetPosition(tableX, 0)
    self.headLabels[2]:SetWidth(math.max(0, COL_TABLE - GAP))
    self.headLabels[3]:SetPosition(chanceX, 0)
    self.headLabels[3]:SetWidth(COL_CHANCE)
    -- the bar between CHANCE and ROLLS is unlabelled on purpose: it is the same number as
    -- CHANCE, drawn as a length
    self.headLabels[4]:SetPosition(rollsX, 0)
    self.headLabels[4]:SetWidth(COL_ROLLS)
    -- YOURS names the rate AND its sample, so its label spans both
    self.headLabels[5]:SetPosition(yoursX, 0)
    self.headLabels[5]:SetWidth(COL_YOURS)

    local tableTop = headTop + HEAD_H + SEP_W
    local footTop  = height - PAD - HEAD_H
    local tableH   = math.max(0, footTop - GAP - tableTop)

    self.tableHost:SetPosition(tableLeft, tableTop)
    self.tableHost:SetSize(math.max(0, tableW - 10), tableH)
    self.tableScroll:SetPosition(tableLeft + tableW - 10, tableTop)
    self.tableScroll:SetHeight(tableH)

    self.footLabel:SetPosition(tableLeft, footTop)
    self.footLabel:SetSize(math.floor(tableW / 2), HEAD_H)

    local hintW = tableW - math.floor(tableW / 2)

    self.hintLabel:SetPosition(tableLeft + math.floor(tableW / 2), footTop)
    self.hintLabel:SetSize(hintW, HEAD_H)

    -- TWO HINTS, AS MANY AS FIT. The hover is the one that stays: a derivation nobody knows is
    -- there is a derivation nobody reads, and the column heading cannot say it. The greyed-rates
    -- note joins it when the window is wide enough. Turbine will not clip a label, so the choice
    -- is made here rather than left to overflow across the item count beside it.
    local oddsHint = _G.L("browserOddsHint")
    local bothHint = _G.L("browserRateHint") .. _G.Sep .. oddsHint

    self.hintLabel:SetText(
        (_G.Glyphs(bothHint) * _G.GlyphWidth(10) <= hintW) and bothHint or oddsHint)

    self:LayoutRows()

end

function _G.LootBrowser:Toggle()

    self:SetVisible(not self:IsVisible())

    if self:IsVisible() then
        self:RebuildTree()
        self:RebuildTable()
        self:Activate()
    end

end

function _G.LootBrowser:OnMoved()

    local left, top = self:GetPosition()

    _G.Settings.lootBrowser.left = left
    _G.Settings.lootBrowser.top  = top
    _G.SaveSettings()

end

function _G.LootBrowser:OnResized()

    local width, height = self:GetSize()

    _G.Settings.lootBrowser.width  = width
    _G.Settings.lootBrowser.height = height
    _G.SaveSettings()

end

function _G.LootBrowser:PositionChanged()

    if not self._dragging then
        self:OnMoved()
    end

end
