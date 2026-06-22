--=================================================================================================
--= Process match     
--= ===============================================================================================
--= process a match from chat parsing
--=================================================================================================


-- process match ----------------------------------------------------------------------------------
function ProcessMatch(message, log, logIndex)

    local logs = _G.Logs[_G.characterId].logs

    -- mark as done
    if log.type == EventTypes.Done then
        logs[logIndex] = {
            value = "Done",
            timeOfDeath = CalculateDeath(log)
        }

    -- quest / progress tracker: extract (X/Y) from message
    elseif log.type == EventTypes.ExtractValue then
        local progress = string.match(message, "%((%d+/%d+)%)")
        local value
        if progress then
            local a, b = string.match(progress, "(%d+)/(%d+)")
            value = (a == b) and "Done" or progress
        else
            value = "Done"
        end
        -- don't overwrite a "Done" entry with partial progress
        if logs[logIndex] == nil or logs[logIndex].value ~= "Done" or value == "Done" then
            logs[logIndex] = {
                value = value,
                timeOfDeath = CalculateDeath(log)
            }
        end

    -- instance chest with favoured / common / locked states
    elseif log.type == EventTypes.Completions then
        local favCount = string.match(message, ": You have (%d+) favoured completion")
        local comCount = not favCount and string.match(message, ": You have (%d+) completion")
        local isReset  = not favCount and not comCount and string.find(message, "resets in: ")

        local value
        if favCount then
            value = "Fav: " .. favCount
        elseif comCount then
            value = "Com: " .. comCount
        elseif isReset then
            value = "Locked"
        end

        if value then
            logs[logIndex] = {
                value = value,
                timeOfDeath = CalculateDeath(log)
            }
        end

    end

    SaveLogs()

end


-- calculate death --------------------------------------------------------------------------------
function CalculateDeath(log)

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
            PrintAlert("LL: Error: log has no reset day: " .. log.name)
            return
        end
        dayOfWeek = dayOfWeek % 7 + 1

    end

    local timeUntilDeath = daysUntilReset * 24 * 3600
                         + (resetTimeOfDay - currentHours) * 3600
                         - current.Minute * 60
                         - current.Second

    Turbine.Shell.WriteLine(currentTime + timeUntilDeath)

    return currentTime + timeUntilDeath

end