--============================================================
-- XEIREN 5V5 COMBAT HUB
-- Roblox Studio LocalScript
-- Password: anakin
--
-- Features:
-- • Password protection
-- • Smooth 360° aim
-- • Head / Body target
-- • Aim distance / speed / strength / FOV
-- • Team check / wall check
-- • ESP / health / HP / distance / head marker
-- • Tracers
-- • Fly
-- • Speed run
-- • Draggable XE logo
-- • PC / iOS / Android detection
-- • Auto / Performance / Balanced / Quality
-- • FPS monitor
-- • Dynamic low-FPS optimization
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--============================================================
-- SETTINGS
--============================================================

local Settings = {

    -- AIM
    AimEnabled = false,
    Full360 = true,
    LockStrength = 75,
    AimSpeed = 28,
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

    -- PERFORMANCE
    FPSBoost = true,
    PerformanceMode = "Auto",
    ESPUpdateRate = 12,

    -- FPS
    ShowFPS = true,
    DynamicOptimization = true,
}

--============================================================
-- DEVICE DETECTION
--============================================================

local DeviceType = "PC"

if UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled then

    if UserInputService.AccelerometerEnabled
        or UserInputService.GyroscopeEnabled then

        DeviceType = "Mobile"

    else

        DeviceType = "Mobile"
    end
end

if UserInputService.TouchEnabled
    and UserInputService.KeyboardEnabled then

    DeviceType = "Mobile + Keyboard"
end

--============================================================
-- PERFORMANCE PROFILES
--============================================================

local Profiles = {

    Performance = {
        ParticleRate = 0,
        ParticleTimeScale = 0,
        TrailLifetime = 0,
        BeamEnabled = false,
        PostEffects = false,
        Shadows = false,
        GlobalShadows = false,
        Fog = false,
        MaterialQuality = Enum.QualityLevel.Level01,
    },

    Balanced = {
        ParticleRate = 0.35,
        ParticleTimeScale = 0.7,
        TrailLifetime = 0.15,
        BeamEnabled = true,
        PostEffects = false,
        Shadows = false,
        GlobalShadows = false,
        Fog = true,
        MaterialQuality = Enum.QualityLevel.Level04,
    },

    Quality = {
        ParticleRate = 1,
        ParticleTimeScale = 1,
        TrailLifetime = 1,
        BeamEnabled = true,
        PostEffects = true,
        Shadows = true,
        GlobalShadows = true,
        Fog = true,
        MaterialQuality = Enum.QualityLevel.Automatic,
    },
}

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local Root

local function SetupCharacter(char)

    Character = char

    Humanoid =
        char:WaitForChild("Humanoid", 5)

    Root =
        char:WaitForChild(
            "HumanoidRootPart",
            5
        )
end

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(
    SetupCharacter
)

--============================================================
-- UTILITY
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
            and LocalPlayer.Team ==
                player.Team then

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
-- AIM PART
--============================================================

local function GetAimPart(player)

    local char =
        GetCharacter(player)

    if not char then
        return nil
    end

    if Settings.AimPart == "Head" then

        return char:FindFirstChild("Head")
            or char:FindFirstChild(
                "HumanoidRootPart"
            )
    end

    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild(
            "HumanoidRootPart"
        )
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

--============================================================
-- TARGET FINDER
--============================================================

local CurrentTarget = nil

local function FindTarget()

    if not Camera then
        return nil
    end

    local bestTarget = nil
    local bestScore = math.huge

    for _, player in
        ipairs(Players:GetPlayers()) do

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

                            -- TRUE 3D SEARCH.
                            -- No screen-position math.
                            -- This prevents the 360° glitch.

                            local score =
                                distance

                            if score <
                                bestScore then

                                bestScore =
                                    score

                                bestTarget =
                                    player
                            end

                        else

                            local screenPosition,
                                visible =
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

                                local screenTarget =
                                    Vector2.new(
                                        screenPosition.X,
                                        screenPosition.Y
                                    )

                                local screenDistance =
                                    (
                                        screenTarget -
                                        center
                                    ).Magnitude

                                if screenDistance <=
                                    Settings.AimFOV then

                                    if screenDistance <
                                        bestScore then

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

    local distance =
        GetDistance(CurrentTarget)

    if distance >
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

    -- Frame-rate-independent smoothing.

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
            0.90
        )

    local cameraPosition =
        Camera.CFrame.Position

    local desired =
        CFrame.lookAt(
            cameraPosition,
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

--============================================================
-- CREATE ESP
--============================================================

local function CreateESP(player)

    if player == LocalPlayer then
        return
    end

    if ESPObjects[player] then
        return
    end

    local data = {}

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
        ESPFolder

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

    local headFrame =
        Instance.new("Frame")

    headFrame.Size =
        UDim2.fromScale(
            1,
            1
        )

    headFrame.BackgroundTransparency =
        0.15

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
-- TRACERS
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

        local attachment =
            Instance.new("Attachment")

        attachment.Name =
            "Origin"

        attachment.Parent =
            originPart
    end

    local targetAttachment =
        Instance.new("Attachment")

    targetAttachment.Name =
        "XE_TracerTarget"

    targetAttachment.Parent =
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
        targetAttachment

    beam.Parent =
        ESPFolder

    data.Tracer =
        beam

    data.TracerAttachment =
        targetAttachment
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

        if typeof(object) ==
            "Instance" then

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

        for _, data in
            pairs(ESPObjects) do

            if data.Highlight then
                data.Highlight.Enabled =
                    false
            end

            if data.Billboard then
                data.Billboard.Enabled =
                    false
            end

            if data.HeadMarker then
                data.HeadMarker.Enabled =
                    false
            end

            if data.Tracer then
                data.Tracer.Enabled =
                    false
            end
        end

        return
    end

    for _, player in
        ipairs(Players:GetPlayers()) do

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
                and char:FindFirstChild(
                    "Head"
                )

            if IsEnemy(player)
                and root
                and hum
                and hum.Health > 0 then

                local distance =
                    GetDistance(player)

                if distance <=
                    Settings.ESPDistance then

                    local color =
                        GetESPColor(
                            player
                        )

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
                            math.floor(
                                distance
                            )
                            .. " studs"

                        data.DistanceLabel.TextColor3 =
                            color

                        data.HPLabel.Text =
                            math.floor(
                                hum.Health
                            )
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

                    if Settings.TracerEnabled
                        and not Settings.FPSBoost then

                        CreateTracer(player)

                        if data.Tracer then

                            data.Tracer.Enabled =
                                true

                            if data.TracerAttachment then
                                data.TracerAttachment.Parent =
                                    root
                            end
                        end

                    elseif data.Tracer then

                        data.Tracer.Enabled =
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

                    if data.HeadMarker then
                        data.HeadMarker.Enabled =
                            false
                    end

                    if data.Tracer then
                        data.Tracer.Enabled =
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

                if data.HeadMarker then
                    data.HeadMarker.Enabled =
                        false
                end

                if data.Tracer then
                    data.Tracer.Enabled =
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
            16
    end
end

local function ToggleSpeed()

    Settings.SpeedEnabled =
        not Settings.SpeedEnabled

    UpdateSpeed()
end

--============================================================
-- PERFORMANCE OPTIMIZER
--============================================================

local OriginalSettings = {}

local function SaveOriginal(instance)

    if OriginalSettings[instance] then
        return
    end

    OriginalSettings[instance] = {
        Enabled =
            instance.Enabled
    }
end

local function SetEffectsEnabled(enabled)

    for _, object in
        ipairs(Lighting:GetDescendants()) do

        if object:IsA(
            "PostEffect"
        ) then

            SaveOriginal(object)

            object.Enabled =
                enabled
        end
    end
end

local function OptimizeParticles(profile)

    for _, object in
        ipairs(Workspace:GetDescendants()) do

        if object:IsA(
            "ParticleEmitter"
        ) then

            if profile ==
                Profiles.Performance then

                object.Enabled =
                    false

            elseif profile ==
                Profiles.Balanced then

                object.Enabled =
                    true

                object.TimeScale =
                    Profiles.Balanced
                    .ParticleTimeScale

            else

                object.Enabled =
                    true

                object.TimeScale =
                    1
            end
        end

        if object:IsA("Trail") then

            if profile ==
                Profiles.Performance then

                object.Enabled =
                    false

            elseif profile ==
                Profiles.Balanced then

                object.Enabled =
                    true

                object.Lifetime =
                    Profiles.Balanced
                    .TrailLifetime

            else

                object.Enabled =
                    true
            end
        end

        if object:IsA("Beam") then

            if object.Name:find(
                "XE_Tracer"
            ) then

                continue
            end

            object.Enabled =
                Profiles[profile] and
                Profiles[profile].BeamEnabled
        end
    end
end

local function ApplyPerformanceProfile(profileName)

    local profile =
        Profiles[profileName]

    if not profile then
        return
    end

    -- Lighting
    Lighting.GlobalShadows =
        profile.GlobalShadows

    -- Post processing
    SetEffectsEnabled(
        profile.PostEffects
    )

    -- Particles / trails / beams
    OptimizeParticles(
        profileName
    )

    -- Terrain decorations
    local terrain =
        Workspace:FindFirstChildOfClass(
            "Terrain"
        )

    if terrain then

        pcall(function()

            if profileName ==
                "Performance" then

                terrain.Decoration =
                    false

            else

                terrain.Decoration =
                    true
            end

        end)
    end

    -- Roblox rendering quality.
    -- QualityLevel is controlled by Roblox on many
    -- client platforms, so failure is safely ignored.

    pcall(function()

        if profileName ==
            "Performance" then

            settings().Rendering.QualityLevel =
                Enum.QualityLevel.Level01

        elseif profileName ==
            "Balanced" then

            settings().Rendering.QualityLevel =
                Enum.QualityLevel.Level04

        elseif profileName ==
            "Quality" then

            settings().Rendering.QualityLevel =
                Enum.QualityLevel.Automatic
        end

    end)
end

--============================================================
-- AUTOMATIC PROFILE
--============================================================

local CurrentProfile =
    "Balanced"

local function GetAutomaticProfile()

    if DeviceType == "Mobile"
        or DeviceType ==
            "Mobile + Keyboard" then

        -- Mobile starts with Performance.
        return "Performance"
    end

    return "Balanced"
end

local function ApplyFPSMode()

    if not Settings.FPSBoost then

        ApplyPerformanceProfile(
            "Quality"
        )

        CurrentProfile =
            "Quality"

        return
    end

    if Settings.PerformanceMode ==
        "Auto" then

        CurrentProfile =
            GetAutomaticProfile()

    else

        CurrentProfile =
            Settings.PerformanceMode
    end

    ApplyPerformanceProfile(
        CurrentProfile
    )
end

--============================================================
-- FPS MONITOR
--============================================================

local FPS = 60
local FPSTimer = 0
local FPSFrames = 0

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
-- DYNAMIC OPTIMIZATION
--============================================================

local DynamicTimer = 0

local function DynamicPerformance(dt)

    if not Settings.FPSBoost
        or not Settings.DynamicOptimization then

        return
    end

    DynamicTimer += dt

    if DynamicTimer < 2 then
        return
    end

    DynamicTimer = 0

    if FPS < 25 then

        if CurrentProfile ~=
            "Performance" then

            CurrentProfile =
                "Performance"

            ApplyPerformanceProfile(
                "Performance"
            )
        end

    elseif FPS < 40 then

        if CurrentProfile ~=
            "Balanced" then

            CurrentProfile =
                "Balanced"

            ApplyPerformanceProfile(
                "Balanced"
            )
        end
    end
end

--============================================================
-- GUI
--============================================================

local PlayerGui =
    LocalPlayer:WaitForChild(
        "PlayerGui"
    )

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
        330,
        470
    )

MainFrame.Position =
    UDim2.new(
        0.5,
        -165,
        0.5,
        -235
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
        42
    )

Header.BackgroundColor3 =
    Color3.fromRGB(
        28,
        28,
        34
    )

Header.Text =
    "XEIREN  •  5V5"

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
-- MENU DRAG
--============================================================

local menuDragging = false
local menuDragStart
local menuStartPosition

Header.InputBegan:Connect(
    function(input)

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
    end
)

UserInputService.InputChanged:Connect(
    function(input)

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
    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

            menuDragging = false
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
        -12,
        1,
        -52
    )

Scroll.Position =
    UDim2.fromOffset(
        6,
        46
    )

Scroll.BackgroundTransparency =
    1

Scroll.BorderSizePixel =
    0

Scroll.ScrollBarThickness =
    4

Scroll.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        1150
    )

Scroll.Parent =
    MainFrame

local Layout =
    Instance.new("UIListLayout")

Layout.Padding =
    UDim.new(
        0,
        6
    )

Layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

Layout.Parent =
    Scroll

--============================================================
-- GUI HELPERS
--============================================================

local function Section(text)

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -10,
            0,
            25
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
        14

    label.Parent =
        Scroll

    return label
end

local function Toggle(
    text,
    key
)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(
            1,
            -10,
            0,
            34
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
        13

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

                UpdateSpeed()
            end

            if key ==
                "FPSBoost" then

                ApplyFPSMode()
            end
        end
    )

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
            52
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
            22
        )

    label.Position =
        UDim2.fromOffset(
            5,
            2
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
        12

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
            18
        )

    bar.Position =
        UDim2.fromOffset(
            10,
            28
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
                Settings[key]
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
                *
                step
        end

        Settings[key] =
            value

        Refresh()

        if key ==
            "FPSBoost" then

            ApplyFPSMode()
        end
    end

    Refresh()

    local sliding = false

    bar.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                sliding = true

                UpdateFromX(
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

                UpdateFromX(
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

    return holder
end

--============================================================
-- AIM UI
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
        34
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
    13

AimPartButton.Parent =
    Scroll

AimPartButton.Activated:Connect(
    function()

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
    end
)

--============================================================
-- ESP UI
--============================================================

Section("STRONG ESP")

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
    "Player Name",
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
-- TRACERS
--============================================================

Section("TRACERS")

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
-- MOVEMENT
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
-- PERFORMANCE UI
--============================================================

Section("FPS BOOST")

Toggle(
    "FPS BOOST",
    "FPSBoost"
)

Toggle(
    "Dynamic Optimization",
    "DynamicOptimization"
)

Toggle(
    "FPS Counter",
    "ShowFPS"
)

-- Performance mode
local ModeButton =
    Instance.new("TextButton")

ModeButton.Size =
    UDim2.new(
        1,
        -10,
        0,
        34
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
    "Mode : "
    .. Settings.PerformanceMode

ModeButton.Font =
    Enum.Font.Gotham

ModeButton.TextSize =
    13

ModeButton.Parent =
    Scroll

local Modes = {
    "Auto",
    "Performance",
    "Balanced",
    "Quality",
}

local ModeIndex = 1

ModeButton.Activated:Connect(
    function()

        ModeIndex += 1

        if ModeIndex >
            #Modes then

            ModeIndex = 1
        end

        Settings.PerformanceMode =
            Modes[ModeIndex]

        ModeButton.Text =
            "Mode : "
            .. Settings.PerformanceMode

        ApplyFPSMode()
    end
)

Slider(
    "ESP Update Rate",
    "ESPUpdateRate",
    5,
    30,
    1
)

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
        45
    )

DeviceLabel.BackgroundTransparency =
    1

DeviceLabel.Text =
    "Device: "
    .. DeviceType
    .. "\nProfile: "
    .. CurrentProfile

DeviceLabel.TextColor3 =
    Color3.fromRGB(
        160,
        160,
        170
    )

DeviceLabel.Font =
    Enum.Font.Gotham

DeviceLabel.TextSize =
    12

DeviceLabel.TextXAlignment =
    Enum.TextXAlignment.Left

DeviceLabel.Parent =
    Scroll

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
        70
    )

Controls.BackgroundTransparency =
    1

Controls.Text =
    "R  = Fly\n"
    .. "V  = Speed Run\n"
    .. "XE Logo = Open / Close"

Controls.TextColor3 =
    Color3.fromRGB(
        190,
        190,
        200
    )

Controls.TextSize =
    13

Controls.Font =
    Enum.Font.Gotham

Controls.TextXAlignment =
    Enum.TextXAlignment.Left

Controls.Parent =
    Scroll

--============================================================
-- FPS COUNTER
--============================================================

local FPSLabel =
    Instance.new("TextLabel")

FPSLabel.Size =
    UDim2.fromOffset(
        100,
        30
    )

FPSLabel.Position =
    UDim2.new(
        1,
        -110,
        0,
        10
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
        48,
        48
    )

LogoButton.Position =
    UDim2.new(
        0,
        16,
        0.5,
        -24
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
-- LOGO DRAG
--============================================================

local logoDragging = false
local logoDragStart
local logoStartPosition
local logoMoved = false

LogoButton.InputBegan:Connect(
    function(input)

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

LogoButton.Activated:Connect(
    function()

        if logoMoved then

            logoMoved = false
            return
        end

        MainFrame.Visible =
            not MainFrame.Visible
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
-- KEYBINDS
--============================================================

UserInputService.InputBegan:Connect(
    function(
        input,
        gameProcessed
    )

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
-- MAIN UPDATE LOOP
--============================================================

local ESPTimer = 0

ApplyFPSMode()

RunService.RenderStepped:Connect(
    function(dt)

        UpdateFPS(dt)

        UpdateAim(dt)

        UpdateFly()

        UpdateSpeed()

        DynamicPerformance(dt)

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
            .. "\nProfile: "
            .. CurrentProfile
    end
)
