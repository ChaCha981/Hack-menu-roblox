--============================================================
-- XEIREN 5V5 COMBAT HUB
-- ROBLOX STUDIO - LOCALSCRIPT
--
-- Password: anakin
--
-- FEATURES
-- AIM ASSIST
-- 360° LOCK
-- STRONG / SMOOTH LOCK
-- AIM SPEED / DISTANCE / FOV
-- HEAD / BODY TARGET
-- ESP
-- HEALTH / NAME / DISTANCE
-- HEAD MARKER
-- TEAM COLOR
-- TRACERS
-- TEAM CHECK
-- WALL CHECK
-- FLY
-- SPEED RUN
-- ULTRA FPS BOOST
-- DYNAMIC FPS OPTIMIZATION
-- FPS COUNTER
-- PC / MOBILE UI
-- DRAGGABLE XE BUTTON
-- COMPACT MENU
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

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
	SpeedRun = 32,

	-- FPS
	FPSBoost = true,
	UltraFPS = true,
	DynamicOptimization = true,
	PerformanceMode = "Ultra",
	ESPUpdateRate = 10,
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

local function SetupCharacter(char)

	Character = char

	Humanoid = char:WaitForChild("Humanoid", 5)
	Root = char:WaitForChild("HumanoidRootPart", 5)

	if Humanoid then
		OriginalWalkSpeed = Humanoid.WalkSpeed
	end

	Settings.FlyEnabled = false
end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)

	SetupCharacter(char)

	task.wait(0.5)

	if Settings.SpeedEnabled then
		Humanoid.WalkSpeed = Settings.SpeedRun
	end
end)

--============================================================
-- PLAYER HELPERS
--============================================================

local function GetCharacter(player)
	return player.Character
end

local function GetHumanoid(player)

	local char = GetCharacter(player)

	if not char then
		return nil
	end

	return char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(player)

	local char = GetCharacter(player)

	if not char then
		return nil
	end

	return char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)

	local hum = GetHumanoid(player)
	local root = GetRoot(player)

	return hum
		and hum.Health > 0
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

	local targetRoot = GetRoot(player)

	if not targetRoot then
		return math.huge
	end

	return (Root.Position - targetRoot.Position).Magnitude
end

--============================================================
-- AIM PART
--============================================================

local function GetAimPart(player)

	local char = GetCharacter(player)

	if not char then
		return nil
	end

	if Settings.AimPart == "Head" then

		return char:FindFirstChild("Head")
			or char:FindFirstChild("HumanoidRootPart")

	end

	return char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("HumanoidRootPart")
end

--============================================================
-- WALL CHECK
--============================================================

local function HasLineOfSight(targetPart)

	if not Settings.WallCheck then
		return true
	end

	if not targetPart or not Camera then
		return false
	end

	if not Character then
		return false
	end

	local origin = Camera.CFrame.Position

	local direction =
		targetPart.Position - origin

	local params = RaycastParams.new()

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

--============================================================
-- AIM TARGET
--============================================================

local CurrentTarget = nil

local function FindTarget()

	if not Camera then
		return nil
	end

	local bestTarget = nil
	local bestScore = math.huge

	for _, player in ipairs(Players:GetPlayers()) do

		if IsEnemy(player) then

			local targetPart =
				GetAimPart(player)

			if targetPart then

				local distance =
					GetDistance(player)

				if distance <= Settings.AimDistance then

					if HasLineOfSight(targetPart) then

						-- 360 MODE
						if Settings.Full360 then

							local score = distance

							if score < bestScore then

								bestScore = score
								bestTarget = player

							end

						-- NORMAL FOV MODE
						else

							local screenPosition, visible =
								Camera:WorldToViewportPoint(
									targetPart.Position
								)

							if visible
								and screenPosition.Z > 0 then

								local center =
									Vector2.new(
										Camera.ViewportSize.X / 2,
										Camera.ViewportSize.Y / 2
									)

								local targetScreen =
									Vector2.new(
										screenPosition.X,
										screenPosition.Y
									)

								local screenDistance =
									(targetScreen - center).Magnitude

								if screenDistance <= Settings.AimFOV then

									if screenDistance < bestScore then

										bestScore =
											screenDistance

										bestTarget =
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

	return bestTarget
end

--============================================================
-- SMOOTH AIM
--============================================================

local function UpdateAim(dt)

	if not Settings.AimEnabled then

		CurrentTarget = nil
		return

	end

	if not Character
		or not Humanoid
		or Humanoid.Health <= 0 then

		CurrentTarget = nil
		return
	end

	if not CurrentTarget
		or not IsEnemy(CurrentTarget) then

		CurrentTarget = FindTarget()
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

	local distance =
		GetDistance(CurrentTarget)

	if distance > Settings.AimDistance then

		CurrentTarget = nil
		return
	end

	if not HasLineOfSight(targetPart) then

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
		1 - math.exp(-speed * dt)

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
	Workspace:FindFirstChild("XEIREN_ESP")

if not ESPFolder then

	ESPFolder = Instance.new("Folder")

	ESPFolder.Name =
		"XEIREN_ESP"

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

	--========================================================
	-- HIGHLIGHT
	--========================================================

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"XE_Highlight"

	highlight.FillTransparency =
		0.78

	highlight.OutlineTransparency =
		0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		ESPFolder

	data.Highlight =
		highlight

	--========================================================
	-- INFO BILLBOARD
	--========================================================

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"XE_Info"

	billboard.Size =
		UDim2.fromOffset(
			170,
			80
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3.2,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.MaxDistance =
		Settings.ESPDistance

	billboard.Parent =
		PlayerGui

	data.Billboard =
		billboard

	--========================================================
	-- FRAME
	--========================================================

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

	--========================================================
	-- NAME
	--========================================================

	local nameLabel =
		Instance.new("TextLabel")

	nameLabel.Size =
		UDim2.new(
			1,
			0,
			0,
			20
		)

	nameLabel.BackgroundTransparency =
		1

	nameLabel.TextScaled =
		true

	nameLabel.Font =
		Enum.Font.GothamBold

	nameLabel.TextStrokeTransparency =
		0.4

	nameLabel.Parent =
		frame

	data.NameLabel =
		nameLabel

	--========================================================
	-- DISTANCE
	--========================================================

	local distanceLabel =
		Instance.new("TextLabel")

	distanceLabel.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	distanceLabel.Position =
		UDim2.fromOffset(
			0,
			21
		)

	distanceLabel.BackgroundTransparency =
		1

	distanceLabel.TextScaled =
		true

	distanceLabel.Font =
		Enum.Font.Gotham

	distanceLabel.TextStrokeTransparency =
		0.4

	distanceLabel.Parent =
		frame

	data.DistanceLabel =
		distanceLabel

	--========================================================
	-- HP TEXT
	--========================================================

	local hpLabel =
		Instance.new("TextLabel")

	hpLabel.Size =
		UDim2.new(
			1,
			0,
			0,
			18
		)

	hpLabel.Position =
		UDim2.fromOffset(
			0,
			42
		)

	hpLabel.BackgroundTransparency =
		1

	hpLabel.TextScaled =
		true

	hpLabel.Font =
		Enum.Font.GothamBold

	hpLabel.TextStrokeTransparency =
		0.4

	hpLabel.Parent =
		frame

	data.HPLabel =
		hpLabel

	--========================================================
	-- HP BAR
	--========================================================

	local hpBackground =
		Instance.new("Frame")

	hpBackground.Size =
		UDim2.new(
			0.8,
			0,
			0,
			6
		)

	hpBackground.Position =
		UDim2.new(
			0.1,
			0,
			1,
			-10
		)

	hpBackground.BorderSizePixel =
		0

	hpBackground.BackgroundColor3 =
		Color3.fromRGB(
			30,
			30,
			30
		)

	hpBackground.Parent =
		frame

	data.HPBackground =
		hpBackground

	local hpBar =
		Instance.new("Frame")

	hpBar.Size =
		UDim2.fromScale(
			1,
			1
		)

	hpBar.BorderSizePixel =
		0

	hpBar.Parent =
		hpBackground

	data.HPBar =
		hpBar

	--========================================================
	-- HEAD MARKER
	--========================================================

	local headMarker =
		Instance.new("BillboardGui")

	headMarker.Name =
		"XE_Head"

	headMarker.Size =
		UDim2.fromOffset(
			14,
			14
		)

	headMarker.AlwaysOnTop =
		true

	headMarker.MaxDistance =
		Settings.ESPDistance

	headMarker.Parent =
		PlayerGui

	local headFrame =
		Instance.new("Frame")

	headFrame.Size =
		UDim2.fromScale(
			1,
			1
		)

	headFrame.BorderSizePixel =
		0

	headFrame.Parent =
		headMarker

	data.HeadMarker =
		headMarker

	data.HeadFrame =
		headFrame

	ESPObjects[player] =
		data
end

--============================================================
-- TRACER
--============================================================

local function CreateTracer(player)

	local data =
		ESPObjects[player]

	if not data then
		return
	end

	if data.Tracer then
		return
	end

	local originPart =
		ESPFolder:FindFirstChild(
			"XE_TracerOrigin"
		)

	if not originPart then

		originPart =
			Instance.new("Part")

		originPart.Name =
			"XE_TracerOrigin"

		originPart.Anchored =
			true

		originPart.CanCollide =
			false

		originPart.CanTouch =
			false

		originPart.CanQuery =
			false

		originPart.Transparency =
			1

		originPart.Size =
			Vector3.new(
				0.1,
				0.1,
				0.1
			)

		originPart.Parent =
			ESPFolder

		local origin =
			Instance.new("Attachment")

		origin.Name =
			"Origin"

		origin.Parent =
			originPart
	end

	local target =
		Instance.new("Attachment")

	target.Name =
		"XE_TracerTarget"

	target.Parent =
		ESPFolder

	local beam =
		Instance.new("Beam")

	beam.Name =
		"XE_Tracer"

	beam.FaceCamera =
		true

	beam.Width0 =
		0.035

	beam.Width1 =
		0.035

	beam.Transparency =
		NumberSequence.new(
			0.25
		)

	beam.Attachment0 =
		originPart:FindFirstChild(
			"Origin"
		)

	beam.Attachment1 =
		target

	beam.Parent =
		ESPFolder

	data.Tracer =
		beam

	data.TracerAttachment =
		target
end

--============================================================
-- REMOVE ESP
--============================================================

local function RemoveESP(player)

	local data =
		ESPObjects[player]

	if not data then
		return
	end

	for _, object in pairs(data) do

		if typeof(object) == "Instance" then
			object:Destroy()
		end
	end

	ESPObjects[player] =
		nil
end

--============================================================
-- ESP UPDATE
--============================================================

local function UpdateESP()

	if not Settings.ESPEnabled then

		for _, data in pairs(ESPObjects) do

			if data.Highlight then
				data.Highlight.Enabled = false
			end

			if data.Billboard then
				data.Billboard.Enabled = false
			end

			if data.HeadMarker then
				data.HeadMarker.Enabled = false
			end

			if data.Tracer then
				data.Tracer.Enabled = false
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

			local char =
				GetCharacter(player)

			local hum =
				GetHumanoid(player)

			local root =
				GetRoot(player)

			local head =
				char
				and char:FindFirstChild("Head")

			if IsEnemy(player)
				and root
				and hum
				and hum.Health > 0 then

				local distance =
					GetDistance(player)

				if distance <= Settings.ESPDistance then

					local color =
						GetESPColor(player)

					-- HIGHLIGHT
					if data.Highlight then

						data.Highlight.Enabled =
							Settings.ESPBox

						data.Highlight.Adornee =
							char

						data.Highlight.FillColor =
							color

						data.Highlight.OutlineColor =
							color

						data.Highlight.DepthMode =
							Settings.ESPAlwaysOnTop
							and Enum.HighlightDepthMode.AlwaysOnTop
							or Enum.HighlightDepthMode.Occluded
					end

					-- INFO
					if data.Billboard then

						data.Billboard.Enabled =
							true

						data.Billboard.Adornee =
							root

						data.Billboard.MaxDistance =
							Settings.ESPDistance

						data.NameLabel.Visible =
							Settings.ESPName

						data.DistanceLabel.Visible =
							Settings.ESPDistanceText

						data.HPLabel.Visible =
							Settings.ESPHealth

						data.HPBackground.Visible =
							Settings.ESPHealth

						data.NameLabel.Text =
							player.DisplayName

						data.NameLabel.TextColor3 =
							color

						data.DistanceLabel.Text =
							math.floor(distance)
							.. " studs"

						data.DistanceLabel.TextColor3 =
							color

						data.HPLabel.Text =
							math.floor(hum.Health)
							.. " / "
							.. math.floor(
								hum.MaxHealth
							)

						data.HPLabel.TextColor3 =
							color

						local hp =
							math.clamp(
								hum.Health /
								math.max(
									hum.MaxHealth,
									1
								),
								0,
								1
							)

						data.HPBar.Size =
							UDim2.new(
								hp,
								0,
								1,
								0
							)

						data.HPBar.BackgroundColor3 =
							color
					end

					-- HEAD
					if data.HeadMarker then

						if head
							and Settings.ESPHead then

							data.HeadMarker.Enabled =
								true

							data.HeadMarker.Adornee =
								head

							data.HeadFrame.BackgroundColor3 =
								color

						else

							data.HeadMarker.Enabled =
								false
						end
					end

					-- TRACER
					if Settings.TracerEnabled then

						CreateTracer(player)

						if data.Tracer then

							data.Tracer.Enabled =
								true

							data.TracerAttachment.Parent =
								root
						end

					elseif data.Tracer then

						data.Tracer.Enabled =
							false
					end

				else

					if data.Highlight then
						data.Highlight.Enabled = false
					end

					if data.Billboard then
						data.Billboard.Enabled = false
					end

					if data.HeadMarker then
						data.HeadMarker.Enabled = false
					end

					if data.Tracer then
						data.Tracer.Enabled = false
					end
				end

			else

				if data.Highlight then
					data.Highlight.Enabled = false
				end

				if data.Billboard then
					data.Billboard.Enabled = false
				end

				if data.HeadMarker then
					data.HeadMarker.Enabled = false
				end

				if data.Tracer then
					data.Tracer.Enabled = false
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

	if not Root or not FlyVelocity then
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
-- FPS BOOST
--============================================================

local FPSBackup = {}

local function BackupInstance(instance)

	if FPSBackup[instance] ~= nil then
		return
	end

	if instance:IsA("ParticleEmitter") then

		FPSBackup[instance] =
			{
				Type = "Particle",
				Enabled = instance.Enabled
			}

	elseif instance:IsA("Trail") then

		FPSBackup[instance] =
			{
				Type = "Trail",
				Enabled = instance.Enabled
			}

	elseif instance:IsA("Beam") then

		if not instance.Name:find("XE_Tracer") then

			FPSBackup[instance] =
				{
					Type = "Beam",
					Enabled = instance.Enabled
				}
		end

	elseif instance:IsA("PostEffect") then

		FPSBackup[instance] =
			{
				Type = "PostEffect",
				Enabled = instance.Enabled
			}
	end
end

local function BackupVisuals()

	FPSBackup = {}

	FPSBackup["GlobalShadows"] =
		Lighting.GlobalShadows

	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		BackupInstance(object)
	end

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do

		BackupInstance(object)
	end
end

local function RestoreVisuals()

	if FPSBackup["GlobalShadows"] ~= nil then

		Lighting.GlobalShadows =
			FPSBackup["GlobalShadows"]
	end

	for object, data in pairs(
		FPSBackup
	) do

		if typeof(object) == "Instance"
			and object.Parent then

			pcall(function()

				object.Enabled =
					data.Enabled

			end)
		end
	end

	FPSBackup = {}
end

local function ApplyUltraFPS()

	--========================================================
	-- SHADOWS
	--========================================================

	Lighting.GlobalShadows =
		false

	--========================================================
	-- POST EFFECTS
	--========================================================

	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		if object:IsA("PostEffect") then
			object.Enabled = false
		end
	end

	--========================================================
	-- PARTICLES / TRAILS / BEAMS
	--========================================================

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do

		if object:IsA("ParticleEmitter") then

			object.Enabled =
				false

		elseif object:IsA("Trail") then

			object.Enabled =
				false

		elseif object:IsA("Beam") then

			if not object.Name:find(
				"XE_Tracer"
			) then

				object.Enabled =
					false
			end
		end
	end

	--========================================================
	-- TERRAIN
	--========================================================

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

local function ApplyBalancedFPS()

	Lighting.GlobalShadows =
		false

	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		if object:IsA("PostEffect") then
			object.Enabled = false
		end
	end

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do

		if object:IsA("ParticleEmitter") then

			object.Enabled =
				false

		elseif object:IsA("Trail") then

			object.Enabled =
				true
		end
	end

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

local function ApplyFPSMode()

	if not Settings.FPSBoost then

		RestoreVisuals()

		return
	end

	BackupVisuals()

	if Settings.PerformanceMode ==
		"Ultra" then

		ApplyUltraFPS()

	elseif Settings.PerformanceMode ==
		"Balanced" then

		ApplyBalancedFPS()

	elseif Settings.PerformanceMode ==
		"Performance" then

		ApplyUltraFPS()

	elseif Settings.PerformanceMode ==
		"Quality" then

		RestoreVisuals()
	end
end

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

local DynamicLevel = 0

local function DynamicPerformance(dt)

	if not Settings.FPSBoost then
		return
	end

	if not Settings.DynamicOptimization then
		return
	end

	DynamicTimer += dt

	if DynamicTimer < 3 then
		return
	end

	DynamicTimer = 0

	-- VERY LOW FPS
	if FPS < 25 then

		if DynamicLevel ~= 3 then

			DynamicLevel = 3

			Settings.ESPUpdateRate = 5

			Settings.TracerEnabled = false

			ApplyUltraFPS()
		end

	-- LOW FPS
	elseif FPS < 40 then

		if DynamicLevel ~= 2 then

			DynamicLevel = 2

			Settings.ESPUpdateRate = 7

			ApplyUltraFPS()
		end

	-- GOOD FPS
	elseif FPS < 55 then

		if DynamicLevel ~= 1 then

			DynamicLevel = 1

			Settings.ESPUpdateRate = 10

			ApplyUltraFPS()
		end

	-- HIGH FPS
	else

		if DynamicLevel ~= 0 then

			DynamicLevel = 0

			Settings.ESPUpdateRate = 15
		end
	end
end

--============================================================
-- GUI
--============================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"XEIREN_CombatHub"

ScreenGui.ResetOnSpawn =
	false

ScreenGui.IgnoreGuiInset =
	true

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
		180
	)

PasswordFrame.Position =
	UDim2.new(
		0.5,
		-150,
		0.5,
		-90
	)

PasswordFrame.BackgroundColor3 =
	Color3.fromRGB(
		20,
		20,
		24
	)

PasswordFrame.BorderSizePixel =
	0

PasswordFrame.Parent =
	ScreenGui

local PasswordCorner =
	Instance.new("UICorner")

PasswordCorner.CornerRadius =
	UDim.new(
		0,
		12
	)

PasswordCorner.Parent =
	PasswordFrame

local PasswordTitle =
	Instance.new("TextLabel")

PasswordTitle.Size =
	UDim2.new(
		1,
		-20,
		0,
		35
	)

PasswordTitle.Position =
	UDim2.fromOffset(
		10,
		10
	)

PasswordTitle.BackgroundTransparency =
	1

PasswordTitle.Text =
	"XEIREN 5V5"

PasswordTitle.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PasswordTitle.TextScaled =
	true

PasswordTitle.Font =
	Enum.Font.GothamBold

PasswordTitle.Parent =
	PasswordFrame

local PasswordBox =
	Instance.new("TextBox")

PasswordBox.Size =
	UDim2.new(
		1,
		-40,
		0,
		40
	)

PasswordBox.Position =
	UDim2.fromOffset(
		20,
		55
	)

PasswordBox.BackgroundColor3 =
	Color3.fromRGB(
		35,
		35,
		42
	)

PasswordBox.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PasswordBox.PlaceholderText =
	"Password"

PasswordBox.Text =
	""

PasswordBox.TextScaled =
	true

PasswordBox.Font =
	Enum.Font.Gotham

PasswordBox.ClearTextOnFocus =
	false

PasswordBox.Parent =
	PasswordFrame

local PasswordButton =
	Instance.new("TextButton")

PasswordButton.Size =
	UDim2.new(
		1,
		-40,
		0,
		40
	)

PasswordButton.Position =
	UDim2.fromOffset(
		20,
		110
	)

PasswordButton.BackgroundColor3 =
	Color3.fromRGB(
		50,
		50,
		60
	)

PasswordButton.Text =
	"UNLOCK"

PasswordButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PasswordButton.TextScaled =
	true

PasswordButton.Font =
	Enum.Font.GothamBold

PasswordButton.Parent =
	PasswordFrame

local PasswordStatus =
	Instance.new("TextLabel")

PasswordStatus.Size =
	UDim2.new(
		1,
		-20,
		0,
		20
	)

PasswordStatus.Position =
	UDim2.fromOffset(
		10,
		150
	)

PasswordStatus.BackgroundTransparency =
	1

PasswordStatus.Text =
	""

PasswordStatus.TextScaled =
	true

PasswordStatus.Font =
	Enum.Font.Gotham

PasswordStatus.TextColor3 =
	Color3.fromRGB(
		255,
		80,
		80
	)

PasswordStatus.Parent =
	PasswordFrame

--============================================================
-- MAIN MENU
--============================================================

local MainFrame =
	Instance.new("Frame")

MainFrame.Size =
	UDim2.fromOffset(
		300,
		360
	)

MainFrame.Position =
	UDim2.new(
		0.5,
		-150,
		0.5,
		-180
	)

MainFrame.BackgroundColor3 =
	Color3.fromRGB(
		18,
		18,
		22
	)

MainFrame.BorderSizePixel =
	0

MainFrame.Visible =
	false

MainFrame.Parent =
	ScreenGui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(
		0,
		12
	)

MainCorner.Parent =
	MainFrame

--============================================================
-- HEADER
--============================================================

local Header =
	Instance.new("TextLabel")

Header.Size =
	UDim2.new(
		1,
		0,
		0,
		38
	)

Header.BackgroundColor3 =
	Color3.fromRGB(
		28,
		28,
		34
	)

Header.Text =
	"XEIREN • 5V5"

Header.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Header.TextScaled =
	true

Header.Font =
	Enum.Font.GothamBold

Header.Parent =
	MainFrame

--============================================================
-- DRAG MENU
--============================================================

local menuDragging = false
local menuDragStart
local menuStartPosition

Header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		menuDragging = true

		menuDragStart =
			input.Position

		menuStartPosition =
			MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not menuDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position -
			menuDragStart

		MainFrame.Position =
			UDim2.new(
				menuStartPosition.X.Scale,
				menuStartPosition.X.Offset
					+ delta.X,

				menuStartPosition.Y.Scale,
				menuStartPosition.Y.Offset
					+ delta.Y
			)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		menuDragging = false
	end
end)

--============================================================
-- SCROLL
--============================================================

local Scroll =
	Instance.new("ScrollingFrame")

Scroll.Size =
	UDim2.new(
		1,
		-10,
		1,
		-44
	)

Scroll.Position =
	UDim2.fromOffset(
		5,
		42
	)

Scroll.BackgroundTransparency =
	1

Scroll.BorderSizePixel =
	0

Scroll.ScrollBarThickness =
	3

Scroll.CanvasSize =
	UDim2.new(
		0,
		0,
		0,
		1450
	)

Scroll.Parent =
	MainFrame

local Layout =
	Instance.new("UIListLayout")

Layout.Padding =
	UDim.new(
		0,
		4
	)

Layout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

Layout.Parent =
	Scroll

--============================================================
-- GUI FUNCTIONS
--============================================================

local function Section(text)

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-10,
			0,
			21
		)

	label.BackgroundTransparency =
		1

	label.Text =
		text

	label.TextColor3 =
		Color3.fromRGB(
			180,
			180,
			190
		)

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Font =
		Enum.Font.GothamBold

	label.TextSize =
		12

	label.Parent =
		Scroll

	return label
end

local function Toggle(text, key)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-10,
			0,
			30
		)

	button.BackgroundColor3 =
		Color3.fromRGB(
			30,
			30,
			36
		)

	button.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	button.Font =
		Enum.Font.Gotham

	button.TextSize =
		12

	button.Parent =
		Scroll

	local function Refresh()

		button.Text =
			text
			.. " : "
			.. (
				Settings[key]
				and "ON"
				or "OFF"
			)
	end

	Refresh()

	button.Activated:Connect(function()

		Settings[key] =
			not Settings[key]

		Refresh()

		if key == "FlyEnabled" then

			if Settings.FlyEnabled then
				StartFly()
			else
				StopFly()
			end
		end

		if key == "SpeedEnabled" then
			UpdateSpeed()
		end

		if key == "FPSBoost" then
			ApplyFPSMode()
		end

		if key == "ShowFPS" then
			-- handled in RenderStepped
		end
	end)

	return button
end

local function Slider(
	text,
	key,
	minValue,
	maxValue,
	step
)

	local holder =
		Instance.new("Frame")

	holder.Size =
		UDim2.new(
			1,
			-10,
			0,
			45
		)

	holder.BackgroundColor3 =
		Color3.fromRGB(
			28,
			28,
			34
		)

	holder.Parent =
		Scroll

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-10,
			0,
			18
		)

	label.Position =
		UDim2.fromOffset(
			5,
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
		11

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
			15
		)

	bar.Position =
		UDim2.fromOffset(
			10,
			25
		)

	bar.BackgroundColor3 =
		Color3.fromRGB(
			50,
			50,
			58
		)

	bar.Text =
		""

	bar.AutoButtonColor =
		false

	bar.Parent =
		holder

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

	local function UpdateFromX(x)

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
			minValue
			+
			(
				maxValue -
				minValue
			)
			*
			percent

		if step then

			value =
				math.floor(
					value / step
					+ 0.5
				)
				* step
		end

		Settings[key] =
			value

		Refresh()
	end

	Refresh()

	local sliding = false

	bar.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			sliding = true

			UpdateFromX(
				input.Position.X
			)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if not sliding then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			UpdateFromX(
				input.Position.X
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			sliding = false
		end
	end)

	return holder
end

--============================================================
-- AIM MENU
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

local AimPartButton =
	Instance.new("TextButton")

AimPartButton.Size =
	UDim2.new(
		1,
		-10,
		0,
		30
	)

AimPartButton.BackgroundColor3 =
	Color3.fromRGB(
		30,
		30,
		36
	)

AimPartButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

AimPartButton.Text =
	"Target : "
	.. Settings.AimPart

AimPartButton.Font =
	Enum.Font.Gotham

AimPartButton.TextSize =
	12

AimPartButton.Parent =
	Scroll

AimPartButton.Activated:Connect(function()

	if Settings.AimPart ==
		"Head" then

		Settings.AimPart =
			"Body"

	else

		Settings.AimPart =
			"Head"
	end

	AimPartButton.Text =
		"Target : "
		.. Settings.AimPart
end)

--============================================================
-- ESP MENU
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
	"Distance",
	"ESPDistanceText"
)

Toggle(
	"Health",
	"ESPHealth"
)

Toggle(
	"Head Marker",
	"ESPHead"
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

--============================================================
-- TRACER
--============================================================

Section("TRACER")

Toggle(
	"Tracers",
	"TracerEnabled"
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
-- FLY
--============================================================

Section("FLY")

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

--============================================================
-- SPEED
--============================================================

Section("MOVEMENT")

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
-- FPS
--============================================================

Section("FPS BOOST")

Toggle(
	"FPS Boost",
	"FPSBoost"
)

Toggle(
	"Dynamic Optimize",
	"DynamicOptimization"
)

Toggle(
	"FPS Counter",
	"ShowFPS"
)

Toggle(
	"ULTRA Mode",
	"UltraFPS"
)

--============================================================
-- FPS MODE BUTTON
--============================================================

local ModeButton =
	Instance.new("TextButton")

ModeButton.Size =
	UDim2.new(
		1,
		-10,
		0,
		30
	)

ModeButton.BackgroundColor3 =
	Color3.fromRGB(
		30,
		30,
		36
	)

ModeButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

ModeButton.Text =
	"FPS Mode : "
	.. Settings.PerformanceMode

ModeButton.Font =
	Enum.Font.Gotham

ModeButton.TextSize =
	12

ModeButton.Parent =
	Scroll

local Modes = {
	"Ultra",
	"Performance",
	"Balanced",
	"Quality"
}

local ModeIndex = 1

ModeButton.Activated:Connect(function()

	ModeIndex += 1

	if ModeIndex >
		#Modes then

		ModeIndex = 1
	end

	Settings.PerformanceMode =
		Modes[ModeIndex]

	ModeButton.Text =
		"FPS Mode : "
		.. Settings.PerformanceMode

	ApplyFPSMode()
end)

Slider(
	"ESP Update",
	"ESPUpdateRate",
	5,
	30,
	1
)

--============================================================
-- CONTROLS
--============================================================

Section("CONTROLS")

local Controls =
	Instance.new("TextLabel")

Controls.Size =
	UDim2.new(
		1,
		-10,
		0,
		55
	)

Controls.BackgroundTransparency =
	1

Controls.Text =
	"R = Fly\n"
	..
	"V = Speed Run\n"
	..
	"XE = Open / Close"

Controls.TextColor3 =
	Color3.fromRGB(
		190,
		190,
		200
	)

Controls.TextSize =
	11

Controls.Font =
	Enum.Font.Gotham

Controls.TextXAlignment =
	Enum.TextXAlignment.Left

Controls.Parent =
	Scroll

--============================================================
-- DEVICE INFO
--============================================================

local DeviceLabel =
	Instance.new("TextLabel")

DeviceLabel.Size =
	UDim2.new(
		1,
		-10,
		0,
		40
	)

DeviceLabel.BackgroundTransparency =
	1

DeviceLabel.Text =
	"Device: "
	.. DeviceType

DeviceLabel.TextColor3 =
	Color3.fromRGB(
		160,
		160,
		170
	)

DeviceLabel.Font =
	Enum.Font.Gotham

DeviceLabel.TextSize =
	11

DeviceLabel.TextXAlignment =
	Enum.TextXAlignment.Left

DeviceLabel.Parent =
	Scroll

--============================================================
-- FPS COUNTER
--============================================================

local FPSLabel =
	Instance.new("TextLabel")

FPSLabel.Size =
	UDim2.fromOffset(
		95,
		28
	)

FPSLabel.Position =
	UDim2.new(
		1,
		-105,
		0,
		8
	)

FPSLabel.BackgroundTransparency =
	1

FPSLabel.Text =
	"FPS: --"

FPSLabel.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

FPSLabel.TextScaled =
	true

FPSLabel.Font =
	Enum.Font.GothamBold

FPSLabel.Visible =
	Settings.ShowFPS

FPSLabel.Parent =
	ScreenGui

--============================================================
-- XE LOGO
--============================================================

local LogoButton =
	Instance.new("TextButton")

LogoButton.Name =
	"XE_Logo"

LogoButton.Size =
	UDim2.fromOffset(
		46,
		46
	)

LogoButton.Position =
	UDim2.new(
		0,
		16,
		0.5,
		-23
	)

LogoButton.BackgroundColor3 =
	Color3.fromRGB(
		24,
		24,
		30
	)

LogoButton.Text =
	"XE"

LogoButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

LogoButton.TextScaled =
	true

LogoButton.Font =
	Enum.Font.GothamBlack

LogoButton.Parent =
	ScreenGui

local LogoCorner =
	Instance.new("UICorner")

LogoCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

LogoCorner.Parent =
	LogoButton

--============================================================
-- DRAG XE LOGO
--============================================================

local logoDragging = false
local logoDragStart
local logoStartPosition
local logoMoved = false

LogoButton.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		logoDragging = true
		logoMoved = false

		logoDragStart =
			input.Position

		logoStartPosition =
			LogoButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not logoDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position -
			logoDragStart

		if math.abs(delta.X) > 5
			or math.abs(delta.Y) > 5 then

			logoMoved = true
		end

		LogoButton.Position =
			UDim2.new(
				logoStartPosition.X.Scale,
				logoStartPosition.X.Offset
					+ delta.X,

				logoStartPosition.Y.Scale,
				logoStartPosition.Y.Offset
					+ delta.Y
			)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		logoDragging = false
	end
end)

LogoButton.Activated:Connect(function()

	if logoMoved then

		logoMoved = false

		return
	end

	MainFrame.Visible =
		not MainFrame.Visible
end)

--============================================================
-- PASSWORD
--============================================================

local function Unlock()

	if PasswordBox.Text ==
		"anakin" then

		PasswordFrame.Visible =
			false

		MainFrame.Visible =
			true

	else

		PasswordStatus.Text =
			"Wrong password"
	end
end

PasswordButton.Activated:Connect(
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
	function(input, gameProcessed)

		if gameProcessed then
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
-- PLAYER REMOVING
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
-- CLEANUP NEW VISUAL OBJECTS
--============================================================

Workspace.DescendantAdded:Connect(
	function(object)

		if not Settings.FPSBoost then
			return
		end

		if object:IsA("ParticleEmitter")
			or object:IsA("Trail")
			or object:IsA("PostEffect") then

			task.defer(function()

				if Settings.FPSBoost
					and object.Parent then

					pcall(function()

						object.Enabled =
							false

					end)
				end
			end)
		end
	end
)

--============================================================
-- INITIAL FPS BOOST
--============================================================

if Settings.FPSBoost then

	BackupVisuals()

	if Settings.PerformanceMode ==
		"Ultra" then

		ApplyUltraFPS()

	else

		ApplyFPSMode()
	end
end

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

		DynamicPerformance(dt)

		--====================================================
		-- ESP THROTTLE
		--====================================================

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

		--====================================================
		-- FPS UI
		--====================================================

		FPSLabel.Visible =
			Settings.ShowFPS

		if Settings.ShowFPS then

			FPSLabel.Text =
				"FPS: "
				.. tostring(FPS)
		end

		DeviceLabel.Text =
			"Device: "
			.. DeviceType
			.. "\nFPS Mode: "
			.. Settings.PerformanceMode
	end
)

--============================================================
-- END
--============================================================
