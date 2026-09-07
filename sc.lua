--============================================================
-- XEIREN 5V5 PERFORMANCE HUB
-- ROBLOX STUDIO LOCALSCRIPT
--
-- PASSWORD: anakin
--
-- AIM / 360 LOCK
-- ESP / BOX / NAME / HP / DISTANCE
-- ESP TRACER LINES
-- FLY
-- SPEED
-- MAX FPS BOOST
-- DYNAMIC OPTIMIZATION
-- MOBILE + PC UI
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
	ESPBox = true,
	ESPName = true,
	ESPHealth = true,
	ESPDistanceText = true,
	ESPHead = true,
	ESPTeamColor = false,
	ESPDistance = 600,

	-- NEW ESP LINE
	ESPLine = true,

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
	DynamicFPS = true,
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

local function SetupCharacter(char)

	Character = char

	Humanoid =
		char:WaitForChild(
			"Humanoid",
			5
		)

	Root =
		char:WaitForChild(
			"HumanoidRootPart",
			5
		)

	if Humanoid then
		OriginalWalkSpeed =
			Humanoid.WalkSpeed
	end

	-- reset movement states
	Settings.FlyEnabled = false
	Settings.SpeedEnabled = false
end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(
	function(char)

		SetupCharacter(char)

	end
)

--============================================================
-- PLAYER HELPERS
--============================================================

local function GetCharacter(player)
	return player.Character
end

local function GetHumanoid(player)

	local char =
		GetCharacter(player)

	if not char then
		return nil
	end

	return char:FindFirstChildOfClass(
		"Humanoid"
	)
end

local function GetRoot(player)

	local char =
		GetCharacter(player)

	if not char then
		return nil
	end

	return char:FindFirstChild(
		"HumanoidRootPart"
	)
end

local function IsAlive(player)

	local hum =
		GetHumanoid(player)

	local root =
		GetRoot(player)

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

	local target =
		GetRoot(player)

	if not target then
		return math.huge
	end

	return (
		Root.Position -
		target.Position
	).Magnitude
end

--============================================================
-- AIM
--============================================================

local function GetAimPart(player)

	local char =
		GetCharacter(player)

	if not char then
		return nil
	end

	if Settings.AimPart ==
		"Head" then

		return char:FindFirstChild("Head")
			or char:FindFirstChild(
				"HumanoidRootPart"
			)
	end

	return char:FindFirstChild(
		"UpperTorso"
	)
		or char:FindFirstChild(
			"Torso"
		)
		or char:FindFirstChild(
			"HumanoidRootPart"
		)
end

local function HasLineOfSight(target)

	if not Settings.WallCheck then
		return true
	end

	if not target
		or not Camera
		or not Character then

		return false
	end

	local origin =
		Camera.CFrame.Position

	local direction =
		target.Position -
		origin

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances =
		{
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
		target.Parent
	)
end

local CurrentTarget

local function FindTarget()

	if not Camera then
		return nil
	end

	local best
	local score =
		math.huge

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if IsEnemy(player) then

			local part =
				GetAimPart(player)

			if part then

				local distance =
					GetDistance(player)

				if distance <=
					Settings.AimDistance then

					if HasLineOfSight(part) then

						if Settings.Full360 then

							if distance <
								score then

								score =
									distance

								best =
									player
							end

						else

							local screen,
								visible =
								Camera:WorldToViewportPoint(
									part.Position
								)

							if visible
								and screen.Z > 0 then

								local center =
									Vector2.new(
										Camera.ViewportSize.X / 2,
										Camera.ViewportSize.Y / 2
									)

								local target =
									Vector2.new(
										screen.X,
										screen.Y
									)

								local distance2 =
									(
										target -
										center
									).Magnitude

								if distance2 <=
									Settings.AimFOV
									and distance2 < score then

									score =
										distance2

									best =
										player
								end
							end
						end
					end
				end
			end
		end
	end

	return best
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

	local part =
		GetAimPart(CurrentTarget)

	if not part then

		CurrentTarget = nil
		return
	end

	if GetDistance(CurrentTarget) >
		Settings.AimDistance then

		CurrentTarget = nil
		return
	end

	if not HasLineOfSight(part) then

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
		Settings.AimSpeed *
		strength

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
			part.Position
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
		"XEIREN_ESP"
	)

if not ESPFolder then

	ESPFolder =
		Instance.new("Folder")

	ESPFolder.Name =
		"XEIREN_ESP"

	ESPFolder.Parent =
		Workspace
end

local ESPObjects = {}

local function ESPColor(player)

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
		"XE_Box"

	highlight.FillTransparency =
		0.82

	highlight.OutlineTransparency =
		0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		ESPFolder

	data.Highlight =
		highlight

	--========================================================
	-- INFO
	--========================================================

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"XE_Info"

	billboard.Size =
		UDim2.fromOffset(
			150,
			65
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

	-- NAME
	local name =
		Instance.new("TextLabel")

	name.Size =
		UDim2.new(
			1,
			0,
			0,
			19
		)

	name.BackgroundTransparency =
		1

	name.Font =
		Enum.Font.GothamBold

	name.TextSize =
		12

	name.TextStrokeTransparency =
		0.3

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
			19
		)

	distance.BackgroundTransparency =
		1

	distance.Font =
		Enum.Font.Gotham

	distance.TextSize =
		10

	distance.TextStrokeTransparency =
		0.3

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
			36
		)

	hp.BackgroundTransparency =
		1

	hp.Font =
		Enum.Font.GothamBold

	hp.TextSize =
		10

	hp.TextStrokeTransparency =
		0.3

	hp.Parent =
		frame

	data.HP =
		hp

	--========================================================
	-- SCREEN TRACER
	--========================================================

	local line =
		Instance.new("Frame")

	line.Name =
		"XE_TracerLine"

	line.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)

	line.BackgroundColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	line.BorderSizePixel =
		0

	line.Visible =
		false

	line.Parent =
		ScreenGui

	data.Line =
		line

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

--============================================================
-- TRACER DRAW
--============================================================

local function DrawLine(
	line,
	from,
	to
)

	local difference =
		to - from

	local length =
		difference.Magnitude

	line.Position =
		UDim2.fromOffset(
			(
				from.X +
				to.X
			) / 2,

			(
				from.Y +
				to.Y
			) / 2
		)

	line.Size =
		UDim2.fromOffset(
			2,
			length
		)

	line.Rotation =
		math.deg(
			math.atan2(
				difference.Y,
				difference.X
			)
		) + 90

	line.Visible =
		true
end

--============================================================
-- ESP UPDATE
--============================================================

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

			if data.Line then
				data.Line.Visible =
					false
			end
		end

		return
	end

	local viewport =
		Camera.ViewportSize

	local lineStart =
		Vector2.new(
			viewport.X / 2,
			viewport.Y
		)

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

			if IsEnemy(player)
				and char
				and hum
				and root then

				local distance =
					GetDistance(player)

				if distance <=
					Settings.ESPDistance then

					local color =
						ESPColor(player)

					-- BOX
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
								hum.Health
							)
							..
							" / "
							..
							math.floor(
								hum.MaxHealth
							)

						data.HP.TextColor3 =
							color
					end

					-- SCREEN LINE
					if Settings.ESPLine
						and data.Line then

						local screen,
							visible =
							Camera:WorldToViewportPoint(
								root.Position
							)

						if visible
							and screen.Z > 0 then

							local target =
								Vector2.new(
									screen.X,
									screen.Y
								)

							data.Line.BackgroundColor3 =
								color

							DrawLine(
								data.Line,
								lineStart,
								target
							)

						else

							data.Line.Visible =
								false
						end

					elseif data.Line then

						data.Line.Visible =
							false
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

					if data.Line then
						data.Line.Visible =
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

				if data.Line then
					data.Line.Visible =
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

		FlyVelocity.VectorVelocity =
			Vector3.zero

		FlyVelocity:Destroy()

		FlyVelocity = nil
	end

	if FlyAttachment then

		FlyAttachment:Destroy()

		FlyAttachment = nil
	end

	if Humanoid then

		Humanoid.PlatformStand =
			false
	end
end

local function StartFly()

	if not Root
		or not Humanoid then

		return
	end

	StopFly()

	Settings.FlyEnabled =
		true

	-- Stop normal humanoid physics
	Humanoid.PlatformStand =
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
		or not FlyVelocity
		or not Humanoid then

		return
	end

	local cameraCF =
		Camera.CFrame

	local direction =
		Vector3.zero

	-- PC
	if UserInputService:IsKeyDown(
		Enum.KeyCode.W
	) then

		direction +=
			cameraCF.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.S
	) then

		direction -=
			cameraCF.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.A
	) then

		direction -=
			cameraCF.RightVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.D
	) then

		direction +=
			cameraCF.RightVector
	end

	-- remove camera vertical angle
	local horizontal =
		Vector3.new(
			direction.X,
			0,
			direction.Z
		)

	if horizontal.Magnitude > 1 then

		horizontal =
			horizontal.Unit
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
		horizontal *
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

local function EnableSpeed()

	if not Humanoid then
		return
	end

	Settings.SpeedEnabled =
		true

	Humanoid.WalkSpeed =
		Settings.SpeedRun
end

local function DisableSpeed()

	if not Humanoid then
		return
	end

	Settings.SpeedEnabled =
		false

	Humanoid.WalkSpeed =
		OriginalWalkSpeed
end

local function ToggleSpeed()

	if Settings.SpeedEnabled then

		DisableSpeed()

	else

		EnableSpeed()
	end
end

--============================================================
-- GUI
--============================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"XEIREN_HUB"

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

local Password =
	Instance.new("Frame")

Password.Size =
	UDim2.fromOffset(
		300,
		180
	)

Password.Position =
	UDim2.new(
		0.5,
		-150,
		0.5,
		-90
	)

Password.BackgroundColor3 =
	Color3.fromRGB(
		13,
		14,
		18
	)

Password.BorderSizePixel =
	0

Password.Parent =
	ScreenGui

local PC =
	Instance.new("UICorner")

PC.CornerRadius =
	UDim.new(
		0,
		15
	)

PC.Parent =
	Password

local PT =
	Instance.new("TextLabel")

PT.Size =
	UDim2.new(
		1,
		-20,
		0,
		35
	)

PT.Position =
	UDim2.fromOffset(
		10,
		12
	)

PT.BackgroundTransparency =
	1

PT.Text =
	"XEIREN"

PT.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PT.Font =
	Enum.Font.GothamBlack

PT.TextSize =
	24

PT.Parent =
	Password

local PB =
	Instance.new("TextBox")

PB.Size =
	UDim2.new(
		1,
		-30,
		0,
		40
	)

PB.Position =
	UDim2.fromOffset(
		15,
		55
	)

PB.BackgroundColor3 =
	Color3.fromRGB(
		25,
		26,
		32
	)

PB.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PB.PlaceholderText =
	"Password"

PB.Text =
	""

PB.ClearTextOnFocus =
	false

PB.Font =
	Enum.Font.Gotham

PB.TextSize =
	13

PB.Parent =
	Password

local PBU =
	Instance.new("TextButton")

PBU.Size =
	UDim2.new(
		1,
		-30,
		0,
		40
	)

PBU.Position =
	UDim2.fromOffset(
		15,
		105
	)

PBU.BackgroundColor3 =
	Color3.fromRGB(
		40,
		42,
		50
	)

PBU.Text =
	"UNLOCK"

PBU.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

PBU.Font =
	Enum.Font.GothamBold

PBU.TextSize =
	12

PBU.Parent =
	Password

local Status =
	Instance.new("TextLabel")

Status.Size =
	UDim2.new(
		1,
		-20,
		0,
		20
	)

Status.Position =
	UDim2.fromOffset(
		10,
		150
	)

Status.BackgroundTransparency =
	1

Status.Text =
	""

Status.TextColor3 =
	Color3.fromRGB(
		255,
		80,
		80
	)

Status.Font =
	Enum.Font.Gotham

Status.TextSize =
	10

Status.Parent =
	Password

--============================================================
-- MAIN
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
		11,
		12,
		16
	)

Main.BorderSizePixel =
	0

Main.Visible =
	false

Main.Parent =
	ScreenGui

local MC =
	Instance.new("UICorner")

MC.CornerRadius =
	UDim.new(
		0,
		16
	)

MC.Parent =
	Main

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
		20,
		21,
		27
	)

Header.BorderSizePixel =
	0

Header.Parent =
	Main

local HC =
	Instance.new("UICorner")

HC.CornerRadius =
	UDim.new(
		0,
		16
	)

HC.Parent =
	Header

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.new(
		1,
		-60,
		0,
		30
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

local Subtitle =
	Instance.new("TextLabel")

Subtitle.Size =
	UDim2.new(
		1,
		-60,
		0,
		16
	)

Subtitle.Position =
	UDim2.fromOffset(
		15,
		32
	)

Subtitle.BackgroundTransparency =
	1

Subtitle.Text =
	"5V5 • MAX PERFORMANCE"

Subtitle.TextColor3 =
	Color3.fromRGB(
		125,
		130,
		140
	)

Subtitle.Font =
	Enum.Font.Gotham

Subtitle.TextSize =
	9

Subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

Subtitle.Parent =
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
		-40,
		0,
		12
	)

Close.BackgroundColor3 =
	Color3.fromRGB(
		32,
		33,
		40
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
	19

Close.Parent =
	Header

Close.Activated:Connect(
	function()

		Main.Visible =
			false
	end
)

--============================================================
-- MENU DRAG
--============================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = true

			dragStart =
				input.Position

			startPos =
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
					startPos.X.Scale,
					startPos.X.Offset
						+ delta.X,

					startPos.Y.Scale,
					startPos.Y.Offset
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
-- SCROLL
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
		1350
	)

Scroll.Parent =
	Main

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
-- UI
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
			125,
			130,
			140
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

local function Toggle(text, key)

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
			8
		)

	corner.Parent =
		button

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

	button.Activated:Connect(
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

				if Settings.SpeedEnabled then
					EnableSpeed()
				else
					DisableSpeed()
				end
			end

			if key ==
				"FPSBoost" then

				if Settings.FPSBoost then
					SetFPSBoost(true)
				else
					SetFPSBoost(false)
				end
			end
		end
	)

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
			43
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
			8
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
			0
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
			12
		)

	bar.Position =
		UDim2.fromOffset(
			10,
			26
		)

	bar.BackgroundColor3 =
		Color3.fromRGB(
			40,
			41,
			49
		)

	bar.Text =
		""

	bar.AutoButtonColor =
		false

	bar.Parent =
		holder

	local bc =
		Instance.new("UICorner")

	bc.CornerRadius =
		UDim.new(
			1,
			0
		)

	bc.Parent =
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

	local function SetValue(x)

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

				SetValue(
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

				SetValue(
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
-- PERFORMANCE
--============================================================

Section("⚡ PERFORMANCE")

Toggle(
	"MAX FPS",
	"FPSBoost"
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
	Instance.new("TextButton")

TargetButton.Size =
	UDim2.new(
		1,
		-10,
		0,
		31
	)

TargetButton.BackgroundColor3 =
	Color3.fromRGB(
		23,
		24,
		30
	)

TargetButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

TargetButton.Text =
	"Target : "
	.. Settings.AimPart

TargetButton.Font =
	Enum.Font.Gotham

TargetButton.TextSize =
	11

TargetButton.Parent =
	Scroll

TargetButton.Activated:Connect(
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
	"ESP Line",
	"ESPLine"
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
	"Always On Top",
	"ESPAlwaysOnTop"
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
-- CONTROLS
--============================================================

Section("CONTROLS")

local ControlLabel =
	Instance.new("TextLabel")

ControlLabel.Size =
	UDim2.new(
		1,
		-10,
		0,
		45
	)

ControlLabel.BackgroundTransparency =
	1

ControlLabel.Text =
	"R = Fly     V = Speed\n"
	..
	"XE button = Open / Close"

ControlLabel.TextColor3 =
	Color3.fromRGB(
		125,
		130,
		140
	)

ControlLabel.Font =
	Enum.Font.Gotham

ControlLabel.TextSize =
	10

ControlLabel.TextXAlignment =
	Enum.TextXAlignment.Left

ControlLabel.Parent =
	Scroll

--============================================================
-- DEVICE INFO
--============================================================

local Info =
	Instance.new("TextLabel")

Info.Size =
	UDim2.new(
		1,
		-10,
		0,
		35
	)

Info.BackgroundTransparency =
	1

Info.Text =
	"Device : "
	.. DeviceType

Info.TextColor3 =
	Color3.fromRGB(
		110,
		115,
		125
	)

Info.Font =
	Enum.Font.Gotham

Info.TextSize =
	9

Info.TextXAlignment =
	Enum.TextXAlignment.Left

Info.Parent =
	Scroll

--============================================================
-- XE BUTTON
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

local LC =
	Instance.new("UICorner")

LC.CornerRadius =
	UDim.new(
		1,
		0
	)

LC.Parent =
	Logo

local LS =
	Instance.new("UIStroke")

LS.Thickness =
	1.5

LS.Transparency =
	0.35

LS.Parent =
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

	if PB.Text ==
		"anakin" then

		Password.Visible =
			false

		Main.Visible =
			true

	else

		Status.Text =
			"Incorrect password"
	end
end

PBU.Activated:Connect(
	Unlock
)

PB.FocusLost:Connect(
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
-- FPS STORAGE
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
		or object:IsA("Beam")
		or object:IsA("PostEffect") then

		OriginalVisuals[object] =
			{
				Enabled =
					object.Enabled
			}
	end
end

local function SaveVisuals()

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

local function DisableEffects()

	Lighting.GlobalShadows =
		false

	for _, object in ipairs(
		Lighting:GetDescendants()
	) do

		if object:IsA("PostEffect") then
			object.Enabled =
				false
		end
	end

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

local function RestoreEffects()

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

	Lighting.GlobalShadows =
		true
end

function SetFPSBoost(enabled)

	Settings.FPSBoost =
		enabled

	if enabled then

		SaveVisuals()

		DisableEffects()

	else

		RestoreEffects()
	end
end

--============================================================
-- AUTO EFFECT DISABLE
--============================================================

Workspace.DescendantAdded:Connect(
	function(object)

		if not Settings.FPSBoost then
			return
		end

		task.defer(
			function()

				if not object.Parent then
					return
				end

				if object:IsA(
					"ParticleEmitter"
				)
					or object:IsA("Trail")
					or object:IsA("Smoke")
					or object:IsA("Fire")
					or object:IsA("Sparkles") then

					object.Enabled =
						false
				end

				if object:IsA("Beam")
					and not object.Name:find(
						"XE"
					) then

					object.Enabled =
						false
				end
			end
		)
	end
)

--============================================================
-- FPS
--============================================================

local FPS = 60
local FPSTimer = 0
local FPSFrames = 0
local DynamicTimer = 0

local FPSDisplay =
	Instance.new("TextLabel")

FPSDisplay.Size =
	UDim2.fromOffset(
		90,
		28
	)

FPSDisplay.Position =
	UDim2.new(
		1,
		-100,
		0,
		8
	)

FPSDisplay.BackgroundTransparency =
	1

FPSDisplay.Text =
	"FPS --"

FPSDisplay.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

FPSDisplay.Font =
	Enum.Font.GothamBold

FPSDisplay.TextSize =
	12

FPSDisplay.Parent =
	ScreenGui

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

	if FPS < 25 then

		Settings.ESPUpdateRate =
			3

		Settings.ESPLine =
			false

		DisableEffects()

	elseif FPS < 40 then

		Settings.ESPUpdateRate =
			5

		DisableEffects()

	elseif FPS < 55 then

		Settings.ESPUpdateRate =
			7

	else

		Settings.ESPUpdateRate =
			10
	end
end

--============================================================
-- PLAYER CLEANUP
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
-- INITIAL
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

		-- IMPORTANT:
		-- Do NOT continuously overwrite WalkSpeed.
		-- This fixes Speed OFF.

		DynamicOptimize(dt)

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

		FPSDisplay.Visible =
			Settings.ShowFPS

		if Settings.ShowFPS then

			FPSDisplay.Text =
				"FPS "
				.. tostring(FPS)
		end

		Info.Text =
			"Device : "
			.. DeviceType
			.. "\nFPS : "
			.. tostring(FPS)

	end
)

--============================================================
-- END
--============================================================
