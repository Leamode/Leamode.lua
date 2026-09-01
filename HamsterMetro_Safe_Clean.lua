-- HAMSTER METRO - SAFE STUDIO DEMO (v3)
-- Kendi Roblox Studio oyununuz icin LocalScript.
-- Anti-cheat bypass / remote killer / anti-kick YOK.
--
-- StarterPlayer > StarterPlayerScripts icine LocalScript olarak koyun.
--
-- NOT: Gercek "olmeme / item dusmeme" kendi oyununuzda SERVER tarafinda
-- yapilmalidir. Bu dosya Studio demo / local yardimcidir.
--
-- Ozellikler:
-- * Intro + yan menu
-- * Wall / Metro / Prone (In)
-- * Sandalye
-- * Antikill (local)
-- * Egg Lock: eldeki egg sabit, vurulunca dusmesin
-- * E: yakin egg'i aninda al
-- * Anti-knock: vurulunca dusme animasyonu yok, ayakta kal
-- * 1 kisilik public server bulucu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("HamsterMetroSafe")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterMetroSafe"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- =========================================================
-- INTRO (kisa)
-- =========================================================

local intro = Instance.new("Frame")
intro.Size = UDim2.fromScale(1, 1)
intro.BackgroundColor3 = Color3.fromRGB(3, 3, 8)
intro.BorderSizePixel = 0
intro.ZIndex = 100
intro.Parent = gui

local function planet(size, position, text)
	local p = Instance.new("TextLabel")
	p.Size = UDim2.fromOffset(size, size)
	p.Position = position
	p.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	p.BorderSizePixel = 0
	p.Text = text
	p.TextSize = math.floor(size * 0.45)
	p.ZIndex = 101
	p.Parent = intro
	Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
	return p
end

local leftPlanet = planet(160, UDim2.new(0.5, -280, 0.5, -80), "☀")
local rightPlanet = planet(160, UDim2.new(0.5, 120, 0.5, -80), "☀")
local glow = Instance.new("TextLabel")
glow.Size = UDim2.fromScale(1, 1)
glow.BackgroundTransparency = 1
glow.Text = "✦"
glow.TextSize = 70
glow.TextColor3 = Color3.new(1, 1, 1)
glow.TextTransparency = 1
glow.ZIndex = 102
glow.Parent = intro

local infoTween = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
TweenService:Create(leftPlanet, infoTween, {Position = UDim2.new(0.5, -80, 0.5, -80)}):Play()
TweenService:Create(rightPlanet, infoTween, {Position = UDim2.new(0.5, -80, 0.5, -80)}):Play()
task.wait(0.75)
TweenService:Create(glow, TweenInfo.new(0.12), {TextTransparency = 0, TextSize = 140}):Play()
task.wait(0.15)
TweenService:Create(intro, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
TweenService:Create(leftPlanet, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
TweenService:Create(rightPlanet, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
TweenService:Create(glow, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
task.wait(0.45)
intro:Destroy()

-- =========================================================
-- MENU
-- =========================================================

local toggle = Instance.new("TextButton")
toggle.Name = "MenuToggle"
toggle.Size = UDim2.fromOffset(58, 58)
toggle.Position = UDim2.new(1, -75, 0.5, -29)
toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
toggle.BorderSizePixel = 0
toggle.Text = "☰"
toggle.TextSize = 26
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.ZIndex = 20
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local menu = Instance.new("Frame")
menu.Name = "SideMenu"
menu.Size = UDim2.fromOffset(440, 560)
menu.Position = UDim2.new(1, 20, 0.5, -280)
menu.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
menu.BorderSizePixel = 0
menu.ZIndex = 10
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 46)
title.Position = UDim2.fromOffset(18, 8)
title.BackgroundTransparency = 1
title.Text = "HAMSTER METRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 11
title.Parent = menu

local trash = Instance.new("TextButton")
trash.Size = UDim2.fromOffset(42, 42)
trash.Position = UDim2.new(1, -50, 0, 10)
trash.BackgroundTransparency = 1
trash.Text = "🗑"
trash.TextSize = 22
trash.ZIndex = 12
trash.Parent = menu

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -30, 0, 1)
divider.Position = UDim2.fromOffset(15, 54)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider.BorderSizePixel = 0
divider.ZIndex = 11
divider.Parent = menu

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.5, -12, 1, -70)
leftPanel.Position = UDim2.fromOffset(10, 64)
leftPanel.BackgroundTransparency = 1
leftPanel.ZIndex = 11
leftPanel.Parent = menu

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.5, -12, 1, -70)
rightPanel.Position = UDim2.new(0.5, 2, 0, 64)
rightPanel.BackgroundTransparency = 1
rightPanel.ZIndex = 11
rightPanel.Parent = menu

local function makeButton(parent, text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 44)
	b.Position = UDim2.fromOffset(4, y)
	b.BackgroundColor3 = Color3.fromRGB(31, 31, 42)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 12
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
	return b
end

-- Sol
local seatButton = makeButton(leftPanel, "🪑 SANDALYE OLUSTUR", 0)
local sitButton = makeButton(leftPanel, "🪑 OTUR", 50)
local leaveButton = makeButton(leftPanel, "⬇ SANDALYEDEN IN", 100)
local wallButton = makeButton(leftPanel, "🧱 WALL : KAPALI", 150)
local metroButton = makeButton(leftPanel, "🚇 METRO : KAPALI", 200)
local proneButton = makeButton(leftPanel, "⬇ IN (YERE) : KAPALI", 250)

-- Sag - yeni
local antikillButton = makeButton(rightPanel, "❤ ANTIKILL : KAPALI", 0)
local eggLockButton = makeButton(rightPanel, "🥚 EGG LOCK : KAPALI", 50)
local antiKnockButton = makeButton(rightPanel, "🛡 AYAKTA KAL : KAPALI", 100)
local serverButton = makeButton(rightPanel, "👤 1 KISILIK SERVER BUL", 150)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -8, 0, 200)
info.Position = UDim2.fromOffset(4, 205)
info.BackgroundTransparency = 1
info.Text = "ANTIKILL: can 0 olmaz (local)\nEGG LOCK: eldeki egg dusmez\nE tusu: yakin egg aninda al\nAYAKTA KAL: vurulunca dusme yok\n\nKendi Studio oyunun icin.\nKalici koruma = server script."
info.TextColor3 = Color3.fromRGB(180, 180, 190)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextYAlignment = Enum.TextYAlignment.Top
info.ZIndex = 12
info.Parent = rightPanel

-- =========================================================
-- STATE
-- =========================================================

local seat, wall
local wallEnabled = false
local metroEnabled = false
local proneEnabled = false
local antikillEnabled = false
local eggLockEnabled = false
local antiKnockEnabled = false
local metroDirection

local METRO_SPEED = 180
local WALL_PUSH = 42
local PRONE_OFFSET = 2.6
local EGG_PICK_RANGE = 18

local savedHipHeight, savedWalkSpeed, savedJumpPower
local lockedEggTool = nil -- elde sabitlenen tool
local humanoidConns = {}

local function getCharacter()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid and root then
		return character, humanoid, root
	end
end

local function clearHumanoidConns()
	for _, c in ipairs(humanoidConns) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(humanoidConns)
end

local function isEggName(name)
	if not name then return false end
	local n = string.lower(name)
	return string.find(n, "egg", 1, true) ~= nil
		or string.find(n, "yumurta", 1, true) ~= nil
end

local function findEggTool(container)
	if not container then return nil end
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("Tool") and isEggName(ch.Name) then
			return ch
		end
	end
	return nil
end

-- =========================================================
-- SEAT / WALL / METRO / PRONE (onceki)
-- =========================================================

seatButton.Activated:Connect(function()
	local _, _, root = getCharacter()
	if not root then return end
	if seat then seat:Destroy() end
	seat = Instance.new("Seat")
	seat.Name = "HamsterMetroSeat"
	seat.Size = Vector3.new(2.5, 1, 2.5)
	seat.Anchored = true
	seat.CanCollide = true
	seat.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
	seat.Parent = workspace
	seatButton.Text = "✓ SANDALYE HAZIR"
	task.delay(1, function()
		if seatButton.Parent then seatButton.Text = "🪑 SANDALYE OLUSTUR" end
	end)
end)

sitButton.Activated:Connect(function()
	local _, humanoid, root = getCharacter()
	if not root or not humanoid then return end
	if not seat or not seat.Parent then
		sitButton.Text = "ONCE SANDALYE"
		task.delay(1, function()
			if sitButton.Parent then sitButton.Text = "🪑 OTUR" end
		end)
		return
	end
	root.CFrame = seat.CFrame * CFrame.new(0, 2.5, 0)
	task.wait(0.1)
	pcall(function()
		seat:Sit(humanoid)
	end)
end)

leaveButton.Activated:Connect(function()
	local _, humanoid = getCharacter()
	if humanoid then
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

local function createWall()
	local _, _, root = getCharacter()
	if not root then return end
	if wall then wall:Destroy() end
	wall = Instance.new("Part")
	wall.Name = "HamsterMetroWall"
	wall.Size = Vector3.new(16, 12, 4)
	wall.Anchored = true
	wall.CanCollide = true
	wall.CanTouch = true
	wall.CanQuery = false
	wall.Transparency = 1
	wall.Parent = workspace
	wallEnabled = true
end

wallButton.Activated:Connect(function()
	if wallEnabled then
		wallEnabled = false
		if wall then wall:Destroy(); wall = nil end
		wallButton.Text = "🧱 WALL : KAPALI"
	else
		createWall()
		wallButton.Text = "🧱 WALL : AKTIF"
	end
end)

metroButton.Activated:Connect(function()
	if not metroEnabled then
		metroEnabled = true
		metroButton.Text = "🚇 METRO : AKTIF"
	else
		metroEnabled = false
		metroDirection = nil
		metroButton.Text = "🚇 METRO : KAPALI"
	end
end)

local function setProne(on)
	local character, humanoid, root = getCharacter()
	if not humanoid or not root then return end
	if on then
		if not proneEnabled then
			savedHipHeight = humanoid.HipHeight
			savedWalkSpeed = humanoid.WalkSpeed
			savedJumpPower = humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight
		end
		proneEnabled = true
		pcall(function() humanoid.HipHeight = 0.1 end)
		humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, 8)
		if humanoid.UseJumpPower then humanoid.JumpPower = 0 else humanoid.JumpHeight = 0 end
		local pos = root.Position
		root.CFrame = CFrame.new(pos.X, pos.Y - PRONE_OFFSET, pos.Z) * (root.CFrame - root.CFrame.Position)
		proneButton.Text = "⬇ IN (YERE) : AKTIF"
	else
		proneEnabled = false
		if savedHipHeight then pcall(function() humanoid.HipHeight = savedHipHeight end) end
		if savedWalkSpeed then humanoid.WalkSpeed = savedWalkSpeed end
		if savedJumpPower then
			if humanoid.UseJumpPower then humanoid.JumpPower = savedJumpPower else humanoid.JumpHeight = savedJumpPower end
		end
		local pos = root.Position
		root.CFrame = CFrame.new(pos.X, pos.Y + PRONE_OFFSET, pos.Z) * (root.CFrame - root.CFrame.Position)
		proneButton.Text = "⬇ IN (YERE) : KAPALI"
	end
end

proneButton.Activated:Connect(function()
	setProne(not proneEnabled)
end)

-- =========================================================
-- 1 KISILIK PUBLIC SERVER BULUCU
-- =========================================================
-- Yalnizca public instance listesinde playing == 1 olan
-- server'i arar. Bulamazsa mevcut server'da kalir.
-- Bu kisim anti-cheat/koruma atlatmaz.

local function findOnePlayerServer()
	local placeId = game.PlaceId
	if not placeId or placeId <= 0 then
		return nil, "Gecerli PlaceId yok."
	end

	local cursor = ""

	for _ = 1, 10 do
		local url =
			"https://games.roblox.com/v1/games/"
			.. tostring(placeId)
			.. "/servers/Public?sortOrder=Asc&limit=100"

		if cursor ~= "" then
			url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
		end

		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)

		if not ok or type(body) ~= "string" then
			return nil, "Server listesine erisilemedi."
		end

		local decodedOk, data = pcall(function()
			return HttpService:JSONDecode(body)
		end)

		if not decodedOk or type(data) ~= "table" then
			return nil, "Server listesi okunamadi."
		end

		for _, server in ipairs(data.data or {}) do
			local playing = tonumber(server.playing) or 0
			local maxPlayers = tonumber(server.maxPlayers) or 0

			if server.id
				and playing == 1
				and maxPlayers > 1 then
				return server.id
			end
		end

		cursor = data.nextPageCursor or ""
		if cursor == "" then
			break
		end

		task.wait()
	end

	return nil, "1 kisilik public server bulunamadi."
end

serverButton.Activated:Connect(function()
	if serverButton:GetAttribute("Busy") then
		return
	end

	serverButton:SetAttribute("Busy", true)
	serverButton.Text = "🔎 SERVER ARANIYOR..."

	task.spawn(function()
		local serverId, err = findOnePlayerServer()

		if not serverId then
			warn("[HamsterMetro] " .. tostring(err))
			serverButton.Text = "SERVER BULUNAMADI"

			task.wait(1.2)

			if serverButton.Parent then
				serverButton.Text = "👤 1 KISILIK SERVER BUL"
			end

			serverButton:SetAttribute("Busy", false)
			return
		end

		serverButton.Text = "✓ SERVER BULUNDU"

		local ok, teleportError = pcall(function()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				serverId,
				player
			)
		end)

		if not ok then
			warn("[HamsterMetro] Teleport hatasi: " .. tostring(teleportError))
			serverButton.Text = "TELEPORT BASARISIZ"

			task.wait(1.2)

			if serverButton.Parent then
				serverButton.Text = "👤 1 KISILIK SERVER BUL"
			end
		end

		serverButton:SetAttribute("Busy", false)
	end)
end)

-- =========================================================
-- ANTIKILL (local - kendi Studio)
-- =========================================================

local function bindAntikill(humanoid)
	if not humanoid then return end
	table.insert(humanoidConns, humanoid.HealthChanged:Connect(function(h)
		if antikillEnabled and h <= 0 then
			pcall(function()
				pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
			end)
		elseif antikillEnabled and h < humanoid.MaxHealth * 0.15 then
			pcall(function()
				pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
			end)
		end
	end))
	table.insert(humanoidConns, humanoid.Died:Connect(function()
		if antikillEnabled then
			task.defer(function()
				if humanoid and humanoid.Parent then
					pcall(function()
				pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
			end)
				end
			end)
		end
	end))
end

antikillButton.Activated:Connect(function()
	antikillEnabled = not antikillEnabled
	antikillButton.Text = antikillEnabled and "❤ ANTIKILL : AKTIF" or "❤ ANTIKILL : KAPALI"
	if antikillEnabled then
		local _, humanoid = getCharacter()
		if humanoid then
			pcall(function()
				pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
			end)
		end
	end
end)

-- =========================================================
-- EGG LOCK + hizli al (E)
-- =========================================================

eggLockButton.Activated:Connect(function()
	eggLockEnabled = not eggLockEnabled
	eggLockButton.Text = eggLockEnabled and "🥚 EGG LOCK : AKTIF" or "🥚 EGG LOCK : KAPALI"
	if eggLockEnabled then
		local character = player.Character
		local tool = character and findEggTool(character)
		if not tool then
			tool = findEggTool(player:FindFirstChild("Backpack"))
		end
		if tool then
			lockedEggTool = tool
			-- Elde tut
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and tool.Parent ~= character then
				pcall(function() humanoid:EquipTool(tool) end)
			end
		end
	else
		lockedEggTool = nil
	end
end)

local function tryPickupNearestEgg()
	local character, humanoid, root = getCharacter()
	if not root or not humanoid then return end

	local best, bestDist
	-- Workspace'te Tool veya egg isimli BasePart
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Tool") and isEggName(obj.Name) and obj.Parent ~= character and obj.Parent ~= player.Backpack then
			local h = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
			if h then
				local d = (h.Position - root.Position).Magnitude
				if d <= EGG_PICK_RANGE and (not bestDist or d < bestDist) then
					best, bestDist = obj, d
				end
			end
		elseif obj:IsA("BasePart") and isEggName(obj.Name) and not obj:IsDescendantOf(character) then
			local d = (obj.Position - root.Position).Magnitude
			if d <= EGG_PICK_RANGE and (not bestDist or d < bestDist) then
				best, bestDist = obj, d
			end
		end
	end

	if not best then return end

	if best:IsA("Tool") then
		pcall(function()
			best.Parent = character
			humanoid:EquipTool(best)
			if eggLockEnabled then lockedEggTool = best end
		end)
	elseif best:IsA("BasePart") then
		-- Part ise basit Tool'a sar (Studio demo)
		pcall(function()
			local tool = Instance.new("Tool")
			tool.Name = best.Name
			tool.RequiresHandle = true
			best.Name = "Handle"
			best.Parent = tool
			best.Anchored = false
			best.CanCollide = false
			tool.Parent = character
			humanoid:EquipTool(tool)
			if eggLockEnabled then lockedEggTool = tool end
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.E then
		tryPickupNearestEgg()
	end
end)

-- Egg lock: dusmesin, elde kalsin
local function maintainEggLock()
	if not eggLockEnabled then return end
	local character, humanoid = getCharacter()
	if not character or not humanoid then return end

	-- Once elde / backpack'te egg var mi
	local inChar = findEggTool(character)
	local inBag = findEggTool(player:FindFirstChild("Backpack"))

	if lockedEggTool and lockedEggTool.Parent == nil then
		-- Yok oldu / dustu - yakininda ara, aninda al
		tryPickupNearestEgg()
		lockedEggTool = findEggTool(character) or findEggTool(player:FindFirstChild("Backpack"))
	end

	local tool = inChar or inBag or lockedEggTool
	if tool and tool:IsA("Tool") then
		lockedEggTool = tool
		if tool.Parent ~= character then
			pcall(function()
				tool.Parent = character
				humanoid:EquipTool(tool)
			end)
		end
		-- CanBeDropped kapat (local)
		pcall(function() tool.CanBeDropped = false end)
	end
end

-- =========================================================
-- ANTI-KNOCK / AYAKTA KAL
-- =========================================================

antiKnockButton.Activated:Connect(function()
	antiKnockEnabled = not antiKnockEnabled
	antiKnockButton.Text = antiKnockEnabled and "🛡 AYAKTA KAL : AKTIF" or "🛡 AYAKTA KAL : KAPALI"
end)

local function maintainAntiKnock(humanoid, root)
	if not antiKnockEnabled or not humanoid or not root then return end

	-- Dusme / platform standing / flying durumlarini kes
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.Physics
		or state == Enum.HumanoidStateType.Freefall then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end

	-- Asiri velocity (vurulma itmesi) sifirla - ayakta kal
	local v = root.AssemblyLinearVelocity
	if math.abs(v.X) > 28 or math.abs(v.Z) > 28 or v.Y > 40 then
		root.AssemblyLinearVelocity = Vector3.new(0, math.min(v.Y, 12), 0)
	end
	root.AssemblyAngularVelocity = Vector3.zero

	-- PlatformStand / Sit zorla acildiysa kapat (vurulma)
	if humanoid.PlatformStand then
		humanoid.PlatformStand = false
	end
end

local function bindStateGuard(humanoid)
	if not humanoid then return end
	table.insert(humanoidConns, humanoid.StateChanged:Connect(function(_, new)
		if not antiKnockEnabled then return end
		if new == Enum.HumanoidStateType.FallingDown
			or new == Enum.HumanoidStateType.Ragdoll
			or new == Enum.HumanoidStateType.Physics then
			task.defer(function()
				if humanoid and humanoid.Parent and antiKnockEnabled then
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
					humanoid.PlatformStand = false
				end
			end)
		end
	end))
end

-- =========================================================
-- UPDATE
-- =========================================================

RunService.RenderStepped:Connect(function(dt)
	local character, humanoid, root = getCharacter()
	if not root then return end

	local camera = workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or root.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude > 0.05 then
		flatLook = flatLook.Unit
	else
		flatLook = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if flatLook.Magnitude > 0.05 then flatLook = flatLook.Unit end
	end

	if metroEnabled then
		metroDirection = flatLook
		root.CFrame = root.CFrame + metroDirection * METRO_SPEED * dt
		if seat and seat.Parent then
			seat.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
		end
	end

	if wallEnabled and wall and wall.Parent then
		local behind = root.Position - flatLook * 5
		wall.CFrame = CFrame.lookAt(behind, behind + flatLook)
		root.CFrame = root.CFrame + flatLook * WALL_PUSH * dt
		if seat and seat.Parent and not metroEnabled then
			seat.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
		end
	end

	if proneEnabled and humanoid then
		pcall(function() humanoid.HipHeight = 0.1 end)
		local ray = workspace:Raycast(root.Position + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0))
		if ray then
			local targetY = ray.Position.Y + 1.0
			if root.Position.Y > targetY + 0.4 then
				root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
					* (root.CFrame - root.CFrame.Position)
			end
		end
	end

	if antikillEnabled and humanoid and humanoid.Health <= 1 then
		pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
	end

	maintainEggLock()
	maintainAntiKnock(humanoid, root)
end)

-- =========================================================
-- CHARACTER BIND
-- =========================================================

local function onCharacter(character)
	clearHumanoidConns()
	metroEnabled = false
	metroDirection = nil
	wallEnabled = false
	proneEnabled = false
	-- antikill / egg / antiknock tercihleri kalir
	if seat then seat:Destroy(); seat = nil end
	if wall then wall:Destroy(); wall = nil end
	metroButton.Text = "🚇 METRO : KAPALI"
	wallButton.Text = "🧱 WALL : KAPALI"
	proneButton.Text = "⬇ IN (YERE) : KAPALI"

	local humanoid = character:WaitForChild("Humanoid", 8)
	if humanoid then
		bindAntikill(humanoid)
		bindStateGuard(humanoid)
		if antikillEnabled then
			pcall(function()
				pcall(function()
			humanoid.Health = humanoid.MaxHealth
		end)
			end)
		end
	end

	-- Tool elde gelince egg lock
	character.ChildAdded:Connect(function(ch)
		if eggLockEnabled and ch:IsA("Tool") and isEggName(ch.Name) then
			lockedEggTool = ch
			pcall(function() ch.CanBeDropped = false end)
		end
	end)
end

if player.Character then
	task.spawn(onCharacter, player.Character)
end
player.CharacterAdded:Connect(onCharacter)

-- =========================================================
-- MENU ANIM
-- =========================================================

local open = false
local function setMenu(value)
	open = value
	local target = open and UDim2.new(1, -455, 0.5, -280) or UDim2.new(1, 20, 0.5, -280)
	TweenService:Create(menu, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
end

toggle.Activated:Connect(function() setMenu(not open) end)
trash.Activated:Connect(function() setMenu(false) end)

print("[HamsterMetro] Safe v3 - Antikill / EggLock / AyaktaKal")
