--=================================================================================================
--= Tooltip
--= ===============================================================================================
--= Turbine has no native control tooltip -- SetTooltip is not an API method, it just silently
--= doesn't exist, and every real plugin on this client rolls its own. This is LootLogs' one: a
--= single floating window, reused for every hover across the browser and the popup, shown at the
--= control's position on MouseEnter and hidden on MouseLeave. _G.LootTooltip.Attach is the only
--= entry point a row needs.
--=================================================================================================

_G.LootTooltip = class(Turbine.UI.Window)

local PAD_X, PAD_Y = 8, 6

-- markup tags (_G.CM output) have no width of their own and must not be counted against it
local function StripMarkup(text)
    return (text:gsub("<[^>]->", ""))
end

function _G.LootTooltip:Constructor()

    Turbine.UI.Window.Constructor(self)

    self:SetVisible(false)
    self:SetMouseVisible(false)
    self:SetZOrder(100)

    self.inner = Turbine.UI.Control()
    self.inner:SetParent(self)
    self.inner:SetPosition(1, 1)
    self.inner:SetMouseVisible(false)

    self.label = Turbine.UI.Label()
    self.label:SetParent(self.inner)
    self.label:SetPosition(PAD_X, PAD_Y)
    self.label:SetMultiline(true)
    self.label:SetMarkupEnabled(true)
    self.label:SetMouseVisible(false)

end

-- text: a possibly multi-line _G.CM()-markup string. x, y: the top-left screen position it is
-- asked to appear at, nudged back onto the screen if it would run off the edge.
function _G.LootTooltip:Show(text, x, y)

    if text == nil or text == "" then return end

    -- coloured, not just re-fonted: unlike QuickLaunch's badge this reads theme colours, so a
    -- theme switch (which does not rebuild this singleton) must not leave it showing the old one
    self:SetBackColor(_G.Theme.FRAME)
    self.inner:SetBackColor(_G.Theme.BG)
    self.label:SetForeColor(_G.Theme.TEXT)
    self.label:SetFont(_G.Font(12))
    self.label:SetFontStyle(_G.Theme.FONT_STYLE)
    self.label:SetText(text)

    -- there is no reliable way to ask Turbine how tall a line of a given font renders, so this
    -- follows the same rule the rest of the UI uses for row heights: a fixed line height that
    -- steps with the font scale setting rather than the font's own metrics
    local lineH  = _G.Scaled(16)
    local glyphW = _G.GlyphWidth(12)

    local lines, widest = 0, 0
    for line in (StripMarkup(text) .. "\n"):gmatch("(.-)\n") do
        lines  = lines + 1
        widest = math.max(widest, _G.Glyphs(line))
    end

    local labelW = math.ceil(widest * glyphW) + 6
    local labelH = lines * lineH + 2

    self.label:SetSize(labelW, labelH)

    local w = labelW + PAD_X * 2 + 2
    local h = labelH + PAD_Y * 2 + 2

    self.inner:SetSize(w - 2, h - 2)
    self:SetSize(w, h)

    local dw, dh = Turbine.UI.Display.GetSize()
    if x + w > dw then x = dw - w end
    if y + h > dh then y = dh - h end

    self:SetPosition(math.max(0, x), math.max(0, y))
    self:SetVisible(true)

end

function _G.LootTooltip:Hide()
    self:SetVisible(false)
end

-- Wires MouseEnter/MouseLeave on `control` so it shows `text` (a string, or a function returning
-- one -- resolved on hover so it can read state that changes after the row is built) just below
-- the control. Whether `control` receives the mouse at all is still the caller's call, same as
-- every other hover in this codebase -- Attach only decides what appears once it does.
function _G.LootTooltip.Attach(control, text)

    control.MouseEnter = function()
        local shown = (type(text) == "function") and text() or text
        if shown == nil or shown == "" then return end
        local left, top = control:GetParent():PointToScreen(control:GetPosition())
        local _, h = control:GetSize()
        _G.LootTooltipWindow:Show(shown, left, top + h + 4)
    end

    control.MouseLeave = function()
        _G.LootTooltipWindow:Hide()
    end

end
