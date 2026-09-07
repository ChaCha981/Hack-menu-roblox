--============================================================
-- XEIREN 5V5
-- PERFORMANCE HUB
-- Roblox Studio LocalScript
--
-- PASSWORD: anakin
--
-- MAIN FOCUS:
--   MAX FPS
--   Remove unnecessary visual effects
--   Dynamic performance optimization
--   Lightweight ESP
--   Lightweight aim system
--
-- CONTROLS:
--   R = Fly
--   V = Speed
--   XE = Open / Close
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = Workspace.CurrentCamera

--============================================================
-- SETTINGS
--============================================================

local Settings = {

	-- AIM
	AimEnabled = false,
	Full360 = true,
	LockStrength = 85,
	AimSpeed = 30,
	AimDistance = 600,
	AimFOV = 180,
	AimPart = "Head",

	-- ESP
	ESPEnabled = false,
	ESPAlwaysOnTop = true,
	ESPDistance = 500,
	ESPName = true,
	ESPHealth = true,
	ESPDistanceText = true,
	ESPBox = true,
	ESPHead = false,
	ESPTeamColor = false,

	-- TRACER
	TracerEnabled = false,

	-- CHECKS
	TeamCheck = true,
	WallCheck = false,

	-- MOVEMENT
	FlyEnabled = false,
	FlySpeed = 70,
	FlyVerticalSpeed = 60,

	SpeedEnabled = false,
	SpeedRun = 32,

	-- FPS
	FPSBoost = true,
	DynamicFPS = true,

	-- 0 = MAX
	OptimizationLevel = 0,

	ESPUpdateRate = 8,

	ShowFPS = true,
}

--============================================================
-- DEVICE
--============================================================

local DeviceType = "PC"

if UserInputService.TouchEnabled then

	if UserInputService.KeyboardEnabled then
		DeviceType = "Mobile + Keyboard"
	else
		DeviceType = "Mobile"
	end

end

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local Root
local OriginalWalkSpeed = 16

local function SetupCharacter(character)

	Character = character

	Humanoid =
		character:WaitForChild(
			"Humanoid",
			5
		)

	Root =
		character:WaitForChild(
			"HumanoidRootPart",
			5
		)

	if Humanoid then
		OriginalWalkSpeed =
			Humanoid.WalkSpeed
	end

	Settings.FlyEnabled = false
end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(
	function(character)

		SetupCharacter(character)

		task.wait(0.4)

		if Settings.SpeedEnabled then
			Humanoid.WalkSpeed =
				Settings.SpeedRun
		end

	end
)

--============================================================
-- PLAYER FUNCTIONS
--============================================================

local function GetCharacter(player)
	return player.Character
end

local function GetHumanoid(player)

	local character =
		GetCharacter(player)

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass(
		"Humanoid"
	)
end

local function GetRoot(player)

	local character =
		GetCharacter(player)

	if not character then
		return nil
	end

	return character:FindFirstChild(
		"HumanoidRootPart"
	)
end

local function IsAlive(player)

	local humanoid =
		GetHumanoid(player)

	local root =
		GetRoot(player)

	return humanoid
		and humanoid.Health > 0
		and root ~= nil
end

local function IsEnemy(player)

	if player == LocalPlayer then
		return false
	end

	if not IsAlive(player) then
		return false
	end

	if Settings.TeamCheck then

		if LocalPlayer.Team
			and player.Team
			and LocalPlayer.Team == player.Team then

			return false
		end

	end

	return true
end

local function GetDistance(player)

	if not Root then
		return math.huge
	end

	local targetRoot =
		GetRoot(player)

	if not targetRoot then
		return math.huge
	end

	return (
		Root.Position -
		targetRoot.Position
	).Magnitude
end

--============================================================
-- AIM
--============================================================

local function GetAimPart(player)

	local character =
		GetCharacter(player)

	if not character then
		return nil
	end

	if Settings.AimPart == "Head" then

		return character:FindFirstChild("Head")
			or character:FindFirstChild(
				"HumanoidRootPart"
			)

	end

	return character:FindFirstChild(
		"UpperTorso"
	)
		or character:FindFirstChild(
			"Torso"
		)
		or character:FindFirstChild(
			"HumanoidRootPart"
		)
end

local function HasLineOfSight(targetPart)

	if not Settings.WallCheck then
		return true
	end

	if not Camera
		or not Character
		or not targetPart then

		return false
	end

	local origin =
		Camera.CFrame.Position

	local direction =
		targetPart.Position -
		origin

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		Character
	}

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
		targetPart.Parent
	)
end

local CurrentTarget

local function FindTarget()

	if not Camera then
		return nil
	end

	local bestPlayer
	local bestScore =
		math.huge

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if IsEnemy(player) then

			local targetPart =
				GetAimPart(player)

			if targetPart then

				local distance =
					GetDistance(player)

				if distance <=
					Settings.AimDistance then

					if HasLineOfSight(
						targetPart
					) then

						if Settings.Full360 then

							if distance <
								bestScore then

								bestScore =
									distance

								bestPlayer =
									player
							end

						else

							local screen,
								visible =
								Camera:WorldToViewportPoint(
									targetPart.Position
								)

							if visible
								and screen.Z > 0 then

								local center =
									Vector2.new(
										Camera.ViewportSize.X / 2,
										Camera.ViewportSize.Y / 2
									)

								local position =
									Vector2.new(
										screen.X,
										screen.Y
									)

								local screenDistance =
									(
										position -
										center
									).Magnitude

								if screenDistance <=
									Settings.AimFOV then

									if screenDistance <
										bestScore then

										bestScore =
											screenDistance

										bestPlayer =
											player
									end

								end
							end
						end
					end
				end
			end
		end
	end

	return bestPlayer
end

local function UpdateAim(dt)

	if not Settings.AimEnabled then

		CurrentTarget = nil
		return
	end

	if not Humanoid
		or Humanoid.Health <= 0 then

		CurrentTarget = nil
		return
	end

	if not CurrentTarget
		or not IsEnemy(CurrentTarget) then

		CurrentTarget =
			FindTarget()
	end

	if not CurrentTarget then
		return
	end

	local targetPart =
		GetAimPart(CurrentTarget)

	if not targetPart then

		CurrentTarget = nil
		return
	end

	if GetDistance(CurrentTarget) >
		Settings.AimDistance then

		CurrentTarget = nil
		return
	end

	if not HasLineOfSight(
		targetPart
	) then

		CurrentTarget = nil
		return
	end

	local strength =
		math.clamp(
			Settings.LockStrength,
			1,
			100
		) / 100

	local speed =
		math.max(
			Settings.AimSpeed,
			0.1
		) * strength

	local alpha =
		1 -
		math.exp(
			-speed * dt
		)

	alpha =
		math.clamp(
			alpha,
			0.003,
			0.9
		)

	local desired =
		CFrame.lookAt(
			Camera.CFrame.Position,
			targetPart.Position
		)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			desired,
			alpha
		)
end

--============================================================
-- ESP
--============================================================

local ESPFolder =
	Workspace:FindFirstChild(
		"XEIREN_ClientESP"
	)

if not ESPFolder then

	ESPFolder =
		Instance.new("Folder")

	ESPFolder.Name =
		"XEIREN_ClientESP"

	ESPFolder.Parent =
		Workspace
end

local ESPObjects = {}

local function GetESPColor(player)

	if Settings.ESPTeamColor
		and player.Team then

		return player.Team.TeamColor.Color
	end

	return Color3.fromRGB(
		255,
		255,
		255
	)
end

local function CreateESP(player)

	if player == LocalPlayer then
		return
	end

	if ESPObjects[player] then
		return
	end

	local data = {}

	-- HIGHLIGHT
	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"XE_Highlight"

	highlight.FillTransparency =
		0.82

	highlight.OutlineTransparency =
		0.1

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		ESPFolder

	data.Highlight =
		highlight

	-- BILLBOARD
	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"XE_Info"

	billboard.Size =
		UDim2.fromOffset(
			150,
			62
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.Parent =
		PlayerGui

	data.Billboard =
		billboard

	local frame =
		Instance.new("Frame")

	frame.Size =
		UDim2.fromScale(
			1,
			1
		)

	frame.BackgroundTransparency =
		1

	frame.Parent =
		billboard

	data.Frame =
		frame

	-- NAME
	local name =
		Instance.new("TextLabel")

	name.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	name.BackgroundTransparency =
		1

	name.Font =
		Enum.Font.GothamBold

	name.TextSize =
		12

	name.TextStrokeTransparency =
		0.4

	name.Parent =
		frame

	data.Name =
		name

	-- DISTANCE
	local distance =
		Instance.new("TextLabel")

	distance.Size =
		UDim2.new(
			1,
			0,
			0,
			17
		)

	distance.Position =
		UDim2.fromOffset(
			0,
			18
		)

	distance.BackgroundTransparency =
		1

	distance.Font =
		Enum.Font.Gotham

	distance.TextSize =
		11

	distance.TextStrokeTransparency =
		0.4

	distance.Parent =
		frame

	data.Distance =
		distance

	-- HP
	local hp =
		Instance.new("TextLabel")

	hp.Size =
		UDim2.new(
			1,
			0,
			0,
			17
		)

	hp.Position =
		UDim2.fromOffset(
			0,
			35
		)

	hp.BackgroundTransparency =
		1

	hp.Font =
		Enum.Font.GothamBold

	hp.TextSize =
		11

	hp.TextStrokeTransparency =
		0.4

	hp.Parent =
		frame

	data.HP =
		hp

	ESPObjects[player] =
		data
end

local function RemoveESP(player)

	local data =
		ESPObjects[player]

	if not data then
		return
	end

	for _, object in pairs(
		data
	) do

		if typeof(object) ==
			"Instance" then

			object:Destroy()
		end
	end

	ESPObjects[player] =
		nil
end

local function UpdateESP()

	if not Settings.ESPEnabled then

		for _, data in pairs(
			ESPObjects
		) do

			if data.Highlight then
				data.Highlight.Enabled =
					false
			end

			if data.Billboard then
				data.Billboard.Enabled =
					false
			end
		end

		return
	end

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player ~= LocalPlayer then

			if not ESPObjects[player] then
				CreateESP(player)
			end

			local data =
				ESPObjects[player]

			local character =
				GetCharacter(player)

			local humanoid =
				GetHumanoid(player)

			local root =
				GetRoot(player)

			if IsEnemy(player)
				and character
				and humanoid
				and root then

				local distance =
					GetDistance(player)

				if distance <=
					Settings.ESPDistance then

					local color =
						GetESPColor(player)

					if data.Highlight then

						data.Highlight.Enabled =
							Settings.ESPBox

						data.Highlight.Adornee =
							character

						data.Highlight.FillColor =
							color

						data.Highlight.OutlineColor =
							color

						data.Highlight.DepthMode =
							Settings.ESPAlwaysOnTop
							and Enum.HighlightDepthMode.AlwaysOnTop
							or Enum.HighlightDepthMode.Occluded
					end

					if data.Billboard then

						data.Billboard.Enabled =
							true

						data.Billboard.Adornee =
							root

						data.Billboard.MaxDistance =
							Settings.ESPDistance

						data.Name.Visible =
							Settings.ESPName

						data.Distance.Visible =
							Settings.ESPDistanceText

						data.HP.Visible =
							Settings.ESPHealth

						data.Name.Text =
							player.DisplayName

						data.Name.TextColor3 =
							color

						data.Distance.Text =
							math.floor(distance)
							.. " studs"

						data.Distance.TextColor3 =
							color

						data.HP.Text =
							math.floor(
								humanoid.Health
							)
							..
							" / "
							..
							math.floor(
								humanoid.MaxHealth
							)

						data.HP.TextColor3 =
							color
					end

				else

					if data.Highlight then
						data.Highlight.Enabled =
							false
					end

					if data.Billboard then
						data.Billboard.Enabled =
							false
					end
				end

			else

				if data.Highlight then
					data.Highlight.Enabled =
						false
				end

				if data.Billboard then
					data.Billboard.Enabled =
						false
				end
			end
		end
	end
end

--============================================================
-- FLY
--============================================================

local FlyAttachment
local FlyVelocity

local function StopFly()

	Settings.FlyEnabled =
		false

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

	if not Root then
		return
	end

	StopFly()

	Settings.FlyEnabled =
		true

	FlyAttachment =
		Instance.new("Attachment")

	FlyAttachment.Name =
		"XE_FlyAttachment"

	FlyAttachment.Parent =
		Root

	FlyVelocity =
		Instance.new("LinearVelocity")

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

local function ToggleFly()

	if Settings.FlyEnabled then
		StopFly()
	else
		StartFly()
	end
end

local function UpdateFly()

	if not Settings.FlyEnabled then
		return
	end

	if not Root
		or not FlyVelocity then
		return
	end

	local direction =
		Vector3.zero

	if UserInputService:IsKeyDown(
		Enum.KeyCode.W
	) then

		direction +=
			Camera.CFrame.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.S
	) then

		direction -=
			Camera.CFrame.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.A
	) then

		direction -=
			Camera.CFrame.RightVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.D
	) then

		direction +=
			Camera.CFrame.RightVector
	end

	direction =
		Vector3.new(
			direction.X,
			0,
			direction.Z
		)

	if direction.Magnitude > 1 then
		direction =
			direction.Unit
	end

	local vertical = 0

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

	FlyVelocity.VectorVelocity =
		direction *
		Settings.FlySpeed
		+
		Vector3.new(
			0,
			vertical,
			0
		)
end

--============================================================
-- SPEED
--============================================================

local function UpdateSpeed()

	if not Humanoid then
		return
	end

	if Settings.SpeedEnabled then

		Humanoid.WalkSpeed =
			Settings.SpeedRun

	else

		Humanoid.WalkSpeed =
			OriginalWalkSpeed
	end
end

local function ToggleSpeed()

	Settings.SpeedEnabled =
		not Settings.SpeedEnabled

	UpdateSpeed()
end

--============================================================
-- FPS OPTIMIZER
--============================================================

local OriginalVisuals = {}

local function SaveVisual(object)

	if OriginalVisuals[object] then
		return
	end

	if object:IsA("ParticleEmitter")
		or object:IsA("Trail")
		or object:IsA("Smoke")
		or object:IsA("Fire")
		or object:IsA("Sparkles")
		or object:IsA("Beam") then

		OriginalVisuals[object] =
			{
				Enabled = object.Enabled
			}
	end

	if object:IsA("PostEffect") then

		OriginalVisuals[object] =
			{
				Enabled = object.Enabled
			}
	end
end

local function SaveAllVisuals()

	OriginalVisuals = {}

	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		SaveVisual(object)
	end

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do

		SaveVisual(object)
	end
end

local function DisableExpensiveVisuals()

	-- POST EFFECTS
	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		if object:IsA("PostEffect") then
			object.Enabled = false
		end
	end

	-- SHADOWS
	Lighting.GlobalShadows =
		false

	-- MAP EFFECTS
	for _, object in ipairs(
		Workspace:GetDescendants()
	) do

		if object:IsA("ParticleEmitter")
			or object:IsA("Trail")
			or object:IsA("Smoke")
			or object:IsA("Fire")
			or object:IsA("Sparkles") then

			object.Enabled =
				false

		elseif object:IsA("Beam") then

			if not object.Name:find(
				"XE"
			) then

				object.Enabled =
					false
			end
		end
	end

	-- TERRAIN
	local terrain =
		Workspace:FindFirstChildOfClass(
			"Terrain"
		)

	if terrain then

		pcall(function()

			terrain.Decoration =
				false

		end)
	end
end

local function RestoreVisuals()

	for object, data in pairs(
		OriginalVisuals
	) do

		if object
			and object.Parent then

			pcall(function()

				object.Enabled =
					data.Enabled

			end)
		end
	end

	OriginalVisuals = {}
end

local function SetFPSBoost(enabled)

	Settings.FPSBoost =
		enabled

	if enabled then

		SaveAllVisuals()

		DisableExpensiveVisuals()

	else

		RestoreVisuals()

		Lighting.GlobalShadows =
			true
	end
end

--============================================================
-- AUTO DISABLE NEW EFFECTS
--============================================================

Workspace.DescendantAdded:Connect(
	function(object)

		if not Settings.FPSBoost then
			return
		end

		task.defer(function()

			if not object.Parent then
				return
			end

			if object:IsA("ParticleEmitter")
				or object:IsA("Trail")
				or object:IsA("Smoke")
				or object:IsA("Fire")
				or object:IsA("Sparkles") then

				object.Enabled =
					false

			elseif object:IsA("Beam") then

				if not object.Name:find(
					"XE"
				) then

					object.Enabled =
						false
				end
			end
		end)
	end
)

--============================================================
-- FPS MONITOR
--============================================================

local FPS = 60
local FPSTimer = 0
local FPSFrames = 0
local DynamicTimer = 0

local function UpdateFPS(dt)

	FPSTimer += dt
	FPSFrames += 1

	if FPSTimer >= 0.5 then

		FPS =
			math.floor(
				FPSFrames /
				FPSTimer
				+ 0.5
			)

		FPSTimer = 0
		FPSFrames = 0
	end
end

--============================================================
-- DYNAMIC FPS
--============================================================

local function DynamicOptimize(dt)

	if not Settings.FPSBoost
		or not Settings.DynamicFPS then

		return
	end

	DynamicTimer += dt

	if DynamicTimer < 3 then
		return
	end

	DynamicTimer = 0

	-- VERY LOW
	if FPS < 25 then

		Settings.ESPUpdateRate =
			5

		Settings.TracerEnabled =
			false

		DisableExpensiveVisuals()

	-- LOW
	elseif FPS < 40 then

		Settings.ESPUpdateRate =
			6

		DisableExpensiveVisuals()

	-- MEDIUM
	elseif FPS < 55 then

		Settings.ESPUpdateRate =
			8

	-- GOOD
	elseif FPS >= 60 then

		Settings.ESPUpdateRate =
			12
	end
end

--============================================================
-- GUI ROOT
--============================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"XEIREN_PerformanceHub"

ScreenGui.ResetOnSpawn =
	false

ScreenGui.IgnoreGuiInset =
	true

ScreenGui.DisplayOrder =
	999

ScreenGui.Parent =
	PlayerGui

--============================================================
-- PASSWORD
--============================================================

local PasswordFrame =
	Instance.new("Frame")

PasswordFrame.Size =
	UDim2.fromOffset(
		300,
		185
	)

PasswordFrame.Position =
	UDim2.new(
		0.5,
		-150,
		0.5,
		-92
	)

PasswordFrame.BackgroundColor3 =
	Color3.fromRGB(
		13,
		14,
		18
	)

PasswordFrame.BorderSizePixel =
	0

PasswordFrame.Parent =
	ScreenGui

local PCorner =
	Instance.new("UICorner")

PCorner.CornerRadius =
	UDim.new(
		0,
		16
	)

PCorner.Parent =
	PasswordFrame

local PStroke =
	Instance.new("UIStroke")

PStroke.Thickness =
	1

PStroke.Transparency =
	0.55

PStroke.Parent =
	PasswordFrame

local PTitle =
	Instance.new("TextLabel")

PTitle.Size =
	UDim2.new(
		1,
		-30,
		0,
		35
	)

PTitle.Position =
	UDim2.fromOffset(
		15,
		12
	)

PTitle.BackgroundTransparency =
	1

PTitle.Text =
	"XEIREN"

PTitle.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PTitle.Font =
	Enum.Font.GothamBlack

PTitle.TextSize =
	24

PTitle.Parent =
	PasswordFrame

local PSub =
	Instance.new("TextLabel")

PSub.Size =
	UDim2.new(
		1,
		-30,
		0,
		20
	)

PSub.Position =
	UDim2.fromOffset(
		15,
		45
	)

PSub.BackgroundTransparency =
	1

PSub.Text =
	"5V5 PERFORMANCE HUB"

PSub.TextColor3 =
	Color3.fromRGB(
		140,
		145,
		155
	)

PSub.Font =
	Enum.Font.Gotham

PSub.TextSize =
	10

PSub.Parent =
	PasswordFrame

local PasswordBox =
	Instance.new("TextBox")

PasswordBox.Size =
	UDim2.new(
		1,
		-30,
		0,
		38
	)

PasswordBox.Position =
	UDim2.fromOffset(
		15,
		72
	)

PasswordBox.BackgroundColor3 =
	Color3.fromRGB(
		24,
		25,
		31
	)

PasswordBox.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PasswordBox.PlaceholderText =
	"Enter password"

PasswordBox.Text =
	""

PasswordBox.ClearTextOnFocus =
	false

PasswordBox.Font =
	Enum.Font.Gotham

PasswordBox.TextSize =
	13

PasswordBox.Parent =
	PasswordFrame

local PBoxCorner =
	Instance.new("UICorner")

PBoxCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

PBoxCorner.Parent =
	PasswordBox

local Unlock =
	Instance.new("TextButton")

Unlock.Size =
	UDim2.new(
		1,
		-30,
		0,
		38
	)

Unlock.Position =
	UDim2.fromOffset(
		15,
		116
	)

Unlock.BackgroundColor3 =
	Color3.fromRGB(
		45,
		47,
		56
	)

Unlock.Text =
	"UNLOCK"

Unlock.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Unlock.Font =
	Enum.Font.GothamBold

Unlock.TextSize =
	12

Unlock.Parent =
	PasswordFrame

local UCorner =
	Instance.new("UICorner")

UCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

UCorner.Parent =
	Unlock

local PasswordStatus =
	Instance.new("TextLabel")

PasswordStatus.Size =
	UDim2.new(
		1,
		-30,
		0,
		20
	)

PasswordStatus.Position =
	UDim2.fromOffset(
		15,
		157
	)

PasswordStatus.BackgroundTransparency =
	1

PasswordStatus.Text =
	""

PasswordStatus.TextColor3 =
	Color3.fromRGB(
		255,
		90,
		90
	)

PasswordStatus.Font =
	Enum.Font.Gotham

PasswordStatus.TextSize =
	10

PasswordStatus.Parent =
	PasswordFrame

--============================================================
-- MAIN WINDOW
--============================================================

local Main =
	Instance.new("Frame")

Main.Size =
	UDim2.fromOffset(
		310,
		390
	)

Main.Position =
	UDim2.new(
		0.5,
		-155,
		0.5,
		-195
	)

Main.BackgroundColor3 =
	Color3.fromRGB(
		12,
		13,
		17
	)

Main.BorderSizePixel =
	0

Main.Visible =
	false

Main.Parent =
	ScreenGui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(
		0,
		17
	)

MainCorner.Parent =
	Main

local MainStroke =
	Instance.new("UIStroke")

MainStroke.Thickness =
	1

MainStroke.Transparency =
	0.5

MainStroke.Parent =
	Main

--============================================================
-- HEADER
--============================================================

local Header =
	Instance.new("Frame")

Header.Size =
	UDim2.new(
		1,
		0,
		0,
		55
	)

Header.BackgroundColor3 =
	Color3.fromRGB(
		19,
		20,
		25
	)

Header.BorderSizePixel =
	0

Header.Parent =
	Main

local HeaderCorner =
	Instance.new("UICorner")

HeaderCorner.CornerRadius =
	UDim.new(
		0,
		17
	)

HeaderCorner.Parent =
	Header

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.new(
		1,
		-90,
		0,
		28
	)

Title.Position =
	UDim2.fromOffset(
		15,
		7
	)

Title.BackgroundTransparency =
	1

Title.Text =
	"XEIREN"

Title.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Title.Font =
	Enum.Font.GothamBlack

Title.TextSize =
	18

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent =
	Header

local SubTitle =
	Instance.new("TextLabel")

SubTitle.Size =
	UDim2.new(
		1,
		-90,
		0,
		17
	)

SubTitle.Position =
	UDim2.fromOffset(
		15,
		31
	)

SubTitle.BackgroundTransparency =
	1

SubTitle.Text =
	"5V5 • PERFORMANCE"

SubTitle.TextColor3 =
	Color3.fromRGB(
		125,
		130,
		140
	)

SubTitle.Font =
	Enum.Font.Gotham

SubTitle.TextSize =
	9

SubTitle.TextXAlignment =
	Enum.TextXAlignment.Left

SubTitle.Parent =
	Header

local Close =
	Instance.new("TextButton")

Close.Size =
	UDim2.fromOffset(
		32,
		32
	)

Close.Position =
	UDim2.new(
		1,
		-43,
		0,
		11
	)

Close.BackgroundColor3 =
	Color3.fromRGB(
		30,
		31,
		38
	)

Close.Text =
	"×"

Close.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Close.Font =
	Enum.Font.GothamBold

Close.TextSize =
	20

Close.Parent =
	Header

local CloseCorner =
	Instance.new("UICorner")

CloseCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

CloseCorner.Parent =
	Close

Close.Activated:Connect(
	function()
		Main.Visible = false
	end
)

--============================================================
-- DRAG MAIN
--============================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = true
			dragStart =
				input.Position

			startPosition =
				Main.Position
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

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position -
				dragStart

			Main.Position =
				UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset
						+ delta.X,

					startPosition.Y.Scale,
					startPosition.Y.Offset
						+ delta.Y
				)
		end
	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = false
		end
	end
)

--============================================================
-- CONTENT
--============================================================

local Scroll =
	Instance.new("ScrollingFrame")

Scroll.Size =
	UDim2.new(
		1,
		-10,
		1,
		-65
	)

Scroll.Position =
	UDim2.fromOffset(
		5,
		60
	)

Scroll.BackgroundTransparency =
	1

Scroll.BorderSizePixel =
	0

Scroll.ScrollBarThickness =
	2

Scroll.CanvasSize =
	UDim2.fromOffset(
		0,
		1450
	)

Scroll.Parent =
	Main

local Layout =
	Instance.new("UIListLayout")

Layout.Padding =
	UDim.new(
		0,
		5
	)

Layout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

Layout.Parent =
	Scroll

--============================================================
-- UI HELPERS
--============================================================

local function Section(text)

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-10,
			0,
			20
		)

	label.BackgroundTransparency =
		1

	label.Text =
		text

	label.TextColor3 =
		Color3.fromRGB(
			120,
			125,
			138
		)

	label.Font =
		Enum.Font.GothamBold

	label.TextSize =
		10

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent =
		Scroll

	return label
end

local function Button(
	text,
	callback
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-10,
			0,
			31
		)

	button.BackgroundColor3 =
		Color3.fromRGB(
			23,
			24,
			30
		)

	button.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	button.Text =
		text

	button.Font =
		Enum.Font.Gotham

	button.TextSize =
		11

	button.AutoButtonColor =
		false

	button.Parent =
		Scroll

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			9
		)

	corner.Parent =
		button

	button.MouseEnter:Connect(
		function()

			TweenService:Create(
				button,
				TweenInfo.new(
					0.12
				),
				{
					BackgroundColor3 =
						Color3.fromRGB(
							34,
							35,
							43
						)
				}
			):Play()

		end
	)

	button.MouseLeave:Connect(
		function()

			TweenService:Create(
				button,
				TweenInfo.new(
					0.12
				),
				{
					BackgroundColor3 =
						Color3.fromRGB(
							23,
							24,
							30
						)
				}
			):Play()

		end
	)

	button.Activated:Connect(
		callback
	)

	return button
end

local function Toggle(
	text,
	key
)

	local button

	local function Refresh()

		button.Text =
			text
			.. "   "
			.. (
				Settings[key]
				and "ON"
				or "OFF"
			)

	end

	button =
		Button(
			"",
			function()

				Settings[key] =
					not Settings[key]

				Refresh()

				if key ==
					"FlyEnabled" then

					if Settings.FlyEnabled then
						StartFly()
					else
						StopFly()
					end
				end

				if key ==
					"SpeedEnabled" then

					UpdateSpeed()
				end

				if key ==
					"FPSBoost" then

					SetFPSBoost(
						Settings.FPSBoost
					)
				end
			end
		)

	Refresh()

	return button
end

local function Slider(
	text,
	key,
	minimum,
	maximum,
	step
)

	local holder =
		Instance.new("Frame")

	holder.Size =
		UDim2.new(
			1,
			-10,
			0,
			44
		)

	holder.BackgroundColor3 =
		Color3.fromRGB(
			18,
			19,
			24
		)

	holder.BorderSizePixel =
		0

	holder.Parent =
		Scroll

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			9
		)

	corner.Parent =
		holder

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-15,
			0,
			18
		)

	label.Position =
		UDim2.fromOffset(
			8,
			1
		)

	label.BackgroundTransparency =
		1

	label.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	label.Font =
		Enum.Font.Gotham

	label.TextSize =
		10

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent =
		holder

	local bar =
		Instance.new("TextButton")

	bar.Size =
		UDim2.new(
			1,
			-20,
			0,
			13
		)

	bar.Position =
		UDim2.fromOffset(
			10,
			26
		)

	bar.BackgroundColor3 =
		Color3.fromRGB(
			38,
			39,
			47
		)

	bar.Text =
		""

	bar.AutoButtonColor =
		false

	bar.Parent =
		holder

	local barCorner =
		Instance.new("UICorner")

	barCorner.CornerRadius =
		UDim.new(
			1,
			0
		)

	barCorner.Parent =
		bar

	local function Refresh()

		label.Text =
			text
			.. " : "
			.. tostring(
				math.floor(
					Settings[key]
					+ 0.5
				)
			)
	end

	local sliding = false

	local function UpdateValue(x)

		local percent =
			math.clamp(
				(
					x -
					bar.AbsolutePosition.X
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
				maximum -
				minimum
			)
			*
			percent

		value =
			math.floor(
				value / step
				+ 0.5
			)
			*
			step

		Settings[key] =
			value

		Refresh()
	end

	bar.InputBegan:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1

				or input.UserInputType ==
				Enum.UserInputType.Touch then

				sliding = true

				UpdateValue(
					input.Position.X
				)
			end
		end
	)

	UserInputService.InputChanged:Connect(
		function(input)

			if not sliding then
				return
			end

			if input.UserInputType ==
				Enum.UserInputType.MouseMovement

				or input.UserInputType ==
				Enum.UserInputType.Touch then

				UpdateValue(
					input.Position.X
				)
			end
		end
	)

	UserInputService.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1

				or input.UserInputType ==
				Enum.UserInputType.Touch then

				sliding = false
			end
		end
	)

	Refresh()

	return holder
end

--============================================================
-- PERFORMANCE FIRST SECTION
--============================================================

Section("⚡ MAX PERFORMANCE")

local FPSButton =
	Button(
		"⚡ MAX FPS : ON",
		function()

			Settings.FPSBoost =
				not Settings.FPSBoost

			SetFPSBoost(
				Settings.FPSBoost
			)

			FPSButton.Text =
				Settings.FPSBoost
				and "⚡ MAX FPS : ON"
				or "⚡ MAX FPS : OFF"
		end
	)

Toggle(
		"Dynamic FPS",
		"DynamicFPS"
)

Toggle(
		"FPS Counter",
		"ShowFPS"
)

--============================================================
-- AIM
--============================================================

Section("AIM")

Toggle(
	"Aim Assist",
	"AimEnabled"
)

Toggle(
	"360° Lock",
	"Full360"
)

Slider(
	"Lock Strength",
	"LockStrength",
	1,
	100,
	1
)

Slider(
	"Aim Speed",
	"AimSpeed",
	1,
	100,
	1
)

Slider(
	"Aim Distance",
	"AimDistance",
	50,
	1000,
	10
)

Slider(
	"Aim FOV",
	"AimFOV",
	20,
	600,
	5
)

local TargetButton

TargetButton =
	Button(
		"Target : "
		.. Settings.AimPart,
		function()

			if Settings.AimPart ==
				"Head" then

				Settings.AimPart =
					"Body"

			else

				Settings.AimPart =
					"Head"
			end

			TargetButton.Text =
				"Target : "
				.. Settings.AimPart
		end
	)

--============================================================
-- ESP
--============================================================

Section("ESP")

Toggle(
	"ESP",
	"ESPEnabled"
)

Toggle(
	"Always On Top",
	"ESPAlwaysOnTop"
)

Toggle(
	"ESP Box",
	"ESPBox"
)

Toggle(
	"Name",
	"ESPName"
)

Toggle(
	"Health",
	"ESPHealth"
)

Toggle(
	"Distance",
	"ESPDistanceText"
)

Toggle(
	"Team Color",
	"ESPTeamColor"
)

Slider(
	"ESP Distance",
	"ESPDistance",
	50,
	1000,
	10
)

Slider(
	"ESP Update",
	"ESPUpdateRate",
	3,
	20,
	1
)

--============================================================
-- CHECKS
--============================================================

Section("CHECKS")

Toggle(
	"Team Check",
	"TeamCheck"
)

Toggle(
	"Wall Check",
	"WallCheck"
)

--============================================================
-- MOVEMENT
--============================================================

Section("MOVEMENT")

Toggle(
	"Fly",
	"FlyEnabled"
)

Slider(
	"Fly Speed",
	"FlySpeed",
	10,
	200,
	5
)

Slider(
	"Vertical Speed",
	"FlyVerticalSpeed",
	10,
	200,
	5
)

Toggle(
	"Speed Run",
	"SpeedEnabled"
)

Slider(
	"Run Speed",
	"SpeedRun",
	16,
	100,
	1
)

--============================================================
-- TRACER
--============================================================

Section("TRACER")

Toggle(
	"Tracers",
	"TracerEnabled"
)

--============================================================
-- DEVICE
--============================================================

Section("SYSTEM")

local DeviceInfo =
	Instance.new("TextLabel")

DeviceInfo.Size =
	UDim2.new(
		1,
		-10,
		0,
		38
	)

DeviceInfo.BackgroundTransparency =
	1

DeviceInfo.Text =
	"Device : "
	.. DeviceType
	.. "\nMAX FPS removes unnecessary effects"

DeviceInfo.TextColor3 =
	Color3.fromRGB(
		125,
		130,
		140
	)

DeviceInfo.Font =
	Enum.Font.Gotham

DeviceInfo.TextSize =
	10

DeviceInfo.TextXAlignment =
	Enum.TextXAlignment.Left

DeviceInfo.Parent =
	Scroll

--============================================================
-- XE FLOATING BUTTON
--============================================================

local Logo =
	Instance.new("TextButton")

Logo.Size =
	UDim2.fromOffset(
		48,
		48
	)

Logo.Position =
	UDim2.new(
		0,
		15,
		0.5,
		-24
	)

Logo.BackgroundColor3 =
	Color3.fromRGB(
		15,
		16,
		21
	)

Logo.Text =
	"XE"

Logo.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Logo.Font =
	Enum.Font.GothamBlack

Logo.TextSize =
	16

Logo.AutoButtonColor =
	false

Logo.Parent =
	ScreenGui

local LogoCorner =
	Instance.new("UICorner")

LogoCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

LogoCorner.Parent =
	Logo

local LogoStroke =
	Instance.new("UIStroke")

LogoStroke.Thickness =
	1.5

LogoStroke.Transparency =
	0.35

LogoStroke.Parent =
	Logo

--============================================================
-- LOGO DRAG
--============================================================

local logoDragging = false
local logoMoved = false
local logoStart
local logoPosition

Logo.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			logoDragging = true
			logoMoved = false

			logoStart =
				input.Position

			logoPosition =
				Logo.Position
		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if not logoDragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position -
				logoStart

			if math.abs(delta.X) > 5
				or math.abs(delta.Y) > 5 then

				logoMoved = true
			end

			Logo.Position =
				UDim2.new(
					logoPosition.X.Scale,
					logoPosition.X.Offset
						+ delta.X,

					logoPosition.Y.Scale,
					logoPosition.Y.Offset
						+ delta.Y
				)
		end
	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			logoDragging = false
		end
	end
)

Logo.Activated:Connect(
	function()

		if logoMoved then

			logoMoved = false

			return
		end

		Main.Visible =
			not Main.Visible
	end
)

--============================================================
-- PASSWORD
--============================================================

local function Unlock()

	if PasswordBox.Text ==
		"anakin" then

		PasswordFrame.Visible =
			false

		Main.Visible =
			true

	else

		PasswordStatus.Text =
			"Incorrect password"
	end
end

Unlock.Activated:Connect(
	Unlock
)

PasswordBox.FocusLost:Connect(
	function(enterPressed)

		if enterPressed then
			Unlock()
		end
	end
)

--============================================================
-- KEYBOARD
--============================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if input.KeyCode ==
			Enum.KeyCode.R then

			ToggleFly()
		end

		if input.KeyCode ==
			Enum.KeyCode.V then

			ToggleSpeed()
		end
	end
)

--============================================================
-- CLEANUP
--============================================================

Players.PlayerRemoving:Connect(
	function(player)

		RemoveESP(player)

		if CurrentTarget ==
			player then

			CurrentTarget =
				nil
		end
	end
)

--============================================================
-- INITIAL MAX FPS
--============================================================

SetFPSBoost(true)

--============================================================
-- MAIN LOOP
--============================================================

local ESPTimer = 0

RunService.RenderStepped:Connect(
	function(dt)

		UpdateFPS(dt)

		UpdateAim(dt)

		UpdateFly()

		UpdateSpeed()

		DynamicOptimize(dt)

		-- ESP is deliberately throttled
		-- so it does not consume every frame.

		ESPTimer += dt

		local interval =
			1 /
			math.max(
				Settings.ESPUpdateRate,
				1
			)

		if ESPTimer >= interval then

			ESPTimer = 0

			UpdateESP()
		end

		FPSLabelUpdate = nil

		if Settings.ShowFPS then

			if not _G.XE_FPS_LABEL then

				local fps =
					Instance.new(
						"TextLabel"
					)

				fps.Size =
					UDim2.fromOffset(
						85,
						25
					)

				fps.Position =
					UDim2.new(
						1,
						-95,
						0,
						8
					)

				fps.BackgroundTransparency =
					1

				fps.TextColor3 =
					Color3.new(
						1,
						1,
						1
					)

				fps.Font =
					Enum.Font.GothamBold

				fps.TextSize =
					12

				fps.Parent =
					ScreenGui

				_G.XE_FPS_LABEL =
					fps
			end

			_G.XE_FPS_LABEL.Text =
				"FPS "
				.. tostring(FPS)

			_G.XE_FPS_LABEL.Visible =
				true

		elseif _G.XE_FPS_LABEL then

			_G.XE_FPS_LABEL.Visible =
				false
		end

		DeviceInfo.Text =
			"Device : "
			.. DeviceType
			.. "\nFPS : "
			.. tostring(FPS)
			.. "  •  MAX FPS : "
			.. (
				Settings.FPSBoost
				and "ON"
				or "OFF"
			)
	end
)
