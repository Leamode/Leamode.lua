--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ WEAPON SYSTEM v15.0 - KÜÇÜK MENÜ + ÇALIŞAN SİSTEMLER
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ MENÜ: Sağ üst köşe - ÇOK KÜÇÜK (60x200)
    ✅ HER BUTON AYRI AYRI ÇALIŞIR (Aç/Kapa)
    ✅ MAGIC BULLET - GERÇEK MERMİ YÖNLENDİRME (FULL)
    ✅ ESP - Kutu + İsim + HP + Mesafe
    ✅ 360 - Sürekli dönüş
    ✅ GIANT - Devasa boyut
    ✅ UÇMA - Fly ile uçma
    ✅ RAINBOW - Renk değiştirme
    ✅ TELEPORT - Işınlanma + Otomatik ateş
    ✅ SPEED - +/- ile ayar
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  1/2  -  A Y A R L A R  +  M E N Ü  (KÜÇÜK)
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    SpeedValue = 50,
    GiantSize = 2.5,
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
    giant = false,
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
local killCount = 0

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü  (KÜÇÜK - Sağ üst)
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponSystemGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 60, 0, 200)
mainFrame.Position = UDim2.new(1, -65, 0, 5)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 14)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.Parent = mainFrame

-- BUTON OLUŞTURMA
local function createSmallButton(parent, text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 54, 0, 14)
    btn.Position = UDim2.new(0, 3, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.BorderSizePixel = 0
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- BUTONLAR
local btnMagic = createSmallButton(mainFrame, "🔫", 17, Color3.fromRGB(30, 30, 50), function()
    states.magicBullet = not states.magicBullet
    btnMagic.BackgroundColor3 = states.magicBullet and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.magicBullet then startMagicBullet() else stopMagicBullet() end
end)

local btnESP = createSmallButton(mainFrame, "👁️", 34, Color3.fromRGB(30, 30, 50), function()
    states.esp = not states.esp
    btnESP.BackgroundColor3 = states.esp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.esp then startESP() else stopESP() end
end)

local btn360 = createSmallButton(mainFrame, "🔄", 51, Color3.fromRGB(30, 30, 50), function()
    states.rotation = not states.rotation
    btn360.BackgroundColor3 = states.rotation and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.rotation then start360() else stop360() end
end)

local btnGiant = createSmallButton(mainFrame, "🦍", 68, Color3.fromRGB(30, 30, 50), function()
    states.giant = not states.giant
    btnGiant.BackgroundColor3 = states.giant and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.giant then startGiant() else stopGiant() end
end)

local btnFly = createSmallButton(mainFrame, "✈️", 85, Color3.fromRGB(30, 30, 50), function()
    states.fly = not states.fly
    btnFly.BackgroundColor3 = states.fly and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.fly then startFly() else stopFly() end
end)

local btnRainbow = createSmallButton(mainFrame, "🌈", 102, Color3.fromRGB(30, 30, 50), function()
    states.rainbow = not states.rainbow
    btnRainbow.BackgroundColor3 = states.rainbow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.rainbow then startRainbow() else stopRainbow() end
end)

local btnTeleport = createSmallButton(mainFrame, "🚀", 119, Color3.fromRGB(30, 30, 50), function()
    states.teleport = not states.teleport
    btnTeleport.BackgroundColor3 = states.teleport and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 50)
    if states.teleport then startTeleport() else stopTeleport() end
end)

-- Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 25, 0, 12)
speedLabel.Position = UDim2.new(0, 3, 0, 138)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 9
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0, 12, 0, 12)
speedUpBtn.Position = UDim2.new(0, 30, 0, 138)
speedUpBtn.Text = "+"
speedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 9
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = mainFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0, 12, 0, 12)
speedDownBtn.Position = UDim2.new(0, 44, 0, 138)
speedDownBtn.Text = "-"
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 9
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 54, 0, 14)
closeButton.Position = UDim2.new(0, 3, 0, 155)
closeButton.Text = "✕"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 10
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
-- 1. MAGIC BULLET - GERÇEK MERMİ YÖNLENDİRME (FULL)
-- ═══════════════════════════════════════════════════════════════════════════

local function startMagicBullet()
    if connections.magic then return end
    connections.magic = RunService.Stepped:Connect(function()
        if not states.magicBullet then return end
        
        -- Hedef kontrolü
        local target = currentTarget
        if not target then
            target = getNearestEnemy()
            if target then currentTarget = target end
        end
        
        if not currentTarget then return end
        
        local targetChar = currentTarget.Character
        if not targetChar then return end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local targetPos = targetRoot.Position
        
        -- Tüm mermileri tara
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") then
                local name = obj.Name:lower()
                -- Mermi tespiti (çeşitli isimler)
                if name:find("bullet") or name:find("projectile") or name:find("shell") or name:find("pellet") or name:find("round") or name:find("ammo") then
                    -- Mermi bizim değilse yönlendir
                    if obj.Parent and obj.Parent ~= character then
                        -- Hız vektörünü hedefe yönlendir
                        local direction = (targetPos - obj.Position).Unit
                        local speed = 350
                        -- Eğer Velocity varsa
                        if obj:IsA("BasePart") and obj:FindFirstChild("Velocity") then
                            obj.Velocity = direction * speed
                        end
                        -- CFrame ile yönlendirme
                        if obj:IsA("BasePart") then
                            obj.CFrame = CFrame.new(obj.Position, targetPos)
                        end
                        -- BodyVelocity varsa
                        local bv = obj:FindFirstChildOfClass("BodyVelocity")
                        if bv then
                            bv.Velocity = direction * speed
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
-- 2. ESP - KUTU + İSİM + HP + MESAFE
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
        
        -- Kutu
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = isEnemyPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(connections.esp, box)
        
        -- İsim + HP
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
        
        -- Mesafe
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 40, 0, 15)
        distTag.Adornee = otherRoot
        distTag.AlwaysOnTop = true
        distTag.Position = UDim2.new(0, 0, 0, -2)
        distTag.Parent = otherRoot
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 9
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Parent = distTag
        table.insert(connections.esp, distTag)
        
        -- Mesafe güncelleme
        RunService.Heartbeat:Connect(function()
            if otherRoot and rootPart then
                local dist = (otherRoot.Position - rootPart.Position).Magnitude
                distLabel.Text = math.floor(dist) .. "m"
            end
        end)
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
-- 6. RAINBOW
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
-- 7. TELEPORT + OTOMATİK ATEŞ
-- ═══════════════════════════════════════════════════════════════════════════

local function startTeleport()
    if connections.teleport then return end
    
    -- Teleport döngüsü
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
    
    -- Otomatik ateş
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
    stopGiant()
    stopRainbow()
    
    if states.fly then startFly() end
    if states.giant then startGiant() end
    if states.rainbow then startRainbow() end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ WEAPON SYSTEM v15.0 - KÜÇÜK MENÜ + ÇALIŞAN ⚡        ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🔫 Magic Bullet - GERÇEK mermi yönlendirme                 ║")
print("║  👁️  ESP - Kutu + İsim + HP + Mesafe                       ║")
print("║  🔄 360 - Sürekli dönüş                                    ║")
print("║  🦍 Giant - Devasa boyut                                   ║")
print("║  ✈️  Uçma - Fly ile uçma                                   ║")
print("║  🌈 Rainbow - Renk değiştirme                              ║")
print("║  🚀 Teleport - Işınlanma + Otomatik ateş                   ║")
print("║  ⚡ Speed - +/- ile ayarla                                  ║")
print("╚══════════════════════════════════════════════════════════════╝")
