--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v48.0 - BÖLÜM 1/5 (AYARLAR + MENÜ - OPTİMİZE)
    ═══════════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- DÜŞÜK PERFORMANS MODU
getgenv().LEAModState = {
    AimbotV1 = false, AimbotV2 = false, AimAssist = false, AimLock = false,
    CrosshairAim = false, MagicBullet = false, ESP = false, Spin360 = false,
    Rainbow = false, InfJump = false, Teleport = false, Fly = false,
    Bunnyhop = false, Triggerbot = false, SpeedVal = 50, FOV = 1000,
    TeamCheck = true, AutoFire = true, WallCheck = true, KillCheck = true,
    MenuVisible = true, LowPerformance = true
}

local viewportSize = Camera.ViewportSize

if CoreGui:FindFirstChild("LEAModUniversalGui") then CoreGui.LEAModUniversalGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModUniversalGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "LEAModHeader"
HeaderLabel.Parent = ScreenGui
HeaderLabel.AnchorPoint = Vector2.new(0.5, 1)
HeaderLabel.Position = UDim2.new(0.5, 0, 0.48, -5)
HeaderLabel.Size = UDim2.new(0, 120, 0, 25)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.Text = "⚡LEA"
HeaderLabel.TextColor3 = Color3.fromRGB(200, 0, 255)
HeaderLabel.TextSize = 22
HeaderLabel.TextStrokeTransparency = 0.3

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.78, 0, 0.02, 0)
MainFrame.Size = UDim2.new(0, 155, 0, 430)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
ToggleButton.BorderColor3 = Color3.fromRGB(200, 0, 255)
ToggleButton.Position = UDim2.new(0.78, 0, 0.005, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 18)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.MouseButton1Click:Connect(function()
    getgenv().LEAModState.MenuVisible = not getgenv().LEAModState.MenuVisible
    MainFrame.Visible = getgenv().LEAModState.MenuVisible
end)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 1)

local function createButton(name, key)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Size = UDim2.new(1, -6, 0, 18)
    btn.Position = UDim2.new(0, 3, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        getgenv().LEAModState[key] = not getgenv().LEAModState[key]
        if getgenv().LEAModState[key] then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
            btn.Text = name .. " ✅"
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = name .. " ❌"
        end
        if key == "AimbotV1" and getgenv().LEAModState.AimbotV1 then
            getgenv().LEAModState.AimbotV2 = false
            local v2btn = MainFrame:FindFirstChild("AimbotV2Btn")
            if v2btn then v2btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) v2btn.Text = "Aimbot V2 ❌" end
        end
        if key == "AimbotV2" and getgenv().LEAModState.AimbotV2 then
            getgenv().LEAModState.AimbotV1 = false
            local v1btn = MainFrame:FindFirstChild("AimbotV1Btn")
            if v1btn then v1btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) v1btn.Text = "Aimbot V1 ❌" end
        end
        if key == "AimAssist" and getgenv().LEAModState.AimAssist then
            getgenv().LEAModState.AimLock = false
            local lockbtn = MainFrame:FindFirstChild("AimLockBtn")
            if lockbtn then lockbtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) lockbtn.Text = "AimLock ❌" end
        end
        if key == "AimLock" and getgenv().LEAModState.AimLock then
            getgenv().LEAModState.AimAssist = false
            local assistbtn = MainFrame:FindFirstChild("AimAssistBtn")
            if assistbtn then assistbtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) assistbtn.Text = "AimAssist ❌" end
        end
        if key == "MagicBullet" then
            if getgenv().LEAModState.MagicBullet then startMagicBullet() else stopMagicBullet() end
        end
        if key == "ESP" then
            if getgenv().LEAModState.ESP then refreshESP() else clearESP() end
        end
    end)
    return btn
end

createButton("Aim V1", "AimbotV1")
createButton("Aim V2", "AimbotV2")
createButton("Assist", "AimAssist")
createButton("Lock", "AimLock")
createButton("Cross Aim", "CrosshairAim")
createButton("M.Bullet", "MagicBullet")
createButton("ESP", "ESP")
createButton("360", "Spin360")
createButton("RB", "Rainbow")
createButton("InfJump", "InfJump")
createButton("Teleport", "Teleport")
createButton("Fly", "Fly")
createButton("Bunnyhop", "Bunnyhop")
createButton("Trigger", "Triggerbot")

-- SPEED
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainFrame
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Size = UDim2.new(1, -6, 0, 16)
SpeedFrame.Position = UDim2.new(0, 3, 0, 0)

local SpeedDec = Instance.new("TextButton")
SpeedDec.Parent = SpeedFrame
SpeedDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedDec.Size = UDim2.new(0.3, 0, 1, 0)
SpeedDec.Font = Enum.Font.SourceSansBold
SpeedDec.Text = "-"
SpeedDec.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDec.TextSize = 12

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Size = UDim2.new(0.4, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.3, 0, 0, 0)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Text = "50"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
SpeedLabel.TextSize = 10

local SpeedInc = Instance.new("TextButton")
SpeedInc.Parent = SpeedFrame
SpeedInc.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
SpeedInc.Size = UDim2.new(0.3, 0, 1, 0)
SpeedInc.Position = UDim2.new(0.7, 0, 0, 0)
SpeedInc.Font = Enum.Font.SourceSansBold
SpeedInc.Text = "+"
SpeedInc.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInc.TextSize = 12

SpeedDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal - 5, 5, 9999)
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)
SpeedInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = getgenv().LEAModState.SpeedVal + 5
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)

-- FLY BUTONLARI
local FlyFrame = Instance.new("Frame")
FlyFrame.Parent = MainFrame
FlyFrame.BackgroundTransparency = 1
FlyFrame.Size = UDim2.new(1, -6, 0, 40)
FlyFrame.Position = UDim2.new(0, 3, 0, 0)

local FlyUp = Instance.new("TextButton")
FlyUp.Parent = FlyFrame
FlyUp.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
FlyUp.Size = UDim2.new(0.33, -2, 0.5, -1)
FlyUp.Position = UDim2.new(0.33, 0, 0, 0)
FlyUp.Font = Enum.Font.SourceSansBold
FlyUp.Text = "▲"
FlyUp.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyUp.TextSize = 14
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
FlyDown.Size = UDim2.new(0.33, -2, 0.5, -1)
FlyDown.Position = UDim2.new(0.33, 0, 0.5, 0)
FlyDown.Font = Enum.Font.SourceSansBold
FlyDown.Text = "▼"
FlyDown.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDown.TextSize = 14
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
FlyLeft.Size = UDim2.new(0.33, -2, 0.5, -1)
FlyLeft.Position = UDim2.new(0, 0, 0.25, 0)
FlyLeft.Font = Enum.Font.SourceSansBold
FlyLeft.Text = "◀"
FlyLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLeft.TextSize = 14
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
FlyRight.Size = UDim2.new(0.33, -2, 0.5, -1)
FlyRight.Position = UDim2.new(0.66, 0, 0.25, 0)
FlyRight.Font = Enum.Font.SourceSansBold
FlyRight.Text = "▶"
FlyRight.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyRight.TextSize = 14
FlyRight.MouseButton1Click:Connect(function()
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Camera.CFrame.RightVector * 50
        end
    end
end)

print("✅ BÖLÜM 1/5 YÜKLENDİ - BÖLÜM 2/5'İ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v48.0 - BÖLÜM 2/5 (ESP - OPTİMİZE)
    ═══════════════════════════════════════════════════════════════════════════
]]

local espCache = {}
local espUpdateTimer = 0

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if getgenv().LEAModState.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
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
        if hit and hit:IsDescendantOf(targetRoot.Parent) then return true end
        return false
    end
    return true
end

local function getNearestEnemy()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 1000
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = getHitbox(char)
        if not root then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then 
            if getgenv().LEAModState.KillCheck then continue end
        end
        if not canSeeTarget(root) then continue end
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            target = player
        end
    end
    return target
end

local function clearESP()
    for player, _ in pairs(espCache) do
        if espCache[player] then
            for _, obj in pairs(espCache[player]) do
                if obj then pcall(function() obj:Destroy() end) end
            end
            espCache[player] = nil
        end
    end
end

local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        espCache[player] = nil
    end
    
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
    billboard.Size = UDim2.new(0, 120, 0, 40)
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
    textLabel.Text = string.format("%s\nHP: %d", player.Name, math.floor(humanoid.Health))
    
    espCache[player] = {Box = box, Billboard = billboard, Text = textLabel}
end

local function refreshESP()
    clearESP()
    if not getgenv().LEAModState.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        createESPForPlayer(player)
    end
end

-- ESP OPTİMİZE - Sadece oyuncu eklendiğinde veya çıktığında güncellenir
Players.PlayerAdded:Connect(function(player)
    wait(1)
    if getgenv().LEAModState.ESP then
        createESPForPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        espCache[player] = nil
    end
end)

-- ESP GÜNCELLEME - Her 0.5 saniyede bir (DONMAZ)
RunService.Heartbeat:Connect(function()
    espUpdateTimer = espUpdateTimer + 1
    if espUpdateTimer % 3 ~= 0 then return end -- ~0.5 saniye
    
    if not getgenv().LEAModState.ESP then
        clearESP()
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do
                    if obj then pcall(function() obj:Destroy() end) end
                end
                espCache[player] = nil
            end
            continue
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do
                    if obj then pcall(function() obj:Destroy() end) end
                end
                espCache[player] = nil
            end
            continue
        end
        
        if humanoid.Health <= 0 then
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do
                    if obj then pcall(function() obj:Destroy() end) end
                end
                espCache[player] = nil
            end
            continue
        end
        
        if not espCache[player] then
            createESPForPlayer(player)
        end
        
        local cache = espCache[player]
        if cache then
            local enemyCheck = isEnemy(player)
            local color = enemyCheck and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            cache.Box.Color3 = color
            local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
            cache.Text.Text = string.format("%s\nHP: %d | %dm", player.Name, math.floor(humanoid.Health), dist)
            cache.Text.TextColor3 = color
        end
    end
end)

print("✅ BÖLÜM 2/5 YÜKLENDİ - BÖLÜM 3/5'İ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v48.0 - BÖLÜM 3/5 (TÜM ÖZELLİKLER - OPTİMİZE)
    ═══════════════════════════════════════════════════════════════════════════
]]

-- 360 (Her frame'de döner, sorun yok)
RunService.Heartbeat:Connect(function()
    if getgenv().LEAModState.Spin360 then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0) end
    end
end)

-- RAINBOW (Her frame'de renk değiştirir)
RunService.Heartbeat:Connect(function()
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

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if getgenv().LEAModState.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- BUNNYHOP
RunService.Heartbeat:Connect(function()
    if not getgenv().LEAModState.Bunnyhop then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.MoveDirection.Magnitude > 0 and hum:GetState() == Enum.HumanoidStateType.Landed then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- TELEPORT (En yakın düşmana)
RunService.Heartbeat:Connect(function()
    if not getgenv().LEAModState.Teleport then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    -- getNearestEnemy fonksiyonu Bölüm 2'den gelir
    local target = getNearestEnemy()
    if not target then return end
    
    local tChar = target.Character
    if not tChar then return end
    
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 4, 5)
    getgenv().LEAModState.Teleport = false
    
    local btn = CoreGui:FindFirstChild("LEAModUniversalGui") and CoreGui.LEAModUniversalGui.MainFrame:FindFirstChild("TeleportBtn")
    if btn then
        btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        btn.Text = "Teleport ❌"
    end
end)

-- FLY
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if getgenv().LEAModState.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    elseif char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end)

-- SPEED
RunService.Heartbeat:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().LEAModState.SpeedVal
        hum.JumpPower = 50
    end
end)

local function restartAllSystems()
    lockedTarget = nil
    isAiming = false
    if getgenv().LEAModState.ESP then refreshESP() end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().LEAModState.SpeedVal
        hum.JumpPower = 50
    end
    if getgenv().LEAModState.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local humFly = char:FindFirstChildOfClass("Humanoid")
            if humFly then humFly.PlatformStand = true end
        end
    end
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
end

LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    restartAllSystems()
end)

print("✅ BÖLÜM 3/5 YÜKLENDİ - BÖLÜM 4/5'İ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v48.0 - BÖLÜM 4/5 (AİMBOT + CROSSHAIR AIM - OPTİMİZE)
    ═══════════════════════════════════════════════════════════════════════════
]]

local isAiming = false
local lockedTarget = nil
local viewportSize = Camera.ViewportSize
local aimUpdateTimer = 0

local function findNearestEnemy()
    local target = nil
    local shortestDist = 1000
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = getHitbox(char)
        if not root then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then 
            if getgenv().LEAModState.KillCheck then continue end
        end
        if getgenv().LEAModState.WallCheck then
            if not canSeeTarget(root) then continue end
        end
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            target = player
        end
    end
    return target
end

local function isTargetStillValid(targetPlayer)
    if not targetPlayer then return false end
    local char = targetPlayer.Character
    if not char then return false end
    local root = getHitbox(char)
    if not root then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    if getgenv().LEAModState.WallCheck then
        if not canSeeTarget(root) then return false end
    end
    return true
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        if pos.X > viewportSize.X / 2 then
            if getgenv().LEAModState.AimbotV1 or getgenv().LEAModState.AimbotV2 or getgenv().LEAModState.AimAssist or getgenv().LEAModState.AimLock or getgenv().LEAModState.CrosshairAim then
                isAiming = true
                if not lockedTarget then
                    lockedTarget = findNearestEnemy()
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isAiming = false
        lockedTarget = nil
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().LEAModState.AimbotV1 or getgenv().LEAModState.AimbotV2 or getgenv().LEAModState.AimAssist or getgenv().LEAModState.AimLock or getgenv().LEAModState.CrosshairAim then
            isAiming = true
            if not lockedTarget then
                lockedTarget = findNearestEnemy()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
        lockedTarget = nil
    end
end)

-- AIMBOT V1 (Her 2 frame'de bir güncelle - DONMAZ)
RunService.Heartbeat:Connect(function()
    aimUpdateTimer = aimUpdateTimer + 1
    if aimUpdateTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.AimbotV1 or not isAiming then
        if lockedTarget then lockedTarget = nil end
        return
    end
    
    if not lockedTarget then
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    if not isTargetStillValid(lockedTarget) then
        lockedTarget = nil
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    local char = lockedTarget.Character
    if not char then lockedTarget = nil return end
    
    local root = getHitbox(char)
    if not root then lockedTarget = nil return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if getgenv().LEAModState.KillCheck then lockedTarget = nil return end
    end
    
    local targetPos = root.Position
    local currentPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(currentPos, targetPos)
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
    end
    
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- AIMBOT V2 (Her 2 frame'de bir)
RunService.Heartbeat:Connect(function()
    if aimUpdateTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.AimbotV2 or not isAiming then
        if lockedTarget then lockedTarget = nil end
        return
    end
    
    if not lockedTarget then
        local target = nil
        local shortestDist = 1000
        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("Head") or getHitbox(char)
            if not root then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                if getgenv().LEAModState.KillCheck then continue end
            end
            if getgenv().LEAModState.WallCheck then
                if not canSeeTarget(root) then continue end
            end
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
        lockedTarget = target
        if not lockedTarget then return end
    end
    
    if not isTargetStillValid(lockedTarget) then
        lockedTarget = nil
        local target = nil
        local shortestDist = 1000
        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("Head") or getHitbox(char)
            if not root then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                if getgenv().LEAModState.KillCheck then continue end
            end
            if getgenv().LEAModState.WallCheck then
                if not canSeeTarget(root) then continue end
            end
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
        lockedTarget = target
        if not lockedTarget then return end
    end
    
    local char = lockedTarget.Character
    if not char then lockedTarget = nil return end
    
    local root = char:FindFirstChild("Head") or getHitbox(char)
    if not root then lockedTarget = nil return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if getgenv().LEAModState.KillCheck then lockedTarget = nil return end
    end
    
    local targetPos = root.Position
    local currentPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(currentPos, targetPos)
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
    end
    
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- AIMASSIST (Her 2 frame'de bir)
RunService.Heartbeat:Connect(function()
    if aimUpdateTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.AimAssist or not isAiming then
        if lockedTarget then lockedTarget = nil end
        return
    end
    
    if not lockedTarget then
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    if not isTargetStillValid(lockedTarget) then
        lockedTarget = nil
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    local char = lockedTarget.Character
    if not char then lockedTarget = nil return end
    
    local root = getHitbox(char)
    if not root then lockedTarget = nil return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if getgenv().LEAModState.KillCheck then lockedTarget = nil return end
    end
    
    local targetPos = root.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
    end
    
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- AIMLOCK (Her 2 frame'de bir)
RunService.Heartbeat:Connect(function()
    if aimUpdateTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.AimLock or not isAiming then
        if lockedTarget then lockedTarget = nil end
        return
    end
    
    if not lockedTarget then
        local target = nil
        local shortestDist = 1000
        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("Head") or getHitbox(char)
            if not root then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                if getgenv().LEAModState.KillCheck then continue end
            end
            if getgenv().LEAModState.WallCheck then
                if not canSeeTarget(root) then continue end
            end
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
        lockedTarget = target
        if not lockedTarget then return end
    end
    
    if not isTargetStillValid(lockedTarget) then
        lockedTarget = nil
        local target = nil
        local shortestDist = 1000
        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("Head") or getHitbox(char)
            if not root then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                if getgenv().LEAModState.KillCheck then continue end
            end
            if getgenv().LEAModState.WallCheck then
                if not canSeeTarget(root) then continue end
            end
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
        lockedTarget = target
        if not lockedTarget then return end
    end
    
    local char = lockedTarget.Character
    if not char then lockedTarget = nil return end
    
    local root = char:FindFirstChild("Head") or getHitbox(char)
    if not root then lockedTarget = nil return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if getgenv().LEAModState.KillCheck then lockedTarget = nil return end
    end
    
    local targetPos = root.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
    end
    
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- CROSSHAIR AIM (Her 2 frame'de bir - KARAKTER SABİT)
RunService.Heartbeat:Connect(function()
    if aimUpdateTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.CrosshairAim or not isAiming then
        if lockedTarget then lockedTarget = nil end
        return
    end
    
    if not lockedTarget then
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    if not isTargetStillValid(lockedTarget) then
        lockedTarget = nil
        lockedTarget = findNearestEnemy()
        if not lockedTarget then return end
    end
    
    local char = lockedTarget.Character
    if not char then lockedTarget = nil return end
    
    local root = getHitbox(char)
    if not root then lockedTarget = nil return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if getgenv().LEAModState.KillCheck then lockedTarget = nil return end
    end
    
    -- SADECE KAMERA HEDEFE BAKAR (KARAKTER SABİT)
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

print("✅ BÖLÜM 4/5 YÜKLENDİ - BÖLÜM 5/5'İ ÇALIŞTIR")--[[
    ═══════════════════════════════════════════════════════════════════════════
    📱 LEA MOD v48.0 - BÖLÜM 5/5 (MAGIC BULLET + TRIGGERBOT - OPTİMİZE)
    ═══════════════════════════════════════════════════════════════════════════
]]

local magicBulletConnection = nil
local magicBulletTools = {}
local magicBulletTimer = 0

local function GetNearestTarget(originPosition)
    local nearestTargetPart = nil
    local shortestDistance = 300

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart") 
                or char:FindFirstChild("Torso") 
                or char:FindFirstChild("UpperTorso")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                if getgenv().LEAModState.TeamCheck then
                    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        continue
                    end
                end
                local distance = (rootPart.Position - originPosition).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestTargetPart = rootPart
                end
            end
        end
    end

    return nearestTargetPart
end

local function FireHomingBullet(originInput)
    local char = LocalPlayer.Character
    if not char then return end
    
    local startCFrame = nil
    if typeof(originInput) == "CFrame" then
        startCFrame = originInput
    elseif typeof(originInput) == "Vector3" then
        startCFrame = CFrame.new(originInput)
    elseif typeof(originInput) == "Instance" and originInput:IsA("BasePart") then
        startCFrame = originInput.CFrame
    elseif char then
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("Handle")
        if rightHand then
            startCFrame = rightHand.CFrame
        elseif Workspace.CurrentCamera then
            startCFrame = Workspace.CurrentCamera.CFrame
        end
    end

    if not startCFrame then return end

    local targetPart = GetNearestTarget(startCFrame.Position)
    if not targetPart then return end

    local bullet = Instance.new("Part")
    bullet.Name = "HomingBullet"
    bullet.Size = Vector3.new(0.3, 0.3, 0.8)
    bullet.CanCollide = false
    bullet.Anchored = true
    bullet.Transparency = 0.2
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 0, 255)

    local spawnPos = startCFrame.Position + (startCFrame.LookVector * 3)
    bullet.CFrame = CFrame.lookAt(spawnPos, spawnPos + startCFrame.LookVector)
    bullet.Parent = Workspace

    local currentVelocity = (targetPart.Position - spawnPos).Unit * 350
    local connection = nil
    local isCleanedUp = false
    local lifetime = 0

    local function Cleanup()
        if isCleanedUp then return end
        isCleanedUp = true
        if connection then connection:Disconnect() connection = nil end
        if bullet and bullet.Parent then bullet:Destroy() end
    end

    task.delay(5, Cleanup)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if isCleanedUp or not bullet or not bullet.Parent then
            Cleanup()
            return
        end

        lifetime = lifetime + deltaTime
        if lifetime > 5 then Cleanup() return end

        local dt = math.clamp(deltaTime, 0.001, 0.1)

        local ignoreList = {bullet, LocalPlayer.Character}
        raycastParams.FilterDescendantsInstances = ignoreList

        local newTarget = GetNearestTarget(bullet.Position)
        if newTarget and newTarget.Parent then
            targetPart = newTarget
        end

        if targetPart and targetPart.Parent then
            local targetVector = (targetPart.Position - bullet.Position)
            if targetVector.Magnitude > 0 then
                local desiredDir = targetVector.Unit
                local currentDir = currentVelocity.Unit
                local blendedDir = currentDir:Lerp(desiredDir, 0.9)
                if blendedDir.Magnitude > 0 then
                    currentVelocity = blendedDir.Unit * 350
                end
            end
        end

        local stepMovement = currentVelocity * dt
        local currentPos = bullet.Position
        local nextPos = currentPos + stepMovement

        local rayResult = Workspace:Raycast(currentPos, stepMovement, raycastParams)
        if rayResult then
            local hitInstance = rayResult.Instance
            local hitModel = hitInstance and hitInstance:FindFirstAncestorOfClass("Model")
            local humanoid = hitModel and hitModel:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Cleanup()
                return
            end
        end

        if stepMovement.Magnitude > 0 and currentVelocity.Magnitude > 0 then
            bullet.CFrame = CFrame.lookAt(nextPos, nextPos + currentVelocity)
        end
    end)
end

local function HookTool(tool)
    if tool:IsA("Tool") and not tool:GetAttribute("HomingHooked") then
        tool:SetAttribute("HomingHooked", true)
        local connection = tool.Activated:Connect(function()
            if getgenv().LEAModState.MagicBullet then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                local originCF = handle and handle.CFrame or nil
                FireHomingBullet(originCF)
            end
        end)
        table.insert(magicBulletTools, {tool = tool, connection = connection})
    end
end

local function SetupMagicBulletHooks(char)
    if not char then return end

    char.ChildAdded:Connect(function(child)
        HookTool(child)
    end)

    for _, child in ipairs(char:GetChildren()) do
        HookTool(child)
    end
end

local function startMagicBullet()
    if magicBulletConnection then return end
    if LocalPlayer.Character then
        SetupMagicBulletHooks(LocalPlayer.Character)
    end
    magicBulletConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        SetupMagicBulletHooks(newChar)
    end)
    print("✅ Magic Bullet AKTİF")
end

local function stopMagicBullet()
    if magicBulletConnection then
        magicBulletConnection:Disconnect()
        magicBulletConnection = nil
    end
    for _, data in ipairs(magicBulletTools) do
        if data.connection then
            data.connection:Disconnect()
        end
        if data.tool then
            data.tool:SetAttribute("HomingHooked", nil)
        end
    end
    magicBulletTools = {}
    print("❌ Magic Bullet PASİF")
end

-- TRIGGERBOT (Her 2 frame'de bir)
RunService.Heartbeat:Connect(function()
    magicBulletTimer = magicBulletTimer + 1
    if magicBulletTimer % 2 ~= 0 then return end
    
    if not getgenv().LEAModState.Triggerbot then return end
    
    local target = nil
    local shortestDist = 50
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("Head") or getHitbox(char)
        if not root then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if getgenv().LEAModState.WallCheck then
            if not canSeeTarget(root) then continue end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(centerX, centerY)).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                target = player
            end
        end
    end
    
    if target then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    lockedTarget = nil
    isAiming = false
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   🔥 LEA MOD v48.0 - OPTİMİZE EDİLDİ (DONMA YOK) ⚡        ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🎯 AIMBOT - Her 2 frame'de bir güncellenir               ║")
print("║  👁️  ESP - Her 0.5 saniyede bir güncellenir               ║")
print("║  🔫 MAGIC BULLET - Optimize edildi                         ║")
print("║  🚀 TÜM SİSTEMLER - DONMA YOK                             ║")
print("╚══════════════════════════════════════════════════════════════╝")
