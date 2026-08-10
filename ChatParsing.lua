--=================================================================================================
--= Chat parsing        
--= ===============================================================================================
--= parse the chat and call handlers if a match is found
--=================================================================================================




-- lotro chat interface ---------------------------------------------------------------------------
function Turbine.Chat.Received(sender, args)

    -- filter nil massages
    if  (args.Message  == nil) then
        return

    end

    -- Loot lines are the Loot Drops feature's only input. They can never match an _G.Events
    -- entry, so they are handled here and go no further -- which is what the filter below did
    -- with them before the feature existed. Wrapped, so a line the parser chokes on cannot
    -- take the whole chat subscription down with it.
    if (args.ChatType == Turbine.ChatType.SelfLoot
        or args.ChatType == Turbine.ChatType.FellowLoot) then

        if _G.LootDrops then
            local ok, err = pcall(_G.LootDrops.HandleChat, args.ChatType, args.Message)
            if not ok and _G.Settings.lootDebug then
                Turbine.Shell.WriteLine("LL loot error: " .. tostring(err))
            end
        end

        return

    end

    -- filter chat types
    if (args.ChatType == Turbine.ChatType.PlayerCombat
        or args.ChatType == Turbine.ChatType.EnemyCombat) then
        return

    end

    -- Entering an instance. Every instance hands out a quest on entry, and that quest is
    -- specific to the instance AND the tier -- so the line identifies both, and it is the only
    -- thing that says a run BEGAN. A chest message only ever says one was looted.
    --
    -- MATCHED AGAINST DATA, never against "New Quest:" alone: the game hands out thousands of
    -- quests, and treating any of them as an instance entry would reset the run every time the
    -- player picked something up in a quest hub.
    --
    -- The prefix test is a cheap gate so the entry table is only walked for the handful of
    -- lines that could possibly be one.
    if _G.LootDrops and _G.InstanceEntries and _G.InstanceEntryPrefix
        and string.find(args.Message, _G.InstanceEntryPrefix) then

        for _, entry in ipairs(_G.InstanceEntries) do
            if string.find(args.Message, entry.match) then
                pcall(_G.LootDrops.OnRunStart, entry.instance, entry.tier)
                break

            end

        end

    end

    -- deliberately does not return: quest trackers are matched below and some of them arrive
    -- on this same chat type

    -- iterate logs and compare to the message
    for logIndex, log in ipairs(_G.Events) do

        if (string.find(args.Message, log.match)) then
            ProcessMatch(args.Message, log, logIndex)

        end

    end

end