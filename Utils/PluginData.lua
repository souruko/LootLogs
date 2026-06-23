--=================================================================================================
--= Plugin data
--= ===============================================================================================
--= load and save plugin data
--=================================================================================================

function FindCurrentCharacter()
    for id, character in pairs(_G.Logs) do
        if character.name == _G.name then
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

end

function LoadServerCompleteHandler()

end

_G.Server = Turbine.PluginData.Load(Turbine.DataScope.Server, "GetServer", LoadServerCompleteHandler)



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

end

function LoadSettingsCompleteHandler()


end

_G.Settings = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootSettings", LoadSettingsCompleteHandler)

-- set defaults
if _G.Settings == nil then
    _G.Settings = {}
    _G.Settings.timezone = 1
    _G.Settings._G.PrintAlerts = true
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

    _G.Settings.customList = {}

    _G.Settings.quickLaunch = {}
    _G.Settings.quickLaunch.left = 100
    _G.Settings.quickLaunch.top  = 100

end

if _G.Settings.language == nil then
    _G.Settings.language = "en"
end

if _G.Settings.customList == nil then
    _G.Settings.customList = {}
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

end

function LoadLogsCompleteHandler()

end

_G.Logs = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootLogs", LoadLogsCompleteHandler)

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
else
    _G.Logs[_G.characterId].server = _G.Server
    _G.Logs[_G.characterId].level = _G.localPlayer:GetLevel()
end

-- remove "dead" logs
local currentTime = Turbine.Engine.GetLocalTime()
local logHasChanged = false

-- iterate all characters
for id, character in pairs(_G.Logs) do
    -- collect expired indices first to avoid mutating while iterating
    local toDelete = {}
    for index, log in pairs(character.logs) do
        if log.timeOfDeath <= currentTime then
            table.insert(toDelete, index)
        end
    end
    for _, index in ipairs(toDelete) do
        local event    = _G.Events[index]
        local instance = _G.Instances[event.instance]
        if event.onlyResetIfDone then
            character.logs[index].timeOfDeath = CalculateDeath(event)
            logHasChanged = true
        else
            _G.PrintAlert(
                _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
                " " .. event.name ..
                " " .. _G.CM("DIM") .. "(" .. event.tier .. ")" .. _G.CMR ..
                " reset for " .. _G.CM("ACCENT") .. character.name .. _G.CMR
            )
            character.logs[index] = nil
            logHasChanged = true
        end
    end
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
            return a.log.timeOfDeath < b.log.timeOfDeath
        end)
        for _, entry in ipairs(sorted) do
            local event    = _G.Events[entry.index]
            local instance = _G.Instances[event.instance]
            local remaining = entry.log.timeOfDeath - currentTime
            Turbine.Shell.WriteLine(
                _G.CM("DIM") .. " · " .. _G.CMR ..
                _G.CM("HOVER") .. "[" .. (instance and instance.name or "?") .. "]" .. _G.CMR ..
                " " .. event.name ..
                " " .. _G.CM("DIM") .. "(" .. event.tier .. ")" .. _G.CMR ..
                "  " .. _G.CM("ACCENT") .. _G.FormatTimeSpan(remaining) .. _G.CMR
            )
        end
    else
        Turbine.Shell.WriteLine("  No active lockouts.")
    end

end

_G.ApplyTheme(_G.Settings.colorTheme or "moria")