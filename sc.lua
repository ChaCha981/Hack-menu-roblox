--==============================================================
-- XEIREN 5V5 COMBAT HUB
-- OLD COMPACT UI • GROW ANIMATION • STAR EFFECTS
-- ESP AUTO REFRESH • SMOOTH 360 AIM
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--==============================================================
-- SETTINGS
--==============================================================

local S = {
	AimEnabled = false,
	Full360 = true,
	LockStrength = 500,
	AimSpeed = 70,
	AimSmoothness = 65,
	AimDistance = 5000,
	AimFOV = 999,
	AimPart = "Head",

	ESPEnabled = false,
	ESPLine = true,
	ESPBox = true,
	ESPName = true,
	ESPHealth = true,
	ESPDistance = true,
	ESPHead = false,
	ESPAlwaysOnTop = true,
	ESPTeamColor = false,
	ESPMaxDistance = 5000,

	TeamCheck = true,
	WallCheck = false,

	FlyEnabled = false,
	FlySpeed = 70,
	FlyVerticalSpeed = 60,

	SpeedEnabled = false,
	SpeedRun = 32,

	SuperJumpEnabled = false,
	JumpPower = 100,

	NoRecoil = false,
	NoReload = false,

	FPSBoost = false,
	ShowFPS = true,
}

local exited = false
local opened = false

--==============================================================
-- CHARACTER
--==============================================================

local Character
local Humanoid
local RootPart
local OriginalSpeed = 16
local OriginalJump = 50

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid", 10)
	RootPart = char:WaitForChild("HumanoidRootPart", 10)

	if Humanoid then
		OriginalSpeed = Humanoid.WalkSpeed
		OriginalJump = Humanoid.JumpPower
	end
end

if LP.Character then
	SetupCharacter(LP.Character)
end

LP.CharacterAdded:Connect(function(char)
	task.wait(0.15)
	SetupCharacter(char)
end)

--==============================================================
-- GUI
--==============================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "XeirenCombatHub"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999
GUI.Parent = PlayerGui

local BG = Color3.fromRGB(10, 11, 18)
local PANEL = Color3.fromRGB(18, 19, 29)
local PANEL2 = Color3.fromRGB(25, 26, 39)
local TEXT = Color3.fromRGB(240, 240, 248)
local SUB = Color3.fromRGB(145, 148, 170)
local ACCENT = Color3.fromRGB(145, 85, 255)
local BLUE = Color3.fromRGB(90, 155, 255)
local GREEN = Color3.fromRGB(70, 220, 130)
local RED = Color3.fromRGB(240, 75, 100)

--==============================================================
-- PASSWORD
--==============================================================

local Login = Instance.new("Frame")
Login.Size = UDim2.fromOffset(330, 190)
Login.Position = UDim2.fromScale(.5, .5)
Login.AnchorPoint = Vector2.new(.5, .5)
Login.BackgroundColor3 = BG
Login.BorderSizePixel = 0
Login.Parent = GUI

Instance.new("UICorner", Login).CornerRadius = UDim.new(0, 12)

local ls = Instance.new("UIStroke", Login)
ls.Color = ACCENT
ls.Thickness = 1.5

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, -20, 0, 35)
LoginTitle.Position = UDim2.fromOffset(10, 10)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Text = "XEIREN 5V5"
LoginTitle.TextColor3 = TEXT
LoginTitle.TextSize = 22
LoginTitle.Font = Enum.Font.GothamBlack
LoginTitle.Parent = Login

local LoginSub = Instance.new("TextLabel")
LoginSub.Size = UDim2.new(1, -20, 0, 22)
LoginSub.Position = UDim2.fromOffset(10, 45)
LoginSub.BackgroundTransparency = 1
LoginSub.Text = "Enter password"
LoginSub.TextColor3 = SUB
LoginSub.TextSize = 12
LoginSub.Font = Enum.Font.Gotham
LoginSub.Parent = Login

local Pass = Instance.new("TextBox")
Pass.Size = UDim2.new(1, -40, 0, 38)
Pass.Position = UDim2.fromOffset(20, 75)
Pass.BackgroundColor3 = PANEL2
Pass.BorderSizePixel = 0
Pass.PlaceholderText = "Password..."
Pass.Text = ""
Pass.TextColor3 = TEXT
Pass.PlaceholderColor3 = SUB
Pass.TextSize = 13
Pass.Font = Enum.Font.Gotham
Pass.ClearTextOnFocus = false
Pass.Parent = Login

Instance.new("UICorner", Pass).CornerRadius = UDim.new(0, 7)

local Enter = Instance.new("TextButton")
Enter.Size = UDim2.new(1, -40, 0, 38)
Enter.Position = UDim2.fromOffset(20, 125)
Enter.BackgroundColor3 = ACCENT
Enter.BorderSizePixel = 0
Enter.Text = "ENTER"
Enter.TextColor3 = Color3.new(1,1,1)
Enter.TextSize = 13
Enter.Font = Enum.Font.GothamBold
Enter.Parent = Login

Instance.new("UICorner", Enter).CornerRadius = UDim.new(0, 7)

--==============================================================
-- MAIN MENU
--==============================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(0, 0)
Main.Position = UDim2.fromScale(.5, .5)
Main.AnchorPoint = Vector2.new(.5, .5)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = ACCENT
MainStroke.Thickness = 1
MainStroke.Transparency = .15

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = .94

--==============================================================
-- BACKGROUND STARS
--==============================================================

local Stars = Instance.new("Frame")
Stars.Size = UDim2.fromScale(1,1)
Stars.BackgroundTransparency = 1
Stars.ClipsDescendants = true
Stars.ZIndex = 0
Stars.Parent = Main

local function Star()
	if not Main.Visible then return end

	local x = math.random(3,97)/100

	local star = Instance.new("TextLabel")
	star.BackgroundTransparency = 1
	star.Text = math.random(1,3) == 1 and "✦" or "·"
	star.TextSize = math.random(7,14)
	star.Font = Enum.Font.GothamBold
	star.TextColor3 = Color3.fromRGB(
		math.random(130,190),
		math.random(120,180),
		255
	)
	star.TextTransparency = .1
	star.Size = UDim2.fromOffset(20,20)
	star.Position = UDim2.fromScale(x,-.06)
	star.ZIndex = 0
	star.Parent = Stars

	local duration = math.random(35,70)/10

	TweenService:Create(
		star,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{
			Position = UDim2.fromScale(
				math.clamp(x + math.random(-8,8)/100,0,1),
				1.08
			),
			TextTransparency = 1
		}
	):Play()

	task.delay(duration + .1,function()
		if star then star:Destroy() end
	end)
end

task.spawn(function()
	while not exited do
		task.wait(.22)
		Star()
	end
end)

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,48)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0,12)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1,-100,1,0)
HeaderTitle.Position = UDim2.fromOffset(14,0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "XEIREN 5V5 COMBAT HUB"
HeaderTitle.TextColor3 = TEXT
HeaderTitle.TextSize = 14
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 3
HeaderTitle.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(70,30)
Status.Position = UDim2.new(1,-78,0,9)
Status.BackgroundTransparency = 1
Status.Text = "READY"
Status.TextColor3 = GREEN
Status.TextSize = 9
Status.Font = Enum.Font.GothamBold
Status.ZIndex = 3
Status.Parent = Header

-- Header shimmer
local Shimmer = Instance.new("Frame")
Shimmer.Size = UDim2.fromOffset(70,2)
Shimmer.Position = UDim2.new(0,-80,1,-2)
Shimmer.BackgroundColor3 = ACCENT
Shimmer.BorderSizePixel = 0
Shimmer.ZIndex = 4
Shimmer.Parent = Header

task.spawn(function()
	while not exited do
		task.wait(2)

		if Main.Visible then
			Shimmer.Position = UDim2.new(0,-80,1,-2)

			TweenService:Create(
				Shimmer,
				TweenInfo.new(1.1,Enum.EasingStyle.Linear),
				{Position = UDim2.new(1,10,1,-2)}
			):Play()
		end
	end
end)

--==============================================================
-- DRAG
--==============================================================

local function Drag(obj, handle)
	local dragging = false
	local start
	local original

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			start = input.Position
			original = obj.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local d = input.Position - start

			obj.Position = UDim2.new(
				original.X.Scale,
				original.X.Offset+d.X,
				original.Y.Scale,
				original.Y.Offset+d.Y
			)
		end
	end)
end

Drag(Main,Header)

--==============================================================
-- SIDEBAR
--==============================================================

local Side = Instance.new("Frame")
Side.Size = UDim2.new(0,105,1,-60)
Side.Position = UDim2.fromOffset(9,55)
Side.BackgroundColor3 = PANEL
Side.BorderSizePixel = 0
Side.ZIndex = 2
Side.Parent = Main

Instance.new("UICorner",Side).CornerRadius = UDim.new(0,8)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Side

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-124,1,-60)
Content.Position = UDim2.fromOffset(119,55)
Content.BackgroundColor3 = PANEL
Content.BorderSizePixel = 0
Content.ZIndex = 2
Content.Parent = Main

Instance.new("UICorner",Content).CornerRadius = UDim.new(0,8)

local Pages = {}

local function Page(name)
	local p = Instance.new("ScrollingFrame")
	p.Name = name
	p.Size = UDim2.new(1,-14,1,-14)
	p.Position = UDim2.fromOffset(7,7)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.ScrollBarImageTransparency = .35
	p.CanvasSize = UDim2.new()
	p.Visible = false
	p.ZIndex = 3
	p.Parent = Content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,5)
	layout.Parent = p

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		p.CanvasSize = UDim2.fromOffset(
			0,
			layout.AbsoluteContentSize.Y+10
		)
	end)

	Pages[name] = p
	return p
end

local AimPage = Page("Aim")
local ESPPage = Page("ESP")
local MovePage = Page("Move")
local SystemPage = Page("System")

local Tabs = {}

local function ShowPage(name)
	for n,p in pairs(Pages) do
		p.Visible = n == name
	end

	for n,b in pairs(Tabs) do
		b.BackgroundColor3 =
			n == name
			and ACCENT
			or PANEL2
	end
end

local function Tab(name,text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,40)
	b.BackgroundColor3 = PANEL2
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = TEXT
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 3
	b.Parent = Side

	Instance.new("UICorner",b).CornerRadius = UDim.new(0,7)

	Tabs[name] = b

	b.MouseEnter:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(.12),
			{Size = UDim2.new(1,-6,0,42)}
		):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(.12),
			{Size = UDim2.new(1,-10,0,40)}
		):Play()
	end)

	b.MouseButton1Click:Connect(function()
		ShowPage(name)
	end)

	return b
end

Tab("Aim","AIM")
Tab("ESP","ESP")
Tab("Move","MOVE")
Tab("System","SYSTEM")

--==============================================================
-- UI ROW
--==============================================================

local function Row(parent,h)
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1,0,0,h or 34)
	r.BackgroundColor3 = PANEL2
	r.BorderSizePixel = 0
	r.ZIndex = 4
	r.Parent = parent

	Instance.new("UICorner",r).CornerRadius = UDim.new(0,7)

	return r
end

local function Toggle(parent,text,get,set)
	local r = Row(parent,34)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-65,1,0)
	label.Position = UDim2.fromOffset(10,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TEXT
	label.TextSize = 10
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 5
	label.Parent = r

	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(40,19)
	b.Position = UDim2.new(1,-50,.5,-9)
	b.BackgroundColor3 = Color3.fromRGB(45,46,60)
	b.BorderSizePixel = 0
	b.Text = ""
	b.ZIndex = 5
	b.Parent = r

	Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(15,15)
	knob.Position = UDim2.fromOffset(2,2)
	knob.BackgroundColor3 = SUB
	knob.BorderSizePixel = 0
	knob.ZIndex = 6
	knob.Parent = b

	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

	local function Update()
		local on = get()

		TweenService:Create(
			b,
			TweenInfo.new(.14),
			{
				BackgroundColor3 =
					on and ACCENT or Color3.fromRGB(45,46,60)
			}
		):Play()

		TweenService:Create(
			knob,
			TweenInfo.new(.14,Enum.EasingStyle.Back),
			{
				Position =
					on
					and UDim2.fromOffset(23,2)
					or UDim2.fromOffset(2,2),

				BackgroundColor3 =
					on and Color3.new(1,1,1) or SUB
			}
		):Play()
	end

	b.MouseButton1Click:Connect(function()
		set(not get())
		Update()

		TweenService:Create(
			b,
			TweenInfo.new(.08,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,true),
			{Size = UDim2.fromOffset(44,21)}
		):Play()
	end)

	Update()
end

local function Slider(parent,text,min,max,get,set)
	local r = Row(parent,47)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-70,0,19)
	label.Position = UDim2.fromOffset(9,2)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TEXT
	label.TextSize = 10
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 5
	label.Parent = r

	local value = Instance.new("TextLabel")
	value.Size = UDim2.fromOffset(55,18)
	value.Position = UDim2.new(1,-62,0,2)
	value.BackgroundTransparency = 1
	value.TextColor3 = BLUE
	value.TextSize = 9
	value.Font = Enum.Font.GothamBold
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.ZIndex = 5
	value.Parent = r

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1,-18,0,5)
	bar.Position = UDim2.fromOffset(9,30)
	bar.BackgroundColor3 = Color3.fromRGB(43,44,57)
	bar.BorderSizePixel = 0
	bar.ZIndex = 5
	bar.Parent = r

	Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0,1)
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.ZIndex = 6
	fill.Parent = bar

	Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

	local dragging = false

	local function Update()
		local v = get()
		local pct = math.clamp((v-min)/(max-min),0,1)

		fill.Size = UDim2.fromScale(pct,1)
		value.Text = tostring(math.floor(v))
	end

	local function SetX(x)
		local pct = math.clamp(
			(x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,
			0,1
		)

		set(math.floor(min+(max-min)*pct))
		Update()
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and
			(input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then

			SetX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	Update()
end

--==============================================================
-- AIM UI
--==============================================================

Toggle(AimPage,"Aim Assist",
	function() return S.AimEnabled end,
	function(v) S.AimEnabled=v end)

Toggle(AimPage,"360° Lock",
	function() return S.Full360 end,
	function(v) S.Full360=v end)

Toggle(AimPage,"Team Check",
	function() return S.TeamCheck end,
	function(v) S.TeamCheck=v end)

Toggle(AimPage,"Wall Check",
	function() return S.WallCheck end,
	function(v) S.WallCheck=v end)

Slider(AimPage,"Lock Strength",1,1000,
	function() return S.LockStrength end,
	function(v) S.LockStrength=v end)

Slider(AimPage,"Aim Speed",1,100,
	function() return S.AimSpeed end,
	function(v) S.AimSpeed=v end)

Slider(AimPage,"Aim Smoothness",1,100,
	function() return S.AimSmoothness end,
	function(v) S.AimSmoothness=v end)

Slider(AimPage,"Aim Distance",50,5000,
	function() return S.AimDistance end,
	function(v) S.AimDistance=v end)

Slider(AimPage,"Aim FOV",10,999,
	function() return S.AimFOV end,
	function(v) S.AimFOV=v end)

--==============================================================
-- ESP UI
--==============================================================

Toggle(ESPPage,"ESP",
	function() return S.ESPEnabled end,
	function(v) S.ESPEnabled=v end)

Toggle(ESPPage,"ESP Lines",
	function() return S.ESPLine end,
	function(v) S.ESPLine=v end)

Toggle(ESPPage,"ESP Box",
	function() return S.ESPBox end,
	function(v) S.ESPBox=v end)

Toggle(ESPPage,"ESP Name",
	function() return S.ESPName end,
	function(v) S.ESPName=v end)

Toggle(ESPPage,"ESP Health",
	function() return S.ESPHealth end,
	function(v) S.ESPHealth=v end)

Toggle(ESPPage,"ESP Distance",
	function() return S.ESPDistance end,
	function(v) S.ESPDistance=v end)

Toggle(ESPPage,"ESP Head",
	function() return S.ESPHead end,
	function(v) S.ESPHead=v end)

Toggle(ESPPage,"Always On Top",
	function() return S.ESPAlwaysOnTop end,
	function(v) S.ESPAlwaysOnTop=v end)

Toggle(ESPPage,"Team Color",
	function() return S.ESPTeamColor end,
	function(v) S.ESPTeamColor=v end)

Slider(ESPPage,"ESP Distance",50,5000,
	function() return S.ESPMaxDistance end,
	function(v) S.ESPMaxDistance=v end)

--==============================================================
-- MOVE UI
--==============================================================

Toggle(MovePage,"Fly",
	function() return S.FlyEnabled end,
	function(v) S.FlyEnabled=v end)

Slider(MovePage,"Fly Speed",1,200,
	function() return S.FlySpeed end,
	function(v) S.FlySpeed=v end)

Slider(MovePage,"Fly Vertical",1,200,
	function() return S.FlyVerticalSpeed end,
	function(v) S.FlyVerticalSpeed=v end)

Toggle(MovePage,"Speed Run",
	function() return S.SpeedEnabled end,
	function(v) S.SpeedEnabled=v end)

Slider(MovePage,"Run Speed",16,200,
	function() return S.SpeedRun end,
	function(v) S.SpeedRun=v end)

Toggle(MovePage,"Super Jump",
	function() return S.SuperJumpEnabled end,
	function(v) S.SuperJumpEnabled=v end)

Slider(MovePage,"Jump Power",50,300,
	function() return S.JumpPower end,
	function(v) S.JumpPower=v end)

--==============================================================
-- SYSTEM UI
--==============================================================

Toggle(SystemPage,"No Recoil",
	function() return S.NoRecoil end,
	function(v) S.NoRecoil=v end)

Toggle(SystemPage,"No Reload",
	function() return S.NoReload end,
	function(v) S.NoReload=v end)

Toggle(SystemPage,"FPS Boost",
	function() return S.FPSBoost end,
	function(v) S.FPSBoost=v end)

Toggle(SystemPage,"Show FPS",
	function() return S.ShowFPS end,
	function(v) S.ShowFPS=v end)

--==============================================================
-- EXIT
--==============================================================

local Exit = Row(SystemPage,34)
Exit.BackgroundColor3 = Color3.fromRGB(52,25,36)

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.fromScale(1,1)
ExitButton.BackgroundTransparency = 1
ExitButton.Text = "EXIT MODE"
ExitButton.TextColor3 = RED
ExitButton.TextSize = 10
ExitButton.Font = Enum.Font.GothamBold
ExitButton.ZIndex = 6
ExitButton.Parent = Exit

--==============================================================
-- FPS
--==============================================================

local FPS = Instance.new("TextLabel")
FPS.Size = UDim2.fromOffset(75,20)
FPS.Position = UDim2.new(1,-82,1,-25)
FPS.BackgroundTransparency = 1
FPS.Text = "FPS: --"
FPS.TextColor3 = SUB
FPS.TextSize = 9
FPS.Font = Enum.Font.GothamBold
FPS.TextXAlignment = Enum.TextXAlignment.Right
FPS.ZIndex = 7
FPS.Parent = Main

local fpsTime = 0
local fpsFrames = 0

--==============================================================
-- ESP WORLD
--==============================================================

local ESPWorld = Workspace:FindFirstChild("XeirenESPWorld")

if not ESPWorld then
	ESPWorld = Instance.new("Folder")
	ESPWorld.Name = "XeirenESPWorld"
	ESPWorld.Parent = Workspace
end

local ESP = {}
local PlayerConnections = {}

local function Enemy(player)
	if player == LP then
		return false
	end

	if not S.TeamCheck then
		return true
	end

	if not LP.Team or not player.Team then
		return true
	end

	return LP.Team ~= player.Team
end

local function ColorFor(player)
	if S.ESPTeamColor and player.Team then
		return player.Team.TeamColor.Color
	end

	return ACCENT
end

local function Visible(part)
	if not S.WallCheck then
		return true
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character}

	local origin = Camera.CFrame.Position
	local direction = part.Position-origin

	local hit = Workspace:Raycast(
		origin,
		direction,
		params
	)

	return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

--==============================================================
-- ESP CLEANUP
--==============================================================

local function ClearESP(player)
	local data = ESP[player]

	if not data then
		return
	end

	for _,obj in ipairs(data.objects or {}) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end

	ESP[player] = nil
end

--==============================================================
-- ESP BUILD
--==============================================================

local function BuildESP(player)
	if player == LP or not player.Character then
		return
	end

	ClearESP(player)

	local char = player.Character
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildOfClass("Humanoid")

	if not root or not hum then
		return
	end

	local objects = {}

	local highlight = Instance.new("Highlight")
	highlight.Adornee = char
	highlight.DepthMode =
		S.ESPAlwaysOnTop
		and Enum.HighlightDepthMode.AlwaysOnTop
		or Enum.HighlightDepthMode.Occluded

	highlight.FillTransparency = .72
	highlight.OutlineTransparency = .1
	highlight.Enabled = S.ESPEnabled and S.ESPBox
	highlight.FillColor = ColorFor(player)
	highlight.OutlineColor = ColorFor(player)
	highlight.Parent = ESPWorld

	table.insert(objects,highlight)

	local targetAttachment = Instance.new("Attachment")
	targetAttachment.Parent = root
	table.insert(objects,targetAttachment)

	local origin = Instance.new("Part")
	origin.Name = "XeirenOrigin"
	origin.Size = Vector3.new(.1,.1,.1)
	origin.Transparency = 1
	origin.Anchored = true
	origin.CanCollide = false
	origin.CanTouch = false
	origin.CanQuery = false
	origin.Position = Camera.CFrame.Position
	origin.Parent = ESPWorld
	table.insert(objects,origin)

	local originAttachment = Instance.new("Attachment")
	originAttachment.Parent = origin
	table.insert(objects,originAttachment)

	local beam = Instance.new("Beam")
	beam.Attachment0 = originAttachment
	beam.Attachment1 = targetAttachment
	beam.FaceCamera = true
	beam.Width0 = .025
	beam.Width1 = .025
	beam.LightEmission = .8
	beam.Transparency = NumberSequence.new(.1)
	beam.Color = ColorSequence.new(ColorFor(player))
	beam.Enabled = S.ESPEnabled and S.ESPLine
	beam.Parent = ESPWorld
	table.insert(objects,beam)

	local bill = Instance.new("BillboardGui")
	bill.Adornee = root
	bill.Size = UDim2.fromOffset(170,55)
	bill.StudsOffset = Vector3.new(0,3.2,0)
	bill.AlwaysOnTop = S.ESPAlwaysOnTop
	bill.MaxDistance = S.ESPMaxDistance
	bill.Enabled = S.ESPEnabled
	bill.Parent = GUI
	table.insert(objects,bill)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.fromScale(1,1)
	info.BackgroundTransparency = 1
	info.TextColor3 = ColorFor(player)
	info.TextStrokeTransparency = .25
	info.TextSize = 10
	info.Font = Enum.Font.GothamBold
	info.Parent = bill
	table.insert(objects,info)

	local headMarker

	if head then
		headMarker = Instance.new("BillboardGui")
		headMarker.Adornee = head
		headMarker.Size = UDim2.fromOffset(18,18)
		headMarker.AlwaysOnTop = true
		headMarker.Enabled = S.ESPEnabled and S.ESPHead
		headMarker.Parent = GUI
		table.insert(objects,headMarker)

		local mark = Instance.new("TextLabel")
		mark.Size = UDim2.fromScale(1,1)
		mark.BackgroundTransparency = 1
		mark.Text = "◆"
		mark.TextColor3 = RED
		mark.TextSize = 13
		mark.Font = Enum.Font.GothamBold
		mark.Parent = headMarker
		table.insert(objects,mark)
	end

	ESP[player] = {
		character = char,
		root = root,
		humanoid = hum,
		objects = objects,
		origin = origin,
		target = targetAttachment,
		beam = beam,
		highlight = highlight,
		bill = bill,
		info = info,
		headMarker = headMarker,
	}
end

--==============================================================
-- PLAYER ESP CONNECTIONS
-- IMPORTANT: NEW PLAYERS + RESPAWNS
--==============================================================

local function WatchPlayer(player)
	if player == LP then return end

	if PlayerConnections[player] then
		for _,c in ipairs(PlayerConnections[player]) do
			c:Disconnect()
		end
	end

	PlayerConnections[player] = {}

	table.insert(
		PlayerConnections[player],
		player.CharacterAdded:Connect(function(character)

			-- Wait until the character is actually assembled.
			character:WaitForChild("Humanoid",10)
			character:WaitForChild("HumanoidRootPart",10)

			task.wait(.15)

			BuildESP(player)
		end)
	)

	table.insert(
		PlayerConnections[player],
		player.CharacterRemoving:Connect(function()
			ClearESP(player)
		end)
	)

	if player.Character then
		task.spawn(function()
			task.wait(.1)
			BuildESP(player)
		end)
	end
end

for _,player in ipairs(Players:GetPlayers()) do
	WatchPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
	-- This is the important new-player refresh.
	WatchPlayer(player)

	task.spawn(function()
		for i = 1,20 do
			if exited then return end

			if S.ESPEnabled then
				BuildESP(player)
			end

			if player.Character
				and player.Character:FindFirstChild("HumanoidRootPart") then
				break
			end

			task.wait(.25)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	ClearESP(player)

	if PlayerConnections[player] then
		for _,c in ipairs(PlayerConnections[player]) do
			c:Disconnect()
		end
	end

	PlayerConnections[player] = nil
end)

--==============================================================
-- AIM REGISTRY
--==============================================================

local AimPlayers = {}

for _,p in ipairs(Players:GetPlayers()) do
	if p ~= LP then
		AimPlayers[p] = true
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LP then
		AimPlayers[p] = true
	end
end)

Players.PlayerRemoving:Connect(function(p)
	AimPlayers[p] = nil
end)

local function AimPart(char)
	if S.AimPart == "Head" then
		return char:FindFirstChild("Head")
			or char:FindFirstChild("HumanoidRootPart")
	end

	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function FindTarget()
	local best
	local bestScore = math.huge

	local camPos = Camera.CFrame.Position
	local look = Camera.CFrame.LookVector

	for player in pairs(AimPlayers) do
		if player.Parent == Players and Enemy(player) then

			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local part = char and AimPart(char)

			if hum and hum.Health > 0 and part then
				local offset = part.Position-camPos
				local distance = offset.Magnitude

				if distance <= S.AimDistance then

					local angle = math.deg(
						math.acos(
							math.clamp(
								look:Dot(offset.Unit),
								-1,1
							)
						)
					)

					local valid =
						S.Full360
						or angle <= S.AimFOV/2

					if valid and Visible(part) then
						local score =
							S.Full360
							and distance
							or angle*10+distance*.01

						if score < bestScore then
							bestScore = score
							best = part
						end
					end
				end
			end
		end
	end

	return best
end

local function UpdateAim(dt)
	if not S.AimEnabled then return end

	local target = FindTarget()

	if not target then return end

	local targetCF = CFrame.lookAt(
		Camera.CFrame.Position,
		target.Position
	)

	local strength = math.clamp(
		S.LockStrength/1000,
		.001,1
	)

	local speed = math.clamp(
		S.AimSpeed/100,
		.01,1
	)

	local smooth = math.clamp(
		S.AimSmoothness/100,
		.01,1
	)

	local response =
		2
		+ strength*18
		+ speed*12
		+ smooth*8

	local alpha =
		1-math.exp(-response*dt)

	alpha = math.clamp(alpha,.01,.98)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			targetCF,
			alpha
		)
end

--==============================================================
-- FLY
--==============================================================

local FlyAttachment
local FlyVelocity

local function StopFly()
	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end
end

local function StartFly()
	if not RootPart then return end

	StopFly()

	FlyAttachment = Instance.new("Attachment")
	FlyAttachment.Parent = RootPart

	FlyVelocity = Instance.new("LinearVelocity")
	FlyVelocity.Attachment0 = FlyAttachment
	FlyVelocity.MaxForce = math.huge
	FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVelocity.VectorVelocity = Vector3.zero
	FlyVelocity.Parent = RootPart
end

local function UpdateFly()
	if not S.FlyEnabled then
		StopFly()
		return
	end

	if not RootPart or not Humanoid then return end

	if not FlyVelocity then
		StartFly()
	end

	if not FlyVelocity then return end

	local velocity =
		Humanoid.MoveDirection*S.FlySpeed

	local vertical = 0

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		vertical += S.FlyVerticalSpeed
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		vertical -= S.FlyVerticalSpeed
	end

	FlyVelocity.VectorVelocity =
		velocity+Vector3.new(0,vertical,0)
end

--==============================================================
-- MOVEMENT
--==============================================================

local function UpdateMovement()
	if not Humanoid then return end

	if S.SpeedEnabled then
		Humanoid.WalkSpeed = S.SpeedRun
	else
		Humanoid.WalkSpeed = OriginalSpeed
	end

	Humanoid.UseJumpPower = true

	if S.SuperJumpEnabled then
		Humanoid.JumpPower = S.JumpPower
	else
		Humanoid.JumpPower = OriginalJump
	end
end

--==============================================================
-- WEAPON CONFIG
--==============================================================

local function UpdateWeapon()
	local config =
		ReplicatedStorage:FindFirstChild("XeirenWeaponConfig")

	if not config then
		config = Instance.new("Folder")
		config.Name = "XeirenWeaponConfig"
		config.Parent = ReplicatedStorage
	end

	config:SetAttribute("NoRecoil",S.NoRecoil)
	config:SetAttribute("NoReload",S.NoReload)
end

--==============================================================
-- FPS BOOST
--==============================================================

local function FPSBoost()
	if not S.FPSBoost then return end

	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000

	for _,obj in ipairs(Lighting:GetChildren()) do
		if obj:IsA("PostEffect") then
			obj.Enabled = false
		end
	end

	for _,obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter")
			or obj:IsA("Trail") then

			if not obj:IsDescendantOf(ESPWorld) then
				obj.Enabled = false
			end
		end
	end

	local terrain = Workspace:FindFirstChildOfClass("Terrain")

	if terrain then
		pcall(function()
			terrain.Decoration = false
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterReflectance = 0
		end)
	end
end

--==============================================================
-- XE BUTTON
--==============================================================

local XE = Instance.new("TextButton")
XE.Size = UDim2.fromOffset(48,48)
XE.Position = UDim2.fromOffset(15,260)
XE.BackgroundColor3 = PANEL
XE.BorderSizePixel = 0
XE.Text = "XE"
XE.TextColor3 = TEXT
XE.TextSize = 14
XE.Font = Enum.Font.GothamBlack
XE.Parent = GUI

Instance.new("UICorner",XE).CornerRadius = UDim.new(1,0)

local XStroke = Instance.new("UIStroke",XE)
XStroke.Color = ACCENT
XStroke.Thickness = 2

-- Pulse effect
task.spawn(function()
	while not exited do
		task.wait(1)

		if XE.Parent then
			TweenService:Create(
				XStroke,
				TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{Transparency=.6}
			):Play()

			task.wait(.5)

			TweenService:Create(
				XStroke,
				TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{Transparency=0}
			):Play()
		end
	end
end)

local xeDragging = false
local xeMoved = false
local xeStart
local xeOriginal

XE.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		xeDragging = true
		xeMoved = false
		xeStart = input.Position
		xeOriginal = XE.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				xeDragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not xeDragging then return end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local d = input.Position-xeStart

		if d.Magnitude > 6 then
			xeMoved = true
		end

		XE.Position = UDim2.new(
			xeOriginal.X.Scale,
			xeOriginal.X.Offset+d.X,
			xeOriginal.Y.Scale,
			xeOriginal.Y.Offset+d.Y
		)
	end
end)

--==============================================================
-- MENU OPEN / CLOSE GROW EFFECT
--==============================================================

local function OpenMenu()
	if exited then return end

	Main.Visible = true
	opened = true

	Main.Size = UDim2.fromOffset(0,0)
	MainScale.Scale = .88

	TweenService:Create(
		Main,
		TweenInfo.new(
			.28,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(440,350)
		}
	):Play()

	TweenService:Create(
		MainScale,
		TweenInfo.new(
			.28,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{Scale=1}
	):Play()
end

local function CloseMenu()
	opened = false

	TweenService:Create(
		MainScale,
		TweenInfo.new(
			.18,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.In
		),
		{Scale=.88}
	):Play()

	local tween = TweenService:Create(
		Main,
		TweenInfo.new(
			.18,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(0,0)
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		if not opened then
			Main.Visible = false
		end
	end)
end

XE.MouseButton1Click:Connect(function()
	if xeMoved or exited then return end

	if opened then
		CloseMenu()
	else
		OpenMenu()
	end
end)

--==============================================================
-- EXIT MODE
--==============================================================

ExitButton.MouseButton1Click:Connect(function()
	exited = true

	S.AimEnabled = false
	S.ESPEnabled = false
	S.FlyEnabled = false
	S.SpeedEnabled = false
	S.SuperJumpEnabled = false

	StopFly()

	if Humanoid then
		Humanoid.WalkSpeed = OriginalSpeed
		Humanoid.JumpPower = OriginalJump
	end

	for player in pairs(ESP) do
		ClearESP(player)
	end

	for player,connections in pairs(PlayerConnections) do
		for _,connection in ipairs(connections) do
			connection:Disconnect()
		end
	end

	Status.Text = "EXITED"
	Status.TextColor3 = RED

	CloseMenu()

	XE.Active = false

	for _,obj in ipairs(Stars:GetChildren()) do
		obj:Destroy()
	end
end)

--==============================================================
-- KEYBINDS
-- R = FLY
-- V = SPEED
--==============================================================

UserInputService.InputBegan:Connect(function(input,processed)
	if processed or exited then return end

	if input.KeyCode == Enum.KeyCode.R then
		S.FlyEnabled = not S.FlyEnabled

		if not S.FlyEnabled then
			StopFly()
		end
	end

	if input.KeyCode == Enum.KeyCode.V then
		S.SpeedEnabled = not S.SpeedEnabled
	end
end)

--==============================================================
-- LOGIN
--==============================================================

local function LoginSuccess()
	Login.Visible = false
	ShowPage("Aim")
	OpenMenu()
end

Enter.MouseButton1Click:Connect(function()
	if Pass.Text == "anakin" then
		LoginSuccess()
	else
		Pass.Text = ""
		LoginSub.Text = "Wrong password"

		TweenService:Create(
			Login,
			TweenInfo.new(
				.07,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,
				3,
				true
			),
			{
				Position = UDim2.fromScale(.505,.5)
			}
		):Play()

		task.delay(1,function()
			if Login.Visible then
				LoginSub.Text = "Enter password"
			end
		end)
	end
end)

Pass.FocusLost:Connect(function(enter)
	if enter then
		Enter:Activate()
	end
end)

--==============================================================
-- MAIN LOOP
--==============================================================

local ESPTimer = 0

RunService.RenderStepped:Connect(function(dt)
	if exited then return end

	UpdateAim(dt)
	UpdateFly()
	UpdateMovement()
	UpdateWeapon()

	-- Keep ESP objects synchronized.
	ESPTimer += dt

	for player,data in pairs(ESP) do
		if not player.Parent then
			ClearESP(player)
			continue
		end

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		-- Automatic rebuild if the character changed.
		if char ~= data.character
			or not root
			or data.root ~= root then

			if char and root then
				BuildESP(player)
			end

			continue
		end

		if not S.ESPEnabled
			or not Enemy(player)
			or not root
			or not hum
			or hum.Health <= 0 then

			if data.highlight then
				data.highlight.Enabled = false
			end

			if data.beam then
				data.beam.Enabled = false
			end

			if data.bill then
				data.bill.Enabled = false
			end

			continue
		end

		local distance =
			(Camera.CFrame.Position-root.Position).Magnitude

		local valid =
			distance <= S.ESPMaxDistance

		if data.highlight then
			data.highlight.Enabled =
				valid and S.ESPBox

			data.highlight.FillColor =
				ColorFor(player)

			data.highlight.OutlineColor =
				ColorFor(player)

			data.highlight.DepthMode =
				S.ESPAlwaysOnTop
				and Enum.HighlightDepthMode.AlwaysOnTop
				or Enum.HighlightDepthMode.Occluded
		end

		if data.beam then
			data.beam.Enabled =
				valid and S.ESPLine

			data.beam.Color =
				ColorSequence.new(
					ColorFor(player)
				)
		end

		if data.bill then
			data.bill.Enabled = valid
			data.bill.AlwaysOnTop =
				S.ESPAlwaysOnTop
			data.bill.MaxDistance =
				S.ESPMaxDistance
		end

		if data.headMarker then
			data.headMarker.Enabled =
				valid and S.ESPHead
		end

		if data.info then
			local lines = {}

			if S.ESPName then
				table.insert(
					lines,
					player.DisplayName
				)
			end

			if S.ESPHealth then
				table.insert(
					lines,
					"HP: "
					..math.floor(hum.Health)
					.."/"
					..math.floor(hum.MaxHealth)
				)
			end

			if S.ESPDistance then
				table.insert(
					lines,
					math.floor(distance).." studs"
				)
			end

			data.info.Text =
				table.concat(lines,"\n")

			data.info.TextColor3 =
				ColorFor(player)
		end

		-- Beam origin updates every frame.
		if data.origin then
			data.origin.Position =
				Camera.CFrame.Position
				+Camera.CFrame.LookVector*2
				+Camera.CFrame.UpVector*1.5
		end

		if data.target and root then
			data.target.WorldPosition =
				root.Position
		end
	end

	-- FPS counter
	fpsTime += dt
	fpsFrames += 1

	if fpsTime >= .5 then
		FPS.Text =
			"FPS: "
			..math.floor(fpsFrames/fpsTime)

		fpsTime = 0
		fpsFrames = 0
	end

	FPS.Visible = S.ShowFPS
end)

--==============================================================
-- INITIAL
--==============================================================

ShowPage("Aim")
UpdateWeapon()

print("==========================================")
print(" XEIREN 5V5 COMBAT HUB")
print(" Old Compact UI")
print(" Falling Stars + Glow + Grow Animation")
print(" ESP New Player Refresh: ON")
print(" ESP Respawn Refresh: ON")
print(" 360 Smooth Aim: ON")
print("==========================================")
