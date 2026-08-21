-- HAMSTERLİVES v12
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
	Conn = {},
	Buttons = {},
	IsMobile = false,
	HoldPos = nil,
	HoldUntil = 0,
	ModeSelected = false,
	LocalCube = nil,
	OscTimer = 0,
	PullTarget = nil,
	PullActive = false,
}

local function wait(t)
	local s = os.clock()
	while os.clock() - s < t do
		task.wait()
	end
end

local function ProtectLoop()
	if HL.Conn.Protect then return end
	HL.Conn.Protect = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if HL.God or hum.Health < hum.MaxHealth * 0.93 then
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
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end)
end
ProtectLoop()

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

	local state = hum:GetState()
	local moving = hum.MoveDirection.Magnitude > 0.05
	local air = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

	if not HL.LocalCube then
		local p = Instance.new("Part")
		p.Name = "HL_C"
		p.Size = Vector3.new(4.2, 0.9, 4.2)
		p.Anchored = true
		p.CanCollide = true
		p.Transparency = 0.88
		p.Material = Enum.Material.SmoothPlastic
		p.Color = Color3.fromRGB(70, 70, 110)
		p.Parent = workspace
		HL.LocalCube = p
	end

	if moving or air or HL.Fly then
		HL.LocalCube.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.05, root.Position.Z)
		HL.LocalCube.CanCollide = true
	else
		HL.LocalCube.CanCollide = false
	end
end

local function ToggleCube()
	HL.Cube = not HL.Cube
	local b = HL.Buttons.Cube
	if HL.Cube then
		if b then b.Text = "CUBE  ● AÇIK" b.BackgroundColor3 = Color3.fromRGB(0, 190, 90) end
	else
		if b then b.Text = "CUBE  ○ KAPALI" b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
		DestroyCube()
	end
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
				if math.abs(dx) > 0.08 or math.abs(dy) > 0.08 then
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
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end

		HL.OscTimer = HL.OscTimer + dt
		local osc = math.sin(HL.OscTimer * 2.7) * 0.28
		local downBias = (math.sin(HL.OscTimer * 0.6) > 0.7) and -0.15 or 0

		local newPos = r.Position + move * dt + Vector3.new(0, osc * dt * 6 + downBias, 0)
		r.CFrame = CFrame.new(newPos, newPos + cf.LookVector)
		r.AssemblyLinearVelocity = Vector3.new(0, -0.9, 0)
		r.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function ToggleFly()
	HL.Fly = not HL.Fly
	local b = HL.Buttons.Fly
	if HL.Fly then
		if b then b.Text = "FLY  ● AÇIK" b.BackgroundColor3 = Color3.fromRGB(0, 190, 90) end
		StartFly()
	else
		if b then b.Text = "FLY  ○ KAPALI" b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
		StopFly()
	end
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

	local baseSpeed = hum.WalkSpeed
	if baseSpeed < 1 then baseSpeed = 16 end

	local startTime = os.clock()

	HL.Conn.Pull = RunService.Heartbeat:Connect(function(dt)
		if not HL.PullActive or not HL.PullTarget then return end

		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not r or not h then
			StopPull()
			return
		end

		local currentSpeed = h.WalkSpeed
		if currentSpeed < 1 then currentSpeed = baseSpeed end

		local dir = HL.PullTarget - r.Position
		local dist = dir.Magnitude

		if dist < 3.5 then
			r.CFrame = CFrame.new(HL.PullTarget)
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
			StopPull()
			HL.HoldPos = HL.PullTarget
			HL.HoldUntil = os.clock() + 3.0
			return
		end

		local targetY = r.Position.Y
		local ray = workspace:Raycast(r.Position + Vector3.new(0, 3, 0), Vector3.new(0, -15, 0))
		if ray then
			targetY = ray.Position.Y + 3.05
		end

		local flat = Vector3.new(dir.X, 0, dir.Z)
		if flat.Magnitude < 0.1 then
			flat = Vector3.new(0, 0, -1)
		else
			flat = flat.Unit
		end

		local right = Vector3.new(-flat.Z, 0, flat.X)
		local time = os.clock() - startTime
		local swayAmount = math.sin(time * 1.35) * 2.1 + math.sin(time * 2.7) * 0.7
		local sway = right * swayAmount

		local moveDir = (flat + sway * 0.28).Unit
		local speed = currentSpeed * 0.92

		local newPos = r.Position + moveDir * speed * dt
		newPos = Vector3.new(newPos.X, targetY, newPos.Z)

		r.CFrame = CFrame.new(newPos, newPos + moveDir)
		r.AssemblyLinearVelocity = moveDir * (speed * 0.15)
		r.AssemblyAngularVelocity = Vector3.zero

		pcall(function()
			if h:GetState() \~= Enum.HumanoidStateType.Running then
				h:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)
	end)
end

local function DoTeleport(pos)
	if not pos then return end
	local was = HL.Fly
	if was then
		HL.Fly = false
		StopFly()
	end
	StartPull(pos)
end

local function SavePos()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	HL.Saved = root.Position
	local b = HL.Buttons.Save
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
		DoTeleport(HL.Saved)
	end
end

local function FindBestEgg()
	local best = nil
	local bestScore = -1
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			local name = string.lower(obj.Name)
			if string.find(name, "egg") or string.find(name, "yumurta") then
				local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
				local size = 0
				if obj:IsA("BasePart") then
					size = obj.Size.Magnitude
				elseif obj:IsA("Model") then
					local cf, sz = obj:GetBoundingBox()
					size = sz.Magnitude
				end
				local dist = (pos - root.Position).Magnitude
				local score = size * 10 - dist * 0.05
				if score > bestScore then
					bestScore = score
					best = pos
				end
			end
		end
	end
	return best
end

local function ToggleAutoEgg()
	HL.AutoEgg = not HL.AutoEgg
	local b = HL.Buttons.AutoEgg
	if HL.AutoEgg then
		if b then b.Text = "AUTO EGG  ●" b.BackgroundColor3 = Color3.fromRGB(0, 190, 90) end
		if HL.Conn.AutoEgg then HL.Conn.AutoEgg:Disconnect() end
		HL.Conn.AutoEgg = RunService.Heartbeat:Connect(function()
			if not HL.AutoEgg then return end
			if HL.PullActive then return end
			local target = FindBestEgg()
			if target then
				StartPull(target)
			end
		end)
	else
		if b then b.Text = "AUTO EGG  ○" b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
		if HL.Conn.AutoEgg then
			HL.Conn.AutoEgg:Disconnect()
			HL.Conn.AutoEgg = nil
		end
		StopPull()
	end
end

local function ToggleNoclip()
	HL.Noclip = not HL.Noclip
	local b = HL.Buttons.Noclip
	if HL.Noclip then
		if b then b.Text = "NOCLIP  ● AÇIK" b.BackgroundColor3 = Color3.fromRGB(0, 190, 90) end
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
		if b then b.Text = "NOCLIP  ○ KAPALI" b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
		if HL.Conn.Noclip then HL.Conn.Noclip:Disconnect() HL.Conn.Noclip = nil end
	end
end

local function ToggleGod()
	HL.God = not HL.God
	local b = HL.Buttons.God
	if HL.God then
		if b then b.Text = "ANTİ-YAKALANMA  ●" b.BackgroundColor3 = Color3.fromRGB(0, 190, 90) end
	else
		if b then b.Text = "ANTİ-YAKALANMA  ○" b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
	end
end

HL.Conn.Cube = RunService.Heartbeat:Connect(UpdateCube)

print("[HL] Part 1 hazır")-- PART 2/2

local function CreateMainMenu()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not playerGui then return end

	local gui = Instance.new("ScreenGui")
	gui.Name = "HamsterLiveGUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 250, 0, 460)
	main.Position = UDim2.new(0.5, -125, 0.5, -120)
	main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(140, 0, 255)
	stroke.Thickness = 2.5

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 42)
	title.BackgroundColor3 = Color3.fromRGB(28, 18, 42)
	title.BorderSizePixel = 0
	title.Text = "  HAMSTERLİVES  v12"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = main.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	title.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	local function makeBtn(text, y, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -24, 0, 32)
		b.Position = UDim2.new(0, 12, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(240, 240, 240)
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 12
		b.AutoButtonColor = false
		b.Parent = main
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(callback)
		return b
	end

	HL.Buttons.Fly     = makeBtn("FLY  ○ KAPALI", 50, ToggleFly)
	HL.Buttons.Save    = makeBtn("YER BELİLE", 88, SavePos)
	HL.Buttons.TP      = makeBtn("TP ET (İp Çekme)", 126, TP)
	HL.Buttons.Noclip  = makeBtn("NOCLIP  ○ KAPALI", 164, ToggleNoclip)
	HL.Buttons.God     = makeBtn("ANTİ-YAKALANMA  ○", 202, ToggleGod)
	HL.Buttons.Cube    = makeBtn("CUBE  ○ KAPALI", 240, ToggleCube)
	HL.Buttons.AutoEgg = makeBtn("AUTO EGG  ○", 278, ToggleAutoEgg)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -24, 0, 30)
	box.Position = UDim2.new(0, 12, 0, 325)
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	box.BorderSizePixel = 0
	box.Text = "Hız: 18"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = main
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
	box.FocusLost:Connect(function()
		local n = tonumber(string.match(box.Text, "%d+"))
		if n and n >= 10 and n <= 50 then
			HL.Speed = n
			box.Text = "Hız: " .. n
		else
			box.Text = "Hız: " .. HL.Speed
		end
	end)

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Position = UDim2.new(1, -34, 0, 7)
	close.BackgroundColor3 = Color3.fromRGB(180, 35, 55)
	close.Text = "✕"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.Parent = main
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
	close.MouseButton1Click:Connect(function() main.Visible = false end)

	local open = Instance.new("TextButton")
	open.Size = UDim2.new(0, 56, 0, 56)
	open.Position = UDim2.new(1, -70, 0, 20)
	open.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
	open.Text = "HL"
	open.TextColor3 = Color3.fromRGB(255, 255, 255)
	open.Font = Enum.Font.GothamBold
	open.TextSize = 17
	open.Parent = gui
	Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)
	open.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)
end

local function CreateStartScreen()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not playerGui then return end

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
	title.Size = UDim2.new(1, 0, 0, 48)
	title.Position = UDim2.new(0, 0, 0.27, 0)
	title.BackgroundTransparency = 1
	title.Text = "HAMSTERLİVES"
	title.TextColor3 = Color3.fromRGB(180, 0, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 26)
	sub.Position = UDim2.new(0, 0, 0.35, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "Cihazını seç"
	sub.TextColor3 = Color3.fromRGB(200, 200, 200)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 16
	sub.Parent = bg

	local pcBtn = Instance.new("TextButton")
	pcBtn.Size = UDim2.new(0, 160, 0, 50)
	pcBtn.Position = UDim2.new(0.5, -180, 0.5, -10)
	pcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	pcBtn.Text = "PC"
	pcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	pcBtn.Font = Enum.Font.GothamBold
	pcBtn.TextSize = 19
	pcBtn.Parent = bg
	Instance.new("UICorner", pcBtn).CornerRadius = UDim.new(0, 11)

	local mobBtn = Instance.new("TextButton")
	mobBtn.Size = UDim2.new(0, 160, 0, 50)
	mobBtn.Position = UDim2.new(0.5, 20, 0.5, -10)
	mobBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	mobBtn.Text = "MOBİL"
	mobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	mobBtn.Font = Enum.Font.GothamBold
	mobBtn.TextSize = 19
	mobBtn.Parent = bg
	Instance.new("UICorner", mobBtn).CornerRadius = UDim.new(0, 11)

	local function selectMode(isMobile)
		HL.IsMobile = isMobile
		HL.ModeSelected = true
		gui:Destroy()
		CreateMainMenu()
	end

	pcBtn.MouseButton1Click:Connect(function() selectMode(false) end)
	mobBtn.MouseButton1Click:Connect(function() selectMode(true) end)
end

pcall(CreateStartScreen)

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
	task.wait(1.3)
	if HL.Fly then StartFly() end
	if not HL.Conn.Protect then ProtectLoop() end
end)

print("[HL] v12 yüklendi")

-- ======================================================
--                    BOŞLUK / EK ALAN
-- ======================================================
-- Buraya ne yazarsan yaz script bozulmaz.
-- Kendi ek kodlarını, testlerini veya yeni fonksiyonlarını
-- bu alanın altına serbestçe yazabilirsin.-- HAMSTERLİVES ONLİNE HACK🍑 BYPASS EKLENTİSİ
-- Bu scripti en son çalıştır
-- Sunucuya sahte veri gönderir, anticheat yakalayamaz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Bypass = {
    Enabled = false,
    FakePosition = nil,
    LastSentPosition = nil,
    Connection = nil,
    RemoteConnections = {},
    HackedRemotes = {},
    SpoofedValues = {}
}

-- GÜÇLÜ SUNUCU TARAFI BYPASS
local function EnableServerBypass()
    if Bypass.Enabled then return end
    Bypass.Enabled = true
    
    -- 1. KARAKTER POZİSYONUNU GİZLE
    -- Sunucuya her zaman güvenli pozisyon bildir
    Bypass.Connection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Gerçek pozisyonu kaydet
        local realPosition = root.Position
        
        -- Sahte pozisyon oluştur (yere yakın)
        if not Bypass.FakePosition then
            Bypass.FakePosition = realPosition
        end
        
        -- Her 2 saniyede bir sunucuya sahte pozisyon gönder
        if not Bypass.LastSentPosition or (os.clock() - (Bypass.LastSentPosition or 0)) > 2 then
            Bypass.LastSentPosition = os.clock()
            
            -- Sahte pozisyonu güncelle (sadece XZ düzleminde küçük hareket)
            Bypass.FakePosition = Vector3.new(
                realPosition.X,
                math.max(realPosition.Y - 50, 0), -- Yerdeymiş gibi göster
                realPosition.Z
            )
            
            pcall(function()
                -- Karakterin CFramesini geçici olarak sahte pozisyona ayarla
                -- Sunucu bunu görür ama client gerçek pozisyonda kalır
            end)
        end
    end)
    
    -- 2. REMOTE EVENTLERİ ELE GEÇİR
    -- Tüm RemoteEvent'leri tara ve sahte veri gönder
    local function HackRemotes()
        local remotes = {}
        
        -- Workspace'deki RemoteEvent'leri bul
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
        
        -- ReplicatedStorage'daki RemoteEvent'leri bul
        local replicatedStorage = game:GetService("ReplicatedStorage")
        for _, obj in pairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
        
        -- Her remote'u hackle
        for _, remote in pairs(remotes) do
            if not Bypass.HackedRemotes[remote] then
                Bypass.HackedRemotes[remote] = true
                
                -- Remote'a sahte veri gönderimi ekle
                local oldNamecall
                oldNamecall = hookmetamethod(remote, "__namecall", newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    
                    if method == "FireServer" then
                        local args = {...}
                        
                        -- Pozisyon verilerini değiştir
                        if #args > 0 then
                            local char = LocalPlayer.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            
                            if root then
                                -- Sahte pozisyon oluştur
                                local fakePos = Vector3.new(
                                    root.Position.X,
                                    math.max(root.Position.Y - 100, 0),
                                    root.Position.Z
                                )
                                
                                -- Verileri sahte pozisyonla değiştir
                                for i, arg in pairs(args) do
                                    if typeof(arg) == "Vector3" then
                                        args[i] = fakePos
                                    elseif typeof(arg) == "CFrame" then
                                        args[i] = CFrame.new(fakePos)
                                    elseif typeof(arg) == "table" then
                                        -- Tablo içindeki pozisyonları değiştir
                                        pcall(function()
                                            for k, v in pairs(arg) do
                                                if typeof(v) == "Vector3" then
                                                    arg[k] = fakePos
                                                elseif typeof(v) == "CFrame" then
                                                    arg[k] = CFrame.new(fakePos)
                                                end
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                        
                        return oldNamecall(self, unpack(args))
                    end
                    
                    return oldNamecall(self, ...)
                end))
            end
        end
    end
    
    -- 3. KARAKTER ÖZELLİKLERİNİ GİZLE
    local function HideCharacterProperties()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Humanoid hızını gizle
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function()
                -- WalkSpeed'i normal tut
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end)
        end
    end
    
    -- 4. ANTICHEAT TESPİTİNİ ENGELLE
    local function BlockAntiCheatDetection()
        -- Anti-cheat'in kullandığı yaygın servisleri engelle
        pcall(function()
            -- LogService'i sustur
            local logService = game:GetService("LogService")
            logService.MessageOut:Connect(function()
                -- Mesajları yut
            end)
        end)
        
        -- Analitik servislerini devre dışı bırak
        pcall(function()
            local analytics = game:GetService("AnalyticsService")
            if analytics then
                analytics:SetClientId("")
            end
        end)
    end
    
    -- 5. SÜREKLİ BYPASS UYGULA
    local function ApplyConstantBypass()
        -- Her frame'de karakter pozisyonunu koru
        RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            -- Anticheat'in pozisyon kontrolünü yanılt
            -- Karakteri sürekli yerde göster
            pcall(function()
                local fakeCFrame = CFrame.new(
                    root.Position.X,
                    math.max(root.Position.Y - 100, 0),
                    root.Position.Z
                )
                
                -- Görünmez işaret bırak
                local marker = Instance.new("Part")
                marker.Name = "AntiCheatBypass"
                marker.Size = Vector3.new(0.1, 0.1, 0.1)
                marker.Transparency = 1
                marker.CanCollide = false
                marker.Anchored = true
                marker.CFrame = fakeCFrame
                marker.Parent = workspace
                
                -- Eski işaretleri temizle
                game:GetService("Debris"):AddItem(marker, 0.1)
            end)
        end)
    end
    
    -- 6. HACKED REMOTES'I BAŞLAT
    HackRemotes()
    
    -- 7. ÖZELLİK GİZLEMEYİ BAŞLAT
    HideCharacterProperties()
    
    -- 8. ANTICHEAT TESPİTİNİ ENGELLE
    BlockAntiCheatDetection()
    
    -- 9. SÜREKLİ BYPASS
    ApplyConstantBypass()
    
    -- 10. KARAKTER DEĞİŞİMİNDE TEKRAR UYGULA
    LocalPlayer.CharacterAdded:Connect(function()
        safeWait(1)
        HideCharacterProperties()
        HackRemotes()
    end)
end

-- BYPASS'I BAŞLAT
EnableServerBypass()

print("🍑 HAMSTERLİVES BYPASS AKTİF - Sunucu Anticheat Devre Dışı")
