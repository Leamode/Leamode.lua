--[[
    PART 1/2: TÜM ÖZEL FONKSİYONLAR - TELEFON OPTİMİZE
    Freeze, Unfreeze, Fling, Fly (dokunmatik), God, NoClip, ESP, Para Bulucu
    Hiçbir oyun remote'una bağlı değil.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local ActiveFeatures = {
    Fly = false,
    NoClip = false,
    God = false,
    ESP = false
}

-- === DOKUNMATİK FLY KONTROLLERİ ===
local FlySpeed = 50
local TouchControls = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

-- === FREEZE ===
local function freezePlayer(player)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true end
    end
end

local function unfreezePlayer(player)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = false end
    end
end

local function freezeAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then freezePlayer(p) end
    end
end

local function unfreezeAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then unfreezePlayer(p) end
    end
end

-- === FLING (En alta ışınlar/atar) ===
local function flingPlayer(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    hrp.Velocity = Vector3.new(math.random(-99999, 99999), math.random(99999, 199999), math.random(-99999, 99999))
    hrp.RotVelocity = Vector3.new(math.random(-999, 999), math.random(-999, 999), math.random(-999, 999))
    task.wait(0.5)
    hum.PlatformStand = false
end

-- === FLY (Dokunmatik butonlarla) ===
local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    ActiveFeatures.Fly = true
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not ActiveFeatures.Fly then conn:Disconnect(); hum.PlatformStand = false; return end
        
        local dir = Vector3.new(0, 0, 0)
        local cam = Workspace.CurrentCamera
        
        if TouchControls.Forward then dir += cam.CFrame.LookVector * FlySpeed end
        if TouchControls.Backward then dir += cam.CFrame.LookVector * -FlySpeed end
        if TouchControls.Left then dir += cam.CFrame.RightVector * -FlySpeed end
        if TouchControls.Right then dir += cam.CFrame.RightVector * FlySpeed end
        if TouchControls.Up then dir += Vector3.new(0, FlySpeed, 0) end
        if TouchControls.Down then dir += Vector3.new(0, -FlySpeed, 0) end
        
        hrp.Velocity = dir
    end)
end

local function stopFly()
    ActiveFeatures.Fly = false
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end

-- === NOCLIP ===
local function startNoClip()
    ActiveFeatures.NoClip = true
    local conn
    conn = RunService.Stepped:Connect(function()
        if not ActiveFeatures.NoClip then conn:Disconnect(); return end
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function stopNoClip()
    ActiveFeatures.NoClip = false
    local char = LP.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- === GOD MODE ===
local function startGod()
    ActiveFeatures.God = true
    local function apply(char)
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.BreakJointsOnDeath = false
        end
    end
    if LP.Character then apply(LP.Character) end
    LP.CharacterAdded:Connect(function(c) if ActiveFeatures.God then task.wait(0.1); apply(c) end end)
end

-- === ESP ===
local function startESP()
    ActiveFeatures.ESP = true
    local objects = {}
    
    spawn(function()
        while ActiveFeatures.ESP do
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                    if not objects[p] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = p.Character
                        objects[p] = hl
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0, 100, 0, 30)
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = p.Character.Head
                        
                        local lb = Instance.new("TextLabel")
                        lb.Size = UDim2.new(1, 0, 1, 0)
                        lb.BackgroundTransparency = 1
                        lb.TextColor3 = Color3.fromRGB(255, 255, 255)
                        lb.TextStrokeTransparency = 0
                        lb.Text = p.Name
                        lb.Font = Enum.Font.SourceSansBold
                        lb.TextSize = 12
                        lb.Parent = bg
                        
                        objects[p .. "_bg"] = bg
                    end
                end
            end
            task.wait(1)
        end
        
        for _, v in pairs(objects) do
            if v and v.Parent then v:Destroy() end
        end
    end)
end

-- === PARA SİSTEMİ BULUCU VE BYPASS ===
local function findAndExploitMoney()
    local moneyRemotes = {}
    local keywords = {"money","cash","coin","gold","gem","diamond","credit","point","balance","currency","buy","purchase","shop","store","add","give","set"}
    
    local function scan(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                local nm = child.Name:lower()
                local pn = child.Parent and child.Parent.Name:lower() or ""
                for _, kw in ipairs(keywords) do
                    if nm:find(kw) or pn:find(kw) then
                        table.insert(moneyRemotes, child)
                        break
                    end
                end
            end
            scan(child)
        end
    end
    scan(game)
    
    local payloads = {
        {"AddMoney", 99999999999},
        {"GiveMoney", LP.UserId, 99999999999},
        {"SetMoney", LP.UserId, 99999999999},
        {"AddCash", 99999999999},
        {"GiveCash", LP.UserId, 99999999999},
        {"AddCoins", 99999999999},
        {"GiveCoins", LP.UserId, 99999999999},
        {"AddGems", 99999999999},
        {"GiveGems", LP.UserId, 99999999999},
        {"AddBalance", LP.UserId, 99999999999},
        {LP.UserId, 99999999999, "Money"},
        {99999999999, LP.UserId},
        {"Add", "Money", 99999999999},
        {"Give", LP.UserId, "Money", 99999999999},
    }
    
    for _, remote in ipairs(moneyRemotes) do
        spawn(function()
            for _, payload in ipairs(payloads) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(payload))
                    else
                        remote:InvokeServer(unpack(payload))
                    end
                end)
                task.wait(0.005)
            end
        end)
    end
    
    return #moneyRemotes
end

-- PART 2'YE VERİ AKTAR
local env = getsenv and getsenv() or _G
env.__CUSTOM_ADMIN_DATA = {
    freezePlayer = freezePlayer,
    unfreezePlayer = unfreezePlayer,
    freezeAll = freezeAll,
    unfreezeAll = unfreezeAll,
    flingPlayer = flingPlayer,
    startFly = startFly,
    stopFly = stopFly,
    startNoClip = startNoClip,
    stopNoClip = stopNoClip,
    startGod = startGod,
    startESP = startESP,
    findAndExploitMoney = findAndExploitMoney,
    ActiveFeatures = ActiveFeatures,
    TouchControls = TouchControls
}

print("[PART 1] Telefon için tüm fonksiyonlar hazır")
print("[PART 1] Part 2'yi execute edin")--[[
    PART 2/2: TELEFON İÇİN TAM DOKUNMATİK MENÜ
    Part 1 çalıştıktan sonra execute edin.
    Büyük butonlar, dokunmatik fly kontrolü, oyuncu seçimi.
    Telefon ekranına tam uyumlu.
]]--

local env = getsenv and getsenv() or _G
local data = env.__CUSTOM_ADMIN_DATA
if not data then
    warn("[PART 2] Önce Part 1'i çalıştırın!")
    return
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local SelectedPlayer = nil
local MenuOpen = true

-- === ANA MENÜ ===
local gui = Instance.new("ScreenGui")
gui.Name = "PhoneAdmin"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(gui)
end

-- Ana panel - telefon ekranına uygun büyüklükte
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 420)
main.Position = UDim2.new(0.5, -140, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

-- Toggle buton (aç/kapa)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(1, -45, 0, 5)
toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Text = "✕"
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 20
toggle.BorderSizePixel = 0
toggle.ZIndex = 100
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggle

-- Başlık
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Text = "🔥 COOLER ADMIN"
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Kaydırılabilir içerik
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -48)
scroll.Position = UDim2.new(0, 6, 0, 44)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ScrollBarImageTransparency = 0.5
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.Parent = scroll

-- Seçili oyuncu göstergesi
local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, 0, 0, 32)
selectedLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
selectedLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
selectedLabel.Text = "🎯 Seçili: YOK"
selectedLabel.Font = Enum.Font.SourceSansBold
selectedLabel.TextSize = 13
selectedLabel.Parent = scroll

local selCorner = Instance.new("UICorner")
selCorner.CornerRadius = UDim.new(0, 6)
selCorner.Parent = selectedLabel

-- Oyuncu listesi başlığı
local playerHeader = Instance.new("TextLabel")
playerHeader.Size = UDim2.new(1, 0, 0, 20)
playerHeader.BackgroundTransparency = 1
playerHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
playerHeader.Text = "─ OYUNCULAR ─"
playerHeader.Font = Enum.Font.SourceSans
playerHeader.TextSize = 12
playerHeader.Parent = scroll

-- Oyuncu butonları
local playerButtons = {}

local function refreshPlayerList()
    for _, btn in ipairs(playerButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    playerButtons = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Text = "👤 " .. p.Name
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Parent = scroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = p
                selectedLabel.Text = "🎯 Seçili: " .. p.Name
                for _, b in ipairs(playerButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                end
                btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            end)
            
            btn.TouchTap:Connect(function()
                SelectedPlayer = p
                selectedLabel.Text = "🎯 Seçili: " .. p.Name
                for _, b in ipairs(playerButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                end
                btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            end)
            
            table.insert(playerButtons, btn)
        end
    end
end

refreshPlayerList()

-- Aksiyon başlığı
local actionHeader = Instance.new("TextLabel")
actionHeader.Size = UDim2.new(1, 0, 0, 20)
actionHeader.BackgroundTransparency = 1
actionHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
actionHeader.Text = "─ AKSİYONLAR ─"
actionHeader.Font = Enum.Font.SourceSans
actionHeader.TextSize = 12
actionHeader.Parent = scroll

-- Aksiyon butonları
local actions = {
    {"❄️ Freeze Seçili", function()
        if SelectedPlayer then data.freezePlayer(SelectedPlayer) end
    end},
    {"🔥 Unfreeze Seçili", function()
        if SelectedPlayer then data.unfreezePlayer(SelectedPlayer) end
    end},
    {"💨 Fling Seçili", function()
        if SelectedPlayer then data.flingPlayer(SelectedPlayer) end
    end},
    {"❄️❄️ Freeze HERKES", function()
        data.freezeAll()
    end},
    {"🔥🔥 Unfreeze HERKES", function()
        data.unfreezeAll()
    end},
}

for _, action in ipairs(actions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = action[1]
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = scroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        action[2]()
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.wait(0.2)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end)
    
    btn.TouchTap:Connect(function()
        action[2]()
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.wait(0.2)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end)
end

-- Özellik başlığı
local featHeader = Instance.new("TextLabel")
featHeader.Size = UDim2.new(1, 0, 0, 20)
featHeader.BackgroundTransparency = 1
featHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
featHeader.Text = "─ ÖZELLİKLER ─"
featHeader.Font = Enum.Font.SourceSans
featHeader.TextSize = 12
featHeader.Parent = scroll

-- Toggle özellikler
local features = {
    {"🦅 Fly", data.startFly, data.stopFly},
    {"🚶 NoClip", data.startNoClip, data.stopNoClip},
    {"🛡️ God Mode", data.startGod, nil},
    {"👁️ ESP", data.startESP, nil},
}

for _, feat in ipairs(features) do
    local isOn = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = feat[1] .. " ⚪"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = scroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local function toggleFeature()
        isOn = not isOn
        if isOn then
            btn.Text = feat[1] .. " 🟢"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            feat[2]()
        else
            btn.Text = feat[1] .. " ⚪"
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            if feat[3] then feat[3]() end
        end
    end
    
    btn.MouseButton1Click:Connect(toggleFeature)
    btn.TouchTap:Connect(toggleFeature)
end

-- === DOKUNMATİK FLY KONTROL BUTONLARI ===
local flyCtrlHeader = Instance.new("TextLabel")
flyCtrlHeader.Size = UDim2.new(1, 0, 0, 20)
flyCtrlHeader.BackgroundTransparency = 1
flyCtrlHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
flyCtrlHeader.Text = "─ FLY KONTROL (Dokunmatik) ─"
flyCtrlHeader.Font = Enum.Font.SourceSans
flyCtrlHeader.TextSize = 11
flyCtrlHeader.Parent = scroll

local function createFlyButton(text, position, controlKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.TouchTap:Connect(function()
        data.TouchControls[controlKey] = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        task.wait(0.3)
        data.TouchControls[controlKey] = false
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)
    
    btn.MouseButton1Down:Connect(function()
        data.TouchControls[controlKey] = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end)
    
    btn.MouseButton1Up:Connect(function()
        data.TouchControls[controlKey] = false
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)
    
    btn.TouchLongPress:Connect(function()
        data.TouchControls[controlKey] = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end)
    
    return btn
end

-- Fly kontrol grid'i
local flyGrid = Instance.new("Frame")
flyGrid.Size = UDim2.new(1, 0, 0, 170)
flyGrid.BackgroundTransparency = 1
flyGrid.Parent = scroll

-- İLERİ
local btnFwd = createFlyButton("▲", nil, "Forward")
btnFwd.Position = UDim2.new(0.5, -30, 0, 0)
btnFwd.Parent = flyGrid

-- SOL
local btnLeft = createFlyButton("◄", nil, "Left")
btnLeft.Position = UDim2.new(0.5, -95, 0, 55)
btnLeft.Parent = flyGrid

-- SAĞ
local btnRight = createFlyButton("►", nil, "Right")
btnRight.Position = UDim2.new(0.5, 35, 0, 55)
btnRight.Parent = flyGrid

-- GERİ
local btnBack = createFlyButton("▼", nil, "Backward")
btnBack.Position = UDim2.new(0.5, -30, 0, 110)
btnBack.Parent = flyGrid

-- YUKARI
local btnUp = createFlyButton("⬆", nil, "Up")
btnUp.Position = UDim2.new(0.5, -30, 0, 55)
btnUp.Parent = flyGrid

-- AŞAĞI (gizli tut, manuel)
local btnDown = Instance.new("TextButton")
btnDown.Size = UDim2.new(0, 60, 0, 50)
btnDown.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDown.Text = "⬇"
btnDown.Font = Enum.Font.SourceSansBold
btnDown.TextSize = 18
btnDown.BorderSizePixel = 0
btnDown.AutoButtonColor = false
btnDown.Position = UDim2.new(0.5, -30, 0, 55)
btnDown.Visible = false
btnDown.Parent = flyGrid

-- Para başlığı
local moneyHeader = Instance.new("TextLabel")
moneyHeader.Size = UDim2.new(1, 0, 0, 20)
moneyHeader.BackgroundTransparency = 1
moneyHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
moneyHeader.Text = "─ PARA ─"
moneyHeader.Font = Enum.Font.SourceSans
moneyHeader.TextSize = 12
moneyHeader.Parent = scroll

-- Para butonu
local moneyBtn = Instance.new("TextButton")
moneyBtn.Size = UDim2.new(1, 0, 0, 42)
moneyBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
moneyBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
moneyBtn.Text = "💰 SONSUZ PARA"
moneyBtn.Font = Enum.Font.SourceSansBold
moneyBtn.TextSize = 15
moneyBtn.BorderSizePixel = 0
moneyBtn.AutoButtonColor = false
moneyBtn.Parent = scroll

local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 6)
moneyCorner.Parent = moneyBtn

moneyBtn.TouchTap:Connect(function()
    moneyBtn.Text = "💰 TARANIYOR..."
    moneyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    local count = data.findAndExploitMoney()
    moneyBtn.Text = "💰 " .. count .. " remote"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    task.wait(2)
    moneyBtn.Text = "💰 SONSUZ PARA"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
end)

moneyBtn.MouseButton1Click:Connect(function()
    moneyBtn.Text = "💰 TARANIYOR..."
    moneyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    local count = data.findAndExploitMoney()
    moneyBtn.Text = "💰 " .. count .. " remote"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    task.wait(2)
    moneyBtn.Text = "💰 SONSUZ PARA"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
end)

-- Yenile butonu
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 36)
refreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.Text = "🔄 Listeyi Yenile"
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 13
refreshBtn.BorderSizePixel = 0
refreshBtn.AutoButtonColor = false
refreshBtn.Parent = scroll

local refCorner = Instance.new("UICorner")
refCorner.CornerRadius = UDim.new(0, 6)
refCorner.Parent = refreshBtn

refreshBtn.TouchTap:Connect(function()
    refreshPlayerList()
    if SelectedPlayer and not SelectedPlayer.Parent then
        SelectedPlayer = nil
        selectedLabel.Text = "🎯 Seçili: YOK"
    end
end)

refreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    if SelectedPlayer and not SelectedPlayer.Parent then
        SelectedPlayer = nil
        selectedLabel.Text = "🎯 Seçili: YOK"
    end
end)

-- Aç/kapa mantığı
local visible = true

toggle.TouchTap:Connect(function()
    visible = not visible
    if visible then
        main.Size = UDim2.new(0, 280, 0, 420)
        main.Position = UDim2.new(0.5, -140, 0.5, -210)
        titleBar.Visible = true
        scroll.Visible = true
        toggle.Text = "✕"
        toggle.Position = UDim2.new(1, -45, 0, 5)
    else
        main.Size = UDim2.new(0, 50, 0, 50)
        main.Position = UDim2.new(1, -60, 0, 10)
        titleBar.Visible = false
        scroll.Visible = false
        toggle.Text = "☰"
        toggle.Position = UDim2.new(0, 5, 0, 5)
    end
end)

toggle.MouseButton1Click:Connect(function()
    visible = not visible
    if visible then
        main.Size = UDim2.new(0, 280, 0, 420)
        main.Position = UDim2.new(0.5, -140, 0.5, -210)
        titleBar.Visible = true
        scroll.Visible = true
        toggle.Text = "✕"
        toggle.Position = UDim2.new(1, -45, 0, 5)
    else
        main.Size = UDim2.new(0, 50, 0, 50)
        main.Position = UDim2.new(1, -60, 0, 10)
        titleBar.Visible = false
        scroll.Visible = false
        toggle.Text = "☰"
        toggle.Position = UDim2.new(0, 5, 0, 5)
    end
end)

-- Sürükleme (dokunmatik)
local drag = false
local dragStart = nil
local posStart = nil

local function startDrag(input)
    drag = true
    dragStart = input.Position
    posStart = main.Position
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startDrag(input)
    end
end)

toggle.InputBegan:Connect(function(input)
    if not visible then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input)
        end
    end
end)

UserInputService.TouchMoved:Connect(function(input, processed)
    if drag and dragStart then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and drag and dragStart then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    drag = false
    dragStart = nil
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
        dragStart = nil
    end
end)

print("══════════════════════════════════")
print("  TELEFON COOLER ADMIN HAZIR")
print("  Ekran ortasında kırmızı menü")
print("  Yeşil ✕ buton: Aç/Kapa")
print("  Başlıktan tutup sürükle")
print("  Fly: Dokunmatik butonlar")
print("══════════════════════════════════")
