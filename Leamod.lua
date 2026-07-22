-- LEA MOD V16.0 - PART 1 (NATURAL ANIMATION & BALANCED CORE)
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    getgenv().LeaStateV16 = getgenv().LeaStateV16 or {
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

    local S = getgenv().LeaStateV16

    for _, c in pairs(S.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    S.Connections = {}

    -- ==============================================================================
    -- 1. GİZLİ VE GELİŞTİRİLMİŞ METAMETHOD KORUMASI
    -- ==============================================================================
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            local oldIndex = mt.__index
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local selfStr = tostring(self):lower()
                
                if S.AntiKick and (method == "Kick" or selfStr:find("kick") or selfStr:find("ban") or selfStr:find("anticheat") or selfStr:find("integrity") or selfStr:find("teleport")) then
                    return nil
                end
                
                return oldNamecall(self, ...)
            end)
            
            mt.__index = newcclosure(function(self, k)
                if S.AntiReset and self:IsA("Humanoid") and (k == "Health" or k == "MaxHealth") then
                    return oldIndex(self, k)
                end
                return oldIndex(self, k)
            end)
            
            setreadonly(mt, true)
        end
    end)

    -- ==============================================================================
    -- 2. DENGELİ VE YUMUŞATILMIŞ ANTI-RESET
    -- ==============================================================================
    local function ApplyAntiReset(char)
        local hum = char:WaitForChild("Humanoid", 3)
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hum or not hrp then return end

        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false

        table.insert(S.Connections, hum.HealthChanged:Connect(function(hp)
            if S.AntiReset and hp < 25 then
                task.spawn(function()
                    pcall(function()
                        hum.Health = hum.MaxHealth
                    end)
                end)
            end
        end))
    end

    if LocalPlayer.Character then ApplyAntiReset(LocalPlayer.Character) end
    table.insert(S.Connections, LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        ApplyAntiReset(c)
    end))

    -- ==============================================================================
    -- 3. OPTİMİZE EDİLMİŞ CUBE SİSTEMİ
    -- ==============================================================================
    table.insert(S.Connections, RunService.RenderStepped:Connect(function()
        if not S.Cube then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        pcall(function()
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude

            local res = Workspace:Raycast(hrp.Position, Vector3.new(0, -9, 0), params)
            if not res or (hrp.Position - res.Position).Magnitude > 4 then
                local cube = Instance.new("Part")
                cube.Size = Vector3.new(2.5, 0.3, 2.5)
                cube.Position = hrp.Position - Vector3.new(0, 3.5, 0)
                cube.Anchored = true
                cube.CanCollide = true
                cube.Material = Enum.Material.SmoothPlastic
                cube.Color = Color3.fromRGB(0, 200, 255)
                cube.Transparency = 0.3
                cube.Parent = Workspace

                table.insert(S.Cache.Cubes, cube)
                if #S.Cache.Cubes > 5 then
                    local old = table.remove(S.Cache.Cubes, 1)
                    if old and old.Parent then old:Destroy() end
                end

                task.delay(1.2, function()
                    if cube and cube.Parent then cube:Destroy() end
                end)
            end
        end)
    end))

    -- ==============================================================================
    -- 4. DOĞAL ZIPLAMA ANİMASYONLU FLY (ANTİCHEAT KÖRLEYİCİ)
    -- ==============================================================================
    table.insert(S.Connections, RunService.RenderStepped:Connect(function(dt)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if S.Fly then
            -- Sert platform kilitlenmesi kaldırıldı; karakter zıplama/süzülme animasyonunda kalır
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            local camCF = Camera.CFrame
            local moveDir = hum.MoveDirection
            local speed = 22
            
            local currentVel = hrp.AssemblyLinearVelocity
            local targetVel = Vector3.zero
            
            if moveDir.Magnitude > 0 then
                targetVel = (camCF.RightVector * moveDir.X + camCF.LookVector * -moveDir.Z).Unit * speed
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                targetVel = Vector3.new(targetVel.X, speed * 0.7, targetVel.Z)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                targetVel = Vector3.new(targetVel.X, -speed * 0.7, targetVel.Z)
            else
                targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
            end
            
            hrp.AssemblyLinearVelocity = targetVel
        end
    end))

    -- ==============================================================================
    -- 5. HIZI DÜŞÜRÜLMÜŞ YUMUŞAK TAKİP VE AUTO MEDUSA
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

    table.insert(S.Connections, RunService.Heartbeat:Connect(function(dt)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if S.Follow then
            local tChar = GetNearestTarget()
            if tChar then
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local targetPos = tHrp.Position - ((tHrp.Position - hrp.Position).Unit * 5)
                    -- Çok hızlı hareket önlendi, lerp ile yumuşatıldı
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hrp.Position, tHrp.Position), 0.1)
                    if (hrp.Position - tHrp.Position).Magnitude <= 6 then
                        pcall(function()
                            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                            VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
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

    print("✅ Part 1 V16 Doğal Fizik Yüklendi!")
end)
-- LEA MOD V16.0 - PART 2 (UI ARAYÜZ)
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local S = getgenv().LeaStateV16
    if not S then
        warn("❌ Önce Part 1 Kodunu Çalıştırmalısın!")
        return
    end

    pcall(function() if CoreGui:FindFirstChild("LEAMOD_V16_UI") then CoreGui.LEAMOD_V16_UI:Destroy() end end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "LEAMOD_V16_UI"
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
    Open.TextColor3 = Color3.fromRGB(0, 200, 255)
    Open.TextSize = 11
    Open.Font = Enum.Font.SourceSansBold
    Open.Visible = false
    Open.Parent = Gui
    Instance.new("UICorner", Open).CornerRadius = UDim.new(0, 3)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA V16 NATURAL"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
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

    print("✅ Part 2 V16 UI Yüklendi!")
end)
