--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ LEA MOD v25.0 - AIMBOT ENTEGRE (BÖLÜM 1/2)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ Aimbot - Sağ tık basılı tut (FOV + Smooth + Prediction + Autowall)
    ✅ ESP - Kutu + İsim + HP + Mesafe
    ✅ 360 - Sürekli dönüş
    ✅ Rainbow - Renk değiştirme
    ✅ Infinite Jump - Sınırsız zıplama
    ✅ Teleport - En yakın düşmana ışınlan
    ✅ Fly - WASD + Space/Shift
    ✅ Speed - +/- ayar
    ✅ Triggerbot - Ayrı buton
    ✅ AntiAim - Ayrı buton
    ✅ Bunnyhop - Ayrı buton
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- S E R V İ S L E R
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- States Table
getgenv().LEAModState = {
    Aimbot = false,
    ESP = false,
    Spin360 = false,
    Rainbow = false,
    InfJump = false,
    Teleport = false,
    Fly = false,
    Triggerbot = false,
    AntiAim = false,
    Bunnyhop = false,
    SpeedVal = 50,
    FOV = 180,
    Smoothness = 0.15,
    Prediction = false,
    Autowall = true,
    TeamCheck = true,
    MenuVisible = true
}

-- ═══════════════════════════════════════════════════════════════════════════
-- G U I
-- ═══════════════════════════════════════════════════════════════════════════

-- Cleanup existing GUI
if CoreGui:FindFirstChild("LEAModUniversalGui") then
    CoreGui.LEAModUniversalGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModUniversalGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- LEA MOD Header
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "LEAModHeader"
HeaderLabel.Parent = ScreenGui
HeaderLabel.AnchorPoint = Vector2.new(0.5, 1)
HeaderLabel.Position = UDim2.new(0.5, 0, 0.45, -15)
HeaderLabel.Size = UDim2.new(0, 200, 0, 40)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.Text = "LEA MOD"
HeaderLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
HeaderLabel.TextSize = 28
HeaderLabel.TextStrokeTransparency = 0.5

-- Main Menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.75, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 190, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Menu Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.BorderColor3 = Color3.fromRGB(170, 0, 255)
ToggleButton.Position = UDim2.new(0.75, 0, 0.05, 0)
ToggleButton.Size = UDim2.new(0, 60, 0, 25)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().LEAModState.MenuVisible = not getgenv().LEAModState.MenuVisible
    MainFrame.Visible = getgenv().LEAModState.MenuVisible
end)

-- UI List Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- Button Creator
local function createButton(name, key)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12

    btn.MouseButton1Click:Connect(function()
        getgenv().LEAModState[key] = not getgenv().LEAModState[key]
        if getgenv().LEAModState[key] then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
            btn.Text = name .. " ✅"
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = name .. " ❌"
        end
    end)
    return btn
end

-- Butonlar
createButton("Aimbot", "Aimbot")
createButton("ESP", "ESP")
createButton("360 Spin", "Spin360")
createButton("Rainbow", "Rainbow")
createButton("Inf Jump", "InfJump")
createButton("Teleport", "Teleport")
createButton("Fly", "Fly")
createButton("Triggerbot", "Triggerbot")
createButton("AntiAim", "AntiAim")
createButton("Bunnyhop", "Bunnyhop")

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainFrame
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Size = UDim2.new(1, 0, 0, 25)

local SpeedDec = Instance.new("TextButton")
SpeedDec.Parent = SpeedFrame
SpeedDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedDec.Size = UDim2.new(0.5, 0, 1, 0)
SpeedDec.Font = Enum.Font.SourceSansBold
SpeedDec.Text = "Speed -"
SpeedDec.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDec.TextSize = 12

local SpeedInc = Instance.new("TextButton")
SpeedInc.Parent = SpeedFrame
SpeedInc.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedInc.Position = UDim2.new(0.5, 0, 0, 0)
SpeedInc.Size = UDim2.new(0.5, 0, 1, 0)
SpeedInc.Font = Enum.Font.SourceSansBold
SpeedInc.Text = "Speed +"
SpeedInc.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInc.TextSize = 12

SpeedDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal - 5, 16, 200)
end)

SpeedInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal + 5, 16, 200)
end)

-- FOV
local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = MainFrame
FOVFrame.BackgroundTransparency = 1
FOVFrame.Size = UDim2.new(1, 0, 0, 25)

local FOVDec = Instance.new("TextButton")
FOVDec.Parent = FOVFrame
FOVDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVDec.Size = UDim2.new(0.5, 0, 1, 0)
FOVDec.Font = Enum.Font.SourceSansBold
FOVDec.Text = "FOV -"
FOVDec.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVDec.TextSize = 12

local FOVInc = Instance.new("TextButton")
FOVInc.Parent = FOVFrame
FOVInc.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVInc.Position = UDim2.new(0.5, 0, 0, 0)
FOVInc.Size = UDim2.new(0.5, 0, 1, 0)
FOVInc.Font = Enum.Font.SourceSansBold
FOVInc.Text = "FOV +"
FOVInc.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVInc.TextSize = 12

FOVDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.FOV = math.clamp(getgenv().LEAModState.FOV - 10, 10, 360)
end)

FOVInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.FOV = math.clamp(getgenv().LEAModState.FOV + 10, 10, 360)
end)

print("✅ BÖLÜM 1/2 YÜKLENDİ - BÖLÜM 2/2'Yİ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ LEA MOD v25.0 - BÖLÜM 2/2 (AIMBOT + SİSTEMLER)
    ═══════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- Y A R D I M C I   F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if getgenv().LEAModState.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end
    return true
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. AIMBOT (Axiom tarzı + Prediction + Autowall)
-- ═══════════════════════════════════════════════════════════════════════════

local function getClosestTarget()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 180
    local mousePos = UserInputService:GetMouseLocation()
    local myPos = getRootPart()
    if not myPos then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        -- Autowall (duvar kontrolü)
        if getgenv().LEAModState.Autowall then
            local origin = Camera.CFrame.Position
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character, char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(origin, root.Position - origin, params)
            if result then
                -- Duvar varsa hedef alma
                if dist < shortestDist then
                    shortestDist = dist
                    target = player
                end
            end
        else
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
    end
    return target
end

-- Prediction (hedef hareket tahmini)
local function getPredictedPosition(target)
    if not getgenv().LEAModState.Prediction then
        return target.Position
    end
    
    local char = target.Parent
    if not char then return target.Position end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return target.Position end
    
    local velocity = hum:GetPropertyChangedSignal("MoveDirection") and hum.MoveDirection or Vector3.new()
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    local bulletSpeed = 3000 -- varsayılan mermi hızı
    
    local time = distance / bulletSpeed
    return target.Position + (velocity * time * 50)
end

local aiming = false
local currentTarget = nil

-- Sağ tık basılı tut
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().LEAModState.Aimbot then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        currentTarget = nil
    end
end)

-- Aimbot ana döngüsü
RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Aimbot or not aiming then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local target = getClosestTarget()
    if not target then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local char = target.Character
    if not char then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if currentTarget then currentTarget = nil end
        return
    end
    
    currentTarget = target
    
    -- Hedef pozisyonu (prediction ile)
    local targetPos = getPredictedPosition(root)
    
    -- Kamera kilidi (smoothness ile)
    local currentPos = Camera.CFrame.Position
    local targetCFrame = CFrame.new(currentPos, targetPos)
    
    local smooth = getgenv().LEAModState.Smoothness or 0.15
    if smooth > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smooth)
    else
        Camera.CFrame = targetCFrame
    end
    
    -- Otomatik ateş
    local mouse = LocalPlayer:GetMouse()
    if mouse then
        mouse.Button1Down:Fire()
        wait(0.03)
        mouse.Button1Up:Fire()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. TRIGGERBOT (Hedefe gelince otomatik ateş)
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Triggerbot then return end
    
    local target = getClosestTarget()
    if not target then return end
    
    local char = target.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Crosshair hedefin üzerindeyse ateş et
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if onScreen then
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if dist < 50 then -- Crosshair hedefin üzerinde
            local mouse = LocalPlayer:GetMouse()
            if mouse then
                mouse.Button1Down:Fire()
                wait(0.03)
                mouse.Button1Up:Fire()
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. ANTI-AIM (Kafa karıştırma)
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.AntiAim then return end
    
    local root = getRootPart()
    if not root then return end
    
    -- Rastgele açılarda dön
    local angle = math.rad(math.random(0, 360))
    root.CFrame = root.CFrame * CFrame.Angles(0, angle, 0)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. BUNNYHOP (Sürekli zıplama)
-- ═══════════════════════════════════════════════════════════════════════════

local bhopTimer = 0
RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Bunnyhop then return end
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if hum.MoveDirection.Magnitude > 0 and hum:GetState() == Enum.HumanoidStateType.Landed then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local espCache = {}

local function removeESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj then obj:Destroy() end
        end
        espCache[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.ESP then
        for player, _ in pairs(espCache) do
            removeESP(player)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local root = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if not espCache[player] then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Size = char:GetExtentsSize()
                box.Adornee = char
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.5
                box.Parent = CoreGui
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPInfo"
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = CoreGui
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "InfoText"
                textLabel.Parent = billboard
                textLabel.BackgroundTransparency = 1
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                textLabel.TextStrokeTransparency = 0
                
                espCache[player] = {Box = box, Billboard = billboard, Text = textLabel}
            end

            local cache = espCache[player]
            local enemyCheck = isEnemy(player)
            local color = enemyCheck and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            
            cache.Box.Color3 = color
            
            if humanoid then
                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                cache.Text.Text = string.format("%s\nHP: %d | %dm", player.Name, math.floor(humanoid.Health), dist)
                cache.Text.TextColor3 = color
            end
        else
            removeESP(player)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. 360 SPIN
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Spin360 then
        local root = getRootPart()
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Rainbow then
        local char = getCharacter()
        if char then
            local hue = tick() % 5 / 5
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = rainbowColor
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. INFINITE JUMP
-- ═══════════════════════════════════════════════════════════════════════════

UserInputService.JumpRequest:Connect(function()
    if getgenv().LEAModState.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if not getgenv().LEAModState.Teleport then return end
    
    local myRoot = getRootPart()
    if not myRoot then return end
    
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestTarget = root
            end
        end
    end

    if closestTarget then
        myRoot.CFrame = closestTarget.CFrame * CFrame.new(0, 4, 5)
        getgenv().LEAModState.Teleport = false
        local btn = MainFrame:FindFirstChild("TeleportBtn")
        if btn then
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = "Teleport ❌"
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. FLY
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local char = getCharacter()
    if getgenv().LEAModState.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
        
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        root.Velocity = moveDir * 50
        root.RotVelocity = Vector3.new(0, 0, 0)
    elseif char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. SPEED
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().LEAModState.SpeedVal
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- KARAKTER DEĞİŞİMİ
-- ═══════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function()
    -- ESP cache temizle
    for player, _ in pairs(espCache) do
        removeESP(player)
    end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ LEA MOD v25.0 - TÜM SİSTEMLER HAZIR ⚡                ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🎯 Aimbot - Sağ tık basılı tut (FOV + Smooth + Pred)     ║")
print("║  👁️  ESP - Kutu + İsim + HP + Mesafe                       ║")
print("║  🔄 360 Spin - Sürekli dönüş                               ║")
print("║  🌈 Rainbow - Renk değiştirme                              ║")
print("║  ⬆️ Inf Jump - Sınırsız zıplama                            ║")
print("║  🚀 Teleport - En yakın düşmana ışınlan                    ║")
print("║  ✈️  Fly - WASD + Space/Shift                              ║")
print("║  🎯 Triggerbot - Crosshair hedefteyse ateş et             ║")
print("║  🔄 AntiAim - Kafa karıştırma                              ║")
print("║  🐰 Bunnyhop - Sürekli zıplama                             ║")
print("║  ⚡ Speed - +/- ayar                                       ║")
print("║  📐 FOV - +/- ayar                                         ║")
print("╚══════════════════════════════════════════════════════════════╝")
