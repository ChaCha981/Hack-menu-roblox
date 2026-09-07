--// =========================================================
--// COMBAT HUB
--// Password: anakin
--// Roblox Studio LocalScript
--//
--// Features:
--// Password Lock
--// Aim Assist
--// ESP
--// Tracers
--// Fly
--// Speed Run
--// Aim Distance
--// Aim FOV
--// Aim Speed
--// ESP Distance
--// Team Check
--// Wall Check
--// Draggable UI
--// Mobile + PC
--// Close / Reopen
--// Keyboard Shortcuts
--// Respawn Support
--// =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--============================================================
-- SETTINGS
--============================================================

local PASSWORD = "anakin"

local Settings = {
    AimEnabled = false,
    AimSpeed = 25,
    AimDistance = 600,
    AimFOV = 180,
    AimPart = "Head",

    ESPEnabled = false,
    TracerEnabled = false,

    ESPDistance = 600,
    TracerThickness = 0.08,

    TeamCheck = true,
    WallCheck = true,

    FlyEnabled = false,
    FlySpeed = 50,

    SpeedEnabled = false,
    SpeedRun = 32,
}

--============================================================
-- VARIABLES
--============================================================

local Character
local Humanoid
local RootPart

local NormalWalkSpeed = 16

local FlyConnection
local SpeedConnection

local ESPObjects = {}
local TracerObjects = {}

local MainGui
local MainFrame

local FlyVelocity
local FlyAttachment

--============================================================
-- CHARACTER
--============================================================

local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")

    NormalWalkSpeed = Humanoid.WalkSpeed

    task.wait(0.2)

    if Settings.SpeedEnabled then
        Humanoid.WalkSpeed = Settings.SpeedRun
    end
end

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Settings.FlyEnabled = false

    SetupCharacter(char)

    if Settings.SpeedEnabled then
        task.wait(0.2)
        Humanoid.WalkSpeed = Settings.SpeedRun
    end
end)

--============================================================
-- UTILITY
--============================================================

local function GetCharacter(player)
    if not player then
        return nil
    end

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

    return hum and hum.Health > 0
end

local function IsEnemy(player)
    if player == LocalPlayer then
        return false
    end

    if not IsAlive(player) then
        return false
    end

    if Settings.TeamCheck then
        if LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
            return false
        end
    end

    return true
end

--============================================================
-- WALL CHECK
--============================================================

local function IsVisible(targetCharacter, targetPart)
    if not Settings.WallCheck then
        return true
    end

    if not Character then
        return false
    end

    local Camera = workspace.CurrentCamera

    if not Camera then
        return false
    end

    local Origin = Camera.CFrame.Position
    local Direction = targetPart.Position - Origin

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {
        Character
    }

    Params.IgnoreWater = true

    local Result = workspace:Raycast(
        Origin,
        Direction,
        Params
    )

    if not Result then
        return true
    end

    return Result.Instance:IsDescendantOf(targetCharacter)
end

--============================================================
-- AIM TARGET
--============================================================

local function FindAimTarget()
    local Camera = workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local ViewportSize = Camera.ViewportSize
    local Center = Vector2.new(
        ViewportSize.X / 2,
        ViewportSize.Y / 2
    )

    local BestPlayer = nil
    local BestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do

        if IsEnemy(player) then

            local char = player.Character
            local targetPart = char and char:FindFirstChild(Settings.AimPart)

            if targetPart then

                local WorldDistance =
                    (targetPart.Position - Camera.CFrame.Position).Magnitude

                if WorldDistance <= Settings.AimDistance then

                    local ScreenPosition, OnScreen =
                        Camera:WorldToViewportPoint(targetPart.Position)

                    if OnScreen then

                        local ScreenDistance =
                            (Vector2.new(
                                ScreenPosition.X,
                                ScreenPosition.Y
                            ) - Center).Magnitude

                        if ScreenDistance <= Settings.AimFOV then

                            if IsVisible(char, targetPart) then

                                if ScreenDistance < BestDistance then
                                    BestDistance = ScreenDistance
                                    BestPlayer = player
                                end

                            end
                        end
                    end
                end
            end
        end
    end

    return BestPlayer
end

--============================================================
-- AIM ASSIST
--============================================================

local function UpdateAim()
    if not Settings.AimEnabled then
        return
    end

    if not Character or not RootPart then
        return
    end

    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local Target = FindAimTarget()

    if not Target then
        return
    end

    local TargetCharacter = Target.Character

    if not TargetCharacter then
        return
    end

    local TargetPart =
        TargetCharacter:FindFirstChild(Settings.AimPart)

    if not TargetPart then
        return
    end

    local Direction =
        TargetPart.Position - Camera.CFrame.Position

    if Direction.Magnitude <= 0 then
        return
    end

    local TargetCFrame =
        CFrame.lookAt(
            Camera.CFrame.Position,
            TargetPart.Position
        )

    local Alpha =
        math.clamp(Settings.AimSpeed / 100, 0.01, 1)

    Camera.CFrame =
        Camera.CFrame:Lerp(
            TargetCFrame,
            Alpha
        )
end

--============================================================
-- ESP
--============================================================

local function RemoveESP(player)
    local Highlight = ESPObjects[player]

    if Highlight then
        Highlight:Destroy()
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    if not Settings.ESPEnabled then
        return
    end

    if not IsEnemy(player) then
        RemoveESP(player)
        return
    end

    local char = player.Character

    if not char then
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    if not Character or not RootPart then
        return
    end

    local Distance =
        (root.Position - RootPart.Position).Magnitude

    if Distance > Settings.ESPDistance then
        RemoveESP(player)
        return
    end

    if ESPObjects[player] then
        return
    end

    local Highlight = Instance.new("Highlight")

    Highlight.Name = "CombatHubESP"
    Highlight.Adornee = char

    Highlight.FillTransparency = 0.55
    Highlight.OutlineTransparency = 0

    Highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    Highlight.Parent = char

    ESPObjects[player] = Highlight
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            if Settings.ESPEnabled then
                CreateESP(player)
            else
                RemoveESP(player)
            end

        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--============================================================
-- TRACERS
--============================================================

local TracerFolder = Instance.new("Folder")
TracerFolder.Name = "CombatHubTracers"
TracerFolder.Parent = workspace

local OriginPart = Instance.new("Part")
OriginPart.Name = "TracerOrigin"
OriginPart.Anchored = true
OriginPart.CanCollide = false
OriginPart.CanTouch = false
OriginPart.CanQuery = false
OriginPart.Transparency = 1
OriginPart.Size = Vector3.new(0.1, 0.1, 0.1)
OriginPart.Parent = TracerFolder

local OriginAttachment = Instance.new("Attachment")
OriginAttachment.Parent = OriginPart

local function RemoveTracer(player)
    local Data = TracerObjects[player]

    if Data then

        if Data.Beam then
            Data.Beam:Destroy()
        end

        if Data.Attachment then
            Data.Attachment:Destroy()
        end

        TracerObjects[player] = nil
    end
end

local function CreateTracer(player)
    if player == LocalPlayer then
        return
    end

    if not Settings.TracerEnabled then
        return
    end

    if not IsEnemy(player) then
        RemoveTracer(player)
        return
    end

    local char = player.Character

    if not char then
        RemoveTracer(player)
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")

    if not root then
        RemoveTracer(player)
        return
    end

    if not Character or not RootPart then
        return
    end

    local Distance =
        (root.Position - RootPart.Position).Magnitude

    if Distance > Settings.ESPDistance then
        RemoveTracer(player)
        return
    end

    if TracerObjects[player] then
        return
    end

    local Attachment = Instance.new("Attachment")
    Attachment.Name = "TracerAttachment"
    Attachment.Parent = root

    local Beam = Instance.new("Beam")

    Beam.Name = "CombatHubTracer"

    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = Attachment

    Beam.Width0 = Settings.TracerThickness
    Beam.Width1 = Settings.TracerThickness

    Beam.FaceCamera = true

    Beam.LightEmission = 1
    Beam.LightInfluence = 0

    Beam.Transparency =
        NumberSequence.new(0.15)

    Beam.Parent = TracerFolder

    TracerObjects[player] = {
        Beam = Beam,
        Attachment = Attachment
    }
end

local function UpdateTracers()
    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    OriginPart.CFrame =
        Camera.CFrame * CFrame.new(
            0,
            -Camera.ViewportSize.Y / 200,
            0
        )

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            if Settings.TracerEnabled then
                CreateTracer(player)
            else
                RemoveTracer(player)
            end

        end
    end
end

--============================================================
-- FLY
--============================================================

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

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
    StopFly()

    if not Character or not Humanoid or not RootPart then
        return
    end

    if Humanoid.Health <= 0 then
        return
    end

    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Name = "CombatHubFlyAttachment"
    FlyAttachment.Parent = RootPart

    FlyVelocity = Instance.new("LinearVelocity")

    FlyVelocity.Name = "CombatHubFlyVelocity"

    FlyVelocity.Attachment0 = FlyAttachment

    FlyVelocity.MaxForce = math.huge

    FlyVelocity.VectorVelocity = Vector3.zero

    FlyVelocity.RelativeTo =
        Enum.ActuatorRelativeTo.World

    FlyVelocity.Parent = RootPart

    FlyConnection = RunService.RenderStepped:Connect(function()

        if not Settings.FlyEnabled then
            StopFly()
            return
        end

        if not Character or not RootPart or not Humanoid then
            return
        end

        local Camera = workspace.CurrentCamera

        if not Camera then
            return
        end

        local MoveDirection = Vector3.zero

        local Look = Camera.CFrame.LookVector
        local Right = Camera.CFrame.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection += Look
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection -= Look
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection += Right
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection -= Right
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveDirection += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            MoveDirection -= Vector3.new(0, 1, 0)
        end

        if MoveDirection.Magnitude > 0 then
            MoveDirection =
                MoveDirection.Unit * Settings.FlySpeed
        end

        FlyVelocity.VectorVelocity = MoveDirection

        Humanoid.PlatformStand = false
    end)
end

local function SetFly(state)
    Settings.FlyEnabled = state

    if state then
        StartFly()
    else
        StopFly()
    end
end

--============================================================
-- SPEED RUN
--============================================================

local function UpdateSpeed()
    if not Humanoid then
        return
    end

    if Humanoid.Health <= 0 then
        return
    end

    if Settings.SpeedEnabled then
        Humanoid.WalkSpeed = Settings.SpeedRun
    else
        Humanoid.WalkSpeed = NormalWalkSpeed
    end
end

SpeedConnection =
    RunService.Heartbeat:Connect(function()

        if Settings.SpeedEnabled then
            UpdateSpeed()
        end
    end)

--============================================================
-- PASSWORD SCREEN
--============================================================

local PasswordGui = Instance.new("ScreenGui")

PasswordGui.Name = "CombatHubPassword"
PasswordGui.ResetOnSpawn = false
PasswordGui.IgnoreGuiInset = true
PasswordGui.Parent = PlayerGui

local PasswordBackground = Instance.new("Frame")

PasswordBackground.Size = UDim2.fromScale(1, 1)
PasswordBackground.BackgroundTransparency = 0.2
PasswordBackground.BackgroundColor3 =
    Color3.fromRGB(10, 10, 14)

PasswordBackground.Parent = PasswordGui

local PasswordFrame = Instance.new("Frame")

PasswordFrame.Size =
    UDim2.fromOffset(320, 210)

PasswordFrame.Position =
    UDim2.fromScale(0.5, 0.5)

PasswordFrame.AnchorPoint =
    Vector2.new(0.5, 0.5)

PasswordFrame.BackgroundColor3 =
    Color3.fromRGB(25, 25, 32)

PasswordFrame.Parent = PasswordBackground

local PasswordCorner = Instance.new("UICorner")
PasswordCorner.CornerRadius = UDim.new(0, 14)
PasswordCorner.Parent = PasswordFrame

local PasswordTitle = Instance.new("TextLabel")

PasswordTitle.Size =
    UDim2.new(1, -30, 0, 45)

PasswordTitle.Position =
    UDim2.fromOffset(15, 12)

PasswordTitle.BackgroundTransparency = 1

PasswordTitle.Text = "COMBAT HUB"

PasswordTitle.TextColor3 =
    Color3.fromRGB(255, 255, 255)

PasswordTitle.Font =
    Enum.Font.GothamBold

PasswordTitle.TextSize = 24

PasswordTitle.Parent = PasswordFrame

local PasswordSub = Instance.new("TextLabel")

PasswordSub.Size =
    UDim2.new(1, -30, 0, 25)

PasswordSub.Position =
    UDim2.fromOffset(15, 50)

PasswordSub.BackgroundTransparency = 1

PasswordSub.Text = "Enter password to continue"

PasswordSub.TextColor3 =
    Color3.fromRGB(170, 170, 180)

PasswordSub.Font =
    Enum.Font.Gotham

PasswordSub.TextSize = 14

PasswordSub.Parent = PasswordFrame

local PasswordBox = Instance.new("TextBox")

PasswordBox.Size =
    UDim2.new(1, -40, 0, 42)

PasswordBox.Position =
    UDim2.fromOffset(20, 82)

PasswordBox.BackgroundColor3 =
    Color3.fromRGB(40, 40, 50)

PasswordBox.TextColor3 =
    Color3.fromRGB(255, 255, 255)

PasswordBox.PlaceholderText =
    "Password"

PasswordBox.PlaceholderColor3 =
    Color3.fromRGB(130, 130, 140)

PasswordBox.Text = ""

PasswordBox.TextSize = 16

PasswordBox.Font =
    Enum.Font.Gotham

PasswordBox.ClearTextOnFocus = false

PasswordBox.Parent = PasswordFrame

local PasswordBoxCorner = Instance.new("UICorner")
PasswordBoxCorner.CornerRadius = UDim.new(0, 8)
PasswordBoxCorner.Parent = PasswordBox

local UnlockButton = Instance.new("TextButton")

UnlockButton.Size =
    UDim2.new(1, -40, 0, 42)

UnlockButton.Position =
    UDim2.fromOffset(20, 130)

UnlockButton.BackgroundColor3 =
    Color3.fromRGB(65, 110, 255)

UnlockButton.Text = "UNLOCK"

UnlockButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

UnlockButton.TextSize = 16

UnlockButton.Font =
    Enum.Font.GothamBold

UnlockButton.Parent = PasswordFrame

local UnlockCorner = Instance.new("UICorner")
UnlockCorner.CornerRadius = UDim.new(0, 8)
UnlockCorner.Parent = UnlockButton

local PasswordStatus = Instance.new("TextLabel")

PasswordStatus.Size =
    UDim2.new(1, -40, 0, 25)

PasswordStatus.Position =
    UDim2.fromOffset(20, 174)

PasswordStatus.BackgroundTransparency = 1

PasswordStatus.Text = ""

PasswordStatus.TextColor3 =
    Color3.fromRGB(255, 90, 90)

PasswordStatus.TextSize = 13

PasswordStatus.Font =
    Enum.Font.Gotham

PasswordStatus.Parent = PasswordFrame

--============================================================
-- MAIN HUB
--============================================================

local function CreateMainHub()

    MainGui = Instance.new("ScreenGui")

    MainGui.Name = "CombatHub"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.Parent = PlayerGui

    MainFrame = Instance.new("Frame")

    MainFrame.Size =
        UDim2.fromOffset(330, 560)

    MainFrame.Position =
        UDim2.fromOffset(30, 100)

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(20, 20, 26)

    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    --========================================================
    -- TITLE BAR
    --========================================================

    local TitleBar = Instance.new("Frame")

    TitleBar.Size =
        UDim2.new(1, 0, 0, 55)

    TitleBar.BackgroundColor3 =
        Color3.fromRGB(30, 30, 38)

    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 14)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")

    Title.Size =
        UDim2.new(1, -70, 1, 0)

    Title.Position =
        UDim2.fromOffset(15, 0)

    Title.BackgroundTransparency = 1

    Title.Text = "⚡ COMBAT HUB"

    Title.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    Title.TextSize = 20

    Title.Font =
        Enum.Font.GothamBold

    Title.TextXAlignment =
        Enum.TextXAlignment.Left

    Title.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")

    CloseButton.Size =
        UDim2.fromOffset(40, 40)

    CloseButton.Position =
        UDim2.new(1, -48, 0, 8)

    CloseButton.BackgroundColor3 =
        Color3.fromRGB(180, 55, 55)

    CloseButton.Text = "×"

    CloseButton.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    CloseButton.TextSize = 25

    CloseButton.Font =
        Enum.Font.GothamBold

    CloseButton.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton

    --========================================================
    -- DRAGGING
    --========================================================

    local Dragging = false
    local DragStart
    local StartPosition

    TitleBar.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            Dragging = true

            DragStart = input.Position
            StartPosition = MainFrame.Position

            input.Changed:Connect(function()

                if input.UserInputState ==
                    Enum.UserInputState.End then

                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not Dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local Delta =
                input.Position - DragStart

            MainFrame.Position =
                UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset + Delta.X,
                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset + Delta.Y
                )
        end
    end)

    --========================================================
    -- SCROLL AREA
    --========================================================

    local Scroll = Instance.new("ScrollingFrame")

    Scroll.Size =
        UDim2.new(1, -16, 1, -70)

    Scroll.Position =
        UDim2.fromOffset(8, 62)

    Scroll.BackgroundTransparency = 1

    Scroll.BorderSizePixel = 0

    Scroll.ScrollBarThickness = 5

    Scroll.CanvasSize =
        UDim2.new(0, 0, 0, 850)

    Scroll.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(0, 8)

    Layout.HorizontalAlignment =
        Enum.HorizontalAlignment.Center

    Layout.Parent = Scroll

    --========================================================
    -- HELPERS
    --========================================================

    local function CreateSection(text)

        local Label = Instance.new("TextLabel")

        Label.Size =
            UDim2.new(1, -10, 0, 30)

        Label.BackgroundTransparency = 1

        Label.Text = text

        Label.TextColor3 =
            Color3.fromRGB(120, 170, 255)

        Label.TextSize = 15

        Label.Font =
            Enum.Font.GothamBold

        Label.TextXAlignment =
            Enum.TextXAlignment.Left

        Label.Parent = Scroll

        return Label
    end

    local function CreateToggle(text, callback)

        local Button = Instance.new("TextButton")

        Button.Size =
            UDim2.new(1, -10, 0, 42)

        Button.BackgroundColor3 =
            Color3.fromRGB(40, 40, 50)

        Button.TextColor3 =
            Color3.fromRGB(255, 255, 255)

        Button.TextSize = 14

        Button.Font =
            Enum.Font.GothamSemibold

        Button.TextXAlignment =
            Enum.TextXAlignment.Left

        Button.Text = text .. ": OFF"

        Button.Parent = Scroll

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Button

        local State = false

        local function Refresh()

            if State then
                Button.Text =
                    text .. ": ON"

                Button.BackgroundColor3 =
                    Color3.fromRGB(55, 120, 75)
            else
                Button.Text =
                    text .. ": OFF"

                Button.BackgroundColor3 =
                    Color3.fromRGB(40, 40, 50)
            end
        end

        Button.Activated:Connect(function()

            State = not State

            Refresh()

            callback(State)
        end)

        return Button
    end

    local function CreateNumberInput(text, default, callback)

        local Holder = Instance.new("Frame")

        Holder.Size =
            UDim2.new(1, -10, 0, 42)

        Holder.BackgroundColor3 =
            Color3.fromRGB(40, 40, 50)

        Holder.Parent = Scroll

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Holder

        local Label = Instance.new("TextLabel")

        Label.Size =
            UDim2.new(0.55, 0, 1, 0)

        Label.Position =
            UDim2.fromOffset(12, 0)

        Label.BackgroundTransparency = 1

        Label.Text = text

        Label.TextColor3 =
            Color3.fromRGB(255, 255, 255)

        Label.TextSize = 13

        Label.Font =
            Enum.Font.Gotham

        Label.TextXAlignment =
            Enum.TextXAlignment.Left

        Label.Parent = Holder

        local Box = Instance.new("TextBox")

        Box.Size =
            UDim2.new(0.35, 0, 0, 30)

        Box.Position =
            UDim2.new(0.62, 0, 0.5, -15)

        Box.BackgroundColor3 =
            Color3.fromRGB(25, 25, 32)

        Box.TextColor3 =
            Color3.fromRGB(255, 255, 255)

        Box.TextSize = 13

        Box.Font =
            Enum.Font.Gotham

        Box.Text =
            tostring(default)

        Box.ClearTextOnFocus = false

        Box.Parent = Holder

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 6)
        BoxCorner.Parent = Box

        Box.FocusLost:Connect(function()

            local Number =
                tonumber(Box.Text)

            if Number then
                callback(Number)
            else
                Box.Text =
                    tostring(default)
            end
        end)

        return Box
    end

    --========================================================
    -- AIM
    --========================================================

    CreateSection("🎯 AIM")

    CreateToggle("Aim Assist", function(state)

        Settings.AimEnabled = state

    end)

    CreateNumberInput(
        "Aim Speed",
        Settings.AimSpeed,
        function(value)

            Settings.AimSpeed =
                math.clamp(value, 1, 100)

        end
    )

    CreateNumberInput(
        "Aim Distance",
        Settings.AimDistance,
        function(value)

            Settings.AimDistance =
                math.clamp(value, 10, 5000)

        end
    )

    CreateNumberInput(
        "Aim FOV",
        Settings.AimFOV,
        function(value)

            Settings.AimFOV =
                math.clamp(value, 10, 1000)

        end
    )

    --========================================================
    -- ESP
    --========================================================

    CreateSection("👁 ESP")

    CreateToggle("ESP", function(state)

        Settings.ESPEnabled = state

        if not state then

            for player in pairs(ESPObjects) do
                RemoveESP(player)
            end

        end

    end)

    CreateToggle("Tracers", function(state)

        Settings.TracerEnabled = state

        if not state then

            for player in pairs(TracerObjects) do
                RemoveTracer(player)
            end

        end

    end)

    CreateNumberInput(
        "ESP Distance",
        Settings.ESPDistance,
        function(value)

            Settings.ESPDistance =
                math.clamp(value, 10, 5000)

        end
    )

    --========================================================
    -- CHECKS
    --========================================================

    CreateSection("🛡 CHECKS")

    CreateToggle("Team Check", function(state)

        Settings.TeamCheck = state

    end)

    CreateToggle("Wall Check", function(state)

        Settings.WallCheck = state

    end)

    --========================================================
    -- MOVEMENT
    --========================================================

    CreateSection("🏃 MOVEMENT")

    CreateToggle("Speed Run", function(state)

        Settings.SpeedEnabled = state

        UpdateSpeed()

    end)

    CreateNumberInput(
        "Run Speed",
        Settings.SpeedRun,
        function(value)

            Settings.SpeedRun =
                math.clamp(value, 16, 500)

            if Settings.SpeedEnabled then
                UpdateSpeed()
            end

        end
    )

    CreateToggle("Fly", function(state)

        SetFly(state)

    end)

    CreateNumberInput(
        "Fly Speed",
        Settings.FlySpeed,
        function(value)

            Settings.FlySpeed =
                math.clamp(value, 1, 500)

        end
    )

    --========================================================
    -- INFO
    --========================================================

    CreateSection("⌨ CONTROLS")

    local Info = Instance.new("TextLabel")

    Info.Size =
        UDim2.new(1, -10, 0, 80)

    Info.BackgroundColor3 =
        Color3.fromRGB(30, 30, 38)

    Info.Text =
        "R = Toggle Fly\n" ..
        "V = Toggle Speed Run\n" ..
        "WASD = Fly Movement\n" ..
        "SPACE = Up\n" ..
        "LEFT CTRL = Down"

    Info.TextColor3 =
        Color3.fromRGB(190, 190, 200)

    Info.TextSize = 13

    Info.Font =
        Enum.Font.Gotham

    Info.TextWrapped = true

    Info.Parent = Scroll

    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 8)
    InfoCorner.Parent = Info

    --========================================================
    -- CLOSE / REOPEN
    --========================================================

    CloseButton.Activated:Connect(function()

        MainFrame.Visible = false

    end)

    local ReopenButton = Instance.new("TextButton")

    ReopenButton.Size =
        UDim2.fromOffset(65, 65)

    ReopenButton.Position =
        UDim2.new(0, 20, 0.5, -32)

    ReopenButton.BackgroundColor3 =
        Color3.fromRGB(50, 100, 220)

    ReopenButton.Text = "HUB"

    ReopenButton.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    ReopenButton.TextSize = 15

    ReopenButton.Font =
        Enum.Font.GothamBold

    ReopenButton.Parent = MainGui

    local ReopenCorner = Instance.new("UICorner")
    ReopenCorner.CornerRadius = UDim.new(1, 0)
    ReopenCorner.Parent = ReopenButton

    ReopenButton.Activated:Connect(function()

        MainFrame.Visible = true

    end)
end

--============================================================
-- PASSWORD CHECK
--============================================================

local function Unlock()

    if PasswordBox.Text == PASSWORD then

        PasswordGui:Destroy()

        CreateMainHub()

    else

        PasswordStatus.Text =
            "❌ Wrong password"

        PasswordBox.Text = ""

        task.delay(1.5, function()

            if PasswordStatus then
                PasswordStatus.Text = ""
            end

        end)
    end
end

UnlockButton.Activated:Connect(Unlock)

PasswordBox.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        Unlock()
    end

end)

--============================================================
-- KEYBOARD
--============================================================

UserInputService.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.R then

        SetFly(not Settings.FlyEnabled)

    elseif input.KeyCode == Enum.KeyCode.V then

        Settings.SpeedEnabled =
            not Settings.SpeedEnabled

        UpdateSpeed()
    end
end)

--============================================================
-- MAIN LOOP
--============================================================

RunService.RenderStepped:Connect(function()

    if Settings.AimEnabled then
        UpdateAim()
    end

    UpdateESP()
    UpdateTracers()

end)

print("================================")
print("Combat Hub loaded")
print("Password: anakin")
print("R = Fly")
print("V = Speed Run")
print("================================")