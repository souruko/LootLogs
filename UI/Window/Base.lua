import "LootLogs2.UI.Window.Settings"
import "LootLogs2.UI.Window.Sidebar"
import "LootLogs2.UI.Window.ContentView"

_G.LLWindow = class(Turbine.UI.Lotro.Window)
-- window constructor --------------------------------------------------------------------------
function _G.LLWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self )

    self.windowSettings = _G.Settings.window
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
    self.settings:SetPosition(10, 35)
    

    self:SetPosition(self.windowSettings.left, self.windowSettings.top)
    self:SetSize(self.windowSettings.width, self.windowSettings.height)

    self:SetVisible(true)

end

function _G.LLWindow:SelectionChanged()

    self.contentView:UpdateContent()
    
end

function _G.LLWindow:SizeChanged()

    local width, height = self:GetSize()

    -- update settings
    self.windowSettings.width = width
    self.windowSettings.height = height
    _G.SaveSettings()

    -- update children
    self.sidebar:SetHeight(height - 45)
    self.contentView:SetSize(width - 325, height - 45)
    self.settings:SetSize(width - 20, height - 45)

end

function _G.LLWindow:PositionChanged()

    local left, top = self:GetPosition()

    -- update settings
    self.windowSettings.left = left
    self.windowSettings.top = top
    _G.SaveSettings()

end
