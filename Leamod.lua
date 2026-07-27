-- ============================================
-- STEAL BRAINROT DUEL SCRIPT (TAM ENTEGRE)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ============================================
-- ANA DEĞİŞKENLER
-- ============================================
local FlyActive = false
local FlySpeed = 35
local AutoBadActive = false
local MedusaActive = false
local CubeActive = false
local GhostModeActive = false
local TargetPlayer = nil
local CubeList = {}
local ConnectionList = {}

-- ============================================
-- GHOST MODE (ÖLÜ GÖZÜKÜP HİTBOX KORUMA)
-- ============================================
local function ActivateGhostMode()
    GhostModeActive = true
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    -- Анимация смерти сохраняется, но физическое тело остаётся активным
    Humanoid.Health = 0 -- Отображение смерти
    Humanoid.BreakJointsOnDeath = false -- Предотвращение разрушения соединений
    RootPart.Anchored = false -- Сохранение подвижности хитбокса
    
    -- Создание невидимого дубликата хитбокса для обхода обнаружения
    local GhostPart = Instance.new("Part")
    GhostPart.Name = "GhostHitbox"
    GhostPart.Size = Vector3.new(2, 2, 1)
    GhostPart.Transparency = 1
    GhostPart.CanCollide = true
    GhostPart.Anchored = false
    GhostPart.Parent = Character
    GhostPart.CFrame = RootPart.CFrame
    
    -- Привязка дубликата к корневой части
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = GhostPart
    Weld.Part1 = RootPart
    Weld.Parent = GhostPart
    
    -- Цикл поддержания состояния смерти
    spawn(function()
        while GhostModeActive and Character and Character.Parent do
            if Humanoid.Health > 0 then
                Humanoid.Health = 0
            end
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ============================================
-- NEW BUTTON (IŞINLANMA SALDIRISI - 34 HIZ)
-- ============================================
local function TeleportToTarget()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    if TargetPlayer and TargetPlayer.Character then
        local TargetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local TargetHead = TargetPlayer.Character:FindFirstChild("Head")
        if TargetRoot and TargetHead then
            -- Мгновенное перемещение к голове цели со скоростью 34 (в 2 раза быстрее ходьбы)
            local TeleportCFrame = TargetHead.CFrame * CFrame.new(0, 0, -2)
            RootPart.CFrame = TeleportCFrame
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
    
    -- Удаление куба при неподвижности игрока
    spawn(function()
        local LastPosition = RootPart.Position
        while Cube and Cube.Parent do
            if (RootPart.Position - LastPosition).Magnitude < 0.1 then
                Cube:Destroy()
                table.remove(CubeList, table.find(CubeList, Cube))
                break
            end
            LastPosition = RootPart.Position
            RunService.Heartbeat:Wait()
        end
    end)
end

local function CubeMovementLoop()
    while CubeActive do
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
                CreateCube()
            elseif Humanoid and Humanoid.Jump then
                CreateCube()
            end
        end
        wait(0.1)
    end
end

-- ============================================
-- YERE İN (ANINDA YERE İNİŞ)
-- ============================================
local function InstantGround()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    -- Проверка нахождения в воздухе
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {Character}
    
    local RayResult = Workspace:Raycast(RootPart.Position, Vector3.new(0, -500, 0), RaycastParams)
    if RayResult then
        RootPart.CFrame = CFrame.new(RootPart.Position.X, RayResult.Position.Y + 3, RootPart.Position.Z)
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- FLY SYSTEM (SÜZÜLME / UÇMA)
-- ============================================
local function StopFly()
    FlyActive = false
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function UpdateFly()
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
-- AUTO BAD (OTOMATİK BAD ALIP TAKİP VE VURMA)
-- ============================================
local function AutoBadLoop()
    while AutoBadActive do
        local Character = LocalPlayer.Character
        if not Character then wait(0.1) continue end
        
        -- Автоматическое получение оружия "Bad"
        local Backpack = LocalPlayer.Backpack
        local BadTool = Backpack:FindFirstChild("Bad") or Character:FindFirstChild("Bad")
        if not BadTool then
            -- Попытка найти Bad в инвентаре
            for _, Tool in ipairs(Backpack:GetChildren()) do
                if Tool:IsA("Tool") and Tool.Name == "Bad" then
                    BadTool = Tool
                    break
                end
            end
        end
        
        if BadTool and not BadTool.Parent:FindFirstChildOfClass("Humanoid") then
            BadTool.Parent = Character
        end
        
        -- Активация полёта для преследования цели
        FlyActive = true
        
        if TargetPlayer and TargetPlayer.Character then
            local TargetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if TargetRoot and TargetHumanoid and TargetHumanoid.Health > 0 then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    -- Постоянное направление к цели
                    local Direction = (TargetRoot.Position - RootPart.Position).Unit
                    RootPart.AssemblyLinearVelocity = Direction * FlySpeed
                    
                    -- Автоматическая атака при сближении
                    if (TargetRoot.Position - RootPart.Position).Magnitude < 5 then
                        if BadTool and BadTool:FindFirstChild("Handle") then
                            firetouchinterest(BadTool.Handle, TargetRoot, 0)
                            firetouchinterest(BadTool.Handle, TargetRoot, 1)
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
end

-- ============================================
-- MEDUSA MODU (1 METRE YAKLAŞINCA OTOMATİK)
-- ============================================
local function MedusaLoop()
    while MedusaActive do
        local Character = LocalPlayer.Character
        if not Character then wait(0.1) continue end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then wait(0.1) continue end
        
        -- Проверка всех игроков в радиусе 1 метра
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
                if TargetRoot and (TargetRoot.Position - RootPart.Position).Magnitude <= 1 then
                    -- Автоматическое получение Medusa
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
                        wait(0.05)
                        -- Активация способности Medusa
                        if MedusaTool:FindFirstChild("Handle") then
                            firetouchinterest(MedusaTool.Handle, TargetRoot, 0)
                            firetouchinterest(MedusaTool.Handle, TargetRoot, 1)
                            wait(0.1)
                            MedusaTool:Activate()
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
end

-- ============================================
-- ANTICHEAT BYPASS (HATA VERDİRME SİSTEMİ)
-- ============================================
local function AnticheatBypass()
    -- Перегрузка детектора античита путём спама легитимными пакетами
    spawn(function()
        while true do
            pcall(function()
                -- Отправка поддельных данных о положении
                local Character = LocalPlayer.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local RootPart = Character:FindFirstChild("HumanoidRootPart")
                    -- Искусственное создание ошибки валидации позиции
                    for i = 1, 50 do
                        RootPart.Velocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
            wait(0.5)
        end
    end)
    
    -- Перехват удаления персонажа сервером
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        Humanoid.Died:Connect(function()
            -- Предотвращение респавна
            wait(0.1)
            if GhostModeActive then
                ActivateGhostMode()
            end
        end)
    end)
end

-- ============================================
-- KONTROL TUŞLARI
-- ============================================
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    
    -- Yere İn: X tuşu
    if Input.KeyCode == Enum.KeyCode.X then
        InstantGround()
    end
    
    -- Ghost Mode: G tuşu
    if Input.KeyCode == Enum.KeyCode.G then
        GhostModeActive = not GhostModeActive
        if GhostModeActive then
            ActivateGhostMode()
        end
    end
    
    -- New Button: N tuşu (ışınlanma)
    if Input.KeyCode == Enum.KeyCode.N then
        TeleportToTarget()
    end
    
    -- Fly Toggle: F tuşu
    if Input.KeyCode == Enum.KeyCode.F then
        FlyActive = not FlyActive
        if not FlyActive then
            StopFly()
        end
    end
    
    -- Cube System: C tuşu
    if Input.KeyCode == Enum.KeyCode.C then
        CubeActive = not CubeActive
        if CubeActive then
            CubeMovementLoop()
        end
    end
    
    -- Auto Bad: B tuşu
    if Input.KeyCode == Enum.KeyCode.B then
        AutoBadActive = not AutoBadActive
        if AutoBadActive then
            AutoBadLoop()
        else
            FlyActive = false
            StopFly()
        end
    end
    
    -- Medusa Mode: M tuşu
    if Input.KeyCode == Enum.KeyCode.M then
        MedusaActive = not MedusaActive
        if MedusaActive then
            MedusaLoop()
        end
    end
    
    -- Hedef seçimi: Mouse sol tık
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Target = Mouse.Target
        if Target then
            local TargetCharacter = Target.Parent
            if TargetCharacter and TargetCharacter:FindFirstChildOfClass("Humanoid") then
                TargetPlayer = Players:GetPlayerFromCharacter(TargetCharacter)
            end
        end
    end
end)

-- ============================================
-- OTOMATİK BAŞLATMA VE DÖNGÜLER
-- ============================================
AnticheatBypass()

-- Fly güncelleme döngüsü
RunService.Heartbeat:Connect(function()
    if FlyActive then
        UpdateFly()
    end
end)

-- VirtualUser bağlantısı (anti-AFK)
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

print("Steal Brainrot Duel Script Yüklendi - LeftEr4Dead")
