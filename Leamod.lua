-- HAMSTERLİVES ONLİNE HACK🍑
-- Palofsc // PC Executor Uyumlu v3.0
-- Tüm executor'larda çalışır

-- // SERVİSLER
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // ANA TABLO
local HamsterLive = {
    FlyEnabled = false,
    FlySpeed = 50,
    SavedPosition = nil,
    BodyGyro = nil,
    BodyVelocity = nil,
    RenderSteppedConnection = nil,
    Teleporting = false
}

-- // GÜVENLİ BEKLEME
local function wait(seconds)
    local start = tick()
    repeat
        task.wait()
    until tick() - start >= seconds
end

-- // FLY FİZİK
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
end

local function CreateFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    DestroyFly()

    -- BodyGyro
    HamsterLive.BodyGyro = Instance.new("BodyGyro")
    HamsterLive.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    HamsterLive.BodyGyro.D = 0
    HamsterLive.BodyGyro.P = 9e5
    HamsterLive.BodyGyro.CFrame = root.CFrame
    HamsterLive.BodyGyro.Parent = root

    -- BodyVelocity
    HamsterLive.BodyVelocity = Instance.new("BodyVelocity")
    HamsterLive.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    HamsterLive.BodyVelocity.Velocity = Vector3.zero
    HamsterLive.BodyVelocity.Parent = root

    -- RenderStepped döngüsü
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

        local speed = HamsterLive.FlySpeed
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * speed
        end

        -- Düşme hissi
        moveVector = moveVector - Vector3.new(0, speed * 0.05, 0)

        vel.Velocity = moveVector
        gyro.CFrame = CFrame.new(currentRoot.Position, currentRoot.Position + camCF.LookVector)
    end)
end

-- // TELEPORT
local function TeleportTo(position)
    if not position then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    HamsterLive.Teleporting = true

    -- Fly'ı kapat
    local wasFlying = HamsterLive.FlyEnabled
    if wasFlying then
        HamsterLive.FlyEnabled = false
        DestroyFly()
    end

    -- İlk ışınlanma
    root.CFrame = CFrame.new(position)
    wait(0.05)
    
    -- Geri atıldıysa tekrar ışınlan
    if (root.Position - position).Magnitude > 10 then
        root.CFrame = CFrame.new(position)
        wait(0.05)
    end
    
    -- İkinci kontrol
    if (root.Position - position).Magnitude > 10 then
        root.CFrame = CFrame.new(position)
        wait(0.05)
    end

    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    HamsterLive.Teleporting = false

    -- Fly'ı geri aç
    if wasFlying then
        HamsterLive.FlyEnabled = true
        CreateFly()
    end
end

-- // MENÜ
local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HamsterLiveGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Başlık
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 350, 0, 35)
    Title.Position = UDim2.new(0.5, -175, 0.03, 0)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BackgroundTransparency = 0.2
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "HAMSTERLİVES ONLİNE HACK🍑"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.Parent = ScreenGui

    -- Toggle Buton
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 35)
    ToggleButton.Position = UDim2.new(1, -130, 0, 10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Text = "MENÜ"
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 16
    ToggleButton.Parent = ScreenGui

    -- Menü Frame
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 200, 0, 150)
    MenuFrame.Position = UDim2.new(1, -210, 0, 50)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuFrame.BackgroundTransparency = 0.1
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui

    -- Fly Butonu
    local FlyButton = Instance.new("TextButton")
    FlyButton.Size = UDim2.new(0, 180, 0, 30)
    FlyButton.Position = UDim2.new(0, 10, 0, 10)
    FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyButton.Text = "Fly: KAPALI"
    FlyButton.Parent = MenuFrame

    -- Yer Belirle Butonu
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0, 180, 0, 30)
    SaveButton.Position = UDim2.new(0, 10, 0, 50)
    SaveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.Text = "Yer Belirle"
    SaveButton.Parent = MenuFrame

    -- TP Butonu
    local TpButton = Instance.new("TextButton")
    TpButton.Size = UDim2.new(0, 180, 0, 30)
    TpButton.Position = UDim2.new(0, 10, 0, 90)
    TpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpButton.Text = "TP"
    TpButton.Parent = MenuFrame

    -- Hız Ayarı
    local SpeedSlider = Instance.new("TextBox")
    SpeedSlider.Size = UDim2.new(0, 180, 0, 25)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 125)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.Text = "Hız: 50"
    SpeedSlider.Parent = MenuFrame

    -- Olaylar
    ToggleButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)

    FlyButton.MouseButton1Click:Connect(function()
        HamsterLive.FlyEnabled = not HamsterLive.FlyEnabled
        if HamsterLive.FlyEnabled then
            FlyButton.Text = "Fly: AÇIK"
            FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            CreateFly()
        else
            FlyButton.Text = "Fly: KAPALI"
            FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            DestroyFly()
        end
    end)

    SaveButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HamsterLive.SavedPosition = root.Position
            SaveButton.Text = "Kaydedildi!"
            wait(1)
            SaveButton.Text = "Yer Belirle"
        end
    end)

    TpButton.MouseButton1Click:Connect(function()
        if HamsterLive.SavedPosition then
            TeleportTo(HamsterLive.SavedPosition)
        end
    end)

    SpeedSlider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local match = string.match(SpeedSlider.Text, "%d+")
            if match then
                local newSpeed = tonumber(match)
                if newSpeed and newSpeed > 0 and newSpeed <= 500 then
                    HamsterLive.FlySpeed = newSpeed
                    SpeedSlider.Text = "Hız: " .. newSpeed
                else
                    SpeedSlider.Text = "Hız: 50"
                    HamsterLive.FlySpeed = 50
                end
            else
                SpeedSlider.Text = "Hız: 50"
                HamsterLive.FlySpeed = 50
            end
        end
    end)
end

-- // BAŞLAT
CreateMenu()

-- Karakter yeniden doğarsa fly'ı sıfırla
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if HamsterLive.FlyEnabled then
        CreateFly()
    end
end)
