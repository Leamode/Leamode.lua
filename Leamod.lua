-- HAMSTERLİVES ONLİNE HACK🍑
-- Palofsc // Roblox Executor Payload
-- Fly + Yer Belirle + TP + Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // ANA TABLO
local HamsterLive = {
    Enabled = false,
    FlyEnabled = false,
    FlySpeed = 50,
    SavedPosition = nil,
    BypassActive = false,
    Connections = {},
    BodyGyro = nil,
    BodyVelocity = nil
}

-- // BYPASS SISTEMI
local function EnableBypass()
    if HamsterLive.BypassActive then return end
    HamsterLive.BypassActive = true

    -- Anti-teleport geri atma için network sahte paket geciktirme
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if HamsterLive.BypassActive and self == LocalPlayer.Character and key == "Position" then
            if HamsterLive.Teleporting then
                return HamsterLive.TeleportTarget or oldIndex(self, key)
            end
        end
        return oldIndex(self, key)
    end))

    -- Anti-cheat tespitini atlatmak için RemoteEvent karartması
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if HamsterLive.BypassActive and method == "FireServer" and tostring(self) == "MainRemote" then
            -- Kritik pozisyon verilerini geciktir
            task.wait(0.03)
            return oldNamecall(self, ...)
        end
        return oldNamecall(self, ...)
    end))

    -- Karakter physics bypass
    HamsterLive.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root then
            root:SetAttribute("HamsterBypass", true)
        end
    end)
end

-- // FLY MOTORU
local function CreateFlyPhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not root or not humanoid then return end

    -- Eski physics temizle
    if HamsterLive.BodyGyro then HamsterLive.BodyGyro:Destroy() end
    if HamsterLive.BodyVelocity then HamsterLive.BodyVelocity:Destroy() end

    -- BodyGyro - dönüş kontrolü
    HamsterLive.BodyGyro = Instance.new("BodyGyro")
    HamsterLive.BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    HamsterLive.BodyGyro.D = 0
    HamsterLive.BodyGyro.P = 1e6
    HamsterLive.BodyGyro.CFrame = root.CFrame
    HamsterLive.BodyGyro.Parent = root

    -- BodyVelocity - hareket kontrolü
    HamsterLive.BodyVelocity = Instance.new("BodyVelocity")
    HamsterLive.BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    HamsterLive.BodyVelocity.Velocity = Vector3.zero
    HamsterLive.BodyVelocity.Parent = root

    -- Düşme animasyonu simülasyonu (ziplamada kalmış gibi)
    HamsterLive.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        if not HamsterLive.FlyEnabled then return end
        local currentChar = LocalPlayer.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        if not currentRoot then return end

        -- Sürekli hafif aşağı ivme = düşüyormuş hissi
        local vel = Vector3.zero
        local direction = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            vel = vel + direction
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            vel = vel - direction
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            vel = vel - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            vel = vel + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel - Vector3.new(0, 1, 0)
        end

        -- Hız ayarlama
        local speed = HamsterLive.FlySpeed
        vel = vel * speed

        -- Sürekli hafif düşme efekti
        vel = vel - Vector3.new(0, speed * 0.15, 0)

        HamsterLive.BodyVelocity.Velocity = vel
        HamsterLive.BodyGyro.CFrame = Camera.CFrame
    end)
end

-- // TELEPORT BYPASS
local function TeleportTo(position)
    HamsterLive.Teleporting = true
    HamsterLive.TeleportTarget = position

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        HamsterLive.Teleporting = false
        return
    end

    -- Karakteri geçici olarak network'ten ayır
    root.Anchored = false
    local oldPos = root.Position

    -- Tween ile yumuşak geçiş (anti tespit)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()

    -- Pozisyonu zorla sabitle
    root.CFrame = CFrame.new(position)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    task.wait(0.1)
    HamsterLive.Teleporting = false
end

-- // MENU OLUŞTURMA
local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HamsterLiveGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Başlık
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 350, 0, 35)
    Title.Position = UDim2.new(0.5, -175, 0.03, 0)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BackgroundTransparency = 0.2
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "HAMSTERLİVES ONLİNE HACK🍑"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.Parent = ScreenGui

    -- Buton
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 120, 0, 35)
    ToggleButton.Position = UDim2.new(1, -130, 0, 10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Text = "MENÜ"
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 16
    ToggleButton.Parent = ScreenGui

    -- Menu Frame
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "MenuFrame"
    MenuFrame.Size = UDim2.new(0, 200, 0, 150)
    MenuFrame.Position = UDim2.new(1, -210, 0, 50)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuFrame.BackgroundTransparency = 0.1
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui

    -- Fly Butonu
    local FlyButton = Instance.new("TextButton")
    FlyButton.Name = "FlyButton"
    FlyButton.Size = UDim2.new(0, 180, 0, 30)
    FlyButton.Position = UDim2.new(0, 10, 0, 10)
    FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyButton.Text = "Fly: KAPALI"
    FlyButton.Parent = MenuFrame

    -- Yer Belirle Butonu
    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Size = UDim2.new(0, 180, 0, 30)
    SaveButton.Position = UDim2.new(0, 10, 0, 50)
    SaveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.Text = "Yer Belirle"
    SaveButton.Parent = MenuFrame

    -- TP Butonu
    local TpButton = Instance.new("TextButton")
    TpButton.Name = "TpButton"
    TpButton.Size = UDim2.new(0, 180, 0, 30)
    TpButton.Position = UDim2.new(0, 10, 0, 90)
    TpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpButton.Text = "TP"
    TpButton.Parent = MenuFrame

    -- Hız Ayarı
    local SpeedSlider = Instance.new("TextBox")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(0, 180, 0, 25)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 125)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.Text = "Hız: 50"
    SpeedSlider.Parent = MenuFrame

    -- Toggle buton
    ToggleButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)

    -- Fly toggle
    FlyButton.MouseButton1Click:Connect(function()
        HamsterLive.FlyEnabled = not HamsterLive.FlyEnabled
        if HamsterLive.FlyEnabled then
            FlyButton.Text = "Fly: AÇIK"
            FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            CreateFlyPhysics()
        else
            FlyButton.Text = "Fly: KAPALI"
            FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            if HamsterLive.BodyGyro then HamsterLive.BodyGyro:Destroy() end
            if HamsterLive.BodyVelocity then HamsterLive.BodyVelocity:Destroy() end
            if HamsterLive.Connections.RenderStepped then
                HamsterLive.Connections.RenderStepped:Disconnect()
            end
        end
    end)

    -- Yer belirle
    SaveButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HamsterLive.SavedPosition = root.Position
            SaveButton.Text = "Kaydedildi!"
            task.wait(1)
            SaveButton.Text = "Yer Belirle"
        end
    end)

    -- TP
    TpButton.MouseButton1Click:Connect(function()
        if HamsterLive.SavedPosition then
            TeleportTo(HamsterLive.SavedPosition)
        end
    end)

    -- Hız ayarı
    SpeedSlider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(SpeedSlider.Text:match("%d+"))
            if newSpeed then
                HamsterLive.FlySpeed = newSpeed
                SpeedSlider.Text = "Hız: " .. newSpeed
            end
        end
    end)
end

-- // BAŞLAT
EnableBypass()
CreateMenu()
