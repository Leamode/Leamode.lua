--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ MAGIC BULLET + TELEPORT ESP v10.0 - FULL SİSTEM
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ Magic Bullet - Mermi hedefe yönlenir (silah hack)
    ✅ Teleport - GİT basınca direk hedefin arkasına ışınlanır
    ✅ ESP - Tüm oyuncuları gösterir (isim, HP, mesafe, kutu)
    ✅ Fly ile hedefin arkasında sabit kalır
    ✅ Aimbot tam kilit
    ✅ Otomatik ateş
    ✅ Ölünce direk diğer adama ışınlanır
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- A Y A R L A R
-- ═══════════════════════════════════════════════════════════════════════════

local SETTINGS = {
    OffsetBack = 5,
    OffsetUp = 4,
    FlySpeed = 80,
    MaxDistance = 500,
    TeamCheck = true,
    AutoFire = true,
    AntiReset = true,
    BulletProof = true,
    ESPEnabled = true,
    MagicBullet = true,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- B A Ş L A N G I Ç
-- ═══════════════════════════════════════════════════════════════════════════

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local killCount = 0
local currentTarget = nil
local isActive = false
local isRunning = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local lastHealth = humanoid.Health
local espObjects = {}
local magicConnection = nil

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü   (Sağ köşe - küçük)
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimlockGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 75, 0, 120)
mainFrame.Position = UDim2.new(1, -85, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 18)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡HACK"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -10, 0, 1)
line.Position = UDim2.new(0, 5, 0, 20)
line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
line.BackgroundTransparency = 0.5
line.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -4, 0, 14)
statusLabel.Position = UDim2.new(0, 2, 0, 23)
statusLabel.Text = "⏸"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local targetNameLabel = Instance.new("TextLabel")
targetNameLabel.Size = UDim2.new(1, -4, 0, 14)
targetNameLabel.Position = UDim2.new(0, 2, 0, 39)
targetNameLabel.Text = "Yok"
targetNameLabel.BackgroundTransparency = 1
targetNameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
targetNameLabel.Font = Enum.Font.Gotham
targetNameLabel.TextSize = 9
targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
targetNameLabel.Parent = mainFrame

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -4, 0, 14)
hpLabel.Position = UDim2.new(0, 2, 0, 55)
hpLabel.Text = "HP: 100"
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 9
hpLabel.TextXAlignment = Enum.TextXAlignment.Left
hpLabel.Parent = mainFrame

local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(1, -4, 0, 14)
distLabel.Position = UDim2.new(0, 2, 0, 71)
distLabel.Text = "0m"
distLabel.BackgroundTransparency = 1
distLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
distLabel.Font = Enum.Font.Gotham
distLabel.TextSize = 9
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = mainFrame

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(1, -4, 0, 14)
killLabel.Position = UDim2.new(0, 2, 0, 87)
killLabel.Text = "💀 0"
killLabel.BackgroundTransparency = 1
killLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
killLabel.Font = Enum.Font.GothamBold
killLabel.TextSize = 10
killLabel.TextXAlignment = Enum.TextXAlignment.Left
killLabel.Parent = mainFrame

local gitButton = Instance.new("TextButton")
gitButton.Size = UDim2.new(0, 35, 0, 22)
gitButton.Position = UDim2.new(0, 2, 0, 103)
gitButton.Text = "▶"
gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
gitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gitButton.Font = Enum.Font.GothamBold
gitButton.TextSize = 14
gitButton.BorderSizePixel = 0
gitButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 22)
closeButton.Position = UDim2.new(0, 41, 0, 103)
closeButton.Text = "✕"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

-- ═══════════════════════════════════════════════════════════════════════════
-- E S P   S İ S T E M İ
-- ═══════════════════════════════════════════════════════════════════════════

local function createESP()
    if not SETTINGS.ESPEnabled then return end
    
    for _, esp in pairs(espObjects) do
        if esp then esp:Destroy() end
    end
    espObjects = {}
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer == player then continue end
        
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid then continue end
        
        -- Kutu
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = isEnemy(otherPlayer) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        box.Transparency = 0.7
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        
        -- İsim
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 100, 0, 30)
        nameTag.Adornee = otherRoot
        nameTag.AlwaysOnTop = true
        nameTag.Parent = otherRoot
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name .. " | " .. math.floor(otherHumanoid.Health) .. "HP"
        nameLabel.TextColor3 = isEnemy(otherPlayer) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = nameTag
        
        -- Mesafe
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 50, 0, 20)
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
        distLabel.TextSize = 12
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Parent = distTag
        
        table.insert(espObjects, box)
        table.insert(espObjects, nameTag)
        table.insert(espObjects, distTag)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- M A G I C   B U L L E T   (Mermi yönlendirme)
-- ═══════════════════════════════════════════════════════════════════════════

local function setupMagicBullet()
    if not SETTINGS.MagicBullet then return end
    if magicConnection then magicConnection:Disconnect() end
    
    -- Tüm mermileri yakala ve hedefe yönlendir
    magicConnection = game:GetService("RunService").Stepped:Connect(function()
        if not isActive or not currentTarget then return end
        
        local targetChar = currentTarget.Character
        if not targetChar then return end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        -- Tüm mermi objelerini bul ve yönlendir
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:lower():find("bullet") or obj.Name:lower():find("projectile") then
                if obj.Parent and obj.Parent:FindFirstChild("Humanoid") then
                    -- Mermiyi hedefe yönlendir
                    local direction = (targetRoot.Position - obj.Position).Unit
                    obj.Velocity = direction * 300
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == player then return false end
    if SETTINGS.TeamCheck then
        if player.Team and targetPlayer.Team then
            return player.Team ~= targetPlayer.Team
        end
        return true
    end
    return true
end

-- En yakın düşmanı bul (DIREK, arama yok)
local function getNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer == player then continue end
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

-- FLY oluştur
local function createFly()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    
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
end

local function destroyFly()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
end

-- Otomatik ateş
local function autoFire()
    if not SETTINGS.AutoFire then return end
    local mouse = player:GetMouse()
    if mouse then
        mouse.Button1Down:Fire()
        wait(0.05)
        mouse.Button1Up:Fire()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HEDEFE IŞINLAN + FLY + KİLİT
-- ═══════════════════════════════════════════════════════════════════════════

local function teleportToTarget(targetPlayer)
    if not targetPlayer then return false end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        return false
    end
    
    -- Önceki bağlantıları temizle
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    destroyFly()
    
    currentTarget = targetPlayer
    lastHealth = targetHumanoid.Health
    
    -- DIREK IŞINLAN (arama yok, hemen)
    local targetPos = targetRoot.Position
    local lookVector = targetRoot.CFrame.LookVector
    local teleportPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
    rootPart.CFrame = CFrame.new(teleportPos, targetPos)
    
    createFly()
    
    isActive = true
    isRunning = true
    gitButton.Text = "⏹"
    gitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Text = "🔴"
    targetNameLabel.Text = targetPlayer.Name
    hpLabel.Text = "HP: " .. math.floor(targetHumanoid.Health)
    
    -- FLY + AIMBOT DÖNGÜSÜ
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isActive or not isRunning then
            destroyFly()
            isActive = false
            isRunning = false
            gitButton.Text = "▶"
            gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            statusLabel.Text = "⏸"
            targetNameLabel.Text = "Yok"
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
            return
        end
        
        -- HEDEF ÖLDÜ MÜ? DIREK YENİSİNE IŞINLAN
        if currentTarget then
            local tChar = currentTarget.Character
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            
            if not tChar or not tHum or tHum.Health <= 0 then
                killCount = killCount + 1
                killLabel.Text = "💀 " .. killCount
                
                local newTarget = getNearestEnemy()
                if newTarget then
                    teleportToTarget(newTarget)
                    return
                else
                    destroyFly()
                    isActive = false
                    isRunning = false
                    gitButton.Text = "▶"
                    gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                    statusLabel.Text = "⏸"
                    targetNameLabel.Text = "Yok"
                    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
                    return
                end
            end
            
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                -- FLY ile arkasında kal
                local targetPos = tRoot.Position
                local lookVector = tRoot.CFrame.LookVector
                local flyTargetPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
                
                local direction = (flyTargetPos - rootPart.Position)
                local distance = direction.Magnitude
                
                if distance > 0.5 then
                    local speed = math.min(distance * SETTINGS.FlySpeed, SETTINGS.FlySpeed * 3)
                    if bodyVelocity then
                        bodyVelocity.Velocity = direction.Unit * speed
                    end
                else
                    if bodyVelocity then
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                
                -- AIMBOT
                if bodyGyro then
                    bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, tRoot.Position)
                end
                
                local dist = (tRoot.Position - rootPart.Position).Magnitude
                distLabel.Text = math.floor(dist) .. "m"
                statusLabel.Text = dist < 15 and "🟢" or "🟡"
                
                -- HP güncelle
                if tHum.Health ~= lastHealth then
                    lastHealth = tHum.Health
                    hpLabel.Text = "HP: " .. math.floor(tHum.Health)
                    hpLabel.TextColor3 = tHum.Health > 50 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                end
            end
        end
        
        -- Otomatik ateş
        if SETTINGS.AutoFire then
            autoFire()
        end
    end)
    
    return true
end

-- Durdur
local function stopAll()
    isActive = false
    isRunning = false
    destroyFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if magicConnection then magicConnection:Disconnect(); magicConnection = nil end
    gitButton.Text = "▶"
    gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    statusLabel.Text = "⏸"
    targetNameLabel.Text = "Yok"
    currentTarget = nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B U T O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

gitButton.MouseButton1Click:Connect(function()
    if isActive then
        stopAll()
    else
        local target = getNearestEnemy()
        if target then
            teleportToTarget(target)
        else
            statusLabel.Text = "⚠️"
            gitButton.Text = "⏳"
            spawn(function()
                local attempts = 0
                while attempts < 30 do
                    local t = getNearestEnemy()
                    if t then
                        teleportToTarget(t)
                        return
                    end
                    attempts = attempts + 1
                    wait(0.2)
                end
                gitButton.Text = "▶"
                gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                statusLabel.Text = "⚠️"
            end)
        end
    end
end)

closeButton.MouseButton1Click:Connect(function()
    stopAll()
    screenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- E T K İ N L İ K   Y A K A L A Y I C I L A R
-- ═══════════════════════════════════════════════════════════════════════════

-- ESP'yi başlat
createESP()
setupMagicBullet()

-- Yeni oyuncu geldiğinde ESP güncelle
game.Players.PlayerAdded:Connect(function()
    wait(1)
    createESP()
end)

game.Players.PlayerRemoving:Connect(function()
    createESP()
end)

-- Karakter değişimi
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    stopAll()
    wait(1)
    createESP()
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║  ⚡ MAGIC BULLET + TELEPORT ESP v10.0 - FULL SİSTEM ⚡     ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🔫 Magic Bullet - Mermiler hedefe yönlenir                ║")
print("║  📍 GİT bas - DIREK hedefin arkasına IŞINLANIR            ║")
print("║  👁️  ESP - Tüm oyuncuları gösterir                         ║")
print("║  🪰 FLY ile arkasında sabit kalır                          ║")
print("║  🎯 Aimbot tam kilit                                       ║")
print("║  💀 Ölünce DIREK diğer adama IŞINLANIR                     ║")
print("╚═════════════════════════════════════════════════════════
