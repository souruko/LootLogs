
Settings = class(Turbine.UI.Control)

function Settings:Constructor()
    Turbine.UI.Control.Constructor(self)
    self:SetVisible(false)
    self.serverRowMap = {}
    self.allRows = {}
    self:Build()
end

-- ------------------------------------------------------------------------------------------------

local COL_OUTER   = Turbine.UI.Color(0.22, 0.18, 0.12)
local COL_FRAME   = Turbine.UI.Color(0.40, 0.33, 0.20)
local COL_BG      = Turbine.UI.Color(0.05, 0.04, 0.03)
local COL_PANEL   = Turbine.UI.Color(0.07, 0.06, 0.04)
local COL_HOVER   = Turbine.UI.Color(0.65, 0.54, 0.28)
local COL_PRESS   = Turbine.UI.Color(0.18, 0.15, 0.08)
local COL_TEXT    = Turbine.UI.Color(0.73, 0.65, 0.50)
local COL_ACCENT  = Turbine.UI.Color(1.0,  0.88, 0.55)
local COL_DIM     = Turbine.UI.Color(0.45, 0.38, 0.26)
local COL_SECTION = Turbine.UI.Color(0.10, 0.08, 0.04)
local COL_HEADER  = Turbine.UI.Color(0.12, 0.10, 0.06)
local COL_SEL_BG  = Turbine.UI.Color(0.22, 0.18, 0.08)

-- ------------------------------------------------------------------------------------------------

function Settings:MakeSectionHeader(title)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(COL_SECTION)
    row:SetMouseVisible(false)

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 26)
    accent:SetBackColor(COL_FRAME)
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(26)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    label:SetFontStyle(Turbine.UI.FontStyle.Outline)
    label:SetForeColor(COL_DIM)
    label:SetText(string.upper(title))
    label:SetMouseVisible(false)

    row.SizeChanged = function()
        label:SetWidth(row:GetWidth() - 12)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function Settings:MakeToggleRow(labelText, settingKey, onChanged)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(COL_PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(COL_TEXT)
    nameLabel:SetText(labelText)
    nameLabel:SetMouseVisible(false)

    local TOGGLE_W = 52
    local TOGGLE_H = 22

    local toggleFrame = Turbine.UI.Control()
    toggleFrame:SetParent(row)
    toggleFrame:SetSize(TOGGLE_W + 2, TOGGLE_H + 2)
    toggleFrame:SetBackColor(COL_FRAME)

    local toggleBg = Turbine.UI.Control()
    toggleBg:SetParent(toggleFrame)
    toggleBg:SetPosition(1, 1)
    toggleBg:SetSize(TOGGLE_W, TOGGLE_H)
    toggleBg:SetBackColor(COL_BG)

    local toggleLabel = Turbine.UI.Label()
    toggleLabel:SetParent(toggleBg)
    toggleLabel:SetSize(TOGGLE_W, TOGGLE_H)
    toggleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    toggleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    toggleLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    toggleLabel:SetMouseVisible(false)

    local function RefreshToggle()
        if _G.Settings[settingKey] then
            toggleLabel:SetText(_G.L("toggleOn"))
            toggleLabel:SetForeColor(COL_ACCENT)
        else
            toggleLabel:SetText(_G.L("toggleOff"))
            toggleLabel:SetForeColor(COL_DIM)
        end
    end
    RefreshToggle()

    local hover = false
    toggleBg.MouseEnter = function()
        hover = true
        toggleFrame:SetBackColor(COL_HOVER)
    end
    toggleBg.MouseLeave = function()
        hover = false
        toggleFrame:SetBackColor(COL_FRAME)
    end
    toggleBg.MouseDown = function()
        toggleBg:SetBackColor(COL_PRESS)
    end
    toggleBg.MouseUp = function()
        toggleBg:SetBackColor(COL_BG)
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
    row:SetBackColor(COL_PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(COL_TEXT)
    nameLabel:SetText(_G.L("timezone"))
    nameLabel:SetMouseVisible(false)

    local BTN_W = 24
    local BTN_H = 22
    local VAL_W = 58

    local valBg = Turbine.UI.Control()
    valBg:SetParent(row)
    valBg:SetSize(VAL_W, BTN_H)
    valBg:SetBackColor(COL_BG)
    valBg:SetMouseVisible(false)

    local valLabel = Turbine.UI.Label()
    valLabel:SetParent(valBg)
    valLabel:SetSize(VAL_W, BTN_H)
    valLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    valLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    valLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    valLabel:SetForeColor(COL_ACCENT)
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
        frame:SetBackColor(COL_FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(COL_BG)

        local lbl = Turbine.UI.Label()
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana14)
        lbl:SetFontStyle(Turbine.UI.FontStyle.Outline)
        lbl:SetForeColor(COL_TEXT)
        lbl:SetText(sign)
        lbl:SetMouseVisible(false)

        local hover = false
        bg.MouseEnter = function()
            hover = true
            frame:SetBackColor(COL_HOVER)
        end
        bg.MouseLeave = function()
            hover = false
            frame:SetBackColor(COL_FRAME)
        end
        bg.MouseDown = function()
            bg:SetBackColor(COL_PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(COL_BG)
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

function Settings:MakeServerRow(serverName)

    local row = Turbine.UI.Control()
    row:SetHeight(34)

    local function GetBgColor()
        if _G.Server == serverName then return COL_SEL_BG else return COL_PANEL end
    end
    local function GetAccentColor()
        if _G.Server == serverName then return COL_HOVER else return COL_FRAME end
    end
    local function GetTextColor()
        if _G.Server == serverName then return COL_ACCENT else return COL_TEXT end
    end

    row:SetBackColor(GetBgColor())

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(GetAccentColor())
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(34)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    label:SetFontStyle(Turbine.UI.FontStyle.Outline)
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
            row:SetBackColor(Turbine.UI.Color(0.13, 0.11, 0.06))
        end
    end
    row.MouseLeave = function()
        hover = false
        row:SetBackColor(GetBgColor())
    end
    row.MouseDown = function()
        row:SetBackColor(COL_PRESS)
    end
    row.MouseUp = function()
        if hover and _G.Server ~= serverName then
            _G.Server = serverName
            _G.SaveServer()
            _G.Logs[_G.characterId].server = serverName
            _G.SaveLogs()
            self:RefreshServerRows()
            self:GetParent().sidebar:RefreshItems()
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
    row:SetBackColor(COL_PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(COL_TEXT)
    nameLabel:SetText(_G.L("timeDisplay"))
    nameLabel:SetMouseVisible(false)

    local MODES  = { "timespan", "timestamp", "both" }
    local LABELS = { _G.L("timeDisplaySpan"), _G.L("timeDisplayStamp"), _G.L("timeDisplayBoth") }
    local BTN_W  = 76
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, mode in ipairs(MODES) do
            if _G.Settings.timeDisplay == mode then
                buttons[i].frame:SetBackColor(COL_HOVER)
                buttons[i].label:SetForeColor(COL_ACCENT)
            else
                buttons[i].frame:SetBackColor(COL_FRAME)
                buttons[i].label:SetForeColor(COL_DIM)
            end
        end
    end

    for i, mode in ipairs(MODES) do
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(COL_FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(COL_BG)

        local lbl = Turbine.UI.Label()
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        lbl:SetFontStyle(Turbine.UI.FontStyle.Outline)
        lbl:SetForeColor(COL_DIM)
        lbl:SetText(LABELS[i])
        lbl:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = lbl }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            if _G.Settings.timeDisplay ~= mode then
                frame:SetBackColor(COL_HOVER)
            end
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(COL_PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(COL_BG)
            if hover and _G.Settings.timeDisplay ~= mode then
                _G.Settings.timeDisplay = mode
                _G.SaveSettings()
                self:GetParent().contentView:UpdateContent()
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

function Settings:MakeLanguageRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(COL_PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(COL_TEXT)
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
                buttons[i].frame:SetBackColor(COL_HOVER)
                buttons[i].label:SetForeColor(COL_ACCENT)
            else
                buttons[i].frame:SetBackColor(COL_FRAME)
                buttons[i].label:SetForeColor(COL_DIM)
            end
        end
    end

    for i, lang in ipairs(LANGS) do
        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(COL_FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(COL_BG)

        local lbl = Turbine.UI.Label()
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        lbl:SetFontStyle(Turbine.UI.FontStyle.Outline)
        lbl:SetForeColor(COL_DIM)
        lbl:SetText(LABELS[i])
        lbl:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = lbl }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            if _G.Settings.language ~= lang then
                frame:SetBackColor(COL_HOVER)
            end
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(COL_PRESS)
        end
        bg.MouseUp = function()
            bg:SetBackColor(COL_BG)
            if hover and _G.Settings.language ~= lang then
                _G.Settings.language = lang
                _G.SaveSettings()
                self:Rebuild()
                self:GetParent().sidebar:ApplyLanguage()
                self:GetParent().contentView:UpdateContent()
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

function Settings:BuildRows()

    local function addRow(row)
        self.listbox:AddItem(row)
        self.allRows[#self.allRows + 1] = row
    end

    addRow(self:MakeSectionHeader(_G.L("sectionChat")))
    addRow(self:MakeToggleRow(_G.L("printAlerts"),  "printAlerts",  nil))
    addRow(self:MakeToggleRow(_G.L("printWelcome"), "printWelcome", nil))

    addRow(self:MakeSectionHeader(_G.L("sectionDisplay")))
    addRow(self:MakeToggleRow(_G.L("showCustomList"), "showCustomList", function()
        self:GetParent().sidebar:ApplySettings()
    end))
    addRow(self:MakeToggleRow(_G.L("showServers"), "showServers", function()
        self:GetParent().sidebar:FillCharacterItems()
    end))
    addRow(self:MakeToggleRow(_G.L("showBadge"), "showBadge", function()
        if not _G.Settings.showBadge and _G.QuickLaunchBtn then
            _G.QuickLaunchBtn:ClearBadge()
        end
    end))
    addRow(self:MakeTimezoneRow())
    addRow(self:MakeTimeDisplayRow())
    addRow(self:MakeLanguageRow())

    addRow(self:MakeSectionHeader(_G.L("sectionServer")))
    for _, serverName in ipairs(_G.Servers) do
        local row = self:MakeServerRow(serverName)
        self.serverRowMap[serverName] = row
        addRow(row)
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:Rebuild()

    self.listbox:ClearItems()
    self.allRows = {}
    self.serverRowMap = {}
    self:BuildRows()

    local listW = self.listbox:GetWidth()
    for _, row in ipairs(self.allRows) do
        row:SetWidth(listW)
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:RefreshServerRows()

    for _, row in pairs(self.serverRowMap) do
        if row.Refresh then row.Refresh() end
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:SizeChanged()

    local width, height = self:GetSize()

    self.background1:SetSize(width - 10, height - 10)
    self.frame1:SetSize(width - 20, height - 20)

    local headerW  = width - 22
    local CLOSE_SIZE = 24
    self.header:SetWidth(headerW)
    self.closeBtn:SetLeft(headerW - CLOSE_SIZE - 6)
    self.headerName:SetWidth(headerW - CLOSE_SIZE - 20)
    self.separator:SetWidth(headerW)

    local listW = headerW - 12
    self.background2:SetSize(headerW, height - 55)
    self.listbox:SetSize(listW, height - 55)
    self.scrollbar:SetPosition(listW, 0)
    self.scrollbar:SetHeight(height - 55)

    for _, row in ipairs(self.allRows) do
        row:SetWidth(listW)
    end

end

-- ------------------------------------------------------------------------------------------------

function Settings:Build()

    self:SetBackColor(COL_OUTER)

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(COL_BG)
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(COL_FRAME)
    self.frame1:SetPosition(5, 5)

    self.header = Turbine.UI.Control()
    self.header:SetParent(self.frame1)
    self.header:SetPosition(1, 1)
    self.header:SetHeight(32)
    self.header:SetBackColor(COL_HEADER)

    self.headerName = Turbine.UI.Label()
    self.headerName:SetParent(self.header)
    self.headerName:SetPosition(10, 0)
    self.headerName:SetHeight(32)
    self.headerName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerName:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.headerName:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.headerName:SetForeColor(COL_ACCENT)
    self.headerName:SetText(_G.L("settingsTitle"))
    self.headerName:SetMouseVisible(false)

    -- close button (top-right of header)
    local CLOSE_SIZE = 24

    self.closeBtn = Turbine.UI.Control()
    self.closeBtn:SetParent(self.header)
    self.closeBtn:SetSize(CLOSE_SIZE + 2, CLOSE_SIZE + 2)
    self.closeBtn:SetTop(math.floor((32 - CLOSE_SIZE - 2) / 2))
    self.closeBtn:SetBackColor(COL_FRAME)

    local closeBg = Turbine.UI.Control()
    closeBg:SetParent(self.closeBtn)
    closeBg:SetPosition(1, 1)
    closeBg:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    closeBg:SetBackColor(COL_BG)

    local closeLabel = Turbine.UI.Label()
    closeLabel:SetParent(closeBg)
    closeLabel:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    closeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    closeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    closeLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    closeLabel:SetForeColor(COL_DIM)
    closeLabel:SetText("x")
    closeLabel:SetMouseVisible(false)

    local closeHover = false
    closeBg.MouseEnter = function()
        closeHover = true
        self.closeBtn:SetBackColor(COL_HOVER)
        closeLabel:SetForeColor(COL_ACCENT)
    end
    closeBg.MouseLeave = function()
        closeHover = false
        self.closeBtn:SetBackColor(COL_FRAME)
        closeLabel:SetForeColor(COL_DIM)
    end
    closeBg.MouseDown = function()
        closeBg:SetBackColor(COL_PRESS)
    end
    closeBg.MouseUp = function()
        closeBg:SetBackColor(COL_BG)
        if closeHover then
            self:GetParent():ToggleSettings()
        end
    end

    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self.frame1)
    self.separator:SetPosition(1, 33)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(COL_FRAME)

    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(COL_PANEL)
    self.background2:SetPosition(1, 34)

    self.listbox = Turbine.UI.ListBox()
    self.listbox:SetParent(self.background2)
    self.listbox:SetBackColor(COL_PANEL)

    self.scrollbar = Turbine.UI.Lotro.ScrollBar()
    self.scrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollbar:SetParent(self.background2)
    self.scrollbar:SetWidth(10)
    self.listbox:SetVerticalScrollBar(self.scrollbar)

    self:BuildRows()

end
