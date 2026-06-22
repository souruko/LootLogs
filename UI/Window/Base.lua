import "LootLogs2.UI.Window.Settings"
import "LootLogs2.UI.Window.Sidebar"
import "LootLogs2.UI.Window.ContentView"
import "LootLogs2.UI.Window.ServerSelect"

local DAY_NAMES = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }

_G.LLWindow = class(Turbine.UI.Lotro.Window)
-- window constructor --------------------------------------------------------------------------
function _G.LLWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self )

    self.windowSettings  = _G.Settings.window
    self.settingsVisible = false

    self:SetText("LootLogs")
    self:SetResizable(true)
    self:SetMinimumSize(1000, 200)

    self.sidebar = Sidebar()
    self.sidebar:SetParent(self)
    self.sidebar:SetPosition(10, 35)
    self.sidebar:SetWidth(300)

    self.contentView = ContentView()
    self.contentView:SetParent(self)
    self.contentView:SetPosition(315, 35)

    self.settings = Settings()
    self.settings:SetParent(self)
    self.settings:SetPosition(315, 35)

    -- footer bar (below sidebar) --------------------------------------------------------------
    self.footer = Turbine.UI.Control()
    self.footer:SetParent(self)
    self.footer:SetSize(300, 28)
    self.footer:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.12))

    -- settings button (left side)
    self.settingsBtn = Turbine.UI.Control()
    self.settingsBtn:SetParent(self.footer)
    self.settingsBtn:SetPosition(0, 0)
    self.settingsBtn:SetSize(28, 28)
    self.settingsBtn:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))

    self.settingsBg = Turbine.UI.Control()
    self.settingsBg:SetParent(self.settingsBtn)
    self.settingsBg:SetPosition(1, 1)
    self.settingsBg:SetSize(26, 26)
    self.settingsBg:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.settingsBg:SetMouseVisible(false)

    self.settingsIcon = Turbine.UI.Control()
    self.settingsIcon:SetParent(self.settingsBg)
    self.settingsIcon:SetSize(26, 26)
    self.settingsIcon:SetPosition(-1, -1)
    self.settingsIcon:SetBackground("LootLogs2/Ressources/settings.tga")
    self.settingsIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.settingsIcon:SetMouseVisible(false)

    local btnHover = false
    self.settingsBtn.MouseEnter = function()
        btnHover = true
        self.settingsBtn:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.settingsBtn.MouseLeave = function()
        btnHover = false
        self.settingsBtn:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    end
    self.settingsBtn.MouseDown = function()
        self.settingsBg:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
    end
    self.settingsBtn.MouseUp = function()
        self.settingsBg:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        if btnHover then
            self:ToggleSettings()
        end
    end

    -- quickslot (between settings button and clock)
    _G.LootLogs_Shortcut = _G.L("quickslotCmd")
    self.quickslot = Turbine.UI.Lotro.Quickslot()
    self.quickslot:SetParent(self.footer)
    self.quickslot:SetPosition(32, -2)
    self.quickslot:SetSize(29, 29)
    self.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, _G.LootLogs_Shortcut))

    -- clock (right side, with dark background panel)
    self.clockBg = Turbine.UI.Control()
    self.clockBg:SetParent(self.footer)
    self.clockBg:SetPosition(65, 5)
    self.clockBg:SetSize(230, 17)
    self.clockBg:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.clockBg:SetMouseVisible(false)

    self.clockLabel = Turbine.UI.Label()
    self.clockLabel:SetParent(self.footer)
    self.clockLabel:SetPosition(61, 0)
    self.clockLabel:SetHeight(28)
    self.clockLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.clockLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.clockLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.clockLabel:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    self.clockLabel:SetMouseVisible(false)

    -- clock ticker (fires every game tick, updates label when minute changes)
    local win        = self
    local lastMinute = -1
    self.clockUpdater = Turbine.UI.Control()
    self.clockUpdater.Update = function()
        local date = Turbine.Engine.GetDate()
        if date.Minute ~= lastMinute then
            lastMinute = date.Minute
            win:UpdateClock()
        end
    end

    -- position and size
    self:SetPosition(self.windowSettings.left, self.windowSettings.top)
    self:SetSize(self.windowSettings.width, self.windowSettings.height)

    self.clockUpdater:SetWantsUpdates(true)
    self.contentView:UpdateContent()

    self.KeyDown = function(sender, args)
        if args.Action == Turbine.UI.Lotro.Action.Escape then
            self:SetVisible(false)
        end
    end

    self:SetWantsKeyEvents(true)

    if _G.Server == nil then
        self.serverSelectPopup = ServerSelectPopup(function()
            self.sidebar:RefreshItems()
        end)
    end

end

-- ------------------------------------------------------------------------------------------------

function _G.LLWindow:UpdateClock()

    local date    = Turbine.Engine.GetDate()
    local dayName = DAY_NAMES[date.DayOfWeek] or ""
    self.clockLabel:SetText(string.format(
        "%s, %02d.%02d.%04d  %02d:%02d",
        dayName, date.Day, date.Month, date.Year, date.Hour, date.Minute
    ))

end

function _G.LLWindow:ToggleSettings()

    self.settingsVisible = not self.settingsVisible
    self.settings:SetVisible(self.settingsVisible)
    self.contentView:SetVisible(not self.settingsVisible)

    if self.settingsVisible then
        -- self.settingsIcon:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    else
        -- self.settingsIcon:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    end

end

-- ------------------------------------------------------------------------------------------------

function _G.LLWindow:SelectionChanged()

    self.contentView:UpdateContent()

end

function _G.LLWindow:SizeChanged()

    local width, height = self:GetSize()

    self.windowSettings.width = width
    self.windowSettings.height = height
    _G.SaveSettings()

    -- sidebar (shorter to leave room for footer)
    self.sidebar:SetHeight(height - 78)

    -- footer (28px, 2px gap below sidebar, 10px bottom margin)
    self.footer:SetPosition(10, height - 38)
    self.footer:SetWidth(300)
    self.settingsBtn:SetLeft(0)
    self.clockBg:SetLeft(67)
    self.clockBg:SetWidth(228)
    self.clockLabel:SetLeft(68)
    self.clockLabel:SetWidth(226)

    -- content / settings panels (full height)
    self.contentView:SetSize(width - 325, height - 45)
    self.settings:SetSize(width - 325, height - 45)

end

function _G.LLWindow:PositionChanged()

    local left, top = self:GetPosition()

    self.windowSettings.left = left
    self.windowSettings.top  = top
    _G.SaveSettings()

end
