
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

local function FormatTimeRemaining(seconds)
    if seconds <= 0 then return "< 1m" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if d > 0 then return d .. "d " .. h .. "h"
    elseif h > 0 then return h .. "h " .. m .. "m"
    else return m .. "m"
    end
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
                    groups[o] = { name = event.name, tiers = {} }
                end
                local t = groups[o].tiers
                t[#t + 1] = {
                    tier      = tostring(event.tier),
                    tierOrder = tierOrder(event.tier),
                    time      = math.max(0, log.timeOfDeath - currentTime),
                }
            end
        end
    end

    local keys = {}
    for o in pairs(groups) do keys[#keys + 1] = o end
    table.sort(keys)

    local result = {}
    for _, o in ipairs(keys) do
        local g = groups[o]
        table.sort(g.tiers, function(a, b) return a.tierOrder < b.tierOrder end)
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
    table.sort(sortedTierNames, function(a, b) return tiers[a].order < tiers[b].order end)

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

                local completedChars = {}
                local timeRemaining  = 0
                for _, character in ipairs(chars) do
                    for _, ei in ipairs(boss.indices) do
                        if character.logs and character.logs[ei] ~= nil then
                            timeRemaining = math.max(0, character.logs[ei].timeOfDeath - currentTime)
                            completedChars[#completedChars + 1] = character
                            break
                        end
                    end
                end

                local timeText = #completedChars > 0 and FormatTimeRemaining(timeRemaining) or "—"
                addRow(self:MakeInstanceBossRow(boss.name, completedChars, timeText))
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

    for contentIndex, content in ipairs(_G.Content) do

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
        table.sort(contentInstanceIds)

        if #contentInstanceIds > 0 then
            hadContent = true
            addRow(self:MakeContentRow(content))
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
    table.sort(instanceIds)

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

    for contentIndex, content in ipairs(_G.Content) do

        local contentRow = self:MakeContentRow(content)
        contentRow:SetWidth(listWidth)
        local eventRows = {}

        for instanceId, instance in pairs(_G.Instances) do
            if instance.content == contentIndex then

                local groups = collectOrderGroups(instanceId, character.logs, currentTime)

                if #groups > 0 then
                    local instanceRow = self:MakeInstanceRow(instance)
                    instanceRow:SetWidth(listWidth)
                    eventRows[#eventRows + 1] = instanceRow

                    for _, group in ipairs(groups) do
                        local row = self:MakeCombinedEventRow(group.name, group.tiers)
                        row:SetWidth(listWidth)
                        eventRows[#eventRows + 1] = row
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

        for contentIndex, _ in ipairs(_G.Content) do
            for instanceId, instance in pairs(_G.Instances) do
                if instance.content == contentIndex then
                    local groups = collectOrderGroups(instanceId, character.logs, currentTime)
                    if #groups > 0 then
                        charRows[#charRows + 1] = self:MakeInstanceRow(instance)
                        for _, group in ipairs(groups) do
                            charRows[#charRows + 1] = self:MakeCombinedEventRow(group.name, group.tiers)
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
    row:SetHeight(28)
    row:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.16, 0.13, 0.07)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(10, 7)
    accent:SetSize(2, 14)
    accent:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(20, 0)
    label:SetHeight(28)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    label:SetFontStyle(Turbine.UI.FontStyle.Outline)
    label:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))
    label:SetText(tierName)
    label:SetMouseVisible(false)

    -- custom list toggle
    local checkHover = false

    local checkFrame = Turbine.UI.Control()
    checkFrame:SetParent(row)
    checkFrame:SetSize(14, 14)
    checkFrame:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))

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
            checkBg:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
        else
            checkBg:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        end
    end

    updateCheckVisual()

    -- hover tooltip label
    local hoverLabel = Turbine.UI.Label()
    hoverLabel:SetParent(row)
    hoverLabel:SetHeight(28)
    hoverLabel:SetPosition(20, 0)
    hoverLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    hoverLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    hoverLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    hoverLabel:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    hoverLabel:SetText(_G.L("customListHover"))
    hoverLabel:SetVisible(false)
    hoverLabel:SetMouseVisible(false)

    checkFrame.MouseEnter = function()
        checkHover = true
        checkFrame:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
        hoverLabel:SetVisible(true)
    end
    checkFrame.MouseLeave = function()
        checkHover = false
        checkFrame:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
        hoverLabel:SetVisible(false)
    end
    checkFrame.MouseDown = function()
        checkBg:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
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
        label:SetWidth(w - 20 - 24)
        checkFrame:SetTop(7)
        checkFrame:SetLeft(w - 20)
        hoverLabel:SetWidth(w - 20 - 24 - 6)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeInstanceBossRow(bossName, completedChars, timeText)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.11, 0.09, 0.05)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(20, 6)
    accent:SetSize(2, 14)
    accent:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    accent:SetMouseVisible(false)

    local bossLabel = Turbine.UI.Label()
    bossLabel:SetParent(row)
    bossLabel:SetPosition(30, 0)
    bossLabel:SetHeight(26)
    bossLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    bossLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    bossLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    bossLabel:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))
    bossLabel:SetText(bossName)
    bossLabel:SetMouseVisible(false)

    local charText
    local tooltipText = nil

    if #completedChars == 0 then
        charText = "—"
    else
        local parts = {}
        for _, char in ipairs(completedChars) do
            parts[#parts + 1] = char.name
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
    charsLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    if #completedChars == 0 then
        charsLabel:SetForeColor(Turbine.UI.Color(0.30, 0.26, 0.18))
    else
        charsLabel:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))
    end
    charsLabel:SetText(charText)
    charsLabel:SetMouseVisible(false)

    local timeLabel = Turbine.UI.Label()
    timeLabel:SetParent(row)
    timeLabel:SetHeight(26)
    timeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    timeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    timeLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    if #completedChars == 0 then
        timeLabel:SetForeColor(Turbine.UI.Color(0.30, 0.26, 0.18))
    else
        timeLabel:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    end
    timeLabel:SetText(timeText .. "  ")
    timeLabel:SetMouseVisible(false)

    local TIME_W = 68

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

function ContentView:MakeCombinedEventRow(name, tiers)

    local row = Turbine.UI.Control()
    row:SetHeight(26)
    row:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.13, 0.11, 0.07)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(20, 6)
    accent:SetSize(2, 14)
    accent:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    accent:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(30, 0)
    nameLabel:SetHeight(26)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))
    nameLabel:SetText(name)
    nameLabel:SetMouseVisible(false)

    local parts = {}
    for _, t in ipairs(tiers) do
        parts[#parts + 1] = t.tier .. "  " .. FormatTimeRemaining(t.time)
    end

    local tiersLabel = Turbine.UI.Label()
    tiersLabel:SetParent(row)
    tiersLabel:SetHeight(26)
    tiersLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    tiersLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    tiersLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    tiersLabel:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    tiersLabel:SetText(table.concat(parts, "   ·   ") .. "  ")
    tiersLabel:SetMouseVisible(false)

    row.SizeChanged = function()
        local w         = row:GetWidth()
        local nameWidth = math.floor(w * 0.38)
        nameLabel:SetWidth(nameWidth)
        tiersLabel:SetLeft(30 + nameWidth)
        tiersLabel:SetWidth(w - 30 - nameWidth)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeCharacterHeaderRow(character)

    local row = Turbine.UI.Control()
    row:SetHeight(34)
    row:SetBackColor(Turbine.UI.Color(0.14, 0.11, 0.05))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.21, 0.17, 0.08)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.14, 0.11, 0.05)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
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
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
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
    row:SetBackColor(Turbine.UI.Color(0.18, 0.14, 0.06))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.25, 0.20, 0.09)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.18, 0.14, 0.06)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 34)
    accent:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    accent:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    nameLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    nameLabel:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    nameLabel:SetText(content.name)
    nameLabel:SetMouseVisible(false)

    local levelLabel = Turbine.UI.Label()
    levelLabel:SetParent(row)
    levelLabel:SetHeight(34)
    levelLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    levelLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    levelLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    levelLabel:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
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

function ContentView:MakeInstanceRow(instance)

    local row = Turbine.UI.Control()
    row:SetHeight(30)
    row:SetBackColor(Turbine.UI.Color(0.14, 0.11, 0.05))
    row.MouseEnter = function() row:SetBackColor(Turbine.UI.Color(0.20, 0.16, 0.07)) end
    row.MouseLeave = function() row:SetBackColor(Turbine.UI.Color(0.14, 0.11, 0.05)) end

    local accent = Turbine.UI.Control()
    accent:SetParent(row)
    accent:SetPosition(0, 0)
    accent:SetSize(3, 30)
    accent:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    accent:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(12, 0)
    label:SetHeight(30)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    label:SetFontStyle(Turbine.UI.FontStyle.Outline)
    label:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    label:SetText(instance.name)
    label:SetMouseVisible(false)

    row.SizeChanged = function()
        label:SetWidth(row:GetWidth() - 12)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeEmptyRow(message)

    local row = Turbine.UI.Control()
    row:SetHeight(40)
    row:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))
    row:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetParent(row)
    label:SetPosition(0, 0)
    label:SetHeight(40)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    label:SetFontStyle(Turbine.UI.FontStyle.Outline)
    label:SetForeColor(Turbine.UI.Color(0.45, 0.38, 0.26))
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
    self.headerName:SetWidth(headerW - 100)
    self.headerType:SetWidth(80)
    self.headerType:SetLeft(headerW - 82)
    self.separator:SetWidth(headerW)

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

    self:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.12))

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    self.frame1:SetPosition(5, 5)

    -- header bar
    self.header = Turbine.UI.Control()
    self.header:SetParent(self.frame1)
    self.header:SetPosition(1, 1)
    self.header:SetHeight(32)
    self.header:SetBackColor(Turbine.UI.Color(0.12, 0.10, 0.06))

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
    self.headerName:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.headerName:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    self.headerName:SetMouseVisible(false)

    self.headerType = Turbine.UI.Label()
    self.headerType:SetParent(self.header)
    self.headerType:SetHeight(32)
    self.headerType:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.headerType:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.headerType:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.headerType:SetForeColor(Turbine.UI.Color(0.45, 0.38, 0.26))
    self.headerType:SetMouseVisible(false)

    -- separator line
    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self.frame1)
    self.separator:SetPosition(1, 33)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))

    -- content area below header
    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))
    self.background2:SetPosition(1, 34)

    self.listbox = Turbine.UI.ListBox()
    self.listbox:SetParent(self.background2)
    self.listbox:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))

    self.scrollbar = Turbine.UI.Lotro.ScrollBar()
    self.scrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollbar:SetParent(self.background2)
    self.scrollbar:SetWidth(10)
    self.listbox:SetVerticalScrollBar(self.scrollbar)

end
