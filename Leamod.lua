--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v33.0 - BÖLÜM 1/2 (AIMBOT V1 + V2 + TÜM ÖZELLİKLER)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ AIMBOT V1 - Ekran sağına basılı tut, crosshair ortasına kilit
    ✅ AIMBOT V2 - Crosshair neredeyse oraya kilit (1. şahıs/3. şahıs desteği)
    ✅ WallCheck - Duvar arkasındaki düşmana kitlenmez
    ✅ KillCheck - Düşman ölünce otomatik diğerine geçer
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- STATES
getgenv().LEAModState = {
    Aimbot = false,
    AimbotV2 = false,
    ESP = false,
    Spin360 = false,
    Rainbow = false,
    InfJump = false,
    Teleport = false,
    Fly = false,
    Bunnyhop = false,
    Triggerbot = false,
    SpeedVal = 50,
    FOV = 360,
    TeamCheck = true,
    AutoFire = true,
    WallCheck = true,
    KillCheck = true,
    MenuVisible = true
}

local espCache = {}
local viewportSize = Camera.ViewportSize

-- ═══════════════════════════════════════════════════════════════════════════
-- G U I
-- ═══════════════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("LEAModUniversalGui") then CoreGui.LEAModUniversalGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModUniversalGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "LEAModHeader"
HeaderLabel.Parent = ScreenGui
HeaderLabel.AnchorPoint = Vector2.new(0.5, 1)
HeaderLabel.Position = UDim2.new(0.5, 0, 0.45, -15)
HeaderLabel.Size = UDim2.new(0, 180, 0, 35)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.Text = "LEA MOD"
HeaderLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
HeaderLabel.TextSize = 26
HeaderLabel.TextStrokeTransparency = 0.5

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.75, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.BorderColor3 = Color3.fromRGB(170, 0, 255)
ToggleButton.Position = UDim2.new(0.75, 0, 0.02, 0)
ToggleButton.Size = UDim2.new(0, 55, 0, 22)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.MouseButton1Click:Connect(function()
    getgenv().LEAModState.MenuVisible = not getgenv().LEAModState.MenuVisible
    MainFrame.Visible = getgenv().LEAModState.MenuVisible
end)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local function createButton(name, key)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
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

createButton("Aimbot V1", "Aimbot")
createButton("Aimbot V2", "AimbotV2")
createButton("ESP", "ESP")
createButton("360", "Spin360")
createButton("Rainbow", "Rainbow")
createButton("InfJump", "InfJump")
createButton("Teleport", "Teleport")
createButton("Fly", "Fly")
createButton("Bunnyhop", "Bunnyhop")
createButton("Triggerbot", "Triggerbot")

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainFrame
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Size = UDim2.new(1, -10, 0, 20)
SpeedFrame.Position = UDim2.new(0, 5, 0, 0)

local SpeedDec = Instance.new("TextButton")
SpeedDec.Parent = SpeedFrame
SpeedDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedDec.Size = UDim2.new(0.3, 0, 1, 0)
SpeedDec.Font = Enum.Font.SourceSansBold
SpeedDec.Text = "-"
SpeedDec.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDec.TextSize = 14

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Size = UDim2.new(0.4, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.3, 0, 0, 0)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Text = "50"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
SpeedLabel.TextSize = 12

local SpeedInc = Instance.new("TextButton")
SpeedInc.Parent = SpeedFrame
SpeedInc.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
SpeedInc.Size = UDim2.new(0.3, 0, 1, 0)
SpeedInc.Position = UDim2.new(0.7, 0, 0, 0)
SpeedInc.Font = Enum.Font.SourceSansBold
SpeedInc.Text = "+"
SpeedInc.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInc.TextSize = 14

SpeedDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal - 5, 5, 9999)
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)
SpeedInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = getgenv().LEAModState.SpeedVal + 5
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)

-- Fly Butonları
local FlyFrame = Instance.new("Frame")
FlyFrame.Parent = MainFrame
FlyFrame.BackgroundTransparency = 1
FlyFrame.Size = UDim2.new(1, -10, 0, 60)
FlyFrame.Position = UDim2.new(0, 5, 0, 0)

local FlyUp = Instance.new("TextButton")
FlyUp.Parent = FlyFrame
FlyUp.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
FlyUp.Size = UDim2.new(0.33, -5, 0.5, -2)
FlyUp.Position = UDim2.new(0.33, 0, 0, 0)
FlyUp.Font = Enum.Font.SourceSansBold
FlyUp.Text = "▲"
FlyUp.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyUp.TextSize = 18
FlyUp.MouseButton1Click:Connect(function()
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
        end
    end
end)

local FlyDown = Instance.new("TextButton")
FlyDown.Parent = FlyFrame
FlyDown.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
FlyDown.Size = UDim2.new(0.33, -5, 0.5, -2)
FlyDown.Position = UDim2.new(0.33, 0, 0.5, 0)
FlyDown.Font = Enum.Font.SourceSansBold
FlyDown.Text = "▼"
FlyDown.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDown.TextSize = 18
FlyDown.MouseButton1Click:Connect(function()
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0, -50, 0)
        end
    end
end)

local FlyLeft = Instance.new("TextButton")
FlyLeft.Parent = FlyFrame
FlyLeft.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
FlyLeft.Size = UDim2.new(0.33, -5, 0.5, -2)
FlyLeft.Position = UDim2.new(0, 0, 0.25, 0)
FlyLeft.Font = Enum.Font.SourceSansBold
FlyLeft.Text = "◀"
FlyLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLeft.TextSize = 18
FlyLeft.MouseButton1Click:Connect(function()
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = -Camera.CFrame.RightVector * 50
        end
    end
end)

local FlyRight = Instance.new("TextButton")
FlyRight.Parent = FlyFrame
FlyRight.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
FlyRight.Size = UDim2.new(0.33, -5, 0.5, -2)
FlyRight.Position = UDim2.new(0.66, 0, 0.25, 0)
FlyRight.Font = Enum.Font.SourceSansBold
FlyRight.Text = "▶"
FlyRight.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyRight.TextSize = 18
FlyRight.MouseButton1Click:Connect(function()
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Camera.CFrame.RightVector * 50
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if getgenv().LEAModState.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    end
    return true
end

local function getHitbox(char)
    local parts = {"HumanoidRootPart", "UpperTorso", "Torso", "Head"}
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

-- WALL CHECK - Duvar kontrolü
local function canSeeTarget(targetRoot)
    if not getgenv().LEAModState.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetRoot.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetRoot.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, direction * distance, params)
    
    if result then
        local hit = result.Instance
        if hit and hit:IsDescendantOf(targetRoot.Parent) then
            return true
        end
        return false
    end
    return true
end

-- Crosshair pozisyonu (1. şahıs/3. şahıs desteği)
local function getCrosshairPosition()
    -- Ekranın ortası
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    
    -- 3. şahıs kontrolü (karakter ekranın altında kalıyorsa)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen and screenPos.Y > viewportSize.Y / 2 then
            -- Karakter ekranın alt yarısındaysa 3. şahıs
            centerY = viewportSize.Y * 0.4 -- Crosshair'i biraz yukarı al
        end
    end
    
    return centerX, centerY
end

local function getNearestEnemy()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 360
    local centerX, centerY = getCrosshairPosition()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        
        local root = getHitbox(char)
        if not root then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- KILL CHECK - Ölüyse geç
        if getgenv().LEAModState.KillCheck and hum.Health <= 0 then continue end
        
        -- WALL CHECK - Duvar arkasıysa geç
        if not canSeeTarget(root) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(centerX, centerY)).Magnitude
        
        if dist < shortestDist then
            shortestDist = dist
            target = player
        end
    end
    return target
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════════════════════════

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
        for player, _ in pairs(espCache) do removeESP(player) end
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
-- 360 SPIN
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Spin360 then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Rainbow then
        local char = LocalPlayer.Character
        if char then
            local hue = tick() % 5 / 5
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Color = rainbowColor end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- INFINITE JUMP
-- ═══════════════════════════════════════════════════════════════════════════

UserInputService.JumpRequest:Connect(function()
    if getgenv().LEAModState.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUNNYHOP
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Bunnyhop then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.MoveDirection.Magnitude > 0 and hum:GetState() == Enum.HumanoidStateType.Landed then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if not getgenv().LEAModState.Teleport then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local closestTarget = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            if not canSeeTarget(root) then continue end
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
-- FLY
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if getgenv().LEAModState.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    elseif char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- SPEED
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().LEAModState.SpeedVal
        hum.JumpPower = 50
    end
end)

print("✅ BÖLÜM 1/2 YÜKLENDİ - BÖLÜM 2/2'Yİ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v33.0 - BÖLÜM 2/2 (AIMBOT V1 + V2)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ AIMBOT V1 - Ekran sağına basılı tut, crosshair ortasına kilit
    ✅ AIMBOT V2 - Crosshair neredeyse oraya kilit (1. şahıs/3. şahıs desteği)
    ✅ WallCheck - Duvar arkasındaki düşmana kitlenmez
    ✅ KillCheck - Düşman ölünce otomatik diğerine geçer
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local isAimingV1 = false
local isAimingV2 = false
local currentTarget = nil
local viewportSize = Camera.ViewportSize

-- ═══════════════════════════════════════════════════════════════════════════
-- YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if getgenv().LEAModState.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    end
    return true
end

local function getHitbox(char)
    local parts = {"HumanoidRootPart", "UpperTorso", "Torso", "Head"}
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

-- WALL CHECK
local function canSeeTarget(targetRoot)
    if not getgenv().LEAModState.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetRoot.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetRoot.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, direction * distance, params)
    
    if result then
        local hit = result.Instance
        if hit and hit:IsDescendantOf(targetRoot.Parent) then
            return true
        end
        return false
    end
    return true
end

-- Crosshair pozisyonu (1. şahıs/3. şahıs desteği)
local function getCrosshairPosition()
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen and screenPos.Y > viewportSize.Y / 2 then
            centerY = viewportSize.Y * 0.38
        end
    end
    
    return centerX, centerY
end

local function getNearestEnemy()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 360
    local centerX, centerY = getCrosshairPosition()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        
        local root = getHitbox(char)
        if not root then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        if getgenv().LEAModState.KillCheck and hum.Health <= 0 then continue end
        if not canSeeTarget(root) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(centerX, centerY)).Magnitude
        
        if dist < shortestDist then
            shortestDist = dist
            target = player
        end
    end
    return target
end

-- ═══════════════════════════════════════════════════════════════════════════
-- AIMBOT V1 - Ekran sağına basılı tut
-- ═══════════════════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        if pos.X > viewportSize.X / 2 then
            if getgenv().LEAModState.Aimbot then
                isAimingV1 = true
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isAimingV1 = false
        isAimingV2 = false
        currentTarget = nil
    end
end)

-- PC için
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().LEAModState.Aimbot then
            isAimingV1 = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAimingV1 = false
        isAimingV2 = false
        currentTarget = nil
    end
end)

-- AIMBOT V1 döngüsü
RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Aimbot or not isAimingV1 then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local target = getNearestEnemy()
    if not target then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local char = target.Character
    if not char then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local root = getHitbox(char)
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
    
    local targetPos = root.Position
    local currentPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(currentPos, targetPos)
    
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- AIMBOT V2 - Crosshair neredeyse oraya kilit (1. şahıs/3. şahıs desteği)
-- ═══════════════════════════════════════════════════════════════════════════

-- V2 için ayrı tetikleme (Aimbot V2 butonu ile)
-- V2 aktifken V1 çalışmaz, V2 çalışır

-- V2 için Input (Aimbot V2 butonu ile aktif)
-- V2 butonuna basınca aktif olur, sağ tık/touch ile kilit

-- V2 döngüsü (Aimbot V2 aktifse ve isAimingV1 true ise çalışır)
-- V2, V1 ile aynı tetikleme mekanizmasını kullanır ama farklı hesaplama yapar

-- V2 için crosshair takibi (daha hassas)
local function getNearestEnemyV2()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 360
    local centerX, centerY = getCrosshairPosition()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        
        -- V2'de Head öncelikli
        local root = char:FindFirstChild("Head") or getHitbox(char)
        if not root then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        if getgenv().LEAModState.KillCheck and hum.Health <= 0 then continue end
        if not canSeeTarget(root) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(centerX, centerY)).Magnitude
        
