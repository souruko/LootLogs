
-- settings panel geometry (docs/design/window-redesign/README.md, section 10)
local BORDER, HEADER_H, PAD_X, COL_GAP, SECTION_H, RULE_STEPS, CLOSE_SIZE, THEME_H

-- recomputed when the Font Size setting changes
local function Metrics()
    BORDER           = 1
    HEADER_H         = _G.Scaled(44)
    PAD_X            = _G.Scaled(14)
    COL_GAP          = _G.Scaled(16)
    SECTION_H        = _G.Scaled(26)
    RULE_STEPS       = 6
    CLOSE_SIZE       = 22
    THEME_H          = _G.Scaled(26)
end

_G.RegisterMetrics(Metrics)

local THEME_MODES = { "moria", "lorien", "mordor", "rivendell", "rohan", "wulf", "misty" }

Settings = class(Turbine.UI.Control)

function Settings:Constructor()
    Turbine.UI.Control.Constructor(self)
    self:SetVisible(false)
    self.serverRowMap = {}
    self.allRows = {}
    self:Build()
end

-- ------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------

-- the window, which is no longer our direct parent: PanelWindow puts content
-- inside self.client and hangs a back-pointer off it
function Settings:Window()

    local parent = self:GetParent()
    return parent ~= nil and parent.window or nil

end

function Settings:MakeSectionHeader(title)

    local row = Turbine.UI.Control()
    row:SetHeight(SECTION_H)
    row:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(0, 0)
    label:SetHeight(SECTION_H - 1)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM2)
    label:SetText(_G.Upper(title))
    label:SetMouseVisible(false)

    -- Turbine has no gradients, so the rule fades in steps from the frame colour into
    -- the panel it sits on
    local steps = {}
    for index = 1, RULE_STEPS do
        local segment = Turbine.UI.Control()
        segment:SetParent(row)
        segment:SetHeight(1)
        segment:SetTop(SECTION_H - 1)
        segment:SetBackColor(_G.MixColor("FRAME", "PANEL", (index - 1) / RULE_STEPS))
        segment:SetMouseVisible(false)
        steps[index] = segment
    end

    row.SizeChanged = function()
        local width = row:GetWidth()
        label:SetWidth(width)

        local segmentWidth = math.floor(width / RULE_STEPS)
        for index, segment in ipairs(steps) do
            segment:SetLeft((index - 1) * segmentWidth)
            segment:SetWidth(index == RULE_STEPS and (width - (index - 1) * segmentWidth)
                                                 or  segmentWidth)
        end
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- A plain full-width button row, used for the destructive action at the bottom.
function Settings:MakeActionRow(text, destructive, onClick)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetMouseVisible(false)

    local frame = Turbine.UI.Control()
    frame:SetParent(row)
    frame:SetPosition(0, 6)
    frame:SetHeight(22)
    frame:SetBackColor(_G.Theme.FRAME)

    local bg = Turbine.UI.Control()
    bg:SetParent(frame)
    bg:SetPosition(1, 1)
    bg:SetHeight(20)
    bg:SetBackColor(_G.Theme.BG)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(bg)
    label:SetPosition(0, 0)
    label:SetHeight(20)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(_G.Font(12))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(destructive and _G.Theme.CHIP_USED_TEXT or _G.Theme.DIM2)
    label:SetText(text)
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
        if hover then onClick() end
    end

    row.SizeChanged = function()
        local width = row:GetWidth()
        frame:SetWidth(width)
        bg:SetWidth(width - 2)
        label:SetWidth(width - 2)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeToggleRow(labelText, settingKey, onChanged)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(labelText)
    nameLabel:SetMouseVisible(false)

    local TOGGLE_W = 52
    local TOGGLE_H = 22

    local toggleFrame = Turbine.UI.Control()
    toggleFrame:SetParent(row)
    toggleFrame:SetSize(TOGGLE_W + 2, TOGGLE_H + 2)
    toggleFrame:SetBackColor(_G.Theme.FRAME)

    local toggleBg = Turbine.UI.Control()
    toggleBg:SetParent(toggleFrame)
    toggleBg:SetPosition(1, 1)
    toggleBg:SetSize(TOGGLE_W, TOGGLE_H)
    toggleBg:SetBackColor(_G.Theme.BG)

    local toggleLabel = Turbine.UI.Label()
    toggleLabel:SetMultiline(false)
    toggleLabel:SetParent(toggleBg)
    toggleLabel:SetSize(TOGGLE_W, TOGGLE_H)
    toggleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    toggleLabel:SetFont(_G.Font(12))
    toggleLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    toggleLabel:SetMouseVisible(false)

    local function RefreshToggle()
        if _G.Settings[settingKey] then
            toggleLabel:SetText(_G.L("toggleOn"))
            toggleLabel:SetForeColor(_G.Theme.ACCENT)
        else
            toggleLabel:SetText(_G.L("toggleOff"))
            toggleLabel:SetForeColor(_G.Theme.DIM)
        end
    end
    RefreshToggle()

    local hover = false
    toggleBg.MouseEnter = function()
        hover = true
        toggleFrame:SetBackColor(_G.Theme.HOVER)
    end
    toggleBg.MouseLeave = function()
        hover = false
        toggleFrame:SetBackColor(_G.Theme.FRAME)
    end
    toggleBg.MouseDown = function()
        toggleBg:SetBackColor(_G.Theme.PRESS)
    end
    toggleBg.MouseUp = function()
        toggleBg:SetBackColor(_G.Theme.BG)
        if hover then
            _G.Settings[settingKey] = not _G.Settings[settingKey]
            _G.SaveSettings()
            RefreshToggle()
            if onChanged then onChanged() end
        end
    end

    row.SizeChanged = function()
        local w = row:GetWidth()
        nameLabel:SetWidth(w - TOGGLE_W - 24)
        toggleFrame:SetLeft(w - TOGGLE_W - 12)
        toggleFrame:SetTop(math.floor((34 - TOGGLE_H - 2) / 2))
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeTimezoneRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("timezone"))
    nameLabel:SetMouseVisible(false)

    local BTN_W = 24
    local BTN_H = 22
    local VAL_W = 58

    local valBg = Turbine.UI.Control()
    valBg:SetParent(row)
    valBg:SetSize(VAL_W, BTN_H)
    valBg:SetBackColor(_G.Theme.BG)
    valBg:SetMouseVisible(false)

    local valLabel = Turbine.UI.Label()
    valLabel:SetMultiline(false)
    valLabel:SetParent(valBg)
    valLabel:SetSize(VAL_W, BTN_H)
    valLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    valLabel:SetFont(_G.Font(12))
    valLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    valLabel:SetForeColor(_G.Theme.ACCENT)
    valLabel:SetMouseVisible(false)

    local function RefreshVal()
        local tz = _G.Settings.timezone or 0
        if tz >= 0 then
            valLabel:SetText("UTC+" .. tz)
        else
            valLabel:SetText("UTC" .. tz)
        end
    end
    RefreshVal()

    local function MakeStepBtn(sign, delta)
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local lbl = Turbine.UI.Label()
        lbl:SetMultiline(false)
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(_G.Font(14))
        lbl:SetFontStyle(_G.Theme.FONT_STYLE)
        lbl:SetForeColor(_G.Theme.TEXT)
        lbl:SetText(sign)
        lbl:SetMouseVisible(false)

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
                local tz = (_G.Settings.timezone or 0) + delta
                if tz < -12 then tz = -12 end
                if tz > 14  then tz = 14  end
                _G.Settings.timezone = tz
                _G.SaveSettings()
                RefreshVal()
            end
        end

        return frame
    end

    local minusBtn = MakeStepBtn("-", -1)
    local plusBtn  = MakeStepBtn("+",  1)

    row.SizeChanged = function()
        local w        = row:GetWidth()
        local BTN_TOP  = math.floor((34 - BTN_H - 2) / 2)
        local VAL_TOP  = math.floor((34 - BTN_H) / 2)
        local right    = w - 10
        local plusLeft  = right - (BTN_W + 2)
        local valLeft   = plusLeft - 2 - VAL_W
        local minusLeft = valLeft - 2 - (BTN_W + 2)

        plusBtn:SetLeft(plusLeft)
        plusBtn:SetTop(BTN_TOP)
        valBg:SetLeft(valLeft)
        valBg:SetTop(VAL_TOP)
        minusBtn:SetLeft(minusLeft)
        minusBtn:SetTop(BTN_TOP)

        nameLabel:SetWidth(minusLeft - 12 - 4)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeQuickLaunchSizeRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("quickLaunchSize"))
    nameLabel:SetMouseVisible(false)

    local BTN_W = 24
    local BTN_H = 22
    local VAL_W = 46
    local MIN_SIZE, MAX_SIZE, STEP = 30, 80, 5

    local valBg = Turbine.UI.Control()
    valBg:SetParent(row)
    valBg:SetSize(VAL_W, BTN_H)
    valBg:SetBackColor(_G.Theme.BG)
    valBg:SetMouseVisible(false)

    local valLabel = Turbine.UI.Label()
    valLabel:SetMultiline(false)
    valLabel:SetParent(valBg)
    valLabel:SetSize(VAL_W, BTN_H)
    valLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    valLabel:SetFont(_G.Font(12))
    valLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    valLabel:SetForeColor(_G.Theme.ACCENT)
    valLabel:SetMouseVisible(false)

    local function RefreshVal()
        valLabel:SetText(tostring(_G.Settings.quickLaunchSize or 50) .. "px")
    end
    RefreshVal()

    local function MakeStepBtn(sign, delta)
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local lbl = Turbine.UI.Label()
        lbl:SetMultiline(false)
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(_G.Font(14))
        lbl:SetFontStyle(_G.Theme.FONT_STYLE)
        lbl:SetForeColor(_G.Theme.TEXT)
        lbl:SetText(sign)
        lbl:SetMouseVisible(false)

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
                local size = (_G.Settings.quickLaunchSize or 50) + delta
                if size < MIN_SIZE then size = MIN_SIZE end
                if size > MAX_SIZE then size = MAX_SIZE end
                _G.Settings.quickLaunchSize = size
                _G.SaveSettings()
                RefreshVal()
                if _G.QuickLaunchBtn then
                    _G.QuickLaunchBtn:SetIconSize(size)
                end
            end
        end

        return frame
    end

    local minusBtn = MakeStepBtn("-", -STEP)
    local plusBtn  = MakeStepBtn("+",  STEP)

    row.SizeChanged = function()
        local w        = row:GetWidth()
        local BTN_TOP  = math.floor((34 - BTN_H - 2) / 2)
        local VAL_TOP  = math.floor((34 - BTN_H) / 2)
        local right    = w - 10
        local plusLeft  = right - (BTN_W + 2)
        local valLeft   = plusLeft - 2 - VAL_W
        local minusLeft = valLeft - 2 - (BTN_W + 2)

        plusBtn:SetLeft(plusLeft)
        plusBtn:SetTop(BTN_TOP)
        valBg:SetLeft(valLeft)
        valBg:SetTop(VAL_TOP)
        minusBtn:SetLeft(minusLeft)
        minusBtn:SetTop(BTN_TOP)

        nameLabel:SetWidth(minusLeft - 12 - 4)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeServerRow(serverName)

    local row = Turbine.UI.Control()
    row:SetHeight(34)

    local function GetBgColor()
        if _G.Server == serverName then return _G.Theme.SEL_BG else return _G.Theme.PANEL end
    end
    local function GetAccentColor()
        if _G.Server == serverName then return _G.Theme.HOVER else return _G.Theme.FRAME end
    end
    local function GetTextColor()
        if _G.Server == serverName then return _G.Theme.ACCENT else return _G.Theme.TEXT end
    end

    row:SetBackColor(GetBgColor())

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(GetAccentColor())
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(34)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(14))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(GetTextColor())
    label:SetText(serverName)
    label:SetMouseVisible(false)

    row.Refresh = function()
        row:SetBackColor(GetBgColor())
        accent:SetBackColor(GetAccentColor())
        label:SetForeColor(GetTextColor())
    end

    local hover = false
    row.MouseEnter = function()
        hover = true
        if _G.Server ~= serverName then
            row:SetBackColor(_G.Theme.SECTION)
        end
    end
    row.MouseLeave = function()
        hover = false
        row:SetBackColor(GetBgColor())
    end
    row.MouseDown = function()
        row:SetBackColor(_G.Theme.PRESS)
    end
    row.MouseUp = function()
        if hover and _G.Server ~= serverName then
            _G.Server = serverName
            _G.SaveServer()
            _G.Logs[_G.characterId].server = serverName
            _G.SaveLogs()
            self:RefreshServerRows()
            self:Window().sidebar:RefreshItems()
        end
        row:SetBackColor(GetBgColor())
    end

    row.SizeChanged = function()
        label:SetWidth(row:GetWidth() - 12)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeTimeDisplayRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("timeDisplay"))
    nameLabel:SetMouseVisible(false)

    local MODES  = { "timespan", "timestamp", "both" }
    local LABELS = { _G.L("timeDisplaySpan"), _G.L("timeDisplayStamp"), _G.L("timeDisplayBoth") }
    local BTN_W  = 60
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, mode in ipairs(MODES) do
            if _G.Settings.timeDisplay == mode then
                buttons[i].frame:SetBackColor(_G.Theme.HOVER)
                buttons[i].label:SetForeColor(_G.Theme.ACCENT)
            else
                buttons[i].frame:SetBackColor(_G.Theme.FRAME)
                buttons[i].label:SetForeColor(_G.Theme.DIM)
            end
        end
    end

    for i, mode in ipairs(MODES) do
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local lbl = Turbine.UI.Label()
        lbl:SetMultiline(false)
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(_G.Font(12))
        lbl:SetFontStyle(_G.Theme.FONT_STYLE)
        lbl:SetForeColor(_G.Theme.DIM)
        lbl:SetText(LABELS[i])
        lbl:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = lbl }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            if _G.Settings.timeDisplay ~= mode then
                frame:SetBackColor(_G.Theme.HOVER)
            end
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(_G.Theme.PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(_G.Theme.BG)
            if hover and _G.Settings.timeDisplay ~= mode then
                _G.Settings.timeDisplay = mode
                _G.SaveSettings()
                self:Window().contentView:UpdateContent()
            end
        end
    end

    RefreshButtons()

    row.SizeChanged = function()
        local w     = row:GetWidth()
        local top   = math.floor((34 - BTN_H - 2) / 2)
        local right = w - 10
        for i = #MODES, 1, -1 do
            buttons[i].frame:SetLeft(right - (BTN_W + 2))
            buttons[i].frame:SetTop(top)
            right = right - (BTN_W + 2) - 4
        end
        nameLabel:SetWidth(right - 12)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------

-- Everything in the UI is authored at its smallest; each step moves the whole thing one
-- rung up the font ladder and grows the rows with it.
function Settings:MakeFontSizeRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("fontSize"))
    nameLabel:SetMouseVisible(false)

    local STEPS  = { 0, 1, 2 }
    local LABELS = { _G.L("fontSmall"), _G.L("fontMedium"), _G.L("fontLarge") }
    local BTN_W  = 56
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, step in ipairs(STEPS) do
            if (_G.Settings.fontScale or 0) == step then
                buttons[i].frame:SetBackColor(_G.Theme.HOVER)
                buttons[i].label:SetForeColor(_G.Theme.ACCENT)
            else
                buttons[i].frame:SetBackColor(_G.Theme.FRAME)
                buttons[i].label:SetForeColor(_G.Theme.DIM2)
            end
            buttons[i].bg:SetBackColor(_G.Theme.BG)
        end
    end

    for i, step in ipairs(STEPS) do
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local label = Turbine.UI.Label()
        label:SetMultiline(false)
        label:SetParent(bg)
        label:SetSize(BTN_W, BTN_H)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(_G.Font(12))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.DIM2)
        label:SetText(LABELS[i])
        label:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = label }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            frame:SetBackColor(_G.Theme.HOVER)
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(_G.Theme.PRESS)
        end
        bg.MouseUp = function()
            if hover and (_G.Settings.fontScale or 0) ~= step then
                _G.Settings.fontScale = step
                _G.SaveSettings()

                -- every control caches its font and every row its height at build time,
                -- so the windows are rebuilt, exactly as a theme change does
                _G.ApplyFontScale()

                _G.RebuildWindows(function()
                    _G.Window:SetVisible(true)
                    _G.Window:ToggleSettings()
                end)
            else
                RefreshButtons()
            end
        end
    end

    RefreshButtons()

    row.SizeChanged = function()
        local w     = row:GetWidth()
        local top   = math.floor((34 - BTN_H - 2) / 2)
        local right = w - 10
        for i = #STEPS, 1, -1 do
            buttons[i].frame:SetLeft(right - (BTN_W + 2))
            buttons[i].frame:SetTop(top)
            right = right - (BTN_W + 2) - 4
        end
        nameLabel:SetWidth(math.max(0, right - 12))
    end

    return row

end

-- A row of mutually exclusive buttons, in the same anatomy as the Font Size row above but
-- driven by data, because that row is no longer the only one that needs it.
--
--   choices = { { value = 20, label = "2s" }, ... }
--
-- Unlike Font Size this does NOT rebuild the windows: it writes a number that is read when it
-- is next used, so there is nothing cached to invalidate.
function Settings:MakeChoiceRow(labelText, settingKey, choices, onChanged)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(labelText)
    nameLabel:SetMouseVisible(false)

    local BTN_W  = 40
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, choice in ipairs(choices) do
            if _G.Settings[settingKey] == choice.value then
                buttons[i].frame:SetBackColor(_G.Theme.HOVER)
                buttons[i].label:SetForeColor(_G.Theme.ACCENT)
            else
                buttons[i].frame:SetBackColor(_G.Theme.FRAME)
                buttons[i].label:SetForeColor(_G.Theme.DIM2)
            end
            buttons[i].bg:SetBackColor(_G.Theme.BG)
        end
    end

    for i, choice in ipairs(choices) do

        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local label = Turbine.UI.Label()
        label:SetMultiline(false)
        label:SetParent(bg)
        label:SetSize(BTN_W, BTN_H)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(_G.Font(12))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.DIM2)
        label:SetText(choice.label)
        label:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = label }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            frame:SetBackColor(_G.Theme.HOVER)
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(_G.Theme.PRESS)
        end
        bg.MouseUp = function()
            if hover and _G.Settings[settingKey] ~= choice.value then
                _G.Settings[settingKey] = choice.value
                _G.SaveSettings()
                if onChanged ~= nil then onChanged() end
            end
            RefreshButtons()
        end

    end

    RefreshButtons()

    row.SizeChanged = function()
        local w     = row:GetWidth()
        local top   = math.floor((34 - BTN_H - 2) / 2)
        local right = w - 10
        for i = #choices, 1, -1 do
            buttons[i].frame:SetLeft(right - (BTN_W + 2))
            buttons[i].frame:SetTop(top)
            right = right - (BTN_W + 2) - 4
        end
        nameLabel:SetWidth(math.max(0, right - 12))
    end

    return row

end

function Settings:MakeLanguageRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(14))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("sectionLanguage"))
    nameLabel:SetMouseVisible(false)

    local LANGS  = { "en", "de", "fr" }
    local LABELS = { "EN", "DE", "FR" }
    local BTN_W  = 36
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, lang in ipairs(LANGS) do
            if _G.Settings.language == lang then
                buttons[i].frame:SetBackColor(_G.Theme.HOVER)
                buttons[i].label:SetForeColor(_G.Theme.ACCENT)
            else
                buttons[i].frame:SetBackColor(_G.Theme.FRAME)
                buttons[i].label:SetForeColor(_G.Theme.DIM)
            end
        end
    end

    for i, lang in ipairs(LANGS) do
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(_G.Theme.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(_G.Theme.BG)

        local lbl = Turbine.UI.Label()
        lbl:SetMultiline(false)
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(_G.Font(12))
        lbl:SetFontStyle(_G.Theme.FONT_STYLE)
        lbl:SetForeColor(_G.Theme.DIM)
        lbl:SetText(LABELS[i])
        lbl:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = lbl }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            if _G.Settings.language ~= lang then
                frame:SetBackColor(_G.Theme.HOVER)
            end
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(_G.Theme.PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(_G.Theme.BG)
            if hover and _G.Settings.language ~= lang then
                _G.Settings.language = lang
                _G.SaveSettings()
                self:Rebuild()
                self:Window().sidebar:ApplyLanguage()
                self:Window().contentView:UpdateContent()
            end
        end
    end

    RefreshButtons()

    row.SizeChanged = function()
        local w      = row:GetWidth()
        local top    = math.floor((34 - BTN_H - 2) / 2)
        local right  = w - 10
        for i = #LANGS, 1, -1 do
            buttons[i].frame:SetLeft(right - (BTN_W + 2))
            buttons[i].frame:SetTop(top)
            right = right - (BTN_W + 2) - 4
        end
        nameLabel:SetWidth(right - 12)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- One theme per row: a preview swatch of that theme's own ground and accent, its name,
-- and the active one marked. The old row laid all seven out side by side, which needs
-- more than twice the width a column has.
function Settings:MakeThemeRow(mode, label)

    local raw = _G.Themes[mode]
    local function colour(role)
        local rgb = raw[role]
        return Turbine.UI.Color(rgb[1], rgb[2], rgb[3])
    end

    local active = (_G.Settings.colorTheme == mode)

    local row = Turbine.UI.Control()
    row:SetHeight(THEME_H)
    row:SetBackColor(active and _G.Theme.SEL_BG or _G.Theme.PANEL)

    local mark = Turbine.UI.Control()
    mark:SetParent(row)
    mark:SetPosition(0, 0)
    mark:SetSize(2, THEME_H)
    mark:SetBackColor(_G.Theme.ACCENT)
    mark:SetVisible(active)
    mark:SetMouseVisible(false)

    -- 26x12 preview: the theme's frame, its ground, and a dot of its accent
    local swatch = Turbine.UI.Control()
    swatch:SetParent(row)
    swatch:SetPosition(10, math.floor((THEME_H - 12) / 2))
    swatch:SetSize(26, 12)
    swatch:SetBackColor(colour("FRAME"))
    swatch:SetMouseVisible(false)

    local ground = Turbine.UI.Control()
    ground:SetParent(swatch)
    ground:SetPosition(1, 1)
    ground:SetSize(24, 10)
    ground:SetBackColor(colour("BG"))
    ground:SetMouseVisible(false)

    local dot = Turbine.UI.Control()
    dot:SetParent(ground)
    dot:SetPosition(16, 3)
    dot:SetSize(4, 4)
    dot:SetBackColor(colour("ACCENT"))
    dot:SetMouseVisible(false)

    local name = Turbine.UI.Label()
    name:SetMultiline(false)
    name:SetParent(row)
    name:SetPosition(44, 0)
    name:SetHeight(THEME_H)
    name:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    name:SetFont(_G.Font(12))
    name:SetFontStyle(_G.Theme.FONT_STYLE)
    name:SetForeColor(active and _G.Theme.ACCENT or _G.Theme.TEXT)
    name:SetText(label)
    name:SetMouseVisible(false)

    local hover = false
    row.MouseEnter = function()
        hover = true
        if not active then row:SetBackColor(_G.Theme.SECTION) end
    end
    row.MouseLeave = function()
        hover = false
        if not active then row:SetBackColor(_G.Theme.PANEL) end
    end
    row.MouseClick = function()
        if active then return end

        _G.Settings.colorTheme = mode
        _G.SaveSettings()
        _G.ApplyTheme(mode)

        -- every window is rebuilt: every control cached a colour at build time
        _G.RebuildWindows(function()
            _G.Window:SetVisible(true)
            _G.Window:ToggleSettings()
        end)
    end

    row.SizeChanged = function()
        name:SetWidth(math.max(0, row:GetWidth() - 44 - 10))
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:BuildRows()

    local function left(row)
        self.leftList:AddItem(row)
        self.allRows[#self.allRows + 1] = { row = row, side = "left" }
        return row
    end

    local function right(row)
        self.rightList:AddItem(row)
        self.allRows[#self.allRows + 1] = { row = row, side = "right" }
        return row
    end

    -- left column: what the plugin says and shows -----------------------------------------
    left(self:MakeSectionHeader(_G.L("sectionChat")))
    left(self:MakeToggleRow(_G.L("printAlerts"),  "printAlerts",  nil))
    left(self:MakeToggleRow(_G.L("printWelcome"), "printWelcome", nil))

    left(self:MakeSectionHeader(_G.L("sectionDisplay")))
    left(self:MakeToggleRow(_G.L("showCustomList"), "showCustomList", function()
        self:Window().sidebar:ApplySettings()
    end))
    left(self:MakeToggleRow(_G.L("showServers"), "showServers", function()
        self:Window().sidebar:FillCharacterItems()
    end))
    left(self:MakeToggleRow(_G.L("showBadge"), "showBadge", function()
        if not _G.Settings.showBadge and _G.QuickLaunchBtn then
            _G.QuickLaunchBtn:ClearBadge()
        end
    end))
    left(self:MakeQuickLaunchSizeRow())
    left(self:MakeTimezoneRow())
    left(self:MakeTimeDisplayRow())
    left(self:MakeFontSizeRow())

    -- loot drops -------------------------------------------------------------------------
    left(self:MakeSectionHeader(_G.L("sectionLoot")))
    left(self:MakeToggleRow(_G.L("showLootPopup"), "showLootPopup", nil))
    left(self:MakeToggleRow(_G.L("lootPopupWishOnly"), "lootPopupWishOnly", nil))

    -- How long after the chest message a loot line still counts as that chest's. Measured on
    -- a six-man run at 2.9s (docs/design/loot-drops/reference/chat-samples.txt), so the
    -- default sits above it with room to spare. Whole seconds only: the value is stored in
    -- tenths as an integer to survive the Euro save round-trip.
    left(self:MakeChoiceRow(_G.L("lootWindow"), "lootWindowFwdTenths", {
        { value = 20, label = "2s" },
        { value = 30, label = "3s" },
        { value = 40, label = "4s" },
        { value = 60, label = "6s" },
    }, nil))

    -- right column: how it looks, where it is, and the destructive bit ---------------------
    right(self:MakeSectionHeader(_G.L("sectionLanguage")))
    right(self:MakeLanguageRow())

    right(self:MakeSectionHeader(_G.L("sectionAppearance")))
    for _, mode in ipairs(THEME_MODES) do
        right(self:MakeThemeRow(mode, _G.L("theme" .. string.upper(string.sub(mode, 1, 1)) .. string.sub(mode, 2))))
    end

    right(self:MakeSectionHeader(_G.L("sectionServer")))
    for _, serverName in ipairs(_G.Servers) do
        local row = self:MakeServerRow(serverName)
        self.serverRowMap[serverName] = row
        right(row)
    end

    right(self:MakeSectionHeader(_G.L("sectionActions")))
    right(self:MakeActionRow(_G.L("clearThisChar"), true, function()
        local logs = _G.Logs[_G.characterId]
        if logs == nil then return end
        logs.logs = {}
        _G.SaveLogs()
        local window = self:Window()
        if window ~= nil then
            window.contentView:UpdateContent()
            window.sidebar:RefreshTierSquares()
        end
    end))

end

-- ------------------------------------------------------------------------------------------------

function Settings:Rebuild()

    self.leftList:ClearItems()
    self.rightList:ClearItems()
    self.allRows      = {}
    self.serverRowMap = {}
    self:BuildRows()
    self:SizeChanged()

end

-- ------------------------------------------------------------------------------------------------

function Settings:RefreshServerRows()

    for _, row in pairs(self.serverRowMap) do
        if row.Refresh then row.Refresh() end
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:SizeChanged()

    if self.header == nil then return end

    local width, height = self:GetSize()
    local iw = math.max(0, width - 2 * BORDER)

    self.header:SetWidth(iw)
    self.closeBtn:SetLeft(iw - CLOSE_SIZE - PAD_X)
    self.headerName:SetWidth(math.max(0, iw - CLOSE_SIZE - PAD_X * 2 - 8))
    self.separator:SetPosition(BORDER, BORDER + HEADER_H)
    self.separator:SetWidth(iw)

    local bodyTop = BORDER + HEADER_H + 1
    local bodyH   = math.max(0, height - BORDER - bodyTop)

    self.body:SetPosition(BORDER, bodyTop)
    self.body:SetSize(iw, bodyH)

    -- two columns with a rule between them
    local columnW = math.floor((iw - PAD_X * 2 - COL_GAP) / 2)
    local listW   = math.max(0, columnW - 12)

    self.leftList:SetPosition(PAD_X, 0)
    self.leftList:SetSize(columnW, bodyH)
    self.leftScroll:SetPosition(PAD_X + listW, 0)
    self.leftScroll:SetHeight(bodyH)

    local rightLeft = PAD_X + columnW + COL_GAP
    self.divider:SetPosition(PAD_X + columnW + math.floor(COL_GAP / 2), 8)
    self.divider:SetSize(1, math.max(0, bodyH - 16))

    self.rightList:SetPosition(rightLeft, 0)
    self.rightList:SetSize(columnW, bodyH)
    self.rightScroll:SetPosition(rightLeft + listW, 0)
    self.rightScroll:SetHeight(bodyH)

    for _, entry in ipairs(self.allRows) do
        entry.row:SetWidth(listW)
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:Build()

    -- same chrome as the content panel: 1px border, header, rule, body
    self:SetBackColor(_G.Theme.FRAME)

    self.header = Turbine.UI.Control()
    self.header:SetParent(self)
    self.header:SetPosition(BORDER, BORDER)
    self.header:SetHeight(HEADER_H)
    self.header:SetBackColor(_G.Theme.HEADER)

    self.headerMark = Turbine.UI.Control()
    self.headerMark:SetParent(self.header)
    self.headerMark:SetPosition(0, 0)
    self.headerMark:SetSize(2, HEADER_H)
    self.headerMark:SetBackColor(_G.Theme.ACCENT)
    self.headerMark:SetMouseVisible(false)

    self.headerName = Turbine.UI.Label()
    self.headerName:SetMultiline(false)
    self.headerName:SetParent(self.header)
    self.headerName:SetPosition(PAD_X, 0)
    self.headerName:SetHeight(HEADER_H)
    self.headerName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerName:SetFont(_G.Font(16))
    self.headerName:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerName:SetForeColor(_G.Theme.ACCENT)
    self.headerName:SetText(_G.L("settingsTitle"))
    self.headerName:SetMouseVisible(false)

    -- close button, matching the title bar buttons
    self.closeBtn = Turbine.UI.Control()
    self.closeBtn:SetParent(self.header)
    self.closeBtn:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    self.closeBtn:SetTop(math.floor((HEADER_H - CLOSE_SIZE) / 2))
    self.closeBtn:SetBackColor(_G.Theme.SEL_BG)

    local closeIcon = Turbine.UI.Control()
    closeIcon:SetParent(self.closeBtn)
    closeIcon:SetSize(16, 16)
    closeIcon:SetPosition(math.floor((CLOSE_SIZE - 16) / 2), math.floor((CLOSE_SIZE - 16) / 2))
    closeIcon:SetBackground("LootLogs/Ressources/cross.tga")
    closeIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    closeIcon:SetMouseVisible(false)

    self.closeBtn.MouseEnter = function() self.closeBtn:SetBackColor(_G.Theme.FRAME) end
    self.closeBtn.MouseLeave = function() self.closeBtn:SetBackColor(_G.Theme.SEL_BG) end
    self.closeBtn.MouseClick = function() self:Window():ToggleSettings() end

    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(_G.Theme.FRAME)

    self.body = Turbine.UI.Control()
    self.body:SetParent(self)
    self.body:SetBackColor(_G.Theme.PANEL)

    self.divider = Turbine.UI.Control()
    self.divider:SetParent(self.body)
    self.divider:SetBackColor(_G.Theme.FRAME)
    self.divider:SetMouseVisible(false)

    self.leftList = Turbine.UI.ListBox()
    self.leftList:SetParent(self.body)
    self.leftList:SetBackColor(_G.Theme.PANEL)

    self.leftScroll = Turbine.UI.Lotro.ScrollBar()
    self.leftScroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.leftScroll:SetParent(self.body)
    self.leftScroll:SetWidth(10)
    self.leftList:SetVerticalScrollBar(self.leftScroll)

    self.rightList = Turbine.UI.ListBox()
    self.rightList:SetParent(self.body)
    self.rightList:SetBackColor(_G.Theme.PANEL)

    self.rightScroll = Turbine.UI.Lotro.ScrollBar()
    self.rightScroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.rightScroll:SetParent(self.body)
    self.rightScroll:SetWidth(10)
    self.rightList:SetVerticalScrollBar(self.rightScroll)

    self:BuildRows()

end
