--=================================================================================================
--= Functions     
--= ===============================================================================================
--= utility functions
--=================================================================================================

import "LootLogs.Utils.EventIndex"


function _G.PrintAlert(text)
    
    if _G.Settings.printAlerts == false then
        return
    end

    Turbine.Shell.WriteLine(text)

end

-- Turbine has no letter-spacing, so the uppercase labels in the design fake it by putting a
-- space between characters. Splits on UTF-8 boundaries so localised labels survive.
function _G.Spaced(text)

    local chars = {}
    for char in string.gmatch(text, "[\1-\127\194-\244][\128-\191]*") do
        chars[#chars + 1] = char
    end

    return table.concat(chars, " ")

end

-- string.upper only touches ASCII, which leaves "Carn Dum" style names half-cased in the
-- uppercase group headers. This also covers the Latin-1 supplement, so the German and
-- French strings survive too.
function _G.Upper(text)

    local out = string.upper(text)

    out = string.gsub(out, "\195([\160-\190])", function(char)
        local byte = string.byte(char)
        if byte == 183 then return "\195" .. char end   -- division sign, not a letter
        return "\195" .. string.char(byte - 32)
    end)

    return out

end

-- Turbine cannot measure a label and does not clip an oversized one either, so a name
-- wider than its column simply runs over its neighbours. Cut it to fit from an average
-- glyph width instead; the full text is still reachable on hover.
function _G.Truncate(text, pixels, charWidth)

    if text == nil or text == "" then return "" end
    if pixels == nil or pixels <= 0 then return "" end

    local chars = {}
    for char in string.gmatch(text, "[\1-\127\194-\244][\128-\191]*") do
        chars[#chars + 1] = char
    end

    local fits = math.floor(pixels / (charWidth or 6.2))
    if #chars <= fits then return text end
    if fits < 3 then return "" end

    return table.concat(chars, "", 1, fits - 2) .. ".."

end


-- A colour between two theme roles. Turbine has no gradients, so the fading section
-- rules in the settings panel are drawn as a few segments stepped with this.
function _G.MixColor(roleA, roleB, t)

    local theme = _G.Themes[_G.Settings.colorTheme or "moria"]
    local a = theme and theme[roleA]
    local b = theme and theme[roleB]
    if a == nil or b == nil then return _G.Theme[roleA] end

    return Turbine.UI.Color(
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t)

end

-- font scale -------------------------------------------------------------------------------------
--
-- Every size in the UI is written at its smallest, and the Font Size setting steps the
-- whole thing up together: the font moves one rung up Turbine's Verdana ladder per step,
-- and the row heights and text columns grow with it so nothing clips.
--
-- Icon sizes deliberately do NOT scale. Turbine clips a .tga to its control rather than
-- resizing it, so a scaled icon box would just crop the art.

-- built from the fonts the client actually exposes, so a missing rung cannot produce nil
local FontLadder = {}
-- even rungs only: an odd one would make a step barely visible
for _, size in ipairs({ 10, 12, 14, 16, 18, 20, 22, 24 }) do
    if Turbine.UI.Lotro.Font["Verdana" .. size] ~= nil then
        FontLadder[#FontLadder + 1] = size
    end
end

local ScaleFactor = { [0] = 1.00, [1] = 1.15, [2] = 1.30 }

local function ScaleStep()
    local step = _G.Settings and _G.Settings.fontScale or 0
    if ScaleFactor[step] == nil then return 0 end
    return step
end

-- The Verdana the given base size becomes at the current setting.
function _G.Font(base)

    local step  = ScaleStep()
    local index = nil
    for i, size in ipairs(FontLadder) do
        if size == base then index = i break end
    end

    if index == nil then
        return Turbine.UI.Lotro.Font["Verdana" .. base] or Turbine.UI.Lotro.Font.Verdana12
    end

    index = math.min(#FontLadder, index + step)
    return Turbine.UI.Lotro.Font["Verdana" .. FontLadder[index]]

end

-- A height, width or padding at the current setting.
function _G.Scaled(pixels)
    return math.floor(pixels * ScaleFactor[ScaleStep()] + 0.5)
end

-- Rough average glyph width for a base size, measured at whatever the Font Size setting
-- has actually promoted it to. Verdana runs close to 0.535 of its nominal size.
function _G.GlyphWidth(base)

    local step  = ScaleStep()
    local index = nil
    for i, size in ipairs(FontLadder) do
        if size == base then index = i break end
    end

    local actual = base
    if index ~= nil then
        actual = FontLadder[math.min(#FontLadder, index + step)]
    end

    return actual * 0.535

end

-- Geometry lives in file-scope locals so it stays cheap to read. Each module registers a
-- function that recomputes its own, and changing the setting runs all of them before the
-- window is rebuilt.
local metricsHooks = {}

function _G.RegisterMetrics(refresh)
    metricsHooks[#metricsHooks + 1] = refresh
    refresh()
end

function _G.ApplyFontScale()
    for _, refresh in ipairs(metricsHooks) do
        refresh()
    end
end

-- Every control caches its font, its colour and its height at build time, so a change to
-- either setting means rebuilding the windows rather than repainting them. Reconstruction has
-- to happen on the NEXT tick: doing it inside the click handler destroys the control the click
-- is still being dispatched to.
--
-- This exists as one function because there are now four windows and two settings that
-- trigger it, and the two call sites had already drifted from a copy of each other.
--
-- _G.QuickLaunchBtn is deliberately NOT rebuilt. Its badge is a top-level window that is never
-- parented to it, so a rebuild would leave the old badge drawn on screen with nothing owning
-- it. The badge digit is the only thing on it that scales, and it is just re-fonted in place.
function _G.RebuildWindows(after)

    -- what has to survive the rebuild
    local mainVisible    = _G.Window ~= nil and _G.Window:IsVisible()
    local popupVisible   = _G.LootPopupWindow ~= nil and _G.LootPopupWindow:IsVisible()
    local popupChest     = _G.LootPopupWindow ~= nil and _G.LootPopupWindow.chest or nil
    local popupSelected  = _G.LootPopupWindow ~= nil and _G.LootPopupWindow.selected or nil
    local browserVisible = _G.LootBrowserWindow ~= nil and _G.LootBrowserWindow:IsVisible()

    local browserState = nil
    if _G.LootBrowserWindow ~= nil then
        browserState = {
            instance = _G.LootBrowserWindow.selectedInstance,
            event    = _G.LootBrowserWindow.selectedEvent,
            tier     = _G.LootBrowserWindow.selectedTier,
        }
    end

    local oldWindow  = _G.Window
    local oldPopup   = _G.LootPopupWindow
    local oldBrowser = _G.LootBrowserWindow

    _G.Window            = nil
    _G.LootPopupWindow   = nil
    _G.LootBrowserWindow = nil

    if oldWindow  then oldWindow:SetVisible(false)  end
    if oldPopup   then oldPopup:SetVisible(false)   end
    if oldBrowser then oldBrowser:SetVisible(false) end

    if _G.QuickLaunchBtn ~= nil and _G.QuickLaunchBtn.badgeLabel ~= nil then
        _G.QuickLaunchBtn.badgeLabel:SetFont(_G.Font(12))
    end

    local reloader = Turbine.UI.Control()
    reloader.Update = function()

        reloader:SetWantsUpdates(false)

        _G.Window = _G.LLWindow()
        _G.Window:SetVisible(mainVisible)

        _G.LootPopupWindow = _G.LootPopup()
        if popupVisible and popupChest ~= nil then
            _G.LootPopupWindow:ShowChest(popupChest)
            -- ShowChest resets the selection to the chest that opened it, so the boss chip the
            -- player was actually looking at is put back afterwards
            if popupSelected ~= nil then
                _G.LootPopupWindow.selected = popupSelected
                _G.LootPopupWindow:Rebuild()
            end
        end

        _G.LootBrowserWindow = _G.LootBrowser()
        if browserState ~= nil and browserState.instance ~= nil then
            _G.LootBrowserWindow.selectedInstance = browserState.instance
            _G.LootBrowserWindow.selectedEvent    = browserState.event
            _G.LootBrowserWindow.selectedTier     = browserState.tier
        end
        if browserVisible then
            _G.LootBrowserWindow:SetVisible(true)
            _G.LootBrowserWindow:RebuildTree()
            _G.LootBrowserWindow:RebuildTable()
        end

        if after ~= nil then after() end

    end
    reloader:SetWantsUpdates(true)

end

-- per-tier squares -------------------------------------------------------------------------------

_G.TierSquare     = 6
_G.TierSquareGap  = 3
_G.TierSquareMax  = 5

-- Summarises one character's logs for one instance, one entry per tier, lowest tier first.
-- Each entry is "done", "used" or "empty", taken from the least progressed boss in that tier:
-- all bosses done or locked -> done, any boss partly used -> used, any boss with nothing
-- recorded -> empty. Returns nil when the character has nothing recorded for the instance at
-- all, which is how the sidebar knows to draw no bar.
function _G.InstanceTierStates(instanceId, characterId)

    local character = characterId ~= nil and _G.Logs[characterId] or nil
    if character == nil or character.logs == nil then return nil end

    -- gather the tiers of this instance, and the boss buckets within each tier.
    --
    -- One instance's events, not all of them: the sidebar calls this once per instance item and
    -- refreshes the lot on every chest anyone loots, so filtering the whole event table here was
    -- the same walk repeated sixty times over.
    local tiers = {}
    for _, eventIndex in ipairs(_G.EventIndex.ForInstance(instanceId)) do
        local event    = _G.Events[eventIndex]
        local tierName = tostring(event.tier)
        if tiers[tierName] == nil then
            tiers[tierName] = {
                name   = tierName,
                order  = (_G.TierOrder and _G.TierOrder[tierName]) or 99,
                bosses = {},
            }
        end
        local bossOrder = event.order or 99
        if tiers[tierName].bosses[bossOrder] == nil then
            tiers[tierName].bosses[bossOrder] = {}
        end
        local indices = tiers[tierName].bosses[bossOrder]
        indices[#indices + 1] = eventIndex
    end

    local ordered = {}
    for _, tier in pairs(tiers) do ordered[#ordered + 1] = tier end
    table.sort(ordered, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.name < b.name
    end)

    local all = {}

    for _, tier in ipairs(ordered) do

        -- start at the most progressed state and let every boss drag it down
        local state    = "done"
        local hasEntry = false

        for _, indices in pairs(tier.bosses) do
            local entry = nil
            for _, eventIndex in ipairs(indices) do
                if character.logs[eventIndex] ~= nil then
                    entry = character.logs[eventIndex]
                    break
                end
            end

            if entry == nil then
                state = "empty"
            else
                hasEntry = true
                if entry.value ~= "Done" and entry.value ~= "Locked" and state ~= "empty" then
                    state = "used"
                end
            end
        end

        all[#all + 1] = { state = state, hasEntry = hasEntry }
    end

    -- More tiers than squares: ten instances carry Solo on top of T1-T5. The design
    -- puts T1 leftmost, so it is the bottom of the ladder that gets dropped, not the
    -- top tier the player cares most about.
    local first = math.max(1, #all - _G.TierSquareMax + 1)

    local states = {}
    local hasAny = false
    for index = first, #all do
        states[#states + 1] = all[index].state
        hasAny = hasAny or all[index].hasEntry
    end

    if not hasAny then return nil end

    return states

end

function _G.InstanceIsPinned(instanceId)

    local tiers = _G.CustomList and _G.CustomList[instanceId]
    if tiers == nil then return false end

    for _, pinned in pairs(tiers) do
        if pinned == true then return true end
    end

    return false

end

-- One square: 1px border, filled unless the tier is untouched. `ground` is the colour behind
-- the square, which an empty square shows through its own middle.
function _G.MakeTierSquare(parent)

    local square = Turbine.UI.Control()
    square:SetParent(parent)
    square:SetSize(_G.TierSquare, _G.TierSquare)
    square:SetMouseVisible(false)

    square.fill = Turbine.UI.Control()
    square.fill:SetParent(square)
    square.fill:SetPosition(1, 1)
    square.fill:SetSize(_G.TierSquare - 2, _G.TierSquare - 2)
    square.fill:SetMouseVisible(false)

    return square

end

function _G.SetTierSquareState(square, state, ground)

    if state == "used" then
        square:SetBackColor(_G.Theme.CHIP_USED_FRAME)
        square.fill:SetBackColor(_G.Theme.CHIP_USED_TEXT)
    elseif state == "done" then
        square:SetBackColor(_G.Theme.CHIP_DONE_FRAME)
        square.fill:SetBackColor(_G.Theme.CHIP_DONE_TEXT)
    else
        square:SetBackColor(_G.Theme.SQUARE_EMPTY)
        square.fill:SetBackColor(ground or _G.Theme.PANEL)
    end

end

-- width a bar of n squares occupies
function _G.TierSquaresWidth(count)

    if count == nil or count <= 0 then return 0 end
    return count * _G.TierSquare + (count - 1) * _G.TierSquareGap

end

-- ------------------------------------------------------------------------------------------------

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
