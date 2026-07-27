_G.EventTypes = {
    Done         = 1,
    ExtractValue = 2,
    Completions  = 3,
}

-- Completions message patterns -----------------------------------------------------------------
_G.Ini_FavoredCompletions = ": Euch verbleiben (%d+) bevorzugt%(e%) Abschl"
_G.Ini_Completions        = ": Euch verbleiben (%d+) Abschl"
_G.Ini_ResetIn            = "wird zurückgesetzt in: "

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
    ["UBs"]      = 7,
    ["Aufgaben"]    = 8,
    ["Täglich"]    = 9,
    ["Wöchentlich"]    = 10,
    ["Motes"]    = 11,
    ["Funken"]   = 12,
    ["Tugenden"]  = 13,
}

-- content -------------------------------------------------------------------------------------
_G.Content = {
    [11] = { name = "Die Königreiche von Harad",  level = "160" },
    [10] = { name = "Morgoths Vermächtnis",        level = "160" },
    [9] = { name = "Korsaren von Umbar",           level = "150" },
    [8] = { name = "Rückkehr nach Carn Dûm",       level = "150" },
    [7] = { name = "Schicksal von Gundabad",       level = "140" },
    [6]  = { name = "Krieg der Drei Gipfel",       level = "140" },
    [5] = { name = "Minas Morgul",                 level = "130" },
    [4] = { name = "Graues Gebirge",               level = "120" },
    [3] = { name = "Andere Instanzen",             level = "" },
    [2] = { name = "Sonstiges",                    level = "" },
    [1] = { name = "Events",                       level = "" },
}

-- instances -----------------------------------------------------------------------------------
_G.Instances = {
    -- Die Königreiche von Harad
    [54]  = { name = "Die Schatzhöhlen von Hurum Kâna",   content = 11 },
    [53] = { name = "Ekal-nêbi, der gefallene Palast",      content = 11 },
    [52] = { name = "Kôth Rau, die Klagefeste",             content = 11 },
    [51] = { name = "Pagru-kirít, der Leichengarten",       content = 11 },
    [50] = { name = "Nagakhêdis Torheit",               content = 11 },
    [49] = { name = "Aufgaben: Die Königreiche von Harad",  content = 11 },
    -- Morgoths Vermächtnis
    [48] = { name = "Ashunûg, der Tempel der Verfluchten",  content = 10 },
    [47] = { name = "Nirgambâr, das Ruhelose Grab",         content = 10 },
    [46] = { name = "Dun Shûma, die Festung des Königs",    content = 10 },
    [45] = { name = "Tûl Zakana, dem Quell des Vergessens", content = 10 },
    [44] = { name = "Der Tempel von Utug-bûr",              content = 10 },
    [43] = { name = "Aufgaben: Morgoths Vermächtnis",       content = 10 },
    -- Korsaren von Umbar
    [42] = { name = "Die Insel der Stürme",                 content = 9 },
    [41] = { name = "Die Straßen der Râhal Bakh",           content = 9 },
    [40] = { name = "Dahâl Huliz, die Arena",               content = 9 },
    [39] = { name = "Der Drache und der Sturm",             content = 9 },
    [38] = { name = "Die Tiefen des Mâkhda Khorbo",         content = 9 },
    [37] = { name = "Aufgaben: Umbar",                      content = 9 },
    [36] = { name = "Handwerksgilden",                      content = 9 },
    -- Rückkehr nach Carn Dûm
    [35] = { name = "Sant Lhoer, der Giftgarten",           content = 8 },
    [34] = { name = "Thaurisgar, die abscheuliche Apotheke", content = 8 },
    [33] = { name = "Sagroth, Hort des Ungeziefers",        content = 8 },
    [32] = { name = "Gwathrenost, Ziadelle des Hexenkönigs", content = 8 },
    [31] = { name = "Aufgaben: Carn Dûm",                   content = 8 },
    -- Schicksal von Gundabad
    [30] = { name = "Angriff auf Dhúrstrok",                content = 7 },
    [29] = { name = "Höhle von Pughlak",                    content = 7 },
    [28] = { name = "Adkhât-zahhar, die Häuser der Ruhe",   content = 7 },
    [27] = { name = "Abnankâra, der Heimlichhort",         content = 7 },
    [26] = { name = "Aufgaben: Gundabad",                   content = 7 },
    -- Krieg der Drei Gipfel
    [25] = { name = "Shakalush, die Stufenschlacht",        content = 6 },
    [24] = { name = "Amdân Dammul, die Blutige Schwelle",   content = 6 },
    [23] = { name = "Der Fall von Khazad-dûm",              content = 6 },
    -- Minas Morgul
    [22] = { name = "Eithel Gwaur, der Dreckbrunnen",            content = 5 },
    [21] = { name = "Gath Daeroval, der Schattenhorst",          content = 5 },
    [20] = { name = "Gorthad Nûr, das Tiefengrab",               content = 5 },
    [19] = { name = "Das Grauen von Morgul",                      content = 5 },
    [18] = { name = "Bâr Nírnaeth, die Häuser der Wehklagen",    content = 5 },
    [17] = { name = "Ghashan-kútot, die Hallen des Dunklen Wissens", content = 5 },
    [16] = { name = "Die gefallenen Könige",                      content = 5 },
    [15] = { name = "Remmorchant, das Netz der Finsternis",       content = 5 },
    [14] = { name = "Aufgaben: Minas Morgul",                     content = 5 },
    -- Graues Gebirge
    [13] = { name = "Der Amboss der Winterschmiede",              content = 4 },
    -- Andere Instanzen
    [12] = { name = "Wöchentliche Instanz",                       content = 3 },
    [11] = { name = "Agoroth, die schmale Senke",                 content = 3 },
    [10] = { name = "Askâd-mazal, die Kammer der Schatten",       content = 3 },
    [9] = { name = "Klage der Weide",                             content = 3 },
    [8] = { name = "Sarch Vorn, das Schwarze Grab",                 content = 3 },
    [7] = { name = "Der Untergang von Caras Gelebren",                      content = 3 },
    -- Sonstiges
    [6] = { name = "Missionen/Erkundungen",                       content = 2 },
    [5] = { name = "Aufträge",                                    content = 2 },
    [4] = { name = "Funken/Staub/Tugenden",                       content = 2 },
    -- Events
    [3] = { name = "Die rote Maid",                               content = 1 },
    [2] = { name = "Thrâng",                                      content = 1 },
    [1] = { name = "Storvâgûn",                                   content = 1 },
}

-- events --------------------------------------------------------------------------------------
_G.Events = {

    -- Die Schatzhöhlen von Hurum Kâna — Solo (daily) ----------------------------------------
    [585] = { name = "Pakhán-gebar",       match = "Pakhán.gebars Truhe .Solo",             instance = 54,  tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [584] = { name = "Rat der Schatten", match = "Truhe des Rats der Schatten .Solo",    instance = 54,  tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [583] = { name = "Bârlat",             match = "Truhe von Bârlat dem Kühnen .Solo",          instance = 54,  tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [582] = { name = "Pakhán-gebar",       match = "Pakhán.gebars Truhe .Stufe 1",           instance = 54,  tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [581] = { name = "Rat der Schatten", match = "Truhe des Rats der Schatten .Stufe 1",  instance = 54,  tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [580] = { name = "Bârlat",             match = "Truhe von Bârlat dem Kühnen .Stufe 1",        instance = 54,  tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [579] = { name = "Pakhán-gebar",       match = "Pakhán.gebars Truhe .Stufe 2",           instance = 54,  tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [578] = { name = "Rat der Schatten", match = "Truhe des Rats der Schatten .Stufe 2",  instance = 54,  tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [577] = { name = "Bârlat",             match = "Truhe von Bârlat dem Kühnen .Stufe 2",        instance = 54,  tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [576] = { name = "Pakhán-gebar",       match = "Pakhán.gebars Truhe .Stufe 3",           instance = 54,  tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [575] = { name = "Rat der Schatten", match = "Truhe des Rats der Schatten .Stufe 3",  instance = 54,  tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [574] = { name = "Bârlat",             match = "Truhe von Bârlat dem Kühnen .Stufe 3",        instance = 54,  tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Ekal-nêbi, the Fallen Palace — Solo (daily) ---------------------------------------------
    [573] = { name = "Ratúlko",    match = "Truhe des Blutwächters .Solo",   instance = 53, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [572] = { name = "Barkhuráni", match = "Truhe der dunklen Priesterin .Solo",   instance = 53, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [571] = { name = "Thothril",   match = "Truhe der Verstrickerin .Solo",       instance = 53, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [570] = { name = "Ratúlko",    match = "Truhe des Blutwächters .Stufe 1", instance = 53, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [569] = { name = "Barkhuráni", match = "Truhe der dunklen Priesterin .Stufe 1", instance = 53, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [568] = { name = "Thothril",   match = "Truhe der Verstrickerin .Stufe 1",     instance = 53, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [567] = { name = "Ratúlko",    match = "Truhe des Blutwächters .Stufe 2", instance = 53, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [566] = { name = "Barkhuráni", match = "Truhe der dunklen Priesterin .Stufe 2", instance = 53, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [565] = { name = "Thothril",   match = "Truhe der Verstrickerin .Stufe 2",     instance = 53, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [564] = { name = "Ratúlko",    match = "Truhe des Blutwächters .Stufe 3", instance = 53, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [563] = { name = "Barkhuráni", match = "Truhe der dunklen Priesterin .Stufe 3", instance = 53, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [562] = { name = "Thothril",   match = "Truhe der Verstrickerin .Stufe 3",     instance = 53, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Kôth Rau, the Wailing Hold — Solo (daily) -----------------------------------------------
    [561] = { name = "Zwillinge", match = "Die Truhe der Zwillinge .Solo",           instance = 52, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [560] = { name = "Ombátha",   match = "Ombáthas persönliche Truhe .Solo",   instance = 52, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [559] = { name = "Râkdakul",  match = "Râkdakuls Tribut .Solo",         instance = 52, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [558] = { name = "Zwillinge", match = "Die Truhe der Zwillinge .Stufe 1",         instance = 52, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [557] = { name = "Ombátha",   match = "Ombáthas persönliche Truhe .Stufe 1", instance = 52, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [556] = { name = "Râkdakul",  match = "Râkdakuls Tribut .Stufe 1",       instance = 52, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [555] = { name = "Zwillinge", match = "Die Truhe der Zwillinge .Stufe 2",         instance = 52, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [554] = { name = "Ombátha",   match = "Ombáthas persönliche Truhe .Stufe 2", instance = 52, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [553] = { name = "Râkdakul",  match = "Râkdakuls Tribut .Stufe 2",       instance = 52, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [552] = { name = "Zwillinge", match = "Die Truhe der Zwillinge .Stufe 3",         instance = 52, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [551] = { name = "Ombátha",   match = "Ombáthas persönliche Truhe .Stufe 3", instance = 52, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [550] = { name = "Râkdakul",  match = "Râkdakuls Tribut .Stufe 3",       instance = 52, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Pagru-kirít, the Garden of Corpses — Solo (daily) ---------------------------------------
    [549] = { name = "Kishâsu",  match = "Kishâsu's Truhe .Solo",   instance = 51, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [548] = { name = "Khardâmu", match = "Khardâmus Truhe .Solo",  instance = 51, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [547] = { name = "Sudûgul",  match = "Sudûguls Truhe .Solo",   instance = 51, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [546] = { name = "Kishâsu",  match = "Kishâsu's Truhe .Stufe 1", instance = 51, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [545] = { name = "Khardâmu", match = "Khardâmus Truhe .Stufe 1", instance = 51, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [544] = { name = "Sudûgul",  match = "Sudûguls Truhe .Stufe 1", instance = 51, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [543] = { name = "Kishâsu",  match = "Kishâsu's Truhe .Stufe 2", instance = 51, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [542] = { name = "Khardâmu", match = "Khardâmus Truhe .Stufe 2", instance = 51, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [541] = { name = "Sudûgul",  match = "Sudûguls Truhe .Stufe 2", instance = 51, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [540] = { name = "Kishâsu",  match = "Kishâsu's Truhe .Stufe 3", instance = 51, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [539] = { name = "Khardâmu", match = "Khardâmus Truhe .Stufe 3", instance = 51, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [538] = { name = "Sudûgul",  match = "Sudûguls Truhe .Stufe 3", instance = 51, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Nagakhêdis Torheit — T1 (weekly Thu) ------------------------------------------------
    [537]  = { name = "Badharál",                match = "Badharáls groteskes Ei .Stufe 1",  instance = 50, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [536]  = { name = "Maukhorn",                match = "Maukhorns Truhe .Stufe 1",          instance = 50, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [535]  = { name = "Die Legion",              match = "Truhe der Legion .Stufe 1",        instance = 50, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [534]  = { name = "Zamâktar der Verweste", match = "Zamâktar der Verweste .Stufe 1",  instance = 50, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [533] = { name = "Badharál",                match = "Badharáls groteskes Ei .Stufe 2",  instance = 50, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [532] = { name = "Maukhorn",                match = "Maukhorns Truhe .Stufe 2",          instance = 50, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [531] = { name = "Die Legion",              match = "Truhe der Legion .Stufe 2",        instance = 50, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [530] = { name = "Zamâktar der Verweste", match = "Zamâktar der Verweste .Stufe 2",  instance = 50, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3 (weekly Thu)
    [529] = { name = "Badharál",                match = "Badharáls groteskes Ei .Stufe 3",  instance = 50, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [528] = { name = "Maukhorn",                match = "Maukhorns Truhe .Stufe 3",          instance = 50, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [527] = { name = "Die Legion",              match = "Truhe der Legion .Stufe 3",        instance = 50, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [526] = { name = "Zamâktar der Verweste", match = "Zamâktar der Verweste .Stufe 3",  instance = 50, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Kingdoms of Harad — Weeklies (weekly Thu) ---------------------------------------
    [525] = { name = "20 Aufgaben",    match = "erhaltener Anerkennungen aus Mûr Ghala .%d+/20.",                        instance = 49, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [524] = { name = "30 Aufgaben",    match = "erhaltener Anerkennungen aus Mûr Ghala .%d+/30.",                        instance = 49, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [523] = { name = "6 Instanzen",  match = "abgeschlossener Mûr.Ghala.Instanzen .%d+/6.",                   instance = 49, tier = "Wöchentlich", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [522] = { name = "T3 Instanzen", match = "Abgeschlossen:.Fortgeschrittene Herausforderungen von Mûr Ghala .Wöchentlich.",               instance = 49, tier = "Wöchentlich", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [521] = { name = "Raid",         match = "bgeschlossen:.Herausforderungen von Nagakhêdis Torheit .Wöchentlich.", instance = 49, tier = "Wöchentlich", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [520] = { name = "T3 Raid",      match = "Abgeschlossen:.Fortgeschrittene Herausforderungen von Nagakhêdis Torheit .Wöchentlich.",  instance = 49, tier = "Wöchentlich", order = 6, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- UBs (weekly Thu)
    [519] = { name = "UB Agáthar",    match = "Abgeschlossen:.Wöchentlich. Die Geißel von Adagím",         instance = 49, tier = "UBs", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [518] = { name = "UB Blutzahn", match = "Abgeschlossen:.Wöchentlich. Der Fluch des Kighâns",           instance = 49, tier = "UBs", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [517] = { name = "UB Daithor",    match = "Abgeschlossen:.Wöchentlich. Der Schrecken von An Shêru",        instance = 49, tier = "UBs", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [516] = { name = "UB Imtushâl",   match = "Abgeschlossen:.Wöchentlich. Die Niedertracht von Idagâl",     instance = 49, tier = "UBs", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- Dailies (daily)
    [515] = { name = "12 Samples", match = "Abgeschlossen:.Ernte der Kranken",                  instance = 49, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [514] = { name = "10 Weavers", match = "Abgeschlossen:.Seuchenweberinnen",                          instance = 49, tier = "Täglich", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [513] = { name = "8 Trolls",   match = "Abgeschlossen:.Von der Fäulnis verderbte Trolle",                      instance = 49, tier = "Täglich", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [512] = { name = "6 Huorns",   match = "Abgeschlossen:.Der Wald wendet sich gegen uns",              instance = 49, tier = "Täglich", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [511] = { name = "Agáthar",    match = "Abgeschlossen:.Umherziehende Bedrohung: Agáthar der Beraubte",        instance = 49, tier = "Täglich", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [510] = { name = "Bloodtooth", match = "Abgeschlossen:.Umherziehende Bedrohung: Blutzahns unstillbarer Hunger",  instance = 49, tier = "Täglich", order = 6, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Ashunûg, the Fane of the Accursed — Solo (daily) ----------------------------------------
    [509] = { name = "Eshêgur",          match = "Eshêgurs Truhe .Solo",          instance = 48, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [508] = { name = "Anâkhi-Trupp",  match = "Truhe des Anâkhi.Trupps .Solo",  instance = 48, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [507] = { name = "Nâkhugir",         match = "Nâkhugirs Schmutz .Solo",         instance = 48, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [506] = { name = "Eshêgur",          match = "Eshêgurs Truhe .Stufe 1",        instance = 48, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [505] = { name = "Anâkhi-Trupp",  match = "Truhe des Anâkhi.Trupps .Stufe 1", instance = 48, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [504] = { name = "Nâkhugir",         match = "Nâkhugirs Schmutz .Stufe 1",       instance = 48, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [503] = { name = "Eshêgur",          match = "Eshêgurs Truhe .Stufe 2",        instance = 48, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [502] = { name = "Anâkhi-Trupp",  match = "Truhe des Anâkhi.Trupps .Stufe 2", instance = 48, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [501] = { name = "Nâkhugir",         match = "Nâkhugirs Schmutz .Stufe 2",       instance = 48, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [500] = { name = "Eshêgur",          match = "Eshêgurs Truhe .Stufe 3",        instance = 48, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [499] = { name = "Anâkhi-Trupp",  match = "Truhe des Anâkhi.Trupps .Stufe 3", instance = 48, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [498] = { name = "Nâkhugir",         match = "Nâkhugirs Schmutz .Stufe 3",       instance = 48, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Nirgambâr, the Restless Tomb — Solo (daily) ----------------------------------------------
    [497] = { name = "Sakhârshag", match = "Sakhârshags Truhe .Solo",   instance = 47, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [496] = { name = "Imanak-tûr", match = "Imanak.tûrs Truhe .Solo",   instance = 47, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [495] = { name = "Aratûg",     match = "Aratûgs Truhe .Solo",       instance = 47, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [494] = { name = "Sakhârshag", match = "Sakhârshags Truhe .Stufe 1", instance = 47, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [493] = { name = "Imanak-tûr", match = "Imanak.tûrs Truhe .Stufe 1", instance = 47, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [492] = { name = "Aratûg",     match = "Aratûgs Truhe .Stufe 1",     instance = 47, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [491] = { name = "Sakhârshag", match = "Sakhârshags Truhe .Stufe 2", instance = 47, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [490] = { name = "Imanak-tûr", match = "Imanak.tûrs Truhe .Stufe 2", instance = 47, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [489] = { name = "Aratûg",     match = "Aratûgs Truhe .Stufe 2",     instance = 47, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [488] = { name = "Sakhârshag", match = "Sakhârshags Truhe .Stufe 3", instance = 47, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [487] = { name = "Imanak-tûr", match = "Imanak.tûrs Truhe .Stufe 3", instance = 47, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [486] = { name = "Aratûg",     match = "Aratûgs Truhe .Stufe 3",     instance = 47, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Dun Shûma, The King's Fortress — Solo (daily) --------------------------------------------
    [485] = { name = "Waffenmeister Mâkhragab",       match = "Die Truhe des Waffenmeisters .Solo",    instance = 46, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [484] = { name = "Ushdâla, Fürstin des Rudels",   match = "Die Truhe der Rudelfürstin .Solo", instance = 46, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [483] = { name = "Zidunâm der Geisterbeschwörer",  match = "Die Truhe des Schlangenrufers .Solo",  instance = 46, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [482] = { name = "Waffenmeister Mâkhragab",       match = "Die Truhe des Waffenmeisters .Stufe 1",    instance = 46, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [481] = { name = "Ushdâla, Fürstin des Rudels",   match = "Die Truhe der Rudelfürstin .Stufe 1", instance = 46, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [480] = { name = "Zidunâm der Geisterbeschwörer",  match = "Die Truhe des Schlangenrufers .Stufe 1", instance = 46, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [479] = { name = "Waffenmeister Mâkhragab",       match = "Die Truhe des Waffenmeisters .Stufe 2",    instance = 46, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [478] = { name = "Ushdâla, Fürstin des Rudels",   match = "Die Truhe der Rudelfürstin .Stufe 2", instance = 46, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [477] = { name = "Zidunâm der Geisterbeschwörer",  match = "Die Truhe des Schlangenrufers .Stufe 2", instance = 46, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [476] = { name = "Waffenmeister Mâkhragab",       match = "Die Truhe des Waffenmeisters .Stufe 3",    instance = 46, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [475] = { name = "Ushdâla, Fürstin des Rudels",   match = "Die Truhe der Rudelfürstin .Stufe 3", instance = 46, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [474] = { name = "Zidunâm der Geisterbeschwörer",  match = "Die Truhe des Schlangenrufers .Stufe 3", instance = 46, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Tûl Zakana, the Well of Forgetting — Solo (daily) ----------------------------------------
    [473] = { name = "Pahór-korat",         match = "Truhe der Pahór.korat .Solo",       instance = 45, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [472] = { name = "Gorthorog Verwüster", match = "Gorthorog.Verwüster.Truhe .Solo",  instance = 45, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [471] = { name = "Mûkh Bahora",          match = "Mûkh Bahoras Truhe .Solo",           instance = 45, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [470] = { name = "Bahádring",            match = "Bahádrings Truhe .Solo",              instance = 45, tier = "Solo", order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [469] = { name = "Pahór-korat",         match = "Truhe der Pahór.korat .Stufe 1",     instance = 45, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [468] = { name = "Gorthorog Verwüster", match = "Gorthorog.Verwüster.Truhe .Stufe 1", instance = 45, tier = "T1",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [467] = { name = "Mûkh Bahora",          match = "Mûkh Bahoras Truhe .Stufe 1",         instance = 45, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [466] = { name = "Bahádring",            match = "Bahádrings Truhe .Stufe 1",            instance = 45, tier = "T1",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T2 (daily)
    [465] = { name = "Pahór-korat",         match = "Truhe der Pahór.korat .Stufe 2",     instance = 45, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [464] = { name = "Gorthorog Verwüster", match = "Gorthorog.Verwüster.Truhe .Stufe 2", instance = 45, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [463] = { name = "Mûkh Bahora",          match = "Mûkh Bahoras Truhe .Stufe 2",         instance = 45, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [462] = { name = "Bahádring",            match = "Bahádrings Truhe .Stufe 2",            instance = 45, tier = "T2",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T3 (daily)
    [461] = { name = "Pahór-korat",         match = "Truhe der Pahór.korat .Stufe 3",     instance = 45, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [460] = { name = "Gorthorog Verwüster", match = "Gorthorog.Verwüster.Truhe .Stufe 3", instance = 45, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [459] = { name = "Mûkh Bahora",          match = "Mûkh Bahoras Truhe .Stufe 3",         instance = 45, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [458] = { name = "Bahádring",            match = "Bahádrings Truhe .Stufe 3",            instance = 45, tier = "T3",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- The Temple of Utug-bûr — T1 (Mon/Thu/Sat) -----------------------------------------------
    [457] = { name = "Kulkorth",              match = "Kulkorths Truhe .Stufe 1",             instance = 44, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [456] = { name = "Maluchon",              match = "Maluchons Truhe .Stufe 1",             instance = 44, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [455] = { name = "Khablag und Daikhag",   match = "Khablags und Daikhags Truhe .Stufe 1", instance = 44, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [454] = { name = "Kormoltur",             match = "Kormolturs Truhe .Stufe 1",            instance = 44, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [453] = { name = "Azagath",               match = "Truhe des Meeresschattens .Stufe 1",       instance = 44, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [452] = { name = "Gârash, the Emptiness", match = "Azagath Meeresschatten .Stufe 1",          instance = 44, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [451] = { name = "Kulkorth",              match = "Kulkorths Truhe .Stufe 2",             instance = 44, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [450] = { name = "Maluchon",              match = "Maluchons Truhe .Stufe 2",             instance = 44, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [449] = { name = "Khablag und Daikhag",   match = "Khablags und Daikhags Truhe .Stufe 2", instance = 44, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [448] = { name = "Kormoltur",             match = "Kormolturs Truhe .Stufe 2",            instance = 44, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [447] = { name = "Azagath",               match = "Truhe des Meeresschattens .Stufe 2",       instance = 44, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [446] = { name = "Gârash, the Emptiness", match = "Azagath Meeresschatten .Stufe 2",          instance = 44, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3 (weekly Thu)
    [445] = { name = "Kulkorth",              match = "Kulkorths Truhe .Stufe 3",             instance = 44, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [444] = { name = "Maluchon",              match = "Maluchons Truhe .Stufe 3",             instance = 44, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [443] = { name = "Khablag und Daikhag",   match = "Khablags und Daikhags Truhe .Stufe 3", instance = 44, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [442] = { name = "Kormoltur",             match = "Kormolturs Truhe .Stufe 3",            instance = 44, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [441] = { name = "Azagath",               match = "Truhe des Meeresschattens .Stufe 3",       instance = 44, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [440] = { name = "Gârash, the Emptiness", match = "Azagath Meeresschatten .Stufe 3",          instance = 44, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Legacy of Morgoth — Weeklies (weekly Thu) ----------------------------------------
    [439] = { name = "12 Missions",       match = "Abgeschlossen:.Fortschritte im Ikorbân.Tal .Wöchentlich.",                 instance = 43, tier = "Wöchentlich", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [438] = { name = "6 Instanzen",       match = "Abgeschlossen:.Herausforderungen von Ikorbân.Tal .Wöchentlich.",                    instance = 43, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [437] = { name = "Raid T1+",          match = "Abgeschlossen:.Die Prüfungen von Umbar und Ikorbân .Wöchentlich.",                          instance = 43, tier = "Wöchentlich", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [436] = { name = "Raid T2+",          match = "Abgeschlossen:.Das Böse von Umbar und Ikorbân .Wöchentlich.", instance = 43, tier = "Wöchentlich", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [435] = { name = "Raid höhste Stufe", match = "Abgeschlossen:.Das große Böse von Umbar und Ikorbân .Wöchentlich.", instance = 43, tier = "Wöchentlich", order = 5, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },

    -- The Isle of Storms — Solo (daily) --------------------------------------------------------
    [434] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Solo.",   instance = 42, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [433] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Solo.",     instance = 42, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [432] = { name = "Raghârik",  match = "Raghâriks Truhe .Solo.",   instance = 42, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [431] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Stufe 1.", instance = 42, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [430] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Stufe 1.",   instance = 42, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [429] = { name = "Raghârik",  match = "Raghâriks Truhe .Stufe 1.", instance = 42, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [428] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Stufe 2.", instance = 42, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [427] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Stufe 2.",   instance = 42, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [426] = { name = "Raghârik",  match = "Raghâriks Truhe .Stufe 2.", instance = 42, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [425] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Stufe 3.", instance = 42, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [424] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Stufe 3.",   instance = 42, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [423] = { name = "Raghârik",  match = "Raghâriks Truhe .Stufe 3.", instance = 42, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [422] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Stufe 4.", instance = 42, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [421] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Stufe 4.",   instance = 42, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [420] = { name = "Raghârik",  match = "Raghâriks Truhe .Stufe 4.", instance = 42, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [419] = { name = "Krizhmûl",  match = "Krizhmûls Truhe .Stufe 5.", instance = 42, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [418] = { name = "Urâbaz",    match = "Urâbaz' Truhe .Stufe 5.",   instance = 42, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [417] = { name = "Raghârik",  match = "Raghâriks Truhe .Stufe 5.", instance = 42, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Streets of Râhal Bakh — Solo (daily) -------------------------------------------------
    [416] = { name = "Utho",    match = "Uthos Truhe .Solo.",   instance = 41, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [415] = { name = "Khâshap", match = "Khâshaps Truhe .Solo.", instance = 41, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [414] = { name = "Utho",    match = "Uthos Truhe .Stufe 1.",  instance = 41, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [413] = { name = "Khâshap", match = "Khâshaps Truhe .Stufe 1.", instance = 41, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [412] = { name = "Utho",    match = "Uthos Truhe .Stufe 2.",  instance = 41, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [411] = { name = "Khâshap", match = "Khâshaps Truhe .Stufe 2.", instance = 41, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [410] = { name = "Utho",    match = "Uthos Truhe .Stufe 3.",  instance = 41, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [409] = { name = "Khâshap", match = "Khâshaps Truhe .Stufe 3.", instance = 41, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [408] = { name = "Utho",    match = "Uthos Truhe .Stufe 4.",  instance = 41, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [407] = { name = "Khâshap", match = "Khâshaps Truhe .Stufe 4.", instance = 41, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [406] = { name = "Utho",    match = "Uthos Truhe .Stufe 5.",  instance = 41, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [405] = { name = "Khâshap", match = "Khâshaps Truhe .Stufe 5.", instance = 41, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Dahâl Huliz, The Arena — Solo (daily) ---------------------------------------------------
    [404] = { name = "Akhmâr", match = "Arenaneulings.Truhe .Solo.",  instance = 40, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [403] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Solo.",   instance = 40, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [402] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Solo.",  instance = 40, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)  note: source T1 omits space before "Tier" ("Chest. Tier 1") — kept verbatim
    [401] = { name = "Akhmâr", match = "Arenaneulings.Truhe.Stufe 1.", instance = 40, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [400] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Stufe 1.", instance = 40, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [399] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Stufe 1.", instance = 40, tier = "T1",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [398] = { name = "Akhmâr", match = "Arenaneulings.Truhe .Stufe 2.", instance = 40, tier = "T2",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [397] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Stufe 2.",  instance = 40, tier = "T2",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [396] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Stufe 2.", instance = 40, tier = "T2",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [395] = { name = "Akhmâr", match = "Arenaneulings.Truhe .Stufe 3.", instance = 40, tier = "T3",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [394] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Stufe 3.",  instance = 40, tier = "T3",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [393] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Stufe 3.", instance = 40, tier = "T3",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [392] = { name = "Akhmâr", match = "Arenaneulings.Truhe .Stufe 4.", instance = 40, tier = "T4",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [391] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Stufe 4.",  instance = 40, tier = "T4",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [390] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Stufe 4.", instance = 40, tier = "T4",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [389] = { name = "Akhmâr", match = "Arenaneulings.Truhe .Stufe 5.", instance = 40, tier = "T5",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [388] = { name = "Ulanor",  match = "Arenaveteranen.Truhe .Stufe 5.",  instance = 40, tier = "T5",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [387] = { name = "Rothog",         match = "Arenawaffenmeister.Truhe .Stufe 5.", instance = 40, tier = "T5",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Dragon and the Storm — Solo (daily) --------------------------------------------------
    [386] = { name = "Ragrekhûl", match = "Ragrekhûls Beute . Solo",   instance = 39, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T3 (weekly Thu)
    [385] = { name = "Ragrekhûl", match = "Ragrekhûls Beute . Stufe 1", instance = 39, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [384] = { name = "Ragrekhûl", match = "Ragrekhûls Beute . Stufe 2", instance = 39, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [383] = { name = "Ragrekhûl", match = "Ragrekhûls Beute . Stufe 3", instance = 39, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Depths of Mâkhda Khorbo — T1 (Mon/Thu/Sat) ----------------------------------------------
    [382] = { name = "Azagath",  match = "Abgenutzte Korsarentruhe .Stufe 1.",  instance = 38, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [381] = { name = "Belondor", match = "Belondors Truhe .Stufe 1.",          instance = 38, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [380] = { name = "Umshûhra", match = "Vergessene Schmugglertruhe .Stufe 1.", instance = 38, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [379] = { name = "Azagath",  match = "Abgenutzte Korsarentruhe .Stufe 2.",  instance = 38, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [378] = { name = "Belondor", match = "Belondors Truhe .Stufe 2.",           instance = 38, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [377] = { name = "Umshûhra", match = "Vergessene Schmugglertruhe .Stufe 2.", instance = 38, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [376] = { name = "Azagath",  match = "Abgenutzte Korsarentruhe .Stufe 3.",  instance = 38, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [375] = { name = "Belondor", match = "Belondors Truhe .Stufe 3.",           instance = 38, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [374] = { name = "Umshûhra", match = "Vergessene Schmugglertruhe .Stufe 3.", instance = 38, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [373] = { name = "Azagath",  match = "Abgenutzte Korsarentruhe .Stufe 4.",  instance = 38, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [372] = { name = "Belondor", match = "Belondors Truhe .Stufe 4.",           instance = 38, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [371] = { name = "Umshûhra", match = "Vergessene Schmugglertruhe .Stufe 4.", instance = 38, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [370] = { name = "Azagath",  match = "Abgenutzte Korsarentruhe .Stufe 5.",  instance = 38, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [369] = { name = "Belondor", match = "Belondors Truhe .Stufe 5.",           instance = 38, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [368] = { name = "Umshûhra", match = "Vergessene Schmugglertruhe .Stufe 5.", instance = 38, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Umbar — Weeklies (weekly Thu) ---------------------------------------------------
    [367] = { name = "16 Aufgaben",  match = "Anzahl abgeschlossener täglicher 'Das Wohlergehen von Umbar Baharbêl'.Aufgaben .%d+/16.", instance = 37, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [366] = { name = "6 Instanzen", match = "Abgeschlossen:.Herausforderungen von Umbar .Wöchentlich.",               instance = 37, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [365] = { name = "20 Aufgaben",  match = "Anzahl abgeschlossener .Verteidigung von Umbar.môkh.*Aufgaben .%d+/20.", instance = 37, tier = "Wöchentlich", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Proto Island (daily)
    [364] = { name = "Huorn",      match = "Abgeschlossen.*Kopfgeld. Protohuorn",      instance = 37, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [363] = { name = "Salamander", match = "Abgeschlossen.*Kopfgeld. Protosalamander", instance = 37, tier = "Täglich", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [362] = { name = "Krebs",       match = "Abgeschlossen.*Kopfgeld. Protokrebs",       instance = 37, tier = "Täglich", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [361] = { name = "Bestie",      match = "Abgeschlossen.*Kopfgeld. Protobestie",      instance = 37, tier = "Täglich", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [360] = { name = "Krähe",       match = "Abgeschlossen.*Kopfgeld. Protokrähe",       instance = 37, tier = "Täglich", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Craft Guilds — Weeklies (weekly Thu) ----------------------------------------------------
    [359] = { name = "Koch",         match = "Abgeschlossen.*Essen für Umbar .Wöchentlich.",        instance = 36, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [358] = { name = "Goldschmied",     match = "Abgeschlossen.*Ringe für Umbar .Wöchentlich.",    instance = 36, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [357] = { name = "Schmied",   match = "Abgeschlossen.*Schilde für Umbar .Wöchentlich.",  instance = 36, tier = "Wöchentlich", order = 3, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [356] = { name = "Gelehrter",      match = "Abgeschlossen.*Tränke für Umbar .Wöchentlich.",     instance = 36, tier = "Wöchentlich", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [355] = { name = "Schneider",       match = "Abgeschlossen.*Kleidung für Umbar .Wöchentlich.",      instance = 36, tier = "Wöchentlich", order = 5, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [354] = { name = "Waffenschmied",  match = "Abgeschlossen.*Waffen für Umbar .Wöchentlich.", instance = 36, tier = "Wöchentlich", order = 6, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [353] = { name = "Drechsler",   match = "Abgeschlossen.*Bögen für Umbar .Wöchentlich.",  instance = 36, tier = "Wöchentlich", order = 7, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Dailies (daily)
    [352] = { name = "Koch",        match = "Abgeschlossen.*Lukullische Nachfrage .Täglich.",     instance = 36, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [351] = { name = "Goldschmied",    match = "Abgeschlossen.*Ungeschliffene Rohdiamanten .Täglich.", instance = 36, tier = "Täglich", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [350] = { name = "Schmied",  match = "Abgeschlossen.*Schutz des Volkes .Täglich.",  instance = 36, tier = "Täglich", order = 3, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [349] = { name = "Gelehrter",     match = "Abgeschlossen.*Tränke für alle .Täglich.",      instance = 36, tier = "Täglich", order = 4, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [348] = { name = "Schneider",      match = "Abgeschlossen.*Nadel und Faden .Täglich.", instance = 36, tier = "Täglich", order = 5, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [347] = { name = "Waffenschmied", match = "Abgeschlossen.*Waffenkontrolle .Täglich.",         instance = 36, tier = "Täglich", order = 6, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [346] = { name = "Drechsler",  match = "Abgeschlossen.*Sprechendes Holz .Täglich.", instance = 36, tier = "Täglich", order = 7, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Sant Lhoer, the Poison Gardens — Solo (daily) -------------------------------------------
    [345] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Solo",    instance = 35, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [344] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Solo",   instance = 35, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [343] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Stufe 1",  instance = 35, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [342] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Stufe 1", instance = 35, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [341] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Stufe 2",  instance = 35, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [340] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Stufe 2", instance = 35, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [339] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Stufe 3",  instance = 35, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [338] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Stufe 3", instance = 35, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [337] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Stufe 4",  instance = 35, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [336] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Stufe 4", instance = 35, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [335] = { name = "Tarkka-oka and Cráthair",    match = "Tarkka-okas und Cráthairs Truhe . Stufe 5",  instance = 35, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [334] = { name = "Grand Cultivator Oganuin",   match = "Großzüchterin Oganuins Truhe . Stufe 5", instance = 35, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Thaurisgar, the Vile Apothecary — Solo (daily) ------------------------------------------
    [333] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Solo",         instance = 34, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [332] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Solo",     instance = 34, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [331] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Stufe 1",        instance = 34, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [330] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Stufe 1",   instance = 34, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [329] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Stufe 2",        instance = 34, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [328] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Stufe 2",   instance = 34, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [327] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Stufe 3",        instance = 34, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [326] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Stufe 3",   instance = 34, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [325] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Stufe 4",        instance = 34, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [324] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Stufe 4",   instance = 34, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [323] = { name = "Puzzle Box",        match = "Aniocháns Rätselkiste .Stufe 5",        instance = 34, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [322] = { name = "Kurja and Kârsija", match = "Kurjas und Kârsijas Truhe .Stufe 5",   instance = 34, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Sagroth, Lair of Vermin — Solo (daily) --------------------------------------------------
    [321] = { name = "Gárvadach", match = "Gárvadachs Truhe .Solo",   instance = 33, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [320] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Solo",    instance = 33, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [319] = { name = "Gárvadach", match = "Gárvadachs Truhe .Stufe 1", instance = 33, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [318] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Stufe 1",  instance = 33, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [317] = { name = "Gárvadach", match = "Gárvadachs Truhe .Stufe 2", instance = 33, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [316] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Stufe 2",  instance = 33, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [315] = { name = "Gárvadach", match = "Gárvadachs Truhe .Stufe 3", instance = 33, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [314] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Stufe 3",  instance = 33, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [313] = { name = "Gárvadach", match = "Gárvadachs Truhe .Stufe 4", instance = 33, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [312] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Stufe 4",  instance = 33, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [311] = { name = "Gárvadach", match = "Gárvadachs Truhe .Stufe 5", instance = 33, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [310] = { name = "Rádarríg",  match = "Rádarrígs Truhe .Stufe 5",  instance = 33, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gwathrenost, the Witch-king's Citadel — T1 (Mon/Thu/Sat) --------------------------------
    [309] = { name = "Gurkrak",                 match = "Gurkraks Truhe .Stufe 1",              instance = 32, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [308] = { name = "Obáshurz",                match = "Obáshurz' Truhe .Stufe 1",             instance = 32, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [307] = { name = "Ásachal and Claghórd",    match = "Ásachals und Claghórds Truhe .Stufe 1", instance = 32, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [306] = { name = "The Shard",               match = "Relikte aus Gwathrenost .Stufe 1",        instance = 32, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [305] = { name = "Gurkrak",                 match = "Gurkraks Truhe .Stufe 2",              instance = 32, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [304] = { name = "Obáshurz",                match = "Obáshurz' Truhe .Stufe 2",             instance = 32, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [303] = { name = "Ásachal and Claghórd",    match = "Ásachals und Claghórds Truhe .Stufe 2", instance = 32, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [302] = { name = "The Shard",               match = "Relikte aus Gwathrenost .Stufe 2",        instance = 32, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [301] = { name = "Gurkrak",                 match = "Gurkraks Truhe .Stufe 3",              instance = 32, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [300] = { name = "Obáshurz",                match = "Obáshurz' Truhe .Stufe 3",             instance = 32, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [299] = { name = "Ásachal and Claghórd",    match = "Ásachals und Claghórds Truhe .Stufe 3", instance = 32, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [298] = { name = "The Shard",               match = "Relikte aus Gwathrenost .Stufe 3",        instance = 32, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [297] = { name = "Gurkrak",                 match = "Gurkraks Truhe .Stufe 4",              instance = 32, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [296] = { name = "Obáshurz",                match = "Obáshurz' Truhe .Stufe 4",             instance = 32, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [295] = { name = "Ásachal and Claghórd",    match = "Ásachals und Claghórds Truhe .Stufe 4", instance = 32, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [294] = { name = "The Shard",               match = "Relikte aus Gwathrenost .Stufe 4",        instance = 32, tier = "T4", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [293] = { name = "Gurkrak",                 match = "Gurkraks Truhe .Stufe 5",              instance = 32, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [292] = { name = "Obáshurz",                match = "Obáshurz' Truhe .Stufe 5",             instance = 32, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [291] = { name = "Ásachal und Claghórd",    match = "Ásachals und Claghórds Truhe .Stufe 5", instance = 32, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [290] = { name = "Splitter",               match = "Relikte aus Gwathrenost .Stufe 5",        instance = 32, tier = "T5", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Carn Dûm — Weeklies (weekly Thu) ------------------------------------------------
    [289] = { name = "4 Daylies", match = "Abgeschlossen:.Herausforderer der Eisernen Krone .Wöchentlich.", instance = 31, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [288] = { name = "Raid",      match = "Abgeschlossen:.Schlachtzug. Gwathrenost, die Zitadelle des Hexenkönigs .Wöchentlich", instance = 31, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    -- Daylies (daily)
    [287] = { name = "CD Instanz", match = "Abgeschlossen:.Der Kampf um Carn Dûm .Täglich.[^']", instance = 31, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Assault on Dhúrstrok — Solo (daily) -------------------------------------------------------
    [286] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Solo",   instance = 30, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [285] = { name = "Mozrúk",         match = "Mozrúks Truhe .Solo.",           instance = 30, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [284] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Stufe 1", instance = 30, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [283] = { name = "Mozrúk",         match = "Mozrúks Truhe .Stufe 1.",         instance = 30, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [282] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Stufe 2", instance = 30, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [281] = { name = "Mozrúk",         match = "Mozrúks Truhe .Stufe 2.",         instance = 30, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [280] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Stufe 3", instance = 30, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [279] = { name = "Mozrúk",         match = "Mozrúks Truhe .Stufe 3.",         instance = 30, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [278] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Stufe 4.", instance = 30, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [277] = { name = "Mozrúk",         match = "Mozrúks Truhe .Stufe 4.",         instance = 30, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [276] = { name = "Gâdh-and-Shum", match = "Gâdh.and. Shums Truhe .Stufe 5", instance = 30, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [275] = { name = "Mozrúk",         match = "Mozrúks Truhe .Stufe 5.",         instance = 30, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Den of Pughlak — Solo (daily) ------------------------------------------------------------
    [274] = { name = "Kordkoth", match = "Kordkoths Truhe .Solo.",   instance = 29, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [273] = { name = "Pughlak",  match = "Pughlaks Truhe .Solo.",    instance = 29, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [272] = { name = "Kordkoth", match = "Kordkoths Truhe .Stufe 1.", instance = 29, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [271] = { name = "Pughlak",  match = "Pughlaks Truhe .Stufe 1.",  instance = 29, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [270] = { name = "Kordkoth", match = "Kordkoths Truhe .Stufe 2.", instance = 29, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [269] = { name = "Pughlak",  match = "Pughlaks Truhe .Stufe 2.",  instance = 29, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [268] = { name = "Kordkoth", match = "Kordkoth's Chest .Stufe 3", instance = 29, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [267] = { name = "Pughlak",  match = "Pughlak's Chest .Stufe 3",  instance = 29, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone == false },
    [264] = { name = "Kordkoth", match = "Kordkoths Truhe .Stufe 5", instance = 29, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [263] = { name = "Pughlak",  match = "Pughlaks Truhe .Stufe 5",  instance = 29, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Adkhât-zahhar, the Houses of Rest — Solo (daily) -----------------------------------------
    [262] = { name = "Risen Lords", match = "Truhe der auferstandenen Herrscher .Solo",   instance = 28, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [261] = { name = "Loknashra",   match = "Loknashras Truhe .Solo",    instance = 28, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [260] = { name = "Vethug",      match = "Vethugs Truhe .Solo",       instance = 28, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (weekly Thu)  note: source omits space before "Tier 1" for Risen Lords — kept verbatim
    [259] = { name = "Auferstandenen Herrscher", match = "Truhe der auferstandenen Herrscher .Stufe 1.",  instance = 28, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [258] = { name = "Loknashra",   match = "Loknashras Truhe .Stufe 1.",  instance = 28, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [257] = { name = "Vethug",      match = "Vethug's Truhe .Stufe 1.",     instance = 28, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [256] = { name = "Auferstandenen Herrscher", match = "Truhe der auferstandenen Herrscher .Stufe 2.", instance = 28, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [255] = { name = "Loknashra",   match = "Loknashras Truhe .Stufe 2.",  instance = 28, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [254] = { name = "Vethug",      match = "Vethug's Truhe .Stufe 2.",     instance = 28, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [253] = { name = "Auferstandenen Herrscher", match = "Truhe der auferstandenen Herrscher .Stufe 3.", instance = 28, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [252] = { name = "Loknashra",   match = "Loknashras Truhe .Stufe 3.",  instance = 28, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [251] = { name = "Vethug",      match = "Vethug's Truhe .Stufe 3.",     instance = 28, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [250] = { name = "Auferstandenen Herrscher", match = "Truhe der auferstandenen Herrscher .Stufe 4.", instance = 28, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [249] = { name = "Loknashra",   match = "Loknashras Truhe .Stufe 4.",  instance = 28, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [248] = { name = "Vethug",      match = "Vethugs Truhe .Stufe 4.",     instance = 28, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [247] = { name = "Auferstandenen Herrscher", match = "Truhe der auferstandenen Herrscher .Stufe 5.", instance = 28, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [246] = { name = "Loknashra",   match = "Loknashras Truhe .Stufe 5.",  instance = 28, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [245] = { name = "Vethug",      match = "Vethugs Truhe .Stufe 5.",     instance = 28, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Abnankâra, der Heimlichhort — T1 (Mon/Thu/Sat) ------------------------------------------
    [244] = { name = "Thyrstáth's Tribute", match = "Thyrstáths Tribut .Stufe 1.",        instance = 27, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [243] = { name = "Dushtalbúk",          match = "Ausrüstung von Ibkêrmazal .Stufe 1.",    instance = 27, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [242] = { name = "Hrímil",              match = "Hrímil Frostherz' Hort .Stufe 1.", instance = 27, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [241] = { name = "Thyrstáth's Tribute", match = "Thyrstáths Tribut .Stufe 2.",        instance = 27, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [240] = { name = "Dushtalbúk",          match = "Ausrüstung von Ibkêrmazal .Stufe 2.",    instance = 27, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [239] = { name = "Hrímil",              match = "Hrímil Frostherz' Hort .Stufe 2.", instance = 27, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [238] = { name = "Thyrstáth's Tribute", match = "Thyrstáths Tribut .Stufe 3.",        instance = 27, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [237] = { name = "Dushtalbúk",          match = "Ausrüstung von Ibkêrmazal .Stufe 3.",    instance = 27, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [236] = { name = "Hrímil",              match = "Hrímil Frostherz' Hort .Stufe 3.", instance = 27, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [235] = { name = "Thyrstáth's Tribute", match = "Thyrstáths Tribut .Stufe 4.",        instance = 27, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [234] = { name = "Dushtalbúk",          match = "Ausrüstung von Ibkêrmazal .Stufe 4.",    instance = 27, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [233] = { name = "Hrímil",              match = "Hrímil Frostherz' Hort .Stufe 4.", instance = 27, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [232] = { name = "Thyrstáth's Tribute", match = "Thyrstáths Tribut .Stufe 5.",        instance = 27, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [231] = { name = "Dushtalbúk",          match = "Ausrüstung von Ibkêrmazal .Stufe 5.",    instance = 27, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [230] = { name = "Hrímil",              match = "Hrímil Frostherz' Hort .Stufe 5.", instance = 27, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Gundabad — Weeklies (weekly Thu) --------------------------------------------------
    [229] = { name = "20 Aufgaben",  match = "Abgeschlossen:.Rückeroberung der Bergfestung .Wöchentlich.", instance = 26, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [228] = { name = "6 Instanzen", match = "Abgeschlossen:.Herausforderungen des Gundabad .Wöchentlich.",        instance = 26, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [227] = { name = "Raid",       match = "Abgeschlossen:.Schlachtzug. Abnankâra, der Heimlichhort .Wöchentlich.",  instance = 26, tier = "Wöchentlich", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- Daylies (daily)
    [226] = { name = "Schmiede", match = "Abgeschlossen:.Die Schlacht bei der Schmiede[^:]", instance = 26, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [225] = { name = "Speichern", match = "Abgeschlossen:.Die Schlacht bei den Speichern[^:]", instance = 26, tier = "Täglich", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Shakalush, the Stair Battle — Solo (daily) -----------------------------------------------
    [224] = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrushs Truhe .Solo/Duo", instance = 25, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [223] = { name = "Shatarkha",          match = "Shatarkhas Truhe .Solo/Duo",           instance = 25, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [222] = { name = "Groz-und-Ulk",       match = "Groz' und Ulks Truhe .Solo/Duo",       instance = 25, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [221] = { name = "Azbauz & Maurgrush", match = "Azbauz' & Maurgrushs Truhe .Stufe 1.",   instance = 25, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [220] = { name = "Shatarkha",          match = "Shatarkhas Truhe .Stufe 1.",             instance = 25, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [219] = { name = "Groz-und-Ulk",       match = "Groz' und Ulks Truhe .Stufe 1.",         instance = 25, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [218] = { name = "Azbauz & Maurgrush", match = "Azbauz' & Maurgrushs Truhe .Stufe 2.",   instance = 25, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [217] = { name = "Shatarkha",          match = "Shatarkhas Truhe .Stufe 2.",             instance = 25, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [216] = { name = "Groz-und-Ulk",       match = "Groz' und Ulks Truhe .Stufe 2.",         instance = 25, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [215] = { name = "Azbauz & Maurgrush", match = "Azbauz' & Maurgrushs Truhe .Stufe 3%+.",   instance = 25, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [214] = { name = "Shatarkha",          match = "Shatarkhas Truhe .Stufe 3%+.",             instance = 25, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [213] = { name = "Groz-und-Ulk",       match = "Groz' und Ulks Truhe .Stufe 3%+.",         instance = 25, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Amdân Dammul, the Bloody Threshold — T1 (Mon/Thu/Sat) ------------------------------------
    [212] = { name = "The Beast", match = "Truhe of the Beasts .Stufe 1", instance = 24, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [211] = { name = "Ránulur",   match = "Ránulurs Truhe .Stufe 1",     instance = 24, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [210] = { name = "The Beast", match = "Truhe der Bestien .Stufe 2.", instance = 24, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [209] = { name = "Ránulur",   match = "Ránulurs Truhe .Stufe 2.",     instance = 24, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [208] = { name = "The Beast", match = "Truhe der Bestien .Stufe 3.", instance = 24, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [207] = { name = "Ránulur",   match = "Ránulurs Truhe .Stufe 3.",     instance = 24, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [206] = { name = "The Beast", match = "Truhe der Bestien .Stufe 4.", instance = 24, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [205] = { name = "Ránulur",   match = "Ránulurs Truhe .Stufe 4.",     instance = 24, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [204] = { name = "The Beast", match = "Truhe der Bestien .Stufe 5.", instance = 24, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [203] = { name = "Ránulur",   match = "Ránulurs Truhe .Stufe 5.",     instance = 24, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Fall of Khazad-dûm — T1 (Mon/Thu/Sat) -----------------------------------------------
    [202] = { name = "Balrog", match = "Truhe von Durins Fluch .Stufe 1.", instance = 23, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [201] = { name = "Balrog", match = "Truhe von Durins Fluch .Stufe 2.", instance = 23, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [200] = { name = "Balrog", match = "Truhe von Durins Fluch .Stufe 3.", instance = 23, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [199] = { name = "Balrog", match = "Truhe von Durins Fluch .Stufe 4.", instance = 23, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [198] = { name = "Balrog", match = "Truhe von Durins Fluch .Stufe 5.", instance = 23, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Eithel Gwaur, the Filth-well — Solo (daily) ----------------------------------------------
    [197] = { name = "Balchneth",  match = "Balchneths Truhe",        instance = 22, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [196] = { name = "Gwaurodel",  match = "Gwaurodels Truhe",        instance = 22, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [195] = { name = "Balchneth",  match = "Balchneths Silbertruhe", instance = 22, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [194] = { name = "Gwaurodel",  match = "Gwaurodels Silbertruhe", instance = 22, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [193] = { name = "Balchneth",  match = "Balchneths Goldtruhe",   instance = 22, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [192] = { name = "Gwaurodel",  match = "Gwaurodels Goldtruhe",   instance = 22, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [191] = { name = "Balchneth",  match = "Balchneths Mithriltruhe", instance = 22, tier = "T3+", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [190] = { name = "Gwaurodel",  match = "Gwaurodels Mithriltruhe", instance = 22, tier = "T3+", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gath Daeroval, the Shadow-roost — Solo (daily) -------------------------------------------
    [189] = { name = "Khúrthak",  match = "Khúrthaks Truhe",         instance = 21, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [188] = { name = "Khatlob",   match = "Khatlobs Truhe",          instance = 21, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [187] = { name = "Khúrthak",  match = "Khúrthaks Silbertruhe",  instance = 21, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [186] = { name = "Khatlob",   match = "Khatlobs Silbertruhe",   instance = 21, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [185] = { name = "Khúrthak",  match = "Khúrthaks Goldtruhe",    instance = 21, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [184] = { name = "Khatlob",   match = "Khatlobs Goldtruhe",     instance = 21, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [183] = { name = "Khúrthak",  match = "Khúrthaks Mithriltruhe", instance = 21, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [182] = { name = "Khatlob",   match = "Khatlobs Mithriltruhe",  instance = 21, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Gorthad Nûr, the Deep-barrow — Solo (daily) ----------------------------------------------
    [181] = { name = "Shalgoth",  match = "Shalgoths Truhe",         instance = 20, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [180] = { name = "Gurzhorn",  match = "Gurzhorns Truhe",         instance = 20, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [179] = { name = "Shalgoth",  match = "Shalgoths Silbertruhe",  instance = 20, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [178] = { name = "Gurzhorn",  match = "Gurzhorns Silbertruhe",  instance = 20, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [177] = { name = "Shalgoth",  match = "Shalgoths Goldtruhe",    instance = 20, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [176] = { name = "Gurzhorn",  match = "Gurzhorns Goldtruhe",    instance = 20, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [175] = { name = "Shalgoth",  match = "Shalgoths Mithriltruhe", instance = 20, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [174] = { name = "Gurzhorn",  match = "Gurzhorns Mithriltruhe", instance = 20, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Harrowing of Morgul — Solo (daily) ---------------------------------------------------
    [173] = { name = "Shaktur",   match = "Shakturs Truhe",          instance = 19, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [172] = { name = "Dargásh",   match = "Dargáshs Truhe",          instance = 19, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [171] = { name = "Shaktur",   match = "Shakturs Silbertruhe",   instance = 19, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [170] = { name = "Dargásh",   match = "Dargáshs Silbertruhe",   instance = 19, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [169] = { name = "Shaktur",   match = "Shakturs Goldtruhe",     instance = 19, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [168] = { name = "Dargásh",   match = "Dargáshs Goldtruhe",     instance = 19, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [167] = { name = "Shaktur",   match = "Shakturs Mithriltruhe",  instance = 19, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [166] = { name = "Dargásh",   match = "Dargáshs Mithriltruhe",  instance = 19, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Bâr Nírnaeth, the Houses of Lamentation — Solo (daily) -----------------------------------
    [165] = { name = "Manôzagar",  match = "Manôzagars Truhe",         instance = 18, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [164] = { name = "Narkhor",    match = "Narkhors Truhe",           instance = 18, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [163] = { name = "Morloth",    match = "Morloths Truhe",           instance = 18, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [162] = { name = "Agath-kali", match = "Agath.kalis Truhe",        instance = 18, tier = "Solo", order = 4, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [161] = { name = "Manôzagar",  match = "Manôzagars Silbertruhe",  instance = 18, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [160] = { name = "Narkhor",    match = "Narkhors Silbertruhe",    instance = 18, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [159] = { name = "Morloth",    match = "Morloths Silbertruhe",    instance = 18, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [158] = { name = "Agath-kali", match = "Agath.kalis Silbertruhe", instance = 18, tier = "T1",   order = 4, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [157] = { name = "Manôzagar",  match = "Manôzagars Goldtruhe",    instance = 18, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [156] = { name = "Narkhor",    match = "Narkhors Goldtruhe",      instance = 18, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [155] = { name = "Morloth",    match = "Morloths Goldtruhe",      instance = 18, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [154] = { name = "Agath-kali", match = "Agath.kalis Goldtruhe",   instance = 18, tier = "T2",   order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [153] = { name = "Manôzagar",  match = "Manôzagars Mithriltruhe",  instance = 18, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [152] = { name = "Narkhor",    match = "Narkhors Mithriltruhe",    instance = 18, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [151] = { name = "Morloth",    match = "Morloths Mithriltruhe",    instance = 18, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [150] = { name = "Agath-kali", match = "Agath.kalis Mithriltruhe", instance = 18, tier = "T3+",  order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Ghashan-Kútot, the Halls of Black Lore — Solo (daily) ------------------------------------
    [149] = { name = "Past Adventures", match = "Truhe vergangener Abenteuer",        instance = 17, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [148] = { name = "Fallen Foe",      match = "Truhe des gefallenen Feindes",         instance = 17, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [147] = { name = "Dolguzigir",      match = "Dolguzigirs Truhe",              instance = 17, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [146] = { name = "Past Adventures", match = "Silbertruhe vergangener Abenteuer", instance = 17, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [145] = { name = "Fallen Foe",      match = "Silbertruhe des gefallenen Feindes",  instance = 17, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [144] = { name = "Dolguzigir",      match = "Dolguzigirs Silbertruhe",       instance = 17, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [143] = { name = "Past Adventures", match = "Goldtruhe vergangener Abenteuer", instance = 17, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [142] = { name = "Fallen Foe",      match = "Goldtruhen des gefallenen Feindes",  instance = 17, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [141] = { name = "Dolguzigir",      match = "Dolguzigirs Goldtruhen",       instance = 17, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [140] = { name = "Past Adventures", match = "Mithriltruhe vergangener Abenteuer", instance = 17, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [139] = { name = "Fallen Foe",      match = "Mithriltruhe des gefallenen Feindes",  instance = 17, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [138] = { name = "Dolguzigir",      match = "Dolguzigirs Mithriltruhe",        instance = 17, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Fallen Kings — Solo (daily) ----------------------------------------------------------
    [137] = { name = "The Witch King", match = "Die Truhe des Hexenkönigs",        instance = 16, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [136] = { name = "The Witch King", match = "Die Silbertruhe des Hexenkönigs", instance = 16, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [135] = { name = "The Witch King", match = "Die Goldtruhen des Hexenkönigs", instance = 16, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [134] = { name = "The Witch King", match = "Die Mithriltruhe des Hexenkönigs", instance = 16, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Remmorchant, the Net of Darkness — T1 (Mon/Thu/Sat) -------------------------------------
    [133] = { name = "Gragarag",       match = "Gragarags Truhe .Stufe 1.",       instance = 15, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [132] = { name = "Guruthang",      match = "Guruthangs Truhe .Stufe 1.",      instance = 15, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [131] = { name = "Gamnagol",       match = "Gamnagols Truhe .Stufe 1.",       instance = 15, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [130] = { name = "Bratha Tasakh",  match = "Bratha Tasakhs Truhe .Stufe 1.",  instance = 15, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [129] = { name = "Thossulun",      match = "Thossuluns Truhe .Stufe 1.",      instance = 15, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [128] = { name = "Rûkhor der Bleiche Herold", match = "Truhe des Bleichen Herolds .Stufe 1.", instance = 15, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [127] = { name = "Kankra", match = "Schatz der Spinnenkönigin .Stufe 1.", instance = 15, tier = "T1", order = 7, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    -- T2–T5 (weekly Thu)
    [126] = { name = "Gragarag",       match = "Gragarags Truhe .Stufe 2.",       instance = 15, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [125] = { name = "Guruthang",      match = "Guruthangs Truhe .Stufe 2.",      instance = 15, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [124] = { name = "Gamnagol",       match = "Gamnagols Truhe .Stufe 2.",       instance = 15, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [123] = { name = "Bratha Tasakh",  match = "Bratha Tasakhs Truhe .Stufe 2.",  instance = 15, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [122] = { name = "Thossulun",      match = "Thossuluns Truhe .Stufe 2.",      instance = 15, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [121] = { name = "Rûkhor der Bleiche Herold", match = "Truhe des Bleichen Herolds .Stufe 2.", instance = 15, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [120] = { name = "Kankra", match = "Schatz der Spinnenkönigin .Stufe 2.", instance = 15, tier = "T2", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [119] = { name = "Gragarag",       match = "Gragarags Truhe .Stufe 3.",       instance = 15, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [118] = { name = "Guruthang",      match = "Guruthangs Truhe .Stufe 3.",      instance = 15, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [117] = { name = "Gamnagol",       match = "Gamnagols Truhe .Stufe 3.",       instance = 15, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [116] = { name = "Bratha Tasakh",  match = "Bratha Tasakhs Truhe .Stufe 3.",  instance = 15, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [115] = { name = "Thossulun",      match = "Thossuluns Truhe .Stufe 3.",      instance = 15, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [114] = { name = "Rûkhor der Bleiche Herold", match = "Truhe des Bleichen Herolds .Stufe 3.", instance = 15, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [113] = { name = "Kankra", match = "Schatz der Spinnenkönigin .Stufe 3.", instance = 15, tier = "T3", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [112] = { name = "Gragarag",       match = "Gragarags Truhe .Stufe 4.",       instance = 15, tier = "T4", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [111] = { name = "Guruthang",      match = "Guruthangs Truhe .Stufe 4.",      instance = 15, tier = "T4", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [110] = { name = "Gamnagol",       match = "Gamnagols Truhe .Stufe 4.",       instance = 15, tier = "T4", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [109] = { name = "Bratha Tasakh",  match = "Bratha Tasakhs Truhe .Stufe 4.",  instance = 15, tier = "T4", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [108] = { name = "Thossulun",      match = "Thossuluns Truhe .Stufe 4.",      instance = 15, tier = "T4", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [107] = { name = "Rûkhor der Bleiche Herold", match = "Truhe des Bleichen Herolds .Stufe 4.", instance = 15, tier = "T4", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [106] = { name = "Kankra", match = "Schatz der Spinnenkönigin .Stufe 4.", instance = 15, tier = "T4", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [105] = { name = "Gragarag",       match = "Gragarags Truhe . .Stufe 5.",       instance = 15, tier = "T5", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [104] = { name = "Guruthang",      match = "Guruthangs Truhe . .Stufe 5.",      instance = 15, tier = "T5", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [103] = { name = "Gamnagol",       match = "Gamnagols Truhe . .Stufe 5.",       instance = 15, tier = "T5", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [102] = { name = "Bratha Tasakh",  match = "Bratha Tasakhs Truhe . .Stufe 5.",  instance = 15, tier = "T5", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [101] = { name = "Thossulun",      match = "Thossuluns Truhe . .Stufe 5.",      instance = 15, tier = "T5", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [100] = { name = "Rûkhor der Bleiche Herold", match = "Truhe des Bleichen Herolds. .Stufe 5.", instance = 15, tier = "T5", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [99] = { name = "Kankra", match = "Schatz der Spinnenkönigin .Stufe 5.", instance = 15, tier = "T5", order = 7, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Aufgaben: Minas Morgul — Weeklies (weekly Thu) ---------------------------------------------
    [98] = { name = "UBs Mordor", match = "Imlad Morgul: Weitere Gefahren",   instance = 14, tier = "Wöchentlich", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [97] = { name = "10 Aufgaben",         match = "Imlad Morgul: Die Rückeroberung",      instance = 14, tier = "Wöchentlich", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [96] = { name = "4 Instanzen",       match = "Imlad Morgul: Schleier der Hexerei",      instance = 14, tier = "Wöchentlich", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [95] = { name = "Limlók",            match = "Beschützer des Wilderlands: Kopfgelder", instance = 14, tier = "Wöchentlich", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- The Anvil of Winterstith — T1 (Mon/Thu/Sat) ---------------------------------------------
    [94] = { name = "Isvítha",   match = "Isvíthas Silbertruhe",    instance = 13, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [93] = { name = "Ingór",     match = "Ingórs Silbertruhe",      instance = 13, tier = "T1", order = 2, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [92] = { name = "Ice-Grim",  match = "Versteckter Silberschatz",        instance = 13, tier = "T1", order = 3, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [91] = { name = "Icebeast",  match = "Eisbiest.Silberschatz",   instance = 13, tier = "T1", order = 4, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [90] = { name = "Karazgar",  match = "Karazgars Silbertruhe",   instance = 13, tier = "T1", order = 5, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },
    [89] = { name = "Hrímil",    match = "Hrímils Silbertruhe",     instance = 13, tier = "T1", order = 6, type = _G.EventTypes.Completions, reset = { days = TriWeek, time = 8 }, onlyResetIfDone = false },

    -- T2 (weekly Thu)
    [88] = { name = "Isvítha",   match = "Isvíthas Goldtruhe",    instance = 13, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [87] = { name = "Ingór",     match = "Ingórs Goldtruhe",      instance = 13, tier = "T2", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [86] = { name = "Ice-Grim",  match = "Versteckter Goldschatz",          instance = 13, tier = "T2", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [85] = { name = "Icebeast",  match = "Eisbiest.Goldschatz",   instance = 13, tier = "T2", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [84] = { name = "Karazgar",  match = "Karazgars Goldtruhe",   instance = 13, tier = "T2", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [83] = { name = "Hrímil",    match = "Hrímils Goldtruhe",     instance = 13, tier = "T2", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- T3 (weekly Thu)
    [82] = { name = "Isvítha",   match = "Isvíthas Mithriltruhe",   instance = 13, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [81] = { name = "Ingór",     match = "Ingórs Mithriltruhe",     instance = 13, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [80] = { name = "Ice-Grim",  match = "Versteckter Mithrilschatz",       instance = 13, tier = "T3", order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [79] = { name = "Icebeast",  match = "Eisbiest.Mithrilschatz",  instance = 13, tier = "T3", order = 4, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [78] = { name = "Karazgar",  match = "Karazgars Mithriltruhe",  instance = 13, tier = "T3", order = 5, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [77] = { name = "Hrímil",    match = "Hrímils Mithriltruhe",    instance = 13, tier = "T3", order = 6, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Featured Instance — Daylies (daily) ------------------------------------------------------
    [76] = { name = "Low level", match = "Abgeschlossen:.Wöchentliche Instanz.+",            instance = 12, tier = "Täglich", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [75] = { name = "Cap level", match = "Abgeschlossen:.Wöchentliche Instanz.+.max. Stufe.", instance = 12, tier = "Täglich", order = 2, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Agoroth, the Narrowdelve — Solo (daily) --------------------------------------------------
    [74] = { name = "Rúcrog Raubalg", match = "Truhe des Raubalgs .Solo.",   instance = 11, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [73] = { name = "Aigrith die Leichenfahle",    match = "Truhe des Aschenen .Solo.",      instance = 11, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [72] = { name = "Sturm des Hexenkönigs",    match = "Truhe des Sturms .Solo.",      instance = 11, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [71] = { name = "Rúcrog Raubalg", match = "Truhe des Raubalgs .Stufe 1.", instance = 11, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [70] = { name = "Aigrith die Leichenfahle",    match = "Truhe des Aschenen .Stufe 1.",    instance = 11, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [69] = { name = "Sturm des Hexenkönigs",    match = "Truhe des Sturms .Stufe 1.",    instance = 11, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [68] = { name = "Rúcrog Raubalg", match = "Truhe des Raubalgs .Stufe 2.", instance = 11, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [67] = { name = "Aigrith die Leichenfahle",    match = "Truhe des Aschenen .Stufe 2.",    instance = 11, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [66] = { name = "Sturm des Hexenkönigs",    match = "Truhe des Sturms .Stufe 2.",    instance = 11, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [65] = { name = "Hoarpelt", match = "Truhe des Raubalgs .Stufe 3%+", instance = 11, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [64] = { name = "Ashen",    match = "Truhe des Aschenen .Stufe 3%+",    instance = 11, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [63] = { name = "Storm",    match = "Truhe des Sturms .Stufe 3%+",    instance = 11, tier = "T3+",  order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Askâd-mazal, the Chamber of Shadows — Solo (daily) --------------------------------------
    [62] = { name = "Der Schattenkönig", match = "Die Truhe des Königs .Solo",   instance = 10, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [61] = { name = "Der Schattenkönig", match = "Die Truhe des Königs .Stufe 1.", instance = 10, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [60] = { name = "Der Schattenkönig", match = "Die Truhe des Königs .Stufe 2.", instance = 10, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [59] = { name = "Der Schattenkönig", match = "Die Truhe des Königs .Stufe 3%+.", instance = 10, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Woe of the Willow — Solo (daily) --------------------------------------------------------
    [58] = { name = "Gulmúk Feuchtschimmel", match = "Feuchtschimmels Truhe .Solo.",   instance = 9, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [57] = { name = "Morgul-Klinge",  match = "Bombadils Gabe .Solo.",     instance = 9, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1 (daily)
    [56] = { name = "Gulmúk Feuchtschimmel", match = "Feuchtschimmels Truhe .Stufe 1.", instance = 9, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [55] = { name = "Morgul-Klinge",  match = "Bombadils Gabe .Stufe 1.",   instance = 9, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T2 (weekly Thu)
    [54] = { name = "Gulmúk Feuchtschimmel", match = "Feuchtschimmels Truhe .Stufe 2.", instance = 9, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [53] = { name = "Morgul-Klinge",  match = "Bombadils Gabe .Stufe 2.",   instance = 9, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    -- T3+ (weekly Thu)
    [52] = { name = "Dampmould", match = "Feuchtschimmels Truhe .Stufe 3%+", instance = 9, tier = "T3+",  order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [51] = { name = "Bombadil",  match = "Bombadils Gabe .Stufe 3%+",   instance = 9, tier = "T3+",  order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Sarch Vorn, das Schwarze Grab — Solo (daily) -----------------------------------------------
    [50] = { name = "Fladach",     match = "Fladachs Truhe .Solo.",   instance = 8, tier = "Solo", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [49] = { name = "Luilloth",    match = "Luilloths Truhe .Solo.",  instance = 8, tier = "Solo", order = 2, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    [48] = { name = "Hithrengor",  match = "Hithrengors Truhe .Solo.", instance = 8, tier = "Solo", order = 3, type = _G.EventTypes.Completions, reset = { days = Daily,  time = 8 }, onlyResetIfDone = false },
    -- T1–T5 (weekly Thu)
    [47] = { name = "Fladach",     match = "Fladachs Truhe .Stufe 1.",   instance = 8, tier = "T1",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [46] = { name = "Luilloth",    match = "Luilloths Truhe .Stufe 1.",  instance = 8, tier = "T1",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [45] = { name = "Hithrengor",  match = "Hithrengors Truhe .Stufe 1.", instance = 8, tier = "T1",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [44] = { name = "Fladach",     match = "Fladachs Truhe .Stufe 2.",   instance = 8, tier = "T2",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [43] = { name = "Luilloth",    match = "Luilloths Truhe .Stufe 2.",  instance = 8, tier = "T2",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [42] = { name = "Hithrengor",  match = "Hithrengors Truhe .Stufe 2.", instance = 8, tier = "T2",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [41] = { name = "Fladach",     match = "Fladachs Truhe .Stufe 3.",   instance = 8, tier = "T3",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [40] = { name = "Luilloth",    match = "Luilloths Truhe .Stufe 3.",  instance = 8, tier = "T3",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [39] = { name = "Hithrengor",  match = "Hithrengors Truhe .Stufe 3.", instance = 8, tier = "T3",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [38] = { name = "Fladach",     match = "Fladachs Truhe .Stufe 4.",   instance = 8, tier = "T4",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [37] = { name = "Luilloth",    match = "Luilloths Truhe .Stufe 4.",  instance = 8, tier = "T4",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [36] = { name = "Hithrengor",  match = "Hithrengors Truhe .Stufe 4.", instance = 8, tier = "T4",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [35] = { name = "Fladach",     match = "Fladachs Truhe .Stufe 5.",   instance = 8, tier = "T5",   order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [34] = { name = "Luilloth",    match = "Luilloths Truhe .Stufe 5.",  instance = 8, tier = "T5",   order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [33] = { name = "Hithrengor",  match = "Hithrengors Truhe .Stufe 5.", instance = 8, tier = "T5",   order = 3, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Der Untergang von Caras Gelebren — T3 (weekly Thu) ------------------------------------------------
    [32] = { name = "6-man",  match = "Großes Geschenk der Mírdain .Stufe 3", instance = 7, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [31] = { name = "12-man", match = "Größeres Geschenk der Mírdain .Stufe 3",   instance = 7, tier = "T3", order = 2, type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Missions/Delvings — Weeklies (weekly Thu) ------------------------------------------------
    [30] = { name = "15 Missonen",      match = "Anzahl erfüllter Missionen .%d+/15",                          instance = 6, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [29] = { name = "45 Missonen",      match = "Anzahl erfüllter Missionen .%d+/45",                          instance = 6, tier = "Wöchentlich", order = 2, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [28] = { name = "15 Erkundungen",      match = "Abgeschlossen:.Wagt Euch tiefer .Wöchentlich.",                                instance = 6, tier = "Wöchentlich", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [27] = { name = "10 T6+ Erkundungen",  match = "Anzahl abgeschlossener hochstufiger Erkundungen .Stufe 6 oder höher. .%d+.10.", instance = 6, tier = "Wöchentlich", order = 4, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [26] = { name = "Ini Erkundungen",     match = "Abgeschlossen:.Wagt Euch in die tiefste Tiefen .Wöchentlich.",                               instance = 6, tier = "Wöchentlich", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Tasks — Weeklies (weekly Thu) ------------------------------------------------------------
    [25] = { name = "10 Aufträge",                   match = "Abgeschlossen:.Anstehende Aufträge",               instance = 5, tier = "Wöchentlich", order = 1, type = _G.EventTypes.ExtractValue, reset = { days = Weekly, time = 8 }, onlyResetIfDone = true },
    [24] = { name = "Marken des Heldentums",          match = "Abgeschlossen:.Marken des Heldentums[^ ]",            instance = 5, tier = "Wöchentlich", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [23] = { name = "Marken des Heldentums (Stufe 2)", match = "Abgeschlossen:.Marken des Heldentums .Stufe 2.",       instance = 5, tier = "Wöchentlich", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [22] = { name = "Marken des Heldentums (Stufe 3)", match = "Abgeschlossen:.Marken des Heldentums .Stufe 3.",       instance = 5, tier = "Wöchentlich", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Embers (Sunday reset) ---------------------------------------------
    [21] = { name = "Umbari Tâm for Embers",        match = "Abgeschlossen:.Umbar.Tâm gegen Funken",              instance = 4, tier = "Funken", order = 1, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [20] = { name = "Handwerk gegen Funken",    match = "Abgeschlossen:.Handwerk gegen Funken",                   instance = 4, tier = "Funken", order = 2, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    -- Motes (Sunday reset)
    [19] = { name = "Vales of Anduin Motes",  match = "Abgeschlossen:.Gúlmark gegen Staub",                     instance = 4, tier = "Motes", order = 1, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [18] = { name = "Ered Mithrin Motes",     match = "Abgeschlossen:.Marken der Langbärte gegen Staub",               instance = 4, tier = "Motes", order = 2, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [17] = { name = "Siegel von Imlad Ithil", match = "Abgeschlossen:.Siegel von Imlad Ithil für Funken",         instance = 4, tier = "Motes", order = 3, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [16] = { name = "Elderslade Motes",       match = "Abgeschlossen:.Copper Coins of Gundabad for Motes",      instance = 4, tier = "Motes", order = 4, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    [15] = { name = "Gundabad Asche Aufgabe", match = "Abgeschlossen:.Silbermünzen von Gundabad gegen Staub",      instance = 4, tier = "Motes", order = 5, type = _G.EventTypes.Done, reset = { days = {Sunday}, time = 8 }, onlyResetIfDone = false },
    -- Virtues (weekly Thu)
    [14] = { name = "I",       match = "From the Ashes Comes Virtue . I[^ ]",    instance = 4, tier = "Tugenden", order = 1, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [13] = { name = "II",      match = "From the Ashes Comes Virtue . II[^ ]",   instance = 4, tier = "Tugenden", order = 2, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [12] = { name = "III",     match = "From the Ashes Comes Virtue . III",       instance = 4, tier = "Tugenden", order = 3, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [11] = { name = "IV",      match = "From the Ashes Comes Virtue . IV",        instance = 4, tier = "Tugenden", order = 4, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [10] = { name = "V",       match = "From the Ashes Comes Virtue . V",         instance = 4, tier = "Tugenden", order = 5, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [9] = { name = "VI",      match = "From the Ashes Comes Virtue . VI",        instance = 4, tier = "Tugenden", order = 6, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },
    [8] = { name = "Weekly",  match = "From the Ashes Comes Virtue . Weekly",    instance = 4, tier = "Tugenden", order = 7, type = _G.EventTypes.Done, reset = { days = Weekly, time = 8 }, onlyResetIfDone = false },

    -- Naruhel — T1/T2/T3 (daily) --------------------------------------------------------------
    [7] = { name = "Maid", match = "Naruhels Silbertruhe",  instance = 3, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [6] = { name = "Maid", match = "Narkhors Goldtruhe",  instance = 3, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [5] = { name = "Maid", match = "Narkhors Mithriltruhe", instance = 3, tier = "T3", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Thrâng — T1/T2 (daily) ------------------------------------------------------------------
    [4] = { name = "Thrâng", match = "Thrângs Silbertruhe",  instance = 2, tier = "T1", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [3] = { name = "Thrâng", match = "Thrângs Goldtruhe",  instance = 2, tier = "T2", order = 1, type = _G.EventTypes.Completions, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

    -- Storvâgûn — T1/T2 (daily) ---------------------------------------------------------------
    [2] = { name = "Storvâgûn", match = "Storvâgûns winzigere Schmuckkiste", instance = 1, tier = "T1", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },
    [1] = { name = "Storvâgûn", match = "Storvâgûns winzige Schmuckkiste",   instance = 1, tier = "T2", order = 1, type = _G.EventTypes.Done, reset = { days = Daily, time = 8 }, onlyResetIfDone = false },

}
