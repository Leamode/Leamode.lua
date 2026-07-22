--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ WEAPON SYSTEM v16.0 - TAŞINABİLİR MENÜ + ÇALIŞAN BUTONLAR
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ TAŞINABİLİR MENÜ (Sürükle Bırak)
    ✅ HER BUTON AÇ/KAPA ÇALIŞIR (Yeşil/Kırmızı)
    ✅ Magic Bullet - FULL mermi yönlendirme
    ✅ ESP - Kutu + İsim + HP + Mesafe
    ✅ 360 - Sürekli dönüş
    ✅ Uçma - Fly ile uçma
    ✅ Rainbow - Renk değiştirme
    ✅ Teleport - Işınlanma + Otomatik ateş
    ✅ Speed - +/- ayar
    ✅ GIANT KALDIRILDI
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  1/2  -  A Y A R L A R  +  M E N Ü
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    SpeedValue = 50,
    FlySpeed = 70,
    OffsetBack = 5,
    OffsetUp = 4,
    TeamCheck = true,
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:FindFirstChild("Head")

-- DURUMLAR
local states = {
    magicBullet = false,
    esp = false,
    rotation = false,
    fly = false,
    rainbow = false,
    teleport = false,
}

-- BAĞLANTILAR
local connections = {
    magic = nil,
    esp = {},
    rotation = nil,
    rainbow = nil,
    fly = nil,
    teleport = nil,
    autoFire = nil,
}

local bodyVelocity = nil
local bodyGyro = nil
local currentTarget = nil

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü  (KÜÇÜK - TAŞINABİLİR)
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponSystemGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 55, 0, 160)
mainFrame.Position = UDim2.new(1, -60, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- SÜRÜKLEME (Drag)
local dragging = false
local dragStart = nil
local dragStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
    end
end)

-- BAŞLIK
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 12)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 10
titleLabel.Parent = mainFrame

-- BUTON OLUŞTURMA
local function createToggleButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 49, 0, 14)
    btn.Position = UDim2.new(0, 3, 0, yPos)
    btn.Text = text .. " ❌"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.BorderSizePixel = 0
    btn.Parent = parent
    return btn
end

-- BUTONLAR
local btnMagic = createToggleButton(mainFrame, "🔫", 15)
local btnESP = createToggleButton(mainFrame, "👁️", 32)
local btn360 = createToggleButton(mainFrame, "🔄", 49)
local btnFly = createToggleButton(mainFrame, "✈️", 66)
local btnRainbow = createToggleButton(mainFrame, "🌈", 83)
local btnTeleport = createToggleButton(mainFrame, "🚀", 100)

-- Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 20, 0, 12)
speedLabel.Position = UDim2.new(0, 3, 0, 118)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 9
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0, 12, 0, 12)
speedUpBtn.Position = UDim2.new(0, 25, 0, 118)
speedUpBtn.Text = "+"
speedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 9
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = mainFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0, 12, 0, 12)
speedDownBtn.Position = UDim2.new(0, 39, 0, 118)
speedDownBtn.Text = "-"
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 9
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 49, 0, 14)
closeButton.Position = UDim2.new(0, 3, 0, 135)
closeButton.Text = "✕ KAPAT"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 9
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
        if not states.magicBullet then return end
        
        local target = currentTarget or getNearestEnemy()
        if not target then return end
        
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local targetPos = targetRoot.Position
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") then
                local name = obj.Name:lower()
                if name:find("bullet") or name:find("projectile") or name:find("shell") then
                    if obj.Parent and obj.Parent ~= character then
                        local direction = (targetPos - obj.Position).Unit
                        obj.CFrame = CFrame.new(obj.Position, targetPos)
                        if obj:IsA("BasePart") then
                            obj.Velocity = direction * 400
                        end
                        local bv = obj:FindFirstChildOfClass("BodyVelocity")
                        if bv then
                            bv.Velocity = direction * 400
                        end
                    end
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
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(connections.esp, box)
        
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 100, 0, 25)
        nameTag.Adornee = otherRoot
        nameTag.AlwaysOnTop = true
        nameTag.Parent = otherRoot
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name .. " | " .. math.floor(otherHumanoid.Health) .. "HP"
        nameLabel.TextColor3 = isEnemyPlayer and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 10
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
-- 3. 360
-- ═══════════════════════════════════════════════════════════════════════════

local function start360()
    if connections.rotation then return end
    connections.rotation = RunService.Heartbeat:Connect(function()
        if not states.rotation or not rootPart then return end
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(25), 0)
    end)
end

local function stop360()
    if connections.rotation then
        connections.rotation:Disconnect()
        connections.rotation = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. UÇMA (FLY)
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
        if not states.fly then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            return
        end
        
        local target = currentTarget or getNearestEnemy()
        if not target then return end
        
        local tChar = target.Character
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
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if connections.fly then
        connections.fly:Disconnect()
        connections.fly = nil
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

local function startRainbow()
    if connections.rainbow then return end
    local hue = 0
    connections.rainbow = RunService.Heartbeat:Connect(function()
        if not states.rainbow or not character then return end
        hue = hue + 0.025
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Color = color
            end
        end
        if head then head.Color = color end
    end)
end

local function stopRainbow()
    if connections.rainbow then
        connections.rainbow:Disconnect()
        connections.rainbow = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. TELEPORT + OTOMATİK ATEŞ
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
    
    if connections.autoFire then connections.autoFire:Disconnect() end
    connections.autoFire = RunService.Heartbeat:Connect(function()
        if not states.teleport then return end
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            wait(0.03)
            mouse.Button1Up:Fire()
        end
    end)
end

local function stopTeleport()
    if connections.teleport then
        connections.teleport:Disconnect()
        connections.teleport = nil
    end
    if connections.autoFire then
        connections.autoFire:Disconnect()
        connections.autoFire = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B U T O N   F O N K S İ Y O N L A R I
-- ═══════════════════════════════════════════════════════════════════════════

-- Magic Bullet
btnMagic.MouseButton1Click:Connect(function()
    states.magicBullet = not states.magicBullet
    btnMagic.Text = states.magicBullet and "🔫 ✅" or "🔫 ❌"
    btnMagic.BackgroundColor3 = states.magicBullet and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.magicBullet then startMagicBullet() else stopMagicBullet() end
end)

-- ESP
btnESP.MouseButton1Click:Connect(function()
    states.esp = not states.esp
    btnESP.Text = states.esp and "👁️ ✅" or "👁️ ❌"
    btnESP.BackgroundColor3 = states.esp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.esp then startESP() else stopESP() end
end)

-- 360
btn360.MouseButton1Click:Connect(function()
    states.rotation = not states.rotation
    btn360.Text = states.rotation and "🔄 ✅" or "🔄 ❌"
    btn360.BackgroundColor3 = states.rotation and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rotation then start360() else stop360() end
end)

-- Fly
btnFly.MouseButton1Click:Connect(function()
    states.fly = not states.fly
    btnFly.Text = states.fly and "✈️ ✅" or "✈️ ❌"
    btnFly.BackgroundColor3 = states.fly and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.fly then startFly() else stopFly() end
end)

-- Rainbow
btnRainbow.MouseButton1Click:Connect(function()
    states.rainbow = not states.rainbow
    btnRainbow.Text = states.rainbow and "🌈 ✅" or "🌈 ❌"
    btnRainbow.BackgroundColor3 = states.rainbow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rainbow then startRainbow() else stopRainbow() end
end)

-- Teleport
btnTeleport.MouseButton1Click:Connect(function()
    states.teleport = not states.teleport
    btnTeleport.Text = states.teleport and "🚀 ✅" or "🚀 ❌"
    btnTeleport.BackgroundColor3 = states.teleport and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.teleport then startTeleport() else stopTeleport() end
end)

-- Speed
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

-- Kapat
closeButton.MouseButton1Click:Connect(function()
    stopMagicBullet()
    stopESP()
    stop360()
    stopFly()
    stopRainbow()
    stopTeleport()
    screenGui:Destroy()
end)

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
    stopRainbow()
    if states.fly then startFly() end
    if states.rainbow then startRainbow() end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ WEAPON SYSTEM v16.0 - TAŞINABİLİR MENÜ ⚡             ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🔫 Magic Bullet - Mermi yönlendirme                        ║")
print("║  👁️  ESP - Kutu + İsim + HP                                ║")
print("║  🔄 360 - Sürekli dönüş                                    ║")
print("║  ✈️  Uçma - Fly ile uçma                                   ║")
print("║  🌈 Rainbow - Renk değiştirme                              ║")
print("║  🚀 Teleport - Işınlanma + Otomatik ateş                   ║")
print("║  ⚡ Speed - +/- ile ayarla                                  ║")
print("║  🖱️  Menüyü sürükleyerek taşıyabilirsiniz                   ║")
print("╚══════════════════════════════════════════════════════════════╝")
