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
local COL_SLOT, COL_DB, COL_YOURS, COL_STAR
local PREVIEW_GAP, MORE_W
local MIN_WIDTH, MIN_HEIGHT

-- How many members a group row shows the art of. Most groups hold a handful, so five is
-- usually all of them; the rest are counted in the "+N" that follows.
local PREVIEW_MAX = 5

-- ...but a group can hold fifty, and every candidate costs a lookup into the client's item
-- table. Only so many are tried before the row settles for what it has.
local PREVIEW_TRIES = 12

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
    COL_SLOT   = _G.Scaled(88)
    COL_DB     = _G.Scaled(52)
    COL_YOURS  = _G.Scaled(78)
    COL_STAR   = _G.Scaled(24)
    -- the gap between the icons of a group row's preview strip, and the room the "+N" after
    -- them needs; both scale, unlike the 32px art itself
    PREVIEW_GAP = _G.Scaled(4)
    MORE_W      = _G.Scaled(30)
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
    for _, spec in ipairs({ { "colItem", Turbine.UI.ContentAlignment.MiddleLeft },
                            { "colSlot", Turbine.UI.ContentAlignment.MiddleLeft },
                            { "colDb",   Turbine.UI.ContentAlignment.MiddleRight },
                            { "colYours",Turbine.UI.ContentAlignment.MiddleRight } }) do
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
    self.hintLabel:SetText(_G.L("browserRateHint"))
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

-- distinct tiers of one instance that actually have drops, lowest first
function _G.LootBrowser:TiersFor(instanceId)

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

function _G.LootBrowser:SelectInstance(instanceId)

    self.selectedInstance = instanceId
    self.selectedEvent    = nil

    local tiers = self:TiersFor(instanceId)
    self.selectedTier = tiers[1]

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

        -- how many catalogued rows this instance holds, across every tier
        local total = 0
        for eventIndex, drops in pairs(_G.Drops or {}) do
            local event = _G.Events[eventIndex]
            if event ~= nil and event.instance == entry.id then
                total = total + #drops
            end
        end

        local instanceId = entry.id
        local selected   = (self.selectedInstance == instanceId and self.selectedEvent == nil)

        self.treeHost:AddItem(self:MakeNode("instance", entry.instance.name, total, selected,
            function() self:SelectInstance(instanceId) end))

        -- bosses, only under the open instance, and only at the tier being shown
        if self.selectedInstance == instanceId then
            for _, boss in ipairs(self:BossesFor(instanceId, self.selectedTier)) do
                local eventIndex = boss.index
                local bossCount  = #(_G.Drops[eventIndex] or {})
                self.treeHost:AddItem(self:MakeNode("boss", boss.event.name, bossCount,
                    self.selectedEvent == eventIndex,
                    function()
                        self.selectedEvent = (self.selectedEvent == eventIndex) and nil or eventIndex
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
            self.selectedTier = tier
            -- the boss selection belongs to the old tier and would show its rows
            self.selectedEvent = nil
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

-- A boss name as a group header, with a rule running out to the right.
function _G.LootBrowser:MakeGroupHeader(text)

    local row = Turbine.UI.Control()
    row:SetHeight(HEAD_H)
    row:SetBackColor(_G.Theme.BG)
    row:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetMultiline(false)
    label:SetPosition(PAD, 0)
    label:SetHeight(HEAD_H)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.ACCENT)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetText(_G.Spaced(_G.Upper(text)))
    label:SetMouseVisible(false)

    local rule = Turbine.UI.Control()
    rule:SetParent(row)
    rule:SetHeight(SEP_W)
    rule:SetBackColor(_G.Theme.FRAME)
    rule:SetMouseVisible(false)

    -- named for the same reason as the item row's: AddRow drives it directly, because a
    -- rebuilt row that happens to match the list's width never fires SizeChanged
    row.Layout = function()
        local labelW = math.floor(#text * _G.GlyphWidth(10) * 2) + _G.Scaled(8)
        label:SetWidth(labelW)
        rule:SetPosition(PAD + labelW + GAP, math.floor(HEAD_H / 2))
        rule:SetWidth(math.max(0, row:GetWidth() - PAD * 2 - labelW - GAP))
    end

    row.SizeChanged = row.Layout

    return row

end

-- One catalogued item. Not a LootRow: that one is built around a looter and a level, which a
-- database row has neither of. What they share is the icon and quality vocabulary.
function _G.LootBrowser:MakeItemRow(eventIndex, drop, alt)

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetMouseVisible(true)

    local wished = _G.LootStats ~= nil and _G.LootStats.IsWished(drop.item)

    -- A group row is a HEADING over items, not an item, so it takes the header ground the
    -- table's own column strip uses and stays out of the striping. That band, the fixed mark
    -- where the art goes and the accent name are three signals saying the same thing: what is
    -- named here is a category, and the rate beside it is the category's.
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

    -- A child of an open fold is stepped in as a whole -- bar, icon and name together. Moving
    -- the name alone would leave the art in a column of its own and read as a separate list.
    local indent = drop.child and INDENT or 0

    -- The fold marker takes the quality bar's place on an expandable group row, because a
    -- group has no one quality to show and the two would fight for the same 3px.
    local expandable = drop.isGroup and drop.expandable

    if expandable then

        local caret = Turbine.UI.Control()
        caret:SetParent(row)
        caret:SetSize(STAR, STAR)
        caret:SetPosition(PAD - 4, math.floor((ROW_H - STAR) / 2))
        -- No SetForeColor here: that is a Label method, and calling it on a Control throws --
        -- which killed the whole row and took every grouped line off the table with it. An
        -- Overlay glyph is tinted by the ground BEHIND it, never by a fore colour of its own
        -- (Ressources/ICONS.md).
        caret:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        caret:SetBackground(drop.open and "LootLogs/Ressources/arrow_down.tga"
                                      or  "LootLogs/Ressources/arrow_right.tga")
        caret:SetMouseVisible(false)

    else

        -- quality bar; the icon sits beside it, so rarity stays readable at a glance. A group
        -- that does not fold has no one quality either, so it gets the accent strip instead of
        -- a colour borrowed from whichever member happened to be listed first.
        local bar = Turbine.UI.Control()
        bar:SetParent(row)
        bar:SetSize(3, SLOT)
        bar:SetPosition(PAD + indent, math.floor((ROW_H - SLOT) / 2))
        bar:SetBackColor(drop.isGroup and _G.Theme.STRIP or _G.LootQualityColor(drop.quality))
        bar:SetMouseVisible(false)

    end

    -- Where the art column starts. A group's preview strip begins here too, so its first icon
    -- sits exactly where a plain item's would.
    local iconX = PAD + 3 + math.floor(GAP / 2) + indent

    -- The item's own art, composed from its catalogued id. Images rather than a quickslot, so
    -- no stack count from your bags is painted over a listing about the world -- the tooltip
    -- that used to justify the slot now comes from the name link. See UI/Window/LootRow.lua.
    local iconHost = Turbine.UI.Control()
    iconHost:SetParent(row)
    iconHost:SetSize(SLOT, SLOT)
    iconHost:SetPosition(iconX, math.floor((ROW_H - SLOT) / 2))
    iconHost:SetMouseVisible(false)

    -- A GROUP SHOWS ITS MEMBERS, NOT A NAME. The export numbers its groups -- "Group 12" -- and
    -- most of them are a set nobody has a word for, so the name column was printing a label that
    -- said nothing where the useful thing, WHAT IS IN IT, was a fold away. So the row draws the
    -- first few members' icons across the name column instead, and counts the rest as "+N".
    --
    -- Icons only, and mouse-invisible: they are a picture of the group, not rows of their own,
    -- and the whole line stays one click that opens the fold. The members themselves, with their
    -- names, links and rates, are what the fold is for.
    --
    -- previewCount is every member the group stands for, whether or not its art resolved, because
    -- "+N" answers "how many more are in here" -- not "how many pictures were left out".
    local preview, previewCount, moreLabel = nil, 0, nil

    if drop.isGroup then

        preview = {}

        local tries = 0

        for _, member in ipairs(drop.members) do
            -- the bucket row IS the group -- it carries the category's rate, has no id, and is
            -- not one of the things in it
            if not member.bucket then

                previewCount = previewCount + 1

                if #preview < PREVIEW_MAX and tries < PREVIEW_TRIES then
                    tries = tries + 1
                    local host = Turbine.UI.Control()
                    host:SetParent(row)
                    host:SetSize(SLOT, SLOT)
                    host:SetMouseVisible(false)
                    if _G.MakeItemIcon(host, member.id, SLOT) ~= nil then
                        preview[#preview + 1] = host
                    else
                        -- an uncatalogued id draws nothing; drop the empty host and try the next
                        host:SetParent(nil)
                    end
                end

            end
        end

        if #preview == 0 then

            -- Nothing resolved -- so the row falls back to what it was: the fixed group mark
            -- (a plugin glyph, Overlay over the row's ground, Ressources/ICONS.md) and the
            -- group's own name. A blank line is worse than a name that says little.
            local mark = Turbine.UI.Control()
            mark:SetParent(iconHost)
            mark:SetSize(SLOT, SLOT)
            mark:SetBlendMode(Turbine.UI.BlendMode.Overlay)
            mark:SetBackground("LootLogs/Ressources/group.tga")
            mark:SetMouseVisible(false)
            preview = nil

        else

            moreLabel = Turbine.UI.Label()
            moreLabel:SetParent(row)
            moreLabel:SetMultiline(false)
            moreLabel:SetHeight(ROW_H)
            moreLabel:SetFont(_G.Font(12))
            moreLabel:SetFontStyle(_G.Theme.FONT_STYLE)
            moreLabel:SetForeColor(_G.Theme.ACCENT)
            moreLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
            moreLabel:SetMouseVisible(false)

        end

    else
        _G.MakeItemIcon(iconHost, drop.id, SLOT)
    end

    -- The whole row toggles the fold, not just the caret: a 12px arrow is a small target for
    -- something the entire row is about. The star and the name link keep their own clicks,
    -- because they are mouse-visible and take the event first.
    if expandable then
        row.MouseClick = function()
            self:ToggleGroup(eventIndex, drop.group)
        end
    end

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetMultiline(false)
    nameLabel:SetHeight(ROW_H)
    nameLabel:SetFont(_G.Font(12))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

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
        nameLabel:SetForeColor(_G.LootQualityColor(drop.quality))
        nameLabel:SetMarkupEnabled(true)
        nameLabel:SetMouseVisible(true)

    end

    local slotLabel = Turbine.UI.Label()
    slotLabel:SetParent(row)
    slotLabel:SetMultiline(false)
    slotLabel:SetHeight(ROW_H)
    slotLabel:SetFont(_G.Font(10))
    slotLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    slotLabel:SetForeColor(_G.Theme.DIM2)
    slotLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    slotLabel:SetText(drop.slot or "")
    slotLabel:SetMouseVisible(false)

    -- Database chance. An absent chance means "drops, rate not established" and must read as
    -- unknown -- never as 0%, which would claim knowledge the table does not have.
    local dbLabel = Turbine.UI.Label()
    dbLabel:SetParent(row)
    dbLabel:SetMultiline(false)
    dbLabel:SetHeight(ROW_H)
    dbLabel:SetFont(_G.Font(12))
    dbLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    dbLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    dbLabel:SetMouseVisible(false)
    -- the category's own rate wins over any one member's, on a group row
    local shownChance = drop.bucketChance or drop.chance

    if shownChance ~= nil then
        dbLabel:SetForeColor(_G.Theme.TEXT)
        dbLabel:SetText(math.floor(shownChance * 100 + 0.5) .. "%")
    else
        dbLabel:SetForeColor(_G.Theme.DASH)
        dbLabel:SetText("\226\128\148")                     -- em dash
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

    local count, opens = 0, 0
    if _G.LootStats ~= nil then
        if drop.isGroup then
            -- any member is the same event, so the counts add
            for _, member in ipairs(drop.members) do
                local memberCount, memberOpens = _G.LootStats.Observed(eventIndex, member.item)
                count = count + memberCount
                opens = math.max(opens, memberOpens)
            end
        else
            count, opens = _G.LootStats.Observed(eventIndex, drop.item)
        end
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
    -- exactly where you are looking. So the label drives the same highlight. A group's name is
    -- mouse-invisible and never intercepts it in the first place.
    nameLabel.MouseEnter = row.MouseEnter
    nameLabel.MouseLeave = row.MouseLeave

    -- Named, because a rebuilt row cannot rely on SizeChanged alone: a fresh row whose width
    -- already matches the list never fires one, and then it draws with every column at zero.
    -- RebuildTable calls this directly once the row is in the list and sized.
    row.Layout = function()

        local width  = row:GetWidth()
        local starX  = width - PAD - COL_STAR + math.floor((COL_STAR - STAR) / 2)
        local yoursX = width - PAD - COL_STAR - COL_YOURS
        local dbX    = yoursX - COL_DB
        local slotX  = dbX - COL_SLOT
        local nameX = NAME_X + indent

        nameLabel:SetPosition(nameX, 0)
        nameLabel:SetWidth(math.max(0, slotX - nameX - GAP))

        local glyph = _G.GlyphWidth(12)
        local shown = _G.LootDrops.DisplayName(drop, drop.item)

        if preview ~= nil then

            -- The preview strip takes the name column, so the name is not drawn at all. How many
            -- icons fit is decided HERE and not at build time: the window resizes, and a strip
            -- that ran past the slot column would sit under it rather than be clipped.
            local stride = SLOT + PREVIEW_GAP
            local room   = math.max(0, slotX - GAP - iconX)

            -- an overflow count needs its own space; work out the fit with that reserved, then
            -- keep the reservation only if something is in fact left over
            local fits = math.max(1, math.floor((room + PREVIEW_GAP) / stride))
            if #preview > fits or previewCount > #preview then
                fits = math.max(1, math.floor((room - MORE_W + PREVIEW_GAP) / stride))
            end

            local drawn = math.min(#preview, fits)

            for index, host in ipairs(preview) do
                host:SetVisible(index <= drawn)
                host:SetPosition(iconX + (index - 1) * stride,
                    math.floor((ROW_H - SLOT) / 2))
            end

            local hidden = previewCount - drawn

            moreLabel:SetVisible(hidden > 0)
            moreLabel:SetText("+" .. hidden)
            moreLabel:SetPosition(iconX + drawn * stride, 0)
            moreLabel:SetWidth(MORE_W)

            nameLabel:SetVisible(false)

        elseif drop.isGroup then
            -- plain text, so the full width is the text's own -- no brackets to pay for
            nameLabel:SetText(_G.Truncate(shown, nameLabel:GetWidth(), glyph))
        else
            -- truncate the visible name, then wrap it; the tag is markup and has no width, the
            -- brackets do
            nameLabel:SetText(_G.LootDrops.ItemLink(drop,
                _G.Truncate(shown, nameLabel:GetWidth() - glyph * 2, glyph)))
        end

        slotLabel:SetPosition(slotX, 0)
        slotLabel:SetWidth(COL_SLOT)
        -- A group has no slot of its own; the column says how many things it stands for. That is
        -- previewCount and not #drop.members, because the bucket row is the category itself and
        -- counting it would put the column one ahead of the icons and the "+N" beside it.
        slotLabel:SetText(_G.Truncate(
            drop.isGroup and (previewCount .. " " .. _G.L("groupKinds")) or (drop.slot or ""),
            COL_SLOT - GAP, _G.GlyphWidth(10)))

        dbLabel:SetPosition(dbX, 0)
        dbLabel:SetWidth(COL_DB)

        -- rate and sample share the column: the rate right-aligned against the sample, and
        -- the sample right-aligned against the star
        local sampleW = _G.Scaled(26)
        yoursLabel:SetPosition(yoursX, 0)
        yoursLabel:SetWidth(math.max(0, COL_YOURS - sampleW))
        sampleLabel:SetPosition(yoursX + COL_YOURS - sampleW, 0)
        sampleLabel:SetWidth(sampleW)

        star:SetPosition(starX, math.floor((ROW_H - STAR) / 2))

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

-- Is this group's fold open? Keyed per CHEST as well as per group, so opening "Fallen armour"
-- at Tier 3 does not silently open it at Solo, where a different set of pieces drops.
function _G.LootBrowser:GroupKey(eventIndex, group)
    return tostring(eventIndex) .. "\0" .. tostring(group)
end

function _G.LootBrowser:GroupOpen(eventIndex, group)
    return self.openGroups ~= nil and self.openGroups[self:GroupKey(eventIndex, group)] == true
end

function _G.LootBrowser:ToggleGroup(eventIndex, group)

    self.openGroups = self.openGroups or {}

    local key = self:GroupKey(eventIndex, group)
    self.openGroups[key] = not self.openGroups[key] or nil

    self:RebuildTable()

end

-- One row per group, the rest untouched. The group row carries the members' combined observed
-- count, because any member dropping is the event "one of these dropped" -- which is the only
-- rate that means anything for a class-specific roll.
--
-- An "expand" group keeps its members and hands them back as CHILD rows when the fold is open.
-- A "collapse" group never does: its members are placeholder names and listing them is the
-- thing grouping exists to stop. See _G.LootDrops.GroupMode.
function _G.LootBrowser:Collapse(eventIndex, rows)

    local out, groups = {}, {}

    for _, drop in ipairs(rows) do

        local group = drop.group

        if group == nil or group == "" then
            out[#out + 1] = drop
        else
            local seen = groups[group]
            if seen == nil then
                -- No id and no quality: a group is not an item and must not borrow one member's
                -- identity. The row draws it with the fixed group mark instead, and its name is
                -- text rather than a link -- see MakeItemRow.
                seen = {
                    item    = group,        -- the KEY: what the wishlist and the stats are on
                    label   = _G.LootDrops.GroupLabel(group),   -- and what is drawn instead
                    slot    = drop.slot,
                    chance  = drop.chance,
                    group   = group,
                    members = { drop },
                    isGroup = true,
                }
                -- A BUCKET ROW IS THE CATEGORY, NOT A MEMBER OF IT. The chart gives one rate for
                -- "Fallen armour" without naming a single piece; that rate belongs on the group
                -- line and the row carrying it must not also be listed inside its own fold.
                if drop.bucket then seen.bucketChance = drop.chance end
                seen.expandable = _G.LootDrops.GroupExpands(group)
                seen.open       = seen.expandable and self:GroupOpen(eventIndex, group)
                seen.bucket     = nil       -- the group row is never itself a bucket row
                groups[group]   = seen
                out[#out + 1]   = seen
            else
                seen.members[#seen.members + 1] = drop
                if seen.chance == nil then seen.chance = drop.chance end
                if drop.bucket then seen.bucketChance = drop.chance end
            end
        end

    end

    -- Second pass, because a group's members are only all known once the first pass is done.
    -- An open fold emits its members straight after their parent, marked as children so the
    -- row draws them stepped in and without a fold of their own.
    local expanded = {}

    for _, drop in ipairs(out) do

        expanded[#expanded + 1] = drop

        if drop.isGroup and drop.open then

            table.sort(drop.members, function(a, b)
                return _G.LootDrops.DisplayName(a, a.item) < _G.LootDrops.DisplayName(b, b.item)
            end)

            for _, member in ipairs(drop.members) do
                if not member.bucket then
                    expanded[#expanded + 1] = {
                        item = member.item, plural = member.plural, label = member.label,
                        quality = member.quality, slot = member.slot, chance = member.chance,
                        popup = member.popup, id = member.id, group = member.group,
                        child = true,
                    }
                end
            end

        end

    end

    return expanded

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

-- The rows of the CURRENT SELECTION, built once and kept in self.rows.
--
-- Building is the expensive half: every item row resolves its art through a shortcut lookup into
-- the client's own item table. None of that depends on the search text, so it happens when the
-- selection changes -- instance, tier, boss, the still-needed filter, a fold opening -- and not
-- when a key is pressed. ApplyFilter then decides which of these rows the list shows.
--
-- Each entry carries what the search needs to judge it, lowered here rather than per keystroke.
-- The shape and the rule are _G.LootDrops.SearchFilter's, which is where the entry fields --
-- text, memberText, parent, header -- are documented.
function _G.LootBrowser:BuildRows()

    self.rows = {}

    local instance = self.selectedInstance and _G.Instances[self.selectedInstance]
    self.instanceLabel:SetText(instance and instance.name or "")

    local bosses = self:BossesFor(self.selectedInstance, self.selectedTier)
    self.bossCount = #bosses

    for _, boss in ipairs(bosses) do
        if self.selectedEvent == nil or self.selectedEvent == boss.index then

            -- Which of this boss's rows survive the still-needed filter, decided before the
            -- header is emitted -- a group header over nothing is worse than no header. That
            -- filter is not the search: it changes what EXISTS here, so it belongs in the build.
            local visible = {}
            for _, drop in ipairs(_G.Drops[boss.index] or {}) do
                if not self:Filtered(drop) then
                    visible[#visible + 1] = drop
                end
            end

            -- Collapse grouped rows into one. Six traceries listed separately each look
            -- like a rare drop; as one line they read as what they are.
            visible = self:Collapse(boss.index, visible)

            if #visible > 0 then

                -- the header only earns its line when more than one boss is on screen
                local header = nil
                if self.selectedEvent == nil then
                    header = { kind = "header", row = self:MakeGroupHeader(boss.event.name) }
                    self.rows[#self.rows + 1] = header
                    header.index = #self.rows   -- where the filter reaches back to light it up
                end

                local alt   = false
                local group = nil

                for _, drop in ipairs(visible) do

                    local entry = {
                        kind    = "item",
                        row     = self:MakeItemRow(boss.index, drop, alt),
                        drop    = drop,
                        header  = header and header.index or nil,
                        isGroup = drop.isGroup == true,
                        text    = _G.LootDrops.SearchText(drop),
                    }

                    self.rows[#self.rows + 1] = entry
                    alt = not alt

                    if drop.isGroup then
                        local names = {}
                        for _, member in ipairs(drop.members) do
                            names[#names + 1] = _G.LootDrops.SearchText(member)
                        end
                        entry.memberText = table.concat(names, "\0")
                        group = #self.rows
                    elseif drop.child then
                        entry.parent = group        -- Collapse emits children after their group
                    else
                        group = nil
                    end

                end

            end

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
            if entry.kind == "header" then
                alt = false
                self:AddRow(entry.row)
            else
                -- restripe: which side of the stripe a row lands on depends on what the
                -- search left above it
                if entry.row.SetAlt ~= nil then entry.row.SetAlt(alt) end
                alt = not alt
                self:AddRow(entry.row)
                shown = shown + 1
                if _G.LootStats ~= nil and _G.LootStats.IsWished(entry.drop.item) then
                    starred = starred + 1
                end
            end
        end
    end

    if search == "" then
        self.countLabel:SetText((self.bossCount or 0) .. " " .. _G.L("bosses")
            .. _G.Sep .. shown .. " " .. _G.L("catalogued"))
    else
        self.countLabel:SetText(_G.L("searchItems")
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

    local starX  = tableW - PAD - COL_STAR
    local yoursX = starX - COL_YOURS
    local dbX    = yoursX - COL_DB
    local slotX  = dbX - COL_SLOT

    -- the item column runs from the name to the slot column, and the search button sits at its
    -- right edge -- so the header text stops short of it rather than running underneath
    local itemX  = NAME_X
    local itemW  = math.max(0, slotX - GAP - itemX)
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

    self.headLabels[2]:SetPosition(slotX, 0)
    self.headLabels[2]:SetWidth(COL_SLOT)
    self.headLabels[3]:SetPosition(dbX, 0)
    self.headLabels[3]:SetWidth(COL_DB)
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

    self.hintLabel:SetPosition(tableLeft + math.floor(tableW / 2), footTop)
    self.hintLabel:SetSize(tableW - math.floor(tableW / 2), HEAD_H)

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
