-- Loot browser: a SEPARATE window listing the drops database.
--
-- Left pane is a content pack -> instance -> boss tree built from _G.Content, _G.Instances and
-- _G.Events, filtered to instances that actually have _G.Drops rows. Right pane is the item
-- table for the selection, at the selected tier.
--
-- The tier pills are derived from the distinct tier values of the selected instance's events,
-- ordered by _G.TierOrder -- so they are always right per instance, including the ones that
-- carry Solo on top of T1-T5, with no list maintained here.

import "LootLogs.UI.Window.PanelWindow"
import "LootLogs.UI.Window.LootRow"

local PAD, GAP, SEP_W, ROW_H, TREE_ROW_H, HEAD_H, TREE_W, PILL_H, PILL_GAP, SEARCH_H
local STAR, INDENT, SLOT, NAME_X
local COL_SLOT, COL_DB, COL_YOURS, COL_STAR
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
    COL_SLOT   = _G.Scaled(88)
    COL_DB     = _G.Scaled(52)
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
        self.search = string.lower(self.searchBox:GetText() or "")
        self.searchHint:SetVisible(self.search == "")
        self:RebuildTree()
        self:RebuildTable()
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

local function Matches(search, text)
    return search == "" or string.find(string.lower(text), search, 1, true) ~= nil
end

-- An item is findable under the name the client prints AND under its label, because whoever is
-- searching knows it by one or the other and has no way to tell which this build stores.
local function MatchesDrop(search, drop)
    return Matches(search, drop.item)
        or (drop.label ~= nil and Matches(search, drop.label))
end

-- Every catalogued row, flattened, for the search path. Searching has to reach across
-- instances -- "where does this drop" is the question the box exists to answer.
function _G.LootBrowser:SearchRows()

    local rows = {}

    if _G.Drops == nil then return rows end

    for eventIndex, drops in pairs(_G.Drops) do
        local event = _G.Events[eventIndex]
        if event ~= nil then
            for _, drop in ipairs(drops) do
                if MatchesDrop(self.search, drop) then
                    rows[#rows + 1] = { index = eventIndex, event = event, drop = drop }
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        local nameA = _G.LootDrops.DisplayName(a.drop, a.drop.item)
        local nameB = _G.LootDrops.DisplayName(b.drop, b.drop.item)
        if nameA ~= nameB then return nameA < nameB end
        return a.index < b.index
    end)

    return rows

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

    row.SizeChanged = function()
        local labelW = math.floor(#text * _G.GlyphWidth(10) * 2) + _G.Scaled(8)
        label:SetWidth(labelW)
        rule:SetPosition(PAD + labelW + GAP, math.floor(HEAD_H / 2))
        rule:SetWidth(math.max(0, row:GetWidth() - PAD * 2 - labelW - GAP))
    end

    return row

end

-- One catalogued item. Not a LootRow: that one is built around a looter and a level, which a
-- database row has neither of. What they share is the icon and quality vocabulary.
function _G.LootBrowser:MakeItemRow(eventIndex, drop, alt)

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetMouseVisible(true)

    local wished = _G.LootStats ~= nil and _G.LootStats.IsWished(drop.item)

    local function Ground()
        return wished and _G.Theme.CHIP_FAV_BG or (alt and _G.Theme.ROW_ALT or _G.Theme.BG)
    end
    row:SetBackColor(Ground())

    -- quality bar; the quickslot sits beside it, so rarity stays readable at a glance
    local bar = Turbine.UI.Control()
    bar:SetParent(row)
    bar:SetSize(3, SLOT)
    bar:SetPosition(PAD, math.floor((ROW_H - SLOT) / 2))
    bar:SetBackColor(_G.LootQualityColor(drop.quality))
    bar:SetMouseVisible(false)

    -- the item's own icon and tooltip, from its catalogued id; see UI/Window/LootRow.lua
    local slot = _G.MakeItemQuickslot(row, drop.item)
    _G.ApplyItemShortcut(slot, drop)
    slot:SetPosition(PAD + 3 + math.floor(GAP / 2), math.floor((ROW_H - SLOT) / 2))

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetMultiline(false)
    nameLabel:SetHeight(ROW_H)
    nameLabel:SetFont(_G.Font(12))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.LootQualityColor(drop.quality))
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetMouseVisible(false)

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
    if drop.chance ~= nil then
        dbLabel:SetForeColor(_G.Theme.TEXT)
        dbLabel:SetText(math.floor(drop.chance * 100 + 0.5) .. "%")
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

    row.SizeChanged = function()

        local width  = row:GetWidth()
        local starX  = width - PAD - COL_STAR + math.floor((COL_STAR - STAR) / 2)
        local yoursX = width - PAD - COL_STAR - COL_YOURS
        local dbX    = yoursX - COL_DB
        local slotX  = dbX - COL_SLOT
        local nameX  = NAME_X

        nameLabel:SetPosition(nameX, 0)
        nameLabel:SetWidth(math.max(0, slotX - nameX - GAP))
        nameLabel:SetText(_G.Truncate(_G.LootDrops.DisplayName(drop, drop.item),
            nameLabel:GetWidth(), _G.GlyphWidth(12)))

        slotLabel:SetPosition(slotX, 0)
        slotLabel:SetWidth(COL_SLOT)
        slotLabel:SetText(_G.Truncate(drop.slot or "", COL_SLOT - GAP, _G.GlyphWidth(10)))

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

function _G.LootBrowser:RebuildTable()

    self.tableHost:ClearItems()
    self:RebuildPills()

    local shown, starred = 0, 0
    local alt = false

    if self.search ~= "" then

        -- search mode ignores the tree selection entirely: the question is where an item
        -- drops, and answering it inside one instance would be answering a different one
        local rows = self:SearchRows()
        local lastEvent = nil

        for _, entry in ipairs(rows) do
            if not self:Filtered(entry.drop) then
                if entry.index ~= lastEvent then
                    lastEvent = entry.index
                    local instance = _G.Instances[entry.event.instance]
                    self.tableHost:AddItem(self:MakeGroupHeader(
                        (instance and instance.name or "?") .. _G.Sep
                        .. entry.event.name .. _G.Sep .. tostring(entry.event.tier)))
                    alt = false
                end
                self.tableHost:AddItem(self:MakeItemRow(entry.index, entry.drop, alt))
                alt = not alt
                shown = shown + 1
                if _G.LootStats ~= nil and _G.LootStats.IsWished(entry.drop.item) then
                    starred = starred + 1
                end
            end
        end

        self.instanceLabel:SetText(_G.L("searchItems"))
        self.countLabel:SetText(shown .. " " .. _G.L("items"))

    else

        local instance = self.selectedInstance and _G.Instances[self.selectedInstance]
        self.instanceLabel:SetText(instance and instance.name or "")

        local bosses = self:BossesFor(self.selectedInstance, self.selectedTier)

        for _, boss in ipairs(bosses) do
            if self.selectedEvent == nil or self.selectedEvent == boss.index then

                -- Which of this boss's rows survive the filter, decided before the header is
                -- emitted -- a group header over nothing is worse than no header.
                local visible = {}
                for _, drop in ipairs(_G.Drops[boss.index] or {}) do
                    if not self:Filtered(drop) then
                        visible[#visible + 1] = drop
                    end
                end

                if #visible > 0 then

                    -- the header only earns its line when more than one boss is on screen
                    if self.selectedEvent == nil then
                        self.tableHost:AddItem(self:MakeGroupHeader(boss.event.name))
                        alt = false
                    end

                    for _, drop in ipairs(visible) do
                        self.tableHost:AddItem(self:MakeItemRow(boss.index, drop, alt))
                        alt = not alt
                        shown = shown + 1
                        if _G.LootStats ~= nil and _G.LootStats.IsWished(drop.item) then
                            starred = starred + 1
                        end
                    end

                end

            end
        end

        self.countLabel:SetText(#bosses .. " " .. _G.L("bosses")
            .. _G.Sep .. shown .. " " .. _G.L("catalogued"))

    end

    self.footLabel:SetText(shown .. " " .. _G.L("items")
        .. _G.Sep .. starred .. " " .. _G.L("starred"))

    self:LayoutRows()

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

    self.headLabels[1]:SetPosition(NAME_X, 0)
    self.headLabels[1]:SetWidth(math.max(0, slotX - PAD - GAP))
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
