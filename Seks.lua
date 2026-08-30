-- ============================================================
-- HAMSTER LIVES - BRUTAL HITBOX MOD V3 (SADE HITBOX)
-- HITBOX 40x | GÖRÜNMEZ | KASMA YOK | TRIGGERBOT
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("💀 BRUTAL HITBOX MOD V3 BAŞLADI...")

local BrutalActive = false
local HitboxSize = 40

-- ============================================================
-- HITBOX BÜYÜTME (GÖRÜNMEZ - KASMA YOK)
-- ============================================================
local function SetHitboxSize()
    if not BrutalActive then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Transparency = 1
                    hrp.Material = Enum.Material.Plastic
                    hrp.CanCollide = false
                end
            end
        end
    end
end

-- ============================================================
-- HITBOX'LARI NORMALE DÖNDÜR
-- ============================================================
local function ResetHitboxSize()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 2)
                    hrp.Transparency = 0
                    hrp.Material = Enum.Material.Plastic
                    hrp.CanCollide = true
                end
            end
        end
    end
end

-- ============================================================
-- TEAM CHECK
-- ============================================================
local function IsSameTeam(player)
    local localTeam = LocalPlayer.Team
    local targetTeam = player.Team
    if localTeam and targetTeam then
        return localTeam == targetTeam
    end
    return false
end

-- ============================================================
-- WALL CHECK
-- ============================================================
local function CanSeeTarget(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = Workspace:Raycast(hrp.Position, (targetPos - hrp.Position).Unit * 300, rayParams)
    
    if ray then
        local hit = ray.Instance
        if hit and hit.Parent then
            if hit.Parent:FindFirstChild("Humanoid") then
                return true
            end
            return false
        end
    end
    return true
end

-- ============================================================
-- TRIGGERBOT (HITBOX GÖRÜNCE OTOMATİK SIK)
-- ============================================================
local function TriggerBot()
    if not BrutalActive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            
            -- TEAM CHECK
            if IsSameTeam(player) then
                continue
            end
            
            local tChar = player.Character
            if not tChar then continue end
            
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            if not tHrp then continue end
            
            local tHum = tChar:FindFirstChild("Humanoid")
            if not tHum then continue end
            
            -- ÖLÜ MÜ?
            if tHum.Health <= 0 then
                continue
            end
            
            local dist = (hrp.Position - tHrp.Position).Magnitude
            
            -- WALL CHECK
            if not CanSeeTarget(tHrp.Position) then
                continue
            end
            
            -- HITBOX İÇİNDE Mİ? (40x büyütülmüş hitbox)
            if dist < HitboxSize then
                -- OTOMATİK SIK
                pcall(function()
                    UserInputService:SetKeyDown(Enum.KeyCode.Button1)
                    task.wait(0.05)
                    UserInputService:SetKeyUp(Enum.KeyCode.Button1)
                end)
                break
            end
        end
    end
end

-- ============================================================
-- BRUTAL MOD AÇ/KAPA
-- ============================================================
local function ToggleBrutal()
    BrutalActive = not BrutalActive
    
    if BrutalActive then
        print("💀 BRUTAL HITBOX MOD V3 AKTİF!")
        print("   📏 Hitbox 40x büyütüldü (görünmez)")
        print("   🎯 Triggerbot aktif (hitbox içinde sıkar)")
        print("   🛡️ Team/Wall check aktif")
        
        SetHitboxSize()
        
        -- ANA DÖNGÜ (SADECE HITBOX + TRIGGER)
        task.spawn(function()
            while BrutalActive do
                SetHitboxSize()
                TriggerBot()
                task.wait(0.1)
            end
        end)
    else
        print("💀 BRUTAL HITBOX MOD V3 KAPATILDI!")
        ResetHitboxSize()
    end
end

-- ============================================================
-- MENU BUTONU
-- ============================================================
local function CreateButton()
    local old = CoreGui:FindFirstChild("BrutalButton")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BrutalButton"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = UDim2.new(1, -54, 0, 110)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "💀"
    btn.TextColor3 = Color3.fromRGB(255, 50, 50)
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.Parent = gui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Transparency = 0.5
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 60, 0, 16)
    status.Position = UDim2.new(1, -65, 0, 98)
    status.BackgroundTransparency = 1
    status.Text = "KAPALI"
    status.TextColor3 = Color3.fromRGB(255, 50, 50)
    status.TextSize = 8
    status.Font = Enum.Font.GothamBold
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = gui
    status.ZIndex = 999
    
    btn.MouseButton1Click:Connect(function()
        ToggleBrutal()
        if BrutalActive then
            btn.Text = "💀🔥"
            btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            status.Text = "AKTİF"
            status.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            btn.Text = "💀"
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            status.Text = "KAPALI"
            status.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    return btn
end

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if BrutalActive then
        SetHitboxSize()
    end
end)

-- ============================================================
-- YENİ OYUNCU GİRİŞİ
-- ============================================================
Players.PlayerAdded:Connect(function()
    if BrutalActive then
        task.wait(0.5)
        SetHitboxSize()
    end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
CreateButton()

print("")
print("========================================")
print("💀 BRUTAL HITBOX MOD V3")
print("   📌 Sağ üstteki 💀 butonuna tıkla")
print("   📏 Hitbox 40x (görünmez)")
print("   🎯 Triggerbot (hitbox içinde sıkar)")
print("   🛡️ Team/Wall check")
print("   ⚡ KASMA YOK")
print("========================================")
