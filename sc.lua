--// Xeiren 5v5 Combat Hub
--// Roblox Studio LocalScript
--// Password: anakin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    -- AIM
    AimEnabled = false,
    Full360 = true,
    LockStrength = 100,
    AimSpeed = 25,
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
    ESPUseTeamCheck = true,

    -- TRACERS
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

    -- MENU
    MenuVisible = true
}

--==================================================
-- STATE
--==================================================

local Character
local Humanoid
local RootPart

local OriginalWalkSpeed = 16
local OriginalAutoRotate = true

local FlyAttachment
local FlyVelocity

local ESPObjects = {}
local TracerObjects = {}

local Connections = {}

--==================================================
-- UTILS
--==================================================

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)
end

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

    return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    local root = GetRoot(character)

    return character
        and humanoid
        and root
        and humanoid.Health > 0
end

local function IsEnemy(player)
    if not player or player == LocalPlayer then
        return false
    end

    if Settings.TeamCheck then
        if player.Team ~= nil and LocalPlayer.Team ~= nil then
            if player.Team == LocalPlayer.Team then
                return false
            end
        end
    end

    return true
end

local function GetDistanceFromLocal(player)
    if not IsAlive(player) or not RootPart then
        return math.huge
    end

    local root = GetRoot(player.Character)

    return (root.Position - RootPart.Position).Magnitude
end

--==================================================
-- CHARACTER
--==================================================

local function SetupCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid", 10)
    RootPart = character:WaitForChild("HumanoidRootPart", 10)

    if Humanoid then
        OriginalWalkSpeed = Humanoid.WalkSpeed
        OriginalAutoRotate = Humanoid.AutoRotate
    end

    if Settings.FlyEnabled then
        Settings.FlyEnabled = false
    end
end

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    SetupCharacter(character)
end))

--==================================================
-- VISIBILITY / WALL CHECK
--==================================================

local function IsVisible(targetPart)
    if not targetPart or not Camera then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        Character
    }
    params.IgnoreWater = true

    local result = Workspace:Raycast(
        origin,
        direction,
        params
    )

    if not result then
        return true
    end

    if result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end

    return false
end

--==================================================
-- AIM PART
--==================================================

local function GetAimPart(character)
    if not character then
        return nil
    end

    if Settings.AimPart == "Body" then
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    end

    return character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- TARGET FINDER
--==================================================

local function FindAimTarget()
    if not RootPart or not Camera then
        return nil
    end

    local bestPlayer = nil
    local bestScore = math.huge

    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(
        viewportSize.X / 2,
        viewportSize.Y / 2
    )

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and IsAlive(player) then

            local character = player.Character
            local targetPart = GetAimPart(character)
            local targetRoot = GetRoot(character)

            if targetPart and targetRoot then

                local distance = (
                    targetRoot.Position -
                    RootPart.Position
                ).Magnitude

                if distance <= Settings.AimDistance then

                    local allowed = true

                    if Settings.WallCheck then
                        allowed = IsVisible(targetPart)
                    end

                    if allowed then

                        --======================================
                        -- 360 MODE
                        --======================================

                        if Settings.Full360 then

                            -- Full 360:
                            -- choose nearest valid target.
                            local score = distance

                            if score < bestScore then
                                bestScore = score
                                bestPlayer = player
                            end

                        else

                            --==================================
                            -- NORMAL FOV MODE
                            --==================================

                            local screenPosition, onScreen =
                                Camera:WorldToViewportPoint(
                                    targetPart.Position
                                )

                            if onScreen and screenPosition.Z > 0 then

                                local screenDistance =
                                    (
                                        Vector2.new(
                                            screenPosition.X,
                                            screenPosition.Y
                                        ) -
                                        screenCenter
                                    ).Magnitude

                                if screenDistance <= Settings.AimFOV then

                                    local score =
                                        screenDistance +
                                        distance * 0.01

                                    if score < bestScore then
                                        bestScore = score
                                        bestPlayer = player
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

--==================================================
-- AIM ASSIST
--==================================================

local CurrentTarget = nil

local function UpdateAim(dt)
    if not Settings.AimEnabled then
        CurrentTarget = nil
        return
    end

    if not Camera or not RootPart then
        return
    end

    CurrentTarget = FindAimTarget()

    if not CurrentTarget then
        return
    end

    local character = CurrentTarget.Character
    local targetPart = GetAimPart(character)

    if not targetPart then
        return
    end

    local cameraPosition = Camera.CFrame.Position
    local targetPosition = targetPart.Position

    local targetCFrame = CFrame.lookAt(
        cameraPosition,
        targetPosition
    )

    -- Strong Lock:
    -- 1 = very smooth
    -- 100 = extremely strong
    local strength =
        math.clamp(Settings.LockStrength, 1, 100)

    local speed =
        math.max(Settings.AimSpeed, 1)

    local alpha =
        1 - math.exp(
            -(speed * (strength / 100)) * dt
        )

    alpha = math.clamp(alpha, 0.01, 1)

    Camera.CFrame =
        Camera.CFrame:Lerp(
            targetCFrame,
            alpha
        )
end

--==================================================
-- ESP GUI
--==================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "XeirenESP"
ESPFolder.Parent = PlayerGui

local function CreateESP(player)

    if ESPObjects[player] then
        return ESPObjects[player]
    end

    local objects = {}

    --==============================================
    -- HIGHLIGHT / BOX
    --==============================================

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Enabled = false
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency = 0.80
    highlight.OutlineTransparency = 0

    highlight.Parent = ESPFolder

    objects.Highlight = highlight

    --==============================================
    -- BILLBOARD
    --==============================================

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Info"
    billboard.Size = UDim2.fromOffset(220, 75)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.MaxDistance = Settings.ESPDistance

    billboard.Parent = ESPFolder

    objects.Billboard = billboard

    --==============================================
    -- NAME
    --==============================================

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0, 22)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0.25
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    objects.NameLabel = nameLabel

    --==============================================
    -- DISTANCE
    --==============================================

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.Position = UDim2.new(0, 0, 0, 22)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.Parent = billboard

    objects.DistanceLabel = distanceLabel

    --==============================================
    -- HEALTH BACKGROUND
    --==============================================

    local healthBack = Instance.new("Frame")
    healthBack.Name = "HealthBackground"
    healthBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBack.BorderSizePixel = 0
    healthBack.Size = UDim2.new(0.75, 0, 0, 8)
    healthBack.Position = UDim2.new(0.125, 0, 0, 43)
    healthBack.Parent = billboard

    objects.HealthBack = healthBack

    --==============================================
    -- HEALTH BAR
    --==============================================

    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    healthBar.BorderSizePixel = 0
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Parent = healthBack

    objects.HealthBar = healthBar

    --==============================================
    -- HEALTH TEXT
    --==============================================

    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.BackgroundTransparency = 1
    healthText.Size = UDim2.new(1, 0, 0, 18)
    healthText.Position = UDim2.new(0, 0, 0, 51)
    healthText.Font = Enum.Font.GothamBold
    healthText.TextSize = 11
    healthText.TextStrokeTransparency = 0.3
    healthText.TextColor3 = Color3.new(1, 1, 1)
    healthText.Parent = billboard

    objects.HealthText = healthText

    ESPObjects[player] = objects

    return objects
end

--==================================================
-- TRACER
--==================================================

local function CreateTracer(player)

    if TracerObjects[player] then
        return TracerObjects[player]
    end

    local data = {}

    local startPart = Instance.new("Part")
    startPart.Name = "TracerStart"
    startPart.Anchored = true
    startPart.CanCollide = false
    startPart.CanQuery = false
    startPart.CanTouch = false
    startPart.Transparency = 1
    startPart.Size = Vector3.new(0.1, 0.1, 0.1)
    startPart.Parent = ESPFolder

    local startAttachment = Instance.new("Attachment")
    startAttachment.Parent = startPart

    local endAttachment = Instance.new("Attachment")

    local beam = Instance.new("Beam")
    beam.Name = "ESP_Tracer"
    beam.Attachment0 = startAttachment
    beam.Attachment1 = endAttachment

    beam.FaceCamera = true
    beam.Width0 = 0.08
    beam.Width1 = 0.03
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(0.15)
    beam.Enabled = false

    beam.Parent = startPart

    data.StartPart = startPart
    data.StartAttachment = startAttachment
    data.EndAttachment = endAttachment
    data.Beam = beam

    TracerObjects[player] = data

    return data
end

--==================================================
-- UPDATE ESP
--==================================================

local function UpdateESP(player)

    if player == LocalPlayer then
        return
    end

    local objects = ESPObjects[player] or CreateESP(player)
    local tracer = TracerObjects[player] or CreateTracer(player)

    local valid =
        Settings.ESPEnabled
        and IsEnemy(player)
        and IsAlive(player)

    if not valid then

        objects.Highlight.Enabled = false
        objects.Billboard.Enabled = false
        tracer.Beam.Enabled = false

        return
    end

    local character = player.Character
    local root = GetRoot(character)
    local humanoid = GetHumanoid(character)

    if not root or not humanoid then
        return
    end

    local distance = GetDistanceFromLocal(player)

    if distance > Settings.ESPDistance then

        objects.Highlight.Enabled = false
        objects.Billboard.Enabled = false
        tracer.Beam.Enabled = false

        return
    end

    --==============================================
    -- COLOR
    --==============================================

    local color = Color3.fromRGB(255, 70, 70)

    if Settings.ESPTeamColor then
        color = player.TeamColor.Color
    end

    --==============================================
    -- HIGHLIGHT
    --==============================================

    objects.Highlight.Adornee = character
    objects.Highlight.Enabled = Settings.ESPBox
    objects.Highlight.FillColor = color
    objects.Highlight.OutlineColor = Color3.new(1, 1, 1)

    if Settings.ESPAlwaysOnTop then
        objects.Highlight.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop
    else
        objects.Highlight.DepthMode =
            Enum.HighlightDepthMode.Occluded
    end

    --==============================================
    -- BILLBOARD
    --==============================================

    objects.Billboard.Adornee = root
    objects.Billboard.MaxDistance = Settings.ESPDistance
    objects.Billboard.Enabled = true

    objects.NameLabel.Visible = Settings.ESPName
    objects.DistanceLabel.Visible = Settings.ESPDistanceText

    objects.NameLabel.Text =
        player.DisplayName ..
        "  [" ..
        player.Name ..
        "]"

    objects.NameLabel.TextColor3 = color

    objects.DistanceLabel.Text =
        string.format(
            "%.0f studs",
            distance
        )

    --==============================================
    -- HEALTH
    --==============================================

    if Settings.ESPHealth then

        objects.HealthBack.Visible = true
        objects.HealthBar.Visible = true
        objects.HealthText.Visible = true

        local maxHealth =
            math.max(humanoid.MaxHealth, 1)

        local health =
            math.clamp(
                humanoid.Health / maxHealth,
                0,
                1
            )

        objects.HealthBar.Size =
            UDim2.new(
                health,
                0,
                1,
                0
            )

        objects.HealthText.Text =
            string.format(
                "%d / %d HP",
                humanoid.Health,
                maxHealth
            )

        if health > 0.6 then
            objects.HealthBar.BackgroundColor3 =
                Color3.fromRGB(50, 255, 100)
        elseif health > 0.3 then
            objects.HealthBar.BackgroundColor3 =
                Color3.fromRGB(255, 210, 50)
        else
            objects.HealthBar.BackgroundColor3 =
                Color3.fromRGB(255, 50, 50)
        end

    else

        objects.HealthBack.Visible = false
        objects.HealthBar.Visible = false
        objects.HealthText.Visible = false

    end

    --==============================================
    -- HEAD MARKER
    --==============================================

    if Settings.ESPHead then

        local head = character:FindFirstChild("Head")

        if head then

            if not objects.HeadHighlight then

                local headHighlight =
                    Instance.new("Highlight")

                headHighlight.Name =
                    "ESP_Head"

                headHighlight.FillTransparency = 0.3
                headHighlight.OutlineTransparency = 0
                headHighlight.DepthMode =
                    Enum.HighlightDepthMode.AlwaysOnTop

                headHighlight.Parent =
                    ESPFolder

                objects.HeadHighlight =
                    headHighlight
            end

            objects.HeadHighlight.Adornee = head
            objects.HeadHighlight.FillColor = color
            objects.HeadHighlight.OutlineColor =
                Color3.new(1, 1, 1)

            objects.HeadHighlight.Enabled = true

        end

    elseif objects.HeadHighlight then

        objects.HeadHighlight.Enabled = false

    end

    --==============================================
    -- TRACER
    --==============================================

    if Settings.TracerEnabled then

        local startPosition =
            Camera.CFrame.Position

        tracer.StartPart.Position =
            startPosition

        tracer.EndAttachment.Parent =
            root

        tracer.Beam.Color =
            ColorSequence.new(color)

        tracer.Beam.Enabled = true

    else

        tracer.Beam.Enabled = false

    end
end

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(player)

    local objects = ESPObjects[player]

    if objects then

        for _, object in pairs(objects) do

            if typeof(object) == "Instance" then
                pcall(function()
                    object:Destroy()
                end)
            end
        end

        ESPObjects[player] = nil
    end

    local tracer = TracerObjects[player]

    if tracer then

        if tracer.StartPart then
            tracer.StartPart:Destroy()
        end

        TracerObjects[player] = nil
    end
end

table.insert(
    Connections,
    Players.PlayerRemoving:Connect(RemoveESP)
)

--==================================================
-- FLY
--==================================================

local function StopFly()

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
        Humanoid.AutoRotate =
            OriginalAutoRotate
    end
end

local function StartFly()

    if not RootPart or not Humanoid then
        return
    end

    StopFly()

    Settings.FlyEnabled = true

    OriginalAutoRotate =
        Humanoid.AutoRotate

    Humanoid.AutoRotate = false

    FlyAttachment =
        Instance.new("Attachment")

    FlyAttachment.Name =
        "XeirenFlyAttachment"

    FlyAttachment.Parent =
        RootPart

    FlyVelocity =
        Instance.new("LinearVelocity")

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

    if not RootPart or not Humanoid then
        StopFly()
        return
    end

    if not FlyVelocity then
        StartFly()
        return
    end

    local direction =
        Vector3.zero

    local cameraCFrame =
        Camera.CFrame

    -- Horizontal forward direction
    local forward =
        Vector3.new(
            cameraCFrame.LookVector.X,
            0,
            cameraCFrame.LookVector.Z
        )

    local right =
        Vector3.new(
            cameraCFrame.RightVector.X,
            0,
            cameraCFrame.RightVector.Z
        )

    if forward.Magnitude > 0 then
        forward = forward.Unit
    end

    if right.Magnitude > 0 then
        right = right.Unit
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.W
    ) then
        direction += forward
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.S
    ) then
        direction -= forward
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.D
    ) then
        direction += right
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.A
    ) then
        direction -= right
    end

    local horizontal = Vector3.zero

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

--==================================================
-- SPEED RUN
--==================================================

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

--==================================================
-- GUI
--==================================================

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

ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- COLORS
--==================================================

local BG =
    Color3.fromRGB(13, 13, 18)

local PANEL =
    Color3.fromRGB(20, 20, 27)

local PANEL2 =
    Color3.fromRGB(27, 27, 36)

local ACCENT =
    Color3.fromRGB(120, 70, 255)

local TEXT =
    Color3.fromRGB(245, 245, 250)

local SUBTEXT =
    Color3.fromRGB(165, 165, 180)

local GREEN =
    Color3.fromRGB(70, 220, 120)

local RED =
    Color3.fromRGB(255, 70, 90)

--==================================================
-- UI HELPERS
--==================================================

local function AddCorner(object, radius)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, radius or 8)

    corner.Parent = object
end

local function AddStroke(object)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(55, 55, 70)

    stroke.Transparency = 0.3
    stroke.Thickness = 1

    stroke.Parent = object
end

local function CreateLabel(parent, text, size)

    local label =
        Instance.new("TextLabel")

    label.BackgroundTransparency = 1

    label.Size =
        UDim2.new(
            1,
            -20,
            0,
            size or 25
        )

    label.Text =
        text

    label.Font =
        Enum.Font.GothamMedium

    label.TextSize = 13

    label.TextColor3 =
        TEXT

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        parent

    return label
end

local function CreateButton(
    parent,
    text,
    callback
)

    local button =
        Instance.new("TextButton")

    button.AutoButtonColor = false

    button.BackgroundColor3 =
        PANEL2

    button.Size =
        UDim2.new(
            1,
            0,
            0,
            38
        )

    button.Text =
        text

    button.Font =
        Enum.Font.GothamMedium

    button.TextSize = 13

    button.TextColor3 =
        TEXT

    button.Parent =
        parent

    AddCorner(button, 8)

    AddStroke(button)

    button.Activated:Connect(function()

        callback(button)

    end)

    return button
end

local function CreateToggle(
    parent,
    title,
    getter,
    setter
)

    local button =
        CreateButton(
            parent,
            "",
            function(button)

                setter(
                    not getter()
                )

                local state =
                    getter()

                button.Text =
                    title ..
                    ": " ..
                    (
                        state
                        and "ON"
                        or "OFF"
                    )

                button.BackgroundColor3 =
                    state
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
        ": " ..
        (
            getter()
            and "ON"
            or "OFF"
        )

    if getter() then
        button.BackgroundColor3 =
            Color3.fromRGB(
                55,
                35,
                100
            )
    end

    return button
end

local function CreateNumberInput(
    parent,
    title,
    getter,
    setter
)

    local frame =
        Instance.new("Frame")

    frame.Size =
        UDim2.new(
            1,
            0,
            0,
            48
        )

    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label =
        Instance.new("TextLabel")

    label.BackgroundTransparency = 1

    label.Size =
        UDim2.new(
            0.52,
            0,
            1,
            0
        )

    label.Text =
        title

    label.Font =
        Enum.Font.GothamMedium

    label.TextSize = 13

    label.TextColor3 =
        TEXT

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        frame

    local box =
        Instance.new("TextBox")

    box.BackgroundColor3 =
        PANEL2

    box.Size =
        UDim2.new(
            0.48,
            0,
            0,
            36
        )

    box.Position =
        UDim2.new(
            0.52,
            0,
            0.5,
            -18
        )

    box.Text =
        tostring(getter())

    box.ClearTextOnFocus = false

    box.Font =
        Enum.Font.GothamMedium

    box.TextSize = 13

    box.TextColor3 =
        TEXT

    box.Parent =
        frame

    AddCorner(box, 7)
    AddStroke(box)

    box.FocusLost:Connect(function()

        local number =
            tonumber(box.Text)

        if number then
            setter(number)
            box.Text =
                tostring(getter())
        else
            box.Text =
                tostring(getter())
        end
    end)

    return frame
end

--==================================================
-- PASSWORD SCREEN
--==================================================

local PasswordFrame =
    Instance.new("Frame")

PasswordFrame.Size =
    UDim2.fromOffset(360, 230)

PasswordFrame.Position =
    UDim2.new(
        0.5,
        -180,
        0.5,
        -115
    )

PasswordFrame.BackgroundColor3 =
    BG

PasswordFrame.Parent =
    ScreenGui

AddCorner(
    PasswordFrame,
    14
)

AddStroke(
    PasswordFrame
)

local PasswordTitle =
    CreateLabel(
        PasswordFrame,
        "XEIREN 5V5",
        35
    )

PasswordTitle.Position =
    UDim2.fromOffset(
        20,
        20
    )

PasswordTitle.Size =
    UDim2.new(
        1,
        -40,
        0,
        30
    )

PasswordTitle.TextSize = 21

local PasswordSub =
    CreateLabel(
        PasswordFrame,
        "Enter password to continue",
        25
    )

PasswordSub.Position =
    UDim2.fromOffset(
        20,
        58
    )

PasswordSub.TextColor3 =
    SUBTEXT

local PasswordBox =
    Instance.new("TextBox")

PasswordBox.Size =
    UDim2.new(
        1,
        -40,
        0,
        42
    )

PasswordBox.Position =
    UDim2.fromOffset(
        20,
        95
    )

PasswordBox.BackgroundColor3 =
    PANEL2

PasswordBox.PlaceholderText =
    "Password"

PasswordBox.ClearTextOnFocus =
    false

PasswordBox.Text =
    ""

PasswordBox.TextColor3 =
    TEXT

PasswordBox.PlaceholderColor3 =
    SUBTEXT

PasswordBox.Font =
    Enum.Font.Gotham

PasswordBox.TextSize = 14

PasswordBox.Parent =
    PasswordFrame

AddCorner(
    PasswordBox,
    8
)

AddStroke(
    PasswordBox
)

local LoginButton =
    Instance.new("TextButton")

LoginButton.Size =
    UDim2.new(
        1,
        -40,
        0,
        42
    )

LoginButton.Position =
    UDim2.fromOffset(
        20,
        150
    )

LoginButton.BackgroundColor3 =
    ACCENT

LoginButton.Text =
    "UNLOCK HUB"

LoginButton.Font =
    Enum.Font.GothamBold

LoginButton.TextSize = 13

LoginButton.TextColor3 =
    Color3.new(1, 1, 1)

LoginButton.Parent =
    PasswordFrame

AddCorner(
    LoginButton,
    8
)

local ErrorLabel =
    CreateLabel(
        PasswordFrame,
        "",
        22
    )

ErrorLabel.Position =
    UDim2.fromOffset(
        20,
        198
    )

ErrorLabel.TextColor3 =
    RED

--==================================================
-- MAIN HUB
--==================================================

local MainFrame

local function BuildHub()

    PasswordFrame.Visible = false

    MainFrame =
        Instance.new("Frame")

    MainFrame.Name =
        "MainHub"

    MainFrame.Size =
        UDim2.fromOffset(
            430,
            560
        )

    MainFrame.Position =
        UDim2.new(
            0.5,
            -215,
            0.5,
            -280
        )

    MainFrame.BackgroundColor3 =
        BG

    MainFrame.Parent =
        ScreenGui

    AddCorner(
        MainFrame,
        14
    )

    AddStroke(
        MainFrame
    )

    --==============================================
    -- TITLE BAR
    --==============================================

    local TitleBar =
        Instance.new("Frame")

    TitleBar.Size =
        UDim2.new(
            1,
            0,
            0,
            52
        )

    TitleBar.BackgroundColor3 =
        PANEL

    TitleBar.Parent =
        MainFrame

    AddCorner(
        TitleBar,
        14
    )

    local Title =
        CreateLabel(
            TitleBar,
            "XEIREN • 5V5",
            40
        )

    Title.Position =
        UDim2.fromOffset(
            16,
            6
        )

    Title.Size =
        UDim2.new(
            1,
            -80,
            0,
            40
        )

    Title.Font =
        Enum.Font.GothamBold

    Title.TextSize = 16

    local Close =
        Instance.new("TextButton")

    Close.Size =
        UDim2.fromOffset(
            40,
            36
        )

    Close.Position =
        UDim2.new(
            1,
            -46,
            0,
            8
        )

    Close.BackgroundColor3 =
        Color3.fromRGB(
            45,
            35,
            55
        )

    Close.Text =
        "×"

    Close.Font =
        Enum.Font.GothamBold

    Close.TextSize = 22

    Close.TextColor3 =
        TEXT

    Close.Parent =
        TitleBar

    AddCorner(
        Close,
        8
    )

    Close.Activated:Connect(function()

        MainFrame.Visible =
            false

        ReopenButton.Visible =
            true

    end)

    --==============================================
    -- DRAG
    --==============================================

    local dragging = false
    local dragStart
    local startPosition

    TitleBar.InputBegan:Connect(function(input)

        if input.UserInputType ==
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

            input.Changed:Connect(function()

                if input.UserInputState ==
                    Enum.UserInputState.End
                then
                    dragging = false
                end

            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ==
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
    end)

    --==============================================
    -- SCROLL
    --==============================================

    local Scroll =
        Instance.new("ScrollingFrame")

    Scroll.Size =
        UDim2.new(
            1,
            -24,
            1,
            -68
        )

    Scroll.Position =
        UDim2.fromOffset(
            12,
            58
        )

    Scroll.BackgroundTransparency =
        1

    Scroll.BorderSizePixel = 0

    Scroll.ScrollBarThickness = 4

    Scroll.ScrollBarImageColor3 =
        ACCENT

    Scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    Scroll.CanvasSize =
        UDim2.new()

    Scroll.Parent =
        MainFrame

    local Layout =
        Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(
            0,
            7
        )

    Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    Layout.Parent =
        Scroll

    --==============================================
    -- AIM SECTION
    --==============================================

    local AimTitle =
        CreateLabel(
            Scroll,
            "🎯 AIM ASSIST",
            30
        )

    AimTitle.TextColor3 =
        ACCENT

    CreateToggle(
        Scroll,
        "Aim Assist",
        function()
            return Settings.AimEnabled
        end,
        function(value)
            Settings.AimEnabled = value
        end
    )

    CreateToggle(
        Scroll,
        "360° Lock",
        function()
            return Settings.Full360
        end,
        function(value)
            Settings.Full360 = value
        end
    )

    CreateNumberInput(
        Scroll,
        "Lock Strength 1-100",
        function()
            return Settings.LockStrength
        end,
        function(value)
            Settings.LockStrength =
                math.clamp(
                    value,
                    1,
                    100
                )
        end
    )

    CreateNumberInput(
        Scroll,
        "Aim Speed",
        function()
            return Settings.AimSpeed
        end,
        function(value)
            Settings.AimSpeed =
                math.clamp(
                    value,
                    1,
                    200
                )
        end
    )

    CreateNumberInput(
        Scroll,
        "Aim Distance",
        function()
            return Settings.AimDistance
        end,
        function(value)
            Settings.AimDistance =
                math.clamp(
                    value,
                    10,
                    5000
                )
        end
    )

    CreateNumberInput(
        Scroll,
        "FOV",
        function()
            return Settings.AimFOV
        end,
        function(value)
            Settings.AimFOV =
                math.clamp(
                    value,
                    10,
                    1000
                )
        end
    )

    local TargetButton =
        CreateButton(
            Scroll,
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

    --==============================================
    -- ESP SECTION
    --==============================================

    local ESPTitle =
        CreateLabel(
            Scroll,
            "👁 ESP",
            30
        )

    ESPTitle.TextColor3 =
        ACCENT

    CreateToggle(
        Scroll,
        "Strong ESP",
        function()
            return Settings.ESPEnabled
        end,
        function(value)
            Settings.ESPEnabled =
                value
        end
    )

    CreateToggle(
        Scroll,
        "ESP Box",
        function()
            return Settings.ESPBox
        end,
        function(value)
            Settings.ESPBox =
                value
        end
    )

    CreateToggle(
        Scroll,
        "ESP Name",
        function()
            return Settings.ESPName
        end,
        function(value)
            Settings.ESPName =
                value
        end
    )

    CreateToggle(
        Scroll,
        "ESP Health",
        function()
            return Settings.ESPHealth
        end,
        function(value)
            Settings.ESPHealth =
                value
        end
    )

    CreateToggle(
        Scroll,
        "ESP Distance",
        function()
            return Settings.ESPDistanceText
        end,
        function(value)
            Settings.ESPDistanceText =
                value
        end
    )

    CreateToggle(
        Scroll,
        "Head Marker",
        function()
            return Settings.ESPHead
        end,
        function(value)
            Settings.ESPHead =
                value
        end
    )

    CreateToggle(
        Scroll,
        "Always On Top",
        function()
            return Settings.ESPAlwaysOnTop
        end,
        function(value)
            Settings.ESPAlwaysOnTop =
                value
        end
    )

    CreateToggle(
        Scroll,
        "Team Color",
        function()
            return Settings.ESPTeamColor
        end,
        function(value)
            Settings.ESPTeamColor =
                value
        end
    )

    CreateNumberInput(
        Scroll,
        "ESP Distance",
        function()
            return Settings.ESPDistance
        end,
        function(value)

            Settings.ESPDistance =
                math.clamp(
                    value,
                    50,
                    5000
                )
        end
    )

    CreateToggle(
        Scroll,
        "Tracers",
        function()
            return Settings.TracerEnabled
        end,
        function(value)
            Settings.TracerEnabled =
                value
        end
    )

    --==============================================
    -- CHECKS
    --==============================================

    local CheckTitle =
        CreateLabel(
            Scroll,
            "⚙ CHECKS",
            30
        )

    CheckTitle.TextColor3 =
        ACCENT

    CreateToggle(
        Scroll,
        "Team Check",
        function()
            return Settings.TeamCheck
        end,
        function(value)
            Settings.TeamCheck =
                value
        end
    )

    CreateToggle(
        Scroll,
        "Wall Check",
        function()
            return Settings.WallCheck
        end,
        function(value)
            Settings.WallCheck =
                value
        end
    )

    --==============================================
    -- FLY
    --==============================================

    local FlyTitle =
        CreateLabel(
            Scroll,
            "🪽 FLY",
            30
        )

    FlyTitle.TextColor3 =
        ACCENT

    CreateToggle(
        Scroll,
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

    CreateNumberInput(
        Scroll,
        "Fly Speed",
        function()
            return Settings.FlySpeed
        end,
        function(value)
            Settings.FlySpeed =
                math.clamp(
                    value,
                    1,
                    1000
                )
        end
    )

    CreateNumberInput(
        Scroll,
        "Vertical Speed",
        function()
            return Settings.FlyVerticalSpeed
        end,
        function(value)
            Settings.FlyVerticalSpeed =
                math.clamp(
                    value,
                    1,
                    1000
                )
        end
    )

    --==============================================
    -- SPEED
    --==============================================

    local SpeedTitle =
        CreateLabel(
            Scroll,
            "⚡ MOVEMENT",
            30
        )

    SpeedTitle.TextColor3 =
        ACCENT

    CreateToggle(
        Scroll,
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
                ToggleSpeed()
            end

        end
    )

    CreateNumberInput(
        Scroll,
        "Run Speed",
        function()
            return Settings.SpeedRun
        end,
        function(value)

            Settings.SpeedRun =
                math.clamp(
                    value,
                    1,
                    300
                )

            if Settings.SpeedEnabled then
                UpdateSpeed()
            end
        end
    )

    --==============================================
    -- INFO
    --==============================================

    local Info =
        CreateLabel(
            Scroll,
            "R = Fly   |   V = Speed Run\n" ..
            "360° Lock ignores screen FOV and searches around you.",
            45
        )

    Info.TextColor3 =
        SUBTEXT

end

--==================================================
-- REOPEN BUTTON
--==================================================

ReopenButton =
    Instance.new("TextButton")

ReopenButton.Name =
    "ReopenHub"

ReopenButton.Size =
    UDim2.fromOffset(
        115,
        42
    )

ReopenButton.Position =
    UDim2.new(
        0,
        20,
        0.5,
        -21
    )

ReopenButton.BackgroundColor3 =
    ACCENT

ReopenButton.Text =
    "XEIREN HUB"

ReopenButton.Font =
    Enum.Font.GothamBold

ReopenButton.TextSize = 12

ReopenButton.TextColor3 =
    Color3.new(1, 1, 1)

ReopenButton.Visible = false

ReopenButton.Parent =
    ScreenGui

AddCorner(
    ReopenButton,
    9
)

ReopenButton.Activated:Connect(function()

    if MainFrame then
        MainFrame.Visible =
            true
    end

    ReopenButton.Visible =
        false

end)

--==================================================
-- LOGIN
--==================================================

local function AttemptLogin()

    if PasswordBox.Text ==
        "anakin"
    then

        BuildHub()

    else

        ErrorLabel.Text =
            "Wrong password"

        PasswordBox.Text = ""

        task.delay(
            2,
            function()

                if ErrorLabel then
                    ErrorLabel.Text = ""
                end

            end
        )
    end
end

LoginButton.Activated:Connect(
    AttemptLogin
)

PasswordBox.FocusLost:Connect(
    function(enterPressed)

        if enterPressed then
            AttemptLogin()
        end

    end
)

--==================================================
-- KEYBINDS
--==================================================

table.insert(
    Connections,
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
)

--==================================================
-- MAIN LOOP
--==================================================

table.insert(
    Connections,
    RunService.RenderStepped:Connect(
        function(dt)

            UpdateAim(dt)
            UpdateFly()
            UpdateSpeed()

            if Settings.ESPEnabled then

                for _, player in ipairs(
                    Players:GetPlayers()
                ) do

                    if player ~= LocalPlayer then
                        UpdateESP(player)
                    end

                end

            else

                for _, objects in pairs(
                    ESPObjects
                ) do

                    if objects.Highlight then
                        objects.Highlight.Enabled =
                            false
                    end

                    if objects.Billboard then
                        objects.Billboard.Enabled =
                            false
                    end

                end

                for _, tracer in pairs(
                    TracerObjects
                ) do

                    if tracer.Beam then
                        tracer.Beam.Enabled =
                            false
                    end

                end
            end
        end
    )
)

--==================================================
-- INITIALIZE ESP
--==================================================

for _, player in ipairs(
    Players:GetPlayers()
) do

    if player ~= LocalPlayer then
        CreateESP(player)
        CreateTracer(player)
    end

end

table.insert(
    Connections,
    Players.PlayerAdded:Connect(
        function(player)

            CreateESP(player)
            CreateTracer(player)

        end
    )
)

--==================================================
-- CLEANUP ON CHARACTER DEATH
--==================================================

table.insert(
    Connections,
    RunService.Heartbeat:Connect(
        function()

            if Humanoid then

                if Humanoid.Health <= 0 then

                    if Settings.FlyEnabled then
                        StopFly()
                    end

                end
            end
        end
    )
)

print(
    "[Xeiren] 5v5 Combat Hub loaded."
)
