--============================================================
-- XEIREN 5V5 COMBAT HUB
-- Roblox Studio LocalScript
-- Place in StarterPlayer > StarterPlayerScripts
--
-- Password: anakin
--
-- Features:
-- • Compact modern UI
-- • English / Khmer
-- • Aim Assist
-- • 360° Lock
-- • FOV 10 - 999
-- • Head / Body target
-- • Adjustable aim distance / speed / strength
-- • Cloud ESP
-- • Clean ESP Line
-- • ESP Box / Name / HP / Distance / Head marker
-- • Team Check
-- • Wall Check
-- • Stable Fly
-- • Fly speed / vertical speed
-- • Speed Run
-- • No Recoil / No Reload config for your weapon system
-- • FPS Boost
-- • Dynamic optimization
-- • FPS counter
-- • Mobile + PC
-- • R = Fly
-- • V = Speed
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local Camera = Workspace.CurrentCamera

--============================================================
-- SETTINGS
--============================================================

local Settings = {

    Language = "EN",

    -- AIM
    AimEnabled = false,
    Full360 = true,
    LockStrength = 85,
    AimSpeed = 35,
    AimDistance = 600,
    AimFOV = 180,
    AimPart = "Head",

    -- ESP
    ESPEnabled = false,
    ESPCloud = true,
    ESPLine = true,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPHead = false,
    ESPAlwaysOnTop = true,
    ESPTeamColor = false,
    ESPMaxDistance = 600,

    -- CHECKS
    TeamCheck = true,
    WallCheck = false,

    -- MOVEMENT
    FlyEnabled = false,
    FlySpeed = 70,
    FlyVerticalSpeed = 60,

    SpeedEnabled = false,
    SpeedRun = 32,

    -- WEAPON
    NoRecoil = false,
    NoReload = false,

    -- PERFORMANCE
    FPSBoost = true,
    DynamicFPS = true,
    ShowFPS = true,

    ESPUpdateRate = 15,
}

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local Root

local function SetCharacter(char)

    Character = char

    Humanoid = char:WaitForChild("Humanoid", 10)
    Root = char:WaitForChild("HumanoidRootPart", 10)

end

if LP.Character then
    SetCharacter(LP.Character)
end

--============================================================
-- WEAPON CONFIG
--============================================================

local WeaponConfig =
    ReplicatedStorage:FindFirstChild("XeirenWeaponConfig")

if not WeaponConfig then

    WeaponConfig = Instance.new("Folder")
    WeaponConfig.Name = "XeirenWeaponConfig"
    WeaponConfig.Parent = ReplicatedStorage

end

local function UpdateWeaponConfig()

    WeaponConfig:SetAttribute(
        "NoRecoil",
        Settings.NoRecoil
    )

    WeaponConfig:SetAttribute(
        "NoReload",
        Settings.NoReload
    )

end

UpdateWeaponConfig()

--============================================================
-- CLEAN OLD GUI
--============================================================

local old = PlayerGui:FindFirstChild("XeirenCombatHub")

if old then
    old:Destroy()
end

--============================================================
-- COLORS
--============================================================

local Colors = {

    Background = Color3.fromRGB(12, 13, 18),
    Panel = Color3.fromRGB(20, 21, 28),
    Panel2 = Color3.fromRGB(27, 28, 37),

    Accent = Color3.fromRGB(128, 88, 255),

    White = Color3.fromRGB(245, 245, 250),
    Gray = Color3.fromRGB(160, 161, 175),

    Green = Color3.fromRGB(80, 220, 125),
    Red = Color3.fromRGB(235, 75, 90),

    Line = Color3.fromRGB(255, 80, 100),

}

--============================================================
-- LOCALIZATION
--============================================================

local L = {

    EN = {

        title = "XEIREN 5V5",
        subtitle = "Combat Hub",

        aimTab = "AIM",
        espTab = "ESP",
        moveTab = "MOVE",
        miscTab = "MISC",

        aim = "Aim Assist",
        lock360 = "360° Lock",
        strength = "Lock Strength",
        aimSpeed = "Aim Speed",
        aimDistance = "Aim Distance",
        aimFov = "Aim FOV",
        target = "Target",

        head = "Head",
        body = "Body",

        esp = "ESP",
        cloud = "Cloud ESP",
        line = "ESP Line",
        box = "ESP Box",
        name = "ESP Name",
        health = "ESP Health",
        distance = "ESP Distance",
        headMarker = "Head Marker",
        always = "Always On Top",
        teamColor = "Team Color",
        espDistance = "ESP Distance Limit",

        teamCheck = "Team Check",
        wallCheck = "Wall Check",

        fly = "Fly",
        flySpeed = "Fly Speed",
        verticalSpeed = "Vertical Speed",

        speedRun = "Speed Run",
        runSpeed = "Run Speed",

        noRecoil = "No Recoil",
        noReload = "No Reload",

        fpsBoost = "FPS Boost",
        dynamic = "Dynamic Optimization",
        showFps = "Show FPS",

        locked = "LOCKED",
        unlocked = "UNLOCKED",

        password = "Enter password",
        enter = "ENTER",
        wrong = "Wrong password",

        on = "ON",
        off = "OFF",

    },

    KM = {

        title = "XEIREN 5V5",
        subtitle = "Combat Hub",

        aimTab = "ជំនួយ AIM",
        espTab = "ESP",
        moveTab = "ចលនា",
        miscTab = "ផ្សេងៗ",

        aim = "ជំនួយ Aim",
        lock360 = "ចាក់សោ 360°",
        strength = "កម្លាំង Lock",
        aimSpeed = "ល្បឿន Aim",
        aimDistance = "ចម្ងាយ Aim",
        aimFov = "Aim FOV",
        target = "គោលដៅ",

        head = "ក្បាល",
        body = "ខ្លួន",

        esp = "ESP",
        cloud = "Cloud ESP",
        line = "ខ្សែ ESP",
        box = "ប្រអប់ ESP",
        name = "ឈ្មោះ ESP",
        health = "HP ESP",
        distance = "ចម្ងាយ ESP",
        headMarker = "សញ្ញាក្បាល",
        always = "បង្ហាញពីក្រោយ",
        teamColor = "ពណ៌តាម Team",
        espDistance = "កំណត់ចម្ងាយ ESP",

        teamCheck = "ពិនិត្យ Team",
        wallCheck = "ពិនិត្យជញ្ជាំង",

        fly = "ហោះ",
        flySpeed = "ល្បឿនហោះ",
        verticalSpeed = "ល្បឿនឡើងចុះ",

        speedRun = "រត់លឿន",
        runSpeed = "ល្បឿនរត់",

        noRecoil = "គ្មាន Recoil",
        noReload = "គ្មាន Reload",

        fpsBoost = "បង្កើន FPS",
        dynamic = "Optimization ស្វ័យប្រវត្តិ",
        showFps = "បង្ហាញ FPS",

        locked = "LOCKED",
        unlocked = "UNLOCKED",

        password = "បញ្ចូល Password",
        enter = "ចូល",
        wrong = "Password ខុស",

        on = "បើក",
        off = "បិទ",

    }

}

local function T(key)

    local language = L[Settings.Language]

    return language[key] or key

end

--============================================================
-- MAIN SCREEN GUI
--============================================================

local GUI = Instance.new("ScreenGui")

GUI.Name = "XeirenCombatHub"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

GUI.Parent = PlayerGui

--============================================================
-- PASSWORD
--============================================================

local PasswordFrame = Instance.new("Frame")

PasswordFrame.Size = UDim2.fromOffset(310, 190)
PasswordFrame.Position = UDim2.new(0.5, -155, 0.5, -95)

PasswordFrame.BackgroundColor3 = Colors.Background
PasswordFrame.BorderSizePixel = 0

PasswordFrame.Parent = GUI

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 16)
PCorner.Parent = PasswordFrame

local PStroke = Instance.new("UIStroke")
PStroke.Color = Colors.Accent
PStroke.Thickness = 1.5
PStroke.Parent = PasswordFrame

local PTitle = Instance.new("TextLabel")

PTitle.Size = UDim2.new(1, -30, 0, 35)
PTitle.Position = UDim2.fromOffset(15, 15)

PTitle.BackgroundTransparency = 1
PTitle.Text = "XEIREN"
PTitle.TextColor3 = Colors.White
PTitle.Font = Enum.Font.GothamBlack
PTitle.TextSize = 23

PTitle.Parent = PasswordFrame

local PSub = Instance.new("TextLabel")

PSub.Size = UDim2.new(1, -30, 0, 25)
PSub.Position = UDim2.fromOffset(15, 48)

PSub.BackgroundTransparency = 1
PSub.Text = T("password")
PSub.TextColor3 = Colors.Gray
PSub.Font = Enum.Font.Gotham
PSub.TextSize = 13

PSub.Parent = PasswordFrame

local PBox = Instance.new("TextBox")

PBox.Size = UDim2.new(1, -40, 0, 38)
PBox.Position = UDim2.fromOffset(20, 80)

PBox.BackgroundColor3 = Colors.Panel2
PBox.BorderSizePixel = 0

PBox.PlaceholderText = "Password"
PBox.PlaceholderColor3 = Colors.Gray

PBox.TextColor3 = Colors.White
PBox.Font = Enum.Font.Gotham
PBox.TextSize = 14

PBox.ClearTextOnFocus = false

PBox.Parent = PasswordFrame

local PBoxCorner = Instance.new("UICorner")
PBoxCorner.CornerRadius = UDim.new(0, 9)
PBoxCorner.Parent = PBox

local PButton = Instance.new("TextButton")

PButton.Size = UDim2.new(1, -40, 0, 35)
PButton.Position = UDim2.fromOffset(20, 130)

PButton.BackgroundColor3 = Colors.Accent
PButton.BorderSizePixel = 0

PButton.Text = T("enter")
PButton.TextColor3 = Color3.new(1,1,1)

PButton.Font = Enum.Font.GothamBold
PButton.TextSize = 12

PButton.Parent = PasswordFrame

local PButtonCorner = Instance.new("UICorner")
PButtonCorner.CornerRadius = UDim.new(0, 9)
PButtonCorner.Parent = PButton

local WrongLabel = Instance.new("TextLabel")

WrongLabel.Size = UDim2.new(1, -20, 0, 20)
WrongLabel.Position = UDim2.fromOffset(10, 166)

WrongLabel.BackgroundTransparency = 1
WrongLabel.Text = ""
WrongLabel.TextColor3 = Colors.Red

WrongLabel.Font = Enum.Font.Gotham
WrongLabel.TextSize = 11

WrongLabel.Parent = PasswordFrame

--============================================================
-- HUB
--============================================================

local Hub = Instance.new("Frame")

Hub.Size = UDim2.fromOffset(390, 315)
Hub.Position = UDim2.new(0.5, -195, 0.5, -157)

Hub.BackgroundColor3 = Colors.Background
Hub.BorderSizePixel = 0

Hub.Visible = false
Hub.Parent = GUI

local HubCorner = Instance.new("UICorner")
HubCorner.CornerRadius = UDim.new(0, 16)
HubCorner.Parent = Hub

local HubStroke = Instance.new("UIStroke")
HubStroke.Color = Colors.Accent
HubStroke.Thickness = 1.2
HubStroke.Parent = Hub

--============================================================
-- HEADER
--============================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundTransparency = 1

Header.Parent = Hub

local HeaderTitle = Instance.new("TextLabel")

HeaderTitle.Size = UDim2.new(1, -130, 0, 28)
HeaderTitle.Position = UDim2.fromOffset(15, 7)

HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = T("title")
HeaderTitle.TextColor3 = Colors.White

HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = 17

HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

HeaderTitle.Parent = Header

local HeaderSub = Instance.new("TextLabel")

HeaderSub.Size = UDim2.new(1, -130, 0, 20)
HeaderSub.Position = UDim2.fromOffset(15, 31)

HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = T("subtitle")
HeaderSub.TextColor3 = Colors.Gray

HeaderSub.Font = Enum.Font.Gotham
HeaderSub.TextSize = 10

HeaderSub.TextXAlignment = Enum.TextXAlignment.Left

HeaderSub.Parent = Header

--============================================================
-- LANGUAGE
--============================================================

local LanguageButton = Instance.new("TextButton")

LanguageButton.Size = UDim2.fromOffset(50, 29)
LanguageButton.Position = UDim2.new(1, -110, 0, 14)

LanguageButton.BackgroundColor3 = Colors.Panel2
LanguageButton.BorderSizePixel = 0

LanguageButton.Text = "EN"
LanguageButton.TextColor3 = Colors.White

LanguageButton.Font = Enum.Font.GothamBold
LanguageButton.TextSize = 10

LanguageButton.Parent = Header

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 8)
LangCorner.Parent = LanguageButton

--============================================================
-- CLOSE
--============================================================

local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.fromOffset(32, 29)
CloseButton.Position = UDim2.new(1, -50, 0, 14)

CloseButton.BackgroundColor3 = Colors.Panel2
CloseButton.BorderSizePixel = 0

CloseButton.Text = "×"
CloseButton.TextColor3 = Colors.White

CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18

CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

--============================================================
-- TABS
--============================================================

local TabBar = Instance.new("Frame")

TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.fromOffset(10, 60)

TabBar.BackgroundTransparency = 1

TabBar.Parent = Hub

local TabLayout = Instance.new("UIListLayout")

TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 5)

TabLayout.Parent = TabBar

local Tabs = {}
local Pages = {}

local function CreateTab(key)

    local button = Instance.new("TextButton")

    button.Size = UDim2.fromOffset(82, 32)

    button.BackgroundColor3 = Colors.Panel
    button.BorderSizePixel = 0

    button.Text = T(key)
    button.TextColor3 = Colors.Gray

    button.Font = Enum.Font.GothamBold
    button.TextSize = 10

    button.Parent = TabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    Tabs[key] = button

    return button
end

CreateTab("aimTab")
CreateTab("espTab")
CreateTab("moveTab")
CreateTab("miscTab")

--============================================================
-- PAGE CONTAINER
--============================================================

local PageContainer = Instance.new("Frame")

PageContainer.Size = UDim2.new(1, -20, 1, -105)
PageContainer.Position = UDim2.fromOffset(10, 100)

PageContainer.BackgroundTransparency = 1

PageContainer.Parent = Hub

local function CreatePage()

    local page = Instance.new("ScrollingFrame")

    page.Size = UDim2.fromScale(1, 1)

    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0

    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.Accent

    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    page.Visible = false

    page.Parent = PageContainer

    local layout = Instance.new("UIListLayout")

    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    layout.Parent = page

    local padding = Instance.new("UIPadding")

    padding.PaddingBottom = UDim.new(0, 8)

    padding.Parent = page

    return page
end

Pages.aimTab = CreatePage()
Pages.espTab = CreatePage()
Pages.moveTab = CreatePage()
Pages.miscTab = CreatePage()

--============================================================
-- UI HELPERS
--============================================================

local RefreshFunctions = {}

local function AddRefresh(fn)

    table.insert(RefreshFunctions, fn)

end

local function RefreshAll()

    for _, fn in ipairs(RefreshFunctions) do
        pcall(fn)
    end

end

local function Section(parent, text)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -4, 0, 22)

    label.BackgroundTransparency = 1

    label.Text = text
    label.TextColor3 = Colors.Accent

    label.Font = Enum.Font.GothamBold
    label.TextSize = 10

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = parent

    return label
end

local function Toggle(parent, key, setting)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -4, 0, 34)

    button.BackgroundColor3 = Colors.Panel
    button.BorderSizePixel = 0

    button.Text = ""

    button.AutoButtonColor = false

    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -65, 1, 0)
    label.Position = UDim2.fromOffset(11, 0)

    label.BackgroundTransparency = 1

    label.TextColor3 = Colors.White

    label.Font = Enum.Font.Gotham
    label.TextSize = 11

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = button

    local state = Instance.new("TextLabel")

    state.Size = UDim2.fromOffset(43, 22)
    state.Position = UDim2.new(1, -50, 0.5, -11)

    state.BorderSizePixel = 0

    state.Font = Enum.Font.GothamBold
    state.TextSize = 9

    state.TextColor3 = Color3.new(1,1,1)

    state.Parent = button

    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(0, 6)
    stateCorner.Parent = state

    local function Refresh()

        label.Text = T(key)

        if Settings[setting] then

            state.Text = T("on")
            state.BackgroundColor3 = Colors.Green

        else

            state.Text = T("off")
            state.BackgroundColor3 = Colors.Red

        end

    end

    button.MouseButton1Click:Connect(function()

        Settings[setting] = not Settings[setting]

        if setting == "FlyEnabled" then

            if Settings.FlyEnabled then
                StartFly()
            else
                StopFly()
            end

        elseif setting == "SpeedEnabled" then

            UpdateSpeed()

        elseif setting == "NoRecoil"
            or setting == "NoReload" then

            UpdateWeaponConfig()

        end

        Refresh()

    end)

    AddRefresh(Refresh)

    Refresh()

    return button
end

local function Slider(parent, key, setting, min, max, step)

    local frame = Instance.new("Frame")

    frame.Size = UDim2.new(1, -4, 0, 49)

    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0

    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.fromOffset(10, 2)

    label.BackgroundTransparency = 1

    label.TextColor3 = Colors.White

    label.Font = Enum.Font.Gotham
    label.TextSize = 10

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = frame

    local bar = Instance.new("Frame")

    bar.Size = UDim2.new(1, -20, 0, 5)
    bar.Position = UDim2.fromOffset(10, 34)

    bar.BackgroundColor3 = Color3.fromRGB(50, 51, 61)
    bar.BorderSizePixel = 0

    bar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")

    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0

    fill.Size = UDim2.new(0, 0, 1, 0)

    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false

    local function SetValue(x)

        local pct = math.clamp(
            (x - bar.AbsolutePosition.X)
            / bar.AbsoluteSize.X,
            0,
            1
        )

        local value =
            min + (max - min) * pct

        if step then

            value =
                math.floor(
                    value / step + 0.5
                ) * step

        end

        Settings[setting] =
            math.clamp(value, min, max)

    end

    local function Refresh()

        label.Text =
            T(key)
            .. ": "
            .. tostring(
                math.floor(Settings[setting])
            )

        local pct =
            (Settings[setting] - min)
            / (max - min)

        fill.Size =
            UDim2.new(
                math.clamp(pct, 0, 1),
                0,
                1,
                0
            )

    end

    bar.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true

            SetValue(input.Position.X)
            Refresh()

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            SetValue(input.Position.X)
            Refresh()

        end

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = false

        end

    end)

    AddRefresh(Refresh)

    Refresh()

    return frame
end

local function CycleButton(parent, key, values, setting)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -4, 0, 34)

    button.BackgroundColor3 = Colors.Panel
    button.BorderSizePixel = 0

    button.TextColor3 = Colors.White

    button.Font = Enum.Font.Gotham
    button.TextSize = 11

    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local index = 1

    for i, value in ipairs(values) do

        if value == Settings[setting] then
            index = i
        end

    end

    local function Refresh()

        button.Text =
            T(key)
            .. ": "
            .. (
                Settings[setting] == "Head"
                and T("head")
                or T("body")
            )

    end

    button.MouseButton1Click:Connect(function()

        index += 1

        if index > #values then
            index = 1
        end

        Settings[setting] = values[index]

        Refresh()

    end)

    AddRefresh(Refresh)

    Refresh()

    return button
end

--============================================================
-- AIM PAGE
--============================================================

Section(Pages.aimTab, "AIM SYSTEM")

Toggle(
    Pages.aimTab,
    "aim",
    "AimEnabled"
)

Toggle(
    Pages.aimTab,
    "lock360",
    "Full360"
)

Slider(
    Pages.aimTab,
    "strength",
    "LockStrength",
    1,
    100,
    1
)

Slider(
    Pages.aimTab,
    "aimSpeed",
    "AimSpeed",
    1,
    100,
    1
)

Slider(
    Pages.aimTab,
    "aimDistance",
    "AimDistance",
    50,
    1000,
    10
)

-- FOV NOW GOES TO 999
Slider(
    Pages.aimTab,
    "aimFov",
    "AimFOV",
    10,
    999,
    1
)

CycleButton(
    Pages.aimTab,
    "target",
    {
        "Head",
        "Body"
    },
    "AimPart"
)

Toggle(
    Pages.aimTab,
    "teamCheck",
    "TeamCheck"
)

Toggle(
    Pages.aimTab,
    "wallCheck",
    "WallCheck"
)

--============================================================
-- ESP PAGE
--============================================================

Section(Pages.espTab, "ESP SYSTEM")

Toggle(
    Pages.espTab,
    "esp",
    "ESPEnabled"
)

Toggle(
    Pages.espTab,
    "cloud",
    "ESPCloud"
)

Toggle(
    Pages.espTab,
    "line",
    "ESPLine"
)

Toggle(
    Pages.espTab,
    "box",
    "ESPBox"
)

Toggle(
    Pages.espTab,
    "name",
    "ESPName"
)

Toggle(
    Pages.espTab,
    "health",
    "ESPHealth"
)

Toggle(
    Pages.espTab,
    "distance",
    "ESPDistance"
)

Toggle(
    Pages.espTab,
    "headMarker",
    "ESPHead"
)

Toggle(
    Pages.espTab,
    "always",
    "ESPAlwaysOnTop"
)

Toggle(
    Pages.espTab,
    "teamColor",
    "ESPTeamColor"
)

Slider(
    Pages.espTab,
    "espDistance",
    "ESPMaxDistance",
    50,
    1500,
    10
)

--============================================================
-- MOVEMENT PAGE
--============================================================

Section(Pages.moveTab, "MOVEMENT")

Toggle(
    Pages.moveTab,
    "fly",
    "FlyEnabled"
)

Slider(
    Pages.moveTab,
    "flySpeed",
    "FlySpeed",
    10,
    250,
    5
)

Slider(
    Pages.moveTab,
    "verticalSpeed",
    "FlyVerticalSpeed",
    10,
    250,
    5
)

Toggle(
    Pages.moveTab,
    "speedRun",
    "SpeedEnabled"
)

Slider(
    Pages.moveTab,
    "runSpeed",
    "SpeedRun",
    16,
    100,
    1
)

--============================================================
-- MISC PAGE
--============================================================

Section(Pages.miscTab, "WEAPON")

Toggle(
    Pages.miscTab,
    "noRecoil",
    "NoRecoil"
)

Toggle(
    Pages.miscTab,
    "noReload",
    "NoReload"
)

Section(Pages.miscTab, "PERFORMANCE")

Toggle(
    Pages.miscTab,
    "fpsBoost",
    "FPSBoost"
)

Toggle(
    Pages.miscTab,
    "dynamic",
    "DynamicFPS"
)

Toggle(
    Pages.miscTab,
    "showFps",
    "ShowFPS"
)

--============================================================
-- TAB SYSTEM
--============================================================

local CurrentPage = "aimTab"

local function SelectPage(name)

    CurrentPage = name

    for key, page in pairs(Pages) do

        page.Visible =
            key == name

    end

    for key, button in pairs(Tabs) do

        if key == name then

            button.BackgroundColor3 =
                Colors.Accent

            button.TextColor3 =
                Colors.White

        else

            button.BackgroundColor3 =
                Colors.Panel

            button.TextColor3 =
                Colors.Gray

        end

        button.Text = T(key)

    end

end

for key, button in pairs(Tabs) do

    button.MouseButton1Click:Connect(function()

        SelectPage(key)

    end)

end

SelectPage("aimTab")

--============================================================
-- LANGUAGE
--============================================================

local function UpdateLanguage()

    HeaderTitle.Text = T("title")
    HeaderSub.Text = T("subtitle")

    PSub.Text = T("password")
    PButton.Text = T("enter")

    if Settings.Language == "EN" then
        LanguageButton.Text = "EN"
    else
        LanguageButton.Text = "ខ្មែរ"
    end

    RefreshAll()

    for key, button in pairs(Tabs) do
        button.Text = T(key)
    end

end

LanguageButton.MouseButton1Click:Connect(function()

    if Settings.Language == "EN" then
        Settings.Language = "KM"
    else
        Settings.Language = "EN"
    end

    UpdateLanguage()

end)

--============================================================
-- DRAG HUB
--============================================================

local HubDragging = false
local HubDragStart
local HubStartPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        HubDragging = true

        HubDragStart = input.Position
        HubStartPosition = Hub.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not HubDragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - HubDragStart

        Hub.Position =
            UDim2.new(
                HubStartPosition.X.Scale,
                HubStartPosition.X.Offset + delta.X,
                HubStartPosition.Y.Scale,
                HubStartPosition.Y.Offset + delta.Y
            )

    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        HubDragging = false

    end

end)

CloseButton.MouseButton1Click:Connect(function()

    Hub.Visible = false

end)

--============================================================
-- XE BUTTON
--============================================================

local XEButton = Instance.new("TextButton")

XEButton.Size = UDim2.fromOffset(48, 48)

XEButton.Position =
    UDim2.new(0, 14, 0.5, -24)

XEButton.BackgroundColor3 =
    Colors.Accent

XEButton.BorderSizePixel = 0

XEButton.Text = "XE"

XEButton.TextColor3 =
    Color3.new(1,1,1)

XEButton.Font =
    Enum.Font.GothamBlack

XEButton.TextSize = 15

XEButton.Parent = GUI

local XECorner = Instance.new("UICorner")

XECorner.CornerRadius =
    UDim.new(1, 0)

XECorner.Parent = XEButton

--============================================================
-- DRAG XE BUTTON
--============================================================

local LogoDragging = false
local LogoMoved = false

local LogoStart
local LogoPosition

XEButton.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        LogoDragging = true
        LogoMoved = false

        LogoStart = input.Position
        LogoPosition = XEButton.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not LogoDragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - LogoStart

        if delta.Magnitude > 6 then
            LogoMoved = true
        end

        XEButton.Position =
            UDim2.new(
                LogoPosition.X.Scale,
                LogoPosition.X.Offset + delta.X,
                LogoPosition.Y.Scale,
                LogoPosition.Y.Offset + delta.Y
            )

    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        LogoDragging = false

    end

end)

XEButton.MouseButton1Click:Connect(function()

    if LogoMoved then
        return
    end

    Hub.Visible =
        not Hub.Visible

end)

--============================================================
-- PASSWORD
--============================================================

local Unlocked = false

local function TryUnlock()

    if PBox.Text == "anakin" then

        Unlocked = true

        WrongLabel.Text = ""

        PasswordFrame.Visible = false
        Hub.Visible = true

    else

        WrongLabel.Text =
            T("wrong")

        PBox.Text = ""

        local original =
            PasswordFrame.Position

        local t1 =
            TweenService:Create(
                PasswordFrame,
                TweenInfo.new(0.06),
                {
                    Position =
                        original
                        + UDim2.fromOffset(8, 0)
                }
            )

        local t2 =
            TweenService:Create(
                PasswordFrame,
                TweenInfo.new(0.06),
                {
                    Position = original
                }
            )

        t1:Play()
        t1.Completed:Wait()
        t2:Play()

    end

end

PButton.MouseButton1Click:Connect(TryUnlock)

PBox.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        TryUnlock()
    end

end)

--============================================================
-- AIM
--============================================================

local function IsEnemy(player)

    if player == LP then
        return false
    end

    if Settings.TeamCheck
        and LP.Team
        and player.Team == LP.Team then

        return false

    end

    return true

end

local function GetTargetPart(character)

    if not character then
        return nil
    end

    if Settings.AimPart == "Body" then

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

    return character:FindFirstChild("Head")
        or character:FindFirstChild(
            "HumanoidRootPart"
        )

end

local function VisiblePart(part)

    if not Settings.WallCheck then
        return true
    end

    if not part or not Camera then
        return false
    end

    local origin =
        Camera.CFrame.Position

    local direction =
        part.Position - origin

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
        part.Parent
    )

end

local function GetBestTarget()

    local best
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

        if IsEnemy(player) then

            local char =
                player.Character

            local hum =
                char
                and char:FindFirstChildOfClass(
                    "Humanoid"
                )

            local part =
                GetTargetPart(char)

            if hum
                and hum.Health > 0
                and part then

                local distance =
                    (
                        part.Position
                        - Camera.CFrame.Position
                    ).Magnitude

                if distance <=
                    Settings.AimDistance then

                    local pos, visible =
                        Camera:WorldToViewportPoint(
                            part.Position
                        )

                    if visible
                        and pos.Z > 0 then

                        local screenDistance =
                            (
                                Vector2.new(
                                    pos.X,
                                    pos.Y
                                )
                                - center
                            ).Magnitude

                        local radius =
                            math.min(
                                viewport.X,
                                viewport.Y
                            )
                            * (
                                Settings.AimFOV
                                / 999
                            )
                            * 0.5

                        local allowed =
                            Settings.Full360
                            or screenDistance <= radius

                        if allowed
                            and VisiblePart(part) then

                            local score

                            if Settings.Full360 then
                                score = distance
                            else
                                score = screenDistance
                            end

                            if score < bestScore then

                                bestScore = score
                                best = part

                            end

                        end

                    end

                end

            end

        end

    end

    return best

end

--============================================================
-- CLEAN ESP STORAGE
--============================================================

local ESP = {}

local function ESPColor(player)

    if Settings.ESPTeamColor
        and player.Team then

        return player.Team.TeamColor.Color

    end

    return Colors.Line

end

local function DestroyESP(player)

    local data = ESP[player]

    if not data then
        return
    end

    for _, obj in pairs(data) do

        if typeof(obj) == "Instance"
            and obj.Parent then

            obj:Destroy()

        end

    end

    ESP[player] = nil

end

--============================================================
-- CREATE ESP ONCE
--============================================================

local function CreateESP(player)

    if player == LP then
        return
    end

    if ESP[player] then
        return ESP[player]
    end

    local data = {}

    -- HIGHLIGHT
    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "XE_Highlight"

    highlight.Enabled = false

    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0

    highlight.Parent = GUI

    data.Highlight = highlight

    -- INFO BILLBOARD
    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "XE_Info"

    billboard.Size =
        UDim2.fromOffset(190, 62)

    billboard.StudsOffset =
        Vector3.new(0, 3.2, 0)

    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    billboard.Parent = GUI

    local info =
        Instance.new("Frame")

    info.Size =
        UDim2.fromScale(1,1)

    info.BackgroundTransparency = 1

    info.Parent = billboard

    local name =
        Instance.new("TextLabel")

    name.Size =
        UDim2.new(1,0,0,20)

    name.BackgroundTransparency = 1

    name.TextColor3 =
        Colors.White

    name.TextStrokeTransparency = 0.2

    name.Font =
        Enum.Font.GothamBold

    name.TextSize = 12

    name.Parent = info

    local distance =
        Instance.new("TextLabel")

    distance.Size =
        UDim2.new(1,0,0,18)

    distance.Position =
        UDim2.fromOffset(0,20)

    distance.BackgroundTransparency = 1

    distance.TextColor3 =
        Colors.Gray

    distance.TextStrokeTransparency = 0.3

    distance.Font =
        Enum.Font.Gotham

    distance.TextSize = 10

    distance.Parent = info

    local hp =
        Instance.new("TextLabel")

    hp.Size =
        UDim2.new(1,0,0,18)

    hp.Position =
        UDim2.fromOffset(0,39)

    hp.BackgroundTransparency = 1

    hp.TextColor3 =
        Colors.Green

    hp.TextStrokeTransparency = 0.3

    hp.Font =
        Enum.Font.GothamBold

    hp.TextSize = 10

    hp.Parent = info

    data.Billboard = billboard
    data.Name = name
    data.Distance = distance
    data.Health = hp

    -- HEAD MARKER
    local headGui =
        Instance.new("BillboardGui")

    headGui.Name =
        "XE_Head"

    headGui.Size =
        UDim2.fromOffset(25,25)

    headGui.AlwaysOnTop = true
    headGui.Enabled = false

    headGui.Parent = GUI

    local marker =
        Instance.new("TextLabel")

    marker.Size =
        UDim2.fromScale(1,1)

    marker.BackgroundTransparency = 1

    marker.Text = "●"

    marker.TextColor3 =
        Colors.Line

    marker.TextStrokeTransparency = 0

    marker.Font =
        Enum.Font.GothamBold

    marker.TextSize = 13

    marker.Parent = headGui

    data.Head = headGui

    ESP[player] = data

    return data

end

--============================================================
-- SCREEN ESP LINES
--============================================================

local LineGui =
    Instance.new("ScreenGui")

LineGui.Name =
    "XeirenESPNetwork"

LineGui.ResetOnSpawn = false
LineGui.IgnoreGuiInset = true
LineGui.DisplayOrder = 30

LineGui.Parent = PlayerGui

local PlayerLines = {}

local function GetPlayerLine(player)

    if PlayerLines[player] then
        return PlayerLines[player]
    end

    local line =
        Instance.new("Frame")

    line.Name =
        "XE_PlayerLine"

    line.AnchorPoint =
        Vector2.new(0, 0.5)

    line.BackgroundColor3 =
        Colors.Line

    line.BorderSizePixel = 0

    line.Size =
        UDim2.fromOffset(1,1)

    line.Visible = false

    line.Parent = LineGui

    PlayerLines[player] = line

    return line

end

local function DrawLine(
    line,
    fromPos,
    toPos,
    thickness
)

    local delta =
        toPos - fromPos

    local length =
        delta.Magnitude

    if length < 2 then

        line.Visible = false
        return

    end

    line.Visible = true

    line.Position =
        UDim2.fromOffset(
            fromPos.X,
            fromPos.Y
        )

    line.Size =
        UDim2.fromOffset(
            length,
            thickness
                or 2
        )

    line.Rotation =
        math.deg(
            math.atan2(
                delta.Y,
                delta.X
            )
        )

end

--============================================================
-- CLOUD ESP
--============================================================

local CloudGui =
    Instance.new("ScreenGui")

CloudGui.Name =
    "XeirenCloudESP"

CloudGui.ResetOnSpawn = false
CloudGui.IgnoreGuiInset = true
CloudGui.DisplayOrder = 31

CloudGui.Parent = PlayerGui

local CloudAnchor =
    Instance.new("Frame")

CloudAnchor.Size =
    UDim2.fromOffset(2,2)

CloudAnchor.BackgroundTransparency = 1

CloudAnchor.Visible = false

CloudAnchor.Parent = CloudGui

local Cloud =
    Instance.new("TextLabel")

Cloud.Size =
    UDim2.fromOffset(70,45)

Cloud.Position =
    UDim2.fromOffset(-35,-22)

Cloud.BackgroundTransparency = 1

Cloud.Text = "☁"

Cloud.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Cloud.TextStrokeTransparency = 0

Cloud.Font =
    Enum.Font.GothamBold

Cloud.TextSize = 30

Cloud.Parent = CloudAnchor

local CloudLines = {}

local function CloudLine(index)

    if CloudLines[index] then
        return CloudLines[index]
    end

    local line =
        Instance.new("Frame")

    line.Name =
        "XE_CloudLine_" .. index

    line.AnchorPoint =
        Vector2.new(0,0.5)

    line.BackgroundColor3 =
        Colors.Line

    line.BorderSizePixel = 0

    line.Size =
        UDim2.fromOffset(1,1)

    line.Visible = false

    line.Parent = CloudGui

    CloudLines[index] = line

    return line

end

--============================================================
-- UPDATE ESP
--============================================================

local function UpdateCloudESP()

    if not Settings.ESPEnabled
        or not Settings.ESPCloud then

        CloudAnchor.Visible = false

        for _, line in pairs(
            CloudLines
        ) do

            line.Visible = false

        end

        return

    end

    local viewport =
        Camera.ViewportSize

    local cloudPos =
        Vector2.new(
            viewport.X / 2,
            70
        )

    CloudAnchor.Position =
        UDim2.fromOffset(
            cloudPos.X,
            cloudPos.Y
        )

    CloudAnchor.Visible = true

    local index = 0

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if IsEnemy(player) then

            local char =
                player.Character

            local hum =
                char
                and char:FindFirstChildOfClass(
                    "Humanoid"
                )

            local root =
                char
                and char:FindFirstChild(
                    "HumanoidRootPart"
                )

            if hum
                and hum.Health > 0
                and root then

                local distance =
                    (
                        root.Position
                        - Camera.CFrame.Position
                    ).Magnitude

                if distance <=
                    Settings.ESPMaxDistance then

                    local pos, visible =
                        Camera:WorldToViewportPoint(
                            root.Position
                        )

                    if visible
                        and pos.Z > 0 then

                        index += 1

                        local line =
                            CloudLine(index)

                        line.BackgroundColor3 =
                            ESPColor(player)

                        DrawLine(
                            line,
                            cloudPos,
                            Vector2.new(
                                pos.X,
                                pos.Y
                            ),
                            2
                        )

                    end

                end

            end

        end

    end

    for i = index + 1,
        #CloudLines do

        CloudLines[i].Visible = false

    end

end

local function UpdatePlayerLines()

    if not Settings.ESPEnabled
        or not Settings.ESPLine
        or Settings.ESPCloud then

        for _, line in pairs(
            PlayerLines
        ) do

            line.Visible = false

        end

        return

    end

    local viewport =
        Camera.ViewportSize

    -- Bottom-center origin
    local origin =
        Vector2.new(
            viewport.X / 2,
            viewport.Y - 20
        )

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LP then

            local line =
                GetPlayerLine(player)

            if IsEnemy(player) then

                local char =
                    player.Character

                local hum =
                    char
                    and char:FindFirstChildOfClass(
                        "Humanoid"
                    )

                local root =
                    char
                    and char:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if hum
                    and hum.Health > 0
                    and root then

                    local distance =
                        (
                            root.Position
                            - Camera.CFrame.Position
                        ).Magnitude

                    if distance <=
                        Settings.ESPMaxDistance then

                        local pos, visible =
                            Camera:WorldToViewportPoint(
                                root.Position
                            )

                        if visible
                            and pos.Z > 0 then

                            line.BackgroundColor3 =
                                ESPColor(player)

                            DrawLine(
                                line,
                                origin,
                                Vector2.new(
                                    pos.X,
                                    pos.Y
                                ),
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

            else

                line.Visible = false

            end

        end

    end

end

local function UpdatePlayerESP()

    if not Settings.ESPEnabled then

        for _, data in pairs(ESP) do

            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
            data.Head.Enabled = false

        end

        return

    end

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LP then

            local data =
                CreateESP(player)

            local char =
                player.Character

            local hum =
                char
                and char:FindFirstChildOfClass(
                    "Humanoid"
                )

            local root =
                char
                and char:FindFirstChild(
                    "HumanoidRootPart"
                )

            local head =
                char
                and char:FindFirstChild(
                    "Head"
                )

            local valid = true

            if not IsEnemy(player) then
                valid = false
            end

            if not hum
                or hum.Health <= 0 then

                valid = false

            end

            if not root then
                valid = false
            end

            if valid then

                local distance =
                    (
                        root.Position
                        - Camera.CFrame.Position
                    ).Magnitude

                if distance >
                    Settings.ESPMaxDistance then

                    valid = false

                end

                if Settings.WallCheck
                    and not VisiblePart(root) then

                    valid = false

                end

            end

            if not valid then

                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
                data.Head.Enabled = false

            else

                local color =
                    ESPColor(player)

                local distance =
                    (
                        root.Position
                        - Camera.CFrame.Position
                    ).Magnitude

                -- BOX
                if Settings.ESPBox then

                    data.Highlight.Enabled = true
                    data.Highlight.Adornee = char

                    data.Highlight.FillColor =
                        color

                    data.Highlight.OutlineColor =
                        color

                    if Settings.ESPAlwaysOnTop then

                        data.Highlight.DepthMode =
                            Enum.HighlightDepthMode.AlwaysOnTop

                    else

                        data.Highlight.DepthMode =
                            Enum.HighlightDepthMode.Occluded

                    end

                else

                    data.Highlight.Enabled = false

                end

                -- INFO
                if Settings.ESPName
                    or Settings.ESPDistance
                    or Settings.ESPHealth then

                    data.Billboard.Enabled = true

                    data.Billboard.Adornee =
                        head or root

                    data.Name.Visible =
                        Settings.ESPName

                    data.Distance.Visible =
                        Settings.ESPDistance

                    data.Health.Visible =
                        Settings.ESPHealth

                    data.Name.Text =
                        player.DisplayName
                        ~= ""
                        and player.DisplayName
                        or player.Name

                    data.Name.TextColor3 =
                        color

                    data.Distance.Text =
                        math.floor(
                            distance
                        )
                        .. " studs"

                    local hpPercent =
                        math.clamp(
                            hum.Health
                            / math.max(
                                hum.MaxHealth,
                                1
                            ),
                            0,
                            1
                        )

                    data.Health.Text =
                        "HP: "
                        .. math.floor(
                            hum.Health
                        )
                        .. " / "
                        .. math.floor(
                            hum.MaxHealth
                        )

                    data.Health.TextColor3 =
                        Color3.new(
                            1 - hpPercent,
                            hpPercent,
                            0
                        )

                else

                    data.Billboard.Enabled = false

                end

                -- HEAD MARKER
                if Settings.ESPHead
                    and head then

                    data.Head.Adornee =
                        head

                    data.Head.Enabled =
                        true

                else

                    data.Head.Enabled =
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

local UpHeld = false
local DownHeld = false

local FlyButtons =
    Instance.new("Frame")

FlyButtons.Size =
    UDim2.fromOffset(
        110,
        48
    )

FlyButtons.Position =
    UDim2.new(
        1,
        -125,
        0.5,
        70
    )

FlyButtons.BackgroundTransparency = 1

FlyButtons.Visible = false

FlyButtons.Parent = GUI

local UpButton =
    Instance.new("TextButton")

UpButton.Size =
    UDim2.fromOffset(
        50,
        42
    )

UpButton.BackgroundColor3 =
    Colors.Panel

UpButton.BorderSizePixel = 0

UpButton.Text = "▲"

UpButton.TextColor3 =
    Colors.White

UpButton.Font =
    Enum.Font.GothamBold

UpButton.TextSize = 18

UpButton.Parent = FlyButtons

local UpCorner =
    Instance.new("UICorner")

UpCorner.CornerRadius =
    UDim.new(0, 10)

UpCorner.Parent = UpButton

local DownButton =
    Instance.new("TextButton")

DownButton.Size =
    UDim2.fromOffset(
        50,
        42
    )

DownButton.Position =
    UDim2.fromOffset(
        58,
        0
    )

DownButton.BackgroundColor3 =
    Colors.Panel

DownButton.BorderSizePixel = 0

DownButton.Text = "▼"

DownButton.TextColor3 =
    Colors.White

DownButton.Font =
    Enum.Font.GothamBold

DownButton.TextSize = 18

DownButton.Parent = FlyButtons

local DownCorner =
    Instance.new("UICorner")

DownCorner.CornerRadius =
    UDim.new(0, 10)

DownCorner.Parent = DownButton

local function HoldButton(
    button,
    callback
)

    button.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.Touch
                or input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                callback(true)

            end

        end
    )

    button.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.Touch
                or input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                callback(false)

            end

        end
    )

end

HoldButton(
    UpButton,
    function(v)
        UpHeld = v
    end
)

HoldButton(
    DownButton,
    function(v)
        DownHeld = v
    end
)

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

    FlyButtons.Visible = false

end

function StartFly()

    if not Root
        or not Humanoid then

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

    -- Stop existing falling velocity
    Root.AssemblyLinearVelocity =
        Vector3.zero

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

    -- IMPORTANT:
    -- Always controls Y velocity,
    -- so gravity cannot make the
    -- player slowly fall while flying.
    FlyVelocity.VectorVelocity =
        Vector3.zero

    FlyVelocity.Parent =
        Root

    FlyButtons.Visible =
        UserInputService.TouchEnabled

end

local function UpdateFly()

    if not Settings.FlyEnabled then
        return
    end

    if not Root
        or not Humanoid
        or Humanoid.Health <= 0 then

        StopFly()
        return

    end

    if not FlyVelocity then

        StartFly()
        return

    end

    local cf =
        Camera.CFrame

    local forward =
        Vector3.new(
            cf.LookVector.X,
            0,
            cf.LookVector.Z
        )

    local right =
        Vector3.new(
            cf.RightVector.X,
            0,
            cf.RightVector.Z
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

        local f =
            move:Dot(forward)

        local r =
            move:Dot(right)

        horizontal =
            forward * f
            + right * r

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
        horizontal
        * Settings.FlySpeed
        + Vector3.new(
            0,
            vertical,
            0
        )

end

--============================================================
-- SPEED
--============================================================

local NormalSpeed = 16

local function UpdateSpeed()

    if not Humanoid then
        return
    end

    if Settings.SpeedEnabled then

        Humanoid.WalkSpeed =
            Settings.SpeedRun

    else

        Humanoid.WalkSpeed =
            NormalSpeed

    end

end

--============================================================
-- FPS BOOST
--============================================================

local FPSSaved = {}

local function ApplyFPSBoost()

    if not Settings.FPSBoost then
        return
    end

    Lighting.GlobalShadows = false

    Lighting.FogEnd = 100000

    for _, obj in ipairs(
        Lighting:GetChildren()
    ) do

        if obj:IsA("BloomEffect")
            or obj:IsA("BlurEffect")
            or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("SunRaysEffect")
            or obj:IsA("DepthOfFieldEffect") then

            if FPSSaved[obj] == nil then
                FPSSaved[obj] = obj.Enabled
            end

            obj.Enabled = false

        end

    end

    local terrain =
        Workspace:FindFirstChildOfClass(
            "Terrain"
        )

    if terrain then

        terrain.Decoration = false

        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0

    end

    for _, obj in ipairs(
        Workspace:GetDescendants()
    ) do

        if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles") then

            if FPSSaved[obj] == nil then
                FPSSaved[obj] = obj.Enabled
            end

            obj.Enabled = false

        end

    end

end

--============================================================
-- FPS COUNTER
--============================================================

local FPSLabel =
    Instance.new("TextLabel")

FPSLabel.Size =
    UDim2.fromOffset(
        120,
        25
    )

FPSLabel.Position =
    UDim2.fromOffset(
        10,
        10
    )

FPSLabel.BackgroundTransparency = 1

FPSLabel.TextColor3 =
    Colors.White

FPSLabel.TextStrokeTransparency = 0.3

FPSLabel.Font =
    Enum.Font.GothamBold

FPSLabel.TextSize = 11

FPSLabel.TextXAlignment =
    Enum.TextXAlignment.Left

FPSLabel.Visible = false

FPSLabel.Parent = GUI

local FPSFrames = 0
local FPSTime = 0

--============================================================
-- KEYBINDS
--============================================================

UserInputService.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if not Unlocked then
            return
        end

        -- R = FLY
        if input.KeyCode ==
            Enum.KeyCode.R then

            if Settings.FlyEnabled then
                StopFly()
            else
                StartFly()
            end

            RefreshAll()

        end

        -- V = SPEED
        if input.KeyCode ==
            Enum.KeyCode.V then

            Settings.SpeedEnabled =
                not Settings.SpeedEnabled

            UpdateSpeed()

            RefreshAll()

        end

    end
)

--============================================================
-- RESPAWN
--============================================================

LP.CharacterAdded:Connect(
    function(char)

        SetCharacter(char)

        task.wait(0.4)

        if Settings.SpeedEnabled then
            UpdateSpeed()
        end

        if Settings.FlyEnabled then

            StopFly()

        end

    end
)

--============================================================
-- PLAYER CLEANUP
--============================================================

Players.PlayerRemoving:Connect(
    function(player)

        DestroyESP(player)

        if PlayerLines[player] then

            PlayerLines[player]:Destroy()
            PlayerLines[player] = nil

        end

    end
)

--============================================================
-- MAIN LOOP
--============================================================

local ESPTimer = 0

RunService.RenderStepped:Connect(
    function(dt)

        if not Unlocked then
            return
        end

        Camera =
            Workspace.CurrentCamera

        -- AIM
        if Settings.AimEnabled then

            local target =
                GetBestTarget()

            if target then

                local cameraPos =
                    Camera.CFrame.Position

                local targetCF =
                    CFrame.lookAt(
                        cameraPos,
                        target.Position
                    )

                local strength =
                    math.clamp(
                        Settings.LockStrength
                        / 100,
                        0.01,
                        1
                    )

                local speed =
                    math.clamp(
                        Settings.AimSpeed
                        / 100,
                        0.01,
                        1
                    )

                local alpha =
                    math.clamp(
                        strength
                        * speed
                        * 0.4,
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

        -- FLY
        if Settings.FlyEnabled then
            UpdateFly()
        end

        -- SPEED
        if Settings.SpeedEnabled then
            UpdateSpeed()
        end

        -- ESP
        ESPTimer += dt

        local interval =
            1 / math.max(
                Settings.ESPUpdateRate,
                1
            )

        if ESPTimer >= interval then

            ESPTimer = 0

            UpdatePlayerESP()
            UpdateCloudESP()
            UpdatePlayerLines()

        end

        -- FPS
        FPSFrames += 1
        FPSTime += dt

        if FPSTime >= 0.5 then

            local fps =
                math.floor(
                    FPSFrames / FPSTime
                )

            FPSFrames = 0
            FPSTime = 0

            FPSLabel.Text =
                "FPS: "
                .. tostring(fps)

            FPSLabel.Visible =
                Settings.ShowFPS

        end

    end
)

--============================================================
-- PERFORMANCE LOOP
--============================================================

task.spawn(function()

    while task.wait(2) do

        if Unlocked
            and Settings.FPSBoost
            and Settings.DynamicFPS then

            ApplyFPSBoost()

        end

    end

end)

--============================================================
-- STARTUP
--============================================================

task.delay(
    1,
    function()

        if Settings.FPSBoost then
            ApplyFPSBoost()
        end

    end
)

print(
    "XEIREN 5V5 Combat Hub loaded"
)

print(
    "Password: anakin"
)

print(
    "R = Fly | V = Speed"
)
