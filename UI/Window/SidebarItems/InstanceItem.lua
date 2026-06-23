
InstanceItem = class(Turbine.UI.Control)
function InstanceItem:Constructor(id, instance, sidebar)
	Turbine.UI.Control.Constructor( self )

    self.id       = id
    self.instance = instance
    self.name     = instance.name
    self.sidebar  = sidebar
    self.hover    = false

    self:Build()
    self:ApplySettings()

end

function InstanceItem:SetSelected(value)

    if value then
        self.background1:SetBackColor(_G.Theme.SEL_BG)
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
    else
        self.background1:SetBackColor(_G.Theme.BG)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
    end

end

function InstanceItem:Clicked()
    self.sidebar:InstanceSelected(self)
end

function InstanceItem:SizeChanged()

    if not self.frame1 then return end
    local width = self:GetWidth()

    self.frame1:SetWidth(width - 24)
    self.background1:SetWidth(width - 26)
    self.nameLabel:SetWidth(width - 56)

end

function InstanceItem:ApplySettings() end

function InstanceItem:Build()

    self:SetMouseVisible(false)
    self:SetHeight(44)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetPosition(12, 3)
    self.frame1:SetParent(self)
    self.frame1:SetBackColor(_G.Theme.FRAME)
    self.frame1:SetHeight(38)

    self.background1 = Turbine.UI.Control()
    self.background1:SetPosition(1, 1)
    self.background1:SetParent(self.frame1)
    self.background1:SetBackColor(_G.Theme.BG)
    self.background1:SetHeight(36)
    self.background1.MouseEnter = function()
        self.hover = true
        self.frame1:SetBackColor(_G.Theme.HOVER)
    end
    self.background1.MouseLeave = function()
        self.hover = false
        self.frame1:SetBackColor(_G.Theme.FRAME)
    end
    self.background1.MouseDown = function()
        self.background1:SetBackColor(_G.Theme.PRESS)
    end
    self.background1.MouseUp = function()
        self.background1:SetBackColor(_G.Theme.BG)
        if self.hover then self:Clicked() end
    end

    self.classIcon = Turbine.UI.Control()
    self.classIcon:SetParent(self.background1)
    self.classIcon:SetPosition(4, 8)
    self.classIcon:SetSize(20, 20)
    self.classIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.classIcon:SetBackground(_G.ClassIcons[self.instance.class])

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetParent(self.background1)
    self.nameLabel:SetHeight(36)
    self.nameLabel:SetLeft(30)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.nameLabel:SetMultiline(true)
    self.nameLabel:SetText(self.name)
    self.nameLabel:SetMouseVisible(false)
    self.nameLabel:SetForeColor(_G.Theme.TEXT)

end
