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

    -- iterate logs and compare to the message
    for logIndex, log in ipairs(_G.Events) do

        if (string.find(args.Message, log.match)) then
            ProcessMatch(args.Message, log, logIndex)

        end

    end

end