_G.EventTypes = {
    Done         = 1,
    ExtractValue = 2,
    Completions  = 3,
}

local Sunday    = 1
local Monday    = 2
local Thusday   = 3
local Wednesday = 4
local Thursday  = 5
local Frieday   = 6
local Saturday  = 7

local Daily   = {Sunday, Monday, Thusday, Wednesday, Thursday, Frieday, Saturday}
local Weekly  = {Thursday}
local TriWeek = {Monday, Thursday, Saturday}

-- tier display order -------------------------------------------------------------------
_G.TierOrder = {
    ["Solo"]     = 1,
    ["T1"]       = 2,
    ["T2"]       = 3,
    ["T3"]       = 4,
    ["T3+"]      = 4,
    ["T4"]       = 5,
    ["T5"]       = 6,
    ["RTs"]      = 7,
    ["Quests"]    = 8,
    ["Daylies"]    = 9,
    ["Weeklies"]    = 10,
    ["Motes"]    = 11,
    ["Embers"]   = 12,
    ["Virtues"]  = 13,
}

-- content -------------------------------------------------------------------------------------
_G.Content = {
    [11] = { name = "Kingdoms of Harad",  level = "160" },
    [10] = { name = "Legacy of Morgoth",  level = "160" },
    [9] = { name = "Corsairs of Umbar",    level = "150" },
    [8] = { name = "Return to Carn Dûm",  level = "150" },
    [7] = { name = "Fate of Gundabad",    level = "140" },
    [6]  = { name = "War of Three Peaks",  level = "140" },
    [5] = { name = "Minas Morgul",         level = "130" },
    [4] = { name = "Grey Mountains",       level = "120" },
    [3] = { name = "Other Instances",     level = "" },
    [2] = { name = "Miscellaneous",       level = "" },
    [1] = { name = "Festivals",              level = "" },
}

-- instances -----------------------------------------------------------------------------------
_G.Instances = {
    -- Kingdoms of Harad
    [54]  = { name = "The Treasure Caves of Hurum Kâna",  content = 11 },
    [53] = { name = "Ekal-nêbi, the Fallen Palace",       content = 11 },
    [52] = { name = "Kôth Rau, the Wailing Hold",         content = 11 },
    [51] = { name = "Pagru-kirít, the Garden of Corpses", content = 11 },
    [50] = { name = "The Folly of Nagakhêdi",             content = 11 },
    [49] = { name = "Quests: Kingdoms of Harad",          content = 11 },
    -- Legacy of Morgoth
    [48] = { name = "Ashunûg, the Fane of the Accursed",  content = 10 },
    [47] = { name = "Nirgambâr, the Restless Tomb",        content = 10 },
    [46] = { name = "Dun Shûma, The King's Fortress",      content = 10 },
    [45] = { name = "Tûl Zakana, the Well of Forgetting",  content = 10 },
    [44] = { name = "The Temple of Utug-bûr",              content = 10 },
    [43] = { name = "Quests: Legacy of Morgoth",           content = 10 },
    -- Corsairs of Umbar
    [42] = { name = "The Isle of Storms",                  content = 9 },
    [41] = { name = "The Streets of Râhal Bakh",           content = 9 },
    [40] = { name = "Dahâl Huliz, The Arena",              content = 9 },
    [39] = { name = "The Dragon and the Storm",            content = 9 },
    [38] = { name = "Depths of Mâkhda Khorbo",            content = 9 },
    [37] = { name = "Quests: Umbar",                       content = 9 },
    [36] = { name = "Craft Guilds",                        content = 9 },
    -- Return to Carn Dûm
    [35] = { name = "Sant Lhoer, the Poison Gardens",       content = 8 },
    [34] = { name = "Thaurisgar, the Vile Apothecary",     content = 8 },
    [33] = { name = "Sagroth, Lair of Vermin",             content = 8 },
    [32] = { name = "Gwathrenost, the Witch-king's Citadel", content = 8 },
    [31] = { name = "Quests: Carn Dûm",                   content = 8 },
    -- Fate of Gundabad
    [30] = { name = "Assault on Dhúrstrok",                content = 7 },
    [29] = { name = "Den of Pughlak",                      content = 7 },
    [28] = { name = "Adkhât-zahhar, the Houses of Rest",   content = 7 },
    [27] = { name = "The Hiddenhoard of Abnankâra",        content = 7 },
    [26] = { name = "Quests: Gundabad",                    content = 7 },
    -- War of Three Peaks
    [25] = { name = "Shakalush, the Stair Battle",         content = 6 },
    [24] = { name = "Amdân Dammul, the Bloody Threshold",  content = 6 },
    [23] = { name = "The Fall of Khazad-dûm",              content = 6 },
    -- Minas Morgul
    [22] = { name = "Eithel Gwaur, the Filth-well",             content = 5 },
    [21] = { name = "Gath Daeroval, the Shadow-roost",          content = 5 },
    [20] = { name = "Gorthad Nûr, the Deep-barrow",             content = 5 },
    [19] = { name = "The Harrowing of Morgul",                  content = 5 },
    [18] = { name = "Bâr Nírnaeth, the Houses of Lamentation",  content = 5 },
    [17] = { name = "Ghashan-Kútot, the Halls of Black Lore",   content = 5 },
    [16] = { name = "The Fallen Kings",                         content = 5 },
    [15] = { name = "Remmorchant, the Net of Darkness",         content = 5 },
    [14] = { name = "Quests: Minas Morgul",                     content = 5 },
    -- Grey Mountains
    [13] = { name = "The Anvil of Winterstith",                 content = 4 },
    -- Other Instances
    [12] = { name = "Featured Instance",                        content = 3 },
    [11] = { name = "Agoroth, the Narrowdelve",                 content = 3 },
    [10] = { name = "Askâd-mazal, the Chamber of Shadows",     content = 3 },
    [9] = { name = "Woe of the Willow",                        content = 3 },
    [8] = { name = "Sarch Vorn, the Black Grave",              content = 3 },
    [7] = { name = "Doom of Caras Gelebren",                   content = 3 },
    -- Miscellaneous
    [6] = { name = "Missions/Delvings",                        content = 2 },
    [5] = { name = "Tasks",                                    content = 2 },
    [4] = { name = "Embers/Motes/Virtues",                    content = 2 },
    -- Events
    [3] = { name = "Naruhel",                                  content = 1 },
    [2] = { name = "Thrâng",                                   content = 1 },
    [1] = { name = "Storvâgûn",                                content = 1 },
}

-- events --------------------------------------------------------------------------------------
_G.Events = {

    -- The Treasure Caves of Hurum Kâna — Solo (daily) ----------------------------------------
    [585] = { name = "Pakhán-gebar",       match = "Pakhán.gebar's Chest . Solo",             instance = 54,  tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [584] = { name = "Council of Shadows", match = "The Council of Shadows' Chest . Solo",    instance = 54,  tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [583] = { name = "Bârlat",             match = "Bârlat the Bold's Chest . Solo",          instance = 54,  tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [582] = { name = "Pakhán-gebar",       match = "Pakhán.gebar's Chest . Tier 1",           instance = 54,  tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [581] = { name = "Council of Shadows", match = "The Council of Shadows' Chest . Tier 1",  instance = 54,  tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [580] = { name = "Bârlat",             match = "Bârlat the Bold's Chest . Tier 1",        instance = 54,  tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [579] = { name = "Pakhán-gebar",       match = "Pakhán.gebar's Chest . Tier 2",           instance = 54,  tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [578] = { name = "Council of Shadows", match = "The Council of Shadows' Chest . Tier 2",  instance = 54,  tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [577] = { name = "Bârlat",             match = "Bârlat the Bold's Chest . Tier 2",        instance = 54,  tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [576] = { name = "Pakhán-gebar",       match = "Pakhán.gebar's Chest . Tier 3",           instance = 54,  tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [575] = { name = "Council of Shadows", match = "The Council of Shadows' Chest . Tier 3",  instance = 54,  tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [574] = { name = "Bârlat",             match = "Bârlat the Bold's Chest . Tier 3",        instance = 54,  tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Ekal-nêbi, the Fallen Palace — Solo (daily) ---------------------------------------------
    [573] = { name = "Ratúlko",    match = "The Bloody Warden's Chest . Solo",   instance = 53, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [572] = { name = "Barkhuráni", match = "The Dark Priestess' Chest . Solo",   instance = 53, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [571] = { name = "Thothril",   match = "The Entangler's Chest . Solo",       instance = 53, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [570] = { name = "Ratúlko",    match = "The Bloody Warden's Chest . Tier 1", instance = 53, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [569] = { name = "Barkhuráni", match = "The Dark Priestess' Chest . Tier 1", instance = 53, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [568] = { name = "Thothril",   match = "The Entangler's Chest . Tier 1",     instance = 53, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [567] = { name = "Ratúlko",    match = "The Bloody Warden's Chest . Tier 2", instance = 53, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [566] = { name = "Barkhuráni", match = "The Dark Priestess' Chest . Tier 2", instance = 53, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [565] = { name = "Thothril",   match = "The Entangler's Chest . Tier 2",     instance = 53, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [564] = { name = "Ratúlko",    match = "The Bloody Warden's Chest . Tier 3", instance = 53, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [563] = { name = "Barkhuráni", match = "The Dark Priestess' Chest . Tier 3", instance = 53, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [562] = { name = "Thothril",   match = "The Entangler's Chest . Tier 3",     instance = 53, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Kôth Rau, the Wailing Hold — Solo (daily) -----------------------------------------------
    [561] = { name = "The Twins", match = "The Twins' Chest . Solo",           instance = 52, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [560] = { name = "Ombátha",   match = "Ombátha's Personal Chest . Solo",   instance = 52, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [559] = { name = "Râkdakul",  match = "Râkdakul's Tribute . Solo",         instance = 52, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [558] = { name = "The Twins", match = "The Twins' Chest . Tier 1",         instance = 52, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [557] = { name = "Ombátha",   match = "Ombátha's Personal Chest . Tier 1", instance = 52, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [556] = { name = "Râkdakul",  match = "Râkdakul's Tribute . Tier 1",       instance = 52, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [555] = { name = "The Twins", match = "The Twins' Chest . Tier 2",         instance = 52, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [554] = { name = "Ombátha",   match = "Ombátha's Personal Chest . Tier 2", instance = 52, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [553] = { name = "Râkdakul",  match = "Râkdakul's Tribute . Tier 2",       instance = 52, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [552] = { name = "The Twins", match = "The Twins' Chest . Tier 3",         instance = 52, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [551] = { name = "Ombátha",   match = "Ombátha's Personal Chest . Tier 3", instance = 52, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [550] = { name = "Râkdakul",  match = "Râkdakul's Tribute . Tier 3",       instance = 52, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Pagru-kirít, the Garden of Corpses — Solo (daily) ---------------------------------------
    [549] = { name = "Kishâsu",  match = "Kishâsu's Chest . Solo",   instance = 51, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [548] = { name = "Khardâmu", match = "Khardâmu's Chest . Solo",  instance = 51, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [547] = { name = "Sudûgul",  match = "Sudûgul's Chest . Solo",   instance = 51, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [546] = { name = "Kishâsu",  match = "Kishâsu's Chest . Tier 1", instance = 51, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [545] = { name = "Khardâmu", match = "Khardâmu's Chest . Tier 1", instance = 51, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [544] = { name = "Sudûgul",  match = "Sudûgul's Chest . Tier 1", instance = 51, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [543] = { name = "Kishâsu",  match = "Kishâsu's Chest . Tier 2", instance = 51, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [542] = { name = "Khardâmu", match = "Khardâmu's Chest . Tier 2", instance = 51, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [541] = { name = "Sudûgul",  match = "Sudûgul's Chest . Tier 2", instance = 51, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [540] = { name = "Kishâsu",  match = "Kishâsu's Chest . Tier 3", instance = 51, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [539] = { name = "Khardâmu", match = "Khardâmu's Chest . Tier 3", instance = 51, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [538] = { name = "Sudûgul",  match = "Sudûgul's Chest . Tier 3", instance = 51, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- The Folly of Nagakhêdi — T1 (weekly Thu) ------------------------------------------------
    [537]  = { name = "Badharál",                match = "Badharál's Grotesque Egg . Tier 1",  instance = 50, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [536]  = { name = "Maukhorn",                match = "Maukhorn's Chest . Tier 1",          instance = 50, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [535]  = { name = "The Legion",              match = "The Legion's Chest . Tier 1",        instance = 50, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [534]  = { name = "Zamâktar the Putrescent", match = "Zamâktar the Putrescent . Tier 1",  instance = 50, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [533] = { name = "Badharál",                match = "Badharál's Grotesque Egg . Tier 2",  instance = 50, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [532] = { name = "Maukhorn",                match = "Maukhorn's Chest . Tier 2",          instance = 50, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [531] = { name = "The Legion",              match = "The Legion's Chest . Tier 2",        instance = 50, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [530] = { name = "Zamâktar the Putrescent", match = "Zamâktar the Putrescent . Tier 2",  instance = 50, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3 (weekly Thu)
    [529] = { name = "Badharál",                match = "Badharál's Grotesque Egg . Tier 3",  instance = 50, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [528] = { name = "Maukhorn",                match = "Maukhorn's Chest . Tier 3",          instance = 50, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [527] = { name = "The Legion",              match = "The Legion's Chest . Tier 3",        instance = 50, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [526] = { name = "Zamâktar the Putrescent", match = "Zamâktar the Putrescent . Tier 3",  instance = 50, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Kingdoms of Harad — Weeklies (weekly Thu) ---------------------------------------
    [525] = { name = "20 Quests",    match = "Mûr Ghala commendations .%d+/20.",                        instance = 49, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [524] = { name = "30 Quests",    match = "Mûr Ghala commendations .%d+/30.",                        instance = 49, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [523] = { name = "6 Instances",  match = "Completed Mûr Ghala instances .%d+/6.",                   instance = 49, tier = "Weeklies", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [522] = { name = "T3 Instances", match = "Completed:.Advanced Challenges of Mûr Ghala .Weekly.",               instance = 49, tier = "Weeklies", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [521] = { name = "Raid",         match = "Completed:.Challenges of the Folly of Nagakhêdi .Weekly.", instance = 49, tier = "Weeklies", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [520] = { name = "T3 Raid",      match = "Completed:.Advanced Challenges of the Folly of Nagakhêdi .Weekly.",  instance = 49, tier = "Weeklies", order = 6, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- RTs (weekly Thu)
    [519] = { name = "RT Agáthar",    match = "Completed:.Weekly. The Scourge of Adagím",         instance = 49, tier = "RTs", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [518] = { name = "RT Bloodtooth", match = "Completed:.Weekly. The Curse on Kighân",           instance = 49, tier = "RTs", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [517] = { name = "RT Daithor",    match = "Completed:.Weekly. The Terror of An Shêru",        instance = 49, tier = "RTs", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [516] = { name = "RT Imtushâl",   match = "Completed:.Weekly. The Malevolence of Idagâl",     instance = 49, tier = "RTs", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- Dailies (daily)
    [515] = { name = "12 Samples", match = "Completed:.Harvest of the Diseased",                  instance = 49, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [514] = { name = "10 Weavers", match = "Completed:.Blight.weavers",                          instance = 49, tier = "Daylies", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [513] = { name = "8 Trolls",   match = "Completed:.Rot.touched Trolls",                      instance = 49, tier = "Daylies", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [512] = { name = "6 Huorns",   match = "Completed:.The Forest Turns Against Us",              instance = 49, tier = "Daylies", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [511] = { name = "Agáthar",    match = "Completed:.Roving Threat. Agáthar the Bereft",        instance = 49, tier = "Daylies", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [510] = { name = "Bloodtooth", match = "Completed:.Roving Threat. Bloodtooth Still Hungers",  instance = 49, tier = "Daylies", order = 6, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Ashunûg, the Fane of the Accursed — Solo (daily) ----------------------------------------
    [509] = { name = "Eshêgur",          match = "Eshêgur's Chest . Solo",          instance = 48, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [508] = { name = "Anâkhi Ensemble",  match = "Anâkhi Ensemble's Chest . Solo",  instance = 48, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [507] = { name = "Nâkhugir",         match = "Nâkhugir's Filth . Solo",         instance = 48, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [506] = { name = "Eshêgur",          match = "Eshêgur's Chest . Tier 1",        instance = 48, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [505] = { name = "Anâkhi Ensemble",  match = "Anâkhi Ensemble's Chest . Tier 1", instance = 48, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [504] = { name = "Nâkhugir",         match = "Nâkhugir's Filth . Tier 1",       instance = 48, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [503] = { name = "Eshêgur",          match = "Eshêgur's Chest . Tier 2",        instance = 48, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [502] = { name = "Anâkhi Ensemble",  match = "Anâkhi Ensemble's Chest . Tier 2", instance = 48, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [501] = { name = "Nâkhugir",         match = "Nâkhugir's Filth . Tier 2",       instance = 48, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [500] = { name = "Eshêgur",          match = "Eshêgur's Chest . Tier 3",        instance = 48, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [499] = { name = "Anâkhi Ensemble",  match = "Anâkhi Ensemble's Chest . Tier 3", instance = 48, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [498] = { name = "Nâkhugir",         match = "Nâkhugir's Filth . Tier 3",       instance = 48, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Nirgambâr, the Restless Tomb — Solo (daily) ----------------------------------------------
    [497] = { name = "Sakhârshag", match = "Sakhârshag's Chest . Solo",   instance = 47, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [496] = { name = "Imanak-tûr", match = "Imanak.tûr's Chest . Solo",   instance = 47, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [495] = { name = "Aratûg",     match = "Aratûg's Chest . Solo",       instance = 47, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [494] = { name = "Sakhârshag", match = "Sakhârshag's Chest . Tier 1", instance = 47, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [493] = { name = "Imanak-tûr", match = "Imanak.tûr's Chest . Tier 1", instance = 47, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [492] = { name = "Aratûg",     match = "Aratûg's Chest . Tier 1",     instance = 47, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [491] = { name = "Sakhârshag", match = "Sakhârshag's Chest . Tier 2", instance = 47, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [490] = { name = "Imanak-tûr", match = "Imanak.tûr's Chest . Tier 2", instance = 47, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [489] = { name = "Aratûg",     match = "Aratûg's Chest . Tier 2",     instance = 47, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [488] = { name = "Sakhârshag", match = "Sakhârshag's Chest . Tier 3", instance = 47, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [487] = { name = "Imanak-tûr", match = "Imanak.tûr's Chest . Tier 3", instance = 47, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [486] = { name = "Aratûg",     match = "Aratûg's Chest . Tier 3",     instance = 47, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Dun Shûma, The King's Fortress — Solo (daily) --------------------------------------------
    [485] = { name = "Weaponmaster Mâkhragab",       match = "The Weaponmaster's Chest . Solo",    instance = 46, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [484] = { name = "Ushdâla, Lady of the Pride",   match = "The Lady of the Pride's Chest . Solo", instance = 46, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [483] = { name = "Zidunâm, the Serpent-caller",  match = "The Serpent.caller's Chest . Solo",  instance = 46, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [482] = { name = "Weaponmaster Mâkhragab",       match = "The Weaponmaster's Chest . Tier 1",    instance = 46, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [481] = { name = "Ushdâla, Lady of the Pride",   match = "The Lady of the Pride's Chest . Tier 1", instance = 46, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [480] = { name = "Zidunâm, the Serpent-caller",  match = "The Serpent.caller's Chest . Tier 1", instance = 46, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [479] = { name = "Weaponmaster Mâkhragab",       match = "The Weaponmaster's Chest . Tier 2",    instance = 46, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [478] = { name = "Ushdâla, Lady of the Pride",   match = "The Lady of the Pride's Chest . Tier 2", instance = 46, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [477] = { name = "Zidunâm, the Serpent-caller",  match = "The Serpent.caller's Chest . Tier 2", instance = 46, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [476] = { name = "Weaponmaster Mâkhragab",       match = "The Weaponmaster's Chest . Tier 3",    instance = 46, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [475] = { name = "Ushdâla, Lady of the Pride",   match = "The Lady of the Pride's Chest . Tier 3", instance = 46, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [474] = { name = "Zidunâm, the Serpent-caller",  match = "The Serpent.caller's Chest . Tier 3", instance = 46, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Tûl Zakana, the Well of Forgetting — Solo (daily) ----------------------------------------
    [473] = { name = "Pahór-korat",         match = "Chest of the Pahór.korat . Solo",       instance = 45, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [472] = { name = "Gorthorog Devastator", match = "Gorthorog Devastator's Chest . Solo",  instance = 45, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [471] = { name = "Mûkh Bahora",          match = "Mûkh Bahora's Chest . Solo",           instance = 45, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [470] = { name = "Bahádring",            match = "Bahádring's Chest . Solo",              instance = 45, tier = "Solo", order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [469] = { name = "Pahór-korat",         match = "Chest of the Pahór.korat . Tier 1",     instance = 45, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [468] = { name = "Gorthorog Devastator", match = "Gorthorog Devastator's Chest . Tier 1", instance = 45, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [467] = { name = "Mûkh Bahora",          match = "Mûkh Bahora's Chest . Tier 1",         instance = 45, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [466] = { name = "Bahádring",            match = "Bahádring's Chest . Tier 1",            instance = 45, tier = "T1",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [465] = { name = "Pahór-korat",         match = "Chest of the Pahór.korat . Tier 2",     instance = 45, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [464] = { name = "Gorthorog Devastator", match = "Gorthorog Devastator's Chest . Tier 2", instance = 45, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [463] = { name = "Mûkh Bahora",          match = "Mûkh Bahora's Chest . Tier 2",         instance = 45, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [462] = { name = "Bahádring",            match = "Bahádring's Chest . Tier 2",            instance = 45, tier = "T2",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [461] = { name = "Pahór-korat",         match = "Chest of the Pahór.korat . Tier 3",     instance = 45, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [460] = { name = "Gorthorog Devastator", match = "Gorthorog Devastator's Chest . Tier 3", instance = 45, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [459] = { name = "Mûkh Bahora",          match = "Mûkh Bahora's Chest . Tier 3",         instance = 45, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [458] = { name = "Bahádring",            match = "Bahádring's Chest . Tier 3",            instance = 45, tier = "T3",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- The Temple of Utug-bûr — T1 (Mon/Thu/Sat) -----------------------------------------------
    [457] = { name = "Kulkorth",              match = "Kulkorth's Chest . Tier 1",             instance = 44, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [456] = { name = "Maluchon",              match = "Maluchon's Chest . Tier 1",             instance = 44, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [455] = { name = "Khablag and Daikhag",   match = "Khablag and Daikhag's Chest . Tier 1", instance = 44, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [454] = { name = "Kormoltur",             match = "Kormoltur's Chest . Tier 1",            instance = 44, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [453] = { name = "Azagath",               match = "The Sea.shadow's Chest . Tier 1",       instance = 44, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [452] = { name = "Gârash, the Emptiness", match = "Azagath Sea.shadow . Tier 1",          instance = 44, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [451] = { name = "Kulkorth",              match = "Kulkorth's Chest . Tier 2",             instance = 44, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [450] = { name = "Maluchon",              match = "Maluchon's Chest . Tier 2",             instance = 44, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [449] = { name = "Khablag and Daikhag",   match = "Khablag and Daikhag's Chest . Tier 2", instance = 44, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [448] = { name = "Kormoltur",             match = "Kormoltur's Chest . Tier 2",            instance = 44, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [447] = { name = "Azagath",               match = "The Sea.shadow's Chest . Tier 2",       instance = 44, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [446] = { name = "Gârash, the Emptiness", match = "Azagath Sea.shadow . Tier 2",          instance = 44, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3 (weekly Thu)
    [445] = { name = "Kulkorth",              match = "Kulkorth's Chest . Tier 3",             instance = 44, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [444] = { name = "Maluchon",              match = "Maluchon's Chest . Tier 3",             instance = 44, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [443] = { name = "Khablag and Daikhag",   match = "Khablag and Daikhag's Chest . Tier 3", instance = 44, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [442] = { name = "Kormoltur",             match = "Kormoltur's Chest . Tier 3",            instance = 44, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [441] = { name = "Azagath",               match = "The Sea.shadow's Chest . Tier 3",       instance = 44, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [440] = { name = "Gârash, the Emptiness", match = "Azagath Sea.shadow . Tier 3",          instance = 44, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Legacy of Morgoth — Weeklies (weekly Thu) ----------------------------------------
    [439] = { name = "12 Missions",       match = "Completed:.Forging a Path in the Ikorbân Valley .Weekly.",                 instance = 43, tier = "Weeklies", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [438] = { name = "6 Instances",       match = "Completed Ikorbân Valley instances .%d+/6.",                    instance = 43, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [437] = { name = "Raid T1+",          match = "Completed:.Trials of Umbar and Ikorbân .Weekly.",                          instance = 43, tier = "Weeklies", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [436] = { name = "Raid T2+",          match = "Completed Umbar or Ikorbân raids on tier 2 or higher .%d+/3.", instance = 43, tier = "Weeklies", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [435] = { name = "Raid highest Tier", match = "Completed Umbar or Ikorbân raids on the highest tier .%d+/3.", instance = 43, tier = "Weeklies", order = 5, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },

    -- The Isle of Storms — Solo (daily) --------------------------------------------------------
    [434] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Solo",   instance = 42, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [433] = { name = "Urâbaz",    match = "Urâbaz's Chest . Solo",     instance = 42, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [432] = { name = "Raghârik",  match = "Raghârik's Chest . Solo",   instance = 42, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [431] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 1", instance = 42, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [430] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 1",   instance = 42, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [429] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 1", instance = 42, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [428] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 2", instance = 42, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [427] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 2",   instance = 42, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [426] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 2", instance = 42, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [425] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 3", instance = 42, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [424] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 3",   instance = 42, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [423] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 3", instance = 42, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [422] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 4", instance = 42, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [421] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 4",   instance = 42, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [420] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 4", instance = 42, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [419] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 5", instance = 42, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [418] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 5",   instance = 42, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [417] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 5", instance = 42, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Streets of Râhal Bakh — Solo (daily) -------------------------------------------------
    [416] = { name = "Utho",    match = "Utho's Chest . Solo",   instance = 41, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [415] = { name = "Khâshap", match = "Khâshap's Chest . Solo", instance = 41, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [414] = { name = "Utho",    match = "Utho's Chest . Tier 1",  instance = 41, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [413] = { name = "Khâshap", match = "Khâshap's Chest . Tier 1", instance = 41, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [412] = { name = "Utho",    match = "Utho's Chest . Tier 2",  instance = 41, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [411] = { name = "Khâshap", match = "Khâshap's Chest . Tier 2", instance = 41, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [410] = { name = "Utho",    match = "Utho's Chest . Tier 3",  instance = 41, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [409] = { name = "Khâshap", match = "Khâshap's Chest . Tier 3", instance = 41, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [408] = { name = "Utho",    match = "Utho's Chest . Tier 4",  instance = 41, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [407] = { name = "Khâshap", match = "Khâshap's Chest . Tier 4", instance = 41, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [406] = { name = "Utho",    match = "Utho's Chest . Tier 5",  instance = 41, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [405] = { name = "Khâshap", match = "Khâshap's Chest . Tier 5", instance = 41, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Dahâl Huliz, The Arena — Solo (daily) ---------------------------------------------------
    [404] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest . Solo",  instance = 40, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [403] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Solo",   instance = 40, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [402] = { name = "Rothog",         match = "Arena Champion's Chest . Solo",  instance = 40, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)  note: source T1 omits space before "Tier" ("Chest. Tier 1") — kept verbatim
    [401] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest. Tier 1", instance = 40, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [400] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Tier 1", instance = 40, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [399] = { name = "Rothog",         match = "Arena Champion's Chest . Tier 1", instance = 40, tier = "T1",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [398] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest . Tier 2", instance = 40, tier = "T2",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [397] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Tier 2",  instance = 40, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [396] = { name = "Rothog",         match = "Arena Champion's Chest . Tier 2", instance = 40, tier = "T2",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [395] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest . Tier 3", instance = 40, tier = "T3",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [394] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Tier 3",  instance = 40, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [393] = { name = "Rothog",         match = "Arena Champion's Chest . Tier 3", instance = 40, tier = "T3",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [392] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest . Tier 4", instance = 40, tier = "T4",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [391] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Tier 4",  instance = 40, tier = "T4",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [390] = { name = "Rothog",         match = "Arena Champion's Chest . Tier 4", instance = 40, tier = "T4",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [389] = { name = "Arena Neophyte", match = "Arena Neophyte's Chest . Tier 5", instance = 40, tier = "T5",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [388] = { name = "Arena Veteran",  match = "Arena Veteran's Chest . Tier 5",  instance = 40, tier = "T5",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [387] = { name = "Rothog",         match = "Arena Champion's Chest . Tier 5", instance = 40, tier = "T5",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Dragon and the Storm — Solo (daily) --------------------------------------------------
    [386] = { name = "Ragrekhûl", match = "Ragrekhûl's Spoils . Solo",   instance = 39, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T3 (weekly Thu)
    [385] = { name = "Ragrekhûl", match = "Ragrekhûl's Spoils . Tier 1", instance = 39, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [384] = { name = "Ragrekhûl", match = "Ragrekhûl's Spoils . Tier 2", instance = 39, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [383] = { name = "Ragrekhûl", match = "Ragrekhûl's Spoils . Tier 3", instance = 39, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Depths of Mâkhda Khorbo — T1 (Mon/Thu/Sat) ----------------------------------------------
    [382] = { name = "Azagath",  match = "Well.worn Corsair's Chest. Tier 1",  instance = 38, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [381] = { name = "Belondor", match = "Belondor's Chest . Tier 1",          instance = 38, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [380] = { name = "Umshûhra", match = "Forgotten Smuggler's Chest . Tier 1", instance = 38, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [379] = { name = "Azagath",  match = "Well.worn Corsair's Chest . Tier 2",  instance = 38, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [378] = { name = "Belondor", match = "Belondor's Chest . Tier 2",           instance = 38, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [377] = { name = "Umshûhra", match = "Forgotten Smuggler's Chest . Tier 2", instance = 38, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [376] = { name = "Azagath",  match = "Well.worn Corsair's Chest . Tier 3",  instance = 38, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [375] = { name = "Belondor", match = "Belondor's Chest . Tier 3",           instance = 38, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [374] = { name = "Umshûhra", match = "Forgotten Smuggler's Chest . Tier 3", instance = 38, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [373] = { name = "Azagath",  match = "Well.worn Corsair's Chest . Tier 4",  instance = 38, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [372] = { name = "Belondor", match = "Belondor's Chest . Tier 4",           instance = 38, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [371] = { name = "Umshûhra", match = "Forgotten Smuggler's Chest . Tier 4", instance = 38, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [370] = { name = "Azagath",  match = "Well.worn Corsair's Chest . Tier 5",  instance = 38, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [369] = { name = "Belondor", match = "Belondor's Chest . Tier 5",           instance = 38, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [368] = { name = "Umshûhra", match = "Forgotten Smuggler's Chest . Tier 5", instance = 38, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Umbar — Weeklies (weekly Thu) ---------------------------------------------------
    [367] = { name = "16 Quests",  match = "Fortunes of Umbar Baharbêl daily quests .%d+/16.", instance = 37, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [366] = { name = "6 Instances", match = "Completed Umbar instances .%d+/6.",               instance = 37, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [365] = { name = "20 Quests",  match = "Completed Defending the Umbar.môkh quests .%d+/20.", instance = 37, tier = "Weeklies", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Proto Island (daily)
    [364] = { name = "Huorn",      match = "Completed.*Bounty. Proto.huorn",      instance = 37, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [363] = { name = "Salamander", match = "Completed.*Bounty. Proto.salamander", instance = 37, tier = "Daylies", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [362] = { name = "Crab",       match = "Completed.*Bounty. Proto.crab",       instance = 37, tier = "Daylies", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [361] = { name = "Beast",      match = "Completed.*Bounty. Proto.beast",      instance = 37, tier = "Daylies", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [360] = { name = "Crow",       match = "Completed.*Bounty. Proto.crow",       instance = 37, tier = "Daylies", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Craft Guilds — Weeklies (weekly Thu) ----------------------------------------------------
    [359] = { name = "Cook",         match = "Completed Umbar Cook's Guild daily orders %(%d+/5%)",        instance = 36, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [358] = { name = "Jeweller",     match = "Completed Umbar Jeweller's Guild daily orders %(%d+/5%)",    instance = 36, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [357] = { name = "Metalsmith",   match = "Completed Umbar Metalsmith's Guild daily orders %(%d+/5%)",  instance = 36, tier = "Weeklies", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [356] = { name = "Scholar",      match = "Completed Umbar Scholar's Guild daily orders %(%d+/5%)",     instance = 36, tier = "Weeklies", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [355] = { name = "Tailor",       match = "Completed Umbar Tailor's Guild daily orders %(%d+/5%)",      instance = 36, tier = "Weeklies", order = 5, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [354] = { name = "Weaponsmith",  match = "Completed Umbar Weaponsmith's Guild daily orders %(%d+/5%)", instance = 36, tier = "Weeklies", order = 6, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [353] = { name = "Woodworker",   match = "Completed Umbar Woodworker's Guild daily orders %(%d+/5%)",  instance = 36, tier = "Weeklies", order = 7, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Dailies (daily)
    [352] = { name = "Cook",        match = "Completed.*Epicurean Demands .Daily.",     instance = 36, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [351] = { name = "Jeweller",    match = "Completed.*Diamonds in the Rough .Daily.", instance = 36, tier = "Daylies", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [350] = { name = "Metalsmith",  match = "Completed.*Shielding the People .Daily.",  instance = 36, tier = "Daylies", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [349] = { name = "Scholar",     match = "Completed.*Draughts for All .Daily.",      instance = 36, tier = "Daylies", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [348] = { name = "Tailor",      match = "Completed.*Threading the Needles .Daily.", instance = 36, tier = "Daylies", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [347] = { name = "Weaponsmith", match = "Completed.*Weapons Check .Daily.",         instance = 36, tier = "Daylies", order = 6, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [346] = { name = "Woodworker",  match = "Completed.*Listening to the Wood .Daily.", instance = 36, tier = "Daylies", order = 7, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Sant Lhoer, the Poison Gardens — Solo (daily) -------------------------------------------
    [345] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Solo",    instance = 35, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [344] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Solo",   instance = 35, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [343] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Tier 1",  instance = 35, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [342] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Tier 1", instance = 35, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [341] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Tier 2",  instance = 35, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [340] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Tier 2", instance = 35, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [339] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Tier 3",  instance = 35, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [338] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Tier 3", instance = 35, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [337] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Tier 4",  instance = 35, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [336] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Tier 4", instance = 35, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [335] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka.oka and Cráthair's Chest . Tier 5",  instance = 35, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [334] = { name = "Grand Cultivator Oganuin",   match = "Grand Cultivator Oganuin's Chest . Tier 5", instance = 35, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Thaurisgar, the Vile Apothecary — Solo (daily) ------------------------------------------
    [333] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Solo",         instance = 34, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [332] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Solo",     instance = 34, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [331] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Tier 1",        instance = 34, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [330] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Tier 1",   instance = 34, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [329] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Tier 2",        instance = 34, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [328] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Tier 2",   instance = 34, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [327] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Tier 3",        instance = 34, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [326] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Tier 3",   instance = 34, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [325] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Tier 4",        instance = 34, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [324] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Tier 4",   instance = 34, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [323] = { name = "Puzzle Box",        match = "Aniochán's Puzzle Box . Tier 5",        instance = 34, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [322] = { name = "Kurja and Kârsija", match = "Kurja and Kârsija's Chest . Tier 5",   instance = 34, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Sagroth, Lair of Vermin — Solo (daily) --------------------------------------------------
    [321] = { name = "Gárvadach", match = "Gárvadach's Chest . Solo",   instance = 33, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [320] = { name = "Rádarríg",  match = "Rádarríg's Chest . Solo",    instance = 33, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [319] = { name = "Gárvadach", match = "Gárvadach's Chest . Tier 1", instance = 33, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [318] = { name = "Rádarríg",  match = "Rádarríg's Chest . Tier 1",  instance = 33, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [317] = { name = "Gárvadach", match = "Gárvadach's Chest . Tier 2", instance = 33, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [316] = { name = "Rádarríg",  match = "Rádarríg's Chest . Tier 2",  instance = 33, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [315] = { name = "Gárvadach", match = "Gárvadach's Chest . Tier 3", instance = 33, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [314] = { name = "Rádarríg",  match = "Rádarríg's Chest . Tier 3",  instance = 33, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [313] = { name = "Gárvadach", match = "Gárvadach's Chest . Tier 4", instance = 33, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [312] = { name = "Rádarríg",  match = "Rádarríg's Chest . Tier 4",  instance = 33, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [311] = { name = "Gárvadach", match = "Gárvadach's Chest . Tier 5", instance = 33, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [310] = { name = "Rádarríg",  match = "Rádarríg's Chest . Tier 5",  instance = 33, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gwathrenost, the Witch-king's Citadel — T1 (Mon/Thu/Sat) --------------------------------
    [309] = { name = "Gurkrak",                 match = "Gurkrak's Chest . Tier 1",              instance = 32, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [308] = { name = "Obáshurz",                match = "Obáshurz's Chest . Tier 1",             instance = 32, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [307] = { name = "Ásachal and Claghórd",    match = "Ásachal and Claghórd's Chest . Tier 1", instance = 32, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [306] = { name = "The Shard",               match = "Relics of Gwathrenost . Tier 1",        instance = 32, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [305] = { name = "Gurkrak",                 match = "Gurkrak's Chest . Tier 2",              instance = 32, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [304] = { name = "Obáshurz",                match = "Obáshurz's Chest . Tier 2",             instance = 32, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [303] = { name = "Ásachal and Claghórd",    match = "Ásachal and Claghórd's Chest . Tier 2", instance = 32, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [302] = { name = "The Shard",               match = "Relics of Gwathrenost . Tier 2",        instance = 32, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [301] = { name = "Gurkrak",                 match = "Gurkrak's Chest . Tier 3",              instance = 32, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [300] = { name = "Obáshurz",                match = "Obáshurz's Chest . Tier 3",             instance = 32, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [299] = { name = "Ásachal and Claghórd",    match = "Ásachal and Claghórd's Chest . Tier 3", instance = 32, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [298] = { name = "The Shard",               match = "Relics of Gwathrenost . Tier 3",        instance = 32, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [297] = { name = "Gurkrak",                 match = "Gurkrak's Chest . Tier 4",              instance = 32, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [296] = { name = "Obáshurz",                match = "Obáshurz's Chest . Tier 4",             instance = 32, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [295] = { name = "Ásachal and Claghórd",    match = "Ásachal and Claghórd's Chest . Tier 4", instance = 32, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [294] = { name = "The Shard",               match = "Relics of Gwathrenost . Tier 4",        instance = 32, tier = "T4", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [293] = { name = "Gurkrak",                 match = "Gurkrak's Chest . Tier 5",              instance = 32, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [292] = { name = "Obáshurz",                match = "Obáshurz's Chest . Tier 5",             instance = 32, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [291] = { name = "Ásachal and Claghórd",    match = "Ásachal and Claghórd's Chest . Tier 5", instance = 32, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [290] = { name = "The Shard",               match = "Relics of Gwathrenost . Tier 5",        instance = 32, tier = "T5", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Carn Dûm — Weeklies (weekly Thu) ------------------------------------------------
    [289] = { name = "4 Daylies", match = "Completed 'The Fight for Carn Dûm .Daily.' .%d+/4.", instance = 31, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [288] = { name = "Raid",      match = "Completed:.Raid. Gwathrenost, the Witch.king's Citadel .Weekly", instance = 31, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Daylies (daily)
    [287] = { name = "CD Instance", match = "Completed:.The Fight for Carn Dûm .Daily.[^']", instance = 31, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Assault on Dhúrstrok — Solo (daily) -------------------------------------------------------
    [286] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Solo",   instance = 30, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [285] = { name = "Mozrúk",         match = "Mozrúk's Chest . Solo",           instance = 30, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [284] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 1", instance = 30, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [283] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 1",         instance = 30, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [282] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 2", instance = 30, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [281] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 2",         instance = 30, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [280] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 3", instance = 30, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [279] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 3",         instance = 30, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [278] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 4", instance = 30, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [277] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 4",         instance = 30, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [276] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 5", instance = 30, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [275] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 5",         instance = 30, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Den of Pughlak — Solo (daily) ------------------------------------------------------------
    [274] = { name = "Kordkoth", match = "Kordkoth's Chest . Solo",   instance = 29, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [273] = { name = "Pughlak",  match = "Pughlak's Chest . Solo",    instance = 29, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [272] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 1", instance = 29, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [271] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 1",  instance = 29, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [270] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 2", instance = 29, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [269] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 2",  instance = 29, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [268] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 3", instance = 29, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [267] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 3",  instance = 29, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [266] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 4", instance = 29, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [265] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 4",  instance = 29, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [264] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 5", instance = 29, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [263] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 5",  instance = 29, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Adkhât-zahhar, the Houses of Rest — Solo (daily) -----------------------------------------
    [262] = { name = "Risen Lords", match = "Risen Lords' Chest . Solo",   instance = 28, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [261] = { name = "Loknashra",   match = "Loknashra's Chest . Solo",    instance = 28, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [260] = { name = "Vethug",      match = "Vethug's Chest . Solo",       instance = 28, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (weekly Thu)  note: source omits space before "Tier 1" for Risen Lords — kept verbatim
    [259] = { name = "Risen Lords", match = "Risen Lords' Chest. Tier 1",  instance = 28, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [258] = { name = "Loknashra",   match = "Loknashra's Chest . Tier 1",  instance = 28, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [257] = { name = "Vethug",      match = "Vethug's Chest . Tier 1",     instance = 28, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [256] = { name = "Risen Lords", match = "Risen Lords' Chest . Tier 2", instance = 28, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [255] = { name = "Loknashra",   match = "Loknashra's Chest . Tier 2",  instance = 28, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [254] = { name = "Vethug",      match = "Vethug's Chest . Tier 2",     instance = 28, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [253] = { name = "Risen Lords", match = "Risen Lords' Chest . Tier 3", instance = 28, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [252] = { name = "Loknashra",   match = "Loknashra's Chest . Tier 3",  instance = 28, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [251] = { name = "Vethug",      match = "Vethug's Chest . Tier 3",     instance = 28, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [250] = { name = "Risen Lords", match = "Risen Lords' Chest . Tier 4", instance = 28, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [249] = { name = "Loknashra",   match = "Loknashra's Chest . Tier 4",  instance = 28, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [248] = { name = "Vethug",      match = "Vethug's Chest . Tier 4",     instance = 28, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [247] = { name = "Risen Lords", match = "Risen Lords' Chest . Tier 5", instance = 28, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [246] = { name = "Loknashra",   match = "Loknashra's Chest . Tier 5",  instance = 28, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [245] = { name = "Vethug",      match = "Vethug's Chest . Tier 5",     instance = 28, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Hiddenhoard of Abnankâra — T1 (Mon/Thu/Sat) ------------------------------------------
    [244] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 1",        instance = 27, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [243] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 1",    instance = 27, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [242] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 1", instance = 27, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [241] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 2",        instance = 27, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [240] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 2",    instance = 27, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [239] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 2", instance = 27, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [238] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 3",        instance = 27, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [237] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 3",    instance = 27, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [236] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 3", instance = 27, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [235] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 4",        instance = 27, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [234] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 4",    instance = 27, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [233] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 4", instance = 27, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [232] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 5",        instance = 27, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [231] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 5",    instance = 27, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [230] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 5", instance = 27, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Gundabad — Weeklies (weekly Thu) --------------------------------------------------
    [229] = { name = "20 Quests",  match = "Reclaiming the Mountain.hold quests .%d+/20.", instance = 26, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [228] = { name = "6 Instances", match = "Completed Gundabad instances .%d+/6.",        instance = 26, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [227] = { name = "Raid",       match = "Completed:.Raid. The Hiddenhoard of Abnankâra .Weekly.",  instance = 26, tier = "Weeklies", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- Daylies (daily)
    [226] = { name = "Forge", match = "Completed:.Battle at the Forge[^ ]", instance = 26, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [225] = { name = "Lofts", match = "Completed:.Battle at the Lofts[^ ]", instance = 26, tier = "Daylies", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Shakalush, the Stair Battle — Solo (daily) -----------------------------------------------
    [224] = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Solo/Duo", instance = 25, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [223] = { name = "Shatarkha",          match = "Shatarkha's Chest . Solo/Duo",           instance = 25, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [222] = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Solo/Duo",       instance = 25, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [221] = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Tier 1",   instance = 25, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [220] = { name = "Shatarkha",          match = "Shatarkha's Chest . Tier 1",             instance = 25, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [219] = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Tier 1",         instance = 25, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [218] = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Tier 2",   instance = 25, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [217] = { name = "Shatarkha",          match = "Shatarkha's Chest . Tier 2",             instance = 25, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [216] = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Tier 2",         instance = 25, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [215] = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Tier 3",   instance = 25, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [214] = { name = "Shatarkha",          match = "Shatarkha's Chest . Tier 3",             instance = 25, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [213] = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Tier 3",         instance = 25, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Amdân Dammul, the Bloody Threshold — T1 (Mon/Thu/Sat) ------------------------------------
    [212] = { name = "The Beast", match = "Chest of the Beasts . Tier 1", instance = 24, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [211] = { name = "Ránulur",   match = "Ránulur's Chest . Tier 1",     instance = 24, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [210] = { name = "The Beast", match = "Chest of the Beasts . Tier 2", instance = 24, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [209] = { name = "Ránulur",   match = "Ránulur's Chest . Tier 2",     instance = 24, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [208] = { name = "The Beast", match = "Chest of the Beasts . Tier 3", instance = 24, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [207] = { name = "Ránulur",   match = "Ránulur's Chest . Tier 3",     instance = 24, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [206] = { name = "The Beast", match = "Chest of the Beasts . Tier 4", instance = 24, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [205] = { name = "Ránulur",   match = "Ránulur's Chest . Tier 4",     instance = 24, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [204] = { name = "The Beast", match = "Chest of the Beasts . Tier 5", instance = 24, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [203] = { name = "Ránulur",   match = "Ránulur's Chest . Tier 5",     instance = 24, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Fall of Khazad-dûm — T1 (Mon/Thu/Sat) -----------------------------------------------
    [202] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 1", instance = 23, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [201] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 2", instance = 23, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [200] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 3", instance = 23, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [199] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 4", instance = 23, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [198] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 5", instance = 23, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Eithel Gwaur, the Filth-well — Solo (daily) ----------------------------------------------
    [197] = { name = "Balchneth",  match = "Balchneth's Chest",        instance = 22, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [196] = { name = "Gwaurodel",  match = "Gwaurodel's Chest",        instance = 22, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [195] = { name = "Balchneth",  match = "Balchneth's Silver Chest", instance = 22, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [194] = { name = "Gwaurodel",  match = "Gwaurodel's Silver Chest", instance = 22, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [193] = { name = "Balchneth",  match = "Balchneth's Gold Chest",   instance = 22, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [192] = { name = "Gwaurodel",  match = "Gwaurodel's Gold Chest",   instance = 22, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [191] = { name = "Balchneth",  match = "Balchneth's Mithril Chest", instance = 22, tier = "T3+", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [190] = { name = "Gwaurodel",  match = "Gwaurodel's Mithril Chest", instance = 22, tier = "T3+", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gath Daeroval, the Shadow-roost — Solo (daily) -------------------------------------------
    [189] = { name = "Khúrthak",  match = "Khúrthak's Chest",         instance = 21, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [188] = { name = "Khatlob",   match = "Khatlob's Chest",          instance = 21, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [187] = { name = "Khúrthak",  match = "Khúrthak's Silver Chest",  instance = 21, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [186] = { name = "Khatlob",   match = "Khatlob's Silver Chest",   instance = 21, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [185] = { name = "Khúrthak",  match = "Khúrthak's Gold Chest",    instance = 21, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [184] = { name = "Khatlob",   match = "Khatlob's Gold Chest",     instance = 21, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [183] = { name = "Khúrthak",  match = "Khúrthak's Mithril Chest", instance = 21, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [182] = { name = "Khatlob",   match = "Khatlob's Mithril Chest",  instance = 21, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gorthad Nûr, the Deep-barrow — Solo (daily) ----------------------------------------------
    [181] = { name = "Shalgoth",  match = "Shalgoth's Chest",         instance = 20, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [180] = { name = "Gurzhorn",  match = "Gurzhorn's Chest",         instance = 20, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [179] = { name = "Shalgoth",  match = "Shalgoth's Silver Chest",  instance = 20, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [178] = { name = "Gurzhorn",  match = "Gurzhorn's Silver Chest",  instance = 20, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [177] = { name = "Shalgoth",  match = "Shalgoth's Gold Chest",    instance = 20, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [176] = { name = "Gurzhorn",  match = "Gurzhorn's Gold Chest",    instance = 20, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [175] = { name = "Shalgoth",  match = "Shalgoth's Mithril Chest", instance = 20, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [174] = { name = "Gurzhorn",  match = "Gurzhorn's Mithril Chest", instance = 20, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Harrowing of Morgul — Solo (daily) ---------------------------------------------------
    [173] = { name = "Shaktur",   match = "Shaktur's Chest",          instance = 19, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [172] = { name = "Dargásh",   match = "Dargásh's Chest",          instance = 19, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [171] = { name = "Shaktur",   match = "Shaktur's Silver Chest",   instance = 19, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [170] = { name = "Dargásh",   match = "Dargásh's Silver Chest",   instance = 19, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [169] = { name = "Shaktur",   match = "Shaktur's Gold Chest",     instance = 19, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [168] = { name = "Dargásh",   match = "Dargásh's Gold Chest",     instance = 19, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [167] = { name = "Shaktur",   match = "Shaktur's Mithril Chest",  instance = 19, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [166] = { name = "Dargásh",   match = "Dargásh's Mithril Chest",  instance = 19, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Bâr Nírnaeth, the Houses of Lamentation — Solo (daily) -----------------------------------
    [165] = { name = "Manôzagar",  match = "Manôzagar's Chest",         instance = 18, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [164] = { name = "Narkhor",    match = "Narkhor's Chest",           instance = 18, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [163] = { name = "Morloth",    match = "Morloth's Chest",           instance = 18, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [162] = { name = "Agath-kali", match = "Agath.kali's Chest",        instance = 18, tier = "Solo", order = 4, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [161] = { name = "Manôzagar",  match = "Manôzagar's Silver Chest",  instance = 18, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [160] = { name = "Narkhor",    match = "Narkhor's Silver Chest",    instance = 18, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [159] = { name = "Morloth",    match = "Morloth's Silver Chest",    instance = 18, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [158] = { name = "Agath-kali", match = "Agath.kali's Silver Chest", instance = 18, tier = "T1",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [157] = { name = "Manôzagar",  match = "Manôzagar's Gold Chest",    instance = 18, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [156] = { name = "Narkhor",    match = "Narkhor's Gold Chest",      instance = 18, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [155] = { name = "Morloth",    match = "Morloth's Gold Chest",      instance = 18, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [154] = { name = "Agath-kali", match = "Agath.kali's Gold Chest",   instance = 18, tier = "T2",   order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [153] = { name = "Manôzagar",  match = "Manôzagar's Mithril Chest",  instance = 18, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [152] = { name = "Narkhor",    match = "Narkhor's Mithril Chest",    instance = 18, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [151] = { name = "Morloth",    match = "Morloth's Mithril Chest",    instance = 18, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [150] = { name = "Agath-kali", match = "Agath.kali's Mithril Chest", instance = 18, tier = "T3+",  order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Ghashan-Kútot, the Halls of Black Lore — Solo (daily) ------------------------------------
    [149] = { name = "Past Adventures", match = "Chest of Past Adventures",        instance = 17, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [148] = { name = "Fallen Foe",      match = "Chest of the Fallen Foe",         instance = 17, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [147] = { name = "Dolguzigir",      match = "Dolguzigir's Chest",              instance = 17, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [146] = { name = "Past Adventures", match = "Silver Chest of Past Adventures", instance = 17, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [145] = { name = "Fallen Foe",      match = "Silver Chest of the Fallen Foe",  instance = 17, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [144] = { name = "Dolguzigir",      match = "Dolguzigir's Silver Chest",       instance = 17, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [143] = { name = "Past Adventures", match = "Golden Chest of Past Adventures", instance = 17, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [142] = { name = "Fallen Foe",      match = "Golden Chest of the Fallen Foe",  instance = 17, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [141] = { name = "Dolguzigir",      match = "Dolguzigir's Golden Chest",       instance = 17, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [140] = { name = "Past Adventures", match = "Mithril Chest of Past Adventures", instance = 17, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [139] = { name = "Fallen Foe",      match = "Mithril Chest of the Fallen Foe",  instance = 17, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [138] = { name = "Dolguzigir",      match = "Dolguzigir's Mithril Chest",        instance = 17, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Fallen Kings — Solo (daily) ----------------------------------------------------------
    [137] = { name = "The Witch King", match = "The Witch King's Chest",        instance = 16, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [136] = { name = "The Witch King", match = "The Witch King's Silver Chest", instance = 16, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [135] = { name = "The Witch King", match = "The Witch King's Golden Chest", instance = 16, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [134] = { name = "The Witch King", match = "The Witch King's Mithril Chest", instance = 16, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Remmorchant, the Net of Darkness — T1 (Mon/Thu/Sat) -------------------------------------
    [133] = { name = "Gragarag",       match = "Gragarag's Chest . Tier 1",       instance = 15, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [132] = { name = "Guruthang",      match = "Guruthang's Chest . Tier 1",      instance = 15, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [131] = { name = "Gamnagol",       match = "Gamnagol's Chest . Tier 1",       instance = 15, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [130] = { name = "Bratha Tasakh",  match = "Bratha Tasakh's Chest . Tier 1",  instance = 15, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [129] = { name = "Thossulun",      match = "Thossulun's Chest . Tier 1",      instance = 15, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [128] = { name = "The Pale Herald", match = "The Pale Herald's Chest . Tier 1", instance = 15, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [127] = { name = "The Spider-queen", match = "The Spider.queen's Hoard . Tier 1", instance = 15, tier = "T1", order = 7, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [126] = { name = "Gragarag",       match = "Gragarag's Chest . Tier 2",       instance = 15, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [125] = { name = "Guruthang",      match = "Guruthang's Chest . Tier 2",      instance = 15, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [124] = { name = "Gamnagol",       match = "Gamnagol's Chest . Tier 2",       instance = 15, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [123] = { name = "Bratha Tasakh",  match = "Bratha Tasakh's Chest . Tier 2",  instance = 15, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [122] = { name = "Thossulun",      match = "Thossulun's Chest . Tier 2",      instance = 15, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [121] = { name = "The Pale Herald", match = "The Pale Herald's Chest . Tier 2", instance = 15, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [120] = { name = "The Spider-queen", match = "The Spider.queen's Hoard . Tier 2", instance = 15, tier = "T2", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [119] = { name = "Gragarag",       match = "Gragarag's Chest . Tier 3",       instance = 15, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [118] = { name = "Guruthang",      match = "Guruthang's Chest . Tier 3",      instance = 15, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [117] = { name = "Gamnagol",       match = "Gamnagol's Chest . Tier 3",       instance = 15, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [116] = { name = "Bratha Tasakh",  match = "Bratha Tasakh's Chest . Tier 3",  instance = 15, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [115] = { name = "Thossulun",      match = "Thossulun's Chest . Tier 3",      instance = 15, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [114] = { name = "The Pale Herald", match = "The Pale Herald's Chest . Tier 3", instance = 15, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [113] = { name = "The Spider-queen", match = "The Spider.queen's Hoard . Tier 3", instance = 15, tier = "T3", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [112] = { name = "Gragarag",       match = "Gragarag's Chest . Tier 4",       instance = 15, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [111] = { name = "Guruthang",      match = "Guruthang's Chest . Tier 4",      instance = 15, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [110] = { name = "Gamnagol",       match = "Gamnagol's Chest . Tier 4",       instance = 15, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [109] = { name = "Bratha Tasakh",  match = "Bratha Tasakh's Chest . Tier 4",  instance = 15, tier = "T4", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [108] = { name = "Thossulun",      match = "Thossulun's Chest . Tier 4",      instance = 15, tier = "T4", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [107] = { name = "The Pale Herald", match = "The Pale Herald's Chest . Tier 4", instance = 15, tier = "T4", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [106] = { name = "The Spider-queen", match = "The Spider.queen's Hoard . Tier 4", instance = 15, tier = "T4", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [105] = { name = "Gragarag",       match = "Gragarag's Chest . Tier 5",       instance = 15, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [104] = { name = "Guruthang",      match = "Guruthang's Chest . Tier 5",      instance = 15, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [103] = { name = "Gamnagol",       match = "Gamnagol's Chest . Tier 5",       instance = 15, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [102] = { name = "Bratha Tasakh",  match = "Bratha Tasakh's Chest . Tier 5",  instance = 15, tier = "T5", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [101] = { name = "Thossulun",      match = "Thossulun's Chest . Tier 5",      instance = 15, tier = "T5", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [100] = { name = "The Pale Herald", match = "The Pale Herald's Chest . Tier 5", instance = 15, tier = "T5", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [99] = { name = "The Spider-queen", match = "The Spider.queen's Hoard . Tier 5", instance = 15, tier = "T5", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Quests: Minas Morgul — Weeklies (weekly Thu) ---------------------------------------------
    [98] = { name = "Continued Threats", match = "Completed:.Imlad Morgul: Continued Threats",   instance = 14, tier = "Weeklies", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [97] = { name = "10 Quests",         match = "Completed:.Imlad Morgul: The Reclamation",      instance = 14, tier = "Weeklies", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [96] = { name = "4 Instances",       match = "Completed:.Imlad Morgul: Vale of Sorcery",      instance = 14, tier = "Weeklies", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [95] = { name = "Limlók",            match = "Completed:.Protectors of Wilderland: Bounties", instance = 14, tier = "Weeklies", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Anvil of Winterstith — T1 (Mon/Thu/Sat) ---------------------------------------------
    [94] = { name = "Isvítha",   match = "Isvítha's Silver Chest",    instance = 13, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [93] = { name = "Ingór",     match = "Ingór's Silver Chest",      instance = 13, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [92] = { name = "Ice-Grim",  match = "Hidden Silver Cache",        instance = 13, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [91] = { name = "Icebeast",  match = "Icebeast's Silver Hoard",   instance = 13, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [90] = { name = "Karazgar",  match = "Karazgar's Silver Chest",   instance = 13, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [89] = { name = "Hrímil",    match = "Hrímil's Silver Chest",     instance = 13, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [88] = { name = "Isvítha",   match = "Isvítha's Golden Chest",    instance = 13, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [87] = { name = "Ingór",     match = "Ingór's Golden Chest",      instance = 13, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [86] = { name = "Ice-Grim",  match = "Hidden Gold Cache",          instance = 13, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [85] = { name = "Icebeast",  match = "Icebeast's Golden Hoard",   instance = 13, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [84] = { name = "Karazgar",  match = "Karazgar's Golden Chest",   instance = 13, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [83] = { name = "Hrímil",    match = "Hrímil's Golden Chest",     instance = 13, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3 (weekly Thu)
    [82] = { name = "Isvítha",   match = "Isvítha's Mithril Chest",   instance = 13, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [81] = { name = "Ingór",     match = "Ingór's Mithril Chest",     instance = 13, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [80] = { name = "Ice-Grim",  match = "Hidden Mithril Cache",       instance = 13, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [79] = { name = "Icebeast",  match = "Icebeast's Mithril Hoard",  instance = 13, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [78] = { name = "Karazgar",  match = "Karazgar's Mithril Chest",  instance = 13, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [77] = { name = "Hrímil",    match = "Hrímil's Mithril Chest",    instance = 13, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Featured Instance — Daylies (daily) ------------------------------------------------------
    [76] = { name = "Low level", match = "Completed:.Featured Instance.+",            instance = 12, tier = "Daylies", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [75] = { name = "Cap level", match = "Completed:.Featured Instance.+.cap level.", instance = 12, tier = "Daylies", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Agoroth, the Narrowdelve — Solo (daily) --------------------------------------------------
    [74] = { name = "Hoarpelt", match = "Chest of the Hoarpelt . Solo",   instance = 11, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [73] = { name = "Ashen",    match = "Chest of the Ashen . Solo",      instance = 11, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [72] = { name = "Storm",    match = "Chest of the Storm . Solo",      instance = 11, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [71] = { name = "Hoarpelt", match = "Chest of the Hoarpelt . Tier 1", instance = 11, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [70] = { name = "Ashen",    match = "Chest of the Ashen . Tier 1",    instance = 11, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [69] = { name = "Storm",    match = "Chest of the Storm . Tier 1",    instance = 11, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [68] = { name = "Hoarpelt", match = "Chest of the Hoarpelt . Tier 2", instance = 11, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [67] = { name = "Ashen",    match = "Chest of the Ashen . Tier 2",    instance = 11, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [66] = { name = "Storm",    match = "Chest of the Storm . Tier 2",    instance = 11, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [65] = { name = "Hoarpelt", match = "Chest of the Hoarpelt . Tier 3+", instance = 11, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [64] = { name = "Ashen",    match = "Chest of the Ashen . Tier 3+",    instance = 11, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [63] = { name = "Storm",    match = "Chest of the Storm . Tier 3+",    instance = 11, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Askâd-mazal, the Chamber of Shadows — Solo (daily) --------------------------------------
    [62] = { name = "The Shadowed King", match = "The King's Chest . Solo",   instance = 10, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [61] = { name = "The Shadowed King", match = "The King's Chest . Tier 1", instance = 10, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [60] = { name = "The Shadowed King", match = "The King's Chest . Tier 2", instance = 10, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [59] = { name = "The Shadowed King", match = "The King's Chest . Tier 3+", instance = 10, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Woe of the Willow — Solo (daily) --------------------------------------------------------
    [58] = { name = "Dampmould", match = "Dampmould's Chest . Solo",   instance = 9, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [57] = { name = "Bombadil",  match = "Bombadil's Gift . Solo",     instance = 9, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [56] = { name = "Dampmould", match = "Dampmould's Chest . Tier 1", instance = 9, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [55] = { name = "Bombadil",  match = "Bombadil's Gift . Tier 1",   instance = 9, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [54] = { name = "Dampmould", match = "Dampmould's Chest . Tier 2", instance = 9, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [53] = { name = "Bombadil",  match = "Bombadil's Gift . Tier 2",   instance = 9, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [52] = { name = "Dampmould", match = "Dampmould's Chest . Tier 3+", instance = 9, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [51] = { name = "Bombadil",  match = "Bombadil's Gift . Tier 3+",   instance = 9, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Sarch Vorn, the Black Grave — Solo (daily) -----------------------------------------------
    [50] = { name = "Fladach",     match = "Fladach's Chest . Solo",   instance = 8, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [49] = { name = "Luilloth",    match = "Luilloth's Chest . Solo",  instance = 8, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [48] = { name = "Hithrengor",  match = "Hithrengor's Chest . Solo", instance = 8, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [47] = { name = "Fladach",     match = "Fladach's Chest . Tier 1",   instance = 8, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [46] = { name = "Luilloth",    match = "Luilloth's Chest . Tier 1",  instance = 8, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [45] = { name = "Hithrengor",  match = "Hithrengor's Chest . Tier 1", instance = 8, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [44] = { name = "Fladach",     match = "Fladach's Chest . Tier 2",   instance = 8, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [43] = { name = "Luilloth",    match = "Luilloth's Chest . Tier 2",  instance = 8, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [42] = { name = "Hithrengor",  match = "Hithrengor's Chest . Tier 2", instance = 8, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [41] = { name = "Fladach",     match = "Fladach's Chest . Tier 3",   instance = 8, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [40] = { name = "Luilloth",    match = "Luilloth's Chest . Tier 3",  instance = 8, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [39] = { name = "Hithrengor",  match = "Hithrengor's Chest . Tier 3", instance = 8, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [38] = { name = "Fladach",     match = "Fladach's Chest . Tier 4",   instance = 8, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [37] = { name = "Luilloth",    match = "Luilloth's Chest . Tier 4",  instance = 8, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [36] = { name = "Hithrengor",  match = "Hithrengor's Chest . Tier 4", instance = 8, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [35] = { name = "Fladach",     match = "Fladach's Chest . Tier 5",   instance = 8, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [34] = { name = "Luilloth",    match = "Luilloth's Chest . Tier 5",  instance = 8, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [33] = { name = "Hithrengor",  match = "Hithrengor's Chest . Tier 5", instance = 8, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Doom of Caras Gelebren — T3 (weekly Thu) ------------------------------------------------
    [32] = { name = "6-man",  match = "Greater Gift of the Mírdain . Tier 3", instance = 7, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [31] = { name = "12-man", match = "Grand Gift of the Mírdain . Tier 3",   instance = 7, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Missions/Delvings — Weeklies (weekly Thu) ------------------------------------------------
    [30] = { name = "15 Missions",      match = "Completed missions .%d+/15.",                          instance = 6, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [29] = { name = "45 Missions",      match = "Completed missions .%d+/45.",                          instance = 6, tier = "Weeklies", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [28] = { name = "15 Delvings",      match = "Completed:.Delve Deeper .Weekly.",                                instance = 6, tier = "Weeklies", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [27] = { name = "10 T6+ Delvings",  match = "Completed high tier delvings .tier 6 and higher. .%d+.10.", instance = 6, tier = "Weeklies", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [26] = { name = "Ini Delvings",     match = "Completed:.Delve Deepest .Weekly.",                               instance = 6, tier = "Weeklies", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Tasks — Weeklies (weekly Thu) ------------------------------------------------------------
    [25] = { name = "10 Tasks",                   match = "Completed tasks .%d+/10.",               instance = 5, tier = "Weeklies", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [24] = { name = "Tokens of Heroism",          match = "Completed:.Task. Tokens of Heroism[^ ]",            instance = 5, tier = "Weeklies", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [23] = { name = "Tokens of Heroism (Tier 2)", match = "Completed:.Task. Tokens of Heroism .Tier 2.",       instance = 5, tier = "Weeklies", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [22] = { name = "Tokens of Heroism (Tier 3)", match = "Completed:.Task. Tokens of Heroism .Tier 3.",       instance = 5, tier = "Weeklies", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Embers (Sunday reset) ---------------------------------------------
    [21] = { name = "Umbar Embers",        match = "Completed:.Umbari Tâm for Embers",              instance = 4, tier = "Embers", order = 1, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [20] = { name = "Craft for Embers",    match = "Completed:.Craft for Embers",                   instance = 4, tier = "Embers", order = 2, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    -- Motes (Sunday reset)
    [19] = { name = "Vales of Anduin Motes",  match = "Completed:.Gúlmarks for Motes",                     instance = 4, tier = "Motes", order = 1, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [18] = { name = "Ered Mithrin Motes",     match = "Completed:.Longbeard Marks for Motes",               instance = 4, tier = "Motes", order = 2, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [17] = { name = "Minas Morgul Motes",     match = "Completed:.Sigils of Imlad Ithil for Motes",         instance = 4, tier = "Motes", order = 3, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [16] = { name = "Elderslade Motes",       match = "Completed:.Copper Coins of Gundabad for Motes",      instance = 4, tier = "Motes", order = 4, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [15] = { name = "Gundabad Motes",         match = "Completed:.Silver Coins of Gundabad for Motes",      instance = 4, tier = "Motes", order = 5, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    -- Virtues (weekly Thu)
    [14] = { name = "I",       match = "Completed:.From the Ashes Comes Virtue . I[^ ]",    instance = 4, tier = "Virtues", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [13] = { name = "II",      match = "Completed:.From the Ashes Comes Virtue . II[^ ]",   instance = 4, tier = "Virtues", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [12] = { name = "III",     match = "Completed:.From the Ashes Comes Virtue . III",       instance = 4, tier = "Virtues", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [11] = { name = "IV",      match = "Completed:.From the Ashes Comes Virtue . IV",        instance = 4, tier = "Virtues", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [10] = { name = "V",       match = "Completed:.From the Ashes Comes Virtue . V",         instance = 4, tier = "Virtues", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [9] = { name = "VI",      match = "Completed:.From the Ashes Comes Virtue . VI",        instance = 4, tier = "Virtues", order = 6, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [8] = { name = "Weekly",  match = "Completed:.From the Ashes Comes Virtue . Weekly",    instance = 4, tier = "Virtues", order = 7, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Naruhel — T1/T2/T3 (daily) --------------------------------------------------------------
    [7] = { name = "Naruhel", match = "Naruhel's Silver Chest",  instance = 3, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [6] = { name = "Naruhel", match = "Naruhel's Golden Chest",  instance = 3, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [5] = { name = "Naruhel", match = "Naruhel's Mithril Chest", instance = 3, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Thrâng — T1/T2 (daily) ------------------------------------------------------------------
    [4] = { name = "Thrâng", match = "Thrâng's Silver Chest",  instance = 2, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [3] = { name = "Thrâng", match = "Thrâng's Golden Chest",  instance = 2, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Storvâgûn — T1/T2 (daily) ---------------------------------------------------------------
    [2] = { name = "Storvâgûn", match = "Storvâgûn's Tinier Trinket Box", instance = 1, tier = "T1", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [1] = { name = "Storvâgûn", match = "Storvâgûn's Tiny Trinket Box",   instance = 1, tier = "T2", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

}
