local Game = Zee.DinoGame;
local LevelGenerator = Game.LevelGenerator;
local Canvas = Game.Canvas;

--------------------------------------
--  Level Generator					--
--------------------------------------

function LevelGenerator.Initialize()
    -- Create game object pool
    Game.GameObjects = {}
    for k = 1, LevelGenerator.objectPoolSize, 1 do
        LevelGenerator.CreateNewGameObject();
    end
end

function LevelGenerator.Update()
    -- determine if new puzzle should be spawned
    if Game.travelledDistance >= LevelGenerator.puzzlePosition + LevelGenerator.puzzleLength then
        LevelGenerator.puzzlePosition = Game.travelledDistance;
        LevelGenerator.SpawnPuzzle();
    end

    -- loop through all the objects, and update them
    for k = 1, LevelGenerator.totalObjects, 1 do
        if Game.GameObjects[k].active == true then
            Game.GameObjects[k].position.x = Game.GameObjects[k].position.x + (Game.speed / Game.SCENE_SYNC);
            local x1,y1,z1 = Game.GameObjects[k].actor:GetPosition();
            Game.GameObjects[k].actor:SetPosition(Game.GameObjects[k].position.z, Game.GameObjects[k].position.x * 4 / (Game.GameObjects[k].definition.scale or 1), Game.GameObjects[k].position.y);
            if Game.GameObjects[k].definition.ai ~= nil then
                Game.GameObjects[k].definition.ai.Update(Game.GameObjects[k]);
            end
            if Game.GameObjects[k].position.x > 15 then
                Game.GameObjects[k].ai = nil;
                Game.GameObjects[k].active = false;
                Game.GameObjects[k].actor:SetPosition(Game.GameObjects[k].position.z, Game.GameObjects[k].position.x * 4 / (Game.GameObjects[k].definition.scale or 1), Game.GameObjects[k].position.y);
            end
        end
    end
end

function LevelGenerator.SpawnPuzzle()
    -- local puzzles = { "1Empty", "1Crate", "4CratesLine", "4CratesTetris", "CannonTest", "RoofSlideTest", "RoofTest" };
    -- local puzzles = { "1Empty" };
    -- local puzzles = { "CoinTest", "4Empty" };
    -- local puzzles = { "RoofSlideTest" };
    local puzzles = { "ProblemWithCollision" };

    -- some puzzles for testing
    --local puzzles = { "ForestLogs1", "ForestLogs0", "1Empty", "1Crate", "4CratesLine", "4CratesTetris", "RoofSlideTest","RoofTest", "CoinTest", "RoombaL", "RoombaR" };
    local pick = floor(Game.Random() * #puzzles) + 1;
    local puzzle = Game.Puzzles[puzzles[pick]];

    if puzzle.objects ~= nil then
        for k = 1, #puzzle.objects, 1 do
            local position = { x = puzzle.objects[k].position.x - 10 - puzzle.length, y = puzzle.objects[k].position.y, z = (puzzle.objects[k].position.z or 0)  };
            --position.x = - 10;
            LevelGenerator.SpawnObject(puzzle.objects[k].dName, position)
        end
    end
    LevelGenerator.puzzleLength = puzzle.length;
end

function LevelGenerator.SpawnObject(dName, position)
    local goIndex = LevelGenerator.GetAvailableGameObject();
    Game.GameObjects[goIndex].active = true;
    local definitionName = Game.GameObjects[goIndex].defName;
    local definition = Game.ObjectDefinitions[dName];
    if dName ~= definitionName then
        Game.GameObjects[goIndex].defName = dName;
        Game.GameObjects[goIndex].definition = definition;
        definition.creature = definition.creature or false;
        if definition.creature == false then
            Game.GameObjects[goIndex].actor:SetModelByFileID(definition.id or 0);
        else
            Game.GameObjects[goIndex].actor:SetModelByCreatureDisplayID(definition.id or 0);
        end
        Game.GameObjects[goIndex].actor:SetScale(definition.scale or 1);
        Game.GameObjects[goIndex].actor:SetRoll(rad(0));
    end

    if definition.offset ~= nil then
        Game.GameObjects[goIndex].position.x = position.x + (definition.offset.x or 0);
        Game.GameObjects[goIndex].position.y = position.y + (definition.offset.y or 0);
        Game.GameObjects[goIndex].position.z = position.z + (definition.offset.z or 0);
    else
        Game.GameObjects[goIndex].position.x = position.x;
        Game.GameObjects[goIndex].position.y = position.y;
        Game.GameObjects[goIndex].position.z = position.z;
    end

    Game.GameObjects[goIndex].actor:SetYaw(rad(definition.yaw or 0));
    Game.GameObjects[goIndex].actor:SetPitch(rad(definition.pitch or 0));

    Game.GameObjects[goIndex].actor:SetAlpha(definition.alpha or 1);

    if Game.GameObjects[goIndex].definition.ai ~= nil then
        Game.GameObjects[goIndex].definition.ai.Initialize(Game.GameObjects[goIndex]);
    end
end

function LevelGenerator.GetAvailableGameObject()
    local firstAvailable = -1;
    for k = 1, LevelGenerator.totalObjects, 1 do
        if firstAvailable == -1 then
            if  Game.GameObjects[k].active == false then
                firstAvailable = k;
                break;
            end
        end
    end

    if firstAvailable ~= -1 then
        return firstAvailable;
    else
        return LevelGenerator.CreateNewGameObject();
    end
end

function LevelGenerator.CreateNewGameObject()
    LevelGenerator.totalObjects = LevelGenerator.totalObjects + 1;
    local idx = LevelGenerator.totalObjects;
    Game.GameObjects[idx] = {
        active = false,
        definition = "None",
        position = { x = 0, y = 0, z = 0 },
        actor = Canvas.mainScene:CreateActor("GameObject_" .. idx),
    }
    return idx;
end

function LevelGenerator.Clear()
    for k = 1, LevelGenerator.totalObjects, 1 do
        Game.GameObjects[k].active = false;
        Game.GameObjects[k].position.x = 100;
        Game.GameObjects[k].position.y = 100;
        Game.GameObjects[k].position.z = 0;
        Game.GameObjects[k].actor:SetPosition(Game.GameObjects[k].position.z, Game.GameObjects[k].position.x, Game.GameObjects[k].position.y);
    end
end
