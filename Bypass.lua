-- ============================================================
-- PART 1: EVRİMSEL BYPASS V8.0 - ÇEKİRDEK SİSTEM
-- 3 Hile Servisi + 5 Gizleme Katmanı + 10 Bypass Katmanı
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==================== EVRİM SİSTEMİ ====================
local Evolution = {
    Active = false,
    Level = 0,
    MaxLevel = 10,
    Adaptations = {},
    Detections = {},
    BypassLayers = {},
    EvolutionHistory = {}
}

-- ==================== 10 KATMAN REMOTE KİLL LİSTESİ ====================
local KillList = {
    "ClientCharacter", "ClientCharacter:Ready", "ClientCharacter:Update",
    "ClientCharacter:Sync", "ClientCharacter:CorrectionStarted",
    "ClientCharacter:IntegrityViolation", "ClientCharacter:IntegrityHeartbeat",
    "ClientCharacter:RequestCharacterReset", "ClientCharacter:Reset",
    "ClientCharacter:Teleport", "ClientCharacter:PositionCheck",
    "ClientCharacter:VelocityCheck", "ClientCharacter:HealthCheck",
    "Integrity", "IntegrityViolation", "IntegrityHeartbeat", "IntegrityCheck",
    "IntegrityValidation", "IntegrityVerification", "IntegrityPing",
    "Violation", "ViolationDetected", "ViolationReport", "ViolationWarning",
    "Correction", "CorrectionStarted", "CorrectionCompleted", "CorrectionFailed",
    "Kick", "Ban", "Moderation", "Denetim", "KickPlayer", "BanPlayer",
    "AdminPanel", "AdminPanel_CheckAdminStatus", "AdminPanel_AdminStatusResponse",
    "AdminPanel_GiveAssetToSelf", "AdminPanel_GiveEggToSelf",
    "AdminPanel_ResetSelfData", "AdminPanel_SetWalkSpeed", "AdminPanel_SetSpeedPower",
    "AdminAbuse", "AdminAbuse_GetEventNames", "AdminAbuse_GetActiveEvents",
    "Analytics", "Analytics:ReportAfkState", "Analytics:ReportAfk",
    "Analytics:RequestAfkTeleportFlush", "Analytics:ReportAfkTeleport",
    "Detection", "Detect", "AntiCheat", "AntiExploit", "Exploit", "ExploitDetected",
    "AntiTamper", "AntiTamperCheck", "AntiTamperPing",
    "Reset", "ResetSelfData", "RequestCharacterReset", "ResetCharacter",
    "Sync", "Syncing", "Synchronization", "SyncCheck",
    "Guard", "GuardAttack", "GuardDamage", "GuardHit", "ForestHit",
    "SpeedHit", "SpeedHitOffer", "SpeedHitWarning", "WakeUp",
    "UnequipTool", "RuntimeOwnerCleared", "RuntimeOwnerUpdated",
    "AreaEggDrop", "RequestAreaEggDrop", "RequestUnequip",
    "Spawn", "Respawn", "Revive", "Teleport", "TP", "Position",
    "Ping", "Heartbeat", "KeepAlive", "Validation", "Verification",
    "Trade", "Trading", "Product", "Purchase", "Scan", "Check"
}

-- ==================== 1. HİLE SERVİSLERİ (3 KATMAN) ====================
local CheatServices = {
    Service1 = { Name = "Kick Koruma", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "kick") or string.find(name, "ban") or
                           string.find(name, "moderation") or string.find(name, "denetim") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end)
    end},
    Service2 = { Name = "Detection Koruma", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "detect") or string.find(name, "scan") or
                           string.find(name, "check") or string.find(name, "verify") or
                           string.find(name, "monitor") or string.find(name, "report") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end)
    end},
    Service3 = { Name = "Integrity Koruma", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "integrity") or string.find(name, "violation") or
                           string.find(name, "correction") or string.find(name, "antitamper") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end)
    end}
}

-- ==================== 2. GİZLEME KATMANLARI (5 KATMAN) ====================
local StealthLayers = {
    Layer1 = { Name = "LocalPlayer Gizle", Active = false, Function = function()
        pcall(function()
            if LocalPlayer and not LocalPlayer:IsDescendantOf(Players) then
                LocalPlayer.Parent = Players
            end
            LocalPlayer.Changed:Connect(function(prop)
                if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
                    pcall(function() LocalPlayer.Parent = Players end)
                end
            end)
        end)
    end},
    Layer2 = { Name = "Karakter Gizle", Active = false, Function = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                    end
                end
            end
        end)
    end},
    Layer3 = { Name = "GUI Temizle", Active = false, Function = function()
        pcall(function()
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                for _, c in pairs(gui:GetChildren()) do
                    local n = string.lower(c.Name)
                    if string.find(n, "kick") or string.find(n, "ban") or
                       string.find(n, "integrity") or string.find(n, "violation") or
                       string.find(n, "detect") or string.find(n, "error") then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end)
    end},
    Layer4 = { Name = "Konum Gizle", Active = false, Function = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(
                        math.random(-99999, 99999),
                        math.random(-99999, 99999),
                        math.random(-99999, 99999)
                    )
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end},
    Layer5 = { Name = "İz Bırakma", Active = false, Function = function()
        pcall(function()
            print = function() end
            warn = function() end
            error = function() end
            debug.setmetatable = nil
            debug.getmetatable = nil
            debug.getupvalue = nil
            debug.setupvalue = nil
            debug.getinfo = nil
            debug.getregistry = nil
        end)
    end}
}

-- ==================== 3. BYPASS KATMANLARI (10 KATMAN) ====================
local BypassLayers = {
    Layer1 = { Name = "Remote Killer", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end)
    end},
    Layer2 = { Name = "Anti-Reset", Active = false, Function = function()
        pcall(function()
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
        end)
    end},
    Layer3 = { Name = "Anti-Detection", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "detect") or string.find(name, "scan") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end)
    end},
    Layer4 = { Name = "Egg Koruma", Active = false, Function = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = string.lower(tool.Name)
                        if string.find(name, "egg") then
                            tool.CanBeDropped = false
                            tool.RequiresHandle = false
                        end
                    end
                end
            end
        end)
    end},
    Layer5 = { Name = "Memory Cleaner", Active = false, Function = function()
        pcall(function()
            for k, v in pairs(_G) do
                if type(v) == "function" then
                    local info = debug.getinfo(v)
                    if info and info.source then
                        if string.find(info.source, "detect") then
                            _G[k] = nil
                        end
                    end
                end
            end
        end)
    end},
    Layer6 = { Name = "Script Killer", Active = false, Function = function()
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "detect") or string.find(name, "scan") or
                       string.find(name, "check") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end)
    end},
    Layer7 = { Name = "Anti-Tamper", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "tamper") or string.find(name, "antitamper") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end)
    end},
    Layer8 = { Name = "Position Spoofer", Active = false, Function = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(
                        math.random(-9999, 9999),
                        math.random(-9999, 9999),
                        math.random(-9999, 9999)
                    )
                end
            end
        end)
    end},
    Layer9 = { Name = "Network Blocker", Active = false, Function = function()
        pcall(function()
            for _, container in ipairs({ReplicatedStorage, Workspace}) do
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        pcall(function() child.Parent = nil end)
                    end
                end
            end
        end)
    end},
    Layer10 = { Name = "Ultimate Bypass", Active = false, Function = function()
        pcall(function()
            local network = ReplicatedStorage:FindFirstChild("Network")
            if network then
                for _, obj in ipairs(network:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "detect") or string.find(name, "scan") or
                       string.find(name, "check") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
            if LocalPlayer and not LocalPlayer:IsDescendantOf(Players) then
                LocalPlayer.Parent = Players
            end
        end)
    end}
}

-- ==================== EVRİM FONKSİYONU ====================
local function Evolve()
    if not Evolution.Active then return end
    Evolution.Level = Evolution.Level + 1
    if Evolution.Level > Evolution.MaxLevel then
        Evolution.Level = Evolution.MaxLevel
    end
    print("")
    print("========================================")
    print("🧬 EVRİM GEÇİRİLİYOR! Seviye: " .. Evolution.Level .. "/" .. Evolution.MaxLevel)
    print("========================================")
    for name, service in pairs(CheatServices) do
        if not service.Active then
            service.Active = true
            pcall(service.Function)
            print("   ✅ " .. service.Name .. " aktif!")
            table.insert(Evolution.EvolutionHistory, service.Name .. " aktif")
        end
    end
    for name, layer in pairs(StealthLayers) do
        if not layer.Active then
            layer.Active = true
            pcall(layer.Function)
            print("   🕵️ " .. layer.Name .. " aktif!")
            table.insert(Evolution.EvolutionHistory, layer.Name .. " aktif")
        end
    end
    local level = Evolution.Level
    for name, layer in pairs(BypassLayers) do
        if not layer.Active then
            local layerNum = tonumber(name:gsub("Layer", ""))
            if layerNum and layerNum <= level then
                layer.Active = true
                pcall(layer.Function)
                print("   🛡️ " .. layer.Name .. " aktif!")
                table.insert(Evolution.EvolutionHistory, layer.Name .. " aktif")
            end
        end
    end
    print("========================================")
    print("🧬 EVRİM TAMAMLANDI! Seviye: " .. Evolution.Level)
    print("========================================")
end

-- ==================== OYUN TESPİTİNE KARŞI EVRİM ====================
local function DetectAndEvolve()
    pcall(function()
        local detected = false
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if gui then
            for _, c in pairs(gui:GetChildren()) do
                local n = string.lower(c.Name)
                if string.find(n, "hile") or string.find(n, "cheat") or
                   string.find(n, "exploit") or string.find(n, "detect") then
                    detected = true
                    print("⚠️ OYUN TESPİT ETTİ! Evrim başlatılıyor...")
                    break
                end
            end
        end
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            local count = 0
            for _, obj in ipairs(network:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    count = count + 1
                end
            end
            if count > 50 then
                detected = true
                print("⚠️ YENİ REMOTE'LAR TESPİT EDİLDİ! Evrim başlatılıyor...")
            end
        end
        if detected then
            Evolve()
        end
    end)
end

-- ==================== PART 1 BAŞLAT ====================
local function StartEvolutionBypass()
    if Evolution.Active then return end
    Evolution.Active = true
    print("========================================")
    print("🧬 EVRİMSEL BYPASS V8.0 BAŞLADI!")
    print("   3 Hile Servisi + 5 Gizleme Katmanı")
    print("   10 Bypass Katmanı + 10 Katman Gerçek Bypass")
    print("========================================")
    task.wait(0.5)
    Evolve()
    task.spawn(function()
        while Evolution.Active do
            task.wait(2)
            pcall(DetectAndEvolve)
        end
    end)
end

task.wait(0.3)
StartEvolutionBypass()-- ============================================================
-- PART 2: 10 KATMAN GERÇEK BYPASS + SÜREKLİ KORUMA
-- ============================================================

-- ==================== KATMAN FONKSİYONLARI ====================
local function Layer1_KillRemotes()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if not network then return end
        for _, obj in ipairs(network:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, kw in ipairs(KillList) do
                    if string.find(obj.Name, kw) then
                        pcall(function() obj:Destroy() end)
                        break
                    end
                end
            end
        end
    end)
end

local function Layer2_DeepScan()
    pcall(function()
        local containers = {
            ReplicatedStorage, Workspace, Lighting, LocalPlayer,
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("Backpack"),
            LocalPlayer:FindFirstChild("Character"),
            game:GetService("CoreGui"),
            game:GetService("StarterGui"),
            game:GetService("StarterPack"),
            game:GetService("Chat")
        }
        for _, container in ipairs(containers) do
            if container then
                for _, obj in ipairs(container:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        for _, kw in ipairs(KillList) do
                            if string.find(obj.Name, kw) then
                                pcall(function() obj:Destroy() end)
                                break
                            end
                        end
                    end
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "detect") or string.find(n, "scan") or
                           string.find(n, "check") or string.find(n, "verify") or
                           string.find(n, "integrity") or string.find(n, "violation") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end
    end)
end

local function Layer3_HideLocalPlayer()
    pcall(function()
        if LocalPlayer and not LocalPlayer:IsDescendantOf(Players) then
            LocalPlayer.Parent = Players
        end
        LocalPlayer.Changed:Connect(function(prop)
            if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
                pcall(function() LocalPlayer.Parent = Players end)
            end
        end)
        LocalPlayer:GetPropertyChangedSignal("Character"):Connect(function()
            local char = LocalPlayer.Character
            if char and char.Parent ~= Workspace then
                pcall(function() char.Parent = Workspace end)
            end
        end)
    end)
end

local function Layer4_CleanGUI()
    pcall(function()
        local containers = {
            LocalPlayer:FindFirstChild("PlayerGui"),
            game:GetService("CoreGui"),
            game:GetService("StarterGui")
        }
        for _, container in ipairs(containers) do
            if container then
                for _, c in pairs(container:GetChildren()) do
                    local n = string.lower(c.Name)
                    if string.find(n, "kick") or string.find(n, "ban") or
                       string.find(n, "error") or string.find(n, "integrity") or
                       string.find(n, "violation") or string.find(n, "denetim") or
                       string.find(n, "moderation") or string.find(n, "warning") or
                       string.find(n, "detection") or string.find(n, "exploit") then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
    end)
end

local function Layer5_AntiReset()
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
        if hum.Health < 10 and hum.Health > 0 then
            hum.Health = hum.MaxHealth
        end
        hum.Died:Connect(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end)
end

local function Layer6_EggProtect()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                if string.find(name, "egg") or string.find(name, "yumurta") then
                    tool.CanBeDropped = false
                    tool.RequiresHandle = false
                    if not tool._HLGlued then
                        tool._HLGlued = true
                        tool:GetPropertyChangedSignal("Parent"):Connect(function()
                            if tool.Parent ~= char and tool.Parent ~= LocalPlayer then
                                pcall(function() tool.Parent = char end)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

local function Layer7_MemoryBypass()
    pcall(function()
        for k, v in pairs(_G) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.source and string.find(info.source, "detect") then
                    _G[k] = nil
                end
            end
        end
        debug.setmetatable = nil
        debug.getmetatable = nil
        debug.getupvalue = nil
        debug.setupvalue = nil
        debug.getinfo = nil
        debug.getregistry = nil
        debug.getfenv = nil
        debug.setfenv = nil
    end)
end

local function Layer8_ScriptScanner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local source = ""
                pcall(function() source = obj.Source end)
                if source and #source > 0 then
                    if string.find(source, "detect") or string.find(source, "scan") or
                       string.find(source, "check") or string.find(source, "verify") or
                       string.find(source, "integrity") or string.find(source, "violation") or
                       string.find(source, "kick") or string.find(source, "ban") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)
end

local function Layer9_AntiDetection()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            for _, obj in ipairs(network:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "detect") or string.find(name, "scan") or
                       string.find(name, "check") or string.find(name, "verify") or
                       string.find(name, "monitor") or string.find(name, "report") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)
end

local function Layer10_AntiCheatKiller()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            for _, obj in ipairs(network:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "integrity") or string.find(name, "violation") or
                       string.find(name, "correction") or string.find(name, "antitamper") or
                       string.find(name, "exploit") or string.find(name, "clientcharacter") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)
end

-- ==================== SÜREKLİ KORUMA DÖNGÜSÜ ====================
task.spawn(function()
    while Evolution.Active do
        for _, service in pairs(CheatServices) do
            if service.Active then pcall(service.Function) end
        end
        for _, layer in pairs(StealthLayers) do
            if layer.Active then pcall(layer.Function) end
        end
        for _, layer in pairs(BypassLayers) do
            if layer.Active then pcall(layer.Function) end
        end
        pcall(Layer1_KillRemotes)
        pcall(Layer2_DeepScan)
        pcall(Layer3_HideLocalPlayer)
        pcall(Layer4_CleanGUI)
        pcall(Layer5_AntiReset)
        pcall(Layer6_EggProtect)
        pcall(Layer7_MemoryBypass)
        pcall(Layer8_ScriptScanner)
        pcall(Layer9_AntiDetection)
        pcall(Layer10_AntiCheatKiller)
        task.wait(0.01)
    end
end)

-- ==================== PART 2 BAŞLAT ====================
print("")
print("========================================")
print("✅ EVRİMSEL BYPASS V8.0 HAZIR!")
print("   Oyun tespit ettikçe evrim geçirir!")
print("   3 Hile Servisi aktif!")
print("   5 Gizleme Katmanı aktif!")
print("   10 Bypass Katmanı aktif!")
print("   10 Katman Gerçek Bypass aktif!")
print("========================================")
