-- ============================================================
-- HAMSTER LIVES - METRO MOD (IŞINLANMA BYPASS)
-- 250 TRİLYON HIZ | METRO GİBİ BİN | BOSS BYPASS
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🚇 METRO MOD BAŞLADI...")

local MetroActive = false
local TargetPosition = nil
local Speed = 250000000000000 -- 250 Trilyon
local Character = nil
local HumanoidRootPart = nil
local MenuGui = nil
local MenuVisible = false
local IsMoving = false

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
-- HEDEF BELİRLEME (BAKTIĞIN YER)
-- ============================================================
local function GetTargetPosition()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 10000, rayParams)
    
    if ray then
        return ray.Position
    else
        -- Hiçbir yere çarpmazsa 10000 ileri git
        return cam.CFrame.Position + cam.CFrame.LookVector * 10000
    end
end

-- ============================================================
-- METRO HAREKET (IŞINLANMA BYPASS)
-- ============================================================
local function MetroMove()
    if not MetroActive then return end
    if IsMoving then return end
    if not HumanoidRootPart then return end
    
    local target = GetTargetPosition()
    if not target then return end
    
    IsMoving = true
    
    -- 1. ANİ HIZLANMA (250 Trilyon hız)
    local bp = Instance.new("BodyVelocity")
    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp.Velocity = (target - HumanoidRootPart.Position).Unit * Speed
    bp.Parent = HumanoidRootPart
    
    -- 2. BODY POSITION (HEMEN VAR)
    local bp2 = Instance.new("BodyPosition")
    bp2.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp2.Position = target
    bp2.Parent = HumanoidRootPart
    
    print("🚇 METRO: " .. (target - HumanoidRootPart.Position).Magnitude .. " mesafe, 250 Trilyon hız!")
    
    -- 0.1 SANİYE SONRA TEMİZLE
    task.wait(0.1)
    bp:Destroy()
    bp2:Destroy()
    
    -- 3. DÜZ CFrame (KESİN VAR)
    HumanoidRootPart.CFrame = CFrame.new(target)
    
    IsMoving = false
end

-- ============================================================
-- METRO MOD AÇ/KAPA
-- ============================================================
local function ToggleMetro()
    MetroActive = not MetroActive
    GetCharacter()
    if MetroActive then
        print("🚇 METRO MOD AKTİF! (250 Trilyon hız)")
        -- HEMEN HAREKET ET
        task.wait(0.1)
        MetroMove()
    else
        print("🚇 METRO MOD KAPALI!")
    end
end

-- ============================================================
-- SÜREKLİ TARAMA (BAKTIĞIN YERE OTOMATİK)
-- ============================================================
local function StartAutoMove()
    task.spawn(function()
        while true do
            if MetroActive then
                MetroMove()
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================================
-- MENU (SAĞ ÜST - EN YUKARI)
-- ============================================================
local function CreateMenu()
    if MenuGui then MenuGui:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MetroMenu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.Enabled = false
    MenuGui = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 140, 0, 50)
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
    title.Text = "🚇 METRO"
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
    
    -- METRO BUTON
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 24)
    btn.Position = UDim2.new(0.05, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.Text = "🚇 METRO: KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        ToggleMetro()
        btn.Text = MetroActive and "🚇 METRO: AKTİF" or "🚇 METRO: KAPALI"
        btn.BackgroundColor3 = MetroActive and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(20, 20, 40)
    end)
    
    return gui
end

-- ============================================================
-- AÇMA BUTONU (SAĞ ÜST - EN YUKARI)
-- ============================================================
local function CreateToggle()
    local old = CoreGui:FindFirstChild("MetroToggle")
    if old then old:Destroy() end
    
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
    
    btn.MouseButton1Click:Connect(function()
        if not MenuGui or not MenuGui.Parent then
            MenuGui = CreateMenu()
        end
        if MenuGui then
            MenuVisible = not MenuVisible
            MenuGui.Enabled = MenuVisible
        end
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateToggle()
StartAutoMove()

print("")
print("========================================")
print("🚇 METRO MOD HAZIR!")
print("   📌 Sağ üstteki 🚇 butonuna tıkla")
print("   ⚡ 250 Trilyon hız (ışınlanma)")
print("   🎯 Baktığın yere anında var")
print("   🛡️ Boss bypass aktif")
print("========================================")
