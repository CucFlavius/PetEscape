local Game = Zee.DinoGame;
local Canvas = Game.Canvas;
local Environment = Game.Environment;
local Ground = Game.Environment.Ground;
local Player = Game.Player;
local LevelGenerator = Game.LevelGenerator;

--------------------------------------
--  Settings						--
--------------------------------------
Game.version = 0.2;
Game.devMode = true;
Game.debugNoMenu = true;
Game.debugDrawTrails = false;
Game.runWithEditor = true;
Game.UPDATE_INTERVAL = 0.02;						-- Basicly fixed delta time, represents how much time must pass before the update loops
Game.SCENE_SYNC = 23;								-- Used to synchronize the horizontal movement of the game object actors with the ground scrolling speed (Don't touch, it's gud)
Game.width = 640;									-- Window width, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.height = 300;									-- Window height, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.aspectRatio = Game.width / Game.height;
Canvas.defaultZoom = 1.0;
Canvas.defaultPan = 0;
Ground.floorOffsetY = 99;
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
Environment.Initial = "Forest";