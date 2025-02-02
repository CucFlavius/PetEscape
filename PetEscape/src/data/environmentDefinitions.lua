local Game = Zee.DinoGame;
local Environment = Game.Environment;

Environment.Definitions =
{
    ["TestArea"] =
    {
        Layer0 = { },
        Layer1 = { },
        Layer2 = {
            topTexID = 188523,
            textureScale = 2,
            sideTexID = 188523,
            depthShadowIntensity = 1,
            lightRimColor = {1,1,0.5,0.3},
            depthShadowScale = 1,
        },
        Layer3 = {
            spread = 5,
            camPos = {-50, -5, 5},						-- Camera position in 3D space
            fogColor = {0.1, 0.1, 0.1},
            fogFar = 50,
            fogNear = 10,
            count = 50,
            fDefs = {
                [1] = {
                    fileID = 166046,
                    x = { -8, 0 },
                    y = { -10, 10 },
                    z = { 0.5, 2 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 5 }
                }
            },
        },
        Layer4 = {
            color = {120/256, 120/256, 180/256},
            alpha = 0.2,
            height = Game.height / 2,
        },
        Layer5 = { },
        Layer6 = {
            count = 50,		-- How many to spawn ( density )
            fDefs = {
                [1] = {
                    fileID = 188524,
                    x = { -300, 400 },
                    y = { -200, 100 },
                    w = { 100, 150 },
                    h = { 100, 100 },
                    speed = { 0.8, 1 },
                    color = { {32/256, 39/256, 23/256}, {32/256, 39/256, 23/256} },
                    alpha = 1,
                    proportional = true,
                    mask = true,
                },
            }
        },
        Layer7 = {
            color = {120/256, 120/256, 180/256},
            alpha = 1,
            height = Game.height / 2,
            texCoord = {0, 1, 0, 1},
        },
        Layer8 = {
            color = {0.2, 0.2, 0.2}
        }
    },

    ["Forest"] =
    {
        -- Foreground 0 : Closest things to the camera, that occlude the play area
        Layer0 = { },

        -- Foreground 1 : Extra detail that goes on top of the ground layer (stones, light shafts)
        Layer1 = { },

        -- Ground : Definitions for the ground textures
        Layer2 = {
            topTexID = 127784,					-- File ID of the texture that is displayed on the top side of the ground where the character sits
            sideTexID = 127784,					-- File ID of the texture that is displayed on the side of the ground, facing the screen
            textureScale = 1.6,					-- The scale of the ground texture, both top and side
            depthShadowIntensity = 1,			-- Intensity of the shadow that is drawn on the side of the ground
            depthShadowScale = 1,				-- Scale of the depth shadow
            lightRimColor = {1,1,0.5,0.3},		-- Intensity of the thin outline that is drawn at the intersection of the side and the top of the ground, alpha value is used for intensity
        },

        -- Background 3 : 3D Models that are very near the ground, but behind it
        Layer3 = {
            spread = 5,
            camPos = {-50, -5, 5},						-- Camera position in 3D space
            fogColor = {0.1, 0.1, 0.1},
            fogFar = 1000,
            fogNear = 10,
            count = 50,
            fDefs = {
                [1] = {
                    fileID = 2323113,
                    x = { -40, -10 },
                    y = { -40, 40 },
                    z = { 0, 3 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1 }
                }
            },
        },

        -- Fog 1 : Gradient - Fog layer
        Layer4 = {
            color = {13/256, 47/256, 48/256},
            alpha = 1,
            height = Game.height / 2,
        },

        -- Background 2 : Custom background detail ( like say, ocean ? )
        Layer5 = { },

        -- Background 1 : 2D layer for far away silhouettes
        Layer6 = {
            count = 50,		-- How many to spawn ( density )
            fDefs = {
                [1] = {
                    fileID = 1043765,
                    x = { -300, 400 },
                    y = { -200, 100 },
                    w = { 100, 150 },
                    h = { 100, 100 },
                    speed = { 0.8, 1 },
                    color = { {32/256, 39/256, 23/256}, {32/256, 39/256, 23/256} },
                    alpha = 1,
                    proportional = true,
                    mask = true,
                },
                --[[
                [2] = { 
                    fileID = 1659425,
                    x = { -300, 400 },
                    y = { -100, 100 },
                    w = { 50, 100 },
                    h = { 200, 200 },
                    speed = { 0.8, 1 },
                    color = { {32/256, 39/256, 23/256}, {32/256, 39/256, 23/256} },
                    alpha = 1,
                    proportional = false,
                },
                --]]
            }
        },

        -- Fog 2 : Gradient - Skybox Atmosphere
        Layer7 = {
            color = {13/256, 47/256, 48/256},
            alpha = 1,
            height = Game.height / 2,
            texCoord = {0, 1, 0, 1},
        },

        -- Background 0 : Skybox color ( simple color plane )
        Layer8 = {
            color = {114/256, 119/256, 61/256} 	-- Color of the sky
        },
    },

    ["Beach"] = {
        Layer0 = { },
        Layer1 = { },
        Layer2 = {
            topTexID = 1534179,
            textureScale = 4,
            sideTexID = 1534179,
            depthShadowIntensity = 0.5,
            lightRimColor = {1,1,0.5,0.4},
            lightRimSize = 20,
            depthShadowScale = 1,
        },
        Layer3 = {
            spread = 7,
            camPos = {-50, -5, 5},						-- Camera position in 3D space
            fogColor = {143/256, 217/256, 226/256},
            fogFar = 400,
            fogNear = 10,
            count = 10,
            fDefs = {
                [1] = {
                    fileID = 1867821,	-- ship
                    x = { 20, 100 },
                    y = { -100, 100 },
                    z = { 1 },
                    yaw = { 90 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 1 },
                    animation = "Walk",
                },
                [2] = {
                    fileID = 661374,	--- water wave
                    x = { 10, 20 },
                    y = { -100, 100 },
                    z = { 1 },
                    yaw = { 90 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.5 },
                },
                -- Palm trees FG
                [3] = {
                    fileID = 201800,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                },
                [4] = {
                    fileID = 201801,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                },
                [5] = {
                    fileID = 201802,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                },
                [6] = {
                    fileID = 201800,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                },
                [7] = {
                    fileID = 201801,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                },
                [8] = {
                    fileID = 201802,
                    x = { -10, 10 },
                    y = { -100, 100 },
                    z = { -1 },
                    yaw = { -180, 180 },
                    pitch = { 0 },
                    roll = { 0 },
                    scale = { 0.7, 1.2 },
                }
            },
        },
        Layer4 = {
            blend = "ADD",
            color = {143/256, 217/256, 226/256},
            alpha = 0.5,
            height = 30,
            offsetY = 0,
        },
        Layer5 = { },
        Layer6 = {
            zDepth = 6,		-- Swapping zDepth with layer 6 so the clouds render below skybox
            count = 10,		-- How many to spawn ( density )
            fDefs = {
                -- clouds
                [1] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { 30, 60 },
                    w = { 150, 150 },
                    h = { 40, 60 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 1,
                    texCoord = { 0, 1, 0, 0.36 },
                    proportional = false,
                    mask = false,
                },
                [2] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { 30, 60 },
                    w = { 150, 150 },
                    h = { 40, 60 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 1,
                    texCoord = { 0, 1, 0.36, 0.65 },
                    proportional = false,
                    mask = false,
                },
                [3] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { 30, 60 },
                    w = { 150, 150 },
                    h = { 40, 60 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 1,
                    texCoord = { 0, 1, 0.67, 1 },
                    proportional = false,
                    mask = false,
                },
                -- clouds reflected in water
                [4] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { -20, -25 },
                    w = { 150, 150 },
                    h = { 15, 20 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 0.2,
                    texCoord = { 0, 1, 0.36, 0 },
                    proportional = false,
                    mask = false,
                },
                [5] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { -20, -25 },
                    w = { 150, 150 },
                    h = { 15, 20 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 0.2,
                    texCoord = { 0, 1, 0.65, 0.36 },
                    proportional = false,
                    mask = false,
                },
                [6] = {
                    fileID = 1940593,
                    x = { -300, 300 },
                    y = { -20, -25 },
                    w = { 150, 150 },
                    h = { 15, 20 },
                    speed = { 0.8, 1 },
                    color = { {1,1,1}, {1,1,1} },
                    alpha = 0.2,
                    texCoord = { 0, 1, 1, 0.67 },
                    proportional = false,
                    mask = false,
                },
            }
        },

        Layer7 = {
            zDepth = 7,			-- Swapping zDepth with layer 6 so the clouds render below skybox
            blend = "ADD",
            color = {143/256, 217/256, 226/256},
            alpha = 0.8,
            height = 150,
            offsetY = 40,
        },
        Layer8 = {
            color = {49/256, 117/256, 166/256}
        }
    }
};
