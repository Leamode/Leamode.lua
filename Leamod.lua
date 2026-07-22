-- ==============================================================================
-- LEA MOD V9.0 - PART 1: MASTER ENGINE & ADVANCED BYPASS (STEAL A BRAINROT)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().LeaModState = getgenv().LeaModState or {
    CubeActive = false,
    FlyActive = false,
    FlySpeed = 23,
    TargetFollowActive = false,
    AutoMedusaActive = false,
    LaggerActive = false,
    BasePosition = nil,
    CubePart = nil,
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
-- 1. GELİŞTİRİLMİŞ ÇEKİRDEK BYPASS VE ANTİ-CHEAT KORUMA MODÜLÜ
-- ==============================================================================
local BypassModule = {}

function BypassModule:Init()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if tostring(self) == "AnticheatEvent" or tostring(self) == "ReportViolation" or tostring(self) == "KickRemote" or tostring(self) == "BanCheck" then
                    return
                end
                return oldNamecall(self, unpack(args))
            end)
            setreadonly(mt, true)
        end
    end)
    
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.DisplayName = "User_" .. math.random(10000, 99999)
        end
    end)
end

BypassModule:Init()

function BypassModule:SecureMove(hrp, targetCFrame)
    if not hrp then return end
    local jitter = Vector3.new(
        (math.random() - 0.5) * 0.012,
        0,
        (math.random() - 0.5) * 0.012
    )
    hrp.CFrame = targetCFrame + jitter
end

-- ==============================================================================
-- 2. CUBE SİSTEMİ (65° AÇI VE ZEMİN ALGI MOTORU)
-- ==============================================================================
local CubeModule = {}

function CubeModule:Toggle(enable)
    State.CubeActive = enable
    if not enable then
        if State.CubePart then
            pcall(function() State.CubePart:Destroy() end)
            State.CubePart = nil
        end
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not State.CubePart or not State.CubePart.Parent then
        local cube = Instance.new("Part")
        cube.Name = "LeaStandaloneCube"
        cube.Size = Vector3.new(2.5, 0.4, 2.5)
        cube.Position = hrp.Position - Vector3.new(0, 3.5, 0)
        cube.Anchored = false
        cube.CanCollide = true
        cube.Massless = true
        cube.Material = Enum.Material.Neon
        cube.Color = Color3.fromRGB(0, 255, 200)
        cube.Transparency = 0.3
        
        local att = Instance.new("Attachment", cube)
        local alignPos = Instance.new("AlignPosition", cube)
        alignPos.Attachment0 = att
        alignPos.RigidityEnabled = true
        alignPos.MaxForce = 999999999
        
        local alignOrient = Instance.new("AlignOrientation", cube)
        alignOrient.Attachment0 = att
        alignOrient.RigidityEnabled = true
        alignOrient.MaxTorque = 999999999
        
        cube.Parent = Workspace
        State.CubePart = cube
    end
end

-- ==============================================================================
-- 3. FLY & BASE DÖNÜŞ SİSTEMİ (DİNAMİK HIZ KONTROLÜ)
-- ==============================================================================
local FlyModule = {}

function FlyModule:SetBase()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.BasePosition = hrp.CFrame
    end
end

function FlyModule:ReturnToBase()
    if not State.BasePosition then return end
    State.FlyActive = true
    
    task.spawn(function()
        while State.FlyActive and State.BasePosition do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (State.BasePosition.Position - hrp.Position).Magnitude
                if dist < 3 then
                    State.FlyActive = false
                    break
                end
                
                local speed = 21
                if char:FindFirstChildOfClass("Tool") then speed = 23 end
                
                local dir = (State.BasePosition.Position - hrp.Position).Unit
                BypassModule:SecureMove(hrp, hrp.CFrame + (dir * speed * 0.016))
            end
            task.wait()
        end
    end)
end

-- ==============================================================================
-- 4. TAKİP VE OTOMATİK VURUŞ (DUEL & KAÇMA MOTORU)
-- ==============================================================================
local FollowModule = {}

function FollowModule:GetTarget()
    local target = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and myHrp and targetHum and targetHum.Health > 0 then
                local dist = (myHrp.Position - targetHrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    target = player.Character
                end
            end
        end
    end
    return target
end

-- ==============================================================================
-- 5. AUTO MEDUSA SİSTEMİ
-- ==============================================================================
local MedusaModule = {}

function MedusaModule:Run(enable)
    State.AutoMedusaActive = enable
end

-- ==============================================================================
-- 6. LAGGER MOD (NETWORK STRESS ENGINE)
-- ==============================================================================
local LaggerModule = {}

function LaggerModule:Toggle(enable)
    State.LaggerActive = enable
    if enable then
        task.spawn(function()
            while State.LaggerActive do
                pcall(function()
                    for i = 1, 15 do
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("NetworkEvent")
                        if remote then
                            remote:FireServer(math.random(1e6, 9e6), string.rep("LEA_STRESS_PACKET", 250))
                        end
                    end
                end)
                task.wait(0.03)
            end
        end)
    end
end

print("✅ [LEA MOD V9.0 - PART 1]: Çekirdek ve Bypass Motoru Yüklendi!")
-- ==============================================================================
-- LEA MOD V9.0 - PART 2: UI SYSTEM, HEARTBEAT & MODULE HOOKS (STEAL A BRAINROT)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local State = getgenv().LeaModState

-- ==============================================================================
-- 1. ANA HEARTBEAT ÇEVRİMİ VE MODÜL ENTEGRASYONU
-- ==============================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.Health <= 0 then
        State.FlyActive = false
        hum.PlatformStand = false
        return
    end

    -- Cube Sistem Konum Güncellemesi (65 Derece Açı ve Zemin Algısı)
    if State.CubeActive and State.CubePart then
        local alignPos = State.CubePart:FindFirstChildOfClass("AlignPosition")
        if alignPos then
            alignPos.Position = hrp.Position - Vector3.new(0, 3.4, 0)
        end
    end

    -- Fly / Süzülme Modu ve Dinamik Hız Kontrolü
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

    -- Takip ve Otomatik Vuruş Modu (Duel & Kaçma Mekaniği)
    if State.TargetFollowActive then
        local target = nil
        local shortestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local d = (hrp.Position - tHrp.Position).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        target = p.Character
                    end
                end
            end
        end

        if target then
            local tHrp = target:FindFirstChild("HumanoidRootPart")
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

    -- Auto Medusa Modu (Gecikmesiz Basma ve Koşma)
    if State.AutoMedusaActive then
        local target = nil
        local shortestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local d = (hrp.Position - tHrp.Position).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        target = p.Character
                    end
                end
            end
        end

        if target then
            local tHrp = target:FindFirstChild("HumanoidRootPart")
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

-- ==============================================================================
-- 2. DELTA MOBILE UI SİSTEMİ (SOL ÜST ÇARPI, SAĞ ÜST LEA VE ORT_ÜST LEA MOD)
-- ==============================================================================
local function InitializeUI()
    if CoreGui:FindFirstChild("LEAMOD_V9_UI") then
        CoreGui.LEAMOD_V9_UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEAMOD_V9_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Ekranın Üst Orta Kısmında Sabit LEA MOD Başlığı
    local TopHeaderLabel = Instance.new("TextLabel")
    TopHeaderLabel.Name = "TopHeaderLabel"
    TopHeaderLabel.Size = UDim2.new(0, 180, 0, 25)
    TopHeaderLabel.Position = UDim2.new(0.5, -90, 0, 5)
    TopHeaderLabel.BackgroundTransparency = 1
    TopHeaderLabel.Text = "LEA MOD V9.0"
    TopHeaderLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    TopHeaderLabel.TextSize = 16
    TopHeaderLabel.Font = Enum.Font.SourceSansBold
    TopHeaderLabel.Parent = ScreenGui

    -- Kare Ana Menü Penceresi (Mobil Uyumlu)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 240, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    -- Sol Üstte Çarpı Butonu (Menüyü Kapatır)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(0, 8, 0, 8)
    CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = MainFrame

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    -- Sağ Üstte LEA Logosu (Menü Kapalıyken Geri Açar)
    local OpenButton = Instance.new("TextButton")
    OpenButton.Name = "OpenButton"
    OpenButton.Size = UDim2.new(0, 70, 0, 30)
    OpenButton.Position = UDim2.new(1, -80, 0, 10)
    OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    OpenButton.BorderSizePixel = 0
    OpenButton.Text = "LEA"
    OpenButton.TextColor3 = Color3.fromRGB(0, 255, 200)
    OpenButton.TextSize = 16
    OpenButton.Font = Enum.Font.SourceSansBold
    OpenButton.Visible = false
    OpenButton.Parent = ScreenGui

    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 4)
    OpenCorner.Parent = OpenButton

    -- Kaydırılabilir Mod Listesi Alanı
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -16, 1, -45)
    ScrollFrame.Position = UDim2.new(0, 8, 0, 38)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame

    -- Buton Üreteci Yardımcısı
    local function CreateModButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        btn.BorderSizePixel = 0
        btn.Text = name .. ": KAPALI"
        btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        btn.TextSize = 13
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = ScrollFrame

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        local activeState = false
        btn.MouseButton1Click:Connect(function()
            activeState = not activeState
            if activeState then
                btn.Text = name .. ": AÇIK"
                btn.TextColor3 = Color3.fromRGB(50, 255, 120)
            else
                btn.Text = name .. ": KAPALI"
                btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
            callback(activeState)
        end)
        return btn
    end

    -- Menü Mod Butonlarının Entegrasyonu
    CreateModButton("Cube Sistemi", function(state)
        local cubeModule = {}
        function cubeModule:Toggle(on)
            if getgenv().LeaModState then
                getgenv().LeaModState.CubeActive = on
                if not on and getgenv().LeaModState.CubePart then
                    pcall(function() getgenv().LeaModState.CubePart:Destroy() end)
                    getgenv().LeaModState.CubePart = nil
                elseif on then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (not getgenv().LeaModState.CubePart or not getgenv().LeaModState.CubePart.Parent) then
                        local cube = Instance.new("Part")
                        cube.Name = "LeaStandaloneCube"
                        cube.Size = Vector3.new(2.5, 0.4, 2.5)
                        cube.Position = hrp.Position - Vector3.new(0, 3.5, 0)
                        cube.Anchored = false
                        cube.CanCollide = true
                        cube.Massless = true
                        cube.Material = Enum.Material.Neon
                        cube.Color = Color3.fromRGB(0, 255, 200)
                        cube.Transparency = 0.3
                        
                        local att = Instance.new("Attachment", cube)
                        local alignPos = Instance.new("AlignPosition", cube)
                        alignPos.Attachment0 = att
                        alignPos.RigidityEnabled = true
                        alignPos.MaxForce = 999999999
                        
                        local alignOrient = Instance.new("AlignOrientation", cube)
                        alignOrient.Attachment0 = att
                        alignOrient.RigidityEnabled = true
                        alignOrient.MaxTorque = 999999999
                        
                        cube.Parent = Workspace
                        getgenv().LeaModState.CubePart = cube
                    end
                end
            end
        end
        cubeModule:Toggle(state)
    end)

    CreateModButton("Fly Süzülme", function(state)
        State.FlyActive = state
    end)

    CreateModButton("Base Kaydet", function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            State.BasePosition = hrp.CFrame
        end
    end)

    CreateModButton("Baseye Dön", function(state)
        if State.BasePosition then
            State.FlyActive = true
            task.spawn(function()
                while State.FlyActive and State.BasePosition do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (State.BasePosition.Position - hrp.Position).Magnitude
                        if dist < 3 then
                            State.FlyActive = false
                            break
                        end
                        local dir = (State.BasePosition.Position - hrp.Position).Unit
                        hrp.CFrame = hrp.CFrame + (dir * 23 * 0.016)
                    end
                    task.wait()
                end
            end)
        end
    end)

    CreateModButton("Takip Modu", function(state)
        State.TargetFollowActive = state
    end)

    CreateModButton("Auto Medusa", function(state)
        State.AutoMedusaActive = state
    end)

    CreateModButton("Lagger Mod", function(state)
        State.LaggerActive = state
        if state then
            task.spawn(function()
                while State.LaggerActive do
                    pcall(function()
                        for i = 1, 15 do
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("NetworkEvent")
                            if remote then
                                remote:FireServer(math.random(1e6, 9e6), string.rep("LEA_STRESS", 250))
                            end
                        end
                    end)
                    task.wait(0.03)
                end
            end)
        end
    end)

    -- Menü Gizleme ve Açma Dinamikleri
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenButton.Visible = true
    end)

    OpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenButton.Visible = false
    end)
end

InitializeUI()
print("✅ [LEA MOD V9.0 - PART 2]: Arayüz ve Çalışma Döngüleri Tamamlandı!")

