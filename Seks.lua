-- ============================================================
-- HAMSTER LIVES - MEVLANA MOD (360 DERECE DÖNÜŞ)
-- KAMERA SABİT | KARAKTER 360 DÖNER | SAĞ ÜST BUTON
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("🔄 MEVLANA MOD BAŞLADI...")

local ModActive = false
local RotationSpeed = 5
local CurrentAngle = 0
local Character = nil
local HumanoidRootPart = nil

-- ============================================================
-- KARAKTERİ AL
-- ============================================================
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    return Character
end

-- ============================================================
-- DÖNÜŞ FONKSİYONU
-- ============================================================
local function StartSpinning()
    if not ModActive then return end
    
    CurrentAngle = CurrentAngle + RotationSpeed
    if CurrentAngle > 360 then
        CurrentAngle = CurrentAngle - 360
    end
    
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(CurrentAngle), 0)
    end
end

-- ============================================================
-- MOD BAŞLAT/DURDUR
-- ============================================================
local function ToggleMod()
    ModActive = not ModActive
    GetCharacter()
    
    if ModActive then
        print("🔄 MEVLANA MOD AKTİF! (360 dönüş)")
        -- Dönüş döngüsünü başlat
        task.spawn(function()
            while ModActive do
                StartSpinning()
                task.wait(0.016) -- ~60 FPS
            end
        end)
    else
        print("⏹️ MEVLANA MOD DURDURULDU!")
    end
end

-- ============================================================
-- KARAKTER DEĞİŞİMİNİ İZLE
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GetCharacter()
    if ModActive then
        print("🔄 Karakter yeniden doğdu, dönüş devam ediyor...")
    end
end)

-- ============================================================
-- MENU BUTONU (SAĞ ÜST)
-- ============================================================
local function CreateButton()
    local old = CoreGui:FindFirstChild("MevlanaButton")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MevlanaButton"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = UDim2.new(1, -54, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "🌀"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.Parent = gui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.5
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 60, 0, 16)
    status.Position = UDim2.new(1, -65, 0, 48)
    status.BackgroundTransparency = 1
    status.Text = "KAPALI"
    status.TextColor3 = Color3.fromRGB(255, 50, 50)
    status.TextSize = 8
    status.Font = Enum.Font.GothamBold
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = gui
    status.ZIndex = 999
    
    btn.MouseButton1Click:Connect(function()
        ToggleMod()
        if ModActive then
            btn.Text = "🌀⚡"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            status.Text = "AKTİF"
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            btn.Text = "🌀"
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            status.Text = "KAPALI"
            status.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    return btn
end

-- ============================================================
-- ESC İLE KAPAT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        if ModActive then
            ModActive = false
            print("⏹️ ESC ile MEVLANA MOD kapatıldı!")
        end
    end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateButton()

print("")
print("========================================")
print("🌀 MEVLANA MOD HAZIR!")
print("   📌 Sağ üstteki 🌀 butonuna tıkla")
print("   🔄 Karakter 360 derece döner")
print("   🎥 Kamera sabit kalır")
print("   ⏹️ ESC ile kapat")
print("========================================")
