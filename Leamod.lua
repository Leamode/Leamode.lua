-- ==============================================================================
-- LEA MOD V11.0 - ULTIMATE MASTER ENGINE PART 1 (STEAL A BRAINROT)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().LeaModState = getgenv().LeaModState or {
    CubeActive = false,
    FlyActive = false,
    TargetFollowActive = false,
    AutoMedusaActive = false,
    LaggerActive = false,
    AntiKickActive = true,
    AntiResetActive = true,
    BasePosition = nil,
    Connections = {}
}

local State = getgenv().LeaModState

for _, conn in pairs(State.Connections) do
    if typeof(conn) == "RBXScriptConnection" then
        conn:Disconnect()
    end
end
State.Connections = {}

-- ==============================================================================
-- 1. DERİNLEMESİNE BYPASS VE ANTI-KICK MOTORU (35+ KONTROL KATMANI)
-- ==============================================================================
local BypassEngine = {}
function BypassEngine:Initialize()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if State.AntiKickActive then
                    if method == "Kick" or tostring(self):find("Anticheat") or tostring(self):find("Violation") or tostring(self):find("Kick") or tostring(self):find("Ban") or tostring(self):find("Report") then
                        return
                    end
                end
                return oldNamecall(self, unpack(args))
            end)
            setreadonly(mt, true)
        end
    end)

    pcall(function()
        for _, v in pairs(getgc(true)) do
            if typeof(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.name and (info.name:find("kick") or info.name:find("ban") or info.name:find("detect")) then
                    setconstant(v, 1, function() end)
                end
            end
        end
    end)
end
BypassEngine:Initialize()

-- ==============================================================================
-- 2. Kapsamlı Anti-Reset ve Ölümsüzlük Koruma Sistemi
-- ==============================================================================
local CONFIG = {
    ResetProtection = true,
    HealthLock = true,
    StateLock = true,
    FallProtection = true,
    VoidProtection = true,
    RespawnProtection = true,
    AnimationProtection = true,
    TeleportProtection = true,
    AntiStun = true,
    AntiFreeze = true,
}

local AntiReset = {
    Active = true,
    Character = nil,
    Humanoid = nil,
    RootPart = nil,
    Connections = {},
    LastHealth = 100,
    DeathCount = 0,
    FallSpeed = 0,
}

local function ClearAntiResetConnections()
    for _, conn in ipairs(AntiReset.Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    AntiReset.Connections = {}
end

local function UpdateAntiResetCharacter(char)
    ClearAntiResetConnections()
    AntiReset.Character = char
    AntiReset.Humanoid = char and char:FindFirstChildOfClass("Humanoid")
    AntiReset.RootPart = char and char:FindFirstChild("HumanoidRootPart")
    
    if not AntiReset.Humanoid then return end
    
    if CONFIG.HealthLock then
        AntiReset.Humanoid.BreakJointsOnDeath = false
        AntiReset.Humanoid.MaxHealth = 100
        
        local healthConn = AntiReset.Humanoid.HealthChanged:Connect(function(hp)
            if not AntiReset.Active or not State.AntiResetActive then return end
            if hp <= 0 then
                AntiReset.DeathCount = AntiReset.DeathCount + 1
                task.spawn(function()
                    AntiReset.Humanoid.Health = AntiReset.Humanoid.MaxHealth
                    pcall(function() AntiReset.Humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
                end)
                return
            end
            AntiReset.LastHealth = hp
        end)
        table.insert(AntiReset.Connections, healthConn)
        
        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not AntiReset.Active or not State.AntiResetActive or not AntiReset.Humanoid then return end
            if AntiReset.Humanoid.Health <= 0 then
                AntiReset.Humanoid.Health = AntiReset.Humanoid.MaxHealth
                pcall(function() AntiReset.Humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
            end
        end)
        table.insert(AntiReset.Connections, heartbeatConn)
    end
    
    if CONFIG.StateLock then
        local badStates = {
            Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.GettingUp,
            Enum.HumanoidStateType.Stunned, Enum.HumanoidStateType.Physics,
            Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Climbing,
        }
        for _, state in ipairs(badStates) do
            pcall(function() AntiReset.Humanoid:SetStateEnabled(state, false) end)
        end
        
        local stateConn = AntiReset.Humanoid.StateChanged:Connect(function(oldState, newState)
            if not AntiReset.Active or not State.AntiResetActive then return end
            for _, bad in ipairs(badStates) do
                if newState == bad then
                    task.spawn(function() AntiReset.Humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
                    break
                end
            end
        end)
        table.insert(AntiReset.Connections, stateConn)
    end

    if CONFIG.VoidProtection and AntiReset.RootPart then
        local voidConn = RunService.Heartbeat:Connect(function()
            if not AntiReset.Active or not State.AntiResetActive or not AntiReset.RootPart then return end
            if AntiReset.RootPart.Position.Y < -50 then
                AntiReset.RootPart.CFrame = CFrame.new(0, 50, 0)
                AntiReset.RootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end)
        table.insert(AntiReset.Connections, voidConn)
    end
end

if LocalPlayer.Character then
    UpdateAntiResetCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.05)
    UpdateAntiResetCharacter(char)
end)

-- ==============================================================================
-- 3. ANLIK ZEMİN CUBE MOTORU (KOŞMA VE ZIPLAMADA AYAK ALTINDA ÜRETİM)
-- ==============================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    if not State.CubeActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    pcall(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
        if not rayResult or (hrp.Position - rayResult.Position).Magnitude > 3.8 then
            local cube = Instance.new("Part")
            cube.Name = "LeaDynamicCubeV11"
            cube.Size = Vector3.new(2.5, 0.35, 2.5)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Material = Enum.Material.Neon
            cube.Color = Color3.fromRGB(0, 255, 200)
            cube.Transparency = 0.2
            cube.Parent = Workspace
            
            task.delay(1.2, function()
                if cube and cube.Parent then
                    TweenService:Create(cube, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    task.delay(0.3, function() cube:Destroy() end)
                end
            end)
        end
    end)
end))

-- ==============================================================================
-- 4. FLY SÜZÜLME VE HAREKET MOTORU KONTROLÜ
-- ==============================================================================
local MovementEngine = {}
function MovementEngine:ProcessFly(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if State.FlyActive then
        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speed = (char:FindFirstChildOfClass("Tool") and 23 or 21)
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (speed * dt))
        end
    else
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end

table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    MovementEngine:ProcessFly(dt)
end))

-- ==============================================================================
-- 5. TAKİP VE OTOMATİK VURUŞ (DUEL & MEDUSA MOTOR ALTYAPISI)
-- ==============================================================================
local CombatEngine = {}
function CombatEngine:GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHrp and myHrp and tHum and tHum.Health > 0 then
                local d = (myHrp.Position - tHrp.Position).Magnitude
                if d < shortestDist then
                    shortestDist = d
                    target = p.Character
                end
            end
        end
    end
    return target
end

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if State.TargetFollowActive then
        local tChar = CombatEngine:GetClosestTarget()
        if tChar then
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dist = (hrp.Position - tHrp.Position).Magnitude
                if dist > 5 then
                    hrp.CFrame = CFrame.new(hrp.Position, tHrp.Position) + ((tHrp.Position - hrp.Position).Unit * 4)
                else
                    pcall(function()
                        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                    end)
                end
            end
        end
    end

    if State.AutoMedusaActive then
        local tChar = CombatEngine:GetClosestTarget()
        if tChar then
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            if tHrp and (hrp.Position - tHrp.Position).Magnitude <= 14 then
                pcall(function()
                    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                    local medusa = bp and bp:FindFirstChild("Medusa") or char:FindFirstChild("Medusa")
                    if medusa then
                        medusa.Parent = char
                        if medusa:FindFirstChild("Activate") then
                            medusa:Activate()
                        end
                    end
                end)
            end
        end
    end
end))

print("✅ [LEA MOD V11.0 - PART 1]: Çekirdek, Bypass, Anti-Reset ve Küp Motoru Yüklendi!")
-- ==============================================================================
-- LEA MOD V11.0 - ULTIMATE MASTER ENGINE PART 2 (STEAL A BRAINROT)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local State = getgenv().LeaModState

-- ==============================================================================
-- 1. LAGGER NETWORK STRESS MOTORU (GELİŞTİRİLMİŞ PAKET GÖNDERİMİ)
-- ==============================================================================
local LaggerEngine = {}

function LaggerEngine:Toggle(enable)
    State.LaggerActive = enable
    if enable then
        task.spawn(function()
            while State.LaggerActive do
                pcall(function()
                    for i = 1, 20 do
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("NetworkEvent") or ReplicatedStorage:FindFirstChild("Event")
                        if remote then
                            remote:FireServer(math.random(1e7, 9e7), string.rep("LEA_STRESS_V11_PACKET", 300))
                        end
                    end
                end)
                task.wait(0.025)
            end
        end)
    end
end

-- ==============================================================================
-- 2. ULTRA KOMPAKT DELTA MOBILE ARAYÜZ SİSTEMİ (SOL ÜST X, SAĞ ÜST LEA)
-- ==============================================================================
local UIEngine = {}

function UIEngine:Initialize()
    pcall(function()
        if CoreGui:FindFirstChild("LEAMOD_V11_COMPACT") then
            CoreGui.LEAMOD_V11_COMPACT:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAMOD_V11_COMPACT"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Üst Orta Başlık Yazısı
    local TopTitle = Instance.new("TextLabel")
    TopTitle.Name = "TopTitle"
    TopTitle.Size = UDim2.new(0, 130, 0, 22)
    TopTitle.Position = UDim2.new(0.5, -65, 0, 4)
    TopTitle.BackgroundTransparency = 1
    TopTitle.Text = "LEA MOD V11.0"
    TopTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    TopTitle.TextSize = 13
    TopTitle.Font = Enum.Font.SourceSansBold
    TopTitle.Parent = ScreenGui

    -- Ultra Küçültülmüş Ana Pencere (180x210)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 180, 0, 210)
    MainFrame.Position = UDim2.new(0.5, -90, 0.5, -105)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    -- Sol Üstte Çarpı Butonu (Menüyü Kapatır)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(0, 5, 0, 5)
    CloseBtn.BackgroundTransparency = 0.2
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.Parent = MainFrame

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseBtn

    -- Sağ Üstte LEA Logo Tuşu (Menü Kapalıyken Açar)
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Name = "OpenBtn"
    OpenBtn.Size = UDim2.new(0, 50, 0, 24)
    OpenBtn.Position = UDim2.new(1, -55, 0, 5)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    OpenBtn.BorderSizePixel = 0
    OpenBtn.Text = "LEA"
    OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    OpenBtn.TextSize = 13
    OpenBtn.Font = Enum.Font.SourceSansBold
    OpenBtn.Visible = false
    OpenBtn.Parent = ScreenGui

    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 4)
    OpenCorner.Parent = OpenBtn

    -- Kaydırılabilir Mod Listesi Paneli
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Size = UDim2.new(1, -10, 1, -32)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 28)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.Parent = ScrollFrame

    -- Mod Butonu Oluşturucu Fonksiyonu
    local function CreateModToggle(name, defaultState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.BorderSizePixel = 0
        btn.Text = name .. (defaultState and ": AÇIK" or ": KAPALI")
        btn.TextColor3 = defaultState and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
        btn.TextSize = 11
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = ScrollFrame

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        local currentState = defaultState
        btn.MouseButton1Click:Connect(function()
            currentState = not currentState
            btn.Text = name .. (currentState and ": AÇIK" or ": KAPALI")
            btn.TextColor3 = currentState and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
            callback(currentState)
        end)
        return btn
    end

    -- Tüm Mod Butonlarının Eklenmesi
    CreateModToggle("Anti-Kick", State.AntiKickActive, function(v) State.AntiKickActive = v end)
    CreateModToggle("Anti-Reset", State.AntiResetActive, function(v) State.AntiResetActive = v end)
    CreateModToggle("Cube Sistemi", State.CubeActive, function(v) State.CubeActive = v end)
    CreateModToggle("Fly Süzülme", State.FlyActive, function(v) State.FlyActive = v end)
    CreateModToggle("Takip Modu", State.TargetFollowActive, function(v) State.TargetFollowActive = v end)
    CreateModToggle("Auto Medusa", State.AutoMedusaActive, function(v) State.AutoMedusaActive = v end)
    CreateModToggle("Lagger Mod", State.LaggerActive, function(v) LaggerEngine:Toggle(v) end)

    -- Pencere Açma / Kapatma Olayları
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenBtn.Visible = true
    end)

    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenBtn.Visible = false
    end)
end

UIEngine:Initialize()

print("✅ [LEA MOD V11.0 - PART 2]: Kompakt Arayüz ve Tüm Sistemler Başarıyla Yüklendi!")
