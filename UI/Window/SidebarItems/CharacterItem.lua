
-- One character row in the Characters tab: class portrait, name, level, and the
-- CURRENT tag on whoever is logged in.
--
-- The class icon is drawn at its native 20x20: Turbine clips a background instead of
-- scaling it, and stretching inside a ListBox that has a scrollbar draws the image
-- outside the list.

local ROW_H, INDENT, PAD_RIGHT, MARK_W, PORTRAIT, TAG_W, TAG_H, LEVEL_W

-- recomputed when the Font Size setting changes
local function Metrics()
    ROW_H            = _G.Scaled(28)
    INDENT           = _G.Scaled(20)
    PAD_RIGHT        = _G.Scaled(10)
    MARK_W           = 2
    PORTRAIT         = 20
    TAG_W            = _G.Scaled(54)
    TAG_H            = _G.Scaled(14)
    LEVEL_W          = _G.Scaled(42)
end

_G.RegisterMetrics(Metrics)

CharacterItem = class(Turbine.UI.Control)
function CharacterItem:Constructor(id, character, sidebar)
	Turbine.UI.Control.Constructor( self )

    self.id        = id
    self.character = character
    self.name      = character.name
    self.sidebar   = sidebar
    self.hover     = false
    self.selected  = false
    self.isCurrent = (id == _G.characterId)

    self:Build()
    self:ApplyState()

end

function CharacterItem:SetSelected(value)

    self.selected = value
    self:ApplyState()

end

function CharacterItem:ApplyState()

    self.mark:SetVisible(self.selected)

    local ground = _G.Theme.PANEL
    if self.selected then
        ground = _G.Theme.SEL_BG
    elseif self.hover then
        ground = _G.Theme.SECTION
    end

    self.row:SetBackColor(ground)
    -- the tag is an outline, so its middle has to follow the row
    self.tagBg:SetBackColor(ground)

    -- the logged-in character stays marked whether or not it is the selected one
    if self.isCurrent or self.selected then
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
    else
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
    end

    self.levelLabel:SetForeColor(self.selected and _G.Theme.DIM2 or _G.Theme.DIM)

end

function CharacterItem:Clicked()
    self.sidebar:CharacterSelected(self)
end

function CharacterItem:SizeChanged()

    if self.row == nil then return end

    local width = self:GetWidth()
    if width <= 0 then return end

    self.row:SetSize(width, ROW_H)
    self.mark:SetSize(MARK_W, ROW_H)

    local right = width - PAD_RIGHT

    self.levelLabel:SetLeft(right - LEVEL_W)
    self.levelLabel:SetWidth(LEVEL_W)
    right = right - LEVEL_W - 6

    if self.isCurrent then
        self.tagFrame:SetLeft(right - TAG_W)
        right = right - TAG_W - 6
    end

    local nameLeft = INDENT + PORTRAIT + 8
    self.nameLabel:SetLeft(nameLeft)
    self.nameLabel:SetWidth(math.max(0, right - nameLeft))

end

function CharacterItem:ApplySettings() end

function CharacterItem:Build()

    self:SetMouseVisible(false)
    self:SetHeight(ROW_H)

    self.row = Turbine.UI.Control()
    self.row:SetParent(self)
    self.row:SetPosition(0, 0)
    self.row:SetHeight(ROW_H)
    self.row:SetBackColor(_G.Theme.PANEL)
    self.row.MouseEnter = function()
        self.hover = true
        self:ApplyState()
    end
    self.row.MouseLeave = function()
        self.hover = false
        self:ApplyState()
    end
    self.row.MouseClick = function()
        self:Clicked()
    end

    self.mark = Turbine.UI.Control()
    self.mark:SetParent(self.row)
    self.mark:SetPosition(0, 0)
    self.mark:SetSize(MARK_W, ROW_H)
    self.mark:SetBackColor(_G.Theme.ACCENT)
    self.mark:SetVisible(false)
    self.mark:SetMouseVisible(false)

    -- no frame around the portrait: the class icon is round, so a square ring reads as a
    -- box behind it. Marking the current character is left to the name colour and the tag.
    self.portrait = Turbine.UI.Control()
    self.portrait:SetParent(self.row)
    self.portrait:SetPosition(INDENT, math.floor((ROW_H - PORTRAIT) / 2))
    self.portrait:SetSize(PORTRAIT, PORTRAIT)
    self.portrait:SetMouseVisible(false)
    -- AlphaBlend, not Overlay: Overlay is for the white glyph .tga files and renders a
    -- full-colour game icon invisible against the dark panel
    self.portrait:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
    if _G.ClassIcons[self.character.class] ~= nil then
        self.portrait:SetBackground(_G.ClassIcons[self.character.class])
    end

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetMultiline(false)
    self.nameLabel:SetParent(self.row)
    self.nameLabel:SetTop(0)
    self.nameLabel:SetHeight(ROW_H)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetFont(_G.Font(12))
    self.nameLabel:SetText(self.name)
    self.nameLabel:SetForeColor(_G.Theme.TEXT)
    self.nameLabel:SetMouseVisible(false)

    -- CURRENT tag
    self.tagFrame = Turbine.UI.Control()
    self.tagFrame:SetParent(self.row)
    self.tagFrame:SetTop(math.floor((ROW_H - TAG_H) / 2))
    self.tagFrame:SetSize(TAG_W, TAG_H)
    self.tagFrame:SetBackColor(_G.Theme.ACCENT)
    self.tagFrame:SetVisible(self.isCurrent)
    self.tagFrame:SetMouseVisible(false)

    self.tagBg = Turbine.UI.Control()
    self.tagBg:SetParent(self.tagFrame)
    self.tagBg:SetPosition(1, 1)
    self.tagBg:SetSize(TAG_W - 2, TAG_H - 2)
    self.tagBg:SetBackColor(_G.Theme.PANEL)
    self.tagBg:SetMouseVisible(false)

    self.tagLabel = Turbine.UI.Label()
    self.tagLabel:SetMultiline(false)
    self.tagLabel:SetParent(self.tagBg)
    self.tagLabel:SetSize(TAG_W - 2, TAG_H - 2)
    self.tagLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.tagLabel:SetFont(_G.Font(10))
    self.tagLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.tagLabel:SetForeColor(_G.Theme.ACCENT)
    self.tagLabel:SetText(_G.L("currentTag"))
    self.tagLabel:SetMouseVisible(false)

    self.levelLabel = Turbine.UI.Label()
    self.levelLabel:SetMultiline(false)
    self.levelLabel:SetParent(self.row)
    self.levelLabel:SetTop(0)
    self.levelLabel:SetHeight(ROW_H)
    self.levelLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.levelLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.levelLabel:SetFont(_G.Font(12))
    self.levelLabel:SetText(self.character.level and ("Lv " .. self.character.level) or "")
    self.levelLabel:SetForeColor(_G.Theme.DIM)
    self.levelLabel:SetMouseVisible(false)

end
