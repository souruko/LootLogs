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

    -- filter chat types
    if (args.ChatType == Turbine.ChatType.FellowLoot
        or args.ChatType == Turbine.ChatType.SelfLoot
        or args.ChatType == Turbine.ChatType.PlayerCombat
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