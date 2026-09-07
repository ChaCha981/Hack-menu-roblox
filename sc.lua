--[[
    XEIREN 5V5 COMBAT HUB
    Single LocalScript
    Roblox Studio / Your Own Game

    Password:
        anakin

    Features:
        • Password screen
        • Aim Assist
        • 360° Target Lock
        • Lock Strength
        • Aim Speed
        • Aim Distance
        • Aim FOV up to 999
        • Head / Body target
        • ESP Box
        • ESP Name
        • ESP Health
        • ESP Distance
        • ESP Tracking Line
        • Cloud ESP
        • Team Check
        • Wall Check
        • Speed Run
        • Super Jump
        • Fly
        • Fly Speed
        • Fly Vertical Speed
        • FPS Boost
        • Dynamic FPS
        • FPS Counter
        • English / Khmer
        • Mobile + PC
        • Draggable XE logo
        • Draggable menu
        • R = Fly
        • V = Speed
        • EXIT MODE

    NOTE:
    The GitHub image URL below cannot be used directly as
    ImageButton.Image by Roblox. Upload the image to Roblox
    and replace YOUR_ROBLOX_IMAGE_ASSET_ID.
]]

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------

local PASSWORD = "anakin"

-- Your GitHub logo source
local LOGO_SOURCE_URL =
    "https://raw.githubusercontent.com/ChaCha981/Hack-menu-roblox/refs/heads/main/IMG_2452.jpeg"

-- Upload the image to Roblox and replace this.
local LOGO_ASSET_ID =
    "rbxassetid://YOUR_ROBLOX_IMAGE_ASSET_ID"

local Settings = {

    ------------------------------------------------------------
    -- LANGUAGE
    ------------------------------------------------------------

    Language = "EN",

    ------------------------------------------------------------
    -- AIM
    ------------------------------------------------------------

    AimEnabled = false,
    Full360 = true,

    LockStrength = 85,
    AimSpeed = 30,

    AimDistance = 600,
    AimFOV = 999,

    AimPart = "Head",

    ------------------------------------------------------------
    -- ESP
    ------------------------------------------------------------

    ESPEnabled = false,

    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,

    ESPLine = true,
    CloudESP = true,

    ESPAlwaysOnTop = true,
    ESPTeamColor = true,

    ESPMaxDistance = 600,

    ------------------------------------------------------------
    -- CHECKS
    ------------------------------------------------------------

    TeamCheck = true,
    WallCheck = false,

    ------------------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------------------

    SpeedEnabled = false,
    SpeedRun = 32,

    SuperJumpEnabled = false,
    JumpPower = 75,

    ------------------------------------------------------------
    -- FLY
    ------------------------------------------------------------

    FlyEnabled = false,

    FlySpeed = 70,
    FlyVerticalSpeed = 60,

    ------------------------------------------------------------
    -- PERFORMANCE
    ------------------------------------------------------------

    FPSBoost = false,
    DynamicFPS = false,
    ShowFPS = true,
}

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local Running = true
local Authenticated = false

local Character
local Humanoid
local Root

local ESPObjects = {}

local Connections = {}

local FlyAttachment
local FlyVelocity

local UpHeld = false
local DownHeld = false

local MenuGui
local PasswordGui

local MainFrame
local LogoButton
local FPSLabel

local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local OriginalAutoRotate = true

local PerformanceBackup = {}

----------------------------------------------------------------
-- CONNECTION HELPER
----------------------------------------------------------------

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    table.clear(Connections)
end

----------------------------------------------------------------
-- CHARACTER
----------------------------------------------------------------

local function UpdateCharacter()
    Character = LocalPlayer.Character

    if not Character then
        Humanoid = nil
        Root = nil
        return
    end

    Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    Root =
        Character:FindFirstChild("HumanoidRootPart")

    if Humanoid then
        OriginalWalkSpeed = Humanoid.WalkSpeed
        OriginalJumpPower = Humanoid.JumpPower
        OriginalAutoRotate = Humanoid.AutoRotate
    end
end

UpdateCharacter()

Connect(
    LocalPlayer.CharacterAdded,
    function()
        task.wait(0.5)

        if not Running then
            return
        end

        UpdateCharacter()
    end
)

----------------------------------------------------------------
-- LANGUAGE
----------------------------------------------------------------

local Text = {

    EN = {
        title = "XEIREN 5V5",
        password = "Password",
        enter = "ENTER",
        wrong = "Wrong password",

        aim = "Aim Assist",
        lock = "360° Lock",
        strength = "Lock Strength",
        aimSpeed = "Aim Speed",
        aimDistance = "Aim Distance",
        fov = "Aim FOV",
        target = "Target",

        esp = "ESP",
        box = "ESP Box",
        name = "Player Name",
        health = "Health",
        distance = "Distance",
        line = "Tracking Line",
        cloud = "Cloud ESP",

        team = "Team Check",
        wall = "Wall Check",

        speed = "Speed Run",
        speedValue = "Run Speed",

        jump = "Super Jump",
        jumpValue = "Jump Power",

        fly = "Fly",
        flySpeed = "Fly Speed",
        vertical = "Vertical Speed",

        fps = "FPS Boost",
        dynamic = "Dynamic FPS",
        showfps = "Show FPS",

        language = "Language",

        exit = "EXIT MODE",

        head = "Head",
        body = "Body",

        on = "ON",
        off = "OFF",
    },

    KH = {
        title = "XEIREN 5V5",
        password = "ពាក្យសម្ងាត់",
        enter = "ចូល",
        wrong = "ពាក្យសម្ងាត់មិនត្រឹមត្រូវ",

        aim = "ជំនួយ Aim",
        lock = "ចាក់ Lock 360°",
        strength = "កម្លាំង Lock",
        aimSpeed = "ល្បឿន Aim",
        aimDistance = "ចម្ងាយ Aim",
        fov = "Aim FOV",
        target = "គោលដៅ",

        esp = "ESP",
        box = "ប្រអប់ ESP",
        name = "ឈ្មោះ Player",
        health = "ជីវិត",
        distance = "ចម្ងាយ",
        line = "បន្ទាត់តាមដាន",
        cloud = "Cloud ESP",

        team = "ពិនិត្យ Team",
        wall = "ពិនិត្យជញ្ជាំង",

        speed = "រត់លឿន",
        speedValue = "ល្បឿនរត់",

        jump = "លោតខ្ពស់",
        jumpValue = "កម្លាំងលោត",

        fly = "ហោះ",
        flySpeed = "ល្បឿនហោះ",
        vertical = "ល្បឿនឡើងចុះ",

        fps = "បង្កើន FPS",
        dynamic = "Dynamic FPS",
        showfps = "បង្ហាញ FPS",

        language = "ភាសា",

        exit = "ចាកចេញ",

        head = "ក្បាល",
        body = "ខ្លួន",

        on = "បើក",
        off = "បិទ",
    }
}

local function T(key)
    local language = Text[Settings.Language] or Text.EN
    return language[key] or key
end

----------------------------------------------------------------
-- UI HELPERS
----------------------------------------------------------------

local function New(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function Corner(parent, radius)
    return New(
        "UICorner",
        {
            CornerRadius = UDim.new(0, radius)
        },
        parent
    )
end

local function Stroke(parent, transparency)
    return New(
        "UIStroke",
        {
            Transparency = transparency or 0,
            Thickness = 1
        },
        parent
    )
end

----------------------------------------------------------------
-- PASSWORD UI
----------------------------------------------------------------

local function CreatePasswordUI()

    PasswordGui = New(
        "ScreenGui",
        {
            Name = "XeirenPassword",
            ResetOnSpawn = false,
            IgnoreGuiInset = true
        },
        LocalPlayer:WaitForChild("PlayerGui")
    )

    local Background = New(
        "Frame",
        {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.25
        },
        PasswordGui
    )

    local Box = New(
        "Frame",
        {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 210),
            BackgroundTransparency = 0.08
        },
        Background
    )

    Corner(Box, 14)
    Stroke(Box, 0.15)

    local Logo = New(
        "ImageLabel",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.04),
            Size = UDim2.fromOffset(65, 65),
            BackgroundTransparency = 1,
            Image = LOGO_ASSET_ID,
            ScaleType = Enum.ScaleType.Crop
        },
        Box
    )

    Corner(Logo, 32)

    local Title = New(
        "TextLabel",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.38),
            Size = UDim2.fromOffset(260, 30),
            BackgroundTransparency = 1,
            Text = T("title"),
            TextScaled = true,
            Font = Enum.Font.GothamBold
        },
        Box
    )

    local PasswordBox = New(
        "TextBox",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.55),
            Size = UDim2.fromOffset(240, 38),
            PlaceholderText = T("password"),
            Text = "",
            ClearTextOnFocus = false,
            TextScaled = true,
            Font = Enum.Font.Gotham,
        },
        Box
    )

    Corner(PasswordBox, 8)

    local EnterButton = New(
        "TextButton",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.76),
            Size = UDim2.fromOffset(110, 35),
            Text = T("enter"),
            TextScaled = true,
            Font = Enum.Font.GothamBold
        },
        Box
    )

    Corner(EnterButton, 8)

    local Status = New(
        "TextLabel",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.93),
            Size = UDim2.fromOffset(270, 25),
            BackgroundTransparency = 1,
            Text = "",
            TextScaled = true,
            Font = Enum.Font.Gotham
        },
        Box
    )

    local function Attempt()
        if PasswordBox.Text == PASSWORD then

            Authenticated = true

            if PasswordGui then
                PasswordGui:Destroy()
                PasswordGui = nil
            end

            CreateMainUI()

        else

            Status.Text = T("wrong")

            PasswordBox.Text = ""

        end
    end

    Connect(
        EnterButton.MouseButton1Click,
        Attempt
    )

    Connect(
        PasswordBox.FocusLost,
        function(enterPressed)
            if enterPressed then
                Attempt()
            end
        end
    )
end

----------------------------------------------------------------
-- TARGET CHECK
----------------------------------------------------------------

local function IsAlive(player)

    if not player.Character then
        return false
    end

    local humanoid =
        player.Character:FindFirstChildOfClass("Humanoid")

    return humanoid and humanoid.Health > 0
end

local function IsEnemy(player)

    if player == LocalPlayer then
        return false
    end

    if not IsAlive(player) then
        return false
    end

    if Settings.TeamCheck then

        if player.Team ~= nil
        and LocalPlayer.Team ~= nil
        and player.Team == LocalPlayer.Team then

            return false
        end
    end

    return true
end

local function HasLineOfSight(player)

    if not Settings.WallCheck then
        return true
    end

    if not Character then
        return false
    end

    local targetCharacter = player.Character

    if not targetCharacter then
        return false
    end

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetRoot then
        return false
    end

    local origin = Camera.CFrame.Position

    local direction =
        targetRoot.Position - origin

    local parameters =
        RaycastParams.new()

    parameters.FilterType =
        Enum.RaycastFilterType.Exclude

    parameters.FilterDescendantsInstances = {
        Character,
        Camera
    }

    local result =
        Workspace:Raycast(
            origin,
            direction,
            parameters
        )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(targetCharacter)
end

----------------------------------------------------------------
-- TARGET PART
----------------------------------------------------------------

local function GetTargetPart(player)

    local character = player.Character

    if not character then
        return nil
    end

    if Settings.AimPart == "Body" then

        return character:FindFirstChild(
            "HumanoidRootPart"
        )

    end

    return character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
-- AIM TARGET
----------------------------------------------------------------

local function GetBestTarget()

    if not Camera then
        return nil
    end

    local bestPlayer = nil
    local bestScore = math.huge

    local center =
        Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do

        if IsEnemy(player) then

            local targetPart =
                GetTargetPart(player)

            if targetPart then

                local distance =
                    (Camera.CFrame.Position
                    - targetPart.Position).Magnitude

                if distance <= Settings.AimDistance then

                    local screenPosition,
                        visible =
                        Camera:WorldToViewportPoint(
                            targetPart.Position
                        )

                    if visible then

                        local screenDistance =
                            (
                                Vector2.new(
                                    screenPosition.X,
                                    screenPosition.Y
                                ) - center
                            ).Magnitude

                        if Settings.Full360 then

                            if distance < bestScore then

                                if HasLineOfSight(player) then
                                    bestScore = distance
                                    bestPlayer = player
                                end

                            end

                        elseif screenDistance <= Settings.AimFOV then

                            if screenDistance < bestScore then

                                if HasLineOfSight(player) then
                                    bestScore = screenDistance
                                    bestPlayer = player
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

----------------------------------------------------------------
-- AIM UPDATE
----------------------------------------------------------------

local function UpdateAim()

    if not Settings.AimEnabled then
        return
    end

    if not Camera then
        return
    end

    local target =
        GetBestTarget()

    if not target then
        return
    end

    local targetPart =
        GetTargetPart(target)

    if not targetPart then
        return
    end

    local cameraPosition =
        Camera.CFrame.Position

    local desired =
        CFrame.lookAt(
            cameraPosition,
            targetPart.Position
        )

    local alpha =
        math.clamp(
            Settings.LockStrength / 100,
            0.01,
            1
        )

    local speedMultiplier =
        math.clamp(
            Settings.AimSpeed / 30,
            0.05,
            4
        )

    alpha =
        math.clamp(
            alpha * speedMultiplier * 0.08,
            0.01,
            1
        )

    Camera.CFrame =
        Camera.CFrame:Lerp(
            desired,
            alpha
        )
end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------

local function RemoveESP(player)

    local data =
        ESPObjects[player]

    if not data then
        return
    end

    for _, object in pairs(data) do

        if typeof(object) == "Instance" then

            pcall(function()
                object:Destroy()
            end)

        end
    end

    ESPObjects[player] = nil
end

local function CreateESP(player)

    if player == LocalPlayer then
        return
    end

    if ESPObjects[player] then
        return
    end

    local data = {}

    local highlight =
        New(
            "Highlight",
            {
                Name = "XeirenESP",
                Enabled = false,
                FillTransparency = 0.85,
                OutlineTransparency = 0,
                DepthMode =
                    Enum.HighlightDepthMode.AlwaysOnTop
            }
        )

    local billboard =
        New(
            "BillboardGui",
            {
                Name = "XeirenESPInfo",
                Size = UDim2.fromOffset(180, 70),
                StudsOffset = Vector3.new(0, 3, 0),
                AlwaysOnTop = true,
                Enabled = false
            }
        )

    local info =
        New(
            "TextLabel",
            {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                TextScaled = false,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextStrokeTransparency = 0.2
            },
            billboard
        )

    local lineGui =
        New(
            "ScreenGui",
            {
                Name = "XeirenESPLine",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                Enabled = false
            },
            LocalPlayer.PlayerGui
        )

    local line =
        New(
            "Frame",
            {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(2, 1),
                Visible = false
            },
            lineGui
        )

    local cloudLineGui =
        New(
            "ScreenGui",
            {
                Name = "XeirenCloudESP",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                Enabled = false
            },
            LocalPlayer.PlayerGui
        )

    local cloudLine =
        New(
            "Frame",
            {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(2, 1),
                Visible = false
            },
            cloudLineGui
        )

    data.Highlight = highlight
    data.Billboard = billboard
    data.Info = info

    data.LineGui = lineGui
    data.Line = line

    data.CloudGui = cloudLineGui
    data.CloudLine = cloudLine

    ESPObjects[player] = data
end

local function SetLine(
    frame,
    startPosition,
    endPosition
)

    local difference =
        endPosition - startPosition

    local length =
        difference.Magnitude

    if length < 1 then
        frame.Visible = false
        return
    end

    frame.Position =
        UDim2.fromOffset(
            startPosition.X,
            startPosition.Y
        )

    frame.Size =
        UDim2.fromOffset(
            length,
            2
        )

    frame.Rotation =
        math.deg(
            math.atan2(
                difference.Y,
                difference.X
            )
        )

    frame.Visible = true
end

local function UpdateESP(player)

    local data =
        ESPObjects[player]

    if not data then
        CreateESP(player)
        data = ESPObjects[player]
    end

    if not Settings.ESPEnabled then

        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        data.Line.Visible = false
        data.CloudLine.Visible = false

        return
    end

    if not IsEnemy(player) then

        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        data.Line.Visible = false
        data.CloudLine.Visible = false

        return
    end

    local character =
        player.Character

    local root =
        character and
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    local humanoid =
        character and
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not root or not humanoid then
        return
    end

    local distance =
        (Camera.CFrame.Position
        - root.Position).Magnitude

    if distance > Settings.ESPMaxDistance then

        data.Highlight.Enabled = false
        data.Billboard.Enabled = false
        data.Line.Visible = false
        data.CloudLine.Visible = false

        return
    end

    ------------------------------------------------------------
    -- COLOR
    ------------------------------------------------------------

    local playerColor =
        Color3.fromRGB(
            255,
            70,
            70
        )

    if Settings.ESPTeamColor
    and player.Team then

        playerColor =
            player.TeamColor.Color
    end

    ------------------------------------------------------------
    -- HIGHLIGHT
    ------------------------------------------------------------

    if Settings.ESPBox then

        data.Highlight.Adornee =
            character

        data.Highlight.FillColor =
            playerColor

        data.Highlight.OutlineColor =
            playerColor

        data.Highlight.DepthMode =
            Settings.ESPAlwaysOnTop
            and Enum.HighlightDepthMode.AlwaysOnTop
            or Enum.HighlightDepthMode.Occluded

        data.Highlight.Enabled = true

    else

        data.Highlight.Enabled = false

    end

    ------------------------------------------------------------
    -- BILLBOARD
    ------------------------------------------------------------

    local lines = {}

    if Settings.ESPName then
        table.insert(
            lines,
            player.DisplayName
        )
    end

    if Settings.ESPHealth then

        table.insert(
            lines,
            "HP: "
            .. math.floor(humanoid.Health)
            .. "/"
            .. math.floor(humanoid.MaxHealth)
        )

    end

    if Settings.ESPDistance then

        table.insert(
            lines,
            math.floor(distance)
            .. " studs"
        )

    end

    data.Info.Text =
        table.concat(
            lines,
            "\n"
        )

    data.Info.TextColor3 =
        playerColor

    data.Billboard.Adornee =
        character:FindFirstChild("Head")
        or root

    data.Billboard.Enabled =
        #lines > 0

    ------------------------------------------------------------
    -- NORMAL TRACKING LINE
    ------------------------------------------------------------

    if Settings.ESPLine then

        local position,
            visible =
            Camera:WorldToViewportPoint(
                root.Position
            )

        if visible then

            local screen =
                Vector2.new(
                    position.X,
                    position.Y
                )

            local start =
                Vector2.new(
                    Camera.ViewportSize.X / 2,
                    Camera.ViewportSize.Y
                )

            SetLine(
                data.Line,
                start,
                screen
            )

        else

            data.Line.Visible = false

        end

    else

        data.Line.Visible = false

    end

    ------------------------------------------------------------
    -- CLOUD ESP
    ------------------------------------------------------------

    if Settings.CloudESP then

        local position,
            visible =
            Camera:WorldToViewportPoint(
                root.Position
            )

        if visible then

            local screen =
                Vector2.new(
                    position.X,
                    position.Y
                )

            local cloud =
                Vector2.new(
                    Camera.ViewportSize.X / 2,
                    65
                )

            SetLine(
                data.CloudLine,
                cloud,
                screen
            )

        else

            data.CloudLine.Visible = false

        end

    else

        data.CloudLine.Visible = false

    end
end

local function UpdateAllESP()

    if not Settings.ESPEnabled then
        return
    end

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then
            UpdateESP(player)
        end
    end
end

Connect(
    Players.PlayerAdded,
    function(player)

        if not Running then
            return
        end

        CreateESP(player)

        Connect(
            player.CharacterRemoving,
            function()
                RemoveESP(player)
            end
        )
    end
)

Connect(
    Players.PlayerRemoving,
    function(player)
        RemoveESP(player)
    end
)

for _, player in ipairs(
    Players:GetPlayers()
) do

    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------

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

    UpHeld = false
    DownHeld = false
end

local function StartFly()

    if not Root or not Humanoid then
        return
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
    end

    if FlyAttachment then
        FlyAttachment:Destroy()
    end

    Settings.FlyEnabled = true

    Humanoid.AutoRotate = false

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

local function UpdateFly()

    if not Settings.FlyEnabled then
        return
    end

    if not Root or not Humanoid then

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
        forward = forward.Unit
    end

    if right.Magnitude > 0 then
        right = right.Unit
    end

    local move =
        Humanoid.MoveDirection

    local horizontal =
        Vector3.zero

    if move.Magnitude > 0.01 then

        local forwardAmount =
            move:Dot(forward)

        local rightAmount =
            move:Dot(right)

        horizontal =
            forward * forwardAmount
            + right * rightAmount

        if horizontal.Magnitude > 1 then
            horizontal =
                horizontal.Unit
        end
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

    if UpHeld then
        vertical +=
            Settings.FlyVerticalSpeed
    end

    if DownHeld then
        vertical -=
            Settings.FlyVerticalSpeed
    end

    FlyVelocity.VectorVelocity =
        horizontal * Settings.FlySpeed
        + Vector3.new(
            0,
            vertical,
            0
        )
end

----------------------------------------------------------------
-- SPEED
----------------------------------------------------------------

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

----------------------------------------------------------------
-- SUPER JUMP
----------------------------------------------------------------

local function UpdateJump()

    if not Humanoid then
        return
    end

    if Settings.SuperJumpEnabled then

        Humanoid.UseJumpPower = true

        Humanoid.JumpPower =
            Settings.JumpPower

    else

        Humanoid.UseJumpPower = true

        Humanoid.JumpPower =
            OriginalJumpPower
    end
end

----------------------------------------------------------------
-- FPS BOOST
----------------------------------------------------------------

local function ApplyFPSBoost()

    if not Settings.FPSBoost then

        for object, data in pairs(
            PerformanceBackup
        ) do

            if object
            and object.Parent then

                pcall(function()

                    if data.Material then
                        object.Material =
                            data.Material
                    end

                    if data.CastShadow ~= nil then
                        object.CastShadow =
                            data.CastShadow
                    end

                end)
            end
        end

        table.clear(PerformanceBackup)

        return
    end

    for _, object in ipairs(
        Workspace:GetDescendants()
    ) do

        if object:IsA("BasePart") then

            if not PerformanceBackup[object] then

                PerformanceBackup[object] = {
                    Material = object.Material,
                    CastShadow = object.CastShadow
                }

            end

            object.CastShadow = false

        elseif object:IsA("ParticleEmitter")
        or object:IsA("Trail")
        or object:IsA("Smoke")
        or object:IsA("Fire")
        or object:IsA("Sparkles") then

            object.Enabled = false
        end
    end

    pcall(function()
        Lighting.GlobalShadows = false
    end)
end

----------------------------------------------------------------
-- FPS COUNTER
----------------------------------------------------------------

local FPSFrames = 0
local FPSTime = 0

local function UpdateFPS(dt)

    FPSFrames += 1
    FPSTime += dt

    if FPSTime >= 0.5 then

        local fps =
            math.floor(
                FPSFrames / FPSTime
            )

        if FPSLabel then
            FPSLabel.Text =
                "FPS: " .. fps
        end

        FPSFrames = 0
        FPSTime = 0
    end
end

----------------------------------------------------------------
-- TOGGLE BUTTON
----------------------------------------------------------------

local function CreateToggle(
    parent,
    text,
    default,
    callback
)

    local Button =
        New(
            "TextButton",
            {
                Size = UDim2.new(
                    1,
                    -10,
                    0,
                    34
                ),
                BackgroundTransparency = 0.15,
                Text = "",
                AutoButtonColor = true
            },
            parent
        )

    Corner(Button, 7)

    local Label =
        New(
            "TextLabel",
            {
                Position =
                    UDim2.fromOffset(10, 0),

                Size =
                    UDim2.new(
                        1,
                        -70,
                        1,
                        0
                    ),

                BackgroundTransparency = 1,

                Text = text,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextScaled = true,

                Font =
                    Enum.Font.GothamMedium
            },
            Button
        )

    local State =
        New(
            "TextLabel",
            {
                AnchorPoint =
                    Vector2.new(1, 0.5),

                Position =
                    UDim2.new(
                        1,
                        -10,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        45,
                        25
                    ),

                BackgroundTransparency = 1,

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold
            },
            Button
        )

    local value = default

    local function Refresh()

        State.Text =
            value
            and T("on")
            or T("off")

    end

    Refresh()

    Connect(
        Button.MouseButton1Click,
        function()

            value = not value

            callback(value)

            Refresh()
        end
    )

    return {
        Button = Button,
        Label = Label,
        State = State,

        Set = function(newValue)

            value = newValue

            callback(value)

            Refresh()
        end
    }
end

----------------------------------------------------------------
-- SLIDER
----------------------------------------------------------------

local function CreateSlider(
    parent,
    text,
    minimum,
    maximum,
    default,
    callback
)

    local Frame =
        New(
            "Frame",
            {
                Size = UDim2.new(
                    1,
                    -10,
                    0,
                    48
                ),
                BackgroundTransparency = 1
            },
            parent
        )

    local Label =
        New(
            "TextLabel",
            {
                Position =
                    UDim2.fromOffset(
                        5,
                        0
                    ),

                Size =
                    UDim2.new(
                        1,
                        -60,
                        0,
                        22
                    ),

                BackgroundTransparency = 1,

                Text =
                    text,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextScaled = true,

                Font =
                    Enum.Font.Gotham
            },
            Frame
        )

    local ValueLabel =
        New(
            "TextLabel",
            {
                AnchorPoint =
                    Vector2.new(1, 0),

                Position =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        55,
                        22
                    ),

                BackgroundTransparency = 1,

                Text =
                    tostring(default),

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold
            },
            Frame
        )

    local Bar =
        New(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        5,
                        29
                    ),

                Size =
                    UDim2.new(
                        1,
                        -10,
                        0,
                        6
                    ),

                BackgroundTransparency = 0.2
            },
            Frame
        )

    Corner(Bar, 5)

    local Fill =
        New(
            "Frame",
            {
                Size =
                    UDim2.fromScale(
                        (
                            default - minimum
                        )
                        /
                        (
                            maximum - minimum
                        ),
                        1
                    )
            },
            Bar
        )

    Corner(Fill, 5)

    local dragging = false

    local function SetValueFromX(x)

        local percentage =
            math.clamp(
                (
                    x
                    - Bar.AbsolutePosition.X
                )
                /
                Bar.AbsoluteSize.X,
                0,
                1
            )

        local value =
            minimum
            + (
                maximum - minimum
            )
            * percentage

        value =
            math.floor(
                value + 0.5
            )

        Fill.Size =
            UDim2.fromScale(
                percentage,
                1
            )

        ValueLabel.Text =
            tostring(value)

        callback(value)
    end

    Connect(
        Bar.InputBegan,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true

                SetValueFromX(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputChanged,
        function(input)

            if not dragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                SetValueFromX(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputEnded,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = false

            end
        end
    )

    return Frame
end

----------------------------------------------------------------
-- MAIN UI
----------------------------------------------------------------

function CreateMainUI()

    if MenuGui then
        MenuGui:Destroy()
    end

    MenuGui =
        New(
            "ScreenGui",
            {
                Name = "XeirenHub",
                ResetOnSpawn = false,
                IgnoreGuiInset = true
            },
            LocalPlayer.PlayerGui
        )

    ------------------------------------------------------------
    -- LOGO
    ------------------------------------------------------------

    LogoButton =
        New(
            "ImageButton",
            {
                Name = "XELogo",

                AnchorPoint =
                    Vector2.new(
                        0,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        0,
                        12,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        58,
                        58
                    ),

                BackgroundTransparency = 0.1,

                Image = LOGO_ASSET_ID,

                ScaleType =
                    Enum.ScaleType.Crop,

                AutoButtonColor = true
            },
            MenuGui
        )

    Corner(LogoButton, 29)
    Stroke(LogoButton, 0.1)

    ------------------------------------------------------------
    -- MAIN FRAME
    ------------------------------------------------------------

    MainFrame =
        New(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(
                        0,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        0,
                        80,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        300,
                        390
                    ),

                BackgroundTransparency =
                    0.05
            },
            MenuGui
        )

    Corner(MainFrame, 12)
    Stroke(MainFrame, 0.12)

    ------------------------------------------------------------
    -- HEADER
    ------------------------------------------------------------

    local Header =
        New(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        45
                    ),

                BackgroundTransparency = 1
            },
            MainFrame
        )

    local Title =
        New(
            "TextLabel",
            {
                Position =
                    UDim2.fromOffset(
                        12,
                        5
                    ),

                Size =
                    UDim2.new(
                        1,
                        -100,
                        0,
                        35
                    ),

                BackgroundTransparency = 1,

                Text =
                    T("title"),

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold
            },
            Header
        )

    local Close =
        New(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        1,
                        -10,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        32,
                        30
                    ),

                Text = "×",

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold,

                BackgroundTransparency = 0.2
            },
            Header
        )

    Corner(Close, 7)

    ------------------------------------------------------------
    -- SCROLL
    ------------------------------------------------------------

    local Scroll =
        New(
            "ScrollingFrame",
            {
                Position =
                    UDim2.fromOffset(
                        5,
                        48
                    ),

                Size =
                    UDim2.new(
                        1,
                        -10,
                        1,
                        -53
                    ),

                BackgroundTransparency = 1,

                BorderSizePixel = 0,

                ScrollBarThickness = 4,

                CanvasSize =
                    UDim2.new(
                        0,
                        0,
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y
            },
            MainFrame
        )

    local Layout =
        New(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        5
                    ),

                SortOrder =
                    Enum.SortOrder.LayoutOrder
            },
            Scroll
        )

    New(
        "UIPadding",
        {
            PaddingTop =
                UDim.new(
                    0,
                    5
                ),

            PaddingBottom =
                UDim.new(
                    0,
                    10
                )
        },
        Scroll
    )

    ------------------------------------------------------------
    -- AIM
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("aim"),
        Settings.AimEnabled,
        function(value)
            Settings.AimEnabled = value
        end
    )

    CreateToggle(
        Scroll,
        T("lock"),
        Settings.Full360,
        function(value)
            Settings.Full360 = value
        end
    )

    CreateSlider(
        Scroll,
        T("strength"),
        1,
        100,
        Settings.LockStrength,
        function(value)
            Settings.LockStrength = value
        end
    )

    CreateSlider(
        Scroll,
        T("aimSpeed"),
        1,
        100,
        Settings.AimSpeed,
        function(value)
            Settings.AimSpeed = value
        end
    )

    CreateSlider(
        Scroll,
        T("aimDistance"),
        50,
        1000,
        Settings.AimDistance,
        function(value)
            Settings.AimDistance = value
        end
    )

    CreateSlider(
        Scroll,
        T("fov"),
        1,
        999,
        Settings.AimFOV,
        function(value)
            Settings.AimFOV = value
        end
    )

    CreateToggle(
        Scroll,
        T("target")
        .. ": "
        .. T("head"),
        Settings.AimPart == "Head",
        function(value)

            if value then
                Settings.AimPart = "Head"
            else
                Settings.AimPart = "Body"
            end

        end
    )

    ------------------------------------------------------------
    -- ESP
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("esp"),
        Settings.ESPEnabled,
        function(value)
            Settings.ESPEnabled = value
        end
    )

    CreateToggle(
        Scroll,
        T("box"),
        Settings.ESPBox,
        function(value)
            Settings.ESPBox = value
        end
    )

    CreateToggle(
        Scroll,
        T("name"),
        Settings.ESPName,
        function(value)
            Settings.ESPName = value
        end
    )

    CreateToggle(
        Scroll,
        T("health"),
        Settings.ESPHealth,
        function(value)
            Settings.ESPHealth = value
        end
    )

    CreateToggle(
        Scroll,
        T("distance"),
        Settings.ESPDistance,
        function(value)
            Settings.ESPDistance = value
        end
    )

    CreateToggle(
        Scroll,
        T("line"),
        Settings.ESPLine,
        function(value)
            Settings.ESPLine = value
        end
    )

    CreateToggle(
        Scroll,
        T("cloud"),
        Settings.CloudESP,
        function(value)
            Settings.CloudESP = value
        end
    )

    CreateSlider(
        Scroll,
        "ESP Distance",
        50,
        1000,
        Settings.ESPMaxDistance,
        function(value)
            Settings.ESPMaxDistance = value
        end
    )

    CreateToggle(
        Scroll,
        T("team"),
        Settings.TeamCheck,
        function(value)
            Settings.TeamCheck = value
        end
    )

    CreateToggle(
        Scroll,
        T("wall"),
        Settings.WallCheck,
        function(value)
            Settings.WallCheck = value
        end
    )

    ------------------------------------------------------------
    -- SPEED
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("speed"),
        Settings.SpeedEnabled,
        function(value)

            Settings.SpeedEnabled = value

            UpdateSpeed()

        end
    )

    CreateSlider(
        Scroll,
        T("speedValue"),
        16,
        150,
        Settings.SpeedRun,
        function(value)

            Settings.SpeedRun = value

            if Settings.SpeedEnabled then
                UpdateSpeed()
            end

        end
    )

    ------------------------------------------------------------
    -- SUPER JUMP
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("jump"),
        Settings.SuperJumpEnabled,
        function(value)

            Settings.SuperJumpEnabled = value

            UpdateJump()

        end
    )

    CreateSlider(
        Scroll,
        T("jumpValue"),
        50,
        250,
        Settings.JumpPower,
        function(value)

            Settings.JumpPower = value

            if Settings.SuperJumpEnabled then
                UpdateJump()
            end

        end
    )

    ------------------------------------------------------------
    -- FLY
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("fly"),
        Settings.FlyEnabled,
        function(value)

            if value then
                StartFly()
            else
                StopFly()
            end

        end
    )

    CreateSlider(
        Scroll,
        T("flySpeed"),
        10,
        250,
        Settings.FlySpeed,
        function(value)

            Settings.FlySpeed = value

        end
    )

    CreateSlider(
        Scroll,
        T("vertical"),
        10,
        250,
        Settings.FlyVerticalSpeed,
        function(value)

            Settings.FlyVerticalSpeed =
                value

        end
    )

    ------------------------------------------------------------
    -- FPS
    ------------------------------------------------------------

    CreateToggle(
        Scroll,
        T("fps"),
        Settings.FPSBoost,
        function(value)

            Settings.FPSBoost = value

            ApplyFPSBoost()

        end
    )

    CreateToggle(
        Scroll,
        T("dynamic"),
        Settings.DynamicFPS,
        function(value)

            Settings.DynamicFPS = value

        end
    )

    CreateToggle(
        Scroll,
        T("showfps"),
        Settings.ShowFPS,
        function(value)

            Settings.ShowFPS = value

            if FPSLabel then
                FPSLabel.Visible =
                    value
            end

        end
    )

    ------------------------------------------------------------
    -- LANGUAGE
    ------------------------------------------------------------

    local LanguageButton =
        New(
            "TextButton",
            {
                Size =
                    UDim2.new(
                        1,
                        -10,
                        0,
                        34
                    ),

                Text =
                    "EN / KH",

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold
            },
            Scroll
        )

    Corner(LanguageButton, 7)

    Connect(
        LanguageButton.MouseButton1Click,
        function()

            if Settings.Language == "EN" then
                Settings.Language = "KH"
            else
                Settings.Language = "EN"
            end

            if MenuGui then
                MenuGui:Destroy()
                MenuGui = nil
            end

            CreateMainUI()

        end
    )

    ------------------------------------------------------------
    -- EXIT MODE
    ------------------------------------------------------------

    local ExitButton =
        New(
            "TextButton",
            {
                Size =
                    UDim2.new(
                        1,
                        -10,
                        0,
                        40
                    ),

                Text =
                    "✕  "
                    .. T("exit"),

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold,

                BackgroundTransparency =
                    0.05
            },
            Scroll
        )

    Corner(ExitButton, 8)

    Connect(
        ExitButton.MouseButton1Click,
        function()

            ExitMode()

        end
    )

    ------------------------------------------------------------
    -- FPS LABEL
    ------------------------------------------------------------

    FPSLabel =
        New(
            "TextLabel",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0
                    ),

                Position =
                    UDim2.new(
                        1,
                        -10,
                        0,
                        10
                    ),

                Size =
                    UDim2.fromOffset(
                        100,
                        25
                    ),

                BackgroundTransparency = 1,

                Text =
                    "FPS: --",

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold,

                Visible =
                    Settings.ShowFPS
            },
            MenuGui
        )

    ------------------------------------------------------------
    -- DRAG LOGO
    ------------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition
    local moved = false

    Connect(
        LogoButton.InputBegan,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true
                moved = false

                dragStart =
                    input.Position

                startPosition =
                    LogoButton.Position

            end
        end
    )

    Connect(
        UserInputService.InputChanged,
        function(input)

            if not dragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                local delta =
                    input.Position
                    - dragStart

                if delta.Magnitude > 8 then
                    moved = true
                end

                LogoButton.Position =
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

    Connect(
        UserInputService.InputEnded,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = false

            end
        end
    )

    ------------------------------------------------------------
    -- LOGO CLICK
    ------------------------------------------------------------

    Connect(
        LogoButton.MouseButton1Click,
        function()

            if moved then
                return
            end

            MainFrame.Visible =
                not MainFrame.Visible

        end
    )

    ------------------------------------------------------------
    -- CLOSE MENU ONLY
    ------------------------------------------------------------

    Connect(
        Close.MouseButton1Click,
        function()

            MainFrame.Visible = false

        end
    )
end

----------------------------------------------------------------
-- EXIT MODE
----------------------------------------------------------------

function ExitMode()

    if not Running then
        return
    end

    Running = false
    Authenticated = false

    ------------------------------------------------------------
    -- STOP MOVEMENT
    ------------------------------------------------------------

    StopFly()

    if Humanoid then

        Humanoid.WalkSpeed =
            OriginalWalkSpeed

        Humanoid.JumpPower =
            OriginalJumpPower

        Humanoid.AutoRotate =
            OriginalAutoRotate

    end

    ------------------------------------------------------------
    -- REMOVE ESP
    ------------------------------------------------------------

    for player in pairs(ESPObjects) do
        RemoveESP(player)
    end

    table.clear(ESPObjects)

    ------------------------------------------------------------
    -- RESTORE FPS
    ------------------------------------------------------------

    Settings.FPSBoost = false

    ApplyFPSBoost()

    ------------------------------------------------------------
    -- DESTROY UI
    ------------------------------------------------------------

    if PasswordGui then
        PasswordGui:Destroy()
        PasswordGui = nil
    end

    if MenuGui then
        MenuGui:Destroy()
        MenuGui = nil
    end

    ------------------------------------------------------------
    -- DISCONNECT EVERYTHING
    ------------------------------------------------------------

    DisconnectAll()
end

----------------------------------------------------------------
-- KEYBINDS
----------------------------------------------------------------

Connect(
    UserInputService.InputBegan,
    function(input, processed)

        if processed then
            return
        end

        if not Running
        or not Authenticated then
            return
        end

        --------------------------------------------------------
        -- R = FLY
        --------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.R then

            if Settings.FlyEnabled then
                StopFly()
            else
                StartFly()
            end

        end

        --------------------------------------------------------
        -- V = SPEED
        --------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.V then

            Settings.SpeedEnabled =
                not Settings.SpeedEnabled

            UpdateSpeed()

        end

        --------------------------------------------------------
        -- SPACE MOBILE/KEY
        --------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.Space then

            UpHeld = true

        end

        --------------------------------------------------------
        -- CTRL DOWN
        --------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.LeftControl then

            DownHeld = true

        end
    end
)

Connect(
    UserInputService.InputEnded,
    function(input)

        if input.KeyCode ==
            Enum.KeyCode.Space then

            UpHeld = false

        end

        if input.KeyCode ==
            Enum.KeyCode.LeftControl then

            DownHeld = false

        end
    end
)

----------------------------------------------------------------
-- MOBILE FLY BUTTONS
----------------------------------------------------------------

local function CreateMobileFlyButtons()

    if not UserInputService.TouchEnabled then
        return
    end

    if not MenuGui then
        return
    end

    local UpButton =
        New(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        1
                    ),

                Position =
                    UDim2.new(
                        1,
                        -20,
                        1,
                        -150
                    ),

                Size =
                    UDim2.fromOffset(
                        55,
                        55
                    ),

                Text = "▲",

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold,

                Visible = false
            },
            MenuGui
        )

    Corner(UpButton, 12)

    local DownButton =
        New(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        1
                    ),

                Position =
                    UDim2.new(
                        1,
                        -20,
                        1,
                        -85
                    ),

                Size =
                    UDim2.fromOffset(
                        55,
                        55
                    ),

                Text = "▼",

                TextScaled = true,

                Font =
                    Enum.Font.GothamBold,

                Visible = false
            },
            MenuGui
        )

    Corner(DownButton, 12)

    local function Refresh()

        local visible =
            Settings.FlyEnabled
            and Running

        UpButton.Visible =
            visible

        DownButton.Visible =
            visible
    end

    Connect(
        UpButton.MouseButton1Down,
        function()
            UpHeld = true
        end
    )

    Connect(
        UpButton.MouseButton1Up,
        function()
            UpHeld = false
        end
    )

    Connect(
        DownButton.MouseButton1Down,
        function()
            DownHeld = true
        end
    )

    Connect(
        DownButton.MouseButton1Up,
        function()
            DownHeld = false
        end
    )

    Connect(
        RunService.RenderStepped,
        function()
            if not Running then
                return
            end

            Refresh()
        end
    )
end

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------

Connect(
    RunService.RenderStepped,
    function(dt)

        if not Running then
            return
        end

        if not Authenticated then
            return
        end

        UpdateAim()
        UpdateFly()
        UpdateSpeed()
        UpdateJump()
        UpdateFPS(dt)

    end
)

----------------------------------------------------------------
-- ESP LOOP
----------------------------------------------------------------

task.spawn(
    function()

        while Running do

            if Authenticated
            and Settings.ESPEnabled then

                UpdateAllESP()

            end

            task.wait(0.03)
        end

    end
)

----------------------------------------------------------------
-- START
----------------------------------------------------------------

CreatePasswordUI()

----------------------------------------------------------------
-- END
----------------------------------------------------------------
