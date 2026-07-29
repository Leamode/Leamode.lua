--[=[
    Project: LEA MOD - Kinetic Orbit Fling System
    Platform: Delta Mobile / Luau Environment
    Description: Physics-based rotational orbit system that forces high-velocity 
                 impacts upon collision with the target player's character.
]=--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

getgenv().__DATA = getgenv().__DATA or {}
local DATA = getgenv().__DATA

DATA.SelectedPlayer = nil
DATA.States = {
    Fly = false,
    NoClip = false,
    God = false,
    ESP = false,
    OrbitFling = false
}

DATA.FlyDir = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

if CoreGui:FindFirstChild("AxiomAdminGui") then
    CoreGui.AxiomAdminGui:Destroy()
end

local Functions = {}

function Functions.freezePlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
end

function Functions.unfreezePlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

-- Kinetic Orbit Fling Implementation
function Functions.startOrbitFling()
    if DATA.OrbitConnection then DATA.OrbitConnection:Disconnect() end
    
    local angle = 0
    DATA.OrbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not DATA.States.OrbitFling then return end
        local target = DATA.SelectedPlayer
        if not target or not target.Character then return end
        
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        if not targetHRP or not localChar then return end
        
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        local localHum = localChar:FindFirstChildOfClass("Humanoid")
        if not localHRP or not localHum then return end
        
        -- Enable platform stand to let physics engines apply forces without interference
        localHum.PlatformStand = true
        
        -- Calculate high-speed circular orbit coordinates around target
        angle = angle + (dt * 35) -- Rotation speed multiplier
        local radius = 3.5 -- Distance tight enough to guarantee continuous hitbox collision
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        
        local targetPos = targetHRP.Position
        local newPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + 1.5, targetPos.Z + offsetZ)
        
        -- Apply extreme rotational velocity and kinetic positioning force
        localHRP.CFrame = CFrame.new(newPos, targetPos)
        localHRP.AssemblyLinearVelocity = Vector3.new(math.random(-8000, 8000), 15000, math.random(-8000, 8000))
        localHRP.AssemblyAngularVelocity = Vector3.new(50000, 50000, 50000)
    end)
end

function Functions.stopOrbitFling()
    if DATA.OrbitConnection then
        DATA.OrbitConnection:Disconnect()
        DATA.OrbitConnection = nil
    end
    local localChar = LocalPlayer.Character
    if localChar then
        local localHum = localChar:FindFirstChildOfClass("Humanoid")
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if localHum then localHum.PlatformStand = false end
        if localHRP then
            localHRP.AssemblyLinearVelocity = Vector3.zero
            localHRP.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

function Functions.startFly()
    if DATA.FlyConnection then DATA.FlyConnection:Disconnect() end
    DATA.FlyConnection = RunService.Heartbeat:Connect(function()
        if DATA.States.OrbitFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not hrp then return end

        local moveVector = Vector3.zero
        if DATA.FlyDir.Forward then moveVector = moveVector + cam.CFrame.LookVector end
        if DATA.FlyDir.Backward then moveVector = moveVector - cam.CFrame.LookVector end
        if DATA.FlyDir.Left then moveVector = moveVector - cam.CFrame.RightVector end
        if DATA.FlyDir.Right then moveVector = moveVector + cam.CFrame.RightVector end
        if DATA.FlyDir.Up then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if DATA.FlyDir.Down then moveVector = moveVector - Vector3.new(0, 1, 0) end

        if moveVector.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = moveVector.Unit * 60
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

function Functions.stopFly()
    if DATA.FlyConnection then
        DATA.FlyConnection:Disconnect()
        DATA.FlyConnection = nil
    end
end

function Functions.startNoClip()
    if DATA.NoClipConnection then DATA.NoClipConnection:Disconnect() end
    DATA.NoClipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function Functions.stopNoClip()
    if DATA.NoClipConnection then
        DATA.NoClipConnection:Disconnect()
        DATA.NoClipConnection = nil
    end
end

function Functions.startGod()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

function Functions.startESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not player.Character:FindFirstChild("AxiomESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "AxiomESP"
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
            end
        end
    end
end

function Functions.findMoney()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("money") or name:find("cash") or name:find("coin") or name:find("gold") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer(99999999999)
                    elseif obj:IsA("RemoteFunction") then
                        obj:InvokeServer(99999999999)
                    end
                end)
                count = count + 1
            end
        end
    end
    return count
end

DATA.Functions = Functions

-- GUI Layer Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiomAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "LEA MOD | Admin Panel"
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.Parent = TitleBar

Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -55)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 48)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 820)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

local selLabel = Instance.new("TextLabel")
selLabel.Size = UDim2.new(1, 0, 0, 35)
selLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
selLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
selLabel.TextSize = 14
selLabel.Font = Enum.Font.GothamSemibold
selLabel.Text = "Selected: None"
selLabel.Parent = ScrollingFrame
Instance.new("UICorner", selLabel).CornerRadius = UDim.new(0, 6)

local PlayerListContainer = Instance.new("ScrollingFrame")
PlayerListContainer.Size = UDim2.new(1, 0, 0, 100)
PlayerListContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PlayerListContainer.BorderSizePixel = 0
PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListContainer.ScrollBarThickness = 3
PlayerListContainer.Parent = ScrollingFrame
Instance.new("UICorner", PlayerListContainer).CornerRadius = UDim.new(0, 6)

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerListContainer

local function refreshPlayers()
    for _, child in ipairs(PlayerListContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -6, 0, 25)
            pBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 13
            pBtn.Font = Enum.Font.Gotham
            pBtn.Text = player.Name
            pBtn.Parent = PlayerListContainer
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                DATA.SelectedPlayer = player
                selLabel.Text = "Selected: " .. player.Name
                for _, b in ipairs(PlayerListContainer:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
                end
                pBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            end)
        end
    end
    PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

local function createButton(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.Parent = ScrollingFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("Freeze Selected", Color3.fromRGB(70, 70, 90), function()
    if DATA.SelectedPlayer then Functions.freezePlayer(DATA.SelectedPlayer) end
end)

createButton("Unfreeze Selected", Color3.fromRGB(70, 70, 90), function()
    if DATA.SelectedPlayer then Functions.unfreezePlayer(DATA.SelectedPlayer) end
end)

-- Toggle for Kinetic Orbit Fling
local function createToggle(name, stateKey, onEnable, onDisable)
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(1, 0, 0, 35)
    tBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tBtn.TextSize = 14
    tBtn.Font = Enum.Font.GothamBold
    tBtn.Text = name .. ": OFF"
    tBtn.Parent = ScrollingFrame
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)

    tBtn.MouseButton1Click:Connect(function()
        DATA.States[stateKey] = not DATA.States[stateKey]
        if DATA.States[stateKey] then
            tBtn.Text = name .. ": ON"
            tBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
            onEnable()
        else
            tBtn.Text = name .. ": OFF"
            tBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            onDisable()
        end
    end)
end

createToggle("Orbit Fling Selected", "OrbitFling", Functions.startOrbitFling, Functions.stopOrbitFling)
createToggle("Fly Mode", "Fly", Functions.startFly, Functions.stopFly)
createToggle("NoClip", "NoClip", Functions.startNoClip, Functions.stopNoClip)
createToggle("God Mode", "God", Functions.startGod, function() end)
createToggle("Player ESP", "ESP", Functions.startESP, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("AxiomESP") then
            p.Character.AxiomESP:Destroy()
        end
    end
end)

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, 0, 0, 80)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = ScrollingFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0.32, 0, 0, 35)
UIGrid.CellPadding = UDim2.new(0.02, 0, 0, 8)
UIGrid.Parent = GridFrame

local directions = {"Forward", "Backward", "Left", "Right", "Up", "Down"}
for _, dir in ipairs(directions) do
    local fBtn = Instance.new("TextButton")
    fBtn.Size = UDim2.new(0,0,0,0)
    fBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.TextSize = 12
    fBtn.Font = Enum.Font.GothamBold
    fBtn.Text = dir
    fBtn.Parent = GridFrame
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)

    fBtn.MouseButton1Down:Connect(function() DATA.FlyDir[dir] = true fBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150) end)
    fBtn.MouseButton1Up:Connect(function() DATA.FlyDir[dir] = false fBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end)
end

createButton("Find & Exploit Money Remotes", Color3.fromRGB(210, 140, 30), function()
    local count = Functions.findMoney()
    selLabel.Text = "Exploited remotes count: " .. tostring(count)
end)
