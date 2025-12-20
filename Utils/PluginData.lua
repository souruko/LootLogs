--=================================================================================================
--= Plugin data
--= ===============================================================================================
--= load and save plugin data
--=================================================================================================

-- server -----------------------------------------------------------------------------------------

function SaveServerCompleteHandler()
    PrintAlert("LL: Server saved!")

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
-- printAlerts
-- printWelcome
-- useToDo
--
-- window
-- -- width
-- -- height
-- -- left
-- -- top

function SaveSettingsCompleteHandler()
    PrintAlert("LL: Settings saved!")

end

function _G.SaveSettings()
    -- Turbine.PluginData.Save(Turbine.DataScope.Account, "LootSettings", _G.Logs, SaveSettingsCompleteHandler)

end

function LoadSettingsCompleteHandler()


end

_G.Settings = Turbine.PluginData.Load(Turbine.DataScope.Account, "LootSettings", LoadSettingsCompleteHandler)

-- set defaults
if _G.Settings == nil then
    _G.Settings = {}
    _G.Settings.timezone = 1
    _G.Settings.printAlerts = true
    _G.Settings.printWelcome = true
    _G.Settings.showToDo = true
    _G.Settings.window = {}
    _G.Settings.window.left = 200
    _G.Settings.window.top = 200
    _G.Settings.window.width = 1000
    _G.Settings.window.height = 800
end

-- logs ---------------------------------------------------------------------------------------------
-- structure
-- 
-- ['character name'] {
--     class = 'character class',
--     enabled = true,
--     logs['eventIndex'] {
--         value = 'displayed value',
--         timeOfDeath = 'end timestamp'
--     }
-- }


function SaveLogsCompleteHandler()

end

function _G.SaveLogs()
    Turbine.PluginData.Save(Turbine.DataScope.Server, "LootLogs", _G.Logs, SaveLogsCompleteHandler)

end

function LoadLogsCompleteHandler()

end

_G.Logs = Turbine.PluginData.Load(Turbine.DataScope.Server, "LootLogs", LoadLogsCompleteHandler)

-- set defaults
if _G.Logs == nil then
    _G.Logs = {}
end

-- upsert current character
if _G.Logs[_G.name] == nil then
    _G.Logs[_G.name] = {
        ["class"] = _G.localPlayer:GetClass(),
        ["enabled"] = true,
        ["logs"] = {}
    }

end

-- remove "dead" logs
local currentTime = Turbine.Engine.GetLocalTime()

-- iterate all characters
for characterName, character in pairs(_G.Logs) do
    -- iterate all logs
    for index, log in pairs(character.logs) do
        
        if log.timeOfDeath <= currentTime then
            PrintAlert("LL: " .. _G.Events[index].name .. " has reset.")
            character.logs[index] = nil
        end

    end

end

-- write current characters logs into chat
if _G.Settings.printWelcome then

    Turbine.Shell.WriteLine("LL: == LootLogs ==============================")
    if #_G.Logs[_G.name].logs > 0 then 
        for index, log in pairs(_G.Logs[_G.name].logs) do
            Turbine.Shell.WriteLine("LL: " .. _G.Events[index].name .. " will reset in " .. math.floor(log.timeOfDeath - currentTime)  .. "s.")
        end

    else
        Turbine.Shell.WriteLine("LL: You do not have any logs on this character.")

    end
    
end
