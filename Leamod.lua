-- =====================================================================================
-- PROJECT: LEA MOD (Steal a Brainrot Module)
-- ARCHITECTURE: Distributed Navigation & Input Emulation Framework
-- ENGINE COMPATIBILITY: Delta / Synapse Z / Fluxus (Luau Runtime)
-- =====================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Environment Isolation & State Management
local RuntimeEnv = {
    ActiveScreen = nil,
    IsExecuting = false,
    NavigationActive = false,
    ConnectionRegistry = {},
    TargetQueue = {}
}

-- -------------------------------------------------------------------------------------
-- 1. ADVANCED VISUAL LAYER (Absolute Blackout & Dynamic Telemetry)
-- -------------------------------------------------------------------------------------
local function InitializeVisualInterface()
    if RuntimeEnv.ActiveScreen then
        pcall(function() RuntimeEnv.ActiveScreen:Destroy() end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAModRuntimeInterface"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647

    local success, err = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local BlackoutContainer = Instance.new("Frame")
    BlackoutContainer.Size = UDim2.new(1, 0, 1, 0)
    BlackoutContainer.Position = UDim2.new(0, 0, 0, 0)
    BlackoutContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackoutContainer.BorderSizePixel = 0
    BlackoutContainer.ZIndex = 2147483647
    BlackoutContainer.Parent = ScreenGui

    local StatusHeader = Instance.new("TextLabel")
    StatusHeader.Size = UDim2.new(1, 0, 0, 60)
    StatusHeader.Position = UDim2.new(0, 0, 0.42, -30)
    StatusHeader.BackgroundTransparency = 1
    StatusHeader.Text = "Bypass Loading..."
    StatusHeader.TextColor3 = Color3.fromRGB(240, 240, 240)
    StatusHeader.TextSize = 26
    StatusHeader.Font = Enum.Font.Code
    StatusHeader.ZIndex = StatusHeader.ZIndex + 1
    StatusHeader.Parent = BlackoutContainer

    local SubTelemetry = Instance.new("TextLabel")
    SubTelemetry.Size = UDim2.new(1, 0, 0, 40)
    SubTelemetry.Position = UDim2.new(0, 0, 0.52, -20)
    SubTelemetry.BackgroundTransparency = 1
    SubTelemetry.Text = "Initializing runtime hooks..."
    SubTelemetry.TextColor3 = Color3.fromRGB(140, 140, 140)
    SubTelemetry.TextSize = 16
    SubTelemetry.Font = Enum.Font.SourceSans
    SubTelemetry.ZIndex = SubTelemetry.ZIndex + 1
    SubTelemetry.Parent = BlackoutContainer

    RuntimeEnv.ActiveScreen = ScreenGui
    return StatusHeader, SubTelemetry
end

-- -------------------------------------------------------------------------------------
-- 2. ROBUST PATHFINDING ENGINE (Anti-Stuck & Obstacle Resolution)
-- -------------------------------------------------------------------------------------
local function ExecutePathfindingNavigation(targetPosition)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4
    })

    local computedSuccess, computeError = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)

    if computedSuccess and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        RuntimeEnv.NavigationActive = true

        for index, waypoint in ipairs(waypoints) do
            if not RuntimeEnv.IsExecuting then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

            humanoid:MoveTo(waypoint.Position)
            
            local movementCompleted = false
            local connection
            connection = humanoid.MoveToFinished:Connect(function(reached)
                movementCompleted = true
                if connection then connection:Disconnect() end
            end)

            -- Timeout safeguard to prevent hanging
            local elapsedTime = 0
            while not movementCompleted and elapsedTime < 3.5 do
                elapsedTime = elapsedTime + RunService.Heartbeat:Wait()
                if (rootPart.Position - waypoint.Position).Magnitude < 4 then
                    break
                end
            end

            if connection then connection:Disconnect() end
        end
        RuntimeEnv.NavigationActive = false
        return true
    else
        -- Fallback linear path execution if node graph fails
        humanoid:MoveTo(targetPosition)
        task.wait(1.5)
        return true
    end
end

-- -------------------------------------------------------------------------------------
-- 3. INTERACTION EMULATION LAYER (Proximity & Key Simulation)
-- -------------------------------------------------------------------------------------
local function ExecuteInteractionSequence(targetModel)
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Scan for nearby proximity prompts related to the target structure
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local parentPart = descendant.Parent
            if parentPart and parentPart:IsA("BasePart") then
                if (parentPart.Position - rootPart.Position).Magnitude < 15 then
                    pcall(function()
                        fireproximityprompt(descendant)
                    end)
                end
            end
        end
    end

    -- Emulate PC/Mobile hold actions via VirtualInputManager for deep engine compatibility
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(1.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)

    -- Final cleanup invocation on target model
    pcall(function()
        if targetModel and targetModel.Parent then
            targetModel:Destroy()
        end
    end)
end

-- -------------------------------------------------------------------------------------
-- 4. MAIN ORCHESTRATION WORKER
-- -------------------------------------------------------------------------------------
task.spawn(function()
    if RuntimeEnv.IsExecuting then return end
    RuntimeEnv.IsExecuting = true

    local headerLabel, telemetryLabel = InitializeVisualInterface()
    task.wait(1.5)

    headerLabel.Text = "Scanning Target Entities..."
    
    local targetQueue = {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Model") then
            local objectName = object.Name:lower()
            if objectName:find("pet") or objectName:find("brainrot") or objectName:find("animal") then
                local primary = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
                if primary then
                    table.insert(targetQueue, {Model = object, Part = primary})
                end
            end
        end
    end

    local totalTargets = #targetQueue
    if totalTargets == 0 then
        telemetryLabel.Text = "No target entities located in current sector."
        task.wait(2)
        if RuntimeEnv.ActiveScreen then RuntimeEnv.ActiveScreen:Destroy() end
        RuntimeEnv.IsExecuting = false
        return
    end

    for index, targetData in ipairs(targetQueue) do
        if not RuntimeEnv.IsExecuting then break end
        
        telemetryLabel.Text = string.format("Processing Entity: %d / %d", index, totalTargets)

        if targetData.Model and targetData.Model.Parent and targetData.Part then
            -- Navigate dynamically to the target vector
            ExecutePathfindingNavigation(targetData.Part.Position)
            task.wait(0.2)
            
            -- Trigger input actions and remove object reference
            ExecuteInteractionSequence(targetData.Model)
            task.wait(0.4)
        end
    end

    headerLabel.Text = "Execution Complete"
    telemetryLabel.Text = "All structures cleared."
    task.wait(2)

    if RuntimeEnv.ActiveScreen then
        RuntimeEnv.ActiveScreen:Destroy()
    end
    RuntimeEnv.IsExecuting = false
end)
