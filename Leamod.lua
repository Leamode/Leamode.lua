-- ============================================================
-- HAMSTERLİVES v50 - RGB COOL + ANTIRESET + YER BELİRLEME
-- ERR INT 27 engelle + Antireset + Oynatılabilir RGB Menü
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local HL = {
	AutoEgg = false,
	AntiKickActive = false,
	AntiResetActive = false,
	Saved = nil,
	LastBlockTime = 0,
	LastResetCheck = 0,
	RGBHue = 0,
	Conn = {},
	Buttons = {}
}

-- ==================== REMOTE YOK ETME (AYNI) ====================
local function GetRemote(name)
	local remote = nil
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local network = rs:FindFirstChild("Network")
		if network then
			for _, obj in ipairs(network:GetDescendants()) do
				if obj.Name == name then
					remote = obj
					break
				end
			end
		end
	end)
	return remote
end

local function DestroyAllClientCharacterRemotes()
	local destroyed = {}
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local network = rs:FindFirstChild("Network")
		if network then
			for _, obj in ipairs(network:GetDescendants()) do
				if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
					local name = string.lower(obj.Name)
					if string.find(name, "clientcharacter") or 
					   string.find(name, "integrity") or
					   string.find(name, "correction") or
					   string.find(name, "violation") then
						table.insert(destroyed, obj.Name)
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end
	end)
	return destroyed
end

-- ==================== ANTI-KICK ====================
local function StartAntiKick()
	if HL.AntiKickActive then return end
	HL.AntiKickActive = true
	
	print("🍑 ANTI-KICK BAŞLADI")
	
	DestroyAllClientCharacterRemotes()
	
	LocalPlayer.Changed:Connect(function(prop)
		if prop == "Parent" and not LocalPlayer:IsDescendantOf(Players) then
			pcall(function() LocalPlayer.Parent = Players end)
		end
	end)
	
	task.spawn(function()
		while HL.AntiKickActive do
			task.wait(0.001)
			if not LocalPlayer:IsDescendantOf(Players) then
				pcall(function() LocalPlayer.Parent = Players end)
			end
		end
	end)
	
	HL.Conn.AntiKick = RunService.Heartbeat:Connect(function()
		if not HL.AntiKickActive then return end
		if os.clock() - HL.LastBlockTime > 0.5 then
			HL.LastBlockTime = os.clock()
			pcall(function()
				local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
				if playerGui then
					for _, child in pairs(playerGui:GetChildren()) do
						local name = string.lower(child.Name)
						if string.find(name, "kick") or string.find(name, "ban") or 
						   string.find(name, "integrity") or string.find(name, "error") or
						   string.find(name, "denetim") or string.find(name, "moderation") then
							child:Destroy()
						end
					end
				end
			end)
			DestroyAllClientCharacterRemotes()
		end
	end)
end

-- ==================== ANTI-RESET ====================
local function StartAntiReset()
	if HL.AntiResetActive then return end
	HL.AntiResetActive = true
	
	print("🍑 ANTI-RESET BAŞLADI")
	
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Died:Connect(function()
				pcall(function()
					hum.Health = hum.MaxHealth
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end)
		end
	end)
	
	HL.Conn.AntiReset = RunService.Heartbeat:Connect(function()
		if not HL.AntiResetActive then return end
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end
		
		pcall(function()
			if hum:GetState() == Enum.HumanoidStateType.Dead then
				hum.Health = hum.MaxHealth
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
			if hum.Health < hum.MaxHealth * 0.95 then
				hum.Health = hum.MaxHealth
			end
			if not root:IsDescendantOf(workspace) then
				pcall(function() root.Parent = char end)
			end
			if root.Position.Y < -50 then
				pcall(function()
					if HL.Saved then
						root.CFrame = CFrame.new(HL.Saved)
					end
				end)
			end
			-- Ani pozisyon değişimini düzelt
			if HL.Saved and not HL.PullActive then
				local dist = (root.Position - HL.Saved).Magnitude
				if dist > 200 then
					pcall(function() root.CFrame = CFrame.new(HL.Saved) end)
				end
			end
		end)
	end)
end

-- ==================== YER BELİRLEME ====================
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

-- ==================== AUTOEGG ====================
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
	local duration = math.clamp(totalDist / (hum.WalkSpeed * 1.5), 0.1, 2)
	
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
		
		if t >= 1 then
			r.CFrame = CFrame.new(flatTarget.X, startPos.Y, flatTarget.Z)
			r.AssemblyLinearVelocity = Vector3.zero
			StopPull()
		end
	end)
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
		HL.Conn.AutoEgg = RunService.Heartbeat:Connect(function(dt)
			if not HL.AutoEgg then return end
			if HL.PullActive then return end
			local t = FindBestEgg()
			if t then StartPull(t) end
		end)
	else
		if HL.Conn.AutoEgg then
			HL.Conn.AutoEgg:Disconnect()
			HL.Conn.AutoEgg = nil
		end
		StopPull()
	end
end

-- ==================== RGB COOL MENÜ ====================
local function HSVToRGB(h, s, v)
	h = h % 1
	local r, g, b
	
	if s <= 0 then
		r, g, b = v, v, v
	else
		local h6 = h * 6
		local i = math.floor(h6)
		local f = h6 - i
		local p = v * (1 - s)
		local q = v * (1 - s * f)
		local t = v * (1 - s * (1 - f))
		
		if i == 0 then r, g, b = v, t, p
		elseif i == 1 then r, g, b = q, v, p
		elseif i == 2 then r, g, b = p, v, t
		elseif i == 3 then r, g, b = p, q, v
		elseif i == 4 then r, g, b = t, p, v
		else r, g, b = v, p, q end
	end
	
	return Color3.new(r, g, b)
end

local function CreateCoolMenu()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
	if not playerGui then return end
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "HamsterLiveGUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 280, 0, 260)
	main.Position = UDim2.new(0.5, -140, 0.5, -130)
	main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
	
	local stroke = Instance.new("UIStroke", main)
	stroke.Thickness = 3
	stroke.Parent = main
	
	-- RGB BAŞLIK
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	title.BorderSizePixel = 0
	title.Text = "HAMSTERLİVES THE BEST SCRİPT\nDEVELOPER XVERA"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = main
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
	
	-- Sürüklenebilir
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
		b.Size = UDim2.new(1, -24, 0, 35)
		b.Position = UDim2.new(0, 12, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
	HL.Buttons.AntiKick  = makeBtn("ANTI-KICK  ○", 60, function()
		HL.AntiKickActive = not HL.AntiKickActive
		HL.Buttons.AntiKick.Text = HL.AntiKickActive and "ANTI-KICK  ●" or "ANTI-KICK  ○"
		HL.Buttons.AntiKick.BackgroundColor3 = HL.AntiKickActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(35, 35, 45)
		if HL.AntiKickActive then StartAntiKick() end
	end)
	HL.Buttons.AntiReset = makeBtn("ANTI-RESET  ○", 100, function()
		HL.AntiResetActive = not HL.AntiResetActive
		HL.Buttons.AntiReset.Text = HL.AntiResetActive and "ANTI-RESET  ●" or "ANTI-RESET  ○"
		HL.Buttons.AntiReset.BackgroundColor3 = HL.AntiResetActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 45)
		if HL.AntiResetActive then StartAntiReset() end
	end)
	HL.Buttons.Save      = makeBtn("YER BELİLE", 140, SavePos)
	HL.Buttons.AutoEgg   = makeBtn("AUTO EGG  ○", 180, ToggleAutoEgg)
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -34, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = main
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
	
	local openBtn = Instance.new("TextButton")
	openBtn.Size = UDim2.new(0, 50, 0, 50)
	openBtn.Position = UDim2.new(1, -65, 0, 20)
	openBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
	openBtn.Text = "HL"
	openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openBtn.Font = Enum.Font.GothamBold
	openBtn.TextSize = 16
	openBtn.Parent = gui
	Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
	openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
	
	-- RGB ANİMASYON
	HL.Conn.RGB = RunService.RenderStepped:Connect(function(dt)
		HL.RGBHue = HL.RGBHue + dt * 0.3
		if HL.RGBHue > 1 then HL.RGBHue = HL.RGBHue - 1 end
		
		local rgbColor = HSVToRGB(HL.RGBHue, 1, 1)
		stroke.Color = rgbColor
		title.TextColor3 = rgbColor
		openBtn.BackgroundColor3 = rgbColor
	end)
end

CreateCoolMenu()

-- TUŞLAR
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F7 then
		HL.AntiKickActive = not HL.AntiKickActive
		if HL.AntiKickActive then StartAntiKick() end
	elseif input.KeyCode == Enum.KeyCode.F11 then
		HL.AntiResetActive = not HL.AntiResetActive
		if HL.AntiResetActive then StartAntiReset() end
	elseif input.KeyCode == Enum.KeyCode.F4 then
		SavePos()
	elseif input.KeyCode == Enum.KeyCode.F10 then
		ToggleAutoEgg()
	end
end)

print("🍑 v50 RGB COOL HAZIR")
print("🍑 F7 - ANTI-KICK")
print("🍑 F11 - ANTI-RESET")
print("🍑 F4 - YER BELİLE")
print("🍑 F10 - AUTO EGG")
print("🍑 GELİŞTİRİCİ: XVERA")
