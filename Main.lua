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
import "LootLogs2.Utils.Class"
import "LootLogs2.Utils.Type"

-- static imports ----------------------------------------------------------------------------------
import "LootLogs2.Utils.Constants"
import "LootLogs2.Utils.Functions"
import "LootLogs2.Logs"

-- load plugin data --------------------------------------------------------------------------------
import "LootLogs2.Utils.PluginData"

-- functions ---------------------------------------------------------------------------------------
import "LootLogs2.ProcessMatch"
import "LootLogs2.ChatParsing"

-- ui ----------------------------------------------------------------------------------------------
import "LootLogs2.UI.Window.Base"
import "LootLogs2.UI.QuickLaunch"

_G.Window = _G.LLWindow()
QuickLaunchBtn = _G.QuickLaunch()