--=================================================================================================
--= Loot stats
--= ===============================================================================================
--= Observed drop rates, the global wishlist, and per-character acquisition history.
--=
--= Everything here is Account scope. _G.LootAcquired is keyed by _G.characterId inside an
--= account table, mirroring how _G.Logs already stores per-character data -- Character scope is
--= not used anywhere in this plugin, and mixing scopes would break the "see all your alts"
--= promise.
--=
--= ONE CORRECTION TO THE HANDOVER. Its RecordChest counted every item in the chest towards the
--= observed rate, including the five other people's. With `opens` incremented once per chest,
--= a six-man run where everyone got the same drop would read 6/1 = 600%.
--=
--= The column this feeds is labelled YOURS, so it counts YOURS: opens is the number of times
--= you opened that chest, and items[base] is the number of those times you personally got that
--= item. Other people's luck is not your drop rate. Fellowship loot still reaches the popup and
--= the run history -- it just does not pretend to be your sample.
--=================================================================================================

_G.LootStats = {}

-- Called exactly once per resolved chest, from LootDrops. This is the ONLY place `opens` is
-- incremented: it is the denominator of every observed rate, and counting it in the UI would
-- inflate it every time the window redrew.
function _G.LootStats.RecordChest(chest)

    local index = chest.logIndex

    if _G.LootObserved[index] == nil then
        _G.LootObserved[index] = { opens = 0, items = {} }
    end

    local observed = _G.LootObserved[index]
    observed.opens = observed.opens + 1

    local acquired = _G.LootAcquired[_G.characterId]
    if acquired == nil then
        acquired = {}
        _G.LootAcquired[_G.characterId] = acquired
    end

    for _, item in ipairs(chest.items) do

        if item.isSelf then

            -- OCCURRENCES, not quantity: the rate answers "how often does this drop for me",
            -- so one line is one drop whether it brought one artifact or three.
            observed.items[item.base] = (observed.items[item.base] or 0) + 1

            -- The history is the opposite question -- how many do I have -- so it takes the
            -- quantity.
            local entry = acquired[item.base]
            if entry == nil then
                entry = { count = 0 }
                acquired[item.base] = entry
            end
            entry.count    = entry.count + (item.quantity or 1)
            entry.lastSeen = Turbine.Engine.GetLocalTime()

        end

    end

    -- PluginData writes hitch, so this is one of only two places allowed to save
    _G.SaveLootObserved()
    _G.SaveLootAcquired()

end

-- count, opens -- both, always. A rate without its sample size is a lie, and the browser is
-- required to print the sample beside every percentage it shows.
function _G.LootStats.Observed(eventIndex, base)

    local observed = _G.LootObserved[eventIndex]
    if observed == nil then return 0, 0 end

    return (observed.items[base] or 0), (observed.opens or 0)

end

function _G.LootStats.IsWished(base)

    return _G.LootWishlist[base] == true

end

function _G.LootStats.ToggleWish(base)

    if _G.LootWishlist[base] then
        _G.LootWishlist[base] = nil
    else
        _G.LootWishlist[base] = true
    end

    _G.SaveLootWishlist()

    return _G.LootWishlist[base] == true

end

-- nil when this character has never looted it
function _G.LootStats.Acquired(base, characterId)

    local acquired = _G.LootAcquired[characterId or _G.characterId]
    if acquired == nil then return nil end

    local entry = acquired[base]
    if entry == nil then return nil end

    return entry.count, entry.lastSeen

end
