local Game = Zee.DinoGame;

function Game.CreatePuzzleData()
    Game.Puzzles =
    {
        ["1Empty"] =
        {
            length = 1,
        },

        ["4Empty"] =
        {
            length = 4,
        },

        ["RoofTest"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27 * 2, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27 * 3, y = 1.27 * 2 } },
                { dName = "CoinStatic", position = { x = 1.27 * 2, y = 5.5 } },
            },
            length = 1.27 * 4;
        },

        ["RoofSlideTest"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 1.27 } },
                { dName = "Crate", position = { x = 0, y = 1.27 * 2 } },
                { dName = "CoinStatic", position = { x = 0, y = 4.3 } },
                { dName = "Crate", position = { x = 0, y = 1.27 * 4 } },
            },
            length = 7;
        },

        ["CannonTest"] =
        {
            objects =
            {
                --{ dName = "Crate", position = { x = 0, y = 0 } },
                { dName = "Cannon", position = { x = 1.27, y = 0 } },
                --{ dName = "Crate", position = { x = 1.27 * 2, y = 0 } },
            },
            length = 3;
        },

        ["CoinTest"] =
        {
            objects =
            {
                { dName = "CoinFloaty", position = { x = 0, y = 1 } },
                { dName = "CoinFloaty", position = { x = 1, y = 1 } },
                { dName = "CoinFloaty", position = { x = 2, y = 1 } },
                { dName = "CoinFloaty", position = { x = 3, y = 1 } },
                { dName = "CoinFloaty", position = { x = 4, y = 1 } },
                { dName = "CoinFloaty", position = { x = 5, y = 1 } },
            },
            length = 6;
        },

        ["ForestTest"] =
        {
            objects =
            {
                -- { dName = "WoodenLogA0", position = { x = 0, y = 0 } },
                -- { dName = "WoodenLogA1", position = { x = 1.2, y = 0 } },
                -- { dName = "SawBlade", position = { x = 0, y = 0 } },
                -- { dName = "SideLogA", position = { x = 0, y = 0 } },
                -- { dName = "SideLogA", position = { x = 6, y = 0 } },
                { dName = "RoombaR", position = { x = 0, y = 0 } },
                { dName = "RoombaL", position = { x = 4, y = 0 } },
            },
            length = 10;
        },

        ["ForestLogs0"] =
        {
            objects =
            {
                { dName = "WoodenLogA0", position = { x = 0, y = 0 } },
            },
            length = 5,
        },

        ["ForestLogs1"] =
        {
            objects =
            {
                { dName = "WoodenLogA0", position = { x = 0, y = 0 } },
                { dName = "WoodenLogA1", position = { x = 1.2, y = 0 } },
            },
            length = 5,
        },

        ["RoombaL"] =
        {
            objects =
            {
                { dName = "RoombaL", position = { x = 4, y = 0 } },
                { dName = "CoinFloaty", position = { x = 0, y = 5 } },
                { dName = "CoinFloaty", position = { x = 1, y = 4 } },
            },
            length = 8;
        },

        ["RoombaR"] =
        {
            objects =
            {
                { dName = "RoombaL", position = { x = 4, y = 0 } },
                { dName = "CoinFloaty", position = { x = 3, y = 4 } },
                { dName = "CoinFloaty", position = { x = 4, y = 5 } },
            },
            length = 8;
        },

        ["1Crate"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 0 } },
            },
            length = 1.27,
        },

        ["4CratesLine"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 0 } },
                { dName = "Crate", position = { x = 1.27, y = 0 } },
                { dName = "Crate", position = { x = 1.27 * 2, y = 0 } },
                { dName = "Crate", position = { x = 1.27 * 3, y = 0 } },
            },
            length = 1.27 * 4 + 2;
        },

        ["4CratesTetris"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 0 } },
                { dName = "Crate", position = { x = 1.27, y = 0 } },
                { dName = "Crate", position = { x = 1.27, y = 1.24 } },
                { dName = "Crate", position = { x = 1.27 * 2, y = 0 } },
            },
            length = 1.27 * 4,
        },

        ["ProblemWithCollision"] =
        {
            objects =
            {
                { dName = "Crate", position = { x = 0, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27 * 2, y = 1.27 * 3 } },
                { dName = "Crate", position = { x = 1.27 * 3, y = 1.27 * 2 } },
                { dName = "CoinStatic", position = { x = 1.27 * 2, y = 5.5 } },
            },
            length = 1.27 * 4;
        }

    };
end