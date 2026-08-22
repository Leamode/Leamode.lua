--[[
  LEA MODE 2026
  Tek boş alan = senin bypass / antikick / antireset paketın
  Modlar farklı yöntemlerle (eski TP spam değil)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------
-- ÇALIŞIR YAPIŞTIRMA ALANI
-- PASTE START ile PASTE END arasına kodunu koy (yorum bloğu YOK).
-- Players, LocalPlayer, UIS, RunService, ReplicatedStorage, Workspace hazır.
-- Hata olursa sadece bu blok düşer; altındaki modlar çalışmaya devam eder.
----------------------------------------------------------------
task.spawn(function()
	local ok, err = pcall(function()
		-- ==================== PASTE START ====================
-- ============================================================
-- ULTRA BYPASS ENGINE V5.0 - TAM KAPSAMLI (400+ SATIR)
-- ANTI-CHEAT KILLER + REMOTE DESTROYER + ANTI-KICK + ANTI-RESET
-- TÜM DETECTION SİSTEMLERİ DEVRE DIŞI
-- ============================================================

local Ultra = {
    Active = false,
    AntiCheat = true,
    AntiKick = true,
    AntiReset = true,
    RemoteKiller = true,
    GuiCleaner = true,
    PlayerProtector = true,
    MemoryCleaner = true,
    Counter = 0,
    RemoteKillCount = 0,
    HealCount = 0,
    KickBlockCount = 0,
    LastScan = 0
}

-- ==================== 1. LOG SİSTEMİ ====================
local Log = function(msg, color)
    color = color or "\27[36m"
    print(color .. "[ULTRA] " .. msg .. "\27[0m")
end

-- ==================== 2. REMOTE KİLLER (TÜM ZARARLI REMOTE'LAR) ====================
local RemoteKiller = {
    KillList = {},
    KillCount = 0
}

RemoteKiller.KillList = {
    -- ANTI-CHEAT / INTEGRITY
    "Integrity", "IntegrityViolation", "IntegrityHeartbeat", "IntegrityCheck",
    "IntegrityValidation", "IntegrityVerification", "IntegrityPing",
    "IntegrityScan", "IntegrityMonitor", "IntegrityReport",
    "Correction", "CorrectionStarted", "CorrectionCompleted", "CorrectionFailed",
    "CorrectionPending", "CorrectionQueue", "CorrectionManager",
    "Violation", "ViolationDetected", "ViolationReport", "ViolationWarning",
    "ViolationLog", "ViolationHandler", "ViolationProcessor",
    "AntiTamper", "AntiTamperCheck", "AntiTamperPing", "AntiTamperValidation",
    "AntiTamperScan", "AntiTamperMonitor", "AntiTamperReport",
    
    -- CLIENT CHARACTER
    "ClientCharacter", "ClientCharacter:Ready", "ClientCharacter:Update",
    "ClientCharacter:Sync", "ClientCharacter:CorrectionStarted",
    "ClientCharacter:IntegrityViolation", "ClientCharacter:IntegrityHeartbeat",
    "ClientCharacter:RequestCharacterReset", "ClientCharacter:Reset",
    "ClientCharacter:Teleport", "ClientCharacter:PositionCheck",
    "ClientCharacter:VelocityCheck", "ClientCharacter:HealthCheck",
    "ClientCharacter:StateCheck", "ClientCharacter:AnimationCheck",
    
    -- KICK / BAN / MODERATION
    "Kick", "Ban", "Moderation", "Denetim", "ModerationPanel",
    "KickPlayer", "BanPlayer", "KickAll", "BanAll", "KickUser",
    "BanUser", "ModeratePlayer", "ModerateUser",
    "AdminPanel", "AdminPanel_CheckAdminStatus", "AdminPanel_AdminStatusResponse",
    "AdminPanel_GiveAssetToSelf", "AdminPanel_GiveEggToSelf",
    "AdminPanel_ResetSelfData", "AdminPanel_SetWalkSpeed",
    "AdminPanel_SetSpeedPower", "AdminPanel_GiveMoney",
    "AdminPanel_GiveGems", "AdminPanel_GiveTokens", "AdminPanel_GiveReward",
    "AdminAbuse", "AdminAbuse_GetEventNames", "AdminAbuse_GetActiveEvents",
    "AdminAbuse_GetTimeUntilRecurringEvents", "AdminAbuse_GetScheduledEvents",
    "AdminAbuse_StartEvent", "AdminAbuse_StopEvent", "AdminAbuse_ForceEvent",
    
    -- DETECTION / ANALYTICS
    "Detection", "Detect", "AntiCheat", "AntiExploit",
    "Exploit", "ExploitDetected", "ExploitPrevention", "ExploitDetection",
    "ExploitLogger", "ExploitReporter", "ExploitBlocker",
    "Analytics", "Analytics:ReportAfkState", "Analytics:ReportAfk",
    "Analytics:RequestAfkTeleportFlush", "Analytics:ReportAfkTeleport",
    "Analytics:ReportActivity", "Analytics:ReportMovement",
    "Analytics:ReportJump", "Analytics:ReportTeleport",
    "Analytics:ReportSpeed", "Analytics:ReportFly", "Analytics:ReportNoclip",
    "Analytics:ReportPosition", "Analytics:ReportVelocity",
    
    -- RESET / SYNC
    "Reset", "ResetSelfData", "RequestCharacterReset", "ResetCharacter",
    "ResetAll", "ResetPosition", "ResetVelocity", "ResetState",
    "Sync", "Syncing", "Synchronization", "SyncCheck",
    "SyncValidation", "SyncVerification", "SyncPing", "SyncHeartbeat",
    "SyncManager", "SyncProcessor", "SyncQueue",
    
    -- GUARD / BOSS / ENEMY
    "Guard", "GuardAttack", "GuardDamage", "GuardHit",
    "ForestHit", "ForestGuard", "ForestDamage", "ForestDeposit",
    "SpeedHit", "SpeedHitOffer", "SpeedHitWarning", "SpeedHitCancel",
    "WakeUp", "GuardAlert", "GuardChase", "GuardPatrol",
    "Boss", "BossAttack", "BossDamage", "BossHit", "BossPhase",
    "Enemy", "EnemyAttack", "EnemyDamage", "EnemyHit", "EnemySpawn",
    "Monster", "MonsterAttack", "MonsterDamage", "MonsterSpawn",
    "Creature", "CreatureAttack", "CreatureDamage", "CreatureSpawn",
    
    -- EGG DROP / UNEQUIP
    "UnequipTool", "RuntimeOwnerCleared", "RuntimeOwnerUpdated",
    "AreaEggDrop", "RequestAreaEggDrop", "RequestUnequip",
    "RequestDrop", "DropItem", "DropAsset", "DropEgg",
    "EggDrop", "EggUnequip", "EggRuntimeClear",
    "ActiveAssets:RuntimeOwnerCleared", "ActiveAssets:RuntimeOwnerUpdated",
    "ActiveAssets:RequestUnequip", "Trails:RequestUnequip",
    "Treadmills:RequestUnequip", "GearInventory:Removed",
    
    -- SPAWN / RESPAWN / REVIVE
    "Spawn", "Respawn", "Revive", "SpawnMonster",
    "SpawnEnemy", "SpawnBoss", "SpawnGuard", "SpawnCreature",
    "RespawnPlayer", "RevivePlayer", "RespawnCharacter",
    "SpawnObject", "SpawnNPC", "SpawnMob",
    
    -- TELEPORT / POSITION / MOVEMENT
    "Teleport", "TP", "Position", "MoveTo",
    "SetPosition", "UpdatePosition", "PositionCheck",
    "TeleportPlayer", "TeleportTo", "MovePlayer",
    "VelocityCheck", "SpeedCheck", "FlyCheck", "NoclipCheck",
    
    -- PING / HEARTBEAT / KEEPALIVE
    "Ping", "Heartbeat", "KeepAlive", "Alive",
    "ConnectionPing", "ServerPing", "ClientPing",
    "HeartbeatCheck", "HeartbeatMonitor", "HeartbeatReport",
    
    -- VALIDATION / VERIFICATION
    "Validation", "Verification", "Validate", "Verify",
    "ValidatePlayer", "VerifyPlayer", "ValidateCharacter",
    "ValidatePosition", "ValidateVelocity", "ValidateState",
    
    -- TRADE / MARKET
    "Trade", "Trading", "TradeRequest", "TradeAccept",
    "TradeConfirm", "TradeDecline", "TradeReject", "TradeCancel",
    "Market", "MarketBuy", "MarketSell", "MarketTrade",
    "MarketList", "MarketPrice", "MarketItem",
    
    -- PRODUCT / PURCHASE
    "Product", "Purchase", "Buy", "Sell",
    "ProductGrant", "PurchaseComplete", "PurchaseFailed",
    "ProductCheck", "ProductList", "ProductInfo",
    
    -- DETECTION KEYWORDS (GENİŞ)
    "Detection", "Detect", "Scan", "Check", "Verify",
    "Validate", "Monitor", "Report", "Log", "Alert",
    "Warning", "Error", "Critical", "Security",
    "Anti", "Counter", "Block", "Prevent", "Protect"
}

function RemoteKiller:Scan()
    if not Ultra.RemoteKiller then return end
    
    local network = ReplicatedStorage:FindFirstChild("Network")
    if not network then return end
    
    local killed = 0
    
    for _, obj in ipairs(network:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name
            local shouldKill = false
            
            for _, kw in ipairs(self.KillList) do
                if string.find(name, kw) then
                    shouldKill = true
                    break
                end
            end
            
            if not shouldKill then
                local lowerName = string.lower(name)
                local keywords = {
                    "integrity", "violation", "correction", "detect",
                    "kick", "ban", "admin", "antitamper", "exploit",
                    "clientcharacter", "analytics", "reset", "sync",
                    "guard", "forest", "speedhit", "wakeup",
                    "unequip", "runtimeowner", "areae ggdrop",
                    "ping", "heartbeat", "validation", "verification",
                    "trade", "market", "product", "purchase",
                    "spawn", "respawn", "revive", "teleport", "tp",
                    "check", "scan", "clean", "kill", "detect",
                    "monitor", "report", "log", "alert", "warning",
                    "security", "counter", "block", "prevent"
                }
                for _, kw in ipairs(keywords) do
                    if string.find(lowerName, kw) then
                        shouldKill = true
                        break
                    end
                end
            end
            
            if shouldKill then
                pcall(function()
                    obj:Destroy()
                    killed = killed + 1
                    self.KillCount = self.KillCount + 1
                end)
            end
        end
    end
    
    if killed > 0 then
        Log("🔥 " .. killed .. " remote yok edildi! (Toplam: " .. self.KillCount .. ")", "\27[31m")
    end
    
    return killed
end

function RemoteKiller:Watch()
    local network = ReplicatedStorage:FindFirstChild("Network")
    if not network then return end
    
    network.DescendantAdded:Connect(function(child)
        task.wait(0.02)
        if Ultra.RemoteKiller then
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                local name = child.Name
                local shouldKill = false
                for _, kw in ipairs(self.KillList) do
                    if string.find(name, kw) then
                        shouldKill = true
                        break
                    end
                end
                if shouldKill then
                    pcall(function()
                        child:Destroy()
                        self.KillCount = self.KillCount + 1
                        Log("🆕 Yeni remote yok edildi: " .. name, "\27[31m")
                    end)
                end
            end
        end
    end)
end

function RemoteKiller:Start()
    Log("🔥 Remote Killer Başlatıldı!", "\27[31m")
    self:Scan()
    self:Watch()
end

-- ==================== 3. ANTI-KICK SİSTEMİ ====================
local AntiKick = {
    Active = false,
    BlockCount = 0
}

function AntiKick:Start()
    if self.Active then return end
    self.Active = true
    Log("🛡️ Anti-Kick Başlatıldı!", "\27[33m")
    
    LocalPlayer.Changed:Connect(function(prop)
        if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
            pcall(function() LocalPlayer.Parent = Players end)
            self.BlockCount = self.BlockCount + 1
            Log("🛡️ LocalPlayer korundu! (" .. self.BlockCount .. ")", "\27[33m")
        end
    end)
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.05)
            pcall(function()
                if not LocalPlayer:IsDescendantOf(Players) then
                    LocalPlayer.Parent = Players
                    self.BlockCount = self.BlockCount + 1
                end
                
                local gui = LocalPlayer:FindFirstChild("PlayerGui")
                if gui then
                    for _, c in pairs(gui:GetChildren()) do
                        local n = string.lower(c.Name)
                        if string.find(n, "kick") or string.find(n, "ban") or
                           string.find(n, "error") or string.find(n, "integrity") or
                           string.find(n, "violation") or string.find(n, "denetim") or
                           string.find(n, "moderation") or string.find(n, "warning") or
                           string.find(n, "detection") or string.find(n, "exploit") or
                           string.find(n, "security") or string.find(n, "alert") then
                            c:Destroy()
                            Log("🧹 GUI temizlendi: " .. c.Name, "\27[36m")
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== 4. ANTI-RESET SİSTEMİ ====================
local AntiReset = {
    Active = false,
    HealCount = 0
}

function AntiReset:Start()
    if self.Active then return end
    self.Active = true
    Log("🔄 Anti-Reset Başlatıldı! (BreakJointsOnDeath = false)", "\27[34m")
    
    local function protectCharacter()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if hum.BreakJointsOnDeath ~= false then
            hum.BreakJointsOnDeath = false
            Log("🛡️ BreakJointsOnDeath düzeltildi!", "\27[34m")
        end
        
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
            self.HealCount = self.HealCount + 1
            Log("💚 Can yenilendi! (" .. self.HealCount .. ")", "\27[32m")
        end
        
        if hum.Health < 10 and hum.Health > 0 then
            hum.Health = hum.MaxHealth
            self.HealCount = self.HealCount + 1
            Log("💚 Can düzeltildi! (" .. self.HealCount .. ")", "\27[32m")
        end
        
        if hum.PlatformStand == true then
            hum.PlatformStand = false
        end
        
        if hum.AutoRotate == false then
            hum.AutoRotate = true
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.Health = hum.MaxHealth
            Log("🔄 Karakter yeniden doğdu! Koruma aktif!", "\27[34m")
        end
    end)
    
    local function blockDeath()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        hum.Died:Connect(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
            self.HealCount = self.HealCount + 1
            Log("💀 Ölüm engellendi! (" .. self.HealCount .. ")", "\27[32m")
        end)
    end
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.05)
            pcall(protectCharacter)
        end
    end)
    
    protectCharacter()
    blockDeath()
end

-- ==================== 5. ANTI-CHEAT BYPASS ====================
local AntiCheatBypass = {
    Active = false
}

function AntiCheatBypass:Start()
    if self.Active then return end
    self.Active = true
    Log("🚀 Anti-Cheat Bypass Başlatıldı!", "\27[35m")
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.1)
            pcall(function()
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network then
                    for _, obj in ipairs(network:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local name = string.lower(obj.Name)
                            local detectList = {
                                "detect", "scan", "check", "verify",
                                "validation", "integrity", "violation",
                                "correction", "antitamper", "exploit",
                                "ping", "heartbeat", "alive", "keepalive",
                                "monitor", "report", "log", "alert"
                            }
                            for _, kw in ipairs(detectList) do
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
    end)
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.5)
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        local name = string.lower(obj.Name)
                        if string.find(name, "detect") or string.find(name, "scan") or
                           string.find(name, "check") or string.find(name, "verify") or
                           string.find(name, "integrity") or string.find(name, "violation") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== 6. ANA BAŞLAT ====================
local function StartUltraBypass()
    if Ultra.Active then return end
    Ultra.Active = true
    
    Log("", "\27[36m")
    Log("========================================", "\27[36m")
    Log("🛡️ ULTRA BYPASS AKTİF!", "\27[32m")
    Log("========================================", "\27[36m")
    Log("✅ Anti-Cheat Bypass (Tüm detection'lar yok)", "\27[32m")
    Log("✅ Remote Killer (500+ remote yok edilir)", "\27[32m")
    Log("✅ Anti-Kick (Kick yemezsin)", "\27[32m")
    Log("✅ Anti-Reset (BreakJointsOnDeath)", "\27[32m")
    Log("✅ GUI Cleaner (Kick/Ban pencereleri temizlenir)", "\27[32m")
    Log("✅ Player Protector (LocalPlayer korunur)", "\27[32m")
    Log("========================================", "\27[36m")
    Log("", "\27[36m")
    
    RemoteKiller:Start()
    AntiKick:Start()
    AntiReset:Start()
    AntiCheatBypass:Start()
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.2)
            pcall(function()
                RemoteKiller:Scan()
            end)
        end
    end)
end

-- ==================== 7. KAPAT ====================
local function StopUltraBypass()
    Ultra.Active = false
    RemoteKiller.Active = false
    AntiKick.Active = false
    AntiReset.Active = false
    AntiCheatBypass.Active = false
    
    Log("", "\27[31m")
    Log("========================================", "\27[31m")
    Log("🛡️ ULTRA BYPASS PASİF!", "\27[31m")
    Log("========================================", "\27[31m")
    Log("", "\27[31m")
end

-- ==================== 8. TUŞLAR ====================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F7 then
        if Ultra.Active then
            StopUltraBypass()
        else
            StartUltraBypass()
        end
    end
end)

-- ==================== 9. OTOMATİK BAŞLAT ====================
task.wait(0.5)
StartUltraBypass()

print("")
print("========================================")
print("🛡️ ULTRA BYPASS PAKETİ HAZIR!")
print("========================================")
print("📌 F7 - Bypass Aç/Kapat")
print("✅ Tüm Anti-Cheat sistemleri devre dışı")
print("✅ 500+ zararlı remote yok edilir")
print("✅ Kick yemezsin")
print("✅ Ölmezsin (BreakJointsOnDeath)")
print("✅ Yakalanmazsın")
print("========================================")


		-- ==================== PASTE END ====================
	end)
	if not ok then
		warn("[LEA] Yapıştırma alanı hatası: ", err)
	end
end)
----------------------------------------------------------------

local CFG = {
	flySpeed = 90,
	walkBoost = 56,
	jumpBoost = 92,
	guardRange = 18,
	guardForce = 95,
	magnetRange = 160,
	buddyCount = 4,
	guiScale = 1,
	fov = 95,
	arenaDelay = 0.55,
	arenaName = "arena",
}

local ON = {
	AutoEgg = false, Speed = false, Fly = false, MobPush = false, AutoBed = false,
	Noclip = false, InfJump = false, ClickTP = false, ESP = false, Fullbright = false,
	Spin = false, Collect = false, HighJump = false, NoFall = false,
	EggGuard = false, EggMagnet = false, EggBuddy = false, EggAnchor = false, ThreatESP = false,
	SmoothTP = false, AutoArena = false, GiftMode = false,
}

local mem = {
	saved = nil,
	bg = nil, bv = nil, flyHook = nil,
	noclipHook = nil, espFolder = nil, buddyFolder = nil,
	lit = {},
	arenaList = {},
	arenaIdx = 0,
	arenaBusy = false,
	giftPhase = 0,
	giftWait = 0,
	startPos = nil,
}

local EGG = { "egg", "goldenegg", "petegg", "eggmodel" }
local BED = { "bed", "bad" }
local LOOT = { "coin", "gem", "orb", "candy", "token", "egg" }

local function char() return LocalPlayer.Character end
local function hrp() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hit(obj, list)
	local n = string.lower(obj.Name)
	for _,k in ipairs(list) do if string.find(n,k,1,true) then return true end end
	return false
end

-- ===== hareket (farklı yollar) =====
local function setWalk()
	local h = hum()
	if not h then return end
	h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
	if ON.HighJump then
		h.JumpPower = CFG.jumpBoost
		pcall(function() h.JumpHeight = 22 end)
	else
		h.JumpPower = 50
		pcall(function() h.JumpHeight = 7.2 end)
	end
end

local function flyOff()
	if mem.flyHook then mem.flyHook:Disconnect() mem.flyHook=nil end
	if mem.bg then pcall(function() mem.bg:Destroy() end) mem.bg=nil end
	if mem.bv then pcall(function() mem.bv:Destroy() end) mem.bv=nil end
	local h = hum()
	if h then h.PlatformStand = false end
end

local function flyOn()
	flyOff()
	local r,h = hrp(), hum()
	if not r or not h then return end
	h.PlatformStand = true
	-- yöntem: AlignOrientation + LinearVelocity (BodyVelocity yerine)
	local att = r:FindFirstChild("LeaAtt") or Instance.new("Attachment")
	att.Name = "LeaAtt"
	att.Parent = r
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.MaxForce = 1e6
	lv.VectorVelocity = Vector3.zero
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = r
	mem.bv = lv
	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = att
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.Responsiveness = 40
	ao.MaxTorque = 1e6
	ao.Parent = r
	mem.bg = ao
	mem.flyHook = RunService.RenderStepped:Connect(function()
		if not ON.Fly or not mem.bv then return end
		local cam = Workspace.CurrentCamera
		if not cam then return end
		local v = Vector3.zero
		local f, rt = cam.CFrame.LookVector, cam.CFrame.RightVector
		if UIS:IsKeyDown(Enum.KeyCode.W) then v += f end
		if UIS:IsKeyDown(Enum.KeyCode.S) then v -= f end
		if UIS:IsKeyDown(Enum.KeyCode.A) then v -= rt end
		if UIS:IsKeyDown(Enum.KeyCode.D) then v += rt end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v -= Vector3.yAxis end
		if UIS.TouchEnabled and v.Magnitude < 0.05 then v = f end
		mem.bv.VectorVelocity = v.Magnitude > 0 and v.Unit * CFG.flySpeed or Vector3.zero
		if mem.bg then mem.bg.CFrame = cam.CFrame end
	end)
end

-- yumuşak TP (anında CFrame spam yerine tween)
local function softTP(pos)
	local r = hrp()
	if not r or not pos then return end
	if ON.SmoothTP then
		local tw = TweenService:Create(r, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pos)})
		tw:Play()
	else
		r.CFrame = CFrame.new(pos)
	end
	r.AssemblyLinearVelocity = Vector3.zero
end

local function savePos()
	local r = hrp()
	if r then mem.saved = r.Position return true end
	return false
end

-- egg: magnet = assembly velocity çek, anchor = weld+network
local function eggStep()
	local r = hrp()
	if not r then return end
	if not (ON.AutoEgg or ON.EggMagnet or ON.EggAnchor) then return end
	local range = ON.EggMagnet and CFG.magnetRange or 90
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, EGG) then
			local d = (obj.Position - r.Position).Magnitude
			if d < range then
				obj.Anchored = false
				obj.CanCollide = false
				if ON.EggMagnet and d > 6 then
					-- çek (TP değil)
					local dir = (r.Position + Vector3.new(0, 3, 0) - obj.Position)
					obj.AssemblyLinearVelocity = dir.Unit * math.clamp(d * 4, 40, 140)
				else
					obj.CFrame = r.CFrame * CFrame.new(0, 2.6, 0)
					obj.AssemblyLinearVelocity = Vector3.zero
				end
				if ON.EggAnchor and not obj:FindFirstChild("LeaWeld") then
					local w = Instance.new("WeldConstraint")
					w.Name = "LeaWeld"
					w.Part0 = r
					w.Part1 = obj
					w.Parent = obj
				end
				if ON.EggAnchor then
					obj.CFrame = r.CFrame * CFrame.new(0, 2.6, 0)
				end
				break
			end
		end
	end
	if ON.AutoEgg and mem.saved then
		softTP(mem.saved)
	end
end

-- guard: oyuncuya AssemblyLinearVelocity (seni değil onları iter)
local function guardStep()
	if not ON.EggGuard then return end
	local r = hrp()
	if not r then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local o = plr.Character:FindFirstChild("HumanoidRootPart")
			local oh = plr.Character:FindFirstChildOfClass("Humanoid")
			if o and oh and oh.Health > 0 then
				local d = (o.Position - r.Position).Magnitude
				if d > 0.6 and d <= CFG.guardRange then
					local away = (o.Position - r.Position)
					if away.Magnitude > 0 then
						o.AssemblyLinearVelocity = away.Unit * CFG.guardForce + Vector3.new(0, 45, 0)
					end
				end
			end
		end
	end
end

local function clearBuddy()
	if mem.buddyFolder then pcall(function() mem.buddyFolder:Destroy() end) end
	mem.buddyFolder = nil
end

local function makeBuddy()
	clearBuddy()
	local r = hrp()
	if not r then return end
	local f = Instance.new("Folder")
	f.Name = "LeaBuddy"
	f.Parent = Workspace
	mem.buddyFolder = f
	local cols = {
		Color3.fromRGB(170,70,255), Color3.fromRGB(70,200,255),
		Color3.fromRGB(255,110,70), Color3.fromRGB(120,255,140),
	}
	for i = 1, CFG.buddyCount do
		local p = Instance.new("Part")
		p.Name = "B"..i
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(1.1,1.1,1.1)
		p.Material = Enum.Material.Neon
		p.Color = cols[((i-1)%#cols)+1]
		p.Anchored = true
		p.CanCollide = false
		p.Parent = f
		local pl = Instance.new("PointLight")
		pl.Range = 7
		pl.Brightness = 2
		pl.Color = p.Color
		pl.Parent = p
	end
end

local ang = 0
local function buddyStep()
	if not ON.EggBuddy then return end
	local r = hrp()
	if not r then return end
	if not mem.buddyFolder then makeBuddy() end
	ang += 0.14
	local i = 0
	for _, p in ipairs(mem.buddyFolder:GetChildren()) do
		if p:IsA("BasePart") then
			i += 1
			local a = ang + i * (math.pi*2/CFG.buddyCount)
			local pos = r.Position + Vector3.new(math.cos(a)*5.5, 2+math.sin(ang*2+i)*0.6, math.sin(a)*5.5)
			p.CFrame = CFrame.new(pos)
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local o = plr.Character:FindFirstChild("HumanoidRootPart")
					if o and (o.Position-pos).Magnitude < 3.8 then
						local push = o.Position - r.Position
						if push.Magnitude > 0 then
							o.AssemblyLinearVelocity = push.Unit * 60 + Vector3.new(0, 28, 0)
						end
					end
				end
			end
		end
	end
end

local function mobStep()
	if not ON.MobPush then return end
	local r = hrp()
	if not r then return end
	for _, m in ipairs(Workspace:GetChildren()) do
		if m:IsA("Model") and m ~= char() then
			local mh = m:FindFirstChildOfClass("Humanoid")
			local mr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
			if mh and mr and mh.Health > 0 and not Players:GetPlayerFromCharacter(m) then
				local d = (mr.Position - r.Position).Magnitude
				if d > 0.4 and d <= 14 then
					local away = r.Position - mr.Position
					if away.Magnitude > 0 then
						r.AssemblyLinearVelocity = away.Unit * 80 + Vector3.new(0, 38, 0)
						mr.AssemblyLinearVelocity = -away.Unit * 55
					end
				end
			end
		end
	end
end

local function bedStep()
	if not ON.AutoBed then return end
	local c = char()
	if not c then return end
	local has = false
	for _, t in ipairs(c:GetChildren()) do
		if t:IsA("Tool") and hit(t, BED) then has = true break end
	end
	if not has then return end
	local r = hrp()
	if not r then return end
	local best, bd = nil, 22
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local o = plr.Character:FindFirstChild("HumanoidRootPart")
			local oh = plr.Character:FindFirstChildOfClass("Humanoid")
			if o and oh and oh.Health > 0 then
				local d = (o.Position - r.Position).Magnitude
				if d < bd then bd, best = d, o end
			end
		end
	end
	if best then
		-- pivot lerp + bakış
		r.CFrame = CFrame.lookAt(r.Position:Lerp(best.Position, 0.38), best.Position)
	end
end

local function noclip(on)
	if mem.noclipHook then mem.noclipHook:Disconnect() mem.noclipHook=nil end
	if not on then return end
	mem.noclipHook = RunService.Stepped:Connect(function()
		local c = char()
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end)
end

UIS.JumpRequest:Connect(function()
	if ON.InfJump then
		local h = hum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

Mouse.Button1Down:Connect(function()
	if not ON.ClickTP then return end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS.TouchEnabled then
		if Mouse.Hit then softTP(Mouse.Hit.Position + Vector3.new(0,3,0)) end
	end
end)

local function clearESP()
	if mem.espFolder then pcall(function() mem.espFolder:Destroy() end) end
	mem.espFolder = nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local x = plr.Character:FindFirstChild("LeaHL")
			if x then x:Destroy() end
		end
	end
end

local function esp()
	clearESP()
	if not (ON.ESP or ON.ThreatESP) then return end
	local f = Instance.new("Folder")
	f.Name = "LeaESP"
	f.Parent = Workspace
	mem.espFolder = f
	local me = hrp()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local o = plr.Character:FindFirstChild("HumanoidRootPart")
			if o then
				local near = me and (o.Position-me.Position).Magnitude < 28
				local col = (ON.ThreatESP and near) and Color3.fromRGB(255,50,50) or Color3.fromRGB(175,80,255)
				local hl = Instance.new("Highlight")
				hl.Name = "LeaHL"
				hl.FillColor = col
				hl.OutlineColor = Color3.new(1,1,1)
				hl.FillTransparency = 0.5
				hl.Parent = plr.Character
				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.fromOffset(120,26)
				bb.AlwaysOnTop = true
				bb.StudsOffset = Vector3.new(0,3,0)
				bb.Parent = o
				local t = Instance.new("TextLabel")
				t.Size = UDim2.fromScale(1,1)
				t.BackgroundTransparency = 1
				t.Text = plr.Name .. (near and " !" or "")
				t.TextColor3 = near and Color3.fromRGB(255,90,90) or Color3.fromRGB(255,220,120)
				t.Font = Enum.Font.GothamBold
				t.TextSize = 13
				t.TextStrokeTransparency = 0.3
				t.Parent = bb
			end
		end
	end
end

local function fullbright(on)
	if on then
		mem.lit.b = Lighting.Brightness
		mem.lit.c = Lighting.ClockTime
		mem.lit.f = Lighting.FogEnd
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1e6
		Lighting.GlobalShadows = false
	else
		if mem.lit.b then Lighting.Brightness = mem.lit.b end
		if mem.lit.c then Lighting.ClockTime = mem.lit.c end
		if mem.lit.f then Lighting.FogEnd = mem.lit.f end
		Lighting.GlobalShadows = true
		mem.lit = {}
	end
end

local spinA = 0
local function spinStep()
	if not ON.Spin then return end
	local r = hrp()
	if not r then return end
	spinA += 30
	r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, math.rad(spinA), 0)
end

local function collectStep()
	if not ON.Collect then return end
	local r = hrp()
	if not r then return end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, LOOT) and (obj.Position-r.Position).Magnitude < 55 then
			obj.AssemblyLinearVelocity = (r.Position - obj.Position).Unit * 80
		end
	end
end

local function noFall()
	if not ON.NoFall then return end
	local h = hum()
	if h and h:GetState() == Enum.HumanoidStateType.Freefall then
		h:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end



-- ===== HEDİYE MODU: son arena → egg al → başlangıç → egg bırak =====
local function dropEggAt(pos)
	local r = hrp()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, EGG) then
			local w = obj:FindFirstChild("LeaWeld")
			if w then w:Destroy() end
			-- karakterde yapışıksa bırak
			if r and (obj.Position - r.Position).Magnitude < 12 then
				obj.Anchored = true
				obj.CanCollide = true
				obj.AssemblyLinearVelocity = Vector3.zero
				obj.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
			end
		end
	end
end

local function hasCarriedEgg()
	local r = hrp()
	if not r then return false end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, EGG) then
			if obj:FindFirstChild("LeaWeld") or (obj.Position - r.Position).Magnitude < 8 then
				return true, obj
			end
		end
	end
	return false, nil
end

local function giftStep()
	if not ON.GiftMode then
		mem.giftPhase = 0
		return
	end
	local now = os.clock()
	if now < (mem.giftWait or 0) then return end

	-- phase 0: başlangıcı kaydet + arena listesi
	if mem.giftPhase == 0 then
		local r = hrp()
		if r then mem.startPos = r.Position end
		if mem.saved then mem.startPos = mem.saved end
		mem.arenaList = findArenas()
		-- isim/sayı sırası (son arena = listenin sonu)
		if #mem.arenaList == 0 then
			mem.giftWait = now + 1.5
			return
		end
		mem.giftPhase = 1
		mem.giftWait = now + 0.15
		return
	end

	-- phase 1: son arenanın ortasına TP
	if mem.giftPhase == 1 then
		local last = mem.arenaList[#mem.arenaList]
		if last and last.center then
			softTP(last.center + Vector3.new(0, 3, 0))
		end
		mem.giftPhase = 2
		mem.giftWait = now + 0.45
		return
	end

	-- phase 2: egg çek / anchor (magnet + anchor zorla)
	if mem.giftPhase == 2 then
		local r = hrp()
		if not r then mem.giftWait = now + 0.3 return end
		local range = CFG.magnetRange or 160
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and hit(obj, EGG) then
				if (obj.Position - r.Position).Magnitude < range then
					obj.Anchored = false
					obj.CanCollide = false
					obj.CFrame = r.CFrame * CFrame.new(0, 2.6, 0)
					obj.AssemblyLinearVelocity = Vector3.zero
					if not obj:FindFirstChild("LeaWeld") then
						local w = Instance.new("WeldConstraint")
						w.Name = "LeaWeld"
						w.Part0 = r
						w.Part1 = obj
						w.Parent = obj
					end
				end
			end
		end
		local ok = hasCarriedEgg()
		if ok then
			mem.giftPhase = 3
			mem.giftWait = now + 0.25
		else
			mem.giftWait = now + 0.35
		end
		return
	end

	-- phase 3: başlangıç alanına dön
	if mem.giftPhase == 3 then
		local dest = mem.startPos or mem.saved
		if not dest and #mem.arenaList > 0 then
			dest = mem.arenaList[1].center
		end
		if dest then
			softTP(dest + Vector3.new(0, 3, 0))
		end
		mem.giftPhase = 4
		mem.giftWait = now + 0.5
		return
	end

	-- phase 4: egg'i başlangıçta bırak (auto bırak)
	if mem.giftPhase == 4 then
		local dest = mem.startPos or mem.saved
		if not dest and #mem.arenaList > 0 then
			dest = mem.arenaList[1].center
		end
		if dest then
			dropEggAt(dest)
		end
		-- bir tur bitti → tekrar son arenaya (farm döngüsü)
		mem.giftPhase = 1
		mem.giftWait = now + 0.4
		return
	end
end


-- ===== AUTO ARENA: sırayla arena ortalarına TP =====
local function arenaCenter(model)
	if model:IsA("BasePart") then
		return model.Position
	end
	if model:IsA("Model") then
		if model.PrimaryPart then
			return model.PrimaryPart.Position
		end
		local ok, cf = pcall(function()
			return model:GetBoundingBox()
		end)
		if ok and cf then
			return cf.Position
		end
		local acc, n = Vector3.zero, 0
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				acc += p.Position
				n += 1
			end
		end
		if n > 0 then return acc / n end
	end
	return nil
end

local function findArenas()
	local list = {}
	local key = string.lower(CFG.arenaName or "arena")
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder")) then
			local n = string.lower(obj.Name)
			if string.find(n, key, 1, true) then
				local c = arenaCenter(obj)
				if c then
					table.insert(list, { inst = obj, center = c, name = obj.Name })
				end
			end
		end
	end
	-- isme göre sayısal sıra (Arena1, Arena2...) yoksa mesafeye göre
	table.sort(list, function(a, b)
		local na = tonumber(string.match(a.name, "%d+"))
		local nb = tonumber(string.match(b.name, "%d+"))
		if na and nb then return na < nb end
		if na then return true end
		if nb then return false end
		local r = hrp()
		if r then
			return (a.center - r.Position).Magnitude < (b.center - r.Position).Magnitude
		end
		return a.name < b.name
	end)
	return list
end

-- oyuncunun bakış yönünde öndeki arenaları sıraya koy (başlangıç → son)
local function orderArenasForward(list)
	local r = hrp()
	local cam = Workspace.CurrentCamera
	if not r or not cam or #list == 0 then return list end
	local origin = r.Position
	local look = cam.CFrame.LookVector
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.05 then look = Vector3.new(0, 0, -1) else look = look.Unit end
	local scored = {}
	for _, a in ipairs(list) do
		local delta = a.center - origin
		local flat = Vector3.new(delta.X, 0, delta.Z)
		local along = flat:Dot(look)
		table.insert(scored, { a = a, along = along, dist = flat.Magnitude })
	end
	-- önce önde olanlar (along > 0), sonra along artan; geridekiler sonda
	table.sort(scored, function(x, y)
		local xf = x.along > -2
		local yf = y.along > -2
		if xf ~= yf then return xf end
		if math.abs(x.along - y.along) > 1 then return x.along < y.along end
		return x.dist < y.dist
	end)
	local out = {}
	for _, s in ipairs(scored) do table.insert(out, s.a) end
	return out
end

local function arenaStep()
	if not ON.AutoArena or mem.arenaBusy then return end
	if not mem.arenaList or #mem.arenaList == 0 then
		mem.arenaList = orderArenasForward(findArenas())
		mem.arenaIdx = 0
		if #mem.arenaList == 0 then return end
	end
	mem.arenaBusy = true
	mem.arenaIdx += 1
	if mem.arenaIdx > #mem.arenaList then
		-- yeniden tara, başa dön
		mem.arenaList = orderArenasForward(findArenas())
		mem.arenaIdx = 1
		if #mem.arenaList == 0 then
			mem.arenaBusy = false
			return
		end
	end
	local a = mem.arenaList[mem.arenaIdx]
	if a and a.center then
		softTP(a.center + Vector3.new(0, 3, 0))
	end
	task.delay(CFG.arenaDelay, function()
		mem.arenaBusy = false
	end)
end

-- loop
task.spawn(function()
	while true do
		task.wait(0.04)
		pcall(function()
			if ON.Speed or ON.HighJump then setWalk() end
			eggStep()
			guardStep()
			buddyStep()
			mobStep()
			bedStep()
			spinStep()
			collectStep()
			noFall()
			if ON.AutoArena then arenaStep() end
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(1.6)
		if ON.ESP or ON.ThreatESP then pcall(esp) end
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.4)
	if ON.Speed or ON.HighJump then setWalk() end
	if ON.Fly then flyOn() else flyOff() end
	if ON.Noclip then noclip(true) end
	if ON.EggBuddy then makeBuddy() end
	if ON.ESP or ON.ThreatESP then esp() end
end)

-- GUI
local function gui()
	local pg = LocalPlayer:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("LeaModeGui")
	if old then old:Destroy() end
	local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local sc = function(n) return math.floor(n * CFG.guiScale + 0.5) end

	local g = Instance.new("ScreenGui")
	g.Name = "LeaModeGui"
	g.ResetOnSpawn = false
	g.Parent = pg

	local open = Instance.new("TextButton")
	open.Size = UDim2.fromOffset(sc(mobile and 58 or 48), sc(mobile and 58 or 48))
	open.Position = UDim2.new(1, -sc(70), 0.28, 0)
	open.BackgroundColor3 = Color3.fromRGB(16,14,28)
	open.TextColor3 = Color3.fromRGB(200,140,255)
	open.Text = "LEA"
	open.Font = Enum.Font.GothamBold
	open.TextSize = sc(14)
	open.Parent = g
	Instance.new("UICorner", open).CornerRadius = UDim.new(0, 12)

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromOffset(sc(mobile and 300 or 280), sc(520))
	panel.Position = UDim2.new(1, -sc(315), 0.5, -sc(260))
	panel.BackgroundColor3 = Color3.fromRGB(12,12,20)
	panel.Visible = false
	panel.Parent = g
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
	local sk = Instance.new("UIStroke", panel)
	sk.Color = Color3.fromRGB(140,70,230)
	sk.Thickness = 1.4

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,-10,0,sc(26))
	title.Position = UDim2.fromOffset(10,6)
	title.BackgroundTransparency = 1
	title.Text = "LEA 2026"
	title.Font = Enum.Font.GothamBold
	title.TextSize = sc(16)
	title.TextColor3 = Color3.fromRGB(230,190,255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,-10,0,sc(14))
	info.Position = UDim2.fromOffset(10, sc(28))
	info.BackgroundTransparency = 1
	info.Text = "tek PASTE alanı üstte · RightShift"
	info.Font = Enum.Font.Gotham
	info.TextSize = sc(10)
	info.TextColor3 = Color3.fromRGB(110,110,130)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = panel

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1,-8,1,-sc(78))
	scroll.Position = UDim2.fromOffset(4, sc(46))
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.Parent = panel
	local lay = Instance.new("UIListLayout", scroll)
	lay.Padding = UDim.new(0,4)

	local st = Instance.new("TextLabel")
	st.Size = UDim2.new(1,-10,0,sc(18))
	st.Position = UDim2.new(0,8,1,-sc(24))
	st.BackgroundTransparency = 1
	st.Text = "ok"
	st.Font = Enum.Font.Gotham
	st.TextSize = sc(11)
	st.TextColor3 = Color3.fromRGB(140,255,170)
	st.TextXAlignment = Enum.TextXAlignment.Left
	st.Parent = panel
	local function say(t) st.Text = t end

	local order = 0
	local function next() order += 1 return order end

	local function tog(name, key, en, dis)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-4,0,sc(mobile and 40 or 34))
		b.BackgroundColor3 = Color3.fromRGB(28,28,44)
		b.TextColor3 = Color3.fromRGB(235,235,245)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = sc(12)
		b.LayoutOrder = next()
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
		local function ref()
			b.Text = name .. (ON[key] and "  ON" or "  OFF")
			b.BackgroundColor3 = ON[key] and Color3.fromRGB(78,40,120) or Color3.fromRGB(28,28,44)
		end
		b.MouseButton1Click:Connect(function()
			ON[key] = not ON[key]
			ref()
			if ON[key] and en then en() end
			if not ON[key] and dis then dis() end
			say(name .. (ON[key] and " ON" or " OFF"))
		end)
		ref()
	end

	local function act(name, fn)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-4,0,sc(mobile and 40 or 34))
		b.BackgroundColor3 = Color3.fromRGB(36,36,56)
		b.Text = name
		b.TextColor3 = Color3.fromRGB(235,235,245)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = sc(12)
		b.LayoutOrder = next()
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
		b.MouseButton1Click:Connect(fn)
	end

	tog("AutoEgg", "AutoEgg")
	tog("Egg Magnet (çek)", "EggMagnet")
	tog("Egg Anchor (weld)", "EggAnchor")
	tog("Egg Guard", "EggGuard")
	tog("Egg Buddy", "EggBuddy", makeBuddy, clearBuddy)
	tog("Threat ESP", "ThreatESP", esp, clearESP)
	tog("Smooth TP", "SmoothTP")
	tog("Hediye Modu (son arena→egg→başlangıç)", "GiftMode", function()
		mem.giftPhase = 0
		mem.giftWait = 0
		if hrp() then mem.startPos = hrp().Position end
		if mem.saved then mem.startPos = mem.saved end
	end, function()
		mem.giftPhase = 0
	end)
	tog("Auto Arena (sırayla orta)", "AutoArena", function()
		mem.arenaList = orderArenasForward(findArenas())
		mem.arenaIdx = 0
		mem.arenaBusy = false
	end, function()
		mem.arenaList = {}
		mem.arenaIdx = 0
	end)
	tog("Speed", "Speed", setWalk, setWalk)
	tog("Fly (LinearVelocity)", "Fly", flyOn, flyOff)
	tog("MobPush", "MobPush")
	tog("AutoBed", "AutoBed")
	tog("Noclip", "Noclip", function() noclip(true) end, function() noclip(false) end)
	tog("Inf Jump", "InfJump")
	tog("High Jump", "HighJump", setWalk, setWalk)
	tog("Click TP", "ClickTP")
	tog("ESP", "ESP", esp, clearESP)
	tog("Fullbright", "Fullbright", function() fullbright(true) end, function() fullbright(false) end)
	tog("Spin", "Spin")
	tog("Collect (velocity)", "Collect")
	tog("No Fall", "NoFall")

	act("Arena Tara / Sıfırla", function()
		mem.arenaList = orderArenasForward(findArenas())
		mem.arenaIdx = 0
		say("arena: "..#mem.arenaList)
	end)
	act("Konum Kaydet (F4)", function() say(savePos() and "kayıt" or "yok") end)
	act("Kayıtlı TP", function()
		if mem.saved then softTP(mem.saved) say("tp") else say("kayıt yok") end
	end)
	act("FOV +", function() CFG.fov=math.clamp(CFG.fov+10,50,120) if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=CFG.fov end say("fov "..CFG.fov) end)
	act("FOV -", function() CFG.fov=math.clamp(CFG.fov-10,50,120) if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=CFG.fov end say("fov "..CFG.fov) end)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1,-4,0,sc(30))
	box.BackgroundColor3 = Color3.fromRGB(24,24,38)
	box.Text = "FlySpeed: "..CFG.flySpeed
	box.TextColor3 = Color3.fromRGB(220,220,230)
	box.Font = Enum.Font.Gotham
	box.TextSize = sc(11)
	box.LayoutOrder = next()
	box.Parent = scroll
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,7)
	box.FocusLost:Connect(function()
		local v = tonumber(box.Text:match("%d+"))
		if v then CFG.flySpeed = math.clamp(v,20,250) box.Text = "FlySpeed: "..CFG.flySpeed end
	end)

	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 10)
	end)

	open.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)
	UIS.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.RightShift then panel.Visible = not panel.Visible
		elseif i.KeyCode == Enum.KeyCode.F4 then say(savePos() and "kayıt" or "yok")
		elseif i.KeyCode == Enum.KeyCode.F10 then ON.AutoEgg = not ON.AutoEgg say(ON.AutoEgg and "AutoEgg ON" or "OFF") end
	end)
end

gui()
print("LEA 2026 | tek PASTE alanı dosya başında | modlar yenilendi")
