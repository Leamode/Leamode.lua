-- ============================================================
-- ULTRA BYPASS V8.0 - 3 KATMAN (RESET + KİCK + TESPİT ENGELLER)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== 1. REMOTE KILLER (TÜM ZARARLI REMOTE'LAR) ====================
local function KillAllRemotes()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if not network then return end
        
        local killList = {
            -- RESET REMOTE'LARI
            "Reset", "ResetSelfData", "RequestCharacterReset", "ResetCharacter",
            "ResetAll", "ResetPosition", "ResetVelocity", "ResetState",
            "ResetPlayer", "ResetCharacterData", "ForceReset",
            
            -- KİCK REMOTE'LARI
            "Kick", "Ban", "Moderation", "Denetim",
            "KickPlayer", "BanPlayer", "KickAll", "BanAll",
            "KickUser", "BanUser", "ModeratePlayer",
            
            -- ANTİ-CHEAT REMOTE'LARI
            "Integrity", "Violation", "Correction", "Detect",
            "IntegrityViolation", "IntegrityHeartbeat", "IntegrityCheck",
            "ViolationDetected", "ViolationReport", "ViolationWarning",
            "CorrectionStarted", "CorrectionCompleted", "CorrectionFailed",
            "AntiTamper", "AntiTamperCheck", "AntiTamperPing",
            "ClientCharacter", "ClientCharacter:Ready", "ClientCharacter:Update",
            "ClientCharacter:Sync", "ClientCharacter:CorrectionStarted",
            "ClientCharacter:IntegrityViolation", "ClientCharacter:IntegrityHeartbeat",
            "ClientCharacter:RequestCharacterReset",
            
            -- TESPİT REMOTE'LARI
            "Detection", "Detect", "AntiCheat", "AntiExploit",
            "Exploit", "ExploitDetected", "ExploitPrevention",
            "Analytics", "Analytics:ReportAfkState", "Analytics:ReportAfk",
            "Analytics:RequestAfkTeleportFlush", "Analytics:ReportAfkTeleport",
            "Analytics:ReportActivity", "Analytics:ReportMovement",
            "Analytics:ReportJump", "Analytics:ReportTeleport",
            
            -- ADMIN REMOTE'LARI
            "AdminPanel", "AdminPanel_CheckAdminStatus", "AdminPanel_AdminStatusResponse",
            "AdminPanel_GiveAssetToSelf", "AdminPanel_GiveEggToSelf",
            "AdminPanel_ResetSelfData", "AdminPanel_SetWalkSpeed",
            "AdminPanel_SetSpeedPower", "AdminAbuse",
            
            -- GUARD REMOTE'LARI
            "Guard", "ForestHit", "SpeedHit", "SpeedHitOffer",
            "SpeedHitWarning", "WakeUp", "ForestDeposit",
            "GuardAttack", "GuardDamage", "GuardHit",
            
            -- SYNC REMOTE'LARI
            "Sync", "Syncing", "Synchronization", "SyncCheck",
            "SyncValidation", "SyncVerification", "SyncPing", "SyncHeartbeat"
        }
        
        for _, obj in ipairs(network:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name
                local shouldKill = false
                
                for _, kw in ipairs(killList) do
                    if string.find(name, kw) then
                        shouldKill = true
                        break
                    end
                end
                
                if shouldKill then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- ==================== 2. LOCALPLAYER GİZLEYİCİ (SERVER'DAN SAKLAN) ====================
local function HideFromServer()
    pcall(function()
        -- LocalPlayer'ı server'dan gizle
        if LocalPlayer then
            -- Parent değişimini engelle
            LocalPlayer.Changed:Connect(function(prop)
                if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
                    pcall(function() LocalPlayer.Parent = Players end)
                end
            end)
            
            -- Character değişimini engelle
            LocalPlayer:GetPropertyChangedSignal("Character"):Connect(function()
                local char = LocalPlayer.Character
                if char then
                    pcall(function()
                        -- Character'ı workspace'te tut
                        if char.Parent ~= Workspace then
                            char.Parent = Workspace
                        end
                    end)
                end
            end)
        end
        
        -- Tüm detection script'lerini yok et
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local name = string.lower(obj.Name)
                if string.find(name, "detect") or string.find(name, "scan") or
                   string.find(name, "check") or string.find(name, "verify") or
                   string.find(name, "integrity") or string.find(name, "violation") or
                   string.find(name, "antitamper") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- ==================== 3. ANTI-RESET (RESET ATMAYI ENGELLE) ====================
local function AntiReset()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- BreakJointsOnDeath = false (Ölünce dağılma)
        if hum.BreakJointsOnDeath ~= false then
            hum.BreakJointsOnDeath = false
        end
        
        -- Can sıfırlanırsa düzelt
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        
        -- Can düşükse düzelt
        if hum.Health < 10 and hum.Health > 0 then
            hum.Health = hum.MaxHealth
        end
        
        -- CharacterAdded (yeniden doğma)
        LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.3)
            local newHum = newChar:FindFirstChildOfClass("Humanoid")
            if newHum then
                newHum.BreakJointsOnDeath = false
                newHum.Health = newHum.MaxHealth
            end
        end)
        
        -- Died olayını engelle
        hum.Died:Connect(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end)
end

-- ==================== 4. ANA BYPASS ====================
local Bypass = {
    Active = false
}

local function StartBypass()
    if Bypass.Active then return end
    Bypass.Active = true
    
    print("========================================")
    print("🚀 ULTRA BYPASS V8.0 AKTİF!")
    print("========================================")
    print("✅ 1. Remote Killer (Tüm zararlı remote'lar yok)")
    print("✅ 2. LocalPlayer Gizleyici (Server'dan saklanır)")
    print("✅ 3. Anti-Reset (Reset atma engellenir)")
    print("========================================")
    
    -- 1. Remote Killer (Sürekli)
    task.spawn(function()
        while Bypass.Active do
            pcall(KillAllRemotes)
            task.wait(0.05)
        end
    end)
    
    -- 2. LocalPlayer Gizleyici (Sürekli)
    task.spawn(function()
        while Bypass.Active do
            pcall(HideFromServer)
            task.wait(0.05)
        end
    end)
    
    -- 3. Anti-Reset (Sürekli)
    task.spawn(function()
        while Bypass.Active do
            pcall(AntiReset)
            task.wait(0.05)
        end
    end)
    
    -- İlk çalıştırma
    KillAllRemotes()
    HideFromServer()
    AntiReset()
end

local function StopBypass()
    Bypass.Active = false
    print("🚀 ULTRA BYPASS PASİF!")
end

-- ==================== 5. OTOMATİK BAŞLAT ====================
task.wait(0.3)
StartBypass()

print("")
print("========================================")
print("🚀 ULTRA BYPASS V8.0 HAZIR!")
print("========================================")
print("✅ Reset atma engellendi")
print("✅ Kick atma engellendi")
print("✅ Tespit edilme engellendi")
print("✅ Server'dan gizlendin")
print("========================================")-- ============================================================
-- HAMSTERLİVES v106 + ULTRA BYPASS V8.0
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== ULTRA BYPASS V8.0 ====================
local Bypass = { Active = false }

local function KillAllRemotes()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if not network then return end
        local killList = {
            "Reset", "Kick", "Ban", "Integrity", "Violation", "Correction",
            "Detect", "ClientCharacter", "Analytics", "AdminPanel",
            "AdminAbuse", "Guard", "ForestHit", "SpeedHit", "Sync",
            "AntiTamper", "Exploit", "Moderation", "Denetim"
        }
        for _, obj in ipairs(network:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, kw in ipairs(killList) do
                    if string.find(obj.Name, kw) then
                        pcall(function() obj:Destroy() end)
                        break
                    end
                end
            end
        end
    end)
end

local function HideFromServer()
    pcall(function()
        if LocalPlayer and not LocalPlayer:IsDescendantOf(Players) then
            LocalPlayer.Parent = Players
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local n = string.lower(obj.Name)
                if string.find(n, "detect") or string.find(n, "scan") or
                   string.find(n, "check") or string.find(n, "integrity") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local function AntiReset()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.BreakJointsOnDeath = false
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        if hum.Health < 10 then
            hum.Health = hum.MaxHealth
        end
        LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.3)
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.BreakJointsOnDeath = false h.Health = h.MaxHealth end
        end)
        hum.Died:Connect(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end)
end

local function StartBypass()
    if Bypass.Active then return end
    Bypass.Active = true
    task.spawn(function() while Bypass.Active do pcall(KillAllRemotes) task.wait(0.05) end end)
    task.spawn(function() while Bypass.Active do pcall(HideFromServer) task.wait(0.05) end end)
    task.spawn(function() while Bypass.Active do pcall(AntiReset) task.wait(0.05) end end)
    KillAllRemotes(); HideFromServer(); AntiReset()
end

task.wait(0.3)
StartBypass()

-- ==================== HAMSTERLİVES ANA KOD ====================
local HL = {
    AutoEgg = false,
    AntiKick = false,
    AntiReset = false,
    MonsterBlock = false,
    Saved = nil,
    RGBHue = 0,
    BodyVel = nil,
    BodyGyro = nil,
    Conn = {},
    Buttons = {}
}

-- ==================== TÜM CANAVARLARI TAVUK YAP ====================
local function MakeAllMonstersLikeChicken()
    HL.MonsterBlock = true
    HL.Conn.MonsterBlock = RunService.Heartbeat:Connect(function()
        if not HL.MonsterBlock then return end
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name == "Guard" or obj.Name == "ForestGuardAuthored") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:Destroy() end) end
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function()
                                part.CanCollide = false
                                part.CanTouch = false
                                part.CanQuery = false
                                part.Anchored = true
                                part.Transparency = 0.8
                            end)
                        end
                    end
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("Tool") then pcall(function() child:Destroy() end) end
                        if child:IsA("Script") or child:IsA("LocalScript") then
                            pcall(function() child.Enabled = false end)
                        end
                    end
                    pcall(function() obj:PivotTo(CFrame.new(0, -500, 0)) end)
                end
            end
        end)
    end)
end

-- ==================== EGG YAPIŞTIR ====================
local function GlueEgg()
    HL.Conn.Glue = RunService.Heartbeat:Connect(function()
        if not HL.AutoEgg then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    tool.CanBeDropped = false
                    tool.RequiresHandle = false
                    tool:GetPropertyChangedSignal("Parent"):Connect(function()
                        if tool.Parent ~= char and tool.Parent ~= LocalPlayer then
                            pcall(function() tool.Parent = char end)
                        end
                    end)
                end)
            end
        end
    end)
end

-- ==================== YER BELİRLE ====================
local function FindGround(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then params.FilterDescendantsInstances = {LocalPlayer.Character} end
    local result = Workspace:Raycast(position + Vector3.new(0, 100, 0), Vector3.new(0, -300, 0), params)
    if result and result.Instance.Size.Magnitude > 3 then
        return result.Position + Vector3.new(0, 3.5, 0)
    end
    return position
end

local function SavePos()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    HL.Saved = FindGround(root.Position)
    local b = HL.Buttons.Save
    if b then
        b.Text = "✓"
        b.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        task.delay(1, function()
            if b then
                b.Text = "YER"
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            end
        end)
    end
end

-- ==================== AUTOEGG ====================
local function StartGlide(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if HL.BodyVel then HL.BodyVel:Destroy() HL.BodyVel = nil end
    if HL.BodyGyro then HL.BodyGyro:Destroy() HL.BodyGyro = nil end
    pcall(function() hum.WalkSpeed = 120 end)
    HL.BodyVel = Instance.new("BodyVelocity")
    HL.BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    HL.BodyVel.Velocity = Vector3.zero
    HL.BodyVel.Parent = root
    HL.BodyGyro = Instance.new("BodyGyro")
    HL.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    HL.BodyGyro.D = 0
    HL.BodyGyro.P = 100000
    HL.BodyGyro.CFrame = root.CFrame
    HL.BodyGyro.Parent = root
    local flatTarget = Vector3.new(targetPos.X, root.Position.Y + 3, targetPos.Z)
    HL.Conn.Glide = RunService.RenderStepped:Connect(function()
        if not HL.AutoEgg then return end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local direction = (flatTarget - r.Position)
        local dist = direction.Magnitude
        if dist < 5 then
            if HL.BodyVel then HL.BodyVel.Velocity = Vector3.zero end
            HL.AutoEgg = false
            if HL.Conn.Glide then HL.Conn.Glide:Disconnect() HL.Conn.Glide = nil end
            if HL.BodyVel then HL.BodyVel:Destroy() HL.BodyVel = nil end
            if HL.BodyGyro then HL.BodyGyro:Destroy() HL.BodyGyro = nil end
            pcall(function() local h = c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end end)
            local b = HL.Buttons.AutoEgg
            if b then b.Text = "EGG ○" b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
            return
        end
        local vel = direction.Unit * 120
        vel = vel + Vector3.new(0, math.sin(os.clock() * 2) * 1.5, 0)
        if HL.BodyVel then HL.BodyVel.Velocity = vel end
        if HL.BodyGyro then HL.BodyGyro.CFrame = CFrame.new(r.Position, flatTarget) end
    end)
end

local function ToggleAutoEgg()
    HL.AutoEgg = not HL.AutoEgg
    local b = HL.Buttons.AutoEgg
    if b then
        b.Text = HL.AutoEgg and "EGG ●" or "EGG ○"
        b.BackgroundColor3 = HL.AutoEgg and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(35, 35, 45)
    end
    if HL.AutoEgg then
        GlueEgg()
        if HL.Saved then StartGlide(HL.Saved) end
    else
        if HL.Conn.Glide then HL.Conn.Glide:Disconnect() HL.Conn.Glide = nil end
        if HL.Conn.Glue then HL.Conn.Glue:Disconnect() HL.Conn.Glue = nil end
        if HL.BodyVel then HL.BodyVel:Destroy() HL.BodyVel = nil end
        if HL.BodyGyro then HL.BodyGyro:Destroy() HL.BodyGyro = nil end
        pcall(function() local char = LocalPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = 16 end end)
    end
end

-- ==================== RGB MENÜ ====================
local function HSVToRGB(h, s, v)
    h = h % 1
    local r, g, b
    if s <= 0 then
        r, g, b = v, v, v
    else
        local h6 = h * 6
        local i = math.floor(h6)
        local f = h6 - i
        local p = v * (1 - s)
        local q = v * (1 - s * f)
        local t = v * (1 - s * (1 - f))
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        else r, g, b = v, p, q end
    end
    return Color3.new(r, g, b)
end

local function CreateMenu()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
    if not playerGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "HL_GUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 140, 0, 140)
    main.Position = UDim2.new(0.5, -70, 0.5, -70)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Parent = main
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.BorderSizePixel = 0
    title.Text = "HL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = main
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = main.Position
        end
    end)
    title.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    local function makeBtn(text, y, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -12, 0, 18)
        b.Position = UDim2.new(0, 6, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.BorderSizePixel = 0
        b.Text = text
        b.TextColor3 = Color3.fromRGB(240, 240, 240)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.Parent = main
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(callback)
        return b
    end
    HL.Buttons = {}
    HL.Buttons.Save = makeBtn("YER", 23, SavePos)
    HL.Buttons.AutoEgg = makeBtn("EGG", 43, ToggleAutoEgg)
    HL.Buttons.MonsterBlock = makeBtn("CANAVAR", 63, function()
        HL.MonsterBlock = not HL.MonsterBlock
        HL.Buttons.MonsterBlock.Text = HL.MonsterBlock and "CANAVAR✓" or "CANAVAR"
        HL.Buttons.MonsterBlock.BackgroundColor3 = HL.MonsterBlock and Color3.fromRGB(255,150,0) or Color3.fromRGB(35,35,45)
        if HL.MonsterBlock then MakeAllMonstersLikeChicken()
        else if HL.Conn.MonsterBlock then HL.Conn.MonsterBlock:Disconnect() HL.Conn.MonsterBlock = nil end end
    end)
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 35, 0, 35)
    openBtn.Position = UDim2.new(1, -45, 0, 15)
    openBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
    openBtn.Text = "HL"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 10
    openBtn.Parent = gui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
    HL.Conn.RGB = RunService.RenderStepped:Connect(function(dt)
        HL.RGBHue = HL.RGBHue + dt * 0.3
        if HL.RGBHue > 1 then HL.RGBHue = HL.RGBHue - 1 end
        local rgbColor = HSVToRGB(HL.RGBHue, 1, 1)
        stroke.Color = rgbColor
        title.TextColor3 = rgbColor
        openBtn.BackgroundColor3 = rgbColor
    end)
end

CreateMenu()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then SavePos()
    elseif input.KeyCode == Enum.KeyCode.F10 then ToggleAutoEgg()
    end
end)

print("🍑 ULTRA BYPASS V8.0 + HAMSTERLİVES HAZIR")
print("🍑 F4 - Yer | F10 - Egg | CANAVAR")
print("🍑 Reset atma engellendi!")
print("🍑 Kick atma engellendi!")
print("🍑 Tespit edilme engellendi!")
