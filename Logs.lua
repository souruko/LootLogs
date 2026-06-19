EventTypes = {
    Done = 1,
    ExtractValue = 2
}


local Sunday = 1
local Monday = 2
local Thusday = 3
local Wednesday = 4
local Thursday = 5
local Frieday = 6
local Saturday = 7

-- content -----------------------------------------------------------------------------
_G.Content = {
    [1] = {
        name = "Zwergen update",
        level = "140"
    },
    [2] = {
        name = "Strand Urlaub",
        level = "150"
    }
}

-- instances ---------------------------------------------------------------------------
_G.Instances = {
    [1] = {
        name = "HoA",
        content = 1
    }
}

-- logs --------------------------------------------------------------------------------
_G.Events = {
    [1] = {
        name = "Hirmil",
        match = "The chest of Hirmil",
        instance = 1,
        tier = "T1",
        type = EventTypes.Done,
        reset = {
            days = {Monday, Thusday},
            time = 10
        },
    },
    [2] = {
        name = "Nethe",
        match = "The chest of Nethelos",
        content = 1,
        instance = 1,
        tier = 1,
        type = EventTypes.Done,
        reset = {
            days = {Monday, Thusday},
            time = 10
        }
    }
}