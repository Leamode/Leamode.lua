-- ============================================================
-- HAMSTER LIVES - ULTRA MOD V5 (FULL)
-- 360 DÖNÜŞ | BRUTAL HITBOX 40x | TRIGGERBOT | ESP | INF JUMP | SPEED | TP RAKİBE
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🔥 ULTRA MOD V5 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local Mods = {
    Mevlana = false,
    Brutal = false,
    InfJump = false,
    Speed = false,
    TpEnemy = false
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local HitboxSize = 40
local WalkSpeed = 50
local JumpPower = 100
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

-- ============================================================
-- KARAKTER AL
-- ============================================================
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChild("Humanoid")
    end
    return Character
end

-- ============================================================
-- 360 DÖNÜŞ
-- ============================================================
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
    print("🌀 MEVLANA: " .. (Mods.Mevlana and "AKTİF" or "KAPALI"))
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

-- ============================================================
-- TRIGGERBOT
-- ============================================================
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
        print("💀 BRUTAL AKTİF!")
        SetHitboxSize()
    else
        print("💀 BRUTAL KAPALI!")
        ResetHitboxSize()
    end
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local function ToggleInfJump()
    Mods.InfJump = not Mods.InfJump
    GetCharacter()
    if Humanoid then
        Humanoid.JumpPower = Mods.InfJump and 100 or 50
    end
    print("🦘 INF JUMP: " .. (Mods.InfJump and "AKTİF" or "KAPALI"))
end

-- ============================================================
-- SPEED HACK
-- ============================================================
local function ToggleSpeed()
    Mods.Speed = not Mods.Speed
    GetCharacter()
    if Humanoid then
        Humanoid.WalkSpeed = Mods.Speed and WalkSpeed or 16
    end
    print("💨 SPEED: " .. (Mods.Speed and "AKTİF" or "KAPALI"))
end

-- ============================================================
-- ESP (WALL CHECK + TEAM CHECK OTOMATİK)
-- ============================================================
local EspObjects = {}

local function UpdateESP()
    -- Eski ESP'leri temizle
    for _, obj in ipairs(EspObjects) do
        pcall(function() obj:Destroy() end)
    end
    EspObjects = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                -- Team check (takımdaş değilse kırmızı, takımdaşsa yeşil)
                local isEnemy = not IsSameTeam(player)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = char
                    table.insert(EspObjects, highlight)
                end
            end
        end
    end
end

-- ============================================================
-- TP RAKİBE (EN YAKIN DÜŞMAN)
-- ============================================================
local function TpToEnemy()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closest = nil
    local closestDist = math.huge
    local pos = hrp.Position
    
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
            
            local dist = (pos - tHrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = tHrp
            end
        end
    end
    
    if closest then
        hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 3, 0))
        print("🚀 En yakın düşmana ışınlandı!")
    else
        print("❌ Düşman bulunamadı!")
    end
end

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
local function MainLoop()
    task.spawn(function()
        while true do
            if Mods.Mevlana then StartSpinning() end
            if Mods.Brutal then
                SetHitboxSize()
                TriggerBot()
            end
            -- ESP'yi her 0.5 saniyede güncelle
            if not Mods.Brutal then
                UpdateESP()
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================================
-- MENU (BUTONLAR EN YUKARIDA - btnY = 5)
-- ============================================================
local function CreateMenu()
    local old = CoreGui:FindFirstChild("UltraMenu")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "UltraMenu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btnY = 5
    local btnGap = 48
    
    -- MEVLANA
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
        status1.Text = Mods.Mevlana and "AKTİF" or "KAPALI"
        status1.TextColor3 = Mods.Mevlana and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 50, 50)
        btn1.BackgroundColor3 = Mods.Mevlana and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(0, 0, 0)
        btn1.Text = Mods.Mevlana and "🌀⚡" or "🌀"
    end)
    
    -- BRUTAL
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
        status2.Text = Mods.Brutal and "AKTİF" or "KAPALI"
        status2.TextColor3 = Mods.Brutal and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 50, 50)
        btn2.BackgroundColor3 = Mods.Brutal and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 0, 0)
        btn2.Text = Mods.Brutal and "💀🔥" or "💀"
    end)
    
    -- INF JUMP
    local btn3 = Instance.new("TextButton")
    btn3.Size = UDim2.new(0, 40, 0, 40)
    btn3.Position = UDim2.new(1, -50, 0, btnY + btnGap * 2)
    btn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn3.BackgroundTransparency = 0.3
    btn3.Text = "🦘"
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
        ToggleInfJump()
        status3.Text = Mods.InfJump and "AKTİF" or "KAPALI"
        status3.TextColor3 = Mods.InfJump and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        btn3.BackgroundColor3 = Mods.InfJump and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 0, 0)
        btn3.Text = Mods.InfJump and "🦘⚡" or "🦘"
    end)
    
    -- SPEED
    local btn4 = Instance.new("TextButton")
    btn4.Size = UDim2.new(0, 40, 0, 40)
    btn4.Position = UDim2.new(1, -50, 0, btnY + btnGap * 3)
    btn4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn4.BackgroundTransparency = 0.3
    btn4.Text = "💨"
    btn4.TextColor3 = Color3.fromRGB(0, 200, 255)
    btn4.TextSize = 20
    btn4.Font = Enum.Font.GothamBold
    btn4.Parent = gui
    btn4.ZIndex = 999
    Instance.new("UICorner", btn4).CornerRadius = UDim.new(1, 0)
    
    local status4 = Instance.new("TextLabel")
    status4.Size = UDim2.new(0, 50, 0, 14)
    status4.Position = UDim2.new(1, -55, 0, btnY + btnGap * 3 - 18)
    status4.BackgroundTransparency = 1
    status4.Text = "KAPALI"
    status4.TextColor3 = Color3.fromRGB(255, 50, 50)
    status4.TextSize = 7
    status4.Font = Enum.Font.GothamBold
    status4.TextXAlignment = Enum.TextXAlignment.Right
    status4.Parent = gui
    status4.ZIndex = 999
    
    btn4.MouseButton1Click:Connect(function()
        ToggleSpeed()
        status4.Text = Mods.Speed and "AKTİF" or "KAPALI"
        status4.TextColor3 = Mods.Speed and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 50, 50)
        btn4.BackgroundColor3 = Mods.Speed and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(0, 0, 0)
        btn4.Text = Mods.Speed and "💨⚡" or "💨"
    end)
    
    -- TP RAKİBE
    local btn5 = Instance.new("TextButton")
    btn5.Size = UDim2.new(0, 40, 0, 40)
    btn5.Position = UDim2.new(1, -50, 0, btnY + btnGap * 4)
    btn5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn5.BackgroundTransparency = 0.3
    btn5.Text = "🚀"
    btn5.TextColor3 = Color3.fromRGB(255, 200, 0)
    btn5.TextSize = 20
    btn5.Font = Enum.Font.GothamBold
    btn5.Parent = gui
    btn5.ZIndex = 999
    Instance.new("UICorner", btn5).CornerRadius = UDim.new(1, 0)
    
    btn5.MouseButton1Click:Connect(function()
        TpToEnemy()
    end)
end

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GetCharacter()
    if Mods.Brutal then SetHitboxSize() end
    if Mods.InfJump and Humanoid then Humanoid.JumpPower = 100 end
    if Mods.Speed and Humanoid then Humanoid.WalkSpeed = WalkSpeed end
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
print("🔥 ULTRA MOD V5 HAZIR!")
print("   🌀 Mevlana: 360 dönüş")
print("   💀 Brutal: Hitbox 40x + TRIGGERBOT")
print("   🦘 Inf Jump: Sonsuz zıplama")
print("   💨 Speed: Hızlı yürüme")
print("   🚀 TP Rakibe: En yakın düşmana ışınlan")
print("   📌 Sağ üstteki butonlar")
print("========================================")
