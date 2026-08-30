-- ============================================================
-- HAMSTER LIVES - MEVLANA MOD V2 (HIZ AYARLI)
-- 360 DERECE DÖNÜŞ | HIZ AYARLI | SAĞ ÜST BUTON
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("🌀 MEVLANA MOD V2 BAŞLADI...")

local ModActive = false
local RotationSpeed = 30  -- Başlangıç hızı (derece/frame)
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
        print("🌀 MEVLANA MOD AKTİF! (Hız: " .. RotationSpeed .. " derece/frame)")
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
-- HIZ AYARLAMA
-- ============================================================
local function SetSpeed(value)
    RotationSpeed = math.clamp(value, 5, 200)
    print("🌀 Dönüş hızı: " .. RotationSpeed .. " derece/frame")
end

-- ============================================================
-- KARAKTER DEĞİŞİMİNİ İZLE
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GetCharacter()
    if ModActive then
        print("🌀 Karakter yeniden doğdu, dönüş devam ediyor...")
    end
end)

-- ============================================================
-- MENU BUTONU + HIZ AYARI (SAĞ ÜST)
-- ============================================================
local function CreateButton()
    local old = CoreGui:FindFirstChild("MevlanaButton")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MevlanaButton"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    -- ANA BUTON
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
    
    -- HIZ ÇUBUĞU (YANINA)
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(0, 80, 0, 20)
    speedFrame.Position = UDim2.new(1, -90, 0, 108)
    speedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    speedFrame.BackgroundTransparency = 0.3
    speedFrame.Parent = gui
    speedFrame.ZIndex = 999
    Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(1, 0)
    
    -- DOLU KISIM
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((RotationSpeed - 5) / 195, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    fill.BorderSizePixel = 0
    fill.Parent = speedFrame
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    -- HIZ ETİKETİ
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 1, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = math.round(RotationSpeed) .. "°"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 9
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.Parent = speedFrame
    speedLabel.ZIndex = 1000
    
    -- ARTTIR BUTONU
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 20, 0, 20)
    upBtn.Position = UDim2.new(1, -75, 0, 60)
    upBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    upBtn.Text = "▲"
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.TextSize = 12
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Parent = gui
    upBtn.ZIndex = 999
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(1, 0)
    
    upBtn.MouseEnter:Connect(function()
        upBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end)
    upBtn.MouseLeave:Connect(function()
        upBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
    
    upBtn.MouseButton1Click:Connect(function()
        SetSpeed(RotationSpeed + 10)
        fill.Size = UDim2.new((RotationSpeed - 5) / 195, 0, 1, 0)
        speedLabel.Text = math.round(RotationSpeed) .. "°"
    end)
    
    -- AZALT BUTONU
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 20, 0, 20)
    downBtn.Position = UDim2.new(1, -75, 0, 82)
    downBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    downBtn.Text = "▼"
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.TextSize = 12
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Parent = gui
    downBtn.ZIndex = 999
    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(1, 0)
    
    downBtn.MouseEnter:Connect(function()
        downBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end)
    downBtn.MouseLeave:Connect(function()
        downBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end)
    
    downBtn.MouseButton1Click:Connect(function()
        SetSpeed(RotationSpeed - 10)
        fill.Size = UDim2.new((RotationSpeed - 5) / 195, 0, 1, 0)
        speedLabel.Text = math.round(RotationSpeed) .. "°"
    end)
    
    -- ANA BUTON İŞLEVİ
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
print("🌀 MEVLANA MOD V2 HAZIR!")
print("   📌 Sağ üstteki 🌀 butonuna tıkla")
print("   🔄 Karakter 360 derece döner")
print("   🎥 Kamera sabit kalır")
print("   📊 ▲▼ ile dönüş hızını ayarla")
print("   ⏹️ ESC ile kapat")
print("========================================")
