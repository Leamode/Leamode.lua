-- ============================================================
-- HAMSTER ULTRA MOD V8.2 (TELEFON, KÜÇÜK MENÜ + ✕/⚙️)
-- ============================================================
-- РАЗРАБОТЧИК: palofsc
-- ВЕРСИЯ: 8.2
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("🔥 ULTRA MOD V8.2 YÜKLENİYOR...")

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
    BrutalHitbox = false,
    SpeedHack = false,
    NoRecoil = false,
    AutoClick = false
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local FlySpeed = 80
local SpeedMultiplier = 2.5
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local MenuVisible = true
local MenuGui = nil
local OpenButton = nil   -- sağ ortadaki açma butonu
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
-- FLY (KONTROLLÜ UÇUŞ)
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
-- SPEED HACK
-- ============================================================
local function ApplySpeed()
    if not Mods.SpeedHack then
        if Humanoid then Humanoid.WalkSpeed = 16 end
        return
    end
    if Humanoid then
        Humanoid.WalkSpeed = 16 * SpeedMultiplier
    end
end

-- ============================================================
-- NO RECOIL
-- ============================================================
local function ApplyNoRecoil()
    if not Mods.NoRecoil then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local recoil = tool:FindFirstChild("Recoil") or tool:FindFirstChild("CameraRecoil")
            if recoil then recoil:Destroy() end
        end
    end
end

-- ============================================================
-- AUTO CLICK
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if Mods.AutoClick then
            pcall(function()
                UserInputService:SetKeyDown(Enum.KeyCode.Button1)
                task.wait(0.02)
                UserInputService:SetKeyUp(Enum.KeyCode.Button1)
            end)
        end
    end
end)

-- ============================================================
-- ESP (parlak, yenilenir, yeni oyuncuları yakalar)
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

        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 2)
        box.Adornee = hrp
        box.Color3 = Color3.fromRGB(0, 255, 255)
        box.Transparency = 0.3
        box.ZIndex = 0
        box.AlwaysOnTop = true
        box.Parent = hrp
        table.insert(espObjects, box)

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

Players.PlayerAdded:Connect(function()
    if Mods.ESP then BuildESP() end
end)

-- ============================================================
-- WALL SEX (sadece ayak üstü, anında, mermi geçer)
-- ============================================================
local function ClearWalls()
    if not Mods.WallSex then
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
    local ayakY = pos.Y - 2.5

    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part ~= hrp then
            if part:IsDescendantOf(char) then continue end
            if part.Position.Y < ayakY then continue end
            local dist = (pos - part.Position).Magnitude
            if dist < 40 then
                if not table.find(wallRemovedParts, part) then
                    table.insert(wallRemovedParts, part)
                end
                part.CanCollide = false
                part.Transparency = 1
                part.Material = Enum.Material.ForceField
                part.CastShadow = false
            end
        end
    end
end

-- ============================================================
-- 1 KURŞUN 3 KİŞİ (GERÇEK: Mouse tıklamasında hasar)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Mods.OneBulletThree then
            local targets = GetTargets()
            if #targets >= 3 then
                for i = 1, 3 do
                    local t = targets[i]
                    if t and t.Character then
                        local hum = t.Character:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            hum.Health = hum.Health - 15
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- BRUTAL HITBOX (15 KAT BÜYÜK, GÖRÜNMEZ)
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
                        hrp.Material = Enum.Material.Plastic
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
                    hrp.Size = Vector3.new(2, 2, 2) * 15
                    hrp.Transparency = 1
                    hrp.BrickColor = BrickColor.new("Bright orange")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end
end-- ============================================================
-- MENÜ (sağda, kaydırılabilir, ✕ kapatır, F12 toggle)
-- ============================================================
local function CreateMenu()
    if MenuGui then MenuGui:Destroy() end

    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "UltraMenuV8"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = true

    -- Ana çerçeve (sağda, dar)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 65, 1, 0)
    mainFrame.Position = UDim2.new(1, -70, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.Parent = MenuGui
    mainFrame.ZIndex = 999

    -- ✕ KAPATMA BUTONU (sol üst)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(0, 4, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    closeBtn.ZIndex = 1000
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function()
        if MenuGui then
            MenuGui.Enabled = false
            if OpenButton then OpenButton.Visible = true end
        end
    end)

    -- ScrollingFrame (kaydırma)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -10)
    scroll.Position = UDim2.new(0, 0, 0, 30)  -- closeBtn'in altından başlasın
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    scroll.Parent = mainFrame
    scroll.ZIndex = 999
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local btnSize = 38
    local gap = 10
    local startY = 5
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
        {name="Speed", emoji="⚡", modRef="SpeedHack", colorOn=Color3.fromRGB(0,200,255)},
        {name="NoRecoil", emoji="🎯", modRef="NoRecoil", colorOn=Color3.fromRGB(255,200,0)},
        {name="AutoClick", emoji="🖱️", modRef="AutoClick", colorOn=Color3.fromRGB(255,100,200)},
    }

    local btnRefs = {}

    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(0.5, -btnSize/2, 0, currentY)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.BackgroundTransparency = 0.1
        btn.Text = btnData.emoji
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 20
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        btn.ZIndex = 999
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 12)
        status.Position = UDim2.new(0, 0, 1, 0)
        status.BackgroundTransparency = 1
        status.Text = "KAPALI"
        status.TextColor3 = Color3.fromRGB(255,50,50)
        status.TextSize = 9
        status.Font = Enum.Font.GothamBold
        status.TextXAlignment = Enum.TextXAlignment.Center
        status.Parent = btn
        status.ZIndex = 999

        btnRefs[btnData.modRef] = {
            btn = btn,
            status = status,
            colorOff = btn.BackgroundColor3,
            colorOn = btnData.colorOn,
            modRef = btnData.modRef,
            emoji = btnData.emoji
        }

        currentY = currentY + btnSize + gap
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, currentY + 20)

    -- Buton tıklama olayları
    for modRef, data in pairs(btnRefs) do
        data.btn.MouseButton1Click:Connect(function()
            Mods[modRef] = not Mods[modRef]
            local aktif = Mods[modRef]

            if aktif then
                data.btn.BackgroundColor3 = data.colorOn
                data.btn.Text = data.emoji .. "⚡"
                data.status.Text = "AKTİF"
                data.status.TextColor3 = Color3.fromRGB(0,255,0)
            else
                data.btn.BackgroundColor3 = data.colorOff
                data.btn.Text = data.emoji
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
                if aktif then ClearWalls() else ClearWalls() end
            end
            if modRef == "BrutalHitbox" then
                SetBrutalHitbox()
            end
            if modRef == "SpeedHack" then
                ApplySpeed()
            end
            if modRef == "NoRecoil" then
                ApplyNoRecoil()
            end
            if modRef == "AutoClick" then
                -- zaten spawn'da çalışıyor
            end
        end)
    end
end

-- ============================================================
-- AÇMA BUTONU (ekranın tam ortasının en sağında)
-- ============================================================
local function CreateOpenButton()
    if OpenButton then OpenButton:Destroy() end

    OpenButton = Instance.new("TextButton")
    OpenButton.Size = UDim2.new(0, 48, 0, 48)
    OpenButton.Position = UDim2.new(1, -54, 0.5, -24)  -- sağ kenar, dikey orta
    OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    OpenButton.Text = "⚙️"
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextSize = 24
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Parent = CoreGui
    OpenButton.ZIndex = 999
    Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
    OpenButton.Visible = false  -- başlangıçta gizli (menü açık)

    OpenButton.MouseButton1Click:Connect(function()
        if MenuGui then
            MenuGui.Enabled = true
            OpenButton.Visible = false
        end
    end)
end

-- ============================================================
-- F12 İLE MENÜ AÇ/KAPA
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F12 then
        if not MenuGui then return end
        MenuGui.Enabled = not MenuGui.Enabled
        if OpenButton then
            OpenButton.Visible = not MenuGui.Enabled
        end
    end
end)

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
    GetCharacter()
    StartSpinning()
    UpdateFly()
    if Mods.InfiniteJump or Mods.HighJump then HandleJump() end
    if Mods.ESP then
        if not espObjects or #espObjects == 0 then BuildESP() end
    end
    if Mods.WallSex then ClearWalls() end
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.SpeedHack then ApplySpeed() end
    if Mods.NoRecoil then ApplyNoRecoil() end
end)

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    GetCharacter()
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.ESP then BuildESP() end
    if Mods.WallSex then ClearWalls() end
    if Mods.Fly then EnableFly() end
    if Mods.SpeedHack then ApplySpeed() end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateMenu()
CreateOpenButton()  -- sağ ortada ⚙️ oluşur

print("")
print("========================================")
print("🔥 ULTRA MOD V8.2 TELEFON HAZIR!")
print("   🌀 Mevlana     ✈️ Fly")
print("   🦘 InfJump    📈 HighJump")
print("   👁️ ESP         🧱 WallSex (ayak üstü)")
print("   🔫 1Bullet3    💢 BrutalHB (15x, görünmez)")
print("   ⚡ Speed       🎯 NoRecoil")
print("   🖱️ AutoClick")
print("   📌 Menü sağda, ✕ kapatır, ⚙️ sağ ortada açar")
print("   📌 F12 toggle (aç/kapa)")
print("========================================")
