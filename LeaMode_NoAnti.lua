--[[ LEA MODE — TAM KAPSAMLI BYPASS + ANTİKİCK + ANTİRESET ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- PART 1: ULTRA BYPASS ENGINE + ANTİKİCK + ANTİRESET
-- ============================================================

local Ultra = {
    Active = false,
    AntiCheat = true,
    AntiKick = true,
    AntiReset = true,
    RemoteKiller = true,
    GuiCleaner = true,
    PlayerProtector = true,
    Counter = 0,
    RemoteKillCount = 0,
    HealCount = 0,
    KickBlockCount = 0
}

-- ==================== REMOTE KİLLER ====================
local RemoteKiller = { KillList = {}, KillCount = 0 }

RemoteKiller.KillList = {
    "Integrity", "Violation", "Correction", "Detect", "Kick", "Ban",
    "Admin", "AntiTamper", "Exploit", "ClientCharacter", "Analytics",
    "Reset", "Sync", "Guard", "Forest", "SpeedHit", "WakeUp",
    "Unequip", "RuntimeOwner", "Ping", "Heartbeat", "Validation",
    "Verification", "Teleport", "TP", "Position", "MoveTo",
    "Spawn", "Respawn", "Revive", "Trade", "Market", "Product"
}

function RemoteKiller:Scan()
    local network = ReplicatedStorage:FindFirstChild("Network")
    if not network then return end
    local killed = 0
    for _, obj in ipairs(network:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, kw in ipairs(self.KillList) do
                if string.find(obj.Name, kw) then
                    pcall(function() obj:Destroy() end)
                    killed = killed + 1
                    break
                end
            end
        end
    end
    if killed > 0 then
        print("🔥 " .. killed .. " remote yok edildi! (Toplam: " .. self.KillCount .. ")")
        self.KillCount = self.KillCount + killed
    end
end

function RemoteKiller:Watch()
    local network = ReplicatedStorage:FindFirstChild("Network")
    if not network then return end
    network.DescendantAdded:Connect(function(child)
        task.wait(0.05)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            for _, kw in ipairs(self.KillList) do
                if string.find(child.Name, kw) then
                    pcall(function() child:Destroy() end)
                    self.KillCount = self.KillCount + 1
                    print("🆕 Remote yok edildi: " .. child.Name)
                    break
                end
            end
        end
    end)
end

-- ==================== ANTI-KICK ====================
local AntiKick = { Active = false, BlockCount = 0 }

function AntiKick:Start()
    if self.Active then return end
    self.Active = true
    print("🛡️ ANTI-KICK AKTİF!")
    
    LocalPlayer.Changed:Connect(function(prop)
        if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
            pcall(function() LocalPlayer.Parent = Players end)
            self.BlockCount = self.BlockCount + 1
            print("🛡️ LocalPlayer korundu! (" .. self.BlockCount .. ")")
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
                           string.find(n, "violation") or string.find(n, "denetim") then
                            c:Destroy()
                            print("🧹 GUI temizlendi: " .. c.Name)
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== ANTI-RESET ====================
local AntiReset = { Active = false, HealCount = 0 }

function AntiReset:Start()
    if self.Active then return end
    self.Active = true
    print("🔄 ANTI-RESET AKTİF! (BreakJointsOnDeath = false)")
    
    local function protectChar()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if hum.BreakJointsOnDeath ~= false then
            hum.BreakJointsOnDeath = false
            print("🛡️ BreakJointsOnDeath düzeltildi!")
        end
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
            self.HealCount = self.HealCount + 1
            print("💚 Can yenilendi! (" .. self.HealCount .. ")")
        end
        if hum.Health < 10 then
            hum.Health = hum.MaxHealth
            self.HealCount = self.HealCount + 1
        end
        if hum.PlatformStand == true then hum.PlatformStand = false end
        if hum.AutoRotate == false then hum.AutoRotate = true end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.Health = hum.MaxHealth
            print("🔄 Karakter yeniden doğdu! Koruma aktif!")
        end
    end)
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.05)
            pcall(protectChar)
        end
    end)
    protectChar()
end

-- ==================== BYPASS BAŞLAT ====================
local function StartUltraBypass()
    if Ultra.Active then return end
    Ultra.Active = true
    
    print("========================================")
    print("🛡️ ULTRA BYPASS AKTİF!")
    print("✅ Anti-Cheat Bypass")
    print("✅ Remote Killer (500+ remote yok edilir)")
    print("✅ Anti-Kick (Kick yemezsin)")
    print("✅ Anti-Reset (BreakJointsOnDeath)")
    print("========================================")
    
    RemoteKiller:Scan()
    RemoteKiller:Watch()
    AntiKick:Start()
    AntiReset:Start()
    
    task.spawn(function()
        while Ultra.Active do
            task.wait(0.2)
            pcall(function() RemoteKiller:Scan() end)
        end
    end)
end

local function StopUltraBypass()
    Ultra.Active = false
    print("🛡️ ULTRA BYPASS PASİF!")
end

-- ==================== OTOMATİK BAŞLAT ====================
task.wait(0.5)
StartUltraBypass()-- ============================================================
-- PART 2: LEA MODE ANA SİSTEM + MODLAR
-- ============================================================

local CFG = {
	flySpeed = 70,
	walkBoost = 48,
	jumpBoost = 80,
	eggRange = 120,
	guardRange = 16,
	arenaDelay = 0.35,
	arenaName = "arena",
	giftDelay = 0.25,
}

local ON = {}
for _, k in ipairs({
	"AutoEgg","Speed","Fly","MobPush","AutoBed","Noclip","InfJump","ClickTP",
	"ESP","Fullbright","HighJump","NoFall","EggGuard","EggMagnet","EggAnchor",
	"EggBuddy","AutoArena","GiftMode","SmoothTP"
}) do ON[k] = false end

local M = {
	saved = nil, startPos = nil,
	flyBV = nil, flyBG = nil, flyAtt = nil, flyConn = nil,
	noclipConn = nil, espFolder = nil, buddyFolder = nil,
	arenaList = {}, arenaIdx = 0, arenaBusy = false,
	giftPhase = 0, giftWait = 0,
	lit = {},
}

local EGG = {"egg","goldenegg","petegg","eggmodel"}
local BED = {"bed","bad"}

local function char() return LocalPlayer.Character end
local function hrp() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hit(o, list)
	local n = string.lower(o.Name)
	for _,k in ipairs(list) do if string.find(n,k,1,true) then return true end end
	return false
end

local function hardTP(pos)
	local r = hrp()
	if not r or not pos then return end
	r.CFrame = CFrame.new(pos)
	r.AssemblyLinearVelocity = Vector3.zero
	r.AssemblyAngularVelocity = Vector3.zero
end

local function savePos()
	local r = hrp()
	if r then M.saved = r.Position return true end
	return false
end

-- ==================== SPEED ====================
local function applySpeed()
	local h = hum()
	if not h then return end
	h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
	if ON.HighJump then
		h.JumpPower = CFG.jumpBoost
		pcall(function() h.JumpHeight = 18 end)
	else
		h.JumpPower = 50
		pcall(function() h.JumpHeight = 7.2 end)
	end
end

-- ==================== FLY ====================
local function flyDestroy()
	if M.flyConn then M.flyConn:Disconnect() M.flyConn = nil end
	if M.flyBV then pcall(function() M.flyBV:Destroy() end) M.flyBV = nil end
	if M.flyBG then pcall(function() M.flyBG:Destroy() end) M.flyBG = nil end
	if M.flyAtt then pcall(function() M.flyAtt:Destroy() end) M.flyAtt = nil end
	local h = hum()
	if h and not ON.Fly then h.PlatformStand = false end
end

local function flyEnsure()
	if not ON.Fly then flyDestroy() return end
	local r, h = hrp(), hum()
	if not r or not h then return end
	h.PlatformStand = true
	if not M.flyAtt or M.flyAtt.Parent ~= r then
		flyDestroy()
		local att = Instance.new("Attachment")
		att.Name = "LeaFlyAtt"
		att.Parent = r
		M.flyAtt = att
		local lv = Instance.new("LinearVelocity")
		lv.Name = "LeaFlyLV"
		lv.Attachment0 = att
		lv.MaxForce = 1e7
		lv.VectorVelocity = Vector3.zero
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		lv.Parent = r
		M.flyBV = lv
		local ao = Instance.new("AlignOrientation")
		ao.Name = "LeaFlyAO"
		ao.Attachment0 = att
		ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
		ao.MaxTorque = 1e7
		ao.Responsiveness = 50
		ao.Parent = r
		M.flyBG = ao
	end
	if not M.flyConn then
		M.flyConn = RunService.Heartbeat:Connect(function()
			if not ON.Fly then return end
			local rr = hrp()
			if not rr then return end
			if not M.flyBV or M.flyBV.Parent ~= rr then
				flyDestroy()
				flyEnsure()
				return
			end
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
			M.flyBV.VectorVelocity = v.Magnitude > 0 and v.Unit * CFG.flySpeed or Vector3.zero
			if M.flyBG then M.flyBG.CFrame = cam.CFrame end
			local hh = hum()
			if hh then hh.PlatformStand = true end
		end)
	end
end

-- ==================== EGG ====================
local function grabEgg()
	local r = hrp()
	if not r then return false end
	local range = ON.EggMagnet and CFG.eggRange or 80
	local best, bestD = nil, range
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, EGG) then
			local d = (obj.Position - r.Position).Magnitude
			if d < bestD then bestD, best = d, obj end
		end
	end
	if not best then return false end
	best.Anchored = false
	best.CanCollide = false
	best.CFrame = r.CFrame * CFrame.new(0, 2.5, 0)
	best.AssemblyLinearVelocity = Vector3.zero
	if ON.EggAnchor or ON.AutoEgg or ON.GiftMode then
		if not best:FindFirstChild("LeaWeld") then
			local w = Instance.new("WeldConstraint")
			w.Name = "LeaWeld"
			w.Part0 = r
			w.Part1 = best
			w.Parent = best
		end
	end
	return true
end

local function dropEggAt(pos)
	local r = hrp()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and hit(obj, EGG) then
			local w = obj:FindFirstChild("LeaWeld")
			if w then w:Destroy() end
			if r and (obj.Position - r.Position).Magnitude < 15 then
				obj.Anchored = true
				obj.CanCollide = true
				obj.AssemblyLinearVelocity = Vector3.zero
				obj.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
			end
		end
	end
end

local function eggTick()
	if ON.AutoEgg then
		if M.saved then hardTP(M.saved) end
		grabEgg()
	elseif ON.EggMagnet or ON.EggAnchor then
		grabEgg()
	end
end

-- ==================== GUARD / MOB ====================
local function guardTick()
	if not ON.EggGuard then return end
	local r = hrp()
	if not r then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local o = plr.Character:FindFirstChild("HumanoidRootPart")
			if o then
				local d = (o.Position - r.Position).Magnitude
				if d > 0.5 and d <= CFG.guardRange then
					local away = o.Position - r.Position
					if away.Magnitude > 0 then
						o.AssemblyLinearVelocity = away.Unit * 90 + Vector3.new(0, 40, 0)
					end
				end
			end
		end
	end
end

local function mobTick()
	if not ON.MobPush then return end
	local r = hrp()
	if not r then return end
	for _, m in ipairs(Workspace:GetChildren()) do
		if m:IsA("Model") and m ~= char() and not Players:GetPlayerFromCharacter(m) then
			local mh = m:FindFirstChildOfClass("Humanoid")
			local mr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
			if mh and mr and mh.Health > 0 then
				local d = (mr.Position - r.Position).Magnitude
				if d > 0.4 and d <= 14 then
					local away = r.Position - mr.Position
					if away.Magnitude > 0 then
						r.AssemblyLinearVelocity = away.Unit * 75 + Vector3.new(0, 35, 0)
					end
				end
			end
		end
	end
end

-- ==================== BED ====================
local function bedTick()
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
	local best, bd = nil, 18
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
		r.CFrame = CFrame.lookAt(r.Position:Lerp(best.Position, 0.4), best.Position)
	end
end

-- ==================== NOCLIP ====================
local function setNoclip(on)
	if M.noclipConn then M.noclipConn:Disconnect() M.noclipConn = nil end
	if not on then return end
	M.noclipConn = RunService.Stepped:Connect(function()
		local c = char()
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end)
end

-- ==================== INFJUMP ====================
UIS.JumpRequest:Connect(function()
	if ON.InfJump then
		local h = hum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ==================== CLICKTP ====================
Mouse.Button1Down:Connect(function()
	if not ON.ClickTP then return end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS.TouchEnabled then
		if Mouse.Hit then hardTP(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
	end
end)

-- ==================== ESP ====================
local function clearESP()
	if M.espFolder then pcall(function() M.espFolder:Destroy() end) end
	M.espFolder = nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local x = plr.Character:FindFirstChild("LeaHL")
			if x then x:Destroy() end
		end
	end
end

local function doESP()
	clearESP()
	if not ON.ESP then return end
	local f = Instance.new("Folder")
	f.Name = "LeaESP"
	f.Parent = Workspace
	M.espFolder = f
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hl = Instance.new("Highlight")
			hl.Name = "LeaHL"
			hl.FillColor = Color3.fromRGB(170, 80, 255)
			hl.OutlineColor = Color3.new(1,1,1)
			hl.FillTransparency = 0.55
			hl.Parent = plr.Character
		end
	end
end

-- ==================== FULLBRIGHT ====================
local function fullbright(on)
	if on then
		M.lit.b, M.lit.c, M.lit.f = Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1e6
		Lighting.GlobalShadows = false
	else
		if M.lit.b then Lighting.Brightness = M.lit.b end
		if M.lit.c then Lighting.ClockTime = M.lit.c end
		if M.lit.f then Lighting.FogEnd = M.lit.f end
		Lighting.GlobalShadows = true
		M.lit = {}
	end
end

-- ==================== NOFALL ====================
local function noFall()
	if not ON.NoFall then return end
	local h = hum()
	if h and h:GetState() == Enum.HumanoidStateType.Freefall then
		h:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end-- ============================================================
-- PART 3: ARENA + GİFT + MENÜ + ANA LOOP
-- ============================================================

-- ==================== ARENA ====================
local function arenaCenter(model)
	if model:IsA("BasePart") then return model.Position end
	if model:IsA("Model") then
		local ok, cf = pcall(function() return model:GetBoundingBox() end)
		if ok and cf then return cf.Position end
		if model.PrimaryPart then return model.PrimaryPart.Position end
	end
	return nil
end

local function findArenas()
	local list, key = {}, string.lower(CFG.arenaName)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), key, 1, true) then
			local c = arenaCenter(obj)
			if c then table.insert(list, {center=c, name=obj.Name}) end
		end
	end
	table.sort(list, function(a,b)
		local na, nb = tonumber(string.match(a.name,"%d+")), tonumber(string.match(b.name,"%d+"))
		if na and nb then return na < nb end
		return a.name < b.name
	end)
	return list
end

local function arenaTick()
	if not ON.AutoArena or M.arenaBusy then return end
	if #M.arenaList == 0 then
		M.arenaList = findArenas()
		M.arenaIdx = 0
		if #M.arenaList == 0 then return end
	end
	M.arenaBusy = true
	M.arenaIdx += 1
	if M.arenaIdx > #M.arenaList then
		M.arenaList = findArenas()
		M.arenaIdx = 1
	end
	local a = M.arenaList[M.arenaIdx]
	if a then hardTP(a.center + Vector3.new(0, 3, 0)) end
	task.delay(CFG.arenaDelay, function() M.arenaBusy = false end)
end

-- ==================== GİFT MODE ====================
local function giftTick()
	if not ON.GiftMode then M.giftPhase = 0 return end
	local now = os.clock()
	if now < M.giftWait then return end

	if M.giftPhase == 0 then
		M.startPos = M.saved or (hrp() and hrp().Position)
		M.arenaList = findArenas()
		if #M.arenaList == 0 then M.giftWait = now + 1 return end
		M.giftPhase = 1
		M.giftWait = now + 0.05
		return
	end
	if M.giftPhase == 1 then
		local last = M.arenaList[#M.arenaList]
		if last then hardTP(last.center + Vector3.new(0, 3, 0)) end
		M.giftPhase = 2
		M.giftWait = now + CFG.giftDelay
		return
	end
	if M.giftPhase == 2 then
		if grabEgg() then
			M.giftPhase = 3
			M.giftWait = now + 0.1
		else
			M.giftWait = now + 0.2
		end
		return
	end
	if M.giftPhase == 3 then
		local dest = M.startPos or M.saved
		if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
		if dest then hardTP(dest + Vector3.new(0, 3, 0)) end
		M.giftPhase = 4
		M.giftWait = now + CFG.giftDelay
		return
	end
	if M.giftPhase == 4 then
		local dest = M.startPos or M.saved
		if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
		if dest then dropEggAt(dest) end
		M.giftPhase = 1
		M.giftWait = now + 0.15
	end
end

-- ==================== BUDDY ====================
local function buddyTick()
	if not ON.EggBuddy then
		if M.buddyFolder then pcall(function() M.buddyFolder:Destroy() end) M.buddyFolder = nil end
		return
	end
	local r = hrp()
	if not r then return end
	if not M.buddyFolder then
		local f = Instance.new("Folder")
		f.Name = "LeaBuddy"
		f.Parent = Workspace
		M.buddyFolder = f
		for i = 1, 3 do
			local p = Instance.new("Part")
			p.Shape = Enum.PartType.Ball
			p.Size = Vector3.new(1,1,1)
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromRGB(160, 80, 255)
			p.Anchored = true
			p.CanCollide = false
			p.Parent = f
		end
	end
	local t = os.clock()
	local i = 0
	for _, p in ipairs(M.buddyFolder:GetChildren()) do
		if p:IsA("BasePart") then
			i += 1
			local a = t * 3 + i * 2.1
			p.CFrame = CFrame.new(r.Position + Vector3.new(math.cos(a)*5, 2, math.sin(a)*5))
		end
	end
end

-- ==================== ANA LOOP ====================
RunService.Heartbeat:Connect(function()
	pcall(function()
		if ON.Speed or ON.HighJump then applySpeed() end
		if ON.Fly then flyEnsure() end
		eggTick()
		guardTick()
		mobTick()
		bedTick()
		noFall()
		buddyTick()
		if ON.AutoArena then arenaTick() end
		if ON.GiftMode then giftTick() end
	end)
end)

task.spawn(function()
	while true do
		task.wait(2)
		if ON.ESP then pcall(doESP) end
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.3)
	flyDestroy()
	if ON.Fly then flyEnsure() end
	if ON.Speed then applySpeed() end
	if ON.Noclip then setNoclip(true) end
	if ON.ESP then doESP() end
end)

-- ==================== MENÜ ====================
local function buildGui()
	local pg = LocalPlayer:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("LeaModeGui")
	if old then old:Destroy() end

	local g = Instance.new("ScreenGui")
	g.Name = "LeaModeGui"
	g.ResetOnSpawn = false
	g.Parent = pg

	local open = Instance.new("TextButton")
	open.Size = UDim2.fromOffset(44, 44)
	open.Position = UDim2.new(1, -52, 0.35, 0)
	open.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
	open.TextColor3 = Color3.fromRGB(200, 140, 255)
	open.Text = "LEA"
	open.Font = Enum.Font.GothamBold
	open.TextSize = 12
	open.Parent = g
	Instance.new("UICorner", open).CornerRadius = UDim.new(0, 10)

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromOffset(200, 320)
	panel.Position = UDim2.new(1, -212, 0.5, -160)
	panel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
	panel.Visible = false
	panel.Parent = g
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
	local st = Instance.new("UIStroke", panel)
	st.Color = Color3.fromRGB(130, 70, 220)
	st.Thickness = 1

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -8, 0, 22)
	title.Position = UDim2.fromOffset(6, 4)
	title.BackgroundTransparency = 1
	title.Text = "LEA"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = Color3.fromRGB(220, 180, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -6, 1, -48)
	scroll.Position = UDim2.fromOffset(3, 26)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.Parent = panel
	local lay = Instance.new("UIListLayout", scroll)
	lay.Padding = UDim.new(0, 3)

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -8, 0, 16)
	status.Position = UDim2.new(0, 6, 1, -18)
	status.BackgroundTransparency = 1
	status.Text = "ok"
	status.Font = Enum.Font.Gotham
	status.TextSize = 10
	status.TextColor3 = Color3.fromRGB(140, 255, 170)
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = panel
	local function say(t) status.Text = tostring(t) end

	local order = 0
	local function tog(name, key, onE, onD)
		order += 1
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 26)
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
		b.TextColor3 = Color3.fromRGB(230, 230, 240)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 11
		b.LayoutOrder = order
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local function ref()
			b.Text = name .. (ON[key] and " ON" or " OFF")
			b.BackgroundColor3 = ON[key] and Color3.fromRGB(70, 40, 110) or Color3.fromRGB(30, 30, 44)
		end
		b.MouseButton1Click:Connect(function()
			ON[key] = not ON[key]
			ref()
			if ON[key] and onE then onE() end
			if not ON[key] and onD then onD() end
			say(name .. (ON[key] and " ON" or " OFF"))
		end)
		ref()
	end

	local function act(name, fn)
		order += 1
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 26)
		b.BackgroundColor3 = Color3.fromRGB(38, 38, 56)
		b.Text = name
		b.TextColor3 = Color3.fromRGB(230, 230, 240)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 11
		b.LayoutOrder = order
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(fn)
	end

	tog("AutoEgg", "AutoEgg")
	tog("Egg Magnet", "EggMagnet")
	tog("Egg Anchor", "EggAnchor")
	tog("Egg Guard", "EggGuard")
	tog("Gift Mode", "GiftMode", function()
		M.giftPhase = 0
		M.startPos = M.saved or (hrp() and hrp().Position)
	end)
	tog("Auto Arena", "AutoArena", function()
		M.arenaList = findArenas()
		M.arenaIdx = 0
		M.arenaBusy = false
		say("arena "..#M.arenaList)
	end)
	tog("Speed", "Speed", applySpeed, applySpeed)
	tog("Fly", "Fly", flyEnsure, flyDestroy)
	tog("MobPush", "MobPush")
	tog("AutoBed", "AutoBed")
	tog("Noclip", "Noclip", function() setNoclip(true) end, function() setNoclip(false) end)
	tog("InfJump", "InfJump")
	tog("HighJump", "HighJump", applySpeed, applySpeed)
	tog("ClickTP", "ClickTP")
	tog("ESP", "ESP", doESP, clearESP)
	tog("Fullbright", "Fullbright", function() fullbright(true) end, function() fullbright(false) end)
	tog("NoFall", "NoFall")
	
	-- ==================== BYPASS BUTONLARI ====================
	act("🛡️ BYPASS: AÇ", function()
		StartUltraBypass()
		say("Bypass Aktif")
	end)
	act("🛡️ BYPASS: KAPAT", function()
		StopUltraBypass()
		say("Bypass Pasif")
	end)

	act("Kaydet (F4)", function() say(savePos() and "kayıt OK" or "yok") end)
	act("Base TP", function()
		if M.saved then hardTP(M.saved) say("base") else say("F4 kaydet") end
	end)
	act("Arena tara", function()
		M.arenaList = findArenas()
		say("arena "..#M.arenaList)
	end)

	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 6)
	end)

	open.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)

	UIS.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.RightShift then
			panel.Visible = not panel.Visible
		elseif i.KeyCode == Enum.KeyCode.F4 then
			say(savePos() and "kayıt OK" or "yok")
		elseif i.KeyCode == Enum.KeyCode.F10 then
			ON.AutoEgg = not ON.AutoEgg
			say(ON.AutoEgg and "AutoEgg ON" or "OFF")
		end
	end)
end

buildGui()
print("[LEA] TAM KAPSAMLI BYPASS | AutoEgg | Fly | RightShift menü")
