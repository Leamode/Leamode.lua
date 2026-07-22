--[================================================================]--
--               WEAPON SYSTEM : ADVANCED COMBAT ENGINE             --
--[================================================================]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    SpeedValue = 50,
    GiantSize = 2,
    FlySpeed = 60,
    OffsetBack = 5,
    OffsetUp = 4,
    TeamCheck = true,
    AutoFire = true,
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:FindFirstChild("Head")

local killCount = 0
local isActive = false
local isRunning = false
local currentTarget = nil
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local espObjects = {}
local magicConnection = nil
local rainbowConnection = nil
local rotationConnection = nil
local lastHealth = humanoid.Health

-- UI Initialization
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponSystemGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 80, 0, 150)
mainFrame.Position = UDim2.new(1, -90, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 18)
titleLabel.Text = "⚡COMBAT"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -4, 0, 14)
statusLabel.Position = UDim2.new(0, 2, 0, 23)
statusLabel.Text = "⏸"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local targetNameLabel = Instance.new("TextLabel")
targetNameLabel.Size = UDim2.new(1, -4, 0, 14)
targetNameLabel.Position = UDim2.new(0, 2, 0, 39)
targetNameLabel.Text = "Yok"
targetNameLabel.BackgroundTransparency = 1
targetNameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
targetNameLabel.Font = Enum.Font.Gotham
targetNameLabel.TextSize = 9
targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
targetNameLabel.Parent = mainFrame

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -4, 0, 14)
hpLabel.Position = UDim2.new(0, 2, 0, 55)
hpLabel.Text = "HP: 100"
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 9
hpLabel.TextXAlignment = Enum.TextXAlignment.Left
hpLabel.Parent = mainFrame

local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(1, -4, 0, 14)
distLabel.Position = UDim2.new(0, 2, 0, 71)
distLabel.Text = "0m"
distLabel.BackgroundTransparency = 1
distLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
distLabel.Font = Enum.Font.Gotham
distLabel.TextSize = 9
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = mainFrame

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(1, -4, 0, 14)
killLabel.Position = UDim2.new(0, 2, 0, 87)
killLabel.Text = "💀 0"
killLabel.BackgroundTransparency = 1
killLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
killLabel.Font = Enum.Font.GothamBold
killLabel.TextSize = 10
killLabel.TextXAlignment = Enum.TextXAlignment.Left
killLabel.Parent = mainFrame

local gitButton = Instance.new("TextButton")
gitButton.Size = UDim2.new(0, 35, 0, 22)
gitButton.Position = UDim2.new(0, 2, 0, 103)
gitButton.Text = "▶"
gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
gitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gitButton.Font = Enum.Font.GothamBold
gitButton.TextSize = 14
gitButton.BorderSizePixel = 0
gitButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 22)
closeButton.Position = UDim2.new(0, 41, 0, 103)
closeButton.Text = "✕"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 30, 0, 14)
speedLabel.Position = UDim2.new(0, 2, 0, 130)
speedLabel.Text = "50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Helper Functions
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

-- ESP System
local function createESP()
    for _, esp in pairs(espObjects) do
        pcall(function() esp:Destroy() end)
    end
    espObjects = {}
    
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
        box.Transparency = 0.6
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(espObjects, box)
        
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
        nameLabel.TextSize = 12
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = nameTag
        table.insert(espObjects, nameTag)
    end
end

-- Combat Systems (Magic Bullet, 360, Giant, Fly, Rainbow, Speed)
local function setupMagicBullet()
    if magicConnection then magicConnection:Disconnect() end
    magicConnection = RunService.Stepped:Connect(function()
        if not isActive or not currentTarget then return end
        local targetChar = currentTarget.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("bullet") or obj.Name:lower():find("projectile")) then
                if obj.Parent and obj.Parent ~= character then
                    obj.CFrame = CFrame.new(obj.Position, targetRoot.Position)
                end
            end
        end
    end)
end

local function setup360()
    if rotationConnection then rotationConnection:Disconnect() end
    rotationConnection = RunService.Heartbeat:Connect(function()
        if not isActive then return end
        if rootPart then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end
    end)
end

local function setupGiant()
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * SETTINGS.GiantSize
            end
        end
    end
end

local function resetGiant()
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size / SETTINGS.GiantSize
            end
        end
    end
end

local function createFly()
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
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
end

local function setupRainbow()
    if rainbowConnection then rainbowConnection:Disconnect() end
    local hue = 0
    rainbowConnection = RunService.Heartbeat:Connect(function()
        if not isActive then return end
        hue = hue + 0.03
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Color = color
                end
            end
        end
    end)
end

local function startAllSystems()
    isActive = true
    isRunning = true
    setupMagicBullet()
    createESP()
    setup360()
    setupGiant()
    createFly()
    humanoid.WalkSpeed = SETTINGS.SpeedValue
    setupRainbow()
    
    gitButton.Text = "⏹"
    gitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Text = "🟢"
end

local function stopAllSystems()
    isActive = false
    isRunning = false
    
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if magicConnection then magicConnection:Disconnect(); magicConnection = nil end
    if rotationConnection then rotationConnection:Disconnect(); rotationConnection = nil end
    if rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection = nil end
    
    resetGiant()
    humanoid.WalkSpeed = 16
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    
    for _, esp in pairs(espObjects) do
        pcall(function() esp:Destroy() end)
    end
    espObjects = {}
    
    gitButton.Text = "▶"
    gitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    statusLabel.Text = "⏸"
    targetNameLabel.Text = "Yok"
    currentTarget = nil
end

gitButton.MouseButton1Click:Connect(function()
    if isActive then
        stopAllSystems()
    else
        startAllSystems()
        local target = getNearestEnemy()
        if target then
            currentTarget = target
            targetNameLabel.Text = target.Name
        end
    end
end)

closeButton.MouseButton1Click:Connect(function()
    stopAllSystems()
    screenGui:Destroy()
end)

print("[WEAPON SYSTEM]: Successfully initialized.")

