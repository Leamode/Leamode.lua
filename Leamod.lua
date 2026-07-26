-- // ============================================
-- // ZOMBIE MAYHEM - ULTIMATE HACK (STABLE)
-- // ============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Karakter bekleme
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("✅ Karakter hazır:", Character.Name)

-- ============================================
-- OYUNCUYU ÖLÜMSÜZ YAP (GOD MODE)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
        wait(0.1)
    end
end)
print("🛡️ God Mode aktif")

-- ============================================
-- ANTI-AFK (DONMAYI ENGELLE)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            -- Karakteri hafif hareket ettir (donmayı engeller)
            if RootPart then
                RootPart.Velocity = Vector3.new(0, 0.1, 0)
            end
        end)
        wait(5)
    end
end)
print("🔄 Anti-AFK aktif")

-- ============================================
-- REMOTE BULUCU
-- ============================================
local KillRemote = nil
local MoneyRemote = nil

for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local name = v.Name:lower()
        
        if not KillRemote then
            if name:find("kill") or name:find("zombie") or name:find("death") then
                KillRemote = v
            end
        end
        
        if not MoneyRemote then
            if name:find("cash") or name:find("money") or name:find("coin") or 
               name:find("gem") or name:find("point") or name:find("reward") then
                MoneyRemote = v
            end
        end
    end
end

-- Eğer bulunamazsa tüm remoteları al
if not KillRemote then
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            KillRemote = v
            break
        end
    end
end

if not MoneyRemote then
    MoneyRemote = KillRemote -- Aynı remote'u kullan
end

print("🔫 Kill Remote:", KillRemote and KillRemote.Name or "YOK")
print("💰 Money Remote:", MoneyRemote and MoneyRemote.Name or "YOK")

-- ============================================
-- PARA DEĞERİ BUL
-- ============================================
local MoneyValue = nil

local function FindMoney()
    -- leaderstats
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                MoneyValue = v
                return v
            end
        end
    end
    
    -- Player
    for _, v in pairs(LocalPlayer:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local n = v.Name:lower()
            if n:find("cash") or n:find("money") or n:find("coin") or n:find("point") then
                MoneyValue = v
                return v
            end
        end
    end
    
    return nil
end

FindMoney()
print("💵 Para değeri:", MoneyValue and MoneyValue.Name or "BULUNAMADI")

-- ============================================
-- ZOMBİ BULMA
-- ============================================
local function GetZombies()
    local zombies = {}
    local myChar = Character
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar then
            -- Oyuncuları atla
            local isPlayer = false
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character == obj then
                    isPlayer = true
                    break
                end
            end
            if isPlayer then continue end
            
            -- Humanoid kontrolü
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(zombies, {
                    Model = obj,
                    Humanoid = hum,
                    RootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                })
            end
        end
    end
    
    return zombies
end

-- ============================================
-- ÖLDÜRME FONKSİYONU
-- ============================================
local function KillZombie(zombie)
    local model = zombie.Model
    local hum = zombie.Humanoid
    local root = zombie.RootPart
    
    -- Remote ile öldür
    if KillRemote then
        spawn(function()
            pcall(function()
                KillRemote:FireServer(model)
                KillRemote:FireServer(hum)
                if root then KillRemote:FireServer(root) end
            end)
        end)
    end
    
    if MoneyRemote and MoneyRemote ~= KillRemote then
        spawn(function()
            pcall(function()
                MoneyRemote:FireServer(model)
                MoneyRemote:FireServer(hum)
            end)
        end)
    end
    
    -- Direkt hasar
    spawn(function()
        pcall(function()
            hum.Health = 0
            hum:TakeDamage(99999)
        end)
    end)
    
    -- Parçala
    spawn(function()
        pcall(function()
            model:BreakJoints()
        end)
    end)
end

-- ============================================
-- PARA EKLEME
-- ============================================
local function AddMoney(amount)
    -- Direkt değer değiştirme
    if MoneyValue then
        pcall(function()
            MoneyValue.Value = MoneyValue.Value + amount
        end)
        return true
    end
    
    -- Remote ile ekleme
    if MoneyRemote then
        for i = 1, 100 do
            spawn(function()
                pcall(function()
                    MoneyRemote:FireServer(amount / 100)
                    MoneyRemote:FireServer(amount / 100, "Kill")
                    MoneyRemote:FireServer(amount / 100, "Zombie")
                end)
            end)
        end
        return true
    end
    
    -- Tüm değerleri dene
    for _, v in pairs(LocalPlayer:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            pcall(function()
                v.Value = v.Value + amount
            end)
            return true
        end
    end
    
    return false
end

-- ============================================
-- OTOMATİK ZOMBİ ÖLDÜRME (SÜREKLİ)
-- ============================================
local autoKill = false

spawn(function()
    while true do
        if autoKill then
            pcall(function()
                local zombies = GetZombies()
                for _, z in pairs(zombies) do
                    KillZombie(z)
                end
            end)
        end
        wait(0.5)
    end
end)

-- ============================================
-- GUI - TEMİZ VE BASİT
-- ============================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ZM_Hack"
ScreenGui.ResetOnSpawn = false

-- Ana Panel
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 180, 0, 210)
Panel.Position = UDim2.new(0.5, -90, 0.5, -105)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

-- Başlık
local Header = Instance.new("Frame", Panel)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderText = Instance.new("TextLabel", Header)
HeaderText.Size = UDim2.new(0.7, 0, 1, 0)
HeaderText.Position = UDim2.new(0.05, 0, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "🧟 HACK MENU"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 12
HeaderText.TextXAlignment = Enum.TextXAlignment.Left

-- Kapat
local X = Instance.new("TextButton", Header)
X.Size = UDim2.new(0, 22, 0, 22)
X.Position = UDim2.new(1, -25, 0, 4)
X.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
X.Text = "✕"
X.TextColor3 = Color3.fromRGB(255, 255, 255)
X.Font = Enum.Font.GothamBold
X.TextSize = 12
X.BorderSizePixel = 0
Instance.new("UICorner", X).CornerRadius = UDim.new(0, 5)
X.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Buton Alanı
local Buttons = Instance.new("Frame", Panel)
Buttons.Size = UDim2.new(1, -10, 1, -40)
Buttons.Position = UDim2.new(0, 5, 0, 35)
Buttons.BackgroundTransparency = 1

-- ============================================
-- BUTON 1: TÜM ZOMBİLERİ ÖLDÜR
-- ============================================
local Btn1 = Instance.new("TextButton", Buttons)
Btn1.Size = UDim2.new(1, 0, 0, 36)
Btn1.Position = UDim2.new(0, 0, 0, 0)
Btn1.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
Btn1.Text = "💀 TÜMÜNÜ ÖLDÜR"
Btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn1.Font = Enum.Font.GothamBold
Btn1.TextSize = 11
Btn1.BorderSizePixel = 0
Instance.new("UICorner", Btn1).CornerRadius = UDim.new(0, 6)

Btn1.MouseButton1Click:Connect(function()
    Btn1.Text = "⏳ Öldürülüyor..."
    Btn1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    spawn(function()
        local zombies = GetZombies()
        local count = #zombies
        
        for i, z in pairs(zombies) do
            KillZombie(z)
            if i % 20 == 0 then
                Btn1.Text = "⏳ " .. i .. "/" .. count
                wait()
            end
        end
        
        Btn1.Text = "✅ " .. count .. " ÖLDÜRÜLDÜ"
        Btn1.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        wait(2)
        Btn1.Text = "💀 TÜMÜNÜ ÖLDÜR"
        Btn1.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    end)
end)

-- ============================================
-- BUTON 2: OTOMATİK ÖLDÜR (AÇ/KAPA)
-- ============================================
local Btn2 = Instance.new("TextButton", Buttons)
Btn2.Size = UDim2.new(1, 0, 0, 36)
Btn2.Position = UDim2.new(0, 0, 0.22, 0)
Btn2.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
Btn2.Text = "🔄 OTO ÖLDÜR: KAPALI"
Btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn2.Font = Enum.Font.GothamBold
Btn2.TextSize = 11
Btn2.BorderSizePixel = 0
Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0, 6)

Btn2.MouseButton1Click:Connect(function()
    autoKill = not autoKill
    if autoKill then
        Btn2.Text = "🔄 OTO ÖLDÜR: AÇIK"
        Btn2.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        Btn2.Text = "🔄 OTO ÖLDÜR: KAPALI"
        Btn2.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end
end)

-- ============================================
-- BUTON 3: PARA EKLE
-- ============================================
local Btn3 = Instance.new("TextButton", Buttons)
Btn3.Size = UDim2.new(1, 0, 0, 36)
Btn3.Position = UDim2.new(0, 0, 0.44, 0)
Btn3.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Btn3.Text = "💰 +100K PARA"
Btn3.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn3.Font = Enum.Font.GothamBold
Btn3.TextSize = 11
Btn3.BorderSizePixel = 0
Instance.new("UICorner", Btn3).CornerRadius = UDim.new(0, 6)

Btn3.MouseButton1Click:Connect(function()
    Btn3.Text = "⏳ Ekleniyor..."
    Btn3.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    spawn(function()
        local success = AddMoney(100000)
        
        if success then
            Btn3.Text = "✅ +100K EKLENDİ"
            Btn3.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            Btn3.Text = "❌ BULUNAMADI"
            Btn3.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end
        
        wait(2)
        Btn3.Text = "💰 +100K PARA"
        Btn3.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
end)

-- ============================================
-- BUTON 4: 10K KİLL SİNYALİ
-- ============================================
local Btn4 = Instance.new("TextButton", Buttons)
Btn4.Size = UDim2.new(1, 0, 0, 36)
Btn4.Position = UDim2.new(0, 0, 0.66, 0)
Btn4.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
Btn4.Text = "📡 10K KİLL SİNYALİ"
Btn4.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn4.Font = Enum.Font.GothamBold
Btn4.TextSize = 11
Btn4.BorderSizePixel = 0
Instance.new("UICorner", Btn4).CornerRadius = UDim.new(0, 6)

Btn4.MouseButton1Click:Connect(function()
    Btn4.Text = "⏳ Gönderiliyor..."
    Btn4.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    spawn(function()
        local target = KillRemote or MoneyRemote
        if target then
            for i = 1, 10000 do
                spawn(function()
                    pcall(function()
                        target:FireServer()
                        target:FireServer("Kill")
                        target:FireServer("ZombieKilled")
                        target:FireServer(10)
                    end)
                end)
                if i % 500 == 0 then
                    Btn4.Text = "📡 " .. i .. "/10000"
                    wait(0.01)
                end
            end
            Btn4.Text = "✅ SİNYAL GÖNDERİLDİ"
            Btn4.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            Btn4.Text = "❌ REMOTE YOK"
            Btn4.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        
        wait(2)
        Btn4.Text = "📡 10K KİLL SİNYALİ"
        Btn4.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    end)
end)

-- ============================================
-- DURUM ÇUBUĞU
-- ============================================
local StatusBar = Instance.new("TextLabel", Panel)
StatusBar.Size = UDim2.new(1, 0, 0, 20)
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusBar.BackgroundTransparency = 0.3
StatusBar.Text = "✅ SİSTEM AKTİF | GOD MODE ON"
StatusBar.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusBar.Font = Enum.Font.Gotham
StatusBar.TextSize = 8

-- ============================================
-- BİLGİ YAZDIR
-- ============================================
print("╔══════════════════════════════╗")
print("║   ZOMBIE MAYHEM HACK v2.0   ║")
print("╠══════════════════════════════╣")
print("║ 🛡️ God Mode: AKTİF         ║")
print("║ 🔄 Anti-Donma: AKTİF       ║")
print("║ 🔫 Kill Remote: " .. (KillRemote and "VAR" or "YOK") .. "         ║")
print("║ 💰 Money Remote: " .. (MoneyRemote and "VAR" or "YOK") .. "       ║")
print("║ 💵 Money Value: " .. (MoneyValue and "VAR" or "YOK") .. "         ║")
print("║ 📋 4 Buton Hazır           ║")
print("╚══════════════════════════════╝")
