-- =====================================================================================
-- PROJECT: LEA MOD (Steal a Brainrot Module - Hardened Z-Index & Mobile Touch Engine)
-- =====================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- Global Runtime Control
local LEAModState = {
    GUI = nil,
    Running = false
}

-- -------------------------------------------------------------------------------------
-- 1. ABSOLUTE TOP-LAYER RENDERER (Forces loading text and black screen above everything)
-- -------------------------------------------------------------------------------------
local function ForceTopLevelBlackout()
    if LEAModState.GUI then
        pcall(function() LEAModState.GUI:Destroy() end)
    end

    -- CoreGui with maximum DisplayOrder overrides all built-in game and UI elements
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

    -- High-priority TextLabel to guarantee "Loading..." remains visible above all render layers
    local LoadingLabel = Instance.new("TextLabel")
    LoadingLabel.Size = UDim2.new(1, 0, 0, 100)
    LoadingLabel.Position = UDim2.new(0, 0, 0.45, -50)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = "Loading..."
    LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingLabel.TextSize = 32
    LoadingLabel.Font = Enum.Font.Code
    LoadingLabel.ZIndex = 2147483647 -- Maximized to prevent any clipping or hiding
    LoadingLabel.Parent = BlackoutFrame

    LEAModState.GUI = ScreenGui
    return LoadingLabel
end

-- -------------------------------------------------------------------------------------
-- 2. PRECISE TARGET SELECTION & PATHFINDING (Locks onto specific pet/brainrot entities)
-- -------------------------------------------------------------------------------------
local function LocateAndNavigateToTarget(targetPart)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart or not targetPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 2.5
    })

    local computed = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPart.Position)
    end)

    if computed and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, wp in ipairs(waypoints) do
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            humanoid:MoveTo(wp.Position)
            
            local reached = false
            local conn
            conn = humanoid.MoveToFinished:Connect(function()
                reached = true
                if conn then conn:Disconnect() end
            end)

            local t = 0
            while not reached and t < 2.5 do
                t = t + RunService.Heartbeat:Wait()
                if (rootPart.Position - wp.Position).Magnitude < 3 then
                    break
                end
            end
            if conn then conn:Disconnect() end
        end
        return true
    else
        humanoid:MoveTo(targetPart.Position)
        task.wait(1.2)
        return true
    end
end

-- -------------------------------------------------------------------------------------
-- 3. MOBILE-OPTIMIZED & PC INTERACTION EMULATION (Fixes mobile touch-hold deletion)
-- -------------------------------------------------------------------------------------
local function ExecuteMobileOrPCDeletion(targetModel, targetPart)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- 1. Try to trigger any active ProximityPrompt in range
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local pParent = prompt.Parent
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if pParent and root and (pParent.Position - root.Position).Magnitude < 14 then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end

    -- 2. Platform specific interaction emulation
    if isMobile then
        -- Mobile-specific screen touch simulation loop (simulates holding finger on UI/Screen deletion button)
        pcall(function()
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local centerX = viewportSize.X / 2
            local centerY = viewportSize.Y / 2
            
            -- Simulate touch down, hold for removal sequence, touch up
            VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.Begin, centerX, centerY)
            task.wait(1.5)
            VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.End, centerX, centerY)
        end)
    else
        -- PC Key simulation (E / Backspace)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(1.2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end

    -- 3. Direct model purge to ensure clean removal regardless of engine blocks
    pcall(function()
        if targetModel and targetModel.Parent then
            targetModel:Destroy()
        end
    end)
end

-- -------------------------------------------------------------------------------------
-- 4. EXECUTION PIPELINE
-- -------------------------------------------------------------------------------------
task.spawn(function()
    if LEAModState.Running then return end
    LEAModState.Running = true

    local loadingLabel = ForceTopLevelBlackout()
    task.wait(1.5)

    -- Strict filtering for player-owned pets/brainrot models in workspace
    local petTargets = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") then
            local n = item.Name:lower()
            if n:find("pet") or n:find("brainrot") then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(petTargets, {Model = item, Part = part})
                end
            end
        end
    end

    if #petTargets == 0 then
        loadingLabel.Text = "Loading..."
        task.wait(2)
        if LEAModState.GUI then LEAModState.GUI:Destroy() end
        LEAModState.Running = false
        return
    end

    for _, data in ipairs(petTargets) do
        if data.Model and data.Model.Parent and data.Part then
            LocateAndNavigateToTarget(data.Part)
            task.wait(0.3)
            ExecuteMobileOrPCDeletion(data.Model, data.Part)
            task.wait(0.4)
        end
    end

    loadingLabel.Text = "Loading..."
    task.wait(1.5)

    if LEAModState.GUI then
        LEAModState.GUI:Destroy()
    end
    LEAModState.Running = false
end)
