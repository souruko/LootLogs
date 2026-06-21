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

    local currentTime = Turbine.Engine.GetLocalTime()
    local current = Turbine.Engine.GetDate()

    local daysUntilReset = -1
    local dayOfWeek = current.DayOfWeek

    while true do
        
        if _G.TableContains(log.reset.days, dayOfWeek) then
            break
        end

        if daysUntilReset > 7 then
            -- make sure to break the while
            PrintAlert("LL: Error: log has no reset day: " .. log.name)
            return
        end

        daysUntilReset = daysUntilReset + 1

        dayOfWeek = dayOfWeek % 7
        dayOfWeek = dayOfWeek + 1

    end

    -- round hours up because minutes will be added
    local currentHours = current.Hour + 1
    -- add timezone
    local resetTimeOfDay = log.reset.time + Settings.timezone
    if resetTimeOfDay > currentHours then
        -- if resetTime > currentHour add a full day and the rest of the hours
        daysUntilReset = daysUntilReset + 1

    else
        -- if restTime is smaller subtract 24 hours
        currentHours = currentHours - 24

    end

    local timeUntilDeath = (daysUntilReset * 24 * 60 * 60) -- days
    timeUntilDeath = timeUntilDeath + ((resetTimeOfDay - currentHours) * 60 * 60) -- hours
    timeUntilDeath = timeUntilDeath + ((60 - current.Minute + 1) * 60) -- minutes
    timeUntilDeath = timeUntilDeath + (60 - current.Second) -- seconds

    Turbine.Shell.WriteLine(currentTime + timeUntilDeath)

    return currentTime + timeUntilDeath

end