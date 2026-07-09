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
-- _G.PrintAlerts
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
    _G.Settings.PrintAlerts = true
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

end

if _G.Settings.language == nil then
    _G.Settings.language = "en"
end

if _G.Settings.quickLaunch == nil then
    _G.Settings.quickLaunch = {}
    _G.Settings.quickLaunch.left = 100
    _G.Settings.quickLaunch.top  = 100
end

if _G.Settings.timeDisplay == nil then
    _G.Settings.timeDisplay = "timespan"
end

if _G.Settings.colorTheme == nil then
    _G.Settings.colorTheme = "moria"
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

local allToDelete = {}

for id, character in pairs(_G.Logs) do
    for index, log in pairs(character.logs) do
        if log.timeOfDeath <= currentTime then
            local event = _G.Events[index]
            if event.onlyResetIfDone and character.logs[index].value ~= "Done" then
                character.logs[index].timeOfDeath = _G.CalculateDeath(event)
                logHasChanged = true
            else
                allToDelete[#allToDelete + 1] = { character = character, index = index }
            end
        end
    end
end

table.sort(allToDelete, function(a, b)
    local ea = _G.Events[a.index]
    local eb = _G.Events[b.index]
    if ea.instance ~= eb.instance then return ea.instance > eb.instance end
    local ta = _tierOrder(ea.tier)
    local tb = _tierOrder(eb.tier)
    if ta ~= tb then return ta > tb end
    local oa = ea.order or 99
    local ob = eb.order or 99
    if oa ~= ob then return oa < ob end
    return a.character.name < b.character.name
end)

local RED = "<rgb=#CC4444>"

if #allToDelete > 0 then
    _G.PrintAlert(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR .. _G.CM("DIM") .. "  — " .. _G.CMR .. RED .. "resets" .. _G.CMR)
end

for _, entry in ipairs(allToDelete) do
    local character = entry.character
    local index     = entry.index
    local event     = _G.Events[index]
    local instance  = _G.Instances[event.instance]
    _G.PrintAlert(
        _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
        " " .. event.name ..
        " " .. _G.CM("DIM") .. "(" .. event.tier .. ")" .. _G.CMR ..
        " reset for " .. RED .. character.name .. _G.CMR
    )
    character.logs[index] = nil
    logHasChanged = true
end

if logHasChanged then
    _G.SaveLogs()
end

-- write current characters logs into chat
if _G.Settings.printWelcome then

    Turbine.Shell.WriteLine(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR .. _G.CM("DIM") .. "  — " .. _G.name .. _G.CMR)
    local activeLogs = _G.Logs[_G.characterId].logs
    if next(activeLogs) ~= nil then
        local sorted = {}
        for index, log in pairs(activeLogs) do
            table.insert(sorted, { index = index, log = log })
        end
        table.sort(sorted, function(a, b)
            if a.log.timeOfDeath ~= b.log.timeOfDeath then
                return a.log.timeOfDeath < b.log.timeOfDeath
            end
            local aInst = _G.Instances[_G.Events[a.index].instance]
            local bInst = _G.Instances[_G.Events[b.index].instance]
            local aCont = aInst and aInst.content or 0
            local bCont = bInst and bInst.content or 0
            if aCont ~= bCont then
                return aCont < bCont
            end
            return _G.Events[a.index].instance < _G.Events[b.index].instance
        end)
        for _, entry in ipairs(sorted) do
            local event    = _G.Events[entry.index]
            local instance = _G.Instances[event.instance]
            local remaining = entry.log.timeOfDeath - currentTime
            Turbine.Shell.WriteLine(
                _G.CM("DIM") .. "· " .. _G.CMR ..
                _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
                " " .. event.name ..
                " " .. _G.CM("DIM") .. "(" .. event.tier .. ")" .. _G.CMR ..
                " " .. entry.log.value ..
                " " .. _G.CM("ACCENT") .. _G.FormatTimeSpan(remaining) .. _G.CMR
            )
        end
    else
        Turbine.Shell.WriteLine("  No active lockouts.")
    end

end

_G.ApplyTheme(_G.Settings.colorTheme or "moria")
