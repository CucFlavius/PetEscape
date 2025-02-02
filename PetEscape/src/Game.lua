----------------------------------------------------------------------
-- • Title: Pet Escape									  			--
-- • Description : A mini-game designed for World of Warcraft 		--
-- • Version: 0.2 Development								  		--
-- • Contact In game: Songzee (ArgentDawn)(EU)			  			--
-- • Contact Email: cucflavius@gmail.com					  		--
-- • Some more details about the project:							--
--   The inspiration came from the small game that shows up in the	--
--   Chrome browser when your internet is down, you might see the	--
--	 name "dinogame" pop out through code here and there.			--
--   As a challenge I've set two limitations when designing it,		--
--	 the first one being to only use in game assets to create every --
--	 single graphic in the game.									--
--   I wanted to make something very simple to control, with a		--
--	 single key press, mainly to reduce complexity and development	--
--	 time, but also for the chance to think about how puzzles can	--
--	 be designed around the limitation of character interaction		--
----------------------------------------------------------------------

-- Things of interest
-- TODO : Delete these
-- Interface/Common/CommonIcons.png
-- k_pagetext.ttf
-- world\expansion02\doodads\coldarra\coldarracloud_mask.blp 194342
-- creature\hunterkillership\alphamask_verticalgradient.blp 2903846

local Game = Zee.DinoGame; 
local Canvas = Game.Canvas;
local Environment = Game.Environment; 
local Ground = Game.Environment.Ground;
local Player = Game.Player;
local Physics = Game.Physics;
local LevelGenerator = Game.LevelGenerator;
local Cutscene = Game.Cutscene;
local Sound = Game.Sound;
local UI = Game.UI; 
local FX = Game.FX;
local AI = Game.AI;
local Editor = Game.Editor;

local floor = math.floor;
local random = math.random;
local sin = math.sin;
local cos = math.cos;
local PI = math.pi;
local rad = math.rad;
local min = math.min;
local max = math.max;

--------------------------------------
--  Variables						--
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
Game.matchCoins = 0;
Environment.isTransitioning = false;
Environment.objPosition = 0;
Environment.totalObjects = 0;
Environment.CurrentDefinition = Environment.Initial;
Environment.NextDefinition = "";

--------------------------------------
--  Game State						--
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
		Game.matchCoins = 0;
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

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function Game.Random()
	return random();
	--[[
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = floor(V/D20)
    X2 = V - X1*D20
    return V/D40
	--]]
end

function Game.Lerp(a, b, t)
	 return a * (1-t) + b * t
end

--------------------------------------
--  AI								--
--------------------------------------

function AI.CannonInit(gameObject)
	gameObject.currentAnimation = "Emerge";
	gameObject.ai = {};
	gameObject.ai.time = 0;
	gameObject.actor:SetAnimation(Game.AnimationIDs[gameObject.currentAnimation], 0, 1.5, 1);
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
		gameObject.actor:SetAnimation(Game.AnimationIDs[gameObject.currentAnimation], 0, 1.2);
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

function AI.CoinStaticInit(gameObject)
	gameObject.ai = {};
	gameObject.ai.time = 0;
	gameObject.ai.collect = false;		-- init
	gameObject.ai.collecting = false;	-- update
	gameObject.actor:SetPitch(rad(90));
	gameObject.actor:SetParticleOverrideScale(0);
end

function AI.CoinStaticUpdate(gameObject)
	gameObject.ai.time = gameObject.ai.time + 1;
	if gameObject.ai.collecting == false then
		gameObject.actor:SetRoll(rad(gameObject.ai.time * 2));
	else
		AI.Collect(gameObject);
	end

	if gameObject.ai.collect == true then
		gameObject.ai.collecting = true;
		gameObject.ai.collect = false;
		gameObject.ai.collectingTime = gameObject.ai.time;
	end
end

function AI.CoinFloatyInit(gameObject)
	gameObject.ai = {};
	gameObject.ai.time = gameObject.position.x * 10 + 20;	-- ensuring the coins sqwing at different intervals
	gameObject.ai.collect = false;		-- init
	gameObject.ai.collecting = false;	-- update
	gameObject.ai.initialY = gameObject.position.y;
	gameObject.actor:SetPitch(rad(90));
	gameObject.actor:SetParticleOverrideScale(0);
end

function AI.CoinFloatyUpdate(gameObject)
	gameObject.ai.time = gameObject.ai.time + 1;
	if gameObject.ai.collecting == false then
		gameObject.position.y = sin(gameObject.ai.time / 10) / 2 + gameObject.ai.initialY;
		gameObject.actor:SetRoll(rad(gameObject.ai.time * 2));
	else
		AI.Collect(gameObject);
	end

	if gameObject.ai.collect == true then
		gameObject.ai.collecting = true;
		gameObject.ai.collect = false;
		gameObject.actor:SetParticleOverrideScale(2);
		gameObject.ai.collectingTime = gameObject.ai.time;
	end
end

function AI.Collect(gameObject)
	local timer = (gameObject.ai.time - gameObject.ai.collectingTime);
	gameObject.position.y = Game.Lerp(gameObject.position.y, 5.5, sin(timer / 200 * PI));	-- I was gonna do ease in curve for the coin collecting but gave up halfway through
	gameObject.actor:SetAlpha(gameObject.actor:GetAlpha() - 0.03);
	gameObject.actor:SetRoll(rad(gameObject.ai.time * 20));

	-- Actually collect
	if timer == 20 then
		Game.matchCoins = Game.matchCoins + 1;
		UI.HUD.SetCoins();
		if UI.HUD.coinCollectTimer >= 1 then
			UI.HUD.coinCollectTimer = 0;
		end
	end
end

function AI.SawBladeInit(gameObject)
	gameObject.currentAnimation = "Hold";
	gameObject.ai = {};
	gameObject.ai.time = 0;
	gameObject.actor:SetAnimation(Game.AnimationIDs[gameObject.currentAnimation], 0, 0.1, 1);
	gameObject.actor:SetYaw(rad(90));
end

function AI.SawBladeUpdate(gameObject)

end

function AI.RoombaInit(gameObject)
	gameObject.currentAnimation = "Walk";
	gameObject.ai = {};
	gameObject.ai.time = 0;
	gameObject.ai.kill = false;
	gameObject.alive = true;
	gameObject.ai.killTimer = -1;
	gameObject.actor:SetAnimation(Game.AnimationIDs[gameObject.currentAnimation], 0, 1, 1);
end

function AI.RoombaUpdate(gameObject)
	gameObject.ai.time = gameObject.ai.time + 1;
	x,y,z = gameObject.actor:GetPosition();

	-- trigger kill
	if gameObject.ai.kill == true then
		gameObject.ai.kill = false;
		gameObject.ai.killTimer = 0;
	end

	-- if alive, patroll
	if gameObject.alive == true then
		if gameObject.actor:GetYaw() > 0 then
			gameObject.position.x = gameObject.position.x + 0.02;
		elseif gameObject.actor:GetYaw() < 0 then
			gameObject.position.x = gameObject.position.x - 0.02;
		end
	end

	-- play kill animation
	if gameObject.ai.killTimer == 0 then
		gameObject.ai.killTimer = gameObject.ai.killTimer + 1;

		if gameObject.ai.killTimer == 1 then
			gameObject.actor:SetAnimation(Game.AnimationIDs["Death"], 1, 1, 1);
		elseif gameObject.ai.killTimer == 20 then
			--gameObject.actor:SetPaused(true);
		end
		if gameObject.ai.killTimer > 10 and gameObject.ai.killTimer < 100 then
			-- Animate character going up and then down, falling off the screen
			-- I know at least a dozen games that do this, time to pay homage ;)
			local localTime = gameObject.ai.killTimer - 10;
			local localNormalizedTime = localTime / 170;
			local increment = localTime / 10;
			local bounce = sin(localNormalizedTime * PI * 1.5) * 15;
			--[[
			local x, y, z = gameObject.actor:GetPosition();
			gameObject.actor:SetPosition(
				x - increment,
				y - increment,
				z + bounce - increment
			);
			--]]
			--gameObject.positionX = gameObject.positionX - increment;
			--gameObject.positionY = gameObject.positionY + bounce - increment;
			--gameObject.actor:SetAnimation(Game.AnimationIDs["Death"], 0, 1, 1);
		elseif gameObject.ai.killTimer == 100 then
			gameObject.actor:SetPosition(
				100,
				100,
				100
			);
		end
	end
end

--------------------------------------
--  Canvas							--
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
    Canvas.character:SetYaw(rad(-90));
	Canvas.character:SetPosition(0, 21, 0);
	Canvas.character:SetPaused(true);
	Game.PlayerObject = {}
	Game.PlayerObject.actor = Canvas.character;
	Game.PlayerObject.definition = Game.ObjectDefinitions["Player"];

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
--  UI								--
--------------------------------------

--- Create a new Window
---@param posX number Window X position (horizontal)
---@param posY number Window Y position (vertical)
---@param sizeX number Window width
---@param sizeY number Window height
---@param parent table Parent frame
---@param windowPoint string Pivot point of the current window
---@param parentPoint string Pivot point of the parent
---@param title string Title text
---@return table windowFrame Wow Frame that contains all of the window elements
function UI.CreateWindow(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, title)

	-- properties --
	local TitleBarHeight = 20;
	local TitleBarFont = "Fonts\\FRIZQT__.TTF";
	local TitleBarFontSize = 10;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if title == nil then title = ""; end

	-- main window frame --
	local WindowFrame = CreateFrame("Frame", "Window "..title, parent);
	WindowFrame:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	WindowFrame:SetSize(sizeX, sizeY);
	WindowFrame.texture = WindowFrame:CreateTexture("Window "..title.. " texture", "BACKGROUND");
	WindowFrame.texture:SetColorTexture(0.2,0.2,0.2,1);
	WindowFrame.texture:SetAllPoints(WindowFrame);
	WindowFrame:SetMovable(true);
	WindowFrame:EnableMouse(true);
	--WindowFrame:SetUserPlaced(true);

	-- title bar frame --
	WindowFrame.TitleBar = CreateFrame("Frame", "Window "..title.. " TitleBar", WindowFrame);
	WindowFrame.TitleBar:SetPoint("BOTTOM", WindowFrame, "TOP", 0, 0);
	WindowFrame.TitleBar:SetSize(sizeX, TitleBarHeight);
	WindowFrame.TitleBar.texture = WindowFrame.TitleBar:CreateTexture("Window "..title.. " TitleBar texture", "BACKGROUND");
	WindowFrame.TitleBar.texture:SetColorTexture(0.5,0.5,0.5,1);
	WindowFrame.TitleBar.texture:SetAllPoints(WindowFrame.TitleBar);
	WindowFrame.TitleBar.text = WindowFrame.TitleBar:CreateFontString("Window "..title.. " TitleBar text");
	WindowFrame.TitleBar.text:SetFont(TitleBarFont, TitleBarFontSize, "NORMAL");
	WindowFrame.TitleBar.text:SetAllPoints(WindowFrame.TitleBar);
	WindowFrame.TitleBar.text:SetText(title);
	WindowFrame.TitleBar:EnableMouse(true);
	WindowFrame.TitleBar:RegisterForDrag("LeftButton");
	WindowFrame.TitleBar:SetScript("OnDragStart", function()  WindowFrame:StartMoving(); end);
	WindowFrame.TitleBar:SetScript("OnDragStop", function() WindowFrame:StopMovingOrSizing(); end);

	-- Close Button --
	WindowFrame.CloseButton = UI.CreateButton(-1, -1, TitleBarHeight - 1, TitleBarHeight - 1, WindowFrame.TitleBar, "TOPRIGHT", "TOPRIGHT", "x", nil)
	WindowFrame.CloseButton:SetScript("OnClick", function (self, button, down) WindowFrame:Hide(); end)
	return WindowFrame;

end

function UI.CreateButton(posX, posY, sizeX, sizeY, parent, buttonPoint, parentPoint, text, icon)

	-- properties --
	local ButtonFont = "Fonts\\FRIZQT__.TTF";
	local ButtonFontSize = 12;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 10; end
	if sizeY == nil or sizeY == 0 then sizeY = 10; end	
	if parent == nil then parent = UIParent; end
	if buttonPoint == nil then buttonPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end

	-- main button frame --
	local Button = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	Button:SetPoint(buttonPoint, parent, parentPoint, posX, posY);
	Button:SetWidth(sizeX)
	Button:SetHeight(sizeY)
	Button.ntex = Button:CreateTexture()
	Button.htex = Button:CreateTexture()
	Button.ptex = Button:CreateTexture()
	Button.ntex:SetColorTexture(0.3,0.3,0.3,1);
	Button.htex:SetColorTexture(0.1,0.1,0.1,1);
	Button.ptex:SetColorTexture(0.1,0.1,0.1,1);

	Button.ntex:SetAllPoints()	
	Button.ptex:SetAllPoints()
	Button.htex:SetAllPoints()
	Button:SetNormalTexture(Button.ntex)
	Button:SetHighlightTexture(Button.htex)
	Button:SetPushedTexture(Button.ptex)

	-- icon --
	if icon ~= nil then
		local iconSize = 10;
		if sizeX >= sizeY then iconSize = sizeY; end
		if sizeX <= sizeY then iconSize = sizeX; end
		Button.icon = CreateFrame("Frame", "Zee.WindowAPI.Button Icon", parent);
		Button.icon:SetPoint("CENTER", Button, "CENTER", 0, 0);
		Button.icon:SetSize(iconSize, iconSize);
		Button.icon.texture = Button.icon:CreateTexture("Zee.WindowAPI.Button Icon Texture", "BACKGROUND");
		Button.icon.texture:SetTexture(icon)
		Button.icon.texture:SetAllPoints(Button.icon);
	end

	-- text --
	if text ~= nil then
		Button.text = Button:CreateFontString("Zee.WindowAPI.Button Text");
		Button.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
		Button.text:SetAllPoints(Button);
		Button.text:SetText(text);
	end

	return Button;

end

function UI.Initialize()
	-- Create main window --
	Game.mainWindow = UI.CreateWindow(0, 0, Game.width, Game.height, UIParent, "CENTER", "CENTER", "Pet Escape");
	Game.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect
	Game.mainWindow:SetScale(1.5);
	Game.mainWindow:Hide();

	--Game.menuWindow = Win.CreateFrame

	UI.CreateMainMenu();

	-- Create logo frames --
	UI.CreateLogo();
	UI.CreateLogoText();

	UI.HUD.Create();

	-- Run first frame of the logo animation --
	Cutscene.isPlaying = true;
	Cutscene.current = "Logo";
	Cutscene.Update();
	Cutscene.current = "None";
	Cutscene.isPlaying = false;
end

function UI.Animate()
	UI.MainMenu.Animate();
	UI.HUD.Animate();
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
	UI.MainMenu.bgFrame.texture:SetRotation(rad(90));
	UI.MainMenu.bgFrame.texture:SetAllPoints(UI.MainMenu.bgFrame);

	UI.MainMenu.menuBgFrame = CreateFrame("Frame", "UI.MainMenu.menuBgFrame", UI.MainMenu.frame);
	UI.MainMenu.menuBgFrame:SetPoint("CENTER", UI.MainMenu.frame, "CENTER", 0, 0);
	UI.MainMenu.menuBgFrame:SetSize(200, 200);
	UI.MainMenu.menuBgFrame:SetFrameLevel(1200);
	UI.MainMenu.menuBgFrame.texture = UI.MainMenu.menuBgFrame:CreateTexture("UI.MainMenu.bgFrame.texture","BACKGROUND")
	UI.MainMenu.menuBgFrame.texture:SetTexture(3640932, "CLAMP", "CLAMP");
	UI.MainMenu.menuBgFrame.texture:SetTexCoord(0,0.65,0,0.575);
	--UI.MainMenu.menuBgFrame.texture:SetRotation(rad(-90));
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
	UI.MainMenu.scene:SetCameraFieldOfView(rad(90));
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
    --UI.MainMenu.assets[1]:SetYaw(rad(0));
	UI.MainMenu.assets[1]:SetPitch(rad(90));
	UI.MainMenu.assets[1]:SetPosition(0, 2, 0);

	UI.MainMenu.assets[2] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[2]");
    UI.MainMenu.assets[2]:SetModelByFileID(1013989);
    --UI.MainMenu.assets[2]:SetYaw(rad(0));
	UI.MainMenu.assets[2]:SetPitch(rad(90));
	UI.MainMenu.assets[2]:SetPosition(0, -2, 0);

	UI.MainMenu.assets[3] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[3]");
    UI.MainMenu.assets[3]:SetModelByFileID(1013989);
    UI.MainMenu.assets[3]:SetRoll(rad(90));
	UI.MainMenu.assets[3]:SetYaw(rad(90));
	UI.MainMenu.assets[3]:SetPosition(0, 0, 2.5);

	UI.MainMenu.assets[4] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[4]");
    UI.MainMenu.assets[4]:SetModelByFileID(1013989);
    UI.MainMenu.assets[4]:SetRoll(rad(90));
	UI.MainMenu.assets[4]:SetYaw(rad(90));
	UI.MainMenu.assets[4]:SetPosition(0, 0, -2.5);

	UI.MainMenu.assets[5] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[5]");
    UI.MainMenu.assets[5]:SetModelByFileID(1523215);
    UI.MainMenu.assets[5]:SetRoll(rad(0));
	UI.MainMenu.assets[5]:SetYaw(rad(180));
	UI.MainMenu.assets[5]:SetPosition(-2, -4, -5.5);
	UI.MainMenu.assets[5]:SetScale(0.5);

	UI.MainMenu.assets[6] = UI.MainMenu.scene:CreateActor("UI.MainMenu.assets[6]");
    UI.MainMenu.assets[6]:SetModelByFileID(1523229);
    UI.MainMenu.assets[6]:SetRoll(rad(0));
	UI.MainMenu.assets[6]:SetYaw(rad(180));
	UI.MainMenu.assets[6]:SetPosition(-2, 4, -5.5);
	UI.MainMenu.assets[6]:SetScale(0.5);
end

function UI.MainMenu.Animate()
	local x, y;
	local speed = 5;
	local ofs = 50;
	local ofs2 = 1.5;
	for b = 1, #UI.MainMenu.buttons, 1 do
		for i = 1, #UI.MainMenu.buttons[b].text, 1 do
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
	UI.Logo.scene:SetCameraFieldOfView(rad(90));
	--UI.Logo.scene:SetFogFar(100); -- 9.1.5 broke model scene fog
	--UI.Logo.scene:SetFogNear(20);
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
	UI.Logo.shadowScene:SetCameraFieldOfView(rad(60));
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
	UI.Logo.bgScene:SetCameraFieldOfView(rad(90));
	UI.Logo.bgScene:Hide();

	UI.Logo.assets[1] = UI.AddLogoAsset("UI.Logo.LeftSideNPC", UI.Logo.scene, 90029, true, 150, 0, 0, 0, 0, 0, "Run", 1);
	UI.Logo.assets[-1] = UI.AddLogoAsset("UI.Logo.LeftSideNPCShadow", UI.Logo.shadowScene, 90029, true, 150, 0, 0, 0, 0, 0, "Run", 1);
	UI.Logo.assets[2] = UI.AddLogoAsset("UI.Logo.RightSideNPC", UI.Logo.scene, 16259, true, 210, 0, 0, 0, 0, 0, "Run", 2);
	UI.Logo.assets[-2] = UI.AddLogoAsset("UI.Logo.RightSideNPCShadow", UI.Logo.shadowScene, 16259, true, 210, 0, 0, 0, 0, 0, "Run", 2);
	UI.Logo.assets[3] = UI.AddLogoAsset("UI.Logo.MonsterNPC", UI.Logo.scene, 378, true, 180, -10, 0, 0, 0, 0, "Run", 4);
	UI.Logo.assets[-3] = UI.AddLogoAsset("UI.Logo.MonsterNPCShadow", UI.Logo.shadowScene, 378, true, 180, -10, 0, 0, 0, 0, "Run", 4);
	UI.Logo.assets[4] = UI.AddLogoAsset("UI.Logo.CenterNPC", UI.Logo.scene, 87401, true, 180, 0, 0, 0, 0, 0, "Run", 1.5);
	UI.Logo.assets[-4] = UI.AddLogoAsset("UI.Logo.CenterNPCShadow", UI.Logo.shadowScene, 87401, true, 180, 0, 0, 0, 0, 0, "Run", 1.5);
	UI.Logo.assets[6] = UI.AddLogoAsset("UI.Logo.Cloud", UI.Logo.bgScene, 394984, false, 90, 0, 0, 0, -0.3, -0.1, "Stand", 3);
end

function UI.AddLogoAsset(name, scene, ID, isCreature, yaw, pitch, roll, posX, posY, posZ, animation, scale)
	local asset = scene:CreateActor(name);
	if isCreature == true then
    	asset:SetModelByCreatureDisplayID(ID);
	else
		asset:SetModelByFileID(ID);
	end
    asset:SetYaw(rad(yaw));
	asset:SetPitch(rad(pitch));
	asset:SetRoll(rad(roll));
	asset:SetPosition(posX, posY, posZ);
	asset:SetAnimation(Game.AnimationIDs[animation]);
	asset:SetPaused(true);
	asset:SetScale(scale);
	return asset;
end

function UI.CreateLogoText()
	UI.Logo.Text = {}
	UI.Logo.TextHolder = CreateFrame("Frame", "UI.Logo.TextHolder", UI.Logo.scene);
	UI.Logo.TextHolder:SetPoint("CENTER", UI.Logo.scene, "CENTER", -30, -100);
	UI.Logo.TextHolder:SetFrameStrata("HIGH");
	UI.Logo.TextHolder:SetFrameLevel(1000);
    UI.Logo.TextHolder:SetSize(1000, 1000);
	UI.Logo.Text[1] = FX.Text.CreateWord("PET", 0, 0, UI.Logo.TextHolder, 0.8, 1, 1, 1, 1, nil, 1002);
	UI.Logo.Text[2] = FX.Text.CreateWord("ESCAPE", -45, -40, UI.Logo.TextHolder, 0.8, 1, 1, 1, 1, nil,  1002);
	UI.Logo.Text[-1] = FX.Text.CreateWord("PET", 0, 0, UI.Logo.TextHolder, 0.8, 1.1, 0, 0, 0, nil, 1001);
	UI.Logo.Text[-2] = FX.Text.CreateWord("ESCAPE", -45, -40, UI.Logo.TextHolder, 0.8, 1.1, 0, 0, 0, nil, 1001);
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
	btn.text = FX.Text.CreateWord(name, 0, 0, btn.button , 1, 0.5, 1, 1, 1, "LEFT", 1204);
	btn.shadowText = FX.Text.CreateWord(name, 0, 0, btn.button , 1, 0.5, 0, 0, 0, "LEFT", 1203);
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

function UI.HUD.Create()
	UI.HUD.texts = {};

	UI.HUD.FrameLevel = 1101;

	-- Coins text
	UI.HUD.coins = {};
	UI.HUD.coins.frame = CreateFrame("Frame", "UI.HUD.coins.frame", Game.mainWindow);
	UI.HUD.coins.frame:SetPoint("TOPLEFT", Game.mainWindow, "TOPLEFT", x, y);
	UI.HUD.coins.frame:SetSize(100, 30);
	UI.HUD.coins.frame:SetFrameLevel(UI.HUD.FrameLevel);
	UI.HUD.coins.shadowText = FX.Text.CreateWord(0, 100, 0, UI.HUD.coins.frame , 1, 0.3, 0, 0, 0, "LEFT", UI.HUD.FrameLevel + 1);
	UI.HUD.coins.text = FX.Text.CreateWord(0, 100, 0, UI.HUD.coins.frame , 1, 0.3, 1, 1, 1, "LEFT", UI.HUD.FrameLevel + 2);
	UI.HUD.texts[1] = UI.HUD.coins;	-- adding to be animated

	-- Coin icon
	UI.HUD.coinIconModel = CreateFrame("PlayerModel", "UI.HUD.coinIconModel", UI.HUD.coins.frame);
	UI.HUD.coinIconModel:SetPoint("LEFT", UI.HUD.coins.frame, "LEFT", 0, 0);
    UI.HUD.coinIconModel:SetSize(40, 40);
	UI.HUD.coinIconModel:SetFrameLevel(UI.HUD.FrameLevel);
	UI.HUD.coinIconModel:SetModel(916276);
	UI.HUD.coinIconModel:SetPosition(0,0,0);
	UI.HUD.coinIconModel:SetModelScale(1.5);
	UI.HUD.coinIconModel:SetPitch(rad(90));
	UI.HUD.coinIconModel:SetFacing(rad(0));
	UI.HUD.coinIconModel:SetParticlesEnabled(false);
	UI.HUD.coinIconModel:Show();
	UI.HUD.coinCollectTimer = 1;
	-- UI.HUD.coinIconModel.texture = UI.HUD.coinIconModel:CreateTexture("UI.HUD.coinIconModel.texture")
	-- UI.HUD.coinIconModel.texture:SetColorTexture(0,0,0);
	-- UI.HUD.coinIconModel.texture:SetAllPoints(UI.HUD.coinIconModel);
end

function UI.HUD.Animate()
	local x, y;
	local speed = 5;
	local ofs = 50;
	local ofs2 = 1.5;
	for b = 1, #UI.HUD.texts, 1 do
		for i = 1, #UI.HUD.texts[b].text, 1 do
			x, y = FX.RotatePoint(0, 1, Game.realTime * speed + (i * ofs));
			UI.HUD.texts[b].text[i].texture:SetVertexOffset(1, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(0, 0, Game.realTime * speed + (i * ofs));
			UI.HUD.texts[b].text[i].texture:SetVertexOffset(2, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(1, 1, Game.realTime * speed + (i * ofs));
			UI.HUD.texts[b].text[i].texture:SetVertexOffset(3, x * ofs2, y * ofs2);
			x, y = FX.RotatePoint(1, 0, Game.realTime * speed + (i * ofs));
			UI.HUD.texts[b].text[i].texture:SetVertexOffset(4, x * ofs2, y * ofs2);
		end
	end

	if UI.HUD.coinCollectTimer < 1 then
		UI.HUD.coinCollectTimer = UI.HUD.coinCollectTimer + 0.02;
		local angle = Game.Lerp(0, 360, UI.HUD.coinCollectTimer);
		--UI.HUD.coinIconModel:SetPitch(rad(angle));
		UI.HUD.coinIconModel:SetFacing(rad(angle));
		local scale = 1.5;
		if UI.HUD.coinCollectTimer < 0.5 then
			scale = Game.Lerp(1.5, 3, UI.HUD.coinCollectTimer * 2);
		else
			scale =  Game.Lerp(3, 1.5, (UI.HUD.coinCollectTimer - 0.5) * 2);
		end
		UI.HUD.coinIconModel:SetModelScale(scale);
	end

	UI.HUD.coinIconModel:SetPosition(0,0,sin(Game.realTime * 5) / 20);
end

function UI.HUD.SetCoins()
	FX.Text.SetWord(tostring(Game.matchCoins), UI.HUD.coins.text, UI.HUD.FrameLevel + 2);
	FX.Text.SetWord(tostring(Game.matchCoins), UI.HUD.coins.shadowText, UI.HUD.FrameLevel + 1);
end

--------------------------------------
--  Sound							--
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
--  Cutscene						--
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
				local localTime = Cutscene.time - 30;
				local localNormalizedTime = localTime / 170;
				local increment = localTime / 10;
				local bounce = sin(localNormalizedTime * PI * 1.5) * 15;
				Canvas.character:SetPosition(
					Player.posX - increment,
					Player.posY - increment,
					Player.posZ + bounce - increment
				);
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
					local scale = max(0.01, sin(rad(Cutscene.time)) * 1.1);
					UI.Logo.scene:SetScale(scale);
					UI.Logo.shadowScene:SetScale(scale);
					UI.Logo.bgScene:SetScale(scale);
				end

				if Cutscene.time <= 190 then
					local ofs2 = max(0.7, Cutscene.time / 180);
					local scale = sin(rad((Cutscene.time + 30) * ofs2)) * 1.4;
					scale = max(1, scale);

					UI.Logo.TextHolder:SetScale(scale + 0.3);
				end

				if Cutscene.time <= 320 then
					local x, y;
					local speed = 5;
					local ofs = 50;
					local ofs2 = 1.5;
					for i = 1, #UI.Logo.Text[1], 1 do
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

					for i = 1, #UI.Logo.Text[2], 1 do
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
					local frame = (sin(rad((Cutscene.time - offs1) / 2) * PI / 4) + 1) / 2;
					local posOffs = 2;
					local hOffs = -1;

					-- Left side npc
					local scale1 = UI.Logo.assets[1]:GetScale();
					UI.Logo.assets[1]:SetPaused(true);
					UI.Logo.assets[-1]:SetPaused(true);
					UI.Logo.assets[1]:SetAnimation(Game.AnimationIDs["AttackUnarmed"], 0, 1, frame / 4 - 0.1);
					UI.Logo.assets[-1]:SetAnimation(Game.AnimationIDs["AttackUnarmed"], 0, 1, frame / 4 - 0.1);
					UI.Logo.assets[1]:SetPosition(frame / scale1, (frame + posOffs) / scale1, -2 / scale1 + hOffs);
					UI.Logo.assets[-1]:SetPosition(frame / scale1, (frame + posOffs) / scale1, -2 / scale1 + hOffs);

					-- Right side npc
					local scale2 = UI.Logo.assets[2]:GetScale();
					UI.Logo.assets[2]:SetPaused(true);
					UI.Logo.assets[-2]:SetPaused(true);
					UI.Logo.assets[2]:SetAnimation(Game.AnimationIDs["AttackUnarmed"], 2, 1, frame / 4 - 0.1);
					UI.Logo.assets[-2]:SetAnimation(Game.AnimationIDs["AttackUnarmed"], 2, 1, frame / 4 - 0.1);
					UI.Logo.assets[2]:SetPosition(frame / scale2, (-posOffs - frame) / scale2, (-2 + hOffs)/ scale2);
					UI.Logo.assets[-2]:SetPosition(frame / scale2, (-posOffs - frame) / scale2, (-2 + hOffs) / scale2);

					-- Monster npc
					local scale3 = UI.Logo.assets[3]:GetScale();
					UI.Logo.assets[3]:SetPaused(true);
					UI.Logo.assets[-3]:SetPaused(true);
					UI.Logo.assets[3]:SetAnimation(Game.AnimationIDs["Run"], 2, 1, frame / 4);
					UI.Logo.assets[-3]:SetAnimation(Game.AnimationIDs["Run"], 2, 1, frame / 4);
					UI.Logo.assets[3]:SetPosition(frame / scale3 + 4, 1 / scale3, hOffs);
					UI.Logo.assets[-3]:SetPosition(frame / scale3 + 4, 1 / scale3, hOffs);

					-- Center npc
					local scale4 = UI.Logo.assets[4]:GetScale();
					UI.Logo.assets[4]:SetPaused(true);
					UI.Logo.assets[-4]:SetPaused(true);
					UI.Logo.assets[4]:SetAnimation(Game.AnimationIDs["Run"], 2, 1, frame / 4);
					UI.Logo.assets[-4]:SetAnimation(Game.AnimationIDs["Run"], 2, 1, frame / 4);
					UI.Logo.assets[4]:SetPosition(frame / scale4 - 4, 0, -1 + hOffs);
					UI.Logo.assets[-4]:SetPosition(frame / scale4 - 4, 0, -1.2 + hOffs);
				end

				local cutsceneBlendTime = 350;
				local cutsceneBlendSpeed = 0.05;
				if Cutscene.time >= cutsceneBlendTime then

					Game.mainWindow:Show();
					local alpha = (Cutscene.time - cutsceneBlendTime) * cutsceneBlendSpeed;
					if (alpha > 1) then
						alpha = 1;
					end
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
--  Effects							--
--------------------------------------

function FX.Text.CreateSymbol(symbol, x, y, parent, scale, r, g, b, point, level)
	local sInfo = Game.FX.Symbols[symbol];
	local s = {};
	s = CreateFrame("Frame", "TextTestA", parent);
	s:SetWidth(sInfo.fw);
	s:SetHeight(40);
	s:SetScale(scale);
	s:SetPoint(point, x, y);
    s:SetFrameLevel(level);
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

function FX.Text.SetSymbol(symbol, s, level)
	local sInfo = Game.FX.Symbols[symbol];
	s:SetWidth(sInfo.fw);
    s:SetFrameLevel(level);
	s.mask:SetTexture(sInfo.fileID, "CLAMP", "CLAMP")
	s.mask:SetSize(sInfo.w, sInfo.h);
	s.mask:SetPoint("LEFT", sInfo.x, sInfo.y)
end

function FX.Text.CreateWord(word, x, y, parent, spacing, scale, r, g, b, point, level)
	word = string.upper(word)
	if r == nil then r = 1 end
	if g == nil then g = 1 end
	if b == nil then b = 1 end
	if spacing == nil then spacing = 0.8 end
	if scale == nil then scale = 1 end
	if point == nil then point = "CENTER" end;

	local length = #word;
	local w = {};
	w.x = x;
	w.y = y;
	w.parent = parent;
	w.spacing = spacing;
	w.scale = scale;
	w.r = r;
	w.g = g;
	w.b = b;
	w.point = point;
	local offs = 0;
	for	i = 1, length, 1 do
		local char = string.sub(word, i, i);
		w[i] = FX.Text.CreateSymbol(char, x + offs, y, parent, scale, r, g, b, point, level);
		offs = offs + Game.FX.Symbols[char].fw * spacing;
	end

	return w;
end

function FX.Text.SetWord(word, w, level)
	word = string.upper(word)
	local offs = 0;
	local wL = #w;
	for	i = 1, #word, 1 do
		local char = string.sub(word, i, i);
		if i <= #w then
			FX.Text.SetSymbol(char, w[i], level);
			w[i]:Show();
		else
			w[i] = FX.Text.CreateSymbol(char, w.x + (Game.FX.Symbols[char].fw * w.spacing * (i - 1)), w.y, w.parent, w.scale, w.r, w.g, w.b, w.point, level);
		end
	end

	if #w > #word then
		for	i = 1, #w, 1 do
			if i > #word then
				w[i]:Hide();
			end
		end
	end
end

--------------------------------------
--  DEBUGGING						--
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
--  PLayer Input					--
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
--  Character Animations			--
--------------------------------------

function Player.UpdateBlobShadow()
	local scale = (Player.worldPosY / 10 * 0.8);
	local alpha = 0.6 * (1 - scale);
	if alpha < 0 then
		alpha = 0;
	end
	Canvas.dinoShadowBlobFrame:SetAlpha(alpha);
	Canvas.dinoShadowBlobFrame:SetSize(60 + (60 * scale), 60 + (60 * scale));
	local screenPos =  ((1 - ((Player.posX / 12) - 2)) + 1) * 80 - (Player.posX / 5) - 10;	-- TODO : format brain, or just calculate modelscene->screen position for real next time
	Canvas.dinoShadowBlobFrame:SetPoint("BOTTOMLEFT", Canvas.frame, "BOTTOMLEFT", screenPos, Canvas.dinoShadowBlobY - (25 * scale));
end

function Player.CalculateJumpVelocity()
	local distance = Player.worldPosY / Player.CurrentJumpHeight;
	local val =  sin((1 - distance) * PI * 0.9) * 50 + 0.01;
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
	local val = (sin((1 - distance) * PI * 2) * 50 + 0.01);
	--Player.jumpTime = Player.jumpTime - distance;--(Game.UPDATE_INTERVAL * 5);
	val = max(val , 0);
    --return val * 1.7;
	return val;
end

function Player.SetAnimation(name, speed)
	Player.currentAnimation = name;
	Canvas.character:SetAnimation(Game.AnimationIDs[name], 0, speed);
end

--------------------------------------
--  Environment						--
--------------------------------------

--- Create Environment, executed only at initialization.
function Environment.Create()
	Environment.CreateLayer0();
	Environment.CreateLayer1();
	Environment.CreateLayer2();
	Environment.CreateLayer3();
	Environment.CreateLayer4();
	Environment.CreateLayer5();
	Environment.CreateLayer6();
	Environment.CreateLayer7();
	Environment.CreateLayer8();
end

--- Create Closest things to the camera, that occlude the play area
function Environment.CreateLayer0()
-- frame level 60
end

--- Create Extra detail that goes on top of the ground layer (stones, light shafts)
function Environment.CreateLayer1()
-- frame level 52-59 (inclusive)
end

--- Create the Ground frames.
function Environment.CreateLayer2()
    Ground.floorFrames = {}
	Ground.floorTransitionFrames = {}

	local def = Environment.Definitions[Environment.CurrentDefinition].Layer2;

	-- Create the floor frames --
	for k = 1, Environment.Constants.layer2GroundDepth, 1 do
		Ground.floorFrames[k] = Environment.CreateFrame("Ground.floorFrame_" .. k, 0, k - 1 + Ground.floorOffsetY, Game.width, 1, "BOTTOM", 50, def.topTexID, "REPEAT");
		
		-- Blend floor frame
		Ground.floorTransitionFrames[k] = Environment.CreateFrame("Ground.floorEffectFrame_" .. k, 0, k - 1 + Ground.floorOffsetY, Game.width * 2, 1, "BOTTOM", 51, 0, "REPEAT");
		Ground.floorTransitionFrames[k].maskTexture = Ground.floorTransitionFrames[k]:CreateMaskTexture();
		Ground.floorTransitionFrames[k].maskTexture:SetTexture(Environment.Constants.layer2BlendMaskID, "CLAMP", "CLAMP");
		Ground.floorTransitionFrames[k].maskTexture:SetAllPoints(Ground.floorTransitionFrames[k]);
		Ground.floorTransitionFrames[k].texture:AddMaskTexture(Ground.floorTransitionFrames[k].maskTexture);
		Ground.floorTransitionFrames[k]:Hide();
	end	

	Ground.fgFloorFrame = Environment.CreateFrame("Ground.fgFloorFrame", 0, 0, Game.width, Ground.floorOffsetY, "BOTTOM", 51, def.sideTexID, "REPEAT")
	Ground.depthShadow = Environment.CreateFrame("Ground.depthShadow", 0, 0, Game.width, Ground.floorOffsetY * def.depthShadowScale, "BOTTOM", 52, 131963, "CLAMP", {1,0,1,0}, nil, def.depthShadowIntensity);
	Ground.depthShadow2 = Environment.CreateFrame("Ground.depthShadow2", 0, 0, Game.width, Ground.floorOffsetY * def.depthShadowScale, "BOTTOM", 52, 131963, "CLAMP", {1,0,1,0}, nil, def.depthShadowIntensity, "BLEND");
	Ground.rimLightTop = Environment.CreateFrame("Ground.rimLightTop", 0, Ground.floorOffsetY, Game.width, Environment.Constants.layer2GroundDepth + (def.lightRimSize or 0), "BOTTOM", 52, 621343, "CLAMP", {0,1,0,1}, def.lightRimColor, 1, "ADD");
	Ground.rimLightSide = Environment.CreateFrame("Ground.rimLightSide", 0, Ground.floorOffsetY - Environment.Constants.layer2GroundDepth - (def.lightRimSize or 0), Game.width, Environment.Constants.layer2GroundDepth + (def.lightRimSize or 0), "BOTTOM", 52, 621343, "CLAMP", {1,0,1,0}, def.lightRimColor, 1, "ADD");
	Ground.floorLight = Environment.CreateFrame("Ground.floorLight", 0, 0, Game.width, Ground.floorOffsetY + Environment.Constants.layer2GroundDepth, "BOTTOM", 52, 621343, "CLAMP", {1,0,1,0}, {1,1,0.5,0.05}, 1, "ADD");

	-- Blend side frame
	Ground.fgFloorBlendFrame = Environment.CreateFrame("Ground.fgFloorFrame", Game.width * 2, 0, Game.width * 2, Ground.floorOffsetY, "BOTTOM", 51, def.sideTexID, "REPEAT");
	Ground.fgFloorBlendFrame.maskTexture = Ground.fgFloorBlendFrame:CreateMaskTexture();
	Ground.fgFloorBlendFrame.maskTexture:SetTexture(Environment.Constants.layer2BlendMaskID, "CLAMP", "CLAMP");
	Ground.fgFloorBlendFrame.maskTexture:SetAllPoints(Ground.fgFloorBlendFrame);
	Ground.fgFloorBlendFrame.texture:AddMaskTexture(Ground.fgFloorBlendFrame.maskTexture);
	
	Ground.fgFloorBlendFrame:Hide();

	-- Top frames --
	local firstScale = 1;
	local firstScaleY = 1;
	for k = 1, Environment.Constants.layer2GroundDepth, 1 do
		local diff = Environment.Constants.layer2GroundDepth * 3;
		local K = (diff / ((diff - k) + 15)) * 4;
		local scale = (K * 0.5) * def.textureScale;
		--Ground.floorFrames[k].texture:SetTexCoord(-(scale / 3), scale - (scale / 3), scale, scale - ((1 / K) / 8));
		Ground.floorTransitionFrames[k].texture:SetTexCoord(-(scale), scale - (scale), scale, scale - ((1 / K) / 8));
		if k == 1 then
			firstScale = scale;
			firstScaleY = ((1 / K) / 8);
		end
	end

	-- Side frame --
	Ground.fgFloorBlendFrame.texture:SetTexCoord(
		- (firstScale / 3),
		firstScale - (firstScale / 3),
		firstScale - firstScaleY,
		def.textureScale * 1.2
	);
end

--- Create Background 3D scene
function Environment.CreateLayer3()
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer3;
	Environment.l3Spread = def.spread;
	if def.count > Environment.Constants.layer3MaxActors then def.count = Environment.Constants.layer3MaxActors end

	Environment.BGScene = CreateFrame("ModelScene", "Environment.BGScene", Canvas.parentFrame);
	Environment.BGScene:SetPoint("CENTER", Canvas.parentFrame, "CENTER", 0, 0);
    Environment.BGScene:SetSize(Game.width, Game.height);
	Environment.BGScene:SetFrameLevel(10);
    Environment.BGScene:SetCameraPosition(def.camPos[1], def.camPos[2], def.camPos[3]);
	Environment.BGScene:SetFogColor(def.fogColor[1], def.fogColor[2], def.fogColor[3]);
	Environment.BGScene:SetFogFar(def.fogFar);
	Environment.BGScene:SetFogNear(def.fogNear);
	Environment.BGScene:SetCameraFarClip(1000);

	Environment.actors = {};

	Environment.PreSapwn();
end

--- Create Gradient - Near Fog layer
function Environment.CreateLayer4()
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer4;

	Environment.FogNear = CreateFrame("Frame", "Environment.FogNear", Canvas.frame);
	Environment.FogNear:SetSize(Game.width, def.height);
	Environment.FogNear:SetPoint("BOTTOM", 0, Ground.floorOffsetY + (def.offsetY or 0));
	Environment.FogNear.texture = Environment.FogNear:CreateTexture("Environment.VFogNear_texture","BACKGROUND")
	--Environment.FogNear.texture:SetTexture(Environment.Constants.layer4NearFogGradientID, "CLAMP", "CLAMP");
	Environment.FogNear.texture:SetAllPoints(Environment.FogNear);
	--Environment.FogNear.texture:SetTexCoord(def.texCoord[1], def.texCoord[2], def.texCoord[3], def.texCoord[4]);
	--Environment.FogNear.texture:SetVertexColor(def.color[1], def.color[2], def.color[3], def.alpha);
	Environment.FogNear.texture:SetBlendMode(def.blend or "BLEND");
	Environment.FogNear:SetFrameLevel(9);

	Environment.FogNear.maskTexture =  Environment.FogNear:CreateMaskTexture();
	Environment.FogNear.maskTexture:SetTexture(Environment.Constants.layer4NearFogGradientID, "CLAMP", "CLAMP");
	Environment.FogNear.maskTexture:SetSize(Game.width, def.height);
	Environment.FogNear.maskTexture:SetPoint("TOPLEFT", 0, 0);
	--Environment.FogNear.maskTexture:SetTexCoord(def.texCoord[1], def.texCoord[2], def.texCoord[3], def.texCoord[4]);
	
	Environment.FogNear.texture:SetColorTexture(1, 1, 1, 1);
	Environment.FogNear.texture:SetVertexColor(def.color[1], def.color[2], def.color[3], def.alpha);
	Environment.FogNear.texture:AddMaskTexture(Environment.FogNear.maskTexture);
end

--- Custom detail layer (Idk yet)
function Environment.CreateLayer5()
-- frame level = 8
end

--- Create the distance layer that contains 2D silhouettes or bilboards.
function Environment.CreateLayer6()
	Environment.Layer6Frames = {};
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer6;
	local zDepth = def.zDepth or 7;
	local blend = def.blend or nil;
	for i = 1, Environment.Constants.layer6MaxSprites, 1 do
		local pick = floor(Game.Random() * #def.fDefs) + 1;
		local fdef = def.fDefs[pick];

		Environment.Layer6Frames[i] = {};
		Environment.Layer6Frames[i].transition = false;
		Environment.Layer6Frames[i].alpha = 1;

		if fdef.x[1] == fdef.x[2] then
			Environment.Layer6Frames[i].x = fdef.x[1];
		else
			Environment.Layer6Frames[i].x = Game.Lerp(fdef.x[1], fdef.x[2], Game.Random());
		end
		if fdef.y[1] == fdef.y[2] then
			Environment.Layer6Frames[i].y = fdef.y[1];
		else
			Environment.Layer6Frames[i].y = Game.Lerp(fdef.y[1], fdef.y[2], Game.Random());
		end
		if fdef.proportional == true then
			local val = Game.Lerp(fdef.w[1], fdef.w[2], Game.Random());
			Environment.Layer6Frames[i].w = val;
			Environment.Layer6Frames[i].h = val;
		else
			if fdef.w[1] == fdef.w[2] then
				Environment.Layer6Frames[i].w = fdef.w[1];
			else
				Environment.Layer6Frames[i].w = Game.Lerp(fdef.w[1], fdef.w[2], Game.Random());
			end
			if fdef.h[1] == fdef.h[2] then
				Environment.Layer6Frames[i].h = fdef.h[1];
			else
				Environment.Layer6Frames[i].h = Game.Lerp(fdef.h[1], fdef.h[2], Game.Random());
			end
		end
		if fdef.speed[1] == fdef.speed[2] then
			Environment.Layer6Frames[i].speed = fdef.speed[1];
		else
			Environment.Layer6Frames[i].speed = Game.Lerp(fdef.speed[1], fdef.speed[2], Game.Random());
		end

		local texCoord = fdef.texCoord or {0, 1, 0, 1};
		Environment.Layer6Frames[i].frame = Environment.CreateSilhouette(
			"Environment.Layer6Frames[" .. i .. "]",
			Environment.Layer6Frames[i].x, Environment.Layer6Frames[i].y,
			Environment.Layer6Frames[i].w, Environment.Layer6Frames[i].h, "CENTER", zDepth,
			fdef.fileID, "CLAMP", texCoord,
			{Game.Lerp(fdef.color[1][1], fdef.color[2][1], Game.Random()), Game.Lerp(fdef.color[1][2], fdef.color[2][2], Game.Random()), Game.Lerp(fdef.color[1][3], fdef.color[2][3], Game.Random())},
			fdef.alpha, blend, def.mask
		);

		if i <= def.count then
			Environment.Layer6Frames[i].frame:Show();
		else
			Environment.Layer6Frames[i].frame:Hide();
		end
	end
end

--- Create the Skybox atmosphere gradient.
function Environment.CreateLayer7()
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer7;
	local zDepth = def.zDepth or 6;
	Environment.SkyGradient = CreateFrame("Frame", "Environment.SkyGradient", Canvas.frame);
	Environment.SkyGradient:SetPoint("BOTTOM", 0, Ground.floorOffsetY + (def.offsetY or 0));
	Environment.SkyGradient:SetSize(Game.width, def.height);
	Environment.SkyGradient.texture = Environment.SkyGradient:CreateTexture("Environment.SkyGradient_texture","BACKGROUND")
	--Environment.SkyGradient.texture:SetTexture(Environment.Constants.layer7SkyGradientID, "CLAMP", "CLAMP");
	Environment.SkyGradient.texture:SetAllPoints(Environment.SkyGradient);
	--Environment.SkyGradient.texture:SetTexCoord(def.texCoord[1], def.texCoord[2], def.texCoord[3], def.texCoord[4]);
	Environment.SkyGradient.texture:SetVertexColor(def.color[1], def.color[2], def.color[3], def.alpha);
	Environment.SkyGradient.texture:SetBlendMode(def.blend or "BLEND");
	Environment.SkyGradient:SetFrameLevel(zDepth);
	Environment.SkyGradient.maskTexture =  Environment.SkyGradient:CreateMaskTexture();
	Environment.SkyGradient.maskTexture:SetTexture(Environment.Constants.layer7SkyGradientID, "CLAMP", "CLAMP");
	Environment.SkyGradient.maskTexture:SetSize(Game.width, def.height);
	Environment.SkyGradient.maskTexture:SetPoint("TOPLEFT", 0, 0);

	Environment.SkyGradient.texture:SetColorTexture(1, 1, 1, 1);
	Environment.SkyGradient.texture:SetVertexColor(def.color[1], def.color[2], def.color[3], def.alpha);
	Environment.SkyGradient.texture:AddMaskTexture(Environment.SkyGradient.maskTexture);

end

--- Create the Skybox Color frame.
function Environment.CreateLayer8()
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer8;

	Environment.SkyColor = CreateFrame("Frame", "Environment.SkyColor", Canvas.frame);
	Environment.SkyColor:SetWidth(Game.width);
	Environment.SkyColor:SetHeight(Game.height);
	Environment.SkyColor:SetPoint("BOTTOM", 0, 0);
	Environment.SkyColor.texture = Environment.SkyColor:CreateTexture("Environment.SkyColor_texture","BACKGROUND")
	Environment.SkyColor.texture:SetColorTexture(1, 1, 1, 1);
	Environment.SkyColor.texture:SetVertexColor(def.color[1], def.color[2], def.color[3], 1);
	Environment.SkyColor.texture:SetAllPoints(Environment.SkyColor);
	Environment.SkyColor:SetFrameLevel(5);
end

--- Update environment, runs every frame.
function Environment.Update()

	Environment.UpdateLayer0();
	Environment.UpdateLayer1();
	Environment.UpdateLayer2();
	Environment.UpdateLayer3();
	Environment.UpdateLayer4();
	Environment.UpdateLayer5();
	Environment.UpdateLayer6();
	Environment.UpdateLayer7();
	Environment.UpdateLayer8();

	if Environment.isTransitioning == true then
		local cDefL2 = Environment.Definitions[Environment.CurrentDefinition].Layer2;
		local nDefL2 = Environment.Definitions[Environment.NextDefinition].Layer2;
		local cDefL3 = Environment.Definitions[Environment.CurrentDefinition].Layer3;
		local nDefL3 = Environment.Definitions[Environment.NextDefinition].Layer3;
		local cDefL4 = Environment.Definitions[Environment.CurrentDefinition].Layer4;
		local nDefL4 = Environment.Definitions[Environment.NextDefinition].Layer4;
		local cDefL7 = Environment.Definitions[Environment.CurrentDefinition].Layer7;
		local nDefL7 = Environment.Definitions[Environment.NextDefinition].Layer7;
		local cDefL8 = Environment.Definitions[Environment.CurrentDefinition].Layer8;
		local nDefL8 = Environment.Definitions[Environment.NextDefinition].Layer8;
		Environment.transitionTime = Environment.transitionTime + 1;

		if Environment.transitionTime >= 1000 then
			Environment.isTransitioning = false;
			Ground.fgFloorBlendFrame:Hide();
			for k = 1, Environment.Constants.layer2GroundDepth, 1 do
				Ground.floorTransitionFrames[k]:Hide();
			end

			Environment.CurrentDefinition = Environment.NextDefinition;
		end

		if Environment.transitionTime >= Environment.Constants.transitionTimeStart and Environment.transitionTime <= Environment.Constants.transitionTimeStart + Environment.Constants.transitionTimeDuration then
			local time = (Environment.transitionTime - Environment.Constants.transitionTimeStart) / Environment.Constants.transitionTimeDuration;

			-- Layer 2 transition
			local depthShadowIntensity = Game.Lerp(cDefL2.depthShadowIntensity, nDefL2.depthShadowIntensity, time);
			local depthShadowScale = Game.Lerp(cDefL2.depthShadowScale, nDefL2.depthShadowScale, time);
			Ground.depthShadow:SetAlpha(depthShadowIntensity);
			Ground.depthShadow2:SetAlpha(depthShadowIntensity);
			Ground.depthShadow:SetSize(Game.width, Ground.floorOffsetY * depthShadowScale);
			Ground.depthShadow2:SetSize(Game.width, Ground.floorOffsetY * depthShadowScale);
			local lightRimColorR = Game.Lerp(cDefL2.lightRimColor[1], nDefL2.lightRimColor[1], time);
			local lightRimColorG = Game.Lerp(cDefL2.lightRimColor[2], nDefL2.lightRimColor[2], time);
			local lightRimColorB = Game.Lerp(cDefL2.lightRimColor[3], nDefL2.lightRimColor[3], time);
			local lightRimColorA = Game.Lerp(cDefL2.lightRimColor[4], nDefL2.lightRimColor[4], time);
			Ground.rimLightTop.texture:SetVertexColor(lightRimColorR, lightRimColorG, lightRimColorB, lightRimColorA);
			Ground.rimLightSide.texture:SetVertexColor(lightRimColorR, lightRimColorG, lightRimColorB, lightRimColorA);
			local lightRimSize = Game.Lerp(cDefL2.lightRimSize or 0, nDefL2.lightRimSize or 0, time);
			Ground.rimLightTop:SetSize(Game.width, Environment.Constants.layer2GroundDepth + lightRimSize);
			Ground.rimLightSide:SetSize(Game.width, Environment.Constants.layer2GroundDepth + lightRimSize);
			Ground.rimLightSide:ClearAllPoints();
			Ground.rimLightSide:SetPoint("BOTTOM", 0, Ground.floorOffsetY - Environment.Constants.layer2GroundDepth - lightRimSize);

			-- Layer 3 transition
			local camPosX = Game.Lerp(cDefL3.camPos[1], nDefL3.camPos[1], time);
			local camPosY = Game.Lerp(cDefL3.camPos[2], nDefL3.camPos[2], time);
			local camPosZ = Game.Lerp(cDefL3.camPos[3], nDefL3.camPos[3], time);
			Environment.BGScene:SetCameraPosition(camPosX, camPosY, camPosZ);
			local fogR = Game.Lerp(cDefL3.fogColor[1], nDefL3.fogColor[1], time);
			local fogG = Game.Lerp(cDefL3.fogColor[2], nDefL3.fogColor[2], time);
			local fogB = Game.Lerp(cDefL3.fogColor[3], nDefL3.fogColor[3], time);
			Environment.BGScene:SetFogColor(fogR, fogG, fogB);
			local fogFar = Game.Lerp(cDefL3.fogFar, nDefL3.fogFar, time);
			Environment.BGScene:SetFogFar(fogFar);
			local fogNear = Game.Lerp(cDefL3.fogNear, nDefL3.fogNear, time);
			Environment.BGScene:SetFogNear(fogNear);
			
			-- Layer 4 transition
			local l4height = Game.Lerp(cDefL4.height, nDefL4.height, time);
			Environment.FogNear:SetSize(Game.width, l4height);
			Environment.FogNear.maskTexture:SetSize(Game.width, l4height);
			
			local l4offsetY = Game.Lerp(Ground.floorOffsetY + (cDefL4.offsetY or 0), Ground.floorOffsetY + (nDefL4.offsetY or 0), time);
			Environment.FogNear:SetPoint("BOTTOM", 0, l4offsetY);
			local l4colorR = Game.Lerp(cDefL4.color[1], nDefL4.color[1], time);
			local l4colorG = Game.Lerp(cDefL4.color[2], nDefL4.color[2], time);
			local l4colorB = Game.Lerp(cDefL4.color[3], nDefL4.color[3], time);
			local l4alpha = Game.Lerp(cDefL4.alpha, nDefL4.alpha, time);
			Environment.FogNear.texture:SetVertexColor(l4colorR, l4colorG, l4colorB, l4alpha);

			-- Layer 7 transition
			local l7height = Game.Lerp(cDefL7.height, nDefL7.height, time);
			Environment.SkyGradient:SetSize(Game.width, l7height);
			Environment.SkyGradient.maskTexture:SetSize(Game.width, l7height);
			local l7offsetY = Game.Lerp(Ground.floorOffsetY + (cDefL7.offsetY or 0), Ground.floorOffsetY + (nDefL7.offsetY or 0), time);
			Environment.SkyGradient:SetPoint("BOTTOM", 0, l7offsetY);
			local l7colorR = Game.Lerp(cDefL7.color[1], nDefL7.color[1], time);
			local l7colorG = Game.Lerp(cDefL7.color[2], nDefL7.color[2], time);
			local l7colorB = Game.Lerp(cDefL7.color[3], nDefL7.color[3], time);
			local l7alpha = Game.Lerp(cDefL7.alpha, nDefL7.alpha, time);
			Environment.SkyGradient.texture:SetVertexColor(l7colorR, l7colorG, l7colorB, l7alpha);

			-- Layer 8 transition
			local l8colorR = Game.Lerp(cDefL8.color[1], nDefL8.color[1], time);
			local l8colorG = Game.Lerp(cDefL8.color[2], nDefL8.color[2], time);
			local l8colorB = Game.Lerp(cDefL8.color[3], nDefL8.color[3], time);
			Environment.SkyColor.texture:SetVertexColor(l8colorR, l8colorG, l8colorB, 1);
		end

		if Environment.transitionTime == 200 then
			Ground.fgFloorBlendFrame:Show();
			Ground.fgFloorBlendFrame.texture:SetTexture(nDefL2.sideTexID, "REPEAT", "REPEAT");
			for k = 1, Environment.Constants.layer2GroundDepth, 1 do
				Ground.floorTransitionFrames[k]:Show();
				Ground.floorTransitionFrames[k].texture:SetTexture(nDefL2.sideTexID, "REPEAT", "REPEAT");
			end
		end

		if Environment.transitionTime >= 200 then
			-- blend layer 2
			Ground.fgFloorBlendFrame:ClearAllPoints(); 
			local xOffset =  (Game.width * 1.2) - ((Environment.transitionTime - 200) * 1.3 * Game.speed);
			Ground.fgFloorBlendFrame:SetPoint("BOTTOM", xOffset, 0);
			for k = 1, Environment.Constants.layer2GroundDepth, 1 do
				Ground.floorTransitionFrames[k]:SetPoint("BOTTOM", xOffset, k - 1 + Ground.floorOffsetY);
			end
		end
		
		if Environment.transitionTime < 600 and Environment.transitionTime >= 200 then
			-- Layer 6 transition
			for i = 1, Environment.Constants.layer6MaxSprites, 1 do
				if Environment.Layer6Frames[i].alpha > 0 then
					Environment.Layer6Frames[i].alpha = Environment.Layer6Frames[i].alpha - 0.003;
					Environment.Layer6Frames[i].frame:SetAlpha(Environment.Layer6Frames[i].alpha);
				end
			end
		end

		if Environment.transitionTime > 600 then
			-- Layer 6 transition 2
			for i = 1, Environment.Constants.layer6MaxSprites, 1 do
				if Environment.Layer6Frames[i].alpha < 1 then
					Environment.Layer6Frames[i].alpha = Environment.Layer6Frames[i].alpha + 0.003;
					Environment.Layer6Frames[i].frame:SetAlpha(Environment.Layer6Frames[i].alpha);
				end
			end
		end

		if Environment.transitionTime == 600 then
			for i = 1, Environment.Constants.layer6MaxSprites, 1 do
				local def = Environment.Definitions[Environment.NextDefinition].Layer6;
				local pick = floor(Game.Random() * #def.fDefs) + 1;
				local fdef = def.fDefs[pick];

				--Environment.Layer6Frames[i].transition = false;
				
				if fdef.x[1] == fdef.x[2] then
					Environment.Layer6Frames[i].x = fdef.x[1];
				else
					Environment.Layer6Frames[i].x = Game.Lerp(fdef.x[1], fdef.x[2], Game.Random());
				end
				if fdef.y[1] == fdef.y[2] then
					Environment.Layer6Frames[i].y = fdef.y[1];
				else
					Environment.Layer6Frames[i].y = Game.Lerp(fdef.y[1], fdef.y[2], Game.Random());
				end
				if fdef.proportional == true then
					local val = Game.Lerp(fdef.w[1], fdef.w[2], Game.Random());
					Environment.Layer6Frames[i].w = val;
					Environment.Layer6Frames[i].h = val;
				else
					if fdef.w[1] == fdef.w[2] then
						Environment.Layer6Frames[i].w = fdef.w[1];
					else
						Environment.Layer6Frames[i].w = Game.Lerp(fdef.w[1], fdef.w[2], Game.Random());
					end
					if fdef.h[1] == fdef.h[2] then
						Environment.Layer6Frames[i].h = fdef.h[1];
					else
						Environment.Layer6Frames[i].h = Game.Lerp(fdef.h[1], fdef.h[2], Game.Random());
					end
				end
				if fdef.speed[1] == fdef.speed[2] then
					Environment.Layer6Frames[i].speed = fdef.speed[1];
				else
					Environment.Layer6Frames[i].speed = Game.Lerp(fdef.speed[1], fdef.speed[2], Game.Random());
				end
		
				Environment.ChangeSilhouette(
					Environment.Layer6Frames[i].frame,
					"Environment.Layer6Frames[" .. i .. "]",
					Environment.Layer6Frames[i].x, Environment.Layer6Frames[i].y,
					Environment.Layer6Frames[i].w, Environment.Layer6Frames[i].h, "CENTER", def.zDepth or 7,
					fdef.fileID, "CLAMP", fdef.texCoord or {0, 1, 0, 1},
					{Game.Lerp(fdef.color[1][1], fdef.color[2][1], Game.Random()), Game.Lerp(fdef.color[1][2], fdef.color[2][2], Game.Random()), Game.Lerp(fdef.color[1][3], fdef.color[2][3], Game.Random())},
					nil, def.blend, def.mask
				);

				if i <= def.count then
					Environment.Layer6Frames[i].frame:Show();
				else
					Environment.Layer6Frames[i].frame:Hide();
				end
			end
		end

		if Environment.transitionTime == 300 + 200 then
			Ground.fgFloorFrame.texture:SetTexture(nDefL2.sideTexID, "REPEAT", "REPEAT");

			for k = 1, Environment.Constants.layer2GroundDepth, 1 do
				Ground.floorFrames[k].texture:SetTexture(nDefL2.topTexID, "REPEAT", "REPEAT");
			end
		end
	end
end

-- Update foreground occluders
function Environment.UpdateLayer0()

end

-- Update extra detail for ground layer
function Environment.UpdateLayer1()

end

--- Update the Ground frames.
function Environment.UpdateLayer2()
	local def = Environment.Definitions[Environment.CurrentDefinition].Layer2;
	
	if Environment.isTransitioning and Environment.transitionTime > 500 then
		def = Environment.Definitions[Environment.NextDefinition].Layer2;
	end

	-- Top frames --
	local offset = (Game.time * 0.15625 * Game.speed * def.textureScale);
	local firstScale = 1;
	local firstScaleY = 1;
	local kOfs = 15;
	for k = 1, Environment.Constants.layer2GroundDepth, 1 do
		local diff = Environment.Constants.layer2GroundDepth * 3;
		local K = (diff / ((diff - k) + kOfs)) * 4;
		local scale = (K * 0.5) * def.textureScale;
		Ground.floorFrames[k].texture:SetTexCoord(offset - (scale / 3), offset + scale - (scale / 3), scale, scale - ((1 / K) / 8));
		--Ground.floorTransitionFrames[k].texture:SetTexCoord(offset - (scale), offset + scale - (scale), scale, scale - ((1 / K) / 8));
		if k == 1 then
			firstScale = scale;
			firstScaleY = ((1 / K) / 8);
		end
	end

	-- Side frame --
	Ground.fgFloorFrame.texture:SetTexCoord(
		offset - (firstScale / 3),
		offset + firstScale - (firstScale / 3),
		firstScale - firstScaleY,
		def.textureScale * 1.2
	);
end

--- Update Background 3D scene
function Environment.UpdateLayer3()

	-- determine if new environment model should be spawned
	if Game.travelledDistance >= Environment.objPosition + Environment.l3Spread then
		Environment.objPosition = Game.travelledDistance;
		Environment.SpawnObject(false);
	end

	-- loop through all the objects, and update them
	for k = 1, Environment.totalObjects, 1 do
		if Environment.actors[k].active == true then

			-- move
			Environment.actors[k].positionY = Environment.actors[k].positionY + ((Game.speed / 50) / Environment.actors[k].scale);

			-- reset 
			if Environment.actors[k].positionY * Environment.actors[k].scale > 5 then
				-- Environment.actors[k].active = false;
				-- Environment.actors[k].frame:Hide()
				-- Environment.actors[k].positionY = -50 / Environment.actors[k].scale;
			end

			if Environment.actors[k].positionY * Environment.actors[k].scale > 20 then
				Environment.actors[k].active = false;
				Environment.actors[k].frame:Hide()
			end

			Environment.actors[k].frame:SetPosition(Environment.actors[k].positionX, Environment.actors[k].positionY, Environment.actors[k].positionZ);
		end
	end
end

function Environment.PreSapwn()
	for k = 1, 20, 1 do
		Environment.SpawnObject(true)
	end
end

function Environment.SpawnObject(preSpawn)

	local defName = Environment.CurrentDefinition;
	if Environment.isTransitioning == true then
		defName = Environment.NextDefinition;
	end
	local nDefL3 = Environment.Definitions[defName].Layer3;
	local pick = floor(Game.Random() * #nDefL3.fDefs) + 1;
	local fdef = nDefL3.fDefs[pick];

	local k = Environment.GetAvailableGameObject();
	Environment.actors[k].active = true;
	Environment.actors[k].frame:Show();
	Environment.actors[k].frame:SetModelByFileID(fdef.fileID);
	Environment.actors[k].frame:SetAnimation(Game.AnimationIDs[fdef.animation or "Stand"], 0, 1);
	
	-- pos
	if #fdef.x == 1 then
		Environment.actors[k].positionX = fdef.x[1];
	else
		Environment.actors[k].positionX = Game.Lerp(fdef.x[1], fdef.x[2], Game.Random());
	end

	if preSpawn then
		if #fdef.y == 1 then
			Environment.actors[k].positionY = fdef.y[1];
		else
			Environment.actors[k].positionY = Game.Lerp(fdef.y[1], fdef.y[2], Game.Random());
		end
	else
		Environment.actors[k].positionY = -40;
	end

	if #fdef.z == 1 then
		Environment.actors[k].positionZ = fdef.z[1];
	else
		Environment.actors[k].positionZ = Game.Lerp(fdef.z[1], fdef.z[2], Game.Random());
	end
	
	-- rot
	if #fdef.yaw == 1 then
		Environment.actors[k].frame:SetYaw(rad(fdef.yaw[1]));
	else
		Environment.actors[k].frame:SetYaw(rad(Game.Lerp(fdef.yaw[1], fdef.yaw[2], Game.Random())));
	end
	if #fdef.pitch == 1 then
		Environment.actors[k].frame:SetPitch(rad(fdef.pitch[1]));
	else
		Environment.actors[k].frame:SetPitch(rad(Game.Lerp(fdef.pitch[1], fdef.pitch[2], Game.Random())));
	end
	if #fdef.roll == 1 then
		Environment.actors[k].frame:SetRoll(rad(fdef.roll[1]));
	else
		Environment.actors[k].frame:SetRoll(rad(Game.Lerp(fdef.roll[1], fdef.roll[2], Game.Random())));
	end

	-- scale
	if #fdef.scale == 1 then
		Environment.actors[k].scale = fdef.scale[1];
		Environment.actors[k].frame:SetScale(Environment.actors[k].scale);
	else
		Environment.actors[k].scale = Game.Lerp(fdef.scale[1], fdef.scale[2], Game.Random());
		Environment.actors[k].frame:SetScale(Environment.actors[k].scale);
	end


end

function Environment.GetAvailableGameObject()
	local firstAvailable = -1;
	for k = 1, Environment.totalObjects, 1 do
		if firstAvailable == -1 then
			if Environment.actors[k].active == false then
				firstAvailable = k;
				break;
			end
		end
	end

	if firstAvailable ~= -1 then
		return firstAvailable;
	else
		return Environment.CreateNewGameObject();
	end
end

function Environment.CreateNewGameObject()
	Environment.totalObjects = Environment.totalObjects + 1;
	local idx = Environment.totalObjects;
	Environment.actors[idx] = {
		active = false,
		scale = 1,
		positionX = 0,
		positionY = 0,
		positionZ = 0,
		frame = Environment.BGScene:CreateActor("BGScene.actor_" .. idx);
	}
	return idx;
end

--- Update Gradient - Near Fog layer
--- Doesn't really have an update, just blending during transition.
function Environment.UpdateLayer4()

end

--- Update Custom detail layer (Idk yet)
function Environment.UpdateLayer5()

end

--- Update the distant 2D silhouettes
function Environment.UpdateLayer6()
	for i = 1, #Environment.Layer6Frames, 1 do
		Environment.Layer6Frames[i].x = Environment.Layer6Frames[i].x - (Environment.Layer6Frames[i].speed * Environment.Constants.layer6SpeedAdjust * Game.speed);
		if Environment.Layer6Frames[i].x + (Environment.Layer6Frames[i].w / 2) < -Game.width / 2 then
			-- respawn
			Environment.Layer6Frames[i].x = Game.width / 2 + Environment.Layer6Frames[i].w / 2;
		end
		Environment.Layer6Frames[i].frame:ClearAllPoints();
		Environment.Layer6Frames[i].frame:SetPoint("CENTER", Environment.Layer6Frames[i].x, Environment.Layer6Frames[i].y);
	end
end

--- Update the sky gradient.
--- Doesn't really have an update, just blending during transition.
function Environment.UpdateLayer7()

end

--- Update the sky color.
--- Doesn't really have an update, just blending during transition.
function Environment.UpdateLayer8()

end

--- Create a texture frame in the Canvas.
---@param name string The name of the frame
---@param x number X position in screen space
---@param y number Y position in screen space
---@param w number Frame with
---@param h number Frame height
---@param point string Anchor point in Canvas
---@param frameLevel number Used for Z sorting the canvas frames
---@param textureID number File ID of the texture to be rendered on the frame
---@param wrap string Texture wrap mode
---@param texCoord table Texture coordinates
---@param color table Vertex color
---@param alpha number Alpha value
---@param blendMode string Frame blend mode operation
---@return table frame The create frame reference 
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

--- Create a silhouette frame in the Canvas.
---@param name string The name of the frame
---@param x number X position in screen space
---@param y number Y position in screen space
---@param w number Frame with
---@param h number Frame height
---@param point string Anchor point in Canvas
---@param frameLevel number Used for Z sorting the canvas frames
---@param textureID number File ID of the texture to be rendered on the frame
---@param wrap string Texture wrap mode
---@param texCoord table Texture coordinates
---@param color table Vertex color
---@param alpha number Alpha value
---@param blendMode string Frame blend mode operation
---@return table frame The create frame reference 
function Environment.CreateSilhouette(name, x, y, w, h, point, frameLevel, textureID, wrap, texCoord, color, alpha, blendMode, mask)
	if wrap == nil then wrap = "REPEAT" end

	local f = CreateFrame("Frame", name, Canvas.frame);
	f:SetSize(w, h);
	f:SetPoint(point, x, y);
	f.texture = f:CreateTexture(name .. ".texture","BACKGROUND");

	f.texture:SetAllPoints(f);
	if texCoord ~= nil then 
		f.texture:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4]);
	end
	if blendMode ~= nil then
		f.texture:SetBlendMode(blendMode);
	end
	if alpha ~= nil then
		f:SetAlpha(alpha);
	end
	f:SetFrameLevel(frameLevel);
	-- f.maskTexture =  f:CreateMaskTexture();
	-- f.maskTexture:SetTexture(textureID, "CLAMP", "CLAMP");
	-- f.maskTexture:SetSize(w, h);
	-- f.maskTexture:SetPoint("TOPLEFT", 0, 0);
	

	-- if mask == true then
	-- 	f.texture:SetColorTexture(color[1], color[2], color[3], color[4]);
	-- 	f.texture:AddMaskTexture(f.maskTexture);
	-- else
		f.texture:SetTexture(textureID, wrap, wrap);
		f.texture:SetVertexColor(color[1], color[2], color[3], color[4]);
	-- end

	return f;
end

function Environment.ChangeSilhouette(f, name, x, y, w, h, point, frameLevel, textureID, wrap, texCoord, color, alpha, blendMode, mask)
	if wrap == nil then wrap = "REPEAT" end

	f:SetSize(w, h);
	f:SetPoint(point, x, y);

	if texCoord ~= nil then 
		f.texture:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4]);
	end
	if blendMode ~= nil then
		f.texture:SetBlendMode(blendMode);
	end
	if alpha ~= nil then
		f:SetAlpha(alpha);
	end
	f:SetFrameLevel(frameLevel);
	
	-- f.maskTexture =  f:CreateMaskTexture();
	-- f.maskTexture:SetTexture(textureID, "CLAMP", "CLAMP");
	-- f.maskTexture:SetSize(w, h);
	-- f.maskTexture:SetPoint("TOPLEFT", 0, 0);
	

	-- if mask == true then
	-- 	f.texture:SetColorTexture(color[1], color[2], color[3], color[4]);
	-- 	f.texture:AddMaskTexture(f.maskTexture);
	-- else
		f.texture:SetTexture(textureID, wrap, wrap);
		f.texture:SetVertexColor(color[1], color[2], color[3], color[4]);
	-- end

	return f;
end

function Environment.Blend(defName)
	if Environment.isTransitioning == true then return end
	Environment.NextDefinition = defName;
	Environment.isTransitioning = true;
	Environment.transitionTime = 0;
	local nDefL3 = Environment.Definitions[defName].Layer3;
	Environment.l3Spread = nDefL3.spread or 5;

	-- for i = 1, #Environment.Layer6Frames, 1 do
	-- 	Environment.Layer6Frames[i].transition = true;
	-- end
	
end

--------------------------------------
--  Physics							--
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
			local objCol = definition.collider or { x = 0, y = 0, w = 2, h = 2 };
			local oScale = definition.scale or 1;
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
	gameObject.definition.danger = gameObject.definition.danger or 0
	gameObject.definition.collectible = gameObject.definition.collectible or 0
	-- Danger 0 : Can be in contact with object anywhere
	if gameObject.definition.danger == 0 then

	-- Danger 1 : Cant' touch object at all
	elseif gameObject.definition.danger == 1 then
		Game.Over(true);
	-- Danger 2 : Can only touch object from the top
	elseif gameObject.definition.danger == 2 then
		local px, py, pz = Canvas.character:GetPosition();
		local objCol = gameObject.definition.collider or { x = 0, y = 0, w = 2, h = 2 };
		if gameObject.alive == true then
			if pz > gameObject.position.y + (objCol.h / 4) and Player.falling == true then
				-- kill
				gameObject.ai.kill = true;
				gameObject.alive = false;
			else
				Game.Over(true);
			end
		end
	end

	-- Collectible 1 : Coin
	if gameObject.definition.collectible == 1 then
		gameObject.ai.collect = true;
	end
end

function Physics.CheckCollision(objectA, objectB)
	local colliderA = objectA.definition.collider or { x = 0, y = 0, w = 2, h = 2 };
	local colliderB = objectB.definition.collider or { x = 0, y = 0, w = 2, h = 2 };
	local px, py, pz = objectA.actor:GetPosition();
	local ox, oy, oz = objectB.actor:GetPosition();
	local pScale = objectA.definition.scale or 1;
	local oScale = objectB.definition.scale or 1;
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
--  Editor					        --
--------------------------------------

function Editor.CreateUI()
    -- TODO : write a ui for puzzle generator, need to be able to pick from the list of available game objects and place them on screen
end

function Editor.Load()
    UI.MainMenu.frame:Hide();
    Editor.CreateUI();
end

--------------------------------------
--  Initialization					--
--------------------------------------

function Game.Initialize()
	-- Load data
	Game.CreateObjectDefinitions(); -- Has to be done in a function at the start because some table values will reference functions
    Game.CreatePuzzleData();

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
	if Game.devMode then
		Game.mainWindow:Show();
        if Game.debugDrawTrails then
		    Canvas.DEBUG_CreateCaracterTrails();
        end
        if Game.runWithEditor then
            Editor.Load();
        else
            Game.NewGame();
        end
	end

	Game.initialized = true;
end

--------------------------------------
--  Update loop						--
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

			if Game.devMode then
                if Game.debugDrawTrails then
				    Canvas.DEBUG_UpdateCharacterTrails();
                end
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