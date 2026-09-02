-- ============================================================
-- HAMSTER ULTRA MOD V6.1 (TELEFON İÇİN OPTİMİZE)
-- MEVLANA (akıcı 360, tplen yok) | FLY (kontrol edilebilir)
-- INFINITE JUMP | HIGH JUMP | ESP | WALL SEX (duvar silme)
-- 1 KURŞUN 3 KİŞİ | HITBOX 2x | MENU AÇ/KAPA (F12)
-- Buton aralığı 24px, tüm butonlar ekranın üst kısmında
-- ============================================================
-- РАЗРАБОТЧИК: palofsc
-- ВЕРСИЯ: 6.1 (TELEFON)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("🔥 ULTRA MOD V6.1 TELEFON BAŞLADI...")

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
    BrutalHitbox = false   -- 2x размер (mevcut)
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local FlySpeed = 80
local JumpPower = 50
local HitboxMultiplier = 2
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local MenuVisible = true
local MenuGui = nil

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
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
-- MEVLANA (АКИФЛЫ 360, ТЕЛЕПОРТ ОТСУТСТВУЕТ)
-- ============================================================
local function StartSpinning()
    if not Mods.Mevlana then return end
    if not HumanoidRootPart then return end
    CurrentAngle = (CurrentAngle + MevlanaSpeed) % 360
    local pos = HumanoidRootPart.Position
    HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(CurrentAngle), 0)
end

-- ============================================================
-- FLY (УПРАВЛЯЕМЫЙ, ТОЛЬКО ВПЕРЁД)
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
-- ESP (ЛИНИИ, ИМЕНА, ЗДОРОВЬЕ)
-- ============================================================
local espObjects = {}

local function CreateESP()
    if not Mods.ESP then
        for _, obj in pairs(espObjects) do if obj and obj.Parent then obj:Destroy() end end
        espObjects = {}
        return
    end
    for _, obj in pairs(espObjects) do if obj and obj.Parent then obj:Destroy() end end
    espObjects = {}
    for _, plr in ipairs(GetTargets()) do
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local line = Instance.new("Part")
            line.Size = Vector3.new(0.1, 0.1, 0.1)
            line.Anchored = true
            line.CanCollide = false
            line.Material = Enum.Material.Neon
            line.Color = Color3.fromRGB(255, 0, 0)
            line.Transparency = 0.5
            line.Parent = Workspace
            table.insert(espObjects, line)
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 100, 0, 20)
            bill.Adornee = hrp
            bill.Parent = hrp
            bill.StudsOffset = Vector3.new(0, 3, 0)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = plr.Name .. " | " .. math.round(char.Humanoid.Health)
            label.TextColor3 = Color3.fromRGB(0, 255, 0)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0.3
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.Parent = bill
            table.insert(espObjects, bill)
        end
    end
end

local function UpdateESP()
    if not Mods.ESP then return end
    local localPos = HumanoidRootPart and HumanoidRootPart.Position or Vector3.new(0,0,0)
    local idx = 1
    for _, plr in ipairs(GetTargets()) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and espObjects[idx] then
            local line = espObjects[idx]
            if line and line:IsA("Part") then
                local dist = (localPos - hrp.Position).Magnitude
                line.Size = Vector3.new(0.1, 0.1, dist)
                line.CFrame = CFrame.new(localPos, hrp.Position) * CFrame.new(0, 0, -dist/2)
            end
            idx = idx + 1
        end
    end
end

-- ============================================================
-- WALL SEX (УДАЛЕНИЕ СТЕН)
-- ============================================================
local wallRemovedParts = {}

local function ClearWalls()
    if not Mods.WallSex then
        for _, part in pairs(wallRemovedParts) do
            if part and part.Parent == nil then
                part.Parent = Workspace
                part.CanCollide = true
                part.Transparency = 0
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
    local radius = 30
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part ~= hrp then
            local partPos = part.Position
            if partPos.Y < pos.Y - 5 then continue end
            if part:IsDescendantOf(char) then continue end
            local dist = (pos - partPos).Magnitude
            if dist < radius then
                if not table.find(wallRemovedParts, part) then
                    table.insert(wallRemovedParts, part)
                end
                part.CanCollide = false
                part.Transparency = 0.8
                part.Material = Enum.Material.ForceField
            end
        end
    end
end

-- ============================================================
-- 1 KURŞUN 3 KİŞİ (ЦЕПНАЯ РЕАКЦИЯ)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(2)
        if Mods.OneBulletThree then
            local targets = GetTargets()
            if #targets >= 3 then
                for i=1, 3 do
                    local t = targets[i]
                    if t and t.Character and t.Character:FindFirstChild("Humanoid") then
                        local hum = t.Character.Humanoid
                        if hum.Health > 0 then
                            hum.Health = hum.Health - 10
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- BRUTAL HITBOX (2x БОЛЬШЕ) - MEVCUT
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
                    hrp.Size = Vector3.new(2, 2, 2) * HitboxMultiplier
                    hrp.Transparency = 0.5
                    hrp.CanCollide = false
                end
            end
        end
    end
end

-- ============================================================
-- MENU AÇ/KAPA (F12 TOGGLE)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F12 then
        MenuVisible = not MenuVisible
        if MenuGui then MenuGui.Enabled = MenuVisible end
    end
end)

-- ============================================================
-- MENU OLUŞTURMA (TELEFON İÇİN OPTİMİZE: aralık 24px)
-- ============================================================
local function CreateMenu()
    if MenuGui then MenuGui:Destroy() end
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "UltraMenuV6"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = true

    local btnY = 2          -- daha yukarı
    local btnGap = 24       -- YARIYA İNDİ (eski 48)
    local btnSize = 36      -- biraz küçültüldü
    local xPos = -45

    local buttons = {
        {name="Mevlana", emoji="🌀", modRef="Mevlana", colorOn=Color3.fromRGB(0,150,200), colorOff=Color3.fromRGB(0,0,0)},
        {name="Fly", emoji="✈️", modRef="Fly", colorOn=Color3.fromRGB(0,200,100), colorOff=Color3.fromRGB(0,0,0)},
        {name="InfJump", emoji="🦘", modRef="InfiniteJump", colorOn=Color3.fromRGB(200,200,0), colorOff=Color3.fromRGB(0,0,0)},
        {name="HighJump", emoji="📈", modRef="HighJump", colorOn=Color3.fromRGB(255,150,0), colorOff=Color3.fromRGB(0,0,0)},
        {name="ESP", emoji="👁️", modRef="ESP", colorOn=Color3.fromRGB(0,255,0), colorOff=Color3.fromRGB(0,0,0)},
        {name="WallSex", emoji="🧱", modRef="WallSex", colorOn=Color3.fromRGB(150,0,255), colorOff=Color3.fromRGB(0,0,0)},
        {name="1Bullet3", emoji="🔫", modRef="OneBulletThree", colorOn=Color3.fromRGB(255,0,0), colorOff=Color3.fromRGB(0,0,0)},
        {name="BrutalHB", emoji="💢", modRef="BrutalHitbox", colorOn=Color3.fromRGB(255,50,50), colorOff=Color3.fromRGB(0,0,0)},
    }

    for i, btnData in ipairs(buttons) do
        local y = btnY + (i-1) * btnGap

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(1, xPos, 0, y)
        btn.BackgroundColor3 = btnData.colorOff
        btn.BackgroundTransparency = 0.2
        btn.Text = btnData.emoji
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 18
        btn.Font = Enum.Font.GothamBold
        btn.Parent = MenuGui
        btn.ZIndex = 999
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0, 45, 0, 12)
        status.Position = UDim2.new(1, xPos - 2, 0, y - 16)
        status.BackgroundTransparency = 1
        status.Text = "KAPALI"
        status.TextColor3 = Color3.fromRGB(255,50,50)
        status.TextSize = 6
        status.Font = Enum.Font.GothamBold
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = MenuGui
        status.ZIndex = 999

        btn.MouseButton1Click:Connect(function()
            local modName = btnData.modRef
            Mods[modName] = not Mods[modName]

            if Mods[modName] then
                btn.BackgroundColor3 = btnData.colorOn
                btn.Text = btnData.emoji .. "⚡"
                status.Text = "AKTİF"
                status.TextColor3 = Color3.fromRGB(0,255,0)
            else
                btn.BackgroundColor3 = btnData.colorOff
                btn.Text = btnData.emoji
                status.Text = "KAPALI"
                status.TextColor3 = Color3.fromRGB(255,50,50)
            end

            if modName == "Fly" and Mods.Fly then EnableFly()
            elseif modName == "Fly" and not Mods.Fly then DisableFly() end

            if modName == "HighJump" and Mods.HighJump then
                if Humanoid then Humanoid.JumpPower = 150 end
            elseif modName == "HighJump" and not Mods.HighJump then
                if Humanoid then Humanoid.JumpPower = 50 end
            end

            if modName == "Mevlana" and not Mods.Mevlana then CurrentAngle = 0 end
            if modName == "ESP" then CreateESP() end
            if modName == "WallSex" then ClearWalls() end
            if modName == "BrutalHitbox" then SetBrutalHitbox() end
        end)
    end
end

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
    GetCharacter()
    StartSpinning()
    if Mods.Fly then UpdateFly() else DisableFly() end
    if Mods.InfiniteJump or Mods.HighJump then HandleJump() end
    if Mods.ESP then UpdateESP() end
    if Mods.WallSex then ClearWalls() end
    if Mods.BrutalHitbox then SetBrutalHitbox() end
end)

-- ============================================================
-- KARAKTER DEĞİŞİMİ
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    GetCharacter()
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.ESP then CreateESP() end
    if Mods.WallSex then ClearWalls() end
    if Mods.Fly then EnableFly() end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
GetCharacter()
CreateMenu()

print("")
print("========================================")
print("🔥 ULTRA MOD V6.1 TELEFON HAZIR!")
print("   🌀 Mevlana (akıcı dönüş, tplen yok)")
print("   ✈️ Fly (kontrol edilebilir uçuş)")
print("   🦘 Infinite Jump (havada zıplama)")
print("   📈 High Jump (yüksek zıplama)")
print("   👁️ ESP (çizgi + isim + can)")
print("   🧱 WallSex (duvarları siler, mermi geçer)")
print("   🔫 1Bullet3 (1 mermi 3 kişi) - otomatik hasar")
print("   💢 BrutalHB (hitbox 2x büyük) - MEVCUT")
print("   📌 Menü: F12 AÇ/KAPA, buton aralığı 24px (telefon)")
print("========================================")
