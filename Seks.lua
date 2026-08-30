-- ============================================================
-- HAMSTER LIVES - BRUTAL MOD V2 (GELİŞMİŞ)
-- HITBOX 40x | TRIGGERBOT | AIMBOT | TEAM/WALL/KILL CHECK
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("💀 BRUTAL MOD V2 BAŞLADI...")

local BrutalActive = false
local AimTarget = nil
local CurrentWeapon = nil
local HitboxSize = 40
local FOVRadius = 300

-- ============================================================
-- HITBOX BÜYÜTME (40x)
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
                    hrp.Transparency = 0.3
                    hrp.Material = Enum.Material.Neon
                    hrp.BrickColor = BrickColor.new("Bright red")
                end
                -- Tüm parçaları büyüt
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= hrp then
                        part.Size = part.Size * 2
                    end
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
                end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= hrp then
                        part.Size = part.Size / 2
                    end
                end
            end
        end
    end
end

-- ============================================================
-- SİLAH TESPİTİ (GELİŞMİŞ)
-- ============================================================
local function DetectWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Tool ara
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    
    -- Accessory ara
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            return child
        end
    end
    
    -- Humanoid'de EquipTool kontrol et
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        local equipTool = hum:FindFirstChild("EquipTool")
        if equipTool then
            return equipTool.Parent
        end
    end
    
    return nil
end

-- ============================================================
-- WALL CHECK (GELİŞMİŞ)
-- ============================================================
local function CanSeeTarget(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Raycast ile duvar kontrolü
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    
    local ray = Workspace:Raycast(hrp.Position, (targetPos - hrp.Position).Unit * 500, rayParams)
    
    if ray then
        local hit = ray.Instance
        if hit and hit.Parent then
            if hit.Parent:FindFirstChild("Humanoid") then
                return true
            else
                return false
            end
        end
    end
    return true
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
-- EN YAKIN HEDEF BUL (FOV İLE)
-- ============================================================
local function FindClosestTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest = nil
    local closestDist = FOVRadius
    local pos = hrp.Position
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    local camLook = cam.CFrame.LookVector
    
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
            
            -- KILL CHECK (ÖLÜ MÜ?)
            if tHum.Health <= 0 then
                continue
            end
            
            local dist = (pos - tHrp.Position).Magnitude
            
            -- FOV KONTROLÜ
            local directionToTarget = (tHrp.Position - camPos).Unit
            local angle = math.deg(math.acos(camLook:Dot(directionToTarget)))
            if angle > 45 then
                continue
            end
            
            -- WALL CHECK
            if not CanSeeTarget(tHrp.Position) then
                continue
            end
            
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    
    return closest
end

-- ============================================================
-- AIMBOT (HEDEFE ODAKLAN)
-- ============================================================
local function AimBot(target)
    if not target then return end
    
    local tChar = target.Character
    if not tChar then return end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    -- HEDEFE BAK (SMOOTH)
    local targetPos = tHrp.Position + Vector3.new(0, 1.5, 0)
    local newCF = CFrame.new(cam.CFrame.Position, targetPos)
    
    TweenService:Create(cam, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
        CFrame = newCF
    }):Play()
end

-- ============================================================
-- TRIGGERBOT (OTOMATİK SIKMA)
-- ============================================================
local function TriggerBot()
    if not BrutalActive then return end
    
    local target = FindClosestTarget()
    if not target then
        CurrentWeapon = DetectWeapon()
        return
    end
    
    -- HEDEFE ODAKLAN
    AimBot(target)
    
    -- SİLAH VAR MI?
    local weapon = DetectWeapon()
    if not weapon then return end
    
    -- OTOMATİK SIK
    pcall(function()
        UserInputService:SetKeyDown(Enum.KeyCode.Button1)
        task.wait(0.05)
        UserInputService:SetKeyUp(Enum.KeyCode.Button1)
    end)
end

-- ============================================================
-- OTOMATİK HEDEF DEĞİŞTİRME
-- ============================================================
local function AutoSwitchTarget()
    if not BrutalActive then return end
    
    local target = FindClosestTarget()
    if target then
        AimTarget = target
    end
end

-- ============================================================
-- BRUTAL MOD AÇ/KAPA
-- ============================================================
local function ToggleBrutal()
    BrutalActive = not BrutalActive
    
    if BrutalActive then
        print("💀 BRUTAL MOD V2 AKTİF!")
        print("   📏 Hitbox 40x büyütüldü")
        print("   🎯 Aimbot + Triggerbot aktif")
        print("   🛡️ Team/Wall/Kill check")
        print("   🔫 Silah otomatik tespit")
        
        SetHitboxSize()
        
        -- ANA DÖNGÜ
        task.spawn(function()
            while BrutalActive do
                -- HITBOX KONTROL
                SetHitboxSize()
                
                -- OTOMATİK HEDEF DEĞİŞTİR
                AutoSwitchTarget()
                
                -- TRIGGERBOT
                TriggerBot()
                
                -- SİLAH TESPİTİ
                CurrentWeapon = DetectWeapon()
                
                task.wait(0.05)
            end
        end)
    else
        print("💀 BRUTAL MOD V2 KAPATILDI!")
        ResetHitboxSize()
        AimTarget = nil
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
print("💀 BRUTAL MOD V2 HAZIR!")
print("   📌 Sağ üstteki 💀 butonuna tıkla")
print("   📏 Hitbox 40x büyütülür")
print("   🎯 Aimbot + Triggerbot")
print("   🛡️ Team/Wall/Kill check")
print("   🔫 Silah otomatik tespit")
print("   👁️ FOV ile hedef seçimi")
print("========================================")
