--[[\
    Project: LEA MOD (Universal Gun Mod Edition - Final Clean Build)
    Target: Universal Roblox FPS / Shooter Games
    Environment: Roblox Luau
]]--

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
    SpeedVal = 16,
    HitboxSize = 2,
    MenuVisible = true
}

-- Cleanup existing GUI if re-executed
if CoreGui:FindFirstChild("LEAModUniversalGui") then
    CoreGui.LEAModUniversalGui:Destroy()
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModUniversalGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- LEA MOD Header Label (Top Center Above Crosshair)
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

-- Draggable Main Menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.75, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 190, 0, 350)
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

-- UI List Layout for Features
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- Helper function to create feature toggles
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

createButton("Aimbot", "Aimbot")
createButton("ESP", "ESP")
createButton("360 Spin", "Spin360")
createButton("Rainbow", "Rainbow")
createButton("Inf Jump", "InfJump")
createButton("Teleport", "Teleport")
createButton("Fly", "Fly")

-- Speed Controls Frame
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
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal - 2, 16, 200)
end)

SpeedInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal + 2, 16, 200)
end)

-- Hitbox Controls Frame (Up to 300)
local HitboxFrame = Instance.new("Frame")
HitboxFrame.Parent = MainFrame
HitboxFrame.BackgroundTransparency = 1
HitboxFrame.Size = UDim2.new(1, 0, 0, 25)

local HitboxDec = Instance.new("TextButton")
HitboxDec.Parent = HitboxFrame
HitboxDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
HitboxDec.Size = UDim2.new(0.5, 0, 1, 0)
HitboxDec.Font = Enum.Font.SourceSansBold
HitboxDec.Text = "Hitbox -"
HitboxDec.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxDec.TextSize = 12

local HitboxInc = Instance.new("TextButton")
HitboxInc.Parent = HitboxFrame
HitboxInc.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
HitboxInc.Position = UDim2.new(0.5, 0, 0, 0)
HitboxInc.Size = UDim2.new(0.5, 0, 1, 0)
HitboxInc.Font = Enum.Font.SourceSansBold
HitboxInc.Text = "Hitbox +"
HitboxInc.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxInc.TextSize = 12

HitboxDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.HitboxSize = math.clamp(getgenv().LEAModState.HitboxSize - 5, 2, 300)
end)

HitboxInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.HitboxSize = math.clamp(getgenv().LEAModState.HitboxSize + 5, 2, 300)
end)

-- Helper: Strict Enemy Check
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

-- 1. PERFECTED AIMBOT LOGIC (Right-click hold, zero smoothness, exact center locking)
RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestTarget = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = rootPart
                    end
                end
            end
        end

        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end
end)

-- 2. ESP LOGIC (BoxHandleAdornment, Name, HP, Distance, Team Color, AlwaysOnTop)
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

-- 3. HITBOX EXPANDER LOGIC (Enemies only, invisible size expansion up to 300)
RunService.RenderStepped:Connect(function()
    local targetSize = getgenv().LEAModState.HitboxSize
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            root.Size = Vector3.new(targetSize, targetSize, targetSize)
            root.Transparency = 1
            root.CanCollide = false
        end
    end
end)

-- 4. 360 SPIN LOGIC
RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Spin360 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0)
    end
end)

-- 5. RAINBOW (HSV Color Cycle)
RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Rainbow and LocalPlayer.Character then
        local hue = tick() % 5 / 5
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = rainbowColor
            end
        end
    end
end)

-- 6. INFINITE JUMP LOGIC
UserInputService.JumpRequest:Connect(function()
    if getgenv().LEAModState.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 7. TELEPORT BEHIND NEAREST ENEMY (Enemies only)
RunService.Heartbeat:Connect(function()
    if getgenv().LEAModState.Teleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local closestTarget = nil
        local shortestDistance = math.huge
        local myRoot = LocalPlayer.Character.HumanoidRootPart

        for _, player in ipairs(Players:GetPlayers()) do
            if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestTarget = player.Character.HumanoidRootPart
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
    end
end)

-- 8. FLY LOGIC (WASD + Space/Shift)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if getgenv().LEAModState.Fly and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.PlatformStand = true
        
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

-- 9. SPEED LOGIC
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().LEAModState.SpeedVal
    end
end)
