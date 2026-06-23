
CharacterItem = class(Turbine.UI.Control)
function CharacterItem:Constructor(id, character, sidebar)
	Turbine.UI.Control.Constructor( self )

    self.id        = id
    self.character = character
    self.name      = character.name
    self.sidebar   = sidebar
    self.hover     = false

    self:Build()
    self:ApplySettings()

end

function CharacterItem:SetSelected(value)

    if value then
        self.background1:SetBackColor(_G.Theme.SEL_BG)
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
        self.levelLabel:SetForeColor(_G.Theme.TEXT)
    else
        self.background1:SetBackColor(_G.Theme.BG)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
        self.levelLabel:SetForeColor(_G.Theme.DIM)
    end

end

function CharacterItem:Clicked()
    self.sidebar:CharacterSelected(self)
end

function CharacterItem:SizeChanged()

    if not self.frame1 then return end
    local width = self:GetWidth()

    self.frame1:SetWidth(width - 24)
    self.background1:SetWidth(width - 26)
    self.nameLabel:SetWidth(width - 108)
    self.levelLabel:SetLeft(width - 74)
    self.levelLabel:SetWidth(44)

end

function CharacterItem:ApplySettings() end

function CharacterItem:Build()

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
    self.classIcon:SetBackground(_G.ClassIcons[self.character.class])

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

    self.levelLabel = Turbine.UI.Label()
    self.levelLabel:SetParent(self.background1)
    self.levelLabel:SetHeight(36)
    self.levelLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.levelLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.levelLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.levelLabel:SetText(self.character.level and ("Lv." .. self.character.level) or "")
    self.levelLabel:SetMouseVisible(false)
    self.levelLabel:SetForeColor(_G.Theme.DIM)

end
