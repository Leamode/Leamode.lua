-- ============================================================
-- HAMSTER LIVES - ULTRA MOD V8 (ESP EKLENDİ)
-- 360 DÖNÜŞ | HITBOX 40x | TRIGGERBOT | INF JUMP | SPEED | ESP
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🔥 ULTRA MOD V8 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local Mods = {
    Mevlana = false,
    Brutal = false,
    InfJump = false,
    Speed = false,
    Esp = false
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local HitboxSize = 40
local WalkSpeed = 50
local JumpPower = 100
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local EspObjects = {}

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
-- 360 DÖNÜŞ (BOZULMADI - AYNI)
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
-- BRUTAL (HITBOX + TRIGGERBOT)
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

local function FindClosestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
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
            
            if not CanSeeTarget(tHrp.Position) then continue end
            
            local dist = (pos - tHrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    
    return closest, closestDist
end

local function TriggerBot()
    if not Mods.Brutal then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local enemy, dist = FindClosestEnemy()
    if not enemy then return end
    
    local tChar = enemy.Character
    if not tChar then return end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end
    
    if dist < HitboxSize then
        pcall(function()
            UserInputService:SetKeyDown(Enum.KeyCode.Button1)
            task.wait(0.05)
            UserInputService:SetKeyUp(Enum.KeyCode.Button1)
        end)
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
-- INFINITE JUMP (HIGH JUMP + SÜREKLİ)
-- ============================================================
local JumpThread = nil

local function ToggleInfJump()
    Mods.InfJump = not Mods.InfJump
    GetCharacter()
    
    if JumpThread then
        coroutine.close(JumpThread)
        JumpThread = nil
    end
    
    if Mods.InfJump then
        if Humanoid then
            Humanoid.JumpPower = 100
        end
        JumpThread = coroutine.create(function()
            while Mods.InfJump and Humanoid and Humanoid.Parent do
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.01)
            end
        end)
        coroutine.resume(JumpThread)
        print("🦘 INF JUMP: AKTİF (Sürekli zıplama + High Jump)")
    else
        if Humanoid then
            Humanoid.JumpPower = 50
        end
        print("🦘 INF JUMP: KAPALI")
    end
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
    print("💨 SPEED: " .. (Mods.Speed and "AKTİF (" .. WalkSpeed .. " hız)" or "KAPALI"))
end

-- ============================================================
-- ESP (SÜREKLİ GÜNCELLENİR)
-- ============================================================
local function UpdateESP()
    for _, obj in ipairs(EspObjects) do
        pcall(function() obj:Destroy() end)
    end
    EspObjects = {}
    
    if not Mods.Esp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local isEnemy = not IsSameTeam(player)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = char
                    table.insert(EspObjects, highlight)
                end
            end
        end
    end
end

local function ToggleEsp()
    Mods.Esp = not Mods.Esp
    if not Mods.Esp then
        for _, obj in ipairs(EspObjects) do
            pcall(function() obj:Destroy() end)
        end
        EspObjects = {}
    end
    print("👁️ ESP: " .. (Mods.Esp and "AKTİF" or "KAPALI"))
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
            if Mods.Esp then
                UpdateESP()
            end
            task.wait(0.1)
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
    if Mods.InfJump then
        if Humanoid then Humanoid.JumpPower = 100 end
        if JumpThread then coroutine.close(JumpThread) end
        JumpThread = coroutine.create(function()
            while Mods.InfJump and Humanoid and Humanoid.Parent do
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.01)
            end
        end)
        coroutine.resume(JumpThread)
    end
    if Mods.Speed and Humanoid then Humanoid.WalkSpeed = WalkSpeed end
end)

-- ============================================================
-- MENU
-- ============================================================
local function CreateMenu()
    local old = CoreGui:FindFirstChild("UltraMenu")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "UltraMenu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btnY = 5
    local btnGap = 42
    
    -- MEVLANA
    local btn1 = Instance.new("TextButton")
    btn1.Size = UDim2.new(0, 36, 0, 36)
    btn1.Position = UDim2.new(1, -44, 0, btnY)
    btn1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn1.BackgroundTransparency = 0.3
    btn1.Text = "🌀"
    btn1.TextColor3 = Color3.fromRGB(100, 200, 255)
    btn1.TextSize = 18
    btn1.Font = Enum.Font.GothamBold
    btn1.Parent = gui
    btn1.ZIndex = 999
    Instance.new("UICorner", btn1).CornerRadius = UDim.new(1, 0)
    
    local st1 = Instance.new("TextLabel")
    st1.Size = UDim2.new(0, 40, 0, 12)
    st1.Position = UDim2.new(1, -48, 0, btnY - 14)
    st1.BackgroundTransparency = 1
    st1.Text = "KAPALI"
    st1.TextColor3 = Color3.fromRGB(255, 50, 50)
    st1.TextSize = 6
    st1.Font = Enum.Font.GothamBold
    st1.TextXAlignment = Enum.TextXAlignment.Right
    st1.Parent = gui
    st1.ZIndex = 999
    
    btn1.MouseButton1Click:Connect(function()
        ToggleMevlana()
        st1.Text = Mods.Mevlana and "AKTİF" or "KAPALI"
        st1.TextColor3 = Mods.Mevlana and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 50, 50)
        btn1.BackgroundColor3 = Mods.Mevlana and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(0, 0, 0)
        btn1.Text = Mods.Mevlana and "🌀⚡" or "🌀"
    end)
    
    -- BRUTAL
    local btn2 = Instance.new("TextButton")
    btn2.Size = UDim2.new(0, 36, 0, 36)
    btn2.Position = UDim2.new(1, -44, 0, btnY + btnGap)
    btn2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn2.BackgroundTransparency = 0.3
    btn2.Text = "💀"
    btn2.TextColor3 = Color3.fromRGB(255, 50, 50)
    btn2.TextSize = 18
    btn2.Font = Enum.Font.GothamBold
    btn2.Parent = gui
    btn2.ZIndex = 999
    Instance.new("UICorner", btn2).CornerRadius = UDim.new(1, 0)
    
    local st2 = Instance.new("TextLabel")
    st2.Size = UDim2.new(0, 40, 0, 12)
    st2.Position = UDim2.new(1, -48, 0, btnY + btnGap - 14)
    st2.BackgroundTransparency = 1
    st2.Text = "KAPALI"
    st2.TextColor3 = Color3.fromRGB(255, 50, 50)
    st2.TextSize = 6
    st2.Font = Enum.Font.GothamBold
    st2.TextXAlignment = Enum.TextXAlignment.Right
    st2.Parent = gui
    st2.ZIndex = 999
    
    btn2.MouseButton1Click:Connect(function()
        ToggleBrutal()
        st2.Text = Mods.Brutal and "AKTİF" or "KAPALI"
        st2.TextColor3 = Mods.Brutal and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 50, 50)
        btn2.BackgroundColor3 = Mods.Brutal and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 0, 0)
        btn2.Text = Mods.Brutal and "💀🔥" or "💀"
    end)
    
    -- INF JUMP
    local btn3 = Instance.new("TextButton")
    btn3.Size = UDim2.new(0, 36, 0, 36)
    btn3.Position = UDim2.new(1, -44, 0, btnY + btnGap * 2)
    btn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn3.BackgroundTransparency = 0.3
    btn3.Text = "🦘"
    btn3.TextColor3 = Color3.fromRGB(0, 255, 100)
    btn3.TextSize = 18
    btn3.Font = Enum.Font.GothamBold
    btn3.Parent = gui
    btn3.ZIndex = 999
    Instance.new("UICorner", btn3).CornerRadius = UDim.new(1, 0)
    
    local st3 = Instance.new("TextLabel")
    st3.Size = UDim2.new(0, 40, 0, 12)
    st3.Position = UDim2.new(1, -48, 0, btnY + btnGap * 2 - 14)
    st3.BackgroundTransparency = 1
    st3.Text = "KAPALI"
    st3.TextColor3 = Color3.fromRGB(255, 50, 50)
    st3.TextSize = 6
    st3.Font = Enum.Font.GothamBold
    st3.TextXAlignment = Enum.TextXAlignment.Right
    st3.Parent = gui
    st3.ZIndex = 999
    
    btn3.MouseButton1Click:Connect(function()
        ToggleInfJump()
        st3.Text = Mods.InfJump and "AKTİF" or "KAPALI"
        st3.TextColor3 = Mods.InfJump and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        btn3.BackgroundColor3 = Mods.InfJump and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 0, 0)
        btn3.Text = Mods.InfJump and "🦘⚡" or "🦘"
    end)
    
    -- SPEED
    local btn4 = Instance.new("TextButton")
    btn4.Size = UDim2.new(0, 36, 0, 36)
    btn4.Position = UDim2.new(1, -44, 0, btnY + btnGap * 3)
    btn4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn4.BackgroundTransparency = 0.3
    btn4.Text = "💨"
    btn4.TextColor3 = Color3.fromRGB(0, 200, 255)
    btn4.TextSize = 18
    btn4.Font = Enum.Font.GothamBold
    btn4.Parent = gui
    btn4.ZIndex = 999
    Instance.new("UICorner", btn4).CornerRadius = UDim.new(1, 0)
    
    local st4 = Instance.new("TextLabel")
    st4.Size = UDim2.new(0, 40, 0, 12)
    st4.Position = UDim2.new(1, -48, 0, btnY + btnGap * 3 - 14)
    st4.BackgroundTransparency = 1
    st4.Text = "KAPALI"
    st4.TextColor3 = Color3.fromRGB(255, 50, 50)
    st4.TextSize = 6
    st4.Font = Enum.Font.GothamBold
    st4.TextXAlignment = Enum.TextXAlignment.Right
    st4.Parent = gui
    st4.ZIndex = 999
    
    btn4.MouseButton1Click:Connect(function()
        ToggleSpeed()
        st4.Text = Mods.Speed and "AKTİF" or "KAPALI"
        st4.TextColor3 = Mods.Speed and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 50, 50)
        btn4.BackgroundColor3 = Mods.Speed and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(0, 0, 0)
        btn4.Text = Mods.Speed and "💨⚡" or "💨"
    end)
    
    -- ESP
    local btn5 = Instance.new("TextButton")
    btn5.Size = UDim2.new(0, 36, 0, 36)
    btn5.Position = UDim2.new(1, -44, 0, btnY + btnGap * 4)
    btn5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn5.BackgroundTransparency = 0.3
    btn5.Text = "👁️"
    btn5.TextColor3 = Color3.fromRGB(255, 100, 255)
    btn5.TextSize = 18
    btn5.Font = Enum.Font.GothamBold
    btn5.Parent = gui
    btn5.ZIndex = 999
    Instance.new("UICorner", btn5).CornerRadius = UDim.new(1, 0)
    
    local st5 = Instance.new("TextLabel")
    st5.Size = UDim2.new(0, 40, 0, 12)
    st5.Position = UDim2.new(1, -48, 0, btnY + btnGap * 4 - 14)
    st5.BackgroundTransparency = 1
    st5.Text = "KAPALI"
    st5.TextColor3 = Color3.fromRGB(255, 50, 50)
    st5.TextSize = 6
    st5.Font = Enum.Font.GothamBold
    st5.TextXAlignment = Enum.TextXAlignment.Right
    st5.Parent = gui
    st5.ZIndex = 999
    
    btn5.MouseButton1Click:Connect(function()
        ToggleEsp()
        st5.Text = Mods.Esp and "AKTİF" or "KAPALI"
        st5.TextColor3 = Mods.Esp and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(255, 50, 50)
        btn5.BackgroundColor3 = Mods.Esp and Color3.fromRGB(150, 0, 150) or Color3.fromRGB(0, 0, 0)
        btn5.Text = Mods.Esp and "👁️⚡" or "👁️"
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateMenu()
MainLoop()

print("")
print("========================================")
print("🔥 ULTRA MOD V8 HAZIR!")
print("   🌀 Mevlana: 360 dönüş")
print("   💀 Brutal: Hitbox 40x + TRIGGERBOT")
print("   🦘 Inf Jump: Sürekli zıplama + High Jump")
print("   💨 Speed: Hızlı yürüme")
print("   👁️ ESP: Düşmanları gör (sürekli güncellenir)")
print("   📌 Sağ üstteki butonlar (EN YUKARIDA)")
print("========================================")
