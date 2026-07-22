-- ==============================================================================
-- LEA MOD V12.1 - PART 1: ÇEKİRDEK SİSTEMLER
-- ==============================================================================
local function initializeCore()
    -- Servisleri gizli bağla
    local Services = {}
    local function getService(name)
        if not Services[name] then
            Services[name] = game:GetService(name)
        end
        return Services[name]
    end

    local Players = getService("Players")
    local RunService = getService("RunService")
    local Workspace = getService("Workspace")
    local UserInputService = getService("UserInputService")
    local TweenService = getService("TweenService")
    local ReplicatedStorage = getService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- Ana state (global yerine lokal scope'ta)
    local State = {
        CubeActive = false,
        FlyActive = false,
        TargetFollowActive = false,
        AutoMedusaActive = false,
        LaggerActive = false,
        AntiKickActive = true,
        AntiResetActive = true,
        Connections = {},
        FlyConnection = nil,
        CubeCache = {}
    }

    -- State'i Part 2 için dışa aktar
    _G.LeaStateInternal = State
    _G.LeaServices = {
        Players = Players,
        RunService = RunService,
        Workspace = Workspace,
        UserInputService = UserInputService,
        TweenService = TweenService,
        ReplicatedStorage = ReplicatedStorage,
        LocalPlayer = LocalPlayer,
        Camera = Camera
    }

    -- ==============================================================================
    -- 1. GELİŞMİŞ GİZLİ BYPASS SİSTEMİ
    -- ==============================================================================
    local function setupBypass()
        -- Metamethod koruması
        pcall(function()
            local mt = getrawmetatable(game)
            if mt then
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    
                    if State.AntiKickActive and method == "Kick" then
                        task.wait()
                        return nil
                    end
                    
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end
        end)

        -- Garbage collection taraması
        pcall(function()
            for _, obj in pairs(getgc(true)) do
                if typeof(obj) == "function" then
                    local info = debug.getinfo(obj)
                    if info and info.name then
                        local n = info.name:lower()
                        if n:find("kick") or n:find("ban") or n:find("detect") then
                            pcall(function()
                                debug.setupvalue(obj, 1, function() return end)
                            end)
                        end
                    end
                end
            end
        end)

        -- Karakter başlangıç koruması
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.BreakJointsOnDeath = false
                    hum.RequiresNeck = false
                end
            end
        end)
    end

    -- ==============================================================================
    -- 2. ANTI-RESET VE ÖLÜMSÜZLÜK SİSTEMİ
    -- ==============================================================================
    function State.ProtectCharacter(char)
        if not char or not State.AntiResetActive then return end
        
        task.spawn(function()
            pcall(function()
                local hum = char:WaitForChild("Humanoid", 5)
                if not hum then return end
                
                hum.BreakJointsOnDeath = false
                hum.Health = hum.MaxHealth

                -- Sağlık anlık koruma
                local healthConn = hum.HealthChanged:Connect(function(health)
                    if State.AntiResetActive and health < 10 then
                        task.wait(0.05)
                        pcall(function()
                            hum.Health = hum.MaxHealth
                        end)
                    end
                end)
                table.insert(State.Connections, healthConn)

                -- Düşme ve reset koruması
                local stateConn = hum.StateChanged:Connect(function(_, state)
                    if state == Enum.HumanoidStateType.FallingDown then
                        task.wait(0.05)
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                        end)
                    end
                end)
                table.insert(State.Connections, stateConn)

                -- Void koruması
                local rbConn = RunService.Heartbeat:Connect(function()
                    if not State.AntiResetActive then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y < -100 then
                        hrp.CFrame = CFrame.new(0, 50, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
                table.insert(State.Connections, rbConn)
            end)
        end)
    end

    -- ==============================================================================
    -- 3. CUBE SİSTEMİ
    -- ==============================================================================
    function State.ManageCube()
        if not State.CubeActive then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Eski cube'ları temizle
        for i, cube in pairs(State.CubeCache) do
            if cube and cube.Parent then
                if (cube.Position - hrp.Position).Magnitude > 15 then
                    cube:Destroy()
                    State.CubeCache[i] = nil
                end
            else
                State.CubeCache[i] = nil
            end
        end

        -- Yeni cube oluştur (maksimum 3 adet)
        if #State.CubeCache < 3 then
            pcall(function()
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude

                local rayResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
                if not rayResult or (hrp.Position - rayResult.Position).Magnitude > 3.6 then
                    local cube = Instance.new("Part")
                    cube.Name = "Cube_" .. math.random(1000, 9999)
                    cube.Size = Vector3.new(2.5, 0.3, 2.5)
                    cube.Position = hrp.Position - Vector3.new(0, 3.3, 0)
                    cube.Anchored = true
                    cube.CanCollide = true
                    cube.Transparency = 0.8
                    cube.Material = Enum.Material.SmoothPlastic
                    cube.Color = Color3.fromRGB(80, 80, 80)
                    cube.Parent = Workspace

                    table.insert(State.CubeCache, cube)

                    task.delay(2, function()
                        if cube and cube.Parent then
                            TweenService:Create(cube, TweenInfo.new(0.3), {Transparency = 1}):Play()
                            task.delay(0.3, function()
                                cube:Destroy()
                            end)
                        end
                    end)
                end
            end)
        end
    end

    -- ==============================================================================
    -- 4. FLY SİSTEMİ
    -- ==============================================================================
    function State.ToggleFly(enable)
        if State.FlyConnection then
            State.FlyConnection:Disconnect()
            State.FlyConnection = nil
        end

        if not enable then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
            end
            return
        end

        State.FlyConnection = RunService.Heartbeat:Connect(function(dt)
            if not State.FlyActive then return end

            local char = LocalPlayer.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            hum.PlatformStand = true

            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local speed = 20
                local camForward = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector

                local movement = Vector3.new()
                movement = movement + (camForward * -moveDir.Z)
                movement = movement + (camRight * moveDir.X)

                if movement.Magnitude > 0 then
                    movement = movement.Unit * speed * dt
                    hrp.CFrame = hrp.CFrame + movement
                end
            end

            local upDown = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                upDown = 12
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                upDown = -12
            end

            if upDown ~= 0 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, upDown * dt, 0)
            end
        end)
    end

    -- ==============================================================================
    -- 5. TAKİP VE MEDUSA MOTORU
    -- ==============================================================================
    function State.FindNearestTarget()
        local target = nil
        local minDist = math.huge
        local myChar = LocalPlayer.Character
        if not myChar then return nil end

        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tChar = player.Character
                local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar:FindFirstChildOfClass("Humanoid")

                if tHrp and tHum and tHum.Health > 0 then
                    local dist = (myHrp.Position - tHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = tChar
                    end
                end
            end
        end

        return target
    end

    function State.ExecuteFollow()
        if not State.TargetFollowActive then return end

        local tChar = State.FindNearestTarget()
        if not tChar then return end

        local myChar = LocalPlayer.Character
        if not myChar then return end

        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        local tHrp = tChar:FindFirstChild("HumanoidRootPart")

        if not myHrp or not tHrp then return end

        local dist = (myHrp.Position - tHrp.Position).Magnitude

        if dist > 5 then
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(tHrp.Position.X, myHrp.Position.Y, tHrp.Position.Z))
            myHrp.CFrame = myHrp.CFrame + myHrp.CFrame.LookVector * 4
        else
            pcall(function()
                local VirtualUser = getService("VirtualUser")
                VirtualUser:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                VirtualUser:Button1Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
    end

    function State.ExecuteMedusa()
        if not State.AutoMedusaActive then return end

        local tChar = State.FindNearestTarget()
        if not tChar then return end

        local myChar = LocalPlayer.Character
        if not myChar then return end

        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        local tHrp = tChar:FindFirstChild("HumanoidRootPart")

        if not myHrp or not tHrp then return end
        if (myHrp.Position - tHrp.Position).Magnitude > 14 then return end

        pcall(function()
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            local medusa = backpack and backpack:FindFirstChild("Medusa")
            local equipped = myChar:FindFirstChild("Medusa")

            if medusa then
                medusa.Parent = myChar
                if medusa:FindFirstChild("Activate") then
                    medusa:Activate()
                end
            elseif equipped and equipped:FindFirstChild("Activate") then
                equipped:Activate()
            end
        end)
    end

    -- ==============================================================================
    -- 6. LAGGER SİSTEMİ
    -- ==============================================================================
    function State.ExecuteLagger()
        if not State.LaggerActive then return end

        task.spawn(function()
            while State.LaggerActive do
                pcall(function()
                    for i = 1, 10 do
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") 
                            or ReplicatedStorage:FindFirstChild("NetworkEvent") 
                            or ReplicatedStorage:FindFirstChild("Event")
                        if remote then
                            remote:FireServer(math.random(1e8, 9e8), string.rep("x", 100))
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end

    -- ==============================================================================
    -- 7. BAŞLATMA
    -- ==============================================================================
    setupBypass()

    -- Karakter bağlantıları
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        State.ProtectCharacter(char)
    end)

    if LocalPlayer.Character then
        State.ProtectCharacter(LocalPlayer.Character)
    end

    print("✅ LEA MOD V12.1 - PART 1: Çekirdek Sistemler Yüklendi!")
    print("📌 Part 2'yi çalıştırarak UI ve ana döngüyü başlatın!")
end

-- Başlat
pcall(initializeCore)-- ==============================================================================
-- LEA MOD V12.1 - PART 2: UI VE ANA DÖNGÜ
-- ==============================================================================
local function initializeUI()
    -- Part 1'den state'i al
    local State = _G.LeaStateInternal
    local Services = _G.LeaServices

    if not State or not Services then
        warn("❌ Part 1 çalıştırılmadı! Önce Part 1'i çalıştırın.")
        return
    end

    local Players = Services.Players
    local RunService = Services.RunService
    local Workspace = Services.Workspace
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = Services.UserInputService
    local LocalPlayer = Services.LocalPlayer

    -- ==============================================================================
    -- 1. UI OLUŞTURMA
    -- ==============================================================================
    local function createUI()
        -- Eski UI varsa temizle
        pcall(function()
            if CoreGui:FindFirstChild("LeaUI_Main") then
                CoreGui.LeaUI_Main:Destroy()
            end
        end)

        -- Ana ScreenGui
        local gui = Instance.new("ScreenGui")
        gui.Name = "LeaUI_Main"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = CoreGui

        -- Açma butonu (küçük)
        local openBtn = Instance.new("TextButton")
        openBtn.Name = "OpenBtn"
        openBtn.Size = UDim2.new(0, 45, 0, 25)
        openBtn.Position = UDim2.new(0.5, -22, 0, 10)
        openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        openBtn.BorderSizePixel = 0
        openBtn.Text = "LEA"
        openBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        openBtn.TextSize = 12
        openBtn.Font = Enum.Font.GothamBold
        openBtn.Visible = true
        openBtn.Parent = gui

        local openCorner = Instance.new("UICorner")
        openCorner.CornerRadius = UDim.new(0, 5)
        openCorner.Parent = openBtn

        -- Ana panel
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 190, 0, 260)
        mainFrame.Position = UDim2.new(0.5, -95, 0.5, -130)
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Visible = false
        mainFrame.Parent = gui

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = mainFrame

        -- Kapat butonu
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.new(0, 22, 0, 22)
        closeBtn.Position = UDim2.new(0, 5, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = mainFrame

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn

        -- Başlık
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -50, 0, 22)
        title.Position = UDim2.new(0, 30, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "LEA MOD V12.1"
        title.TextColor3 = Color3.fromRGB(0, 255, 150)
        title.TextSize = 13
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = mainFrame

        -- Ayraç
        local divider = Instance.new("Frame")
        divider.Name = "Divider"
        divider.Size = UDim2.new(1, -20, 0, 1)
        divider.Position = UDim2.new(0, 10, 0, 32)
        divider.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        divider.BorderSizePixel = 0
        divider.Parent = mainFrame

        -- Scroll alanı
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Scroll"
        scroll.Size = UDim2.new(1, -10, 1, -42)
        scroll.Position = UDim2.new(0, 5, 0, 38)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
        scroll.Parent = mainFrame

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 4)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = scroll

        -- Toggle buton oluşturma fonksiyonu
        local function createToggle(name, defaultState, callback)
            local btn = Instance.new("TextButton")
            btn.Name = name .. "Toggle"
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.BorderSizePixel = 0
            btn.Text = name .. ": " .. (defaultState and "AÇIK" or "KAPALI")
            btn.TextColor3 = defaultState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.Parent = scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn

            local isActive = defaultState
            btn.MouseButton1Click:Connect(function()
                isActive = not isActive
                btn.Text = name .. ": " .. (isActive and "AÇIK" or "KAPALI")
                btn.TextColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
                callback(isActive)
            end)

            return btn
        end

        -- Butonları oluştur
        createToggle("Anti-Kick", State.AntiKickActive, function(v)
            State.AntiKickActive = v
        end)

        createToggle("Anti-Reset", State.AntiResetActive, function(v)
            State.AntiResetActive = v
        end)

        createToggle("Cube Sistemi", State.CubeActive, function(v)
            State.CubeActive = v
        end)

        createToggle("Fly Süzülme", State.FlyActive, function(v)
            State.FlyActive = v
            State.ToggleFly(v)
        end)

        createToggle("Takip Modu", State.TargetFollowActive, function(v)
            State.TargetFollowActive = v
        end)

        createToggle("Auto Medusa", State.AutoMedusaActive, function(v)
            State.AutoMedusaActive = v
        end)

        createToggle("Lagger Mod", State.LaggerActive, function(v)
            State.LaggerActive = v
            State.ExecuteLagger()
        end)

        -- Açma/Kapama butonları
        openBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            openBtn.Visible = false
        end)

        closeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
            openBtn.Visible = true
        end)
    end

    -- ==============================================================================
    -- 2. ANA DÖNGÜ
    -- ==============================================================================
    local function startMainLoop()
        RunService.Heartbeat:Connect(function()
            State.ManageCube()
            State.ExecuteFollow()
            State.ExecuteMedusa()
        end)
    end

    -- ==============================================================================
    -- 3. BAŞLAT
    -- ==============================================================================
    task.wait(0.3)
    createUI()
    startMainLoop()

    print("✅ LEA MOD V12.1 - PART 2: UI ve Ana Döngü Aktif!")
    print("🎮 Panel'i açmak için üstteki 'LEA' butonuna tıkla!")
    print("🛡️ Anti-Kick ve Anti-Reset otomatik aktif!")
end

-- Başlat
pcall(initializeUI)
