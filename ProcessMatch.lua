--=================================================================================================
--= Process match     
--= ===============================================================================================
--= process a match from chat parsing
--=================================================================================================


-- process match ----------------------------------------------------------------------------------
function ProcessMatch(message, log, logIndex)

    local logs = _G.Logs[_G.characterId].logs

    -- open or done
    if log.type == 1 then
        -- upsert log
        logs[logIndex] = {
            value = "Done",
            timeOfDeath = CalculateDeath(log)
        }

    -- extract value
    elseif log.type == 2 then

    -- ...
    elseif log.type == 3 then

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