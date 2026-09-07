--// XEIREN 5V5 COMBAT HUB
--// Roblox Studio LocalScript
--// Place in StarterPlayer > StarterPlayerScripts
--// Password: anakin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    Language = "EN",

    AimEnabled = false,
    Full360 = true,
    LockStrength = 85,
    AimSpeed = 30,
    AimDistance = 600,
    AimFOV = 180,
    AimPart = "Head",

    ESPEnabled = false,

    -- Clean ESP
    ESPCloud = true,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPLine = true,

    ESPAlwaysOnTop = true,
    ESPTeamColor = false,
    ESPMaxDistance = 600,

    TeamCheck = true,
    WallCheck = false,

    FlyEnabled = false,
    FlySpeed = 70,
    FlyVerticalSpeed = 60,

    SpeedEnabled = false,
    SpeedRun = 32,

    NoRecoil = false,
    NoReload = false,

    FPSBoost = true,
    DynamicFPS = true,
    ShowFPS = true,

    ESPUpdateRate = 12,
}

--==================================================
-- CHARACTER
--==================================================

local Character
local Humanoid
local Root

local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    Root = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    SetupCharacter(char)

    task.wait(0.5)

    if Settings.FlyEnabled then
        StopFly()
    end

    if Settings.SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = Settings.SpeedRun
    end
end)

--==================================================
-- WEAPON CONFIG
--==================================================

local WeaponConfig = ReplicatedStorage:FindFirstChild("XeirenWeaponConfig")

if not WeaponConfig then
    WeaponConfig = Instance.new("Folder")
    WeaponConfig.Name = "XeirenWeaponConfig"
    WeaponConfig.Parent = ReplicatedStorage
end

local function UpdateWeaponConfig()
    WeaponConfig:SetAttribute("NoRecoil", Settings.NoRecoil)
    WeaponConfig:SetAttribute("NoReload", Settings.NoReload)
end

UpdateWeaponConfig()

--==================================================
-- GUI
--==================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OldGui = PlayerGui:FindFirstChild("XeirenCombatHub")
if OldGui then
    OldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XeirenCombatHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 24)
local BG2 = Color3.fromRGB(25, 25, 33)
local ACCENT = Color3.fromRGB(120, 80, 255)
local TEXT = Color3.fromRGB(245, 245, 250)
local SUBTEXT = Color3.fromRGB(170, 170, 185)
local ON = Color3.fromRGB(80, 220, 120)
local OFF = Color3.fromRGB(220, 70, 80)

--==================================================
-- PASSWORD UI
--==================================================

local PasswordFrame = Instance.new("Frame")
PasswordFrame.Size = UDim2.fromOffset(300, 180)
PasswordFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
PasswordFrame.BackgroundColor3 = BG
PasswordFrame.BorderSizePixel = 0
PasswordFrame.Parent = ScreenGui

local PasswordCorner = Instance.new("UICorner")
PasswordCorner.CornerRadius = UDim.new(0, 14)
PasswordCorner.Parent = PasswordFrame

local PasswordStroke = Instance.new("UIStroke")
PasswordStroke.Color = ACCENT
PasswordStroke.Thickness = 1.5
PasswordStroke.Parent = PasswordFrame

local PasswordTitle = Instance.new("TextLabel")
PasswordTitle.Size = UDim2.new(1, -20, 0, 35)
PasswordTitle.Position = UDim2.fromOffset(10, 12)
PasswordTitle.BackgroundTransparency = 1
PasswordTitle.Text = "XEIREN"
PasswordTitle.TextColor3 = TEXT
PasswordTitle.Font = Enum.Font.GothamBold
PasswordTitle.TextSize = 22
PasswordTitle.Parent = PasswordFrame

local PasswordSub = Instance.new("TextLabel")
PasswordSub.Size = UDim2.new(1, -20, 0, 25)
PasswordSub.Position = UDim2.fromOffset(10, 48)
PasswordSub.BackgroundTransparency = 1
PasswordSub.Text = "Enter password"
PasswordSub.TextColor3 = SUBTEXT
PasswordSub.Font = Enum.Font.Gotham
PasswordSub.TextSize = 13
PasswordSub.Parent = PasswordFrame

local PasswordBox = Instance.new("TextBox")
PasswordBox.Size = UDim2.new(1, -40, 0, 38)
PasswordBox.Position = UDim2.fromOffset(20, 78)
PasswordBox.BackgroundColor3 = BG2
PasswordBox.BorderSizePixel = 0
PasswordBox.PlaceholderText = "Password"
PasswordBox.Text = ""
PasswordBox.TextColor3 = TEXT
PasswordBox.PlaceholderColor3 = SUBTEXT
PasswordBox.Font = Enum.Font.Gotham
PasswordBox.TextSize = 14
PasswordBox.ClearTextOnFocus = false
PasswordBox.Parent = PasswordFrame

local PasswordBoxCorner = Instance.new("UICorner")
PasswordBoxCorner.CornerRadius = UDim.new(0, 8)
PasswordBoxCorner.Parent = PasswordBox

local EnterButton = Instance.new("TextButton")
EnterButton.Size = UDim2.new(1, -40, 0, 35)
EnterButton.Position = UDim2.fromOffset(20, 128)
EnterButton.BackgroundColor3 = ACCENT
EnterButton.BorderSizePixel = 0
EnterButton.Text = "ENTER"
EnterButton.TextColor3 = Color3.new(1, 1, 1)
EnterButton.Font = Enum.Font.GothamBold
EnterButton.TextSize = 13
EnterButton.Parent = PasswordFrame

local EnterCorner = Instance.new("UICorner")
EnterCorner.CornerRadius = UDim.new(0, 8)
EnterCorner.Parent = EnterButton

--==================================================
-- MAIN HUB
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(355, 500)
MainFrame.Position = UDim2.new(0.5, -177, 0.5, -250)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT
MainStroke.Thickness = 1.3
MainStroke.Parent = MainFrame

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "XEIREN 5V5"
Title.TextColor3 = TEXT
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local LanguageButton = Instance.new("TextButton")
LanguageButton.Size = UDim2.fromOffset(45, 28)
LanguageButton.Position = UDim2.new(1, -95, 0, 13)
LanguageButton.BackgroundColor3 = BG2
LanguageButton.BorderSizePixel = 0
LanguageButton.Text = "EN"
LanguageButton.TextColor3 = TEXT
LanguageButton.Font = Enum.Font.GothamBold
LanguageButton.TextSize = 11
LanguageButton.Parent = Header

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 7)
LangCorner.Parent = LanguageButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(35, 28)
CloseButton.Position = UDim2.new(1, -45, 0, 13)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = TEXT
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseButton

--==================================================
-- SCROLL
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -14, 1, -65)
Scroll.Position = UDim2.fromOffset(7, 58)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = ACCENT
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 4)
Padding.PaddingRight = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 12)
Padding.Parent = Scroll

--==================================================
-- LANGUAGE
--==================================================

local Texts = {
    EN = {
        aim = "Aim Assist",
        full360 = "360° Lock",
        strength = "Lock Strength",
        speed = "Aim Speed",
        distance = "Aim Distance",
        fov = "Aim FOV",
        target = "Target",
        head = "Head",
        body = "Body",

        esp = "ESP",
        cloud = "Cloud ESP",
        box = "ESP Box",
        name = "ESP Name",
        health = "ESP Health",
        espdistance = "ESP Distance",
        line = "ESP Line",
        teamcolor = "Team Color",
        always = "Always On Top",
        espmax = "ESP Max Distance",

        teamcheck = "Team Check",
        wallcheck = "Wall Check",

        fly = "Fly",
        flyspeed = "Fly Speed",
        flyvertical = "Fly Vertical Speed",

        run = "Speed Run",
        runspeed = "Run Speed",

        norecoil = "No Recoil",
        noreload = "No Reload",

        fps = "FPS Boost",
        dynamic = "Dynamic Optimization",
        showfps = "Show FPS",

        close = "Close",
    },

    KM = {
        aim = "ជំនួយ Aim",
        full360 = "ចាក់សោ 360°",
        strength = "កម្លាំង Lock",
        speed = "ល្បឿន Aim",
        distance = "ចម្ងាយ Aim",
        fov = "Aim FOV",
        target = "គោលដៅ",
        head = "ក្បាល",
        body = "ខ្លួន",

        esp = "ESP",
        cloud = "Cloud ESP",
        box = "ESP Box",
        name = "ឈ្មោះ ESP",
        health = "HP ESP",
        espdistance = "ចម្ងាយ ESP",
        line = "ESP Line",
        teamcolor = "ពណ៌តាម Team",
        always = "បង្ហាញពីក្រោយជញ្ជាំង",
        espmax = "ចម្ងាយ ESP អតិបរមា",

        teamcheck = "ពិនិត្យ Team",
        wallcheck = "ពិនិត្យជញ្ជាំង",

        fly = "ហោះ",
        flyspeed = "ល្បឿនហោះ",
        flyvertical = "ល្បឿនឡើងចុះ",

        run = "រត់លឿន",
        runspeed = "ល្បឿនរត់",

        norecoil = "គ្មាន Recoil",
        noreload = "គ្មាន Reload",

        fps = "បង្កើន FPS",
        dynamic = "Optimization ស្វ័យប្រវត្តិ",
        showfps = "បង្ហាញ FPS",

        close = "បិទ",
    }
}

local function T(key)
    return Texts[Settings.Language][key] or key
end

--==================================================
-- UI HELPERS
--==================================================

local Controls = {}

local function CreateSection(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -8, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ACCENT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Scroll

    return Label
end

local function CreateToggle(key, setting)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 38)
    Button.BackgroundColor3 = BG2
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Text = ""
    Button.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local State = Instance.new("TextLabel")
    State.Size = UDim2.fromOffset(45, 25)
    State.Position = UDim2.new(1, -52, 0.5, -12)
    State.BackgroundColor3 = OFF
    State.BorderSizePixel = 0
    State.TextColor3 = Color3.new(1, 1, 1)
    State.Font = Enum.Font.GothamBold
    State.TextSize = 10
    State.Parent = Button

    local StateCorner = Instance.new("UICorner")
    StateCorner.CornerRadius = UDim.new(0, 6)
    StateCorner.Parent = State

    local function Refresh()
        Label.Text = T(key)

        if Settings[setting] then
            State.Text = "ON"
            State.BackgroundColor3 = ON
        else
            State.Text = "OFF"
            State.BackgroundColor3 = OFF
        end
    end

    Button.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]

        if setting == "NoRecoil" or setting == "NoReload" then
            UpdateWeaponConfig()
        end

        Refresh()
    end)

    Controls[#Controls + 1] = Refresh
    Refresh()

    return Button
end

local function CreateSlider(key, setting, min, max, step)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -8, 0, 58)
    Frame.BackgroundColor3 = BG2
    Frame.BorderSizePixel = 0
    Frame.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 24)
    Label.Position = UDim2.fromOffset(10, 3)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 6)
    Bar.Position = UDim2.fromOffset(10, 37)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = ACCENT
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local dragging = false

    local function SetFromX(x)
        local pct = math.clamp(
            (x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0,
            1
        )

        local value = min + (max - min) * pct

        if step then
            value = math.floor(value / step + 0.5) * step
        end

        Settings[setting] = value
    end

    local function Refresh()
        Label.Text = T(key) .. ": " .. tostring(math.floor(Settings[setting]))

        local pct = (Settings[setting] - min) / (max - min)
        Fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetFromX(input.Position.X)
            Refresh()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            SetFromX(input.Position.X)
            Refresh()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Controls[#Controls + 1] = Refresh
    Refresh()

    return Frame
end

local function CreateButton(text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 36)
    Button.BackgroundColor3 = BG2
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = TEXT
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 12
    Button.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    return Button
end

--==================================================
-- MENU
--==================================================

CreateSection("AIM")

CreateToggle("aim", "AimEnabled")
CreateToggle("full360", "Full360")
CreateSlider("strength", "LockStrength", 1, 100, 1)
CreateSlider("speed", "AimSpeed", 1, 100, 1)
CreateSlider("distance", "AimDistance", 50, 1000, 10)
CreateSlider("fov", "AimFOV", 10, 180, 5)

local TargetButton = CreateButton("Target: Head")

TargetButton.MouseButton1Click:Connect(function()
    if Settings.AimPart == "Head" then
        Settings.AimPart = "Body"
    else
        Settings.AimPart = "Head"
    end

    TargetButton.Text = T("target") .. ": " ..
        (Settings.AimPart == "Head" and T("head") or T("body"))
end)

CreateSection("ESP")

CreateToggle("esp", "ESPEnabled")
CreateToggle("cloud", "ESPCloud")
CreateToggle("box", "ESPBox")
CreateToggle("name", "ESPName")
CreateToggle("health", "ESPHealth")
CreateToggle("espdistance", "ESPDistance")
CreateToggle("line", "ESPLine")
CreateToggle("teamcolor", "ESPTeamColor")
CreateToggle("always", "ESPAlwaysOnTop")
CreateSlider("espmax", "ESPMaxDistance", 50, 1000, 10)

CreateSection("CHECKS")

CreateToggle("teamcheck", "TeamCheck")
CreateToggle("wallcheck", "WallCheck")

CreateSection("MOVEMENT")

CreateToggle("fly", "FlyEnabled")
CreateSlider("flyspeed", "FlySpeed", 10, 200, 5)
CreateSlider("flyvertical", "FlyVerticalSpeed", 10, 200, 5)

CreateToggle("run", "SpeedEnabled")
CreateSlider("runspeed", "SpeedRun", 16, 100, 1)

CreateSection("WEAPON")

CreateToggle("norecoil", "NoRecoil")
CreateToggle("noreload", "NoReload")

CreateSection("PERFORMANCE")

CreateToggle("fps", "FPSBoost")
CreateToggle("dynamic", "DynamicFPS")
CreateToggle("showfps", "ShowFPS")

--==================================================
-- TARGET BUTTON LANGUAGE REFRESH
--==================================================

table.insert(Controls, function()
    TargetButton.Text = T("target") .. ": " ..
        (Settings.AimPart == "Head" and T("head") or T("body"))
end)

--==================================================
-- XE LOGO
--==================================================

local LogoButton = Instance.new("TextButton")
LogoButton.Size = UDim2.fromOffset(48, 48)
LogoButton.Position = UDim2.new(0, 15, 0.5, -24)
LogoButton.BackgroundColor3 = ACCENT
LogoButton.BorderSizePixel = 0
LogoButton.Text = "XE"
LogoButton.TextColor3 = Color3.new(1, 1, 1)
LogoButton.Font = Enum.Font.GothamBlack
LogoButton.TextSize = 16
LogoButton.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.new(1, 1, 1)
LogoStroke.Transparency = 0.7
LogoStroke.Parent = LogoButton

--==================================================
-- DRAG LOGO
--==================================================

local draggingLogo = false
local dragStart
local startPosition
local movedLogo = false

LogoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingLogo = true
        movedLogo = false
        dragStart = input.Position
        startPosition = LogoButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingLogo = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingLogo then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            movedLogo = true
        end

        LogoButton.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

LogoButton.MouseButton1Click:Connect(function()
    if movedLogo then
        return
    end

    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

--==================================================
-- LANGUAGE BUTTON
--==================================================

LanguageButton.MouseButton1Click:Connect(function()
    if Settings.Language == "EN" then
        Settings.Language = "KM"
        LanguageButton.Text = "ខ្មែរ"
    else
        Settings.Language = "EN"
        LanguageButton.Text = "EN"
    end

    for _, refresh in ipairs(Controls) do
        refresh()
    end
end)

--==================================================
-- PASSWORD
--==================================================

local Unlocked = false

local function Unlock()
    if PasswordBox.Text == "anakin" then
        Unlocked = true

        PasswordFrame.Visible = false
        MainFrame.Visible = true
    else
        PasswordBox.Text = ""

        local original = PasswordFrame.Position

        local tween1 = TweenService:Create(
            PasswordFrame,
            TweenInfo.new(0.05),
            {Position = original + UDim2.fromOffset(8, 0)}
        )

        local tween2 = TweenService:Create(
            PasswordFrame,
            TweenInfo.new(0.05),
            {Position = original}
        )

        tween1:Play()
        tween1.Completed:Wait()
        tween2:Play()
    end
end

EnterButton.MouseButton1Click:Connect(Unlock)

PasswordBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        Unlock()
    end
end)

--==================================================
-- AIM ASSIST
--==================================================

local function IsEnemy(player)
    if player == LocalPlayer then
        return false
    end

    if Settings.TeamCheck and LocalPlayer.Team ~= nil then
        if player.Team == LocalPlayer.Team then
            return false
        end
    end

    return true
end

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

local function HasLineOfSight(part)
    if not Settings.WallCheck then
        return true
    end

    if not part or not Camera then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

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

    return result.Instance:IsDescendantOf(part.Parent)
end

local function GetBestTarget()
    if not Camera then
        return nil
    end

    local bestPart
    local bestScore = math.huge

    local viewport = Camera.ViewportSize
    local screenCenter = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local part = GetAimPart(character)

            if humanoid and humanoid.Health > 0 and part then
                local distance = (part.Position - Camera.CFrame.Position).Magnitude

                if distance <= Settings.AimDistance then
                    local screenPos, visible =
                        Camera:WorldToViewportPoint(part.Position)

                    if visible and screenPos.Z > 0 then
                        local screenDistance = (
                            Vector2.new(screenPos.X, screenPos.Y)
                            - screenCenter
                        ).Magnitude

                        local radius =
                            math.min(viewport.X, viewport.Y)
                            * (Settings.AimFOV / 180)
                            * 0.5

                        local allowed = Settings.Full360
                            or screenDistance <= radius

                        if allowed and HasLineOfSight(part) then
                            local score = Settings.Full360
                                and distance
                                or screenDistance

                            if score < bestScore then
                                bestScore = score
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPart
end

--==================================================
-- CLEAN ESP SYSTEM
--==================================================

local ESPObjects = {}

local function GetESPColor(player)
    if Settings.ESPTeamColor and player.Team then
        return player.Team.TeamColor.Color
    end

    return Color3.fromRGB(255, 80, 90)
end

local function RemoveESP(player)
    local data = ESPObjects[player]

    if not data then
        return
    end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            if object.Parent then
                object:Destroy()
            end
        end
    end

    ESPObjects[player] = nil
end

local function CreateESP(player)
    if player == LocalPlayer then
        return nil
    end

    if ESPObjects[player] then
        return ESPObjects[player]
    end

    local data = {}

    --==============================================
    -- HIGHLIGHT / BOX
    --==============================================

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "XE_ESP_Highlight"
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillTransparency = 0.82
    Highlight.OutlineTransparency = 0
    Highlight.Enabled = false
    Highlight.Parent = ScreenGui

    data.Highlight = Highlight

    --==============================================
    -- NAME + DISTANCE + HP
    --==============================================

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "XE_ESP_Info"
    Billboard.Size = UDim2.fromOffset(180, 60)
    Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false
    Billboard.Parent = ScreenGui

    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.fromScale(1, 1)
    InfoFrame.BackgroundTransparency = 1
    InfoFrame.Parent = Billboard

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 20)
    NameLabel.Position = UDim2.fromOffset(0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = TEXT
    NameLabel.TextStrokeTransparency = 0.2
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 13
    NameLabel.Text = ""
    NameLabel.Parent = InfoFrame

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Size = UDim2.new(1, 0, 0, 18)
    DistanceLabel.Position = UDim2.fromOffset(0, 20)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
    DistanceLabel.TextStrokeTransparency = 0.3
    DistanceLabel.Font = Enum.Font.Gotham
    DistanceLabel.TextSize = 11
    DistanceLabel.Text = ""
    DistanceLabel.Parent = InfoFrame

    local HPLabel = Instance.new("TextLabel")
    HPLabel.Size = UDim2.new(1, 0, 0, 18)
    HPLabel.Position = UDim2.fromOffset(0, 38)
    HPLabel.BackgroundTransparency = 1
    HPLabel.TextColor3 = ON
    HPLabel.TextStrokeTransparency = 0.3
    HPLabel.Font = Enum.Font.GothamBold
    HPLabel.TextSize = 11
    HPLabel.Text = ""
    HPLabel.Parent = InfoFrame

    data.Billboard = Billboard
    data.NameLabel = NameLabel
    data.DistanceLabel = DistanceLabel
    data.HPLabel = HPLabel

    --==============================================
    -- HEAD MARKER
    --==============================================

    local HeadMarker = Instance.new("BillboardGui")
    HeadMarker.Name = "XE_ESP_Head"
    HeadMarker.Size = UDim2.fromOffset(25, 25)
    HeadMarker.AlwaysOnTop = true
    HeadMarker.Enabled = false
    HeadMarker.Parent = ScreenGui

    local HeadText = Instance.new("TextLabel")
    HeadText.Size = UDim2.fromScale(1, 1)
    HeadText.BackgroundTransparency = 1
    HeadText.Text = "●"
    HeadText.TextColor3 = Color3.fromRGB(255, 90, 90)
    HeadText.TextStrokeTransparency = 0
    HeadText.Font = Enum.Font.GothamBold
    HeadText.TextSize = 14
    HeadText.Parent = HeadMarker

    data.HeadMarker = HeadMarker

    ESPObjects[player] = data

    return data
end

--==================================================
-- CLOUD ESP
--==================================================

local CloudGui = Instance.new("ScreenGui")
CloudGui.Name = "XeirenCloudESP"
CloudGui.ResetOnSpawn = false
CloudGui.IgnoreGuiInset = true
CloudGui.DisplayOrder = 20
CloudGui.Parent = PlayerGui

local CloudAnchor = Instance.new("Frame")
CloudAnchor.Size = UDim2.fromOffset(2, 2)
CloudAnchor.Position = UDim2.new(0.5, 0, 0, 75)
CloudAnchor.BackgroundTransparency = 1
CloudAnchor.Visible = false
CloudAnchor.Parent = CloudGui

local CloudText = Instance.new("TextLabel")
CloudText.Size = UDim2.fromOffset(60, 40)
CloudText.Position = UDim2.fromOffset(-30, -20)
CloudText.BackgroundTransparency = 1
CloudText.Text = "☁"
CloudText.TextColor3 = Color3.fromRGB(255, 255, 255)
CloudText.TextStrokeTransparency = 0
CloudText.Font = Enum.Font.GothamBold
CloudText.TextSize = 28
CloudText.Parent = CloudAnchor

local CloudLines = {}

local function GetCloudLine(index)
    if CloudLines[index] then
        return CloudLines[index]
    end

    local line = Instance.new("Frame")
    line.Name = "XE_CloudLine_" .. index
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 80, 90)
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(1, 1)
    line.Visible = false
    line.Parent = CloudGui

    CloudLines[index] = line

    return line
end

local function DrawLine(line, fromPos, toPos, thickness)
    local delta = toPos - fromPos
    local length = delta.Magnitude

    if length < 2 then
        line.Visible = false
        return
    end

    line.Visible = true
    line.Position = UDim2.fromOffset(
        fromPos.X,
        fromPos.Y
    )

    line.Size = UDim2.fromOffset(
        length,
        thickness or 1
    )

    line.Rotation = math.deg(
        math.atan2(delta.Y, delta.X)
    )
end

local function ClearCloudLines()
    for _, line in pairs(CloudLines) do
        line.Visible = false
    end
end

local function UpdateCloudESP()
    if not Settings.ESPEnabled or not Settings.ESPCloud then
        CloudAnchor.Visible = false
        ClearCloudLines()
        return
    end

    CloudAnchor.Visible = true

    local viewport = Camera.ViewportSize

    local cloudPos = Vector2.new(
        viewport.X / 2,
        75
    )

    local index = 0

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then

            local character = player.Character
            local humanoid =
                character and character:FindFirstChildOfClass("Humanoid")

            local root =
                character and character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and root then

                local distance =
                    (root.Position - Camera.CFrame.Position).Magnitude

                if distance <= Settings.ESPMaxDistance then

                    local screenPos, visible =
                        Camera:WorldToViewportPoint(root.Position)

                    if visible and screenPos.Z > 0 then

                        index += 1

                        local line = GetCloudLine(index)

                        line.BackgroundColor3 =
                            GetESPColor(player)

                        DrawLine(
                            line,
                            cloudPos,
                            Vector2.new(screenPos.X, screenPos.Y),
                            2
                        )
                    end
                end
            end
        end
    end

    for i = index + 1, #CloudLines do
        CloudLines[i].Visible = false
    end
end

--==================================================
-- ESP UPDATE
--==================================================

local function UpdateESP()
    if not Settings.ESPEnabled then

        for player in pairs(ESPObjects) do
            local data = ESPObjects[player]

            if data then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
                data.HeadMarker.Enabled = false
            end
        end

        UpdateCloudESP()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local data = CreateESP(player)

            local character = player.Character
            local humanoid =
                character and character:FindFirstChildOfClass("Humanoid")

            local root =
                character and character:FindFirstChild("HumanoidRootPart")

            local head =
                character and character:FindFirstChild("Head")

            local valid = true

            if not IsEnemy(player) then
                valid = false
            end

            if not humanoid or humanoid.Health <= 0 then
                valid = false
            end

            if not root then
                valid = false
            end

            if valid then

                local distance =
                    (root.Position - Camera.CFrame.Position).Magnitude

                if distance > Settings.ESPMaxDistance then
                    valid = false
                end

                if Settings.WallCheck and not HasLineOfSight(root) then
                    valid = false
                end
            end

            if valid then

                local color = GetESPColor(player)

                --==================================
                -- BOX
                --==================================

                if Settings.ESPBox then
                    data.Highlight.Enabled = true
                    data.Highlight.Adornee = character
                    data.Highlight.FillColor = color
                    data.Highlight.OutlineColor = color
                    data.Highlight.DepthMode =
                        Settings.ESPAlwaysOnTop
                        and Enum.HighlightDepthMode.AlwaysOnTop
                        or Enum.HighlightDepthMode.Occluded
                else
                    data.Highlight.Enabled = false
                end

                --==================================
                -- INFO
                --==================================

                if Settings.ESPName
                    or Settings.ESPDistance
                    or Settings.ESPHealth then

                    data.Billboard.Enabled = true
                    data.Billboard.Adornee =
                        head or root

                    data.NameLabel.Visible =
                        Settings.ESPName

                    data.DistanceLabel.Visible =
                        Settings.ESPDistance

                    data.HPLabel.Visible =
                        Settings.ESPHealth

                    data.NameLabel.Text =
                        player.DisplayName ~= ""
                        and player.DisplayName
                        or player.Name

                    data.NameLabel.TextColor3 = color

                    data.DistanceLabel.Text =
                        math.floor(distance) .. " studs"

                    data.HPLabel.Text =
                        "HP: "
                        .. math.floor(humanoid.Health)
                        .. " / "
                        .. math.floor(humanoid.MaxHealth)

                    local hpPercent =
                        math.clamp(
                            humanoid.Health /
                            math.max(humanoid.MaxHealth, 1),
                            0,
                            1
                        )

                    data.HPLabel.TextColor3 =
                        Color3.new(
                            1 - hpPercent,
                            hpPercent,
                            0
                        )

                else
                    data.Billboard.Enabled = false
                end

                --==================================
                -- HEAD MARKER
                --==================================

                if head then
                    data.HeadMarker.Enabled = true
                    data.HeadMarker.Adornee = head
                    data.HeadMarker.Enabled = Settings.ESPBox
                else
                    data.HeadMarker.Enabled = false
                end

            else

                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
                data.HeadMarker.Enabled = false
            end
        end
    end

    UpdateCloudESP()
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--==================================================
-- NORMAL ESP LINE
--==================================================

local ESPLineGui = Instance.new("ScreenGui")
ESPLineGui.Name = "XeirenESPLine"
ESPLineGui.ResetOnSpawn = false
ESPLineGui.IgnoreGuiInset = true
ESPLineGui.DisplayOrder = 19
ESPLineGui.Parent = PlayerGui

local ESPLines = {}

local function GetNormalLine(player)
    if ESPLines[player] then
        return ESPLines[player]
    end

    local line = Instance.new("Frame")
    line.Name = "XE_Line"
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 80, 90)
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(1, 1)
    line.Visible = false
    line.Parent = ESPLineGui

    ESPLines[player] = line

    return line
end

local function UpdateNormalLines()
    if not Settings.ESPEnabled
        or not Settings.ESPLine
        or Settings.ESPCloud then

        for _, line in pairs(ESPLines) do
            line.Visible = false
        end

        return
    end

    local viewport = Camera.ViewportSize

    local origin = Vector2.new(
        viewport.X / 2,
        viewport.Y
    )

    for _, player in ipairs(Players:GetPlayers()) do

        if IsEnemy(player) then

            local character = player.Character
            local root =
                character and character:FindFirstChild("HumanoidRootPart")

            local humanoid =
                character and character:FindFirstChildOfClass("Humanoid")

            local line = GetNormalLine(player)

            if root
                and humanoid
                and humanoid.Health > 0 then

                local distance =
                    (root.Position - Camera.CFrame.Position).Magnitude

                if distance <= Settings.ESPMaxDistance then

                    local pos, visible =
                        Camera:WorldToViewportPoint(root.Position)

                    if visible and pos.Z > 0 then

                        line.BackgroundColor3 =
                            GetESPColor(player)

                        DrawLine(
                            line,
                            origin,
                            Vector2.new(pos.X, pos.Y),
                            2
                        )
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if ESPLines[player] then
        ESPLines[player]:Destroy()
        ESPLines[player] = nil
    end
end)

--==================================================
-- FLY
--==================================================

local FlyAttachment
local FlyVelocity

local UpHeld = false
local DownHeld = false

local FlyControls = Instance.new("Frame")
FlyControls.Size = UDim2.fromOffset(110, 100)
FlyControls.Position = UDim2.new(1, -125, 0.5, -50)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = ScreenGui

local UpButton = Instance.new("TextButton")
UpButton.Size = UDim2.fromOffset(50, 42)
UpButton.Position = UDim2.fromOffset(0, 0)
UpButton.BackgroundColor3 = BG2
UpButton.BorderSizePixel = 0
UpButton.Text = "▲"
UpButton.TextColor3 = TEXT
UpButton.Font = Enum.Font.GothamBold
UpButton.TextSize = 18
UpButton.Parent = FlyControls

local DownButton = Instance.new("TextButton")
DownButton.Size = UDim2.fromOffset(50, 42)
DownButton.Position = UDim2.fromOffset(55, 0)
DownButton.BackgroundColor3 = BG2
DownButton.BorderSizePixel = 0
DownButton.Text = "▼"
DownButton.TextColor3 = TEXT
DownButton.Font = Enum.Font.GothamBold
DownButton.TextSize = 18
DownButton.Parent = FlyControls

local function HoldButton(button, callback)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(true)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(false)
        end
    end)
end

HoldButton(UpButton, function(value)
    UpHeld = value
end)

HoldButton(DownButton, function(value)
    DownHeld = value
end)

function StopFly()
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

    FlyControls.Visible = false
end

function StartFly()

    if not Root or not Humanoid then
        return
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyAttachment then
        FlyAttachment:Destroy()
        FlyAttachment = nil
    end

    Settings.FlyEnabled = true

    Humanoid.AutoRotate = false

    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Name = "XE_FlyAttachment"
    FlyAttachment.Parent = Root

    FlyVelocity = Instance.new("LinearVelocity")
    FlyVelocity.Name = "XE_FlyVelocity"
    FlyVelocity.Attachment0 = FlyAttachment
    FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    FlyVelocity.MaxForce = math.huge
    FlyVelocity.VectorVelocity = Vector3.zero
    FlyVelocity.Parent = Root

    FlyControls.Visible =
        UserInputService.TouchEnabled
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

    local cameraCF = Camera.CFrame

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

    local move = Humanoid.MoveDirection

    local horizontal = Vector3.zero

    if move.Magnitude > 0.01 then

        local forwardAmount =
            move:Dot(forward)

        local rightAmount =
            move:Dot(right)

        horizontal =
            forward * forwardAmount
            + right * rightAmount

        if horizontal.Magnitude > 1 then
            horizontal = horizontal.Unit
        end
    end

    local vertical = 0

    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        vertical += Settings.FlyVerticalSpeed
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        vertical -= Settings.FlyVerticalSpeed
    end

    if UpHeld then
        vertical += Settings.FlyVerticalSpeed
    end

    if DownHeld then
        vertical -= Settings.FlyVerticalSpeed
    end

    FlyVelocity.VectorVelocity =
        horizontal * Settings.FlySpeed
        + Vector3.new(0, vertical, 0)
end

--==================================================
-- SPEED
--==================================================

local NormalWalkSpeed = 16

local function UpdateSpeed()

    if not Humanoid then
        return
    end

    if Settings.SpeedEnabled then
        Humanoid.WalkSpeed = Settings.SpeedRun
    else
        Humanoid.WalkSpeed = NormalWalkSpeed
    end
end

--==================================================
-- FPS BOOST
--==================================================

local FPSObjects = {}

local function ApplyFPSBoost()

    if not Settings.FPSBoost then
        return
    end

    -- Lighting
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000

    -- Remove expensive post-processing
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("BloomEffect")
            or obj:IsA("BlurEffect")
            or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("SunRaysEffect")
            or obj:IsA("DepthOfFieldEffect") then

            if FPSObjects[obj] == nil then
                FPSObjects[obj] = obj.Enabled
            end

            obj.Enabled = false
        end
    end

    -- Terrain
    local terrain = Workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        terrain.Decoration = false
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
    end

    -- Existing effects
    for _, obj in ipairs(Workspace:GetDescendants()) do

        if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles") then

            if FPSObjects[obj] == nil then
                FPSObjects[obj] = obj.Enabled
            end

            obj.Enabled = false
        end
    end
end

local function RestoreFPS()

    for obj, state in pairs(FPSObjects) do
        if obj and obj.Parent then
            pcall(function()
                obj.Enabled = state
            end)
        end
    end

    FPSObjects = {}
end

--==================================================
-- FPS COUNTER
--==================================================

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.fromOffset(130, 30)
FPSLabel.Position = UDim2.fromOffset(10, 10)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.TextStrokeTransparency = 0.2
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 12
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Visible = false
FPSLabel.Parent = ScreenGui

local FPSCounter = 0
local FPSTime = 0

--==================================================
-- KEYBINDS
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    if not Unlocked then
        return
    end

    if input.KeyCode == Enum.KeyCode.R then

        if Settings.FlyEnabled then
            StopFly()
        else
            StartFly()
        end

    elseif input.KeyCode == Enum.KeyCode.V then

        Settings.SpeedEnabled =
            not Settings.SpeedEnabled

        UpdateSpeed()

    end
end)

--==================================================
-- MAIN LOOP
--==================================================

local espTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)

    if not Unlocked then
        return
    end

    -- Aim
    if Settings.AimEnabled then

        local target = GetBestTarget()

        if target then

            local cameraPosition =
                Camera.CFrame.Position

            local direction =
                target.Position - cameraPosition

            if direction.Magnitude > 0 then

                local targetCF =
                    CFrame.lookAt(
                        cameraPosition,
                        target.Position
                    )

                local strength =
                    math.clamp(
                        Settings.LockStrength / 100,
                        0.01,
                        1
                    )

                local speed =
                    math.clamp(
                        Settings.AimSpeed / 100,
                        0.01,
                        1
                    )

                local alpha =
                    math.clamp(
                        strength * speed * 0.35,
                        0.01,
                        1
                    )

                Camera.CFrame =
                    Camera.CFrame:Lerp(
                        targetCF,
                        alpha
                    )
            end
        end
    end

    -- Fly
    if Settings.FlyEnabled then
        UpdateFly()
    end

    -- Speed
    if Settings.SpeedEnabled then
        UpdateSpeed()
    end

    -- ESP
    espTimer += deltaTime

    local espInterval =
        1 / math.max(Settings.ESPUpdateRate, 1)

    if espTimer >= espInterval then
        espTimer = 0

        UpdateESP()
        UpdateNormalLines()
    end

    -- FPS
    FPSCounter += 1
    FPSTime += deltaTime

    if FPSTime >= 0.5 then

        local fps =
            math.floor(
                FPSCounter / FPSTime
            )

        FPSCounter = 0
        FPSTime = 0

        FPSLabel.Text =
            "FPS: " .. tostring(fps)

        FPSLabel.Visible =
            Settings.ShowFPS
    end
end)

--==================================================
-- DYNAMIC FPS
--==================================================

task.spawn(function()

    while task.wait(2) do

        if Unlocked and Settings.FPSBoost then

            if Settings.DynamicFPS then
                ApplyFPSBoost()
            end

        end
    end
end)

--==================================================
-- INITIAL PERFORMANCE
--==================================================

task.delay(1, function()

    if Settings.FPSBoost then
        ApplyFPSBoost()
    end

end)

--==================================================
-- CLEANUP
--==================================================

ScreenGui.Destroying:Connect(function()

    for player in pairs(ESPObjects) do
        RemoveESP(player)
    end

    for player, line in pairs(ESPLines) do
        if line then
            line:Destroy()
        end
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
    end

    if FlyAttachment then
        FlyAttachment:Destroy()
    end

end)

print("XEIREN 5V5 Combat Hub loaded.")
print("Password: anakin")
print("R = Fly")
print("V = Speed Run")
