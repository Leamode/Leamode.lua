-- HAMSTERLİVES v15 (Bypass içte uyumlu)
-- PART 1/2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HL = {
	Fly = false,
	Speed = 18,
	Saved = nil,
	Noclip = false,
	God = false,
	Cube = false,
	AutoEgg = false,
	IsMobile = false,
	ModeSelected = false,
	HoldPos = nil,
	HoldUntil = 0,
	PullTarget = nil,
	PullActive = false,
	LocalCube = nil,
	OscTimer = 0,
	Conn = {}
}

-- ==================== BYPASS (içte) ====================
local Bypass = {
	Active = false,
	FakeGroundY = nil,
	LastSafePosition = nil,
	CachedGroundY = nil,
	GroundCacheTime = 0,
	GroundCacheTTL = 1.2,
}

local function FindGroundY(pos)
	local now = os.clock()
	if Bypass.CachedGroundY and (now - Bypass.GroundCacheTime) < Bypass.GroundCacheTTL then
		return Bypass.CachedGroundY
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	if LocalPlayer.Character then
		params.FilterDescendantsInstances = {LocalPlayer.Character}
	end
	local result = workspace:Raycast(pos + Vector3.new(0, 25, 0), Vector3.new(0, -250, 0), params)
	if result then
		Bypass.CachedGroundY = result.Position.Y + 3.2
		Bypass.GroundCacheTime = now
		return Bypass.CachedGroundY
	end
	return pos.Y - 8
end

local function StartBypass()
	if Bypass.Active then return end
	Bypass.Active = true

	-- Pozisyon spoof (hafif)
	task.spawn(function()
		while Bypass.Active do
			task.wait(0.18)
			local char = LocalPlayer.Character
			if not char then continue end
			local root = char:FindFirstChild("HumanoidRootPart")
			if not root then continue end

			Bypass.LastSafePosition = root.Position

			if root.Position.Y > 18 then
				local gy = Bypass.FakeGroundY or FindGroundY(root.Position)
				Bypass.FakeGroundY = gy
				local fake = Vector3.new(root.Position.X, gy, root.Position.Z)
				pcall(function()
					local real = root.CFrame
					root.CFrame = CFrame.new(fake)
					root.AssemblyLinearVelocity = Vector3.zero
					task.wait()
					root.CFrame = real
				end)
			else
				Bypass.FakeGroundY = root.Position.Y
			end
		end
	end)

	-- State + health koruması
	task.spawn(function()
		while Bypass.Active do
			task.wait(0.35)
			local char = LocalPlayer.Character
			if not char then continue end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then continue end
			pcall(function()
				if hum:GetState() == Enum.HumanoidStateType.Freefall and not HL.Fly then
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end
				if hum.Health <= 0 then
					hum.Health = hum.MaxHealth
				end
			end)
		end
	end)

	print("[HL] Bypass v2 içte aktif")
end

-- ==================== ANA SİSTEM ====================
local function ProtectLoop()
	if HL.Conn.Protect then return end
	HL.Conn.Protect = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if HL.God or hum.Health < hum.MaxHealth * 0.9 then
			hum.Health = hum.MaxHealth
		end
		if hum:GetState() == Enum.HumanoidStateType.Dead then
			hum.Health = hum.MaxHealth
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end
		if not root:IsDescendantOf(workspace) then
			pcall(function() root.Parent = char end)
		end
		if HL.HoldPos and os.clock() < HL.HoldUntil then
			root.CFrame = CFrame.new(HL.HoldPos)
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end)
end

local function DestroyCube()
	if HL.LocalCube then
		pcall(function() HL.LocalCube:Destroy() end)
		HL.LocalCube = nil
	end
end

local function UpdateCube()
	if not HL.Cube then
		DestroyCube()
		return
	end
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local moving = hum.MoveDirection.Magnitude > 0.05
	local air = hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall

	if not HL.LocalCube then
		local p = Instance.new("Part")
		p.Name = "HL_Cube"
		p.Size = Vector3.new(4, 1, 4)
		p.Anchored = true
		p.CanCollide = true
		p.Transparency = 0.9
		p.Color = Color3.fromRGB(80, 80, 120)
		p.Parent = workspace
		HL.LocalCube = p
	end

	if moving or air or HL.Fly then
		HL.LocalCube.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3, root.Position.Z)
		HL.LocalCube.CanCollide = true
	else
		HL.LocalCube.CanCollide = false
	end
end

local function ToggleCube()
	HL.Cube = not HL.Cube
	local b = HL.Buttons and HL.Buttons.Cube
	if b then
		b.Text = HL.Cube and "CUBE  ● AÇIK" or "CUBE  ○ KAPALI"
		b.BackgroundColor3 = HL.Cube and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if not HL.Cube then DestroyCube() end
end

local function StopFly()
	if HL.Conn.Fly then
		HL.Conn.Fly:Disconnect()
		HL.Conn.Fly = nil
	end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
end

local function StartFly()
	StopFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
	HL.OscTimer = 0

	HL.Conn.Fly = RunService.RenderStepped:Connect(function(dt)
		if not HL.Fly then return end
		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not r or not h then return end

		pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end)

		local cf = Camera.CFrame
		local move = Vector3.zero

		if HL.IsMobile then
			local touches = UserInputService:GetTouches()
			if #touches > 0 then
				local t = touches[1]
				local size = Camera.ViewportSize
				local dx = (t.Position.X - size.X/2) / (size.X/2)
				local dy = (t.Position.Y - size.Y/2) / (size.Y/2)
				if math.abs(dx) > 0.1 or math.abs(dy) > 0.1 then
					move = cf.LookVector * (-dy) + cf.RightVector * dx
				end
			end
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end
		end

		local speed = HL.Speed * 1.8
		if move.Magnitude > 0 then move = move.Unit * speed end

		HL.OscTimer = HL.OscTimer + dt
		local osc = math.sin(HL.OscTimer * 2.5) * 0.25
		local newPos = r.Position + move * dt + Vector3.new(0, osc * dt * 5, 0)
		r.CFrame = CFrame.new(newPos, newPos + cf.LookVector)
		r.AssemblyLinearVelocity = Vector3.new(0, -0.8, 0)
	end)
end

local function ToggleFly()
	HL.Fly = not HL.Fly
	local b = HL.Buttons and HL.Buttons.Fly
	if b then
		b.Text = HL.Fly and "FLY  ● AÇIK" or "FLY  ○ KAPALI"
		b.BackgroundColor3 = HL.Fly and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if HL.Fly then StartFly() else StopFly() end
end

local function StopPull()
	HL.PullActive = false
	HL.PullTarget = nil
	if HL.Conn.Pull then
		HL.Conn.Pull:Disconnect()
		HL.Conn.Pull = nil
	end
end

local function StartPull(targetPos)
	StopPull()
	HL.PullTarget = targetPos
	HL.PullActive = true

	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local startTime = os.clock()

	HL.Conn.Pull = RunService.Heartbeat:Connect(function(dt)
		if not HL.PullActive or not HL.PullTarget then return end
		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not r or not h then StopPull() return end

		local currentSpeed = math.max(h.WalkSpeed, 16)
		local dir = HL.PullTarget - r.Position
		local dist = dir.Magnitude

		if dist < 4 then
			r.CFrame = CFrame.new(HL.PullTarget)
			r.AssemblyLinearVelocity = Vector3.zero
			StopPull()
			HL.HoldPos = HL.PullTarget
			HL.HoldUntil = os.clock() + 2.5
			return
		end

		local targetY = r.Position.Y
		local ray = workspace:Raycast(r.Position + Vector3.new(0, 3, 0), Vector3.new(0, -15, 0))
		if ray then targetY = ray.Position.Y + 3 end

		local flat = Vector3.new(dir.X, 0, dir.Z)
		if flat.Magnitude < 0.1 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
		local right = Vector3.new(-flat.Z, 0, flat.X)
		local sway = right * math.sin(os.clock() - startTime) * 1.5
		local moveDir = (flat + sway * 0.3).Unit

		local newPos = r.Position + moveDir * currentSpeed * 0.9 * dt
		newPos = Vector3.new(newPos.X, targetY, newPos.Z)
		r.CFrame = CFrame.new(newPos, newPos + moveDir)
		r.AssemblyLinearVelocity = Vector3.zero
		pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
	end)
end

local function SavePos()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	HL.Saved = root.Position
	local b = HL.Buttons and HL.Buttons.Save
	if b then
		b.Text = "KAYDEDİLDİ ✓"
		b.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
		task.delay(1.2, function()
			if b then
				b.Text = "YER BELİLE"
				b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			end
		end)
	end
end

local function TP()
	if HL.Saved then
		if HL.Fly then HL.Fly = false StopFly() end
		StartPull(HL.Saved)
	end
end

local function FindBestEgg()
	local best, bestScore = nil, -1
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			local name = string.lower(obj.Name)
			if string.find(name, "egg") or string.find(name, "yumurta") then
				local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
				local size = obj:IsA("BasePart") and obj.Size.Magnitude or 5
				local score = size * 8 - (pos - root.Position).Magnitude * 0.1
				if score > bestScore then bestScore = score best = pos end
			end
		end
	end
	return best
end

local function ToggleAutoEgg()
	HL.AutoEgg = not HL.AutoEgg
	local b = HL.Buttons and HL.Buttons.AutoEgg
	if b then
		b.Text = HL.AutoEgg and "AUTO EGG  ●" or "AUTO EGG  ○"
		b.BackgroundColor3 = HL.AutoEgg and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if HL.AutoEgg then
		if HL.Conn.AutoEgg then HL.Conn.AutoEgg:Disconnect() end
		HL.Conn.AutoEgg = RunService.Heartbeat:Connect(function()
			if not HL.AutoEgg or HL.PullActive then return end
			local t = FindBestEgg()
			if t then StartPull(t) end
		end)
	else
		if HL.Conn.AutoEgg then HL.Conn.AutoEgg:Disconnect() HL.Conn.AutoEgg = nil end
		StopPull()
	end
end

local function ToggleNoclip()
	HL.Noclip = not HL.Noclip
	local b = HL.Buttons and HL.Buttons.Noclip
	if b then
		b.Text = HL.Noclip and "NOCLIP  ● AÇIK" or "NOCLIP  ○ KAPALI"
		b.BackgroundColor3 = HL.Noclip and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if HL.Noclip then
		if HL.Conn.Noclip then HL.Conn.Noclip:Disconnect() end
		HL.Conn.Noclip = RunService.Stepped:Connect(function()
			if not HL.Noclip then return end
			local char = LocalPlayer.Character
			if not char then return end
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		if HL.Conn.Noclip then HL.Conn.Noclip:Disconnect() HL.Conn.Noclip = nil end
	end
end

local function ToggleGod()
	HL.God = not HL.God
	local b = HL.Buttons and HL.Buttons.God
	if b then
		b.Text = HL.God and "ANTİ-YAKALANMA  ●" or "ANTİ-YAKALANMA  ○"
		b.BackgroundColor3 = HL.God and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
end

HL.Conn.Cube = RunService.Heartbeat:Connect(UpdateCube)
ProtectLoop()
StartBypass() -- Bypass burada, sistemle birlikte başlıyor

print("[HL] Part 1 hazır")-- PART 2/2

local function CreateMainMenu()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
	if not playerGui then return end

	local old = playerGui:FindFirstChild("HamsterLiveGUI")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "HamsterLiveGUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 240, 0, 430)
	main.Position = UDim2.new(0.5, -120, 0.5, -120)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(140, 0, 255)
	stroke.Thickness = 2

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
	title.BorderSizePixel = 0
	title.Text = "  HAMSTERLİVES  v15"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

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
		b.Size = UDim2.new(1, -20, 0, 32)
		b.Position = UDim2.new(0, 10, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(240, 240, 240)
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 13
		b.Parent = main
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(callback)
		return b
	end

	HL.Buttons = {}
	HL.Buttons.Fly     = makeBtn("FLY  ○ KAPALI", 50, ToggleFly)
	HL.Buttons.Save    = makeBtn("YER BELİLE", 88, SavePos)
	HL.Buttons.TP      = makeBtn("TP ET", 126, TP)
	HL.Buttons.Noclip  = makeBtn("NOCLIP  ○ KAPALI", 164, ToggleNoclip)
	HL.Buttons.God     = makeBtn("ANTİ-YAKALANMA  ○", 202, ToggleGod)
	HL.Buttons.Cube    = makeBtn("CUBE  ○ KAPALI", 240, ToggleCube)
	HL.Buttons.AutoEgg = makeBtn("AUTO EGG  ○", 278, ToggleAutoEgg)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 0, 30)
	box.Position = UDim2.new(0, 10, 0, 320)
	box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	box.BorderSizePixel = 0
	box.Text = "Hız: 18"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.Parent = main
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
	box.FocusLost:Connect(function()
		local n = tonumber(string.match(box.Text, "%d+"))
		if n and n >= 10 and n <= 40 then
			HL.Speed = n
			box.Text = "Hız: " .. n
		else
			box.Text = "Hız: " .. HL.Speed
		end
	end)

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Position = UDim2.new(1, -34, 0, 6)
	close.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.Parent = main
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
	close.MouseButton1Click:Connect(function() main.Visible = false end)

	local open = Instance.new("TextButton")
	open.Size = UDim2.new(0, 50, 0, 50)
	open.Position = UDim2.new(1, -65, 0, 20)
	open.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
	open.Text = "HL"
	open.TextColor3 = Color3.fromRGB(255, 255, 255)
	open.Font = Enum.Font.GothamBold
	open.TextSize = 16
	open.Parent = gui
	Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)
	open.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
end

local function CreateStartScreen()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
	if not playerGui then return end
	local old = playerGui:FindFirstChild("HL_Start")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "HL_Start"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0.3, 0)
	title.BackgroundTransparency = 1
	title.Text = "HAMSTERLİVES"
	title.TextColor3 = Color3.fromRGB(180, 0, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 30)
	sub.Position = UDim2.new(0, 0, 0.38, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "Cihazını seç"
	sub.TextColor3 = Color3.fromRGB(200, 200, 200)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 16
	sub.Parent = bg

	local function makeChoice(text, x)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 150, 0, 50)
		btn.Position = UDim2.new(0.5, x, 0.5, -10)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 18
		btn.Parent = bg
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
		return btn
	end

	local pcBtn = makeChoice("PC", -170)
	local mobBtn = makeChoice("MOBİL", 20)

	local function select(isMobile)
		HL.IsMobile = isMobile
		HL.ModeSelected = true
		gui:Destroy()
		CreateMainMenu()
	end

	pcBtn.MouseButton1Click:Connect(function() select(false) end)
	mobBtn.MouseButton1Click:Connect(function() select(true) end)
end

CreateStartScreen()

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp or not HL.ModeSelected then return end
	if inp.KeyCode == Enum.KeyCode.F8 then ToggleFly()
	elseif inp.KeyCode == Enum.KeyCode.F4 then SavePos()
	elseif inp.KeyCode == Enum.KeyCode.F5 then TP()
	elseif inp.KeyCode == Enum.KeyCode.F6 then ToggleNoclip()
	elseif inp.KeyCode == Enum.KeyCode.F7 then ToggleGod()
	elseif inp.KeyCode == Enum.KeyCode.F9 then ToggleCube()
	elseif inp.KeyCode == Enum.KeyCode.F10 then ToggleAutoEgg()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1.2)
	if HL.Fly then StartFly() end
	-- Bypass karakter değişince devam etsin diye
	if not Bypass.Active then StartBypass() end
end)

print("[HL] v15 yüklendi - Bypass içte uyumlu")
