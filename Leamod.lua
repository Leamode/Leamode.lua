-- // ============================================
-- // PARÇA 1: Zombie Mayhem - Algılayıcı + Kill
-- // ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ============================================
-- ZOMBİ ALGILAYICI
-- ============================================
local ZombieDetector = {}

function ZombieDetector.IsPlayer(model)
    if not model then return true end
    
    -- Players servisi üzerinden kontrol
    local player = Players:GetPlayerFromCharacter(model)
    if player then return true end
    
    -- LocalPlayer karakteri mi?
    if model == LocalPlayer.Character then return true end
    
    -- Diğer oyuncu karakterleri
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    
    -- İsim eşleşmesi
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == model.Name then return true end
    end
    
    return false
end

function ZombieDetector.HasHumanoid(model)
    if not model then return false end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    
    return true
end

function ZombieDetector.HasHitbox(model)
    if not model then return false end
    
    local hitboxParts = {"Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
    
    for _, partName in ipairs(hitboxParts) do
        local part = model:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return true
        end
    end
    
    return false
end

function ZombieDetector.IsZombie(model)
    if not model then return false end
    if not model:IsA("Model") then return false end
    if ZombieDetector.IsPlayer(model) then return false end
    if not ZombieDetector.HasHumanoid(model) then return false end
    if not ZombieDetector.HasHitbox(model) then return false end
    
    -- İsim kontrolü
    local modelName = model.Name:lower()
    local zombieNames = {"zombie", "zombi", "undead", "walker", "infected", 
                         "enemy", "mob", "monster", "creature", "ghoul", 
                         "boss", "minion", "spawn", "npc"}
    
    for _, name in ipairs(zombieNames) do
        if modelName:find(name) then return true end
    end
    
    -- Klasör kontrolü
    local parent = model.Parent
    if parent then
        local parentName = parent.Name:lower()
        local enemyFolders = {"enemy", "zombie", "zombi", "mob", "npc", "spawn", "monster"}
        for _, folder in ipairs(enemyFolders) do
            if parentName:find(folder) then return true end
        end
    end
    
    -- Humanoid varsa ve RigType kontrolü
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RigType then
        return true
    end
    
    return false
end

function ZombieDetector.ScanAll()
    local zombies = {}
    local scanned = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            scanned = scanned + 1
            if ZombieDetector.IsZombie(obj) then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                table.insert(zombies, {
                    Model = obj,
                    Humanoid = humanoid,
                    Name = obj.Name,
                    Health = humanoid and humanoid.Health or 0
                })
            end
        end
    end
    
    return zombies, scanned
end

-- ============================================
-- REMOTE BULUCU
-- ============================================
local KillRemote = nil
local DamageRemote = nil
local MoneyRemote = nil

local function FindRemotes()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            
            if not KillRemote then
                if rName:find("kill") or rName:find("zombie") then
                    KillRemote = remote
                end
            end
            
            if not DamageRemote then
                if rName:find("damage") or rName:find("hit") or rName:find("shoot") then
                    DamageRemote = remote
                end
            end
            
            if not MoneyRemote then
                if rName:find("cash") or rName:find("money") or rName:find("coin") or 
                   rName:find("reward") or rName:find("point") then
                    MoneyRemote = remote
                end
            end
        end
    end
end

FindRemotes()

-- ============================================
-- BYPASS ÖLDÜRME
-- ============================================
local function BypassKillZombie(zombieData)
    local zombie = zombieData.Model
    local humanoid = zombieData.Humanoid
    
    -- Kill remote spam
    if KillRemote then
        for _ = 1, 5 do
            spawn(function()
                pcall(function()
                    KillRemote:FireServer(zombie)
                    KillRemote:FireServer(humanoid)
                    KillRemote:FireServer()
                end)
            end)
        end
    end
    
    -- Damage remote spam
    if DamageRemote then
        local hitPart = zombie:FindFirstChild("Head") or 
                       zombie:FindFirstChild("HumanoidRootPart") or
                       zombie:FindFirstChild("Torso")
        if hitPart then
            for _ = 1, 5 do
                spawn(function()
                    pcall(function()
                        DamageRemote:FireServer(hitPart, 9999999)
                    end)
                end)
            end
        end
    end
    
    -- Direkt öldür
    spawn(function()
        pcall(function()
            if humanoid then
                humanoid.Health = 0
                humanoid:TakeDamage(9999999)
            end
        end)
    end)
    
    spawn(function()
        pcall(function()
            zombie:BreakJoints()
        end)
    end)
end

-- ============================================
-- MİNİ MENÜ
-- ============================================
local Menu = Instance.new("ScreenGui")
Menu.Name = "ZM_KillMenu"
Menu.Parent = game:GetService("CoreGui")
Menu.ResetOnSpawn = false

local BG = Instance.new("Frame")
BG.Name = "MainFrame"
BG.Parent = Menu
BG.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
BG.BorderSizePixel = 0
BG.Position = UDim2.new(0.5, -85, 0.5, -100)
BG.Size = UDim2.new(0, 170, 0, 200)
BG.ClipsDescendants = true
BG.Active = true
BG.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = BG

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = BG
TitleBar.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 28)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "💀 Kill All"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -24, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Menu:Destroy()
end)

-- İçerik
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = BG
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 5, 0, 33)
Content.Size = UDim2.new(1, -10, 1, -38)

-- Zombi sayacı
local ZombieCount = Instance.new("TextLabel")
ZombieCount.Name = "ZombieCount"
ZombieCount.Parent = Content
ZombieCount.BackgroundTransparency = 1
ZombieCount.Size = UDim2.new(1, 0, 0, 16)
ZombieCount.Position = UDim2.new(0, 0, 0.02, 0)
ZombieCount.Font = Enum.Font.GothamBold
ZombieCount.Text = "🧟 Taranıyor..."
ZombieCount.TextColor3 = Color3.fromRGB(255, 200, 100)
ZombieCount.TextSize = 9

-- Buton
local KillBtn = Instance.new("TextButton")
KillBtn.Name = "KillBtn"
KillBtn.Parent = Content
KillBtn.Size = UDim2.new(1, 0, 0, 42)
KillBtn.Position = UDim2.new(0, 0, 0.18, 0)
KillBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
KillBtn.BorderSizePixel = 0
KillBtn.Font = Enum.Font.GothamBold
KillBtn.Text = "💀 TÜM ZOMBİLERİ ÖLDÜR"
KillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KillBtn.TextSize = 10
KillBtn.AutoButtonColor = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 7)
BtnCorner.Parent = KillBtn

-- Progress bar
local ProgressFrame = Instance.new("Frame")
ProgressFrame.Name = "ProgressFrame"
ProgressFrame.Parent = Content
ProgressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressFrame.BorderSizePixel = 0
ProgressFrame.Size = UDim2.new(1, 0, 0, 6)
ProgressFrame.Position = UDim2.new(0, 0, 0.52, 0)
ProgressFrame.Visible = false

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 3)
ProgressCorner.Parent = ProgressFrame

local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "Fill"
ProgressFill.Parent = ProgressFrame
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ProgressFill.BorderSizePixel = 0
ProgressFill.Size = UDim2.new(0, 0, 1, 0)

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 3)
FillCorner.Parent = ProgressFill

-- Durum
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Parent = Content
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 14)
StatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🟢 Sistem Hazır"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 9

-- ============================================
-- ZOMBİ SAYACI GÜNCELLEME
-- ============================================
spawn(function()
    while wait(2) do
        pcall(function()
            local zombies, scanned = ZombieDetector.ScanAll()
            if zombies and scanned then
                if #zombies > 0 then
                    ZombieCount.Text = "🧟 " .. #zombies .. " zombi bulundu"
                    ZombieCount.TextColor3 = Color3.fromRGB(255, 80, 80)
                else
                    ZombieCount.Text = "🧟 0 zombi | Temiz"
                    ZombieCount.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            end
        end)
    end
end)

-- ============================================
-- BUTON İŞLEVİ
-- ============================================
local isProcessing = false

KillBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end
    isProcessing = true
    
    local zombies, _ = ZombieDetector.ScanAll()
    
    if not zombies or #zombies == 0 then
        StatusLabel.Text = "⚠️ Zombi bulunamadı!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        wait(2)
        StatusLabel.Text = "🟢 Sistem Hazır"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        isProcessing = false
        return
    end
    
    KillBtn.Text = "💀 Öldürülüyor..."
    KillBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ProgressFrame.Visible = true
    StatusLabel.Text = "🔴 " .. #zombies .. " zombi tespit edildi"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    for i, zombieData in ipairs(zombies) do
        BypassKillZombie(zombieData)
        ProgressFill.Size = UDim2.new(i / #zombies, 0, 1, 0)
        
        if i % 10 == 0 then
            StatusLabel.Text = "🔴 " .. i .. "/" .. #zombies .. " öldürüldü"
            wait()
        end
    end
    
    wait(0.3)
    
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.Text = "✅ " .. #zombies .. " zombi öldürüldü!"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    KillBtn.Text = "✅ BAŞARILI!"
    KillBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    
    wait(2)
    ProgressFrame.Visible = false
    KillBtn.Text = "💀 TÜM ZOMBİLERİ ÖLDÜR"
    KillBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    StatusLabel.Text = "🟢 Sistem Hazır"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    isProcessing = false
end)

print("✅ Parça 1 yüklendi: Zombi Algılayıcı + Kill Sistemi")
print("   - Otomatik oyuncu/zombi ayırma")
print("   - Hitbox ve Humanoid kontrolü")
print("   - Canlı zombi sayacı")-- // ============================================
-- // PARÇA 2: Zombie Mayhem - Para + Sinyal
-- // ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- REMOTE BULUCU
-- ============================================
local KillRemote = nil
local MoneyRemote = nil

local function FindRemotes()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            
            if not KillRemote then
                if rName:find("kill") or rName:find("zombie") or rName:find("death") then
                    KillRemote = remote
                end
            end
            
            if not MoneyRemote then
                if rName:find("cash") or rName:find("money") or rName:find("coin") or 
                   rName:find("reward") or rName:find("point") or rName:find("gem") then
                    MoneyRemote = remote
                end
            end
        end
    end
    
    -- Eğer MoneyRemote bulunamadıysa tüm remote'ları yazdır
    if not MoneyRemote and not KillRemote then
        print("❌ Remote bulunamadı! Mevcut Remote'lar:")
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                print("   -", remote.Name, ":", remote.ClassName)
            end
        end
    end
end

FindRemotes()

-- ============================================
-- BYPASS FONKSİYONLARI
-- ============================================
local function BypassAddMoney(amount)
    if not MoneyRemote then return false end
    
    local formats = {
        {amount},
        {amount, "Kill"},
        {amount, "ZombieKilled"},
        {amount, 1},
        {amount, "Reward"},
        {[1] = amount, [2] = "Kill"},
        {cash = amount},
        {money = amount}
    }
    
    for _, args in ipairs(formats) do
        spawn(function()
            pcall(function()
                if type(args) == "table" then
                    MoneyRemote:FireServer(unpack(args))
                else
                    MoneyRemote:FireServer(args)
                end
            end)
        end)
    end
    
    return true
end

local function SendKillSignal(remote)
    if not remote then return false end
    
    local formats = {
        {},
        {"Kill"},
        {10},
        {"ZombieKilled"},
        {1, "Kill"},
        {10, 1}
    }
    
    for _, args in ipairs(formats) do
        spawn(function()
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end)
    end
    
    return true
end

-- ============================================
-- MİNİ MENÜ
-- ============================================
local Menu = Instance.new("ScreenGui")
Menu.Name = "ZM_MoneyMenu"
Menu.Parent = game:GetService("CoreGui")
Menu.ResetOnSpawn = false

local BG = Instance.new("Frame")
BG.Name = "MainFrame"
BG.Parent = Menu
BG.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
BG.BorderSizePixel = 0
BG.Position = UDim2.new(0.5, -85, 0.55, -80)
BG.Size = UDim2.new(0, 170, 0, 185)
BG.ClipsDescendants = true
BG.Active = true
BG.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = BG

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = BG
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 28)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "💰 Para Hack"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -24, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Menu:Destroy()
end)

-- İçerik
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = BG
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 5, 0, 33)
Content.Size = UDim2.new(1, -10, 1, -38)

-- Buton 1: Para
local MoneyBtn = Instance.new("TextButton")
MoneyBtn.Name = "MoneyBtn"
MoneyBtn.Parent = Content
MoneyBtn.Size = UDim2.new(1, 0, 0, 38)
MoneyBtn.Position = UDim2.new(0, 0, 0.05, 0)
MoneyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
MoneyBtn.BorderSizePixel = 0
MoneyBtn.Font = Enum.Font.GothamBold
MoneyBtn.Text = "💰 +100.000 PARA"
MoneyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MoneyBtn.TextSize = 11
MoneyBtn.AutoButtonColor = true

local Btn1Corner = Instance.new("UICorner")
Btn1Corner.CornerRadius = UDim.new(0, 7)
Btn1Corner.Parent = MoneyBtn

-- Buton 1 açıklama
local Desc1 = Instance.new("TextLabel")
Desc1.Name = "Desc1"
Desc1.Parent = Content
Desc1.BackgroundTransparency = 1
Desc1.Size = UDim2.new(1, 0, 0, 12)
Desc1.Position = UDim2.new(0, 0, 0.3, 0)
Desc1.Font = Enum.Font.Gotham
Desc1.Text = "Para remote bypass eder"
Desc1.TextColor3 = Color3.fromRGB(150, 255, 150)
Desc1.TextSize = 8

-- Buton 2: 10K Sinyal
local SignalBtn = Instance.new("TextButton")
SignalBtn.Name = "SignalBtn"
SignalBtn.Parent = Content
SignalBtn.Size = UDim2.new(1, 0, 0, 38)
SignalBtn.Position = UDim2.new(0, 0, 0.42, 0)
SignalBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
SignalBtn.BorderSizePixel = 0
SignalBtn.Font = Enum.Font.GothamBold
SignalBtn.Text = "📡 10K KİLL SİNYALİ"
SignalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SignalBtn.TextSize = 11
SignalBtn.AutoButtonColor = true

local Btn2Corner = Instance.new("UICorner")
Btn2Corner.CornerRadius = UDim.new(0, 7)
Btn2Corner.Parent = SignalBtn

-- Buton 2 açıklama
local Desc2 = Instance.new("TextLabel")
Desc2.Name = "Desc2"
Desc2.Parent = Content
Desc2.BackgroundTransparency = 1
Desc2.Size = UDim2.new(1, 0, 0, 12)
Desc2.Position = UDim2.new(0, 0, 0.67, 0)
Desc2.Font = Enum.Font.Gotham
Desc2.Text = "10bin zombi öldürme sinyali"
Desc2.TextColor3 = Color3.fromRGB(255, 200, 150)
Desc2.TextSize = 8

-- Progress bar
local ProgressFrame = Instance.new("Frame")
ProgressFrame.Name = "ProgressFrame"
ProgressFrame.Parent = Content
ProgressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressFrame.BorderSizePixel = 0
ProgressFrame.Size = UDim2.new(1, 0, 0, 5)
ProgressFrame.Position = UDim2.new(0, 0, 0.8, 0)
ProgressFrame.Visible = false

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 3)
ProgressCorner.Parent = ProgressFrame

local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "Fill"
ProgressFill.Parent = ProgressFrame
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ProgressFill.BorderSizePixel = 0
ProgressFill.Size = UDim2.new(0, 0, 1, 0)

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 3)
FillCorner.Parent = ProgressFill

-- Durum
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Parent = Content
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 14)
StatusLabel.Position = UDim2.new(0, 0, 0.88, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🟢 Hazır"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 9

-- ============================================
-- BUTON İŞLEVLERİ
-- ============================================
local isProcessing = false

-- Para Butonu
MoneyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end
    isProcessing = true
    
    MoneyBtn.Text = "💰 Ekleniyor..."
    MoneyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SignalBtn.Interactable = false
    ProgressFrame.Visible = true
    StatusLabel.Text = "💰 Para bypass başladı"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local targetRemote = MoneyRemote or KillRemote
    
    if targetRemote then
        for i = 1, 10000 do
            spawn(function()
                pcall(function()
                    if MoneyRemote then
                        BypassAddMoney(10)
                    else
                        SendKillSignal(targetRemote)
                    end
                end)
            end)
            
            if i % 500 == 0 then
                ProgressFill.Size = UDim2.new(i / 10000, 0, 1, 0)
                StatusLabel.Text = "💰 " .. (i * 10) .. " / 100.000"
                wait(0.01)
            end
        end
        
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)
        StatusLabel.Text = "✅ +100.000 para eklendi!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "❌ Remote bulunamadı!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    MoneyBtn.Text = "✅ BAŞARILI!"
    MoneyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    
    wait(2)
    ProgressFrame.Visible = false
    MoneyBtn.Text = "💰 +100.000 PARA"
    MoneyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    SignalBtn.Interactable = true
    StatusLabel.Text = "🟢 Hazır"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    isProcessing = false
end)

-- Sinyal Butonu (Tek seferlik)
SignalBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end
    isProcessing = true
    
    SignalBtn.Text = "📡 Gönderiliyor..."
    SignalBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MoneyBtn.Interactable = false
    ProgressFrame.Visible = true
    StatusLabel.Text = "📡 10K sinyal başladı"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local targetRemote = KillRemote or MoneyRemote
    
    if targetRemote then
        for i = 1, 10000 do
            spawn(function()
                pcall(function()
                    targetRemote:FireServer()
                    targetRemote:FireServer(10)
                    targetRemote:FireServer("Kill")
                    targetRemote:FireServer("ZombieKilled")
                end)
            end)
            
            if i % 500 == 0 then
                ProgressFill.Size = UDim2.new(i / 10000, 0, 1, 0)
                StatusLabel.Text = "📡 " .. i .. " / 10.000 sinyal"
                wait(0.01)
            end
        end
        
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)
        StatusLabel.Text = "✅ 10K sinyal gönderildi!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "❌ Remote bulunamadı!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    SignalBtn.Text = "✅ GÖNDERİLDİ!"
    SignalBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    
    wait(2)
    ProgressFrame.Visible = false
    SignalBtn.Text = "📡 10K KİLL SİNYALİ"
    SignalBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
    MoneyBtn.Interactable = true
    StatusLabel.Text = "🟢 Hazır"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    isProcessing = false
end)

print("✅ Parça 2 yüklendi: Para Bypass + 10K Sinyal")
print("   - Remote:", MoneyRemote and MoneyRemote.Name or KillRemote and KillRemote.Name or "YOK")
print("   - +100.000 Para bypass")
print("   - 10.000 Kill sinyali (tek seferlik)")
