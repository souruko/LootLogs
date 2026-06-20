--=================================================================================================
--= Contants     
--= ===============================================================================================
--= define global constants
--=================================================================================================


_G.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
_G.name = _G.localPlayer:GetName()
_G.characterId = nil

_G.Tab = {}
_G.Tab.Content = 1
_G.Tab.Characters = 2

_G.Servers = {
    "Orcrist [EU]",
    "Grond [EU]",
    "Sting",
    "Peregrin [RP]",
    "Meriadoc [EU-RP]",
    "Glamdring",
    "Angmar",
    "Mordor [EU]",
}

-- _G.Settings = {}
-- _G.Logs = {}

_G.ClassIcons = {
    
	[ Turbine.Gameplay.Class.Hunter ]     = 0x41007dea, --0x410000E8 --0x41007DDA --0x41008201 --0x410095C2                 --0x41108678
	[ Turbine.Gameplay.Class.Warden ]     = 0x410ea239, --0x410095C5 --0x410EA237                                           --0x410F25C2
	[ Turbine.Gameplay.Class.Burglar ]    = 0x41007deb, --0x410000E4 --0x41007DDB --0x41007E87 --0x410095BB                 --0x41108674
	[ Turbine.Gameplay.Class.Captain ]    = 0x41007de7, --0x410000E5 --0x41007DD7 --0x410081F3 --0x410095C5                 --0x41108675
	[ Turbine.Gameplay.Class.Champion ]   = 0x41007dec, --0x410000E6 --0x41007DDC --0x410081CD --0x410095B5                 --0x41108676
	[ Turbine.Gameplay.Class.Guardian ]   = 0x41007de8, --0x410000E7 --0x41007DD8 --0x410081FF --0x410095B8                 --0x41108677
	[ Turbine.Gameplay.Class.Minstrel ]   = 0x41007de6, --0x410000E9 --0x41007DD6 --0x41004C49 --0x410081F7                 --0x4110867A
	[ Turbine.Gameplay.Class.Beorning ]   = 0x4115370d,
	[ Turbine.Gameplay.Class.LoreMaster ] = 0x41007de9, --0x410000E9 --0x41007DD9 --0x410081FC --0x410095BF                 --0x41108679
	[ Turbine.Gameplay.Class.RuneKeeper ] = 0x410ea238, --0x410E6BF4 --0x410EA236                                           --0x4110867B
	[ Turbine.Gameplay.Class.Brawler ]    = 0x411F516F, --1092680920
    [ Turbine.Gameplay.Class.Mariner ]    = 0x4122f875,

	[ Turbine.Gameplay.Class.Weaver ]     = 0x41007DEE, --0x41007DE0 --0x41007DCA
	[ Turbine.Gameplay.Class.Reaver ]     = 0x41007DED, --0x41007DDD --0x41007DC9
	[ Turbine.Gameplay.Class.Defiler ]    = 0x410E6BF4, --0x410E6BF5 --0x410E6BF4
	[ Turbine.Gameplay.Class.Stalker ]    = 0x41007DF1, --0x41007DE1 --0x41007DCD
	[ Turbine.Gameplay.Class.WarLeader ]  = 0x41007DF0, --0x41007DDD --0x41007DCC
	[ Turbine.Gameplay.Class.BlackArrow ] = 0x41007DEF  --0x41007DDF --0x41007DCB

}