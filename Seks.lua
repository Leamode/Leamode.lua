-- ============================================================
-- HAMSTER LIVES - ULTRA MOD V2 (MENÜLÜ)
-- 360 DÖNÜŞ | BRUTAL HITBOX 40x | TRIGGERBOT (OTOMATİK TIK)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("🔥 ULTRA MOD V2 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local Mods = {
    Mevlana = false,
    Brutal = false,
    Trigger = false,
    Bypass = false
}

local MevlanaSpeed = 30
local HitboxSize = 40
local CurrentAngle = 0
local MenuVisible = false
local Character = nil
local HumanoidRootPart = nil

-- ============================================================
-- BYPASS
-- ============================================================
local function RunBypass()
    if not Mods.Bypass then return end
    local patterns = {"AntiCheat","AC","Security","Protect","Ban","Kick","Detect","Monitor","Guard","Watch","Hyperion","Byfron"}
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
    print("[BYPASS] " .. killed .. " anticheat imha edildi.")
end

-- ============================================================
-- 360 DÖNÜŞ
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

-- ============================================================
-- HITBOX
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
-- TRIGGERBOT (EKRA GÖRÜNCE OTOMATİK TIK)
-- ============================================================
local function TriggerBot()
    if not Mods.Trigger then return end
    
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

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
local function MainLoop()
    task.spawn(function()
        while true do
            if Mods.Mevlana then StartSpinning() end
            if Mods.Brutal then SetHitboxSize() end
            if Mods.Trigger then TriggerBot() end
            task.wait(0.016)
        end
    end)
end

-- ============================================================
-- MENU (EKRA ORTASI - AÇ/KAPA BUTONU İLE)
-- ============================================================
local function CreateMenu()
    local old = CoreGui:FindFirstChild("UltraMenuV2")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "UltraMenuV2"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.Enabled = false
    
    -- ANA PANEL (ORTA)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 220, 0, 280)
    panel.Position = UDim2.new(0.5, -110, 0.3, 0)
    panel.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    panel.BackgroundTransparency = 0.1
    panel.Parent = gui
    panel.ZIndex = 999
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", panel)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.5
    
    -- BAŞLIK
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "🔥 ULTRA MOD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.Parent = panel
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    local yPos = 38
    
    -- MEVLANA MOD (360 DÖNÜŞ)
    local mevBtn = Instance.new("TextButton")
    mevBtn.Size = UDim2.new(0.9, 0, 0, 30)
    mevBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    mevBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    mevBtn.Text = "🌀 MEVLANA: KAPALI"
    mevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mevBtn.TextSize = 10
    mevBtn.Font = Enum.Font.GothamBold
    mevBtn.Parent = panel
    Instance.new("UICorner", mevBtn).CornerRadius = UDim.new(0, 4)
    
    mevBtn.MouseButton1Click:Connect(function()
        Mods.Mevlana = not Mods.Mevlana
        mevBtn.Text = Mods.Mevlana and "🌀 MEVLANA: AKTİF" or "🌀 MEVLANA: KAPALI"
        mevBtn.BackgroundColor3 = Mods.Mevlana and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(20, 20, 40)
    end)
    
    yPos = yPos + 38
    
    -- MEVLANA HIZ AYARI
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.4, 0, 0, 18)
    speedLabel.Position = UDim2.new(0.05, 0, 0, yPos)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Hız: " .. MevlanaSpeed
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 9
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = panel
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(0.4, 0, 0, 14)
    speedSlider.Position = UDim2.new(0.5, 0, 0, yPos + 2)
    speedSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    speedSlider.Parent = panel
    Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(1, 0)
    
    local speedFill = Instance.new("Frame")
    speedFill.Size = UDim2.new(MevlanaSpeed / 200, 0, 1, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    speedFill.Parent = speedSlider
    Instance.new("UICorner", speedFill).CornerRadius = UDim.new(1, 0)
    
    speedSlider.MouseButton1Click:Connect(function(input)
        local x = input.Position.X - speedSlider.AbsolutePosition.X
        local w = speedSlider.AbsoluteSize.X
        local val = math.clamp(math.floor((x / w) * 200), 1, 200)
        MevlanaSpeed = val
        speedFill.Size = UDim2.new(val / 200, 0, 1, 0)
        speedLabel.Text = "Hız: " .. val
    end)
    
    yPos = yPos + 28
    
    -- BRUTAL MOD (HITBOX)
    local brutBtn = Instance.new("TextButton")
    brutBtn.Size = UDim2.new(0.9, 0, 0, 30)
    brutBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    brutBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    brutBtn.Text = "💀 BRUTAL: KAPALI"
    brutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    brutBtn.TextSize = 10
    brutBtn.Font = Enum.Font.GothamBold
    brutBtn.Parent = panel
    Instance.new("UICorner", brutBtn).CornerRadius = UDim.new(0, 4)
    
    brutBtn.MouseButton1Click:Connect(function()
        Mods.Brutal = not Mods.Brutal
        brutBtn.Text = Mods.Brutal and "💀 BRUTAL: AKTİF" or "💀 BRUTAL: KAPALI"
        brutBtn.BackgroundColor3 = Mods.Brutal and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(20, 20, 40)
        if not Mods.Brutal then ResetHitboxSize() end
    end)
    
    yPos = yPos + 38
    
    -- HITBOX BOYUT AYARI
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.4, 0, 0, 18)
    sizeLabel.Position = UDim2.new(0.05, 0, 0, yPos)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "Hitbox: " .. HitboxSize
    sizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sizeLabel.TextSize = 9
    sizeLabel.Font = Enum.Font.Gotham
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = panel
    
    local sizeSlider = Instance.new("Frame")
    sizeSlider.Size = UDim2.new(0.4, 0, 0, 14)
    sizeSlider.Position = UDim2.new(0.5, 0, 0, yPos + 2)
    sizeSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    sizeSlider.Parent = panel
    Instance.new("UICorner", sizeSlider).CornerRadius = UDim.new(1, 0)
    
    local sizeFill = Instance.new("Frame")
    sizeFill.Size = UDim2.new(HitboxSize / 1000, 0, 1, 0)
    sizeFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    sizeFill.Parent = sizeSlider
    Instance.new("UICorner", sizeFill).CornerRadius = UDim.new(1, 0)
    
    sizeSlider.MouseButton1Click:Connect(function(input)
        local x = input.Position.X - sizeSlider.AbsolutePosition.X
        local w = sizeSlider.AbsoluteSize.X
        local val = math.clamp(math.floor((x / w) * 1000), 5, 1000)
        HitboxSize = val
        sizeFill.Size = UDim2.new(val / 1000, 0, 1, 0)
        sizeLabel.Text = "Hitbox: " .. val
    end)
    
    yPos = yPos + 28
    
    -- TRIGGERBOT
    local trigBtn = Instance.new("TextButton")
    trigBtn.Size = UDim2.new(0.9, 0, 0, 30)
    trigBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    trigBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    trigBtn.Text = "🎯 TRIGGER: KAPALI"
    trigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    trigBtn.TextSize = 10
    trigBtn.Font = Enum.Font.GothamBold
    trigBtn.Parent = panel
    Instance.new("UICorner", trigBtn).CornerRadius = UDim.new(0, 4)
    
    trigBtn.MouseButton1Click:Connect(function()
        Mods.Trigger = not Mods.Trigger
        trigBtn.Text = Mods.Trigger and "🎯 TRIGGER: AKTİF" or "🎯 TRIGGER: KAPALI"
        trigBtn.BackgroundColor3 = Mods.Trigger and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(20, 20, 40)
    end)
    
    yPos = yPos + 38
    
    -- BYPASS
    local bypassBtn = Instance.new("TextButton")
    bypassBtn.Size = UDim2.new(0.9, 0, 0, 30)
    bypassBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    bypassBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    bypassBtn.Text = "🔓 BYPASS: KAPALI"
    bypassBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bypassBtn.TextSize = 10
    bypassBtn.Font = Enum.Font.GothamBold
    bypassBtn.Parent = panel
    Instance.new("UICorner", bypassBtn).CornerRadius = UDim.new(0, 4)
    
    bypassBtn.MouseButton1Click:Connect(function()
        Mods.Bypass = not Mods.Bypass
        bypassBtn.Text = Mods.Bypass and "🔓 BYPASS: AKTİF" or "🔓 BYPASS: KAPALI"
        bypassBtn.BackgroundColor3 = Mods.Bypass and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(20, 20, 40)
        if Mods.Bypass then RunBypass() end
    end)
    
    -- KAPATMA BUTONU
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = panel
    closeBtn.ZIndex = 1000
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
        MenuVisible = false
    end)
    
    return gui
end

-- ============================================================
-- AÇMA/KAPAMA BUTONU (SAĞ ÜST)
-- ============================================================
local function CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(1, -50, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.Text = "⚡"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CoreGui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local menu = CreateMenu()
    
    btn.MouseButton1Click:Connect(function()
        if menu then
            MenuVisible = not MenuVisible
            menu.Enabled = MenuVisible
        end
    end)
    
    return btn
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
CreateToggleButton()
MainLoop()

print("")
print("========================================")
print("🔥 ULTRA MOD V2 HAZIR!")
print("   📌 Sağ üstteki ⚡ butonuna tıkla")
print("   📊 Menü ekranın ortasında açılır")
print("   🌀 Mevlana: 360 dönüş (hız ayarlı)")
print("   💀 Brutal: Hitbox (1000'e kadar)")
print("   🎯 Trigger: Otomatik tık")
print("   🔓 Bypass: Anti-cheat killer")
print("========================================")
