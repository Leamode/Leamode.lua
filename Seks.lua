-- ============================================================
-- HAMSTER LIVES - METRO MOD V6
-- CAMERA DIRECTION + HUMANOID SPEED
-- 100 TRİLYON SPEED
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("🚇 METRO MOD V6 BAŞLADI")

-- ============================================================
-- AYARLAR
-- ============================================================

local SPEED = 100000000000000

local MetroActive = false
local Character = nil
local Humanoid = nil
local RootPart = nil

local MetroGui = nil
local ToggleButton = nil
local MoveConnection = nil

local OldWalkSpeed = nil
local OldAutoRotate = nil

-- ============================================================
-- KARAKTER
-- ============================================================

local function GetCharacter()
    Character = LocalPlayer.Character

    if not Character then
        return false
    end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")

    return Humanoid ~= nil and RootPart ~= nil
end

-- ============================================================
-- METRO HAREKET
-- ============================================================

local function StartMetro()
    if not GetCharacter() then
        return
    end

    if MetroActive then
        return
    end

    MetroActive = true

    OldWalkSpeed = Humanoid.WalkSpeed
    OldAutoRotate = Humanoid.AutoRotate

    -- Oyunun kendi speed sistemini kullan
    Humanoid.WalkSpeed = SPEED

    -- Karakter kamera yönünü takip etsin
    Humanoid.AutoRotate = false

    print("🚇 METRO AKTİF")
    print("⚡ Speed: " .. tostring(SPEED))

    if MoveConnection then
        MoveConnection:Disconnect()
    end

    MoveConnection = RunService.RenderStepped:Connect(function()
        if not MetroActive then
            return
        end

        if not Character
            or not Character.Parent
            or not Humanoid
            or not Humanoid.Parent
            or not RootPart
        then
            GetCharacter()
            return
        end

        local Camera = workspace.CurrentCamera

        if not Camera then
            return
        end

        -- Kameranın baktığı yatay yön
        local Look = Camera.CFrame.LookVector
        local Direction = Vector3.new(Look.X, 0, Look.Z)

        if Direction.Magnitude > 0 then
            Direction = Direction.Unit

            -- Karakteri baktığın yöne çevir
            RootPart.CFrame = CFrame.lookAt(
                RootPart.Position,
                RootPart.Position + Direction
            )

            -- Humanoid'in normal hareket sistemini kullan
            Humanoid:Move(Direction, false)
        end
    end)
end

-- ============================================================
-- METRO DURDUR
-- ============================================================

local function StopMetro()
    if not MetroActive then
        return
    end

    MetroActive = false

    if MoveConnection then
        MoveConnection:Disconnect()
        MoveConnection = nil
    end

    if GetCharacter() then
        if OldWalkSpeed then
            Humanoid.WalkSpeed = OldWalkSpeed
        end

        if OldAutoRotate ~= nil then
            Humanoid.AutoRotate = OldAutoRotate
        else
            Humanoid.AutoRotate = true
        end

        -- Normal hareketi geri ver
        Humanoid:Move(Vector3.zero, false)
    end

    print("🚇 METRO KAPALI")
end

-- ============================================================
-- TOGGLE
-- ============================================================

local function ToggleMetro()
    if MetroActive then
        StopMetro()
    else
        StartMetro()
    end
end

-- ============================================================
-- GUI TEMİZLE
-- ============================================================

pcall(function()
    local OldGui = PlayerGui:FindFirstChild("HamsterMetroV6")

    if OldGui then
        OldGui:Destroy()
    end
end)

-- ============================================================
-- ANA GUI
-- ============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "HamsterMetroV6"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

MetroGui = Gui

-- ============================================================
-- AÇMA BUTONU
-- ============================================================

local Toggle = Instance.new("TextButton")

Toggle.Name = "MetroToggle"
Toggle.Size = UDim2.fromOffset(52, 52)
Toggle.Position = UDim2.new(1, -65, 0, 80)

Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Toggle.BackgroundTransparency = 0.05

Toggle.Text = "🚇"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 25
Toggle.Font = Enum.Font.GothamBold

Toggle.AutoButtonColor = true
Toggle.Active = true

Toggle.Parent = Gui

Toggle.ZIndex = 100

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = Toggle

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.2
ToggleStroke.Parent = Toggle

ToggleButton = Toggle

-- ============================================================
-- MENÜ
-- ============================================================

local Menu = Instance.new("Frame")

Menu.Name = "MetroMenu"
Menu.Size = UDim2.fromOffset(210, 135)
Menu.Position = UDim2.new(1, -225, 0, 140)

Menu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Menu.BackgroundTransparency = 0.05

Menu.Visible = false
Menu.Active = true
Menu.Parent = Gui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 2
MenuStroke.Transparency = 0.2
MenuStroke.Parent = Menu

-- ============================================================
-- BAŞLIK
-- ============================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, 0, 0, 35)

Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

Title.Text = "🚇 METRO MOD V6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

Title.TextSize = 14
Title.Font = Enum.Font.GothamBold

Title.Parent = Menu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ============================================================
-- DURUM
-- ============================================================

local Status = Instance.new("TextLabel")

Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.fromOffset(10, 42)

Status.BackgroundTransparency = 1

Status.Text = "Durum: KAPALI"
Status.TextColor3 = Color3.fromRGB(220, 220, 220)

Status.TextSize = 12
Status.Font = Enum.Font.GothamBold

Status.Parent = Menu

-- ============================================================
-- AKTİF ET BUTONU
-- ============================================================

local Activate = Instance.new("TextButton")

Activate.Size = UDim2.new(1, -20, 0, 35)
Activate.Position = UDim2.fromOffset(10, 72)

Activate.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

Activate.Text = "🚇 AKTİF ET"

Activate.TextColor3 = Color3.fromRGB(255, 255, 255)
Activate.TextSize = 12
Activate.Font = Enum.Font.GothamBold

Activate.Parent = Menu

local ActivateCorner = Instance.new("UICorner")
ActivateCorner.CornerRadius = UDim.new(0, 6)
ActivateCorner.Parent = Activate

-- ============================================================
-- BUTON DURUMU
-- ============================================================

local function UpdateButton()
    if MetroActive then
        Activate.Text = "🛑 METROYU DURDUR"
        Activate.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        Status.Text = "Durum: AKTİF"
    else
        Activate.Text = "🚇 AKTİF ET"
        Activate.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Status.Text = "Durum: KAPALI"
    end
end

-- ============================================================
-- MENÜYÜ AÇ / KAPAT
-- ============================================================

Toggle.Activated:Connect(function()
    Menu.Visible = not Menu.Visible

    print("🚇 Menü: " .. tostring(Menu.Visible))
end)

-- ============================================================
-- AKTİF ET
-- ============================================================

Activate.Activated:Connect(function()
    ToggleMetro()
    UpdateButton()
end)

-- ============================================================
-- KARAKTER DEĞİŞİNCE
-- ============================================================

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)

    Character = NewCharacter
    Humanoid = nil
    RootPart = nil

    task.wait(1)

    GetCharacter()

    if MetroActive and Humanoid then
        Humanoid.WalkSpeed = SPEED
        Humanoid.AutoRotate = false
    end

end)

-- ============================================================
-- BAŞLANGIÇ
-- ============================================================

GetCharacter()
UpdateButton()

print("========================================")
print("🚇 HAMSTER METRO V6 HAZIR")
print("⚡ Speed: 100 TRİLYON")
print("🎯 Kamera yönüne hareket")
print("📱 Mobil Activated desteği")
print("========================================")
