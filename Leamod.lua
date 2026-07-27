-- =====================================================================================
-- PROJECT: LEA MOD (Steal a Brainrot Module - Universal Compatibility & Safe Fallback)
-- =====================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- Executor Safe ProximityPrompt Triggering
local function SafeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- Audio Mute Routine
local function MuteAudio()
    pcall(function()
        SoundService.Volume = 0
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") then
                s.Volume = 0
                s:Stop()
            end
        end
    end)
end

-- UI Engine with Error Handling
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAModShield"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 2147483647

    local parented = pcall(function() ScreenGui.Parent = CoreGui end)
    if not parented or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 50)
    Label.Position = UDim2.new(0, 0, 0.4, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Loading..."
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 28
    Label.Font = Enum.Font.Code

    local BarBg = Instance.new("Frame", Frame)
    BarBg.Size = UDim2.new(0.6, 0, 0, 12)
    BarBg.Position = UDim2.new(0.2, 0, 0.5, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBg.BorderSizePixel = 0

    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 220, 110)
    BarFill.BorderSizePixel = 0

    return ScreenGui, BarFill
end

-- Main Task Execution
task.spawn(function()
    MuteAudio()
    local soundLoop = RunService.RenderStepped:Connect(MuteAudio)

    local gui, progress = CreateUI()
    progress.Size = UDim2.new(0.3, 0, 1, 0)
    task.wait(0.5)

    local targetFound = false
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)

    -- Broad Search Logic for Entities
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item ~= char and not item:IsDescendantOf(char) then
            local lowerName = item.Name:lower()
            if lowerName:find("pet") or lowerName:find("brainrot") or lowerName:find("steal") or item:FindFirstChildOfClass("Humanoid") then
                targetFound = true
                
                local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if targetPart and root then
                    -- Move to target
                    pcall(function() root.CFrame = targetPart.CFrame * CFrame.new(0, 0, 2) end)
                    task.wait(0.2)
                end

                -- Intercept ProximityPrompts
                for _, p in ipairs(item:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        SafeFirePrompt(p)
                    end
                end

                -- Direct Destroy Attempt
                pcall(function() item:Destroy() end)
            end
        end
    end

    progress.Size = UDim2.new(1, 0, 1, 0)
    task.wait(0.4)

    if soundLoop then soundLoop:Disconnect() end

    -- Kick trigger upon task completion
    if targetFound then
        LocalPlayer:Kick("\n[Anti-Cheat Enforcement]\n\nTİKTOK @LEAPLUS")
    else
        -- Fallback kick if objects are already processed
        LocalPlayer:Kick("\n[Anti-Cheat Enforcement]\n\nTİKTOK @LEAPLUS")
    end
end)
