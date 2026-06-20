EventTypes = {
    Done = 1,
    ExtractValue = 2
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
    ["T4"]       = 5,
    ["T5"]       = 6,
    ["Weeklies"] = 7,
    ["Daylies"]  = 8,
    ["Dailies"]  = 8,
}

-- content -------------------------------------------------------------------------------------
_G.Content = {
    [1] = { name = "War of Three Peaks",  level = "140" },
    [2] = { name = "Fate of Gundabad",    level = "140" },
    [3] = { name = "Corsairs of Umbar",   level = "150" },
}

-- instances -----------------------------------------------------------------------------------
_G.Instances = {
    -- War of Three Peaks
    [1] = { name = "Shakalush, the Stair Battle",        content = 1 },
    [2] = { name = "Amdân Dammul, the Bloody Threshold", content = 1 },
    [3] = { name = "The Fall of Khazad-dûm",             content = 1 },
    -- Fate of Gundabad
    [4] = { name = "Assault on Dhúrstrok",               content = 2 },
    [5] = { name = "Den of Pughlak",                     content = 2 },
    [6] = { name = "The Hiddenhoard of Abnankâra",       content = 2 },
    -- Corsairs of Umbar
    [7] = { name = "The Isle of Storms",                 content = 3 },
    [8] = { name = "Depths of Mâkhda Khorbo",            content = 3 },
}

-- events --------------------------------------------------------------------------------------
_G.Events = {

    -- Shakalush — Solo (daily) ----------------------------------------------------------------
    [1]  = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Solo/Duo", instance = 1, tier = "Solo", order = 1, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    [2]  = { name = "Shatarkha",          match = "Shatarkha's Chest . Solo/Duo",           instance = 1, tier = "Solo", order = 2, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    [3]  = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Solo/Duo",       instance = 1, tier = "Solo", order = 3, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    -- Shakalush — T1 (daily)
    [4]  = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Tier 1",   instance = 1, tier = "T1",   order = 1, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    [5]  = { name = "Shatarkha",          match = "Shatarkha's Chest . Tier 1",             instance = 1, tier = "T1",   order = 2, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    [6]  = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Tier 1",         instance = 1, tier = "T1",   order = 3, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    -- Shakalush — T2 (weekly Thu)
    [7]  = { name = "Azbauz & Maurgrush", match = "Azbauz & Maurgrush's Chest . Tier 2",   instance = 1, tier = "T2",   order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [8]  = { name = "Shatarkha",          match = "Shatarkha's Chest . Tier 2",             instance = 1, tier = "T2",   order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [9]  = { name = "Groz-and-Ulk",       match = "Groz.and.Ulk's Chest . Tier 2",         instance = 1, tier = "T2",   order = 3, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

    -- Amdân Dammul — T1 (Mon/Thu/Sat) -------------------------------------------------------
    [10] = { name = "The Beast",  match = "Chest of the Beasts . Tier 1",  instance = 2, tier = "T1", order = 1, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    [11] = { name = "Ránulur",    match = "Ránulur's Chest . Tier 1",      instance = 2, tier = "T1", order = 2, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    -- Amdân Dammul — T2 (weekly Thu)
    [12] = { name = "The Beast",  match = "Chest of the Beasts . Tier 2",  instance = 2, tier = "T2", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [13] = { name = "Ránulur",    match = "Ránulur's Chest . Tier 2",      instance = 2, tier = "T2", order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    -- Amdân Dammul — T3 (weekly Thu)
    [14] = { name = "The Beast",  match = "Chest of the Beasts . Tier 3",  instance = 2, tier = "T3", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [15] = { name = "Ránulur",    match = "Ránulur's Chest . Tier 3",      instance = 2, tier = "T3", order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

    -- The Fall of Khazad-dûm — T1 (Mon/Thu/Sat) --------------------------------------------
    [16] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 1", instance = 3, tier = "T1", order = 1, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    -- T2–T4 (weekly Thu)
    [17] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 2", instance = 3, tier = "T2", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [18] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 3", instance = 3, tier = "T3", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [19] = { name = "Balrog", match = "Chest of Durin's Bane . Tier 4", instance = 3, tier = "T4", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

    -- Assault on Dhúrstrok — Solo (daily) ---------------------------------------------------
    [20] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Solo",   instance = 4, tier = "Solo", order = 1, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    [21] = { name = "Mozrúk",         match = "Mozrúk's Chest . Solo",           instance = 4, tier = "Solo", order = 2, type = EventTypes.Done, reset = { days = Daily,   time = 3 } },
    -- T1–T2 (weekly Thu)
    [22] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 1", instance = 4, tier = "T1",   order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [23] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 1",         instance = 4, tier = "T1",   order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [24] = { name = "Gâdh-and-Shum", match = "Gâdh.and.Shum's Chest . Tier 2", instance = 4, tier = "T2",   order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [25] = { name = "Mozrúk",         match = "Mozrúk's Chest . Tier 2",         instance = 4, tier = "T2",   order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

    -- Den of Pughlak — Solo (daily) ---------------------------------------------------------
    [26] = { name = "Kordkoth", match = "Kordkoth's Chest . Solo",   instance = 5, tier = "Solo", order = 1, type = EventTypes.Done, reset = { days = Daily,  time = 3 } },
    [27] = { name = "Pughlak",  match = "Pughlak's Chest . Solo",    instance = 5, tier = "Solo", order = 2, type = EventTypes.Done, reset = { days = Daily,  time = 3 } },
    -- T1 (weekly Thu)
    [28] = { name = "Kordkoth", match = "Kordkoth's Chest . Tier 1", instance = 5, tier = "T1",   order = 1, type = EventTypes.Done, reset = { days = Weekly, time = 3 } },
    [29] = { name = "Pughlak",  match = "Pughlak's Chest . Tier 1",  instance = 5, tier = "T1",   order = 2, type = EventTypes.Done, reset = { days = Weekly, time = 3 } },

    -- The Hiddenhoard of Abnankâra — T1 (Mon/Thu/Sat) --------------------------------------
    [30] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 1",         instance = 6, tier = "T1", order = 1, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    [31] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 1",     instance = 6, tier = "T1", order = 2, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    [32] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 1",  instance = 6, tier = "T1", order = 3, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    -- T2 (weekly Thu)
    [33] = { name = "Thyrstáth's Tribute", match = "Thyrstáth's Tribute . Tier 2",         instance = 6, tier = "T2", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [34] = { name = "Dushtalbúk",          match = "Armaments of Ibkêrmazal . Tier 2",     instance = 6, tier = "T2", order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [35] = { name = "Hrímil",              match = "Hrímil Frost.heart's Hoard . Tier 2",  instance = 6, tier = "T2", order = 3, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

    -- The Isle of Storms — Solo (daily) -----------------------------------------------------
    [36] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Solo",    instance = 7, tier = "Solo", order = 1, type = EventTypes.Done, reset = { days = Daily,  time = 3 } },
    [37] = { name = "Urâbaz",    match = "Urâbaz's Chest . Solo",      instance = 7, tier = "Solo", order = 2, type = EventTypes.Done, reset = { days = Daily,  time = 3 } },
    [38] = { name = "Raghârik",  match = "Raghârik's Chest . Solo",    instance = 7, tier = "Solo", order = 3, type = EventTypes.Done, reset = { days = Daily,  time = 3 } },
    -- T1 (weekly Thu)
    [39] = { name = "Krizhmûl",  match = "Krizhmûl's Chest . Tier 1",  instance = 7, tier = "T1",   order = 1, type = EventTypes.Done, reset = { days = Weekly, time = 3 } },
    [40] = { name = "Urâbaz",    match = "Urâbaz's Chest . Tier 1",    instance = 7, tier = "T1",   order = 2, type = EventTypes.Done, reset = { days = Weekly, time = 3 } },
    [41] = { name = "Raghârik",  match = "Raghârik's Chest . Tier 1",  instance = 7, tier = "T1",   order = 3, type = EventTypes.Done, reset = { days = Weekly, time = 3 } },

    -- Depths of Mâkhda Khorbo — T1 (Mon/Thu/Sat) ------------------------------------------
    [42] = { name = "Azagath",   match = "Well.worn Corsair's Chest . Tier 1",   instance = 8, tier = "T1", order = 1, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    [43] = { name = "Belondor",  match = "Belondor's Chest . Tier 1",            instance = 8, tier = "T1", order = 2, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    [44] = { name = "Umshûhra",  match = "Forgotten Smuggler's Chest . Tier 1",  instance = 8, tier = "T1", order = 3, type = EventTypes.Done, reset = { days = TriWeek, time = 3 } },
    -- T2 (weekly Thu)
    [45] = { name = "Azagath",   match = "Well.worn Corsair's Chest . Tier 2",   instance = 8, tier = "T2", order = 1, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [46] = { name = "Belondor",  match = "Belondor's Chest . Tier 2",            instance = 8, tier = "T2", order = 2, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },
    [47] = { name = "Umshûhra",  match = "Forgotten Smuggler's Chest . Tier 2",  instance = 8, tier = "T2", order = 3, type = EventTypes.Done, reset = { days = Weekly,  time = 3 } },

}
