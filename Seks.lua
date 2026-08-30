-- ============================================================
-- HAMSTER LIVES - ULTRA MOD V1
-- 360 DÖNÜŞ | BRUTAL HITBOX 40x | TRIGGERBOT | BYPASS
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("🔥 ULTRA MOD V1 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local Mods = {
    Mevlana = false,     -- 360 dönüş
    Brutal = false,      -- Hitbox + Triggerbot
    Bypass = false       -- Anti-cheat bypass
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local HitboxSize = 40
local Character = nil
local HumanoidRootPart = nil

-- ============================================================
-- BYPASS (ANTİ-CHEAT KİLLER)
-- ============================================================
local function RunBypass()
    if not Mods.Bypass then return end
    
    local patterns = {
        "AntiCheat", "AC", "Security", "Protect", "Ban",
        "Kick", "Detect", "Monitor", "Guard", "Watch",
        "Hyperion", "Byfron", "Luau", "Bytecode"
    }
    
    local killed = 0
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name then
            for _, p in ipairs(patterns) do
                if obj.Name:find(p) then
                    pcall(function()
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            obj.Disabled = true
                            killed = killed + 1
                        end
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") then
                                obj:Destroy()
                                killed = killed + 1
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
    print("[BYPASS] " .. killed .. " anticheat nesnesi imha edildi.")
end

-- ============================================================
-- 360 DÖNÜŞ (MEVLANA MOD)
-- ============================================================
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    return Character
end

local function StartSpinning()
    if not Mods.Mevlana then return end
    if not HumanoidRootPart then return end
    
    CurrentAngle = CurrentAngle + MevlanaSpeed
    if CurrentAngle > 360 then CurrentAngle = CurrentAngle - 360 end
    
    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(CurrentAngle), 0)
end

local function ToggleMevlana()
    Mods.Mevlana = not Mods.Mevlana
    GetCharacter()
    if Mods.Mevlana then
        print("🌀 MEVLANA MOD AKTİF!")
    else
        print("🌀 MEVLANA MOD KAPALI!")
    end
end

-- ============================================================
-- BRUTAL HITBOX + TRIGGERBOT
-- ============================================================
local function SetHitboxSize()
    if not Mods.Brutal then return end
    
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

local function IsSameTeam(player)
    local localTeam = LocalPlayer.Team
    local targetTeam = player.Team
    if localTeam and targetTeam then
        return localTeam == targetTeam
    end
    return false
end

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

local function TriggerBot()
    if not Mods.Brutal then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if IsSameTeam(player) then continue end
            
            local tChar = player.Character
            if not tChar then continue end
            
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            if not tHrp then continue end
            
            local tHum = tChar:FindFirstChild("Humanoid")
            if not tHum then continue end
            if tHum.Health <= 0 then continue end
            
            local dist = (hrp.Position - tHrp.Position).Magnitude
            if not CanSeeTarget(tHrp.Position) then continue end
            
            if dist < HitboxSize then
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

local function ToggleBrutal()
    Mods.Brutal = not Mods.Brutal
    if Mods.Brutal then
        print("💀 BRUTAL MOD AKTİF!")
        SetHitboxSize()
    else
        print("💀 BRUTAL MOD KAPALI!")
        ResetHitboxSize()
    end
end

-- ============================================================
-- BYPASS AÇ/KAPA
-- ============================================================
local function ToggleBypass()
    Mods.Bypass = not Mods.Bypass
    if Mods.Bypass then
        print("🔓 BYPASS AKTİF!")
        RunBypass()
    else
        print("🔓 BYPASS KAPALI!")
    end
end

-- ============================================================
-- ANA DÖNGÜ (HER ŞEY)
-- ============================================================
local function MainLoop()
    task.spawn(function()
        while true do
            -- 360 DÖNÜŞ
            if Mods.Mevlana then
                StartSpinning()
            end
            
            -- BRUTAL HITBOX
            if Mods.Brutal then
                SetHitboxSize()
                TriggerBot()
            end
            
            task.wait(0.016) -- ~60 FPS
        end
    end)
end

-- ============================================================
-- MENU (SAĞ ÜST - 3 BUTON)
-- ============================================================
local function CreateMenu()
    local old = CoreGui:FindFirstChild("UltraMenu")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "UltraMenu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btnY = 55
    local btnGap = 48
    
    -- MEVLANA BUTONU (EN ÜST)
    local btn1 = Instance.new("TextButton")
    btn1.Size = UDim2.new(0, 40, 0, 40)
    btn1.Position = UDim2.new(1, -50, 0, btnY)
    btn1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn1.BackgroundTransparency = 0.3
    btn1.Text = "🌀"
    btn1.TextColor3 = Color3.fromRGB(100, 200, 255)
    btn1.TextSize = 20
    btn1.Font = Enum.Font.GothamBold
    btn1.Parent = gui
    btn1.ZIndex = 999
    Instance.new("UICorner", btn1).CornerRadius = UDim.new(1, 0)
    
    local status1 = Instance.new("TextLabel")
    status1.Size = UDim2.new(0, 50, 0, 14)
    status1.Position = UDim2.new(1, -55, 0, btnY - 18)
    status1.BackgroundTransparency = 1
    status1.Text = "KAPALI"
    status1.TextColor3 = Color3.fromRGB(255, 50, 50)
    status1.TextSize = 7
    status1.Font = Enum.Font.GothamBold
    status1.TextXAlignment = Enum.TextXAlignment.Right
    status1.Parent = gui
    status1.ZIndex = 999
    
    btn1.MouseButton1Click:Connect(function()
        ToggleMevlana()
        if Mods.Mevlana then
            btn1.Text = "🌀⚡"
            btn1.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
            status1.Text = "AKTİF"
            status1.TextColor3 = Color3.fromRGB(0, 255, 200)
        else
            btn1.Text = "🌀"
            btn1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            status1.Text = "KAPALI"
            status1.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    -- BRUTAL BUTONU (ORTA)
    local btn2 = Instance.new("TextButton")
    btn2.Size = UDim2.new(0, 40, 0, 40)
    btn2.Position = UDim2.new(1, -50, 0, btnY + btnGap)
    btn2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn2.BackgroundTransparency = 0.3
    btn2.Text = "💀"
    btn2.TextColor3 = Color3.fromRGB(255, 50, 50)
    btn2.TextSize = 20
    btn2.Font = Enum.Font.GothamBold
    btn2.Parent = gui
    btn2.ZIndex = 999
    Instance.new("UICorner", btn2).CornerRadius = UDim.new(1, 0)
    
    local status2 = Instance.new("TextLabel")
    status2.Size = UDim2.new(0, 50, 0, 14)
    status2.Position = UDim2.new(1, -55, 0, btnY + btnGap - 18)
    status2.BackgroundTransparency = 1
    status2.Text = "KAPALI"
    status2.TextColor3 = Color3.fromRGB(255, 50, 50)
    status2.TextSize = 7
    status2.Font = Enum.Font.GothamBold
    status2.TextXAlignment = Enum.TextXAlignment.Right
    status2.Parent = gui
    status2.ZIndex = 999
    
    btn2.MouseButton1Click:Connect(function()
        ToggleBrutal()
        if Mods.Brutal then
            btn2.Text = "💀🔥"
            btn2.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            status2.Text = "AKTİF"
            status2.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            btn2.Text = "💀"
            btn2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            status2.Text = "KAPALI"
            status2.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    -- BYPASS BUTONU (EN ALT)
    local btn3 = Instance.new("TextButton")
    btn3.Size = UDim2.new(0, 40, 0, 40)
    btn3.Position = UDim2.new(1, -50, 0, btnY + btnGap * 2)
    btn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn3.BackgroundTransparency = 0.3
    btn3.Text = "🔓"
    btn3.TextColor3 = Color3.fromRGB(0, 255, 100)
    btn3.TextSize = 20
    btn3.Font = Enum.Font.GothamBold
    btn3.Parent = gui
    btn3.ZIndex = 999
    Instance.new("UICorner", btn3).CornerRadius = UDim.new(1, 0)
    
    local status3 = Instance.new("TextLabel")
    status3.Size = UDim2.new(0, 50, 0, 14)
    status3.Position = UDim2.new(1, -55, 0, btnY + btnGap * 2 - 18)
    status3.BackgroundTransparency = 1
    status3.Text = "KAPALI"
    status3.TextColor3 = Color3.fromRGB(255, 50, 50)
    status3.TextSize = 7
    status3.Font = Enum.Font.GothamBold
    status3.TextXAlignment = Enum.TextXAlignment.Right
    status3.Parent = gui
    status3.ZIndex = 999
    
    btn3.MouseButton1Click:Connect(function()
        ToggleBypass()
        if Mods.Bypass then
            btn3.Text = "🔓✅"
            btn3.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            status3.Text = "AKTİF"
            status3.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            btn3.Text = "🔓"
            btn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            status3.Text = "KAPALI"
            status3.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
end

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GetCharacter()
    if Mods.Brutal then SetHitboxSize() end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateMenu()
MainLoop()

print("")
print("========================================")
print("🔥 ULTRA MOD V1 HAZIR!")
print("   🌀 Mevlana: 360 dönüş")
print("   💀 Brutal: Hitbox 40x + Triggerbot")
print("   🔓 Bypass: Anti-cheat killer")
print("   📌 Sağ üstteki butonlar")
print("========================================")
