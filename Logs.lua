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



local test = Turbine.Engine.GetDate()
Turbine.Shell.WriteLine(test.DayOfWeek)

-- content -----------------------------------------------------------------------------
_G.Content = {
    [1] = {
        name = "Zwergen update",
        level = "140"
    }
}

-- instances ---------------------------------------------------------------------------
_G.Instances = {
    [1] = {
        name = "HoA"
    }
}

-- tiers -------------------------------------------------------------------------------
_G.Tiers = {
    [1] = {
        name = "T1"
    }
}

-- logs --------------------------------------------------------------------------------
_G.Events = {
    [1] = {
        name = "Hirmil",
        match = "The chest of Hirmil",
        content = 1,
        instance = 1,
        tier = 1,
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