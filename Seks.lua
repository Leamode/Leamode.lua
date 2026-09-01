-- ============================================================
-- HAMSTER LIVES - METRO MOD V3 (TREADMILL FIX)
-- 250 TRİLYON HIZ | METRO GİBİ BİN | BOSS BYPASS
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🚇 METRO MOD V3 BAŞLADI...")

local MetroActive = false
local Speed = 250000000000000
local Character = nil
local HumanoidRootPart = nil
local MenuVisible = false
local IsMoving = false
local MetroGui = nil
local ToggleBtn = nil
local MoveConnection = nil
local LastTarget = nil

-- ============================================================
-- KARAKTER AL
-- ============================================================
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    return Character
end

-- ============================================================
-- HEDEF BELİRLEME
-- ============================================================
local function GetTargetPosition()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    
    local ray = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 10000, rayParams)
    
    if ray then
        return ray.Position
    else
        return cam.CFrame.Position + cam.CFrame.LookVector * 10000
    end
end

-- ============================================================
-- METRO HAREKET (TREADMILL GÜVENLİ)
-- ============================================================
local function MetroMove()
    if not MetroActive then return end
    if IsMoving then return end
    if not HumanoidRootPart then return end
    
    local target = GetTargetPosition()
    if not target then return end
    
    -- Aynı hedefe tekrar gitme (gereksiz döngüyü engelle)
    if LastTarget and (target - LastTarget).Magnitude < 5 then
        return
    end
    LastTarget = target
    
    IsMoving = true
    
    -- Treadmill hatasını önlemek için karakteri sabitle
    local hum = Character:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    -- BodyVelocity ile hızlanma
    local bp = Instance.new("BodyVelocity")
    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp.Velocity = (target - HumanoidRootPart.Position).Unit * Speed
    bp.Parent = HumanoidRootPart
    
    -- BodyPosition ile hedefe çek
    local bp2 = Instance.new("BodyPosition")
    bp2.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp2.Position = target
    bp2.Parent = HumanoidRootPart
    bp2.D = 1000
    bp2.P = 10000
    
    -- Hedefe ulaşana kadar bekle
    local startTime = tick()
    while (HumanoidRootPart.Position - target).Magnitude > 5 and tick() - startTime < 2 do
        HumanoidRootPart.CFrame = CFrame.new(target)
        task.wait(0.01)
    end
    
    -- Temizlik
    task.wait(0.05)
    pcall(function()
        bp:Destroy()
        bp2:Destroy()
    end)
    
    -- Son CFrame
    HumanoidRootPart.CFrame = CFrame.new(target)
    
    if hum then
        hum.PlatformStand = false
    end
    
    IsMoving = false
end

-- ============================================================
-- TOGGLE
-- ============================================================
local function ToggleMetro()
    MetroActive = not MetroActive
    GetCharacter()
    
    if MetroActive then
        print("🚇 METRO MOD AKTİF!")
        LastTarget = nil
        task.wait(0.1)
        MetroMove()
    else
        print("🚇 METRO MOD KAPALI!")
        LastTarget = nil
        IsMoving = false
    end
end

-- ============================================================
-- OTOMATİK HAREKET (DÜZGÜN DÖNGÜ)
-- ============================================================
local function StartAutoMove()
    if MoveConnection then
        MoveConnection:Disconnect()
        MoveConnection = nil
    end
    
    MoveConnection = RunService.Heartbeat:Connect(function()
        if MetroActive and not IsMoving then
            MetroMove()
        end
    end)
end

-- ============================================================
-- MENU
-- ============================================================
local function CreateMenu()
    if MetroGui then 
        MetroGui:Destroy()
        MetroGui = nil
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MetroMenu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.Enabled = false
    MetroGui = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 140, 0, 80)
    frame.Position = UDim2.new(1, -150, 0, 5)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.Parent = gui
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.5
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "🚇 METRO MOD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 18, 0, 18)
    close.Position = UDim2.new(1, -22, 0, 2)
    close.BackgroundTransparency = 1
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.TextSize = 11
    close.Font = Enum.Font.GothamBold
    close.Parent = title
    close.MouseButton1Click:Connect(function()
        gui.Enabled = false
        MenuVisible = false
    end)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 24)
    btn.Position = UDim2.new(0.05, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.Text = "🚇 AKTİF ET"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        ToggleMetro()
        btn.Text = MetroActive and "🚇 DURDUR" or "🚇 AKTİF ET"
        btn.BackgroundColor3 = MetroActive and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(20, 20, 40)
    end)
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.new(0, 0, 0, 54)
    info.BackgroundTransparency = 1
    info.Text = "⚡ 250 Trilyon hız"
    info.TextColor3 = Color3.fromRGB(150, 150, 150)
    info.TextSize = 8
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Center
    info.Parent = frame
    
    return gui
end

-- ============================================================
-- AÇMA BUTONU
-- ============================================================
local function CreateToggle()
    if ToggleBtn then 
        ToggleBtn:Destroy()
        ToggleBtn = nil
    end
    
    local btn = Instance.new("TextButton")
    btn.Name = "MetroToggle"
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(1, -44, 0, 55)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.Text = "🚇"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CoreGui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    ToggleBtn = btn
    
    btn.MouseButton1Click:Connect(function()
        if not MetroGui or not MetroGui.Parent then
            MetroGui = CreateMenu()
        end
        if MetroGui then
            MenuVisible = not MenuVisible
            MetroGui.Enabled = MenuVisible
        end
    end)
end

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GetCharacter()
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateToggle()
StartAutoMove()

print("")
print("========================================")
print("🚇 METRO MOD V3 HAZIR!")
print("   📌 Sağ üstteki 🚇 butonuna tıkla")
print("   ⚡ 250 Trilyon hız")
print("   🎯 Baktığın yere anında var")
print("   ✅ Treadmill hatası giderildi")
print("========================================")
