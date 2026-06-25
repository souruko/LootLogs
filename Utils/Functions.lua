--=================================================================================================
--= Functions     
--= ===============================================================================================
--= utility functions
--=================================================================================================


function _G.PrintAlert(text)
    
    if _G.Settings.PrintAlerts == false then
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

-- Returns an LOTRO chat color markup start tag for the given theme color slot.
-- Usage: CM("ACCENT") .. "text" .. CMR
function _G.CM(colorKey)
    local t = _G.Themes[_G.Settings.colorTheme or "moria"]
    local rgb = t and t[colorKey]
    if not rgb then return "" end
    return string.format("<rgb=#%02X%02X%02X>",
        math.floor(rgb[1] * 255),
        math.floor(rgb[2] * 255),
        math.floor(rgb[3] * 255))
end

_G.CMR = "</rgb>"

function _G.FormatTimeSpan(seconds)
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


-- calculate death --------------------------------------------------------------------------------
function _G.CalculateDeath(log)

    local currentTime    = Turbine.Engine.GetLocalTime()
    local current        = Turbine.Engine.GetDate()
    local resetTimeOfDay = log.reset.time + Settings.timezone
    local currentHours   = current.Hour

    local daysUntilReset = 0
    local dayOfWeek      = current.DayOfWeek

    while true do

        if _G.TableContains(log.reset.days, dayOfWeek) then
            -- Use this day if it's in the future, or if it's today and the reset hasn't passed yet.
            if daysUntilReset > 0 or resetTimeOfDay > currentHours then
                break
            end
        end

        daysUntilReset = daysUntilReset + 1
        if daysUntilReset > 8 then
            _G.PrintAlert("LL: Error: log has no reset day: " .. log.name)
            return
        end
        dayOfWeek = dayOfWeek % 7 + 1

    end

    local timeUntilDeath = daysUntilReset * 24 * 3600
                         + (resetTimeOfDay - currentHours) * 3600
                         - current.Minute * 60
                         - current.Second

    return currentTime + timeUntilDeath

end
