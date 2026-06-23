--=================================================================================================
--= Process match     
--= ===============================================================================================
--= process a match from chat parsing
--=================================================================================================


-- process match ----------------------------------------------------------------------------------
function ProcessMatch(message, log, logIndex)

    local logs     = _G.Logs[_G.characterId].logs
    local newEntry = nil

    -- mark as done
    if log.type == _G.EventTypes.Done then
        local tod = CalculateDeath(log)
        if tod == nil then return end
        newEntry = { value = "Done", timeOfDeath = tod }

    -- quest / progress tracker: extract (X/Y) from message
    elseif log.type == _G.EventTypes.ExtractValue then
        local progress = string.match(message, "%((%d+/%d+)%)")
                      or string.match(message, "%.(%d+/%d+)%.")
        local value
        if progress then
            local a, b = string.match(progress, "(%d+)/(%d+)")
            value = (a == b) and "Done" or progress
        else
            value = "Done"
        end
        -- don't overwrite a "Done" entry with partial progress
        if logs[logIndex] == nil or logs[logIndex].value ~= "Done" or value == "Done" then
            local tod = CalculateDeath(log)
            if tod == nil then return end
            newEntry = { value = value, timeOfDeath = tod }
        end

    -- instance chest with favoured / common / locked states
    elseif log.type == _G.EventTypes.Completions then
        local favCount = string.match(message, ": You have (%d+) favoured completion")
        local comCount = not favCount and string.match(message, ": You have (%d+) completion")
        local isReset  = not favCount and not comCount and string.find(message, "resets in: ")

        local value
        if favCount then
            value = favCount .. "f"
        elseif comCount then
            value = comCount .. "c"
        elseif isReset then
            value = "Locked"
        end

        if value then
            local tod = CalculateDeath(log)
            if tod == nil then return end
            newEntry = { value = value, timeOfDeath = tod }
        end

    end

    if newEntry then
        logs[logIndex] = newEntry
    end

    SaveLogs()

    if newEntry then
        local event     = _G.Events[logIndex]
        local instance  = _G.Instances[event.instance]
        local remaining = newEntry.timeOfDeath - Turbine.Engine.GetLocalTime()
        _G.PrintAlert(
            _G.CM("ACCENT") .. "LL:" .. _G.CMR ..
            " [" .. (instance and instance.name or "?") .. "] " ..
            event.name .. " (" .. event.tier .. ")" ..
            " - " .. newEntry.value .. ", resets in " ..
            _G.CM("ACCENT") .. FormatTimeSpan(remaining) .. _G.CMR
        )
    end

    if _G.QuickLaunchBtn then
        _G.QuickLaunchBtn:IncrementBadge()
    end

    if _G.Window and _G.Window.contentView then
        _G.Window.contentView:UpdateContent()
    end

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