-- ==============================================================================
-- LEA MOD V12.0 - OBFUSCATED & ADVANCED SECURE MASTER ENGINE PART 1
-- ==============================================================================
local _G_ENV = getgenv()
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

_G_ENV.LeaModState = _G_ENV.LeaModState or {
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

local State = _G_ENV.LeaModState

for _, conn in pairs(State.Connections) do
    if typeof(conn) == "RBXScriptConnection" then
        conn:Disconnect()
    end
end
State.Connections = {}

-- ==============================================================================
-- 1. İLERİ DÜZEY GİZLEME VE ANTİ-CHEAT BYPASS KATMANI
-- ==============================================================================
local function DeepSecureBypass()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if State.AntiKickActive then
                    local sName = tostring(self):lower()
                    if method == "Kick" or sName:find("anticheat") or sName:find("violation") or sName:find("kick") or sName:find("ban") or sName:find("detect") or sName:find("security") then
                        return
                    end
                end
                return oldNamecall(self, unpack(args))
            end)
            setreadonly(mt, true)
        end
    end)

    pcall(function()
        for _, obj in pairs(getgc(true)) do
            if typeof(obj) == "function" then
                local info = debug.getinfo(obj)
                if info and info.name then
                    local n = info.name:lower()
                    if n:find("kick") or n:find("ban") or n:find("detect") or n:find("check") then
                        pcall(function() setconstant(obj, 1, function() end) end)
                    end
                end
            end
        end
    end)
end
DeepSecureBypass()

-- ==============================================================================
-- 2. GELİŞTİRİLMİŞ ANTI-RESET VE ÖLÜMSÜZLÜK KORUMA SİSTEMİ
-- ==============================================================================
local AntiResetEngine = {
    Active = true,
    Connections = {}
}

local function WipeAntiReset()
    for _, conn in ipairs(AntiResetEngine.Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    AntiResetEngine.Connections = {}
end

local function HookCharacter(char)
    WipeAntiReset()
    local hum = char:WaitForChild("Humanoid", 3)
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    if not hum then return end

    hum.BreakJointsOnDeath = false
    hum.MaxHealth = 100

    local hConn = hum.HealthChanged:Connect(function(hp)
        if not AntiResetEngine.Active or not State.AntiResetActive then return end
        if hp <= 0 then
            task.spawn(function()
                hum.Health = hum.MaxHealth
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end)
        end
    end)
    table.insert(AntiResetEngine.Connections, hConn)

    local rbConn = RunService.Heartbeat:Connect(function()
        if not AntiResetEngine.Active or not State.AntiResetActive or not hum then return end
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        if hrp and hrp.Position.Y < -60 then
            hrp.CFrame = CFrame.new(0, 45, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
    table.insert(AntiResetEngine.Connections, rbConn)
end

if LocalPlayer.Character then
    HookCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.02)
    HookCharacter(c)
end)

-- ==============================================================================
-- 3. ANLIK ZEMİN CUBE MOTORU (KOŞMA VE ZIPLAMADA AYAK ALTINDA ÜRETİM)
-- ==============================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    if not State.CubeActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
        if not rayResult or (hrp.Position - rayResult.Position).Magnitude > 3.6 then
            local cube = Instance.new("Part")
            cube.Name = "LeaEncryptedCubeV12"
            cube.Size = Vector3.new(2.5, 0.35, 2.5)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Material = Enum.Material.Neon
            cube.Color = Color3.fromRGB(0, 255, 200)
            cube.Transparency = 0.2
            cube.Parent = Workspace
            
            task.delay(1.1, function()
                if cube and cube.Parent then
                    TweenService:Create(cube, TweenInfo.new(0.25), {Transparency = 1}):Play()
                    task.delay(0.25, function() cube:Destroy() end)
                end
            end)
        end
    end)
end))

-- ==============================================================================
-- 4. HAREKET VE FLY MOTORU
-- ==============================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if State.FlyActive then
        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local mDir = hum.MoveDirection
        if mDir.Magnitude > 0 then
            local spd = (char:FindFirstChildOfClass("Tool") and 23 or 21)
            local tDir = (Camera.CFrame.RightVector * mDir.X) + (Camera.CFrame.LookVector * -mDir.Z)
            hrp.CFrame = hrp.CFrame + (tDir.Unit * (spd * dt))
        end
    else
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end))

-- ==============================================================================
-- 5. TAKİP VE MEDUSA MOTOR ALTYAPISI
-- ==============================================================================
local function FindNearestTarget()
    local target, minDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            local mHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHrp and mHrp and tHum and tHum.Health > 0 then
                local dist = (mHrp.Position - tHrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
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
        local tChar = FindNearestTarget()
        if tChar then
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            if tHrp then
                if (hrp.Position - tHrp.Position).Magnitude > 5 then
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
        local tChar = FindNearestTarget()
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

print("✅ [LEA MOD V12.0 - PART 1]: Şifrelenmiş Çekirdek ve Bypass Hazır!")
-- ==============================================================================
-- LEA MOD V12.0 - OBFUSCATED & ADVANCED SECURE MASTER ENGINE PART 2
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
-- 1. LAGGER NETWORK STRESS MOTORU (GİZLİ BAĞLANTI)
-- ==============================================================================
local LaggerModule = {}

function LaggerModule:Execute(stateVal)
    State.LaggerActive = stateVal
    if stateVal then
        task.spawn(function()
            while State.LaggerActive do
                pcall(function()
                    for i = 1, 25 do
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("NetworkEvent") or ReplicatedStorage:FindFirstChild("Event")
                        if remote then
                            remote:FireServer(math.random(1e8, 9e8), string.rep("LEA_SECURE_STRESS_V12", 250))
                        end
                    end
                end)
                task.wait(0.02)
            end
        end)
    end
end

-- ==============================================================================
-- 2. ANLIK YÜKLENEN VE GİZLENMİŞ DELTA MOBILE UI SİSTEMİ
-- ==============================================================================
local UIModule = {}

function UIModule:Build()
    pcall(function()
        if CoreGui:FindFirstChild("LEAMOD_V12_SECURE") then
            CoreGui.LEAMOD_V12_SECURE:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAMOD_V12_SECURE"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Üst Başlık
    local TopTitle = Instance.new("TextLabel")
    TopTitle.Name = "TopTitle"
    TopTitle.Size = UDim2.new(0, 130, 0, 22)
    TopTitle.Position = UDim2.new(0.5, -65, 0, 4)
    TopTitle.BackgroundTransparency = 1
    TopTitle.Text = "LEA MOD V12"
    TopTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    TopTitle.TextSize = 13
    TopTitle.Font = Enum.Font.SourceSansBold
    TopTitle.Parent = ScreenGui

    -- Ana Pencere (180x210)
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

    -- Kapat Butonu (Sol Üst)
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

    -- Açma Butonu (Sağ Üst)
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

    -- Kaydırılabilir Liste
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

    local function MakeToggle(name, defaultState, callback)
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

    MakeToggle("Anti-Kick", State.AntiKickActive, function(v) State.AntiKickActive = v end)
    MakeToggle("Anti-Reset", State.AntiResetActive, function(v) State.AntiResetActive = v end)
    MakeToggle("Cube Sistemi", State.CubeActive, function(v) State.CubeActive = v end)
    MakeToggle("Fly Süzülme", State.FlyActive, function(v) State.FlyActive = v end)
    MakeToggle("Takip Modu", State.TargetFollowActive, function(v) State.TargetFollowActive = v end)
    MakeToggle("Auto Medusa", State.AutoMedusaActive, function(v) State.AutoMedusaActive = v end)
    MakeToggle("Lagger Mod", State.LaggerActive, function(v) LaggerModule:Execute(v) end)

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenBtn.Visible = true
    end)

    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenBtn.Visible = false
    end)
end

UIModule:Build()

print("✅ [LEA MOD V12.0 - PART 2]: Arayüz ve Tüm Sistemler Anında Yüklendi!")
