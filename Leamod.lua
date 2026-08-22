-- ============================================================
-- CRAZYHUB ULTRA V1.0 - TAM KAPSAMLI SİSTEM
-- Anti-Reset (BreakJointsOnDeath) + Anti-Kick + Teleport + Egg Guard
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== DEĞİŞKENLER ====================
local Settings = {
    AutoEgg = false,
    AntiReset = false,
    AntiKick = false,
    SavedPos = nil,
    Teleporting = false,
    EggGlued = false,
    TeleportCount = 0
}

-- ==================== CRAZYHUB ANTI-RESET ====================
-- CrazyHub'ın anti-reset sistemi: BreakJointsOnDeath = false
-- Can 0 olsa bile ölmez, karakter dağılmaz
local function CrazyHubAntiReset()
    if Settings.AntiReset then return end
    Settings.AntiReset = true
    
    -- Karakteri koru (BreakJointsOnDeath = false)
    local function protectCharacter()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- CrazyHub'ın en önemli özelliği: BreakJointsOnDeath = false
        hum.BreakJointsOnDeath = false
        
        -- Can 0 olsa bile ölme
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        
        -- Can düşükse düzelt
        if hum.Health < 10 then
            hum.Health = hum.MaxHealth
        end
        
        -- PlatformStand KAPALI (normal durur)
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
    
    -- Died olayını engelle
    local function blockDeath()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        hum.Died:Connect(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
            print("💀 Ölüm engellendi! (CrazyHub Anti-Reset)")
        end)
    end
    
    -- CharacterAdded olayı
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.Health = hum.MaxHealth
            print("🔄 Karakter yeniden doğdu! (CrazyHub Anti-Reset)")
        end
    end)
    
    -- Sürekli koruma döngüsü
    task.spawn(function()
        while Settings.AntiReset do
            task.wait(0.1)
            pcall(protectCharacter)
        end
    end)
    
    protectCharacter()
    blockDeath()
    print("🔄 CrazyHub Anti-Reset AKTİF! (BreakJointsOnDeath = false)")
end

-- ==================== CRAZYHUB ANTI-KICK ====================
-- CrazyHub'ın anti-kick sistemi: Tüm kick remote'larını yok eder
local function CrazyHubAntiKick()
    if Settings.AntiKick then return end
    Settings.AntiKick = true
    
    -- Tüm kick/ban remote'larını yok et
    local function killKickRemotes()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                        local name = string.lower(obj.Name)
                        local killList = {
                            "kick", "ban", "integrity", "violation", 
                            "correction", "detect", "antitamper", 
                            "clientcharacter", "exploit", "ping"
                        }
                        for _, kw in ipairs(killList) do
                            if string.find(name, kw) then
                                pcall(function() obj:Destroy() end)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- LocalPlayer koruması
    LocalPlayer.Changed:Connect(function(prop)
        if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
            pcall(function() LocalPlayer.Parent = Players end)
        end
    end)
    
    -- GUI temizleme
    local function cleanGUI()
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, child in pairs(playerGui:GetChildren()) do
                    local name = string.lower(child.Name)
                    if string.find(name, "kick") or string.find(name, "ban") or
                       string.find(name, "error") or string.find(name, "denetim") or
                       string.find(name, "moderation") or string.find(name, "integrity") then
                        child:Destroy()
                    end
                end
            end
        end)
    end
    
    -- Sürekli kontrol
    task.spawn(function()
        while Settings.AntiKick do
            task.wait(0.5)
            pcall(function()
                killKickRemotes()
                cleanGUI()
                if not LocalPlayer:IsDescendantOf(Players) then
                    LocalPlayer.Parent = Players
                end
            end)
        end
    end)
    
    killKickRemotes()
    cleanGUI()
    print("🛡️ CrazyHub Anti-Kick AKTİF!")
end

-- ==================== TELEPORT (CRAZYHUB) ====================
-- CrazyHub'ın teleport sistemi: Anında ışınlanma
local function TeleportTo(pos)
    if Settings.Teleporting then return end
    Settings.Teleporting = true
    
    local char = LocalPlayer.Character
    if not char then 
        Settings.Teleporting = false 
        return 
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then 
        Settings.Teleporting = false 
        return 
    end
    
    -- Havada kalsın (CrazyHub'daki gibi)
    local target = Vector3.new(pos.X, pos.Y + 3, pos.Z)
    
    -- ANINDA IŞINLAN
    pcall(function()
        root.CFrame = CFrame.new(target)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
    
    Settings.TeleportCount = Settings.TeleportCount + 1
    if Settings.TeleportCount % 5 == 0 then
        print("📍 " .. Settings.TeleportCount .. ". ışınlanma!")
    end
    
    Settings.Teleporting = false
end

-- ==================== EGG YAPIŞTIR (CRAZYHUB) ====================
-- CrazyHub'ın egg yapıştırma sistemi: Egg düşmez
local function GlueEgg()
    if Settings.EggGlued then return end
    Settings.EggGlued = true
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool.CanBeDropped = false
                tool.RequiresHandle = false
                if not tool._Glued then
                    tool._Glued = true
                    tool:GetPropertyChangedSignal("Parent"):Connect(function()
                        if tool.Parent ~= char and tool.Parent ~= LocalPlayer then
                            pcall(function() tool.Parent = char end)
                        end
                    end)
                end
            end
        end
    end)
end

-- ==================== YER KAYDET ====================
local function SavePos()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Settings.SavedPos = root.Position
    print("📍 Yer kaydedildi! (" .. string.format("%.1f", Settings.SavedPos.X) .. ", " .. string.format("%.1f", Settings.SavedPos.Y) .. ", " .. string.format("%.1f", Settings.SavedPos.Z) .. ")")
end

-- ==================== AUTO EGG ====================
local function ToggleAutoEgg()
    Settings.AutoEgg = not Settings.AutoEgg
    
    if Settings.AutoEgg then
        print("🥚 AUTO EGG AKTİF - CrazyHub Sistemi")
        
        -- CrazyHub sistemlerini başlat
        CrazyHubAntiReset()
        CrazyHubAntiKick()
        GlueEgg()
        
        if not Settings.SavedPos then
            print("⚠️ Önce F4 ile yer kaydet!")
        end
        
        -- Ana döngü
        task.spawn(function()
            while Settings.AutoEgg do
                pcall(function()
                    -- Sürekli koruma
                    if Settings.AntiReset then
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.BreakJointsOnDeath = false
                                if hum.Health <= 0 then
                                    hum.Health = hum.MaxHealth
                                    hum:ChangeState(Enum.HumanoidStateType.Running)
                                end
                            end
                        end
                    end
                    
                    -- Teleport (sadece kaydedilen yere)
                    if Settings.SavedPos then
                        TeleportTo(Settings.SavedPos)
                    end
                    
                    -- Egg yapıştır
                    GlueEgg()
                end)
                task.wait(0.05)
            end
        end)
    else
        print("🥚 AUTO EGG PASİF")
    end
end

-- ==================== TUŞLAR ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        SavePos()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        ToggleAutoEgg()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        CrazyHubAntiKick()
    elseif input.KeyCode == Enum.KeyCode.F11 then
        CrazyHubAntiReset()
    end
end)

-- ==================== BAŞLAT ====================
print("")
print("========================================")
print("🔥 CRAZYHUB ULTRA V1.0")
print("========================================")
print("📍 F4 - Yer kaydet (Buraya ışınlanacaksın)")
print("🥚 F10 - AUTO EGG (Kaydedilen yere git)")
print("🛡️ F7 - ANTI-KICK (CrazyHub sistemi)")
print("🔄 F11 - ANTI-RESET (CrazyHub sistemi)")
print("========================================")
print("✅ CrazyHub Anti-Reset: BreakJointsOnDeath = false")
print("✅ CrazyHub Anti-Kick: Tüm kick remote'ları yok edilir")
print("✅ CrazyHub Teleport: Anında ışınlanma")
print("✅ CrazyHub Egg: Egg düşmez (yapıştırılır)")
print("✅ Can 0 olsa bile ölmezsin!")
print("========================================")
