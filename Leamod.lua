-- ============================================================
-- HAMSTERLİVES v20 - NORMAL ANİMASYON KORUMALI
-- PART 1/2 - KARAKTER KİLİTLENMEZ + GÜÇLÜ ANTI-KICK
-- ============================================================

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
	GlideTimer = 0,
	GlideVelocity = Vector3.zero,
	Conn = {},
	Buttons = {}
}

-- ==================== GÜÇLÜ ANTI-KICK + ANİMASYON KORUMA ====================
local Bypass = {
	Active = false,
	LastSafePosition = nil,
	Layer1 = nil,
	Layer2 = nil,
	Layer3 = nil,
	Layer4 = nil,
	Layer5 = nil,
	Layer6 = nil,
	Layer7 = nil,
	Layer8 = nil,
	Layer9 = nil,
	Layer10 = nil,
	AnimProtect = nil,
	LastAnimState = nil,
	LastAnimTime = 0
}

local function StartBypass()
	if Bypass.Active then return end
	Bypass.Active = true

	-- KATMAN 1: HEALTH
	Bypass.Layer1 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			if hum.Health < hum.MaxHealth * 0.95 or HL.God then
				hum.Health = hum.MaxHealth
			end
		end)
	end)

	-- KATMAN 2: ÖLÜM ENGELLEME
	Bypass.Layer2 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			if hum:GetState() == Enum.HumanoidStateType.Dead then
				hum.Health = hum.MaxHealth
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)
	end)

	-- KATMAN 3: ANTI-RESET
	Bypass.Layer3 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if Bypass.LastSafePosition and not HL.Fly and not HL.PullActive then
			local dist = (root.Position - Bypass.LastSafePosition).Magnitude
			if dist > 150 then
				pcall(function()
					root.CFrame = CFrame.new(Bypass.LastSafePosition)
				end)
			end
		end
		Bypass.LastSafePosition = root.Position
	end)

	-- KATMAN 4: KICK ENGELLEME
	Bypass.Layer4 = LocalPlayer.Changed:Connect(function(prop)
		if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
			pcall(function()
				LocalPlayer.Parent = Players
			end)
		end
	end)

	-- KATMAN 5: HIZ KORUMA
	Bypass.Layer5 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			if hum.WalkSpeed < 16 and not HL.Fly then
				hum.WalkSpeed = 16
			end
			if hum.JumpPower < 50 and not HL.Fly then
				hum.JumpPower = 50
			end
			if hum.WalkSpeed == 0 then
				hum.WalkSpeed = 16
			end
		end)
	end)

	-- KATMAN 6: VOID KURTARMA
	Bypass.Layer6 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if root.Position.Y < -100 then
			pcall(function()
				if Bypass.LastSafePosition then
					root.CFrame = CFrame.new(Bypass.LastSafePosition)
				end
			end)
		end
	end)

	-- KATMAN 7: KARAKTER KORUMA
	Bypass.Layer7 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if not root:IsDescendantOf(workspace) then
			pcall(function()
				root.Parent = char
			end)
		end
	end)

	-- KATMAN 8: STATE KORUMA
	Bypass.Layer8 = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			if hum:GetState() == Enum.HumanoidStateType.Dead then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
			if hum.PlatformStand and not HL.Fly then
				hum.PlatformStand = false
			end
		end)
	end)

	-- KATMAN 9: PARENT KORUMA
	Bypass.Layer9 = RunService.Heartbeat:Connect(function()
		if not LocalPlayer:IsDescendantOf(Players) then
			pcall(function()
				LocalPlayer.Parent = Players
			end)
		end
	end)

	-- KATMAN 10: SONSUZ DÖNGÜ
	Bypass.Layer10 = RunService.Stepped:Connect(function()
		pcall(function()
			if not Bypass.Active then return end
			if not Bypass.Layer1 or not Bypass.Layer1.Connected then
				StartBypass()
			end
		end)
	end)

	-- ANİMASYON KORUMA - KARAKTER ASLA KİLİTLENMEZ
	Bypass.AnimProtect = RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end

		-- Karakterin normal animasyonunu bozma
		pcall(function()
			-- Eğer TP veya AutoEgg aktifse normal yürüme animasyonu
			if HL.PullActive then
				-- Normal yürüme state'ini koru
				if hum:GetState() ~= Enum.HumanoidStateType.Running and hum:GetState() ~= Enum.HumanoidStateType.RunningNoPhysics then
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end
				-- Animasyonu serbest bırak
				hum:Move(Vector3.new(0, 0, -1), false)
			end

			-- Fly aktifse freefall animasyonu koru
			if HL.Fly then
				if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
					hum:ChangeState(Enum.HumanoidStateType.Freefall)
				end
			end

			-- Normal durumda animasyonu serbest bırak
			if not HL.Fly and not HL.PullActive then
				-- Animasyonu kilitleme, serbest bırak
				hum:Move(Vector3.zero, false)
			end
		end)
	end)

	print("[HL] 10 KATMAN + ANİMASYON KORUMA AKTİF")
end

-- ==================== SÜZÜLME FLY ====================
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
	HL.GlideVelocity = Vector3.zero
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
	HL.GlideTimer = 0
	HL.GlideVelocity = Vector3.zero

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
				if math.abs(dx) > 0.04 or math.abs(dy) > 0.04 then
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

		local speed = HL.Speed * 3
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end

		HL.OscTimer = HL.OscTimer + dt
		HL.GlideTimer = HL.GlideTimer + dt

		local targetVelocity = move
		local lerpFactor = 1 - math.exp(-12 * dt)

		HL.GlideVelocity = HL.GlideVelocity:Lerp(targetVelocity, lerpFactor)

		local downwardGlide = Vector3.new(0, -1, 0)
		HL.GlideVelocity = HL.GlideVelocity + downwardGlide * dt

		if HL.GlideVelocity.Magnitude > speed * 2 then
			HL.GlideVelocity = HL.GlideVelocity.Unit * speed * 2
		end

		local oscY = math.sin(HL.OscTimer * 1.5) * 0.25
		local oscX = math.cos(HL.OscTimer * 1.1) * 0.08

		local newPos = r.Position + HL.GlideVelocity * dt + Vector3.new(oscX * dt * 2, oscY * dt * 2, 0)

		local lookDir = HL.GlideVelocity.Magnitude > 0.5 and HL.GlideVelocity.Unit or cf.LookVector
		local smoothCFrame = CFrame.new(newPos, newPos + lookDir:Lerp(cf.LookVector, 0.15))

		r.CFrame = smoothCFrame
		r.AssemblyLinearVelocity = Vector3.new(0, -0.5, 0)
		r.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function ToggleFly()
	HL.Fly = not HL.Fly
	local b = HL.Buttons.Fly
	if b then
		b.Text = HL.Fly and "FLY  ● AÇIK" or "FLY  ○ KAPALI"
		b.BackgroundColor3 = HL.Fly and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if HL.Fly then StartFly() else StopFly() end
end

-- ==================== TP DÜZ ====================
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

	local startPos = root.Position
	local flatTarget = Vector3.new(targetPos.X, startPos.Y, targetPos.Z)
	local totalDist = (flatTarget - startPos).Magnitude
	local startTime = os.clock()
	local duration = math.clamp(totalDist / (hum.WalkSpeed * 2), 0.2, 3)

	HL.Conn.Pull = RunService.Heartbeat:Connect(function(dt)
		if not HL.PullActive then return end

		local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not r or not h then StopPull() return end

		local elapsed = os.clock() - startTime
		local t = math.clamp(elapsed / duration, 0, 1)

		local currentPos = startPos:Lerp(flatTarget, t)
		currentPos = Vector3.new(currentPos.X, startPos.Y, currentPos.Z)

		r.CFrame = CFrame.new(currentPos, flatTarget)
		r.AssemblyLinearVelocity = Vector3.zero
		r.AssemblyAngularVelocity = Vector3.zero

		-- NORMAL YÜRÜME ANİMASYONU - KİLİTLENME YOK
		pcall(function()
			h:ChangeState(Enum.HumanoidStateType.Running)
			h:Move(Vector3.new(0, 0, -1), false)
		end)

		if t >= 1 then
			local finalPos = Vector3.new(flatTarget.X, startPos.Y, flatTarget.Z)
			r.CFrame = CFrame.new(finalPos)
			r.AssemblyLinearVelocity = Vector3.zero
			StopPull()
			HL.HoldPos = finalPos
			HL.HoldUntil = os.clock() + 1.5
		end
	end)
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
		if HL.Fly then
			HL.Fly = false
			StopFly()
		end
		StartPull(HL.Saved)
	end
end

-- ==================== CUBE ====================
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
	local b = HL.Buttons.Cube
	if b then
		b.Text = HL.Cube and "CUBE  ● AÇIK" or "CUBE  ○ KAPALI"
		b.BackgroundColor3 = HL.Cube and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
	if not HL.Cube then DestroyCube() end
end

-- ==================== AUTO EGG ====================
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
				local score = size * 10 - (pos - root.Position).Magnitude * 0.05
				if score > bestScore then bestScore = score best = pos end
			end
		end
	end
	return best
end

local function ToggleAutoEgg()
	HL.AutoEgg = not HL.AutoEgg
	local b = HL.Buttons.AutoEgg
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

-- ==================== NOCLIP ====================
local function ToggleNoclip()
	HL.Noclip = not HL.Noclip
	local b = HL.Buttons.Noclip
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

-- ==================== GOD ====================
local function ToggleGod()
	HL.God = not HL.God
	local b = HL.Buttons.God
	if b then
		b.Text = HL.God and "ANTİ-YAKALANMA  ●" or "ANTİ-YAKALANMA  ○"
		b.BackgroundColor3 = HL.God and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 50)
	end
end

-- ==================== BAŞLAT ====================
HL.Conn.Cube = RunService.Heartbeat:Connect(UpdateCube)
StartBypass()

print("[HL] Part 1 hazır - v20 NORMAL ANİMASYON")-- ============================================================
-- HAMSTERLİVES v20 - PART 2/2
-- MENÜ + TUŞLAR
-- ============================================================

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
	title.Text = "  HAMSTERLİVES  v20"
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
	HL.Buttons.TP      = makeBtn("TP ET (DÜZ)", 126, TP)
	HL.Buttons.Noclip  = makeBtn("NOCLIP  ○ KAPALI", 164, ToggleNoclip)
	HL.Buttons.God     = makeBtn("ANTİ-YAKALANMA  ○", 202, ToggleGod)
	HL.Buttons.Cube    = makeBtn("CUBE  ○ KAPALI", 240, ToggleCube)
	HL.Buttons.AutoEgg = makeBtn("AUTO EGG  ○", 278, ToggleAutoEgg)

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
	if not Bypass.Active then StartBypass() end
end)

print("[HL] v20 yüklendi - NORMAL ANİMASYON")
