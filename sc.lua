--========================================================
-- XEIREN 5V5 COMBAT HUB
-- Roblox Studio LocalScript
-- Password: anakin
--
-- Compact UI
-- Click XE logo = Open / Close Hub
-- Draggable menu
-- 360° Aim Lock
-- Adjustable Lock Strength
-- Head / Body target
-- Strong ESP
-- ESP Box / Name / Health / Distance / Head Marker
-- Tracers
-- Team Check / Wall Check
-- Fly + Fly Speed + Vertical Speed
-- Speed Run
-- Mobile + PC friendly UI
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- SETTINGS
--========================================================

local Settings = {

	-- AIM
	AimEnabled = false,
	Full360 = true,
	LockStrength = 100,
	AimSpeed = 50,
	AimDistance = 600,
	AimFOV = 180,
	AimPart = "Head",

	-- ESP
	ESPEnabled = false,
	ESPAlwaysOnTop = true,
	ESPDistance = 600,
	ESPHealth = true,
	ESPName = true,
	ESPDistanceText = true,
	ESPBox = true,
	ESPHead = true,
	ESPTeamColor = false,

	-- TRACER
	TracerEnabled = false,

	-- CHECKS
	TeamCheck = true,
	WallCheck = false,

	-- FLY
	FlyEnabled = false,
	FlySpeed = 70,
	FlyVerticalSpeed = 60,

	-- SPEED
	SpeedEnabled = false,
	SpeedRun = 32
}

--========================================================
-- CHARACTER
--========================================================

local Character
local Humanoid
local RootPart

local OriginalWalkSpeed = 16
local OriginalAutoRotate = true

local FlyAttachment
local FlyVelocity

local function SetupCharacter(character)

	Character = character

	Humanoid =
		character:WaitForChild(
			"Humanoid",
			10
		)

	RootPart =
		character:WaitForChild(
			"HumanoidRootPart",
			10
		)

	if Humanoid then

		OriginalWalkSpeed =
			Humanoid.WalkSpeed

		OriginalAutoRotate =
			Humanoid.AutoRotate
	end

	if Settings.FlyEnabled then

		Settings.FlyEnabled = false

		if FlyVelocity then
			FlyVelocity:Destroy()
			FlyVelocity = nil
		end

		if FlyAttachment then
			FlyAttachment:Destroy()
			FlyAttachment = nil
		end
	end
end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)

	task.wait(0.5)

	SetupCharacter(character)

end)

--========================================================
-- UTILITIES
--========================================================

local function GetCharacter(player)

	if not player then
		return nil
	end

	return player.Character
end

local function GetHumanoid(character)

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass(
		"Humanoid"
	)
end

local function GetRoot(character)

	if not character then
		return nil
	end

	return character:FindFirstChild(
		"HumanoidRootPart"
	)
end

local function IsAlive(player)

	local character =
		GetCharacter(player)

	local humanoid =
		GetHumanoid(character)

	local root =
		GetRoot(character)

	return character
		and humanoid
		and root
		and humanoid.Health > 0
end

local function IsEnemy(player)

	if not player then
		return false
	end

	if player == LocalPlayer then
		return false
	end

	if Settings.TeamCheck then

		if player.Team ~= nil
			and LocalPlayer.Team ~= nil
		then

			if player.Team ==
				LocalPlayer.Team
			then
				return false
			end
		end
	end

	return true
end

local function GetDistance(player)

	if not RootPart then
		return math.huge
	end

	if not IsAlive(player) then
		return math.huge
	end

	local root =
		GetRoot(player.Character)

	return (
		root.Position -
		RootPart.Position
	).Magnitude
end

--========================================================
-- WALL CHECK
--========================================================

local function IsVisible(targetPart)

	if not targetPart then
		return false
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
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
		targetPart.Parent
	)
end

--========================================================
-- AIM PART
--========================================================

local function GetAimPart(character)

	if not character then
		return nil
	end

	if Settings.AimPart ==
		"Body"
	then

		return character:FindFirstChild(
			"HumanoidRootPart"
		)
		or character:FindFirstChild(
			"UpperTorso"
		)
		or character:FindFirstChild(
			"Torso"
		)
	end

	return character:FindFirstChild(
		"Head"
	)
	or character:FindFirstChild(
		"HumanoidRootPart"
	)
end

--========================================================
-- FIND TARGET
--========================================================

local function FindTarget()

	if not RootPart then
		return nil
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local bestPlayer = nil
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

		if
			IsEnemy(player)
			and
			IsAlive(player)
		then

			local character =
				player.Character

			local targetPart =
				GetAimPart(character)

			local targetRoot =
				GetRoot(character)

			if targetPart
				and targetRoot
			then

				local distance =
					(
						targetRoot.Position -
						RootPart.Position
					).Magnitude

				if distance <=
					Settings.AimDistance
				then

					local allowed = true

					if Settings.WallCheck then

						allowed =
							IsVisible(
								targetPart
							)
					end

					if allowed then

						--====================================
						-- 360 DEGREE MODE
						--====================================

						if Settings.Full360 then

							local score =
								distance

							if score <
								bestScore
							then

								bestScore =
									score

								bestPlayer =
									player
							end

						--====================================
						-- NORMAL FOV MODE
						--====================================

						else

							local screenPos,
								onScreen =
								Camera:WorldToViewportPoint(
									targetPart.Position
								)

							if onScreen
								and screenPos.Z > 0
							then

								local screenDistance =
									(
										Vector2.new(
											screenPos.X,
											screenPos.Y
										) -
										center
									).Magnitude

								if screenDistance <=
									Settings.AimFOV
								then

									local score =
										screenDistance +
										distance *
										0.01

									if score <
										bestScore
									then

										bestScore =
											score

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

--========================================================
-- AIM
--========================================================

local CurrentTarget

local function UpdateAim(dt)

	if not Settings.AimEnabled then

		CurrentTarget = nil

		return
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera or not RootPart then
		return
	end

	CurrentTarget =
		FindTarget()

	if not CurrentTarget then
		return
	end

	local targetPart =
		GetAimPart(
			CurrentTarget.Character
		)

	if not targetPart then
		return
	end

	local cameraPosition =
		Camera.CFrame.Position

	local targetPosition =
		targetPart.Position

	local targetCFrame =
		CFrame.lookAt(
			cameraPosition,
			targetPosition
		)

	-- Strong lock
	local strength =
		math.clamp(
			Settings.LockStrength,
			1,
			100
		)

	local speed =
		math.max(
			Settings.AimSpeed,
			1
		)

	local alpha =
		1 -
		math.exp(
			-(speed *
				(strength / 100)) *
			dt
		)

	alpha =
		math.clamp(
			alpha,
			0.01,
			1
		)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			targetCFrame,
			alpha
		)
end

--========================================================
-- ESP
--========================================================

local ESPFolder =
	Instance.new("Folder")

ESPFolder.Name =
	"XeirenESP"

ESPFolder.Parent =
	Workspace

local ESPObjects = {}
local TracerObjects = {}

local function CreateESP(player)

	if ESPObjects[player] then
		return ESPObjects[player]
	end

	local data = {}

	--============================================
	-- PLAYER HIGHLIGHT
	--============================================

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"PlayerESP"

	highlight.Enabled = false

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.FillTransparency =
		0.82

	highlight.OutlineTransparency =
		0

	highlight.Parent =
		ESPFolder

	data.Highlight =
		highlight

	--============================================
	-- INFO BILLBOARD
	--============================================

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"PlayerInfo"

	billboard.Size =
		UDim2.fromOffset(
			220,
			80
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3.7,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.Enabled =
		false

	billboard.MaxDistance =
		Settings.ESPDistance

	billboard.Parent =
		ESPFolder

	data.Billboard =
		billboard

	--============================================
	-- NAME
	--============================================

	local name =
		Instance.new("TextLabel")

	name.BackgroundTransparency =
		1

	name.Size =
		UDim2.new(
			1,
			0,
			0,
			20
		)

	name.Position =
		UDim2.fromOffset(
			0,
			0
		)

	name.Font =
		Enum.Font.GothamBold

	name.TextSize =
		13

	name.TextStrokeTransparency =
		0.2

	name.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	name.Parent =
		billboard

	data.Name =
		name

	--============================================
	-- DISTANCE
	--============================================

	local distance =
		Instance.new("TextLabel")

	distance.BackgroundTransparency =
		1

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

	distance.Font =
		Enum.Font.Gotham

	distance.TextSize =
		11

	distance.TextStrokeTransparency =
		0.3

	distance.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	distance.Parent =
		billboard

	data.Distance =
		distance

	--============================================
	-- HEALTH BACKGROUND
	--============================================

	local healthBackground =
		Instance.new("Frame")

	healthBackground.BackgroundColor3 =
		Color3.fromRGB(
			25,
			25,
			30
		)

	healthBackground.BorderSizePixel =
		0

	healthBackground.Size =
		UDim2.new(
			0.78,
			0,
			0,
			8
		)

	healthBackground.Position =
		UDim2.new(
			0.11,
			0,
			0,
			40
		)

	healthBackground.Parent =
		billboard

	data.HealthBackground =
		healthBackground

	--============================================
	-- HEALTH BAR
	--============================================

	local health =
		Instance.new("Frame")

	health.BackgroundColor3 =
		Color3.fromRGB(
			60,
			230,
			100
		)

	health.BorderSizePixel =
		0

	health.Size =
		UDim2.new(
			1,
			0,
			1,
			0
		)

	health.Parent =
		healthBackground

	data.Health =
		health

	--============================================
	-- HP TEXT
	--============================================

	local hpText =
		Instance.new("TextLabel")

	hpText.BackgroundTransparency =
		1

	hpText.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	hpText.Position =
		UDim2.fromOffset(
			0,
			49
		)

	hpText.Font =
		Enum.Font.GothamBold

	hpText.TextSize =
		10

	hpText.TextStrokeTransparency =
		0.25

	hpText.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	hpText.Parent =
		billboard

	data.HPText =
		hpText

	ESPObjects[player] =
		data

	return data
end

--========================================================
-- TRACER
--========================================================

local function CreateTracer(player)

	if TracerObjects[player] then
		return TracerObjects[player]
	end

	local data = {}

	local startPart =
		Instance.new("Part")

	startPart.Name =
		"TracerOrigin"

	startPart.Anchored =
		true

	startPart.CanCollide =
		false

	startPart.CanTouch =
		false

	startPart.CanQuery =
		false

	startPart.Transparency =
		1

	startPart.Size =
		Vector3.new(
			0.1,
			0.1,
			0.1
		)

	startPart.Parent =
		ESPFolder

	local startAttachment =
		Instance.new("Attachment")

	startAttachment.Parent =
		startPart

	local endAttachment =
		Instance.new("Attachment")

	local beam =
		Instance.new("Beam")

	beam.Attachment0 =
		startAttachment

	beam.Attachment1 =
		endAttachment

	beam.FaceCamera =
		true

	beam.Width0 =
		0.07

	beam.Width1 =
		0.025

	beam.LightEmission =
		1

	beam.Transparency =
		NumberSequence.new(
			0.15
		)

	beam.Enabled =
		false

	beam.Parent =
		startPart

	data.Start =
		startPart

	data.End =
		endAttachment

	data.Beam =
		beam

	TracerObjects[player] =
		data

	return data
end

--========================================================
-- UPDATE ESP
--========================================================

local function UpdateESP(player)

	if player == LocalPlayer then
		return
	end

	local data =
		ESPObjects[player]
		or CreateESP(player)

	local tracer =
		TracerObjects[player]
		or CreateTracer(player)

	if not Settings.ESPEnabled then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		tracer.Beam.Enabled =
			false

		return
	end

	if not IsEnemy(player)
		or not IsAlive(player)
	then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		tracer.Beam.Enabled =
			false

		return
	end

	local character =
		player.Character

	local root =
		GetRoot(character)

	local humanoid =
		GetHumanoid(character)

	if not root or not humanoid then
		return
	end

	local distance =
		GetDistance(player)

	if distance >
		Settings.ESPDistance
	then

		data.Highlight.Enabled =
			false

		data.Billboard.Enabled =
			false

		tracer.Beam.Enabled =
			false

		return
	end

	--============================================
	-- COLOR
	--============================================

	local color =
		Color3.fromRGB(
			255,
			70,
			80
		)

	if Settings.ESPTeamColor then

		color =
			player.TeamColor.Color
	end

	--============================================
	-- HIGHLIGHT
	--============================================

	data.Highlight.Adornee =
		character

	data.Highlight.FillColor =
		color

	data.Highlight.OutlineColor =
		Color3.new(
			1,
			1,
			1
		)

	data.Highlight.DepthMode =
		Settings.ESPAlwaysOnTop
		and
		Enum.HighlightDepthMode.AlwaysOnTop
		or
		Enum.HighlightDepthMode.Occluded

	data.Highlight.Enabled =
		Settings.ESPBox

	--============================================
	-- BILLBOARD
	--============================================

	data.Billboard.Adornee =
		root

	data.Billboard.MaxDistance =
		Settings.ESPDistance

	data.Billboard.Enabled =
		true

	data.Name.Visible =
		Settings.ESPName

	data.Distance.Visible =
		Settings.ESPDistanceText

	data.Name.Text =
		player.DisplayName ..
		" [" ..
		player.Name ..
		"]"

	data.Name.TextColor3 =
		color

	data.Distance.Text =
		string.format(
			"%.0f studs",
			distance
		)

	--============================================
	-- HEALTH
	--============================================

	if Settings.ESPHealth then

		data.HealthBackground.Visible =
			true

		data.Health.Visible =
			true

		data.HPText.Visible =
			true

		local maxHealth =
			math.max(
				humanoid.MaxHealth,
				1
			)

		local health =
			math.clamp(
				humanoid.Health /
					maxHealth,
				0,
				1
			)

		data.Health.Size =
			UDim2.new(
				health,
				0,
				1,
				0
			)

		data.HPText.Text =
			string.format(
				"%d / %d HP",
				math.floor(
					humanoid.Health
				),
				math.floor(
					maxHealth
				)
			)

		if health > 0.6 then

			data.Health.BackgroundColor3 =
				Color3.fromRGB(
					60,
					230,
					100
				)

		elseif health > 0.3 then

			data.Health.BackgroundColor3 =
				Color3.fromRGB(
					255,
					210,
					50
				)

		else

			data.Health.BackgroundColor3 =
				Color3.fromRGB(
					255,
					50,
					60
				)
		end

	else

		data.HealthBackground.Visible =
			false

		data.Health.Visible =
			false

		data.HPText.Visible =
			false
	end

	--============================================
	-- HEAD MARKER
	--============================================

	if Settings.ESPHead then

		local head =
			character:FindFirstChild(
				"Head"
			)

		if head then

			if not data.Head then

				data.Head =
					Instance.new(
						"Highlight"
					)

				data.Head.Name =
					"HeadESP"

				data.Head.FillTransparency =
					0.25

				data.Head.OutlineTransparency =
					0

				data.Head.DepthMode =
					Enum.HighlightDepthMode.AlwaysOnTop

				data.Head.Parent =
					ESPFolder
			end

			data.Head.Adornee =
				head

			data.Head.FillColor =
				color

			data.Head.OutlineColor =
				Color3.new(
					1,
					1,
					1
				)

			data.Head.Enabled =
				true
		end

	elseif data.Head then

		data.Head.Enabled =
			false
	end

	--============================================
	-- TRACER
	--============================================

	if Settings.TracerEnabled then

		local Camera =
			Workspace.CurrentCamera

		if Camera then

			tracer.Start.Position =
				Camera.CFrame.Position
		end

		tracer.End.Parent =
			root

		tracer.Beam.Color =
			ColorSequence.new(
				color
			)

		tracer.Beam.Enabled =
			true

	else

		tracer.Beam.Enabled =
			false
	end
end

--========================================================
-- REMOVE ESP
--========================================================

local function RemoveESP(player)

	local data =
		ESPObjects[player]

	if data then

		for _, object in pairs(data) do

			if typeof(object) ==
				"Instance"
			then

				pcall(function()
					object:Destroy()
				end)
			end
		end

		ESPObjects[player] =
			nil
	end

	local tracer =
		TracerObjects[player]

	if tracer then

		if tracer.Start then
			tracer.Start:Destroy()
		end

		TracerObjects[player] =
			nil
	end
end

Players.PlayerRemoving:Connect(
	RemoveESP
)

Players.PlayerAdded:Connect(
	function(player)

		CreateESP(player)
		CreateTracer(player)

	end
)

for _, player in ipairs(
	Players:GetPlayers()
) do

	if player ~= LocalPlayer then

		CreateESP(player)
		CreateTracer(player)

	end
end

--========================================================
-- FLY
--========================================================

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
			OriginalAutoRotate
	end
end

local function StartFly()

	if not RootPart
		or not Humanoid
	then
		return
	end

	StopFly()

	Settings.FlyEnabled =
		true

	OriginalAutoRotate =
		Humanoid.AutoRotate

	Humanoid.AutoRotate =
		false

	FlyAttachment =
		Instance.new(
			"Attachment"
		)

	FlyAttachment.Name =
		"XeirenFlyAttachment"

	FlyAttachment.Parent =
		RootPart

	FlyVelocity =
		Instance.new(
			"LinearVelocity"
		)

	FlyVelocity.Name =
		"XeirenFlyVelocity"

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
		RootPart
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

	if not RootPart
		or not Humanoid
	then

		StopFly()

		return
	end

	if not FlyVelocity then

		StartFly()

		return
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
		return
	end

	local forward =
		Vector3.new(
			Camera.CFrame.LookVector.X,
			0,
			Camera.CFrame.LookVector.Z
		)

	local right =
		Vector3.new(
			Camera.CFrame.RightVector.X,
			0,
			Camera.CFrame.RightVector.Z
		)

	if forward.Magnitude > 0 then
		forward =
			forward.Unit
	end

	if right.Magnitude > 0 then
		right =
			right.Unit
	end

	local direction =
		Vector3.zero

	if UserInputService:IsKeyDown(
		Enum.KeyCode.W
	) then

		direction +=
			forward
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.S
	) then

		direction -=
			forward
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.D
	) then

		direction +=
			right
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.A
	) then

		direction -=
			right
	end

	local horizontal =
		Vector3.zero

	if direction.Magnitude > 0 then

		horizontal =
			direction.Unit *
			Settings.FlySpeed
	end

	local vertical = 0

	if UserInputService:IsKeyDown(
		Enum.KeyCode.Space
	) then

		vertical =
			Settings.FlyVerticalSpeed
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.LeftControl
	) then

		vertical =
			-Settings.FlyVerticalSpeed
	end

	FlyVelocity.VectorVelocity =
		horizontal +
		Vector3.new(
			0,
			vertical,
			0
		)
end

--========================================================
-- SPEED
--========================================================

local function UpdateSpeed()

	if not Humanoid then
		return
	end

	if Settings.SpeedEnabled then

		Humanoid.WalkSpeed =
			Settings.SpeedRun
	end
end

local function ToggleSpeed()

	Settings.SpeedEnabled =
		not Settings.SpeedEnabled

	if Humanoid then

		if Settings.SpeedEnabled then

			Humanoid.WalkSpeed =
				Settings.SpeedRun

		else

			Humanoid.WalkSpeed =
				OriginalWalkSpeed
		end
	end
end

--========================================================
-- GUI
--========================================================

local OldGui =
	PlayerGui:FindFirstChild(
		"XeirenCombatHub"
	)

if OldGui then
	OldGui:Destroy()
end

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"XeirenCombatHub"

ScreenGui.ResetOnSpawn =
	false

ScreenGui.IgnoreGuiInset =
	true

ScreenGui.Parent =
	PlayerGui

--========================================================
-- COLORS
--========================================================

local BG =
	Color3.fromRGB(
		12,
		12,
		17
	)

local PANEL =
	Color3.fromRGB(
		20,
		20,
		27
	)

local PANEL2 =
	Color3.fromRGB(
		28,
		28,
		37
	)

local ACCENT =
	Color3.fromRGB(
		120,
		70,
		255
	)

local TEXT =
	Color3.fromRGB(
		245,
		245,
		250
	)

local SUBTEXT =
	Color3.fromRGB(
		160,
		160,
		175
	)

local RED =
	Color3.fromRGB(
		255,
		70,
		90
	)

--========================================================
-- CORNER
--========================================================

local function Corner(object, radius)

	local corner =
		Instance.new(
			"UICorner"
		)

	corner.CornerRadius =
		UDim.new(
			0,
			radius
		)

	corner.Parent =
		object
end

local function Stroke(object)

	local stroke =
		Instance.new(
			"UIStroke"
		)

	stroke.Color =
		Color3.fromRGB(
			60,
			60,
			75
		)

	stroke.Transparency =
		0.25

	stroke.Parent =
		object
end

--========================================================
-- PASSWORD
--========================================================

local PasswordFrame =
	Instance.new("Frame")

PasswordFrame.Size =
	UDim2.fromOffset(
		310,
		190
	)

PasswordFrame.Position =
	UDim2.new(
		0.5,
		-155,
		0.5,
		-95
	)

PasswordFrame.BackgroundColor3 =
	BG

PasswordFrame.Parent =
	ScreenGui

Corner(
	PasswordFrame,
	13
)

Stroke(
	PasswordFrame
)

local PasswordTitle =
	Instance.new("TextLabel")

PasswordTitle.BackgroundTransparency =
	1

PasswordTitle.Size =
	UDim2.new(
		1,
		-30,
		0,
		30
	)

PasswordTitle.Position =
	UDim2.fromOffset(
		15,
		15
	)

PasswordTitle.Text =
	"XEIREN HUB"

PasswordTitle.Font =
	Enum.Font.GothamBold

PasswordTitle.TextSize =
	18

PasswordTitle.TextColor3 =
	TEXT

PasswordTitle.Parent =
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
		55
	)

PasswordBox.BackgroundColor3 =
	PANEL2

PasswordBox.PlaceholderText =
	"Password"

PasswordBox.Text =
	""

PasswordBox.ClearTextOnFocus =
	false

PasswordBox.TextColor3 =
	TEXT

PasswordBox.PlaceholderColor3 =
	SUBTEXT

PasswordBox.Font =
	Enum.Font.Gotham

PasswordBox.TextSize =
	13

PasswordBox.Parent =
	PasswordFrame

Corner(
	PasswordBox,
	7
)

local Login =
	Instance.new("TextButton")

Login.Size =
	UDim2.new(
		1,
		-30,
		0,
		38
	)

Login.Position =
	UDim2.fromOffset(
		15,
		102
	)

Login.BackgroundColor3 =
	ACCENT

Login.Text =
	"UNLOCK"

Login.Font =
	Enum.Font.GothamBold

Login.TextSize =
	12

Login.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Login.Parent =
	PasswordFrame

Corner(
	Login,
	7
)

local PasswordError =
	Instance.new("TextLabel")

PasswordError.BackgroundTransparency =
	1

PasswordError.Size =
	UDim2.new(
		1,
		-30,
		0,
		25
	)

PasswordError.Position =
	UDim2.fromOffset(
		15,
		150
	)

PasswordError.Text =
	""

PasswordError.Font =
	Enum.Font.Gotham

PasswordError.TextSize =
	11

PasswordError.TextColor3 =
	RED

PasswordError.Parent =
	PasswordFrame

--========================================================
-- MAIN HUB
--========================================================

local MainFrame
local LogoButton

local function BuildHub()

	if MainFrame then
		MainFrame:Destroy()
	end

	MainFrame =
		Instance.new("Frame")

	MainFrame.Name =
		"CompactHub"

	-- SMALL MENU
	MainFrame.Size =
		UDim2.fromOffset(
			330,
			450
		)

	MainFrame.Position =
		UDim2.new(
			0.5,
			-165,
			0.5,
			-225
		)

	MainFrame.BackgroundColor3 =
		BG

	MainFrame.Parent =
		ScreenGui

	Corner(
		MainFrame,
		13
	)

	Stroke(
		MainFrame
	)

	--============================================
	-- HEADER
	--============================================

	local Header =
		Instance.new("Frame")

	Header.Size =
		UDim2.new(
			1,
			0,
			0,
			43
		)

	Header.BackgroundColor3 =
		PANEL

	Header.Parent =
		MainFrame

	Corner(
		Header,
		13
	)

	local HeaderTitle =
		Instance.new("TextLabel")

	HeaderTitle.BackgroundTransparency =
		1

	HeaderTitle.Size =
		UDim2.new(
			1,
			-50,
			1,
			0
		)

	HeaderTitle.Position =
		UDim2.fromOffset(
			14,
			0
		)

	HeaderTitle.Text =
		"XEIREN • 5V5"

	HeaderTitle.Font =
		Enum.Font.GothamBold

	HeaderTitle.TextSize =
		14

	HeaderTitle.TextColor3 =
		TEXT

	HeaderTitle.TextXAlignment =
		Enum.TextXAlignment.Left

	HeaderTitle.Parent =
		Header

	local Close =
		Instance.new("TextButton")

	Close.Size =
		UDim2.fromOffset(
			30,
			30
		)

	Close.Position =
		UDim2.new(
			1,
			-36,
			0,
			6
		)

	Close.BackgroundColor3 =
		PANEL2

	Close.Text =
		"×"

	Close.Font =
		Enum.Font.GothamBold

	Close.TextSize =
		18

	Close.TextColor3 =
		TEXT

	Close.Parent =
		Header

	Corner(
		Close,
		7
	)

	Close.Activated:Connect(
		function()

			MainFrame.Visible =
				false

		end
	)

	--============================================
	-- DRAG
	--============================================

	local dragging = false
	local dragStart
	local startPosition

	Header.InputBegan:Connect(
		function(input)

			if
				input.UserInputType ==
				Enum.UserInputType.MouseButton1
				or
				input.UserInputType ==
				Enum.UserInputType.Touch
			then

				dragging = true

				dragStart =
					input.Position

				startPosition =
					MainFrame.Position

				input.Changed:Connect(
					function()

						if
							input.UserInputState ==
							Enum.UserInputState.End
						then

							dragging =
								false
						end
					end
				)
			end
		end
	)

	UserInputService.InputChanged:Connect(
		function(input)

			if not dragging then
				return
			end

			if
				input.UserInputType ==
				Enum.UserInputType.MouseMovement
				or
				input.UserInputType ==
				Enum.UserInputType.Touch
			then

				local delta =
					input.Position -
					dragStart

				MainFrame.Position =
					UDim2.new(
						startPosition.X.Scale,
						startPosition.X.Offset +
							delta.X,

						startPosition.Y.Scale,
						startPosition.Y.Offset +
							delta.Y
					)
			end
		end
	)

	--============================================
	-- SCROLL
	--============================================

	local Scroll =
		Instance.new(
			"ScrollingFrame"
		)

	Scroll.Size =
		UDim2.new(
			1,
			-16,
			1,
			-51
		)

	Scroll.Position =
		UDim2.fromOffset(
			8,
			47
		)

	Scroll.BackgroundTransparency =
		1

	Scroll.BorderSizePixel =
		0

	Scroll.ScrollBarThickness =
		3

	Scroll.ScrollBarImageColor3 =
		ACCENT

	Scroll.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	Scroll.CanvasSize =
		UDim2.new()

	Scroll.Parent =
		MainFrame

	local Layout =
		Instance.new(
			"UIListLayout"
		)

	Layout.Padding =
		UDim.new(
			0,
			5
		)

	Layout.Parent =
		Scroll

	--============================================
	-- HELPERS
	--============================================

	local function Label(text)

		local label =
			Instance.new(
				"TextLabel"
			)

		label.BackgroundTransparency =
			1

		label.Size =
			UDim2.new(
				1,
				0,
				0,
				25
			)

		label.Text =
			text

		label.Font =
			Enum.Font.GothamBold

		label.TextSize =
			11

		label.TextColor3 =
			ACCENT

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
			Instance.new(
				"TextButton"
			)

		button.AutoButtonColor =
			false

		button.Size =
			UDim2.new(
				1,
				0,
				0,
				33
			)

		button.BackgroundColor3 =
			PANEL2

		button.Text =
			text

		button.Font =
			Enum.Font.GothamMedium

		button.TextSize =
			11

		button.TextColor3 =
			TEXT

		button.Parent =
			Scroll

		Corner(
			button,
			7
		)

		button.Activated:Connect(
			function()

				callback(button)

			end
		)

		return button
	end

	local function Toggle(
		title,
		get,
		set
	)

		local button

		button =
			Button(
				"",
				function()

					set(
						not get()
					)

					button.Text =
						title ..
						"  " ..
						(
							get()
							and "ON"
							or "OFF"
						)

					button.BackgroundColor3 =
						get()
						and Color3.fromRGB(
							55,
							35,
							100
						)
						or PANEL2
				end
			)

		button.Text =
			title ..
			"  " ..
			(
				get()
				and "ON"
				or "OFF"
			)

		if get() then

			button.BackgroundColor3 =
				Color3.fromRGB(
					55,
					35,
					100
				)
		end

		return button
	end

	local function Number(
		title,
		get,
		set,
		minimum,
		maximum
	)

		local frame =
			Instance.new("Frame")

		frame.Size =
			UDim2.new(
				1,
				0,
				0,
				38
			)

		frame.BackgroundTransparency =
			1

		frame.Parent =
			Scroll

		local label =
			Instance.new(
				"TextLabel"
			)

		label.BackgroundTransparency =
			1

		label.Size =
			UDim2.new(
				0.58,
				0,
				1,
				0
			)

		label.Text =
			title

		label.Font =
			Enum.Font.GothamMedium

		label.TextSize =
			11

		label.TextColor3 =
			TEXT

		label.TextXAlignment =
			Enum.TextXAlignment.Left

		label.Parent =
			frame

		local box =
			Instance.new(
				"TextBox"
			)

		box.Size =
			UDim2.new(
				0.42,
				0,
				0,
				30
			)

		box.Position =
			UDim2.new(
				0.58,
				0,
				0.5,
				-15
			)

		box.BackgroundColor3 =
			PANEL2

		box.Text =
			tostring(
				get()
			)

		box.ClearTextOnFocus =
			false

		box.Font =
			Enum.Font.Gotham

		box.TextSize =
			11

		box.TextColor3 =
			TEXT

		box.Parent =
			frame

		Corner(
			box,
			6
		)

		box.FocusLost:Connect(
			function()

				local value =
					tonumber(
						box.Text
					)

				if value then

					value =
						math.clamp(
							value,
							minimum,
							maximum
						)

					set(value)

				end

				box.Text =
					tostring(
						get()
					)
			end
		)

		return frame
	end

	--============================================
	-- AIM
	--============================================

	Label(
		"🎯 AIM"
	)

	Toggle(
		"Aim Assist",
		function()
			return Settings.AimEnabled
		end,
		function(value)
			Settings.AimEnabled =
				value
		end
	)

	Toggle(
		"360° Strong Lock",
		function()
			return Settings.Full360
		end,
		function(value)
			Settings.Full360 =
				value
		end
	)

	Number(
		"Lock Strength",
		function()
			return Settings.LockStrength
		end,
		function(value)
			Settings.LockStrength =
				value
		end,
		1,
		100
	)

	Number(
		"Aim Speed",
		function()
			return Settings.AimSpeed
		end,
		function(value)
			Settings.AimSpeed =
				value
		end,
		1,
		200
	)

	Number(
		"Aim Distance",
		function()
			return Settings.AimDistance
		end,
		function(value)
			Settings.AimDistance =
				value
		end,
		10,
		5000
	)

	Button(
		"Target: " ..
		Settings.AimPart,
		function(button)

			if Settings.AimPart ==
				"Head"
			then

				Settings.AimPart =
					"Body"

			else

				Settings.AimPart =
					"Head"
			end

			button.Text =
				"Target: " ..
				Settings.AimPart
		end
	)

	--============================================
	-- ESP
	--============================================

	Label(
		"👁 STRONG ESP"
	)

	Toggle(
		"ESP",
		function()
			return Settings.ESPEnabled
		end,
		function(value)
			Settings.ESPEnabled =
				value
		end
	)

	Toggle(
		"ESP Box",
		function()
			return Settings.ESPBox
		end,
		function(value)
			Settings.ESPBox =
				value
		end
	)

	Toggle(
		"Player Name",
		function()
			return Settings.ESPName
		end,
		function(value)
			Settings.ESPName =
				value
		end
	)

	Toggle(
		"Health Bar",
		function()
			return Settings.ESPHealth
		end,
		function(value)
			Settings.ESPHealth =
				value
		end
	)

	Toggle(
		"Distance",
		function()
			return Settings.ESPDistanceText
		end,
		function(value)
			Settings.ESPDistanceText =
				value
		end
	)

	Toggle(
		"Head Marker",
		function()
			return Settings.ESPHead
		end,
		function(value)
			Settings.ESPHead =
				value
		end
	)

	Toggle(
		"Always On Top",
		function()
			return Settings.ESPAlwaysOnTop
		end,
		function(value)
			Settings.ESPAlwaysOnTop =
				value
		end
	)

	Toggle(
		"Team Color",
		function()
			return Settings.ESPTeamColor
		end,
		function(value)
			Settings.ESPTeamColor =
				value
		end
	)

	Toggle(
		"Tracers",
		function()
			return Settings.TracerEnabled
		end,
		function(value)
			Settings.TracerEnabled =
				value
		end
	)

	Number(
		"ESP Distance",
		function()
			return Settings.ESPDistance
		end,
		function(value)
			Settings.ESPDistance =
				value
		end,
		50,
		5000
	)

	--============================================
	-- CHECKS
	--============================================

	Label(
		"⚙ CHECKS"
	)

	Toggle(
		"Team Check",
		function()
			return Settings.TeamCheck
		end,
		function(value)
			Settings.TeamCheck =
				value
		end
	)

	Toggle(
		"Wall Check",
		function()
			return Settings.WallCheck
		end,
		function(value)
			Settings.WallCheck =
				value
		end
	)

	--============================================
	-- FLY
	--============================================

	Label(
		"🪽 FLY"
	)

	Toggle(
		"Fly",
		function()
			return Settings.FlyEnabled
		end,
		function(value)

			if value then
				StartFly()
			else
				StopFly()
			end

		end
	)

	Number(
		"Fly Speed",
		function()
			return Settings.FlySpeed
		end,
		function(value)
			Settings.FlySpeed =
				value
		end,
		1,
		1000
	)

	Number(
		"Vertical Speed",
		function()
			return Settings.FlyVerticalSpeed
		end,
		function(value)
			Settings.FlyVerticalSpeed =
				value
		end,
		1,
		1000
	)

	--============================================
	-- MOVEMENT
	--============================================

	Label(
		"⚡ MOVEMENT"
	)

	Toggle(
		"Speed Run",
		function()
			return Settings.SpeedEnabled
		end,
		function(value)

			if value then

				Settings.SpeedEnabled =
					true

				UpdateSpeed()

			else

				Settings.SpeedEnabled =
					false

				if Humanoid then

					Humanoid.WalkSpeed =
						OriginalWalkSpeed
				end
			end
		end
	)

	Number(
		"Run Speed",
		function()
			return Settings.SpeedRun
		end,
		function(value)

			Settings.SpeedRun =
				value

			if Settings.SpeedEnabled then
				UpdateSpeed()
			end

		end,
		1,
		300
	)

	--============================================
	-- INFO
	--============================================

	Label(
		"⌨ CONTROLS"
	)

	local info =
		Instance.new(
			"TextLabel"
		)

	info.BackgroundTransparency =
		1

	info.Size =
		UDim2.new(
			1,
			0,
			0,
			45
		)

	info.Text =
		"R = Fly    V = Speed\n" ..
		"W/A/S/D = Fly    Space = Up    Ctrl = Down"

	info.Font =
		Enum.Font.Gotham

	info.TextSize =
		10

	info.TextColor3 =
		SUBTEXT

	info.TextXAlignment =
		Enum.TextXAlignment.Left

	info.Parent =
		Scroll
end

--========================================================
-- LOGO BUTTON
--========================================================

LogoButton =
	Instance.new("TextButton")

LogoButton.Name =
	"XeirenLogo"

LogoButton.Size =
	UDim2.fromOffset(
		48,
		48
	)

LogoButton.Position =
	UDim2.new(
		0,
		18,
		0.5,
		-24
	)

LogoButton.BackgroundColor3 =
	ACCENT

LogoButton.Text =
	"XE"

LogoButton.Font =
	Enum.Font.GothamBlack

LogoButton.TextSize =
	14

LogoButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

LogoButton.Parent =
	ScreenGui

Corner(
	LogoButton,
	24
)

local LogoStroke =
	Instance.new("UIStroke")

LogoStroke.Color =
	Color3.fromRGB(
		190,
		150,
		255
	)

LogoStroke.Thickness =
	2

LogoStroke.Parent =
	LogoButton

--============================================
-- LOGO CLICK
--============================================

LogoButton.Activated:Connect(
	function()

		if not MainFrame then
			return
		end

		MainFrame.Visible =
			not MainFrame.Visible

	end
)

--========================================================
-- LOGIN
--========================================================

local function LoginHub()

	if PasswordBox.Text ==
		"anakin"
	then

		PasswordFrame.Visible =
			false

		BuildHub()

	else

		PasswordError.Text =
			"Wrong password"

		PasswordBox.Text =
			""

		task.delay(
			2,
			function()

				if PasswordError then
					PasswordError.Text =
						""
				end

			end
		)
	end
end

Login.Activated:Connect(
	LoginHub
)

PasswordBox.FocusLost:Connect(
	function(enterPressed)

		if enterPressed then
			LoginHub()
		end

	end
)

--========================================================
-- KEYBINDS
--========================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if input.KeyCode ==
			Enum.KeyCode.R
		then

			ToggleFly()

		elseif input.KeyCode ==
			Enum.KeyCode.V
		then

			ToggleSpeed()

		end
	end
)

--========================================================
-- MAIN LOOP
--========================================================

RunService.RenderStepped:Connect(
	function(dt)

		UpdateAim(dt)

		UpdateFly()

		UpdateSpeed()

		for _, player in ipairs(
			Players:GetPlayers()
		) do

			if player ~= LocalPlayer then
				UpdateESP(player)
			end

		end
	end
)

print(
	"[Xeiren] Compact 5V5 Hub loaded."
)
