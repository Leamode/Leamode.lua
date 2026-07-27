-- ============================================
-- PART 1: SERVİSLER, DEĞİŞKENLER, MENÜ, HEDEF SEÇME
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================
-- ANA DEĞİŞKENLER (VARSAYILAN: KAPALI)
-- ============================================
local FlyActive = false
local FlySpeed = 35
local AutoBadActive = false
local MedusaActive = false
local CubeActive = false
local GhostModeActive = false
local TargetPlayer = nil
local CubeList = {}
local ScreenGui = nil
local Buttons = {}

-- ============================================
-- ÇOK KÜÇÜK MOBİL MENÜ OLUŞTURMA (SAĞ ÜST KÖŞE)
-- ============================================
local function CreateMobileMenu()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BrainrotMenu_Mobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local ButtonSize = UDim2.new(0, 28, 0, 28)
    local Spacing = 2
    
    local ButtonData = {
        {Name = "Ghost", Text = "G", Color = Color3.fromRGB(255, 50, 50), Toggle = "GhostModeActive"},
        {Name = "Fly", Text = "F", Color = Color3.fromRGB(50, 150, 255), Toggle = "FlyActive"},
        {Name = "Bad", Text = "B", Color = Color3.fromRGB(255, 150, 50), Toggle = "AutoBadActive"},
        {Name = "Medusa", Text = "M", Color = Color3.fromRGB(150, 50, 255), Toggle = "MedusaActive"},
        {Name = "Cube", Text = "C", Color = Color3.fromRGB(50, 255, 150), Toggle = "CubeActive"},
        {Name = "Down", Text = "↓", Color = Color3.fromRGB(200, 200, 50), Toggle = nil},
        {Name = "TP", Text = "N", Color = Color3.fromRGB(255, 100, 200), Toggle = nil},
        {Name = "Trg", Text = "🎯", Color = Color3.fromRGB(200, 50, 50), Toggle = nil},
    }
    
    for i, Data in ipairs(ButtonData) do
        local Button = Instance.new("TextButton")
        Button.Name = Data.Name
        Button.Size = ButtonSize
        Button.Position = UDim2.new(1, -32, 0, 2 + (i - 1) * (28 + Spacing))
        Button.AnchorPoint = Vector2.new(1, 0)
        Button.BackgroundColor3 = Data.Color
        Button.BackgroundTransparency = 0.3
        Button.BorderSizePixel = 0
        Button.Text = Data.Text
        Button.TextSize = 10
        Button.Font = Enum.Font.GothamBold
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.ZIndex = 10
        Button.AutoButtonColor = false
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = Button
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Transparency = 0.7
        Stroke.Thickness = 1
        Stroke.Parent = Button
        
        Button.Parent = ScreenGui
        
        Button.MouseButton1Click:Connect(function()
            if Data.Toggle then
                if Data.Toggle == "GhostModeActive" then
                    GhostModeActive = not GhostModeActive
                    Button.BackgroundTransparency = GhostModeActive and 0 or 0.3
                    if GhostModeActive then ActivateGhostMode() end
                elseif Data.Toggle == "FlyActive" then
                    FlyActive = not FlyActive
                    Button.BackgroundTransparency = FlyActive and 0 or 0.3
                    if not FlyActive then StopFly() end
                elseif Data.Toggle == "AutoBadActive" then
                    AutoBadActive = not AutoBadActive
                    Button.BackgroundTransparency = AutoBadActive and 0 or 0.3
                    if AutoBadActive then spawn(AutoBadLoop) else FlyActive = false StopFly() end
                elseif Data.Toggle == "MedusaActive" then
                    MedusaActive = not MedusaActive
                    Button.BackgroundTransparency = MedusaActive and 0 or 0.3
                    if MedusaActive then spawn(MedusaLoop) end
                elseif Data.Toggle == "CubeActive" then
                    CubeActive = not CubeActive
                    Button.BackgroundTransparency = CubeActive and 0 or 0.3
                    if CubeActive then spawn(CubeMovementLoop) end
                end
            else
                if Data.Name == "Down" then InstantGround()
                elseif Data.Name == "TP" then TeleportToTarget()
                elseif Data.Name == "Trg" then SelectTargetMode() end
            end
        end)
        
        Buttons[Data.Name] = Button
    end
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 28, 0, 14)
    MinimizeButton.Position = UDim2.new(1, -32, 0, 0)
    MinimizeButton.AnchorPoint = Vector2.new(1, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "—"
    MinimizeButton.TextSize = 8
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.ZIndex = 10
    
    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 4)
    Corner2.Parent = MinimizeButton
    
    MinimizeButton.Parent = ScreenGui
    
    local ButtonsVisible = true
    MinimizeButton.MouseButton1Click:Connect(function()
        ButtonsVisible = not ButtonsVisible
        for _, Btn in pairs(Buttons) do Btn.Visible = ButtonsVisible end
        MinimizeButton.Text = ButtonsVisible and "—" or "+"
    end)
end

-- ============================================
-- HEDEF SEÇME MODU
-- ============================================
local function SelectTargetMode()
    local Mouse = LocalPlayer:GetMouse()
    StarterGui:SetCore("SendNotification", {
        Title = "Hedef Seç",
        Text = "Rakibe tıkla!",
        Duration = 3,
    })
    
    local Connection
    Connection = Mouse.Button1Down:Connect(function()
        local Target = Mouse.Target
        if Target then
            local Character = Target.Parent
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    TargetPlayer = Players:GetPlayerFromCharacter(Character)
                    if TargetPlayer then
                        StarterGui:SetCore("SendNotification", {
                            Title = "Hedef",
                            Text = TargetPlayer.Name,
                            Duration = 2,
                        })
                    end
                end
            end
        end
        Connection:Disconnect()
    end)
end

print("PART 1 Yüklendi - Part 2'yi çalıştırın")-- ============================================
-- PART 2: TÜM SİSTEMLER, BYPASS, DÖNGÜLER
-- ============================================

-- ============================================
-- GHOST MODE (ÖLÜ GÖZÜKÜP HİTBOX KORUMA)
-- ============================================
function ActivateGhostMode()
    GhostModeActive = true
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    Humanoid.BreakJointsOnDeath = false
    Humanoid.Health = 0
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    local GhostPart = Instance.new("Part")
    GhostPart.Name = "GhostHitbox"
    GhostPart.Size = Vector3.new(2, 2, 1)
    GhostPart.Transparency = 1
    GhostPart.CanCollide = true
    GhostPart.Anchored = false
    GhostPart.Parent = Character
    
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = GhostPart
    Weld.Part1 = RootPart
    Weld.Parent = GhostPart
    
    RootPart.Anchored = false
    
    spawn(function()
        while GhostModeActive and Character and Character.Parent do
            if Humanoid and Humanoid.Health > 0 then Humanoid.Health = 0 end
            if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ============================================
-- NEW BUTTON (IŞINLANMA - 34 HIZ)
-- ============================================
function TeleportToTarget()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    if TargetPlayer and TargetPlayer.Character then
        local TargetHead = TargetPlayer.Character:FindFirstChild("Head")
        if TargetHead then
            RootPart.CFrame = TargetHead.CFrame * CFrame.new(0, 0, -2)
            RootPart.AssemblyLinearVelocity = (TargetHead.Position - RootPart.Position).Unit * 34
        end
    end
end

-- ============================================
-- CUBE SYSTEM (ANTI-KICK / ANTI-RESET)
-- ============================================
local function CreateCube()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local Cube = Instance.new("Part")
    Cube.Name = "AntiKickCube"
    Cube.Size = Vector3.new(4, 0.5, 4)
    Cube.Position = RootPart.Position - Vector3.new(0, 3.5, 0)
    Cube.Anchored = true
    Cube.CanCollide = true
    Cube.Transparency = 1
    Cube.Parent = Workspace
    table.insert(CubeList, Cube)
    
    spawn(function()
        local LastPosition = RootPart.Position
        local StillCount = 0
        while Cube and Cube.Parent do
            if (RootPart.Position - LastPosition).Magnitude < 0.1 then
                StillCount = StillCount + 1
                if StillCount > 5 then
                    Cube:Destroy()
                    local idx = table.find(CubeList, Cube)
                    if idx then table.remove(CubeList, idx) end
                    break
                end
            else
                StillCount = 0
            end
            LastPosition = RootPart.Position
            RunService.Heartbeat:Wait()
        end
    end)
end

function CubeMovementLoop()
    while CubeActive do
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            if RootPart then
                if (Humanoid and Humanoid.MoveDirection.Magnitude > 0) or 
                   (Humanoid and Humanoid.Jump) or
                   RootPart.AssemblyLinearVelocity.Y > 2 then
                    CreateCube()
                end
            end
        end
        task.wait(0.05)
    end
end

-- ============================================
-- YERE İN (ANINDA)
-- ============================================
function InstantGround()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {Character}
    
    local RayResult = Workspace:Raycast(RootPart.Position, Vector3.new(0, -500, 0), RaycastParams)
    if RayResult then
        local TargetPos = RayResult.Position + Vector3.new(0, 3, 0)
        local Tween = TweenService:Create(RootPart, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {CFrame = CFrame.new(TargetPos)})
        Tween:Play()
        Tween.Completed:Wait()
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- FLY SYSTEM
-- ============================================
function StopFly()
    FlyActive = false
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if RootPart then RootPart.AssemblyLinearVelocity = Vector3.zero end
    end
end

function UpdateFly()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not FlyActive or not RootPart or not Humanoid then return end
    
    Humanoid.PlatformStand = true
    local MoveDir = Humanoid.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        local CamCFrame = Camera.CFrame
        local TargetDir = (CamCFrame.RightVector * MoveDir.X) + (CamCFrame.LookVector * MoveDir.Z)
        if TargetDir.Magnitude > 0 then
            RootPart.AssemblyLinearVelocity = TargetDir.Unit * FlySpeed
        end
    else
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- AUTO BAD (UÇARAK TAKİP VE SÜREKLİ VURMA)
-- ============================================
function AutoBadLoop()
    while AutoBadActive do
        local Character = LocalPlayer.Character
        if not Character then task.wait(0.1) continue end
        
        local Backpack = LocalPlayer.Backpack
        local BadTool = Backpack:FindFirstChild("Bad") or Character:FindFirstChild("Bad")
        
        if not BadTool then
            for _, Tool in ipairs(Backpack:GetChildren()) do
                if Tool:IsA("Tool") and Tool.Name == "Bad" then
                    BadTool = Tool
                    break
                end
            end
        end
        
        if BadTool and BadTool.Parent ~= Character then
            BadTool.Parent = Character
            task.wait(0.1)
        end
        
        FlyActive = true
        
        if TargetPlayer and TargetPlayer.Character then
            local TargetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if TargetRoot and TargetHumanoid and TargetHumanoid.Health > 0 then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local Direction = (TargetRoot.Position - RootPart.Position).Unit
                    RootPart.AssemblyLinearVelocity = Direction * FlySpeed
                    
                    if (TargetRoot.Position - RootPart.Position).Magnitude < 5 then
                        if BadTool and BadTool:FindFirstChild("Handle") then
                            for _ = 1, 5 do
                                pcall(function()
                                    firetouchinterest(BadTool.Handle, TargetRoot, 0)
                                    firetouchinterest(BadTool.Handle, TargetRoot, 1)
                                end)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
    FlyActive = false
    StopFly()
end

-- ============================================
-- MEDUSA MODU (1 METRE OTOMATİK)
-- ============================================
function MedusaLoop()
    while MedusaActive do
        local Character = LocalPlayer.Character
        if not Character then task.wait(0.1) continue end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then task.wait(0.1) continue end
        
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
                if TargetRoot and (TargetRoot.Position - RootPart.Position).Magnitude <= 1 then
                    local Backpack = LocalPlayer.Backpack
                    local MedusaTool = Backpack:FindFirstChild("Medusa") or Character:FindFirstChild("Medusa")
                    
                    if not MedusaTool then
                        for _, Tool in ipairs(Backpack:GetChildren()) do
                            if Tool:IsA("Tool") and Tool.Name == "Medusa" then
                                MedusaTool = Tool
                                break
                            end
                        end
                    end
                    
                    if MedusaTool then
                        MedusaTool.Parent = Character
                        task.wait(0.05)
                        if MedusaTool:FindFirstChild("Handle") then
                            pcall(function()
                                firetouchinterest(MedusaTool.Handle, TargetRoot, 0)
                                firetouchinterest(MedusaTool.Handle, TargetRoot, 1)
                            end)
                            task.wait(0.05)
                            pcall(function() MedusaTool:Activate() end)
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
end

-- ============================================
-- ANTICHEAT BYPASS (SESSİZ)
-- ============================================
local function AnticheatBypass()
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        
        Humanoid.Died:Connect(function()
            if GhostModeActive then
                task.wait(0.05)
                ActivateGhostMode()
            end
        end)
        
        Humanoid.StateChanged:Connect(function(OldState, NewState)
            if NewState == Enum.HumanoidStateType.Dead then
                if GhostModeActive then
                    task.wait(0.05)
                    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end)
    end)
    
    spawn(function()
        while true do
            pcall(function()
                local Character = LocalPlayer.Character
                if Character then
                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Humanoid:Move(Vector3.new(0.001, 0, 0.001), false)
                        task.wait(0.1)
                        Humanoid:Move(Vector3.new(-0.001, 0, -0.001), false)
                    end
                end
            end)
            task.wait(30)
        end
    end)
end

-- ============================================
-- BAŞLATMA
-- ============================================
FlyActive = false
CreateMobileMenu()
AnticheatBypass()
  _
RunService.Heartbeat:Connect(function()
    if FlyActive then UpdateFly() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    CreateMobileMenu()
    if GhostModeActive then
        task.wait(0.1)
        ActivateGhostMode()
    end
end)

LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    end)
end)

print("PART 2 Yüklendi - Brainrot Duel v2.0 Tamamlandı | Fly: KAPALI")1
