-- // LEA +18 MOD - Античит-байпасс с защитой от ресета (без нарушения хитбокса)
-- // Все функции зашифрованы через newcclosure, прямой доступ к памяти через getrawmetatable
local LEA18 = {
    Version = "1.0.0",
    AntiCheatBypassed = false,
    Connections = {},
    SelectedTarget = nil
}

-- // Байпасс ядра античита (без изменения хитбокса)
local function InitializeBypass()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- // Блокировка кика/бана без вмешательства в физику
        if method == "Kick" or method == "Ban" then
            return nil
        end
        
        -- // Подавление детектов без затрагивания hitbox-функций
        if method == "ReportDetection" or method == "FlagPlayer" then
            return nil
        end
        
        -- // Anti-Reset защита: перехват ресета без изменения коллизий
        if method == "ResetPlayer" or method == "Respawn" then
            if self == game:GetService("Players").LocalPlayer then
                return nil -- // Блокировка ресета локального игрока
            end
        end
        
        return old_namecall(self, unpack(args))
    end)
    
    setreadonly(mt, true)
    LEA18.AntiCheatBypassed = true
end

-- // Функция выбора цели
local function SelectTarget(playerName)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            if player.Name:lower():find(playerName:lower()) or player.DisplayName:lower():find(playerName:lower()) then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LEA18.SelectedTarget = player
                    return player
                end
            end
        end
    end
    return nil
end

-- // FuckDoggy поза: персонаж ложится лицом к нижней части цели, руки между ног
local function FuckDoggy(target)
    local localPlayer = game:GetService("Players").LocalPlayer
    local localChar = localPlayer.Character
    
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
        localPlayer.CharacterAdded:Wait()
        localChar = localPlayer.Character
    end
    
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local targetChar = target.Character
    local targetRoot = targetChar.HumanoidRootPart
    local targetLower = targetChar:FindFirstChild("LowerTorso") or targetChar:FindFirstChild("UpperTorso") or targetRoot
    
    -- // Позиция снизу цели с оффсетом для имитации позы
    local rootPart = localChar.HumanoidRootPart
    local humanoid = localChar:FindFirstChild("Humanoid")
    
    -- // Анимация: лечь на живот
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    -- // Загрузка анимации lying down (лежа)
    local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://507770239" -- // ID анимации лежа на животе
    local animTrack = animator:LoadAnimation(animation)
    animTrack:Play()
    
    -- // Постоянное обновление позиции - снизу цели, руки направлены к нижней части
    local connection = game:GetService("RunService").RenderStepped:Connect(function()
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetLower.Position
            -- // Позиция снизу-сзади цели
            local offset = (targetRoot.CFrame.LookVector * -1.5) + Vector3.new(0, -2.5, 0)
            rootPart.CFrame = CFrame.new(targetPos + offset, targetPos)
            
            -- // Симуляция движения рук (через поворот UpperTorso если есть)
            local upperTorso = localChar:FindFirstChild("UpperTorso")
            if upperTorso then
                upperTorso.CFrame = upperTorso.CFrame * CFrame.Angles(math.rad(-30), 0, 0)
            end
        end
    end)
    
    table.insert(LEA18.Connections, connection)
    return true
end

-- // Остановка FuckDoggy и возврат в обычное состояние
local function StopFuckDoggy()
    for _, conn in ipairs(LEA18.Connections) do
        conn:Disconnect()
    end
    LEA18.Connections = {}
    
    local localChar = game:GetService("Players").LocalPlayer.Character
    if localChar and localChar:FindFirstChild("Humanoid") then
        local humanoid = localChar.Humanoid
        humanoid.PlatformStand = false
        
        -- // Сброс анимаций
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

-- // UI меню (минимальный размер, только необходимые кнопки)
local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LEA18Menu"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- // Основной фрейм (маленький размер)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 160, 0, 180)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- // Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "LEA +18 MOD"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.Parent = MainFrame
    
    -- // Поле ввода имени цели
    local TargetBox = Instance.new("TextBox")
    TargetBox.Size = UDim2.new(1, -10, 0, 22)
    TargetBox.Position = UDim2.new(0, 5, 0, 30)
    TargetBox.PlaceholderText = "Target Name..."
    TargetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetBox.Font = Enum.Font.SourceSans
    TargetBox.TextSize = 12
    TargetBox.Parent = MainFrame
    
    -- // Кнопка выбора цели
    local SelectButton = Instance.new("TextButton")
    SelectButton.Size = UDim2.new(1, -10, 0, 22)
    SelectButton.Position = UDim2.new(0, 5, 0, 57)
    SelectButton.Text = "Select Target"
    SelectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectButton.Font = Enum.Font.SourceSans
    SelectButton.TextSize = 12
    SelectButton.Parent = MainFrame
    
    SelectButton.MouseButton1Click:Connect(function()
        local target = SelectTarget(TargetBox.Text)
        if target then
            Title.Text = "LEA +18 | " .. target.Name
        end
    end)
    
    -- // Кнопка FuckDoggy
    local FuckButton = Instance.new("TextButton")
    FuckButton.Size = UDim2.new(1, -10, 0, 22)
    FuckButton.Position = UDim2.new(0, 5, 0, 84)
    FuckButton.Text = "FuckDoggy"
    FuckButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    FuckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FuckButton.Font = Enum.Font.SourceSansBold
    FuckButton.TextSize = 12
    FuckButton.Parent = MainFrame
    
    FuckButton.MouseButton1Click:Connect(function()
        if LEA18.SelectedTarget then
            StopFuckDoggy()
            FuckDoggy(LEA18.SelectedTarget)
        end
    end)
    
    -- // Кнопка Stop
    local StopButton = Instance.new("TextButton")
    StopButton.Size = UDim2.new(1, -10, 0, 22)
    StopButton.Position = UDim2.new(0, 5, 0, 111)
    StopButton.Text = "Stop All"
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.Font = Enum.Font.SourceSans
    StopButton.TextSize = 12
    StopButton.Parent = MainFrame
    
    StopButton.MouseButton1Click:Connect(function()
        StopFuckDoggy()
        Title.Text = "LEA +18 MOD"
    end)
    
    -- // Кнопка закрытия меню
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -22, 0, 2)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 12
    CloseButton.Parent = MainFrame
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- // Перетаскивание меню
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Title.InputEnded:Connect(function(input)
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // Инициализация скрипта
local function Init()
    InitializeBypass()
    CreateMenu()
    
    -- // Авто-подбор цели при вводе команды в чат
    game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
        local args = msg:split(" ")
        if args[1]:lower() == "!target" and args[2] then
            local targetName = table.concat(args, " ", 2)
            SelectTarget(targetName)
        elseif args[1]:lower() == "!fuckdoggy" then
            if LEA18.SelectedTarget then
                FuckDoggy(LEA18.SelectedTarget)
            end
        elseif args[1]:lower() == "!stop" then
            StopFuckDoggy()
        end
    end)
end

-- // Запуск с защитой от ошибок
pcall(Init)

return LEA18
