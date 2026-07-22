-- LEA MOD V17.0 - PART 1 (CUSTOM CORE & ANTI-KICK BYPASS)
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")

    local LocalPlayer = Players.LocalPlayer

    getgenv().LeaStateV17 = getgenv().LeaStateV17 or {
        Active = true,
        Cube = false,
        Fly = false,
        Follow = false,
        Medusa = false,
        Lagger = false,
        AntiKick = true,
        AntiReset = true,
        Connections = {},
        Cache = { Cubes = {} }
    }

    local S = getgenv().LeaStateV17

    for _, c in pairs(S.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    S.Connections = {}

    -- ==============================================================================
    -- 1) İSTEDİĞİN GÜÇLENDİRİLMİŞ ANTI-CHEAT VE KICK / RESET KORUMASI
    -- ==============================================================================
    local function ApplySecurityBypass()
        pcall(function()
            local mt = getrawmetatable(game)
            if mt then
                setreadonly(mt, false)
                local old = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    local selfStr = tostring(self):lower()
                    
                    if S.AntiKick and (method == "Kick" or method == "Ban" or selfStr:find("anticheat") or selfStr:find("kick") or selfStr:find("ban") or selfStr:find("integrity")) then
                        return nil
                    end
                    
                    if method == "FireServer" and (selfStr:find("anticheat") or selfStr:find("kick") or selfStr:find("ban")) then
                        return nil
                    end
                    
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end
        end)
    end
    ApplySecurityBypass()

    local EngineState = {
        Speed = 24,
        ActiveCubes = {},
        LastCubeTick = 0
    }

    local function ClearCubesSafely()
        for _, cubeInstance in ipairs(EngineState.ActiveCubes) do
            if cubeInstance and cubeInstance.Parent then
                cubeInstance:Destroy()
            end
        end
        EngineState.ActiveCubes = {}
    end

    -- ==============================================================================
    -- 2) HAREKET, HIZ VE CUBE (KÜP) SİSTEMİ (İstediğin Mantık)
    -- ==============================================================================
    table.insert(S.Connections, RunService.Heartbeat:Connect(function(dt)
        local characterModel = LocalPlayer.Character
        if not characterModel then return end
        local hrp = characterModel:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if S.Cube then
            local velocityY = hrp.AssemblyLinearVelocity.Y
            if velocityY < -1 and (os.clock() - EngineState.LastCubeTick > 0.15) then
                if #EngineState.ActiveCubes >= 6 then
                    local oldCube = table.remove(EngineState.ActiveCubes, 1)
                    if oldCube and oldCube.Parent then oldCube:Destroy() end
                end

                local newCube = Instance.new("Part")
                newCube.Size = Vector3.new(4, 0.5, 4)
                newCube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
                newCube.Anchored = true
                newCube.CanCollide = true
                newCube.Transparency = 0.4
                newCube.Material = Enum.Material.Neon
                newCube.Color = Color3.fromRGB(0, 255, 200)
                newCube.Parent = Workspace

                table.insert(EngineState.ActiveCubes, newCube)
                EngineState.LastCubeTick = os.clock()
            end
        else
            ClearCubesSafely()
        end
    end))

    -- ==============================================================================
    -- 3) RESET KORUMA ENTEGRASYONU
    -- ==============================================================================
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        ClearCubesSafely()
        pcall(function()
            local humanoidComp = newChar:WaitForChild("Humanoid", 5)
            if humanoidComp and S.AntiReset then
                humanoidComp:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        end)
    end)

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function()
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end)
    end

    -- ==============================================================================
    -- 4) FLY (UÇUŞ) VE HAREKET MOTORU ENTEGRASYONU
    -- ==============================================================================
    local FlyState = {
        Speed = 32,
        BodyVelocity = nil,
        BodyGyro = nil
    }

    table.insert(S.Connections, RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if S.Fly then
            hum.PlatformStand = true
            
            if not FlyState.BodyVelocity or not FlyState.BodyVelocity.Parent then
                FlyState.BodyVelocity = Instance.new("BodyVelocity")
                FlyState.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                FlyState.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                FlyState.BodyVelocity.Parent = hrp
            end

            if not FlyState.BodyGyro or not FlyState.BodyGyro.Parent then
                FlyState.BodyGyro = Instance.new("BodyGyro")
                FlyState.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                FlyState.BodyGyro.CFrame = hrp.CFrame
                FlyState.BodyGyro.Parent = hrp
            end

            local cam = Workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end

            if FlyState.BodyVelocity and FlyState.BodyGyro then
                FlyState.BodyVelocity.Velocity = moveDirection.Magnitude > 0 and (moveDirection.Unit * FlyState.Speed) or Vector3.new(0, 0.1, 0)
                FlyState.BodyGyro.CFrame = cam.CFrame
            end
        else
            hum.PlatformStand = false
            if FlyState.BodyVelocity then FlyState.BodyVelocity:Destroy() FlyState.BodyVelocity = nil end
            if FlyState.BodyGyro then FlyState.BodyGyro:Destroy() FlyState.BodyGyro = nil end
        end
    end))

    -- ==============================================================================
    -- 5) YUMUŞATILMIŞ TAKİP VE AUTO MEDUSA MOTORLARI
    -- ==============================================================================
    local function GetNearestTarget()
        local target, minDist = nil, math.huge
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local dist = (myHrp.Position - tHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = p.Character
                    end
                end
            end
        end
        return target
    end

    table.insert(S.Connections, RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if S.Follow then
            local tChar = GetNearestTarget()
            if tChar then
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hrp.Position, tHrp.Position), 0.08)
                    if (hrp.Position - tHrp.Position).Magnitude <= 6 then
                        pcall(function()
                            VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                            VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                        end)
                    end
                end
            end
        end

        if S.Medusa then
            local tChar = GetNearestTarget()
            if tChar then
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                if tHrp and (hrp.Position - tHrp.Position).Magnitude <= 14 then
                    pcall(function()
                        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                        local med = bp and bp:FindFirstChild("Medusa") or char:FindFirstChild("Medusa")
                        if med then
                            med.Parent = char
                            if med:FindFirstChild("Activate") then med:Activate() end
                        end
                    end)
                end
            end
        end
    end))

    function S.RunLagger()
        task.spawn(function()
            while S.Lagger do
                pcall(function()
                    local rem = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("NetworkEvent")
                    if rem then rem:FireServer(math.random(1e5, 9e5)) end
                end)
                task.wait(0.05)
            end
        end)
    end

    print("✅ Part 1 İstediğin Çekirdek Bloklarla Güncellendi!")
end)
-- LEA MOD V17.0 - PART 2 (UI ARAYÜZ)
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local S = getgenv().LeaStateV17
    if not S then
        warn("❌ Önce Part 1 Kodunu Çalıştırmalısın!")
        return
    end

    pcall(function() if CoreGui:FindFirstChild("LEAMOD_V17_UI") then CoreGui.LEAMOD_V17_UI:Destroy() end end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "LEAMOD_V17_UI"
    Gui.ResetOnSpawn = false
    Gui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 160, 0, 195)
    Main.Position = UDim2.new(0.5, -80, 0.5, -97)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 5)

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 18, 0, 18)
    Close.Position = UDim2.new(0, 4, 0, 4)
    Close.BackgroundTransparency = 0.3
    Close.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 60, 60)
    Close.TextSize = 10
    Close.Font = Enum.Font.SourceSansBold
    Close.Parent = Main
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 3)

    local Open = Instance.new("TextButton")
    Open.Size = UDim2.new(0, 45, 0, 22)
    Open.Position = UDim2.new(1, -50, 0, 4)
    Open.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Open.Text = "LEA"
    Open.TextColor3 = Color3.fromRGB(0, 255, 200)
    Open.TextSize = 11
    Open.Font = Enum.Font.SourceSansBold
    Open.Visible = false
    Open.Parent = Gui
    Instance.new("UICorner", Open).CornerRadius = UDim.new(0, 3)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA V17 CUSTOM"
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.TextSize = 10
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -8, 1, -28)
    Scroll.Position = UDim2.new(0, 4, 0, 26)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Padding = UDim.new(0, 3)
    Layout.Parent = Scroll

    local function AddBtn(name, stateKey, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        b.BorderSizePixel = 0
        b.Text = name .. (S[stateKey] and ": AÇIK" or ": KAPALI")
        b.TextColor3 = S[stateKey] and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
        b.TextSize = 10
        b.Font = Enum.Font.SourceSansBold
        b.Parent = Scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)

        b.MouseButton1Click:Connect(function()
            S[stateKey] = not S[stateKey]
            b.Text = name .. (S[stateKey] and ": AÇIK" or ": KAPALI")
            b.TextColor3 = S[stateKey] and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
            if callback then callback(S[stateKey]) end
        end)
    end

    AddBtn("Anti-Kick", "AntiKick", function(v) S.AntiKick = v end)
    AddBtn("Anti-Reset", "AntiReset", function(v) S.AntiReset = v end)
    AddBtn("Cube Sistemi", "Cube", function(v) S.Cube = v end)
    AddBtn("Fly Süzülme", "Fly", function(v) S.Fly = v end)
    AddBtn("Takip Modu", "Follow", function(v) S.Follow = v end)
    AddBtn("Auto Medusa", "Medusa", function(v) S.Medusa = v end)
    AddBtn("Lagger Mod", "Lagger", function(v) S.Lagger = v; if v then S.RunLagger() end end)

    Close.MouseButton1Click:Connect(function() Main.Visible = false; Open.Visible = true end)
    Open.MouseButton1Click:Connect(function() Main.Visible = true; Open.Visible = false end)

    print("✅ Part 2 UI Yüklendi!")
end)
