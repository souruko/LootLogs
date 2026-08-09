--=================================================================================================
--= Commands
--= ===============================================================================================
--= The /lootlogs shell command, and the registry its subcommands hang off.
--=
--= Until now the plugin had no shell command at all -- the title bar Quickslot fires the
--= game's own /raid locks alias, which is not the same thing. The Loot Drops feature needs
--= one (docs/design/loot-drops/), so this is the host: modules register their subcommand and
--= never touch Turbine.Shell themselves.
--=
--=     _G.RegisterCommand("drops", "open the loot browser", function(args) ... end)
--=
--= `args` is everything after the subcommand, whitespace trimmed, "" when there was nothing.
--=================================================================================================

local subcommands = {}
local order       = {}

function _G.RegisterCommand(name, help, run)

    if subcommands[name] == nil then
        order[#order + 1] = name
    end

    subcommands[name] = { help = help, run = run }

end

local function Usage()

    Turbine.Shell.WriteLine(_G.CM("ACCENT") .. "LootLogs" .. _G.CMR
        .. _G.CM("DIM") .. "  — /lootlogs <command>" .. _G.CMR)

    for _, name in ipairs(order) do
        Turbine.Shell.WriteLine(_G.CM("DIM") .. "  " .. _G.CMR
            .. _G.CM("HOVER") .. name .. _G.CMR
            .. _G.CM("DIM") .. "  — " .. subcommands[name].help .. _G.CMR)
    end

end

-- ------------------------------------------------------------------------------------------------

local LootLogsCommand = class(Turbine.ShellCommand)

function LootLogsCommand:Constructor()
    Turbine.ShellCommand.Constructor(self)
end

function LootLogsCommand:Execute(command, arguments)

    arguments = arguments or ""

    local name, rest = string.match(arguments, "^%s*(%S+)%s*(.-)%s*$")

    if name == nil then
        Usage()
        return
    end

    local subcommand = subcommands[string.lower(name)]

    if subcommand == nil then
        Turbine.Shell.WriteLine(_G.CM("DIM") .. "LootLogs: no such command "
            .. _G.CMR .. name)
        Usage()
        return
    end

    -- a subcommand that errors must not take the shell command down with it, or the only
    -- way back is a plugin reload
    local ok, err = pcall(subcommand.run, rest or "")
    if not ok then
        Turbine.Shell.WriteLine(_G.CM("DIM") .. "LootLogs: " .. _G.CMR .. tostring(err))
    end

end

function LootLogsCommand:GetHelp()
    return "LootLogs — /lootlogs for the command list"
end

-- ------------------------------------------------------------------------------------------------

_G.LootLogsCommand = LootLogsCommand()

-- A reload leaves the previous registration pointing at a Lua state that no longer exists, so
-- AddCommand can legitimately fail here. Losing the command is survivable; erroring out of
-- Main.lua before the UI is built is not.
for _, name in ipairs({ "lootlogs", "ll" }) do
    local ok, err = pcall(Turbine.Shell.AddCommand, name, _G.LootLogsCommand)
    if not ok then
        Turbine.Shell.WriteLine(_G.CM("DIM")
            .. "LootLogs: /" .. name .. " unavailable (" .. tostring(err) .. ")" .. _G.CMR)
    end
end

-- The plugin's only unload hook. It unregisters the command so the next load can register
-- cleanly, and settles anything the loot feature still has open -- a chest looted a second
-- before /plugins unload would otherwise be lost with its window still running.
--
-- Everything is pcall'd: an error thrown here happens while the plugin is being torn down,
-- where there is nothing left to report it to.
local plugin = _G.Plugins and _G.Plugins["LootLogs"]

if plugin ~= nil then
    plugin.Unload = function()

        if _G.LootDrops ~= nil then
            pcall(_G.LootDrops.Flush)
        end

        pcall(Turbine.Shell.RemoveCommand, _G.LootLogsCommand)

    end
end

-- ------------------------------------------------------------------------------------------------
-- subcommands

_G.RegisterCommand("help", "this list", function()
    Usage()
end)

-- Builds a run out of whatever _G.Drops actually contains, so the popup can be laid out and
-- judged without spending an instance lockout to see it. It writes _G.LootDrops.currentRun,
-- which is the same thing a real run produces -- so what you are looking at is the real
-- window driven by real catalogued data, not a mock-up.
local function DemoRun()

    if _G.Drops == nil or next(_G.Drops) == nil then
        Turbine.Shell.WriteLine(_G.CM("DIM")
            .. "LootLogs: no drops catalogued for this client's language" .. _G.CMR)
        return nil
    end

    -- the instance+tier with the most catalogued chests is the one worth showing
    local groups = {}
    for eventIndex in pairs(_G.Drops) do
        local event = _G.Events[eventIndex]
        if event ~= nil then
            local key = tostring(event.instance) .. "|" .. tostring(event.tier)
            if groups[key] == nil then
                groups[key] = { instance = event.instance, tier = event.tier, events = {} }
            end
            local list = groups[key].events
            list[#list + 1] = eventIndex
        end
    end

    local best = nil
    for _, group in pairs(groups) do
        if best == nil or #group.events > #best.events then best = group end
    end
    if best == nil then return nil end

    table.sort(best.events, function(a, b)
        return (_G.Events[a].order or 99) < (_G.Events[b].order or 99)
    end)

    local fellows = { "Aldwyn", "Brunhild", "Corin", "Dwalinn", "Eowyth" }
    local run = { instance = best.instance, tier = best.tier, t0 = 0, chests = {} }

    for _, eventIndex in ipairs(best.events) do

        local items = {}

        for rowIndex, drop in ipairs(_G.Drops[eventIndex]) do
            items[#items + 1] = {
                base     = drop.item,
                level    = 151,
                -- anything with a plural spelling is shown stacked, so the demo actually
                -- exercises the "3x Name" path rather than only ever rendering singles
                quantity = drop.plural ~= nil and 3 or 1,
                player   = rowIndex == 1 and _G.name or fellows[(rowIndex % #fellows) + 1],
                isSelf   = rowIndex == 1,
                t        = 0,
            }
        end

        run.chests[#run.chests + 1] = {
            logIndex = eventIndex,
            event    = _G.Events[eventIndex],
            instance = best.instance,
            tier     = best.tier,
            t        = 0,
            items    = items,
        }

    end

    _G.LootDrops.currentRun = run

    return run.chests[#run.chests]

end

_G.RegisterCommand("loot", "reopen the loot popup  ('demo' fills it with catalogued data)",
    function(args)

        if _G.LootPopupWindow == nil then
            Turbine.Shell.WriteLine(_G.CM("DIM") .. "LootLogs: no loot popup" .. _G.CMR)
            return
        end

        if string.lower(args) == "demo" then
            local chest = DemoRun()
            if chest ~= nil then
                _G.LootPopupWindow:ShowChest(chest)
            end
            return
        end

        -- no argument: reopen whatever the last chest was
        local run = _G.LootDrops and _G.LootDrops.currentRun
        if run == nil or #run.chests == 0 then
            Turbine.Shell.WriteLine(_G.CM("DIM")
                .. "LootLogs: no chest looted yet this session"
                .. " — try /lootlogs loot demo" .. _G.CMR)
            return
        end

        _G.LootPopupWindow:ShowChest(run.chests[#run.chests])

    end)

_G.RegisterCommand("drops", "open the loot browser", function()

    if _G.LootBrowserWindow == nil then
        Turbine.Shell.WriteLine(_G.CM("DIM") .. "LootLogs: no loot browser" .. _G.CMR)
        return
    end

    _G.LootBrowserWindow:Toggle()

end)
