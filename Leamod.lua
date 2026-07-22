--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ WEAPON SYSTEM v14.0 - AYRI AYRI BUTONLAR (2 PARÇA)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ HER ÖZELLİK AYRI BUTON (AÇ/KAPA)
    ✅ Magic Bullet (ayrı buton)
    ✅ ESP (ayrı buton)
    ✅ 360 (ayrı buton)
    ✅ Giant (ayrı buton)
    ✅ Uçma (ayrı buton)
    ✅ Speed (+/- butonları)
    ✅ Rainbow (ayrı buton)
    ✅ Teleport (ayrı buton)
    ✅ Menü sağ köşe
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  1/2  -  A Y A R L A R  +  M E N Ü
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    SpeedValue = 50,
    GiantSize = 2,
    FlySpeed = 60,
    OffsetBack = 5,
    OffsetUp = 4,
    TeamCheck = true,
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:FindFirstChild("Head")

-- Durumlar
local states = {
    magicBullet = false,
    esp = false,
    rotation = false,
    giant = false,
    fly = false,
    rainbow = false,
    teleport = false,
}

local connections = {
    magic = nil,
    esp = {},
    rotation = nil,
    rainbow = nil,
    fly = nil,
}

local bodyVelocity = nil
local bodyGyro = nil
local currentTarget = nil
local killCount = 0

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü  (Sağ köşe - GENİŞLETİLMİŞ)
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponSystemGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 120, 0, 250)
mainFrame.Position = UDim2.new(1, -130, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡ WEAPON SYSTEM"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.Parent = mainFrame

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -10, 0, 1)
line.Position = UDim2.new(0, 5, 0, 22)
line.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
line.BackgroundTransparency = 0.5
line.Parent = mainFrame

-- BUTON OLUŞTURMA FONKSİYONU
local function createButton(parent, text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 18)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Butonlar
local btnMagic = createButton(mainFrame, "🔫 Magic Bullet: KAPALI", 28, Color3.fromRGB(40, 40, 60), function()
    states.magicBullet = not states.magicBullet
    btnMagic.Text = states.magicBullet and "🔫 Magic Bullet: ACIK" or "🔫 Magic Bullet: KAPALI"
    btnMagic.BackgroundColor3 = states.magicBullet and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.magicBullet then startMagicBullet() else stopMagicBullet() end
end)

local btnESP = createButton(mainFrame, "👁️ ESP: KAPALI", 50, Color3.fromRGB(40, 40, 60), function()
    states.esp = not states.esp
    btnESP.Text = states.esp and "👁️ ESP: ACIK" or "👁️ ESP: KAPALI"
    btnESP.BackgroundColor3 = states.esp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.esp then startESP() else stopESP() end
end)

local btn360 = createButton(mainFrame, "🔄 360: KAPALI", 72, Color3.fromRGB(40, 40, 60), function()
    states.rotation = not states.rotation
    btn360.Text = states.rotation and "🔄 360: ACIK" or "🔄 360: KAPALI"
    btn360.BackgroundColor3 = states.rotation and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rotation then start360() else stop360() end
end)

local btnGiant = createButton(mainFrame, "🦍 Giant: KAPALI", 94, Color3.fromRGB(40, 40, 60), function()
    states.giant = not states.giant
    btnGiant.Text = states.giant and "🦍 Giant: ACIK" or "🦍 Giant: KAPALI"
    btnGiant.BackgroundColor3 = states.giant and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.giant then startGiant() else stopGiant() end
end)

local btnFly = createButton(mainFrame, "✈️ Uçma: KAPALI", 116, Color3.fromRGB(40, 40, 60), function()
    states.fly = not states.fly
    btnFly.Text = states.fly and "✈️ Uçma: ACIK" or "✈️ Uçma: KAPALI"
    btnFly.BackgroundColor3 = states.fly and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.fly then startFly() else stopFly() end
end)

local btnRainbow = createButton(mainFrame, "🌈 Rainbow: KAPALI", 138, Color3.fromRGB(40, 40, 60), function()
    states.rainbow = not states.rainbow
    btnRainbow.Text = states.rainbow and "🌈 Rainbow: ACIK" or "🌈 Rainbow: KAPALI"
    btnRainbow.BackgroundColor3 = states.rainbow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rainbow then startRainbow() else stopRainbow() end
end)

local btnTeleport = createButton(mainFrame, "🚀 Teleport: KAPALI", 160, Color3.fromRGB(40, 40, 60), function()
    states.teleport = not states.teleport
    btnTeleport.Text = states.teleport and "🚀 Teleport: ACIK" or "🚀 Teleport: KAPALI"
    btnTeleport.BackgroundColor3 = states.teleport and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.teleport then startTeleport() else stopTeleport() end
end)

-- Speed Ayarları
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 30, 0, 16)
speedLabel.Position = UDim2.new(0, 10, 0, 184)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(0, 40, 0, 16)
speedText.Position = UDim2.new(0, 45, 0, 184)
speedText.Text = "HIZ"
speedText.BackgroundTransparency = 1
speedText.TextColor3 = Color3.fromRGB(200, 200, 200)
speedText.Font = Enum.Font.Gotham
speedText.TextSize = 9
speedText.TextXAlignment = Enum.TextXAlignment.Left
speedText.Parent = mainFrame

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0, 20, 0, 16)
speedUpBtn.Position = UDim2.new(0, 85, 0, 184)
speedUpBtn.Text = "+"
speedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 12
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = mainFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0, 20, 0, 16)
speedDownBtn.Position = UDim2.new(0, 108, 0, 184)
speedDownBtn.Text = "-"
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 12
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = mainFrame

-- Kapat Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 100, 0, 20)
closeButton.Position = UDim2.new(0, 10, 0, 208)
closeButton.Text = "✕ KAPAT"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

-- ═══════════════════════════════════════════════════════════════════════════
-- F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if SETTINGS.TeamCheck then
        if LocalPlayer.Team and targetPlayer.Team then
            return LocalPlayer.Team ~= targetPlayer.Team
        end
        return true
    end
    return true
end

local function getNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == LocalPlayer then continue end
        if not isEnemy(otherPlayer) then continue end
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid or otherHumanoid.Health <= 0 then continue end
        local dist = (otherRoot.Position - rootPart.Position).Magnitude
        if dist < nearestDist then
            nearest = otherPlayer
            nearestDist = dist
        end
    end
    return nearest
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  2/2  -  S İ S T E M L E R
-- ═══════════════════════════════════════════════════════════════════════════--[[ BÖLÜM 2/2 - SİSTEMLER ]]

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. MAGIC BULLET
-- ═══════════════════════════════════════════════════════════════════════════

local function startMagicBullet()
    if connections.magic then return end
    connections.magic = RunService.Stepped:Connect(function()
        if not states.magicBullet or not currentTarget then return end
        local targetChar = currentTarget.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("bullet") or obj.Name:lower():find("projectile")) then
                if obj.Parent and obj.Parent ~= character then
                    obj.CFrame = CFrame.new(obj.Position, targetRoot.Position)
                end
            end
        end
    end)
end

local function stopMagicBullet()
    if connections.magic then
        connections.magic:Disconnect()
        connections.magic = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local function startESP()
    stopESP()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == LocalPlayer then continue end
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid then continue end
        
        local isEnemyPlayer = isEnemy(otherPlayer)
        
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = isEnemyPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        box.Transparency = 0.6
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(connections.esp, box)
        
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 120, 0, 30)
        nameTag.Adornee = otherRoot
        nameTag.AlwaysOnTop = true
        nameTag.Parent = otherRoot
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name .. " | " .. math.floor(otherHumanoid.Health) .. "HP"
        nameLabel.TextColor3 = isEnemyPlayer and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = nameTag
        table.insert(connections.esp, nameTag)
    end
end

local function stopESP()
    for _, obj in pairs(connections.esp) do
        pcall(function() obj:Destroy() end)
    end
    connections.esp = {}
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 360 DÖNÜŞ
-- ═══════════════════════════════════════════════════════════════════════════

local function start360()
    if connections.rotation then return end
    connections.rotation = RunService.Heartbeat:Connect(function()
        if not states.rotation then return end
        if rootPart then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end
    end)
end

local function stop360()
    if connections.rotation then
        connections.rotation:Disconnect()
        connections.rotation = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. GIANT
-- ═══════════════════════════════════════════════════════════════════════════

local function startGiant()
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * SETTINGS.GiantSize
            end
        end
    end
end

local function stopGiant()
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size / SETTINGS.GiantSize
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. UÇMA (FLY)
-- ═══════════════════════════════════════════════════════════════════════════

local function startFly()
    if bodyVelocity then return end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 999999
    bodyGyro.D = 999999
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    if connections.fly then connections.fly:Disconnect() end
    connections.fly = RunService.Heartbeat:Connect(function()
        if not states.fly or not currentTarget then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            return
        end
        local tChar = currentTarget.Character
        if not tChar then return end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        
        local targetPos = tRoot.Position
        local lookVector = tRoot.CFrame.LookVector
        local flyTargetPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
        
        local direction = (flyTargetPos - rootPart.Position)
        local distance = direction.Magnitude
        if distance > 0.5 and bodyVelocity then
            local speed = math.min(distance * SETTINGS.FlySpeed, SETTINGS.FlySpeed * 3)
            bodyVelocity.Velocity = direction.Unit * speed
        elseif bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        if bodyGyro then
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, tRoot.Position)
        end
    end)
end

local function stopFly()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if connections.fly then
        connections.fly:Disconnect()
        connections.fly = nil
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

local function startRainbow()
    if connections.rainbow then return end
    local hue = 0
    connections.rainbow = RunService.Heartbeat:Connect(function()
        if not states.rainbow then return end
        hue = hue + 0.03
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Color = color
                end
            end
            if head then head.Color = color end
        end
    end)
end

local function stopRainbow()
    if connections.rainbow then
        connections.rainbow:Disconnect()
        connections.rainbow = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════

local function startTeleport()
    if connections.teleport then return end
    connections.teleport = RunService.Heartbeat:Connect(function()
        if not states.teleport then return end
        local target = getNearestEnemy()
        if target then
            currentTarget = target
            local targetChar = target.Character
            if not targetChar then return end
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end
            local targetPos = targetRoot.Position
            local lookVector = targetRoot.CFrame.LookVector
            local teleportPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
            rootPart.CFrame = CFrame.new(teleportPos, targetPos)
        end
    end)
end

local function stopTeleport()
    if connections.teleport then
        connections.teleport:Disconnect()
        connections.teleport = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- OTOMATİK ATEŞ
-- ═══════════════════════════════════════════════════════════════════════════

local function autoFire()
    local mouse = LocalPlayer:GetMouse()
    if mouse then
        mouse.Button1Down:Fire()
        wait(0.05)
        mouse.Button1Up:Fire()
    end
end

-- Teleport ile birlikte otomatik ateş
local autoFireConnection = nil
local function startAutoFire()
    if autoFireConnection then return end
    autoFireConnection = RunService.Heartbeat:Connect(function()
        if not states.teleport then return end
        autoFire()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B U T O N   İ Ş L E V L E R İ
-- ═══════════════════════════════════════════════════════════════════════════

speedUpBtn.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue + 5
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)

speedDownBtn.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue - 5
    if SETTINGS.SpeedValue < 5 then SETTINGS.SpeedValue = 5 end
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)

closeButton.MouseButton1Click:Connect(function()
    stopMagicBullet()
    stopESP()
    stop360()
    stopGiant()
    stopFly()
    stopRainbow()
    stopTeleport()
    if autoFireConnection then autoFireConnection:Disconnect(); autoFireConnection = nil end
    screenGui:Destroy()
end)

-- Otomatik ateşi başlat
startAutoFire()

-- ═══════════════════════════════════════════════════════════════════════════
-- K A R A K T E R   D E Ğ İ Ş İ M İ
-- ═══════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    head = newChar:FindFirstChild("Head")
    currentTarget = nil
    
    stopFly()
    stopGiant()
    stopRainbow()
    
    if states.fly then startFly() end
    if states.giant then startGiant() end
    if states.rainbow then startRainbow() end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ WEAPON SYSTEM v14.0 - AYRI AYRI BUTONLAR ⚡           ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🔫 Magic Bullet - Aç/Kapa                                  ║")
print("║  👁️  ESP - Aç/Kapa                                         ║")
print("║  🔄 360 - Aç/Kapa                                          ║")
print("║  🦍 Giant - Aç/Kapa                                        ║")
print("║  ✈️  Uçma - Aç/Kapa                                        ║")
print("║  🌈 Rainbow - Aç/Kapa                                      ║")
print("║  🚀 Teleport - Aç/Kapa (otomatik ateş ile)                 ║")
print("║  ⚡ Speed - +/- butonları ile ayarla                       ║")
print("╚══════════════════════════════════════════════════════════════╝")
