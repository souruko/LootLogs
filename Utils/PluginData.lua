--=================================================================================================
--= Plugin data
--= ===============================================================================================
--= load and save plugin data
--=================================================================================================

local function IsEuroClient()
    return Turbine.Shell.IsCommand("hilfe") or Turbine.Shell.IsCommand("aide")
end

local function ConvertToEuro(dataRaw)
    if type(dataRaw) ~= "table" then
        return type(dataRaw) == "number" and tostring(dataRaw) or dataRaw
    end
    local newData = {}
    for i, myData in pairs(dataRaw) do
        local tempIndex = type(i) == "number" and tostring(i) or i
        local tempData
        if type(myData) == "table" then
            tempData = ConvertToEuro(myData)
        elseif type(myData) == "number" then
            tempData = tostring(myData)
        else
            tempData = myData
        end
        newData[tempIndex] = tempData
    end
    return newData
end

local function ConvertFromEuro(dataRaw)
    if type(dataRaw) ~= "table" then
        local n = tonumber(dataRaw)
        return n ~= nil and n or dataRaw
    end
    local newData = {}
    for i, myData in pairs(dataRaw) do
        local tempIndex = tonumber(i)
        if tempIndex == nil then tempIndex = i end
        local tempData
        if type(myData) == "table" then
            tempData = ConvertFromEuro(myData)
        else
            tempData = tonumber(myData)
            if tempData == nil then tempData = myData end
        end
        newData[tempIndex] = tempData
    end
    return newData
end

function FindCurrentCharacter()
    for id, character in pairs(_G.Logs) do
        if character.name == _G.name and (character.server == _G.Server or character.server == nil) then
            return id
        end
    end

    return nil
end

-- server -----------------------------------------------------------------------------------------

function SaveServerCompleteHandler()
    _G.PrintAlert("LL: Server saved!")

end

function _G.SaveServer()
    Turbine.PluginData.Save(Turbine.DataScope.Server, "GetServer", _G.Server, SaveServerCompleteHandler)
    Turbine.PluginData.Save(Turbine.DataScope.Server, "GetServer_Euro", ConvertToEuro(_G.Server), SaveServerCompleteHandler)
end

function LoadServerCompleteHandler()

end

if IsEuroClient() then
    local raw = Turbine.PluginData.Load(Turbine.DataScope.Server, "GetServer_Euro", LoadServerCompleteHandler)
    if raw ~= nil then
        _G.Server = ConvertFromEuro(raw)
    else
        _G.Server = Turbine.PluginData.Load(Turbine.DataScope.Server, "GetServer", LoadServerCompleteHandler)
    end
else
    _G.Server = Turbine.PluginData.Load(Turbine.DataScope.Server, "GetServer", LoadServerCompleteHandler)
end



-- settings ---------------------------------------------------------------------------------------
-- structure
-- 
-- timezone
-- printAlerts
-- printWelcome
-- useCustomList
-- showServers
--
-- window
-- -- width
-- -- height
-- -- left
-- -- top
-- 
-- servers
-- -- collapsed
-- content
-- -- collapsed
-- selected
-- -- customList
-- -- tab (content/characters)
-- -- server
-- -- character
-- -- content
-- -- instance

function SaveSettingsCompleteHandler()

end

function _G.SaveSettings()
    Turbine.PluginData.Save(Turbine.DataScope.Account, "LootSettings", _G.Settings, SaveSettingsCompleteHandler)
    Turbine.PluginData.Save(Turbine.DataScope.Account, "LootSettings_Euro", ConvertToEuro(_G.Settings), SaveSettingsCompleteHandler)
end

function LoadSettingsCompleteHandler()


end

if IsEuroClient() then
    local raw = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootSettings_Euro", LoadSettingsCompleteHandler)
    if raw ~= nil then
        _G.Settings = ConvertFromEuro(raw)
    else
        _G.Settings = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootSettings", LoadSettingsCompleteHandler)
    end
else
    _G.Settings = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootSettings", LoadSettingsCompleteHandler)
end

-- set defaults
if _G.Settings == nil then
    _G.Settings = {}
    _G.Settings.timezone = 1
    _G.Settings.printAlerts = true
    _G.Settings.printWelcome = true
    _G.Settings.showCustomList = true
    _G.Settings.showServers = true
    _G.Settings.showBadge = true
    _G.Settings.language = "en"
    _G.Settings.previousId = 3

    _G.Settings.window = {}
    _G.Settings.window.left = 200
    _G.Settings.window.top = 200
    _G.Settings.window.width = 1000
    _G.Settings.window.height = 800

    _G.Settings.servers = {}
    _G.Settings.content = {}

    _G.Settings.selected = {}
    _G.Settings.selected.customList = false
    _G.Settings.selected.tab = _G.Tab.Characters
    _G.Settings.selected.server = nil
    _G.Settings.selected.character = nil
    _G.Settings.selected.content = nil
    _G.Settings.selected.instance = nil

    _G.Settings.quickLaunch = {}
    _G.Settings.quickLaunch.left = 100
    _G.Settings.quickLaunch.top  = 100
    _G.Settings.quickLaunchSize  = 50

end

if _G.Settings.language == nil then
    _G.Settings.language = "en"
end

if _G.Settings.quickLaunch == nil then
    _G.Settings.quickLaunch = {}
    _G.Settings.quickLaunch.left = 100
    _G.Settings.quickLaunch.top  = 100
end

if _G.Settings.quickLaunchSize == nil then
    _G.Settings.quickLaunchSize = 50
end

if _G.Settings.timeDisplay == nil then
    _G.Settings.timeDisplay = "timespan"
end

if _G.Settings.colorTheme == nil then
    _G.Settings.colorTheme = "moria"
end

-- the alerts toggle used to write printAlerts while the check read PrintAlerts, so the
-- setting never did anything; keep whichever value was actually stored
if _G.Settings.printAlerts == nil then
    _G.Settings.printAlerts = (_G.Settings.PrintAlerts ~= false)
end
_G.Settings.PrintAlerts = nil

-- 0 smallest (the sizes everything is authored at), 1 and 2 step the whole UI up
if _G.Settings.fontScale == nil then
    _G.Settings.fontScale = 0
end

-- collapse state of each instance block in the content pack view
if _G.Settings.packInstances == nil then
    _G.Settings.packInstances = {}
end

-- collapse state of the pack and instance groups in the character view
if _G.Settings.charPacks == nil then
    _G.Settings.charPacks = {}
end
if _G.Settings.charInstances == nil then
    _G.Settings.charInstances = {}
end

if _G.Settings.showBadge == nil then
    _G.Settings.showBadge = true
end

-- custom list --------------------------------------------------------------------------------------

function SaveCustomListCompleteHandler()
end

function _G.SaveCustomList()
    Turbine.PluginData.Save(Turbine.DataScope.Server, "LootCustomList", _G.CustomList, SaveCustomListCompleteHandler)
    Turbine.PluginData.Save(Turbine.DataScope.Server, "LootCustomList_Euro", ConvertToEuro(_G.CustomList), SaveCustomListCompleteHandler)
end

if IsEuroClient() then
    local raw = Turbine.PluginData.Load(Turbine.DataScope.Server, "LootCustomList_Euro")
    if raw ~= nil then
        _G.CustomList = ConvertFromEuro(raw)
    else
        _G.CustomList = Turbine.PluginData.Load(Turbine.DataScope.Server, "LootCustomList")
    end
else
    _G.CustomList = Turbine.PluginData.Load(Turbine.DataScope.Server, "LootCustomList")
end

if _G.CustomList == nil then
    _G.CustomList = {}
end

-- logs ---------------------------------------------------------------------------------------------
-- structure
-- 
-- ['character name'] {
--     class = 'character class',
--     enabled = true,
--     server = 'Orcrist',
--     logs['eventIndex'] {
--         value = 'displayed value',
--         timeOfDeath = 'end timestamp'
--     }
-- }


function SaveLogsCompleteHandler()

end

function _G.SaveLogs()
    Turbine.PluginData.Save(Turbine.DataScope.Account, "LootLogs", _G.Logs, SaveLogsCompleteHandler)
    Turbine.PluginData.Save(Turbine.DataScope.Account, "LootLogs_Euro", ConvertToEuro(_G.Logs), SaveLogsCompleteHandler)
end

function LoadLogsCompleteHandler()

end

if IsEuroClient() then
    local raw = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootLogs_Euro", LoadLogsCompleteHandler)
    if raw ~= nil then
        _G.Logs = ConvertFromEuro(raw)
    else
        _G.Logs = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootLogs", LoadLogsCompleteHandler)
    end
else
    _G.Logs = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootLogs", LoadLogsCompleteHandler)
end

-- set defaults
if _G.Logs == nil then
    _G.Logs = {}
end

for _, character in pairs(_G.Logs) do
    if character.logs == nil then
        character.logs = {}
    end
end

-- upsert current character
_G.characterId = FindCurrentCharacter()
if _G.characterId == nil then
    _G.Settings.previousId = _G.Settings.previousId + 1
    _G.characterId = _G.Settings.previousId
    _G.Logs[_G.characterId] = {
        ["name"] = _G.name,
        ["class"] = _G.localPlayer:GetClass(),
        ["level"] = _G.localPlayer:GetLevel(),
        ["enabled"] = true,
        ["logs"] = {},
        ["server"] = _G.Server
    }

    _G.SaveLogs()
else
    if _G.Logs[_G.characterId].server ~= _G.Server or _G.Logs[_G.characterId].level ~= _G.localPlayer:GetLevel() then
        _G.Logs[_G.characterId].server = _G.Server
        _G.Logs[_G.characterId].level = _G.localPlayer:GetLevel()
        _G.SaveLogs()
    end
end

-- remove "dead" logs
local currentTime = Turbine.Engine.GetLocalTime()
local logHasChanged = false

local function _tierOrder(tier)
    return (_G.TierOrder and _G.TierOrder[tostring(tier)]) or 99
end

-- tiers whose bosses share a single reset schedule, so only one summary line is needed per tier
local groupedResetTiers = {
    ["Solo"] = true, ["T1"] = true, ["T2"] = true, ["T3"] = true,
    ["T3+"]  = true, ["T4"] = true, ["T5"] = true,
}

local allToDelete      = {}
local allRecalculated  = {}

for id, character in pairs(_G.Logs) do
    for index, log in pairs(character.logs) do
        if log.timeOfDeath <= currentTime then
            local event = _G.Events[index]
            if event.onlyResetIfDone and character.logs[index].value ~= "Done" then
                character.logs[index].timeOfDeath = _G.CalculateDeath(event)
                allRecalculated[#allRecalculated + 1] = { character = character, index = index, newTimeOfDeath = character.logs[index].timeOfDeath }
            else
                allToDelete[#allToDelete + 1] = { character = character, index = index }
            end
            logHasChanged = true
        end
    end
end

-- sort by character, then content, then instance, then tier, then boss order
local function _sortByCharacterContentInstance(a, b)
    if a.character.name ~= b.character.name then return a.character.name < b.character.name end
    local ea = _G.Events[a.index]
    local eb = _G.Events[b.index]
    local aInst = _G.Instances[ea.instance]
    local bInst = _G.Instances[eb.instance]
    local aCont = aInst and aInst.content or 0
    local bCont = bInst and bInst.content or 0
    if aCont ~= bCont then return aCont < bCont end
    if ea.instance ~= eb.instance then return ea.instance < eb.instance end
    local ta = _tierOrder(ea.tier)
    local tb = _tierOrder(eb.tier)
    if ta ~= tb then return ta < tb end
    return (ea.order or 99) < (eb.order or 99)
end

table.sort(allToDelete, _sortByCharacterContentInstance)
table.sort(allRecalculated, _sortByCharacterContentInstance)

-- collapse consecutive entries that share (character, instance, tier) into one group
-- when that tier's bosses reset together; the sort above guarantees they're adjacent.
local function _groupResetEntries(list)
    local grouped = {}
    local i = 1
    while i <= #list do
        local entry    = list[i]
        local event    = _G.Events[entry.index]
        local tierName = tostring(event.tier)
        local group = { character = entry.character, instance = event.instance, tier = tierName, entries = { entry } }
        if groupedResetTiers[tierName] then
            local j = i + 1
            while j <= #list do
                local nextEntry = list[j]
                local nextEvent = _G.Events[nextEntry.index]
                if nextEntry.character == entry.character and nextEvent.instance == event.instance and tostring(nextEvent.tier) == tierName then
                    table.insert(group.entries, nextEntry)
                    j = j + 1
                else
                    break
                end
            end
            i = j
        else
            i = i + 1
        end
        grouped[#grouped + 1] = group
    end
    return grouped
end

-- boss label for a group: the boss name if it's a single (non-merged) entry, blank otherwise
local function _groupBossLabel(group)
    if #group.entries == 1 then
        return " " .. _G.Events[group.entries[1].index].name
    end
    return ""
end

local RED    = "<rgb=#CC4444>"
local YELLOW = "<rgb=#CCAA44>"

if #allToDelete > 0 then
    _G.PrintAlert(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR .. _G.CM("DIM") .. "  — " .. _G.CMR .. RED .. "resets" .. _G.CMR)
    for _, group in ipairs(_groupResetEntries(allToDelete)) do
        local instance = _G.Instances[group.instance]
        _G.PrintAlert(
            _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
            _groupBossLabel(group) ..
            " " .. _G.CM("DIM") .. "(" .. group.tier .. ")" .. _G.CMR ..
            " reset for " .. RED .. group.character.name .. _G.CMR
        )
    end
end

for _, entry in ipairs(allToDelete) do
    entry.character.logs[entry.index] = nil
end

if #allRecalculated > 0 then
    _G.PrintAlert(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR .. _G.CM("DIM") .. "  — " .. _G.CMR .. YELLOW .. "extended" .. _G.CMR)
    for _, group in ipairs(_groupResetEntries(allRecalculated)) do
        local instance = _G.Instances[group.instance]
        local minNew = nil
        for _, e in ipairs(group.entries) do
            if minNew == nil or e.newTimeOfDeath < minNew then minNew = e.newTimeOfDeath end
        end
        local remaining = math.max(0, minNew - currentTime)
        _G.PrintAlert(
            _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
            _groupBossLabel(group) ..
            " " .. _G.CM("DIM") .. "(" .. group.tier .. ")" .. _G.CMR ..
            " not done, reset pushed to " .. _G.CM("ACCENT") .. _G.FormatTimeSpan(remaining) .. _G.CMR ..
            " for " .. YELLOW .. group.character.name .. _G.CMR
        )
    end
end

if logHasChanged then
    _G.SaveLogs()
end

-- write current characters logs into chat
if _G.Settings.printWelcome then

    -- tiers whose bosses share a single reset schedule, so only one summary line is needed per tier
    local groupedTiers = {
        ["Solo"] = true, ["T1"] = true, ["T2"] = true, ["T3"] = true,
        ["T3+"]  = true, ["T4"] = true, ["T5"] = true,
    }

    Turbine.Shell.WriteLine(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR .. _G.CM("DIM") .. "  — " .. _G.name .. _G.CMR)
    local activeLogs = _G.Logs[_G.characterId].logs
    if next(activeLogs) ~= nil then

        -- group by instance, then by tier
        local instanceGroups = {}
        for index, log in pairs(activeLogs) do
            local event      = _G.Events[index]
            local instance   = _G.Instances[event.instance]
            local contentIdx = instance and instance.content or 0

            local instanceGroup = instanceGroups[event.instance]
            if instanceGroup == nil then
                instanceGroup = { contentIdx = contentIdx, tiers = {} }
                instanceGroups[event.instance] = instanceGroup
            end

            local tierName  = tostring(event.tier)
            local tierGroup = instanceGroup.tiers[tierName]
            if tierGroup == nil then
                tierGroup = { order = _tierOrder(event.tier), entries = {} }
                instanceGroup.tiers[tierName] = tierGroup
            end
            table.insert(tierGroup.entries, { event = event, log = log })
        end

        local instanceIds = {}
        for instanceId in pairs(instanceGroups) do table.insert(instanceIds, instanceId) end
        table.sort(instanceIds, function(a, b)
            local ga, gb = instanceGroups[a], instanceGroups[b]
            if ga.contentIdx ~= gb.contentIdx then return ga.contentIdx < gb.contentIdx end
            return a < b
        end)

        for _, instanceId in ipairs(instanceIds) do
            local instance = _G.Instances[instanceId]
            local tiers    = instanceGroups[instanceId].tiers

            local tierNames = {}
            for tierName in pairs(tiers) do table.insert(tierNames, tierName) end
            table.sort(tierNames, function(a, b) return tiers[a].order < tiers[b].order end)

            for _, tierName in ipairs(tierNames) do
                local tierGroup = tiers[tierName]

                if groupedTiers[tierName] then
                    -- bosses in this tier reset together — collapse into a single summary line
                    local minEntry = nil
                    for _, e in ipairs(tierGroup.entries) do
                        if minEntry == nil or e.log.timeOfDeath < minEntry.log.timeOfDeath then
                            minEntry = e
                        end
                    end
                    local remaining = minEntry.log.timeOfDeath - currentTime
                    Turbine.Shell.WriteLine(
                        _G.CM("DIM") .. "· " .. _G.CMR ..
                        _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
                        " " .. _G.CM("DIM") .. "(" .. tierName .. ")" .. _G.CMR ..
                        " " .. _G.CM("ACCENT") .. _G.FormatTimeSpan(remaining) .. _G.CMR
                    )
                else
                    table.sort(tierGroup.entries, function(a, b)
                        return (a.event.order or 99) < (b.event.order or 99)
                    end)
                    for _, e in ipairs(tierGroup.entries) do
                        local remaining = e.log.timeOfDeath - currentTime
                        Turbine.Shell.WriteLine(
                            _G.CM("DIM") .. "· " .. _G.CMR ..
                            _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
                            " " .. e.event.name ..
                            " " .. _G.CM("DIM") .. "(" .. tierName .. ")" .. _G.CMR ..
                            " " .. e.log.value ..
                            " " .. _G.CM("ACCENT") .. _G.FormatTimeSpan(remaining) .. _G.CMR
                        )
                    end
                end
            end
        end
    else
        Turbine.Shell.WriteLine("  No active lockouts.")
    end

end

-- fixed selection on load ---------------------------------------------------------------------------

local function CustomListHasSelection()
    for _, tiers in pairs(_G.CustomList) do
        for _, selected in pairs(tiers) do
            if selected then return true end
        end
    end
    return false
end

if _G.Settings.showCustomList == true and CustomListHasSelection() then
    _G.Settings.selected.customList = true
    _G.Settings.selected.server     = nil
    _G.Settings.selected.character  = nil
    _G.Settings.selected.content    = nil
    _G.Settings.selected.instance   = nil
else
    _G.Settings.selected.customList = false
    _G.Settings.selected.tab        = _G.Tab.Characters
    _G.Settings.selected.server     = nil
    _G.Settings.selected.character  = _G.characterId
    _G.Settings.selected.content    = nil
    _G.Settings.selected.instance   = nil
end

_G.ApplyTheme(_G.Settings.colorTheme or "moria")
