-- HAMSTERLİVES ONLİNE HACK v3
-- PART 1/2  (önce bunu yapıştır)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HL = {
	FlyEnabled = false,
	FlySpeed = 90,
	SavedPos = nil,
	LV = nil,
	AO = nil,
	Att = nil,
	FlyConn = nil,
	NoclipConn = nil,
	Noclip = false,
	AntiConn = nil,
	HoldPos = nil,
	HoldUntil = 0,
	IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	Buttons = {},
}

local function wait(t)
	local s = os.clock()
	while os.clock() - s < t do task.wait() end
end

-- ==================== ANTİ SNAP / ANTİ RESET ====================
local function StartAnti()
	if HL.AntiConn then return end
	HL.AntiConn = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		-- Root kaybolursa geri koy
		if not root:IsDescendantOf(workspace) then
			pcall(function() root.Parent = char end)
		end

		-- TP sonrası pozisyon kilidi (en önemli kısım)
		if HL.HoldPos and os.clock() < HL.HoldUntil then
			root.CFrame = CFrame.new(HL.HoldPos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end)
end
StartAnti()

-- ==================== FLY ====================
local function KillFly()
	if HL.FlyConn then HL.FlyConn:Disconnect() HL.FlyConn = nil end
	if HL.LV then pcall(function() HL.LV:Destroy() end) HL.LV = nil end
	if HL.AO then pcall(function() HL.AO:Destroy() end) HL.AO = nil end
	if HL.Att then pcall(function() HL.Att:Destroy() end) HL.Att = nil end
end

local function MakeFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	KillFly()
	hum.PlatformStand = true
	hum:ChangeState(Enum.HumanoidStateType.Physics)

	local att = Instance.new("Attachment")
	att.Parent = root
	HL.Att = att

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.VectorVelocity = Vector3.zero
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = root
	HL.LV = lv

	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = att
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.MaxTorque = math.huge
	ao.Responsiveness = 200
	ao.Parent = root
	HL.AO = ao

	HL.FlyConn = RunService.RenderStepped:Connect(function()
		if not HL.FlyEnabled then return end
		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not r or not HL.LV or not HL.AO then
			MakeFly()
			return
		end

		local cf = Camera.CFrame
		local move = Vector3.zero

		if HL.IsMobile then
			local touches = UserInputService:GetTouches()
			if #touches > 0 then
				local t = touches[1]
				local size = Camera.ViewportSize
				local dx = (t.Position.X - size.X/2) / (size.X/2)
				local dy = (t.Position.Y - size.Y/2) / (size.Y/2)
				if math.abs(dx) > 0.12 or math.abs(dy) > 0.12 then
					move = cf.LookVector * (-dy) + cf.RightVector * dx
				end
			end
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.yAxis end
		end

		local speed = HL.FlySpeed * 2.4
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end
		HL.LV.VectorVelocity = move
		HL.AO.CFrame = CFrame.lookAt(r.Position, r.Position + cf.LookVector)
	end)
end

local function ToggleFly()
	HL.FlyEnabled = not HL.FlyEnabled
	local btn = HL.Buttons.Fly
	if HL.FlyEnabled then
		if btn then btn.Text = "FLY  ● AÇIK" btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) end
		MakeFly()
	else
		if btn then btn.Text = "FLY  ○ KAPALI" btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end
		KillFly()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

-- ==================== TELEPORT (Güçlü) ====================
local function TP(pos)
	if not pos then return end
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	HL.HoldPos = pos
	HL.HoldUntil = os.clock() + 2.5

	local wasFly = HL.FlyEnabled
	if wasFly then
		HL.FlyEnabled = false
		KillFly()
	end

	for i = 1, 12 do
		root.CFrame = CFrame.new(pos)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		wait(0.01)
	end

	root.Anchored = true
	wait(0.12)
	root.Anchored = false
	root.CFrame = CFrame.new(pos)

	if wasFly then
		HL.FlyEnabled = true
		MakeFly()
	end
end

local function SavePos()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		HL.SavedPos = root.Position
		local btn = HL.Buttons.Save
		if btn then
			btn.Text = "KAYDEDİLDİ ✓"
			btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
			task.delay(1.1, function()
				if btn then
					btn.Text = "YER BELİLE"
					btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
				end
			end)
		end
	end
end

local function DoTP()
	if HL.SavedPos then TP(HL.SavedPos) end
end

-- ==================== NOCLIP ====================
local function ToggleNoclip()
	HL.Noclip = not HL.Noclip
	local btn = HL.Buttons.Noclip
	if HL.Noclip then
		if btn then btn.Text = "NOCLIP  ● AÇIK" btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) end
		if HL.NoclipConn then HL.NoclipConn:Disconnect() end
		HL.NoclipConn = RunService.Stepped:Connect(function()
			if not HL.Noclip then return end
			local char = LocalPlayer.Character
			if not char then return end
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		if btn then btn.Text = "NOCLIP  ○ KAPALI" btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end
		if HL.NoclipConn then HL.NoclipConn:Disconnect() HL.NoclipConn = nil end
	end
end-- PART 2/2  (hemen altına yapıştır)

-- ==================== SÜRÜKLENEBİLİR MENÜ ====================
local function CreateGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "HamsterLiveGUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Ana Frame (sürüklenebilir)
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 240, 0, 340)
	main.Position = UDim2.new(1, -260, 0.5, -170)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = main

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(140, 0, 255)
	stroke.Thickness = 2
	stroke.Parent = main

	-- Başlık (sürükleme alanı)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 42)
	title.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
	title.BorderSizePixel = 0
	title.Text = "  HAMSTERLİVES  v3"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title

	-- Sürükleme
	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	title.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)

	-- Buton oluşturucu
	local function btn(text, y, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -24, 0, 38)
		b.Position = UDim2.new(0, 12, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(240, 240, 240)
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 14
		b.AutoButtonColor = false
		b.Parent = main

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 8)
		c.Parent = b

		b.MouseButton1Click:Connect(callback)
		b.MouseEnter:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 60, 90)}):Play()
		end)
		b.MouseLeave:Connect(function()
			if not string.find(b.Text, "AÇIK") then
				TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
			end
		end)
		return b
	end

	HL.Buttons.Fly    = btn("FLY  ○ KAPALI", 55, ToggleFly)
	HL.Buttons.Save   = btn("YER BELİLE", 100, SavePos)
	HL.Buttons.TP     = btn("TP ET", 145, DoTP)
	HL.Buttons.Noclip = btn("NOCLIP  ○ KAPALI", 190, ToggleNoclip)

	-- Hız kutusu
	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(1, -24, 0, 36)
	speedBox.Position = UDim2.new(0, 12, 0, 240)
	speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	speedBox.BorderSizePixel = 0
	speedBox.Text = "Hız: 90"
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.Font = Enum.Font.Gotham
	speedBox.TextSize = 14
	speedBox.ClearTextOnFocus = false
	speedBox.Parent = main

	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0, 8)
	sc.Parent = speedBox

	speedBox.FocusLost:Connect(function()
		local n = tonumber(string.match(speedBox.Text, "%d+"))
		if n and n >= 10 and n <= 500 then
			HL.FlySpeed = n
			speedBox.Text = "Hız: " .. n
		else
			speedBox.Text = "Hız: " .. HL.FlySpeed
		end
	end)

	-- Kapat butonu
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 32, 0, 32)
	close.Position = UDim2.new(1, -38, 0, 5)
	close.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
	close.Text = "✕"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.Parent = main
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 8)
	cc.Parent = close
	close.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)

	-- Küçük açma butonu (sağ üst)
	local openBtn = Instance.new("TextButton")
	openBtn.Size = UDim2.new(0, 50, 0, 50)
	openBtn.Position = UDim2.new(1, -60, 0, 20)
	openBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
	openBtn.Text = "HL"
	openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openBtn.Font = Enum.Font.GothamBold
	openBtn.TextSize = 18
	openBtn.Parent = gui
	local oc = Instance.new("UICorner")
	oc.CornerRadius = UDim.new(1, 0)
	oc.Parent = openBtn
	openBtn.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)
end

-- ==================== TUŞLAR ====================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F8 then ToggleFly()
	elseif input.KeyCode == Enum.KeyCode.F4 then SavePos()
	elseif input.KeyCode == Enum.KeyCode.F5 then DoTP()
	elseif input.KeyCode == Enum.KeyCode.F6 then ToggleNoclip()
	end
end)

-- ==================== BAŞLAT ====================
CreateGUI()

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	if HL.FlyEnabled then MakeFly() end
	if not HL.AntiConn then StartAnti() end
end)

print("[HamsterLive v3] Yüklendi - Menü hazır")
