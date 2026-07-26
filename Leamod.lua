-- // Zombie Mayhem - Kill All Zombies v1.0
-- // Sistem 1: Silahla vurmuş gibi algılatır
-- // Sistem 2: Direkt bypass ile öldürür

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ============================================
-- REMOTE BULUCU
-- ============================================
local KillRemote = nil
local DamageRemote = nil
local HitRemote = nil

local killNames = {"KillZombie", "ZombieKilled", "ZombieKill", "Kill", "ZombieDeath", "EnemyKilled", "MobKill"}
local damageNames = {"DamageZombie", "ZombieDamage", "DealDamage", "HitZombie", "ZombieHit", "ShootZombie", "WeaponHit"}
local hitNames = {"HitEvent", "ShootEvent", "BulletHit", "WeaponFire", "GunHit", "FireWeapon"}

for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local rName = remote.Name:lower()
        
        if not KillRemote then
            for _, name in ipairs(killNames) do
                if rName:find(name:lower()) then
                    KillRemote = remote
                    break
                end
            end
        end
        
        if not DamageRemote then
            for _, name in ipairs(damageNames) do
                if rName:find(name:lower()) then
                    DamageRemote = remote
                    break
                end
            end
        end
        
        if not HitRemote then
            for _, name in ipairs(hitNames) do
                if rName:find(name:lower()) then
                    HitRemote = remote
                    break
                end
            end
        end
    end
end

print("Bulunan Remote'lar:")
print("  Kill:", KillRemote and KillRemote.Name or "YOK")
print("  Damage:", DamageRemote and DamageRemote.Name or "YOK")
print("  Hit:", HitRemote and HitRemote.Name or "YOK")

if not KillRemote and not DamageRemote and not HitRemote then
    print("❌ Hiç remote bulunamadı! Mevcut remote'lar:")
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then print("  -", v.Name) end
    end
end

-- ============================================
-- ZOMBİ BULUCU
-- ============================================
local function FindAllZombies()
    local zombies = {}
    
    -- Workspace'te ara
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Zombi isimleri
                local modelName = obj.Name:lower()
                if modelName:find("zombie") or modelName:find("zombi") or 
                   modelName:find("enemy") or modelName:find("mob") or
                   modelName:find("undead") or modelName:find("monster") then
                    table.insert(zombies, obj)
                end
            end
        end
    end
    
    -- İsimle bulunamazsa tüm humanoid'li modelleri al
    if #zombies == 0 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and obj.Name ~= LocalPlayer.Character.Name then
                    table.insert(zombies, obj)
                end
            end
        end
    end
    
    return zombies
end

-- ============================================
-- SİSTEM 1: SİLAHLA VURMUŞ GİBİ ÖLDÜR
-- ============================================
local WeaponKill = {}

function WeaponKill:KillAll()
    local zombies = FindAllZombies()
    local killedCount = 0
    
    print("🔫 Sistem 1: Silah simülasyonu başladı -", #zombies, "zombi bulundu")
    
    for _, zombie in pairs(zombies) do
        spawn(function()
            local humanoid = zombie:FindFirstChild("Humanoid")
            local head = zombie:FindFirstChild("Head")
            local torso = zombie:FindFirstChild("Torso") or zombie:FindFirstChild("UpperTorso")
            local humanoidRootPart = zombie:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 then
                -- Silahla vurma simülasyonu
                local hitPart = head or torso or humanoidRootPart
                
                if hitPart then
                    -- Damage remote'una vurma sinyali
                    if DamageRemote then
                        for _ = 1, 5 do
                            spawn(function()
                                pcall(function()
                                    DamageRemote:FireServer(hitPart, 999999)
                                    DamageRemote:FireServer(zombie, 999999)
                                    DamageRemote:FireServer(humanoid, 999999)
                                end)
                            end)
                        end
                    end
                    
                    -- Hit remote'una vurma sinyali
                    if HitRemote then
                        for _ = 1, 5 do
                            spawn(function()
                                pcall(function()
                                    HitRemote:FireServer(hitPart)
                                    HitRemote:FireServer(zombie)
                                    HitRemote:FireServer(hitPart.Position)
                                end)
                            end)
                        end
                    end
                    
                    -- Kill remote'una öldürme sinyali
                    if KillRemote then
                        for _ = 1, 3 do
                            spawn(function()
                                pcall(function()
                                    KillRemote:FireServer(zombie)
                                    KillRemote:FireServer(humanoid)
                                    KillRemote:FireServer(hitPart)
                                end)
                            end)
                        end
                    end
                    
                    -- Direkt hasar ver
                    spawn(function()
                        pcall(function()
                            humanoid:TakeDamage(999999)
                            humanoid.Health = 0
                        end)
                    end)
                    
                    killedCount = killedCount + 1
                end
            end
        end)
    end
    
    wait(0.5)
    return killedCount
end

-- ============================================
-- SİSTEM 2: BYPASS İLE TOPLU ÖLDÜR
-- ============================================
local BypassKill = {}

function BypassKill:KillAll()
    local zombies = FindAllZombies()
    local killedCount = 0
    
    print("💀 Sistem 2: Bypass öldürme başladı -", #zombies, "zombi bulundu")
    
    -- Method 1: Tüm remote'lara flood
    if KillRemote or DamageRemote or HitRemote then
        local allRemotes = {}
        if KillRemote then table.insert(allRemotes, KillRemote) end
        if DamageRemote then table.insert(allRemotes, DamageRemote) end
        if HitRemote then table.insert(allRemotes, HitRemote) end
        
        for _, zombie in pairs(zombies) do
            spawn(function()
                local humanoid = zombie:FindFirstChild("Humanoid")
                local parts = {}
                for _, part in pairs(zombie:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(parts, part)
                    end
                end
                
                -- Her remote'a farklı formatlarda spam
                for _, remote in pairs(allRemotes) do
                    for _ = 1, 10 do
                        spawn(function()
                            pcall(function()
                                remote:FireServer(zombie)
                                remote:FireServer(humanoid)
                                remote:FireServer(parts[math.random(#parts)] or zombie)
                                remote:FireServer(999999)
                                remote:FireServer()
                            end)
                        end)
                    end
                end
                
                -- Direkt yok et
                spawn(function()
                    pcall(function()
                        if humanoid then
                            humanoid.Health = 0
                            humanoid:Destroy()
                        end
                        zombie:Destroy()
                    end)
                end)
                
                killedCount = killedCount + 1
            end)
        end
    end
    
    -- Method 2: Workspace'teki tüm zombileri yok et
    spawn(function()
        for _, zombie in pairs(zombies) do
            pcall(function()
                local humanoid = zombie:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                    humanoid.MaxHealth = 0
                end
                zombie:BreakJoints()
                zombie:Destroy()
            end)
        end
    end)
    
    -- Method 3: Tüm humanoid'leri bul ve öldür
    spawn(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 and 
               obj.Parent and obj.Parent ~= LocalPlayer.Character then
                pcall(function()
                    obj.Health = 0
                end)
            end
        end
    end)
    
    wait(0.3)
    return killedCount
end

-- ============================================
-- MİNİ MENÜ (Telefon Uyumlu)
-- ============================================
local Menu = Instance.new("ScreenGui", game.CoreGui)
Menu.Name = "ZM_KillMenu"
Menu.ResetOnSpawn = false
Menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Ana frame
local BG = Instance.new("Frame", Menu)
BG.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
BG.BackgroundTransparency = 0.05
BG.BorderSizePixel = 0
BG.Position = UDim2.new(0.5, -85, 0.55, 0)
BG.Size = UDim2.new(0, 170, 0, 185)
BG.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", BG)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Başlık
local TitleBar = Instance.new("Frame", BG)
TitleBar.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 26)

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "💀 Kill All"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Kapat
local Close = Instance.new("TextButton", TitleBar)
Close.Size = UDim2.new(0, 22, 0, 22)
Close.Position = UDim2.new(1, -24, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
Close.BorderSizePixel = 0
Close.Font = Enum.Font.GothamBold
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 11

local CloseCorner = Instance.new("UICorner", Close)
CloseCorner.CornerRadius = UDim.new(0, 5)

Close.MouseButton1Click:Connect(function()
    Menu:Destroy()
end)

-- İçerik
local Content = Instance.new("Frame", BG)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 5, 0, 32)
Content.Size = UDim2.new(1, -10, 1, -38)

-- Zombi sayacı
local ZombieCount = Instance.new("TextLabel", Content)
ZombieCount.BackgroundTransparency = 1
ZombieCount.Size = UDim2.new(1, 0, 0, 16)
ZombieCount.Position = UDim2.new(0, 0, 0, 0)
ZombieCount.Font = Enum.Font.Gotham
ZombieCount.Text = "🧟 Zombi: Taranıyor..."
ZombieCount.TextColor3 = Color3.fromRGB(200, 200, 200)
ZombieCount.TextSize = 9

-- ============================================
-- BUTON 1: SİLAH SİMÜLASYONU
-- ============================================
local Button1 = Instance.new("TextButton", Content)
Button1.Size = UDim2.new(1, 0, 0, 36)
Button1.Position = UDim2.new(0, 0, 0.15, 0)
Button1.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
Button1.BorderSizePixel = 0
Button1.Font = Enum.Font.GothamBold
Button1.Text = "🔫 SİLAHLA ÖLDÜR"
Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
Button1.TextSize = 11
Button1.AutoButtonColor = true

local Btn1Corner = Instance.new("UICorner", Button1)
Btn1Corner.CornerRadius = UDim.new(0, 7)

-- Buton 1 açıklama
local Desc1 = Instance.new("TextLabel", Content)
Desc1.BackgroundTransparency = 1
Desc1.Size = UDim2.new(1, 0, 0, 12)
Desc1.Position = UDim2.new(0, 0, 0.38, 0)
Desc1.Font = Enum.Font.Gotham
Desc1.Text = "Silahla vurmuş gibi algılatır"
Desc1.TextColor3 = Color3.fromRGB(150, 200, 255)
Desc1.TextSize = 7

-- ============================================
-- BUTON 2: BYPASS ÖLDÜR
-- ============================================
local Button2 = Instance.new("TextButton", Content)
Button2.Size = UDim2.new(1, 0, 0, 36)
Button2.Position = UDim2.new(0, 0, 0.48, 0)
Button2.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Button2.BorderSizePixel = 0
Button2.Font = Enum.Font.GothamBold
Button2.Text = "💀 BYPASS İLE ÖLDÜR"
Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
Button2.TextSize = 11
Button2.AutoButtonColor = true

local Btn2Corner = Instance.new("UICorner", Button2)
Btn2Corner.CornerRadius = UDim.new(0, 7)

-- Buton 2 açıklama
local Desc2 = Instance.new("TextLabel", Content)
Desc2.BackgroundTransparency = 1
Desc2.Size = UDim2.new(1, 0, 0, 12)
Desc2.Position = UDim2.new(0, 0, 0.71, 0)
Desc2.Font = Enum.Font.Gotham
Desc2.Text = "Direkt yok eder, anında ölür"
Desc2.TextColor3 = Color3.fromRGB(255, 150, 150)
Desc2.TextSize = 7

-- Durum
local StatusLabel = Instance.new("TextLabel", Content)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 14)
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🟢 Hazır"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 9

-- ============================================
-- ZOMBİ SAYACI GÜNCELLEME
-- ============================================
spawn(function()
    while wait(2) do
        local zombies = FindAllZombies()
        ZombieCount.Text = "🧟 Zombi: " .. #zombies .. " adet"
        if #zombies > 0 then
            ZombieCount.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            ZombieCount.TextColor3 = Color3.fromRGB(100, 255, 100)
            ZombieCount.Text = "🧟 Zombi: 0 (Temiz)"
        end
    end
end)

-- ============================================
-- BUTON İŞLEVLERİ
-- ============================================
local isKilling = false

local function KillAnimation(button, desc, systemType)
    if isKilling then return end
    isKilling = true
    
    button.Interactable = false
    StatusLabel.Text = "🔴 Öldürülüyor..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local killed = 0
    
    if systemType == 1 then
        killed = WeaponKill:KillAll()
    else
        killed = BypassKill:KillAll()
    end
    
    wait(0.5)
    
    -- Sonuç
    local remaining = #FindAllZombies()
    StatusLabel.Text = "✅ " .. killed .. " zombi öldü!"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    button.Text = "✅ BAŞARILI!"
    button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    
    wait(2)
    button.Text = systemType == 1 and "🔫 SİLAHLA ÖLDÜR" or "💀 BYPASS İLE ÖLDÜR"
    button.BackgroundColor3 = systemType == 1 and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(180, 0, 0)
    button.Interactable = true
    isKilling = false
end

Button1.MouseButton1Click:Connect(function()
    KillAnimation(Button1, Desc1, 1)
end)

Button2.MouseButton1Click:Connect(function()
    KillAnimation(Button2, Desc2, 2)
end)

-- ============================================
-- SÜRÜKLENEBİLİR MENÜ
-- ============================================
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = BG.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        BG.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================
-- BAŞLANGIÇ
-- ============================================
print("╔══════════════════════════════════╗")
print("║    💀 Zombie Mayhem Kill All    ║")
print("╠══════════════════════════════════╣")
print("║  🔫 Sistem 1: Silah Simülasyonu ║")
print("║  💀 Sistem 2: Bypass Öldürme    ║")
print("║  🧟 Otomatik zombi sayacı       ║")
print("║  📱 Telefon uyumlu mini menü    ║")
print("╚══════════════════════════════════╝")
