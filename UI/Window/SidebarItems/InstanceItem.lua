
-- One instance row in the Content tab: name, pin marker, and a bar of per-tier
-- squares summarising the current character's logs for that instance.

local ROW_H, INDENT, PAD_RIGHT, MARK_W, PIN

-- recomputed when the Font Size setting changes
local function Metrics()
    ROW_H            = _G.Scaled(24)
    INDENT           = _G.Scaled(22)
    PAD_RIGHT        = _G.Scaled(10)
    MARK_W           = 2
    PIN              = 10
end

_G.RegisterMetrics(Metrics)

InstanceItem = class(Turbine.UI.Control)
function InstanceItem:Constructor(id, instance, sidebar)
	Turbine.UI.Control.Constructor( self )

    self.id       = id
    self.instance = instance
    self.name     = instance.name
    self.sidebar  = sidebar
    self.hover    = false
    self.selected = false

    self:Build()
    self:RefreshSquares()

end

function InstanceItem:SetSelected(value)

    self.selected = value
    self:ApplyState()

end

function InstanceItem:ApplyState()

    self.mark:SetVisible(self.selected)

    if self.selected then
        self.row:SetBackColor(_G.Theme.SEL_BG)
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
    elseif self.hover then
        self.row:SetBackColor(_G.Theme.SECTION)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
    else
        self.row:SetBackColor(_G.Theme.PANEL)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
    end

    -- an empty square shows the row colour through its middle
    self:PaintSquares()

end

function InstanceItem:Clicked()
    self.sidebar:InstanceSelected(self)
end

-- ------------------------------------------------------------------------------------------------

function InstanceItem:Ground()

    if self.selected then return _G.Theme.SEL_BG end
    if self.hover    then return _G.Theme.SECTION end
    return _G.Theme.PANEL

end

function InstanceItem:PaintSquares()

    if self.states == nil then return end

    for index, square in ipairs(self.squares) do
        if self.states[index] ~= nil then
            _G.SetTierSquareState(square, self.states[index], self:Ground())
        end
    end

end

-- Recomputes the bar from the current character's logs. Called whenever the list is
-- refilled and whenever a chest is logged.
function InstanceItem:RefreshSquares()

    self.states = _G.InstanceTierStates(self.id, _G.characterId)
    self.pinned = _G.InstanceIsPinned(self.id)

    for index, square in ipairs(self.squares) do
        square:SetVisible(self.states ~= nil and self.states[index] ~= nil)
    end

    self.pinIcon:SetVisible(self.pinned)

    self:PaintSquares()
    self:LayoutRow()

end

function InstanceItem:LayoutRow()

    local width = self:GetWidth()
    if width <= 0 then return end

    self.row:SetSize(width, ROW_H)
    self.mark:SetSize(MARK_W, ROW_H)

    local right = width - PAD_RIGHT

    local squareCount = self.states ~= nil and #self.states or 0
    local squaresW    = _G.TierSquaresWidth(squareCount)

    if squareCount > 0 then
        local left = right - squaresW
        for index = 1, squareCount do
            self.squares[index]:SetPosition(
                left + (index - 1) * (_G.TierSquare + _G.TierSquareGap),
                math.floor((ROW_H - _G.TierSquare) / 2))
        end
        right = left - 6
    end

    -- Turbine cannot measure a label, so the pin sits at a fixed spot before the
    -- squares rather than tight against the end of the name
    if self.pinned then
        right = right - PIN
        self.pinIcon:SetPosition(right, math.floor((ROW_H - PIN) / 2))
        right = right - 4
    end

    self.nameLabel:SetWidth(math.max(0, right - INDENT))

end

function InstanceItem:SizeChanged()

    if self.row == nil then return end
    self:LayoutRow()

end

function InstanceItem:ApplySettings() end

function InstanceItem:Build()

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

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetMultiline(false)
    self.nameLabel:SetParent(self.row)
    self.nameLabel:SetPosition(INDENT, 0)
    self.nameLabel:SetHeight(ROW_H)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetFont(_G.Font(12))
    self.nameLabel:SetText(self.name)
    self.nameLabel:SetForeColor(_G.Theme.TEXT)
    self.nameLabel:SetMouseVisible(false)

    self.pinIcon = Turbine.UI.Control()
    self.pinIcon:SetParent(self.row)
    self.pinIcon:SetSize(PIN, PIN)
    self.pinIcon:SetBackground("LootLogs/Ressources/star_pin.tga")
    self.pinIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.pinIcon:SetVisible(false)
    self.pinIcon:SetMouseVisible(false)

    self.squares = {}
    for index = 1, _G.TierSquareMax do
        local square = _G.MakeTierSquare(self.row)
        square:SetVisible(false)
        self.squares[index] = square
    end

end
