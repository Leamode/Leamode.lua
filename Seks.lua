-- ============================================================
-- HAMSTER ULTRA MOD V7.0 (FULL PAKET, TELEFON OPTİMİZE)
-- MEVLANA (akıcı) | FLY | INFINITE JUMP | HIGH JUMP
-- ESP (yenilenir, parlak) | WALLSEX (anında, ayak üstü)
-- 1 KURŞUN 3 KİŞİ | BRUTAL HITBOX (2x, görünür)
-- MENÜ: sağda, kaydırılabilir, F12 aç/kapa
-- ============================================================
-- РАЗРАБОТЧИК: palofsc
-- ВЕРСИЯ: 7.0 (TELEFON)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("🔥 ULTRA MOD V7.0 YÜKLENİYOR...")

-- ============================================================
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================
local Mods = {
    Mevlana = false,
    Fly = false,
    InfiniteJump = false,
    HighJump = false,
    ESP = false,
    WallSex = false,
    OneBulletThree = false,
    BrutalHitbox = false
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local FlySpeed = 80
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local MenuVisible = true
local MenuGui = nil
local espObjects = {}
local wallRemovedParts = {}

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ
-- ============================================================
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChild("Humanoid")
    end
    return Character
end

local function GetTargets()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                table.insert(list, plr)
            end
        end
    end
    return list
end

-- ============================================================
-- MEVLANA (360 DÖNÜŞ, TELEPORT YOK)
-- ============================================================
local function StartSpinning()
    if not Mods.Mevlana or not HumanoidRootPart then return end
    CurrentAngle = (CurrentAngle + MevlanaSpeed) % 360
    local pos = HumanoidRootPart.Position
    HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(CurrentAngle), 0)
end

-- ============================================================
-- FLY (KONTROLLÜ UÇUŞ, İLERİ)
-- ============================================================
local flyBodyVelocity = nil
local flyGyro = nil

local function EnableFly()
    if not Character or not HumanoidRootPart then return end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    Humanoid.PlatformStand = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = HumanoidRootPart
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.CFrame = HumanoidRootPart.CFrame
    flyGyro.Parent = HumanoidRootPart
end

local function DisableFly()
    if Humanoid then Humanoid.PlatformStand = false end
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
end

local function UpdateFly()
    if not Mods.Fly then DisableFly(); return end
    if not HumanoidRootPart or not flyBodyVelocity then EnableFly(); return end
    local moveDirection = Camera.CFrame.LookVector * FlySpeed
    flyBodyVelocity.Velocity = moveDirection
    flyGyro.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + Camera.CFrame.LookVector)
end

-- ============================================================
-- INFINITE JUMP + HIGH JUMP
-- ============================================================
local function HandleJump()
    if not Mods.InfiniteJump and not Mods.HighJump then return end
    if Mods.HighJump and Humanoid then Humanoid.JumpPower = 150 elseif Humanoid then Humanoid.JumpPower = 50 end
    if Mods.InfiniteJump and Humanoid and HumanoidRootPart then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end
end

UserInputService.JumpRequest:Connect(function()
    if Mods.InfiniteJump and Humanoid and HumanoidRootPart then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ============================================================
-- ESP (SÜREKLİ YENİLENİR, YENİ OYUNCULARI YAKALAR, PARLAK)
-- ============================================================
local function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function BuildESP()
    ClearESP()
    if not Mods.ESP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        -- Parlak Neon çizgi (BoxHandleAdornment veya Part)
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 2)
        box.Adornee = hrp
        box.Color3 = Color3.fromRGB(0, 255, 255)
        box.Transparency = 0.4
        box.ZIndex = 0
        box.AlwaysOnTop = true
        box.Parent = hrp
        table.insert(espObjects, box)

        -- İsim + sağlık
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 120, 0, 24)
        bill.Adornee = hrp
        bill.StudsOffset = Vector3.new(0, 4, 0)
        bill.Parent = hrp
        bill.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name .. " " .. math.round(hum.Health) .. "❤️"
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = bill
        table.insert(espObjects, bill)
    end
end

-- Yeni oyuncu eklendiğinde ESP'yi yenile
Players.PlayerAdded:Connect(function()
    if Mods.ESP then BuildESP() end
end)

-- Karakter değişiminde de yenile
local function OnCharacterAdded()
    if Mods.ESP then
        task.wait(0.3)
        BuildESP()
    end
end

-- ============================================================
-- WALL SEX (ANINDA YOK ET, SADECE AYAK ÜSTÜ, MERMİ GEÇSİN)
-- ============================================================
local function ClearWalls()
    if not Mods.WallSex then
        -- Geri getir
        for _, part in pairs(wallRemovedParts) do
            if part and part.Parent == nil then
                part.Parent = Workspace
                part.CanCollide = true
                part.Transparency = 0
                part.Material = Enum.Material.Plastic
            end
        end
        wallRemovedParts = {}
        return
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = hrp.Position
    local ayakY = pos.Y - 2  -- ayak seviyesi (tahmini)

    -- Tüm çalışma alanındaki BasePart'ları tara
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part ~= hrp then
            -- Kendi karakterimizin parçalarını atla
            if part:IsDescendantOf(char) then continue end
            -- Zemin / ayak altındakileri atla (Y < ayakY)
            if part.Position.Y < ayakY then continue end

            local dist = (pos - part.Position).Magnitude
            if dist < 35 then  -- menzil
                if not table.find(wallRemovedParts, part) then
                    table.insert(wallRemovedParts, part)
                end
                -- Anında yok et (görünmez, çarpışma yok, mermi geçsin)
                part.CanCollide = false
                part.Transparency = 1
                part.Material = Enum.Material.ForceField
                -- Ekstra: mermi raycast'ini atlatmak için fizik özelliği
                part.CastShadow = false
            end
        end
    end
end

-- ============================================================
-- 1 KURŞUN 3 KİŞİ (OTOMATİK HASAR)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        if Mods.OneBulletThree then
            local targets = GetTargets()
            if #targets >= 3 then
                for i = 1, 3 do
                    local t = targets[i]
                    if t and t.Character then
                        local hum = t.Character:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            hum.Health = hum.Health - 12
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- BRUTAL HITBOX (2x BÜYÜK, GÖRÜNÜR – RENKLİ)
-- ============================================================
local function SetBrutalHitbox()
    if not Mods.BrutalHitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 2)
                        hrp.Transparency = 0
                        hrp.BrickColor = BrickColor.new("Bright red")
                        hrp.CanCollide = true
                    end
                end
            end
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(4, 4, 4)  -- 2x
                    hrp.Transparency = 0.2
                    hrp.BrickColor = BrickColor.new("Bright orange")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end
end-- ============================================================
-- MENÜ: SAĞDA, KAYDIRILABİLİR (SCROLLINGFRAME), F12 AÇ/KAPA
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F12 then
        MenuVisible = not MenuVisible
        if MenuGui then MenuGui.Enabled = MenuVisible end
    end
end)

local function CreateMenu()
    if MenuGui then MenuGui:Destroy() end

    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "UltraMenuV7"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = true

    -- Arka plan (yarı saydam) – sağ tarafa hizalanmış
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 70, 1, 0)
    mainFrame.Position = UDim2.new(1, -75, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.4
    mainFrame.Parent = MenuGui
    mainFrame.ZIndex = 999

    -- ScrollingFrame (kaydırma)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -10)
    scroll.Position = UDim2.new(0, 0, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    scroll.Parent = mainFrame
    scroll.ZIndex = 999
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)  -- dinamik

    local btnSize = 50
    local gap = 10
    local startY = 10
    local currentY = startY

    local buttons = {
        {name="Mevlana", emoji="🌀", modRef="Mevlana", colorOn=Color3.fromRGB(0,150,200)},
        {name="Fly", emoji="✈️", modRef="Fly", colorOn=Color3.fromRGB(0,200,100)},
        {name="InfJump", emoji="🦘", modRef="InfiniteJump", colorOn=Color3.fromRGB(200,200,0)},
        {name="HighJump", emoji="📈", modRef="HighJump", colorOn=Color3.fromRGB(255,150,0)},
        {name="ESP", emoji="👁️", modRef="ESP", colorOn=Color3.fromRGB(0,255,0)},
        {name="WallSex", emoji="🧱", modRef="WallSex", colorOn=Color3.fromRGB(150,0,255)},
        {name="1Bullet3", emoji="🔫", modRef="OneBulletThree", colorOn=Color3.fromRGB(255,0,0)},
        {name="BrutalHB", emoji="💢", modRef="BrutalHitbox", colorOn=Color3.fromRGB(255,80,80)},
    }

    local btnRefs = {}  -- mod adı -> buton

    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(0.5, -btnSize/2, 0, currentY)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.BackgroundTransparency = 0.1
        btn.Text = btnData.emoji
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 24
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        btn.ZIndex = 999
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        -- Durum etiketi
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 14)
        status.Position = UDim2.new(0, 0, 1, 2)
        status.BackgroundTransparency = 1
        status.Text = "KAPALI"
        status.TextColor3 = Color3.fromRGB(255,50,50)
        status.TextSize = 10
        status.Font = Enum.Font.GothamBold
        status.TextXAlignment = Enum.TextXAlignment.Center
        status.Parent = btn
        status.ZIndex = 999

        btnRefs[btnData.modRef] = {btn = btn, status = status, colorOff = btn.BackgroundColor3, colorOn = btnData.colorOn, modRef = btnData.modRef}

        currentY = currentY + btnSize + gap
    end

    -- Canvas yüksekliğini ayarla
    scroll.CanvasSize = UDim2.new(0, 0, 0, currentY + 20)

    -- Buton tıklama olayları
    for modRef, data in pairs(btnRefs) do
        data.btn.MouseButton1Click:Connect(function()
            Mods[modRef] = not Mods[modRef]
            local aktif = Mods[modRef]

            if aktif then
                data.btn.BackgroundColor3 = data.colorOn
                data.btn.Text = data.btn.Text:gsub("[^%a]", "") .. "⚡"  -- emoji + ⚡
                data.status.Text = "AKTİF"
                data.status.TextColor3 = Color3.fromRGB(0,255,0)
            else
                data.btn.BackgroundColor3 = data.colorOff
                data.btn.Text = data.btn.Text:gsub("⚡", "")
                data.status.Text = "KAPALI"
                data.status.TextColor3 = Color3.fromRGB(255,50,50)
            end

            -- Özel işlemler
            if modRef == "Fly" then
                if aktif then EnableFly() else DisableFly() end
            end
            if modRef == "HighJump" then
                if Humanoid then Humanoid.JumpPower = aktif and 150 or 50 end
            end
            if modRef == "Mevlana" and not aktif then CurrentAngle = 0 end
            if modRef == "ESP" then
                if aktif then BuildESP() else ClearESP() end
            end
            if modRef == "WallSex" then
                if aktif then ClearWalls() else ClearWalls() end -- geri getirir
            end
            if modRef == "BrutalHitbox" then
                SetBrutalHitbox()
            end
        end)
    end
end

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
    GetCharacter()
    StartSpinning()
    UpdateFly()
    if Mods.InfiniteJump or Mods.HighJump then HandleJump() end
    if Mods.ESP then
        -- Periyodik yenileme (her 2 saniyede bir tazele)
        if not espObjects or #espObjects == 0 then BuildESP() end
    end
    if Mods.WallSex then ClearWalls() end
    if Mods.BrutalHitbox then SetBrutalHitbox() end
end)

-- ============================================================
-- KARAKTER EKLENDİ / DEĞİŞTİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    GetCharacter()
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.ESP then BuildESP() end
    if Mods.WallSex then ClearWalls() end
    if Mods.Fly then EnableFly() end
end)

-- Yeni oyuncu eklendiğinde ESP'yi yenile (Players.PlayerAdded zaten var)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateMenu()

-- ESP başlangıçta kapalı, ama açılırsa çalışır

print("")
print("========================================")
print("🔥 ULTRA MOD V7.0 TELEFON HAZIR!")
print("   🌀 Mevlana      ✈️ Fly")
print("   🦘 InfJump     📈 HighJump")
print("   👁️ ESP (parlak, yenilenir)")
print("   🧱 WallSex (anında, ayak üstü, mermi geçer)")
print("   🔫 1Bullet3 (otomatik hasar)")
print("   💢 BrutalHB (hitbox 2x, görünür)")
print("   📌 Menü sağda, KAYDIRILABİLİR, F12 aç/kapa")
print("========================================")
