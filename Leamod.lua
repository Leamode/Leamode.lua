-- ============================================
-- STEAL BRAINROT DUEL v4.0 - PART 1 (TEMİZ YAPILANDIRMA)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- GLOBAL DEĞİŞKEN TABLOSU
-- ============================================
local ScriptData = {
    FlyActive = false,
    FlySpeed = 35,
    AutoBadActive = false,
    MedusaActive = false,
    CubeActive = false,
    GhostModeActive = false,
    TargetPlayer = nil,
    CubeList = {},
    ScreenGui = nil,
    Buttons = {},
    Connections = {},
    BadConnection = nil,
    MedusaConnection = nil,
    CubeConnection = nil,
    GhostConnection = nil,
}

-- ============================================
-- MENÜ OLUŞTURMA (BASİT VE TEMİZ)
-- ============================================
local function CreateMenu()
    -- Eski menüyü temizle
    if ScriptData.ScreenGui then
        ScriptData.ScreenGui:Destroy()
        ScriptData.ScreenGui = nil
    end
    
    -- PlayerGui'yi bekle
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        repeat task.wait(0.1) PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") until PlayerGui
    end
    
    -- Yeni ScreenGui
    ScriptData.ScreenGui = Instance.new("ScreenGui")
    ScriptData.ScreenGui.Name = "BrainrotMenu"
    ScriptData.ScreenGui.ResetOnSpawn = false
    ScriptData.ScreenGui.Parent = PlayerGui
    
    -- Buton listesi (isim, text, renk, fonksiyon)
    local ButtonsInfo = {
        {Name = "GhostBtn", Text = "G", Color = Color3.fromRGB(255, 60, 60)},
        {Name = "FlyBtn", Text = "F", Color = Color3.fromRGB(60, 140, 255)},
        {Name = "BadBtn", Text = "B", Color = Color3.fromRGB(255, 140, 40)},
        {Name = "MedusaBtn", Text = "M", Color = Color3.fromRGB(140, 50, 255)},
        {Name = "CubeBtn", Text = "C", Color = Color3.fromRGB(50, 255, 140)},
        {Name = "DownBtn", Text = "D", Color = Color3.fromRGB(200, 200, 50)},
        {Name = "TpBtn", Text = "T", Color = Color3.fromRGB(255, 100, 180)},
        {Name = "TargetBtn", Text = "H", Color = Color3.fromRGB(200, 60, 60)},
    }
    
    -- Butonları oluştur (sağ üst köşe, alt alta)
    for Index, Info in ipairs(ButtonsInfo) do
        local Button = Instance.new("TextButton")
        Button.Name = Info.Name
        Button.Size = UDim2.new(0, 32, 0, 32)
        Button.Position = UDim2.new(1, -36, 0, 8 + (Index - 1) * 35)
        Button.BackgroundColor3 = Info.Color
        Button.BackgroundTransparency = 0.25
        Button.BorderSizePixel = 0
        Button.Text = Info.Text
        Button.TextSize = 11
        Button.Font = Enum.Font.GothamBold
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.ZIndex = 10
        Button.AutoButtonColor = false
        
        -- Köşe yuvarlama
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = Button
        
        -- Kenar çizgisi
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.new(1, 1, 1)
        UIStroke.Transparency = 0.6
        UIStroke.Thickness = 1
        UIStroke.Parent = Button
        
        Button.Parent = ScriptData.ScreenGui
        ScriptData.Buttons[Info.Name] = Button
    end
    
    -- Buton tıklama olayları
    ScriptData.Buttons["GhostBtn"].MouseButton1Click:Connect(function()
        ScriptData.GhostModeActive = not ScriptData.GhostModeActive
        local Btn = ScriptData.Buttons["GhostBtn"]
        Btn.BackgroundTransparency = ScriptData.GhostModeActive and 0 or 0.25
        if ScriptData.GhostModeActive then
            StartGhostMode()
        else
            StopGhostMode()
        end
    end)
    
    ScriptData.Buttons["FlyBtn"].MouseButton1Click:Connect(function()
        ScriptData.FlyActive = not ScriptData.FlyActive
        local Btn = ScriptData.Buttons["FlyBtn"]
        Btn.BackgroundTransparency = ScriptData.FlyActive and 0 or 0.25
        if ScriptData.FlyActive then
            StartFly()
        else
            StopFly()
        end
    end)
    
    ScriptData.Buttons["BadBtn"].MouseButton1Click:Connect(function()
        ScriptData.AutoBadActive = not ScriptData.AutoBadActive
        local Btn = ScriptData.Buttons["BadBtn"]
        Btn.BackgroundTransparency = ScriptData.AutoBadActive and 0 or 0.25
        if ScriptData.AutoBadActive then
            StartAutoBad()
        else
            StopAutoBad()
        end
    end)
    
    ScriptData.Buttons["MedusaBtn"].MouseButton1Click:Connect(function()
        ScriptData.MedusaActive = not ScriptData.MedusaActive
        local Btn = ScriptData.Buttons["MedusaBtn"]
        Btn.BackgroundTransparency = ScriptData.MedusaActive and 0 or 0.25
        if ScriptData.MedusaActive then
            StartMedusa()
        else
            StopMedusa()
        end
    end)
    
    ScriptData.Buttons["CubeBtn"].MouseButton1Click:Connect(function()
        ScriptData.CubeActive = not ScriptData.CubeActive
        local Btn = ScriptData.Buttons["CubeBtn"]
        Btn.BackgroundTransparency = ScriptData.CubeActive and 0 or 0.25
        if ScriptData.CubeActive then
            StartCube()
        else
            StopCube()
        end
    end)
    
    ScriptData.Buttons["DownBtn"].MouseButton1Click:Connect(function()
        InstantGround()
    end)
    
    ScriptData.Buttons["TpBtn"].MouseButton1Click:Connect(function()
        TeleportToTarget()
    end)
    
    ScriptData.Buttons["TargetBtn"].MouseButton1Click:Connect(function()
        SelectTarget()
    end)
    
    print("[Brainrot] Menü hazır - 8 buton")
end

-- ============================================
-- HEDEF SEÇME
-- ============================================
function SelectTarget()
    StarterGui:SetCore("SendNotification", {
        Title = "Hedef Seçimi",
        Text = "Rakibin üzerine tıkla",
        Duration = 3,
    })
    
    local ClickConnection
    ClickConnection = Mouse.Button1Down:Connect(function()
        local Target = Mouse.Target
        if Target then
            local Model = Target:FindFirstAncestorOfClass("Model")
            if Model then
                local Humanoid = Model:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    local Player = Players:GetPlayerFromCharacter(Model)
                    if Player and Player ~= LocalPlayer then
                        ScriptData.TargetPlayer = Player
                        StarterGui:SetCore("SendNotification", {
                            Title = "Hedef Seçildi",
                            Text = Player.Name,
                            Duration = 2,
                        })
                    end
                end
            end
        end
        ClickConnection:Disconnect()
    end)
end

-- ============================================
-- GHOST MODE
-- ============================================
function StartGhostMode()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    -- Ölü göster ama parçalanma
    Humanoid.BreakJointsOnDeath = false
    Humanoid.Health = 0
    
    -- Hayalet parça oluştur
    local GhostPart = Instance.new("Part")
    GhostPart.Name = "GhostHitbox"
    GhostPart.Size = Vector3.new(2, 2, 1)
    GhostPart.Transparency = 1
    GhostPart.CanCollide = true
    GhostPart.Anchored = false
    GhostPart.Parent = Character
    
    local WeldConstraint = Instance.new("WeldConstraint")
    WeldConstraint.Part0 = GhostPart
    WeldConstraint.Part1 = RootPart
    WeldConstraint.Parent = GhostPart
    
    RootPart.Anchored = false
    
    -- Ölü kalma döngüsü
    ScriptData.GhostConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if Character and Character.Parent and Humanoid and Humanoid.Parent then
                if Humanoid.Health > 0 then
                    Humanoid.Health = 0
                end
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            else
                StopGhostMode()
            end
        end)
    end)
end

function StopGhostMode()
    if ScriptData.GhostConnection then
        ScriptData.GhostConnection:Disconnect()
        ScriptData.GhostConnection = nil
    end
    ScriptData.GhostModeActive = false
    
    local Character = LocalPlayer.Character
    if Character then
        -- GhostPart'ları temizle
        for _, Child in ipairs(Character:GetChildren()) do
            if Child.Name == "GhostHitbox" then
                Child:Destroy()
            end
        end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.Health = 100
            Humanoid.BreakJointsOnDeath = true
        end
    end
end

-- ============================================
-- FLY SYSTEM
-- ============================================
function StartFly()
    ScriptData.FlyActive = true
end

function StopFly()
    ScriptData.FlyActive = false
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then
            Humanoid.PlatformStand = false
        end
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Fly güncelleme döngüsü
RunService.Heartbeat:Connect(function()
    if not ScriptData.FlyActive then return end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    Humanoid.PlatformStand = true
    
    local MoveDirection = Humanoid.MoveDirection
    if MoveDirection.Magnitude > 0 then
        local CameraCFrame = Camera.CFrame
        local TargetDirection = (CameraCFrame.RightVector * MoveDirection.X) + (CameraCFrame.LookVector * MoveDirection.Z)
        if TargetDirection.Magnitude > 0 then
            RootPart.AssemblyLinearVelocity = TargetDirection.Unit * ScriptData.FlySpeed
        end
    else
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ============================================
-- INSTANT GROUND
-- ============================================
function InstantGround()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayParams.FilterDescendantsInstances = {Character}
    
    local RayResult = Workspace:Raycast(RootPart.Position, Vector3.new(0, -500, 0), RayParams)
    if RayResult then
        local GroundPos = RayResult.Position + Vector3.new(0, 3, 0)
        RootPart.CFrame = CFrame.new(GroundPos)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ============================================
-- TELEPORT TO TARGET
-- ============================================
function TeleportToTarget()
    if not ScriptData.TargetPlayer then return end
    if not ScriptData.TargetPlayer.Character then return end
    
    local TargetHead = ScriptData.TargetPlayer.Character:FindFirstChild("Head")
    if not TargetHead then return end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    RootPart.CFrame = TargetHead.CFrame * CFrame.new(0, 0, -2)
    RootPart.AssemblyLinearVelocity = (TargetHead.Position - RootPart.Position).Unit * 34
end

-- ============================================
-- CUBE SYSTEM
-- ============================================
function StartCube()
    ScriptData.CubeActive = true
    
    ScriptData.CubeConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local Character = LocalPlayer.Character
            if not Character then return end
            
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not RootPart or not Humanoid then return end
            
            local IsMoving = Humanoid.MoveDirection.Magnitude > 0
            local IsJumping = RootPart.AssemblyLinearVelocity.Y > 2
            
            if IsMoving or IsJumping then
                -- Altında cube var mı kontrol et
                local HasCube = false
                for _, Cube in ipairs(ScriptData.CubeList) do
                    if Cube and Cube.Parent then
                        local Dist = (Cube.Position - (RootPart.Position - Vector3.new(0, 3.5, 0))).Magnitude
                        if Dist < 2 then
                            HasCube = true
                            break
                        end
                    end
                end
                
                if not HasCube then
                    CreateCube(RootPart)
                end
            else
                -- Hareketsiz - cubeları temizle
                CleanupCubes()
            end
        end)
    end)
end

function CreateCube(RootPart)
    local Cube = Instance.new("Part")
    Cube.Name = "AntiKickCube"
    Cube.Size = Vector3.new(4, 0.5, 4)
    Cube.Position = RootPart.Position - Vector3.new(0, 3.5, 0)
    Cube.Anchored = true
    Cube.CanCollide = true
    Cube.Transparency = 1
    Cube.Parent = Workspace
    
    table.insert(ScriptData.CubeList, Cube)
    
    -- 3 saniye sonra otomatik sil
    task.delay(3, function()
        if Cube and Cube.Parent then
            Cube:Destroy()
            local Index = table.find(ScriptData.CubeList, Cube)
            if Index then
                table.remove(ScriptData.CubeList, Index)
            end
        end
    end)
end

function CleanupCubes()
    for i = #ScriptData.CubeList, 1, -1 do
        local Cube = ScriptData.CubeList[i]
        if Cube and Cube.Parent then
            Cube:Destroy()
        end
        table.remove(ScriptData.CubeList, i)
    end
end

function StopCube()
    ScriptData.CubeActive = false
    if ScriptData.CubeConnection then
        ScriptData.CubeConnection:Disconnect()
        ScriptData.CubeConnection = nil
    end
    CleanupCubes()
end

-- ============================================
-- AUTO BAD (ARAÇ GEREKTİRMEDEN - DOĞRUDAN VURMA)
-- ============================================
function StartAutoBad()
    ScriptData.AutoBadActive = true
    
    ScriptData.BadConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not ScriptData.TargetPlayer then return end
            
            local TargetChar = ScriptData.TargetPlayer.Character
            if not TargetChar then return end
            
            local TargetHumanoid = TargetChar:FindFirstChildOfClass("Humanoid")
            local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart")
            if not TargetHumanoid or not TargetRoot then return end
            if TargetHumanoid.Health <= 0 then return end
            
            local MyChar = LocalPlayer.Character
            if not MyChar then return end
            
            local MyRoot = MyChar:FindFirstChild("HumanoidRootPart")
            local MyHumanoid = MyChar:FindFirstChildOfClass("Humanoid")
            if not MyRoot or not MyHumanoid then return end
            
            -- Hedefe doğru uç
            MyHumanoid.PlatformStand = true
            local Direction = (TargetRoot.Position - MyRoot.Position)
            if Direction.Magnitude > 0 then
                MyRoot.AssemblyLinearVelocity = Direction.Unit * ScriptData.FlySpeed
            end
            
            -- Yakınsa vur (tool gerekmez - direkt hasar)
            if Direction.Magnitude < 5 then
                -- Direkt hasar ver
                TargetHumanoid:TakeDamage(10)
                
                -- Knockback efekti
                local Knockback = Direction.Unit * 20
                TargetRoot.AssemblyLinearVelocity = TargetRoot.AssemblyLinearVelocity + Knockback
            end
        end)
    end)
end

function StopAutoBad()
    ScriptData.AutoBadActive = false
    if ScriptData.BadConnection then
        ScriptData.BadConnection:Disconnect()
        ScriptData.BadConnection = nil
    end
    
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then Humanoid.PlatformStand = false end
        if RootPart then RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
end

-- ============================================
-- MEDUSA MODE (1 METRE YAKLAŞINCA OTOMATİK)
-- ============================================
function StartMedusa()
    ScriptData.MedusaActive = true
    
    ScriptData.MedusaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local MyChar = LocalPlayer.Character
            if not MyChar then return end
            
            local MyRoot = MyChar:FindFirstChild("HumanoidRootPart")
            if not MyRoot then return end
            
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player == LocalPlayer then continue end
                
                local TargetChar = Player.Character
                if not TargetChar then continue end
                
                local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart")
                local TargetHumanoid = TargetChar:FindFirstChildOfClass("Humanoid")
                if not TargetRoot or not TargetHumanoid then continue end
                if TargetHumanoid.Health <= 0 then continue end
                
                local Distance = (TargetRoot.Position - MyRoot.Position).Magnitude
                if Distance <= 1 then
                    -- Medusa efekti: dondur ve hasar ver
                    TargetRoot.Anchored = true
                    TargetHumanoid:TakeDamage(25)
                    
                    -- 1 saniye sonra çöz
                    task.delay(1, function()
                        if TargetRoot and TargetRoot.Parent then
                            TargetRoot.Anchored = false
                        end
                    end)
                end
            end
        end)
    end)
end

function StopMedusa()
    ScriptData.MedusaActive = false
    if ScriptData.MedusaConnection then
        ScriptData.MedusaConnection:Disconnect()
        ScriptData.MedusaConnection = nil
    end
end

-- ============================================
-- KARAKTER YENİLENİNCE MENÜ TEKRAR
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(0.5)
    CreateMenu()
    
    -- Ghost mode tekrar aktif et
    if ScriptData.GhostModeActive then
        task.wait(0.1)
        StartGhostMode()
    end
end)

-- ============================================
-- BAŞLAT
-- ============================================
CreateMenu()
print("[Brainrot] Part 1 yüklendi - Part 2'yi çalıştır")-- ============================================
-- STEAL BRAINROT DUEL v4.0 - PART 2 (ANTI-CHEAT BYPASS + KORUMA)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ANTI-KICK: SÜREKLİ MEŞRU VERİ AKIŞI
-- ============================================
spawn(function()
    while true do
        pcall(function()
            local Character = LocalPlayer.Character
            if not Character then return end
            
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            if not Humanoid or not RootPart then return end
            
            -- Çok hafif hareket sinyali (AFK kick engelleme)
            if Humanoid.MoveDirection.Magnitude < 0.01 then
                Humanoid:Move(Vector3.new(0.0001, 0, 0), false)
                task.wait(0.05)
                Humanoid:Move(Vector3.new(-0.0001, 0, 0), false)
            end
        end)
        task.wait(0.15)
    end
end)

-- ============================================
-- ANTI-RESET: ÖLÜM VE SİLİNME ENGELLEME
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    if not Humanoid then return end
    
    -- Ölüm olayını yakala
    Humanoid.Died:Connect(function()
        pcall(function()
            -- Eğer ghost mode aktifse, ölümü engelle
            if _G and _G.GhostModeActive then
                task.wait(0.05)
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                Humanoid.BreakJointsOnDeath = false
                Humanoid.Health = 0.1
            end
        end)
    end)
    
    -- State değişim izleyicisi
    Humanoid.StateChanged:Connect(function(OldState, NewState)
        pcall(function()
            if NewState == Enum.HumanoidStateType.Dead then
                if _G and _G.GhostModeActive then
                    task.wait(0.05)
                    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end)
    end)
    
    -- Health sıfırlanma engelleme
    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        pcall(function()
            if _G and _G.GhostModeActive and Humanoid.Health <= 0 then
                Humanoid.BreakJointsOnDeath = false
                task.wait(0.01)
                Humanoid.Health = 0.1
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)
    end)
    
    -- RootPart silinme engelleme
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if RootPart then
        RootPart.AncestryChanged:Connect(function(_, Parent)
            if Parent == nil then
                pcall(function()
                    if _G and _G.GhostModeActive then
                        task.wait(0.5)
                        -- Karakter yeniden oluşmasını bekle
                    end
                end)
            end
        end)
    end
end)

-- ============================================
-- REMOTE EVENT FİLTRELEME (KİCK/BAN ENGELLE)
-- ============================================
local BlockedPatterns = {
    "kick", "ban", "cheat", "exploit", "hack",
    "detect", "flag", "verify", "check", "report",
    "reset", "teleport", "moderator", "admin"
}

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    
    if Method == "FireServer" or Method == "InvokeServer" then
        if typeof(Self) == "Instance" then
            local Name = Self.Name:lower()
            local ClassName = Self.ClassName:lower()
            
            for _, Pattern in ipairs(BlockedPatterns) do
                if Name:find(Pattern) or ClassName:find(Pattern) then
                    -- Engelle, sessizce nil döndür
                    return nil
                end
            end
        end
    end
    
    return OldNamecall(Self, ...)
end)

-- ============================================
-- ANTI-CRASH: BELLEK TEMİZLİĞİ
-- ============================================
spawn(function()
    while true do
        pcall(function()
            -- Cube listesini temizle (50'den fazla varsa)
            local CubeList = _G.CubeList or ScriptData.CubeList
            if CubeList and #CubeList > 50 then
                for i = 1, 25 do
                    local Cube = CubeList[i]
                    if Cube and Cube.Parent then
                        Cube:Destroy()
                    end
                end
                for i = 1, 25 do
                    table.remove(CubeList, 1)
                end
            end
            
            -- Workspace'deki orphan cubeları temizle
            for _, Obj in ipairs(Workspace:GetChildren()) do
                if Obj.Name == "AntiKickCube" and Obj:IsA("Part") then
                    if not Obj.Parent then
                        Obj:Destroy()
                    end
                end
            end
        end)
        task.wait(5)
    end
end)

-- ============================================
-- ANTI-IDLE: SANAL GİRDİ SİMÜLASYONU
-- ============================================
spawn(function()
    while true do
        pcall(function()
            -- Fare hareketi simülasyonu
            VirtualInputManager:SendMouseMoveEvent(1, 0, game)
            task.wait(0.05)
            VirtualInputManager:SendMouseMoveEvent(-1, 0, game)
            
            -- Tuş basımı simülasyonu
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end)
        task.wait(25)
    end
end)

-- ============================================
-- BAĞLANTI KOPMA KORUMASI
-- ============================================
spawn(function()
    while true do
        pcall(function()
            if not LocalPlayer:IsLoaded() then
                task.wait(3)
            end
        end)
        task.wait(5)
    end
end)

-- ============================================
-- DURUM LOGLAMA (HER 20 SANİYEDE)
-- ============================================
local StartTime = tick()
spawn(function()
    while true do
        task.wait(20)
        pcall(function()
            local Elapsed = tick() - StartTime
            local StatusStr = string.format(
                "[Brainrot] Fly:%s | Ghost:%s | Bad:%s | Medusa:%s | Cube:%s | Hedef:%s | Süre:%.0fs",
                ScriptData.FlyActive and "AÇIK" or "KAPALI",
                ScriptData.GhostModeActive and "AÇIK" or "KAPALI",
                ScriptData.AutoBadActive and "AÇIK" or "KAPALI",
                ScriptData.MedusaActive and "AÇIK" or "KAPALI",
                ScriptData.CubeActive and "AÇIK" or "KAPALI",
                ScriptData.TargetPlayer and ScriptData.TargetPlayer.Name or "YOK",
                Elapsed
            )
            print(StatusStr)
        end)
    end
end)

print("[Brainrot] Part 2 yüklendi - Anti-Cheat Bypass Aktif")
print("[Brainrot] v4.0 Tamamlandı - Temiz kod, gerçek fonksiyonlar")
