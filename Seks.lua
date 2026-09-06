-- ============================================================
-- PART 1: KEY GATE (Anahtar Kontrolü)
-- Bu scripti çalıştırın. Sadece key ekranı görünür.
-- Doğru key: OrospuErdem
-- Key doğru girilirse ekran kapanır ve konsola mesaj yazar:
-- "KEY DOĞRU! Şimdi Part 2 ve Part 3 scriptlerini çalıştırın."
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local KeyUI = nil

local function CreateKeyPrompt()
    if KeyUI then KeyUI:Destroy() end
    KeyUI = Instance.new("ScreenGui")
    KeyUI.Name = "KeyPrompt"
    KeyUI.Parent = CoreGui
    KeyUI.ResetOnSpawn = false
    KeyUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyUI.DisplayOrder = 999

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 130)
    frame.Position = UDim2.new(0.5, -125, 0.5, -65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = KeyUI
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "PLS ENTER YOUR KEY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.Position = UDim2.new(0, 10, 0, 40)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Key girin..."
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.Parent = frame
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 20)
    errorLabel.Position = UDim2.new(0, 0, 0, 75)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.Parent = frame

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(1, -20, 0, 30)
    confirmBtn.Position = UDim2.new(0, 10, 0, 95)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    confirmBtn.Text = "GİRİŞ"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.TextSize = 14
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.Parent = frame
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)

    local function checkKey()
        if inputBox.Text == "OrospuErdem" then
            pcall(function() KeyUI:Destroy() end)
            KeyUI = nil
            print("KEY DOĞRU! Şimdi Part 2 ve Part 3 scriptlerini çalıştırın.")
        else
            errorLabel.Text = "YANLIŞ KEY!"
            inputBox.Text = ""
            inputBox:CaptureFocus()
        end
    end

    confirmBtn.MouseButton1Click:Connect(checkKey)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkKey()
        end
    end)
end

CreateKeyPrompt()-- ============================================================
-- PART 2: ANA MODÜLLER
-- Eski modlar aynen korunmuştur, yeni modlar eklenmiştir.
-- Bu scripti Part 1'den sonra çalıştırın.
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

print("🔥 LEA BYPASS MOD YÜKLENİYOR...")

-- Mods tablosu (eski + yeni + ekstra)
local Mods = {
    Mevlana = false,
    Fly = false,
    InfiniteJump = false,
    HighJump = false,
    ESP = false,
    OneBulletThree = false,
    BrutalHitbox = false,
    SpeedHack = false,
    NoRecoil = false,
    AutoClick = false,
    WallBang = false,
    KillAura = false,
    Invisible = false,
    TeleportToPlayer = false,
    GodMode = false,
    Noclip = false,
    Aimbot = false,
    RapidFire = false,
    AntiVoid = false,
    XRay = false,
    InfiniteAmmo = false
}

local MevlanaSpeed = 30
local CurrentAngle = 0
local FlySpeed = 80
local SpeedMultiplier = 2.5
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local espObjects = {}

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
-- MEVLANA (360 DÖNÜŞ)
-- ============================================================
local function StartSpinning()
    if not Mods.Mevlana or not HumanoidRootPart then return end
    CurrentAngle = (CurrentAngle + MevlanaSpeed) % 360
    local pos = HumanoidRootPart.Position
    HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(CurrentAngle), 0)
end

-- ============================================================
-- FLY
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
-- ESP (duvar arkası görme)
-- ============================================================
local function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function BuildESP()
    ClearESP()
    if not Mods.ESP and not Mods.WallBang and not Mods.XRay then return end
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
    if Mods.ESP or Mods.WallBang or Mods.XRay then BuildESP() end
end)

-- ============================================================
-- 1 KURŞUN 3 KİŞİ (eski mod)
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
-- BRUTAL HITBOX (15x)
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
end

-- ============================================================
-- WALLBANG (duvarları geçen otomatik ateş)
-- ============================================================
local function WallBangFire()
    if not Mods.WallBang then return end
    local targets = GetTargets()
    if #targets == 0 then return end
    local sortedTargets = {}
    for _, plr in ipairs(targets) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            table.insert(sortedTargets, {plr = plr, dist = dist})
        end
    end
    table.sort(sortedTargets, function(a, b) return a.dist < b.dist end)
    local shootCount = math.min(3, #sortedTargets)
    for i = 1, shootCount do
        local target = sortedTargets[i].plr
        local targetChar = target.Character
        if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
            targetChar.Humanoid.Health = targetChar.Humanoid.Health - 30
            local beam = Instance.new("Beam")
            beam.Parent = Workspace.Terrain
            beam.Attachment0 = Instance.new("Attachment", HumanoidRootPart)
            beam.Attachment1 = Instance.new("Attachment", targetChar.HumanoidRootPart)
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            task.delay(0.1, function() beam:Destroy() end)
        end
    end
end

-- ============================================================
-- KILL AURA
-- ============================================================
local function KillAuraTick()
    if not Mods.KillAura then return end
    local targets = GetTargets()
    for _, plr in ipairs(targets) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if dist < 30 then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = hum.Health - 10
                end
            end
        end
    end
end

-- ============================================================
-- INVISIBLE
-- ============================================================
local function SetInvisible()
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = Mods.Invisible and 1 or 0
        end
    end
end

-- ============================================================
-- TELEPORT TO PLAYER (en yakın oyuncuya ışınlan)
-- ============================================================
local function TeleportToNearest()
    if not Mods.TeleportToPlayer then return end
    local targets = GetTargets()
    if #targets == 0 then return end
    local nearest = nil
    local minDist = math.huge
    for _, plr in ipairs(targets) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = plr
            end
        end
    end
    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ============================================================
-- GOD MODE (sürekli can yenile)
-- ============================================================
local function GodModeTick()
    if not Mods.GodMode then return end
    if Humanoid then
        Humanoid.Health = Humanoid.MaxHealth
    end
end

-- ============================================================
-- NOCLIP (duvarlardan geçme)
-- ============================================================
local function SetNoclip()
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not Mods.Noclip
        end
    end
end

-- ============================================================
-- AIMBOT (otomatik nişan alma - en yakın hedefin kafasına)
-- ============================================================
local function AimbotTick()
    if not Mods.Aimbot then return end
    local targets = GetTargets()
    if #targets == 0 then return end
    local nearest = nil
    local minDist = math.huge
    for _, plr in ipairs(targets) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local dist = (Camera.CFrame.Position - char.Head.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = plr
            end
        end
    end
    if nearest and nearest.Character then
        local head = nearest.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end

-- ============================================================
-- RAPID FIRE (bekleme süresini kaldır)
-- ============================================================
local function ApplyRapidFire()
    if not Character then return end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local cooldown = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("ReloadTime") or tool:FindFirstChild("FireRate")
            if cooldown then
                cooldown.Value = 0
            end
        end
    end
end

-- ============================================================
-- ANTI VOID (boşluğa düşersen yukarı ışınla)
-- ============================================================
local function AntiVoidTick()
    if not Mods.AntiVoid then return end
    if HumanoidRootPart and HumanoidRootPart.Position.Y < -50 then
        HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end

-- ============================================================
-- XRAY (duvarların arkasını gör - basit: parlak kutu)
-- ============================================================
-- ESP ile benzer, zaten BuildESP içinde XRay kontrolü var.
-- Ekstra bir şey yapmaya gerek yok.

-- ============================================================
-- INFINITE AMMO (mermi sayısını sıfırlama)
-- ============================================================
local function ApplyInfiniteAmmo()
    if not Mods.InfiniteAmmo then return end
    if not Character then return end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullets")
            if ammo and ammo:IsA("IntValue") then
                ammo.Value = 999
            end
        end
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
    if Mods.ESP or Mods.WallBang or Mods.XRay then BuildESP() end
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.SpeedHack then ApplySpeed() end
    if Mods.NoRecoil then ApplyNoRecoil() end
    if Mods.WallBang then WallBangFire() end
    if Mods.KillAura then KillAuraTick() end
    if Mods.TeleportToPlayer then TeleportToNearest() end
    if Mods.GodMode then GodModeTick() end
    if Mods.Invisible then SetInvisible() else SetInvisible() end
    if Mods.Noclip then SetNoclip() else SetNoclip() end
    if Mods.Aimbot then AimbotTick() end
    if Mods.RapidFire then ApplyRapidFire() end
    if Mods.AntiVoid then AntiVoidTick() end
    if Mods.InfiniteAmmo then ApplyInfiniteAmmo() end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    GetCharacter()
    if Mods.BrutalHitbox then SetBrutalHitbox() end
    if Mods.ESP or Mods.WallBang or Mods.XRay then BuildESP() end
    if Mods.Fly then EnableFly() end
    if Mods.SpeedHack then ApplySpeed() end
    if Mods.Invisible then SetInvisible() end
    if Mods.Noclip then SetNoclip() end
end)

print("Modüller hazır. Şimdi Part 3'ü çalıştırın.")-- ============================================================
-- PART 3: YENİ MENÜ SİSTEMİ
-- Eski menüleri temizlemez, sadece yeni menüyü oluşturur.
-- Part 2'den sonra çalıştırın.
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Mods tablosu ve diğer değişkenler Part 2'de tanımlıdır.
-- Burada sadece yeni menüyü oluşturacağız.
-- Eski menüleri silmiyoruz, sadece yeni menüyü oluşturuyoruz.
-- Eğer daha önce menü oluşturulduysa, tekrar oluşturmamak için bir kontrol ekleyelim.
if MenuGui and OpenButton then
    print("Menü zaten var, tekrar oluşturulmadı.")
    return
end

local function CreateNewMenu()
    -- Üstte açma butonu
    OpenButton = Instance.new("TextButton")
    OpenButton.Name = "LeaBypassOpen"
    OpenButton.Size = UDim2.new(0, 300, 0, 50)
    OpenButton.Position = UDim2.new(0.5, -150, 0, 10)
    OpenButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    OpenButton.Text = "LEA BYPASS AKTİF ANALARİNİ SİKEBİLİRSİNİZ"
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextSize = 14
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Parent = CoreGui
    OpenButton.ZIndex = 1000
    Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", OpenButton).Color = Color3.fromRGB(255, 0, 0)
    OpenButton.Visible = true

    -- Ana menü (başlangıçta kapalı)
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "LeaBypassMenu"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = false -- kapalı

    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MainMenu"
    menuFrame.Size = UDim2.new(0, 400, 0, 400)
    menuFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    menuFrame.BackgroundTransparency = 0.1
    menuFrame.Parent = MenuGui
    menuFrame.ZIndex = 1000
    Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 20)
    Instance.new("UIStroke", menuFrame).Color = Color3.fromRGB(255, 0, 0)

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔥 LEA BYPASS 🔥"
    title.TextColor3 = Color3.fromRGB(255, 255, 0)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBlack
    title.Parent = menuFrame

    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = menuFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function()
        MenuGui.Enabled = false
        OpenButton.Visible = true
    end)

    -- ScrollingFrame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    scroll.Parent = menuFrame
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 80, 0, 80)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.Parent = scroll

    -- Tüm modlar (eski + yeni + ekstra)
    local modList = {
        {name="Mevlana", emoji="🌀", modRef="Mevlana", color=Color3.fromRGB(0,150,200)},
        {name="Fly", emoji="✈️", modRef="Fly", color=Color3.fromRGB(0,200,100)},
        {name="InfJump", emoji="🦘", modRef="InfiniteJump", color=Color3.fromRGB(200,200,0)},
        {name="HighJump", emoji="📈", modRef="HighJump", color=Color3.fromRGB(255,150,0)},
        {name="ESP", emoji="👁️", modRef="ESP", color=Color3.fromRGB(0,255,0)},
        {name="1Bullet3", emoji="🔫", modRef="OneBulletThree", color=Color3.fromRGB(255,0,0)},
        {name="BrutalHB", emoji="💢", modRef="BrutalHitbox", color=Color3.fromRGB(255,80,80)},
        {name="Speed", emoji="⚡", modRef="SpeedHack", color=Color3.fromRGB(0,200,255)},
        {name="NoRecoil", emoji="🎯", modRef="NoRecoil", color=Color3.fromRGB(255,200,0)},
        {name="AutoClick", emoji="🖱️", modRef="AutoClick", color=Color3.fromRGB(255,100,200)},
        {name="WallBang", emoji="🧨", modRef="WallBang", color=Color3.fromRGB(255,0,255)},
        {name="KillAura", emoji="☠️", modRef="KillAura", color=Color3.fromRGB(255,0,0)},
        {name="Invisible", emoji="👻", modRef="Invisible", color=Color3.fromRGB(200,200,200)},
        {name="Teleport", emoji="🌀", modRef="TeleportToPlayer", color=Color3.fromRGB(0,255,255)},
        {name="GodMode", emoji="💪", modRef="GodMode", color=Color3.fromRGB(0,255,0)},
        {name="Noclip", emoji="🚀", modRef="Noclip", color=Color3.fromRGB(150,0,255)},
        {name="Aimbot", emoji="🎯", modRef="Aimbot", color=Color3.fromRGB(255,0,0)},
        {name="RapidFire", emoji="⚡", modRef="RapidFire", color=Color3.fromRGB(0,200,255)},
        {name="AntiVoid", emoji="🕳️", modRef="AntiVoid", color=Color3.fromRGB(200,200,0)},
        {name="XRay", emoji="🔦", modRef="XRay", color=Color3.fromRGB(0,255,255)},
        {name="InfAmmo", emoji="♾️", modRef="InfiniteAmmo", color=Color3.fromRGB(255,200,0)},
    }

    for _, modData in ipairs(modList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 80)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = modData.emoji
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 30
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        btn.ZIndex = 1001
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", btn).Color = modData.color

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 20)
        status.Position = UDim2.new(0, 0, 1, -20)
        status.BackgroundTransparency = 1
        status.Text = "KAPALI"
        status.TextColor3 = Color3.fromRGB(255,50,50)
        status.TextSize = 10
        status.Font = Enum.Font.GothamBold
        status.TextXAlignment = Enum.TextXAlignment.Center
        status.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 90, 0, 90)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 80, 0, 80)}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            Mods[modData.modRef] = not Mods[modData.modRef]
            local aktif = Mods[modData.modRef]
            if aktif then
                btn.BackgroundColor3 = modData.color
                status.Text = "AKTİF"
                status.TextColor3 = Color3.fromRGB(0,255,0)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                status.Text = "KAPALI"
                status.TextColor3 = Color3.fromRGB(255,50,50)
            end
            -- Moda özel tetikleyiciler
            if modData.modRef == "Fly" then
                if aktif then EnableFly() else DisableFly() end
            elseif modData.modRef == "HighJump" then
                if Humanoid then Humanoid.JumpPower = aktif and 150 or 50 end
            elseif modData.modRef == "ESP" or modData.modRef == "XRay" or modData.modRef == "WallBang" then
                if aktif then BuildESP() else ClearESP() end
            elseif modData.modRef == "Invisible" then
                SetInvisible()
            elseif modData.modRef == "Noclip" then
                SetNoclip()
            elseif modData.modRef == "TeleportToPlayer" then
                TeleportToNearest()
            elseif modData.modRef == "RapidFire" then
                ApplyRapidFire()
            elseif modData.modRef == "InfiniteAmmo" then
                ApplyInfiniteAmmo()
            end
        end)
    end

    -- Açılış animasyonu
    local function OpenMenu()
        MenuGui.Enabled = true
        OpenButton.Visible = false
        menuFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
        menuFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(menuFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 400), Position = UDim2.new(0.5, -200, 0.5, -200)})
        tween:Play()
    end

    OpenButton.MouseButton1Click:Connect(OpenMenu)
end

GetCharacter()
CreateNewMenu()

print("Menü hazır! Üstteki butona tıklayarak modları açabilirsiniz.")
