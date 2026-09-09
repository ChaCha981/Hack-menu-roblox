--==============================================================
-- SPECTER X v8.7 - CLEAN SKY TRACERS & OPTIMIZED ESP ENGINE
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global State Configuration
local State = {
	MenuOpen = true,

	-- AIM
	AimEnabled = false,
	Aim360 = false,
	AimFOV = 130,
	AimSmoothness = 0.3,
	AimRange = 500,
	TargetPart = "Head",
	AimTeamCheck = false,
	AimLOS = false,
	AimPriorityDistance = true,

	-- ESP
	ESPEnabled = true,
	ESPBox = true,
	ESPName = true,
	ESPHealth = true,
	ESPDistance = true,
	ESPLine = true,
	ESPTeamCheck = false,
	ESPMaxDistance = 2000,
	ESPTextPosIndex = 1,
	ESPTextPosMode = "Top",

	-- MOVEMENT
	WalkSpeed = 16,
	JumpPower = 50,

	-- PROTECTION
	StreamerMode = true
}

-- Protection and Parent Resolver
local function GetProtectedContainer()
	if gethui then
		return gethui()
	elseif syn and syn.protect_gui then
		local container = Instance.new("Folder")
		container.Name = "SPECTER_PROTECTED_CONTAINER"
		syn.protect_gui(container)
		container.Parent = CoreGui
		return container
	else
		return CoreGui
	end
end

local ProtectedParent = GetProtectedContainer()

-- Deep System Instance Cleanup (Prevents Screen Spam & Duplication)
for _, container in ipairs({ProtectedParent, CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}) do
	if container then
		for _, name in ipairs({"SPECTER_X_MOBILE", "SPECTER_X_ESP_CONTAINER", "SPECTER_X_TRACERS"}) do
			local old = container:FindFirstChild(name)
			if old then old:Destroy() end
		end
	end
end

local CurrentAimTarget = nil
local Character, Humanoid, Root

local function LoadCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid", 10)
	Root = char:WaitForChild("HumanoidRootPart", 10)
	CurrentAimTarget = nil

	if Humanoid then
		Humanoid.WalkSpeed = State.WalkSpeed
		Humanoid.JumpPower = State.JumpPower
	end
end

if LocalPlayer.Character then task.spawn(LoadCharacter, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(LoadCharacter)

-- UI Instance Factory
local function New(className, properties, parent)
	local object = Instance.new(className)
	for prop, val in pairs(properties or {}) do
		object[prop] = val
	end
	object.Parent = parent
	return object
end

local function Round(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = object
	return corner
end

local function Stroke(object, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(110, 70, 160)
	stroke.Transparency = transparency or 0.25
	stroke.Thickness = thickness or 1
	stroke.Parent = object
	return stroke
end

-- GUI Root
local MainGui = New("ScreenGui", {
	Name = "SPECTER_X_MOBILE",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, ProtectedParent)

-- Floating Toggle Logo
local Logo = New("TextButton", {
	Name = "SPECTER_X_LOGO",
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.new(0, 18, 0.5, -22),
	BackgroundColor3 = Color3.fromRGB(18, 14, 26),
	BorderSizePixel = 0,
	Text = "X",
	Font = Enum.Font.GothamBlack,
	TextSize = 20,
	TextColor3 = Color3.fromRGB(225, 195, 255),
	AutoButtonColor = false,
	ZIndex = 20
}, MainGui)

Round(Logo, 22)
Stroke(Logo, Color3.fromRGB(140, 85, 200), 0.1, 1.5)

-- Main Frame
local Main = New("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(420, 330),
	Position = UDim2.new(0.5, -210, 0.5, -165),
	BackgroundColor3 = Color3.fromRGB(12, 12, 16),
	ClipsDescendants = true,
	BorderSizePixel = 0,
	ZIndex = 10
}, MainGui)

Round(Main, 14)
Stroke(Main, Color3.fromRGB(80, 50, 125), 0.2, 1)

-- Header Bar
local Header = New("Frame", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundColor3 = Color3.fromRGB(18, 16, 24),
	BorderSizePixel = 0,
	ZIndex = 11
}, Main)

New("TextLabel", {
	Size = UDim2.fromOffset(160, 22),
	Position = UDim2.fromOffset(14, 6),
	BackgroundTransparency = 1,
	Text = "SPECTER X",
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = Color3.fromRGB(230, 200, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 12
}, Header)

New("TextLabel", {
	Size = UDim2.fromOffset(220, 14),
	Position = UDim2.fromOffset(15, 26),
	BackgroundTransparency = 1,
	Text = "v8.7 CLEAN SKY TRACERS",
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	TextColor3 = Color3.fromRGB(120, 215, 135),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 12
}, Header)

local CloseButton = New("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -36, 0, 8),
	BackgroundColor3 = Color3.fromRGB(32, 24, 40),
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = Color3.fromRGB(220, 195, 230),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	ZIndex = 13
}, Header)
Round(CloseButton, 14)

-- Sidebar Navigation
local Sidebar = New("Frame", {
	Size = UDim2.fromOffset(86, 276),
	Position = UDim2.fromOffset(8, 48),
	BackgroundColor3 = Color3.fromRGB(16, 15, 22),
	BorderSizePixel = 0,
	ZIndex = 11
}, Main)
Round(Sidebar, 10)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 4)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 6)
SidePadding.PaddingLeft = UDim.new(0, 5)
SidePadding.PaddingRight = UDim.new(0, 5)
SidePadding.Parent = Sidebar

local Tabs = {}
local TabNames = { {"HOME", "⌂"}, {"AIM", "◎"}, {"ESP", "◉"}, {"MOVE", "↗"}, {"SET", "⚙"} }

for index, data in ipairs(TabNames) do
	local button = New("TextButton", {
		Name = data[1],
		Size = UDim2.new(1, 0, 0, 47),
		BackgroundColor3 = Color3.fromRGB(22, 21, 28),
		BorderSizePixel = 0,
		Text = data[2] .. "  " .. data[1],
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(140, 140, 155),
		AutoButtonColor = false,
		LayoutOrder = index,
		ZIndex = 12
	}, Sidebar)
	Round(button, 8)
	Tabs[data[1]] = button
end

-- Pages Container
local Pages = {}
local function CreatePage(name)
	local page = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, -108, 1, -54),
		Position = UDim2.fromOffset(100, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.5,
		Visible = false,
		ZIndex = 11
	}, Main)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 2)
	pad.PaddingRight = UDim.new(0, 6)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = page

	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 5)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = page

	Pages[name] = page
	return page
end

local HomePage = CreatePage("HOME")
local AimPage = CreatePage("AIM")
local ESPPage = CreatePage("ESP")
local MovePage = CreatePage("MOVE")
local SetPage = CreatePage("SET")

local function SetActiveTab(name)
	for tabName, btn in pairs(Tabs) do
		if tabName == name then
			btn.BackgroundColor3 = Color3.fromRGB(65, 40, 85)
			btn.TextColor3 = Color3.fromRGB(235, 210, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(22, 21, 28)
			btn.TextColor3 = Color3.fromRGB(140, 140, 155)
		end
	end
	for pName, page in pairs(Pages) do
		page.Visible = (pName == name)
	end
end

for name, btn in pairs(Tabs) do
	btn.MouseButton1Click:Connect(function() SetActiveTab(name) end)
end

-- Component Factories
local function Toggle(parent, title, desc, getValue, setValue)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Color3.fromRGB(19, 18, 25),
		BorderSizePixel = 0,
		ZIndex = 12
	}, parent)
	Round(row, 8)

	New("TextLabel", {
		Size = UDim2.new(1, -60, 0, 18),
		Position = UDim2.fromOffset(10, 5),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(220, 220, 230),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13
	}, row)

	New("TextLabel", {
		Size = UDim2.new(1, -60, 0, 14),
		Position = UDim2.fromOffset(10, 24),
		BackgroundTransparency = 1,
		Text = desc,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextColor3 = Color3.fromRGB(115, 115, 130),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13
	}, row)

	local switch = New("TextButton", {
		Size = UDim2.fromOffset(36, 20),
		Position = UDim2.new(1, -44, 0.5, -10),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		Text = "",
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 14
	}, row)
	Round(switch, 10)

	local dot = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Color3.fromRGB(150, 150, 160),
		BorderSizePixel = 0,
		ZIndex = 15
	}, switch)
	Round(dot, 10)

	local function Refresh()
		if getValue() then
			switch.BackgroundColor3 = Color3.fromRGB(110, 60, 155)
			dot.Position = UDim2.fromOffset(19, 3)
			dot.BackgroundColor3 = Color3.fromRGB(240, 225, 255)
		else
			switch.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			dot.Position = UDim2.fromOffset(3, 3)
			dot.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
		end
	end

	switch.MouseButton1Click:Connect(function()
		setValue(not getValue())
		Refresh()
	end)

	Refresh()
	return { Row = row, Refresh = Refresh }
end

local function ValueControl(parent, title, getValue, setValue, min, max, step)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Color3.fromRGB(19, 18, 25),
		BorderSizePixel = 0,
		ZIndex = 12
	}, parent)
	Round(row, 8)

	New("TextLabel", {
		Size = UDim2.new(1, -80, 0, 18),
		Position = UDim2.fromOffset(10, 4),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(205, 205, 215),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13
	}, row)

	local valueLabel = New("TextLabel", {
		Size = UDim2.fromOffset(65, 18),
		Position = UDim2.new(1, -74, 0, 4),
		BackgroundTransparency = 1,
		Text = tostring(getValue()),
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(205, 170, 245),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 13
	}, row)

	local slider = New("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 0, 35),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BorderSizePixel = 0,
		ZIndex = 13
	}, row)
	Round(slider, 5)

	local fill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(120, 70, 165),
		BorderSizePixel = 0,
		ZIndex = 14
	}, slider)
	Round(fill, 5)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(235, 220, 250),
		BorderSizePixel = 0,
		ZIndex = 15
	}, slider)
	Round(knob, 10)

	local dragging = false
	local function Refresh()
		local val = getValue()
		local norm = math.clamp((val - min) / math.max(max - min, 0.0001), 0, 1)
		fill.Size = UDim2.new(norm, 0, 1, 0)
		knob.Position = UDim2.new(norm, 0, 0.5, 0)
		valueLabel.Text = tostring(val)
	end

	local function UpdateX(x)
		local pos = slider.AbsolutePosition
		local sz = slider.AbsoluteSize
		local pct = math.clamp((x - pos.X) / math.max(sz.X, 1), 0, 1)
		local val = min + (max - min) * pct
		if step and step > 0 then
			val = math.floor(((val - min) / step) + 0.5) * step + min
		end
		setValue(math.clamp(val, min, max))
		Refresh()
	end

	slider.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateX(inp.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.MouseMovement) then
			UpdateX(inp.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	Refresh()
	return { Row = row, Refresh = Refresh }
end

local function Dropdown(parent, title, options, getValue, setValue)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Color3.fromRGB(19, 18, 25),
		BorderSizePixel = 0,
		ZIndex = 12
	}, parent)
	Round(row, 8)

	New("TextLabel", {
		Size = UDim2.new(1, -110, 0, 18),
		Position = UDim2.fromOffset(10, 14),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(220, 220, 230),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13
	}, row)

	local btn = New("TextButton", {
		Size = UDim2.fromOffset(90, 24),
		Position = UDim2.new(1, -98, 0.5, -12),
		BackgroundColor3 = Color3.fromRGB(50, 40, 65),
		Text = getValue(),
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(230, 205, 255),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 14
	}, row)
	Round(btn, 6)

	local currentIndex = 1
	for i, v in ipairs(options) do
		if v == getValue() then currentIndex = i break end
	end

	btn.MouseButton1Click:Connect(function()
		currentIndex = currentIndex + 1
		if currentIndex > #options then currentIndex = 1 end
		local chosen = options[currentIndex]
		setValue(chosen, currentIndex)
		btn.Text = chosen
	end)

	return { Row = row }
end

-- Home Setup
New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	Text = "SPECTER X v8.7 SKY TRACERS",
	Font = Enum.Font.GothamBlack,
	TextSize = 16,
	TextColor3 = Color3.fromRGB(220, 190, 250),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 12
}, HomePage)

-- Control Wiring
Toggle(AimPage, "Aim Lock", "Master aimbot switch", function() return State.AimEnabled end, function(v) State.AimEnabled = v if not v then CurrentAimTarget = nil end end)
Toggle(AimPage, "Line of Sight Check", "Ignore players hiding behind walls", function() return State.AimLOS end, function(v) State.AimLOS = v end)
Toggle(AimPage, "Priority Nearest Studs", "Target closest physical player first", function() return State.AimPriorityDistance end, function(v) State.AimPriorityDistance = v end)
Toggle(AimPage, "Ignore Teammates", "Do not target team members", function() return State.AimTeamCheck end, function(v) State.AimTeamCheck = v CurrentAimTarget = nil end)
Toggle(AimPage, "360° Field Lock", "Lock targets in any direction", function() return State.Aim360 end, function(v) State.Aim360 = v end)
ValueControl(AimPage, "Speed Lock Multiplier", function() return State.AimSmoothness end, function(v) State.AimSmoothness = v end, 0.05, 1, 0.05)
ValueControl(AimPage, "FOV Radius", function() return State.AimFOV end, function(v) State.AimFOV = v end, 30, 500, 10)
ValueControl(AimPage, "Max Aim Range (Studs)", function() return State.AimRange end, function(v) State.AimRange = v end, 50, 2000, 50)

Toggle(ESPPage, "Master ESP", "Player overlays toggle", function() return State.ESPEnabled end, function(v) State.ESPEnabled = v end)
Toggle(ESPPage, "ESP Ignore Teammates", "Completely hide ESP for teammates", function() return State.ESPTeamCheck end, function(v) State.ESPTeamCheck = v end)
Toggle(ESPPage, "ESP Box", "Show highlight outlines", function() return State.ESPBox end, function(v) State.ESPBox = v end)
Toggle(ESPPage, "ESP Name", "Show player username labels", function() return State.ESPName end, function(v) State.ESPName = v end)
Toggle(ESPPage, "ESP Health Bar", "Show health progress bar", function() return State.ESPHealth end, function(v) State.ESPHealth = v end)
Toggle(ESPPage, "ESP Distance", "Show stud distance", function() return State.ESPDistance end, function(v) State.ESPDistance = v end)
Toggle(ESPPage, "ESP Line (Sky Tracers)", "Show snap lines from sky to players", function() return State.ESPLine end, function(v) State.ESPLine = v end)

Dropdown(ESPPage, "ESP Text Position", {"Top", "Center", "Bottom"}, function() return State.ESPTextPosMode end, function(val, idx)
	State.ESPTextPosMode = val
	State.ESPTextPosIndex = idx
end)

ValueControl(ESPPage, "ESP Max Range", function() return State.ESPMaxDistance end, function(v) State.ESPMaxDistance = v end, 100, 5000, 100)

ValueControl(MovePage, "WalkSpeed", function() return State.WalkSpeed end, function(v) State.WalkSpeed = v if Humanoid then Humanoid.WalkSpeed = v end end, 8, 120, 2)
ValueControl(MovePage, "JumpPower", function() return State.JumpPower end, function(v) State.JumpPower = v if Humanoid then Humanoid.JumpPower = v end end, 20, 150, 5)

Toggle(SetPage, "Anti-Capture (Streamer Mode)", "Hides UI/ESP from recordings & streams", function() return State.StreamerMode end, function(v)
	State.StreamerMode = v
	if v then
		MainGui.Parent = ProtectedParent
	else
		MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end)

-- Validation Utilities
local function IsTeammate(plr)
	if plr == LocalPlayer then return true end
	if LocalPlayer.Team ~= nil and plr.Team ~= nil then
		return LocalPlayer.Team == plr.Team
	end
	if LocalPlayer.TeamColor == plr.TeamColor and LocalPlayer.TeamColor ~= nil then
		return true
	end
	return false
end

local function IsAlive(plr)
	if not plr or not plr.Character then return false end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function IsVisible(targetPart)
	if not LocalPlayer.Character then return false end
	Camera = Workspace.CurrentCamera
	if not Camera then return false end

	local origin = Camera.CFrame.Position
	local targetChar = targetPart.Parent
	if not targetChar then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
	rayParams.IgnoreWater = true

	local direction = targetPart.Position - origin
	local result = Workspace:Raycast(origin, direction, rayParams)

	if not result then return true end
	if result.Instance and result.Instance:IsDescendantOf(targetChar) then return true end
	return false
end

-- Core Target Lock Algorithm
local function GetAimTarget()
	Camera = Workspace.CurrentCamera
	if not Camera or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	local myPos = LocalPlayer.Character.HumanoidRootPart.Position
	local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)

	if CurrentAimTarget and CurrentAimTarget.Parent then
		local targetChar = CurrentAimTarget.Parent
		local plr = Players:GetPlayerFromCharacter(targetChar)

		if plr and IsAlive(plr) and not (State.AimTeamCheck and IsTeammate(plr)) then
			local worldDist = (CurrentAimTarget.Position - myPos).Magnitude
			if worldDist <= State.AimRange then
				local losPassed = true
				if State.AimLOS then losPassed = IsVisible(CurrentAimTarget) end

				if losPassed then
					local screenPos, onScreen = Camera:WorldToViewportPoint(CurrentAimTarget.Position)
					local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if State.Aim360 or (onScreen and screenPos.Z > 0 and screenDist <= State.AimFOV) then
						return CurrentAimTarget
					end
				end
			end
		end
	end

	local bestTargetPart = nil
	local shortestStudDistance = math.huge
	local bestScreenDistance = math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and IsAlive(plr) then
			if not (State.AimTeamCheck and IsTeammate(plr)) then
				local char = plr.Character
				local part = char:FindFirstChild(State.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

				if part then
					local worldDist = (part.Position - myPos).Magnitude
					if worldDist <= State.AimRange then
						local losPassed = true
						if State.AimLOS then losPassed = IsVisible(part) end

						if losPassed then
							local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
							local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

							if State.Aim360 or (onScreen and screenPos.Z > 0 and screenDist <= State.AimFOV) then
								if State.AimPriorityDistance then
									if worldDist < shortestStudDistance then
										shortestStudDistance = worldDist
										bestTargetPart = part
									end
								else
									if screenDist < bestScreenDistance then
										bestScreenDistance = screenDist
										bestTargetPart = part
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return bestTargetPart
end

local function UpdateAim(dt)
	Camera = Workspace.CurrentCamera
	if not Camera or not State.AimEnabled then
		CurrentAimTarget = nil
		return
	end

	CurrentAimTarget = GetAimTarget()
	if not CurrentAimTarget then return end

	local targetCF = CFrame.lookAt(Camera.CFrame.Position, CurrentAimTarget.Position)
	local lerpSpeed = math.clamp(State.AimSmoothness * (dt or 0.016) * 60, 0.05, 1)
	Camera.CFrame = Camera.CFrame:Lerp(targetCF, lerpSpeed)
end

-- Render Engine: Native High-Performance Overlay Container
local ESPFolder = New("Folder", { Name = "SPECTER_X_ESP_CONTAINER" }, ProtectedParent)

-- ScreenGui for 2D Tracers/Lines
local TracerGui = New("ScreenGui", {
	Name = "SPECTER_X_TRACERS",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999998,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, ProtectedParent)

local function GetOrCreateESP(plr)
	local tag = ESPFolder:FindFirstChild(plr.Name .. "_BILLBOARD")
	local hl = ESPFolder:FindFirstChild(plr.Name .. "_HIGHLIGHT")
	local line = TracerGui:FindFirstChild(plr.Name .. "_LINE")

	if not tag then
		tag = Instance.new("BillboardGui")
		tag.Name = plr.Name .. "_BILLBOARD"
		tag.AlwaysOnTop = true
		tag.Size = UDim2.fromOffset(250, 50)
		tag.StudsOffset = Vector3.new(0, 2.5, 0)
		tag.Enabled = false
		tag.Parent = ESPFolder

		New("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(240, 220, 255),
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		}, tag)
	end

	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = plr.Name .. "_HIGHLIGHT"
		hl.FillTransparency = 0.7
		hl.OutlineTransparency = 0.1
		hl.OutlineColor = Color3.fromRGB(180, 90, 255)
		hl.FillColor = Color3.fromRGB(120, 40, 200)
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Enabled = false
		hl.Parent = ESPFolder
	end

	if not line then
		line = New("Frame", {
			Name = plr.Name .. "_LINE",
			BackgroundColor3 = Color3.fromRGB(180, 90, 255),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Visible = false,
			ZIndex = 1
		}, TracerGui)
	end

	return tag, hl, line
end

local function UpdateESP()
	if not State.ESPEnabled then
		for _, child in ipairs(ESPFolder:GetChildren()) do
			if child:IsA("BillboardGui") or child:IsA("Highlight") then child.Enabled = false end
		end
		for _, child in ipairs(TracerGui:GetChildren()) do
			if child:IsA("Frame") then child.Visible = false end
		end
		return
	end

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local tag, hl, line = GetOrCreateESP(plr)

			if IsAlive(plr) and not (State.ESPTeamCheck and IsTeammate(plr)) then
				local char = plr.Character
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
				local head = char:FindFirstChild("Head") or root
				local hum = char:FindFirstChildOfClass("Humanoid")

				if root and head and hum then
					local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0

					if dist <= State.ESPMaxDistance then
						hl.Adornee = char
						hl.Enabled = State.ESPBox

						tag.Adornee = root
						if State.ESPTextPosMode == "Top" then
							tag.StudsOffset = Vector3.new(0, 3.2, 0)
						elseif State.ESPTextPosMode == "Center" then
							tag.StudsOffset = Vector3.new(0, 0, 0)
						elseif State.ESPTextPosMode == "Bottom" then
							tag.StudsOffset = Vector3.new(0, -2.8, 0)
						end

						local label = tag:FindFirstChild("Label")
						if label then
							local str = ""
							if State.ESPName then str = plr.Name end
							if State.ESPDistance then str = str .. " [" .. dist .. "m]" end
							if State.ESPHealth then str = str .. " (" .. math.floor(hum.Health) .. "HP)" end
							label.Text = str
						end

						tag.Enabled = (State.ESPName or State.ESPDistance or State.ESPHealth)

						-- v8.7 SKY TRACER MATH (Originates from top-center of screen down to enemy)
						if State.ESPLine then
							Camera = Workspace.CurrentCamera
							local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
							if onScreen and screenPos.Z > 0 then
								local viewportSize = Camera.ViewportSize
								local origin = Vector2.new(viewportSize.X * 0.5, 0) -- Top of the screen (Sky)
								local target = Vector2.new(screenPos.X, screenPos.Y)
								
								local delta = target - origin
								local length = delta.Magnitude
								local angle = math.atan2(delta.Y, delta.X)

								line.Size = UDim2.fromOffset(length, 1.2)
								line.Position = UDim2.fromOffset(origin.X, origin.Y)
								line.Rotation = math.deg(angle)
								line.Visible = true
							else
								line.Visible = false
							end
						else
							line.Visible = false
						end
					else
						tag.Enabled = false
						hl.Enabled = false
						line.Visible = false
					end
				else
					tag.Enabled = false
					hl.Enabled = false
					line.Visible = false
				end
			else
				tag.Enabled = false
				hl.Enabled = false
				line.Visible = false
			end
		end
	end
end

-- Render Execution Hooks
RunService:BindToRenderStep("SPECTER_X_AIM", Enum.RenderPriority.Camera.Value + 1, UpdateAim)

RunService.RenderStepped:Connect(function()
	UpdateESP()
end)

-- Interface Touch & Drag Mechanics
local draggingMenu = false
local dragStart, startPos

Header.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMenu = true
		dragStart = inp.Position
		startPos = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(inp)
	if draggingMenu and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.MouseMovement) then
		local delta = inp.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMenu = false
	end
end)

CloseButton.MouseButton1Click:Connect(function() Main.Visible = false end)
Logo.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

SetActiveTab("HOME")
