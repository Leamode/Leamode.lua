--[[
    PART 1/2: TÜM FONKSİYONLAR
    Telefon için optimize. Freeze, Unfreeze, Fling, Fly, NoClip, God, ESP, Para.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local FlyEnabled = false
local NoClipEnabled = false
local GodEnabled = false
local ESPEnabled = false
local EspObjects = {}
local FlySpeed = 50

local FlyDir = {
    Forward = false, Backward = false, Left = false,
    Right = false, Up = false, Down = false
}

function freezePlayer(plr)
    local char = plr.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.Anchored = true end
    end
end

function unfreezePlayer(plr)
    local char = plr.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.Anchored = false end
    end
end

function freezeAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then freezePlayer(p) end
    end
end

function unfreezeAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then unfreezePlayer(p) end
    end
end

function flingPlayer(plr)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    hrp.Velocity = Vector3.new(math.random(-99999,99999), math.random(99999,199999), math.random(-99999,99999))
    hrp.RotVelocity = Vector3.new(math.random(-999,999), math.random(-999,999), math.random(-999,999))
    task.wait(0.5)
    hum.PlatformStand = false
end

function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    FlyEnabled = true
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then conn:Disconnect(); hum.PlatformStand = false; return end
        local dir = Vector3.new(0,0,0)
        local cam = Workspace.CurrentCamera
        if FlyDir.Forward then dir = dir + cam.CFrame.LookVector * FlySpeed end
        if FlyDir.Backward then dir = dir + cam.CFrame.LookVector * -FlySpeed end
        if FlyDir.Left then dir = dir + cam.CFrame.RightVector * -FlySpeed end
        if FlyDir.Right then dir = dir + cam.CFrame.RightVector * FlySpeed end
        if FlyDir.Up then dir = dir + Vector3.new(0, FlySpeed, 0) end
        if FlyDir.Down then dir = dir + Vector3.new(0, -FlySpeed, 0) end
        hrp.Velocity = dir
    end)
end

function stopFly()
    FlyEnabled = false
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0,0,0) end
    end
end

function startNoClip()
    NoClipEnabled = true
    local conn
    conn = RunService.Stepped:Connect(function()
        if not NoClipEnabled then conn:Disconnect(); return end
        local char = LP.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

function stopNoClip()
    NoClipEnabled = false
    local char = LP.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

function startGod()
    GodEnabled = true
    local function apply(c)
        local h = c:FindFirstChild("Humanoid")
        if h then h.MaxHealth = math.huge; h.Health = math.huge; h.BreakJointsOnDeath = false end
    end
    if LP.Character then apply(LP.Character) end
    LP.CharacterAdded:Connect(function(c) if GodEnabled then task.wait(0.1); apply(c) end end)
end

function startESP()
    ESPEnabled = true
    spawn(function()
        while ESPEnabled do
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and not EspObjects[p] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255,0,0)
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.5
                    hl.Parent = p.Character
                    EspObjects[p] = hl
                end
            end
            task.wait(1)
        end
        for _, v in pairs(EspObjects) do if v and v.Parent then v:Destroy() end end
        EspObjects = {}
    end)
end

function stopESP()
    ESPEnabled = false
end

function findMoney()
    local remotes = {}
    local function scan(p)
        for _, c in ipairs(p:GetChildren()) do
            if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then
                local nm = c.Name:lower()
                local pn = c.Parent and c.Parent.Name:lower() or ""
                local keys = {"money","cash","coin","gold","gem","diamond","credit","point","balance","currency","buy","purchase","shop","store","add","give","set"}
                for _, k in ipairs(keys) do
                    if nm:find(k) or pn:find(k) then table.insert(remotes, c); break end
                end
            end
            scan(c)
        end
    end
    scan(game)
    
    local payloads = {
        {"AddMoney",99999999999},{"GiveMoney",LP.UserId,99999999999},{"SetMoney",LP.UserId,99999999999},
        {"AddCash",99999999999},{"GiveCash",LP.UserId,99999999999},{"AddCoins",99999999999},
        {"GiveCoins",LP.UserId,99999999999},{"AddGems",99999999999},{"GiveGems",LP.UserId,99999999999},
        {"AddBalance",LP.UserId,99999999999},{LP.UserId,99999999999,"Money"},{99999999999,LP.UserId}
    }
    
    for _, r in ipairs(remotes) do
        spawn(function()
            for _, pl in ipairs(payloads) do
                pcall(function()
                    if r:IsA("RemoteEvent") then r:FireServer(unpack(pl))
                    else r:InvokeServer(unpack(pl)) end
                end)
                task.wait(0.005)
            end
        end)
    end
    return #remotes
end

-- PART 2'YE AKTAR
local env = getsenv and getsenv() or _G
env.__DATA = {
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
    stopESP = stopESP,
    findMoney = findMoney,
    FlyDir = FlyDir
}
print("[PART 1] Tamam. Part 2'yi çalıştır.")--[[
    PART 2/2: TELEFON MENÜSÜ
    Part 1'den sonra çalıştır.
]]--

local env = getsenv and getsenv() or _G
local d = env.__DATA
if not d then warn("Önce Part 1'i çalıştır!"); return end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

local SelectedPlayer = nil
local playerBtns = {}

local g = Instance.new("ScreenGui")
g.Name = "CoolerAdmin"
g.Parent = CoreGui
g.ResetOnSpawn = false
g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 450)
main.Position = UDim2.new(0.5, -150, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = g
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 44, 0, 44)
close.Position = UDim2.new(1, -50, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Text = "✕"
close.Font = Enum.Font.SourceSansBold
close.TextSize = 22
close.BorderSizePixel = 0
close.ZIndex = 10
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 12)

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
title.BorderSizePixel = 0
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

local titleTxt = Instance.new("TextLabel")
titleTxt.Size = UDim2.new(1, -60, 1, 0)
titleTxt.Position = UDim2.new(0, 14, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
titleTxt.Text = "🔥 COOLER ADMIN"
titleTxt.Font = Enum.Font.SourceSansBold
titleTxt.TextSize = 17
titleTxt.TextXAlignment = Enum.TextXAlignment.Left
titleTxt.Parent = title

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -14, 1, -54)
scroll.Position = UDim2.new(0, 7, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
scroll.ScrollBarImageTransparency = 0.4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = main

local lst = Instance.new("UIListLayout")
lst.Padding = UDim.new(0, 5)
lst.Parent = scroll

local totalH = 0

local selLabel = Instance.new("TextLabel")
selLabel.Size = UDim2.new(1, 0, 0, 34)
selLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
selLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
selLabel.Text = "🎯 Seçili: YOK"
selLabel.Font = Enum.Font.SourceSansBold
selLabel.TextSize = 14
selLabel.Parent = scroll
Instance.new("UICorner", selLabel).CornerRadius = UDim.new(0, 8)
totalH = totalH + 39

local ph = Instance.new("TextLabel")
ph.Size = UDim2.new(1, 0, 0, 20)
ph.BackgroundTransparency = 1
ph.TextColor3 = Color3.fromRGB(140, 140, 140)
ph.Text = "── OYUNCULAR ──"
ph.Font = Enum.Font.SourceSans
ph.TextSize = 12
ph.Parent = scroll
totalH = totalH + 25

local function refreshPlayers()
    for _, b in ipairs(playerBtns) do if b and b.Parent then b:Destroy() end end
    playerBtns = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 38)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            b.TextColor3 = Color3.fromRGB(230, 230, 230)
            b.Text = "👤  " .. p.Name
            b.Font = Enum.Font.SourceSansBold
            b.TextSize = 14
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Parent = scroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.Activated:Connect(function()
                SelectedPlayer = p
                selLabel.Text = "🎯 Seçili: " .. p.Name
                for _, bb in ipairs(playerBtns) do bb.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end
                b.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end)
            table.insert(playerBtns, b)
            totalH = totalH + 43
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, totalH + 60)
end

refreshPlayers()

local function addHeader(txt)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 20)
    h.BackgroundTransparency = 1
    h.TextColor3 = Color3.fromRGB(140, 140, 140)
    h.Text = txt
    h.Font = Enum.Font.SourceSans
    h.TextSize = 12
    h.Parent = scroll
    totalH = totalH + 25
end

local function addBtn(txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    b.TextColor3 = Color3.fromRGB(245, 245, 245)
    b.Text = txt
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 15
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(function()
        callback()
        b.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
        task.wait(0.2)
        b.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    end)
    totalH = totalH + 45
end

local function addToggle(txt, onStart, onStop)
    local isOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    b.TextColor3 = Color3.fromRGB(245, 245, 245)
    b.Text = txt .. "  ⚪"
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 15
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(function()
        isOn = not isOn
        if isOn then
            b.Text = txt .. "  🟢"
            b.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
            onStart()
        else
            b.Text = txt .. "  ⚪"
            b.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
            if onStop then onStop() end
        end
    end)
    totalH = totalH + 45
end

addHeader("── AKSİYONLAR ──")
addBtn("❄️  Freeze Seçili", function() if SelectedPlayer then d.freezePlayer(SelectedPlayer) end end)
addBtn("🔥  Unfreeze Seçili", function() if SelectedPlayer then d.unfreezePlayer(SelectedPlayer) end end)
addBtn("💨  Fling Seçili", function() if SelectedPlayer then d.flingPlayer(SelectedPlayer) end end)
addBtn("❄️❄️  Freeze HERKES", d.freezeAll)
addBtn("🔥🔥  Unfreeze HERKES", d.unfreezeAll)

addHeader("── ÖZELLİKLER ──")
addToggle("🦅  Fly", d.startFly, d.stopFly)
addToggle("🚶  NoClip", d.startNoClip, d.stopNoClip)
addToggle("🛡️  God Mode", d.startGod, nil)
addToggle("👁️  ESP", d.startESP, d.stopESP)

addHeader("── FLY KONTROL (Basılı Tut) ──")
local flyGrid = Instance.new("Frame")
flyGrid.Size = UDim2.new(1, 0, 0, 180)
flyGrid.BackgroundTransparency = 1
flyGrid.Parent = scroll
totalH = totalH + 185

local function makeFlyBtn(txt, posX, posY, dirKey)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 70, 0, 55)
    b.Position = UDim2.new(0.5, posX, 0, posY)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = txt
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 20
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = flyGrid
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.TouchStarted:Connect(function() d.FlyDir[dirKey] = true; b.BackgroundColor3 = Color3.fromRGB(0, 180, 0) end)
    b.TouchEnded:Connect(function() d.FlyDir[dirKey] = false; b.BackgroundColor3 = Color3.fromRGB(45, 45, 52) end)
    b.MouseButton1Down:Connect(function() d.FlyDir[dirKey] = true; b.BackgroundColor3 = Color3.fromRGB(0, 180, 0) end)
    b.MouseButton1Up:Connect(function() d.FlyDir[dirKey] = false; b.BackgroundColor3 = Color3.fromRGB(45, 45, 52) end)
end

makeFlyBtn("▲", -35, 0, "Forward")
makeFlyBtn("◄", -110, 60, "Left")
makeFlyBtn("►", 40, 60, "Right")
makeFlyBtn("▼", -35, 120, "Backward")
makeFlyBtn("⬆", -35, 60, "Up")
makeFlyBtn("⬇", 40, 0, "Down")

addHeader("── PARA ──")
local moneyBtn = Instance.new("TextButton")
moneyBtn.Size = UDim2.new(1, 0, 0, 44)
moneyBtn.BackgroundColor3 = Color3.fromRGB(240, 170, 0)
moneyBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
moneyBtn.Text = "💰  SONSUZ PARA"
moneyBtn.Font = Enum.Font.SourceSansBold
moneyBtn.TextSize = 16
moneyBtn.BorderSizePixel = 0
moneyBtn.AutoButtonColor = false
moneyBtn.Parent = scroll
Instance.new("UICorner", moneyBtn).CornerRadius = UDim.new(0, 8)
totalH = totalH + 49
moneyBtn.Activated:Connect(function()
    moneyBtn.Text = "⏳  TARANIYOR..."
    moneyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    local cnt = d.findMoney()
    moneyBtn.Text = "✅  " .. cnt .. " remote"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    task.wait(2)
    moneyBtn.Text = "💰  SONSUZ PARA"
    moneyBtn.BackgroundColor3 = Color3.fromRGB(240, 170, 0)
end)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 38)
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
refreshBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
refreshBtn.Text = "🔄  Listeyi Yenile"
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 14
refreshBtn.BorderSizePixel = 0
refreshBtn.AutoButtonColor = false
refreshBtn.Parent = scroll
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)
totalH = totalH + 43
refreshBtn.Activated:Connect(function()
    refreshPlayers()
    if SelectedPlayer and not SelectedPlayer.Parent then
        SelectedPlayer = nil
        selLabel.Text = "🎯 Seçili: YOK"
    end
end)

scroll.CanvasSize = UDim2.new(0, 0, 0, totalH + 60)

local isOpen = true
close.Activated:Connect(function()
    isOpen = not isOpen
    if isOpen then
        main.Size = UDim2.new(0, 300, 0, 450)
        main.Position = UDim2.new(0.5, -150, 0.5, -225)
        title.Visible = true
        scroll.Visible = true
        close.Text = "✕"
        close.Position = UDim2.new(1, -50, 0, 6)
    else
        main.Size = UDim2.new(0, 55, 0, 55)
        main.Position = UDim2.new(1, -65, 0, 10)
        title.Visible = false
        scroll.Visible = false
        close.Text = "☰"
        close.Position = UDim2.new(0, 8, 0, 8)
    end
end)

local dragging = false
local dragStart, panelStart = nil, nil

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    panelStart = main.Position
end

title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(i) end end)
close.InputBegan:Connect(function(i) if not isOpen and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then startDrag(i) end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and dragStart then
        local d = i.Position - dragStart
        main.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + d.X, panelStart.Y.Scale, panelStart.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.TouchEnded or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; dragStart = nil end
end)

StarterGui:SetCore("SendNotification", {Title = "COOLER ADMIN", Text = "Menü hazır!", Duration = 4})
print("[PART 2] Menü açıldı.")
