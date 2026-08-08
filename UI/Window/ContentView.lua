
-- content panel geometry (docs/design/window-redesign/README.md, section 5)
local BORDER, HEADER_H, LEGEND_H, PILL_W, PILL_H, TYPE_W, ACT_H, ACT_CLEAR_W, ACT_DEL_W

-- instance view geometry, same section
local PAD_X, NAME_W, COL_LEFT, COL_GAP, TIME_W, CHIP_W, CHIP_W_C, CHIP_H, COMPACT_AT,
      COL_LEFT_C, TICK, CARRY, COLHEAD_H, COLHEAD_NESTED_H, TIER_H, TIER_NESTED_H,
      BLOCK_H, COLLAPSED_H, GROUP_H, INSTANCE_INDENT, TIER_INDENT, TIER_LABEL_W,
      ROW_H, STAR, CARET, MARK_W, AMBER_AFTER, GROUP_GAP, SUB_INDENT

-- recomputed when the Font Size setting changes. Icon boxes (TICK, CARRY, STAR, CARET)
-- stay fixed: Turbine clips a .tga rather than resizing it.
local function Metrics()

    BORDER      = 1
    MARK_W      = 2
    -- chests at which the table switches to codes. At the largest font the worded chip
    -- no longer fits four columns in the minimum window, so the switch comes a chest
    -- earlier rather than letting the chips overlap.
    COMPACT_AT  = ((_G.Settings and _G.Settings.fontScale or 0) >= 2) and 4 or 5
    TICK        = 10
    CARRY       = 10            -- carry-over marker
    STAR        = 12            -- pin toggle on a tier band
    CARET       = 12            -- disclosure triangle
    AMBER_AFTER = 3 * 86400     -- countdown turns amber inside three days

    HEADER_H    = _G.Scaled(44)
    LEGEND_H    = _G.Scaled(24)
    PILL_W      = _G.Scaled(108)
    PILL_H      = _G.Scaled(16)
    TYPE_W      = _G.Scaled(70)
    ACT_H       = _G.Scaled(20)  -- character view action buttons
    ACT_CLEAR_W = _G.Scaled(76)
    ACT_DEL_W   = _G.Scaled(58)

    PAD_X       = _G.Scaled(14)
    NAME_W      = _G.Scaled(104)
    COL_LEFT    = _G.Scaled(130)
    COL_LEFT_C  = _G.Scaled(108)
    COL_GAP     = _G.Scaled(8)
    TIME_W      = _G.Scaled(104)
    CHIP_W      = _G.Scaled(64)
    -- the compact chip only ever holds two characters, so it follows the text rather
    -- than the blanket scale; at Large a proportional 44px left no gap between columns
    CHIP_W_C    = math.floor(_G.GlyphWidth(10) * 3) + 14
    CHIP_H      = _G.Scaled(15)

    COLHEAD_H        = _G.Scaled(22)
    COLHEAD_NESTED_H = _G.Scaled(20)   -- inside a pack-view instance block
    TIER_H           = _G.Scaled(26)
    TIER_NESTED_H    = _G.Scaled(24)
    ROW_H            = _G.Scaled(24)
    BLOCK_H          = _G.Scaled(28)   -- instance block header in the pack view
    COLLAPSED_H      = _G.Scaled(22)
    GROUP_H          = _G.Scaled(26)   -- pack / instance header in the character view
    INSTANCE_INDENT  = _G.Scaled(20)
    TIER_INDENT      = _G.Scaled(30)
    TIER_LABEL_W     = _G.Scaled(64)
    GROUP_GAP        = _G.Scaled(6)    -- empty strip above a top-level group band
    SUB_INDENT       = _G.Scaled(14)   -- a tier band sitting under an instance header

end

_G.RegisterMetrics(Metrics)

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
    self:ApplyLegend(false, false)

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

-- Build tiers[tierName] = { order, bosses = { bossOrder -> { name, indices[] } } } for one instance.
local function buildInstanceTiers(instanceId)
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

    return tiers, sortedTierNames
end

-- Five or more chests and the worded chips stop fitting, so the table switches to
-- codes: narrower columns starting further left, and a narrower name column with them.
local function IsCompact(count)
    return count >= COMPACT_AT
end

-- Where the boss columns, the name column and the reset column sit for a given panel
-- width. The handoff quotes 74px columns at x=108 for the 5+ case, but that does not
-- leave room for the 104px reset column at the 702px it was drawn at, so the width is
-- divided out instead.
local function ColumnGeometry(width, count)
    local left     = IsCompact(count) and COL_LEFT_C or COL_LEFT
    local timeLeft = width - PAD_X - TIME_W
    local region   = math.max(0, timeLeft - COL_GAP - left)
    local colWidth = (count > 0) and math.floor(region / count) or 0
    return left, colWidth, timeLeft, math.max(0, left - PAD_X - COL_GAP)
end

-- "weekly  Thu 03:00", "tri-weekly  Mon/Thu/Sat 03:00", "daily  08:00".
-- reset.time is UTC, so the timezone setting can roll the hour past midnight and
-- move the day names with it.
local function ResetSchedule(reset)

    if reset == nil or reset.days == nil then return "" end

    local raw   = (reset.time or 0) + ((_G.Settings and _G.Settings.timezone) or 0)
    local hour  = raw % 24
    local shift = math.floor(raw / 24)

    local lang  = (_G.Settings and _G.Settings.language) or "en"
    local short = WEEKDAY_SHORT[lang] or WEEKDAY_SHORT.en

    local count   = #reset.days
    local cadence
    if count >= 7 then
        cadence = _G.L("cadenceDaily")
    elseif count == 1 then
        cadence = _G.L("cadenceWeekly")
    elseif count == 3 then
        cadence = _G.L("cadenceTriWeekly")
    else
        cadence = string.format(_G.L("cadenceTimes"), count)
    end

    local clock = string.format("%02d:00", hour)
    if count >= 7 then
        return cadence .. _G.Sep .. clock
    end

    local days = {}
    for _, day in ipairs(reset.days) do days[#days + 1] = day end
    table.sort(days)

    local names = {}
    for _, day in ipairs(days) do
        names[#names + 1] = short[((day - 1 + shift) % 7) + 1]
    end

    return cadence .. _G.Sep .. table.concat(names, "/") .. " " .. clock

end

-- Entries flagged onlyResetIfDone do not clear at reset unless they were completed —
-- the lockout just extends. In practice this is always the Weeklies tier of a tracker
-- instance, but the flag is read rather than assumed.
local function TierCarriesOver(instanceId, tierName)
    for _, event in pairs(_G.Events) do
        if event.instance == instanceId and tostring(event.tier) == tierName
           and event.onlyResetIfDone then
            return true
        end
    end
    return false
end

local function InstanceCarriesOver(instanceId)
    for _, event in pairs(_G.Events) do
        if event.instance == instanceId and event.onlyResetIfDone then
            return true
        end
    end
    return false
end

-- The reset schedule of a tier, taken from its first event.
local function TierReset(instanceId, tierName)
    for _, event in pairs(_G.Events) do
        if event.instance == instanceId and tostring(event.tier) == tierName then
            return event.reset
        end
    end
    return nil
end

-- Widest tier in the instance, which is how many chest columns the table needs.
local function InstanceChestCount(instanceId)
    local tiers, names = buildInstanceTiers(instanceId)
    local most = 0
    for _, tierName in ipairs(names) do
        local count = 0
        for _ in pairs(tiers[tierName].bosses) do count = count + 1 end
        if count > most then most = count end
    end
    return most
end

-- How many of the instance's tiers anyone has a log for, for the header pill.
local function InstanceTierUsage(instanceId)
    local tiers, names = buildInstanceTiers(instanceId)
    local used = 0
    for _, tierName in ipairs(names) do
        local hit = false
        for _, boss in pairs(tiers[tierName].bosses) do
            for _, eventIndex in ipairs(boss.indices) do
                for _, character in pairs(_G.Logs) do
                    if character.enabled and character.logs and character.logs[eventIndex] ~= nil then
                        hit = true
                        break
                    end
                end
                if hit then break end
            end
            if hit then break end
        end
        if hit then used = used + 1 end
    end
    return used, #names
end

-- ------------------------------------------------------------------------------------------------
-- Lives below the helpers above deliberately: Lua resolves a file-scope local at compile
-- time, so a method defined before InstanceChestCount/InstanceTierUsage would call them as
-- nil globals.

function ContentView:UpdateHeader()

    local tab       = _G.Settings.selected.tab
    local charId    = _G.Settings.selected.character
    local serverId  = _G.Settings.selected.server
    local instId    = _G.Settings.selected.instance
    local contentId = _G.Settings.selected.content

    self.clearLogsFrame:SetVisible(false)
    self.deleteCharFrame:SetVisible(false)
    self.headerTooltip:SetVisible(false)
    self.headerPill:SetVisible(false)
    self.headerIcon:SetVisible(false)
    self.subtitleBase = ""

    if _G.Settings.selected.customList then
        self.headerName:SetText(_G.L("customListName"))
        self.headerType:SetText(_G.L("headerCustomList"))

    elseif tab == _G.Tab.Content and instId ~= nil then
        local instance = _G.Instances[instId]
        if instance then
            self.headerName:SetText(instance.name)
            self.headerType:SetText(_G.L("headerInstance"))

            -- "Corsairs of Umbar  Lv 150  3 chests"
            local parts   = {}
            local content = _G.Content[instance.content]
            if content ~= nil then
                parts[#parts + 1] = content.name
                if content.level ~= nil then
                    parts[#parts + 1] = "Lv " .. content.level
                end
            end
            parts[#parts + 1] = InstanceChestCount(instId) .. " " .. _G.L("chestsCount")
            self.subtitleBase = table.concat(parts, _G.Sep)

            local used, total = InstanceTierUsage(instId)
            self.headerPillLabel:SetText(string.format(_G.L("tiersUsed"), used, total))
            self.headerPill:SetVisible(true)
        end

    elseif tab == _G.Tab.Content and contentId ~= nil then
        local content = _G.Content[contentId]
        if content then
            self.headerName:SetText(content.name)
            self.headerType:SetText(_G.L("headerContent"))
            if content.level ~= nil then
                self.subtitleBase = "Lv " .. content.level
            end
        end

    elseif tab == _G.Tab.Characters and charId ~= nil then
        local character = _G.Logs[charId]
        if character then
            self.headerIcon:SetBackground(_G.ClassIcons[character.class])
            self.headerIcon:SetVisible(true)
            self.headerName:SetText(character.name)
            self.headerType:SetText(_G.L("headerCharacter"))

            local parts = {}
            if character.server ~= nil then parts[#parts + 1] = character.server end
            if character.level  ~= nil then parts[#parts + 1] = "Lv " .. character.level end
            self.subtitleBase = table.concat(parts, _G.Sep)

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
        self.headerName:SetText(serverId)
        self.headerType:SetText(_G.L("headerServer"))

    else
        self.headerName:SetText("")
        self.headerType:SetText("")
    end

    self.headerSub:SetText(self.subtitleBase)
    self:SizeChanged()

end

-- ------------------------------------------------------------------------------------------------
-- Shared helper: appends tier-header + boss rows for one instance into the listbox.
-- Caller is responsible for clearing and setting up currentRows before the first call.
function ContentView:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth, tierFilter, fullTable, nested)

    local tiers, sortedTierNames = buildInstanceTiers(instanceId)

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    -- Boss names by tier, in column order.
    local function tierBossNames(tierName)
        local orders = {}
        for order in pairs(tiers[tierName].bosses) do orders[#orders + 1] = order end
        table.sort(orders)
        local names = {}
        for _, order in ipairs(orders) do
            names[#names + 1] = tiers[tierName].bosses[order].name
        end
        return names
    end

    -- Normally every tier of an instance has the same chests, so one column header does
    -- for the whole table. The tracker pseudo-instances (Quests, Embers/Motes/Virtues)
    -- have a different number of entries per tier, and there one shared header would
    -- label the wrong columns, so each tier gets its own.
    -- the instance view heads the whole table; a pack-view block heads its own instance
    local wantColumns    = fullTable or nested
    local perTierColumns = false
    if wantColumns then
        local first
        for _, tierName in ipairs(sortedTierNames) do
            local count = #tierBossNames(tierName)
            if first == nil then
                first = count
            elseif count ~= first then
                perTierColumns = true
                break
            end
        end

        if not perTierColumns and #sortedTierNames > 0 then
            addRow(self:MakeBossColumnHeaderRow(tierBossNames(sortedTierNames[1]), nested))
        end
    end

    local renderedTiers = 0
    local rowIndex      = 0

    for _, tierName in ipairs(sortedTierNames) do
        if tierFilter == nil or tierFilter(tierName) then
            renderedTiers = renderedTiers + 1
            local tierData = tiers[tierName]

            -- only the instance view heads its own table with tier bands; everywhere
            -- else they hang off an instance header and step in under it
            addRow(self:MakeTierHeaderRow(instanceId, tierName, nested, not fullTable))

            if perTierColumns then
                addRow(self:MakeBossColumnHeaderRow(tierBossNames(tierName), nested))
            end

            local sortedBossOrders = {}
            for o in pairs(tierData.bosses) do sortedBossOrders[#sortedBossOrders + 1] = o end
            table.sort(sortedBossOrders)

            local bossNames = {}
            for _, o in ipairs(sortedBossOrders) do
                bossNames[#bossNames + 1] = tierData.bosses[o].name
            end

            local anyCharacter = false

            for _, character in ipairs(chars) do
                local bossValues     = {}
                local minTimeOfDeath = nil
                local hasAny         = false

                for _, o in ipairs(sortedBossOrders) do
                    local boss  = tierData.bosses[o]
                    local value = false
                    for _, ei in ipairs(boss.indices) do
                        if character.logs and character.logs[ei] ~= nil then
                            local entry = character.logs[ei]
                            value = entry.value
                            hasAny = true
                            if minTimeOfDeath == nil or entry.timeOfDeath < minTimeOfDeath then
                                minTimeOfDeath = entry.timeOfDeath
                            end
                            break
                        end
                    end
                    bossValues[#bossValues + 1] = value
                end

                if hasAny then
                    anyCharacter = true
                    rowIndex     = rowIndex + 1
                    local timeRemaining = math.max(0, minTimeOfDeath - currentTime)
                    local timeText      = FormatTimeRemaining(timeRemaining, minTimeOfDeath)
                    -- the names line up under the tier band they belong to, which steps
                    -- in wherever an instance header sits above it
                    addRow(self:MakeInstanceCharacterRow(character, bossValues, bossNames,
                                                         timeText, rowIndex, timeRemaining,
                                                         fullTable and PAD_X or (PAD_X + SUB_INDENT)))
                end
            end

            -- a tier nobody has touched collapses to one quiet line rather than vanishing
            if not anyCharacter and fullTable then
                addRow(self:MakeEmptyTierRow())
            end
        end
    end

    return renderedTiers > 0

end

-- ------------------------------------------------------------------------------------------------
-- Builds one compact row per tier for a single character within one instance: tier name + all
-- boss/quest values on one line (boss/quest name shown via hover), matching the multi-value-per-
-- line layout used by _AddInstanceTierRows. Only tiers where this character has at least one
-- logged value are included. Returns a plain array of pre-sized rows (does not touch the listbox),
-- so the caller can decide whether to commit them along with an instance header.

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
                local todoTiers = _G.CustomList[instanceId]
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
                local todoTiers = _G.CustomList[instanceId]
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

    self:ApplyLegend(IsCompact(InstanceChestCount(instanceId)), InstanceCarriesOver(instanceId))

    -- fullTable: the instance view is the one that gets the boss column header and
    -- a line for tiers nobody has touched
    local hadContent = self:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth, nil, true)

    if not hadContent then
        local row = self:MakeEmptyRow(_G.L("emptyInstance"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------


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

    local anyCarryOver, anyCompact = false, false

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
                local tierRows = self:_BuildCharacterInstanceRows(instanceId, character, currentTime, listWidth)
                if #tierRows > 0 then
                    anyCarryOver = anyCarryOver or tierRows.carryOver
                    anyCompact   = anyCompact   or tierRows.compact
                    charRows[#charRows + 1] = self:MakeInstanceRow(instance, true)
                    for _, r in ipairs(tierRows) do
                        charRows[#charRows + 1] = r
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

    self:ApplyLegend(anyCompact, anyCarryOver)

    if #self.currentRows == 0 then
        local row = self:MakeEmptyRow(_G.L("emptyServer"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------



-- ------------------------------------------------------------------------------------------------

-- The carry-over marker, placed just after `text` in the label column. Turbine cannot
-- measure a label, so the position comes from the same average glyph width the
-- truncation uses.
local function TextWidth(text, font)

    local chars = 0
    for _ in string.gmatch(text or "", "[\1-\127\194-\244][\128-\191]*") do
        chars = chars + 1
    end

    return math.floor(chars * _G.GlyphWidth(font or 12))

end

local function MarkerLeft(left, text, font)
    return left + TextWidth(text, font) + 6
end

local function AddCarryOverMarker(parent, left, text, height, font)

    local marker = Turbine.UI.Control()
    marker:SetParent(parent)
    marker:SetSize(CARRY, CARRY)
    marker:SetPosition(MarkerLeft(left, text, font), math.floor((height - CARRY) / 2))
    marker:SetBackground("LootLogs/Ressources/carryover.tga")
    marker:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    marker:SetMouseVisible(false)

    return marker

end

-- One status cell: a chip when something is recorded, a quiet dash when not.
-- Locked and Done deliberately collapse into the same chip — the player cannot run
-- either, so the distinction was not earning its colour.
function ContentView:MakeChip(parent, value, compact)

    local chipWidth = compact and CHIP_W_C or CHIP_W

    if value == false or value == nil then
        local dash = Turbine.UI.Label()
        dash:SetMultiline(false)
        dash:SetParent(parent)
        dash:SetSize(chipWidth, CHIP_H)
        dash:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        dash:SetFont(_G.Font(12))
        dash:SetFontStyle(_G.Theme.FONT_STYLE)
        dash:SetForeColor(_G.Theme.DASH)
        dash:SetText("-")
        dash:SetMouseVisible(false)
        return dash
    end

    local text, bg, frame, fore, tick

    if value == "Done" or value == "Locked" then
        text  = compact and "" or _G.L("chipDone")
        bg    = _G.Theme.CHIP_DONE_BG
        frame = _G.Theme.CHIP_DONE_FRAME
        fore  = _G.Theme.CHIP_DONE_TEXT
        tick  = true
    else
        local count, kind = string.match(tostring(value), "^(%d+)([fc])$")
        if kind == "f" then
            text  = compact and (count .. "f") or (count .. " " .. _G.L("chipFavour"))
            bg    = _G.Theme.CHIP_FAV_BG
            frame = _G.Theme.CHIP_FAV_FRAME
            fore  = _G.Theme.CHIP_FAV_TEXT
        elseif kind == "c" then
            text  = compact and (count .. "c") or (count .. " " .. _G.L("chipCommon"))
            bg    = _G.Theme.CHIP_USED_BG
            frame = _G.Theme.CHIP_USED_FRAME
            fore  = _G.Theme.CHIP_USED_TEXT
        else
            -- a progress tracker, e.g. 12/15
            text  = tostring(value)
            bg    = _G.Theme.CHIP_USED_BG
            frame = _G.Theme.CHIP_USED_FRAME
            fore  = _G.Theme.CHIP_USED_TEXT
        end
    end

    local chip = Turbine.UI.Control()
    chip:SetParent(parent)
    chip:SetSize(chipWidth, CHIP_H)
    chip:SetBackColor(frame)
    chip:SetMouseVisible(false)

    local inner = Turbine.UI.Control()
    inner:SetParent(chip)
    inner:SetPosition(1, 1)
    inner:SetSize(chipWidth - 2, CHIP_H - 2)
    inner:SetBackColor(bg)
    inner:SetMouseVisible(false)

    local textLeft = 0
    if tick then
        -- compact chips are the tick alone, so it centres instead of leading the word
        local tickLeft = compact and math.floor((chipWidth - 2 - TICK) / 2) or 10
        local check = Turbine.UI.Control()
        check:SetParent(inner)
        check:SetPosition(tickLeft, math.floor((CHIP_H - 2 - TICK) / 2))
        check:SetSize(TICK, TICK)
        check:SetBackground("LootLogs/Ressources/check.tga")
        check:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        check:SetMouseVisible(false)
        textLeft = compact and 0 or (10 + TICK)
    end

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(inner)
    label:SetPosition(textLeft, 0)
    label:SetSize(chipWidth - 2 - textLeft, CHIP_H - 2)
    label:SetTextAlignment((tick and not compact) and Turbine.UI.ContentAlignment.MiddleLeft
                                                  or  Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(fore)
    label:SetText(text)
    label:SetMouseVisible(false)

    return chip

end

-- ------------------------------------------------------------------------------------------------

-- Boss names are a permanent column header now rather than something you had to hover
-- a cell to discover.
function ContentView:MakeBossColumnHeaderRow(bossNames, nested, firstLabel)

    local height = nested and COLHEAD_NESTED_H or COLHEAD_H

    local row = Turbine.UI.Control()
    row:SetHeight(height)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local border = Turbine.UI.Control()
    border:SetParent(row)
    border:SetPosition(0, height - 1)
    border:SetHeight(1)
    border:SetBackColor(_G.Theme.FRAME)
    border:SetMouseVisible(false)

    local compact = IsCompact(#bossNames)

    local charLabel = Turbine.UI.Label()
    charLabel:SetMultiline(false)
    charLabel:SetParent(row)
    charLabel:SetPosition(PAD_X, 0)
    charLabel:SetSize(NAME_W, height)
    charLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    charLabel:SetFont(_G.Font(10))
    charLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    charLabel:SetForeColor(_G.Theme.DIM)
    charLabel:SetText(_G.L(firstLabel or "colCharacter"))
    charLabel:SetMouseVisible(false)

    local bossFont = compact and _G.Font(10)
                              or  _G.Font(12)

    -- assigned below, once the popup those handlers drive exists
    local showFullName, hideFullName

    local bossLabels = {}
    for index, name in ipairs(bossNames) do
        local label = Turbine.UI.Label()
        label:SetMultiline(false)
        label:SetParent(row)
        label:SetHeight(height)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        label:SetFont(bossFont)
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.DIM2)
        -- the column shows as much of the name as fits; hovering shows all of it
        label.fullName = name
        label.MouseEnter = function() showFullName(index) end
        label.MouseLeave = function() hideFullName() end
        bossLabels[index] = label
    end

    local resetLabel = Turbine.UI.Label()
    resetLabel:SetMultiline(false)
    resetLabel:SetParent(row)
    resetLabel:SetHeight(height)
    resetLabel:SetWidth(TIME_W)
    resetLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    resetLabel:SetFont(_G.Font(10))
    resetLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    resetLabel:SetForeColor(_G.Theme.DIM)
    resetLabel:SetText(_G.L("colResets"))
    resetLabel:SetMouseVisible(false)

    -- The full name on hover. Created last so it draws over the columns it spills into:
    -- Turbine has no z-order for a Control, only the order its parent built it in. It is
    -- also not mouse visible, so moving onto it does not end the hover that opened it.
    local popup = Turbine.UI.Control()
    popup:SetParent(row)
    popup:SetBackColor(_G.Theme.FRAME)
    popup:SetVisible(false)
    popup:SetMouseVisible(false)

    local popupBg = Turbine.UI.Control()
    popupBg:SetParent(popup)
    popupBg:SetPosition(1, 1)
    popupBg:SetBackColor(_G.Theme.SECTION)
    popupBg:SetMouseVisible(false)

    local popupLabel = Turbine.UI.Label()
    popupLabel:SetMultiline(false)
    popupLabel:SetParent(popupBg)
    popupLabel:SetPosition(0, 0)
    popupLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    popupLabel:SetFont(bossFont)
    popupLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    popupLabel:SetForeColor(_G.Theme.TEXT)
    popupLabel:SetMouseVisible(false)

    showFullName = function(index)

        local label = bossLabels[index]
        local text  = label.fullName
        if text == nil or text == "" then return end

        local chars = 0
        for _ in string.gmatch(text, "[\1-\127\194-\244][\128-\191]*") do
            chars = chars + 1
        end

        local rowWidth = row:GetWidth()
        local width    = math.min(math.max(0, rowWidth - 2 * PAD_X),
                                  math.floor(chars * _G.GlyphWidth(compact and 10 or 12)) + 14)
        if width <= 0 then return end

        local centre = label:GetLeft() + math.floor(label:GetWidth() / 2)
        local left   = math.max(PAD_X, math.min(centre - math.floor(width / 2),
                                                rowWidth - PAD_X - width))

        popup:SetPosition(left, 0)
        popup:SetSize(width, height)
        popupBg:SetSize(width - 2, height - 2)
        popupLabel:SetSize(width - 2, height - 2)
        popupLabel:SetText(text)
        popup:SetVisible(true)

    end

    hideFullName = function()
        popup:SetVisible(false)
    end

    row.SizeChanged = function()
        hideFullName()
        local width = row:GetWidth()
        border:SetWidth(width)

        local left, colWidth, timeLeft, nameWidth = ColumnGeometry(width, #bossLabels)
        local charWidth = _G.GlyphWidth(compact and 10 or 12)

        charLabel:SetWidth(nameWidth)
        for index, label in ipairs(bossLabels) do
            label:SetLeft(left + (index - 1) * colWidth)
            label:SetWidth(colWidth)
            label:SetText(_G.Truncate(label.fullName, colWidth - 8, charWidth))
        end
        resetLabel:SetLeft(timeLeft)
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- Whatever a view calls its top level — a character in the server view, an instance in
-- the pinned view, a pack in the character view — gets the same chrome: a gap above it
-- so the group reads as detached from the one before, the brightest fill in the list, a
-- full-height stripe and a rule closing the band off from the rows it owns. Everything
-- below that level keeps the quieter SECTION fill, so two neighbouring levels never
-- look alike.
-- Returns the list row and the band inside it; children go on the band, and a caller
-- that has to reflow sets row.OnResize rather than row.SizeChanged.
function ContentView:MakeTopBand(height, interactive)

    local row = Turbine.UI.Control()
    row:SetHeight(GROUP_GAP + height)
    row:SetBackColor(_G.Theme.PANEL)   -- the gap strip, matching the listbox behind it

    local band = Turbine.UI.Control()
    band:SetParent(row)
    band:SetPosition(0, GROUP_GAP)
    band:SetHeight(height)
    band:SetBackColor(_G.Theme.SEL_BG)

    if interactive then
        band.MouseEnter = function() band:SetBackColor(_G.Theme.PRESS) end
        band.MouseLeave = function() band:SetBackColor(_G.Theme.SEL_BG) end
    else
        row:SetMouseVisible(false)
        band:SetMouseVisible(false)
    end

    local stripe = Turbine.UI.Control()
    stripe:SetParent(band)
    stripe:SetPosition(0, 0)
    stripe:SetSize(3, height)
    stripe:SetBackColor(_G.Theme.HOVER)
    stripe:SetMouseVisible(false)

    local rule = Turbine.UI.Control()
    rule:SetParent(band)
    rule:SetPosition(0, height - 1)
    rule:SetHeight(1)
    rule:SetBackColor(_G.Theme.FRAME)
    rule:SetMouseVisible(false)

    row.SizeChanged = function()
        local width = row:GetWidth()
        band:SetWidth(width)
        rule:SetWidth(width)
        if row.OnResize ~= nil then row.OnResize(width) end
    end

    return row, band

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeTierHeaderRow(instanceId, tierName, nested, sub)

    -- nested in the pack view the instance header carries the context, so the band is
    -- shorter and drops the reset caption
    local height = nested and TIER_NESTED_H or TIER_H

    -- sub: the band hangs off an instance header rather than heading the table itself,
    -- so it steps in and trades the full-height mark for a short notch — the stripe at
    -- the very edge belongs to the header above it
    local indent = sub and (PAD_X + SUB_INDENT) or PAD_X

    local row = Turbine.UI.Control()
    row:SetHeight(height)
    row:SetBackColor(_G.Theme.SECTION)
    row:SetMouseVisible(false)

    local mark = Turbine.UI.Control()
    mark:SetParent(row)
    if sub then
        local notch = math.max(8, math.floor(height / 2))
        mark:SetPosition(indent - 10, math.floor((height - notch) / 2))
        mark:SetSize(MARK_W, notch)
    else
        mark:SetPosition(0, 0)
        mark:SetSize(MARK_W, height)
    end
    mark:SetBackColor(_G.Theme.ACCENT)
    mark:SetMouseVisible(false)

    -- closes the band off from the rows under it, and keeps two tiers stacked back to
    -- back from reading as one block
    local rule = Turbine.UI.Control()
    rule:SetParent(row)
    rule:SetPosition(0, height - 1)
    rule:SetHeight(1)
    rule:SetBackColor(_G.Theme.OUTER)
    rule:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(indent, 0)
    label:SetSize(TIER_LABEL_W, height)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(12))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.ACCENT)
    label:SetText(tierName)
    label:SetMouseVisible(false)

    local schedule = Turbine.UI.Label()
    schedule:SetMultiline(false)
    schedule:SetParent(row)
    schedule:SetPosition(indent + TIER_LABEL_W, 0)
    schedule:SetHeight(height)
    schedule:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    schedule:SetFont(_G.Font(10))
    schedule:SetFontStyle(_G.Theme.FONT_STYLE)
    schedule:SetForeColor(_G.Theme.DIM)
    schedule:SetText(nested and "" or ResetSchedule(TierReset(instanceId, tierName)))
    schedule:SetMouseVisible(false)

    if TierCarriesOver(instanceId, tierName) then
        AddCarryOverMarker(row, indent, tierName, height, 12)
    end

    -- pin toggle: this instance+tier goes in the Pinned tab
    local function isPinned()
        local tiers = _G.CustomList[instanceId]
        return tiers ~= nil and tiers[tierName] == true
    end

    local star = Turbine.UI.Control()
    star:SetParent(row)
    star:SetSize(STAR, STAR)
    star:SetTop(math.floor((height - STAR) / 2))
    star:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    star:SetMouseVisible(true)

    -- a .tga cannot be tinted, so pinned and unpinned are two pieces of art rather
    -- than one glyph in two colours
    local function refreshStar()
        star:SetBackground(isPinned() and "LootLogs/Ressources/star_on.tga"
                                      or  "LootLogs/Ressources/star_off.tga")
    end
    refreshStar()

    star.MouseEnter = function() row:SetBackColor(_G.Theme.SEL_BG) end
    star.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end
    star.MouseClick = function()
        if _G.CustomList[instanceId] == nil then
            _G.CustomList[instanceId] = {}
        end
        _G.CustomList[instanceId][tierName] = not isPinned()
        _G.SaveCustomList()
        refreshStar()
        if _G.Window ~= nil and _G.Window.sidebar ~= nil then
            _G.Window.sidebar:RefreshTierSquares()
        end
    end

    row.SizeChanged = function()
        local width = row:GetWidth()
        rule:SetWidth(width)
        star:SetLeft(width - PAD_X - STAR)
        schedule:SetWidth(math.max(0, width - indent - TIER_LABEL_W - PAD_X - STAR - 8))
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- One data row: a label in the name column, a chip per chest, a countdown on the right.
-- The instance view labels these with a character, the character view with a tier.
function ContentView:MakeValueRow(labelText, bossValues, timeText, index, remaining, options)

    options = options or {}

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetMouseVisible(false)

    local ground = (index % 2 == 0) and _G.Theme.ROW_ALT or _G.Theme.PANEL
    row:SetBackColor(ground)

    if options.marker then
        local dot = Turbine.UI.Control()
        dot:SetParent(row)
        dot:SetPosition((options.indent or PAD_X) - 8, math.floor((ROW_H - 4) / 2))
        dot:SetSize(4, 4)
        dot:SetBackColor(_G.Theme.ACCENT)
        dot:SetMouseVisible(false)
    end

    local compact = IsCompact(#bossValues)
    local indent  = options.indent or PAD_X

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(indent, 0)
    nameLabel:SetSize(NAME_W, ROW_H)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(12))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(options.accent and _G.Theme.ACCENT or _G.Theme.TEXT)
    nameLabel:SetText(labelText)
    nameLabel:SetMouseVisible(false)

    -- placed in SizeChanged, once the label has been cut to the column it has to fit
    local carryMarker
    if options.carryOver then
        carryMarker = Turbine.UI.Control()
        carryMarker:SetParent(row)
        carryMarker:SetSize(CARRY, CARRY)
        carryMarker:SetTop(math.floor((ROW_H - CARRY) / 2))
        carryMarker:SetBackground("LootLogs/Ressources/carryover.tga")
        carryMarker:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        carryMarker:SetMouseVisible(false)
    end

    local chips = {}
    for i, value in ipairs(bossValues) do
        chips[i] = self:MakeChip(row, value, compact)
    end

    local timeLabel = Turbine.UI.Label()
    timeLabel:SetMultiline(false)
    timeLabel:SetParent(row)
    timeLabel:SetHeight(ROW_H)
    timeLabel:SetWidth(TIME_W)
    timeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    timeLabel:SetFont(_G.Font(12))
    timeLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    timeLabel:SetForeColor((remaining ~= nil and remaining < AMBER_AFTER)
        and _G.Theme.CHIP_USED_TEXT or _G.Theme.ACCENT)
    timeLabel:SetText(timeText)
    timeLabel:SetMouseVisible(false)

    local chipWidth = compact and CHIP_W_C or CHIP_W

    row.SizeChanged = function()
        local width = row:GetWidth()
        local left, colWidth, timeLeft, nameWidth = ColumnGeometry(width, #chips)

        local labelWidth = math.max(0, nameWidth - (indent - PAD_X))
        if carryMarker ~= nil then labelWidth = math.max(0, labelWidth - CARRY - 6) end

        nameLabel:SetWidth(labelWidth)
        local shown = _G.Truncate(labelText, labelWidth, _G.GlyphWidth(12))
        nameLabel:SetText(shown)

        if carryMarker ~= nil then
            carryMarker:SetLeft(MarkerLeft(indent, shown, 12))
        end

        for i, chip in ipairs(chips) do
            chip:SetLeft(left + (i - 1) * colWidth + math.floor((colWidth - chipWidth) / 2))
            chip:SetTop(math.floor((ROW_H - CHIP_H) / 2))
        end

        timeLabel:SetLeft(timeLeft)
    end

    return row

end

function ContentView:MakeInstanceCharacterRow(character, bossValues, bossNames, timeText, index, remaining, indent)

    local isCurrent = (character.name == _G.name)
    return self:MakeValueRow(character.name, bossValues, timeText, index, remaining,
        { marker = isCurrent, accent = isCurrent, indent = indent })

end

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeEmptyTierRow()

    local row = Turbine.UI.Control()
    row:SetHeight(ROW_H)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(32, 0)
    label:SetHeight(ROW_H)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM)
    label:SetText(_G.L("nothingRecorded"))
    label:SetMouseVisible(false)

    row.SizeChanged = function()
        label:SetWidth(math.max(0, row:GetWidth() - 32 - PAD_X))
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- Which tiers of an instance anyone holds a lockout on, and when the first one falls.
local function InstanceLockouts(instanceId, chars)

    local tiers, tierNames = buildInstanceTiers(instanceId)
    local locked, soonest  = {}, nil

    for _, tierName in ipairs(tierNames) do
        for _, boss in pairs(tiers[tierName].bosses) do
            for _, eventIndex in ipairs(boss.indices) do
                for _, character in ipairs(chars) do
                    local entry = character.logs and character.logs[eventIndex]
                    if entry ~= nil then
                        locked[tierName] = true
                        if soonest == nil or entry.timeOfDeath < soonest then
                            soonest = entry.timeOfDeath
                        end
                    end
                end
            end
        end
    end

    local count = 0
    for _ in pairs(locked) do count = count + 1 end

    return count, soonest, locked

end

-- ------------------------------------------------------------------------------------------------

-- Header of one instance block in the content pack view.
function ContentView:MakeInstanceBlockHeaderRow(instanceId, instance, collapsed, onToggle)

    local row, band = self:MakeTopBand(BLOCK_H, true)
    row.MouseClick  = function() onToggle() end
    band.MouseClick = function() onToggle() end

    local name = Turbine.UI.Label()
    name:SetMultiline(false)
    name:SetParent(band)
    name:SetPosition(PAD_X, 0)
    name:SetHeight(BLOCK_H)
    name:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    name:SetFont(_G.Font(14))
    name:SetFontStyle(_G.Theme.FONT_STYLE)
    name:SetForeColor(_G.Theme.ACCENT)
    name:SetText(instance.name)
    name:SetMouseVisible(false)

    local chests = Turbine.UI.Label()
    chests:SetMultiline(false)
    chests:SetParent(band)
    chests:SetHeight(BLOCK_H)
    chests:SetWidth(90)
    chests:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    chests:SetFont(_G.Font(10))
    chests:SetFontStyle(_G.Theme.FONT_STYLE)
    chests:SetForeColor(_G.Theme.DIM)
    chests:SetText(InstanceChestCount(instanceId) .. " " .. _G.L("chestsCount"))
    chests:SetMouseVisible(false)

    local caret = Turbine.UI.Control()
    caret:SetParent(band)
    caret:SetSize(CARET, CARET)
    caret:SetTop(math.floor((BLOCK_H - CARET) / 2))
    caret:SetBackground(collapsed and "LootLogs/Ressources/arrow_right.tga"
                                  or  "LootLogs/Ressources/arrow_down.tga")
    caret:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    caret:SetMouseVisible(false)

    row.OnResize = function(width)
        caret:SetLeft(width - PAD_X - CARET)
        chests:SetLeft(width - PAD_X - CARET - 8 - 90)
        name:SetWidth(math.max(0, width - PAD_X - CARET - 8 - 90 - 8 - PAD_X))
    end

    return row

end

-- One line standing in for a collapsed instance.
function ContentView:MakeCollapsedInstanceRow(tierCount, soonest, currentTime)

    local row = Turbine.UI.Control()
    row:SetHeight(COLLAPSED_H)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local text = _G.L("packCollapsed")
    if tierCount > 0 and soonest ~= nil then
        text = text .. _G.Sep .. string.format(_G.L("packLockouts"), tierCount,
            FormatTimeSpan(math.max(0, soonest - currentTime)))
    end

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(32, 0)
    label:SetHeight(COLLAPSED_H)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(10))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.DIM)
    label:SetText(text)
    label:SetMouseVisible(false)

    row.SizeChanged = function()
        label:SetWidth(math.max(0, row:GetWidth() - 32 - PAD_X))
    end

    return row

end

-- Instances nobody has touched, gathered at the bottom of the pack.
function ContentView:MakeUntouchedInstanceRow(instance)

    local row = Turbine.UI.Control()
    row:SetHeight(BLOCK_H)
    row:SetBackColor(_G.Theme.PANEL)
    row:SetMouseVisible(false)

    local name = Turbine.UI.Label()
    name:SetMultiline(false)
    name:SetParent(row)
    name:SetPosition(PAD_X, 0)
    name:SetHeight(BLOCK_H)
    name:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    name:SetFont(_G.Font(12))
    name:SetFontStyle(_G.Theme.FONT_STYLE)
    name:SetForeColor(_G.Theme.DIM)
    name:SetText(instance.name)
    name:SetMouseVisible(false)

    local note = Turbine.UI.Label()
    note:SetMultiline(false)
    note:SetParent(row)
    note:SetHeight(BLOCK_H)
    note:SetWidth(140)
    note:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    note:SetFont(_G.Font(10))
    note:SetFontStyle(_G.Theme.FONT_STYLE)
    note:SetForeColor(_G.Theme.DASH)
    note:SetText(_G.L("packNothing"))
    note:SetMouseVisible(false)

    row.SizeChanged = function()
        local width = row:GetWidth()
        note:SetLeft(width - PAD_X - 140)
        name:SetWidth(math.max(0, width - PAD_X - 140 - 8 - PAD_X))
    end

    return row

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

    -- instances anyone has a lockout on keep their place; the rest sink to the bottom
    local active, untouched = {}, {}
    local anyCarryOver, anyCompact = false, false
    for _, instanceId in ipairs(instanceIds) do
        local count, soonest, locked = InstanceLockouts(instanceId, chars)
        if count > 0 then
            active[#active + 1] = {
                id = instanceId, count = count, soonest = soonest, locked = locked,
            }
            anyCarryOver = anyCarryOver or InstanceCarriesOver(instanceId)
            anyCompact   = anyCompact   or IsCompact(InstanceChestCount(instanceId))
        else
            untouched[#untouched + 1] = instanceId
        end
    end

    self:ApplyLegend(anyCompact, anyCarryOver)

    for _, entry in ipairs(active) do
        local instanceId = entry.id
        local collapsed  = _G.Settings.packInstances[instanceId] == true

        addRow(self:MakeInstanceBlockHeaderRow(instanceId, _G.Instances[instanceId], collapsed,
            function()
                _G.Settings.packInstances[instanceId] = not collapsed
                _G.SaveSettings()
                self:UpdateContent()
            end))

        if collapsed then
            addRow(self:MakeCollapsedInstanceRow(entry.count, entry.soonest, currentTime))
        else
            self:_AddInstanceTierRows(instanceId, chars, currentTime, listWidth,
                function(tierName) return entry.locked[tierName] == true end, false, true)
        end
    end

    for _, instanceId in ipairs(untouched) do
        addRow(self:MakeUntouchedInstanceRow(_G.Instances[instanceId]))
    end

end

-- ------------------------------------------------------------------------------------------------

-- Collapsible group header in the character view. The pack level carries an accent mark
-- and an uppercase name; the instance level is indented under it.
function ContentView:MakeGroupHeaderRow(text, collapsed, indent, accentMark, upper, onToggle)

    -- accentMark marks the pack level, which is the top level of the character view; the
    -- instance level under it keeps the quiet fill so the two never look alike
    local row, band
    if accentMark then
        row, band = self:MakeTopBand(GROUP_H, true)
    else
        row = Turbine.UI.Control()
        row:SetHeight(GROUP_H)
        row:SetBackColor(_G.Theme.SECTION)
        row.MouseEnter = function() row:SetBackColor(_G.Theme.SEL_BG) end
        row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end
        band = row
    end

    row.MouseClick  = function() onToggle() end
    band.MouseClick = function() onToggle() end

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(band)
    label:SetPosition(indent, 0)
    label:SetHeight(GROUP_H)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(12))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(upper and _G.Theme.DIM2 or _G.Theme.ACCENT)
    label:SetText(upper and _G.Upper(text) or text)
    label:SetMouseVisible(false)

    local caret = Turbine.UI.Control()
    caret:SetParent(band)
    caret:SetSize(CARET, CARET)
    caret:SetTop(math.floor((GROUP_H - CARET) / 2))
    caret:SetBackground(collapsed and "LootLogs/Ressources/arrow_right.tga"
                                  or  "LootLogs/Ressources/arrow_down.tga")
    caret:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    caret:SetMouseVisible(false)

    local function reflow(width)
        caret:SetLeft(width - PAD_X - CARET)
        label:SetWidth(math.max(0, width - indent - PAD_X - CARET - 8))
    end

    if accentMark then
        row.OnResize = reflow
    else
        row.SizeChanged = function() reflow(row:GetWidth()) end
    end

    return row

end

-- ------------------------------------------------------------------------------------------------

-- One instance's worth of rows for a single character: a column header labelled TIER,
-- then one row per tier the character has anything recorded in.
function ContentView:_BuildCharacterInstanceRows(instanceId, character, currentTime, listWidth)

    local tiers, sortedTierNames = buildInstanceTiers(instanceId)
    local rows = {}

    local function tierBossNames(tierName)
        local orders = {}
        for order in pairs(tiers[tierName].bosses) do orders[#orders + 1] = order end
        table.sort(orders)
        local names = {}
        for _, order in ipairs(orders) do
            names[#names + 1] = tiers[tierName].bosses[order].name
        end
        return names
    end

    local recorded = {}

    for _, tierName in ipairs(sortedTierNames) do
        local tierData = tiers[tierName]

        local sortedBossOrders = {}
        for o in pairs(tierData.bosses) do sortedBossOrders[#sortedBossOrders + 1] = o end
        table.sort(sortedBossOrders)

        local bossValues     = {}
        local minTimeOfDeath = nil
        local hasAny         = false

        for _, o in ipairs(sortedBossOrders) do
            local boss  = tierData.bosses[o]
            local value = false
            for _, ei in ipairs(boss.indices) do
                if character.logs and character.logs[ei] ~= nil then
                    local entry = character.logs[ei]
                    value  = entry.value
                    hasAny = true
                    if minTimeOfDeath == nil or entry.timeOfDeath < minTimeOfDeath then
                        minTimeOfDeath = entry.timeOfDeath
                    end
                    break
                end
            end
            bossValues[#bossValues + 1] = value
        end

        if hasAny then
            local remaining = math.max(0, minTimeOfDeath - currentTime)
            recorded[#recorded + 1] = {
                name      = tierName,
                values    = bossValues,
                remaining = remaining,
                timeText  = FormatTimeRemaining(remaining, minTimeOfDeath),
            }
        end
    end

    if #recorded == 0 then return rows end

    -- the tracker instances have a different number of entries per tier, so one shared
    -- column header would label the wrong columns
    local uneven, first = false, nil
    for _, tier in ipairs(recorded) do
        if first == nil then
            first = #tier.values
        elseif #tier.values ~= first then
            uneven = true
            break
        end
    end

    if not uneven then
        rows[#rows + 1] = self:MakeBossColumnHeaderRow(tierBossNames(recorded[1].name), true, "colTier")
    end

    for index, tier in ipairs(recorded) do
        if uneven then
            rows[#rows + 1] = self:MakeBossColumnHeaderRow(tierBossNames(tier.name), true, "colTier")
        end

        local carries = TierCarriesOver(instanceId, tier.name)
        rows.carryOver = rows.carryOver or carries
        rows.compact   = rows.compact or IsCompact(#tier.values)

        rows[#rows + 1] = self:MakeValueRow(tier.name, tier.values, tier.timeText, index,
                                            tier.remaining,
                                            { indent = TIER_INDENT, accent = true, carryOver = carries })
    end

    for _, row in ipairs(rows) do
        row:SetWidth(listWidth)
    end

    return rows

end

-- ------------------------------------------------------------------------------------------------

function ContentView:ShowCharacterView(characterId)

    self.listbox:ClearItems()
    self.currentRows = {}

    local character = _G.Logs[characterId]
    if character == nil then return end

    local currentTime = Turbine.Engine.GetLocalTime()
    local listWidth   = self.listbox:GetWidth()

    local function addRow(row)
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[#self.currentRows + 1] = row
    end

    local anyCarryOver, anyCompact = false, false

    local contentIndices = {}
    for contentIndex in pairs(_G.Content) do contentIndices[#contentIndices + 1] = contentIndex end
    table.sort(contentIndices, function(a, b) return a > b end)

    for _, contentIndex in ipairs(contentIndices) do
        local content = _G.Content[contentIndex]

        local instanceIds = {}
        for instanceId, instance in pairs(_G.Instances) do
            if instance.content == contentIndex then instanceIds[#instanceIds + 1] = instanceId end
        end
        table.sort(instanceIds, function(a, b) return a > b end)

        -- build first, so a pack with nothing recorded is never drawn at all
        local blocks = {}
        for _, instanceId in ipairs(instanceIds) do
            local tierRows = self:_BuildCharacterInstanceRows(instanceId, character, currentTime, listWidth)
            if #tierRows > 0 then
                blocks[#blocks + 1] = { id = instanceId, rows = tierRows }
                anyCarryOver = anyCarryOver or tierRows.carryOver
                anyCompact   = anyCompact   or tierRows.compact
            end
        end

        if #blocks > 0 then
            local packCollapsed = _G.Settings.charPacks[contentIndex] == true

            addRow(self:MakeGroupHeaderRow(content.name, packCollapsed, PAD_X, true, true,
                function()
                    _G.Settings.charPacks[contentIndex] = not packCollapsed
                    _G.SaveSettings()
                    self:UpdateContent()
                end))

            if not packCollapsed then
                for _, block in ipairs(blocks) do
                    local instanceCollapsed = _G.Settings.charInstances[block.id] == true

                    addRow(self:MakeGroupHeaderRow(_G.Instances[block.id].name, instanceCollapsed,
                        INSTANCE_INDENT, false, false,
                        function()
                            _G.Settings.charInstances[block.id] = not instanceCollapsed
                            _G.SaveSettings()
                            self:UpdateContent()
                        end))

                    if not instanceCollapsed then
                        for _, row in ipairs(block.rows) do addRow(row) end
                    end
                end
            end
        end

    end

    self:ApplyLegend(anyCompact, anyCarryOver)

    if #self.currentRows == 0 then
        local row = self:MakeEmptyRow(_G.L("emptyCharacter"))
        row:SetWidth(listWidth)
        self.listbox:AddItem(row)
        self.currentRows[1] = row
    end

end

-- ------------------------------------------------------------------------------------------------

-- Compact single-line row combining the tier name with one character's values across all
-- bosses/quests in that tier (multiple values side by side, boss/quest name shown on hover in
-- the header) — merges what used to be a separate tier-header row and value row into one line,
-- since only one character's data is ever shown here.

-- ------------------------------------------------------------------------------------------------

function ContentView:MakeCharacterHeaderRow(character)

    local row, band = self:MakeTopBand(34)

    -- native 20x20 (Turbine clips instead of scaling), and AlphaBlend rather than
    -- Overlay, which is for the white glyph .tga files and renders a full-colour game
    -- icon invisible against the dark panel
    local classIcon = Turbine.UI.Control()
    classIcon:SetParent(band)
    classIcon:SetPosition(10, 7)
    classIcon:SetSize(20, 20)
    classIcon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
    if _G.ClassIcons[character.class] ~= nil then
        classIcon:SetBackground(_G.ClassIcons[character.class])
    end
    classIcon:SetMouseVisible(false)

    local nameLabel = Turbine.UI.Label()
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(band)
    nameLabel:SetPosition(36, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(16))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.ACCENT)
    nameLabel:SetText(character.name)
    nameLabel:SetMouseVisible(false)

    row.OnResize = function(width)
        nameLabel:SetWidth(math.max(0, width - 46))
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
    nameLabel:SetMultiline(false)
    nameLabel:SetParent(row)
    nameLabel:SetPosition(12, 0)
    nameLabel:SetHeight(34)
    nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    nameLabel:SetFont(_G.Font(16))
    nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    nameLabel:SetForeColor(_G.Theme.ACCENT)
    nameLabel:SetText(content.name)
    nameLabel:SetMouseVisible(false)

    local levelLabel = Turbine.UI.Label()
    levelLabel:SetMultiline(false)
    levelLabel:SetParent(row)
    levelLabel:SetHeight(34)
    levelLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    levelLabel:SetFont(_G.Font(14))
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

    if indented then
        -- the server view, where the character band above is the top level
        local row = Turbine.UI.Control()
        row:SetHeight(28)
        row:SetBackColor(_G.Theme.SECTION)
        row.MouseEnter = function() row:SetBackColor(_G.Theme.PRESS) end
        row.MouseLeave = function() row:SetBackColor(_G.Theme.SECTION) end

        -- inset stripe: the one at the very edge belongs to the character band above
        local accent = Turbine.UI.Control()
        accent:SetParent(row)
        accent:SetPosition(10, 0)
        accent:SetSize(3, 28)
        accent:SetBackColor(_G.Theme.HOVER)
        accent:SetMouseVisible(false)

        -- a level below the character band above it, so it stays on the quiet fill and
        -- takes a smaller name
        local label = Turbine.UI.Label()
        label:SetMultiline(false)
        label:SetParent(row)
        label:SetPosition(22, 0)
        label:SetHeight(28)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        label:SetFont(_G.Font(14))
        label:SetFontStyle(_G.Theme.FONT_STYLE)
        label:SetForeColor(_G.Theme.ACCENT)
        label:SetText(instance.name)
        label:SetMouseVisible(false)

        row.SizeChanged = function()
            label:SetWidth(row:GetWidth() - 22)
        end

        return row
    end

    -- the pinned view: the instance is the top level, with tier bands hanging off it
    local row, band = self:MakeTopBand(30)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(band)
    label:SetPosition(12, 0)
    label:SetHeight(30)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(_G.Font(16))
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetForeColor(_G.Theme.ACCENT)
    label:SetText(instance.name)
    label:SetMouseVisible(false)

    row.OnResize = function(width)
        label:SetWidth(math.max(0, width - 12))
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
    label:SetMultiline(false)
    label:SetParent(row)
    label:SetPosition(0, 0)
    label:SetHeight(40)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(_G.Font(14))
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

    if self.header == nil then return end

    local width, height = self:GetSize()
    local iw = math.max(0, width - 2 * BORDER)

    self.header:SetWidth(iw)
    self.separator:SetPosition(BORDER, BORDER + HEADER_H)
    self.separator:SetWidth(iw)

    -- header right cluster: view kind, then the summary pill left of it
    local typeLeft = iw - PAD_X - TYPE_W
    self.headerType:SetLeft(typeLeft)
    self.headerType:SetWidth(TYPE_W)
    self.headerPill:SetLeft(typeLeft - 8 - PILL_W)
    local actTop    = math.floor((HEADER_H - ACT_H) / 2)
    local deleteLeft = typeLeft - 8 - ACT_DEL_W
    self.deleteCharFrame:SetPosition(deleteLeft, actTop)
    self.clearLogsFrame:SetPosition(deleteLeft - 6 - ACT_CLEAR_W, actTop)
    self.headerTooltip:SetWidth(math.max(0, typeLeft - PAD_X))

    -- the name and subtitle stop at whatever the right-hand cluster starts with
    local rightEdge = typeLeft
    if self.clearLogsFrame:IsVisible() then
        rightEdge = self.clearLogsFrame:GetLeft()
    elseif self.headerPill:IsVisible() then
        rightEdge = self.headerPill:GetLeft()
    end

    local textLeft  = self.headerIcon:IsVisible() and (PAD_X + 26) or PAD_X
    local textWidth = math.max(0, rightEdge - 8 - textLeft)
    self.headerName:SetLeft(textLeft)
    self.headerName:SetWidth(textWidth)
    self.headerSub:SetLeft(textLeft)
    self.headerSub:SetWidth(textWidth)

    -- legend pinned to the bottom, body fills what is left
    local legendTop = height - BORDER - LEGEND_H
    self.legend:SetPosition(BORDER, legendTop)
    self.legend:SetSize(iw, LEGEND_H)
    self.legendBorder:SetWidth(iw)

    local bodyTop = BORDER + HEADER_H + 1
    local bodyH   = math.max(0, legendTop - bodyTop)

    self.body:SetPosition(BORDER, bodyTop)
    self.body:SetSize(iw, bodyH)

    local listW = math.max(0, iw - 12)
    self.listbox:SetSize(listW, bodyH)
    self.scrollbar:SetPosition(listW, 0)
    self.scrollbar:SetHeight(bodyH)

    for _, row in ipairs(self.currentRows) do
        row:SetWidth(listW)
    end

end




-- swatches for each chip state, the dash, and the pin marker. Built once; the wording
-- swaps between the worded chips and the 5+ codes via ApplyLegend.
function ContentView:BuildLegend()

    local SWATCH_W, SWATCH_H = 16, 9

    self.legendItems = {}

    local function add(control, gap, wideWidth, compactWidth)
        self.legendItems[#self.legendItems + 1] = {
            control = control,
            gap     = gap,
            wide    = wideWidth,
            compact = compactWidth or wideWidth,
        }
    end

    local function label(wideKey, compactKey, wideWidth, compactWidth, colour)
        local item = Turbine.UI.Label()
        item:SetMultiline(false)
        item:SetParent(self.legend)
        item:SetTop(1)
        item:SetHeight(LEGEND_H - 1)
        item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        item:SetFont(_G.Font(10))
        item:SetFontStyle(_G.Theme.FONT_STYLE)
        item:SetForeColor(colour or _G.Theme.DIM)
        item:SetMouseVisible(false)
        add(item, 12, wideWidth, compactWidth)
        self.legendItems[#self.legendItems].wideKey    = wideKey
        self.legendItems[#self.legendItems].compactKey = compactKey
        return item
    end

    local function swatch(frame, fill)
        local outer = Turbine.UI.Control()
        outer:SetParent(self.legend)
        outer:SetTop(math.floor((LEGEND_H - SWATCH_H) / 2))
        outer:SetSize(SWATCH_W, SWATCH_H)
        outer:SetBackColor(frame)
        outer:SetMouseVisible(false)

        local inner = Turbine.UI.Control()
        inner:SetParent(outer)
        inner:SetPosition(1, 1)
        inner:SetSize(SWATCH_W - 2, SWATCH_H - 2)
        inner:SetBackColor(fill)
        inner:SetMouseVisible(false)

        add(outer, 5, SWATCH_W)
    end

    swatch(_G.Theme.CHIP_USED_FRAME, _G.Theme.CHIP_USED_BG)
    label("legendUsed", "legendUsedShort", 96, 88)

    swatch(_G.Theme.CHIP_FAV_FRAME, _G.Theme.CHIP_FAV_BG)
    label("legendFavoured", "legendFavShort", 60, 74)

    swatch(_G.Theme.CHIP_DONE_FRAME, _G.Theme.CHIP_DONE_BG)
    label("legendDone", "legendDoneShort", 132, 96)

    local dash = label(nil, nil, 8, 8, _G.Theme.DASH)
    dash:SetText("-")
    self.legendItems[#self.legendItems].gap = 4

    label("legendNothing", "legendNothing", 92, 92)

    -- the 10px artwork, matching the carry-over marker beside it; the legend glyphs are
    -- captions, not buttons
    local star = Turbine.UI.Control()
    star:SetParent(self.legend)
    star:SetTop(math.floor((LEGEND_H - 10) / 2))
    star:SetSize(10, 10)
    star:SetBackground("LootLogs/Ressources/star_pin.tga")
    star:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    star:SetMouseVisible(false)
    add(star, 5, 10)

    label("legendPinned", "legendPinned", 60, 60)

    -- only shown in a view that actually contains a carry-over entry
    local carry = Turbine.UI.Control()
    carry:SetParent(self.legend)
    carry:SetTop(math.floor((LEGEND_H - CARRY) / 2))
    carry:SetSize(CARRY, CARRY)
    carry:SetBackground("LootLogs/Ressources/carryover.tga")
    carry:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    carry:SetMouseVisible(false)
    add(carry, 5, CARRY)
    self.legendItems[#self.legendItems].optional = true

    label("legendCarryOver", "legendCarryOver", 132, 132)
    self.legendItems[#self.legendItems].optional = true

    self:ApplyLegend(false, false)

end

-- Below five chests the chips carry words; at five and above they shrink to codes, and
-- the legend has to say what the codes mean.
function ContentView:ApplyLegend(compact, carryOver)

    if self.legendItems == nil then return end

    self.legendCompact = compact and true or false

    local left = PAD_X
    for _, item in ipairs(self.legendItems) do

        if item.optional and not carryOver then
            item.control:SetVisible(false)
        else
            item.control:SetVisible(true)

            local key   = compact and item.compactKey or item.wideKey
            local width = compact and item.compact or item.wide

            if key ~= nil then
                local text = _G.L(key)
                item.control:SetText(text)
                -- measured from the text rather than a fixed slot, so the strip still
                -- fits once the German and French wordings are in it
                width = TextWidth(text, 10) + 4
            end

            item.control:SetLeft(left)
            if key ~= nil or item.gap == 4 then
                item.control:SetWidth(width)
            end
            left = left + width + item.gap
        end

    end

end

function ContentView:Build()

    -- 1px border; the header, body and legend sit inside it
    self:SetBackColor(_G.Theme.FRAME)

    self.subtitleBase = ""

    -- header ------------------------------------------------------------------------------------
    self.header = Turbine.UI.Control()
    self.header:SetParent(self)
    self.header:SetPosition(BORDER, BORDER)
    self.header:SetHeight(HEADER_H)
    self.header:SetBackColor(_G.Theme.HEADER)

    self.headerMark = Turbine.UI.Control()
    self.headerMark:SetParent(self.header)
    self.headerMark:SetPosition(0, 0)
    self.headerMark:SetSize(MARK_W, HEADER_H)
    self.headerMark:SetBackColor(_G.Theme.ACCENT)
    self.headerMark:SetMouseVisible(false)

    -- native 20x20, AlphaBlend; a game icon is neither scaled nor blended
    self.headerIcon = Turbine.UI.Control()
    self.headerIcon:SetParent(self.header)
    self.headerIcon:SetPosition(PAD_X, math.floor((HEADER_H - 20) / 2))
    self.headerIcon:SetSize(20, 20)
    self.headerIcon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
    self.headerIcon:SetVisible(false)
    self.headerIcon:SetMouseVisible(false)

    self.headerName = Turbine.UI.Label()
    self.headerName:SetMultiline(false)
    self.headerName:SetParent(self.header)
    self.headerName:SetPosition(PAD_X, 4)
    self.headerName:SetHeight(22)
    self.headerName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerName:SetFont(_G.Font(16))
    self.headerName:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerName:SetForeColor(_G.Theme.ACCENT)
    self.headerName:SetMarkupEnabled(true)
    self.headerName:SetMouseVisible(false)

    self.headerSub = Turbine.UI.Label()
    self.headerSub:SetMultiline(false)
    self.headerSub:SetParent(self.header)
    self.headerSub:SetPosition(PAD_X, 24)
    self.headerSub:SetHeight(16)
    self.headerSub:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.headerSub:SetFont(_G.Font(10))
    self.headerSub:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerSub:SetForeColor(_G.Theme.DIM)
    self.headerSub:SetMouseVisible(false)

    -- summary pill: "3 of 5 tiers used"
    self.headerPill = Turbine.UI.Control()
    self.headerPill:SetParent(self.header)
    self.headerPill:SetTop(math.floor((HEADER_H - PILL_H) / 2))
    self.headerPill:SetSize(PILL_W, PILL_H)
    self.headerPill:SetBackColor(_G.Theme.FRAME)
    self.headerPill:SetVisible(false)
    self.headerPill:SetMouseVisible(false)

    local pillBg = Turbine.UI.Control()
    pillBg:SetParent(self.headerPill)
    pillBg:SetPosition(1, 1)
    pillBg:SetSize(PILL_W - 2, PILL_H - 2)
    pillBg:SetBackColor(_G.Theme.HEADER)
    pillBg:SetMouseVisible(false)

    self.headerPillLabel = Turbine.UI.Label()
    self.headerPillLabel:SetMultiline(false)
    self.headerPillLabel:SetParent(pillBg)
    self.headerPillLabel:SetSize(PILL_W - 2, PILL_H - 2)
    self.headerPillLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.headerPillLabel:SetFont(_G.Font(10))
    self.headerPillLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerPillLabel:SetForeColor(_G.Theme.DIM2)
    self.headerPillLabel:SetMouseVisible(false)

    self.headerType = Turbine.UI.Label()
    self.headerType:SetMultiline(false)
    self.headerType:SetParent(self.header)
    self.headerType:SetTop(0)
    self.headerType:SetHeight(HEADER_H)
    self.headerType:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.headerType:SetFont(_G.Font(12))
    self.headerType:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerType:SetForeColor(_G.Theme.DIM)
    self.headerType:SetMouseVisible(false)

    -- clear logs button
    self.clearLogsFrame = Turbine.UI.Control()
    self.clearLogsFrame:SetParent(self.header)
    self.clearLogsFrame:SetSize(ACT_CLEAR_W, ACT_H)
    self.clearLogsFrame:SetBackColor(_G.Theme.FRAME)
    self.clearLogsFrame:SetVisible(false)

    self.clearLogsBg = Turbine.UI.Control()
    self.clearLogsBg:SetParent(self.clearLogsFrame)
    self.clearLogsBg:SetPosition(1, 1)
    self.clearLogsBg:SetSize(ACT_CLEAR_W - 2, ACT_H - 2)
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
    self.clearLogsLabel:SetMultiline(false)
    self.clearLogsLabel:SetParent(self.clearLogsBg)
    self.clearLogsLabel:SetSize(ACT_CLEAR_W - 2, ACT_H - 2)
    self.clearLogsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.clearLogsLabel:SetFont(_G.Font(10))
    self.clearLogsLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.clearLogsLabel:SetText(_G.L("clearLogsBtn"))
    self.clearLogsLabel:SetMouseVisible(false)
    self.clearLogsLabel:SetForeColor(_G.Theme.DIM2)

    -- delete character button
    self.deleteCharDisabled = false

    self.deleteCharFrame = Turbine.UI.Control()
    self.deleteCharFrame:SetParent(self.header)
    self.deleteCharFrame:SetSize(ACT_DEL_W, ACT_H)
    self.deleteCharFrame:SetBackColor(_G.Theme.FRAME)
    self.deleteCharFrame:SetVisible(false)

    self.deleteCharBg = Turbine.UI.Control()
    self.deleteCharBg:SetParent(self.deleteCharFrame)
    self.deleteCharBg:SetPosition(1, 1)
    self.deleteCharBg:SetSize(ACT_DEL_W - 2, ACT_H - 2)
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
    self.deleteCharLabel:SetMultiline(false)
    self.deleteCharLabel:SetParent(self.deleteCharBg)
    self.deleteCharLabel:SetSize(ACT_DEL_W - 2, ACT_H - 2)
    self.deleteCharLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.deleteCharLabel:SetFont(_G.Font(10))
    self.deleteCharLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.deleteCharLabel:SetText(_G.L("deleteCharBtn"))
    self.deleteCharLabel:SetMouseVisible(false)
    self.deleteCharLabel:SetForeColor(_G.Theme.DIM2)

    -- shared tooltip label for the two character action buttons
    self.headerTooltip = Turbine.UI.Label()
    self.headerTooltip:SetMultiline(false)
    self.headerTooltip:SetParent(self.header)
    self.headerTooltip:SetPosition(PAD_X, 0)
    self.headerTooltip:SetHeight(HEADER_H)
    self.headerTooltip:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.headerTooltip:SetFont(_G.Font(12))
    self.headerTooltip:SetFontStyle(_G.Theme.FONT_STYLE)
    self.headerTooltip:SetForeColor(_G.Theme.DIM2)
    self.headerTooltip:SetVisible(false)
    self.headerTooltip:SetMouseVisible(false)

    self.separator = Turbine.UI.Control()
    self.separator:SetParent(self)
    self.separator:SetHeight(1)
    self.separator:SetBackColor(_G.Theme.FRAME)

    -- body --------------------------------------------------------------------------------------
    self.body = Turbine.UI.Control()
    self.body:SetParent(self)
    self.body:SetBackColor(_G.Theme.PANEL)

    self.listbox = Turbine.UI.ListBox()
    self.listbox:SetParent(self.body)
    self.listbox:SetBackColor(_G.Theme.PANEL)

    self.scrollbar = Turbine.UI.Lotro.ScrollBar()
    self.scrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollbar:SetParent(self.body)
    self.scrollbar:SetWidth(10)
    self.listbox:SetVerticalScrollBar(self.scrollbar)

    -- legend ------------------------------------------------------------------------------------
    self.legend = Turbine.UI.Control()
    self.legend:SetParent(self)
    self.legend:SetBackColor(_G.Theme.PANEL)
    self.legend:SetMouseVisible(false)

    self.legendBorder = Turbine.UI.Control()
    self.legendBorder:SetParent(self.legend)
    self.legendBorder:SetPosition(0, 0)
    self.legendBorder:SetHeight(1)
    self.legendBorder:SetBackColor(_G.Theme.FRAME)
    self.legendBorder:SetMouseVisible(false)

    self:BuildLegend()

end
