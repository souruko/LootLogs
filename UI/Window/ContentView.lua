
ContentView = class(Turbine.UI.Control)

function ContentView:Constructor()
	Turbine.UI.Control.Constructor( self )

    self.currentRows = {}
    self:Build()

end

-- ------------------------------------------------------------------------------------------------

function ContentView:UpdateContent()

    local tab       = _G.Settings.selected.tab
    local charId    = _G.Settings.selected.character
    local serverId  = _G.Settings.selected.server
    local instId    = _G.Settings.selected.instance
    local contentId = _G.Settings.selected.content

    self:UpdateHeader()

    if _G.Settings.selected.customList then
        self:ShowCustomListView()
    elseif tab == _G.Tab.Content and instId ~= nil then
        self:ShowInstanceView(instId)
    elseif tab == _G.Tab.Content and contentId ~= nil then
        self:ShowContentView(contentId)
    elseif tab == _G.Tab.Characters and charId ~= nil then
        self:ShowCharacterView(charId)
    elseif tab == _G.Tab.Characters and serverId ~= nil then
        self:ShowServerView(serverId)
    else
        self:ClearContent()
    end

end

function ContentView:ClearContent()
    self.listbox:ClearItems()
    self.currentRows = {}
end

-- ------------------------------------------------------------------------------------------------

function ContentView:UpdateHeader()

    local tab       = _G.Settings.selected.tab
    local charId    = _G.Settings.selected.character
    local serverId  = _G.Settings.selected.server
    local instId    = _G.Settings.selected.instance
    local contentId = _G.Settings.selected.content

    self.clearLogsFrame:SetVisible(false)
    self.deleteCharFrame:SetVisible(false)
    self.headerTooltip:SetVisible(false)

    if _G.Settings.selected.customList then
        self.headerIcon:SetVisible(false)
        self.headerName:SetText(_G.L("customListName"))
        self.headerName:SetLeft(10)
        self.headerType:SetText(_G.L("headerCustomList"))

    elseif tab == _G.Tab.Content and instId ~= nil then
        local instance = _G.Instances[instId]
        if instance then
            self.headerIcon:SetVisible(false)
            self.headerName:SetText(instance.name)
            self.headerName:SetLeft(10)
            self.headerType:SetText(_G.L("headerInstance"))
        end

    elseif tab == _G.Tab.Content and contentId ~= nil then
        local content = _G.Content[contentId]
        if content then
            self.headerIcon:SetVisible(false)
            self.headerName:SetText(content.name)
            self.headerName:SetLeft(10)
            self.headerType:SetText(_G.L("headerContent"))
        end

    elseif tab == _G.Tab.Characters and charId ~= nil then
        local character = _G.Logs[charId]
        if character then
            self.headerIcon:SetBackground(_G.ClassIcons[character.class])
            self.headerIcon:SetVisible(true)
            self.headerName:SetText(character.name)
            self.headerName:SetLeft(32)
            self.headerType:SetText(_G.L("headerCharacter"))
            self.clearLogsFrame:SetVisible(true)
            local isCurrentChar = (charId == _G.characterId)
            self.deleteCharDisabled = isCurrentChar
            self.deleteCharFrame:SetVisible(true)
            if isCurrentChar then
                self.deleteCharFrame:SetBackColor(_G.Theme.PRESS)
                self.deleteCharLabel:SetForeColor(_G.Theme.OUTER)
            else
                self.deleteCharFrame:SetBackColor(_G.Theme.FRAME)
                self.deleteCharLabel:SetForeColor(_G.Theme.DIM2)
            end
        end

    elseif tab == _G.Tab.Characters and serverId ~= nil then
        self.headerIcon:SetVisible(false)
        self.headerName:SetText(serverId)
        self.headerName:SetLeft(10)
        self.headerType:SetText(_G.L("headerServer"))

    else
        self.headerIcon:SetVisible(false)
        self.headerName:SetText("")
        self.headerType:SetText("")
    end

end

-- ------------------------------------------------------------------------------------------------

local function tierOrder(tier)
    return (_G.TierOrder and _G.TierOrder[tostring(tier)]) or 99
end

local WEEKDAY_NAMES = {
    en = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
    de = {"Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"},
    fr = {"Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"},
}

local WEEKDAY_SHORT = {
    en = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"},
    de = {"So","Mo","Di","Mi","Do","Fr","Sa"},
    fr = {"Dim","Lun","Mar","Mer","Jeu","Ven","Sam"},
}

local RELATIVE_DAYS_TEMPLATE = {
    en = "In %d days",
    de = "In %d Tagen",
    fr = "Dans %d jours",
}

local function _DateFromUnix(absTime, wdayTable, sep)
    local days  = math.floor(absTime / 86400)
    local wday  = (days + 4) % 7 + 1
    local jdn = days + 2440588
    local a = jdn + 32044
    local b = math.floor((4 * a + 3) / 146097)
    local c = a - math.floor(146097 * b / 4)
    local d = math.floor((4 * c + 3) / 1461)
    local e = c - math.floor(1461 * d / 4)
    local m = math.floor((5 * e + 2) / 153)
    local day   = e - math.floor((153 * m + 2) / 5) + 1
    local month = m + 3 - 12 * math.floor(m / 10)
    local lang  = (_G.Settings and _G.Settings.language) or "en"
    local wdays = wdayTable[lang] or wdayTable.en
    return wdays[wday] .. sep .. day .. "." .. string.format("%02d", month)
end

local function FormatTimestamp(absTime)
    return _DateFromUnix(absTime, WEEKDAY_NAMES, ", ")
end

local function FormatTimestampShort(absTime)
    return _DateFromUnix(absTime, WEEKDAY_SHORT, " ")
end

local function FormatRelativeDays(absTime)
    local tz         = ((_G.Settings and _G.Settings.timezone) or 0) * 3600
    local currentDay = math.floor((Turbine.Engine.GetLocalTime() + tz) / 86400)
    local deathDay   = math.floor((absTime + tz) / 86400)
    local dayDiff    = deathDay - currentDay
    local lang       = (_G.Settings and _G.Settings.language) or "en"
    if dayDiff <= 0 then
        return _G.L("relativeToday")
    elseif dayDiff == 1 then
        return _G.L("relativeTomorrow")
    else
        local tmpl = RELATIVE_DAYS_TEMPLATE[lang] or RELATIVE_DAYS_TEMPLATE.en
        return string.format(tmpl, dayDiff)
    end
end

local function FormatTimeSpan(seconds)
    if seconds <= 0 then return "< 1m" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if d > 0 then return d .. "d " .. h .. "h"
    elseif h > 0 then return h .. "h " .. m .. "m"
    else return m .. "m"
    end
end

local function FormatTimeRemaining(seconds, absTime)
    if _G.Settings.timeDisplay == "timestamp" and absTime ~= nil then
        return FormatTimestamp(absTime)
    elseif _G.Settings.timeDisplay == "both" and absTime ~= nil then
        return FormatRelativeDays(absTime)
    end
    return FormatTimeSpan(seconds)
end

-- Collect events for an instance grouped by order, returning sorted list of groups.
-- Each group: { name, tiers = [{tier, tierOrder, time}] }
local function collectOrderGroups(instanceId, logs, currentTime)
    local groups = {}

    for eventIndex, event in pairs(_G.Events) do
        if event.instance == instanceId then
            local log = logs[eventIndex]
            if log ~= nil then
                local o = event.order or 99
                if groups[o] == nil then
                    groups[o] = { name = event.name, tiers = {}, minIndex = eventIndex }
                else
                    if eventIndex < groups[o].minIndex then groups[o].minIndex = eventIndex end
                end
                local t = groups[o].tiers
                t[#t + 1] = {
                    tier        = tostring(event.tier),
                    tierOrder   = tierOrder(event.tier),
                    time        = math.max(0, log.timeOfDeath - currentTime),
                    timeOfDeath = log.timeOfDeath,
                    value       = log.value,
                }
            end
        end
    end

    local keys = {}
    for o in pairs(groups) do keys[#keys + 1] = o end
    table.sort(keys, function(a, b) return groups[a].minIndex < groups[b].minIndex end)

    local result = {}
    for _, o in ipairs(keys) do
        local g = groups[o]
        table.sort(g.tiers, function(a, b) return a.tierOrder > b.tierOrder end)
        result[#result + 1] = g
    end
    return result
end

-- ------------------------------------------------------------------------------------------------
-- Shared helper: appends tier-header + boss rows for one instance into the listbox.
-- Caller is responsible for clearing and setting up currentRows before the first call.
function ContentView:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth, tierFilter)

    -- build: tiers[tierName] = { order, bosses = { bossOrder → { name, indices[] } } }
    local tiers = {}
    for eventIndex, event in pairs(_G.Events) do
        if event.instance == instanceId then
            local tierName = tostring(event.tier)
            if tiers[tierName] == nil then
                tiers[tierName] = { order = tierOrder(event.tier), bosses = {} }
            end
            local o = event.order or 99
            if tiers[tierName].bosses[o] == nil then
                tiers[tierName].bosses[o] = { name = event.name, indices = {} }
            end
            local idx = tiers[tierName].bosses[o].indices
            idx[#idx + 1] = eventIndex
        end
    end

    local sortedTierNames = {}
    for tierName in pairs(tiers) do sortedTierNames[#sortedTierNames + 1] = tierName end
    table.sort(sortedTierNames, function(a, b) return tiers[a].order > tiers[b].order end)

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    local renderedTiers = 0
    for _, tierName in ipairs(sortedTierNames) do
        if tierFilter == nil or tierFilter(tierName) then
            renderedTiers = renderedTiers + 1
            local tierData = tiers[tierName]

            addRow(self:MakeTierHeaderRow(instanceId, tierName))

            local sortedBossOrders = {}
            for o in pairs(tierData.bosses) do sortedBossOrders[#sortedBossOrders + 1] = o end
            table.sort(sortedBossOrders)

            for _, o in ipairs(sortedBossOrders) do
                local boss = tierData.bosses[o]

                local completedChars  = {}
                local completedValues = {}
                local timeRemaining   = 0
                local timeOfDeath     = 0
                for _, character in ipairs(chars) do
                    for _, ei in ipairs(boss.indices) do
                        if character.logs and character.logs[ei] ~= nil then
                            timeOfDeath   = character.logs[ei].timeOfDeath
                            timeRemaining = math.max(0, timeOfDeath - currentTime)
                            completedChars[#completedChars + 1]  = character
                            completedValues[#completedValues + 1] = character.logs[ei].value
                            break
                        end
                    end
                end

                local timeText = #completedChars > 0 and FormatTimeRemaining(timeRemaining, timeOfDeath) or "—"
                addRow(self:MakeInstanceBossRow(boss.name, completedChars, timeText, completedValues))
            end
        end
    end

    return renderedTiers > 0

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowCustomListView()

    self.listbox:ClearItems()
    self.currentRows = {}

    local listWidth   = self.listbox:GetWidth()
    local currentTime = Turbine.Engine.GetLocalTime()

    local chars = {}
    for charId, character in pairs(_G.Logs) do
        if character.enabled then chars[#chars + 1] = character end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    local hadContent = false

    local contentIndices = {}
    for contentIndex in pairs(_G.Content) do contentIndices[#contentIndices + 1] = contentIndex end
    table.sort(contentIndices, function(a, b) return a > b end)

    for _, contentIndex in ipairs(contentIndices) do

        local contentInstanceIds = {}
        for instanceId, instance in pairs(_G.Instances) do
            if instance.content == contentIndex then
                local todoTiers = _G.Settings.customList[instanceId]
                if todoTiers ~= nil then
                    for _, selected in pairs(todoTiers) do
                        if selected then
                            contentInstanceIds[#contentInstanceIds + 1] = instanceId
                            break
                        end
                    end
                end
            end
        end
        table.sort(contentInstanceIds, function(a, b) return a > b end)

        if #contentInstanceIds > 0 then
            hadContent = true
            for _, instanceId in ipairs(contentInstanceIds) do
                addRow(self:MakeInstanceRow(_G.Instances[instanceId]))
                local todoTiers = _G.Settings.customList[instanceId]
                self:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth, function(tierName)
                    return todoTiers ~= nil and todoTiers[tierName] == true
                end)
            end
        end

    end

    if not hadContent then
        local row = self:MakeEmptyRow(_G.L("emptyCustomList"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ClearCharacterLogs()

    local charId = _G.Settings.selected.character
    if charId == nil then return end
    local character = _G.Logs[charId]
    if character == nil then return end
    character.logs = {}
    _G.SaveLogs()
    self:UpdateContent()

end

function ContentView:DeleteCharacter()

    local charId = _G.Settings.selected.character
    if charId == nil or charId == _G.characterId then return end
    _G.Logs[charId] = nil
    _G.Settings.selected.character = nil
    _G.SaveLogs()
    _G.SaveSettings()
    _G.Window.sidebar:ClearSelection()
    self:UpdateContent()

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowInstanceView(instanceId)

    self.listbox:ClearItems()
    self.currentRows = {}

    local instance = _G.Instances[instanceId]
    if instance == nil then return end

    local listWidth   = self.listbox:GetWidth()
    local currentTime = Turbine.Engine.GetLocalTime()

    local chars = {}
    for charId, character in pairs(_G.Logs) do
        if character.enabled then chars[#chars + 1] = character end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)

    local hadContent = self:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth)

    if not hadContent then
        local row = self:MakeEmptyRow(_G.L("emptyInstance"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowContentView(contentId)

    self.listbox:ClearItems()
    self.currentRows = {}

    local content = _G.Content[contentId]
    if content == nil then return end

    local listWidth   = self.listbox:GetWidth()
    local currentTime = Turbine.Engine.GetLocalTime()

    local chars = {}
    for charId, character in pairs(_G.Logs) do
        if character.enabled then chars[#chars + 1] = character end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)

    local instanceIds = {}
    for instanceId, instance in pairs(_G.Instances) do
        if instance.content == contentId then
            instanceIds[#instanceIds + 1] = instanceId
        end
    end
    table.sort(instanceIds, function(a, b) return a > b end)

    if #instanceIds == 0 then
        local row = self:MakeEmptyRow(_G.L("emptyContent"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
        return
    end

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    for _, instanceId in ipairs(instanceIds) do
        addRow(self:MakeInstanceRow(_G.Instances[instanceId]))
        self:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth)
    end

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowCharacterView(characterId)

    self.listbox:ClearItems()
    self.currentRows = {}

    local character = _G.Logs[characterId]
    if character == nil then return end

    local currentTime = Turbine.Engine.GetLocalTime()
    local listWidth   = self.listbox:GetWidth()

    local contentIndices = {}
    for contentIndex in pairs(_G.Content) do contentIndices[#contentIndices + 1] = contentIndex end
    table.sort(contentIndices, function(a, b) return a > b end)

    for _, contentIndex in ipairs(contentIndices) do
        local content = _G.Content[contentIndex]

        local contentRow = self:MakeContentRow(content)
        contentRow:SetWidth(listWidth)
        local eventRows = {}

        local instanceIds = {}
        for instanceId, instance in pairs(_G.Instances) do
            if instance.content == contentIndex then instanceIds[#instanceIds + 1] = instanceId end
        end
        table.sort(instanceIds, function(a, b) return a > b end)

        for _, instanceId in ipairs(instanceIds) do
            local instance = _G.Instances[instanceId]
            local groups = collectOrderGroups(instanceId, character.logs, currentTime)

            if #groups > 0 then
                local instanceRow = self:MakeInstanceRow(instance, true)
                instanceRow:SetWidth(listWidth)
                eventRows[#eventRows + 1] = instanceRow

                for _, group in ipairs(groups) do
                    local nameRow = self:MakeBossNameRow(group.name)
                    nameRow:SetWidth(listWidth)
                    eventRows[#eventRows + 1] = nameRow
                    for _, t in ipairs(group.tiers) do
                        local tierRow = self:MakeBossTierRow(t)
                        tierRow:SetWidth(listWidth)
                        eventRows[#eventRows + 1] = tierRow
                    end
                end
            end
        end

        if #eventRows > 0 then
            self.listbox:AddItem(contentRow)
            self.currentRows[#self.currentRows + 1] = contentRow
            for _, r in ipairs(eventRows) do
                self.listbox:AddItem(r)
                self.currentRows[#self.currentRows + 1] = r
            end
        end

    end

    if #self.currentRows == 0 then
        local row = self:MakeEmptyRow(_G.L("emptyCharacter"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowServerView(serverName)

    self.listbox:ClearItems()
    self.currentRows = {}

    local currentTime = Turbine.Engine.GetLocalTime()
    local listWidth   = self.listbox:GetWidth()

    local serverChars = {}
    for charId, character in pairs(_G.Logs) do
        if character.server == serverName and character.enabled then
            serverChars[#serverChars + 1] = { id = charId, character = character }
        end
    end
    table.sort(serverChars, function(a, b)
        return a.character.name < b.character.name
    end)

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    for _, entry in ipairs(serverChars) do
        local character  = entry.character
        local charRows   = {}

        local contentIndices = {}
        for contentIndex in pairs(_G.Content) do contentIndices[#contentIndices + 1] = contentIndex end
        table.sort(contentIndices, function(a, b) return a > b end)

        for _, contentIndex in ipairs(contentIndices) do
            local instanceIds = {}
            for instanceId, instance in pairs(_G.Instances) do
                if instance.content == contentIndex then instanceIds[#instanceIds + 1] = instanceId end
            end
            table.sort(instanceIds, function(a, b) return a > b end)

            for _, instanceId in ipairs(instanceIds) do
                local instance = _G.Instances[instanceId]
                local groups = collectOrderGroups(instanceId, character.logs, currentTime)
                if #groups > 0 then
                    charRows[#charRows + 1] = self:MakeInstanceRow(instance, true)
                    for _, group in ipairs(groups) do
                        charRows[#charRows + 1] = self:MakeBossNameRow(group.name)
                        for _, t in ipairs(group.tiers) do
                            charRows[#charRows + 1] = self:MakeBossTierRow(t)
                        end
                    end
                end
            end
        end

        if #charRows > 0 then
            addRow(self:MakeCharacterHeaderRow(character))
            for _, r in ipairs(charRows) do
                addRow(r)
            end
        end
    end

    if #self.currentRows == 0 then
        local row = self:MakeEmptyRow(_G.L("emptyServer"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeTierHeaderRow(instanceId, tierName)

    local row = Turbine.UI.Control()
    row:SetHeight(32)
    row:SetBackColor(_G.Theme.SECTION)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.HEADER) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(12, 9)
    accent:SetSize(2, 14)
    accent:SetBackColor(_G.Theme.HOVER)
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(22, 0)
    label:SetHeight(32)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.ACCENT)
    label:SetText(tierName)
    label:SetMouseVisible(false)

    -- custom list toggle
    local checkHover = false

    local checkFrame = Turbine.UI.Control()
    checkFrame:SetParent(row)
    checkFrame:SetSize(14, 14)
    checkFrame:SetBackColor(_G.Theme.FRAME)

    local checkBg = Turbine.UI.Control()
    checkBg:SetParent(checkFrame)
    checkBg:SetPosition(1, 1)
    checkBg:SetSize(12, 12)
    checkBg:SetMouseVisible(false)

    local function isChecked()
        local t = _G.Settings.customList
        return t[instanceId] ~= nil and t[instanceId][tierName] == true
    end

    local function updateCheckVisual()
        if isChecked() then
            checkBg:SetBackColor(_G.Theme.HOVER)
        else
            checkBg:SetBackColor(_G.Theme.BG)
        end
    end

    updateCheckVisual()

    -- hover tooltip label
    local hoverLabel = Turbine.UI.Label()
    hoverLabel:SetParent(row)
    hoverLabel:SetHeight(32)
    hoverLabel:SetPosition(22, 0)
    hoverLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    hoverLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    hoverLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    hoverLabel:SetForeColor(_G.Theme.DIM2)
    hoverLabel:SetText(_G.L("customListHover"))
    hoverLabel:SetVisible(false)
    hoverLabel:SetMouseVisible(false)

    checkFrame.MouseEnter = function()
        checkHover = true
        checkFrame:SetBackColor(_G.Theme.HOVER)
        hoverLabel:SetVisible(true)
    end
    checkFrame.MouseLeave = function()
        checkHover = false
        checkFrame:SetBackColor(_G.Theme.FRAME)
        hoverLabel:SetVisible(false)
    end
    checkFrame.MouseDown = function()
        checkBg:SetBackColor(_G.Theme.SEL_BG)
    end
    checkFrame.MouseUp = function()
        if checkHover then
            if _G.Settings.customList[instanceId] == nil then
                _G.Settings.customList[instanceId] = {}
            end
            _G.Settings.customList[instanceId][tierName] = not isChecked()
            _G.SaveSettings()
            updateCheckVisual()
        end
    end

    row.SizeChanged = function()
        local w = row:GetWidth()
        label:SetWidth(w - 22 - 24)
        checkFrame:SetTop(9)
        checkFrame:SetLeft(w - 20)
        hoverLabel:SetWidth(w - 22 - 24 - 6)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeInstanceBossRow(bossName, completedChars, timeText, values)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(_G.Theme.PANEL)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.HEADER) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.PANEL) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(20, 6)
    accent:SetSize(2, 14)
    accent:SetBackColor(_G.Theme.FRAME)
    accent:SetMouseVisible(false)

    local bossLabel = Turbine.UI.Label()
    bossLabel:SetParent(row)
    bossLabel:SetPosition(30, 0)
    bossLabel:SetHeight(26)
    bossLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    bossLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    bossLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    bossLabel:SetForeColor(_G.Theme.TEXT)
    bossLabel:SetText(bossName)
    bossLabel:SetMouseVisible(false)

    local charText
    local tooltipText = nil

    if #completedChars == 0 then
        charText = "—"
    else
        local parts = {}
        for i, char in ipairs(completedChars) do
            local v = values and values[i]
            local suffix = (v and v ~= "Done") and (" " .. v) or ""
            parts[#parts + 1] = char.name .. suffix
        end
        if #completedChars <= 3 then
            charText = table.concat(parts, ",  ")
        else
            charText = parts[1] .. ",  " .. parts[2] .. ",  " .. parts[3] .. "  ···"
            tooltipText = table.concat(parts, "\n")
        end
    end

    local charsLabel = Turbine.UI.Label()
    charsLabel:SetParent(row)
    charsLabel:SetHeight(26)
    charsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    charsLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    charsLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    if #completedChars == 0 then
        charsLabel:SetForeColor(_G.Theme.DIM)
    else
        charsLabel:SetForeColor(_G.Theme.DIM2)
    end
    charsLabel:SetText(charText)
    charsLabel:SetMouseVisible(false)

    local timeLabel = Turbine.UI.Label()
    timeLabel:SetParent(row)
    timeLabel:SetHeight(26)
    timeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    timeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    timeLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    if #completedChars == 0 then
        timeLabel:SetForeColor(_G.Theme.DIM)
    else
        timeLabel:SetForeColor(_G.Theme.ACCENT)
    end
    timeLabel:SetText(timeText .. "  ")
    timeLabel:SetMouseVisible(false)

    local TIME_W = (_G.Settings.timeDisplay == "timestamp" and 140)
              or  (_G.Settings.timeDisplay == "both" and 95)
              or  68

    row.SizeChanged = function()
        local w      = row:GetWidth()
        local bossW  = math.floor(w * 0.34)
        bossLabel:SetWidth(bossW)
        charsLabel:SetLeft(30 + bossW)
        charsLabel:SetWidth(w - 30 - bossW - TIME_W)
        timeLabel:SetLeft(w - TIME_W)
        timeLabel:SetWidth(TIME_W)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeBossNameRow(name)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(_G.Theme.PANEL)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.SECTION) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.PANEL) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(20, 6)
    accent:SetSize(2, 14)
    accent:SetBackColor(_G.Theme.HOVER)
    accent:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(30, 0)
    nameLabel:SetHeight(26)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.TEXT)
    nameLabel:SetText(name)
    nameLabel:SetMouseVisible(false)

    row.SizeChanged = function()
        nameLabel:SetWidth(row:GetWidth() - 30)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeBossTierRow(t)

    local TIME_W = (_G.Settings.timeDisplay == "timestamp" and 140)
               or  (_G.Settings.timeDisplay == "both" and 95)
               or  68
    local TIER_W  = 40
    local VALUE_W = 44
    local GAP     = 5
    local LEFT    = 36

    local row = Turbine.UI.Control()
    row:SetHeight(22)
    row:SetBackColor(_G.Theme.BG)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.PANEL) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.BG) end

    local dot = Turbine.UI.Control()
    dot:SetParent(row)
    dot:SetPosition(LEFT - 8, 9)
    dot:SetSize(2, 4)
    dot:SetBackColor(_G.Theme.FRAME)
    dot:SetMouseVisible(false)

    local tierLabel = Turbine.UI.Label()
    tierLabel:SetParent(row)
    tierLabel:SetHeight(22)
    tierLabel:SetWidth(TIER_W)
    tierLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    tierLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    tierLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    tierLabel:SetForeColor(_G.Theme.HOVER)
    tierLabel:SetText(t.tier)
    tierLabel:SetMouseVisible(false)

    local valueLabel = nil
    if t.value then
        valueLabel = Turbine.UI.Label()
        valueLabel:SetParent(row)
        valueLabel:SetHeight(22)
        valueLabel:SetWidth(VALUE_W)
        valueLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        valueLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        valueLabel:SetFontStyle(_G.Theme.FONT_STYLE)
        valueLabel:SetForeColor(_G.Theme.DIM2)
        valueLabel:SetText(t.value)
        valueLabel:SetMouseVisible(false)
    end

    local timeLabel = Turbine.UI.Label()
    timeLabel:SetParent(row)
    timeLabel:SetHeight(22)
    timeLabel:SetWidth(TIME_W)
    timeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    timeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    timeLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    timeLabel:SetForeColor(_G.Theme.ACCENT)
    timeLabel:SetText(FormatTimeRemaining(t.time, t.timeOfDeath))
    timeLabel:SetMouseVisible(false)

    row.SizeChanged = function()
        local w = row:GetWidth()
        tierLabel:SetLeft(LEFT)
        if valueLabel then
            valueLabel:SetLeft(LEFT + TIER_W + GAP)
        end
        timeLabel:SetLeft(w - TIME_W)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeCharacterHeaderRow(character)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.SECTION)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.PRESS) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(_G.Theme.HOVER)
    accent:SetMouseVisible(false)

    local classIcon = Turbine.UI.Control()
    classIcon:SetParent(row)
    classIcon:SetPosition(10, 7)
    classIcon:SetSize(20, 20)
    classIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    classIcon:SetBackground(_G.ClassIcons[character.class])
    classIcon:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(36, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.ACCENT)
    nameLabel:SetText(character.name)
    nameLabel:SetMouseVisible(false)

    row.SizeChanged = function()
        nameLabel:SetWidth(row:GetWidth() - 32)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeContentRow(content)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(_G.Theme.PRESS)
    row.MouseEnter = function() row:SetBackColor(_G.Theme.SEL_BG) end
    row.MouseLeave = function() row:SetBackColor(_G.Theme.PRESS) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(_G.Theme.HOVER)
    accent:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.ACCENT)
    nameLabel:SetText(content.name)
    nameLabel:SetMouseVisible(false)

    local levelLabel = Turbine.UI.Label()
    levelLabel:SetParent(row)
    levelLabel:SetHeight(34)
    levelLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    levelLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    levelLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    levelLabel:SetForeColor(_G.Theme.DIM2)
    levelLabel:SetText(_G.L("levelPrefix") .. content.level .. "  ")
    levelLabel:SetMouseVisible(false)

    row.SizeChanged = function()
        local w = row:GetWidth()
        nameLabel:SetWidth(math.floor(w * 0.65))
        levelLabel:SetWidth(math.floor(w * 0.35))
        levelLabel:SetLeft(math.floor(w * 0.65))
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeInstanceRow(instance, indented)

    local row = Turbine.UI.Control()

    if indented then
        row:SetHeight(28)
        row:SetBackColor(_G.Theme.SECTION)
        row.MouseEnter = function() row:SetBackColor(_G.Theme.HEADER) end
        row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end

        local accent = Turbine.UI.Control()
        accent:SetParent(row)
        accent:SetPosition(12, 7)
        accent:SetSize(2, 14)
        accent:SetBackColor(_G.Theme.HOVER)
        accent:SetMouseVisible(false)

        local label = Turbine.UI.Label()
        label:SetParent(row)
        label:SetPosition(22, 0)
        label:SetHeight(28)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.ACCENT)
        label:SetText(instance.name)
        label:SetMouseVisible(false)

        row.SizeChanged = function()
            label:SetWidth(row:GetWidth() - 22)
        end
    else
        row:SetHeight(30)
        row:SetBackColor(_G.Theme.SECTION)
        row.MouseEnter = function() row:SetBackColor(_G.Theme.PRESS) end
        row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end

        local accent = Turbine.UI.Control()
        accent:SetParent(row)
        accent:SetPosition(0, 0)
        accent:SetSize(3, 30)
        accent:SetBackColor(_G.Theme.HOVER)
        accent:SetMouseVisible(false)

        local label = Turbine.UI.Label()
        label:SetParent(row)
        label:SetPosition(12, 0)
        label:SetHeight(30)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.ACCENT)
        label:SetText(instance.name)
        label:SetMouseVisible(false)

        row.SizeChanged = function()
            label:SetWidth(row:GetWidth() - 12)
        end
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeEmptyRow(message)

    local row = Turbine.UI.Control()
    row:SetHeight(40)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(0, 0)
    label:SetHeight(40)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM)
    label:SetText(message)
    label:SetMouseVisible(false)

    row.SizeChanged = function()
        label:SetWidth(row:GetWidth())
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:SizeChanged()

    local width, height = self:GetSize()

    self.background1:SetSize(width - 10, height - 10)
    self.frame1:SetSize(width - 20, height - 20)

    -- header + separator = 33px
    local headerW = width - 22
    self.header:SetWidth(headerW)
    self.headerName:SetWidth(headerW - 168)
    self.headerType:SetWidth(80)
    self.headerType:SetLeft(headerW - 148)
    self.separator:SetWidth(headerW)
    self.clearLogsFrame:SetPosition(headerW - 64, 5)
    self.deleteCharFrame:SetPosition(headerW - 34, 5)
    self.headerTooltip:SetWidth(headerW - 70)

    local listW = headerW - 12
    self.background2:SetSize(headerW, height - 55)
    self.listbox:SetSize(listW, height - 55)
    self.scrollbar:SetPosition(listW, 0)
    self.scrollbar:SetHeight(height - 55)

    local listWidth = listW
    for _, row in ipairs(self.currentRows) do
        row:SetWidth(listWidth)
    end

end

function ContentView:Build()

    self:SetBackColor(_G.Theme.OUTER)

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(_G.Theme.BG)
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(_G.Theme.FRAME)
    self.frame1:SetPosition(5, 5)

    -- header bar
    self.header = Turbine.UI.Control()
    self.header:SetParent(self.frame1)
    self.header:SetPosition(1, 1)
    self.header:SetHeight(32)
    self.header:SetBackColor(_G.Theme.HEADER)

    self.headerIcon = Turbine.UI.Control()
    self.headerIcon:SetParent(self.header)
    self.headerIcon:SetPosition(8, 8)
    self.headerIcon:SetSize(20, 20)
    self.headerIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.headerIcon:SetVisible(false)
    self.headerIcon:SetMouseVisible(false)

    self.headerName = Turbine.UI.Label()
    self.headerName:SetParent(self.header)
    self.headerName:SetPosition(10, 0)
    self.headerName:SetHeight(32)
    self.headerName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerName:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.headerName:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerName:SetForeColor(_G.Theme.ACCENT)
    self.headerName:SetMouseVisible(false)

    self.headerType = Turbine.UI.Label()
    self.headerType:SetParent(self.header)
    self.headerType:SetHeight(32)
    self.headerType:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.headerType:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.headerType:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerType:SetForeColor(_G.Theme.DIM)
    self.headerType:SetMouseVisible(false)

    -- clear logs button
    self.clearLogsFrame = Turbine.UI.Control()
    self.clearLogsFrame:SetParent(self.header)
    self.clearLogsFrame:SetSize(28, 22)
    self.clearLogsFrame:SetBackColor(_G.Theme.FRAME)
    self.clearLogsFrame:SetVisible(false)

    self.clearLogsBg = Turbine.UI.Control()
    self.clearLogsBg:SetParent(self.clearLogsFrame)
    self.clearLogsBg:SetPosition(1, 1)
    self.clearLogsBg:SetSize(26, 20)
    self.clearLogsBg:SetBackColor(_G.Theme.BG)

    local clearHover = false
    self.clearLogsBg.MouseEnter = function()
        clearHover = true
        self.clearLogsFrame:SetBackColor(_G.Theme.HOVER)
        self.headerTooltip:SetText(_G.L("clearLogsTooltip"))
        self.headerTooltip:SetVisible(true)
        self.headerType:SetVisible(false)
    end
    self.clearLogsBg.MouseLeave = function()
        clearHover = false
        self.clearLogsFrame:SetBackColor(_G.Theme.FRAME)
        self.headerTooltip:SetVisible(false)
        self.headerType:SetVisible(true)
    end
    self.clearLogsBg.MouseDown = function()
        self.clearLogsBg:SetBackColor(_G.Theme.PRESS)
    end
    self.clearLogsBg.MouseUp = function()
        self.clearLogsBg:SetBackColor(_G.Theme.BG)
        if clearHover then
            self:ClearCharacterLogs()
        end
    end

    self.clearLogsLabel = Turbine.UI.Label()
    self.clearLogsLabel:SetParent(self.clearLogsBg)
    self.clearLogsLabel:SetSize(26, 20)
    self.clearLogsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.clearLogsLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.clearLogsLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.clearLogsLabel:SetText(_G.L("clearLogsBtn"))
    self.clearLogsLabel:SetMouseVisible(false)
    self.clearLogsLabel:SetForeColor(_G.Theme.DIM2)

    -- delete character button
    self.deleteCharDisabled = false

    self.deleteCharFrame = Turbine.UI.Control()
    self.deleteCharFrame:SetParent(self.header)
    self.deleteCharFrame:SetSize(28, 22)
    self.deleteCharFrame:SetBackColor(_G.Theme.FRAME)
    self.deleteCharFrame:SetVisible(false)

    self.deleteCharBg = Turbine.UI.Control()
    self.deleteCharBg:SetParent(self.deleteCharFrame)
    self.deleteCharBg:SetPosition(1, 1)
    self.deleteCharBg:SetSize(26, 20)
    self.deleteCharBg:SetBackColor(_G.Theme.BG)

    local deleteHover = false
    self.deleteCharBg.MouseEnter = function()
        if not self.deleteCharDisabled then
            deleteHover = true
            self.deleteCharFrame:SetBackColor(_G.Theme.HOVER)
            self.headerTooltip:SetText(_G.L("deleteCharTooltip"))
        else
            self.headerTooltip:SetText(_G.L("deleteCharTooltipDisabled"))
        end
        self.headerTooltip:SetVisible(true)
        self.headerType:SetVisible(false)
    end
    self.deleteCharBg.MouseLeave = function()
        deleteHover = false
        self.deleteCharFrame:SetBackColor(_G.Theme.FRAME)
        self.headerTooltip:SetVisible(false)
        self.headerType:SetVisible(true)
    end
    self.deleteCharBg.MouseDown = function()
        if not self.deleteCharDisabled then
            self.deleteCharBg:SetBackColor(_G.Theme.PRESS)
        end
    end
    self.deleteCharBg.MouseUp = function()
        self.deleteCharBg:SetBackColor(_G.Theme.BG)
        if deleteHover and not self.deleteCharDisabled then
            self:DeleteCharacter()
        end
    end

    self.deleteCharLabel = Turbine.UI.Label()
    self.deleteCharLabel:SetParent(self.deleteCharBg)
    self.deleteCharLabel:SetSize(26, 20)
    self.deleteCharLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.deleteCharLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.deleteCharLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.deleteCharLabel:SetText(_G.L("deleteCharBtn"))
    self.deleteCharLabel:SetMouseVisible(false)
    self.deleteCharLabel:SetForeColor(_G.Theme.DIM2)

    -- shared tooltip label for the two character action buttons
    self.headerTooltip = Turbine.UI.Label()
    self.headerTooltip:SetParent(self.header)
    self.headerTooltip:SetPosition(0, 0)
    self.headerTooltip:SetHeight(32)
    self.headerTooltip:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.headerTooltip:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.headerTooltip:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerTooltip:SetForeColor(_G.Theme.DIM2)
    self.headerTooltip:SetVisible(false)
    self.headerTooltip:SetMouseVisible(false)

    -- separator line
    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self.frame1)
    self.separator:SetPosition(1, 33)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(_G.Theme.FRAME)

    -- content area below header
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

end
