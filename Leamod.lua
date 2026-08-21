-- HAMSTERLİVES ONLİNE HACK  (Güçlendirilmiş - Tek Script)
-- PART 1/2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HamsterLive = {
	FlyEnabled = false,
	FlySpeed = 100,
	SavedPosition = nil,
	LinearVelocity = nil,
	AlignOrientation = nil,
	Attachment = nil,
	RenderConnection = nil,
	Teleporting = false,
	IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	MenuOpen = false,
	StreamerMode = false,
	NoclipConnection = nil,
	NoclipEnabled = false,
	AutoBadEnabled = false,
	AutoBadConnection = nil,
	BadModEnabled = false,
	BadModConnection = nil,
	FlyButton = nil,
	SaveButton = nil,
	TpButton = nil,
	NoclipButton = nil,
	StreamerButton = nil,
	AutoBadButton = nil,
	BadModButton = nil,
	SpeedSlider = nil,
	AntiSnapConnection = nil,
	HoldPosition = nil,
	HoldUntil = 0,
}

local function safeWait(t)
	local start = os.clock()
	while os.clock() - start < t do
		task.wait()
	end
end

local function StartAntiSnap()
	if HamsterLive.AntiSnapConnection then return end
	HamsterLive.AntiSnapConnection = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if not root:IsDescendantOf(workspace) then
			root.Parent = char
		end

		if HamsterLive.HoldPosition and os.clock() < HamsterLive.HoldUntil then
			root.CFrame = CFrame.new(HamsterLive.HoldPosition)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end)
end
StartAntiSnap()

local function DestroyFly()
	if HamsterLive.RenderConnection then
		HamsterLive.RenderConnection:Disconnect()
		HamsterLive.RenderConnection = nil
	end
	if HamsterLive.LinearVelocity then
		pcall(function() HamsterLive.LinearVelocity:Destroy() end)
		HamsterLive.LinearVelocity = nil
	end
	if HamsterLive.AlignOrientation then
		pcall(function() HamsterLive.AlignOrientation:Destroy() end)
		HamsterLive.AlignOrientation = nil
	end
	if HamsterLive.Attachment then
		pcall(function() HamsterLive.Attachment:Destroy() end)
		HamsterLive.Attachment = nil
	end
end

local function CreateFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	DestroyFly()
	hum:ChangeState(Enum.HumanoidStateType.Physics)
	hum.PlatformStand = true

	local att = Instance.new("Attachment")
	att.Name = "HamsterFlyAtt"
	att.Parent = root
	HamsterLive.Attachment = att

	local lv = Instance.new("LinearVelocity")
	lv.Name = "HamsterFlyLV"
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.VectorVelocity = Vector3.zero
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = root
	HamsterLive.LinearVelocity = lv

	local ao = Instance.new("AlignOrientation")
	ao.Name = "HamsterFlyAO"
	ao.Attachment0 = att
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.MaxTorque = math.huge
	ao.Responsiveness = 200
	ao.Parent = root
	HamsterLive.AlignOrientation = ao

	HamsterLive.RenderConnection = RunService.RenderStepped:Connect(function()
		if not HamsterLive.FlyEnabled then return end
		local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not currentRoot or not HamsterLive.LinearVelocity or not HamsterLive.AlignOrientation then
			CreateFly()
			return
		end

		local camCF = Camera.CFrame
		local move = Vector3.zero

		if HamsterLive.IsMobile then
			local touches = UserInputService:GetTouches()
			if #touches > 0 then
				local touch = touches[1]
				local size = Camera.ViewportSize
				local dx = (touch.Position.X - size.X/2) / (size.X/2)
				local dy = (touch.Position.Y - size.Y/2) / (size.Y/2)
				if math.abs(dx) > 0.15 or math.abs(dy) > 0.15 then
					move = camCF.LookVector * (-dy) + camCF.RightVector * dx
				end
			end
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.yAxis end
		end

		local speed = HamsterLive.FlySpeed * 2.2
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end

		HamsterLive.LinearVelocity.VectorVelocity = move
		HamsterLive.AlignOrientation.CFrame = CFrame.lookAt(currentRoot.Position, currentRoot.Position + camCF.LookVector)
	end)
end

local function ToggleFly()
	HamsterLive.FlyEnabled = not HamsterLive.FlyEnabled
	if HamsterLive.FlyEnabled then
		if HamsterLive.FlyButton then
			HamsterLive.FlyButton.Text = "Fly: AÇIK (F8)"
			HamsterLive.FlyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		end
		CreateFly()
	else
		if HamsterLive.FlyButton then
			HamsterLive.FlyButton.Text = "Fly: KAPALI (F8)"
			HamsterLive.FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		end
		DestroyFly()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

local function TeleportTo(position)
	if not position then return end
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	HamsterLive.Teleporting = true
	HamsterLive.HoldPosition = position
	HamsterLive.HoldUntil = os.clock() + 2.0

	local wasFlying = HamsterLive.FlyEnabled
	if wasFlying then
		HamsterLive.FlyEnabled = false
		DestroyFly()
	end

	for i = 1, 10 do
		root.CFrame = CFrame.new(position)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		safeWait(0.012)
	end

	root.Anchored = true
	safeWait(0.1)
	root.Anchored = false
	root.CFrame = CFrame.new(position)

	HamsterLive.Teleporting = false

	if wasFlying then
		HamsterLive.FlyEnabled = true
		CreateFly()
	end
end

local function SavePosition()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		HamsterLive.SavedPosition = root.Position
		if HamsterLive.SaveButton then
			HamsterLive.SaveButton.Text = "Kaydedildi!"
			HamsterLive.SaveButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
			task.delay(1, function()
				if HamsterLive.SaveButton then
					HamsterLive.SaveButton.Text = "Yer Belirle (F4)"
					HamsterLive.SaveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
				end
			end)
		end
	end
end

local function DoTeleport()
	if HamsterLive.SavedPosition then
		TeleportTo(HamsterLive.SavedPosition)
	end
end

local function ToggleNoclip()
	HamsterLive.NoclipEnabled = not HamsterLive.NoclipEnabled
	if HamsterLive.NoclipEnabled then
		if HamsterLive.NoclipConnection then HamsterLive.NoclipConnection:Disconnect() end
		HamsterLive.NoclipConnection = RunService.Stepped:Connect(function()
			if not HamsterLive.NoclipEnabled then return end
			local char = LocalPlayer.Character
			if not char then return end
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		if HamsterLive.NoclipConnection then
			HamsterLive.NoclipConnection:Disconnect()
			HamsterLive.NoclipConnection = nil
		end
	end
end

local function GetNearestPlayer()
	local nearest, shortest = nil, math.huge
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr \~= LocalPlayer then
			local tChar = plr.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health > 0 then
				local dist = (root.Position - tRoot.Position).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = plr
				end
			end
		end
	end
	return nearest
end

local function FindToolAndAttack(target)
	local char = LocalPlayer.Character
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	local tHum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not tHum or tHum.Health <= 0 then return end
	pcall(function()
		tool:Activate()
		task.wait(0.08)
		tool:Deactivate()
	end)
end

local function ToggleAutoBad()
	HamsterLive.AutoBadEnabled = not HamsterLive.AutoBadEnabled
	if HamsterLive.AutoBadEnabled then
		if HamsterLive.AutoBadConnection then HamsterLive.AutoBadConnection:Disconnect() end
		HamsterLive.AutoBadConnection = RunService.Heartbeat:Connect(function()
			if not HamsterLive.AutoBadEnabled then return end
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local target = GetNearestPlayer()
			if not target then return end
			local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			if not tRoot then return end
			local dist = (root.Position - tRoot.Position).Magnitude
			if dist > 6 then
				if not HamsterLive.FlyEnabled then
					HamsterLive.FlyEnabled = true
					CreateFly()
				end
				if HamsterLive.LinearVelocity then
					local dir = (tRoot.Position - root.Position).Unit
					HamsterLive.LinearVelocity.VectorVelocity = dir * (HamsterLive.FlySpeed * 3.5)
				end
			else
				FindToolAndAttack(target)
			end
		end)
	else
		if HamsterLive.AutoBadConnection then
			HamsterLive.AutoBadConnection:Disconnect()
			HamsterLive.AutoBadConnection = nil
		end
	end
end

local function ToggleBadMod()
	HamsterLive.BadModEnabled = not HamsterLive.BadModEnabled
	if HamsterLive.BadModEnabled then
		if HamsterLive.BadModConnection then HamsterLive.BadModConnection:Disconnect() end
		HamsterLive.BadModConnection = RunService.Heartbeat:Connect(function()
			if not HamsterLive.BadModEnabled then return end
			local char = LocalPlayer.Character
			if not char then return end
			local tool = char:FindFirstChildOfClass("Tool")
			if not tool then return end
			for _, plr in pairs(Players:GetPlayers()) do
				if plr \~= LocalPlayer then
					local tHum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
					if tHum and tHum.Health > 0 then
						pcall(function()
							tool:Activate()
							task.wait(0.04)
							tool:Deactivate()
						end)
					end
				end
			end
		end)
	else
		if HamsterLive.BadModConnection then
			HamsterLive.BadModConnection:Disconnect()
			HamsterLive.BadModConnection = nil
		end
	end
end

local function ToggleStreamerMode()
	HamsterLive.StreamerMode = not HamsterLive.StreamerMode
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	local hamsterGUI = gui and gui:FindFirstChild("HamsterLiveGUI")
	if hamsterGUI then
		hamsterGUI.Enabled = not HamsterLive.StreamerMode
	end
end-- PART 2/2  (devamı - aynı scripte yapıştır)

local function CreateMenu()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "HamsterLiveGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(0, 350, 0, 35)
	Title.Position = UDim2.new(0.5, -175, 0.03, 0)
	Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Title.BackgroundTransparency = 0.3
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Text = "HAMSTERLİVES ONLİNE HACK"
	Title.Font = Enum.Font.SourceSansBold
	Title.TextSize = 20
	Title.Parent = ScreenGui

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 120, 0, 35)
	ToggleButton.Position = UDim2.new(1, -130, 0, 10)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
	ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToggleButton.Text = "MENÜ"
	ToggleButton.Font = Enum.Font.SourceSansBold
	ToggleButton.TextSize = 16
	ToggleButton.Parent = ScreenGui

	local MenuFrame = Instance.new("Frame")
	MenuFrame.Size = UDim2.new(0, 220, 0, 370)
	MenuFrame.Position = UDim2.new(1, -230, 0, 50)
	MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MenuFrame.BackgroundTransparency = 0.1
	MenuFrame.Visible = false
	MenuFrame.Parent = ScreenGui

	local function makeButton(text, y)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 200, 0, 35)
		btn.Position = UDim2.new(0, 10, 0, y)
		btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = text
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 15
		btn.Parent = MenuFrame
		return btn
	end

	HamsterLive.FlyButton      = makeButton("Fly: KAPALI (F8)", 10)
	HamsterLive.SaveButton     = makeButton("Yer Belirle (F4)", 55)
	HamsterLive.TpButton        = makeButton("TP (F5)", 100)
	HamsterLive.NoclipButton    = makeButton("Noclip: KAPALI (F6)", 145)
	HamsterLive.StreamerButton  = makeButton("Yayıncı: KAPALI (F7)", 190)
	HamsterLive.AutoBadButton   = makeButton("AutoBad: KAPALI (F9)", 235)
	HamsterLive.BadModButton    = makeButton("Bad Mod: KAPALI (F10)", 280)

	local SpeedSlider = Instance.new("TextBox")
	SpeedSlider.Size = UDim2.new(0, 200, 0, 30)
	SpeedSlider.Position = UDim2.new(0, 10, 0, 325)
	SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
	SpeedSlider.Text = "Hız: 100"
	SpeedSlider.Font = Enum.Font.SourceSansBold
	SpeedSlider.TextSize = 14
	SpeedSlider.Parent = MenuFrame
	HamsterLive.SpeedSlider = SpeedSlider

	ToggleButton.MouseButton1Click:Connect(function()
		HamsterLive.MenuOpen = not HamsterLive.MenuOpen
		MenuFrame.Visible = HamsterLive.MenuOpen
	end)

	HamsterLive.FlyButton.MouseButton1Click:Connect(ToggleFly)
	HamsterLive.SaveButton.MouseButton1Click:Connect(SavePosition)
	HamsterLive.TpButton.MouseButton1Click:Connect(DoTeleport)

	HamsterLive.NoclipButton.MouseButton1Click:Connect(function()
		ToggleNoclip()
		HamsterLive.NoclipButton.Text = HamsterLive.NoclipEnabled and "Noclip: AÇIK (F6)" or "Noclip: KAPALI (F6)"
		HamsterLive.NoclipButton.BackgroundColor3 = HamsterLive.NoclipEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)
	end)

	HamsterLive.StreamerButton.MouseButton1Click:Connect(function()
		ToggleStreamerMode()
		HamsterLive.StreamerButton.Text = HamsterLive.StreamerMode and "Yayıncı: AÇIK (F7)" or "Yayıncı: KAPALI (F7)"
		HamsterLive.StreamerButton.BackgroundColor3 = HamsterLive.StreamerMode and Color3.fromRGB(255,0,0) or Color3.fromRGB(70,70,70)
	end)

	HamsterLive.AutoBadButton.MouseButton1Click:Connect(function()
		ToggleAutoBad()
		HamsterLive.AutoBadButton.Text = HamsterLive.AutoBadEnabled and "AutoBad: AÇIK (F9)" or "AutoBad: KAPALI (F9)"
		HamsterLive.AutoBadButton.BackgroundColor3 = HamsterLive.AutoBadEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)
	end)

	HamsterLive.BadModButton.MouseButton1Click:Connect(function()
		ToggleBadMod()
		HamsterLive.BadModButton.Text = HamsterLive.BadModEnabled and "Bad Mod: AÇIK (F10)" or "Bad Mod: KAPALI (F10)"
		HamsterLive.BadModButton.BackgroundColor3 = HamsterLive.BadModEnabled and Color3.fromRGB(255,0,0) or Color3.fromRGB(70,70,70)
	end)

	SpeedSlider.FocusLost:Connect(function(enter)
		if enter then
			local num = tonumber(string.match(SpeedSlider.Text, "%d+"))
			if num and num > 0 and num <= 1000 then
				HamsterLive.FlySpeed = num
				SpeedSlider.Text = "Hız: " .. num
			else
				HamsterLive.FlySpeed = 100
				SpeedSlider.Text = "Hız: 100"
			end
		end
	end)
end

local function SetupKeybinds()
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.F8 then
			ToggleFly()
		elseif input.KeyCode == Enum.KeyCode.F4 then
			SavePosition()
		elseif input.KeyCode == Enum.KeyCode.F5 then
			DoTeleport()
		elseif input.KeyCode == Enum.KeyCode.F6 then
			ToggleNoclip()
			if HamsterLive.NoclipButton then
				HamsterLive.NoclipButton.Text = HamsterLive.NoclipEnabled and "Noclip: AÇIK (F6)" or "Noclip: KAPALI (F6)"
				HamsterLive.NoclipButton.BackgroundColor3 = HamsterLive.NoclipEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)
			end
		elseif input.KeyCode == Enum.KeyCode.F7 then
			ToggleStreamerMode()
			if HamsterLive.StreamerButton then
				HamsterLive.StreamerButton.Text = HamsterLive.StreamerMode and "Yayıncı: AÇIK (F7)" or "Yayıncı: KAPALI (F7)"
				HamsterLive.StreamerButton.BackgroundColor3 = HamsterLive.StreamerMode and Color3.fromRGB(255,0,0) or Color3.fromRGB(70,70,70)
			end
		elseif input.KeyCode == Enum.KeyCode.F9 then
			ToggleAutoBad()
			if HamsterLive.AutoBadButton then
				HamsterLive.AutoBadButton.Text = HamsterLive.AutoBadEnabled and "AutoBad: AÇIK (F9)" or "AutoBad: KAPALI (F9)"
				HamsterLive.AutoBadButton.BackgroundColor3 = HamsterLive.AutoBadEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)
			end
		elseif input.KeyCode == Enum.KeyCode.F10 then
			ToggleBadMod()
			if HamsterLive.BadModButton then
				HamsterLive.BadModButton.Text = HamsterLive.BadModEnabled and "Bad Mod: AÇIK (F10)" or "Bad Mod: KAPALI (F10)"
				HamsterLive.BadModButton.BackgroundColor3 = HamsterLive.BadModEnabled and Color3.fromRGB(255,0,0) or Color3.fromRGB(70,70,70)
			end
		end
	end)
end

CreateMenu()
SetupKeybinds()

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1.2)
	if HamsterLive.FlyEnabled then
		CreateFly()
	end
	if not HamsterLive.AntiSnapConnection then
		StartAntiSnap()
	end
end)

print("[HamsterLive] Script başarıyla yüklendi.")
