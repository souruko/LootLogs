-- Main window: title bar + sidebar column + content panel.
--
-- Chrome (border, title bar, drag, close, resize) comes from PanelWindow.

import "LootLogs.UI.Window.PanelWindow"
import "LootLogs.UI.Window.Settings"
import "LootLogs.UI.Window.Sidebar"
import "LootLogs.UI.Window.ContentView"
import "LootLogs.UI.Window.ServerSelect"

-- body geometry (docs/design/window-redesign/README.md, section 1)
local SEP_W, PAD, GAP, BTN_SIZE, DIV_H, TITLE_H, SIDEBAR_W, LEGEND_H

local MIN_WIDTH  = 1000
local MIN_HEIGHT = 200

-- recomputed when the Font Size setting changes
local function Metrics()
    SEP_W      = 1
    BTN_SIZE   = 22
    DIV_H      = 16
    PAD        = _G.Scaled(8)
    GAP        = _G.Scaled(8)
    TITLE_H    = _G.Scaled(30)
    SIDEBAR_W  = _G.Scaled(262)
    LEGEND_H   = _G.Scaled(24)
end

_G.RegisterMetrics(Metrics)

_G.LLWindow = class(_G.PanelWindow)
-- window constructor --------------------------------------------------------------------------
function _G.LLWindow:Constructor()
	_G.PanelWindow.Constructor( self, {
        resizable  = true,
        min_width  = MIN_WIDTH,
        min_height = MIN_HEIGHT,
    })

    self.windowSettings  = _G.Settings.window
    self.settingsVisible = false

    self:RefreshTitle()

    -- title bar extras (left of the close button) ----------------------------------------------
    self.settingsBtn = self:MakeTitleButton("LootLogs/Ressources/settings.tga", function()
        self:ToggleSettings()
    end)

    self.lootBtn = self:MakeTitleButton("LootLogs/Ressources/loot.tga", function()
        if _G.LootBrowserWindow then
            _G.LootBrowserWindow:Toggle()
        end
    end)

    _G.LootLogs_Shortcut = _G.L("quickslotCmd")
    self.quickslot = Turbine.UI.Lotro.Quickslot()
    self.quickslot:SetParent(self.titlebar)
    self.quickslot:SetSize(BTN_SIZE, BTN_SIZE)
    self.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, _G.LootLogs_Shortcut))

    self.title_div = Turbine.UI.Control()
    self.title_div:SetParent(self.titlebar)
    self.title_div:SetSize(SEP_W, DIV_H)
    self.title_div:SetBackColor(_G.Theme.FRAME)
    self.title_div:SetMouseVisible(false)

    -- sidebar column ---------------------------------------------------------------------------
    self.sidebar = Sidebar()
    self.sidebar:SetParent(self.client)
    self.sidebar:SetWidth(SIDEBAR_W)

    -- legend strip under the sidebar (filled in with the per-tier squares in phase 3)
    self.sidebarLegend = Turbine.UI.Control()
    self.sidebarLegend:SetParent(self.client)
    self.sidebarLegend:SetBackColor(_G.Theme.FRAME)

    self.sidebarLegendBg = Turbine.UI.Control()
    self.sidebarLegendBg:SetParent(self.sidebarLegend)
    self.sidebarLegendBg:SetPosition(SEP_W, SEP_W)
    self.sidebarLegendBg:SetBackColor(_G.Theme.PANEL)
    self.sidebarLegendBg:SetMouseVisible(false)

    -- one sample of each square state, then what the bar means
    local sampleTop = math.floor((LEGEND_H - 2 * SEP_W - _G.TierSquare) / 2)
    for index, state in ipairs({ "used", "done", "empty" }) do
        local square = _G.MakeTierSquare(self.sidebarLegendBg)
        square:SetPosition(8 + (index - 1) * (_G.TierSquare + _G.TierSquareGap), sampleTop)
        _G.SetTierSquareState(square, state, _G.Theme.PANEL)
    end

    self.sidebarLegendLabel = Turbine.UI.Label()
    self.sidebarLegendLabel:SetMultiline(false)
    self.sidebarLegendLabel:SetParent(self.sidebarLegendBg)
    self.sidebarLegendLabel:SetPosition(8 + _G.TierSquaresWidth(3) + 8, 0)
    self.sidebarLegendLabel:SetHeight(LEGEND_H - 2 * SEP_W)
    self.sidebarLegendLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.sidebarLegendLabel:SetFont(_G.Font(10))
    self.sidebarLegendLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.sidebarLegendLabel:SetForeColor(_G.Theme.DIM)
    self.sidebarLegendLabel:SetText(_G.L("tierLegend"))
    self.sidebarLegendLabel:SetMouseVisible(false)

    -- content panel ----------------------------------------------------------------------------
    self.contentView = ContentView()
    self.contentView:SetParent(self.client)

    self.settings = Settings()
    self.settings:SetParent(self.client)

    -- position and size ------------------------------------------------------------------------
    self:SetPosition(self.windowSettings.left, self.windowSettings.top)
    self:SetSize(
        math.max(MIN_WIDTH,  self.windowSettings.width),
        math.max(MIN_HEIGHT, self.windowSettings.height)
    )

    self.contentView:UpdateContent()

    self:SetWantsKeyEvents(true)
    self.KeyDown = function(sender, args)
        if args.Action == Turbine.UI.Lotro.Action.Escape then
            self:CloseWindow()
        end
    end

    -- always start closed; the quick launch icon opens it
    self:SetVisible(false)

    if _G.Server == nil then
        self.serverSelectPopup = ServerSelectPopup(function()
            self.sidebar:RefreshItems()
        end)
    end

end

-- ------------------------------------------------------------------------------------------------

-- brand plus a dimmed version, the same title bar Gibberish3 draws
function _G.LLWindow:RefreshTitle()

    self:SetTitleText("LOOTLOGS  "
        .. _G.CM("DIM") .. (_G.LootLogsVersion or "") .. _G.CMR)

end

-- THE FLUSH POINT for the content view's deferred rebuilds. ProcessMatch updates the view on
-- every chest it records, and with the window closed that rebuild is invisible work on the
-- frame thread; the view banks it instead and this is where it is paid, at the moment it starts
-- to matter. Every path that opens the window goes through here.
function _G.LLWindow:SetVisible(visible)

    _G.PanelWindow.SetVisible(self, visible)

    if visible then
        if self.contentView ~= nil then self.contentView:FlushDeferred()   end
        if self.sidebar     ~= nil then self.sidebar:RefreshTierSquares()  end
    end

end

function _G.LLWindow:ToggleSettings()

    self.settingsVisible = not self.settingsVisible
    self.settings:SetVisible(self.settingsVisible)
    self.contentView:SetVisible(not self.settingsVisible)

    -- the view was hidden behind the settings panel, so it may have banked a rebuild too
    if not self.settingsVisible then
        self.contentView:FlushDeferred()
    end

end

function _G.LLWindow:SelectionChanged()

    self.contentView:UpdateContent()

end

-- ------------------------------------------------------------------------------------------------

function _G.LLWindow:OnLayout(width, height)

    if self.sidebar == nil then return end

    -- title bar extras, right to left from the close button
    local btn_top = math.floor((TITLE_H - BTN_SIZE) / 2)
    local x = self:TitleBarRight() - SEP_W
    self.title_div:SetPosition(x, math.floor((TITLE_H - DIV_H) / 2))
    x = x - GAP - BTN_SIZE
    self.quickslot:SetPosition(x, btn_top)
    x = x - GAP - BTN_SIZE
    self.settingsBtn:SetPosition(x, btn_top)
    x = x - GAP - BTN_SIZE
    self.lootBtn:SetPosition(x, btn_top)

    self.title_label:SetWidth(math.max(0, x - GAP - PAD))

    -- sidebar, with the legend strip pinned above the bottom margin
    local legendTop = height - PAD - LEGEND_H

    self.sidebar:SetPosition(PAD, PAD)
    self.sidebar:SetHeight(math.max(0, legendTop - GAP - PAD))

    self.sidebarLegend:SetPosition(PAD, legendTop)
    self.sidebarLegend:SetSize(SIDEBAR_W, LEGEND_H)
    self.sidebarLegendBg:SetSize(SIDEBAR_W - 2 * SEP_W, LEGEND_H - 2 * SEP_W)
    self.sidebarLegendLabel:SetWidth(math.max(0,
        SIDEBAR_W - 2 * SEP_W - self.sidebarLegendLabel:GetLeft() - 8))

    -- content / settings panels
    local contentLeft = PAD + SIDEBAR_W + GAP
    local contentW    = math.max(0, width - contentLeft - PAD)
    local contentH    = math.max(0, height - 2 * PAD)

    self.contentView:SetPosition(contentLeft, PAD)
    self.contentView:SetSize(contentW, contentH)

    self.settings:SetPosition(contentLeft, PAD)
    self.settings:SetSize(contentW, contentH)

end

-- ------------------------------------------------------------------------------------------------

function _G.LLWindow:OnMoved()

    local left, top = self:GetPosition()

    self.windowSettings.left = left
    self.windowSettings.top  = top
    _G.SaveSettings()

end

function _G.LLWindow:OnResized()

    local width, height = self:GetSize()

    self.windowSettings.width  = width
    self.windowSettings.height = height
    _G.SaveSettings()

end

function _G.LLWindow:PositionChanged()

    -- the drag itself saves once on mouse-up, via OnMoved
    if not self._dragging then
        self:OnMoved()
    end

end
