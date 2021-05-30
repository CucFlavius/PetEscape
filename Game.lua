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
--------------------------------------
--				Classes 			--
--------------------------------------
Zee = Zee or {}
Zee.DinoGame = Zee.DinoGame or {}
Zee.DinoGame.Canvas = Zee.DinoGame.Canvas or {}
Zee.DinoGame.Canvas.Environment = Zee.DinoGame.Canvas.Environment or {};
Zee.DinoGame.Player = Zee.DinoGame.Player or {}
Zee.DinoGame.Physics = Zee.DinoGame.Physics or {}
Zee.DinoGame.LevelGenerator = Zee.DinoGame.LevelGenerator or {}
local Game = Zee.DinoGame;
local Win = ZWindowAPI;
local Canvas = Zee.DinoGame.Canvas;
local Environment = Zee.DinoGame.Canvas.Environment;
local Player = Zee.DinoGame.Player;
local Physics = Zee.DinoGame.Physics;
local LevelGenerator = Zee.DinoGame.LevelGenerator;
Canvas.Ground = {};

--------------------------------------
--				Variables			--
--------------------------------------
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
Game.paused = false;
Game.speed = 2;
Game.debugStep = false;
Game.travelledDistance = 0;
LevelGenerator.puzzleLength = 0;
LevelGenerator.puzzlePosition = 0;
LevelGenerator.totalObjects = 0;
Physics.groundCollided = false;

--------------------------------------
--				Settings			--
--------------------------------------
Game.devMode = true;
Game.UPDATE_INTERVAL = 0.02;						-- Basicly fixed delta time, represents how much time must pass before the update loops
Game.SCENE_SYNC = 23;								-- Used to synchronize the horizontal movement of the game object actors with the ground scrolling speed (Don't touch, it's gud)
Game.width = 640;									-- Window width, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.height = 300;									-- Window height, reference resolution (not actual resoluition since we use scale to resize the window for technical reasons)
Game.aspectRatio = Game.width / Game.height;
Canvas.defaultZoom = 1.5;
Canvas.defaultPan = 0;
Canvas.Ground.floorOffsetY = 99;
Canvas.Ground.height = 15;
Canvas.Ground.textureScale = 1.6;
Canvas.Ground.lightRimIntensity = 0.3;
Canvas.Ground.depthShadowIntensity = 1;
Canvas.Ground.depthShadowScale = 1;
Canvas.dinoShadowBlobY = 80;						-- The y position in screen space of the dinosaur blob shadow frame
Player.jumpKey = "W";
Player.jumpStartTime = 0.2;							-- The time in seconds for which to play the "JumpStart" animation before switching to "Jump" (Unused atm)
Player.jumpLandTime = 0.2;							-- The time in seconds for which to play the "JumpEnd" animation before switching to "Run" right after landing
Player.jumpLandAnimationSpeed = 1;					-- The animation speed for the character "JumpEnd" animation, playing at speed 1 feels best tbh
Player.runAnimationSpeedMultiplier = 0.7;			-- Mainly used to make the character animation not play at full Game.speed so his legs doen't look like sonic's at higher game speeds
Game.DEBUG_TrailCount = 40;
LevelGenerator.objectPoolSize = 10;

--------------------------------------
--			     Data				--
--------------------------------------
Game.ObjectDefinitions = 
{
	["Player"] = 
	{
		id = 0,
		scale = 1,
		collider = 
		{
			x = 0,
			y = 0,
			w = 5,
			h = 5
		},
	},

	["Crate"] = 
	{ 
		id = 2261922,
		scale = 4,
		collider = 
		{
			x = 0,
			y = 0,
			w = 5,
			h = 5
		},
	},
}

Game.Puzzles =
{
	["1Empty"] =
	{
		objectCount = 0,
		length = 1,
	},

	["1Crate"] = 
	{
		objectCount = 1,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 0 } },
		},
		length = 1.2,
	},

	["4CratesLine"] = 
	{
		objectCount = 4,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 0 } },
			{ dName = "Crate", position = { x = 1.2, y = 0 } },
			{ dName = "Crate", position = { x = 1.2 * 2, y = 0 } },
			{ dName = "Crate", position = { x = 1.2 * 3, y = 0 } },
		},
		length = 1.2 * 4;
	},

	["4CratesTetris"] = 
	{
		objectCount = 4,
		objects = 
		{ 
			{ dName = "Crate", position = { x = 0, y = 0 } },
			{ dName = "Crate", position = { x = 1.2, y = 0 } },
			{ dName = "Crate", position = { x = 1.2, y = 1.2 } },
			{ dName = "Crate", position = { x = 1.2 * 2, y = 0 } },
		},
		length = 1.2 * 4 + 6, 		-- leaving some space blank for testing purposes (DELETE the 6)
	},
}

Game.CharacterDisplayIDs = { 90029 }

--------------------------------------
--		       Game State			--
--------------------------------------
function Game.Pause()
	Game.paused = true;
	Canvas.character:SetPaused(true);
end

function Game.Resume()
	Game.paused = false;
	Canvas.character:SetPaused(false);
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

	-- loop through all the objects, and move them
	for k = 1, LevelGenerator.totalObjects, 1 do
		if Game.GameObjects[k].active == true then
			Game.GameObjects[k].position.x = Game.GameObjects[k].position.x + (Game.speed / Game.SCENE_SYNC);
			Game.GameObjects[k].actor:SetPosition(0, Game.GameObjects[k].position.x, Game.GameObjects[k].position.y);
			if Game.GameObjects[k].position.x > 10 then
				Game.GameObjects[k].active = false;
			end
		end
	end
end

function LevelGenerator.SpawnPuzzle()
	local puzzle = Game.Puzzles["4CratesTetris"];
	LevelGenerator.puzzleLength = puzzle.length;
	for k = 1, puzzle.objectCount, 1 do
		LevelGenerator.SpawnObject(puzzle.objects[k].dName, puzzle.objects[k].position)
	end
end

function LevelGenerator.SpawnObject(dName, position)
	local goIndex = LevelGenerator.GetAvailableGameObject();
	Game.GameObjects[goIndex].active = true;
	local definitionName = Game.GameObjects[goIndex].definition;
	if dName ~= definitionName then
		local definition = Game.ObjectDefinitions[dName];
		Game.GameObjects[goIndex].definition = definition;
		Game.GameObjects[goIndex].actor:SetModelByFileID(definition.id);
		Game.GameObjects[goIndex].actor:SetScale(definition.scale);
	end
	Game.GameObjects[goIndex].position.x = -10 - position.x;
	Game.GameObjects[goIndex].position.y = 0 + position.y;
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

--------------------------------------
--		       Rendering			--
--------------------------------------

function Canvas.Create()
	-- Create canvas parent frame, used for clipping --
	Canvas.parentFrame = CreateFrame("Frame", "Canvas.parentFrame", Game.mainWindow);
	Canvas.parentFrame:SetWidth(Game.width);
	Canvas.parentFrame:SetHeight(Game.height);
	Canvas.parentFrame:SetPoint("CENTER", 0, 0);
	Canvas.parentFrame:SetClipsChildren(true);

	-- Create main canvas frame --
	Canvas.frame = CreateFrame("Frame", "Canvas.frame", Canvas.parentFrame);
	Canvas.frame:SetWidth(Game.width);
	Canvas.frame:SetHeight(Game.height);
	Canvas.frame:SetPoint("CENTER", Canvas.defaultPan * Game.width, 0);
	Canvas.frame.texture = Canvas.frame:CreateTexture("Canvas.frame_Texture","BACKGROUND")
	--Canvas.frame.texture:SetColorTexture(0.66, 0.66, 0.7, 1);
	Canvas.frame.texture:SetColorTexture(0.2, 0.2, 0.2, 1);
	Canvas.frame.texture:SetAllPoints(Canvas.frame);
	Canvas.frame:SetScale(Canvas.defaultZoom);

	-- Create graphics frames --
	Canvas.CreateGround();
	Canvas.CreateEnvironment();
	Canvas.CreateMainScene();
end

function Canvas.CreateGround()
    Canvas.Ground.floorFrames = {}
	Canvas.Ground.floorEffectFrames = {}
	-- Create the floor frames --
	for k = 1, Canvas.Ground.height, 1 do
		Canvas.Ground.floorFrames[k] = CreateFrame("Frame", "Canvas.Ground.floorFrame_" .. k, Canvas.frame);
		Canvas.Ground.floorFrames[k]:SetWidth(Game.width);
		Canvas.Ground.floorFrames[k]:SetHeight(1);
		Canvas.Ground.floorFrames[k]:SetPoint("BOTTOM", 0, k - 1 + Canvas.Ground.floorOffsetY );
		Canvas.Ground.floorFrames[k].texture = Canvas.Ground.floorFrames[k]:CreateTexture("Canvas.Ground.floorFrame_" .. k .. "_texture","BACKGROUND")
		Canvas.Ground.floorFrames[k].texture:SetTexture(127784,"REPEAT", "REPEAT");
		Canvas.Ground.floorFrames[k].texture:SetAllPoints(Canvas.Ground.floorFrames[k]);
		Canvas.Ground.floorFrames[k]:SetFrameLevel(50);

		Canvas.Ground.floorEffectFrames[k] = CreateFrame("Frame", "Canvas.Ground.floorEffectFrame_" .. k, Canvas.frame);
		Canvas.Ground.floorEffectFrames[k]:SetWidth(Game.width);
		Canvas.Ground.floorEffectFrames[k]:SetHeight(1);
		Canvas.Ground.floorEffectFrames[k]:SetPoint("BOTTOM", 0, k - 1 + Canvas.Ground.floorOffsetY );
		Canvas.Ground.floorEffectFrames[k].texture = Canvas.Ground.floorFrames[k]:CreateTexture("Canvas.Ground.floorEffectFrame_" .. k .. "_texture","BACKGROUND")
		Canvas.Ground.floorEffectFrames[k].texture:SetTexture(3221839, "REPEAT", "REPEAT");
		Canvas.Ground.floorEffectFrames[k].texture:SetAllPoints(Canvas.Ground.floorEffectFrames[k]);
		Canvas.Ground.floorEffectFrames[k].texture:SetVertexColor(1,1,0.5, 0.5);
		Canvas.Ground.floorEffectFrames[k]:SetFrameLevel(51);
	end	

	-- Create foreground floor frame, representing the side of the ground --
	Canvas.Ground.fgFloorFrame = CreateFrame("Frame", "Canvas.Ground.fgFloorFrame", Canvas.frame);
	Canvas.Ground.fgFloorFrame:SetWidth(Game.width);
	Canvas.Ground.fgFloorFrame:SetHeight(Canvas.Ground.floorOffsetY );
	Canvas.Ground.fgFloorFrame:SetPoint("BOTTOM", 0, 0);
	Canvas.Ground.fgFloorFrame.texture = Canvas.Ground.fgFloorFrame:CreateTexture("Canvas.Ground.fgFloorFrame_texture","BACKGROUND")
	Canvas.Ground.fgFloorFrame.texture:SetTexture(127784,"REPEAT", "REPEAT");
	Canvas.Ground.fgFloorFrame.texture:SetAllPoints(Canvas.Ground.fgFloorFrame);
	Canvas.Ground.fgFloorFrame:SetFrameLevel(50);

	-- Create depth shadow frame 1 --
	Canvas.Ground.depthShadowFrame = CreateFrame("Frame", "Canvas.Ground.depthShadowFrame", Canvas.frame);
	Canvas.Ground.depthShadowFrame:SetWidth(Game.width);
	Canvas.Ground.depthShadowFrame:SetHeight(Canvas.Ground.floorOffsetY * Canvas.Ground.depthShadowScale);
	Canvas.Ground.depthShadowFrame:SetPoint("BOTTOM", 0, 0);
	Canvas.Ground.depthShadowFrame.texture = Canvas.Ground.depthShadowFrame:CreateTexture("Canvas.Ground.depthShadowFrame_texture","BACKGROUND")
	Canvas.Ground.depthShadowFrame.texture:SetTexture(131963,"CLAMP", "CLAMP");
	Canvas.Ground.depthShadowFrame.texture:SetAllPoints(Canvas.Ground.depthShadowFrame);
	Canvas.Ground.depthShadowFrame.texture:SetTexCoord(1, 0, 1, 0);
	Canvas.Ground.depthShadowFrame:SetAlpha(Canvas.Ground.depthShadowIntensity);
	Canvas.Ground.depthShadowFrame:SetFrameLevel(51);

	-- Create depth shadow frame 2, for extra contrast --
	Canvas.Ground.depthShadowFrame2 = CreateFrame("Frame", "Canvas.Ground.depthShadowFrame2", Canvas.frame);
	Canvas.Ground.depthShadowFrame2:SetWidth(Game.width);
	Canvas.Ground.depthShadowFrame2:SetHeight(Canvas.Ground.floorOffsetY * Canvas.Ground.depthShadowScale);
	Canvas.Ground.depthShadowFrame2:SetPoint("BOTTOM", 0, 0);
	Canvas.Ground.depthShadowFrame2.texture = Canvas.Ground.depthShadowFrame2:CreateTexture("Canvas.Ground.depthShadowFrame2_texture","BACKGROUND")
	Canvas.Ground.depthShadowFrame2.texture:SetTexture(131963,"CLAMP", "CLAMP");
	Canvas.Ground.depthShadowFrame2.texture:SetAllPoints(Canvas.Ground.depthShadowFrame2);
	Canvas.Ground.depthShadowFrame2.texture:SetTexCoord(1, 0, 1, 0);
	Canvas.Ground.depthShadowFrame2:SetAlpha(Canvas.Ground.depthShadowIntensity);
	Canvas.Ground.depthShadowFrame2:SetFrameLevel(51);
	Canvas.Ground.depthShadowFrame2.texture:SetBlendMode("BLEND");
	local lightRimHeight = Canvas.Ground.height;

	-- Create floor rim light top --
	Canvas.Ground.floorRimLightFrame = CreateFrame("Frame", "Canvas.Ground.floorRimLightFrame", Canvas.frame);
	Canvas.Ground.floorRimLightFrame:SetWidth(Game.width);
	Canvas.Ground.floorRimLightFrame:SetHeight(lightRimHeight);
	Canvas.Ground.floorRimLightFrame:SetPoint("BOTTOM", 0, Canvas.Ground.floorOffsetY );
	Canvas.Ground.floorRimLightFrame.texture = Canvas.Ground.floorRimLightFrame:CreateTexture("Canvas.Ground.floorRimLightFrame_texture","BACKGROUND")
	Canvas.Ground.floorRimLightFrame.texture:SetTexture(621343,"CLAMP", "CLAMP");
	Canvas.Ground.floorRimLightFrame.texture:SetAllPoints(Canvas.Ground.floorRimLightFrame);
	Canvas.Ground.floorRimLightFrame.texture:SetTexCoord(0, 1, 0, 1);
	Canvas.Ground.floorRimLightFrame.texture:SetVertexColor(1,1,0.5, Canvas.Ground.lightRimIntensity);
	Canvas.Ground.floorRimLightFrame.texture:SetBlendMode("ADD");
	Canvas.Ground.floorRimLightFrame:SetFrameLevel(51);

	-- Create floor rim light side --
	Canvas.Ground.floorRimLightFrame2 = CreateFrame("Frame", "Canvas.Ground.floorRimLightFrame2", Canvas.frame);
	Canvas.Ground.floorRimLightFrame2:SetWidth(Game.width);
	Canvas.Ground.floorRimLightFrame2:SetHeight(lightRimHeight);
	Canvas.Ground.floorRimLightFrame2:SetPoint("BOTTOM", 0, Canvas.Ground.floorOffsetY  - lightRimHeight);
	Canvas.Ground.floorRimLightFrame2.texture = Canvas.Ground.floorRimLightFrame2:CreateTexture("Canvas.Ground.floorRimLightFrame2_texture","BACKGROUND")
	Canvas.Ground.floorRimLightFrame2.texture:SetTexture(621343,"CLAMP", "CLAMP");
	Canvas.Ground.floorRimLightFrame2.texture:SetAllPoints(Canvas.Ground.floorRimLightFrame2);
	Canvas.Ground.floorRimLightFrame2.texture:SetTexCoord(1, 0, 1, 0);
	Canvas.Ground.floorRimLightFrame2.texture:SetVertexColor(1,1,0.5, Canvas.Ground.lightRimIntensity);
	Canvas.Ground.floorRimLightFrame2.texture:SetBlendMode("ADD");
	Canvas.Ground.floorRimLightFrame2:SetFrameLevel(51);

	-- Create floor brightness --
	Canvas.Ground.floorBrightnessFrame = CreateFrame("Frame", "Canvas.Ground.floorBrightnessFrame", Canvas.frame);
	Canvas.Ground.floorBrightnessFrame:SetWidth(Game.width);
	Canvas.Ground.floorBrightnessFrame:SetHeight(Canvas.Ground.floorOffsetY + Canvas.Ground.height);
	Canvas.Ground.floorBrightnessFrame:SetPoint("BOTTOM", 0, 0);
	Canvas.Ground.floorBrightnessFrame.texture = Canvas.Ground.floorBrightnessFrame:CreateTexture("Canvas.Ground.floorBrightnessFrame_texture","BACKGROUND")
	Canvas.Ground.floorBrightnessFrame.texture:SetColorTexture(1,1,0.5, 0.05);
	Canvas.Ground.floorBrightnessFrame.texture:SetAllPoints(Canvas.Ground.floorBrightnessFrame);
	Canvas.Ground.floorBrightnessFrame.texture:SetBlendMode("ADD");
	Canvas.Ground.floorBrightnessFrame:SetFrameLevel(51);

end

function Canvas.UpdateGround()
	local offset = (Game.time * 0.25 * Game.speed);
	local firstScale = 1;
	local firstScaleY = 1;
	local kOfs = 15;
	for k = 1, Canvas.Ground.height, 1 do
		local diff = Canvas.Ground.height * 3;
		local K = (diff / ((diff - k) + kOfs)) * 4;
		local scale = (K * 0.5) * Canvas.Ground.textureScale;
		Canvas.Ground.floorFrames[k].texture:SetTexCoord(offset - (scale / 3), offset + scale - (scale / 3), scale, scale - ((1 / K) / 8))
		Canvas.Ground.floorEffectFrames[k].texture:SetTexCoord(offset - (scale), offset + scale - (scale), scale, scale - ((1 / K) / 8))
		if k == 1 then
			firstScale = scale;
			firstScaleY = ((1 / K) / 8);
		end
	end

	Canvas.Ground.fgFloorFrame.texture:SetTexCoord(offset- (firstScale / 3), offset + firstScale - (firstScale / 3), firstScale - firstScaleY, 2)
end

function Canvas.CreateMainScene()
	-- Create main scene frame --
    Canvas.mainScene = CreateFrame("ModelScene", "Canvas.mainScene", Canvas.frame);
    Canvas.mainScene:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", 0, 0);
    Canvas.mainScene:SetSize(Game.width, Game.height);
    Canvas.mainScene:SetCameraPosition(-120, 0, 7);
	Canvas.mainScene:SetFrameLevel(101);
	Canvas.mainScene:SetCameraFarClip(1000);
	Canvas.mainScene:SetLightDirection(0.5, 1, 1);

	-- Create character actor --
    Canvas.character = Canvas.mainScene:CreateActor("character");
    Canvas.character:SetModelByCreatureDisplayID(Game.CharacterDisplayIDs[1]);
    Canvas.character:SetYaw(math.rad(-90));
	Canvas.character:SetPosition(0, 21, 0);
    Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);

	--print(Canvas.character:GetActiveBoundingBox());

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
		Canvas.DEBUG_Trails[k].frame.texture = Canvas.DEBUG_Trails[k].frame:CreateTexture("Canvas.Ground.floorBrightnessFrame_texture","BACKGROUND")
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
		if Player.jumpHold == false and Player.canJump == true then
			Player.jumpHold = true;
		end

		Player.inputFrame:SetPropagateKeyboardInput(false);

		if Player.canJump == true then
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
			Game.Resume();
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
	Canvas.dinoShadowBlobFrame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", Player.screenX - (30 * scale) - 5, Canvas.dinoShadowBlobY - (25 * scale));
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

function Canvas.CreateEnvironment()

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
	for k = 1, 100, 1 do
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
	for k = 1, 20, 1 do
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
	Environment.VFogNear:SetPoint("BOTTOM", 0, Canvas.Ground.floorOffsetY);
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
	Environment.VFogFar:SetPoint("BOTTOM", 0, Canvas.Ground.floorOffsetY);
	Environment.VFogFar.texture = Environment.VFogFar:CreateTexture("Environment.VFogFar_texture","BACKGROUND")
	Environment.VFogFar.texture:SetTexture(621343, "CLAMP", "CLAMP");
	Environment.VFogFar.texture:SetAllPoints(Environment.VFogFar);
	Environment.VFogFar.texture:SetTexCoord(0, 1, 0, 1);
	Environment.VFogFar.texture:SetVertexColor(13/256, 47/256, 48/256, 1);
	--Environment.VFogFar.texture:SetBlendMode("BLEND");
	Environment.VFogFar:SetFrameLevel(8);
end

function Canvas.UpdateEnvironment()
	for k = 1, 100, 1 do
		Environment.actors0[k].positionY = Environment.actors0[k].positionY + (Game.speed / 50);
		Environment.actors0[k].frame:SetPosition(Environment.actors0[k].positionX, Environment.actors0[k].positionY, Environment.actors0[k].positionZ);
		if Environment.actors0[k].positionY >= 90 then
			Environment.actors0[k].positionY = -90;
		end
	end

	for k = 1, 20, 1 do
		Environment.actors1[k].positionY = Environment.actors1[k].positionY + (Game.speed / 50);
		Environment.actors1[k].frame:SetPosition(Environment.actors1[k].positionX, Environment.actors1[k].positionY, Environment.actors1[k].positionZ);
		if Environment.actors1[k].positionY >= 50 then
			Environment.actors1[k].positionY = -50;
		end
	end

end

--------------------------------------
--              Physics             --
--------------------------------------

function Physics.Update()
	Physics.PlayerCollisionUpdate();
end

function Physics.PlayerCollisionUpdate()
	-- all colliders are AABB
	local playerCol = Game.ObjectDefinitions["Player"].collider;
	local px, py, pz = Canvas.character:GetPosition();
	Player.ground = 0;
	Player.isHeldInPlace = false;
	for k = 1, LevelGenerator.totalObjects, 1 do
		if Game.GameObjects[k].active == true then
			local definition = Game.GameObjects[k].definition;
			local objCol = definition.collider;
			local oScale = definition.scale;
			local ox, oy, oz = Game.GameObjects[k].actor:GetPosition();
			oy = oy * oScale;
			oz = oz * oScale;
			
			Physics.groundCollided = Physics.GroundCheck(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
			--local frontCollided = Physics.FrontCheck(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
			if playerCol.x + py < objCol.x + oy + objCol.w and playerCol.x + py + playerCol.w > objCol.x + oy and playerCol.y + pz < objCol.y + oz + objCol.h and playerCol.y + pz + playerCol.h > objCol.y + oz then
				-- collision detected!
				Physics.PlayerCollided(playerCol.x + py, playerCol.y + pz, playerCol.w, playerCol.h, objCol.x + oy, objCol.y + oz, objCol.w, objCol.h);
			else
				Game.GameObjects[k].actor:SetAlpha(1);
			end
		end
	end
end

function Physics.GroundCheck(px, py, pw, ph, ox, oy, ow, oh)
	if py + 0.1 >= oy + oh then		-- adding a 0.1 margin of error in case math explodes
		if px < ox + ow and px + pw > ox then
			if Player.ground < oy + oh then
				Player.ground = oy + oh;
				return true;
			end
		end
	end

	return false;
end

function Physics.PlayerCollided(px, py, pw, ph, ox, oy, ow, oh)
	-- if we aren't sitting on the object
	if Physics.groundCollided == false then
		Player.isHeldInPlace = true;
		--Game.GameObjects[k].actor:SetAlpha(0.5);
	end
end

function Player.Update()
	if Player.posX > 35 then
		Game.Pause();		-- game over actually
	end

	if Player.isHeldInPlace == true then
		Player.posX = Player.posX + (Game.speed / Game.SCENE_SYNC * 4);		-- why do I have to multiply by 4 ?
	else
		if Player.posX > 22 then
			Player.posX = Player.posX - (Game.speed / Game.SCENE_SYNC);
		end
	end

	if Player.jumpHold == true and Player.jumpHeight < 14 and Player.canJump == true then
		Player.yForce = -10;
		Player.jumping = true;
		Player.jumpHeight = Player.jumpHeight + 1;
	end
   
	if Player.jumpHeight >= 14 or Player.jumpHold == false then
		Player.canJump = false;
		Player.jumpHold = false;
		Player.jumpHeight = 0;
		Player.jumping = false;
		-- have the player start falling
		Player.yForce = Player.yForce + 1;
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
			if Player.currentAnimation ~= "Run" then
				Player.SetAnimation("Run", Game.speed * Player.runAnimationSpeedMultiplier);
			end
		end
	end
end

--------------------------------------
--			Initialization			--
--------------------------------------

function Game.Initialize()
	-- Create main window --
	Game.mainWindow = Win.CreateWindow(0, 0, Game.width, Game.height, UIParent, "CENTER", "CENTER", true, "Dino");
	Game.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect
	Game.mainWindow:SetScale(1.5);
	-- Create canvas --
	Canvas.Create();

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
	Canvas.DEBUG_CreateCaracterTrails();
	--Physics.DEBUG_CreateColliderFrames();
end

--------------------------------------
--			Update Loop				--
--------------------------------------
function Game.Update(self, elapsed)
	if Game.paused == false or Game.debugStep == true then
		Game.timeSinceLastUpdate = Game.timeSinceLastUpdate + elapsed; 	
		while (Game.timeSinceLastUpdate > Game.UPDATE_INTERVAL) do
			Game.debugStep = false;
			Canvas.UpdateGround();
			Player.Update();
			Canvas.UpdateEnvironment();
			Physics.Update();
			Canvas.DEBUG_UpdateCharacterTrails();
			LevelGenerator.Update();
			--Physics.DEBUG_UpdateColliderFrames()
			Game.travelledDistance = Game.travelledDistance + (Game.speed / Game.SCENE_SYNC);

			Game.time  = Game.time + Game.UPDATE_INTERVAL;
			Game.timeSinceLastUpdate = Game.timeSinceLastUpdate - Game.UPDATE_INTERVAL;
		end
	end
end


Game.Initialize();