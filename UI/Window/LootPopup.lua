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
import "LootLogs.Utils.EventIndex"

local PAD, GAP, ROW_H, CHIP_H, CHIP_GAP, POPUP_W, FOOT_H, SEP_W, TITLE_H, MIN_ROWS
local MAX_ROWS, SCROLL_W, FIND, ICON, MIN_WIDTH, MIN_HEIGHT, SECTION_H

local function Metrics()
    SEP_W    = 1
    PAD      = _G.Scaled(8)
    GAP      = _G.Scaled(8)
    -- the .tga is clipped to its control rather than scaled, so the glyph stays 16px at every
    -- font size and only the button around it has room to spare (Ressources/ICONS.md)
    ICON     = 16
    FIND     = 18
    -- taken from LootRow rather than restated: the rows are that tall because item art is 36px
    -- and does not scale, and a second copy of the number here would drift
    ROW_H    = _G.LootRowHeight()
    CHIP_H   = _G.Scaled(18)
    CHIP_GAP = _G.Scaled(4)
    FOOT_H   = _G.Scaled(22)
    TITLE_H  = _G.Scaled(30)
    -- A section heading: a label and a rule, the same anatomy the browser's boss headings use.
    SECTION_H = _G.Scaled(18)
    -- WIDE ENOUGH FOR THE NAME. At 320 the item column was about twenty characters and most of
    -- this update's names are longer than that, so the window was mostly ellipsis. Width is the
    -- cheap dimension here: the ceiling that keeps this window modest is MAX_ROWS, and height is
    -- what a popup opening unbidden is judged on.
    --
    -- 400 -> 420 buys the drop-chance column outright, so the name gives up nothing for it.
    POPUP_W  = _G.Scaled(420)
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

    -- Resizing floors. Narrower than this and the boss chips wrap into a ladder; shorter and
    -- there is no room for a row at all. MAX_ROWS still governs the size the window CHOOSES for
    -- itself -- the gripper is there for someone who wants a different one, not to remove the
    -- restraint from the automatic case.
    MIN_WIDTH  = _G.Scaled(320)
    MIN_HEIGHT = TITLE_H + SEP_W + PAD + CHIP_H + GAP + ROW_H + GAP + SEP_W + FOOT_H + PAD
end

_G.RegisterMetrics(Metrics)

_G.LootPopup = class(_G.PanelWindow)

function _G.LootPopup:Constructor()

    _G.PanelWindow.Constructor(self, {
        resizable  = true,
        min_width  = MIN_WIDTH,
        min_height = MIN_HEIGHT,
    })

    self.chest      = nil       -- the chest that opened this popup
    self.selected   = nil       -- eventIndex being shown, or "full"
    self.chips      = {}
    self.rows       = {}
    -- pooled beside the rows and for the same reason: Turbine has no destructor, so a heading
    -- is reparented and re-driven per chest, never rebuilt
    self.headers    = {}
    self.rowCount   = 0
    self.headersH   = 0
    self.chipsH     = CHIP_H    -- one row of chips until BuildChips has counted them
    self.search     = ""        -- the lowered form, matched against
    self.searchText = ""        -- as typed
    self.searchOpen = false

    local settings = _G.Settings.lootPopup or { left = 700, top = 300 }
    self:SetPosition(settings.left, settings.top)
    self:SetSize(settings.width or POPUP_W, settings.height or _G.Scaled(220))

    self.chipStrip = Turbine.UI.Control()
    self.chipStrip:SetParent(self.client)
    self.chipStrip:SetMouseVisible(false)

    -- SEARCH TAKES THE CHIP ROW, it does not add a row of its own. This window opens unbidden
    -- and must never be the biggest thing on the screen -- the same reason MAX_ROWS exists -- so
    -- a permanently visible field would be paying height on every chest for something wanted on
    -- few. The magnifier sits at the end of the chips and the field takes their place while it
    -- is open, which is the browser's own idiom (UI/Window/LootBrowser.lua).
    self.findBtn = Turbine.UI.Control()
    self.findBtn:SetParent(self.client)
    self.findBtn:SetSize(FIND, FIND)
    self.findBtn:SetBackColor(_G.Theme.FRAME)
    self.findBtn:SetMouseVisible(true)

    local findIcon = Turbine.UI.Control()
    findIcon:SetParent(self.findBtn)
    findIcon:SetSize(ICON, ICON)
    findIcon:SetPosition(math.floor((FIND - ICON) / 2), math.floor((FIND - ICON) / 2))
    findIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    findIcon:SetBackground("LootLogs/Ressources/search.tga")
    findIcon:SetMouseVisible(false)

    self.findBtn.MouseEnter = function() self.findBtn:SetBackColor(_G.Theme.HOVER) end
    self.findBtn.MouseLeave = function() self.findBtn:SetBackColor(_G.Theme.FRAME) end
    self.findBtn.MouseClick = function() self:ShowSearch(true) end

    -- frame/inner, the anatomy the chips it replaces already use
    self.searchFrame = Turbine.UI.Control()
    self.searchFrame:SetParent(self.client)
    self.searchFrame:SetBackColor(_G.Theme.FRAME)
    self.searchFrame:SetVisible(false)
    self.searchFrame:SetMouseVisible(false)

    self.searchBg = Turbine.UI.Control()
    self.searchBg:SetParent(self.searchFrame)
    self.searchBg:SetBackColor(_G.Theme.BG)
    self.searchBg:SetMouseVisible(false)

    self.searchIcon = Turbine.UI.Control()
    self.searchIcon:SetParent(self.searchBg)
    self.searchIcon:SetSize(ICON, ICON)
    self.searchIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.searchIcon:SetBackground("LootLogs/Ressources/search.tga")
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

    -- Closing clears. A filter still running behind a folded-away field would read as a chest
    -- that lost half its loot for no reason.
    self.searchClear = Turbine.UI.Control()
    self.searchClear:SetParent(self.searchBg)
    self.searchClear:SetSize(FIND, FIND)
    self.searchClear:SetBackColor(_G.Theme.BG)
    self.searchClear:SetMouseVisible(true)

    local clearIcon = Turbine.UI.Control()
    clearIcon:SetParent(self.searchClear)
    clearIcon:SetSize(ICON, ICON)
    clearIcon:SetPosition(math.floor((FIND - ICON) / 2), math.floor((FIND - ICON) / 2))
    clearIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    clearIcon:SetBackground("LootLogs/Ressources/cross.tga")
    clearIcon:SetMouseVisible(false)

    self.searchClear.MouseEnter = function() self.searchClear:SetBackColor(_G.Theme.FRAME) end
    self.searchClear.MouseLeave = function() self.searchClear:SetBackColor(_G.Theme.BG) end
    self.searchClear.MouseClick = function() self:ShowSearch(false) end

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
            -- Escape backs out one step at a time: the filter first, the window only once
            -- there is no filter left to lose. Closing on the first press would take the
            -- window away from someone who only wanted their search back.
            if self.searchOpen then
                self:ShowSearch(false)
            else
                self:CloseWindow()
            end
        end
    end

    self:SetVisible(false)

end

-- ------------------------------------------------------------------------------------------------

-- Every _G.Events entry for this instance at this tier, in boss order. Generated, never listed.
function _G.LootPopup:BossEvents(instance, tier)

    local list = {}

    for _, eventIndex in ipairs(_G.EventIndex.ForInstance(instance)) do
        local event = _G.Events[eventIndex]
        if event.tier == tier then
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

    -- A NEW CHEST ARRIVES UNSEARCHED. The filter belongs to the chest you were reading, and
    -- carrying it into the next one would open the window on an empty list -- looking, from
    -- where the player sits, exactly like a chest that dropped nothing.
    self:ShowSearch(false)

    self:Rebuild()
    self:SetVisible(true)
    self:Activate()

end

-- ------------------------------------------------------------------------------------------------
-- search

-- Typing does not rebuild the item list, only re-filters it -- but the popup's rows ARE rebuilt
-- per keystroke, which is cheap here in a way it is not in the browser: a chest holds a dozen
-- rows, not a few hundred, and they are reused rather than made again.
function _G.LootPopup:SetSearch(text)

    text = text or ""
    if text == self.searchText then return end

    self.searchText = text
    self.search     = string.lower(text)

    if self.searchBox:GetText() ~= text then self.searchBox:SetText(text) end

    self.searchHint:SetVisible(self.search == "")

    self:Rebuild()

end

-- Opening swaps the chip strip for the field; closing swaps it back AND clears, so the rows
-- always match what the field says is filtering them.
function _G.LootPopup:ShowSearch(open)

    self.searchOpen = open

    self.searchFrame:SetVisible(open)
    self.findBtn:SetVisible(not open)
    self.chipStrip:SetVisible(not open)

    if not open then

        -- Cleared HERE rather than through SetSearch, so the SetText below finds the state
        -- already settled: its TextChanged arrives as a no-op instead of a second rebuild.
        self.searchText = ""
        self.search     = ""
        self.searchHint:SetVisible(true)

        if self.searchBox:GetText() ~= "" then self.searchBox:SetText("") end

    elseif self.searchBox.Focus ~= nil then
        -- clicking the magnifier should leave the caret in the field, not one click away
        self.searchBox:Focus()
    end

    -- The field is one chip row tall whatever the chips wrapped to, so opening it can change
    -- the height of everything below -- and SetSearch only rebuilds when the TEXT changed,
    -- which it has not when the field opens empty.
    if self.chest ~= nil then self:Rebuild() end

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

-- The chips of the current instance, LAID OUT IN A FLOW THAT WRAPS, with the magnifier as the
-- last thing in it.
--
-- The button used to be pinned to the right-hand end of the row, which is fine right up until
-- the chips reach it -- and then it sits on top of "Full run", because a Turbine child is not
-- clipped to its parent and a strip that was told it is narrower simply overflows. Six chests
-- and a long instance name will do it at any width, so the flow has to be real: chips wrap onto
-- another line, the magnifier follows the last of them, and the window is told how tall the
-- whole thing came out (self.chipsH).
--
-- `width` is the window's, passed in rather than read back: on the first Rebuild nothing has
-- been laid out yet, and chips measured against a stale width wrap in the wrong places.
function _G.LootPopup:BuildChips(width)

    for _, chip in ipairs(self.chips) do
        chip:SetParent(nil)
    end
    self.chips  = {}
    self.chipsH = CHIP_H

    if self.chest == nil then return end

    local inner  = math.max(0, width - 2 * PAD)
    local x, y   = 0, 0

    -- Wrap BEFORE placing, never after: a chip that has already been positioned past the edge
    -- has drawn there for one frame, and moving it back is a flicker.
    local function place(chipWidth)
        if x > 0 and x + chipWidth > inner then
            x = 0
            y = y + CHIP_H + CHIP_GAP
        end
        local at = x
        x = x + chipWidth + CHIP_GAP
        return at, y
    end

    local function add(text, selected, dimmed, onClick)
        local chip    = self:MakeChip(text, selected, dimmed, onClick)
        local at, top = place(chip:GetWidth())
        chip:SetPosition(at, top)
        self.chips[#self.chips + 1] = chip
    end

    -- WHAT EACH CHEST GAVE, on the chip. A row of bare boss names says only which chests exist,
    -- which the instance already told you; the counts are what make a chip worth pressing --
    -- and what makes "Run" worth pressing at all.
    --
    -- Counted through SelectedItems, so a chip and the list it opens can never disagree: it is
    -- the same filter, the same grouping and the same items.
    for _, entry in ipairs(self:BossEvents(self.chest.instance, self.chest.tier)) do
        local index = entry.index
        local count = #self:SelectedItems(index)
        -- A boss with nothing recorded still shows, dimmed and clickable, at "· 0": selecting
        -- it and getting the empty state is information, where a missing chip is a question.
        add(entry.event.name .. _G.Sep .. count, self.selected == index,
            not self:HasChest(index), function()
                self.selected = index
                self:Rebuild()
            end)
    end

    -- Asked of the whole run rather than added up: a tracery taken from two chests by the same
    -- person is one row here and two there, so the sum would promise items the list does not
    -- have.
    add(_G.L("run") .. _G.Sep .. #self:SelectedItems("full"), self.selected == "full", false,
        function()
            self.selected = "full"
            self:Rebuild()
        end)

    -- the magnifier is the last chip in the flow, and wraps with them. It is parented to the
    -- client rather than the strip, so that it survives the strip being hidden for the search.
    local at, top = place(FIND)

    self.findAt  = { x = at, y = top + math.floor((CHIP_H - FIND) / 2) }
    self.chipsH  = y + CHIP_H

end

-- The loot to show for ONE selection, ordered by _G.LootDrops.SortLoot: wishlisted first, then
-- by kind -- jewellery, armour, currency, tracery, rune -- then A-Z.
--
-- The ORDER is that function's, not this one's, and deliberately: it is a rule about what the
-- items are, it is the same question the browser asks, and it is tested. This one only decides
-- WHICH items there are.
--
-- `selection` defaults to what is on screen. It is a parameter because the CHIPS ask the same
-- question about chests that are not selected -- a chip saying "· 6" and a list showing four
-- would be worse than no count at all, so both come out of one function.
function _G.LootPopup:SelectedItems(selection)

    local items = {}
    local run   = _G.LootDrops and _G.LootDrops.currentRun

    selection = selection or self.selected

    if run == nil then return items end

    -- ONE LINE PER DROP, under the name chat printed. Nothing is folded together here: what a
    -- person looted is an event, and two of them are two lines even where the drops data would
    -- call them the same kind of thing. The folding that does happen -- an item's several pool
    -- rates into one figure -- is in the catalogue, not in what was looted.
    for _, chest in ipairs(run.chests) do
        if selection == "full" or chest.logIndex == selection then
            for _, item in ipairs(chest.items) do
                -- only what the drops data flagged as worth interrupting for; the rest was
                -- still recorded, it just does not belong in a window that pops up unbidden
                if _G.LootDrops.IsPopupItem(chest.logIndex, item.base) then
                    items[#items + 1] = { item = item, logIndex = chest.logIndex }
                end
            end
        end
    end

    return _G.LootDrops.SortLoot(items)

end

-- One section heading: a label and a rule running out to the right, the same anatomy the main
-- window's group headings use (UI/Window/ContentView.lua, MakeGroupHeaderRow).
--
-- POOLED, like the rows beside it. A window that rebuilt its headings on every chest would pile
-- up orphaned controls for as long as the session lasts, because Turbine has no destructor --
-- only reparenting, which is what ClearItems does to these.
function _G.LootPopup:SectionHeader(index, text, labelColor, ruleColor)

    local header = self.headers[index]

    if header == nil then

        header = Turbine.UI.Control()
        header:SetHeight(SECTION_H)
        header:SetMouseVisible(false)

        local label = Turbine.UI.Label()
        label:SetParent(header)
        label:SetMultiline(false)
        -- clears the 2px rule an item row draws down its left edge, so the heading starts
        -- where the rows do rather than in front of them
        label:SetPosition(2, 0)
        label:SetHeight(SECTION_H)
        label:SetFont(_G.Font(10))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        label:SetMouseVisible(false)

        local rule = Turbine.UI.Control()
        rule:SetParent(header)
        rule:SetHeight(SEP_W)
        rule:SetMouseVisible(false)

        header.label = label
        header.rule  = rule

        -- named for the same reason the browser's rows are: a control whose width already
        -- matches the list never fires SizeChanged, and then nothing has placed the rule
        header.Layout = function()
            local labelW = math.floor(#(header.text or "") * _G.GlyphWidth(10) * 2) + _G.Scaled(8)
            label:SetWidth(labelW)
            rule:SetPosition(2 + labelW + math.floor(GAP / 2), math.floor(SECTION_H / 2))
            rule:SetWidth(math.max(0,
                header:GetWidth() - 2 - labelW - math.floor(GAP / 2)))
        end

        header.SizeChanged = header.Layout

        self.headers[index] = header

    end

    header.text = text
    header.label:SetText(_G.Spaced(_G.Upper(text)))
    header.label:SetForeColor(labelColor)
    header.rule:SetBackColor(ruleColor)

    return header

end

-- THE THREE BLOCKS, dressed. Which item goes where is _G.LootDrops.PartitionLoot's rule and is
-- tested there; this only says what each block is called and what colour it takes.
--
-- The two chip pairs are one warm and one cool in every theme, so STARRED and YOURS cannot be
-- confused with each other whichever theme is on, and FELLOWSHIP takes the quietest rule of the
-- three because it is the block you are not reading.
function _G.LootPopup:Partition(items)

    local starred, yours, fellowship = _G.LootDrops.PartitionLoot(items)

    return {
        { key = "sectionStarred",    label = _G.Theme.CHIP_USED_TEXT,
                                     rule  = _G.Theme.CHIP_USED_FRAME, items = starred },
        { key = "sectionYours",      label = _G.Theme.ACCENT,
                                     rule  = _G.Theme.FRAME,           items = yours },
        { key = "sectionFellowship", label = _G.Theme.DIM,
                                     rule  = _G.Theme.CHIP_DONE_FRAME, items = fellowship },
    }

end

function _G.LootPopup:Rebuild()

    if self.chest == nil then return end

    -- BOSS FIRST, because that is what the window is about: a chest opened, and this is what
    -- was in it. The instance and the tier are context and take the dim.
    local instance = _G.Instances[self.chest.instance]
    local event    = (self.selected ~= "full") and _G.Events[self.selected] or nil
    local context  = (instance and instance.name or "?") .. _G.Sep .. tostring(self.chest.tier)

    if event ~= nil then
        self:SetTitleText(event.name .. _G.CM("DIM") .. _G.Sep .. context .. _G.CMR)
    else
        self:SetTitleText(_G.L("fullRun") .. _G.CM("DIM") .. _G.Sep .. context .. _G.CMR)
    end

    -- the chips are measured against the width the window HAS, which is the player's once they
    -- have dragged the gripper
    self:BuildChips(self:Width())

    local items = self:SelectedItems()
    local total = #items

    -- The search narrows what is ON SCREEN, never what was recorded: the chest keeps its items
    -- and the footer keeps saying how many, so a filter can never look like lost loot.
    items = _G.LootDrops.FilterLoot(items, self.search)

    self.rowCount = #items

    local sections = self:Partition(items)

    -- Settled BEFORE anything is measured: a heading only exists where its block has something
    -- in it -- an empty "FELLOWSHIP" over nothing is a rule and a word saying "nothing here" --
    -- and how many there are decides how tall the window is about to be.
    self.headersH = 0
    for _, section in ipairs(sections) do
        if #section.items > 0 then
            self.headersH = self.headersH + SECTION_H
        end
    end

    -- The width the rows will have, computed rather than read back off rowHost: on the first
    -- Rebuild the host has not been laid out yet, and a row sized from it would cut its name
    -- to fit a width that no longer exists a moment later. Whether the scrollbar is there
    -- changes that width, and the rows are built before the window is laid out -- so Geometry
    -- answers both from the size the window is ABOUT to have.
    local _, _, rowWidth = self:Geometry(#items)

    -- Rows are reused, not rebuilt: Turbine has no destructor, so rebuilding on every chest
    -- would pile up orphaned controls for as long as the session lasts. ClearItems only lets
    -- go of them; the same objects go straight back in.
    self.rowHost:ClearItems()

    local rowIndex, headerIndex = 0, 0

    for _, section in ipairs(sections) do
        if #section.items > 0 then

            headerIndex = headerIndex + 1

            local header = self:SectionHeader(headerIndex, _G.L(section.key),
                section.label, section.rule)

            header:SetSize(rowWidth, SECTION_H)
            self.rowHost:AddItem(header)
            header:SetWidth(rowWidth)
            header.Layout()

            for _, entry in ipairs(section.items) do

                rowIndex = rowIndex + 1

                local row = self.rows[rowIndex]
                if row == nil then
                    row = _G.LootRow(self.rowHost)
                    self.rows[rowIndex] = row
                end

                row:SetVisible(true)
                row:SetSize(rowWidth, ROW_H)
                self.rowHost:AddItem(row)

                -- after AddItem, because the list may have resized the row -- and the width is
                -- what the name is truncated against
                row:SetWidth(rowWidth)
                row:SetLoot(entry.item, _G.LootDrops.DropRow(entry.logIndex, entry.item.base),
                    entry.logIndex)

            end

        end
    end

    -- rows and headings past the end are simply not in the list any more, so nothing draws them

    local mine = 0
    for _, entry in ipairs(items) do
        if entry.item.isSelf then mine = mine + 1 end
    end

    local starred = #sections[1].items

    -- A chest with no matched loot must still show. Silence reads as a broken plugin -- and an
    -- empty list has two quite different meanings, so it says which one this is.
    self.emptyLabel:SetVisible(#items == 0)
    self.emptyLabel:SetText(self.search ~= "" and _G.L("noSearchMatch") or _G.L("noLootYet"))

    -- "3/12 items" while filtering: the count you are looking at, and the count that dropped.
    local count = (self.search ~= "") and (#items .. "/" .. total) or tostring(#items)

    self.footLabel:SetText(count .. " "
        .. (#items == 1 and self.search == "" and _G.L("itemsOne") or _G.L("items"))
        .. _G.Sep .. mine .. " " .. _G.L("yours")
        .. _G.Sep .. starred .. " " .. _G.L("starred"))

    self:Layout(#items)

end

-- The width the window has: the player's if they have ever dragged the gripper, else the
-- default. Read from settings rather than from the control, because Rebuild has to know it
-- before anything has been laid out.
function _G.LootPopup:Width()
    return (_G.Settings.lootPopup or {}).width or POPUP_W
end

-- How tall the chip area is right now. One row while the search field is standing in for it,
-- however many rows the chips wrapped into otherwise.
function _G.LootPopup:ChipsHeight()
    return self.searchOpen and CHIP_H or (self.chipsH or CHIP_H)
end

-- What size the window should be, and what that leaves for the rows. One answer, asked by both
-- Rebuild (which needs the row width before it builds any) and Layout (which applies it).
--
-- THE PLAYER'S SIZE WINS. Until the gripper is dragged there is none, and the window sizes
-- itself to its rows up to MAX_ROWS, which is the restraint that keeps something opening
-- unbidden from being the biggest thing on the screen. Once there is one, it is theirs: a window
-- that resized itself back on the next chest would make the gripper a lie.
function _G.LootPopup:Geometry(rowCount)

    local settings = _G.Settings.lootPopup or {}

    local chrome = TITLE_H + SEP_W
                 + PAD + self:ChipsHeight() + GAP
                 + GAP + SEP_W + FOOT_H + PAD

    local headersH = self.headersH or 0

    local width  = settings.width or POPUP_W
    local height = settings.height

    if height == nil then
        -- MAX_ROWS COUNTS ROWS, NOT HEADINGS. The ceiling exists so a window that opens
        -- unbidden is never the biggest thing on the screen, and three 18px rules are not what
        -- would threaten that -- capping them instead would cost a chest two of its items to
        -- pay for the words naming them.
        local shown = math.max(math.min(rowCount, MAX_ROWS), MIN_ROWS)
        height = chrome + headersH + shown * ROW_H
    end

    -- A saved height is whatever the player dragged it to, including too short for one row, and
    -- a chip row appearing or the search opening moves the chrome under it either way. The
    -- headings live INSIDE the list, so they take their height out of what the rows have.
    local rowsH     = math.max(0, height - chrome)
    local scrolling = rowCount * ROW_H + headersH > rowsH
    local inner     = math.max(0, width - 2 * PAD)
    local rowsW     = math.max(0, inner - (scrolling and (SCROLL_W + math.floor(GAP / 2)) or 0))

    return width, height, rowsW, rowsH, scrolling

end

-- The scrollbar only appears when it is needed -- a permanent one on a three-row popup is a bar
-- of furniture doing nothing.
function _G.LootPopup:Layout(rowCount)

    rowCount = rowCount or 0

    local width, height, _, _, scrolling = self:Geometry(rowCount)

    self.scrolling = scrolling
    self.rowScroll:SetVisible(scrolling)

    self:SetSize(width, height)

    -- A window ALREADY at that size fires no SizeChanged, and then nothing has positioned the
    -- chips this rebuild just moved -- the same trap AddRow works around in the browser. The
    -- client is what OnLayout is measured in, and PanelWindow owns its size, so it is asked
    -- rather than recomputed.
    if self.client ~= nil then
        self:OnLayout(self.client:GetWidth(), self.client:GetHeight())
    end

end

function _G.LootPopup:OnLayout(width, height)

    if self.chipStrip == nil then return end

    local inner = math.max(0, width - 2 * PAD)

    -- The chip area is as tall as the chips wrapped to, and the magnifier is wherever the flow
    -- left it -- both settled in BuildChips, because both depend on the chips' own widths.
    local chipsH = self:ChipsHeight()
    local findAt = self.findAt or { x = math.max(0, inner - FIND), y = 0 }

    self.chipStrip:SetPosition(PAD, PAD)
    self.chipStrip:SetSize(inner, chipsH)

    self.findBtn:SetPosition(PAD + findAt.x, PAD + findAt.y)

    -- open, the field takes the whole row: the chips are not there to make room for
    self.searchFrame:SetPosition(PAD, PAD)
    self.searchFrame:SetSize(inner, CHIP_H)
    self.searchBg:SetPosition(1, 1)
    self.searchBg:SetSize(math.max(0, inner - 2), math.max(0, CHIP_H - 2))

    local fieldH = math.max(0, CHIP_H - 2)
    local textX  = 2 + ICON + math.floor(GAP / 2)

    self.searchIcon:SetPosition(2, math.floor((fieldH - ICON) / 2))
    self.searchClear:SetPosition(math.max(0, inner - 2 - FIND),
        math.floor((fieldH - FIND) / 2))

    local textW = math.max(0, inner - 2 - FIND - textX - math.floor(GAP / 2))

    self.searchBox:SetPosition(textX, 0)
    self.searchBox:SetSize(textW, fieldH)
    self.searchHint:SetPosition(textX + 2, 0)
    self.searchHint:SetSize(textW, fieldH)

    local rowTop  = PAD + chipsH + GAP
    local footTop = height - PAD - FOOT_H

    local rowsH  = math.max(0, footTop - GAP - SEP_W - rowTop)

    -- DECIDED FROM THE HEIGHT THE WINDOW ACTUALLY HAS, not from the row count: this runs on
    -- every frame of a gripper drag, and the bar has to appear the moment the rows stop fitting
    -- rather than at the next rebuild.
    self.scrolling = (self.rowCount or 0) * ROW_H + (self.headersH or 0) > rowsH
    self.rowScroll:SetVisible(self.scrolling)

    -- the scrollbar takes its width out of the rows, so a name is never cut by the bar
    local rowsW  = math.max(0, inner
        - (self.scrolling and (SCROLL_W + math.floor(GAP / 2)) or 0))

    self.rowHost:SetPosition(PAD, rowTop)
    self.rowHost:SetSize(rowsW, rowsH)

    self.rowScroll:SetPosition(PAD + rowsW + math.floor(GAP / 2), rowTop)
    self.rowScroll:SetSize(SCROLL_W, rowsH)

    for _, row in ipairs(self.rows) do
        row:SetWidth(rowsW)
    end

    -- the headings' rules run to the right edge, so they are re-driven rather than left to a
    -- SizeChanged a control already at that width never fires
    for _, header in ipairs(self.headers) do
        header:SetWidth(rowsW)
        header.Layout()
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

-- Dragging the gripper is the player saying what size this window is, and it is remembered from
-- then on -- including the height, which is what switches the automatic sizing off. Rebuilt
-- afterwards, because the chips may now wrap differently and every name is truncated against a
-- width that just changed.
function _G.LootPopup:OnResized()

    local width, height = self:GetSize()

    if _G.Settings.lootPopup == nil then _G.Settings.lootPopup = {} end
    _G.Settings.lootPopup.width  = width
    _G.Settings.lootPopup.height = height
    _G.SaveSettings()

    self:Rebuild()

end

function _G.LootPopup:PositionChanged()

    -- the drag itself saves once on mouse-up, via OnMoved
    if not self._dragging then
        self:OnMoved()
    end

end
