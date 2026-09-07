--==============================================================
-- XEIREN 5V5 COMBAT HUB
-- COMPLETE ROBLOX STUDIO LOCALSCRIPT
--==============================================================
--
-- Place:
-- StarterPlayer
--   └─ StarterPlayerScripts
--       └─ LocalScript
--
-- Password:
-- anakin
--
-- IMPORTANT:
-- This is intended for your own Roblox Studio game.
--
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = Workspace.CurrentCamera

--==============================================================
-- CONFIG
--==============================================================

local PASSWORD = "anakin"

-- Upload your logo to Roblox and replace this.
-- Example:
-- rbxassetid://123456789
local LOGO_IMAGE = "https://raw.githubusercontent.com/ChaCha981/Hack-menu-roblox/refs/heads/main/IMG_2452.jpeg"

--==============================================================
-- SETTINGS
--==============================================================

local Settings = {

	Language = "EN",

	-- AIM
	AimEnabled = false,
	Full360 = true,
	LockStrength = 85,
	AimSpeed = 35,
	AimDistance = 600,
	AimFOV = 180,
	AimPart = "Head",

	-- ESP
	ESPEnabled = false,

	ESPLine = true,
	ESPCloud = true,

	ESPBox = true,
	ESPName = true,
	ESPHealth = true,
	ESPDistance = true,
	ESPHead = false,

	ESPAlwaysOnTop = true,
	ESPTeamColor = false,

	ESPMaxDistance = 600,

	-- CHECKS
	TeamCheck = true,
	WallCheck = false,

	-- MOVEMENT
	FlyEnabled = false,
	FlySpeed = 70,
	FlyVerticalSpeed = 60,

	SpeedEnabled = false,
	SpeedRun = 32,

	-- WEAPON
	NoRecoil = false,
	NoReload = false,

	-- PERFORMANCE
	FPSBoost = true,
	DynamicFPS = true,
	ShowFPS = true,

	ESPUpdateRate = 30,
}

--==============================================================
-- CHARACTER
--==============================================================

local Character
local Humanoid
local Root

local function SetupCharacter(character)

	Character = character

	Humanoid =
		character:WaitForChild(
			"Humanoid",
			10
		)

	Root =
		character:WaitForChild(
			"HumanoidRootPart",
			10
		)

end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

--==============================================================
-- LOCALIZATION
--==============================================================

local Language = {

	EN = {

		title = "XEIREN 5V5",
		subtitle = "Combat Hub",

		aimTab = "AIM",
		espTab = "ESP",
		moveTab = "MOVE",
		miscTab = "MISC",

		aim = "Aim Assist",
		lock360 = "360° Lock",
		strength = "Lock Strength",
		aimSpeed = "Aim Speed",
		aimDistance = "Aim Distance",
		aimFov = "Aim FOV",
		target = "Target",

		head = "Head",
		body = "Body",

		esp = "ESP",
		cloud = "Cloud ESP",
		line = "ESP Line",
		box = "ESP Box",
		name = "ESP Name",
		health = "ESP Health",
		distance = "ESP Distance",
		headMarker = "Head Marker",
		always = "Always On Top",
		teamColor = "Team Color",
		espDistance = "ESP Distance",

		teamCheck = "Team Check",
		wallCheck = "Wall Check",

		fly = "Fly",
		flySpeed = "Fly Speed",
		verticalSpeed = "Vertical Speed",

		speedRun = "Speed Run",
		runSpeed = "Run Speed",

		noRecoil = "No Recoil",
		noReload = "No Reload",

		fpsBoost = "FPS Boost",
		dynamic = "Dynamic Optimization",
		showFps = "Show FPS",

		on = "ON",
		off = "OFF",

		password = "Enter Password",
		enter = "ENTER",
		wrong = "Wrong Password",

	},

	KM = {

		title = "XEIREN 5V5",
		subtitle = "Combat Hub",

		aimTab = "AIM",
		espTab = "ESP",
		moveTab = "ចលនា",
		miscTab = "ផ្សេងៗ",

		aim = "ជំនួយ Aim",
		lock360 = "Lock 360°",
		strength = "កម្លាំង Lock",
		aimSpeed = "ល្បឿន Aim",
		aimDistance = "ចម្ងាយ Aim",
		aimFov = "Aim FOV",
		target = "គោលដៅ",

		head = "ក្បាល",
		body = "ខ្លួន",

		esp = "ESP",
		cloud = "Cloud ESP",
		line = "ខ្សែ ESP",
		box = "ប្រអប់ ESP",
		name = "ឈ្មោះ ESP",
		health = "HP ESP",
		distance = "ចម្ងាយ ESP",
		headMarker = "សញ្ញាក្បាល",
		always = "បង្ហាញពីក្រោយ",
		teamColor = "ពណ៌ Team",
		espDistance = "ចម្ងាយ ESP",

		teamCheck = "ពិនិត្យ Team",
		wallCheck = "ពិនិត្យជញ្ជាំង",

		fly = "ហោះ",
		flySpeed = "ល្បឿនហោះ",
		verticalSpeed = "ល្បឿនឡើងចុះ",

		speedRun = "រត់លឿន",
		runSpeed = "ល្បឿនរត់",

		noRecoil = "គ្មាន Recoil",
		noReload = "គ្មាន Reload",

		fpsBoost = "បង្កើន FPS",
		dynamic = "Optimization ស្វ័យប្រវត្តិ",
		showFps = "បង្ហាញ FPS",

		on = "បើក",
		off = "បិទ",

		password = "បញ្ចូល Password",
		enter = "ចូល",
		wrong = "Password ខុស",

	}

}

local function T(key)

	return Language[
		Settings.Language
	][key] or key

end

--==============================================================
-- WEAPON CONFIG
--==============================================================

local WeaponConfig =
	ReplicatedStorage:FindFirstChild(
		"XeirenWeaponConfig"
	)

if not WeaponConfig then

	WeaponConfig =
		Instance.new("Folder")

	WeaponConfig.Name =
		"XeirenWeaponConfig"

	WeaponConfig.Parent =
		ReplicatedStorage

end

local function UpdateWeaponConfig()

	WeaponConfig:SetAttribute(
		"NoRecoil",
		Settings.NoRecoil
	)

	WeaponConfig:SetAttribute(
		"NoReload",
		Settings.NoReload
	)

end

UpdateWeaponConfig()

--==============================================================
-- REMOVE OLD XEIREN GUI
--==============================================================

local OldGUI =
	PlayerGui:FindFirstChild(
		"XeirenCombatHub"
	)

if OldGUI then
	OldGUI:Destroy()
end

local OldESP =
	PlayerGui:FindFirstChild(
		"XeirenESPSystem"
	)

if OldESP then
	OldESP:Destroy()
end

--==============================================================
-- COLORS
--==============================================================

local COLORS = {

	Background =
		Color3.fromRGB(
			11,
			12,
			17
		),

	Panel =
		Color3.fromRGB(
			20,
			21,
			28
		),

	Panel2 =
		Color3.fromRGB(
			28,
			29,
			38
		),

	Accent =
		Color3.fromRGB(
			132,
			86,
			255
		),

	White =
		Color3.fromRGB(
			245,
			245,
			250
		),

	Gray =
		Color3.fromRGB(
			155,
			157,
			172
		),

	Green =
		Color3.fromRGB(
			75,
			220,
			125
		),

	Red =
		Color3.fromRGB(
			235,
			75,
			90
		),

	ESP =
		Color3.fromRGB(
			255,
			75,
			100
		),

}

--==============================================================
-- MAIN GUI
--==============================================================

local GUI =
	Instance.new("ScreenGui")

GUI.Name =
	"XeirenCombatHub"

GUI.ResetOnSpawn =
	false

GUI.IgnoreGuiInset =
	true

GUI.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

GUI.Parent =
	PlayerGui

--==============================================================
-- PASSWORD WINDOW
--==============================================================

local Password =
	Instance.new("Frame")

Password.Size =
	UDim2.fromOffset(
		315,
		190
	)

Password.Position =
	UDim2.new(
		0.5,
		-157,
		0.5,
		-95
	)

Password.BackgroundColor3 =
	COLORS.Background

Password.BorderSizePixel =
	0

Password.Parent =
	GUI

local PasswordCorner =
	Instance.new("UICorner")

PasswordCorner.CornerRadius =
	UDim.new(
		0,
		16
	)

PasswordCorner.Parent =
	Password

local PasswordStroke =
	Instance.new("UIStroke")

PasswordStroke.Color =
	COLORS.Accent

PasswordStroke.Thickness =
	1.4

PasswordStroke.Parent =
	Password

local PasswordTitle =
	Instance.new("TextLabel")

PasswordTitle.Size =
	UDim2.new(
		1,
		-30,
		0,
		35
	)

PasswordTitle.Position =
	UDim2.fromOffset(
		15,
		12
	)

PasswordTitle.BackgroundTransparency =
	1

PasswordTitle.Text =
	"XEIREN"

PasswordTitle.TextColor3 =
	COLORS.White

PasswordTitle.Font =
	Enum.Font.GothamBlack

PasswordTitle.TextSize =
	24

PasswordTitle.Parent =
	Password

local PasswordSub =
	Instance.new("TextLabel")

PasswordSub.Size =
	UDim2.new(
		1,
		-30,
		0,
		22
	)

PasswordSub.Position =
	UDim2.fromOffset(
		15,
		47
	)

PasswordSub.BackgroundTransparency =
	1

PasswordSub.Text =
	T("password")

PasswordSub.TextColor3 =
	COLORS.Gray

PasswordSub.Font =
	Enum.Font.Gotham

PasswordSub.TextSize =
	12

PasswordSub.Parent =
	Password

local PasswordBox =
	Instance.new("TextBox")

PasswordBox.Size =
	UDim2.new(
		1,
		-40,
		0,
		38
	)

PasswordBox.Position =
	UDim2.fromOffset(
		20,
		76
	)

PasswordBox.BackgroundColor3 =
	COLORS.Panel2

PasswordBox.BorderSizePixel =
	0

PasswordBox.PlaceholderText =
	"Password"

PasswordBox.PlaceholderColor3 =
	COLORS.Gray

PasswordBox.TextColor3 =
	COLORS.White

PasswordBox.Font =
	Enum.Font.Gotham

PasswordBox.TextSize =
	13

PasswordBox.ClearTextOnFocus =
	false

PasswordBox.Parent =
	Password

local PasswordBoxCorner =
	Instance.new("UICorner")

PasswordBoxCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

PasswordBoxCorner.Parent =
	PasswordBox

local Enter =
	Instance.new("TextButton")

Enter.Size =
	UDim2.new(
		1,
		-40,
		0,
		35
	)

Enter.Position =
	UDim2.fromOffset(
		20,
		123
	)

Enter.BackgroundColor3 =
	COLORS.Accent

Enter.BorderSizePixel =
	0

Enter.Text =
	T("enter")

Enter.TextColor3 =
	COLORS.White

Enter.Font =
	Enum.Font.GothamBold

Enter.TextSize =
	11

Enter.Parent =
	Password

local EnterCorner =
	Instance.new("UICorner")

EnterCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

EnterCorner.Parent =
	Enter

local Wrong =
	Instance.new("TextLabel")

Wrong.Size =
	UDim2.new(
		1,
		-20,
		0,
		20
	)

Wrong.Position =
	UDim2.fromOffset(
		10,
		162
	)

Wrong.BackgroundTransparency =
	1

Wrong.Text =
	""

Wrong.TextColor3 =
	COLORS.Red

Wrong.Font =
	Enum.Font.Gotham

Wrong.TextSize =
	10

Wrong.Parent =
	Password

--==============================================================
-- HUB
--==============================================================

local Hub =
	Instance.new("Frame")

Hub.Size =
	UDim2.fromOffset(
		395,
		325
	)

Hub.Position =
	UDim2.new(
		0.5,
		-197,
		0.5,
		-162
	)

Hub.BackgroundColor3 =
	COLORS.Background

Hub.BorderSizePixel =
	0

Hub.Visible =
	false

Hub.Parent =
	GUI

local HubCorner =
	Instance.new("UICorner")

HubCorner.CornerRadius =
	UDim.new(
		0,
		16
	)

HubCorner.Parent =
	Hub

local HubStroke =
	Instance.new("UIStroke")

HubStroke.Color =
	COLORS.Accent

HubStroke.Thickness =
	1.2

HubStroke.Parent =
	Hub

--==============================================================
-- HEADER
--==============================================================

local Header =
	Instance.new("Frame")

Header.Size =
	UDim2.new(
		1,
		0,
		0,
		58
	)

Header.BackgroundTransparency =
	1

Header.Parent =
	Hub

-- Logo

local Logo =
	Instance.new("ImageLabel")

Logo.Size =
	UDim2.fromOffset(
		40,
		40
	)

Logo.Position =
	UDim2.fromOffset(
		10,
		9
	)

Logo.BackgroundColor3 =
	COLORS.Panel2

Logo.BorderSizePixel =
	0

Logo.Parent =
	Header

local LogoCorner =
	Instance.new("UICorner")

LogoCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

LogoCorner.Parent =
	Logo

if LOGO_IMAGE ~= "" then

	Logo.Image =
		LOGO_IMAGE

end

local HeaderTitle =
	Instance.new("TextLabel")

HeaderTitle.Size =
	UDim2.new(
		1,
		-145,
		0,
		25
	)

HeaderTitle.Position =
	UDim2.fromOffset(
		58,
		7
	)

HeaderTitle.BackgroundTransparency =
	1

HeaderTitle.Text =
	T("title")

HeaderTitle.TextColor3 =
	COLORS.White

HeaderTitle.Font =
	Enum.Font.GothamBlack

HeaderTitle.TextSize =
	15

HeaderTitle.TextXAlignment =
	Enum.TextXAlignment.Left

HeaderTitle.Parent =
	Header

local HeaderSub =
	Instance.new("TextLabel")

HeaderSub.Size =
	UDim2.new(
		1,
		-145,
		0,
		18
	)

HeaderSub.Position =
	UDim2.fromOffset(
		58,
		31
	)

HeaderSub.BackgroundTransparency =
	1

HeaderSub.Text =
	T("subtitle")

HeaderSub.TextColor3 =
	COLORS.Gray

HeaderSub.Font =
	Enum.Font.Gotham

HeaderSub.TextSize =
	9

HeaderSub.TextXAlignment =
	Enum.TextXAlignment.Left

HeaderSub.Parent =
	Header

--==============================================================
-- LANGUAGE BUTTON
--==============================================================

local LanguageButton =
	Instance.new("TextButton")

LanguageButton.Size =
	UDim2.fromOffset(
		50,
		29
	)

LanguageButton.Position =
	UDim2.new(
		1,
		-108,
		0,
		14
	)

LanguageButton.BackgroundColor3 =
	COLORS.Panel2

LanguageButton.BorderSizePixel =
	0

LanguageButton.Text =
	"EN"

LanguageButton.TextColor3 =
	COLORS.White

LanguageButton.Font =
	Enum.Font.GothamBold

LanguageButton.TextSize =
	10

LanguageButton.Parent =
	Header

local LanguageCorner =
	Instance.new("UICorner")

LanguageCorner.CornerRadius =
	UDim.new(
		0,
		8
	)

LanguageCorner.Parent =
	LanguageButton

--==============================================================
-- CLOSE
--==============================================================

local Close =
	Instance.new("TextButton")

Close.Size =
	UDim2.fromOffset(
		30,
		29
	)

Close.Position =
	UDim2.new(
		1,
		-50,
		0,
		14
	)

Close.BackgroundColor3 =
	COLORS.Panel2

Close.BorderSizePixel =
	0

Close.Text =
	"×"

Close.TextColor3 =
	COLORS.White

Close.Font =
	Enum.Font.GothamBold

Close.TextSize =
	18

Close.Parent =
	Header

local CloseCorner =
	Instance.new("UICorner")

CloseCorner.CornerRadius =
	UDim.new(
		0,
		8
	)

CloseCorner.Parent =
	Close

--==============================================================
-- TABS
--==============================================================

local TabBar =
	Instance.new("Frame")

TabBar.Size =
	UDim2.new(
		1,
		-20,
		0,
		34
	)

TabBar.Position =
	UDim2.fromOffset(
		10,
		60
	)

TabBar.BackgroundTransparency =
	1

TabBar.Parent =
	Hub

local TabLayout =
	Instance.new("UIListLayout")

TabLayout.FillDirection =
	Enum.FillDirection.Horizontal

TabLayout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

TabLayout.Padding =
	UDim.new(
		0,
		5
	)

TabLayout.Parent =
	TabBar

local Tabs = {}
local Pages = {}

local function CreateTab(key)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.fromOffset(
			88,
			31
		)

	button.BackgroundColor3 =
		COLORS.Panel

	button.BorderSizePixel =
		0

	button.Text =
		T(key)

	button.TextColor3 =
		COLORS.Gray

	button.Font =
		Enum.Font.GothamBold

	button.TextSize =
		10

	button.Parent =
		TabBar

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			8
		)

	corner.Parent =
		button

	Tabs[key] =
		button

	return button

end

CreateTab("aimTab")
CreateTab("espTab")
CreateTab("moveTab")
CreateTab("miscTab")

--==============================================================
-- PAGES
--==============================================================

local PageContainer =
	Instance.new("Frame")

PageContainer.Size =
	UDim2.new(
		1,
		-20,
		1,
		-103
	)

PageContainer.Position =
	UDim2.fromOffset(
		10,
		99
	)

PageContainer.BackgroundTransparency =
	1

PageContainer.Parent =
	Hub

local function CreatePage()

	local page =
		Instance.new("ScrollingFrame")

	page.Size =
		UDim2.fromScale(
			1,
			1
		)

	page.BackgroundTransparency =
		1

	page.BorderSizePixel =
		0

	page.ScrollBarThickness =
		3

	page.ScrollBarImageColor3 =
		COLORS.Accent

	page.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	page.Visible =
		false

	page.Parent =
		PageContainer

	local layout =
		Instance.new("UIListLayout")

	layout.Padding =
		UDim.new(
			0,
			5
		)

	layout.Parent =
		page

	return page

end

Pages.aimTab =
	CreatePage()

Pages.espTab =
	CreatePage()

Pages.moveTab =
	CreatePage()

Pages.miscTab =
	CreatePage()

--==============================================================
-- UI HELPERS
--==============================================================

local Refreshers = {}

local function RegisterRefresh(fn)

	table.insert(
		Refreshers,
		fn
	)

end

local function RefreshUI()

	for _, fn in ipairs(
		Refreshers
	) do

		pcall(fn)

	end

end

local function Section(parent, text)

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-4,
			0,
			20
		)

	label.BackgroundTransparency =
		1

	label.Text =
		text

	label.TextColor3 =
		COLORS.Accent

	label.Font =
		Enum.Font.GothamBold

	label.TextSize =
		10

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent =
		parent

	return label

end

local function Toggle(
	parent,
	key,
	setting
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-4,
			0,
			33
		)

	button.BackgroundColor3 =
		COLORS.Panel

	button.BorderSizePixel =
		0

	button.Text =
		""

	button.AutoButtonColor =
		false

	button.Parent =
		parent

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			8
		)

	corner.Parent =
		button

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-65,
			1,
			0
		)

	label.Position =
		UDim2.fromOffset(
			11,
			0
		)

	label.BackgroundTransparency =
		1

	label.TextColor3 =
		COLORS.White

	label.Font =
		Enum.Font.Gotham

	label.TextSize =
		10

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent =
		button

	local state =
		Instance.new("TextLabel")

	state.Size =
		UDim2.fromOffset(
			43,
			21
		)

	state.Position =
		UDim2.new(
			1,
			-50,
			0.5,
			-10
		)

	state.BorderSizePixel =
		0

	state.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	state.Font =
		Enum.Font.GothamBold

	state.TextSize =
		8

	state.Parent =
		button

	local stateCorner =
		Instance.new("UICorner")

	stateCorner.CornerRadius =
		UDim.new(
			0,
			6
		)

	stateCorner.Parent =
		state

	local function Refresh()

		label.Text =
			T(key)

		if Settings[setting] then

			state.Text =
				T("on")

			state.BackgroundColor3 =
				COLORS.Green

		else

			state.Text =
				T("off")

			state.BackgroundColor3 =
				COLORS.Red

		end

	end

	button.MouseButton1Click:Connect(
		function()

			Settings[setting] =
				not Settings[setting]

			if setting ==
				"FlyEnabled" then

				if Settings.FlyEnabled then
					StartFly()
				else
					StopFly()
				end

			elseif setting ==
				"SpeedEnabled" then

				UpdateSpeed()

			elseif setting ==
				"NoRecoil"
				or setting ==
				"NoReload" then

				UpdateWeaponConfig()

			end

			Refresh()

		end
	)

	RegisterRefresh(
		Refresh
	)

	Refresh()

	return button

end

local function Slider(
	parent,
	key,
	setting,
	minimum,
	maximum,
	step
)

	local frame =
		Instance.new("Frame")

	frame.Size =
		UDim2.new(
			1,
			-4,
			0,
			48
		)

	frame.BackgroundColor3 =
		COLORS.Panel

	frame.BorderSizePixel =
		0

	frame.Parent =
		parent

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			8
		)

	corner.Parent =
		frame

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-20,
			0,
			20
		)

	label.Position =
		UDim2.fromOffset(
			10,
			2
		)

	label.BackgroundTransparency =
		1

	label.TextColor3 =
		COLORS.White

	label.Font =
		Enum.Font.Gotham

	label.TextSize =
		10

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent =
		frame

	local bar =
		Instance.new("Frame")

	bar.Size =
		UDim2.new(
			1,
			-20,
			0,
			5
		)

	bar.Position =
		UDim2.fromOffset(
			10,
			34
		)

	bar.BackgroundColor3 =
		Color3.fromRGB(
			50,
			51,
			61
		)

	bar.BorderSizePixel =
		0

	bar.Parent =
		frame

	local barCorner =
		Instance.new("UICorner")

	barCorner.CornerRadius =
		UDim.new(
			1,
			0
		)

	barCorner.Parent =
		bar

	local fill =
		Instance.new("Frame")

	fill.BackgroundColor3 =
		COLORS.Accent

	fill.BorderSizePixel =
		0

	fill.Parent =
		bar

	local fillCorner =
		Instance.new("UICorner")

	fillCorner.CornerRadius =
		UDim.new(
			1,
			0
		)

	fillCorner.Parent =
		fill

	local dragging = false

	local function SetValue(x)

		local percentage =
			math.clamp(
				(
					x
					- bar.AbsolutePosition.X
				)
				/
				bar.AbsoluteSize.X,
				0,
				1
			)

		local value =
			minimum
			+
			(
				maximum
				- minimum
			)
			*
			percentage

		if step then

			value =
				math.floor(
					value / step
					+ 0.5
				)
				*
				step

		end

		Settings[setting] =
			math.clamp(
				value,
				minimum,
				maximum
			)

	end

	local function Refresh()

		label.Text =
			T(key)
			..
			": "
			..
			tostring(
				math.floor(
					Settings[setting]
				)
			)

		local percentage =
			(
				Settings[setting]
				- minimum
			)
			/
			(
				maximum
				- minimum
			)

		fill.Size =
			UDim2.new(
				math.clamp(
					percentage,
					0,
					1
				),
				0,
				1,
				0
			)

	end

	bar.InputBegan:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1
				or
				input.UserInputType ==
				Enum.UserInputType.Touch then

				dragging = true

				SetValue(
					input.Position.X
				)

				Refresh()

			end

		end
	)

	UserInputService.InputChanged:Connect(
		function(input)

			if not dragging then
				return
			end

			if input.UserInputType ==
				Enum.UserInputType.MouseMovement
				or
				input.UserInputType ==
				Enum.UserInputType.Touch then

				SetValue(
					input.Position.X
				)

				Refresh()

			end

		end
	)

	UserInputService.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1
				or
				input.UserInputType ==
				Enum.UserInputType.Touch then

				dragging = false

			end

		end
	)

	RegisterRefresh(
		Refresh
	)

	Refresh()

	return frame

end

local function Cycle(
	parent,
	key,
	values,
	setting
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-4,
			0,
			33
		)

	button.BackgroundColor3 =
		COLORS.Panel

	button.BorderSizePixel =
		0

	button.TextColor3 =
		COLORS.White

	button.Font =
		Enum.Font.Gotham

	button.TextSize =
		10

	button.Parent =
		parent

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			8
		)

	corner.Parent =
		button

	local index = 1

	for i, value in ipairs(
		values
	) do

		if Settings[setting] ==
			value then

			index = i

		end

	end

	local function Refresh()

		local value =
			Settings[setting]

		if value == "Head" then

			value =
				T("head")

		elseif value == "Body" then

			value =
				T("body")

		end

		button.Text =
			T(key)
			..
			": "
			..
			value

	end

	button.MouseButton1Click:Connect(
		function()

			index += 1

			if index > #values then
				index = 1
			end

			Settings[setting] =
				values[index]

			Refresh()

		end
	)

	RegisterRefresh(
		Refresh
	)

	Refresh()

end

--==============================================================
-- AIM PAGE
--==============================================================

Section(
	Pages.aimTab,
	"AIM SYSTEM"
)

Toggle(
	Pages.aimTab,
	"aim",
	"AimEnabled"
)

Toggle(
	Pages.aimTab,
	"lock360",
	"Full360"
)

Slider(
	Pages.aimTab,
	"strength",
	"LockStrength",
	1,
	100,
	1
)

Slider(
	Pages.aimTab,
	"aimSpeed",
	"AimSpeed",
	1,
	100,
	1
)

Slider(
	Pages.aimTab,
	"aimDistance",
	"AimDistance",
	50,
	1000,
	10
)

--==============================================================
-- FOV 10 -> 999
--==============================================================

Slider(
	Pages.aimTab,
	"aimFov",
	"AimFOV",
	10,
	999,
	1
)

Cycle(
	Pages.aimTab,
	"target",
	{
		"Head",
		"Body"
	},
	"AimPart"
)

Toggle(
	Pages.aimTab,
	"teamCheck",
	"TeamCheck"
)

Toggle(
	Pages.aimTab,
	"wallCheck",
	"WallCheck"
)

--==============================================================
-- ESP PAGE
--==============================================================

Section(
	Pages.espTab,
	"ESP SYSTEM"
)

Toggle(
	Pages.espTab,
	"esp",
	"ESPEnabled"
)

Toggle(
	Pages.espTab,
	"cloud",
	"ESPCloud"
)

Toggle(
	Pages.espTab,
	"line",
	"ESPLine"
)

Toggle(
	Pages.espTab,
	"box",
	"ESPBox"
)

Toggle(
	Pages.espTab,
	"name",
	"ESPName"
)

Toggle(
	Pages.espTab,
	"health",
	"ESPHealth"
)

Toggle(
	Pages.espTab,
	"distance",
	"ESPDistance"
)

Toggle(
	Pages.espTab,
	"headMarker",
	"ESPHead"
)

Toggle(
	Pages.espTab,
	"always",
	"ESPAlwaysOnTop"
)

Toggle(
	Pages.espTab,
	"teamColor",
	"ESPTeamColor"
)

Slider(
	Pages.espTab,
	"espDistance",
	"ESPMaxDistance",
	50,
	1500,
	10
)

--==============================================================
-- MOVEMENT PAGE
--==============================================================

Section(
	Pages.moveTab,
	"MOVEMENT"
)

Toggle(
	Pages.moveTab,
	"fly",
	"FlyEnabled"
)

Slider(
	Pages.moveTab,
	"flySpeed",
	"FlySpeed",
	10,
	250,
	5
)

Slider(
	Pages.moveTab,
	"verticalSpeed",
	"FlyVerticalSpeed",
	10,
	250,
	5
)

Toggle(
	Pages.moveTab,
	"speedRun",
	"SpeedEnabled"
)

Slider(
	Pages.moveTab,
	"runSpeed",
	"SpeedRun",
	16,
	100,
	1
)

--==============================================================
-- MISC PAGE
--==============================================================

Section(
	Pages.miscTab,
	"WEAPON"
)

Toggle(
	Pages.miscTab,
	"noRecoil",
	"NoRecoil"
)

Toggle(
	Pages.miscTab,
	"noReload",
	"NoReload"
)

Section(
	Pages.miscTab,
	"PERFORMANCE"
)

Toggle(
	Pages.miscTab,
	"fpsBoost",
	"FPSBoost"
)

Toggle(
	Pages.miscTab,
	"dynamic",
	"DynamicFPS"
)

Toggle(
	Pages.miscTab,
	"showFps",
	"ShowFPS"
)

--==============================================================
-- PAGE SWITCH
--==============================================================

local function SelectPage(name)

	for key, page in pairs(
		Pages
	) do

		page.Visible =
			key == name

	end

	for key, button in pairs(
		Tabs
	) do

		if key == name then

			button.BackgroundColor3 =
				COLORS.Accent

			button.TextColor3 =
				COLORS.White

		else

			button.BackgroundColor3 =
				COLORS.Panel

			button.TextColor3 =
				COLORS.Gray

		end

	end

end

for key, button in pairs(
	Tabs
) do

	button.MouseButton1Click:Connect(
		function()

			SelectPage(key)

		end
	)

end

SelectPage("aimTab")

--==============================================================
-- LANGUAGE SWITCH
--==============================================================

local function RefreshLanguage()

	HeaderTitle.Text =
		T("title")

	HeaderSub.Text =
		T("subtitle")

	PasswordSub.Text =
		T("password")

	Enter.Text =
		T("enter")

	if Settings.Language ==
		"EN" then

		LanguageButton.Text =
			"EN"

	else

		LanguageButton.Text =
			"ខ្មែរ"

	end

	for key, button in pairs(
		Tabs
	) do

		button.Text =
			T(key)

	end

	RefreshUI()

end

LanguageButton.MouseButton1Click:Connect(
	function()

		if Settings.Language ==
			"EN" then

			Settings.Language =
				"KM"

		else

			Settings.Language =
				"EN"

		end

		RefreshLanguage()

	end
)

--==============================================================
-- DRAG HUB
--==============================================================

local HubDragging = false
local HubDragStart
local HubStartPosition

Header.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			HubDragging = true

			HubDragStart =
				input.Position

			HubStartPosition =
				Hub.Position

		end

	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if not HubDragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position
				- HubDragStart

			Hub.Position =
				UDim2.new(
					HubStartPosition.X.Scale,
					HubStartPosition.X.Offset
						+ delta.X,

					HubStartPosition.Y.Scale,
					HubStartPosition.Y.Offset
						+ delta.Y
				)

		end

	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			HubDragging = false

		end

	end
)

Close.MouseButton1Click:Connect(
	function()

		Hub.Visible = false

	end
)

--==============================================================
-- FLOATING XE BUTTON
--==============================================================

local XE =
	Instance.new("TextButton")

XE.Size =
	UDim2.fromOffset(
		50,
		50
	)

XE.Position =
	UDim2.new(
		0,
		15,
		0.5,
		-25
	)

XE.BackgroundColor3 =
	COLORS.Accent

XE.BorderSizePixel =
	0

XE.Text =
	"XE"

XE.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

XE.Font =
	Enum.Font.GothamBlack

XE.TextSize =
	15

XE.Parent =
	GUI

local XECorner =
	Instance.new("UICorner")

XECorner.CornerRadius =
	UDim.new(
		1,
		0
	)

XECorner.Parent =
	XE

--==============================================================
-- DRAG XE
--==============================================================

local LogoDragging = false
local LogoMoved = false

local LogoStart
local LogoPosition

XE.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			LogoDragging = true
			LogoMoved = false

			LogoStart =
				input.Position

			LogoPosition =
				XE.Position

		end

	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if not LogoDragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position
				- LogoStart

			if delta.Magnitude > 6 then
				LogoMoved = true
			end

			XE.Position =
				UDim2.new(
					LogoPosition.X.Scale,
					LogoPosition.X.Offset
						+ delta.X,

					LogoPosition.Y.Scale,
					LogoPosition.Y.Offset
						+ delta.Y
				)

		end

	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
			Enum.UserInputType.Touch then

			LogoDragging = false

		end

	end
)

XE.MouseButton1Click:Connect(
	function()

		if LogoMoved then
			return
		end

		Hub.Visible =
			not Hub.Visible

	end
)

--==============================================================
-- UNLOCK
--==============================================================

local Unlocked = false

local function Unlock()

	if PasswordBox.Text ==
		PASSWORD then

		Unlocked = true

		Wrong.Text = ""

		Password.Visible = false

		Hub.Visible = true

	else

		Wrong.Text =
			T("wrong")

		PasswordBox.Text =
			""

	end

end

Enter.MouseButton1Click:Connect(
	Unlock
)

PasswordBox.FocusLost:Connect(
	function(enterPressed)

		if enterPressed then
			Unlock()
		end

	end
)

--==============================================================
-- AIM HELPERS
--==============================================================

local function IsEnemy(player)

	if player ==
		LocalPlayer then

		return false

	end

	if Settings.TeamCheck
		and LocalPlayer.Team
		and player.Team ==
		LocalPlayer.Team then

		return false

	end

	return true

end

local function GetAimPart(character)

	if not character then
		return nil
	end

	if Settings.AimPart ==
		"Body" then

		return character:FindFirstChild(
			"HumanoidRootPart"
		)
		or
		character:FindFirstChild(
			"UpperTorso"
		)
		or
		character:FindFirstChild(
			"Torso"
		)

	end

	return character:FindFirstChild(
		"Head"
	)
	or
	character:FindFirstChild(
		"HumanoidRootPart"
	)

end

--==============================================================
-- WALL CHECK
--==============================================================

local function IsVisible(part)

	if not Settings.WallCheck then
		return true
	end

	if not part then
		return false
	end

	if not Camera then
		return false
	end

	local origin =
		Camera.CFrame.Position

	local direction =
		part.Position
		- origin

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances =
		{
			Character
		}

	params.IgnoreWater = true

	local result =
		Workspace:Raycast(
			origin,
			direction,
			params
		)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(
		part.Parent
	)

end

--==============================================================
-- FIND AIM TARGET
--==============================================================

local function FindAimTarget()

	local bestPart = nil
	local bestScore = math.huge

	local viewport =
		Camera.ViewportSize

	local center =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if IsEnemy(player) then

			local character =
				player.Character

			local humanoid =
				character
				and
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			local part =
				GetAimPart(
					character
				)

			if humanoid
				and humanoid.Health > 0
				and part then

				local distance =
					(
						part.Position
						- Camera.CFrame.Position
					).Magnitude

				if distance <=
					Settings.AimDistance then

					local screen,
						onScreen =
						Camera:WorldToViewportPoint(
							part.Position
						)

					if onScreen
						and screen.Z > 0 then

						local screenPosition =
							Vector2.new(
								screen.X,
								screen.Y
							)

						local screenDistance =
							(
								screenPosition
								- center
							).Magnitude

						local allowed

						if Settings.Full360 then

							allowed = true

						else

							local radius =
								math.min(
									viewport.X,
									viewport.Y
								)
								*
								(
									Settings.AimFOV
									/
									999
								)
								*
								0.5

							allowed =
								screenDistance
								<= radius

						end

						if allowed
							and
							IsVisible(part) then

							local score

							if Settings.Full360 then

								score =
									distance

							else

								score =
									screenDistance

							end

							if score <
								bestScore then

								bestScore =
									score

								bestPart =
									part

							end

						end

					end

				end

			end

		end

	end

	return bestPart

end

--==============================================================
-- ESP SYSTEM
--
-- IMPORTANT:
-- Objects are created ONCE.
-- We only update them.
-- No new line every frame.
--==============================================================

local ESPGUI =
	Instance.new("ScreenGui")

ESPGUI.Name =
	"XeirenESPSystem"

ESPGUI.ResetOnSpawn =
	false

ESPGUI.IgnoreGuiInset =
	true

ESPGUI.DisplayOrder =
	25

ESPGUI.Parent =
	PlayerGui

--==============================================================
-- ESP DATA
--==============================================================

local ESPData = {}

local function GetESPColor(player)

	if Settings.ESPTeamColor
		and player.Team then

		return player.Team.TeamColor.Color

	end

	return COLORS.ESP

end

local function RemoveESP(player)

	local data =
		ESPData[player]

	if not data then
		return
	end

	for _, object in pairs(
		data
	) do

		if typeof(object) ==
			"Instance"
			and object.Parent then

			object:Destroy()

		end

	end

	ESPData[player] =
		nil

end

--==============================================================
-- CREATE PLAYER ESP
--==============================================================

local function CreateESP(player)

	if player ==
		LocalPlayer then

		return nil

	end

	if ESPData[player] then
		return ESPData[player]
	end

	local data = {}

	--==========================================================
	-- HIGHLIGHT
	--==========================================================

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"XE_Box_" .. player.UserId

	highlight.Enabled =
		false

	highlight.FillTransparency =
		0.82

	highlight.OutlineTransparency =
		0

	highlight.Parent =
		ESPGUI

	data.Highlight =
		highlight

	--==========================================================
	-- BILLBOARD
	--==========================================================

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"XE_Info_" .. player.UserId

	billboard.Size =
		UDim2.fromOffset(
			190,
			65
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3.2,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.Enabled =
		false

	billboard.Parent =
		ESPGUI

	data.Billboard =
		billboard

	--==========================================================
	-- NAME
	--==========================================================

	local name =
		Instance.new("TextLabel")

	name.Size =
		UDim2.new(
			1,
			0,
			0,
			20
		)

	name.BackgroundTransparency =
		1

	name.TextColor3 =
		COLORS.White

	name.TextStrokeTransparency =
		0.15

	name.Font =
		Enum.Font.GothamBold

	name.TextSize =
		12

	name.Parent =
		billboard

	data.Name =
		name

	--==========================================================
	-- DISTANCE
	--==========================================================

	local distance =
		Instance.new("TextLabel")

	distance.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	distance.Position =
		UDim2.fromOffset(
			0,
			20
		)

	distance.BackgroundTransparency =
		1

	distance.TextColor3 =
		COLORS.Gray

	distance.TextStrokeTransparency =
		0.2

	distance.Font =
		Enum.Font.Gotham

	distance.TextSize =
		10

	distance.Parent =
		billboard

	data.Distance =
		distance

	--==========================================================
	-- HP
	--==========================================================

	local hp =
		Instance.new("TextLabel")

	hp.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	hp.Position =
		UDim2.fromOffset(
			0,
			39
		)

	hp.BackgroundTransparency =
		1

	hp.TextColor3 =
		COLORS.Green

	hp.TextStrokeTransparency =
		0.2

	hp.Font =
		Enum.Font.GothamBold

	hp.TextSize =
		10

	hp.Parent =
		billboard

	data.Health =
		hp

	--==========================================================
	-- HEAD MARKER
	--==========================================================

	local headMarker =
		Instance.new("BillboardGui")

	headMarker.Name =
		"XE_Head_" .. player.UserId

	headMarker.Size =
		UDim2.fromOffset(
			25,
			25
		)

	headMarker.AlwaysOnTop =
		true

	headMarker.Enabled =
		false

	headMarker.Parent =
		ESPGUI

	local marker =
		Instance.new("TextLabel")

	marker.Size =
		UDim2.fromScale(
			1,
			1
		)

	marker.BackgroundTransparency =
		1

	marker.Text =
		"●"

	marker.TextColor3 =
		COLORS.ESP

	marker.TextStrokeTransparency =
		0

	marker.Font =
		Enum.Font.GothamBold

	marker.TextSize =
		12

	marker.Parent =
		headMarker

	data.Head =
		headMarker

	--==========================================================
	-- ONE SCREEN LINE
	--==========================================================

	local line =
		Instance.new("Frame")

	line.Name =
		"XE_Line_" .. player.UserId

	line.AnchorPoint =
		Vector2.new(
			0,
			0.5
		)

	line.Size =
		UDim2.fromOffset(
			1,
			2
		)

	line.BorderSizePixel =
		0

	line.Visible =
		false

	line.Parent =
		ESPGUI

	data.Line =
		line

	ESPData[player] =
		data

	return data

end

--==============================================================
-- UPDATE A SINGLE ESP LINE
--==============================================================

local function UpdateLine(
	player,
	data
)

	local line =
		data.Line

	if not Settings.ESPEnabled
		or not Settings.ESPLine then

		line.Visible =
			false

		return

	end

	if not IsEnemy(player) then

		line.Visible =
			false

		return

	end

	local character =
		player.Character

	local humanoid =
		character
		and
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	local root =
		character
		and
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not humanoid
		or humanoid.Health <= 0
		or not root then

		line.Visible =
			false

		return

	end

	local distance =
		(
			root.Position
			- Camera.CFrame.Position
		).Magnitude

	if distance >
		Settings.ESPMaxDistance then

		line.Visible =
			false

		return

	end

	if Settings.WallCheck
		and
		not IsVisible(root) then

		line.Visible =
			false

		return

	end

	local screen,
		onScreen =
		Camera:WorldToViewportPoint(
			root.Position
		)

	if not onScreen
		or screen.Z <= 0 then

		line.Visible =
			false

		return

	end

	--==========================================================
	-- IMPORTANT:
	-- Start point is at bottom center.
	-- End point is the ACTUAL player position.
	--==========================================================

	local viewport =
		Camera.ViewportSize

	local startPosition =
		Vector2.new(
			viewport.X / 2,
			viewport.Y - 65
		)

	local endPosition =
		Vector2.new(
			screen.X,
			screen.Y
		)

	local delta =
		endPosition
		- startPosition

	local length =
		delta.Magnitude

	if length < 2 then

		line.Visible =
			false

		return

	end

	line.BackgroundColor3 =
		GetESPColor(player)

	line.Position =
		UDim2.fromOffset(
			startPosition.X,
			startPosition.Y
		)

	line.Size =
		UDim2.fromOffset(
			length,
			2
		)

	line.Rotation =
		math.deg(
			math.atan2(
				delta.Y,
				delta.X
			)
		)

	line.Visible =
		true

end

--==============================================================
-- UPDATE PLAYER ESP
--==============================================================

local function UpdateESPPlayer(
	player
)

	if player ==
		LocalPlayer then

		return

	end

	local data =
		CreateESP(player)

	if not data then
		return
	end

	if not Settings.ESPEnabled then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		data.Head.Enabled =
			false

		data.Line.Visible =
			false

		return

	end

	if not IsEnemy(player) then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		data.Head.Enabled =
			false

		data.Line.Visible =
			false

		return

	end

	local character =
		player.Character

	local humanoid =
		character
		and
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	local root =
		character
		and
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	local head =
		character
		and
		character:FindFirstChild(
			"Head"
		)

	if not humanoid
		or humanoid.Health <= 0
		or not root then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		data.Head.Enabled =
			false

		data.Line.Visible =
			false

		return

	end

	local distance =
		(
			root.Position
			- Camera.CFrame.Position
		).Magnitude

	if distance >
		Settings.ESPMaxDistance then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		data.Head.Enabled =
			false

		data.Line.Visible =
			false

		return

	end

	local color =
		GetESPColor(player)

	--==========================================================
	-- BOX
	--==========================================================

	if Settings.ESPBox then

		data.Highlight.Enabled =
			true

		data.Highlight.Adornee =
			character

		data.Highlight.FillColor =
			color

		data.Highlight.OutlineColor =
			color

		if Settings.ESPAlwaysOnTop then

			data.Highlight.DepthMode =
				Enum.HighlightDepthMode.AlwaysOnTop

		else

			data.Highlight.DepthMode =
				Enum.HighlightDepthMode.Occluded

		end

	else

		data.Highlight.Enabled =
			false

	end

	--==========================================================
	-- NAME / HP / DISTANCE
	--==========================================================

	if Settings.ESPName
		or
		Settings.ESPHealth
		or
		Settings.ESPDistance then

		data.Billboard.Enabled =
			true

		data.Billboard.Adornee =
			head
			or
			root

		data.Name.Visible =
			Settings.ESPName

		data.Health.Visible =
			Settings.ESPHealth

		data.Distance.Visible =
			Settings.ESPDistance

		data.Name.Text =
			player.DisplayName
			~= ""
			and
			player.DisplayName
			or
			player.Name

		data.Name.TextColor3 =
			color

		data.Distance.Text =
			math.floor(
				distance
			)
			..
			" studs"

		local hp =
			math.max(
				humanoid.Health,
				0
			)

		local maxHP =
			math.max(
				humanoid.MaxHealth,
				1
			)

		data.Health.Text =
			"HP: "
			..
			math.floor(hp)
			..
			" / "
			..
			math.floor(maxHP)

		local ratio =
			math.clamp(
				hp / maxHP,
				0,
				1
			)

		data.Health.TextColor3 =
			Color3.new(
				1 - ratio,
				ratio,
				0
			)

	else

		data.Billboard.Enabled =
			false

	end

	--==========================================================
	-- HEAD
	--==========================================================

	if Settings.ESPHead
		and
		head then

		data.Head.Adornee =
			head

		data.Head.Enabled =
			true

	else

		data.Head.Enabled =
			false

	end

	--==========================================================
	-- LINE
	--==========================================================

	UpdateLine(
		player,
		data
	)

end

--==============================================================
-- PLAYER ESP LOOP
--==============================================================

local ESPAccumulator = 0

RunService.RenderStepped:Connect(
	function(deltaTime)

		if not Unlocked then
			return
		end

		Camera =
			Workspace.CurrentCamera

		ESPAccumulator +=
			deltaTime

		local interval =
			1 /
			math.max(
				Settings.ESPUpdateRate,
				1
			)

		if ESPAccumulator >=
			interval then

			ESPAccumulator =
				0

			for _, player in ipairs(
				Players:GetPlayers()
			) do

				if player ~=
					LocalPlayer then

					UpdateESPPlayer(
						player
					)

				end

			end

		end

	end
)

--==============================================================
-- PLAYER CLEANUP
--==============================================================

Players.PlayerRemoving:Connect(
	function(player)

		RemoveESP(player)

	end
)

--==============================================================
-- RESPAWN CLEANUP
--==============================================================

Players.PlayerAdded:Connect(
	function(player)

		if player ==
			LocalPlayer then

			return

		end

		player.CharacterRemoving:Connect(
			function()

				local data =
					ESPData[player]

				if data then

					data.Highlight.Enabled =
						false

					data.Billboard.Enabled =
						false

					data.Head.Enabled =
						false

					data.Line.Visible =
						false

				end

			end
		)

	end
)

for _, player in ipairs(
	Players:GetPlayers()
) do

	if player ~=
		LocalPlayer then

		player.CharacterRemoving:Connect(
			function()

				local data =
					ESPData[player]

				if data then

					data.Highlight.Enabled =
						false

					data.Billboard.Enabled =
						false

					data.Head.Enabled =
						false

					data.Line.Visible =
						false

				end

			end
		)

	end

end

--==============================================================
-- FLY SYSTEM
--==============================================================

local FlyAttachment
local FlyVelocity

local UpHeld = false
local DownHeld = false

local function StopFly()

	Settings.FlyEnabled =
		false

	if FlyVelocity then

		FlyVelocity:Destroy()

		FlyVelocity =
			nil

	end

	if FlyAttachment then

		FlyAttachment:Destroy()

		FlyAttachment =
			nil

	end

	if Humanoid then

		Humanoid.AutoRotate =
			true

	end

end

function StopFly()
	-- intentionally public
	Settings.FlyEnabled = false

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end

	if Humanoid then
		Humanoid.AutoRotate = true
	end
end

function StartFly()

	if not Root
		or not Humanoid then

		return

	end

	if FlyVelocity then

		FlyVelocity:Destroy()

	end

	if FlyAttachment then

		FlyAttachment:Destroy()

	end

	Settings.FlyEnabled =
		true

	Humanoid.AutoRotate =
		false

	-- Remove falling velocity
	Root.AssemblyLinearVelocity =
		Vector3.zero

	FlyAttachment =
		Instance.new(
			"Attachment"
		)

	FlyAttachment.Name =
		"XE_FlyAttachment"

	FlyAttachment.Parent =
		Root

	FlyVelocity =
		Instance.new(
			"LinearVelocity"
		)

	FlyVelocity.Name =
		"XE_FlyVelocity"

	FlyVelocity.Attachment0 =
		FlyAttachment

	FlyVelocity.RelativeTo =
		Enum.ActuatorRelativeTo.World

	FlyVelocity.VelocityConstraintMode =
		Enum.VelocityConstraintMode.Vector

	FlyVelocity.MaxForce =
		math.huge

	FlyVelocity.VectorVelocity =
		Vector3.zero

	FlyVelocity.Parent =
		Root

end

--==============================================================
-- MOBILE FLY BUTTONS
--==============================================================

local FlyUI =
	Instance.new("ScreenGui")

FlyUI.Name =
	"XeirenFlyControls"

FlyUI.ResetOnSpawn =
	false

FlyUI.IgnoreGuiInset =
	true

FlyUI.DisplayOrder =
	22

FlyUI.Parent =
	PlayerGui

local FlyButtons =
	Instance.new("Frame")

FlyButtons.Size =
	UDim2.fromOffset(
		112,
		48
	)

FlyButtons.Position =
	UDim2.new(
		1,
		-125,
		0.5,
		70
	)

FlyButtons.BackgroundTransparency =
	1

FlyButtons.Visible =
	false

FlyButtons.Parent =
	FlyUI

local UpButton =
	Instance.new("TextButton")

UpButton.Size =
	UDim2.fromOffset(
		50,
		42
	)

UpButton.BackgroundColor3 =
	COLORS.Panel

UpButton.BorderSizePixel =
	0

UpButton.Text =
	"▲"

UpButton.TextColor3 =
	COLORS.White

UpButton.Font =
	Enum.Font.GothamBold

UpButton.TextSize =
	17

UpButton.Parent =
	FlyButtons

local UpCorner =
	Instance.new("UICorner")

UpCorner.CornerRadius =
	UDim.new(
		0,
		10
	)

UpCorner.Parent =
	UpButton

local DownButton =
	Instance.new("TextButton")

DownButton.Size =
	UDim2.fromOffset(
		50,
		42
	)

DownButton.Position =
	UDim2.fromOffset(
		58,
		0
	)

DownButton.BackgroundColor3 =
	COLORS.Panel

DownButton.BorderSizePixel =
	0

DownButton.Text =
	"▼"

DownButton.TextColor3 =
	COLORS.White

DownButton.Font =
	Enum.Font.GothamBold

DownButton.TextSize =
	17

DownButton.Parent =
	FlyButtons

local DownCorner =
	Instance.new("UICorner")

DownCorner.CornerRadius =
	UDim.new(
		0,
		10
	)

DownCorner.Parent =
	DownButton

local function HoldButton(
	button,
	callback
)

	button.InputBegan:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.Touch
				or
				input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				callback(true)

			end

		end
	)

	button.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.Touch
				or
				input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				callback(false)

			end

		end
	)

end

HoldButton(
	UpButton,
	function(value)

		UpHeld =
			value

	end
)

HoldButton(
	DownButton,
	function(value)

		DownHeld =
			value

	end
)

--==============================================================
-- FLY UPDATE
--==============================================================

local function UpdateFly()

	if not Settings.FlyEnabled then
		return
	end

	if not Root
		or not Humanoid
		or Humanoid.Health <= 0 then

		StopFly()

		return

	end

	if not FlyVelocity then

		StartFly()

		return

	end

	local cameraCF =
		Camera.CFrame

	local forward =
		Vector3.new(
			cameraCF.LookVector.X,
			0,
			cameraCF.LookVector.Z
		)

	local right =
		Vector3.new(
			cameraCF.RightVector.X,
			0,
			cameraCF.RightVector.Z
		)

	if forward.Magnitude > 0 then

		forward =
			forward.Unit

	end

	if right.Magnitude > 0 then

		right =
			right.Unit

	end

	local movement =
		Humanoid.MoveDirection

	local horizontal =
		Vector3.zero

	if movement.Magnitude >
		0.01 then

		local forwardAmount =
			movement:Dot(
				forward
			)

		local rightAmount =
			movement:Dot(
				right
			)

		horizontal =
			forward
			* forwardAmount
			+
			right
			* rightAmount

		if horizontal.Magnitude > 1 then

			horizontal =
				horizontal.Unit

		end

	end

	local vertical =
		0

	if UserInputService:IsKeyDown(
		Enum.KeyCode.Space
	) then

		vertical +=
			Settings.FlyVerticalSpeed

	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.LeftControl
	) then

		vertical -=
			Settings.FlyVerticalSpeed

	end

	if UpHeld then

		vertical +=
			Settings.FlyVerticalSpeed

	end

	if DownHeld then

		vertical -=
			Settings.FlyVerticalSpeed

	end

	-- ALWAYS set Y velocity.
	-- This prevents gravity from making
	-- the player slowly drop while flying.

	FlyVelocity.VectorVelocity =
		horizontal
		*
		Settings.FlySpeed
		+
		Vector3.new(
			0,
			vertical,
			0
		)

	FlyButtons.Visible =
		UserInputService.TouchEnabled

end

--==============================================================
-- SPEED
--==============================================================

local NormalWalkSpeed = 16

function UpdateSpeed()

	if not Humanoid then
		return
	end

	if Settings.SpeedEnabled then

		Humanoid.WalkSpeed =
			Settings.SpeedRun

	else

		Humanoid.WalkSpeed =
			NormalWalkSpeed

	end

end

--==============================================================
-- KEYBINDS
--==============================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if not Unlocked then
			return
		end

		-- R = Fly

		if input.KeyCode ==
			Enum.KeyCode.R then

			if Settings.FlyEnabled then

				StopFly()

			else

				StartFly()

			end

			RefreshUI()

		end

		-- V = Speed

		if input.KeyCode ==
			Enum.KeyCode.V then

			Settings.SpeedEnabled =
				not Settings.SpeedEnabled

			UpdateSpeed()

			RefreshUI()

		end

	end
)

--==============================================================
-- AIM UPDATE
--==============================================================

local function UpdateAim()

	if not Settings.AimEnabled then
		return
	end

	local target =
		FindAimTarget()

	if not target then
		return
	end

	local cameraPosition =
		Camera.CFrame.Position

	local targetCFrame =
		CFrame.lookAt(
			cameraPosition,
			target.Position
		)

	local strength =
		math.clamp(
			Settings.LockStrength
			/
			100,
			0.01,
			1
		)

	local speed =
		math.clamp(
			Settings.AimSpeed
			/
			100,
			0.01,
			1
		)

	local alpha =
		math.clamp(
			strength
			*
			speed
			*
			0.4,
			0.01,
			1
		)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			targetCFrame,
			alpha
		)

end

--==============================================================
-- FPS BOOST
--==============================================================

local function ApplyFPSBoost()

	if not Settings.FPSBoost then
		return
	end

	Lighting.GlobalShadows =
		false

	Lighting.FogEnd =
		100000

	for _, effect in ipairs(
		Lighting:GetChildren()
	) do

		if effect:IsA(
			"BloomEffect"
		)
		or
		effect:IsA(
			"BlurEffect"
		)
		or
		effect:IsA(
			"ColorCorrectionEffect"
		)
		or
		effect:IsA(
			"SunRaysEffect"
		)
		or
		effect:IsA(
			"DepthOfFieldEffect"
		) then

			effect.Enabled =
				false

		end

	end

	local terrain =
		Workspace:FindFirstChildOfClass(
			"Terrain"
		)

	if terrain then

		terrain.Decoration =
			false

		terrain.WaterWaveSize =
			0

		terrain.WaterWaveSpeed =
			0

		terrain.WaterReflectance =
			0

	end

end

--==============================================================
-- FPS COUNTER
--==============================================================

local FPS =
	Instance.new("TextLabel")

FPS.Size =
	UDim2.fromOffset(
		100,
		22
	)

FPS.Position =
	UDim2.fromOffset(
		10,
		10
	)

FPS.BackgroundTransparency =
	1

FPS.TextColor3 =
	COLORS.White

FPS.TextStrokeTransparency =
	0.25

FPS.Font =
	Enum.Font.GothamBold

FPS.TextSize =
	10

FPS.TextXAlignment =
	Enum.TextXAlignment.Left

FPS.Visible =
	false

FPS.Parent =
	GUI

local FPSFrames =
	0

local FPSTimer =
	0

--==============================================================
-- MAIN RENDER LOOP
--==============================================================

RunService.RenderStepped:Connect(
	function(deltaTime)

		if not Unlocked then
			return
		end

		Camera =
			Workspace.CurrentCamera

		-- AIM
		UpdateAim()

		-- FLY
		if Settings.FlyEnabled then

			UpdateFly()

		else

			FlyButtons.Visible =
				false

		end

		-- SPEED
		if Settings.SpeedEnabled then

			UpdateSpeed()

		end

		-- FPS
		FPSFrames += 1

		FPSTimer +=
			deltaTime

		if FPSTimer >=
			0.5 then

			local currentFPS =
				math.floor(
					FPSFrames
					/
					FPSTimer
				)

			FPSFrames =
				0

			FPSTimer =
				0

			FPS.Text =
				"FPS: "
				..
				currentFPS

			FPS.Visible =
				Settings.ShowFPS

		end

	end
)

--==============================================================
-- CHARACTER ADDED
--==============================================================

LocalPlayer.CharacterAdded:Connect(
	function(character)

		SetupCharacter(
			character
		)

		-- Stop fly after respawn
		StopFly()

		task.wait(
			0.3
		)

		UpdateSpeed()

	end
)

--==============================================================
-- PLAYER CHARACTER TRACKING
--==============================================================

local function ConnectPlayer(
	player
)

	if player ==
		LocalPlayer then

		return

	end

	player.CharacterRemoving:Connect(
		function()

			local data =
				ESPData[player]

			if data then

				data.Highlight.Enabled =
					false

				data.Billboard.Enabled =
					false

				data.Head.Enabled =
					false

				data.Line.Visible =
					false

			end

		end
	)

end

for _, player in ipairs(
	Players:GetPlayers()
) do

	ConnectPlayer(
		player
	)

end

Players.PlayerAdded:Connect(
	function(player)

		ConnectPlayer(
			player
		)

	end
)

--==============================================================
-- DYNAMIC PERFORMANCE
--==============================================================

task.spawn(
	function()

		while GUI.Parent do

			task.wait(3)

			if Unlocked
				and
				Settings.FPSBoost
				and
				Settings.DynamicFPS then

				ApplyFPSBoost()

			end

		end

	end
)

--==============================================================
-- START
--==============================================================

task.delay(
	1,
	function()

		if Settings.FPSBoost then

			ApplyFPSBoost()

		end

	end
)

print(
	"[XEIREN] Combat Hub loaded"
)

print(
	"[XEIREN] Password: anakin"
)

print(
	"[XEIREN] R = Fly | V = Speed"
)
