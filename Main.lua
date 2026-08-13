--=================================================================================================
--= Main        
--= ===============================================================================================
--= import all files and start up the plugin
--=================================================================================================



-- lotro imports ----------------------------------------------------------------------------------
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- classes and types -------------------------------------------------------------------------------
import "LootLogs.Utils.Class"
import "LootLogs.Utils.Type"

-- static imports ----------------------------------------------------------------------------------
import "LootLogs.Utils.Constants"
import "LootLogs.Utils.Functions"
import "LootLogs.Utils.Locale"
import "LootLogs.UI.Theme"

if Turbine.Shell.IsCommand("hilfe") then
    import "LootLogs.Logs.German"
    import "LootLogs.Logs.Drops.German"
elseif Turbine.Shell.IsCommand("aide") then
    import "LootLogs.Logs.French"
    import "LootLogs.Logs.Drops.French"
else
    import "LootLogs.Logs.English"
    import "LootLogs.Logs.Drops.English"
end

-- indexes over the data just loaded ---------------------------------------------------------------
import "LootLogs.Utils.EventIndex"

-- load plugin data --------------------------------------------------------------------------------
import "LootLogs.Utils.PluginData"

-- functions ---------------------------------------------------------------------------------------
import "LootLogs.ProcessMatch"
import "LootLogs.LootStats"
import "LootLogs.LootDrops"
import "LootLogs.ChatParsing"
import "LootLogs.Utils.Commands"

-- ui ----------------------------------------------------------------------------------------------
import "LootLogs.UI.Window.Base"
import "LootLogs.UI.Window.LootRow"
import "LootLogs.UI.Window.LootPopup"
import "LootLogs.UI.Window.LootBrowser"
import "LootLogs.UI.QuickLaunch"

_G.Window = _G.LLWindow()
_G.LootPopupWindow = _G.LootPopup()
_G.LootBrowserWindow = _G.LootBrowser()
_G.QuickLaunchBtn = _G.QuickLaunch()