--[=[
    Project: LEA MOD - Clean Stable Admin Suite
    Platform: Delta Mobile / Luau Environment
]=--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

function Functions.freezePlayer(target)
    if not target or not target.Character then return end
    for _, p in ipairs(target.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored = true end
    end
end

function Functions.unfreezePlayer(target)
    if not target or not target.Character then return end
    for _, p in ipairs(target.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored = false end
    end
end

function Functions.startOrbitFling()
    if DATA.OrbitConn then DATA.OrbitConn:Disconnect() end
    local angle = 0
    DATA.OrbitConn = RunService.Heartbeat:Connect(function(dt)
        if not DATA.States.OrbitFling then return end
        local target = DATA.SelectedPlayer
        if not target or not target.Character then return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local lChar = LocalPlayer.Character
        if not tHRP or not lChar then return end
        local lHRP = lChar:FindFirstChild("HumanoidRootPart")
        local lHum = lChar:FindFirstChildOfClass("Humanoid")
        if not lHRP or not lHum then return end

        lHum.PlatformStand = true
        angle = angle + (dt * 40)
        local offset = Vector3.new(math.cos(angle) * 3, 1, math.sin(angle) * 3)
        lHRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
        lHRP.AssemblyLinearVelocity = Vector3.new(math.random(-15000, 15000), 25000, math.random(-15000, 15000))
        lHRP.AssemblyAngularVelocity = Vector3.new(50000, 50000, 50000)
    end)
end

function Functions.stopOrbitFling()
    if DATA.OrbitConn then DATA.OrbitConn:Disconnect(); DATA.OrbitConn = nil end
    local lChar = LocalPlayer.Character
    if lChar then
        local lHum = lChar:FindFirstChildOfClass("Humanoid")
        local lHRP = lChar:FindFirstChild("HumanoidRootPart")
        if lHum then lHum.PlatformStand = false end
        if lHRP then lHRP.AssemblyLinearVelocity = Vector3.zero lHRP.AssemblyAngularVelocity = Vector3.zero end
    end
end

function Functions.startFly()
    if DATA.FlyConn then DATA.FlyConn:Disconnect() end
    DATA.FlyConn = RunService.Heartbeat:Connect(function()
        if DATA.States.OrbitFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not hrp then return end

        local move = Vector3.zero
        if DATA.FlyDir.Forward then move = move + cam.CFrame.LookVector end
        if DATA.FlyDir.Backward then move = move - cam.CFrame.LookVector end
        if DATA.FlyDir.Left then move = move - cam.CFrame.RightVector end
        if DATA.FlyDir.Right then move = move + cam.CFrame.RightVector end
        if DATA.FlyDir.Up then move = move + Vector3.new(0, 1, 0) end
        if DATA.FlyDir.Down then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = move.Unit * 60
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

function Functions.stopFly()
    if DATA.FlyConn then DATA.FlyConn:Disconnect(); DATA.FlyConn = nil end
end

function Functions.startNoClip()
    if DATA.NoClipConn then DATA.NoClipConn:Disconnect() end
    DATA.NoClipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

function Functions.stopNoClip()
    if DATA.NoClipConn then DATA.NoClipConn:Disconnect(); DATA.NoClipConn = nil end
end

function Functions.startGod()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.MaxHealth = math.huge hum.Health = math.huge end
end

function Functions.startESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxiomESP") then
            local hl = Instance.new("Highlight")
            hl.Name = "AxiomESP"
            hl.Adornee = p.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.Parent = p.Character
        end
    end
end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiomAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 440)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "LEA MOD | Admin Panel"
TitleLabel.Parent = TitleBar

-- Minimize & Close Buttons
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -70, 0.5, -15)
MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Text = "-"
MinButton.Font = Enum.Font.GothamBold
MinButton.Parent = TitleBar
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 6)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Content Scrolling Area
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 700)
ContentScroll.ScrollBarThickness = 4
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = ContentScroll

-- Minimize toggle logic
local minimized = false
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentScroll.Visible = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {
        Size = minimized and UDim2.new(0, 320, 0, 45) or UDim2.new(0, 320, 0, 440)
    }):Play()
    MinButton.Text = minimized and "+" : "-"
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable functionality
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Selected Player Label
local selLabel = Instance.new("TextLabel")
selLabel.Size = UDim2.new(1, 0, 0, 35)
selLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
selLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
selLabel.Font = Enum.Font.GothamSemibold
selLabel.TextSize = 13
selLabel.Text = "Selected: None"
selLabel.Parent = ContentScroll
Instance.new("UICorner", selLabel).CornerRadius = UDim.new(0, 6)

-- Player List Frame
local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 90)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.Parent = ContentScroll
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 6)

local PlayerListLay = Instance.new("UIListLayout")
PlayerListLay.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLay.Padding = UDim.new(0, 3)
PlayerListLay.Parent = PlayerScroll

local function updatePlayers()
    for _, c in ipairs(PlayerScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -4, 0, 24)
            pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 12
            pBtn.Text = p.Name
            pBtn.Parent = PlayerScroll
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                DATA.SelectedPlayer = p
                selLabel.Text = "Selected: " .. p.Name
                for _, b in ipairs(PlayerScroll:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 42) end
                end
                pBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
            end)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListLay.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)
updatePlayers()

local function addButton(txt, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = txt
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

addButton("Freeze Selected", Color3.fromRGB(55, 55, 75), function()
    if DATA.SelectedPlayer then Functions.freezePlayer(DATA.SelectedPlayer) end
end)

addButton("Unfreeze Selected", Color3.fromRGB(55, 55, 75), function()
    if DATA.SelectedPlayer then Functions.unfreezePlayer(DATA.SelectedPlayer) end
end)

local function addToggle(txt, key, onEnable, onDisable)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = txt .. ": OFF"
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        DATA.States[key] = not DATA.States[key]
        if DATA.States[key] then
            btn.Text = txt .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(35, 140, 70)
            onEnable()
        else
            btn.Text = txt .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            onDisable()
        end
    end)
end

addToggle("Orbit Fling", "OrbitFling", Functions.startOrbitFling, Functions.stopOrbitFling)
addToggle("Fly Mode", "Fly", Functions.startFly, Functions.stopFly)
addToggle("NoClip", "NoClip", Functions.startNoClip, Functions.stopNoClip)
addToggle("God Mode", "God", Functions.startGod, function() end)
addToggle("Player ESP", "ESP", Functions.startESP, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("AxiomESP") then p.Character.AxiomESP:Destroy() end
    end
end)

-- Fly Controls Grid
local Grid = Instance.new("Frame")
Grid.Size = UDim2.new(1, 0, 0, 75)
Grid.BackgroundTransparency = 1
Grid.Parent = ContentScroll

local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0.32, 0, 0, 32)
GridLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
GridLayout.Parent = Grid

for _, dir in ipairs({"Forward", "Backward", "Left", "Right", "Up", "Down"}) do
    local fBtn = Instance.new("TextButton")
    fBtn.Size = UDim2.new(0,0,0,0)
    fBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.Font = Enum.Font.GothamBold
    fBtn.TextSize = 11
    fBtn.Text = dir
    fBtn.Parent = Grid
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)

    fBtn.MouseButton1Down:Connect(function() DATA.FlyDir[dir] = true fBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 140) end)
    fBtn.MouseButton1Up:Connect(function() DATA.FlyDir[dir] = false fBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70) end)
end
