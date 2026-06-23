
ServerSelectPopup = class(Turbine.UI.Lotro.Window)

function ServerSelectPopup:Constructor(onSelect)
    Turbine.UI.Lotro.Window.Constructor(self)

    self.onSelect = onSelect

    self:SetText("Select Server")
    self:SetResizable(false)

    local popupWidth  = 300
    local popupHeight = 410

    local winLeft = _G.Settings.window.left + math.floor((_G.Settings.window.width  - popupWidth)  / 2)
    local winTop  = _G.Settings.window.top  + math.floor((_G.Settings.window.height - popupHeight) / 2)
    self:SetPosition(winLeft, winTop)
    self:SetSize(popupWidth, popupHeight)

    self:Build()

    self:SetVisible(true)

end

function ServerSelectPopup:Build()

    self.prompt = Turbine.UI.Label()
    self.prompt:SetParent(self)
    self.prompt:SetPosition(10, 36)
    self.prompt:SetSize(280, 28)
    self.prompt:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.prompt:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    self.prompt:SetFontStyle(_G.Theme.FONT_STYLE)
    self.prompt:SetForeColor(_G.Theme.TEXT)
    self.prompt:SetText("Which server are you currently on?")

    for i, serverName in ipairs(_G.Servers) do

        local top = 72 + (i - 1) * 38

        local frame = Turbine.UI.Control()
        frame:SetParent(self)
        frame:SetPosition(10, top)
        frame:SetSize(280, 36)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(278, 34)
        bg:SetBackColor(_G.Theme.BG)

        local label = Turbine.UI.Label()
        label:SetParent(bg)
        label:SetSize(278, 34)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.TEXT)
        label:SetText(serverName)
        label:SetMouseVisible(false)

        local hover = false

        bg.MouseEnter = function()
            hover = true
            frame:SetBackColor(_G.Theme.HOVER)
        end
        bg.MouseLeave = function()
            hover = false
            frame:SetBackColor(_G.Theme.FRAME)
        end
        bg.MouseDown = function()
            bg:SetBackColor(_G.Theme.PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(_G.Theme.BG)
            if hover then
                self:SelectServer(serverName)
            end
        end

    end

end

function ServerSelectPopup:SelectServer(serverName)

    _G.Server = serverName
    _G.SaveServer()

    _G.Logs[_G.characterId].server = serverName
    _G.SaveLogs()

    self:SetVisible(false)

    if self.onSelect then
        self.onSelect(serverName)
    end

end
