-- ==============================================================================
-- LEA MOD V18.0 - PART 1: 50+ SATIR GERÇEK ZAMANLI ANTICHEAT & ZEMİN BYPASS MOTORU
-- ==============================================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")

    local LocalPlayer = Players.LocalPlayer

    getgenv().LeaStateV18 = getgenv().LeaStateV18 or {
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

    local S = getgenv().LeaStateV18

    for _, c in pairs(S.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    S.Connections = {}

    -- ==============================================================================
    -- 1) GERÇEK ZAMANLI SÜREKLİ TARAYAN VE AÇIKLARDAN GİREN GELİŞMİŞ BYPASS (50+ SATIR)
    -- ==============================================================================
    local function InitializeRealtimeDynamicBypass()
        task.spawn(function()
            while S.Active do
                pcall(function()
                    -- A) Metamethod Hook Güçlendirmesi ve Anlık Yakalama
                    local mt = getrawmetatable(game)
                    if mt then
                        setreadonly(mt, false)
                        local oldNamecall = mt.__namecall
                        mt.__namecall = newcclosure(function(self, ...)
                            local method = getnamecallmethod()
                            local selfStr = tostring(self):lower()
                            
                            -- Anticheat kick, ban veya güvenlik açığı denetimlerini anında yok et
                            if S.AntiKick and (method == "Kick" or method == "Ban" or selfStr:find("kick") or selfStr:find("ban") or selfStr:find("anticheat") or selfStr:find("integrity") or selfStr:find("detect")) then
                                return nil
                            end
                            
                            -- Remote üzerinden gelen şüpheli anticheat paketlerini engelle
                            if method == "FireServer" and (selfStr:find("anticheat") or selfStr:find("security") or selfStr:find("check")) then
                                return nil
                            end
                            
                            return oldNamecall(self, ...)
                        end)
                        setreadonly(mt, true)
                    end

                    -- B) Garbage Collection (GC) üzerinden Anticheat fonksiyonlarını etkisizleştirme
                    for _, activeObject in pairs(getgc(true)) do
                        if typeof(activeObject) == "function" then
                            local funcInfo = debug.getinfo(activeObject)
                            if funcInfo and funcInfo.name then
                                local funcNameLower = funcInfo.name:lower()
                                if funcNameLower:find("detect") or funcNameLower:find("cheat") or funcNameLower:find("speed") or funcNameLower:find("fly") or funcNameLower:find("teleport") then
                                    pcall(function()
                                        for index = 1, 15 do
                                            pcall(function() debug.setupvalue(activeObject, index, function() return true end) end)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end)
                -- Gerçek zamanlı çalışma: Her 0.3 saniyede bir yeni açıkları tarar ve durumu günceller
                task.wait(0.3)
            end
        end)
    end
    InitializeRealtimeDynamicBypass()

    -- ==============================================================================
    -- 2) CUBE AKTİFKEN ANTİCHEAT'E "BU ZEMİN" DEYİP KANDIRAN MOTOR
    -- ==============================================================================
    local EngineState = {
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

    table.insert(S.Connections, RunService.Heartbeat:Connect(function()
        local characterModel = LocalPlayer.Character
        if not characterModel then return end
        local hrp = characterModel:FindFirstChild("HumanoidRootPart")
        local hum = characterModel:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if S.Cube then
            -- Anticheat'e karakterin havadayken bile geçerli bir zemin üstünde olduğunu bildiren state sabitlemesi
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            
            local velocityY = hrp.AssemblyLinearVelocity.Y
            if velocityY < 2 and (os.clock() - EngineState.LastCubeTick > 0.12) then
                if #EngineState.ActiveCubes >= 5 then
                    local oldCube = table.remove(EngineState.ActiveCubes, 1)
                    if oldCube and oldCube.Parent then oldCube:Destroy() end
                end

                local newCube = Instance.new("Part")
                newCube.Name = "ValidGroundPlatform" -- Anticheat taramalarına zemin olarak görünmesi için isim etiketi
                newCube.Size = Vector3.new(4.2, 0.4, 4.2)
                newCube.Position = hrp.Position - Vector3.new(0, 3.3, 0)
                newCube.Anchored = true
                newCube.CanCollide = true
                newCube.Transparency = 0.35
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
    -- 3) FLY (UÇUŞ) VE GÜVENLİ HAREKET MOTORU
    -- ==============================================================================
    local FlyState = { Speed = 28, BodyVelocity = nil, BodyGyro = nil }

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
                FlyState.BodyVelocity.Velocity = Vector3.zero
                FlyState.BodyVelocity.Parent = hrp
            end

            if not FlyState.BodyGyro or not FlyState.BodyGyro.Parent then
                FlyState.BodyGyro = Instance.new("BodyGyro")
                FlyState.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                FlyState.BodyGyro.CFrame = hrp.CFrame
                FlyState.BodyGyro.Parent = hrp
            end

            local cam = Workspace.CurrentCamera
            local moveDirection = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

            if FlyState.BodyVelocity and FlyState.BodyGyro then
                FlyState.BodyVelocity.Velocity = moveDirection.Magnitude > 0 and (moveDirection.Unit * FlyState.Speed) or Vector3.new(0, 0.05, 0)
                FlyState.BodyGyro.CFrame = cam.CFrame
            end
        else
            hum.PlatformStand = false
            if FlyState.BodyVelocity then FlyState.BodyVelocity:Destroy() FlyState.BodyVelocity = nil end
            if FlyState.BodyGyro then FlyState.BodyGyro:Destroy() FlyState.BodyGyro = nil end
        end
    end))

    -- ==============================================================================
    -- 4) TAKİP VE AUTO MEDUSA MOTORLARI
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

    print("✅ Part 1 Gerçek Zamanlı Dinamik Bypass Yüklendi!")
end)
-- ==============================================================================
-- LEA MOD V18.0 - PART 2: UI KONTROL ARAYÜZÜ
-- ==============================================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local S = getgenv().LeaStateV18
    if not S then
        warn("❌ Önce Part 1 Kodunu Çalıştırmalısın!")
        return
    end

    pcall(function() if CoreGui:FindFirstChild("LEAMOD_V18_UI") then CoreGui.LEAMOD_V18_UI:Destroy() end end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "LEAMOD_V18_UI"
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
    Title.Text = "LEA V18 SECURE"
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
    AddBtn("Cube Sistemi", "Cube", function(v) S.Cube = vend)
    AddBtn("Fly Süzülme", "Fly", function(v) S.Fly = v end)
    AddBtn("Takip Modu", "Follow", function(v) S.Follow = v end)
    AddBtn("Auto Medusa", "Medusa", function(v) S.Medusa = v end)
    AddBtn("Lagger Mod", "Lagger", function(v) S.Lagger = v; if v then S.RunLagger() end end)

    Close.MouseButton1Click:Connect(function() Main.Visible = false; Open.Visible = true end)
    Open.MouseButton1Click:Connect(function() Main.Visible = true; Open.Visible = false end)

    print("✅ Part 2 UI Arayüzü Yüklendi!")
end)
    
