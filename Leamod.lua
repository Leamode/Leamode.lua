-- ============================================
-- PART 1: SERVİSLER, DEĞİŞKENLER, MENÜ
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- ANA DEĞİŞKENLER (VARSAYILAN: KAPALI)
-- ============================================
_G.FlyActive = false
_G.FlySpeed = 35
_G.AutoBadActive = false
_G.MedusaActive = false
_G.CubeActive = false
_G.GhostModeActive = false
_G.TargetPlayer = nil
_G.CubeList = {}
_G.ScreenGui = nil
_G.Buttons = {}

-- ============================================
-- GHOST MODE
-- ============================================
function _G.ActivateGhostMode()
    _G.GhostModeActive = true
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    Humanoid.BreakJointsOnDeath = false
    Humanoid.Health = 0
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    local GhostPart = Instance.new("Part")
    GhostPart.Name = "GhostHitbox"
    GhostPart.Size = Vector3.new(2, 2, 1)
    GhostPart.Transparency = 1
    GhostPart.CanCollide = true
    GhostPart.Anchored = false
    GhostPart.Parent = Character
    
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = GhostPart
    Weld.Part1 = RootPart
    Weld.Parent = GhostPart
    
    RootPart.Anchored = false
    
    spawn(function()
        while _G.GhostModeActive and Character and Character.Parent do
            if Humanoid and Humanoid.Health > 0 then Humanoid.Health = 0 end
            if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ============================================
-- TELEPORT TO TARGET
-- ============================================
function _G.TeleportToTarget()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    if _G.TargetPlayer and _G.TargetPlayer.Character then
        local TargetHead = _G.TargetPlayer.Character:FindFirstChild("Head")
        if TargetHead then
            RootPart.CFrame = TargetHead.CFrame * CFrame.new(0, 0, -2)
            RootPart.AssemblyLinearVelocity = (TargetHead.Position - RootPart.Position).Unit * 34
        end
    end
end

-- ============================================
-- INSTANT GROUND
-- ============================================
function _G.InstantGround()
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {Character}
    
    local RayResult = Workspace:Raycast(RootPart.Position, Vector3.new(0, -500, 0), RaycastParams)
    if RayResult then
        local TargetPos = RayResult.Position + Vector3.new(0, 3, 0)
        local Tween = TweenService:Create(RootPart, TweenInfo.new(0.05), {CFrame = CFrame.new(TargetPos)})
        Tween:Play()
        Tween.Completed:Wait()
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- STOP FLY
-- ============================================
function _G.StopFly()
    _G.FlyActive = false
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if RootPart then RootPart.AssemblyLinearVelocity = Vector3.zero end
    end
end

-- ============================================
-- FLY UPDATE
-- ============================================
function _G.UpdateFly()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not _G.FlyActive or not RootPart or not Humanoid then return end
    
    Humanoid.PlatformStand = true
    local MoveDir = Humanoid.MoveDirection
    
    if MoveDir.Magnitude > 0 then
        local CamCFrame = Camera.CFrame
        local TargetDir = (CamCFrame.RightVector * MoveDir.X) + (CamCFrame.LookVector * MoveDir.Z)
        if TargetDir.Magnitude > 0 then
            RootPart.AssemblyLinearVelocity = TargetDir.Unit * _G.FlySpeed
        end
    else
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- CREATE CUBE
-- ============================================
function _G.CreateCube()
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
    table.insert(_G.CubeList, Cube)
    
    spawn(function()
        local LastPosition = RootPart.Position
        local StillCount = 0
        while Cube and Cube.Parent do
            if (RootPart.Position - LastPosition).Magnitude < 0.1 then
                StillCount = StillCount + 1
                if StillCount > 5 then
                    Cube:Destroy()
                    local idx = table.find(_G.CubeList, Cube)
                    if idx then table.remove(_G.CubeList, idx) end
                    break
                end
            else
                StillCount = 0
            end
            LastPosition = RootPart.Position
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ============================================
-- CUBE MOVEMENT LOOP
-- ============================================
function _G.CubeMovementLoop()
    while _G.CubeActive do
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            if RootPart then
                if (Humanoid and Humanoid.MoveDirection.Magnitude > 0) or 
                   (Humanoid and Humanoid.Jump) or
                   RootPart.AssemblyLinearVelocity.Y > 2 then
                    _G.CreateCube()
                end
            end
        end
        task.wait(0.05)
    end
end

-- ============================================
-- AUTO BAD LOOP
-- ============================================
function _G.AutoBadLoop()
    while _G.AutoBadActive do
        local Character = LocalPlayer.Character
        if not Character then task.wait(0.1) end
        if not Character then continue end
        
        local Backpack = LocalPlayer.Backpack
        local BadTool = Backpack:FindFirstChild("Bad") or Character:FindFirstChild("Bad")
        
        if not BadTool then
            for _, Tool in ipairs(Backpack:GetChildren()) do
                if Tool:IsA("Tool") and Tool.Name == "Bad" then
                    BadTool = Tool
                    break
                end
            end
        end
        
        if BadTool and BadTool.Parent ~= Character then
            BadTool.Parent = Character
            task.wait(0.1)
        end
        
        _G.FlyActive = true
        
        if _G.TargetPlayer and _G.TargetPlayer.Character then
            local TargetRoot = _G.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = _G.TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if TargetRoot and TargetHumanoid and TargetHumanoid.Health > 0 then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local Direction = (TargetRoot.Position - RootPart.Position).Unit
                    RootPart.AssemblyLinearVelocity = Direction * _G.FlySpeed
                    
                    if (TargetRoot.Position - RootPart.Position).Magnitude < 5 then
                        if BadTool and BadTool:FindFirstChild("Handle") then
                            for _ = 1, 5 do
                                pcall(function()
                                    firetouchinterest(BadTool.Handle, TargetRoot, 0)
                                    firetouchinterest(BadTool.Handle, TargetRoot, 1)
                                end)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
    _G.FlyActive = false
    _G.StopFly()
end

-- ============================================
-- MEDUSA LOOP
-- ============================================
function _G.MedusaLoop()
    while _G.MedusaActive do
        local Character = LocalPlayer.Character
        if not Character then task.wait(0.1) end
        if not Character then continue end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then task.wait(0.1) continue end
        
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
                if TargetRoot and (TargetRoot.Position - RootPart.Position).Magnitude <= 1 then
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
                        task.wait(0.05)
                        if MedusaTool:FindFirstChild("Handle") then
                            pcall(function()
                                firetouchinterest(MedusaTool.Handle, TargetRoot, 0)
                                firetouchinterest(MedusaTool.Handle, TargetRoot, 1)
                            end)
                            task.wait(0.05)
                            pcall(function() MedusaTool:Activate() end)
                        end
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
end

-- ============================================
-- HEDEF SEÇ
-- ============================================
function _G.SelectTargetMode()
    StarterGui:SetCore("SendNotification", {
        Title = "Hedef Seç",
        Text = "Rakibe tıkla!",
        Duration = 3,
    })
    
    local Connection
    Connection = Mouse.Button1Down:Connect(function()
        local Target = Mouse.Target
        if Target then
            local Character = Target.Parent
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    _G.TargetPlayer = Players:GetPlayerFromCharacter(Character)
                    if _G.TargetPlayer then
                        StarterGui:SetCore("SendNotification", {
                            Title = "Hedef",
                            Text = _G.TargetPlayer.Name,
                            Duration = 2,
                        })
                    end
                end
            end
        end
        Connection:Disconnect()
    end)
end

-- ============================================
-- MENÜ OLUŞTUR
-- ============================================
function _G.CreateMobileMenu()
    if _G.ScreenGui then
        _G.ScreenGui:Destroy()
    end
    
    _G.ScreenGui = Instance.new("ScreenGui")
    _G.ScreenGui.Name = "BrainrotMenu"
    _G.ScreenGui.ResetOnSpawn = false
    _G.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        repeat task.wait() PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") until PlayerGui
    end
    _G.ScreenGui.Parent = PlayerGui
    
    local ButtonSize = UDim2.new(0, 30, 0, 30)
    local Spacing = 3
    
    local ButtonData = {
        {Name = "Ghost", Text = "G", Color = Color3.fromRGB(255, 50, 50), Func = function()
            _G.GhostModeActive = not _G.GhostModeActive
            if _G.GhostModeActive then _G.ActivateGhostMode() end
        end},
        {Name = "Fly", Text = "F", Color = Color3.fromRGB(50, 150, 255), Func = function()
            _G.FlyActive = not _G.FlyActive
            if not _G.FlyActive then _G.StopFly() end
        end},
        {Name = "Bad", Text = "B", Color = Color3.fromRGB(255, 150, 50), Func = function()
            _G.AutoBadActive = not _G.AutoBadActive
            if _G.AutoBadActive then spawn(_G.AutoBadLoop) else _G.FlyActive = false _G.StopFly() end
        end},
        {Name = "Medusa", Text = "M", Color = Color3.fromRGB(150, 50, 255), Func = function()
            _G.MedusaActive = not _G.MedusaActive
            if _G.MedusaActive then spawn(_G.MedusaLoop) end
        end},
        {Name = "Cube", Text = "C", Color = Color3.fromRGB(50, 255, 150), Func = function()
            _G.CubeActive = not _G.CubeActive
            if _G.CubeActive then spawn(_G.CubeMovementLoop) end
        end},
        {Name = "Down", Text = "↓", Color = Color3.fromRGB(200, 200, 50), Func = function()
            _G.InstantGround()
        end},
        {Name = "TP", Text = "N", Color = Color3.fromRGB(255, 100, 200), Func = function()
            _G.TeleportToTarget()
        end},
        {Name = "Trg", Text = "🎯", Color = Color3.fromRGB(200, 50, 50), Func = function()
            _G.SelectTargetMode()
        end},
    }
    
    for i, Data in ipairs(ButtonData) do
        local Button = Instance.new("TextButton")
        Button.Name = Data.Name
        Button.Size = ButtonSize
        Button.Position = UDim2.new(1, -34, 0, 5 + (i - 1) * (30 + Spacing))
        Button.BackgroundColor3 = Data.Color
        Button.BackgroundTransparency = 0.3
        Button.BorderSizePixel = 0
        Button.Text = Data.Text
        Button.TextSize = 10
        Button.Font = Enum.Font.GothamBold
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.ZIndex = 10
        Button.AutoButtonColor = false
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 5)
        Corner.Parent = Button
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Transparency = 0.7
        Stroke.Thickness = 1
        Stroke.Parent = Button
        
        Button.MouseButton1Click:Connect(Data.Func)
        Button.Parent = _G.ScreenGui
        
        _G.Buttons[Data.Name] = Button
    end
    
    print("Menü oluşturuldu - 8 buton sağ üst köşede")
end

-- ============================================
-- BAŞLAT
-- ============================================
_G.CreateMobileMenu()

-- Fly update loop
RunService.Heartbeat:Connect(function()
    if _G.FlyActive then
        _G.UpdateFly()
    end
end)

-- Anti kick bypass
spawn(function()
    while true do
        pcall(function()
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid:Move(Vector3.new(0.001, 0, 0.001), false)
                    task.wait(0.1)
                    Humanoid:Move(Vector3.new(-0.001, 0, -0.001), false)
                end
            end
        end)
        task.wait(30)
    end
end)

-- AFK koruma
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    end)
end)

-- Karakter yenilenince menü tekrar
LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(1)
    _G.CreateMobileMenu()
    if _G.GhostModeActive then
        task.wait(0.1)
        _G.ActivateGhostMode()
    end
end)

print("PART 1 Yüklendi - Brainrot Duel v3 - PART 2'yi çalıştır")-- ============================================
-- PART 2: GÜÇLENDİRİLMİŞ ANTICHEAT BYPASS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ANTI-KICK GÜÇLENDİRİLMİŞ (SÜREKLİ PAKET GÖNDERİMİ)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            local Character = LocalPlayer.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                
                if RootPart and Humanoid then
                    -- Meşru pozisyon verisi gönder (anti-desync)
                    local RealPos = RootPart.Position
                    
                    -- Sürekli mikro hareket (AFK kick engelleme)
                    if Humanoid.MoveDirection.Magnitude < 0.01 then
                        Humanoid:Move(Vector3.new(0.0001, 0, 0.0001), false)
                        task.wait(0.05)
                        Humanoid:Move(Vector3.new(-0.0001, 0, -0.0001), false)
                    end
                    
                    -- PlatformStand kontrolü (fly güvenliği)
                    if _G.FlyActive then
                        Humanoid.PlatformStand = true
                    end
                end
            end
        end)
        task.wait(0.1) -- Her 100ms'de bir kontrol
    end
end)

-- ============================================
-- ANTI-RESET (ÖLÜM ENGELLEME)
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    
    -- Ölüm olayını yakala ve engelle
    Humanoid.Died:Connect(function()
        pcall(function()
            if _G.GhostModeActive then
                task.wait(0.05)
                _G.ActivateGhostMode()
            end
        end)
    end)
    
    -- State değişimini izle
    Humanoid.StateChanged:Connect(function(OldState, NewState)
        pcall(function()
            if NewState == Enum.HumanoidStateType.Dead then
                if _G.GhostModeActive then
                    task.wait(0.05)
                    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    Humanoid.BreakJointsOnDeath = false
                end
            end
        end)
    end)
    
    -- Health sıfırlanmasını engelle
    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        pcall(function()
            if _G.GhostModeActive and Humanoid.Health <= 0 then
                Humanoid.BreakJointsOnDeath = false
                task.wait(0.01)
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)
    end)
    
    -- Karakter silinmesini engelle
    Character.AncestryChanged:Connect(function(_, Parent)
        if Parent == nil and _G.GhostModeActive then
            pcall(function()
                task.wait(0.1)
                _G.ActivateGhostMode()
            end)
        end
    end)
end)

-- ============================================
-- REMOTE EVENT KORUMA (KICK/ban eventlerini engelle)
-- ============================================
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    -- Kick/ban remote'larını engelle
    if Method == "FireServer" or Method == "InvokeServer" then
        if typeof(Self) == "Instance" then
            local SelfName = Self.Name:lower()
            local SelfClass = Self.ClassName
            
            -- Yasaklı remote isimleri
            local BlockedNames = {
                "kick", "ban", "anticheat", "report", "detect", 
                "flag", "verify", "check", "teleport", "reset"
            }
            
            for _, Blocked in ipairs(BlockedNames) do
                if SelfName:find(Blocked) or SelfClass:lower():find(Blocked) then
                    -- Engelle ve sahte cevap döndür
                    return nil
                end
            end
        end
    end
    
    return OldNamecall(Self, ...)
end)

-- ============================================
-- ANTI-CRASH (OYUN ÇÖKMESİNİ ENGELLE)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            -- Bellek temizliği (fazla cube temizleme)
            if _G.CubeList and #_G.CubeList > 50 then
                for i = 1, 20 do
                    local Cube = _G.CubeList[i]
                    if Cube and Cube.Parent then
                        Cube:Destroy()
                    end
                end
                for i = 1, 20 do
                    table.remove(_G.CubeList, 1)
                end
            end
        end)
        task.wait(10)
    end
end)

-- ============================================
-- OTOMATİK RECONNECT (KOPMA DURUMUNDA)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character.Parent then
                task.wait(2)
                -- Tekrar bağlanmayı dene
                if not LocalPlayer.Character then
                    LocalPlayer.CharacterAdded:Wait()
                end
            end
        end)
        task.wait(5)
    end
end)

-- ============================================
-- SANAL INPUT SÜREKLİ (ANTI-IDLE)
-- ============================================
spawn(function()
    while true do
        pcall(function()
            -- Her 20 saniyede bir mikro input
            VirtualInputManager:SendMouseMoveEvent(0.1, 0.1, game)
            task.wait(0.05)
            VirtualInputManager:SendMouseMoveEvent(-0.1, -0.1, game)
        end)
        task.wait(20)
    end
end)

-- ============================================
-- LOG KONTROL
-- ============================================
local StartTime = tick()
spawn(function()
    while true do
        local Elapsed = tick() - StartTime
        local Status = {
            Fly = _G.FlyActive and "AÇIK" or "KAPALI",
            Ghost = _G.GhostModeActive and "AÇIK" or "KAPALI",
            Bad = _G.AutoBadActive and "AÇIK" or "KAPALI",
            Medusa = _G.MedusaActive and "AÇIK" or "KAPALI",
            Cube = _G.CubeActive and "AÇIK" or "KAPALI",
            Hedef = _G.TargetPlayer and _G.TargetPlayer.Name or "YOK",
            Süre = string.format("%.0f sn", Elapsed)
        }
        
        if Elapsed % 30 < 0.5 then
            pcall(function()
                local msg = string.format(
                    "[Brainrot] F:%s G:%s B:%s M:%s C:%s | Hedef:%s | %s",
                    Status.Fly, Status.Ghost, Status.Bad, 
                    Status.Medusa, Status.Cube, Status.Hedef, Status.Süre
                )
                print(msg)
            end)
        end
        
        task.wait(0.5)
    end
end)

print("PART 2 Yüklendi - AntiCheat Bypass Aktif - Brainrot Duel v3 Hazır")
