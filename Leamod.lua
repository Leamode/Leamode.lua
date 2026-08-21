-- HAMSTERLİVES ONLİNE HACK🍑 PART 1/2
-- Xeno Executor Uyumlu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HamsterLive = {
    FlyEnabled = false,
    FlySpeed = 100,
    SavedPosition = nil,
    BodyGyro = nil,
    BodyVelocity = nil,
    RenderSteppedConnection = nil,
    Teleporting = false,
    IsMobile = false,
    MenuOpen = false,
    StreamerMode = false,
    Trail = nil,
    TrailAttachment = nil,
    Aura = nil,
    HiddenGUIs = {},
    NoclipConnection = nil,
    NoclipEnabled = false,
    AutoBadEnabled = false,
    AutoBadConnection = nil,
    BadModEnabled = false,
    BadModConnection = nil,
    FlyButton = nil,
    SaveButton = nil,
    TpButton = nil,
    NoclipButton = nil,
    StreamerButton = nil,
    AutoBadButton = nil,
    BadModButton = nil,
    SpeedSlider = nil
}

HamsterLive.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function safeWait(seconds)
    local start = os.clock()
    repeat
        wait()
    until os.clock() - start >= seconds
end

local function GetNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (root.Position - targetRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearest = player
                end
            end
        end
    end
    
    return nearest
end

local function ToggleStreamerMode()
    HamsterLive.StreamerMode = not HamsterLive.StreamerMode
    
    local gui = LocalPlayer:WaitForChild("PlayerGui")
    local hamsterGUI = gui:FindFirstChild("HamsterLiveGUI")
    
    if hamsterGUI then
        if HamsterLive.StreamerMode then
            hamsterGUI.Enabled = false
        else
            hamsterGUI.Enabled = true
        end
    end
end

local function ToggleNoclip()
    HamsterLive.NoclipEnabled = not HamsterLive.NoclipEnabled
    
    if HamsterLive.NoclipEnabled then
        if HamsterLive.NoclipConnection then
            HamsterLive.NoclipConnection:Disconnect()
        end
        
        HamsterLive.NoclipConnection = RunService.Stepped:Connect(function()
            if not HamsterLive.NoclipEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if HamsterLive.NoclipConnection then
            HamsterLive.NoclipConnection:Disconnect()
            HamsterLive.NoclipConnection = nil
        end
    end
end

local function CreateTrail()
    if HamsterLive.Trail then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    HamsterLive.TrailAttachment = Instance.new("Attachment")
    HamsterLive.TrailAttachment.Parent = root
    
    HamsterLive.Trail = Instance.new("Trail")
    HamsterLive.Trail.Attachment0 = HamsterLive.TrailAttachment
    HamsterLive.Trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 0))
    })
    HamsterLive.Trail.Lifetime = 0.5
    HamsterLive.Trail.MinWidth = 0.5
    HamsterLive.Trail.MaxWidth = 1.5
    HamsterLive.Trail.LightEmission = 1
    HamsterLive.Trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    HamsterLive.Trail.Parent = root
end

local function RemoveTrail()
    if HamsterLive.Trail then
        pcall(function() HamsterLive.Trail:Destroy() end)
        HamsterLive.Trail = nil
    end
    if HamsterLive.TrailAttachment then
        pcall(function() HamsterLive.TrailAttachment:Destroy() end)
        HamsterLive.TrailAttachment = nil
    end
end

local function CreateAura()
    if HamsterLive.Aura then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    HamsterLive.Aura = Instance.new("ParticleEmitter")
    HamsterLive.Aura.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    })
    HamsterLive.Aura.LightEmission = 1
    HamsterLive.Aura.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 3)
    })
    HamsterLive.Aura.Lifetime = NumberRange.new(0.5, 1)
    HamsterLive.Aura.Rate = 50
    HamsterLive.Aura.Speed = NumberRange.new(2, 4)
    HamsterLive.Aura.SpreadAngle = Vector2.new(360, 360)
    HamsterLive.Aura.Enabled = true
    HamsterLive.Aura.Parent = root
end

local function RemoveAura()
    if HamsterLive.Aura then
        pcall(function() HamsterLive.Aura:Destroy() end)
        HamsterLive.Aura = nil
    end
end

local function DestroyFly()
    if HamsterLive.BodyGyro then
        pcall(function() HamsterLive.BodyGyro:Destroy() end)
        HamsterLive.BodyGyro = nil
    end
    if HamsterLive.BodyVelocity then
        pcall(function() HamsterLive.BodyVelocity:Destroy() end)
        HamsterLive.BodyVelocity = nil
    end
    if HamsterLive.RenderSteppedConnection then
        pcall(function() HamsterLive.RenderSteppedConnection:Disconnect() end)
        HamsterLive.RenderSteppedConnection = nil
    end
    RemoveTrail()
    RemoveAura()
end

local function CreateFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    DestroyFly()
    CreateTrail()
    CreateAura()

    HamsterLive.BodyGyro = Instance.new("BodyGyro")
    HamsterLive.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    HamsterLive.BodyGyro.D = 0
    HamsterLive.BodyGyro.P = math.huge
    HamsterLive.BodyGyro.CFrame = root.CFrame
    HamsterLive.BodyGyro.Parent = root

    HamsterLive.BodyVelocity = Instance.new("BodyVelocity")
    HamsterLive.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    HamsterLive.BodyVelocity.Velocity = Vector3.zero
    HamsterLive.BodyVelocity.Parent = root

    HamsterLive.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if not HamsterLive.FlyEnabled then return end
        
        local currentChar = LocalPlayer.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local gyro = HamsterLive.BodyGyro
        local vel = HamsterLive.BodyVelocity
        
        if not currentRoot or not gyro or not vel then
            CreateFly()
            return
        end

        local camCF = Camera.CFrame
        local direction = camCF.LookVector
        local right = camCF.RightVector
        local up = Vector3.new(0, 1, 0)

        local moveVector = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + direction
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - direction
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + up
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - up
        end

        local speed = HamsterLive.FlySpeed * 2
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * speed
        end

        moveVector = moveVector - Vector3.new(0, speed * 0.02, 0)

        vel.Velocity = moveVector
        gyro.CFrame = CFrame.new(currentRoot.Position, currentRoot.Position + camCF.LookVector)
    end)
end

local function ToggleFly()
    HamsterLive.FlyEnabled = not HamsterLive.FlyEnabled
    if HamsterLive.FlyEnabled then
        if HamsterLive.FlyButton then
            HamsterLive.FlyButton.Text = "Fly: AÇIK (F8)"
            HamsterLive.FlyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end
        CreateFly()
    else
        if HamsterLive.FlyButton then
            HamsterLive.FlyButton.Text = "Fly: KAPALI (F8)"
            HamsterLive.FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
        DestroyFly()
    end
end

local function SavePosition()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        HamsterLive.SavedPosition = root.Position
        if HamsterLive.SaveButton then
            HamsterLive.SaveButton.Text = "Kaydedildi!"
            HamsterLive.SaveButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            safeWait(1)
            HamsterLive.SaveButton.Text = "Yer Belirle (F4)"
            HamsterLive.SaveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end
end

local function TeleportTo(position)
    if not position then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    HamsterLive.Teleporting = true
    root.CFrame = CFrame.new(position)
    safeWait(0.05)
    root.CFrame = CFrame.new(position)
    safeWait(0.05)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    HamsterLive.Teleporting = false
end

local function DoTeleport()
    if HamsterLive.SavedPosition then
        TeleportTo(HamsterLive.SavedPosition)
    end
end

local function FindToolAndAttack(targetPlayer)
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local targetChar = targetPlayer.Character
    local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")
    if not targetChar or not targetHumanoid or targetHumanoid.Health <= 0 then return end
    
    pcall(function()
        tool:Activate()
        safeWait(0.1)
        tool:Deactivate()
    end)
end

local function ToggleAutoBad()
    HamsterLive.AutoBadEnabled = not HamsterLive.AutoBadEnabled
    
    if HamsterLive.AutoBadEnabled then
        if HamsterLive.AutoBadConnection then
            HamsterLive.AutoBadConnection:Disconnect()
        end
        
        HamsterLive.AutoBadConnection = RunService.RenderStepped:Connect(function()
            if not HamsterLive.AutoBadEnabled then return end
            
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            local targetPlayer = GetNearestPlayer()
            if not targetPlayer then return end
            
            local targetChar = targetPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end
            
            local distance = (root.Position - targetRoot.Position).Magnitude
            
            if distance > 5 then
                if not HamsterLive.FlyEnabled then
                    HamsterLive.FlyEnabled = true
                    CreateFly()
                end
                
                local direction = (targetRoot.Position - root.Position).Unit
                HamsterLive.BodyVelocity.Velocity = direction * (HamsterLive.FlySpeed * 3)
                HamsterLive.BodyGyro.CFrame = CFrame.new(root.Position, targetRoot.Position)
            else
                FindToolAndAttack(targetPlayer)
            end
        end)
    else
        if HamsterLive.AutoBadConnection then
            HamsterLive.AutoBadConnection:Disconnect()
            HamsterLive.AutoBadConnection = nil
        end
    end
end

local function ToggleBadMod()
    HamsterLive.BadModEnabled = not HamsterLive.BadModEnabled
    
    if HamsterLive.BadModEnabled then
        if HamsterLive.BadModConnection then
            HamsterLive.BadModConnection:Disconnect()
        end
        
        HamsterLive.BadModConnection = RunService.RenderStepped:Connect(function()
            if not HamsterLive.BadModEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local targetChar = player.Character
                    local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")
                    
                    if targetChar and targetHumanoid and targetHumanoid.Health > 0 then
                        pcall(function()
                            tool:Activate()
                            safeWait(0.05)
                            tool:Deactivate()
                        end)
                    end
                end
            end
        end)
    else
        if HamsterLive.BadModConnection then
            HamsterLive.BadModConnection:Disconnect()
            HamsterLive.BadModConnection = nil
        end
    end
end-- HAMSTERLİVES ONLİNE HACK🍑 PART 2/2
-- Xeno Executor Uyumlu - PART 1'den sonra çalıştır

local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HamsterLiveGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 350, 0, 35)
    Title.Position = UDim2.new(0.5, -175, 0.03, 0)
    Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Title.BackgroundTransparency = 0.3
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "HAMSTERLİVES ONLİNE HACK🍑"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.Parent = ScreenGui

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 35)
    ToggleButton.Position = UDim2.new(1, -130, 0, 10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Text = "MENÜ"
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 16
    ToggleButton.Parent = ScreenGui

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 220, 0, 320)
    MenuFrame.Position = UDim2.new(1, -230, 0, 50)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MenuFrame.BackgroundTransparency = 0.1
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui

    local FlyButton = Instance.new("TextButton")
    FlyButton.Size = UDim2.new(0, 200, 0, 35)
    FlyButton.Position = UDim2.new(0, 10, 0, 10)
    FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyButton.Text = "Fly: KAPALI (F8)"
    FlyButton.Font = Enum.Font.SourceSansBold
    FlyButton.TextSize = 16
    FlyButton.Parent = MenuFrame
    HamsterLive.FlyButton = FlyButton

    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0, 200, 0, 35)
    SaveButton.Position = UDim2.new(0, 10, 0, 55)
    SaveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.Text = "Yer Belirle (F4)"
    SaveButton.Font = Enum.Font.SourceSansBold
    SaveButton.TextSize = 16
    SaveButton.Parent = MenuFrame
    HamsterLive.SaveButton = SaveButton

    local TpButton = Instance.new("TextButton")
    TpButton.Size = UDim2.new(0, 200, 0, 35)
    TpButton.Position = UDim2.new(0, 10, 0, 100)
    TpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpButton.Text = "TP (F5)"
    TpButton.Font = Enum.Font.SourceSansBold
    TpButton.TextSize = 16
    TpButton.Parent = MenuFrame
    HamsterLive.TpButton = TpButton

    local NoclipButton = Instance.new("TextButton")
    NoclipButton.Size = UDim2.new(0, 200, 0, 35)
    NoclipButton.Position = UDim2.new(0, 10, 0, 145)
    NoclipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    NoclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoclipButton.Text = "Noclip: KAPALI (F6)"
    NoclipButton.Font = Enum.Font.SourceSansBold
    NoclipButton.TextSize = 16
    NoclipButton.Parent = MenuFrame
    HamsterLive.NoclipButton = NoclipButton

    local StreamerButton = Instance.new("TextButton")
    StreamerButton.Size = UDim2.new(0, 200, 0, 35)
    StreamerButton.Position = UDim2.new(0, 10, 0, 190)
    StreamerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    StreamerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StreamerButton.Text = "Yayıncı: KAPALI (F7)"
    StreamerButton.Font = Enum.Font.SourceSansBold
    StreamerButton.TextSize = 16
    StreamerButton.Parent = MenuFrame
    HamsterLive.StreamerButton = StreamerButton

    local AutoBadButton = Instance.new("TextButton")
    AutoBadButton.Size = UDim2.new(0, 200, 0, 35)
    AutoBadButton.Position = UDim2.new(0, 10, 0, 235)
    AutoBadButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    AutoBadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBadButton.Text = "AutoBad: KAPALI (F9)"
    AutoBadButton.Font = Enum.Font.SourceSansBold
    AutoBadButton.TextSize = 16
    AutoBadButton.Parent = MenuFrame
    HamsterLive.AutoBadButton = AutoBadButton

    local BadModButton = Instance.new("TextButton")
    BadModButton.Size = UDim2.new(0, 200, 0, 35)
    BadModButton.Position = UDim2.new(0, 10, 0, 280)
    BadModButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    BadModButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    BadModButton.Text = "Bad Mod: KAPALI (F10)"
    BadModButton.Font = Enum.Font.SourceSansBold
    BadModButton.TextSize = 16
    BadModButton.Parent = MenuFrame
    HamsterLive.BadModButton = BadModButton

    local SpeedSlider = Instance.new("TextBox")
    SpeedSlider.Size = UDim2.new(0, 200, 0, 30)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 325)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.Text = "Hız: 100"
    SpeedSlider.Font = Enum.Font.SourceSansBold
    SpeedSlider.TextSize = 14
    SpeedSlider.Parent = MenuFrame
    HamsterLive.SpeedSlider = SpeedSlider

    ToggleButton.MouseButton1Click:Connect(function()
        HamsterLive.MenuOpen = not HamsterLive.MenuOpen
        MenuFrame.Visible = HamsterLive.MenuOpen
        
        if HamsterLive.MenuOpen then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 255)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    FlyButton.MouseButton1Click:Connect(function()
        ToggleFly()
    end)

    SaveButton.MouseButton1Click:Connect(function()
        SavePosition()
    end)

    TpButton.MouseButton1Click:Connect(function()
        DoTeleport()
    end)

    NoclipButton.MouseButton1Click:Connect(function()
        ToggleNoclip()
        if HamsterLive.NoclipEnabled then
            NoclipButton.Text = "Noclip: AÇIK (F6)"
            NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            NoclipButton.Text = "Noclip: KAPALI (F6)"
            NoclipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    StreamerButton.MouseButton1Click:Connect(function()
        ToggleStreamerMode()
        if HamsterLive.StreamerMode then
            StreamerButton.Text = "Yayıncı: AÇIK (F7)"
            StreamerButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            StreamerButton.Text = "Yayıncı: KAPALI (F7)"
            StreamerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    AutoBadButton.MouseButton1Click:Connect(function()
        ToggleAutoBad()
        if HamsterLive.AutoBadEnabled then
            AutoBadButton.Text = "AutoBad: AÇIK (F9)"
            AutoBadButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            AutoBadButton.Text = "AutoBad: KAPALI (F9)"
            AutoBadButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    BadModButton.MouseButton1Click:Connect(function()
        ToggleBadMod()
        if HamsterLive.BadModEnabled then
            BadModButton.Text = "Bad Mod: AÇIK (F10)"
            BadModButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            BadModButton.Text = "Bad Mod: KAPALI (F10)"
            BadModButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    SpeedSlider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local match = string.match(SpeedSlider.Text, "%d+")
            if match then
                local newSpeed = tonumber(match)
                if newSpeed and newSpeed > 0 and newSpeed <= 1000 then
                    HamsterLive.FlySpeed = newSpeed
                    SpeedSlider.Text = "Hız: " .. newSpeed
                else
                    SpeedSlider.Text = "Hız: 100"
                    HamsterLive.FlySpeed = 100
                end
            else
                SpeedSlider.Text = "Hız: 100"
                HamsterLive.FlySpeed = 100
            end
        end
    end)
end

local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F8 then
            ToggleFly()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            SavePosition()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            DoTeleport()
        elseif input.KeyCode == Enum.KeyCode.F6 then
            ToggleNoclip()
            if HamsterLive.NoclipButton then
                if HamsterLive.NoclipEnabled then
                    HamsterLive.NoclipButton.Text = "Noclip: AÇIK (F6)"
                    HamsterLive.NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                else
                    HamsterLive.NoclipButton.Text = "Noclip: KAPALI (F6)"
                    HamsterLive.NoclipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.F7 then
            ToggleStreamerMode()
            if HamsterLive.StreamerButton then
                if HamsterLive.StreamerMode then
                    HamsterLive.StreamerButton.Text = "Yayıncı: AÇIK (F7)"
                    HamsterLive.StreamerButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                else
                    HamsterLive.StreamerButton.Text = "Yayıncı: KAPALI (F7)"
                    HamsterLive.StreamerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.F9 then
            ToggleAutoBad()
            if HamsterLive.AutoBadButton then
                if HamsterLive.AutoBadEnabled then
                    HamsterLive.AutoBadButton.Text = "AutoBad: AÇIK (F9)"
                    HamsterLive.AutoBadButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                else
                    HamsterLive.AutoBadButton.Text = "AutoBad: KAPALI (F9)"
                    HamsterLive.AutoBadButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.F10 then
            ToggleBadMod()
            if HamsterLive.BadModButton then
                if HamsterLive.BadModEnabled then
                    HamsterLive.BadModButton.Text = "Bad Mod: AÇIK (F10)"
                    HamsterLive.BadModButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                else
                    HamsterLive.BadModButton.Text = "Bad Mod: KAPALI (F10)"
                    HamsterLive.BadModButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
        end
    end)
end

CreateMenu()
SetupKeybinds()

LocalPlayer.CharacterAdded:Connect(function()
    safeWait(1)
    if HamsterLive.FlyEnabled then
        CreateFly()
    end
end)
