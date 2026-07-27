-- =====================================================================================
-- PROJECT: LEA MOD (Steal a Brainrot Module - Enhanced Platform Vector Engine)
-- =====================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Runtime State Table
local RuntimeState = {
    ScreenGui = nil,
    IsActive = false
}

-- -------------------------------------------------------------------------------------
-- 1. ABSOLUTE SCREEN BLACKOUT LAYER (Un-bypassable Z-Index Overload)
-- -------------------------------------------------------------------------------------
local function SetupBlackoutInterface()
    if RuntimeState.ScreenGui then
        pcall(function() RuntimeState.ScreenGui:Destroy() end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAModSecureContainer"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
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
    LoadingLabel.Size = UDim2.new(1, 0, 0, 60)
    LoadingLabel.Position = UDim2.new(0, 0, 0.48, -30)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = "Loading..."
    LoadingLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    LoadingLabel.TextSize = 24
    LoadingLabel.Font = Enum.Font.Code
    LoadingLabel.ZIndex = 2147483647
    LoadingLabel.Parent = BlackoutFrame

    RuntimeState.ScreenGui = ScreenGui
    return LoadingLabel
end

-- -------------------------------------------------------------------------------------
-- 2. ACCURATE PATHFINDING VECTOR OVERRIDE (Fixes orientation / look direction bugs)
-- -------------------------------------------------------------------------------------
local function AccurateNavigateTo(targetVector)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 3
    })

    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, targetVector)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            -- Force character look vector towards waypoint to prevent misalignment
            local lookDirection = (waypoint.Position - rootPart.Position) * Vector3.new(1, 0, 1)
            if lookDirection.Magnitude > 0.1 then
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookDirection)
            end

            humanoid:MoveTo(waypoint.Position)
            
            local reached = false
            local conn
            conn = humanoid.MoveToFinished:Connect(function(isReached)
                reached = true
                if conn then conn:Disconnect() end
            end)

            local timer = 0
            while not reached and timer < 3 do
                timer = timer + RunService.Heartbeat:Wait()
                if (rootPart.Position - waypoint.Position).Magnitude < 3.5 then
                    break
                end
            end
            if conn then conn:Disconnect() end
        end
        return true
    else
        humanoid:MoveTo(targetVector)
        task.wait(1.5)
        return true
    end
end

-- -------------------------------------------------------------------------------------
-- 3. PLATFORM-AWARE INPUT EMULATION (PC vs Mobile Detection)
-- -------------------------------------------------------------------------------------
local function ExecutePlatformInteraction(targetModel)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- ProximityPrompt validation loop
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parentPart = prompt.Parent
            if parentPart and parentPart:IsA("BasePart") then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and (parentPart.Position - rootPart.Position).Magnitude < 12 then
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                end
            end
        end
    end

    if isMobile then
        -- Mobile touch-hold execution emulation
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(1.2)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    else
        -- PC Keybind (E / Backspace / Delete depending on asset mapping) execution
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(1.2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end

    -- Direct destruction fallback to ensure removal
    pcall(function()
        if targetModel and targetModel.Parent then
            targetModel:Destroy()
        end
    end)
end

-- -------------------------------------------------------------------------------------
-- 4. MAIN THREAD EXECUTION LOOP
-- -------------------------------------------------------------------------------------
task.spawn(function()
    if RuntimeState.IsActive then return end
    RuntimeState.IsActive = true

    local loadingLabel = SetupBlackoutInterface()
    task.wait(1)

    -- Filter specifically for player-owned or active pets/brainrot models in workspace
    local petQueue = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("pet") or name:find("brainrot") then
                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    table.insert(petQueue, {Model = obj, Part = primaryPart})
                end
            end
        end
    end

    if #petQueue == 0 then
        loadingLabel.Text = "Loading..."
        task.wait(2)
        if RuntimeState.ScreenGui then RuntimeState.ScreenGui:Destroy() end
        RuntimeState.IsActive = false
        return
    end

    for _, petData in ipairs(petQueue) do
        if petData.Model and petData.Model.Parent and petData.Part then
            AccurateNavigateTo(petData.Part.Position)
            task.wait(0.2)
            ExecutePlatformInteraction(petData.Model)
            task.wait(0.4)
        end
    end

    loadingLabel.Text = "Loading..."
    task.wait(1.5)

    if RuntimeState.ScreenGui then
        RuntimeState.ScreenGui:Destroy()
    end
    RuntimeState.IsActive = false
end)
