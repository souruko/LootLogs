
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

function Settings:MakeSectionHeader(title)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(_G.Theme.SECTION)
    row:SetMouseVisible(false)

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 26)
    accent:SetBackColor(_G.Theme.FRAME)
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(26)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM)
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
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
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
    toggleLabel:SetParent(toggleBg)
    toggleLabel:SetSize(TOGGLE_W, TOGGLE_H)
    toggleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    toggleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
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
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
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
    valLabel:SetParent(valBg)
    valLabel:SetSize(VAL_W, BTN_H)
    valLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    valLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
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
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana14)
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
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(34)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
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
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
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
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana12)
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
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
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
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana12)
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

function Settings:MakeColorThemeRow()

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(_G.L("colorTheme"))
    nameLabel:SetMouseVisible(false)

    local MODES  = { "moria", "lorien", "mordor", "rivendell", "rohan", "wulf", "misty" }
    local LABELS = { _G.L("themeMoria"), _G.L("themeLorien"), _G.L("themeMordor"), _G.L("themeRivendell"), _G.L("themeRohan"), _G.L("themeWulf"), _G.L("themeMisty") }
    local BTN_W  = 70
    local BTN_H  = 22
    local buttons = {}

    local function RefreshButtons()
        for i, mode in ipairs(MODES) do
            local c = buttons[i].c
            if _G.Settings.colorTheme == mode then
                buttons[i].frame:SetBackColor(c.HOVER)
                buttons[i].bg:SetBackColor(c.HOVER)
                buttons[i].label:SetForeColor(c.BG)
                buttons[i].label:SetFontStyle(Turbine.UI.FontStyle.None)
            else
                buttons[i].frame:SetBackColor(c.FRAME)
                buttons[i].bg:SetBackColor(c.BG)
                buttons[i].label:SetForeColor(c.TEXT)
                buttons[i].label:SetFontStyle(Turbine.UI.FontStyle.None)
            end
        end
    end

    for i, mode in ipairs(MODES) do
        local td = _G.Themes[mode]
        local c = {
            FRAME  = Turbine.UI.Color(td.FRAME[1],  td.FRAME[2],  td.FRAME[3]),
            BG     = Turbine.UI.Color(td.BG[1],     td.BG[2],     td.BG[3]),
            HOVER  = Turbine.UI.Color(td.HOVER[1],  td.HOVER[2],  td.HOVER[3]),
            PRESS  = Turbine.UI.Color(td.PRESS[1],  td.PRESS[2],  td.PRESS[3]),
            TEXT   = Turbine.UI.Color(td.TEXT[1],   td.TEXT[2],   td.TEXT[3]),
            ACCENT = Turbine.UI.Color(td.ACCENT[1], td.ACCENT[2], td.ACCENT[3]),
        }

        local frame = Turbine.UI.Control()
        frame:SetParent(row)
        frame:SetSize(BTN_W + 2, BTN_H + 2)
        frame:SetBackColor(c.FRAME)

        local bg = Turbine.UI.Control()
        bg:SetParent(frame)
        bg:SetPosition(1, 1)
        bg:SetSize(BTN_W, BTN_H)
        bg:SetBackColor(c.BG)

        local lbl = Turbine.UI.Label()
        lbl:SetParent(bg)
        lbl:SetSize(BTN_W, BTN_H)
        lbl:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        lbl:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        lbl:SetFontStyle(_G.Theme.FONT_STYLE)
        lbl:SetForeColor(c.TEXT)
        lbl:SetText(LABELS[i])
        lbl:SetMouseVisible(false)

        buttons[i] = { frame = frame, bg = bg, label = lbl, c = c }

        local hover = false
        bg.MouseEnter = function()
            hover = true
            frame:SetBackColor(c.HOVER)
            lbl:SetForeColor(c.ACCENT)
        end
        bg.MouseLeave = function()
            hover = false
            RefreshButtons()
        end
        bg.MouseDown = function()
            bg:SetBackColor(c.PRESS)
        end
        bg.MouseUp = function()
            if hover and _G.Settings.colorTheme ~= mode then
                _G.Settings.colorTheme = mode
                _G.SaveSettings()
                _G.ApplyTheme(mode)
                local old = _G.Window
                _G.Window = nil
                if old then old:SetVisible(false) end
                local reloader = Turbine.UI.Control()
                reloader.Update = function()
                    reloader:SetWantsUpdates(false)
                    _G.Window = _G.LLWindow()
                    _G.Window:SetVisible(true)
                end
                reloader:SetWantsUpdates(true)
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

    addRow(self:MakeSectionHeader(_G.L("sectionAppearance")))
    addRow(self:MakeColorThemeRow())

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

    self:SetBackColor(_G.Theme.OUTER)

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(_G.Theme.BG)
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(_G.Theme.FRAME)
    self.frame1:SetPosition(5, 5)

    self.header = Turbine.UI.Control()
    self.header:SetParent(self.frame1)
    self.header:SetPosition(1, 1)
    self.header:SetHeight(32)
    self.header:SetBackColor(_G.Theme.HEADER)

    self.headerName = Turbine.UI.Label()
    self.headerName:SetParent(self.header)
    self.headerName:SetPosition(10, 0)
    self.headerName:SetHeight(32)
    self.headerName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerName:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.headerName:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerName:SetForeColor(_G.Theme.ACCENT)
    self.headerName:SetText(_G.L("settingsTitle"))
    self.headerName:SetMouseVisible(false)

    -- close button (top-right of header)
    local CLOSE_SIZE = 24

    self.closeBtn = Turbine.UI.Control()
    self.closeBtn:SetParent(self.header)
    self.closeBtn:SetSize(CLOSE_SIZE + 2, CLOSE_SIZE + 2)
    self.closeBtn:SetTop(math.floor((32 - CLOSE_SIZE - 2) / 2))
    self.closeBtn:SetBackColor(_G.Theme.FRAME)

    local closeBg = Turbine.UI.Control()
    closeBg:SetParent(self.closeBtn)
    closeBg:SetPosition(1, 1)
    closeBg:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    closeBg:SetBackColor(_G.Theme.BG)

    local closeLabel = Turbine.UI.Label()
    closeLabel:SetParent(closeBg)
    closeLabel:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    closeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    closeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    closeLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    closeLabel:SetForeColor(_G.Theme.DIM)
    closeLabel:SetText("x")
    closeLabel:SetMouseVisible(false)

    local closeHover = false
    closeBg.MouseEnter = function()
        closeHover = true
        self.closeBtn:SetBackColor(_G.Theme.HOVER)
        closeLabel:SetForeColor(_G.Theme.ACCENT)
    end
    closeBg.MouseLeave = function()
        closeHover = false
        self.closeBtn:SetBackColor(_G.Theme.FRAME)
        closeLabel:SetForeColor(_G.Theme.DIM)
    end
    closeBg.MouseDown = function()
        closeBg:SetBackColor(_G.Theme.PRESS)
    end
    closeBg.MouseUp = function()
        closeBg:SetBackColor(_G.Theme.BG)
        if closeHover then
            self:GetParent():ToggleSettings()
        end
    end

    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self.frame1)
    self.separator:SetPosition(1, 33)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(_G.Theme.FRAME)

    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(_G.Theme.PANEL)
    self.background2:SetPosition(1, 34)

    self.listbox = Turbine.UI.ListBox()
    self.listbox:SetParent(self.background2)
    self.listbox:SetBackColor(_G.Theme.PANEL)

    self.scrollbar = Turbine.UI.Lotro.ScrollBar()
    self.scrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollbar:SetParent(self.background2)
    self.scrollbar:SetWidth(10)
    self.listbox:SetVerticalScrollBar(self.scrollbar)

    self:BuildRows()

end
