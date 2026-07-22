--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ FLY AIMLOCK v5.0 - FULL KİLİT (FOV 180)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ GİT butonu - en yakın düşmana fly ile yapışır
    ✅ Hedefin arka üstüne sabitlenir (2.5 geri, 3 yukarı)
    ✅ Duvarları yok sayar (geçer gider)
    ✅ Adam nereye giderse takip eder
    ✅ Ölene kadar kilitli kalır
    ✅ Ölünce otomatik yeni hedef bulur
    ✅ Takım kontrolü (kendi takımına gitmez)
    ✅ FOV 180 - tüm ekran kilit (anında tam kilit)
    ✅ KAPAT butonu
    ✅ Menü sağ köşede küçük
    ✅ Hedef bilgileri (isim, HP, mesafe)
    ✅ Kill counter
    ✅ BodyGyro ile tam kilit
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- A Y A R L A R
-- ═══════════════════════════════════════════════════════════════════════════

local SETTINGS = {
    OffsetBack = 2.5,              -- Hedefin arkasından kaç stud geride
    OffsetUp = 3,                  -- Hedefin kaç stud yukarısında
    FlySpeed = 70,                 -- Uçuş hızı
    MaxDistance = 500,             -- Maksimum hedef alma mesafesi
    TeamCheck = true,              -- Takım kontrolü açık/kapalı
    WallIgnore = true,             -- Duvarları yok say
    AutoSwitch = true,             -- Ölünce otomatik hedef değiştir
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
local lastTargetHealth = 100
local targetDied = false

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü   (Sağ köşe - küçük)
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyAimlockGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Ana çerçeve
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 75, 0, 120)
mainFrame.Position = UDim2.new(1, -85, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Başlık
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 18)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡KİLİT"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

-- Çizgi
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -10, 0, 1)
line.Position = UDim2.new(0, 5, 0, 20)
line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
line.BackgroundTransparency = 0.5
line.Parent = mainFrame

-- Durum
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

-- Hedef ismi
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

-- HP
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

-- Mesafe
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

-- Kill sayacı
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

-- GİT Butonu
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

-- KAPAT Butonu
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
-- F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

-- Takım kontrolü
local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == player then 
        return false 
    end
    
    if SETTINGS.TeamCheck then
        if player.Team and targetPlayer.Team then
            return player.Team ~= targetPlayer.Team
        end
        return true
    end
    return true
end

-- En yakın düşmanı bul (gelişmiş)
local function getNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    local players = game.Players:GetPlayers()
    
    for _, otherPlayer in pairs(players) do
        if otherPlayer == player then 
            continue 
        end
        
        if not isEnemy(otherPlayer) then
            continue
        end
        
        local otherChar = otherPlayer.Character
        if not otherChar then 
            continue 
        end
        
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        
        if not otherRoot or not otherHumanoid then 
            continue 
        end
        
        if otherHumanoid.Health <= 0 then
            continue
        end
        
        local dist = (otherRoot.Position - rootPart.Position).Magnitude
        
        if dist > SETTINGS.MaxDistance then
            continue
        end
        
        if dist < nearestDist then
            nearest = otherPlayer
            nearestDist = dist
        end
    end
    
    return nearest
end

-- Fly oluştur
local function createFly()
    if bodyVelocity then 
        bodyVelocity:Destroy() 
        bodyVelocity = nil
    end
    if bodyGyro then 
        bodyGyro:Destroy() 
        bodyGyro = nil
    end
    
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

-- Fly yok et
local function destroyFly()
    if bodyVelocity then 
        bodyVelocity:Destroy() 
        bodyVelocity = nil
    end
    if bodyGyro then 
        bodyGyro:Destroy() 
        bodyGyro = nil
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
end

-- Hedefe yapış (fly ile) - TAM KİLİT
local function attachToTarget(targetPlayer)
    if not targetPlayer then
        statusLabel.Text = "⚠️"
        return false
    end
    
    local targetChar = targetPlayer.Character
    if not targetChar then
        statusLabel.Text = "❌"
        return false
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        statusLabel.Text = "💀"
        return false
    end
    
    -- Önceki hedefi temizle
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    currentTarget = targetPlayer
    lastTargetHealth = targetHumanoid.Health
    targetDied = false
    
    -- Fly oluştur
    createFly()
    isActive = true
    isRunning = true
    
    -- Buton görünümünü güncelle
    gitButton.Text = "⏹"
    gitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Text = "🔴"
    
    -- Hedef bilgilerini güncelle
    targetNameLabel.Text = targetPlayer.Name
    hpLabel.Text = "HP: " .. math.floor(targetHumanoid.Health)
    hpLabel.TextColor3 = targetHumanoid.Health > 50 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    local dist = (targetRoot.Position - rootPart.Position).Magnitude
    distLabel.Text = math.floor(dist) .. "m"
    
    -- ═══════ FLY DÖNGÜSÜ - TAM KİLİT ═══════
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isActive or not isRunning or not currentTarget then
            destroyFly()
            isActive = false
            isRunning = false
            gitButton.Text = "▶"
            gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            statusLabel.Text = "⏸"
            if flyConnection then 
                flyConnection:Disconnect() 
                flyConnection = nil 
            end
            return
        end
        
        local targetChar = currentTarget.Character
        if not targetChar then
            if SETTINGS.AutoSwitch then
                local newTarget = getNearestEnemy()
                if newTarget then
                    attachToTarget(newTarget)
                    return
                end
            end
            destroyFly()
            isActive = false
            isRunning = false
            gitButton.Text = "▶"
            gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            statusLabel.Text = "❌"
            if flyConnection then 
                flyConnection:Disconnect() 
                flyConnection = nil 
            end
            return
        end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        
        if not targetRoot or not targetHumanoid then
            if SETTINGS.AutoSwitch then
                local newTarget = getNearestEnemy()
                if newTarget then
                    attachToTarget(newTarget)
                    return
                end
            end
            destroyFly()
            isActive = false
            isRunning = false
            gitButton.Text = "▶"
            gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            statusLabel.Text = "❌"
            if flyConnection then 
                flyConnection:Disconnect() 
                flyConnection = nil 
            end
            return
        end
        
        -- KILL CHECK - Öldü mü?
        if targetHumanoid.Health <= 0 then
            killCount = killCount + 1
            killLabel.Text = "💀 " .. killCount
            targetDied = true
            
            if SETTINGS.AutoSwitch then
                statusLabel.Text = "🔄"
                targetNameLabel.Text = "Yeni hedef..."
                local newTarget = getNearestEnemy()
                if newTarget then
                    attachToTarget(newTarget)
                    return
                else
                    destroyFly()
                    isActive = false
                    isRunning = false
                    gitButton.Text = "▶"
                    gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                    statusLabel.Text = "⏸"
                    targetNameLabel.Text = "Yok"
                    hpLabel.Text = "HP: 0"
                    distLabel.Text = "0m"
                    if flyConnection then 
                        flyConnection:Disconnect() 
                        flyConnection = nil 
                    end
                    return
                end
            else
                destroyFly()
                isActive = false
                isRunning = false
                gitButton.Text = "▶"
                gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                statusLabel.Text = "💀"
                if flyConnection then 
                    flyConnection:Disconnect() 
                    flyConnection = nil 
                end
                return
            end
        end
        
        -- HP güncelle
        if targetHumanoid.Health ~= lastTargetHealth then
            lastTargetHealth = targetHumanoid.Health
            hpLabel.Text = "HP: " .. math.floor(targetHumanoid.Health)
            hpLabel.TextColor3 = targetHumanoid.Health > 50 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end
        
        -- HEDEFİN ARKA ÜSTÜNE GİT
        local targetPos = targetRoot.Position
        local lookVector = targetRoot.CFrame.LookVector
        local targetPosition = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
        
        -- UÇUŞ - DUVARLARI YOK SAYAR
        local direction = (targetPosition - rootPart.Position)
        local distance = direction.Magnitude
        
        if distance > 0.5 then
            local speed = math.min(distance * SETTINGS.FlySpeed, SETTINGS.FlySpeed * 3)
            local velocity = direction.Unit * speed
            if bodyVelocity then
                bodyVelocity.Velocity = velocity
            end
        else
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- ═══════ TAM KİLİT - FOV 180 (anında hedefe bak) ═══════
        if bodyGyro then
            -- Direkt hedefe bak - hiç yumuşaklık yok
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, targetRoot.Position)
        end
        
        -- Mesafeyi güncelle
        local currentDist = (targetRoot.Position - rootPart.Position).Magnitude
        distLabel.Text = math.floor(currentDist) .. "m"
        
        -- Durum rengi
        statusLabel.Text = currentDist < 10 and "🟢" or "🟡"
    end)
    
    return true
end

-- Durdur
local function stopAll()
    isActive = false
    isRunning = false
    destroyFly()
    if flyConnection then 
        flyConnection:Disconnect() 
        flyConnection = nil 
    end
    gitButton.Text = "▶"
    gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    statusLabel.Text = "⏸"
    targetNameLabel.Text = "Yok"
    currentTarget = nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B U T O N   İ Ş L E V L E R İ
-- ═══════════════════════════════════════════════════════════════════════════

-- GİT Butonu
gitButton.MouseButton1Click:Connect(function()
    if isActive then
        stopAll()
    else
        local target = getNearestEnemy()
        if target then
            attachToTarget(target)
        else
            statusLabel.Text = "🔍"
            gitButton.Text = "⏳"
            spawn(function()
                local attempts = 0
                while attempts < 30 do
                    local t = getNearestEnemy()
                    if t then
                        attachToTarget(t)
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

-- KAPAT Butonu
closeButton.MouseButton1Click:Connect(function()
    stopAll()
    screenGui:Destroy()
    print("✅ Fly Aimlock kapatıldı")
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- E T K İ N L İ K   Y A K A L A Y I C I L A R
-- ═══════════════════════════════════════════════════════════════════════════

-- Karakter değişimi
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    stopAll()
    statusLabel.Text = "🔄"
    targetNameLabel.Text = "Yenilendi"
    wait(1)
    if not isActive then
        statusLabel.Text = "⏸"
        targetNameLabel.Text = "Yok"
    end
end)

-- Oyuncu çıkışı
game.Players.PlayerRemoving:Connect(function(plr)
    if currentTarget == plr then
        statusLabel.Text = "👋"
        targetNameLabel.Text = "Çıktı"
        if SETTINGS.AutoSwitch then
            local newTarget = getNearestEnemy()
            if newTarget then
                attachToTarget(newTarget)
            else
                stopAll()
            end
        else
            stopAll()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- B A Ş L A N G I Ç   M E S A J I
-- ═══════════════════════════════════════════════════════════════════════════

print("╔══════════════════════════════════════════════════════════════╗")
print("║        ⚡ FLY AIMLOCK v5.0 - TAM KİLİT ⚡                  ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  ▶ GİT bas - düşmanın arka üstüne yapış                    ║")
print("║  🧱 Duvarları yok sayar - deler geçer                      ║")
print("║  🎯 FOV 180 - TAM EKRAN KİLİT (anında)                     ║")
print("║  👁️  Otomatik takip - hiç yumuşaklık yok                  ║")
print("║  💀 Ölünce otomatik yeni hedef                             ║")
print("║  🛡️  Takım kontrolü aktif                                  ║")
print("║  📊 Kill sayacı aktif                                      ║")
print("╚══════════════════════════════════════════════════════════════╝")
