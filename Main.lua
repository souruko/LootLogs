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
import "LootLogsBeta.Utils.Class"
import "LootLogsBeta.Utils.Type"

-- static imports ----------------------------------------------------------------------------------
import "LootLogsBeta.Utils.Constants"
import "LootLogsBeta.Utils.Functions"
import "LootLogsBeta.Utils.Locale"

if Turbine.Shell.IsCommand("hilfe") then
    import "LootLogsBeta.Logs.German"
elseif Turbine.Shell.IsCommand("aide") then
    import "LootLogsBeta.Logs.French"
else
    import "LootLogsBeta.Logs.English"
end

-- load plugin data --------------------------------------------------------------------------------
import "LootLogsBeta.Utils.PluginData"

-- functions ---------------------------------------------------------------------------------------
import "LootLogsBeta.ProcessMatch"
import "LootLogsBeta.ChatParsing"

-- ui ----------------------------------------------------------------------------------------------
import "LootLogsBeta.UI.Window.Base"
import "LootLogsBeta.UI.QuickLaunch"

_G.Window = _G.LLWindow()
_G.QuickLaunchBtn = _G.QuickLaunch()