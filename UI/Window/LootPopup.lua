-- Loot popup: a SEPARATE window that opens when a chest is looted.
--
-- Chrome (border, title bar, drag, close) comes from PanelWindow, exactly like the main
-- window. Only the body below is this file's concern.
--
-- The boss chips are generated from _G.Events -- every entry sharing the current instance and
-- tier, ordered by event.order -- so they are always right for the instance, with no list
-- maintained here.

import "LootLogs.UI.Window.PanelWindow"
import "LootLogs.UI.Window.LootRow"

local PAD, GAP, ROW_H, CHIP_H, CHIP_GAP, POPUP_W, FOOT_H, SEP_W, TITLE_H, MIN_ROWS
local MAX_ROWS, SCROLL_W

local function Metrics()
    SEP_W    = 1
    PAD      = _G.Scaled(8)
    GAP      = _G.Scaled(8)
    -- taken from LootRow rather than restated: the rows are that tall because a quickslot
    -- cannot be scaled below 32px, and a second copy of the number here would drift
    ROW_H    = _G.LootRowHeight()
    CHIP_H   = _G.Scaled(18)
    CHIP_GAP = _G.Scaled(4)
    FOOT_H   = _G.Scaled(22)
    TITLE_H  = _G.Scaled(30)
    POPUP_W  = _G.Scaled(320)
    MIN_ROWS = 3

    -- The ceiling. The window used to grow to fit whatever dropped, which was fine when the
    -- catalogue was a handful of hand-written rows; against the game's own loot tables a good
    -- chest can flag a dozen items and the popup would run off the screen -- and it opens
    -- UNBIDDEN, so it must never be the biggest thing on it.
    --
    -- Counted in ROWS rather than pixels so it holds at any font size: eight rows is roughly
    -- half the height of the loot browser, and past that you are reading a list, not glancing
    -- at an alert.
    MAX_ROWS = 8
    SCROLL_W = 10
end

_G.RegisterMetrics(Metrics)

_G.LootPopup = class(_G.PanelWindow)

function _G.LootPopup:Constructor()

    _G.PanelWindow.Constructor(self, { resizable = false })

    self.chest    = nil         -- the chest that opened this popup
    self.selected = nil         -- eventIndex being shown, or "full"
    self.chips    = {}
    self.rows     = {}

    local settings = _G.Settings.lootPopup or { left = 700, top = 300 }
    self:SetPosition(settings.left, settings.top)
    self:SetSize(POPUP_W, _G.Scaled(220))

    self.chipStrip = Turbine.UI.Control()
    self.chipStrip:SetParent(self.client)
    self.chipStrip:SetMouseVisible(false)

    -- A ListBox rather than a plain Control, so the rows can scroll once there are more than
    -- the window is allowed to show. It still owns the rows it is given, which is what keeps
    -- them reusable across chests.
    self.rowHost = Turbine.UI.ListBox()
    self.rowHost:SetParent(self.client)
    -- takes the mouse, so the wheel scrolls the list; a list you can only move with the bar is
    -- half a scrollbar
    self.rowHost:SetMouseVisible(true)

    self.rowScroll = Turbine.UI.Lotro.ScrollBar()
    self.rowScroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.rowScroll:SetParent(self.client)
    self.rowScroll:SetWidth(SCROLL_W)
    self.rowScroll:SetVisible(false)
    self.rowHost:SetVerticalScrollBar(self.rowScroll)

    -- On the client, not on rowHost: a ListBox draws the items it was given and nothing else,
    -- so a label parented to it would never appear.
    self.emptyLabel = Turbine.UI.Label()
    self.emptyLabel:SetParent(self.client)
    self.emptyLabel:SetMultiline(true)
    self.emptyLabel:SetFont(_G.Font(10))
    self.emptyLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.emptyLabel:SetForeColor(_G.Theme.DIM)
    self.emptyLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.emptyLabel:SetMouseVisible(false)
    self.emptyLabel:SetVisible(false)

    self.footSep = Turbine.UI.Control()
    self.footSep:SetParent(self.client)
    self.footSep:SetHeight(SEP_W)
    self.footSep:SetBackColor(_G.Theme.FRAME)
    self.footSep:SetMouseVisible(false)

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
    self.hintLabel:SetText("/lootlogs loot")
    self.hintLabel:SetMouseVisible(false)

    self:SetWantsKeyEvents(true)
    self.KeyDown = function(sender, args)
        if args.Action == Turbine.UI.Lotro.Action.Escape then
            self:CloseWindow()
        end
    end

    self:SetVisible(false)

end

-- ------------------------------------------------------------------------------------------------

-- Every _G.Events entry for this instance at this tier, in boss order. Generated, never listed.
function _G.LootPopup:BossEvents(instance, tier)

    local list = {}

    for eventIndex, event in pairs(_G.Events) do
        if event.instance == instance and event.tier == tier then
            list[#list + 1] = { index = eventIndex, event = event }
        end
    end

    table.sort(list, function(a, b)
        return (a.event.order or 99) < (b.event.order or 99)
    end)

    return list

end

-- has this boss been looted in the run currently on screen?
function _G.LootPopup:HasChest(eventIndex)

    local run = _G.LootDrops and _G.LootDrops.currentRun
    if run == nil then return false end

    for _, chest in ipairs(run.chests) do
        if chest.logIndex == eventIndex then return true end
    end

    return false

end

function _G.LootPopup:ShowChest(chest)

    self.chest    = chest
    self.selected = chest.logIndex

    self:Rebuild()
    self:SetVisible(true)
    self:Activate()

end

-- ------------------------------------------------------------------------------------------------

-- One chip, in the frame/inner/label anatomy the content view's chips already use.
function _G.LootPopup:MakeChip(text, selected, dimmed, onClick)

    local width = math.max(_G.Scaled(30),
        math.floor(#text * _G.GlyphWidth(10)) + _G.Scaled(14))

    local chip = Turbine.UI.Control()
    chip:SetParent(self.chipStrip)
    chip:SetSize(width, CHIP_H)
    chip:SetBackColor(selected and _G.Theme.CHIP_FAV_FRAME or _G.Theme.FRAME)
    chip:SetMouseVisible(true)

    local inner = Turbine.UI.Control()
    inner:SetParent(chip)
    inner:SetPosition(1, 1)
    inner:SetSize(width - 2, CHIP_H - 2)
    inner:SetBackColor(selected and _G.Theme.CHIP_FAV_BG or _G.Theme.BG)
    inner:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(inner)
    label:SetMultiline(false)
    label:SetSize(width - 2, CHIP_H - 2)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(selected and _G.Theme.CHIP_FAV_TEXT
                       or (dimmed and _G.Theme.DIM or _G.Theme.TEXT))
    label:SetText(text)
    label:SetMouseVisible(false)

    -- A boss with nothing recorded this run is dimmed but still clickable: selecting it and
    -- getting the empty state is information, where an unclickable chip is just a dead end.
    chip.MouseEnter = function()
        if not selected then chip:SetBackColor(_G.Theme.HOVER) end
    end
    chip.MouseLeave = function()
        if not selected then chip:SetBackColor(_G.Theme.FRAME) end
    end
    chip.MouseClick = onClick

    return chip

end

function _G.LootPopup:BuildChips()

    for _, chip in ipairs(self.chips) do
        chip:SetParent(nil)
    end
    self.chips = {}

    if self.chest == nil then return end

    local x = 0

    local function add(text, selected, dimmed, onClick)
        local chip = self:MakeChip(text, selected, dimmed, onClick)
        chip:SetPosition(x, 0)
        x = x + chip:GetWidth() + CHIP_GAP
        self.chips[#self.chips + 1] = chip
    end

    for _, entry in ipairs(self:BossEvents(self.chest.instance, self.chest.tier)) do
        local index = entry.index
        add(entry.event.name, self.selected == index, not self:HasChest(index), function()
            self.selected = index
            self:Rebuild()
        end)
    end

    add(_G.L("fullRun"), self.selected == "full", false, function()
        self.selected = "full"
        self:Rebuild()
    end)

end

-- The loot to show for the current selection, grouped by looter.
--
-- Chat order is arrival order, which is near-random within a frame and tells the reader
-- nothing. Grouping by player answers the question the popup is actually opened for -- "what
-- did we get, and who has it" -- and sorting the names inside each group keeps a chest's rows
-- in the same order every time it is reopened.
--
-- You come first regardless of your name. Your own loot is what the window emphasises
-- everywhere else, and hunting for yourself alphabetically undoes that.
function _G.LootPopup:SelectedItems()

    local items = {}
    local run   = _G.LootDrops and _G.LootDrops.currentRun

    if run == nil then return items end

    -- Grouped drops collapse to one entry per looter. Six differently-named traceries from one
    -- chest are six lines saying the same thing; "Tracery" once, per person, is the fact.
    --
    -- ONLY "collapse" GROUPS. An "expand" group buckets real, wantable items -- armour pieces --
    -- and nobody looted "Fallen armour": they looted a pair of boots, and that is what the
    -- window has to say. The bucket is a browser convenience, not a thing that drops.
    local grouped = {}

    for _, chest in ipairs(run.chests) do
        if self.selected == "full" or chest.logIndex == self.selected then
            for _, item in ipairs(chest.items) do
                -- only what the drops data flagged as worth interrupting for; the rest was
                -- still recorded, it just does not belong in a window that pops up unbidden
                if _G.LootDrops.IsPopupItem(chest.logIndex, item.base) then

                    local group = _G.LootDrops.GroupOf(chest.logIndex, item.base)
                    if group ~= nil and _G.LootDrops.GroupExpands(group) then
                        group = nil
                    end

                    if group == nil then
                        items[#items + 1] = { item = item, logIndex = chest.logIndex }
                    else
                        local key  = group .. "\0" .. tostring(item.player)
                        local seen = grouped[key]
                        if seen == nil then
                            -- a copy, so the group name is shown without renaming the capture
                            local shown = {
                                base     = group,
                                level    = item.level,
                                quantity = item.quantity or 1,
                                player   = item.player,
                                isSelf   = item.isSelf,
                            }
                            grouped[key] = shown
                            items[#items + 1] = { item = shown, logIndex = chest.logIndex,
                                                  grouped = true }
                        else
                            seen.quantity = (seen.quantity or 1) + (item.quantity or 1)
                        end
                    end

                end
            end
        end
    end

    table.sort(items, function(a, b)

        -- WISHLISTED FIRST, above even your own loot. The popup opens on its own and is read in
        -- a second; the one thing it must never do is put what you have been waiting for below
        -- the fold. Everything else is tidiness.
        local wishA = _G.LootDrops.IsWished(a.logIndex, a.item.base)
        local wishB = _G.LootDrops.IsWished(b.logIndex, b.item.base)
        if wishA ~= wishB then
            return wishA
        end

        if a.item.isSelf ~= b.item.isSelf then
            return a.item.isSelf
        end

        local playerA = a.item.player or ""
        local playerB = b.item.player or ""
        if playerA ~= playerB then
            return playerA < playerB
        end

        -- alphabetical by what is on screen, which is the label where one is set
        return _G.LootDrops.DisplayNameAt(a.logIndex, a.item.base)
             < _G.LootDrops.DisplayNameAt(b.logIndex, b.item.base)

    end)

    return items

end

function _G.LootPopup:Rebuild()

    if self.chest == nil then return end

    local instance = _G.Instances[self.chest.instance]
    self:SetTitleText(
        (instance and instance.name or "?")
        .. _G.Sep .. _G.CM("DIM") .. tostring(self.chest.tier) .. _G.CMR)

    self:BuildChips()

    local items = self:SelectedItems()

    -- The width the rows will have, computed rather than read back off rowHost: on the first
    -- Rebuild the host has not been laid out yet, and a row sized from it would cut its name
    -- to fit a width that no longer exists a moment later.
    -- Whether the bar is there changes how wide a row is, and the rows are built before the
    -- window is laid out -- so the decision is made here, from the count, rather than read
    -- back off a control that has not been sized yet.
    local scrolling = #items > MAX_ROWS
    local rowWidth  = math.max(0, POPUP_W - 2 * PAD
        - (scrolling and (SCROLL_W + math.floor(GAP / 2)) or 0))

    -- Rows are reused, not rebuilt: Turbine has no destructor, so rebuilding on every chest
    -- would pile up orphaned controls for as long as the session lasts. ClearItems only lets
    -- go of them; the same objects go straight back in.
    self.rowHost:ClearItems()

    for index, entry in ipairs(items) do

        local row = self.rows[index]
        if row == nil then
            row = _G.LootRow(self.rowHost)
            self.rows[index] = row
        end

        row:SetVisible(true)
        row:SetSize(rowWidth, ROW_H)
        self.rowHost:AddItem(row)

        -- after AddItem, because the list may have resized the row -- and the width is what
        -- the name is truncated against
        row:SetWidth(rowWidth)
        row:SetLoot(entry.item, _G.LootDrops.DropRow(entry.logIndex, entry.item.base),
            entry.logIndex)

    end

    -- rows past the end are simply not in the list any more, so nothing draws them

    local mine = 0
    for _, entry in ipairs(items) do
        if entry.item.isSelf then mine = mine + 1 end
    end

    -- A chest with no matched loot must still show. Silence reads as a broken plugin.
    self.emptyLabel:SetVisible(#items == 0)
    self.emptyLabel:SetText(_G.L("noLootYet"))

    self.footLabel:SetText(#items .. " "
        .. (#items == 1 and _G.L("itemsOne") or _G.L("items"))
        .. _G.Sep .. mine .. " " .. _G.L("yours"))

    self:Layout(#items)

end

-- The window grows to fit its rows, up to MAX_ROWS; past that it stops growing and the list
-- scrolls. The scrollbar only appears when it is needed -- a permanent one on a three-row
-- popup is a bar of furniture doing nothing.
function _G.LootPopup:Layout(rowCount)

    rowCount = rowCount or 0

    self.scrolling = rowCount > MAX_ROWS

    local shown  = math.max(math.min(rowCount, MAX_ROWS), MIN_ROWS)
    local height = TITLE_H + SEP_W
                 + PAD + CHIP_H + GAP
                 + shown * ROW_H
                 + GAP + SEP_W + FOOT_H + PAD

    self.rowScroll:SetVisible(self.scrolling)

    self:SetSize(POPUP_W, height)

end

function _G.LootPopup:OnLayout(width, height)

    if self.chipStrip == nil then return end

    local inner = math.max(0, width - 2 * PAD)

    self.chipStrip:SetPosition(PAD, PAD)
    self.chipStrip:SetSize(inner, CHIP_H)

    local rowTop  = PAD + CHIP_H + GAP
    local footTop = height - PAD - FOOT_H

    -- the scrollbar takes its width out of the rows, so a name is never cut by the bar
    local rowsW  = inner - (self.scrolling and (SCROLL_W + math.floor(GAP / 2)) or 0)
    local rowsH  = math.max(0, footTop - GAP - SEP_W - rowTop)

    self.rowHost:SetPosition(PAD, rowTop)
    self.rowHost:SetSize(rowsW, rowsH)

    self.rowScroll:SetPosition(PAD + rowsW + math.floor(GAP / 2), rowTop)
    self.rowScroll:SetSize(SCROLL_W, rowsH)

    for _, row in ipairs(self.rows) do
        row:SetWidth(rowsW)
    end

    self.emptyLabel:SetPosition(PAD, rowTop)
    self.emptyLabel:SetSize(inner, rowsH)

    self.footSep:SetPosition(PAD, math.max(0, footTop - GAP))
    self.footSep:SetWidth(inner)

    self.footLabel:SetPosition(PAD, footTop)
    self.footLabel:SetSize(math.floor(inner / 2), FOOT_H)

    self.hintLabel:SetPosition(PAD + math.floor(inner / 2), footTop)
    self.hintLabel:SetSize(inner - math.floor(inner / 2), FOOT_H)

end

function _G.LootPopup:OnMoved()

    local left, top = self:GetPosition()

    if _G.Settings.lootPopup == nil then _G.Settings.lootPopup = {} end
    _G.Settings.lootPopup.left = left
    _G.Settings.lootPopup.top  = top
    _G.SaveSettings()

end

function _G.LootPopup:PositionChanged()

    -- the drag itself saves once on mouse-up, via OnMoved
    if not self._dragging then
        self:OnMoved()
    end

end
