--[================================================================]--
--            LEA MOD : ADVANCED COMBAT & WEAPON ENGINE             --
--               Full Production Build / Zero Shortcuts             --
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
    TeamCheck = true,
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- State Table for Modules
local States = {
    MagicBullet = false,
    ESP = false,
    Rotation360 = false,
    Giant = false,
    Fly = false,
    Speed = false,
    Rainbow = false,
}

local espObjects = {}
local magicConnection = nil
local rainbowConnection = nil
local rotationConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil

-- UI Interface Initialization
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeaModCombatEngineGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 340)
mainFrame.Position = UDim2.new(1, -190, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "⚡ LEA MOD PRO"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = mainFrame

-- Team and Target Helpers
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

-- 1. ESP Module
local function toggleESP(state)
    States.ESP = state
    for _, esp in pairs(espObjects) do
        pcall(function() esp:Destroy() end)
    end
    espObjects = {}
    
    if not state then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == LocalPlayer then continue end
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        if not otherRoot or not otherHumanoid then continue end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1)
        box.Color3 = Color3.fromRGB(255, 50, 50)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Adornee = otherRoot
        box.ZIndex = 10
        box.Parent = otherRoot
        table.insert(espObjects, box)
        
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 100, 0, 30)
        bill.Adornee = otherRoot
        bill.AlwaysOnTop = true
        bill.Parent = otherRoot
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = otherPlayer.Name
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 11
        txt.Parent = bill
        table.insert(espObjects, bill)
    end
end

-- 2. Magic Bullet Module
local function toggleMagicBullet(state)
    States.MagicBullet = state
    if magicConnection then magicConnection:Disconnect() end
    if not state then return end
    
    magicConnection = RunService.Stepped:Connect(function()
        local target = getNearestEnemy()
        if not target or not target.Character then return end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("bullet") or obj.Name:lower():find("projectile") or obj.Name:lower():find("ammo")) then
                if obj.Parent and obj.Parent ~= character then
                    obj.CFrame = CFrame.new(obj.Position, targetRoot.Position)
                end
            end
        end
    end)
end

-- 3. 360 Spin Module
local function toggle360(state)
    States.Rotation360 = state
    if rotationConnection then rotationConnection:Disconnect() end
    if not state then return end
    
    rotationConnection = RunService.Heartbeat:Connect(function()
        if rootPart then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
        end
    end)
end

-- 4. Giant Potion Module
local function toggleGiant(state)
    States.Giant = state
    if not character then return end
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Size = state and (part.Size * SETTINGS.GiantSize) or (part.Size / SETTINGS.GiantSize)
        end
    end
end

-- 5. Fly & Aim Module
local function toggleFly(state)
    States.Fly = state
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    
    if not state then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        return
    end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    flyConnection = RunService.Heartbeat:Connect(function()
        local target = getNearestEnemy()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = target.Character.HumanoidRootPart
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, tRoot.Position)
            local dir = (tRoot.Position - rootPart.Position)
            if dir.Magnitude > 5 and bodyVelocity then
                bodyVelocity.Velocity = dir.Unit * SETTINGS.FlySpeed
            elseif bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

-- 6. Speed Module
local function toggleSpeed(state)
    States.Speed = state
    humanoid.WalkSpeed = state and SETTINGS.SpeedValue or 16
end

-- 7. Rainbow Module
local function toggleRainbow(state)
    States.Rainbow = state
    if rainbowConnection then rainbowConnection:Disconnect() end
    if not state then return end
    
    local hue = 0
    rainbowConnection = RunService.Heartbeat:Connect(function()
        hue = (hue + 0.04) % 1
        local col = Color3.fromHSV(hue, 1, 1)
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then part.Color = col end
            end
        end
    end)
end

-- UI Element Builder for Toggles
local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Text = name .. " : KAPALI"
    btn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = name .. (active and " : AÇIK" or " : KAPALI")
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(35, 35, 45)
        callback(active)
    end)
end

CreateButton("Magic Bullet", 35, toggleMagicBullet)
CreateButton("ESP Göster", 72, toggleESP)
CreateButton("360 Dönüş", 109, toggle360)
CreateButton("Dev Boyut (Giant)", 146, toggleGiant)
CreateButton("Uçma & Hedef (Fly)", 183, toggleFly)
CreateButton("Hız (Speed)", 220, toggleSpeed)
CreateButton("Rainbow Efekt", 257, toggleRainbow)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.9, 0, 0, 32)
closeBtn.Position = UDim2.new(0.05, 0, 0, 294)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Text = "SİSTEMİ KAPAT & TEMİZLE"
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    toggleMagicBullet(false)
    toggleESP(false)
    toggle360(false)
    toggleGiant(false)
    toggleFly(false)
    toggleSpeed(false)
    toggleRainbow(false)
    screenGui:Destroy()
end)

print("[LEA MOD PRO]: System initialized successfully with zero limitations.")
