--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ WEAPON SYSTEM v22.0 - ÇALIŞAN AIMBOT (Axiom tarzı)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ Aimbot - Mouse ile hedefe kilit (Sağ tık basılı tut)
    ✅ FOV Circle - Ekranda hedefleme alanı
    ✅ ESP - İsim + HP + Kutu
    ✅ 360 - Sürekli dönüş
    ✅ FLY - Serbest uçuş (WASD + Space/Shift)
    ✅ Rainbow - Renk değiştirme
    ✅ Teleport - Işınlanma
    ✅ Infinite Jump - Sınırsız zıplama
    ✅ Speed - Hız ayarı
    ✅ LEA MOD - Ekranın ortasının üstünde
    ✅ Menü taşınabilir, aç/kapa
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  1/2  -  A Y A R L A R  +  M E N Ü  +  FLY
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local SETTINGS = {
    SpeedValue = 50,
    FlySpeed = 50,
    OffsetBack = 5,
    OffsetUp = 4,
    FOV = 250,
    Smoothness = 0.15,
    WallCheck = false,
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
}

-- BAĞLANTILAR
local connections = {}
local espObjects = {}
local bodyVelocity = nil
local bodyGyro = nil
local currentTarget = nil
local CamlockState = false

-- FLY KONTROLLERİ
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

-- ═══════════════════════════════════════════════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════════════════════════════════════════════

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Radius = SETTINGS.FOV
FOVCircle.Filled = false

-- ═══════════════════════════════════════════════════════════════════════════
-- LEA MOD
-- ═══════════════════════════════════════════════════════════════════════════

local function createLeaMod()
    local old = PlayerGui:FindFirstChild("LeaModText")
    if old then old:Destroy() end
    local txt = Instance.new("TextLabel")
    txt.Name = "LeaModText"
    txt.Size = UDim2.new(0, 200, 0, 50)
    txt.Position = UDim2.new(0.5, -100, 0, 10)
    txt.Text = "LEA MOD"
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 0, 255)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Parent = PlayerGui
end
createLeaMod()

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

-- Sürükleme
local dragging = false
local dragStart, dragStartPos
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

-- Başlık
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 16)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 18, 0, 14)
toggleBtn.Position = UDim2.new(0, 44, 0, 1)
toggleBtn.Text = "−"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 10
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = titleFrame

local function createBtn(parent, text, yPos)
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

local btnESP = createBtn(mainFrame, "👁️ ESP", 19)
local btnAim = createBtn(mainFrame, "🎯 AIM", 36)
local btn360 = createBtn(mainFrame, "🔄 360", 53)
local btnFly = createBtn(mainFrame, "✈️ FLY", 70)
local btnRB = createBtn(mainFrame, "🌈 RB", 87)
local btnTP = createBtn(mainFrame, "🚀 TP", 104)
local btnJump = createBtn(mainFrame, "⬆️ INF", 121)

-- Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 20, 0, 12)
speedLabel.Position = UDim2.new(0, 3, 0, 139)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 9
speedLabel.Parent = mainFrame

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 12, 0, 12)
speedUp.Position = UDim2.new(0, 25, 0, 139)
speedUp.Text = "+"
speedUp.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.Font = Enum.Font.GothamBold
speedUp.TextSize = 9
speedUp.BorderSizePixel = 0
speedUp.Parent = mainFrame

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 12, 0, 12)
speedDown.Position = UDim2.new(0, 39, 0, 139)
speedDown.Text = "-"
speedDown.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.Font = Enum.Font.GothamBold
speedDown.TextSize = 9
speedDown.BorderSizePixel = 0
speedDown.Parent = mainFrame

-- FOV
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0, 20, 0, 12)
fovLabel.Position = UDim2.new(0, 3, 0, 154)
fovLabel.Text = "FOV"
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 8
fovLabel.Parent = mainFrame

local fovUp = Instance.new("TextButton")
fovUp.Size = UDim2.new(0, 12, 0, 12)
fovUp.Position = UDim2.new(0, 25, 0, 154)
fovUp.Text = "+"
fovUp.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
fovUp.TextColor3 = Color3.fromRGB(255, 255, 255)
fovUp.Font = Enum.Font.GothamBold
fovUp.TextSize = 9
fovUp.BorderSizePixel = 0
fovUp.Parent = mainFrame

local fovDown = Instance.new("TextButton")
fovDown.Size = UDim2.new(0, 12, 0, 12)
fovDown.Position = UDim2.new(0, 39, 0, 154)
fovDown.Text = "-"
fovDown.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
fovDown.TextColor3 = Color3.fromRGB(255, 255, 255)
fovDown.Font = Enum.Font.GothamBold
fovDown.TextSize = 9
fovDown.BorderSizePixel = 0
fovDown.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 59, 0, 14)
closeBtn.Position = UDim2.new(0, 3, 0, 171)
closeBtn.Text = "✕ KAPAT"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 9
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

-- ═══════════════════════════════════════════════════════════════════════════
-- YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(p)
    if not p or p == LocalPlayer then return false end
    if LocalPlayer.Team and p.Team then
        return LocalPlayer.Team ~= p.Team
    end
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- B Ö L Ü M  2/2  -  S İ S T E M L E R
-- ═══════════════════════════════════════════════════════════════════════════--[[ BÖLÜM 2/2 - SİSTEMLER ]]

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local function startESP()
    for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
    espObjects = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChild("Humanoid")
        if not r or not h then continue end
        local enemy = isEnemy(p)
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = enemy and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
        box.Transparency = 0.4
        box.AlwaysOnTop = true
        box.Adornee = r
        box.ZIndex = 10
        box.Parent = r
        table.insert(espObjects, box)
        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.new(0, 120, 0, 30)
        tag.Adornee = r
        tag.AlwaysOnTop = true
        tag.Parent = r
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = p.Name .. " | " .. math.floor(h.Health) .. "HP"
        lbl.TextColor3 = enemy and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,50)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextStrokeTransparency = 0.3
        lbl.Parent = tag
        table.insert(espObjects, tag)
    end
end

local function stopESP()
    for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
    espObjects = {}
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. AIMBOT (Axiom tarzı - Sağ tık ile kilit)
-- ═══════════════════════════════════════════════════════════════════════════

-- Aimbot tuş dinleme
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        CamlockState = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        CamlockState = false
    end
end)

local function GetClosestPlayer()
    local target = nil
    local shortestDist = SETTINGS.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not isEnemy(p) then continue end
        local c = p.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChild("Humanoid")
        if not r or not h or h.Health <= 0 then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(r.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < shortestDist then
                if SETTINGS.WallCheck then
                    local origin = Camera.CFrame.Position
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local result = Workspace:Raycast(origin, r.Position - origin, params)
                    if not result then
                        shortestDist = dist
                        target = p
                    end
                else
                    shortestDist = dist
                    target = p
                end
            end
        end
    end
    return target
end

local function startAimbot()
    if connections.aimbot then return end
    connections.aimbot = RunService.RenderStepped:Connect(function()
        -- FOV Circle'ı güncelle
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = SETTINGS.FOV
        FOVCircle.Visible = states.aimbot
        
        if states.aimbot and CamlockState then
            local targetPlayer = GetClosestPlayer()
            if targetPlayer and targetPlayer.Character then
                local r = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    currentTarget = targetPlayer
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, r.Position)
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, SETTINGS.Smoothness)
                    
                    -- Otomatik ateş
                    local mouse = LocalPlayer:GetMouse()
                    if mouse then
                        mouse.Button1Down:Fire()
                        wait(0.03)
                        mouse.Button1Up:Fire()
                    end
                end
            end
        end
    end)
end

local function stopAimbot()
    if connections.aimbot then
        connections.aimbot:Disconnect()
        connections.aimbot = nil
    end
    FOVCircle.Visible = false
    CamlockState = false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 360
-- ═══════════════════════════════════════════════════════════════════════════

local function start360()
    if connections.rotation then return end
    connections.rotation = RunService.Heartbeat:Connect(function()
        if states.rotation and rootPart then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end
    end)
end

local function stop360()
    if connections.rotation then
        connections.rotation:Disconnect()
        connections.rotation = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. SERBEST UÇUŞ (FLY)
-- ═══════════════════════════════════════════════════════════════════════════

local function startFly()
    if bodyVelocity then return end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.P = 999999
    bodyGyro.D = 999999
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    local function keyDown(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if flyKeys[key] ~= nil then flyKeys[key] = true end
        end
    end
    local function keyUp(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if flyKeys[key] ~= nil then flyKeys[key] = false end
        end
    end
    UserInputService.InputBegan:Connect(keyDown)
    UserInputService.InputEnded:Connect(keyUp)
    
    if connections.fly then connections.fly:Disconnect() end
    connections.fly = RunService.Heartbeat:Connect(function()
        if not states.fly then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.new(0,0,0) end
            return
        end
        if not rootPart then return end
        local speed = SETTINGS.FlySpeed
        local move = Vector3.new(0,0,0)
        if flyKeys.W then move = move + rootPart.CFrame.LookVector * speed end
        if flyKeys.S then move = move - rootPart.CFrame.LookVector * speed end
        if flyKeys.A then move = move - rootPart.CFrame.RightVector * speed end
        if flyKeys.D then move = move + rootPart.CFrame.RightVector * speed end
        if flyKeys.Space then move = move + Vector3.new(0, speed, 0) end
        if flyKeys.Shift then move = move - Vector3.new(0, speed, 0) end
        if bodyVelocity then
            bodyVelocity.Velocity = move
        end
    end)
end

local function stopFly()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if connections.fly then
        connections.fly:Disconnect()
        connections.fly = nil
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    for k in pairs(flyKeys) do flyKeys[k] = false end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

local function startRainbow()
    if connections.rainbow then return end
    local hue = 0
    connections.rainbow = RunService.Heartbeat:Connect(function()
        if not states.rainbow or not character then return end
        hue = hue + 0.025
        if hue > 1 then hue = 0 end
        local col = Color3.fromHSV(hue, 1, 1)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.Color = col end
        end
        if head then head.Color = col end
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
        if not states.teleport or not rootPart then return end
        local target = GetClosestPlayer()
        if not target then return end
        local c = target.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local tPos = r.Position
        local look = r.CFrame.LookVector
        local tpPos = tPos - (look * SETTINGS.OffsetBack) + Vector3.new(0, SETTINGS.OffsetUp, 0)
        rootPart.CFrame = CFrame.new(tpPos, tPos)
    end)
end

local function stopTeleport()
    if connections.teleport then
        connections.teleport:Disconnect()
        connections.teleport = nil
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
-- B U T O N   İ Ş L E V L E R İ
-- ═══════════════════════════════════════════════════════════════════════════

local function toggle(btn, stateKey, startFunc, stopFunc)
    return function()
        states[stateKey] = not states[stateKey]
        btn.Text = (states[stateKey] and "✅" or "❌")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(0,150,0) or Color3.fromRGB(40,40,60)
        if states[stateKey] then startFunc() else stopFunc() end
    end
end

btnESP.MouseButton1Click:Connect(toggle(btnESP, "esp", startESP, stopESP))
btnAim.MouseButton1Click:Connect(toggle(btnAim, "aimbot", startAimbot, stopAimbot))
btn360.MouseButton1Click:Connect(toggle(btn360, "rotation", start360, stop360))
btnFly.MouseButton1Click:Connect(toggle(btnFly, "fly", startFly, stopFly))
btnRB.MouseButton1Click:Connect(toggle(btnRB, "rainbow", startRainbow, stopRainbow))
btnTP.MouseButton1Click:Connect(toggle(btnTP, "teleport", startTeleport, stopTeleport))
btnJump.MouseButton1Click:Connect(toggle(btnJump, "infiniteJump", startInfiniteJump, stopInfiniteJump))

-- Speed
speedUp.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue + 5
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)
speedDown.MouseButton1Click:Connect(function()
    SETTINGS.SpeedValue = SETTINGS.SpeedValue - 5
    if SETTINGS.SpeedValue < 5 then SETTINGS.SpeedValue = 5 end
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    speedLabel.Text = tostring(SETTINGS.SpeedValue)
end)

-- FOV
fovUp.MouseButton1Click:Connect(function()
    SETTINGS.FOV = SETTINGS.FOV + 10
    if SETTINGS.FOV > 360 then SETTINGS.FOV = 360 end
end)
fovDown.MouseButton1Click:Connect(function()
    SETTINGS.FOV = SETTINGS.FOV - 10
    if SETTINGS.FOV < 10 then SETTINGS.FOV = 10 end
end)

-- Menü Aç/Kapa
local menuVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    toggleBtn.Text = menuVisible and "−" or "+"
    for _, child in pairs(mainFrame:GetChildren()) do
        if child ~= titleFrame and child ~= toggleBtn then
            child.Visible = menuVisible
        end
    end
    mainFrame.Size = menuVisible and UDim2.new(0, 65, 0, 190) or UDim2.new(0, 65, 0, 16)
end)

-- Kapat
closeBtn.MouseButton1Click:Connect(function()
    stopESP(); stopAimbot(); stop360(); stopFly(); stopRainbow(); stopTeleport(); stopInfiniteJump()
    screenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- KARAKTER DEĞİŞİMİ
-- ═══════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    head = newChar:FindFirstChild("Head")
    currentTarget = nil
    stopFly(); stopRainbow()
    if states.fly then startFly() end
    if states.rainbow then startRainbow() end
end)

print("✅ WEAPON SYSTEM v22.0 HAZIR - AIMBOT ÇALIŞIYOR!")
print("🎯 AIM açıkken SAĞ TIK basılı tutarak hedefe kilitlen!")
print("🛩️ FLY açıkken WASD ile uç, Space yüksel, Shift alçal")
