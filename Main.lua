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
elseif Turbine.Shell.IsCommand("aide") then
    import "LootLogs.Logs.French"
else
    import "LootLogs.Logs.English"
end

-- load plugin data --------------------------------------------------------------------------------
import "LootLogs.Utils.PluginData"

-- functions ---------------------------------------------------------------------------------------
import "LootLogs.ProcessMatch"
import "LootLogs.ChatParsing"

-- ui ----------------------------------------------------------------------------------------------
import "LootLogs.UI.Window.Base"
import "LootLogs.UI.QuickLaunch"

_G.Window = _G.LLWindow()
_G.QuickLaunchBtn = _G.QuickLaunch()