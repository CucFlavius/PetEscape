local Game = Zee.DinoGame;
local AI = Game.AI;

function Game.CreateObjectDefinitions()
    Game.ObjectDefinitions =
    {
        ["Player"] =
        {
            id = 0,
            scale = 1,
            solid = false,
            danger = 0,
            collider = { x = 0, y = 0, w = 5, h = 4 },
            offset = { x = 0, y = 0 },
            ai = nil,
        },

        ["WoodenLogA0"] = {
            id = 2357607,
            scale = 4,
            solid = true,
            danger = 0,
            collider = { x = 1, y = 0, w = 3, h = 2.5 },
            offset = { x = 0, y = 0.65 },
            yaw = 90,
            pitch = 20,
            ai = nil,
        },

        ["WoodenLogA1"] = {
            id = 2357608,
            scale = 4,
            solid = true,
            danger = 0,
            collider = { x = 1, y = 0, w = 3, h = 2.5 },
            offset = { x = 0, y = 0.65 },
            yaw = 90,
            pitch = 20,
            ai = nil,
        },

        ["SideLogA"] = {
            -- id = 2357604,
            id = 2357608,
            scale = 4,
            solid = true,
            danger = 0,
            collider = { x = -6, y = 0, w = 20, h = 2.5 },
            offset = { x = 0, y = 0.65 },
        },

        ["SawBlade"] = {
            id = 2831400,
            scale = 1,
            solid = false,
            danger = 1,
            ai = { Initialize = AI.SawBladeInit, Update = AI.SawBladeUpdate },
            offset = { x = 0, y = 3.5 },
            collider = { x = 0, y = 0, w = 3, h = 3 },
        },

        ["Crate"] =
        {
            id = 2261922,
            scale = 4,
            solid = true,
            danger = 0,
            collider = { x = 0, y = 0, w = 5, h = 5 },
            offset = { x = 0, y = 0 },
            ai = nil,
        },

        ["Cannon"] =
        {
            id = 1968701,
            scale = 1.5,
            solid = true,
            danger = 0,
            collider = { x = 0, y = 0, w = 6, h = 4 },
            offset = { x = 0, y = 0 },
            ai = { Initialize = AI.CannonInit, Update = AI.CannonUpdate },
        },

        ["Cannonball"] =
        {
            id = 166129,
            scale = 5,
            solid = false,
            danger = 1,
            collider = { x = 2, y = -1, w = 2, h = 2 },
            offset = { x = 1, y = 0.5 },
            ai = { Initialize = AI.ProjectileInit, Update = AI.ProjectileUpdate },
        },

        ["CoinStatic"] =
        {
            id = 916363,
            scale = 4,
            solid = false,
            collectible = 1,
            danger = 0,
            collider = { x = 0, y = 0, w = 2, h = 2 },
            offset = { x = 0, y = 0 },
            ai = { Initialize = AI.CoinStaticInit, Update = AI.CoinStaticUpdate },
        },

        ["CoinFloaty"] =
        {
            id = 916363,
            scale = 4,
            solid = false,
            collectible = 1,
            danger = 0,
            collider = { x = 0, y = 0, w = 2, h = 2 },
            offset = { x = 0, y = 0 },
            ai = { Initialize = AI.CoinFloatyInit, Update = AI.CoinFloatyUpdate },
        },

        ["RoombaL"] =
        {
            id = 83617,
            scale = 2.5,
            creature = true,
            solid = false,
            danger = 2,
            offset = { x = 0, y = 0 },
            collider = { x = 2, y = 0, w = 3, h = 3 },
            yaw = 90,	-- decides ai walk direction 
            ai = { Initialize = AI.RoombaInit, Update = AI.RoombaUpdate },
        },

        ["RoombaR"] =
        {
            id = 83617,
            scale = 2.5,
            creature = true,
            solid = false,
            danger = 2,
            offset = { x = 0, y = 0 },
            collider = { x = 2, y = 0, w = 3, h = 3 },
            yaw = -90,	-- decides ai walk direction 
            ai = { Initialize = AI.RoombaInit, Update = AI.RoombaUpdate },
        },
    }
end