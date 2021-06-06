----------------------------------------------------------------------
-- • Title: Pet Escape									  			--
-- • Description : A mini-game designed for World of Warcraft 		--
-- • Version: 0.1 Development								  		--
-- • Contact In game: Songzee (ArgentDawn)(EU)			  			--
-- • Contact Email: cucflavius@gmail.com					  		--
-- • Some more details about the project:							--
--   The inspiration came from the small game that shows up in the	--
--   Chrome browser when your internet is down, you might see the	--
--	 name "dinogame" pop out through code here and there.			--
--   As a challenge I've set two limitations when designing it,		--
--	 the first one being to only use in game assets to create every --
--	 single graphic in the game, and the second one was to write	--
--	 all the code in a single script file (ignoring the toc file)	--
--   I wanted to make something very simple to control, with a		--
--	 single key press, mainly to reduce complexity and development	--
--	 time, but also for the chance to think about how puzzles can	--
--	 be designed around the limitation of character interaction		--
----------------------------------------------------------------------

-- Things of interest
-- TODO : Delete these
-- Interface/Common/CommonIcons.png
-- k_pagetext.ttf


--------------------------------------
--				Classes 			--
--------------------------------------
Zee = Zee or {}
Zee.DinoGame = Zee.DinoGame or {}
Zee.DinoGame.Canvas = Zee.DinoGame.Canvas or {}
Zee.DinoGame.Environment = Zee.DinoGame.Environment or {};
Zee.DinoGame.Environment.Ground = Zee.DinoGame.Environment.Ground or {};
Zee.DinoGame.Player = Zee.DinoGame.Player or {}
Zee.DinoGame.Physics = Zee.DinoGame.Physics or {}
Zee.DinoGame.LevelGenerator = Zee.DinoGame.LevelGenerator or {}
Zee.DinoGame.Cutscene = Zee.DinoGame.Cutscene or {}
Zee.DinoGame.Sound = Zee.DinoGame.Sound or {}
Zee.DinoGame.UI = Zee.DinoGame.UI or {}
Zee.DinoGame.UI.MainMenu = Zee.DinoGame.UI.MainMenu or {}
Zee.DinoGame.FX = Zee.DinoGame.FX or {}
Zee.DinoGame.FX.Text = Zee.DinoGame.FX.Text or {}
Zee.DinoGame.AI = Zee.DinoGame.AI or {}
local Game = Zee.DinoGame;
local Win = ZWindowAPI;
local Canvas = Zee.DinoGame.Canvas;
local Environment = Zee.DinoGame.Environment;
local Ground = Zee.DinoGame.Environment.Ground;
local Player = Zee.DinoGame.Player;
local Physics = Zee.DinoGame.Physics;
local LevelGenerator = Zee.DinoGame.LevelGenerator;
local Cutscene = Zee.DinoGame.Cutscene;
local Sound = Zee.DinoGame.Sound;
local UI = Zee.DinoGame.UI;
local FX = Zee.DinoGame.FX;
local AI = Zee.DinoGame.AI;
Ground = {};

--------------------------------------
--				Variables			--
--------------------------------------
Game.paused = true;
Game.over = false;
Game.speed = 2;
Game.debugStep = false;
Game.travelledDistance = 0;
Player.screenX = 160;
Player.screenY = 90;
Player.jumping = false;
Player.falling = false;
Player.canJump = true;
Player.landing = false;
Player.grounded = true;
Player.isHeldInPlace = false;
Player.jumpHold = false;
Player.jumpRelease = false;
Player.jumpEnd = false;
Player.worldPosY = 0;
Player.ground = 0;
Player.roof = 25;
Player.posX = 22;
Player.posY = 0;
Player.posZ = 0;
Player.jumpTime = 0;
Player.currentAnimation = "Run";
Player.jumpStartPosition = 0;
Player.currentJumpHeight = 0;
Player.currentLandTime = 0;
Player.jumpHeight = 0;
Player.yForce = 0;
Player.yForceDiv = 10;
LevelGenerator.puzzleLength = 0;
LevelGenerator.puzzlePosition = 0;
LevelGenerator.totalObjects = 0;
Physics.groundCollided = false;
Physics.roofCollided = false;
Cutscene.current = "None";
Cutscene.time = 0;
Game.time = 0;
Game.realTime = 0;
Game.initialized = false;

--------------------------------------
--				Settings			--
--------------------------------------
Game.devMode = true;
Game.debugNoMenu = true;
Game.UPDATE_INTERVAL = 0.02;						-- Basicly fixed delta time, represents how much time must pass before the update loops
Game.SCENE_SYNC = 23;								-- Used to synchronize the horizontal movement of the game object actors with the ground scrolling speed (Don't touch, it's gud)
Game.width = 640;									-- Window width, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.height = 300;									-- Window height, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.aspectRatio = Game.width / Game.height;
Canvas.defaultZoom = 1.5;
Canvas.defaultPan = 0;
Ground.floorOffsetY = 99;
Ground.height = 15;
Ground.textureScale = 1.6;
Ground.lightRimIntensity = 0.3;
Ground.shadowIntensity = 1;
Ground.depthShadowScale = 1;
Canvas.dinoShadowBlobY = 80;						-- The y position in screen space of the dinosaur blob shadow frame
Canvas.ceiling = 50;
Player.jumpKey = "W";
Player.jumpStartTime = 0.2;							-- The time in seconds for which to play the "JumpStart" animation before switching to "Jump" (Unused atm)
Player.jumpLandTime = 0.2;							-- The time in seconds for which to play the "JumpEnd" animation before switching to "Run" right after landing
Player.jumpLandAnimationSpeed = 1;					-- The animation speed for the character "JumpEnd" animation, playing at speed 1 feels best tbh
Player.runAnimationSpeedMultiplier = 0.7;			-- Mainly used to make the character animation not play at full Game.speed so his legs doen't look like sonic's at higher game speeds
Player.deathZone = 31;
Game.DEBUG_TrailCount = 40;
LevelGenerator.objectPoolSize = 10;

--------------------------------------
--			     Data				--
--------------------------------------
function Game.CreateObjectDefinitions()
	Game.ObjectDefinitions = 
	{
		["Player"] = 
		{
			id = 0,
			scale = 1,
			solid = false,
			danger = 0,
			collider = { x = 0, y = 0, w = 5, h = 5 },
			offset = { x = 0, y = 0 },
			ai = nil,
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
	}
end

Game.Puzzles =
{
	["1Empty"] =
	{
		objectCount = 0,
		length = 1,
	},

	["4Empty"] =
	{
		objectCount = 0,
		length = 4,
	},

	["RoofTest"] = 
	{
		objectCount = 4,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 1.27 * 3 } },
			{ dName = "Crate", position = { x = 1.27, y = 1.27 * 3 } },
			{ dName = "Crate", position = { x = 1.27 * 2, y = 1.27 * 3 } },
			{ dName = "Crate", position = { x = 1.27 * 3, y = 1.27 * 2 } },
		},
		length = 1.27 * 4;
	},

	
	["RoofSlideTest"] = 
	{
		objectCount = 4,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 1.27 } },
			{ dName = "Crate", position = { x = 0, y = 1.27 * 2 } },
			{ dName = "Crate", position = { x = 0, y = 1.27 * 3 } },
			{ dName = "Crate", position = { x = 0, y = 1.27 * 4 } },
		},
		length = 7;
	},

	["CannonTest"] = 
	{
		objectCount = 1,
		objects = 
		{ 
			--{ dName = "Crate", position = { x = 0, y = 0 } },
			{ dName = "Cannon", position = { x = 1.27, y = 0 } },
			--{ dName = "Crate", position = { x = 1.27 * 2, y = 0 } },
		},
		length = 3;
	},

	["1Crate"] = 
	{
		objectCount = 1,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 0 } },
		},
		length = 1.27,
	},

	["4CratesLine"] = 
	{
		objectCount = 4,
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
		objectCount = 4,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 0 } },
			{ dName = "Crate", position = { x = 1.27, y = 0 } },
			{ dName = "Crate", position = { x = 1.27, y = 1.24 } },
			{ dName = "Crate", position = { x = 1.27 * 2, y = 0 } },
		},
		length = 1.27 * 4,
	},
};

Game.CharacterDisplayIDs = 
{ 
	90029, -- 2459259 creature/babyraptor/babyraptor.m2
};

Game.Fonts = 
{
	"arialn",
	"frizqt__", "frizqt___cyr",
	"skurri", "skurri_cyr",
	"morpheus", "morpheus_cyr",
	"blei00d",
	"arhei", "arheiuhk_bd",
	"bkai00m",
	"2002", "2002b",
	"nim_____",
	"bhei00m", "bhei01b",
	"arkai_c", "arkai_t",
	"k_pagetext",
	"k_damage",
};

Game.FX.Symbols = 
{
	[" "] = { fileID = 0      , w = 1  , h = 1  , x =  0  , y =  0 , fw = 40 },
	["A"] = { fileID = 1084372, w = 400, h = 100, x = -31 , y =  0 , fw = 40 },
	["B"] = { fileID = 1084372, w = 450, h = 100, x =  5  , y =  0 , fw = 40 },
	["C"] = { fileID = 1084371, w = 420, h = 100, x = -73 , y =  0 , fw = 40 },
	["D"] = { fileID = 1084392, w = 410, h = 100, x = -370, y =  0 , fw = 35 },
	["E"] = { fileID = 1084371, w = 480, h = 100, x = -175, y =  0 , fw = 40 },
	["F"] = { fileID = 1084397, w = 400, h = 100, x = -120, y =  0 , fw = 30 },
	["G"] = { fileID = 1084392, w = 410, h = 100, x = -171, y =  0 , fw = 35 },
	["H"] = { fileID = 1084371, w = 400, h = 100, x = -108, y =  0 , fw = 40 },
	["I"] = { fileID = 1084384, w = 400, h = 100, x = -288 ,y =  0 , fw = 20 },
	["J"] = {},
	["K"] = { fileID = 1084373, w = 400, h = 100, x = -216 ,y =  0 , fw = 35 },
	["L"] = { fileID = 1084371, w = 450, h = 100, x = -48 , y =  0 , fw = 30 },
	["M"] = { fileID = 1084371, w = 400, h = 100, x = -180, y =  0 , fw = 50 },
	["N"] = { fileID = 1084372, w = 400, h = 100, x = -110, y =  0 , fw = 40 },
	["O"] = { fileID = 1084397, w = 400, h = 100, x = -151, y =  0 , fw = 40 },
	["P"] = { fileID = 1084419, w = 400, h = 100, x = -31 , y =  0 , fw = 35 },
	["Q"] = { fileID = 1084378, w = 400, h = 100, x = -168, y =  21, fw = 45 },
	["R"] = { fileID = 1084372, w = 420, h = 100, x = -75 , y =  0 , fw = 40 },
	["S"] = { fileID = 1084392, w = 450, h = 100, x =  5  , y =  0 , fw = 40 },
	["T"] = { fileID = 1084397, w = 450, h = 100, x =  1  , y =  0 , fw = 40 },
	["U"] = { fileID = 1084384, w = 400, h = 100, x = -30 , y =  0 , fw = 40 },
	["V"] = { fileID = 1084374, w = 440, h = 100, x = -178, y = -22, fw = 36 },
	["W"] = { fileID = 1084374, w = 400, h = 100, x = -37 , y = -22, fw = 50 },
	["X"] = { fileID = 1084385, w = 400, h = 100, x = -29 , y =  24, fw = 39 },
	["Y"] = { fileID = 1084371, w = 400, h = 100, x = -230, y =  0 , fw = 34 },
	["Z"] = {},
};

Game.EnvironmentDefinitions =
{
	["Forest"] = 
	{
		Layer0 = { }, -- Foreground 0 : Closest things to the camera, that occlude the play area
		Layer1 = { }, -- Foreground 1 : Extra detail that goes on top of the ground layer (stones, light shafts)
		Layer2 = { }, -- Ground : Definitions for the ground textures
		Layer3 = { }, -- Background 3 : 3D Models that are very near the ground, but behind it
		Layer4 = { }, -- Fog 1 : Gradient - Fog layer
		Layer5 = { }, -- Background 2 : Custom background detail ( like say, ocean ? )
		Layer6 = { }, -- Background 1 : 2D layer for far away silhouettes
		Layer7 = { }, -- Fog 2 : Gradient - Skybox Atmosphere
		Layer8 = { }, -- Background 0 : Skybox color ( simple color plane )
	},
};


--------------------------------------
--		       Game State			--
--------------------------------------
function Game.Pause()
	if Game.debugNoMenu == false then
		UI.MainMenu.frame:Show();
		UI.MainMenu.buttons[1].button:Hide();
		UI.MainMenu.buttons[3].button:Show();
	end
	Game.paused = true;
	Canvas.character:SetPaused(true);
end

function Game.Resume()
	UI.MainMenu.frame:Hide();
	Game.paused = false;
	Canvas.character:SetPaused(false);
	Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);
end

function Game.Over(died)
	Game.over = true;
	if died == true then
		Cutscene.Play("Death");
	end
end

function Game.Restart()
	Canvas.character:Show();
	Game.Resume();
	Game.over = false;
	Canvas.character:SetPosition(0, 21, 0);
	Canvas.character:SetAlpha(1);
    Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);
	LevelGenerator.Clear();

	-- I probably don't need to reset all of these...
	Player.screenX = 160;
	Player.screenY = 90;
	Player.jumping = false;
	Player.falling = false;
	Player.canJump = true;
	Player.landing = false;
	Player.grounded = true;
	Player.isHeldInPlace = false;
	Player.jumpHold = false;
	Player.jumpRelease = false;
	Player.jumpEnd = false;
	Player.worldPosY = 0;
	Player.ground = 0;
	Player.posX = 22;
	Player.jumpTime = 0;
	Player.currentAnimation = "Run";
	Player.jumpStartPosition = 0;
	Player.currentJumpHeight = 0;
	Player.currentLandTime = 0;
	Player.jumpHeight = 0;
	Player.yForce = 0;
	Player.yForceDiv = 10;
	Player.roof = Canvas.ceiling;
	Game.paused = false;
	Game.over = false;
	Game.speed = 2;
	Game.debugStep = false;
	Game.travelledDistance = 0;
	LevelGenerator.puzzleLength = 0;
	LevelGenerator.puzzlePosition = 0;
	Physics.groundCollided = false;
	Physics.roofCollided = false;
	Cutscene.current = "None";
end

function Game.NewGame()
	UI.MainMenu.frame:Hide();
	Game.Restart();
	UI.MainMenu.buttons[1].button:Hide();
	UI.MainMenu.buttons[3].button:Show();
end

function Game.Open()
	UI.Logo.scene:Show();
	UI.Logo.shadowScene:Show();
	UI.Logo.bgScene:Show();
	Game.mainWindow:Hide();
	Game.mainWindow:SetAlpha(0);
	UI.Logo.scene:SetAlpha(1);
	UI.Logo.shadowScene:SetAlpha(1);
	UI.Logo.bgScene:SetAlpha(1);
	Cutscene.Play("Logo");
	UI.MainMenu.buttons[1].button:Show();
	UI.MainMenu.buttons[3].button:Hide();
end

function Game.Exit()
	Game.Over(false);
	Game.mainWindow:Hide();
end

--------------------------------------
--          Level Generator         --
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
			x1,y1,z1 = Game.GameObjects[k].actor:GetPosition();
			Game.GameObjects[k].actor:SetPosition(x1, Game.GameObjects[k].position.x * 4 / Game.GameObjects[k].definition.scale, Game.GameObjects[k].position.y);
			if Game.GameObjects[k].definition.ai ~= nil then
				Game.GameObjects[k].definition.ai.Update(Game.GameObjects[k]);
			end
			if Game.GameObjects[k].position.x > 10 then
				Game.GameObjects[k].ai = nil;
				Game.GameObjects[k].active = false;
				Game.GameObjects[k].actor:SetPosition(0, Game.GameObjects[k].position.x * 4 / Game.GameObjects[k].definition.scale, Game.GameObjects[k].position.y);
			end
		end
	end
end

function LevelGenerator.SpawnPuzzle()
	--local puzzles = { "1Empty", "1Crate", "4CratesLine", "4CratesTetris", "CannonTest", "RoofSlideTest", "RoofTest" };
	local puzzles = { "1Empty" };
	local pick = math.floor(LevelGenerator.random() * table.getn(puzzles)) + 1;
	local puzzle = Game.Puzzles[puzzles[pick]];

	for k = 1, puzzle.objectCount, 1 do
		local position = puzzle.objects[k].position;
		position.x = -10;
		LevelGenerator.SpawnObject(puzzle.objects[k].dName, position)
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
		Game.GameObjects[goIndex].actor:SetModelByFileID(definition.id);
		Game.GameObjects[goIndex].actor:SetScale(definition.scale);
		Game.GameObjects[goIndex].actor:SetRoll(rad(0));
	end

	Game.GameObjects[goIndex].position.x = position.x + definition.offset.x;
	Game.GameObjects[goIndex].position.y = position.y + definition.offset.y;

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
		position = { x = 0, y = 0 },
		actor = Canvas.mainScene:CreateActor("GameObject_" .. idx),
	}
	return idx;
end

function LevelGenerator.Clear()
	for k = 1, LevelGenerator.totalObjects, 1 do
		Game.GameObjects[k].active = false;
		Game.GameObjects[k].position.x = 100;
		Game.GameObjects[k].position.y = 100;
		Game.GameObjects[k].actor:SetPosition(0, Game.GameObjects[k].position.x, Game.GameObjects[k].position.y);
	end
end

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function LevelGenerator.random()
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

--------------------------------------
--			       AI				--
--------------------------------------

function AI.CannonInit(gameObject)
	gameObject.currentAnimation = "Emerge";
	gameObject.ai = {};
	gameObject.ai.time = 0;
	gameObject.actor:SetAnimation(Zee.animIndex[gameObject.currentAnimation], 0, 1.5, 1);
	x,y,z = gameObject.actor:GetPosition();
	gameObject.actor:SetPosition(x - 2, y, z);
	gameObject.actor:SetYaw(rad(90));
end

function AI.CannonUpdate(gameObject)
	gameObject.ai.time = gameObject.ai.time + 1;
	local fire1 = 40;
	local fire2 = 130;
	if gameObject.ai.time == fire1 or gameObject.ai.time == fire2 then
		gameObject.currentAnimation = "SpellCastDirected";
		gameObject.actor:SetAnimation(Zee.animIndex[gameObject.currentAnimation], 0, 1.2);
	end
	if gameObject.ai.time == fire1 + 10 or gameObject.ai.time == fire2 + 10 then
		LevelGenerator.SpawnObject("Cannonball", { x = gameObject.position.x, y = gameObject.position.y });
	end
end

function AI.ProjectileInit(gameObject)
	gameObject.ai = {};
	gameObject.ai.time = 0;
end

function AI.ProjectileUpdate(gameObject)
	gameObject.ai.time = gameObject.ai.time + 1;
	x,y,z = gameObject.actor:GetPosition();
	gameObject.position.x = gameObject.position.x + 0.1;
end

--------------------------------------
--		       	Canvas				--
--------------------------------------

function Canvas.Create()
	-- Create canvas parent frame, used for clipping --
	Canvas.parentFrame = CreateFrame("Frame", "Canvas.parentFrame", Game.mainWindow);
	Canvas.parentFrame:SetWidth(Game.width);
	Canvas.parentFrame:SetHeight(Game.height);
	Canvas.parentFrame:SetPoint("CENTER", 0, 0);
	Canvas.parentFrame:SetFrameLevel(1000);
	Canvas.parentFrame:SetClipsChildren(true);

	-- Create main canvas frame --
	Canvas.frame = CreateFrame("Frame", "Canvas.frame", Canvas.parentFrame);
	Canvas.frame:SetWidth(Game.width);
	Canvas.frame:SetHeight(Game.height);
	Canvas.frame:SetFrameLevel(1);
	Canvas.frame:SetPoint("CENTER", Canvas.defaultPan * Game.width, 0);
	Canvas.frame.texture = Canvas.frame:CreateTexture("Canvas.frame_Texture","BACKGROUND")
	--Canvas.frame.texture:SetColorTexture(0.66, 0.66, 0.7, 1);
	Canvas.frame.texture:SetColorTexture(0.2, 0.2, 0.2, 1);
	Canvas.frame.texture:SetAllPoints(Canvas.frame);
	Canvas.frame:SetScale(Canvas.defaultZoom);

	-- Create graphics frames --
	Canvas.CreateMainScene();
end

function Canvas.CreateMainScene()
	-- Create main scene frame --
    Canvas.mainScene = CreateFrame("ModelScene", "Canvas.mainScene", Canvas.frame);
    Canvas.mainScene:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", 0, 0);
    Canvas.mainScene:SetSize(Game.width, Game.height);
    Canvas.mainScene:SetCameraPosition(-120, 0, 7);
	Canvas.mainScene:SetFrameLevel(101);
	Canvas.mainScene:SetCameraFarClip(1000);
	Canvas.mainScene:SetLightDirection(0.5, 1, -1);

	-- Create character actor --
    Canvas.character = Canvas.mainScene:CreateActor("character");
    Canvas.character:SetModelByCreatureDisplayID(Game.CharacterDisplayIDs[1]);
    Canvas.character:SetYaw(math.rad(-90));
	Canvas.character:SetPosition(0, 21, 0);
	Canvas.character:SetPaused(true);
	Game.PlayerObject = {}
	Game.PlayerObject.actor = Canvas.character;
	Game.PlayerObject.definition = Game.ObjectDefinitions["Player"];
	--Canvas.character:SetSpellVisualKit(144152);
	--[[
	Canvas.mainScene:SetLightVisible(false);
	local lightTest = Canvas.mainScene:CreateActor("lightTest");
	lightTest:SetModelByFileID(3257513);
	--lightTest:SetYaw(math.rad(-90));
	--lightTest:SetPosition(0, 21, 2);
	lightTest:SetPosition(0, 0, 1);
	lightTest:SetScale(10);
	lightTest:SetParticleOverrideScale(0.1);
	--]]
	-- Create character blob shadow --
	Canvas.dinoShadowBlobFrame = CreateFrame("Frame", "Canvas.dinoShadowBlobFrame", Canvas.frame);
    Canvas.dinoShadowBlobFrame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", Player.screenX, Canvas.dinoShadowBlobY);
	Canvas.dinoShadowBlobFrame:SetSize(60, 60);
	Canvas.dinoShadowBlobFrame.texture = Canvas.dinoShadowBlobFrame:CreateTexture("Canvas.dinoShadowBlobFrame_texture","BACKGROUND")
	Canvas.dinoShadowBlobFrame.texture:SetTexture(131943, "CLAMP", "CLAMP");
	Canvas.dinoShadowBlobFrame.texture:SetAllPoints(Canvas.dinoShadowBlobFrame);
	Canvas.dinoShadowBlobFrame.texture:SetTexCoord(-0.5, 1.5, -4, 4);
	Canvas.dinoShadowBlobFrame:SetFrameLevel(100);
	Canvas.dinoShadowBlobFrame:SetAlpha(0.6);
end

--------------------------------------
--		  	     UI					--
--------------------------------------

function UI.Initialize()
	-- Create main window --
	Game.mainWindow = Win.CreateWindow(0, 0, Game.width, Game.height, UIParent, "CENTER", "CENTER", true, "Pet Escape");
	Game.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect
	Game.mainWindow:SetScale(1.5);
	Game.mainWindow:Hide();

	--Game.menuWindow = Win.CreateFrame

	UI.CreateMainMenu();

	-- Create logo frames --
	UI.CreateLogo();
	UI.CreateLogoText();

	-- Run first frame of the logo animation --
	Cutscene.isPlaying = true;
	Cutscene.current = "Logo";
	Cutscene.Update();
	Cutscene.current = "None";
	Cutscene.isPlaying = false;
end

function UI.Animate()
	UI.AnimateMainMenu();
end

function UI.CreateMainMenu()
	UI.MainMenu.frame = CreateFrame("Frame", "UI.MainMenu.frame", Game.mainWindow);
	UI.MainMenu.frame:SetPoint("CENTER", Game.mainWindow, "CENTER", 0, 0);
	UI.MainMenu.frame:SetSize(Game.width, Game.height);

	UI.MainMenu.bgFrame = CreateFrame("Frame", "UI.MainMenu.bgFrame", UI.MainMenu.frame);
	UI.MainMenu.bgFrame:SetPoint("CENTER", Game.mainWindow, "CENTER", 0, 0);
	UI.MainMenu.bgFrame:SetSize(Game.height, Game.width);
	UI.MainMenu.bgFrame:SetFrameLevel(1200);
	UI.MainMenu.bgFrame.texture = UI.MainMenu.bgFrame:CreateTexture("UI.MainMenu.bgFrame.texture","BACKGROUND")
	UI.MainMenu.bgFrame.texture:SetTexture(1883578, "REPEAT", "REPEAT");
	UI.MainMenu.bgFrame.texture:SetTexCoord(0,2,0,4);
	UI.MainMenu.bgFrame.texture:SetRotation(math.rad(90));
	UI.MainMenu.bgFrame.texture:SetAllPoints(UI.MainMenu.bgFrame);

	UI.MainMenu.menuBgFrame = CreateFrame("Frame", "UI.MainMenu.menuBgFrame", UI.MainMenu.frame);
	UI.MainMenu.menuBgFrame:SetPoint("CENTER", UI.MainMenu.frame, "CENTER", 0, 0);
	UI.MainMenu.menuBgFrame:SetSize(200, 200);
	UI.MainMenu.menuBgFrame:SetFrameLevel(1200);
	UI.MainMenu.menuBgFrame.texture = UI.MainMenu.menuBgFrame:CreateTexture("UI.MainMenu.bgFrame.texture","BACKGROUND")
	UI.MainMenu.menuBgFrame.texture:SetTexture(3640932, "CLAMP", "CLAMP");
	UI.MainMenu.menuBgFrame.texture:SetTexCoord(0,0.65,0,0.575);
	--UI.MainMenu.menuBgFrame.texture:SetRotation(math.rad(-90));
	UI.MainMenu.menuBgFrame.texture:SetAllPoints(UI.MainMenu.menuBgFrame);

	UI.MainMenu.buttonsHolder = CreateFrame("Frame", "UI.MainMenu.buttonsHolder", UI.MainMenu.frame);
	UI.MainMenu.buttonsHolder:SetPoint("CENTER", UI.MainMenu.frame, "CENTER", 0, 0);
	UI.MainMenu.buttonsHolder:SetSize(200, 200);
	UI.MainMenu.buttonsHolder:SetFrameLevel(1201);
	--UI.MainMenu.buttonsHolder.texture = UI.MainMenu.buttonsHolder:CreateTexture("UI.MainMenu.buttonsHolder.texture","BACKGROUND")
	--UI.MainMenu.buttonsHolder.texture:SetColorTexture(0,0,0);
	--UI.MainMenu.buttonsHolder.texture:SetAllPoints(UI.MainMenu.buttonsHolder);

	-- Menu buttons --
	UI.MainMenu.buttons = {};
	UI.MainMenu.buttons[1] = UI.MainMenu.CreateButton("NEW GAME", UI.MainMenu.ButtonNewGame, 0, 0, 170, 20);
	UI.MainMenu.buttons[2] = UI.MainMenu.CreateButton("SETTINGS", UI.MainMenu.ButtonSettings, 0, -25, 150, 20);
	UI.MainMenu.buttons[3] = UI.MainMenu.CreateButton("RESUME", UI.MainMenu.ButtonResume, 0, 0, 125, 20);
	UI.MainMenu.buttons[3].button:Hide();
	UI.MainMenu.buttons[4] = UI.MainMenu.CreateButton("EXIT", UI.MainMenu.ButtonExit, 0, -50, 70, 20);

	-- Menu 3d asset decoration --
	UI.MainMenu.assets = {};
	UI.MainMenu.scene = CreateFrame("ModelScene", "UI.MainMenu.scene", UI.MainMenu.frame);
    UI.MainMenu.scene:SetPoint("CENTER", UI.MainMenu.frame, "CENTER", 0, 0);
    UI.MainMenu.scene:SetSize(Game.width, Game.height);
    UI.MainMenu.scene:SetCameraPosition(-10, 0, 0);
	UI.MainMenu.scene:SetFrameLevel(1201);
	UI.MainMenu.scene:SetCameraFarClip(1000);
	UI.MainMenu.scene:SetLightDirection(0.5, 1, -1);
	UI.MainMenu.scene:SetCameraFieldOfView(math.rad(90));
	--UI.CreateMainMenuFrame();
end

function UI.CreateRoundedFrame(x, y, w, h, cornerSize)
	local MF = CreateFrame("Frame", "MF", UI.MainMenu.frame); 
	MF:SetPoint("CENTER", x, y);
	MF:SetSize(w - cornerSize, h);
	MF:SetFrameLevel(1201);
	MF.texture = MF:CreateTexture("MF.texture","BACKGROUND")
	MF.texture:SetColorTexture(1, 1, 1);
	MF.texture:SetAllPoints(MF);

	local ED = CreateFrame("Frame", "ED", MF); 
	ED:SetPoint("CENTER", x, y);
	ED:SetSize(w, h - cornerSize);
	ED:SetFrameLevel(1201);
	ED.texture = ED:CreateTexture("ED.texture","BACKGROUND")
	ED.texture:SetColorTexture(1, 1, 1);
	ED.texture:SetAllPoints(ED);

	local UL = CreateFrame("Frame", "UL", MF);
	UL:SetSize(cornerSize / 2 + 1, cornerSize / 2 + 1);
	UL:SetPoint("TOPLEFT", -cornerSize / 2 - 0.5, 0.5);
	UL:SetFrameLevel(1201);
	UL.texture = UL:CreateTexture("UL.texture","BACKGROUND")
	UL.texture:SetColorTexture(1, 1, 1);
	UL.texture:SetAllPoints(UL);
	UL.mask = UL:CreateMaskTexture()
	UL.mask:SetTexture(186178, "CLAMP", "CLAMP")
	UL.mask:SetSize(cornerSize, cornerSize);
	UL.mask:SetPoint("TOPLEFT", 0, 0)
	UL.texture:AddMaskTexture(UL.mask)

	local UR = CreateFrame("Frame", "UR", MF);
	UR:SetSize(cornerSize / 2 + 1, cornerSize / 2 + 1);
	UR:SetPoint("TOPRIGHT", cornerSize / 2 + 0.5, 0.5);
	UR:SetFrameLevel(1201);
	UR.texture = UR:CreateTexture("UR.texture","BACKGROUND")
	UR.texture:SetColorTexture(1, 1, 1);
	UR.texture:SetAllPoints(UR);
	UR.mask = UR:CreateMaskTexture()
	UR.mask:SetTexture(186178, "CLAMP", "CLAMP")
	UR.mask:SetSize(cornerSize, cornerSize);
	UR.mask:SetPoint("TOPRIGHT", 0, 0)
	UR.texture:AddMaskTexture(UR.mask)

	local LL = CreateFrame("Frame", "LL", MF);
	LL:SetSize(cornerSize / 2 + 1, cornerSize / 2 + 1);
	LL:SetPoint("BOTTOMLEFT", -cornerSize / 2 - 0.5, -0.5);
	LL:SetFrameLevel(1201);
	LL.texture = LL:CreateTexture("LL.texture","BACKGROUND")
	LL.texture:SetColorTexture(1, 1, 1);
	LL.texture:SetAllPoints(LL);
	LL.mask = LL:CreateMaskTexture()
	LL.mask:SetTexture(186178, "CLAMP", "CLAMP")
	LL.mask:SetSize(cornerSize, cornerSize);
	LL.mask:SetPoint("BOTTOMLEFT", 0, 0)
	LL.texture:AddMaskTexture(LL.mask)

	local LR = CreateFrame("Frame", "LR", MF);
	LR:SetSize(cornerSize / 2 + 1, cornerSize / 2 + 1);
	LR:SetPoint("BOTTOMRIGHT", cornerSize / 2 + 0.5, -0.5);
	LR:SetFrameLevel(1201);
	LR.texture = LR:CreateTexture("LR.texture","BACKGROUND")
	LR.texture:SetColorTexture(1, 1, 1);
	LR.texture:SetAllPoints(LR);
	LR.mask = LR:CreateMaskTexture()
	LR.mask:SetTexture(186178, "CLAMP", "CLAMP")
	LR.mask:SetSize(cornerSize, cornerSize);
	LR.mask:SetPoint("BOTTOMRIGHT", 0, 0)
	LR.texture:AddMaskTexture(LR.mask)
end

function UI.CreateMainMenuFrame()
	UI.MainMenu.assets[1] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[1]");
    UI.MainMenu.assets[1]:SetModelByFileID(1013989);
    --UI.MainMenu.assets[1]:SetYaw(math.rad(0));
	UI.MainMenu.assets[1]:SetPitch(math.rad(90));
	UI.MainMenu.assets[1]:SetPosition(0, 2, 0);

	UI.MainMenu.assets[2] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[2]");
    UI.MainMenu.assets[2]:SetModelByFileID(1013989);
    --UI.MainMenu.assets[2]:SetYaw(math.rad(0));
	UI.MainMenu.assets[2]:SetPitch(math.rad(90));
	UI.MainMenu.assets[2]:SetPosition(0, -2, 0);

	UI.MainMenu.assets[3] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[3]");
    UI.MainMenu.assets[3]:SetModelByFileID(1013989);
    UI.MainMenu.assets[3]:SetRoll(math.rad(90));
	UI.MainMenu.assets[3]:SetYaw(math.rad(90));
	UI.MainMenu.assets[3]:SetPosition(0, 0, 2.5);

	UI.MainMenu.assets[4] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[4]");
    UI.MainMenu.assets[4]:SetModelByFileID(1013989);
    UI.MainMenu.assets[4]:SetRoll(math.rad(90));
	UI.MainMenu.assets[4]:SetYaw(math.rad(90));
	UI.MainMenu.assets[4]:SetPosition(0, 0, -2.5);

	UI.MainMenu.assets[5] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[5]");
    UI.MainMenu.assets[5]:SetModelByFileID(1523215);
    UI.MainMenu.assets[5]:SetRoll(math.rad(0));
	UI.MainMenu.assets[5]:SetYaw(math.rad(180));
	UI.MainMenu.assets[5]:SetPosition(-2, -4, -5.5);
	UI.MainMenu.assets[5]:SetScale(0.5);

	UI.MainMenu.assets[6] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[6]");
    UI.MainMenu.assets[6]:SetModelByFileID(1523229);
    UI.MainMenu.assets[6]:SetRoll(math.rad(0));
	UI.MainMenu.assets[6]:SetYaw(math.rad(180));
	UI.MainMenu.assets[6]:SetPosition(-2, 4, -5.5);
	UI.MainMenu.assets[6]:SetScale(0.5);
end

function UI.AnimateMainMenu()
	local x, y;
	local speed = 200;
	local ofs = 50;
	local ofs2 = 1.5;
	for b = 1, getn(UI.MainMenu.buttons), 1 do
		for i = 1, getn(UI.MainMenu.buttons[b].text), 1 do
			x, y = FX.RotatePoint(0, 1, Game.realTime * speed + (i * ofs));
			UI.MainMenu.buttons[b].text[i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(0, 0, Game.realTime * speed + (i * ofs));
			UI.MainMenu.buttons[b].text[i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(1, 1, Game.realTime * speed + (i * ofs));
			UI.MainMenu.buttons[b].text[i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(1, 0, Game.realTime * speed + (i * ofs));
			UI.MainMenu.buttons[b].text[i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
		end
	end
end

function UI.CreateLogo()
	local w = 1000;
	local h = 1000;
	UI.Logo = {}

	UI.Logo.parentFrame = CreateFrame("Frame", "UI.Logo.parentFrame", UIParent);
	UI.Logo.parentFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	UI.Logo.parentFrame:SetSize(w, h);
	UI.Logo.parentFrame:SetClipsChildren(false);

	UI.Logo.assets = {};
	UI.Logo.scene = CreateFrame("ModelScene", "UI.Logo.scene", UI.Logo.parentFrame);
    UI.Logo.scene:SetPoint("CENTER", UI.Logo.parentFrame, "CENTER", 0, 0);
	UI.Logo.scene:SetFrameStrata("MEDIUM");
    UI.Logo.scene:SetSize(w, h);
    UI.Logo.scene:SetCameraPosition(-20, 0, 0);
	UI.Logo.scene:SetFrameLevel(1200);
	UI.Logo.scene:SetCameraFarClip(5000);
	UI.Logo.scene:SetLightDirection(0.5, 1, -1);
	UI.Logo.scene:SetCameraFieldOfView(math.rad(90));
	UI.Logo.scene:SetFogFar(100);
	UI.Logo.scene:SetFogNear(20);
	UI.Logo.scene:SetFogColor(0,0,0);
	UI.Logo.scene:Hide();

	UI.Logo.shadowScene = CreateFrame("ModelScene", "UI.Logo.shadowScene", UI.Logo.parentFrame);
    UI.Logo.shadowScene:SetPoint("CENTER", UI.Logo.parentFrame, "CENTER", 0, 0);
	UI.Logo.shadowScene:SetFrameStrata("MEDIUM");
    UI.Logo.shadowScene:SetSize(w, h);
    UI.Logo.shadowScene:SetCameraPosition(-29, 0, 0);
	UI.Logo.shadowScene:SetFrameLevel(1200);
	UI.Logo.shadowScene:SetCameraFarClip(1000);
	UI.Logo.shadowScene:SetLightDirection(0.5, 1, -1);
	UI.Logo.shadowScene:SetCameraFieldOfView(math.rad(60));
	UI.Logo.shadowScene:SetLightVisible(false);
	UI.Logo.shadowScene:Hide();

	UI.Logo.bgScene = CreateFrame("ModelScene", "UI.Logo.bgScene", UI.Logo.parentFrame);
    UI.Logo.bgScene:SetPoint("CENTER", UI.Logo.parentFrame, "CENTER", 0, 0);
	UI.Logo.bgScene:SetFrameStrata("MEDIUM");
    UI.Logo.bgScene:SetSize(w, h);
    UI.Logo.bgScene:SetCameraPosition(-20, 0, 0);
	UI.Logo.bgScene:SetFrameLevel(1200);
	UI.Logo.bgScene:SetCameraFarClip(5000);
	UI.Logo.bgScene:SetLightDirection(0.5, 1, -1);
	UI.Logo.bgScene:SetCameraFieldOfView(math.rad(90));
	UI.Logo.bgScene:Hide();

	-- Left side npc
	UI.Logo.assets[1] = UI.Logo.scene:CreateActor("UI.Logo.assets[1]");
    UI.Logo.assets[1]:SetModelByCreatureDisplayID(Game.CharacterDisplayIDs[1]);
    UI.Logo.assets[1]:SetYaw(math.rad(180 - 30));
	UI.Logo.assets[1]:SetPosition(0, 0, 0);
	UI.Logo.assets[1]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[1]:SetPaused(true);

	UI.Logo.assets[-1] = UI.Logo.shadowScene:CreateActor("UI.Logo.assets[-1]");
    UI.Logo.assets[-1]:SetModelByCreatureDisplayID(Game.CharacterDisplayIDs[1]);
    UI.Logo.assets[-1]:SetYaw(math.rad(180 - 30));
	UI.Logo.assets[-1]:SetPosition(0, 0, 0);
	UI.Logo.assets[-1]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[-1]:SetPaused(true);

	-- Right side npc
	UI.Logo.assets[2] = UI.Logo.scene:CreateActor("UI.Logo.assets[2]");
    UI.Logo.assets[2]:SetModelByCreatureDisplayID(16259);
    UI.Logo.assets[2]:SetYaw(math.rad(180 + 30));
	UI.Logo.assets[2]:SetPosition(0, 0, 0);
	UI.Logo.assets[2]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[2]:SetPaused(true);
	UI.Logo.assets[2]:SetScale(2);

	UI.Logo.assets[-2] = UI.Logo.shadowScene:CreateActor("UI.Logo.assets[-2]");
    UI.Logo.assets[-2]:SetModelByCreatureDisplayID(16259);
    UI.Logo.assets[-2]:SetYaw(math.rad(180 + 30));
	UI.Logo.assets[-2]:SetPosition(0, 0, 0);
	UI.Logo.assets[-2]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[-2]:SetPaused(true);
	UI.Logo.assets[-2]:SetScale(2);

	-- Monster npc
	UI.Logo.assets[3] = UI.Logo.scene:CreateActor("UI.Logo.assets[3]");
    UI.Logo.assets[3]:SetModelByCreatureDisplayID(378);
    UI.Logo.assets[3]:SetYaw(math.rad(180));
	UI.Logo.assets[3]:SetPitch(math.rad(-10));
	UI.Logo.assets[3]:SetPosition(0, 0, 0);
	UI.Logo.assets[3]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[3]:SetPaused(true);
	UI.Logo.assets[3]:SetScale(4);

	UI.Logo.assets[-3] = UI.Logo.shadowScene:CreateActor("UI.Logo.assets[-3]");
    UI.Logo.assets[-3]:SetModelByCreatureDisplayID(378);
    UI.Logo.assets[-3]:SetYaw(math.rad(180));
	UI.Logo.assets[-3]:SetPitch(math.rad(-10));
	UI.Logo.assets[-3]:SetPosition(0, 0, 0);
	UI.Logo.assets[-3]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[-3]:SetPaused(true);
	UI.Logo.assets[-3]:SetScale(4);

	-- Center npc
	UI.Logo.assets[4] = UI.Logo.scene:CreateActor("UI.Logo.assets[4]");
    UI.Logo.assets[4]:SetModelByCreatureDisplayID(87401);
	UI.Logo.assets[4]:SetYaw(math.rad(180));
	UI.Logo.assets[4]:SetPosition(0, 0, 0);
	UI.Logo.assets[4]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[4]:SetPaused(true);
	UI.Logo.assets[4]:SetScale(1.5);

	UI.Logo.assets[-4] = UI.Logo.shadowScene:CreateActor("UI.Logo.assets[-4]");
    UI.Logo.assets[-4]:SetModelByCreatureDisplayID(87401);
    UI.Logo.assets[-4]:SetYaw(math.rad(180));
	UI.Logo.assets[-4]:SetPosition(0, 0, 0);
	UI.Logo.assets[-4]:SetAnimation(Zee.animIndex["Run"]);
	UI.Logo.assets[-4]:SetPaused(true);
	UI.Logo.assets[-4]:SetScale(1.5);

	-- Mist fx
	--[[
	UI.Logo.assets[5] = UI.Logo.scene:CreateActor("UI.Logo.assets[5]");
    UI.Logo.assets[5]:SetModelByFileID(1777475);
    --UI.Logo.assets[-5]:SetYaw(math.rad(180));
	UI.Logo.assets[5]:SetPosition(20, 0, -8);
	--UI.Logo.assets[-5]:SetAnimation(Zee.animIndex["Stand"]);
	UI.Logo.assets[5]:SetPaused(true);
	UI.Logo.assets[5]:SetScale(0.3);
	--]]
	-- Clouds
	UI.Logo.assets[6] = UI.Logo.bgScene:CreateActor("UI.Logo.assets[6]");
    UI.Logo.assets[6]:SetModelByFileID(394984);
	UI.Logo.assets[6]:SetYaw(math.rad(90));
	UI.Logo.assets[6]:SetPosition(0, -0.3, -0.1);
	UI.Logo.assets[6]:SetAnimation(Zee.animIndex["Stand"], 0, 0.1);
	UI.Logo.assets[6]:SetScale(3);

end

function UI.CreateLogoText()
	UI.Logo.Text = {}
	UI.Logo.TextHolder = CreateFrame("Frame", "UI.Logo.TextHolder", UI.Logo.scene);
	UI.Logo.TextHolder:SetPoint("CENTER", UI.Logo.scene, "CENTER", -30, -100);
	UI.Logo.TextHolder:SetFrameStrata("HIGH");
	UI.Logo.TextHolder:SetFrameLevel(1000);
    UI.Logo.TextHolder:SetSize(1000, 1000);
	UI.Logo.Text[1] = FX.Text.CreateWord("PET", 0, 0, UI.Logo.TextHolder, 0.8, 1, 1, 1, 1);
	UI.Logo.Text[2] = FX.Text.CreateWord("ESCAPE", -45, -40, UI.Logo.TextHolder, 0.8, 1, 1, 1, 1);
	UI.Logo.Text[-1] = FX.Text.CreateWord("PET", 0, 0, UI.Logo.TextHolder, 0.8, 1.1, 0, 0, 0);
	UI.Logo.Text[-2] = FX.Text.CreateWord("ESCAPE", -45, -40, UI.Logo.TextHolder, 0.8, 1.1, 0, 0, 0);
	UI.Logo.TextHolder:SetScale(1);
end

function UI.MainMenu.CreateButton(name, action, x, y, w, h)
	local btn = {};
	btn.button = CreateFrame("Frame", "btn.button_" .. name, UI.MainMenu.buttonsHolder);
	btn.button:SetPoint("CENTER", UI.MainMenu.buttonsHolder, "CENTER", x, y);
	btn.button:SetSize(w, h);
	btn.button:SetFrameLevel(1201);
	btn.button:EnableMouse();
	--btn.texture = btn.button:CreateTexture("btn.texture","BACKGROUND");
	--btn.texture:SetColorTexture(0,0,0, 0.1);
	--btn.texture:SetAllPoints(btn.button);
	btn.button:SetScript('OnMouseUp', action);
	btn.button:SetScript('OnEnter', function() btn.button:SetFrameLevel(1202) btn.button:SetScale(2) btn.button:SetPoint("CENTER", UI.MainMenu.buttonsHolder, "CENTER", x, y / 2) end);
	btn.button:SetScript('OnLeave', function() btn.button:SetFrameLevel(1201) btn.button:SetScale(1) btn.button:SetPoint("CENTER", UI.MainMenu.buttonsHolder, "CENTER", x, y) end);
	btn.text = FX.Text.CreateWord(name, 0, 0, btn.button , 1, 0.5, 1, 1, 1, "LEFT");
	btn.shadowText = FX.Text.CreateWord(name, 0, 0, btn.button , 1, 0.5, 0, 0, 0, "LEFT");
	return btn;
end

function UI.MainMenu.ButtonNewGame()
	if Game.initialized == true then
		Cutscene.Play("NewGame");
	end
end

function UI.MainMenu.ButtonSettings()
	if Game.initialized == true then
		print("Open Settings");
	end
end

function UI.MainMenu.ButtonResume()
	if Game.initialized == true then
		Game.Resume();
	end
end

function UI.MainMenu.ButtonExit()
	if Game.initialized == true then
		Game.Exit();
	end
end

--------------------------------------
--              Sound               --
--------------------------------------

function Sound.Update()
	--[[
	pos = pos + 1;
	if pos == 1 then
		willPlay, soundHandle = PlaySoundFile(537914, "Master");
	end
	if pos == 6 then
		StopSound(soundHandle, 0);
		pos = 0;
	end
	-]]
end

--------------------------------------
--             Cutscene             --
--------------------------------------

function Cutscene.Play(name)
	Cutscene.current = name;
	Cutscene.isPlaying = true;
	Cutscene.time = 0;
end

function Cutscene.Stop()
	Cutscene.current = "None";
	Cutscene.isPlaying = false;
end

function Cutscene.Update()
	if Cutscene.isPlaying == true then
		if Cutscene.current == "Death" then
			Cutscene.time = Cutscene.time + 1;
			if Cutscene.time == 1 then
				Player.posX, Player.posY, Player.posZ = Canvas.character:GetPosition();
				Player.SetAnimation("CombatWound", 2);
			elseif Cutscene.time == 20 then
				Canvas.character:SetPaused(true);
			end
			if Cutscene.time > 30 and Cutscene.time < 200 then
				-- Animate character going up and then down, falling off the screen
				-- I know at least a dozen games that do this, time to pay homage ;)
				Canvas.character:SetPosition(Player.posX - ((Cutscene.time - 30) / 10), Player.posY - ((Cutscene.time - 30) / 10), Player.posZ + (sin((Cutscene.time - 30) * 2) * 15) - ((Cutscene.time - 30) / 10));
			elseif Cutscene.time == 200 then
				-- Animation complete, hide the character actor, stop the cutscene and open the game over UI
				Canvas.character:Hide();
				Cutscene.Stop();

				Game.Restart(); -- Just restarting the game for now, UI is the last thing I'll mess with
			end
		elseif Cutscene.current == "Logo" then
			if UI.Logo ~= nil then
				Cutscene.time = Cutscene.time + 1;

				if Cutscene.time <= 130 then
					local scale = max(0.01, sin(Cutscene.time) * 1.1);
					UI.Logo.scene:SetScale(scale);
					UI.Logo.shadowScene:SetScale(scale);
					UI.Logo.bgScene:SetScale(scale);
				end

				if Cutscene.time <= 190 then
					local ofs2 = max(0.7, Cutscene.time / 180);
					local scale = sin((Cutscene.time + 30) * ofs2) * 1.4;
					scale = max(1, scale);

					UI.Logo.TextHolder:SetScale(scale + 0.3);
				end

				if Cutscene.time <= 320 then
					local x, y;
					local speed = 200;
					local ofs = 50;
					local ofs2 = 1.5;
					for i = 1, table.getn(UI.Logo.Text[1]), 1 do
						x, y = FX.RotatePoint(0, 1, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[1][i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
						UI.Logo.Text[-1][i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(0, 0, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[1][i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
						UI.Logo.Text[-1][i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(1, 1, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[1][i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
						UI.Logo.Text[-1][i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(1, 0, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[1][i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
						UI.Logo.Text[-1][i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
					end

					for i = 1, table.getn(UI.Logo.Text[2]), 1 do
						x, y = FX.RotatePoint(0, 1, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[2][i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
						UI.Logo.Text[-2][i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(0, 0, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[2][i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
						UI.Logo.Text[-2][i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(1, 1, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[2][i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
						UI.Logo.Text[-2][i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
						x, y = FX.RotatePoint(1, 0, Game.realTime * speed + (i * ofs));
						UI.Logo.Text[2][i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
						UI.Logo.Text[-2][i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
					end
				end

				local offs1 = 150;
				if Cutscene.time <= 240 + offs1 then
					--local playSpeed = (2 - (Cutscene.time / 60)) * 2;
					local frame = (sin(((Cutscene.time - offs1) / 2) * math.pi / 4) + 1) / 2;
					local posOffs = 2;
					local hOffs = -1;

					-- Left side npc
					local scale1 = UI.Logo.assets[1]:GetScale();
					UI.Logo.assets[1]:SetPaused(true);
					UI.Logo.assets[-1]:SetPaused(true);
					UI.Logo.assets[1]:SetAnimation(Zee.animIndex["AttackUnarmed"], 0, 1, frame / 4 - 0.1);
					UI.Logo.assets[-1]:SetAnimation(Zee.animIndex["AttackUnarmed"], 0, 1, frame / 4 - 0.1);
					UI.Logo.assets[1]:SetPosition(frame / scale1, (frame + posOffs) / scale1, -2 / scale1 + hOffs);
					UI.Logo.assets[-1]:SetPosition(frame / scale1, (frame + posOffs) / scale1, -2 / scale1 + hOffs);

					-- Right side npc
					local scale2 = UI.Logo.assets[2]:GetScale();
					UI.Logo.assets[2]:SetPaused(true);
					UI.Logo.assets[-2]:SetPaused(true);
					UI.Logo.assets[2]:SetAnimation(Zee.animIndex["AttackUnarmed"], 2, 1, frame / 4 - 0.1);
					UI.Logo.assets[-2]:SetAnimation(Zee.animIndex["AttackUnarmed"], 2, 1, frame / 4 - 0.1);
					UI.Logo.assets[2]:SetPosition(frame / scale2, (-posOffs - frame) / scale2, (-2 + hOffs)/ scale2);
					UI.Logo.assets[-2]:SetPosition(frame / scale2, (-posOffs - frame) / scale2, (-2 + hOffs) / scale2);

					-- Monster npc
					local scale3 = UI.Logo.assets[3]:GetScale();
					UI.Logo.assets[3]:SetPaused(true);
					UI.Logo.assets[-3]:SetPaused(true);
					UI.Logo.assets[3]:SetAnimation(Zee.animIndex["Run"], 2, 1, frame / 4);
					UI.Logo.assets[-3]:SetAnimation(Zee.animIndex["Run"], 2, 1, frame / 4);
					UI.Logo.assets[3]:SetPosition(frame / scale3 + 4, 1 / scale3, hOffs);
					UI.Logo.assets[-3]:SetPosition(frame / scale3 + 4, 1 / scale3, hOffs);

					-- Center npc
					local scale4 = UI.Logo.assets[4]:GetScale();
					UI.Logo.assets[4]:SetPaused(true);
					UI.Logo.assets[-4]:SetPaused(true);
					UI.Logo.assets[4]:SetAnimation(Zee.animIndex["Run"], 2, 1, frame / 4);
					UI.Logo.assets[-4]:SetAnimation(Zee.animIndex["Run"], 2, 1, frame / 4);
					UI.Logo.assets[4]:SetPosition(frame / scale4 - 4, 0, -1 + hOffs);
					UI.Logo.assets[-4]:SetPosition(frame / scale4 - 4, 0, -1.2 + hOffs);
				end

				local cutsceneBlendTime = 350;
				local cutsceneBlendSpeed = 0.05;
				if Cutscene.time >= cutsceneBlendTime then

					Game.mainWindow:Show();
					local alpha = (Cutscene.time - cutsceneBlendTime) * cutsceneBlendSpeed;
					Game.mainWindow:SetAlpha(alpha);
					UI.Logo.scene:SetAlpha(1 - alpha);
					UI.Logo.shadowScene:SetAlpha(1 - alpha);
					UI.Logo.bgScene:SetAlpha(1 - alpha);
				end

				if Cutscene.time >= 400 then
					Cutscene.Stop();
					Game.mainWindow:SetAlpha(1);
					UI.Logo.scene:Hide();
					UI.Logo.shadowScene:Hide();
					UI.Logo.bgScene:Hide();
				end
			end
		elseif Cutscene.current == "NewGame" then
			-- TODO --

			Game.NewGame();
			Cutscene.Stop();
		end
	end
end

function FX.RotatePoint(cx, cy, angle)
	local s = sin(angle);
	local c = cos(angle);

	local p = { x = 1, y = 1 };

	-- translate point back to origin:
	p.x = p.x - cx;
	p.y = p.y - cy;

	-- rotate point
	local xnew = p.x * c - p.y * s;
	local ynew = p.x * s + p.y * c;

	-- translate point back:
	p.x = xnew + cx;
	p.y = ynew + cy;
	return p.x, p.y;
end

--------------------------------------
--			    Effects				--
--------------------------------------

function FX.Text.CreateSymbol(symbol, x, y, parent, scale, r, g, b, point)
	local sInfo = Game.FX.Symbols[symbol];
	local s = {};
	s = CreateFrame("Frame", "TextTestA", parent);
	s:SetWidth(sInfo.fw);
	s:SetHeight(40);
	s:SetScale(scale);
	s:SetPoint(point, x, y);
	s.texture = s:CreateTexture("s","BACKGROUND")
	s.texture:SetColorTexture(r, g, b);
	s.texture:SetAllPoints(s);
	s.mask = s:CreateMaskTexture()
	s.mask:SetTexture(sInfo.fileID, "CLAMP", "CLAMP")
	s.mask:SetSize(sInfo.w, sInfo.h);
	s.mask:SetPoint("LEFT", sInfo.x, sInfo.y)
	s.texture:AddMaskTexture(s.mask)
	return s;
end

function FX.Text.CreateWord(word, x, y, parent, spacing, scale, r, g, b, point)
	if r == nil then r = 1 end
	if g == nil then g = 1 end
	if b == nil then b = 1 end
	if spacing == nil then spacing = 0.8 end
	if scale == nil then scale = 1 end
	if point == nil then point = "CENTER" end;

	local length = strlen(word);
	local w = {};
	local offs = 0;
	for	i = 1, length, 1 do
		local char = string.sub(word, i, i);
		w[i] = FX.Text.CreateSymbol(char, x + offs, y, parent, scale, r, g, b, point);
		offs = offs + Game.FX.Symbols[char].fw * spacing;
	end

	return w;
end

--------------------------------------
--		  	  DEBUGGING				--
--------------------------------------

function Canvas.DEBUG_CreateCaracterTrails()
	Canvas.DEBUG_Trails = {};
	local offs = 0;
	local size = 0.8;
	for k = 1, Game.DEBUG_TrailCount, 1 do
		offs = offs - Game.speed;
		Canvas.DEBUG_Trails[k] = {}
		Canvas.DEBUG_Trails[k].x = offs + Player.screenX + 30;
		Canvas.DEBUG_Trails[k].y = 0 + Player.screenY;
		Canvas.DEBUG_Trails[k].frame = CreateFrame("Frame", "Canvas.DEBUG_CharPathFrame", Canvas.frame);
		Canvas.DEBUG_Trails[k].frame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", Canvas.DEBUG_Trails[k].x, Canvas.DEBUG_Trails[k].y);
		Canvas.DEBUG_Trails[k].frame:SetSize(size, size);
		Canvas.DEBUG_Trails[k].frame:SetFrameLevel(100);
		Canvas.DEBUG_Trails[k].frame.texture = Canvas.DEBUG_Trails[k].frame:CreateTexture("Ground.floorBrightnessFrame_texture","BACKGROUND")
		Canvas.DEBUG_Trails[k].frame.texture:SetColorTexture(0.9,0.9,1, 0.8);
		Canvas.DEBUG_Trails[k].frame.texture:SetAllPoints(Canvas.DEBUG_Trails[k].frame);
		Canvas.DEBUG_Trails[k].frame:Show();
	end
end

function Canvas.DEBUG_UpdateCharacterTrails()
	local offs = 0;
	for k = Game.DEBUG_TrailCount, 1, -1 do
		offs = offs + Game.speed;
		if k == 1 then
			Canvas.DEBUG_Trails[k].y = Player.worldPosY * 5 + Player.screenY + 30;
		else
			Canvas.DEBUG_Trails[k].y = Canvas.DEBUG_Trails[k - 1].y;
		end

		Canvas.DEBUG_Trails[k].x = offs + (-Player.posX * 7.2) + 250;
		Canvas.DEBUG_Trails[k].frame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", Canvas.DEBUG_Trails[k].x , Canvas.DEBUG_Trails[k].y);
	end
end

function Physics.DEBUG_CreateColliderFrames() 
	Physics.tempFrame = CreateFrame("Frame", "Physics.tempFrame", Canvas.frame);
	Physics.tempFrame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", 0, 0);
	Physics.tempFrame:SetSize(Game.ObjectDefinitions["Crate"].collider.w, Game.ObjectDefinitions["Crate"].collider.h);
	Physics.tempFrame:SetFrameLevel(1000);
	Physics.tempFrame.texture = Physics.tempFrame:CreateTexture("Physics.tempFrame_texture","BACKGROUND")
	Physics.tempFrame.texture:SetColorTexture(0.9,0.9,1, 0.8);
	Physics.tempFrame.texture:SetAllPoints(Physics.tempFrame);
	Physics.tempFrame:Show();
end

function Physics.DEBUG_UpdateColliderFrames()
	local x, y, z = Canvas.TestObject:GetPosition();
	local X, Y, Z = Canvas.mainScene:Project3DPointTo2D(x, y, z);
	Physics.tempFrame:SetPoint("LEFT", Canvas.frame, "LEFT", 1000 -X, 0);
end

function Game.DEBUG_StepForward()
	Game.debugStep = true;
end

--------------------------------------
--			PLayer Input			--
--------------------------------------

function Player.KeyPress(self, key)
    if key == Player.jumpKey then

		if Game.debugNoMenu == true and Game.paused == true then
			Game.Resume();
			Player.inputFrame:SetPropagateKeyboardInput(false);
			return;
		end

		if Player.jumpHold == false and Player.canJump == true then
			Player.jumpHold = true;
			Player.jumpEnd = false;
		end

		Player.inputFrame:SetPropagateKeyboardInput(false);

		if Player.canJump == true and Game.over == false then
			Player.jumpStartPosition = Player.worldPosY;
			Player.inputFrame:SetPropagateKeyboardInput(false);
			Player.jumping = true;
			Player.CurrentLandTime = 0;
			Player.landing = false;

			if Player.currentAnimation ~= "JumpStart" then
				Player.SetAnimation("JumpStart", 1);
			end
		end

    elseif key == "ESCAPE" then
		Player.inputFrame:SetPropagateKeyboardInput(false);
		if Game.paused == false then
			Game.Pause();
		else
			Player.inputFrame:SetPropagateKeyboardInput(true);
		end
	elseif key == "RIGHT" then
		if Game.devMode then
			Player.inputFrame:SetPropagateKeyboardInput(false);
			Game.DEBUG_StepForward();
		end
	end
end

function Player.KeyRelease(self, key)
    if key == Player.jumpKey then
		Player.jumpHold = false;
		Player.jumpEnd = true;
    end
	self:SetPropagateKeyboardInput(true);
end

function Game.CreatePlayerInputFrame()
	Player.inputFrame = CreateFrame("Frame", nil, UIParent);
	Player.inputFrame:EnableKeyboard(true);
	Player.inputFrame:SetPropagateKeyboardInput(true);
	Player.inputFrame:SetScript("OnKeyDown", Player.KeyPress);
	Player.inputFrame:SetScript("OnKeyUp", Player.KeyRelease);
end

--------------------------------------
--		Character Animations		--
--------------------------------------

function Player.UpdateBlobShadow()
	local scale = (Player.worldPosY / 10 * 0.8);
	Canvas.dinoShadowBlobFrame:SetAlpha(0.6 * (1 - scale));
	Canvas.dinoShadowBlobFrame:SetSize(60 + (60 * scale), 60 + (60 * scale));
	local screenPos =  ((1 - ((Player.posX / 12) - 2)) + 1) * 80 - (Player.posX / 5) - 10;	-- TODO : format brain, or just calculate modelscene->screen position for real next time
	Canvas.dinoShadowBlobFrame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", screenPos, Canvas.dinoShadowBlobY - (25 * scale));
end

function Player.CalculateJumpVelocity()
	local distance = Player.worldPosY / Player.CurrentJumpHeight;
	local val =  sin((1 - distance) * math.pi * 0.9) * 50 + 0.01;
	--Player.jumpTime = Player.jumpTime + distance;--(Game.UPDATE_INTERVAL * 5);
	val = max(val , 0);
	--[[
	if Player.CurrentJumpHeight > Player.SmallJumpHeight then
		return val * 0.5;
	else
		return val * 0.9;
	end
	--]]
	return val;
end

function Player.CalculateFallVelocity()
	local distance = Player.worldPosY / Player.CurrentJumpHeight;
	local val = (sin((1 - distance) * math.pi * 2) * 50 + 0.01);
	--Player.jumpTime = Player.jumpTime - distance;--(Game.UPDATE_INTERVAL * 5);
	val = max(val , 0);
    --return val * 1.7;
	return val;
end

function Player.SetAnimation(name, speed)
	Player.currentAnimation = name;
	Canvas.character:SetAnimation(Zee.animIndex[name], 0, speed);
end

--------------------------------------
--			Environment				--
--------------------------------------

function Environment.Create()
	Environment.CreateLayer2_Ground();

	--[[
	-- Create background color --
	Environment.BGColor = CreateFrame("Frame", "Environment.BGColor", Canvas.frame);
	Environment.BGColor:SetWidth(Game.width);
	Environment.BGColor:SetHeight(Game.height);
	Environment.BGColor:SetPoint("BOTTOM", 0, 0);
	Environment.BGColor.texture = Environment.BGColor:CreateTexture("Environment.BGColor_texture","BACKGROUND")
	Environment.BGColor.texture:SetColorTexture(114/256, 119/256, 61/256);
	Environment.BGColor.texture:SetAllPoints(Environment.BGColor);
	Environment.BGColor:SetFrameLevel(5);

	-- Create far background --
    Environment.BGScene0 = CreateFrame("ModelScene", "Environment.BGScene0", Canvas.parentFrame);
	Environment.BGScene0:SetPoint("CENTER", Canvas.parentFrame, "CENTER", 0, 0);
    Environment.BGScene0:SetSize(Game.width, Game.height);
    Environment.BGScene0:SetCameraPosition(-50, -5, 5);
	Environment.BGScene0:SetFrameLevel(10);

	Environment.BGScene0:SetFogColor(32/256, 39/256, 23/256);
	Environment.BGScene0:SetFogFar(50);
	Environment.BGScene0:SetFogNear(10);
	Environment.BGScene0:SetCameraFarClip(1000);

	Environment.actors0 = {};
	for k = 1, 10, 1 do
		Environment.actors0[k] = {};
		Environment.actors0[k].frame = Environment.BGScene0:CreateActor("BGScene0.actor_" .. k);
		Environment.actors0[k].frame:SetModelByFileID(2323113);
		Environment.actors0[k].frame:SetYaw(math.rad(math.random() * 180));
		Environment.actors0[k].frame:SetScale((max (math.random(), 0.7) * 1.5));
		local dist = min((math.random() - 0.5) * 150 + 100, 200);
		Environment.actors0[k].positionX = min((math.random() - 0.5) * 120 + 80, 200);
		Environment.actors0[k].positionY = (math.random() - 0.5) * 160;
		Environment.actors0[k].positionZ = (min(math.random(), 0.1)) * 10 - (dist / 10);
	end

	-- Create near background --
	Environment.BGScene1 = CreateFrame("ModelScene", "Environment.BGScene1", Canvas.parentFrame);
	Environment.BGScene1:SetPoint("CENTER", Canvas.parentFrame, "CENTER", 0, 0);
    Environment.BGScene1:SetSize(Game.width, Game.height);
    Environment.BGScene1:SetCameraPosition(-50, -5, 5);
	Environment.BGScene1:SetFrameLevel(20);

	Environment.BGScene1:SetFogColor(0.1, 0.1, 0.1);
	Environment.BGScene1:SetFogFar(50);
	Environment.BGScene1:SetFogNear(10);
	Environment.BGScene1:SetCameraFarClip(1000);

	Environment.actors1 = {};
	for k = 1, 5, 1 do
		Environment.actors1[k] = {};
		Environment.actors1[k].frame = Environment.BGScene1:CreateActor("BGScene1.actor_" .. k);
		Environment.actors1[k].frame:SetModelByFileID(2323113);
		Environment.actors1[k].frame:SetYaw(math.rad(math.random() * 180));
		Environment.actors1[k].frame:SetScale((max (math.random(), 0.7)));
		Environment.actors1[k].positionX = min((math.random() - 0.5) * 20 - 30, 200);
		Environment.actors1[k].positionY = (math.random() - 0.5) * 100;
		Environment.actors1[k].positionZ = (min(math.random(), 0.3)) * 10;
	end

	-- Create vertical fogs --
	Environment.VFogNear = CreateFrame("Frame", "Environment.VFogNear", Canvas.frame);
	Environment.VFogNear:SetWidth(Game.width);
	Environment.VFogNear:SetHeight(Game.height / 2);
	Environment.VFogNear:SetPoint("BOTTOM", 0, Ground.floorOffsetY);
	Environment.VFogNear.texture = Environment.VFogNear:CreateTexture("Environment.VFogNear_texture","BACKGROUND")
	Environment.VFogNear.texture:SetTexture(621343, "CLAMP", "CLAMP");
	Environment.VFogNear.texture:SetAllPoints(Environment.VFogNear);
	Environment.VFogNear.texture:SetTexCoord(0, 1, 0, 1);
	Environment.VFogNear.texture:SetVertexColor(13/256, 47/256, 48/256, 1);
	Environment.VFogNear.texture:SetBlendMode("BLEND");
	Environment.VFogNear:SetFrameLevel(15);

	Environment.VFogFar = CreateFrame("Frame", "Environment.VFogFar", Canvas.frame);
	Environment.VFogFar:SetWidth(Game.width);
	Environment.VFogFar:SetHeight(Game.height / 2);
	Environment.VFogFar:SetPoint("BOTTOM", 0, Ground.floorOffsetY);
	Environment.VFogFar.texture = Environment.VFogFar:CreateTexture("Environment.VFogFar_texture","BACKGROUND")
	Environment.VFogFar.texture:SetTexture(621343, "CLAMP", "CLAMP");
	Environment.VFogFar.texture:SetAllPoints(Environment.VFogFar);
	Environment.VFogFar.texture:SetTexCoord(0, 1, 0, 1);
	Environment.VFogFar.texture:SetVertexColor(13/256, 47/256, 48/256, 1);
	--Environment.VFogFar.texture:SetBlendMode("BLEND");
	Environment.VFogFar:SetFrameLevel(8);
	--]]
end

function Environment.Update()
	Environment.UpdateLayer2_Ground();
	--[[
	for k = 1, 10, 1 do
		Environment.actors0[k].positionY = Environment.actors0[k].positionY + (Game.speed / 50);
		Environment.actors0[k].frame:SetPosition(Environment.actors0[k].positionX, Environment.actors0[k].positionY, Environment.actors0[k].positionZ);
		if Environment.actors0[k].positionY >= 90 then
			Environment.actors0[k].positionY = -90;
		end
	end

	for k = 1, 5, 1 do
		Environment.actors1[k].positionY = Environment.actors1[k].positionY + (Game.speed / 50);
		Environment.actors1[k].frame:SetPosition(Environment.actors1[k].positionX, Environment.actors1[k].positionY, Environment.actors1[k].positionZ);
		if Environment.actors1[k].positionY >= 50 then
			Environment.actors1[k].positionY = -50;
		end
	end
	--]]
end

function Environment.CreateLayer2_Ground()
    Ground.floorFrames = {}
	Ground.floorEffectFrames = {}
	-- Create the floor frames --
	for k = 1, Ground.height, 1 do
		Ground.floorFrames[k] = Environment.CreateFrame("Ground.floorFrame_" .. k, 0, k - 1 + Ground.floorOffsetY, Game.width, 1, "BOTTOM", 50, 127784, "REPEAT");
		Ground.floorEffectFrames[k] = Environment.CreateFrame("Ground.floorEffectFrame_" .. k, 0, k - 1 + Ground.floorOffsetY, Game.width, 1, "BOTTOM", 51, 3221839, "REPEAT", nil, {1,1,0.5,0.5});
	end	

	Ground.fgFloorFrame = Environment.CreateFrame("Ground.fgFloorFrame", 0, 0, Game.width, Ground.floorOffsetY, "BOTTOM", 50, 127784, "REPEAT")
	Ground.depthShadow = Environment.CreateFrame("Ground.depthShadow", 0, 0, Game.width, Ground.floorOffsetY * Ground.depthShadowScale, "BOTTOM", 51, 131963, "CLAMP", {1,0,1,0}, nil, Ground.shadowIntensity);
	Ground.depthShadow2 = Environment.CreateFrame("Ground.depthShadow2", 0, 0, Game.width, Ground.floorOffsetY * Ground.depthShadowScale, "BOTTOM", 51, 131963, "CLAMP", {1,0,1,0}, nil, Ground.shadowIntensity, "BLEND");
	Ground.rimLightTop = Environment.CreateFrame("Ground.rimLightTop", 0, Ground.floorOffsetY, Game.width, Ground.height, "BOTTOM", 51, 621343, "CLAMP", {0,1,0,1}, {1,1,0.5, Ground.lightRimIntensity}, Ground.shadowIntensity, "ADD");
	Ground.rimLightSide = Environment.CreateFrame("Ground.rimLightSide", 0, Ground.floorOffsetY - Ground.height, Game.width, Ground.height, "BOTTOM", 51, 621343, "CLAMP", {1,0,1,0}, {1,1,0.5, Ground.lightRimIntensity}, Ground.shadowIntensity, "ADD");
	Ground.floorLight = Environment.CreateFrame("Ground.floorLight", 0, 0, Game.width, Ground.floorOffsetY + Ground.height, "BOTTOM", 51, 621343, "CLAMP", {1,0,1,0}, {1,1,0.5,0.05}, Ground.shadowIntensity, "ADD");

end

function Environment.CreateFrame(name, x, y, w, h, point, frameLevel, textureID, wrap, texCoord, color, alpha, blendMode)
	if wrap == nil then wrap = "REPEAT" end

	local f = CreateFrame("Frame", name, Canvas.frame);
	f:SetSize(w, h);
	f:SetPoint(point, x, y);
	f.texture = f:CreateTexture(name .. ".texture","BACKGROUND");
	f.texture:SetTexture(textureID, wrap, wrap);
	f.texture:SetAllPoints(f);
	if texCoord ~= nil then 
		f.texture:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4]);
	end
	if color ~= nil then
		f.texture:SetVertexColor(color[1], color[2], color[3], color[4]);
	end
	if blendMode ~= nil then
		f.texture:SetBlendMode(blendMode);
	end
	if alpha ~= nil then
		f:SetAlpha(alpha);
	end
	f:SetFrameLevel(frameLevel);
	return f;
end

function Environment.UpdateLayer2_Ground()
	-- Top frames --
	local offset = (Game.time * 0.25 * Game.speed);
	local firstScale = 1;
	local firstScaleY = 1;
	local kOfs = 15;
	for k = 1, Ground.height, 1 do
		local diff = Ground.height * 3;
		local K = (diff / ((diff - k) + kOfs)) * 4;
		local scale = (K * 0.5) * Ground.textureScale;
		Ground.floorFrames[k].texture:SetTexCoord(offset - (scale / 3), offset + scale - (scale / 3), scale, scale - ((1 / K) / 8))
		Ground.floorEffectFrames[k].texture:SetTexCoord(offset - (scale), offset + scale - (scale), scale, scale - ((1 / K) / 8))
		if k == 1 then
			firstScale = scale;
			firstScaleY = ((1 / K) / 8);
		end
	end

	-- Side frame --
	Ground.fgFloorFrame.texture:SetTexCoord(offset- (firstScale / 3), offset + firstScale - (firstScale / 3), firstScale - firstScaleY, 2)
end


--------------------------------------
--              Physics             --
--------------------------------------

function Physics.Update()
	Physics.PlayerCollisionUpdate();
end

function Physics.PlayerCollisionUpdate()
	local playerCol = Game.ObjectDefinitions["Player"].collider;
	local px, py, pz = Canvas.character:GetPosition();

	-- Reset collision state variables --
	Player.ground = 0;
	Player.roof = Canvas.ceiling;
	Player.isHeldInPlace = false;

	-- Compare player collider against all colliders in scene --
	for k = 1, LevelGenerator.totalObjects, 1 do
		if Game.GameObjects[k].active == true then
			local definition = Game.GameObjects[k].definition;
			local ox, oy, oz = Game.GameObjects[k].actor:GetPosition();
			local objCol = definition.collider;
			local oScale = definition.scale;
			oy = oy * oScale;
			oz = oz * oScale;
			
			-- Check for solids that can block player movement --
			if definition.solid == true then
				Physics.groundCollided = Physics.GroundCheck(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
				Physics.roofCollided = Physics.RoofCheck(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
				Physics.frontCollided = Physics.FrontCheck(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
				if Physics.frontCollided == true then 
					Player.isHeldInPlace = true;
				end
			end

			-- Check for intersections with non solids --
			if Physics.CheckCollision(Game.PlayerObject, Game.GameObjects[k]) == true then
				Physics.PlayerCollided(Game.GameObjects[k]);
			end
			--if playerCol.x + py < objCol.x + oy + objCol.w and playerCol.x + py + playerCol.w > objCol.x + oy and playerCol.y + pz < objCol.y + oz + objCol.h and playerCol.y + pz + playerCol.h > objCol.y + oz then
			--	Physics.PlayerCollided(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h, Game.GameObjects[k]);
			--end
		end
	end
end

function Physics.GroundCheck(px, py, pw, ph, ox, oy, ow, oh)
	if py + 1 >= oy + oh then									-- adding a 1 margin of error to account for fall frame distance delta
		if px < ox + ow - 0.3 and px + pw - 0.3 > ox then		-- adding a 0.3 so it doesn't get stuck on edges between vertical objects
			if Player.ground < oy + oh then
				Player.ground = oy + oh;
				return true;
			end
		end
	end

	return false;
end

function Physics.RoofCheck(px, py, pw, ph, ox, oy, ow, oh)
	if py <= oy then											-- adding a 1 margin of error to account for jump frame distance delta
		if px < ox + ow - 0.3 and px + pw - 0.6 > ox then		-- adding a 0.3 so it doesn't get stuck on edges between vertical objects, also 0.6 to allow jumping between two solids
			--if Player.roof > oy then
				Player.roof = min(Player.roof, oy);
				Player.roof = min(Player.roof, Canvas.ceiling);
				return true;
			--end
		end
	end
	return false;
end

function Physics.FrontCheck(px, py, pw, ph, ox, oy, ow, oh)
	if py < oy + oh and py + ph > oy then
		-- 1. Check colision with -1 offset so that it's ahead of intersection check (so the player doesn't land between gameobjects)
		-- 2. Check at current character position so that we don't stick behind game objects when jumping
		if px - 1 <= ox + ow and px >= ox + ow then
			return true;
		end
	end

	return false;
end

function Physics.PlayerCollided(gameObject)
	-- Danger 0 : Can be in contact with object anywhere
	if gameObject.definition.danger == 0 then

	-- Danger 1 : Cant' touch object at all
	elseif gameObject.definition.danger == 1 then
		Game.Over(true);
	-- Danger 2 : Can only touch object from the top
	elseif gameObject.definition.danger == 2 then

	end
end

function Physics.CheckCollision(objectA, objectB)
	local colliderA = objectA.definition.collider;
	local colliderB = objectB.definition.collider;
	local px, py, pz = objectA.actor:GetPosition();
	local ox, oy, oz = objectB.actor:GetPosition();
	local pScale = objectA.definition.scale;
	local oScale = objectB.definition.scale;
	py = py * pScale;
	pz = pz * pScale;
	oy = oy * oScale;
	oz = oz * oScale;

	if 	colliderA.x + py < colliderB.x + oy + colliderB.w and
		colliderA.x + py + colliderA.w > colliderB.x + oy and
		colliderA.y + pz < colliderB.y + oz + colliderB.h and
		colliderA.y + pz + colliderA.h > colliderB.y + oz then
		return true;
	end
end

function Player.Update()
	if Player.posX > Player.deathZone then
		Game.Over(true);
	end

	if Player.isHeldInPlace == true then
		Player.posX = Player.posX + (Game.speed / Game.SCENE_SYNC * 4);		-- why do I have to multiply by 4 ?
		--Player.worldPosY = Player.worldPosY - 0.3;							-- forcing a faster fall if held in place so it slides down walls faster
	else
		if Player.posX > 22 then
			Player.posX = Player.posX - (Game.speed / Game.SCENE_SYNC);
		end
	end

	if Player.jumpHold == true and Player.jumpEnd == false and Player.jumpHeight < 14 and Player.canJump == true then
		Player.grounded = false;
		Player.yForce = -10;
		Player.jumping = true;
		Player.jumpHeight = Player.jumpHeight + 1;
	end

	--if Player.jumpHold == true and Player.grounded == true then
	--	Game.speed = 4;
	--end

	--print (Player.worldPosY + Game.ObjectDefinitions["Player"].collider.h .. " " ..  Player.roof);
	if Player.jumpHeight >= 14 or Player.jumpHold == false or Player.jumpEnd == true then
		Player.canJump = false;
		--Player.jumpHold = false;
		Player.jumpEnd = true;
		Player.jumpHeight = 0;
		Player.jumping = false;
		-- have the player start falling
		Player.yForce = Player.yForce + 1;
	end

	-- we hit the roof --
	if Player.worldPosY + Game.ObjectDefinitions["Player"].collider.h >= Player.roof then
		Player.canJump = false;
		Player.jumpEnd = true;
		--Player.jumpHold = false;
		Player.jumpHeight = 0;
		Player.jumping = false;

		Player.yForce = 3;
	end

	if Player.worldPosY - (Player.yForce / Player.yForceDiv) <= Player.ground and Player.canJump == false then
		Player.worldPosY = Player.ground;
		Player.yForce = 0;
		if Player.falling then
			Player.landing = true;
		end

		if Player.landing == true then
			if Player.currentAnimation ~= "JumpEnd" then
				Player.SetAnimation("JumpEnd", Player.jumpLandAnimationSpeed);
			end
		end
		Player.falling = false;
		Player.canJump = true;
		Player.grounded = true;
	end

	-- if yForce > 0 means we're falling
	if Player.yForce > 0 then
		Player.falling = true;
		-- make fall happen a bit faster
		Player.yForce = Player.yForce * 1.1;
	end

	Player.worldPosY = Player.worldPosY - (Player.yForce / Player.yForceDiv);
	Canvas.character:SetPosition(0, Player.posX, Player.worldPosY);
	Player.UpdateBlobShadow();

	if Player.jumping == false and Player.falling == false then
		if Player.landing == true then
			Player.currentLandTime = Player.currentLandTime + Game.UPDATE_INTERVAL;
			if Player.currentLandTime >= Player.jumpLandTime then
				Player.currentLandTime = 0;
				Player.landing = false;
				if Player.currentAnimation ~= "Run" then
					Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);
				end
			end
		else
			if Player.isHeldInPlace == true then
				if Player.grounded == true then
					if Player.currentAnimation ~= "Stand" then
						Player.SetAnimation("Stand", 1);
					end
				end
			else
				if Player.currentAnimation ~= "Run" then
					Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);
				end
			end
		end
	end
end

--------------------------------------
--			Initialization			--
--------------------------------------

function Game.Initialize()
	-- Load Object definitions
	-- Has to be done in a function at the start because some table values will reference functions
	Game.CreateObjectDefinitions();

	-- Create all UI --
	UI.Initialize();

	-- Create canvas --
	Canvas.Create();

	-- Create environment --
	Environment.Create();
	Environment.Update();

	-- Initialize Level Generator --
	LevelGenerator.Initialize();

	-- Create update frame --
	Game.timeSinceLastUpdate = 0;
	Game.time = 0;
	Game.updateFrame = CreateFrame("Frame", "Game.updateFrame");
	Game.updateFrame:SetScript("OnUpdate", Game.Update)

	-- Create player input --
	Game.CreatePlayerInputFrame();

	-- Debug init --
	if Game.devMode == true then
		Game.mainWindow:Show();
		Game.NewGame();
		Canvas.DEBUG_CreateCaracterTrails();
	end

	Game.initialized = true;
end

--------------------------------------
--			Update Loop				--
--------------------------------------

function Game.Update(self, elapsed)
	if Game.initialized == false then return end
	Game.realTime = Game.realTime + Game.UPDATE_INTERVAL;
	if (Game.paused == false and Game.over == false) or Game.debugStep == true then
		Game.timeSinceLastUpdate = Game.timeSinceLastUpdate + elapsed; 	
		while (Game.timeSinceLastUpdate > Game.UPDATE_INTERVAL) do
			Game.debugStep = false;
			Player.Update();
			Environment.Update();
			Physics.Update();
			LevelGenerator.Update();
			Sound.Update();

			if Game.devMode == true then
				Canvas.DEBUG_UpdateCharacterTrails();
				--Physics.DEBUG_UpdateColliderFrames()
			end

			Game.travelledDistance = Game.travelledDistance + (Game.speed / Game.SCENE_SYNC);

			Game.time = Game.time + Game.UPDATE_INTERVAL;
			Game.timeSinceLastUpdate = Game.timeSinceLastUpdate - Game.UPDATE_INTERVAL;
		end
	end
	-- Things that get updated even if game over or paused
	Cutscene.Update();
	UI.Animate();
end

Game.Initialize();