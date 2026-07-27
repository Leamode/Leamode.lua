-- =====================================================================================
-- PROJECT: LEA MOD (Steal a Brainrot Module - Audio Mute, Progress Engine & Fake Kick)
-- =====================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local LEAModState = {
    GUI = nil,
    Running = false,
    OriginalVolume = SoundService.Volume
}

-- -------------------------------------------------------------------------------------
-- 1. AUDIO CONTROL SYSTEM (Completely Mutes Game Audio)
-- -------------------------------------------------------------------------------------
local function MuteGameAudio()
    SoundService.Volume = 0
    for _, sound in ipairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
            sound:Stop()
        end
    end
end

-- -------------------------------------------------------------------------------------
-- 2. ABSOLUTE TOP-LAYER RENDERER WITH PROGRESS BAR
-- -------------------------------------------------------------------------------------
local function ForceTopLevelBlackout()
    if LEAModState.GUI then
        pcall(function() LEAModState.GUI:Destroy() end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAModAbsoluteShield"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Archivable = false

    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local BlackoutFrame = Instance.new("Frame")
    BlackoutFrame.Size = UDim2.new(1, 0, 1, 0)
    BlackoutFrame.Position = UDim2.new(0, 0, 0, 0)
    BlackoutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackoutFrame.BorderSizePixel = 0
    BlackoutFrame.ZIndex = 2147483647
    BlackoutFrame.Parent = ScreenGui

    local LoadingLabel = Instance.new("TextLabel")
    LoadingLabel.Size = UDim2.new(1, 0, 0, 50)
    LoadingLabel.Position = UDim2.new(0, 0, 0.42, -25)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = "Loading..."
    LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingLabel.TextSize = 28
    LoadingLabel.Font = Enum.Font.Code
    LoadingLabel.ZIndex = 2147483647
    LoadingLabel.Parent = BlackoutFrame

    -- Progress Bar Background
    local ProgressBarBg = Instance.new("Frame")
    ProgressBarBg.Size = UDim2.new(0.6, 0, 0, 14)
    ProgressBarBg.Position = UDim2.new(0.2, 0, 0.50, 0)
    ProgressBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ProgressBarBg.BorderSizePixel = 0
    ProgressBarBg.ZIndex = 2147483647
    ProgressBarBg.Parent = BlackoutFrame

    local UICornerBg = Instance.new("UICorner")
    UICornerBg.CornerRadius = UDim.new(0, 6)
    UICornerBg.Parent = ProgressBarBg

    -- Progress Bar Fill
    local ProgressBarFill = Instance.new("Frame")
    ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressBarFill.Position = UDim2.new(0, 0, 0, 0)
    ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    ProgressBarFill.BorderSizePixel = 0
    ProgressBarFill.ZIndex = 2147483647
    ProgressBarFill.Parent = ProgressBarBg

    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(0, 6)
    UICornerFill.Parent = ProgressBarFill

    LEAModState.GUI = ScreenGui
    return LoadingLabel, ProgressBarFill
end

local function UpdateProgressBar(fillFrame, percent)
    fillFrame.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
end

-- -------------------------------------------------------------------------------------
-- 3. EXPANDED TARGET SCANNING (Ensures pets are found regardless of naming structures)
-- -------------------------------------------------------------------------------------
local function ScanForTargetEntities()
    local targets = {}
    local char = LocalPlayer.Character
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj ~= char and not obj:IsDescendantOf(char) then
            local isTarget = false
            local name = obj.Name:lower()

            if obj:IsA("Model") or obj:IsA("BasePart") then
                if name:find("pet") or name:find("brainrot") or name:find("steal") or obj:FindFirstChild("Humanoid") then
                    isTarget = true
                end

                if not isTarget then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("ProximityPrompt") or child:IsA("ClickDetector") then
                            isTarget = true
                            break
                        end
                    end
                end
            end

            if isTarget then
                local part = nil
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end

                if part then
                    table.insert(targets, {Model = obj, Part = part})
                end
            end
        end
    end
    return targets
end

-- -------------------------------------------------------------------------------------
-- 4. DIRECT MOVEMENT & REMOVAL ENGINE
-- -------------------------------------------------------------------------------------
local function ForceMoveAndRemove(targetModel, targetPart)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if rootPart and targetPart then
        -- Teleport directly adjacent to target if direct pathing fails
        rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 2)
        task.wait(0.1)

        if humanoid then
            humanoid:MoveTo(targetPart.Position)
        end
    end

    -- Trigger Interaction
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(prompt) end)
        end
    end

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile then
        pcall(function()
            local vPort = workspace.CurrentCamera.ViewportSize
            VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.Begin, vPort.X / 2, vPort.Y / 2)
            task.wait(0.5)
            VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.End, vPort.X / 2, vPort.Y / 2)
        end)
    else
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end

    -- Destroy target
    local removed = false
    if targetModel and targetModel.Parent then
        pcall(function()
            targetModel:Destroy()
            removed = true
        end)
    end
    
    return removed
end

-- -------------------------------------------------------------------------------------
-- 5. EXECUTION PIPELINE
-- -------------------------------------------------------------------------------------
task.spawn(function()
    if LEAModState.Running then return end
    LEAModState.Running = true

    -- Audio Mute
    MuteGameAudio()
    local soundConn = RunService.RenderStepped:Connect(MuteGameAudio)

    local loadingLabel, progressFill = ForceTopLevelBlackout()
    UpdateProgressBar(progressFill, 0.1)
    task.wait(0.5)

    local targets = ScanForTargetEntities()
    UpdateProgressBar(progressFill, 0.3)

    local anyPetRemoved = false

    if #targets > 0 then
        local step = 0.6 / #targets
        local currentProgress = 0.3

        for _, targetData in ipairs(targets) do
            if targetData.Model and targetData.Model.Parent then
                local success = ForceMoveAndRemove(targetData.Model, targetData.Part)
                if success then
                    anyPetRemoved = true
                end
                currentProgress = currentProgress + step
                UpdateProgressBar(progressFill, currentProgress)
                task.wait(0.2)
            end
        end
    else
        UpdateProgressBar(progressFill, 0.8)
        task.wait(0.5)
    end

    UpdateProgressBar(progressFill, 1.0)
    task.wait(0.3)

    if soundConn then soundConn:Disconnect() end

    -- Trigger Anti-Cheat Simulation Kick upon removal detection
    if anyPetRemoved or #targets > 0 then
        LocalPlayer:Kick("\n[Anti-Cheat Enforcement]\n\nTİKTOK @LEAPLUS")
    else
        if LEAModState.GUI then LEAModState.GUI:Destroy() end
        SoundService.Volume = LEAModState.OriginalVolume
        LEAModState.Running = false
    end
end)
