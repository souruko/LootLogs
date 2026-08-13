-- Loot browser: a SEPARATE window listing the drops database.
--
-- Left pane is a content pack -> instance -> boss tree built from _G.Content, _G.Instances and
-- _G.Events, filtered to instances that actually have _G.Drops rows. Right pane is the item
-- table for the selection, at the selected tier.
--
-- The tier pills are derived from the distinct tier values of the selected instance's events,
-- ordered by _G.TierOrder -- so they are always right per instance, including the ones that
-- carry Solo on top of T1-T5, with no list maintained here.
--
-- SEARCHING NARROWS THE SELECTION, it does not leave it. Either search box filters the chest and
-- tier already on screen, and it does it without building anything: BuildRows() makes the rows
-- of the selection once, ApplyFilter() decides which of them the list shows.

import "LootLogs.UI.Window.PanelWindow"
import "LootLogs.UI.Window.LootRow"

local PAD, GAP, SEP_W, ROW_H, TREE_ROW_H, HEAD_H, TREE_W, PILL_H, PILL_GAP, SEARCH_H
local STAR, INDENT, SLOT, NAME_X, ICON, FIND
local COL_ENTRIES, COL_ANY, COL_BAR, BAR_H, COL_YOURS, COL_STAR
local MIN_WIDTH, MIN_HEIGHT

local function Metrics()
    SEP_W      = 1
    PAD        = _G.Scaled(8)
    GAP        = _G.Scaled(8)
    SLOT       = _G.LootSlotSize
    -- item rows seat a 32px quickslot, which cannot be scaled; tree nodes carry only text and
    -- stay at the compact height, so the left pane does not turn into a ladder
    ROW_H      = _G.LootRowHeight()
    TREE_ROW_H = _G.Scaled(24)
    NAME_X     = PAD + 3 + math.floor(GAP / 2) + SLOT + GAP
    HEAD_H     = _G.Scaled(20)
    PILL_H     = _G.Scaled(20)
    PILL_GAP   = _G.Scaled(4)
    SEARCH_H   = _G.Scaled(24)
    TREE_W     = _G.Scaled(212)
    INDENT     = _G.Scaled(12)
    STAR       = 12
    -- the .tga is clipped to its control rather than scaled, so the glyph stays 16px at every
    -- font size and only the button around it has room to spare (Ressources/ICONS.md)
    ICON       = 16
    FIND       = 18
    -- The per-entry rates behind the lead figure. THE SLOT COLUMN'S WIDTH PAYS FOR IT: `slot`
    -- is nil on every generated row, so that column was always empty, and a six-pool item
    -- needs the room to print what it is made of.
    COL_ENTRIES = _G.Scaled(140)
    COL_ANY     = _G.Scaled(56)
    -- Art, not text, so both stay put at every font size -- the same rule as the 32px item
    -- icon and the 12px star.
    COL_BAR     = 60
    BAR_H       = 4
    COL_YOURS  = _G.Scaled(78)
    COL_STAR   = _G.Scaled(24)
    MIN_WIDTH  = _G.Scaled(840)
    MIN_HEIGHT = _G.Scaled(430)
end

_G.RegisterMetrics(Metrics)

-- Below this many opens a measured rate is noise, so it is shown in DIM. The sample size is
-- printed either way -- a 1-of-1 drop reading "100%" beside a database value of 12% destroys
-- trust in the whole window.
local CONFIDENT_OPENS = 10

_G.LootBrowser = class(_G.PanelWindow)

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
    self.pills            = {}
    self.neededOnly       = false

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
    self.pillStrip = Turbine.UI.Control()
    self.pillStrip:SetParent(self.client)
    self.pillStrip:SetMouseVisible(false)

    self.instanceLabel = Turbine.UI.Label()
    self.instanceLabel:SetParent(self.client)
    self.instanceLabel:SetMultiline(false)
    self.instanceLabel:SetFont(_G.Font(14))
    self.instanceLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.instanceLabel:SetForeColor(_G.Theme.TEXT)
    self.instanceLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.instanceLabel:SetMouseVisible(false)

    self.countLabel = Turbine.UI.Label()
    self.countLabel:SetParent(self.client)
    self.countLabel:SetMultiline(false)
    self.countLabel:SetFont(_G.Font(10))
    self.countLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.countLabel:SetForeColor(_G.Theme.DIM)
    self.countLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.countLabel:SetMouseVisible(false)

    -- "still needed" filter. Its own control rather than a tier pill, because it is not a tier
    -- and putting it in the strip would make it look like one.
    self.neededPill = Turbine.UI.Control()
    self.neededPill:SetParent(self.client)
    self.neededPill:SetHeight(PILL_H)
    self.neededPill:SetMouseVisible(true)

    self.neededInner = Turbine.UI.Control()
    self.neededInner:SetParent(self.neededPill)
    self.neededInner:SetPosition(1, 1)
    self.neededInner:SetMouseVisible(false)

    self.neededLabel = Turbine.UI.Label()
    self.neededLabel:SetParent(self.neededInner)
    self.neededLabel:SetMultiline(false)
    self.neededLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.neededLabel:SetFont(_G.Font(10))
    self.neededLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.neededLabel:SetText(_G.L("stillNeeded"))
    self.neededLabel:SetMouseVisible(false)

    self.neededPill.MouseEnter = function()
        if not self.neededOnly then self.neededPill:SetBackColor(_G.Theme.HOVER) end
    end
    self.neededPill.MouseLeave = function()
        if not self.neededOnly then self.neededPill:SetBackColor(_G.Theme.FRAME) end
    end
    self.neededPill.MouseClick = function()
        self.neededOnly = not self.neededOnly
        self:RefreshNeededPill()
        self:RebuildTable()
    end

    self:RefreshNeededPill()

    self.tableHead = Turbine.UI.Control()
    self.tableHead:SetParent(self.client)
    self.tableHead:SetBackColor(_G.Theme.HEADER)
    self.tableHead:SetMouseVisible(false)

    self.headLabels = {}
    for _, spec in ipairs({ { "colItem",    Turbine.UI.ContentAlignment.MiddleLeft },
                            { "colEntries", Turbine.UI.ContentAlignment.MiddleRight },
                            { "colAny",     Turbine.UI.ContentAlignment.MiddleRight },
                            { "colYours",   Turbine.UI.ContentAlignment.MiddleRight } }) do
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

        -- How many catalogued ITEMS this instance holds, across every tier. Not rows: the
        -- tables list an item once per pool it sits in, so counting rows told the sidebar 308
        -- where the table beside it shows 91 -- and the number that disagrees with what you can
        -- see is the one that gets believed.
        local total = 0
        for eventIndex in pairs(_G.Drops or {}) do
            local event = _G.Events[eventIndex]
            if event ~= nil and event.instance == entry.id then
                total = total + _G.LootDrops.ItemCount(eventIndex)
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
                local bossCount  = _G.LootDrops.ItemCount(eventIndex)
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
-- tier pills

function _G.LootBrowser:RebuildPills()

    for _, pill in ipairs(self.pills) do
        pill:SetParent(nil)
    end
    self.pills = {}

    if self.selectedInstance == nil then return end

    local x = 0

    for _, tier in ipairs(self:TiersFor(self.selectedInstance)) do

        local selected = (tostring(self.selectedTier) == tier)
        local width    = math.max(_G.Scaled(34),
                                  math.floor(#tier * _G.GlyphWidth(10)) + _G.Scaled(16))

        local pill = Turbine.UI.Control()
        pill:SetParent(self.pillStrip)
        pill:SetSize(width, PILL_H)
        pill:SetBackColor(selected and _G.Theme.CHIP_FAV_FRAME or _G.Theme.FRAME)
        pill:SetMouseVisible(true)

        local inner = Turbine.UI.Control()
        inner:SetParent(pill)
        inner:SetPosition(1, 1)
        inner:SetSize(width - 2, PILL_H - 2)
        inner:SetBackColor(selected and _G.Theme.CHIP_FAV_BG or _G.Theme.BG)
        inner:SetMouseVisible(false)

        local label = Turbine.UI.Label()
        label:SetParent(inner)
        label:SetMultiline(false)
        label:SetSize(width - 2, PILL_H - 2)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(_G.Font(10))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(selected and _G.Theme.CHIP_FAV_TEXT or _G.Theme.TEXT)
        label:SetText(tier)
        label:SetMouseVisible(false)

        pill.MouseEnter = function()
            if not selected then pill:SetBackColor(_G.Theme.HOVER) end
        end
        pill.MouseLeave = function()
            if not selected then pill:SetBackColor(_G.Theme.FRAME) end
        end
        pill.MouseClick = function()
            -- The selection belongs to the old tier -- a chest is one (boss, tier) pair -- so it
            -- is re-resolved rather than kept: the SAME BOSS at the new tier, which is the
            -- question the pills exist to answer, or its first chest if this tier has no such
            -- boss.
            local boss = self:SelectedBossName()
            self.selectedTier  = tier
            self.selectedEvent = self:BossAt(self.selectedInstance, tier, boss)
            self:RebuildTree()
            self:RebuildTable()
        end

        pill:SetPosition(x, 0)
        x = x + width + PILL_GAP

        self.pills[#self.pills + 1] = pill

    end

end

-- ------------------------------------------------------------------------------------------------
-- table

-- One catalogued item. Not a LootRow: that one is built around a looter and a level, which a
-- database row has neither of. What they share is the icon and quality vocabulary.
--
-- ONE ROW PER ITEM, which is how the drops data is written: `chance` -- the chance it drops at
-- all -- as the lead figure, and `chances`, the individual pool rates behind it, printed after.
function _G.LootBrowser:MakeItemRow(eventIndex, drop, alt)

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetMouseVisible(true)

    local wished = _G.LootStats ~= nil and _G.LootStats.IsWished(drop.item)

    -- A CATEGORY ROW names a kind of reward rather than an item -- "Tracery", which the client
    -- rolls a name for -- so it takes the header ground the table's own column strip uses and
    -- stays out of the striping. That band, the fixed mark where the art goes and the accent
    -- name are three signals saying the same thing: this is not an item you can look up.
    local function Ground()
        if wished then return _G.Theme.CHIP_FAV_BG end
        if drop.category then return _G.Theme.HEADER end
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

    -- quality bar; the icon sits beside it, so rarity stays readable at a glance. A category
    -- names no one item and so has no one quality: it gets the accent strip instead of a colour
    -- that would be a guess.
    local bar = Turbine.UI.Control()
    bar:SetParent(row)
    bar:SetSize(3, SLOT)
    bar:SetPosition(PAD, math.floor((ROW_H - SLOT) / 2))
    bar:SetBackColor(drop.category and _G.Theme.STRIP or _G.LootQualityColor(drop.quality))
    bar:SetMouseVisible(false)

    -- The item's own art, composed from its catalogued id. Images rather than a quickslot, so
    -- no stack count from your bags is painted over a listing about the world -- the tooltip
    -- that used to justify the slot now comes from the name link. See UI/Window/LootRow.lua.
    local iconHost = Turbine.UI.Control()
    iconHost:SetParent(row)
    iconHost:SetSize(SLOT, SLOT)
    iconHost:SetPosition(PAD + 3 + math.floor(GAP / 2), math.floor((ROW_H - SLOT) / 2))
    iconHost:SetMouseVisible(false)

    if drop.category then

        -- A CATEGORY HAS NO ART, because it has no id: "Tracery" is what the tables call the
        -- reward, and the client rolls the actual name. The fixed category mark instead (a
        -- plugin glyph, Overlay over the row's ground, see Ressources/ICONS.md).
        local mark = Turbine.UI.Control()
        mark:SetParent(iconHost)
        mark:SetSize(SLOT, SLOT)
        mark:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        mark:SetBackground("LootLogs/Ressources/group.tga")
        mark:SetMouseVisible(false)

    else
        _G.MakeItemIcon(iconHost, drop.id, SLOT)
    end

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetMultiline(false)
    nameLabel:SetHeight(ROW_H)
    nameLabel:SetFont(_G.Font(12))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

    if drop.category then

        -- NOT A LINK. A category answers to no item id, so there is nothing for the client to
        -- examine and a link would be a dead one. Plain text, in the accent the other headings
        -- use, and markup stays OFF: a "<" in the name would be eaten as a tag.
        nameLabel:SetForeColor(_G.Theme.ACCENT)
        nameLabel:SetMouseVisible(false)

    else

        -- an item link: markup to draw it, the mouse to click it. See UI/Window/LootRow.lua.
        nameLabel:SetForeColor(_G.LootQualityColor(drop.quality))
        nameLabel:SetMarkupEnabled(true)
        nameLabel:SetMouseVisible(true)

    end

    -- The drops data's `label`, drawn UNDER the name as a small description -- "Runekeeper
    -- shoulders red" beneath the game's own words for the same shoulders. The popup's row does
    -- exactly this (UI/Window/LootRow.lua) and the two windows have to agree, or the same item
    -- reads as two different things depending on which one you opened.
    --
    -- nil on most rows and on every category row, so the label is built only where there is
    -- something to put in it and the name keeps the whole row height otherwise.
    local note      = _G.LootDrops.DisplayNote(drop)
    local noteLabel = nil

    if note ~= nil then
        noteLabel = Turbine.UI.Label()
        noteLabel:SetParent(row)
        noteLabel:SetMultiline(false)
        noteLabel:SetFont(_G.Font(10))
        noteLabel:SetFontStyle(_G.Theme.FONT_STYLE)
        noteLabel:SetForeColor(_G.Theme.DIM2)
        noteLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        -- mouse-invisible, so the row's own highlight survives the pointer crossing it
        noteLabel:SetMouseVisible(false)
    end

    -- WHAT THE LEAD FIGURE IS MADE OF. An item in six of a chest's pools has six rates, and
    -- they are six separate chances rather than one repeated -- so they are printed, biggest
    -- first, one step dimmer and one size down. A single entry prints nothing: the lead figure
    -- already is that number, and saying it twice on one line says nothing.
    local entriesLabel = Turbine.UI.Label()
    entriesLabel:SetParent(row)
    entriesLabel:SetMultiline(false)
    entriesLabel:SetHeight(ROW_H)
    entriesLabel:SetFont(_G.Font(10))
    entriesLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    entriesLabel:SetForeColor(_G.Theme.DIM)
    entriesLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    entriesLabel:SetMouseVisible(false)

    local series = _G.LootDrops.EntrySeries(drop.chances)

    -- THE CHANCE IT DROPS AT ALL, which is the question the column exists to answer: an item in
    -- six pools is likelier than an item in one, and this is the only figure that can be
    -- compared between them. An absent chance means "drops, rate not established" and must read
    -- as unknown -- never as 0%, which would claim knowledge the tables do not have.
    local anyLabel = Turbine.UI.Label()
    anyLabel:SetParent(row)
    anyLabel:SetMultiline(false)
    anyLabel:SetHeight(ROW_H)
    anyLabel:SetFont(_G.Font(12))
    anyLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    anyLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    anyLabel:SetMouseVisible(false)

    local shown = _G.LootDrops.FormatChance(drop.chance)

    if shown ~= nil then
        anyLabel:SetForeColor(_G.Theme.TEXT)
        anyLabel:SetText(shown)
    else
        anyLabel:SetForeColor(_G.Theme.DASH)
        anyLabel:SetText("\226\128\148")                    -- em dash
    end

    -- The same number as a length, because a table of "0.76%" and "3.2%" is unsortable by eye
    -- however carefully it is written. TWO CONTROLS, BUILT ONCE: only their positions move in
    -- Layout, so a resize costs nothing.
    --
    -- Square root, not linear: at this width a linear scale puts everything under 5% in the
    -- first three pixels, which is most of the table. Rooted, 0.5% and 3% are still visibly
    -- different, and the eye reads the bar as "roughly how rare" rather than as a measurement.
    local barTrack, barFill = nil, nil

    if drop.chance ~= nil then

        barTrack = Turbine.UI.Control()
        barTrack:SetParent(row)
        barTrack:SetSize(COL_BAR, BAR_H)
        barTrack:SetBackColor(_G.Theme.CHIP_USED_BG)
        barTrack:SetMouseVisible(false)

        barFill = Turbine.UI.Control()
        barFill:SetParent(row)
        barFill:SetSize(math.max(1, math.floor(math.sqrt(drop.chance) * COL_BAR)), BAR_H)
        barFill:SetBackColor(drop.chance >= 0.40 and _G.Theme.CHIP_USED_TEXT or _G.Theme.STRIP)
        barFill:SetMouseVisible(false)

    end

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

    -- Keyed on drop.item -- the same key the wishlist and the observed rate are stored under,
    -- and the same key the drops data is written under, so all three are asking about one thing.
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

    -- An item's name label takes the mouse so its link can be clicked, which means the row stops
    -- seeing the pointer the moment it crosses the name -- and the row highlight would drop out
    -- exactly where you are looking. So the label drives the same highlight. A category's name
    -- is mouse-invisible and never intercepts it in the first place.
    nameLabel.MouseEnter = row.MouseEnter
    nameLabel.MouseLeave = row.MouseLeave

    -- Named, because a rebuilt row cannot rely on SizeChanged alone: a fresh row whose width
    -- already matches the list never fires one, and then it draws with every column at zero.
    -- RebuildTable calls this directly once the row is in the list and sized.
    --
    -- The columns are placed FROM THE RIGHT, so the name -- the one thing whose length is not
    -- known -- takes whatever is left rather than pushing anything off the edge.
    row.Layout = function()

        local width    = row:GetWidth()
        local starX    = width - PAD - COL_STAR
        local yoursX   = starX - COL_YOURS
        local barX     = yoursX - GAP - COL_BAR
        local anyX     = barX - GAP - COL_ANY
        local entriesX = anyX - COL_ENTRIES

        -- The name gives up the top 55% of the row where there is a description under it, and
        -- keeps the whole height where there is not -- the same split as the popup's row, and
        -- by proportion for the same reason: the height tracks the Font Size setting.
        local nameH = note ~= nil and math.floor(ROW_H * 0.55) or ROW_H

        nameLabel:SetPosition(NAME_X, 0)
        nameLabel:SetHeight(nameH)
        nameLabel:SetWidth(math.max(0, entriesX - NAME_X - GAP))

        local glyph = _G.GlyphWidth(12)
        local name  = _G.LootDrops.DisplayName(drop, drop.item)

        if noteLabel ~= nil then
            noteLabel:SetPosition(NAME_X, nameH)
            noteLabel:SetHeight(math.max(0, ROW_H - nameH))
            noteLabel:SetWidth(nameLabel:GetWidth())
            -- plain text, so the column's full width is the description's
            noteLabel:SetText(_G.Truncate(note, noteLabel:GetWidth(), _G.GlyphWidth(10)))
        end

        if drop.category then
            -- plain text, so the full width is the text's own -- no brackets to pay for
            nameLabel:SetText(_G.Truncate(name, nameLabel:GetWidth(), glyph))
        else
            -- truncate the visible name, then wrap it; the tag is markup and has no width, the
            -- brackets do
            nameLabel:SetText(_G.LootDrops.ItemLink(drop,
                _G.Truncate(name, nameLabel:GetWidth() - glyph * 2, glyph)))
        end

        -- Turbine cannot measure a label and will not clip one, so the series is cut to the
        -- column here rather than left to run under the figure beside it.
        entriesLabel:SetPosition(entriesX, 0)
        entriesLabel:SetWidth(math.max(0, COL_ENTRIES - GAP))
        entriesLabel:SetText(series and
            _G.Truncate(series, COL_ENTRIES - GAP, _G.GlyphWidth(10)) or "")

        anyLabel:SetPosition(anyX, 0)
        anyLabel:SetWidth(COL_ANY)

        if barTrack ~= nil then
            local barY = math.floor((ROW_H - BAR_H) / 2)
            barTrack:SetPosition(barX, barY)
            barFill:SetPosition(barX, barY)
        end

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

function _G.LootBrowser:RefreshNeededPill()

    self.neededPill:SetBackColor(self.neededOnly and _G.Theme.CHIP_FAV_FRAME or _G.Theme.FRAME)
    self.neededInner:SetBackColor(self.neededOnly and _G.Theme.CHIP_FAV_BG or _G.Theme.BG)
    self.neededLabel:SetForeColor(self.neededOnly and _G.Theme.CHIP_FAV_TEXT or _G.Theme.TEXT)

end

-- Hidden when the filter is on and this character already has one. Deliberately per-character:
-- the wishlist is shared across your alts, but what you have already collected is not.
function _G.LootBrowser:Filtered(drop)

    if not self.neededOnly then return false end
    if _G.LootStats == nil then return false end

    return _G.LootStats.Acquired(drop.item) ~= nil

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

-- The rows of the SELECTED CHEST, built once and kept in self.rows.
--
-- ONE CHEST, ALWAYS. The whole-instance view is gone: three chests of one instance share most of
-- their pools, so listing them together was the same rows over again under a heading, and it
-- made every figure on the page ambiguous until you had found which boss you were under. The
-- tree selects the chest; the table shows it.
--
-- Building is the expensive half: every item row resolves its art through a shortcut lookup into
-- the client's own item table. None of that depends on the search text, so it happens when the
-- selection changes -- instance, tier, boss, the still-needed filter -- and not when a key is
-- pressed. ApplyFilter then decides which of these rows the list shows.
--
-- Each entry carries what the search needs to judge it, lowered here rather than per keystroke.
-- The shape and the rule are _G.LootDrops.SearchFilter's, which is where the entry fields --
-- text and memberText -- are documented.
function _G.LootBrowser:BuildRows()

    self.rows = {}

    local instance = self.selectedInstance and _G.Instances[self.selectedInstance]
    self.instanceLabel:SetText(instance and instance.name or "")

    -- what the sub-line names, and how many table rows the items on screen were folded from --
    -- which is the sub-line's way of saying what the ENTRIES column is showing
    self.bossName   = self:SelectedBossName()
    self.entryCount = 0

    local eventIndex = self.selectedEvent
    if eventIndex == nil then return end

    -- ONE ROW PER ITEM, LIKELIEST FIRST, and both of those are properties of the data rather
    -- than of this window: the drops file is written that way, so the chest is walked in order
    -- and nothing is folded or sorted here. See Logs/Drops/English.lua.
    --
    -- The still-needed filter is not the search: it changes what EXISTS in the table, so it
    -- belongs in the build rather than in ApplyFilter.
    local alt = false

    for _, drop in ipairs(_G.Drops[eventIndex] or {}) do

        if not self:Filtered(drop) then

            self.rows[#self.rows + 1] = {
                kind = "item",
                row  = self:MakeItemRow(eventIndex, drop, alt),
                drop = drop,
                text = _G.LootDrops.SearchText(drop),
            }

            alt = not alt

            -- how many of the game's own table entries this one row stands for
            self.entryCount = self.entryCount + _G.LootDrops.EntrySpan(drop)

        end

    end

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
            -- restripe: which side of the stripe a row lands on depends on what the search left
            -- above it
            if entry.row.SetAlt ~= nil then entry.row.SetAlt(alt) end
            alt = not alt
            self:AddRow(entry.row)
            shown = shown + 1
            if _G.LootStats ~= nil and _G.LootStats.IsWished(entry.drop.item) then
                starred = starred + 1
            end
        end
    end

    -- THE SUB-LINE NAMES THE CHEST. The heading above it is the instance, which stays put while
    -- you move between its bosses, so the boss belongs here -- and with one chest on screen
    -- there is no group header left to carry the name instead.
    local boss = self.bossName and (self.bossName .. _G.Sep) or ""

    if search == "" then
        -- items first, entries behind: the table has one row per item now, and the entry count
        -- is the answer to "then what is the ENTRIES column counting"
        self.countLabel:SetText(boss .. shown .. " " .. _G.L("catalogued")
            .. _G.Sep .. (self.entryCount or 0) .. " " .. _G.L("entries"))
    else
        self.countLabel:SetText(boss .. _G.L("searchItems")
            .. _G.Sep .. shown .. " " .. _G.L("items"))
    end

    self.footLabel:SetText(shown .. " " .. _G.L("items")
        .. _G.Sep .. starred .. " " .. _G.L("starred"))

    self:LayoutRows()

end

-- Build the selection, then show what matches. Every caller that changes WHAT IS IN the table
-- goes through here; the search goes straight to ApplyFilter.
function _G.LootBrowser:RebuildTable()

    self:RebuildPills()
    self:BuildRows()
    self:ApplyFilter()

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

    self.instanceLabel:SetPosition(tableLeft, PAD)
    self.instanceLabel:SetSize(math.max(0, tableW - _G.Scaled(240)), _G.Scaled(22))

    self.countLabel:SetPosition(tableLeft, PAD + _G.Scaled(22))
    self.countLabel:SetSize(math.max(0, tableW - _G.Scaled(240)), _G.Scaled(16))

    -- tier pills hug the right edge; the "still needed" toggle sits to their left, far enough
    -- from them that it does not read as another tier
    local pillsW   = _G.Scaled(232)
    local neededW  = _G.Scaled(96)
    local pillsX   = math.max(tableLeft, tableLeft + tableW - pillsW)

    self.pillStrip:SetPosition(pillsX, PAD)
    self.pillStrip:SetSize(pillsW, PILL_H)

    self.neededPill:SetPosition(math.max(tableLeft, pillsX - GAP - neededW), PAD)
    self.neededPill:SetSize(neededW, PILL_H)
    self.neededInner:SetSize(neededW - 2, PILL_H - 2)
    self.neededLabel:SetSize(neededW - 2, PILL_H - 2)

    local headTop = PAD + _G.Scaled(44)
    self.tableHead:SetPosition(tableLeft, headTop)
    self.tableHead:SetSize(tableW, HEAD_H)

    -- The header is as wide as the table, but its COLUMNS are measured against the rows' width
    -- -- the list gives 10px to a scrollbar that is always there, and a header laid out over the
    -- full width would sit ten pixels right of every figure it names.
    local rowsW    = math.max(0, tableW - 10)

    local starX    = rowsW - PAD - COL_STAR
    local yoursX   = starX - COL_YOURS
    local barX     = yoursX - GAP - COL_BAR
    local anyX     = barX - GAP - COL_ANY
    local entriesX = anyX - COL_ENTRIES

    -- the item column runs from the name to the entries column, and the search button sits at
    -- its right edge -- so the header text stops short of it rather than running underneath
    local itemX  = NAME_X
    local itemW  = math.max(0, entriesX - GAP - itemX)
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

    self.headLabels[2]:SetPosition(entriesX, 0)
    self.headLabels[2]:SetWidth(math.max(0, COL_ENTRIES - GAP))
    self.headLabels[3]:SetPosition(anyX, 0)
    self.headLabels[3]:SetWidth(COL_ANY)
    -- YOURS names the rate AND its sample, so its label spans both -- the bar between it and
    -- ANY is unlabelled on purpose: it is the same number as ANY, drawn as a length
    self.headLabels[4]:SetPosition(yoursX, 0)
    self.headLabels[4]:SetWidth(COL_YOURS)

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

    -- TWO HINTS, AS MANY AS FIT. "Any" is a word the column heading cannot explain on its own,
    -- so it is the one that stays; the greyed-rates note joins it when the window is wide
    -- enough. Turbine will not clip a label, so the choice is made here rather than left to
    -- overflow across the item count on the other half of the footer.
    local anyHint  = _G.L("browserAnyHint")
    local bothHint = _G.L("browserRateHint") .. _G.Sep .. anyHint

    self.hintLabel:SetText(
        (#bothHint * _G.GlyphWidth(10) <= hintW) and bothHint or anyHint)

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
