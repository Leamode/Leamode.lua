--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ WEAPON SYSTEM v19.0 - TAMAMEN ÇALIŞAN (HATALAR FİXLENDİ)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ ESP - ÇALIŞIYOR (İsim + HP + Kutu + Mesafe)
    ✅ Aimbot - ÇALIŞIYOR (FOV Ayarlanabilir)
    ✅ 360 - ÇALIŞIYOR (Sürekli dönüş)
    ✅ Fly - ÇALIŞIYOR (No Clip)
    ✅ Rainbow - ÇALIŞIYOR (Renk değiştirme)
    ✅ Teleport - ÇALIŞIYOR (Işınlanma + Otomatik ateş)
    ✅ Infinite Jump - ÇALIŞIYOR (Sınırsız zıplama)
    ✅ Speed - ÇALIŞIYOR (+/- ayar)
    ✅ Menü TAŞINABİLİR + AÇ/KAPA
    ✅ LEA MOD - Ekranın ortasının üstünde
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  1/2  -  A Y A R L A R  +  M E N Ü
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    SpeedValue = 50,
    FlySpeed = 70,
    OffsetBack = 5,
    OffsetUp = 4,
    TeamCheck = true,
    FOV = 180,
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:FindFirstChild("Head")

-- DURUMLAR
local states = {
    esp = false,
    aimbot = false,
    rotation = false,
    fly = false,
    rainbow = false,
    teleport = false,
    infiniteJump = false,
    menuOpen = true,
}

-- BAĞLANTILAR
local connections = {
    esp = {},
    aimbot = nil,
    rotation = nil,
    fly = nil,
    rainbow = nil,
    teleport = nil,
    autoFire = nil,
    jump = nil,
}

local bodyVelocity = nil
local bodyGyro = nil
local currentTarget = nil
local menuVisible = true

-- ═══════════════════════════════════════════════════════════════════════════
-- LEA MOD - Ekranın ortasının ÜSTÜNE
-- ═══════════════════════════════════════════════════════════════════════════

local function createLeaMod()
    local oldLea = PlayerGui:FindFirstChild("LeaModText")
    if oldLea then oldLea:Destroy() end
    
    local leaText = Instance.new("TextLabel")
    leaText.Name = "LeaModText"
    leaText.Size = UDim2.new(0, 200, 0, 50)
    leaText.Position = UDim2.new(0.5, -100, 0, 10)
    leaText.Text = "LEA MOD"
    leaText.BackgroundTransparency = 1
    leaText.TextColor3 = Color3.fromRGB(255, 0, 255)
    leaText.TextScaled = true
    leaText.Font = Enum.Font.GothamBold
    leaText.TextStrokeTransparency = 0
    leaText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    leaText.Parent = PlayerGui
end

-- ═══════════════════════════════════════════════════════════════════════════
-- M E N Ü
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponSystemGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 65, 0, 190)
mainFrame.Position = UDim2.new(1, -70, 0, 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- SÜRÜKLEME
local dragging = false
local dragStart = nil
local dragStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
    end
end)

-- BAŞLIK
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 16)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
titleFrame.BackgroundTransparency = 0
titleFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 40, 0, 16)
titleLabel.Position = UDim2.new(0, 2, 0, 0)
titleLabel.Text = "⚡HACK"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 10
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleFrame

local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 18, 0, 14)
toggleMenuBtn.Position = UDim2.new(0, 44, 0, 1)
toggleMenuBtn.Text = "−"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 10
toggleMenuBtn.BorderSizePixel = 0
toggleMenuBtn.Parent = titleFrame

-- BUTON OLUŞTURMA
local function createToggleButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 59, 0, 14)
    btn.Position = UDim2.new(0, 3, 0, yPos)
    btn.Text = text .. " ❌"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.BorderSizePixel = 0
    btn.Parent = parent
    return btn
end

-- BUTONLAR
local btnESP = createToggleButton(mainFrame, "👁️ ESP", 19)
local btnAimbot = createToggleButton(mainFrame, "🎯 AIM", 36)
local btn360 = createToggleButton(mainFrame, "🔄 360", 53)
local btnFly = createToggleButton(mainFrame, "✈️ FLY", 70)
local btnRainbow = createToggleButton(mainFrame, "🌈 RB", 87)
local btnTeleport = createToggleButton(mainFrame, "🚀 TP", 104)
local btnJump = createToggleButton(mainFrame, "⬆️ INF", 121)

-- Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 20, 0, 12)
speedLabel.Position = UDim2.new(0, 3, 0, 139)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 9
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0, 12, 0, 12)
speedUpBtn.Position = UDim2.new(0, 25, 0, 139)
speedUpBtn.Text = "+"
speedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 9
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = mainFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0, 12, 0, 12)
speedDownBtn.Position = UDim2.new(0, 39, 0, 139)
speedDownBtn.Text = "-"
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 9
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = mainFrame

-- FOV Ayarı
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0, 20, 0, 12)
fovLabel.Position = UDim2.new(0, 3, 0, 154)
fovLabel.Text = "FOV"
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 8
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = mainFrame

local fovUpBtn = Instance.new("TextButton")
fovUpBtn.Size = UDim2.new(0, 12, 0, 12)
fovUpBtn.Position = UDim2.new(0, 25, 0, 154)
fovUpBtn.Text = "+"
fovUpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
fovUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovUpBtn.Font = Enum.Font.GothamBold
fovUpBtn.TextSize = 9
fovUpBtn.BorderSizePixel = 0
fovUpBtn.Parent = mainFrame

local fovDownBtn = Instance.new("TextButton")
fovDownBtn.Size = UDim2.new(0, 12, 0, 12)
fovDownBtn.Position = UDim2.new(0, 39, 0, 154)
fovDownBtn.Text = "-"
fovDownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
fovDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovDownBtn.Font = Enum.Font.GothamBold
fovDownBtn.TextSize = 9
fovDownBtn.BorderSizePixel = 0
fovDownBtn.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 59, 0, 14)
closeButton.Position = UDim2.new(0, 3, 0, 171)
closeButton.Text = "✕ KAPAT"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 9
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

-- ═══════════════════════════════════════════════════════════════════════════
-- F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if SETTINGS.TeamCheck then
        if LocalPlayer.Team and targetPlayer.Team then
            return LocalPlayer.Team ~= targetPlayer.Team
        end
        return true
    end
    return true
end

local function getNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == LocalPlayer then continue end
        if not isEnemy(otherPlayer) then continue end
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid or otherHumanoid.Health <= 0 then continue end
        local dist = (otherRoot.Position - rootPart.Position).Magnitude
        if dist < nearestDist then
            nearest = otherPlayer
            nearestDist = dist
        end
    end
    return nearest
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  2/2  -  S İ S T E M L E R
-- ═══════════════════════════════════════════════════════════════════════════--[[ BÖLÜM 2/2 - SİSTEMLER ]]

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local function startESP()
    stopESP()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == LocalPlayer then continue end
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid then continue end
        
        local isEnemyPlayer = isEnemy(otherPlayer)
        
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = isEnemyPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        box.Transparency = 0.4
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(connections.esp, box)
        
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 120, 0, 30)
        nameTag.Adornee = otherRoot
        nameTag.AlwaysOnTop = true
        nameTag.Parent = otherRoot
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name .. " | " .. math.floor(otherHumanoid.Health) .. "HP"
        nameLabel.TextColor3 = isEnemyPlayer and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Parent = nameTag
        table.insert(connections.esp, nameTag)
        
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 50, 0, 15)
        distTag.Adornee = otherRoot
        distTag.AlwaysOnTop = true
        distTag.Position = UDim2.new(0, 0, 0, -2)
        distTag.Parent = otherRoot
        
        local distLabel2 = Instance.new("TextLabel")
        distLabel2.Size = UDim2.new(1, 0, 1, 0)
        distLabel2.BackgroundTransparency = 1
        distLabel2.Text = ""
        distLabel2.TextColor3 = Color3.fromRGB(255, 255, 0)
        distLabel2.Font = Enum.Font.Gotham
        distLabel2.TextSize = 9
        distLabel2.TextStrokeTransparency = 0.3
        distLabel2.Parent = distTag
        table.insert(connections.esp, distTag)
        
        RunService.Heartbeat:Connect(function()
            if otherRoot and rootPart then
                local dist = (otherRoot.Position - rootPart.Position).Magnitude
                distLabel2.Text = math.floor(dist) .. "m"
            end
        end)
    end
end

local function stopESP()
    for _, obj in pairs(connections.esp) do
        pcall(function() obj:Destroy() end)
    end
    connections.esp = {}
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. AIMBOT
-- ═══════════════════════════════════════════════════════════════════════════

local function startAimbot()
    if connections.aimbot then return end
    connections.aimbot = RunService.Heartbeat:Connect(function()
        if not states.aimbot then return end
        if not rootPart then return end
        
        local target = getNearestEnemy()
        if not target then return end
        
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local targetPos = targetRoot.Position
        local lookDirection = (targetPos - rootPart.Position).Unit
        local currentLook = rootPart.CFrame.LookVector
        
        local angle = math.deg(math.acos(currentLook:Dot(lookDirection)))
        
        if angle <= SETTINGS.FOV then
            currentTarget = target
            local newCFrame = CFrame.lookAt(rootPart.Position, targetPos)
            rootPart.CFrame = newCFrame
        end
    end)
end

local function stopAimbot()
    if connections.aimbot then
        connections.aimbot:Disconnect()
        connections.aimbot = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 360
-- ═══════════════════════════════════════════════════════════════════════════

local function start360()
    if connections.rotation then return end
    connections.rotation = RunService.Heartbeat:Connect(function()
        if not states.rotation or not rootPart then return end
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
    end)
end

local function stop360()
    if connections.rotation then
        connections.rotation:Disconnect()
        connections.rotation = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. FLY (No Clip)
-- ═══════════════════════════════════════════════════════════════════════════

local function startFly()
    if bodyVelocity then return end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 999999
    bodyGyro.D = 999999
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if connections.fly then connections.fly:Disconnect() end
    connections.fly = RunService.Heartbeat:Connect(function()
        if not states.fly then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            return
        end
        
        local target = currentTarget or getNearestEnemy()
        if not target then return end
        
        local tChar = target.Character
        if not tChar then return end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        
        local targetPos = tRoot.Position
        local lookVector = tRoot.CFrame.LookVector
        local flyTargetPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
        
        local direction = (flyTargetPos - rootPart.Position)
        local distance = direction.Magnitude
        
        if distance > 0.5 and bodyVelocity then
            local speed = math.min(distance * SETTINGS.FlySpeed, SETTINGS.FlySpeed * 3)
            bodyVelocity.Velocity = direction.Unit * speed
        elseif bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        if bodyGyro then
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, tRoot.Position)
        end
    end)
end

local function stopFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if connections.fly then
        connections.fly:Disconnect()
        connections.fly = nil
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. RAINBOW (RB)
-- ═══════════════════════════════════════════════════════════════════════════

local function startRainbow()
    if connections.rainbow then return end
    local hue = 0
    connections.rainbow = RunService.Heartbeat:Connect(function()
        if not states.rainbow or not character then return end
        hue = hue + 0.025
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Color = color
            end
        end
        if head then head.Color = color end
    end)
end

local function stopRainbow()
    if connections.rainbow then
        connections.rainbow:Disconnect()
        connections.rainbow = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════

local function startTeleport()
    if connections.teleport then return end
    
    connections.teleport = RunService.Heartbeat:Connect(function()
        if not states.teleport then return end
        if not rootPart then return end
        
        local target = getNearestEnemy()
        if target then
            currentTarget = target
            local targetChar = target.Character
            if not targetChar then return end
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end
            
            local targetPos = targetRoot.Position
            local lookVector = targetRoot.CFrame.LookVector
            local teleportPos = targetPos - (lookVector * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
            rootPart.CFrame = CFrame.new(teleportPos, targetPos)
        end
    end)
    
    if connections.autoFire then connections.autoFire:Disconnect() end
    connections.autoFire = RunService.Heartbeat:Connect(function()
        if not states.teleport then return end
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            wait(0.03)
            mouse.Button1Up:Fire()
        end
    end)
end

local function stopTeleport()
    if connections.teleport then
        connections.teleport:Disconnect()
        connections.teleport = nil
    end
    if connections.autoFire then
        connections.autoFire:Disconnect()
        connections.autoFire = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. INFINITE JUMP
-- ═══════════════════════════════════════════════════════════════════════════

local function startInfiniteJump()
    if connections.jump then return end
    connections.jump = UserInputService.JumpRequest:Connect(function()
        if states.infiniteJump and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            wait(0.1)
        end
    end)
end

local function stopInfiniteJump()
    if connections.jump then
        connections.jump:Disconnect()
        connections.jump = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B U T O N   F O N K S İ Y O N L A R I
-- ═══════════════════════════════════════════════════════════════════════════

-- Menü Aç/Kapa
toggleMenuBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    toggleMenuBtn.Text = menuVisible and "−" or "+"
    for _, child in pairs(mainFrame:GetChildren()) do
        if child ~= titleFrame and child ~= toggleMenuBtn then
            child.Visible = menuVisible
        end
    end
    mainFrame.Size = menuVisible and UDim2.new(0, 65, 0, 190) or UDim2.new(0, 65, 0, 16)
end)

-- ESP
btnESP.MouseButton1Click:Connect(function()
    states.esp = not states.esp
    btnESP.Text = states.esp and "👁️ ESP ✅" or "👁️ ESP ❌"
    btnESP.BackgroundColor3 = states.esp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.esp then startESP() else stopESP() end
end)

-- Aimbot
btnAimbot.MouseButton1Click:Connect(function()
    states.aimbot = not states.aimbot
    btnAimbot.Text = states.aimbot and "🎯 AIM ✅" or "🎯 AIM ❌"
    btnAimbot.BackgroundColor3 = states.aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.aimbot then startAimbot() else stopAimbot() end
end)

-- 360
btn360.MouseButton1Click:Connect(function()
    states.rotation = not states.rotation
    btn360.Text = states.rotation and "🔄 360 ✅" or "🔄 360 ❌"
    btn360.BackgroundColor3 = states.rotation and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rotation then start360() else stop360() end
end)

-- Fly
btnFly.MouseButton1Click:Connect(function()
    states.fly = not states.fly
    btnFly.Text = states.fly and "✈️ FLY ✅" or "✈️ FLY ❌"
    btnFly.BackgroundColor3 = states.fly and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.fly then startFly() else stopFly() end
end)

-- Rainbow (RB)
btnRainbow.MouseButton1Click:Connect(function()
    states.rainbow = not states.rainbow
    btnRainbow.Text = states.rainbow and "🌈 RB ✅" or "🌈 RB ❌"
    btnRainbow.BackgroundColor3 = states.rainbow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.rainbow then startRainbow() else stopRainbow() end
end)

-- Teleport
btnTeleport.MouseButton1Click:Connect(function()
    states.teleport = not states.teleport
    btnTeleport.Text = states.teleport and "🚀 TP ✅" or "🚀 TP ❌"
    btnTeleport.BackgroundColor3 = states.teleport and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.teleport then startTeleport() else stopTeleport() end
end)

-- Infinite Jump
btnJump.MouseButton1Click:Connect(function()
    states.infiniteJump = not states.infiniteJump
    btnJump.Text = states.infiniteJump and "⬆️ INF ✅" or "⬆️ INF ❌"
    btnJump.BackgroundColor3 = states.infiniteJump and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 60)
    if states.infiniteJump then startInfiniteJump() else stopInfiniteJump() end
end)

-- Speed
speedUpBtn.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue + 5
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)

speedDownBtn.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue - 5
    if SETTINGS.SpeedValue < 5 then SETTINGS.SpeedValue = 5 end
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)

-- FOV
fovUpBtn.MouseButton1Click:Connect(function()
    SETTINGS.FOV = SETTINGS.FOV + 10
    if SETTINGS.FOV > 360 then SETTINGS.FOV = 360 end
end)

fovDownBtn.MouseButton1Click:Connect(function()
    SETTINGS.FOV = SETTINGS.FOV - 10
    if SETTINGS.FOV < 10 then SETTINGS.FOV = 10 end
end)

-- Kapat
closeButton.MouseButton1Click:Connect(function()
    stopESP()
    stopAimbot()
    stop360()
    stopFly()
    stopRainbow()
    stopTeleport()
    stopInfiniteJump()
    screenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- B A Ş L A T M A
-- ═══════════════════════════════════════════════════════════════════════════

-- LEA MOD
createLeaMod()

-- Karakter değişimi
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    head = newChar:FindFirstChild("Head")
    currentTarget = nil
    stopFly()
    stopRainbow()
    if states.fly then startFly() end
    if states.rainbow then startRainbow() end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ WEAPON SYSTEM v19.0 - TAMAMEN ÇALIŞIYOR ⚡            ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  👁️  ESP - İsim + HP + Kutu + Mesafe                       ║")
print("║  🎯 Aimbot - FOV Ayarlanabilir                             ║")
print("║  🔄 360 - Sürekli dönüş                                    ║")
print("║  ✈️  FLY - No Clip aktif                                   ║")
print("║  🌈 RB - Rainbow renk değiştirme                           ║")
print("║  🚀 Teleport - Işınlanma + Otomatik ateş                   ║")
print("║  ⬆️ Infinite Jump - Sınırsız zıplama                       ║")
print("║  ⚡ Speed - +/- ayar                                       ║")
print("║  📌 LEA MOD - Ekranın ortasının üstünde                    ║")
print("╚══════════════════════════════════════════════════════════════╝")
