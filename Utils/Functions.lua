--=================================================================================================
--= Functions     
--= ===============================================================================================
--= utility functions
--=================================================================================================


function PrintAlert(text)
    
    if _G.Settings.printAlerts == false then
        return
    end

    Turbine.Shell.WriteLine(text)

end

function _G.TableContains(t, value)
    for i = 1, #t do
        if t[i] == value then
            return true
        end
    end
    return false
end

function RemoveDuplicates(t)
    local seen = {}
    local result = {}

    for _, value in ipairs(t) do
        if not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end

    return result
end

function FormatTimeSpan(seconds)
    if seconds <= 0 then return "< 1m" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if d > 0 then return d .. "d " .. h .. "h"
    elseif h > 0 then return h .. "h " .. m .. "m"
    else return m .. "m"
    end
end

function _G.GetServerList()
    
    local serverList = {}
    for id, character in pairs(_G.Logs) do
        if character.server and character.enabled then
            serverList[#serverList+1] = character.server
        end
    end

    serverList = RemoveDuplicates(serverList)

    return serverList

end