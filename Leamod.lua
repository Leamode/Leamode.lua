--[[
    ═══════════════════════════════════════════════════════════════
    GELİŞMİŞ GİT BUTONLU AİMLOCK + TAKIM + DUVAR + KILL CHECK
    ═══════════════════════════════════════════════════════════════
    
    ÖZELLİKLER:
    ✅ GİT butonu - en yakın düşmana ışınlanma
    ✅ Hedefin arka üstüne sabitlenme (2.5 geri, 3 yukarı)
    ✅ Hedefe bakma (aimlock)
    ✅ Takım kontrolü - kendi takımına gitmez
    ✅ Duvar kontrolü - duvar arkasındakini hedeflemez
    ✅ Kill check - ölünce otomatik sonraki hedefe geçer
    ✅ KAPAT butonu - scripti tamamen kapatır
    ✅ Arayüz - durum göstergesi, hedef ismi
    ✅ Hata yönetimi - karakter ölümü, oyuncu çıkışı
    ✅ Ayarlanabilir mesafe ve hassasiyet
]]

-- ═══════════════════════════════════════════════════ AYARLAR ═══════════════════════════════════════════════════

local SETTINGS = {
    MaxDistance = 200,              -- Maksimum hedef alma mesafesi
    TargetOffsetBack = 2.5,         -- Hedefin arkasından ne kadar uzakta duralım
    TargetOffsetUp = 3,             -- Hedefin ne kadar yukarısında duralım
    CheckInterval = 0.1,            -- Kontrol aralığı (saniye)
    AutoRotateSpeed = 10,           -- Dönüş hızı (1-10 arası)
    WallCheckEnabled = true,        -- Duvar kontrolü açık/kapalı
    TeamCheckEnabled = true,        -- Takım kontrolü açık/kapalı
    KillCheckEnabled = true,        -- Kill check açık/kapalı
}

-- ═══════════════════════════════════════════════════ BAŞLANGIÇ ═══════════════════════════════════════════════════

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════ GUI OLUŞTUR ═══════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimlockGUI"
screenGui.Parent = player.PlayerGui

-- Animasyonlu arka plan
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 170)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Başlık
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "⚡ AIMLOCK v2.0"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- Durum göstergesi (hedef ismi + durum)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 35)
statusLabel.Text = "🔴 Bekleniyor..."
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Hedef bilgisi
local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Size = UDim2.new(1, -10, 0, 20)
targetInfoLabel.Position = UDim2.new(0, 5, 0, 62)
targetInfoLabel.Text = "Hedef: Yok"
targetInfoLabel.BackgroundTransparency = 1
targetInfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
targetInfoLabel.Font = Enum.Font.Gotham
targetInfoLabel.TextSize = 12
targetInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
targetInfoLabel.Parent = mainFrame

-- Mesafe bilgisi
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(1, -10, 0, 20)
distLabel.Position = UDim2.new(0, 5, 0, 84)
distLabel.Text = "Mesafe: 0m"
distLabel.BackgroundTransparency = 1
distLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
distLabel.Font = Enum.Font.Gotham
distLabel.TextSize = 12
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = mainFrame

-- GİT Butonu
local gitButton = Instance.new("TextButton")
gitButton.Size = UDim2.new(0, 90, 0, 35)
gitButton.Position = UDim2.new(0, 10, 0, 115)
gitButton.Text = "🔍 GİT"
gitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
gitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gitButton.Font = Enum.Font.GothamBold
gitButton.TextSize = 15
gitButton.BorderSizePixel = 0
gitButton.Parent = mainFrame

-- KAPAT Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 90, 0, 35)
closeButton.Position = UDim2.new(0, 110, 0, 115)
closeButton.Text = "✕ KAPAT"
closeButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 15
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

-- Animasyonlu çizgi
local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 2)
line.Position = UDim2.new(0, 0, 0, 33)
line.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
line.BackgroundTransparency = 0.3
line.Parent = mainFrame

-- ═══════════════════════════════════════════════════ DEĞİŞKENLER ═══════════════════════════════════════════════════

local isActive = false
local currentTarget = nil
local currentTargetDistance = 0
local isRunning = false
local targetHumanoid = nil

-- ═══════════════════════════════════════════════════ FONKSİYONLAR ═══════════════════════════════════════════════════

-- Takım kontrolü (detaylı)
local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == player then 
        return false 
    end
    
    if SETTINGS.TeamCheckEnabled then
        -- Oyuncunun takımı varsa kontrol et
        if player.Team and targetPlayer.Team then
            return player.Team ~= targetPlayer.Team
        end
        
        -- Takım yoksa ama Neutral vs Neutral kontrolü
        if not player.Team and not targetPlayer.Team then
            return true -- Takım yoksa herkes düşman
        end
        
        -- Biri takımlı diğeri değilse
        return true
    end
    
    return true -- Takım kontrolü kapalıysa herkes düşman
end

-- Daha hassas duvar kontrolü
local function canSeeTarget(targetRoot)
    if not SETTINGS.WallCheckEnabled then 
        return true 
    end
    
    local origin = rootPart.Position + Vector3.new(0, 1.5, 0)
    local targetPos = targetRoot.Position + Vector3.new(0, 1.5, 0)
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    
    if distance > SETTINGS.MaxDistance then
        return false
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, targetRoot.Parent}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if result then
        local hitInstance = result.Instance
        -- Eğer çarptığımız şey hedefin bir parçasıysa görüyoruz
        if hitInstance and hitInstance:IsDescendantOf(targetRoot.Parent) then
            return true
        end
        
        -- Vurulan obje duvar mı kontrol et
        if hitInstance and hitInstance.Material then
            local material = hitInstance.Material
            if material == Enum.Material.Air or material == Enum.Material.Glass then
                return true -- Cam veya havadan geçebilir
            end
        end
        
        return false -- Duvar var
    end
    
    return true -- Hiçbir şeye çarpmadıysa görüyor
end

-- Tüm oyuncuları tara ve en yakın düşmanı bul (gelişmiş)
local function getNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    local players = game.Players:GetPlayers()
    local totalPlayers = #players
    
    if totalPlayers == 0 then
        return nil
    end
    
    for _, otherPlayer in pairs(players) do
        -- Kendini ve ölüleri atla
        if otherPlayer == player then 
            continue 
        end
        
        -- Takım kontrolü
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
        
        -- Ölü mü kontrol et
        if otherHumanoid.Health <= 0 then
            continue
        end
        
        -- Mesafe hesapla
        local dist = (otherRoot.Position - rootPart.Position).Magnitude
        
        -- Max mesafe kontrolü
        if dist > SETTINGS.MaxDistance then
            continue
        end
        
        -- Duvar kontrolü
        if not canSeeTarget(otherRoot) then
            continue
        end
        
        -- En yakını bul
        if dist < nearestDist then
            nearest = otherPlayer
            nearestDist = dist
            currentTargetDistance = dist
        end
    end
    
    return nearest
end

-- Hedefe git ve sabitlen (gelişmiş)
local function goToTarget(targetPlayer)
    if not targetPlayer then 
        statusLabel.Text = "⚠️ Hedef bulunamadı!"
        return false 
    end
    
    local targetChar = targetPlayer.Character
    if not targetChar then 
        statusLabel.Text = "❌ Hedef karakteri yok!"
        return false 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar:FindFirstChild("Humanoid")
    
    if not targetRoot or not targetHum or targetHum.Health <= 0 then
        statusLabel.Text = "💀 Hedef ölü!"
        return false
    end
    
    -- Hedef bilgilerini güncelle
    currentTarget = targetPlayer
    targetHumanoid = targetHum
    
    local targetPos = targetRoot.Position
    local lookVector = targetRoot.CFrame.LookVector
    
    -- Hedefin arka üstüne git (ayarlardan)
    local offsetBack = SETTINGS.TargetOffsetBack
    local offsetUp = SETTINGS.TargetOffsetUp
    local targetPosition = targetPos - (lookVector * offsetBack) + Vector3.new(0, offsetUp, 0)
    
    -- Teleport et (güvenli)
    local success, err = pcall(function()
        rootPart.CFrame = CFrame.new(targetPosition, targetPos)
    end)
    
    if not success then
        statusLabel.Text = "⚠️ Teleport hatası!"
        return false
    end
    
    -- Bilgileri güncelle
    local dist = (targetPos - rootPart.Position).Magnitude
    currentTargetDistance = dist
    
    statusLabel.Text = "🎯 Takip: " .. targetPlayer.Name
    targetInfoLabel.Text = "Hedef: " .. targetPlayer.Name .. " | " .. math.floor(targetHum.Health) .. " HP"
    distLabel.Text = "Mesafe: " .. math.floor(dist) .. "m | Takım: " .. (targetPlayer.Team and targetPlayer.Team.Name or "Yok")
    
    return true
end

-- Hedefe bak (aimlock)
local function aimAtTarget()
    if not currentTarget then 
        return 
    end
    
    local targetChar = currentTarget.Character
    if not targetChar then 
        return 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then 
        return 
    end
    
    -- Dönüş hızı ile yumuşak aim
    local targetPos = targetRoot.Position
    local currentPos = rootPart.Position
    local lookAt = CFrame.lookAt(currentPos, targetPos)
    
    -- Yumuşak geçiş
    local speed = SETTINGS.AutoRotateSpeed / 10
    local newCFrame = rootPart.CFrame:Lerp(lookAt, speed)
    rootPart.CFrame = newCFrame
end

-- Kill check (ölüm kontrolü)
local function checkTargetAlive()
    if not SETTINGS.KillCheckEnabled then
        return true
    end
    
    if not currentTarget then 
        return false 
    end
    
    local targetChar = currentTarget.Character
    if not targetChar then 
        statusLabel.Text = "💀 Hedef yok oldu!"
        currentTarget = nil
        targetHumanoid = nil
        return false 
    end
    
    local targetHum = targetChar:FindFirstChild("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        statusLabel.Text = "💀 Hedef öldü! Yeni hedef aranıyor..."
        currentTarget = nil
        targetHumanoid = nil
        return false
    end
    
    return true
end

-- ═══════════════════════════════════════════════════ ANA DÖNGÜ ═══════════════════════════════════════════════════

local function mainLoop()
    while isActive and isRunning do
        -- === KONTROL 1: Hedef yaşıyor mu? ===
        if currentTarget then
            local alive = checkTargetAlive()
            if not alive then
                -- Hedef öldü, yenisini ara
                local newTarget = getNearestEnemy()
                if newTarget then
                    goToTarget(newTarget)
                else
                    statusLabel.Text = "⏳ Düşman aranıyor..."
                    targetInfoLabel.Text = "Hedef: Yok"
                    currentTarget = nil
                    targetHumanoid = nil
                end
                wait(SETTINGS.CheckInterval)
                continue
            end
        end
        
        -- === KONTROL 2: Hedef yoksa yeni hedef bul ===
        if not currentTarget then
            local target = getNearestEnemy()
            if target then
                goToTarget(target)
            else
                statusLabel.Text = "⏳ Düşman aranıyor..."
                targetInfoLabel.Text = "Hedef: Yok"
                distLabel.Text = "Mesafe: 0m"
            end
            wait(SETTINGS.CheckInterval)
            continue
        end
        
        -- === KONTROL 3: Hedefe bak ve pozisyonu koru ===
        if currentTarget then
            local targetChar = currentTarget.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local targetRoot = targetChar.HumanoidRootPart
                
                -- Duvar kontrolü
                if not canSeeTarget(targetRoot) then
                    statusLabel.Text = "🧱 Duvar engelliyor, yeni hedef aranıyor..."
                    local newTarget = getNearestEnemy()
                    if newTarget then
                        goToTarget(newTarget)
                    else
                        currentTarget = nil
                        targetHumanoid = nil
                        statusLabel.Text = "⚠️ Hedef kaybedildi"
                    end
                    wait(SETTINGS.CheckInterval)
                    continue
                end
                
                -- Hedefe bak (aimlock)
                aimAtTarget()
                
                -- Mesafeyi güncelle
                local dist = (targetRoot.Position - rootPart.Position).Magnitude
                currentTargetDistance = dist
                distLabel.Text = "Mesafe: " .. math.floor(dist) .. "m"
                
                -- HP güncelle
                local hum = targetChar:FindFirstChild("Humanoid")
                if hum then
                    targetInfoLabel.Text = "Hedef: " .. currentTarget.Name .. " | " .. math.floor(hum.Health) .. " HP"
                end
            else
                -- Hedef karakteri kayboldu
                statusLabel.Text = "❌ Hedef kayboldu!"
                currentTarget = nil
                targetHumanoid = nil
            end
        end
        
        wait(SETTINGS.CheckInterval)
    end
end

-- ═══════════════════════════════════════════════════ BUTON İŞLEVLERİ ═══════════════════════════════════════════════════

-- GİT butonu
gitButton.MouseButton1Click:Connect(function()
    if isActive then
        -- Durdur
        isActive = false
        isRunning = false
        gitButton.Text = "🔍 GİT"
        gitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        statusLabel.Text = "⏹ Durduruldu"
        targetInfoLabel.Text = "Hedef: Yok"
        distLabel.Text = "Mesafe: 0m"
        currentTarget = nil
        targetHumanoid = nil
    else
        -- Başlat
        isActive = true
        isRunning = true
        gitButton.Text = "⏹ DURDUR"
        gitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🔄 Başlatılıyor..."
        
        -- Yeni thread başlat
        spawn(function()
            mainLoop()
        end)
    end
end)

-- KAPAT butonu
closeButton.MouseButton1Click:Connect(function()
    isActive = false
    isRunning = false
    currentTarget = nil
    targetHumanoid = nil
    screenGui:Destroy()
    print("✅ Script kapatıldı")
end)

-- ═══════════════════════════════════════════════════ OLAY YAKALAYICILAR ═══════════════════════════════════════════════════

-- Karakter değişimi
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    currentTarget = nil
    targetHumanoid = nil
    statusLabel.Text = "🔄 Karakter yenilendi"
    targetInfoLabel.Text = "Hedef: Yok"
    distLabel.Text = "Mesafe: 0m"
end)

-- Oyuncu çıkışı
game.Players.PlayerRemoving:Connect(function(plr)
    if currentTarget == plr then
        currentTarget = nil
        targetHumanoid = nil
        statusLabel.Text = "👋 Hedef çıktı!"
    end
end)

-- ═══════════════════════════════════════════════════ BAŞLANGIÇ MESAJI ═══════════════════════════════════════════════════

print("╔═══════════════════════════════════════════════╗")
print("║     ⚡ AIMLOCK SCRIPT v2.0 HAZIR ⚡          ║")
print("╠═══════════════════════════════════════════════╣")
print("║  🔍 GİT butonu ile hedefe git              ║")
print("║  🎯 Hedefin arka üstüne sabitlenir         ║")
print("║  👁️  Otomatik hedefe bakar (aimlock)        ║")
print("║  🛡️  Takım kontrolü aktif                  ║")
print("║  🧱 Duvar kontrolü aktif                   ║")
print("║  💀 Kill check aktif (ölünce geçer)        ║")
print("╚═══════════════════════════════════════════════╝")
