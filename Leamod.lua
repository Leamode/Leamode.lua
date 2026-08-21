-- HAMSTERLİVES v8  |  Güçlü Bypass + Stabil Fly
-- PART 1/2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HL = {
	Fly = false,
	Speed = 85,
	Saved = nil,
	Noclip = false,
	God = false,
	Conn = {},
	Buttons = {},
	IsMobile = false,
	HoldPos = nil,
	HoldUntil = 0,
	ModeSelected = false,
}

local function wait(t)
	local s = os.clock()
	while os.clock() - s < t do
		task.wait()
	end
end

-------------------------------------------------
-- ANTİ RESET + ANTİ KİLL
-------------------------------------------------
local function ProtectLoop()
	if HL.Conn.Protect then return end

	HL.Conn.Protect = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end

		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if HL.God or hum.Health < hum.MaxHealth * 0.95 then
			hum.Health = hum.MaxHealth
		end

		if hum:GetState() == Enum.HumanoidStateType.Dead then
			hum.Health = hum.MaxHealth
			pcall(function()
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end

		if not root:IsDescendantOf(workspace) then
			pcall(function() root.Parent = char end)
		end

		-- TP kilidi (güçlü)
		if HL.HoldPos and os.clock() < HL.HoldUntil then
			root.CFrame = CFrame.new(HL.HoldPos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end)
end
ProtectLoop()

-------------------------------------------------
-- FLY (yüzme mantığı - stabil)
-------------------------------------------------
local function StopFly()
	if HL.Conn.Fly then
		HL.Conn.Fly:Disconnect()
		HL.Conn.Fly = nil
	end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end
end

local function StartFly()
	StopFly()

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	hum.PlatformStand = true
	pcall(function()
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end)

	HL.Conn.Fly = RunService.RenderStepped:Connect(function(dt)
		if not HL.Fly then return end

		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not r or not h then return end

		h.PlatformStand = true

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

		local speed = HL.Speed * 2.8
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end

		-- Yüzme gibi akıcı hareket
		local newPos = r.Position + move * dt
		r.CFrame = CFrame.new(newPos, newPos + cf.LookVector)
		r.AssemblyLinearVelocity = Vector3.zero
		r.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function ToggleFly()
	HL.Fly = not HL.Fly
	local b = HL.Buttons.Fly

	if HL.Fly then
		if b then
			b.Text = "FLY  ● AÇIK"
			b.BackgroundColor3 = Color3.fromRGB(0, 190, 90)
		end
		StartFly()
	else
		if b then
			b.Text = "FLY  ○ KAPALI"
			b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		end
		StopFly()
	end
end

-------------------------------------------------
-- GÜÇLÜ TP (Anti-Kick Bypass)
-------------------------------------------------
local function DoTeleport(pos)
	if not pos then return end

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local was = HL.Fly
	if was then
		HL.Fly = false
		StopFly()
	end

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local start = root.Position
	local distance = (pos - start).Magnitude
	local steps = math.clamp(math.floor(distance / 18), 8, 25)

	for i = 1, steps do
		local alpha = i / steps
		local mid = start:Lerp(pos, alpha)
		root.CFrame = CFrame.new(mid)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		wait(0.011)
	end

	-- Uzun kilit
	HL.HoldPos = pos
	HL.HoldUntil = os.clock() + 5.0

	for i = 1, 12 do
		root.CFrame = CFrame.new(pos)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		wait(0.008)
	end

	root.Anchored = true
	wait(0.3)
	root.Anchored = false
	root.CFrame = CFrame.new(pos)

	if was then
		HL.Fly = true
		StartFly()
	end
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

-------------------------------------------------
-- NOCLIP
-------------------------------------------------
local function ToggleNoclip()
	HL.Noclip = not HL.Noclip
	local b = HL.Buttons.Noclip

	if HL.Noclip then
		if b then
			b.Text = "NOCLIP  ● AÇIK"
			b.BackgroundColor3 = Color3.fromRGB(0, 190, 90)
		end
		if HL.Conn.Noclip then HL.Conn.Noclip:Disconnect() end
		HL.Conn.Noclip = RunService.Stepped:Connect(function()
			if not HL.Noclip then return end
			local char = LocalPlayer.Character
			if not char then return end
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end)
	else
		if b then
			b.Text = "NOCLIP  ○ KAPALI"
			b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		end
		if HL.Conn.Noclip then
			HL.Conn.Noclip:Disconnect()
			HL.Conn.Noclip = nil
		end
	end
end

-------------------------------------------------
-- ANTİ YAKALANMA
-------------------------------------------------
local function ToggleGod()
	HL.God = not HL.God
	local b = HL.Buttons.God

	if HL.God then
		if b then
			b.Text = "ANTİ-YAKALANMA  ●"
			b.BackgroundColor3 = Color3.fromRGB(0, 190, 90)
		end
	else
		if b then
			b.Text = "ANTİ-YAKALANMA  ○"
			b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		end
	end
end

print("[HL] Part 1 hazır")-- PART 2/2 (hemen altına yapıştır)

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
	main.Size = UDim2.new(0, 250, 0, 380)
	main.Position = UDim2.new(0.5, -125, 0.55, -90)
	main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(140, 0, 255)
	stroke.Thickness = 2.5

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundColor3 = Color3.fromRGB(28, 18, 42)
	title.BorderSizePixel = 0
	title.Text = "  HAMSTERLİVES  v8"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

	-- Sürükleme
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
		b.Size = UDim2.new(1, -24, 0, 36)
		b.Position = UDim2.new(0, 12, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(240, 240, 240)
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 13
		b.AutoButtonColor = false
		b.Parent = main
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(callback)
		return b
	end

	HL.Buttons.Fly    = makeBtn("FLY  ○ KAPALI", 55, ToggleFly)
	HL.Buttons.Save   = makeBtn("YER BELİLE", 98, SavePos)
	HL.Buttons.TP     = makeBtn("TP ET", 141, TP)
	HL.Buttons.Noclip = makeBtn("NOCLIP  ○ KAPALI", 184, ToggleNoclip)
	HL.Buttons.God    = makeBtn("ANTİ-YAKALANMA  ○", 227, ToggleGod)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -24, 0, 34)
	box.Position = UDim2.new(0, 12, 0, 280)
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	box.BorderSizePixel = 0
	box.Text = "Hız: 85"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = main
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

	box.FocusLost:Connect(function()
		local n = tonumber(string.match(box.Text, "%d+"))
		if n and n >= 20 and n <= 400 then
			HL.Speed = n
			box.Text = "Hız: " .. n
		else
			box.Text = "Hız: " .. HL.Speed
		end
	end)

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -36, 0, 7)
	close.BackgroundColor3 = Color3.fromRGB(180, 35, 55)
	close.Text = "✕"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 15
	close.Parent = main
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
	close.MouseButton1Click:Connect(function()
		main.Visible = false
	end)

	-- Mobilde büyük görünür HL butonu
	local open = Instance.new("TextButton")
	open.Size = UDim2.new(0, 60, 0, 60)
	open.Position = UDim2.new(1, -75, 0, 25)
	open.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
	open.Text = "HL"
	open.TextColor3 = Color3.fromRGB(255, 255, 255)
	open.Font = Enum.Font.GothamBold
	open.TextSize = 20
	open.Parent = gui
	Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)

	open.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)
end

-------------------------------------------------
-- SİYAH EKRAN + PC / MOBİL
-------------------------------------------------
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
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0.28, 0)
	title.BackgroundTransparency = 1
	title.Text = "HAMSTERLİVES"
	title.TextColor3 = Color3.fromRGB(180, 0, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 34
	title.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 30)
	sub.Position = UDim2.new(0, 0, 0.36, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "Cihazını seç"
	sub.TextColor3 = Color3.fromRGB(200, 200, 200)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 18
	sub.Parent = bg

	local pcBtn = Instance.new("TextButton")
	pcBtn.Size = UDim2.new(0, 180, 0, 55)
	pcBtn.Position = UDim2.new(0.5, -200, 0.5, -10)
	pcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	pcBtn.Text = "PC"
	pcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	pcBtn.Font = Enum.Font.GothamBold
	pcBtn.TextSize = 22
	pcBtn.Parent = bg
	Instance.new("UICorner", pcBtn).CornerRadius = UDim.new(0, 12)

	local mobBtn = Instance.new("TextButton")
	mobBtn.Size = UDim2.new(0, 180, 0, 55)
	mobBtn.Position = UDim2.new(0.5, 20, 0.5, -10)
	mobBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	mobBtn.Text = "MOBİL"
	mobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	mobBtn.Font = Enum.Font.GothamBold
	mobBtn.TextSize = 22
	mobBtn.Parent = bg
	Instance.new("UICorner", mobBtn).CornerRadius = UDim.new(0, 12)

	local function selectMode(isMobile)
		HL.IsMobile = isMobile
		HL.ModeSelected = true
		gui:Destroy()
		CreateMainMenu()
	end

	pcBtn.MouseButton1Click:Connect(function()
		selectMode(false)
	end)
	mobBtn.MouseButton1Click:Connect(function()
		selectMode(true)
	end)
end

local ok, err = pcall(CreateStartScreen)
if not ok then
	warn("[HL] Start hatası:", err)
end

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp or not HL.ModeSelected then return end
	if inp.KeyCode == Enum.KeyCode.F8 then ToggleFly()
	elseif inp.KeyCode == Enum.KeyCode.F4 then SavePos()
	elseif inp.KeyCode == Enum.KeyCode.F5 then TP()
	elseif inp.KeyCode == Enum.KeyCode.F6 then ToggleNoclip()
	elseif inp.KeyCode == Enum.KeyCode.F7 then ToggleGod()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1.2)
	if HL.Fly then StartFly() end
	if not HL.Conn.Protect then ProtectLoop() end
end)

print("[HL] v8 yüklendi")
