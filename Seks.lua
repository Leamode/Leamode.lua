-- HAMSTER METRO - SERVER
-- Roblox Studio / ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remote = ReplicatedStorage:FindFirstChild("MetroRemote")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "MetroRemote"
	Remote.Parent = ReplicatedStorage
end

local Data = {}

local METRO_SPEED = 30000
local WALL_DISTANCE = 8
local WALL_SIZE = Vector3.new(500, 300, 20)

local function getCharacter(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then return end

	return character, humanoid, root
end

local function createSeat(player)
	local character, humanoid, root = getCharacter(player)
	if not root then return end

	local old = Data[player] and Data[player].Seat

	if old then
		old:Destroy()
	end

	local seat = Instance.new("Seat")
	seat.Name = "MetroSeat_" .. player.UserId
	seat.Size = Vector3.new(2.5, 1, 2.5)
	seat.Anchored = true
	seat.CanCollide = true
	seat.CanTouch = true
	seat.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
	seat.Parent = workspace

	Data[player] = Data[player] or {}
	Data[player].Seat = seat
end

local function sit(player)
	local character, humanoid, root = getCharacter(player)
	if not root then return end

	local info = Data[player]
	if not info or not info.Seat then return end

	local seat = info.Seat

	-- Sandalyenin üzerine yerleştir.
	root.CFrame = seat.CFrame * CFrame.new(0, 2.5, 0)

	task.wait()

	seat:Sit(humanoid)
end

local function createWall(player)
	local character, humanoid, root = getCharacter(player)
	if not root then return end

	local info = Data[player] or {}
	Data[player] = info

	if info.Wall then
		info.Wall:Destroy()
	end

	local wall = Instance.new("Part")
	wall.Name = "MetroWall_" .. player.UserId
	wall.Size = WALL_SIZE
	wall.Anchored = true
	wall.CanCollide = true
	wall.CanTouch = true
	wall.CanQuery = true
	wall.Transparency = 1
	wall.CastShadow = false
	wall.Parent = workspace

	info.Wall = wall
	info.WallEnabled = true
	info.SpawnPosition = info.SpawnPosition or root.Position
end

local function removeWall(player)
	local info = Data[player]

	if not info then return end

	info.WallEnabled = false

	if info.Wall then
		info.Wall:Destroy()
		info.Wall = nil
	end
end

Remote.OnServerEvent:Connect(function(player, action, direction)

	local info = Data[player] or {}
	Data[player] = info

	if action == "CreateSeat" then

		createSeat(player)

	elseif action == "Sit" then

		sit(player)

	elseif action == "Wall" then

		if info.WallEnabled then
			removeWall(player)
		else
			createWall(player)
		end

	elseif action == "Metro" then

		local character, humanoid, root = getCharacter(player)
		if not root then return end

		if typeof(direction) ~= "Vector3" then
			return
		end

		if direction.Magnitude < 0.01 then
			return
		end

		info.MetroEnabled = not info.MetroEnabled

		if info.MetroEnabled then
			info.Direction = direction.Unit
		else
			info.Direction = nil
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end)

-- Duvarı oyuncunun arkasında tut.
RunService.Heartbeat:Connect(function(dt)

	for player, info in pairs(Data) do

		local character, humanoid, root = getCharacter(player)

		if root then

			-- WALL
			if info.WallEnabled and info.Wall then

				local behind =
					root.Position -
					root.CFrame.LookVector *
					WALL_DISTANCE

				info.Wall.CFrame =
					CFrame.lookAt(
						behind,
						behind + root.CFrame.LookVector
					)
			end

			-- METRO
			if info.MetroEnabled and info.Direction then

				local movement =
					info.Direction *
					METRO_SPEED *
					dt

				root.CFrame =
					root.CFrame +
					movement

				-- Sandalyeyi karakterin altında tut.
				if info.Seat and info.Seat.Parent then
					info.Seat.CFrame =
						root.CFrame *
						CFrame.new(0, -2.5, 0)
				end
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)

	Data[player] = {
		SpawnPosition = nil,
		Seat = nil,
		Wall = nil,
		WallEnabled = false,
		MetroEnabled = false,
		Direction = nil
	}

	player.CharacterAdded:Connect(function(character)

		local root =
			character:WaitForChild(
				"HumanoidRootPart",
				10
			)

		if root then
			Data[player].SpawnPosition = root.Position
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)

	local info = Data[player]

	if info then

		if info.Seat then
			info.Seat:Destroy()
		end

		if info.Wall then
			info.Wall:Destroy()
		end
	end

	Data[player] = nil
end)-- HAMSTER METRO - CLIENT
-- Roblox Studio / StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Remote =
	ReplicatedStorage:WaitForChild("MetroRemote")

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterMetro"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(55,55)
open.Position = UDim2.new(1,-70,0,80)
open.Text = "🚇"
open.TextSize = 24
open.BackgroundColor3 = Color3.fromRGB(170,0,0)
open.TextColor3 = Color3.new(1,1,1)
open.Font = Enum.Font.GothamBold
open.Parent = gui

Instance.new("UICorner",open).CornerRadius =
	UDim.new(1,0)

local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(250,270)
menu.Position = UDim2.new(1,-265,0,145)
menu.BackgroundColor3 = Color3.fromRGB(15,15,20)
menu.Visible = false
menu.Parent = gui

Instance.new("UICorner",menu).CornerRadius =
	UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-45,0,40)
title.Position = UDim2.fromOffset(10,5)
title.BackgroundTransparency = 1
title.Text = "🚇 HAMSTER METRO"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = menu

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35,35)
close.Position = UDim2.new(1,-40,0,5)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 18
close.Parent = menu

close.Activated:Connect(function()
	menu.Visible = false
end)

local function button(text,y)

	local b = Instance.new("TextButton")

	b.Size =
		UDim2.new(1,-20,0,45)

	b.Position =
		UDim2.fromOffset(10,y)

	b.BackgroundColor3 =
		Color3.fromRGB(35,35,45)

	b.Text =
		text

	b.TextColor3 =
		Color3.new(1,1,1)

	b.TextSize = 12

	b.Font =
		Enum.Font.GothamBold

	b.Parent =
		menu

	Instance.new("UICorner",b).CornerRadius =
		UDim.new(0,7)

	return b
end

local seatButton =
	button("🪑 SANDALYE OLUŞTUR",50)

local sitButton =
	button("🪑 OTUR",100)

local wallButton =
	button("🧱 WALL : KAPALI",150)

local metroButton =
	button("🚇 METRO : KAPALI",200)

--==================================================
-- SANDALYE
--==================================================

seatButton.Activated:Connect(function()

	Remote:FireServer("CreateSeat")

	seatButton.Text =
		"🪑 SANDALYE OLUŞTURULDU"

	task.delay(1,function()

		if seatButton then
			seatButton.Text =
				"🪑 SANDALYE OLUŞTUR"
		end

	end)
end)

--==================================================
-- OTUR
--==================================================

sitButton.Activated:Connect(function()

	Remote:FireServer("Sit")

	sitButton.Text =
		"🪑 OTURULDU"

end)

--==================================================
-- WALL
--==================================================

local wallOn = false

wallButton.Activated:Connect(function()

	wallOn = not wallOn

	Remote:FireServer("Wall")

	if wallOn then

		wallButton.Text =
			"🧱 WALL : AKTİF"

		wallButton.BackgroundColor3 =
			Color3.fromRGB(0,120,70)

	else

		wallButton.Text =
			"🧱 WALL : KAPALI"

		wallButton.BackgroundColor3 =
			Color3.fromRGB(35,35,45)

	end
end)

--==================================================
-- METRO
--==================================================

local metroOn = false

metroButton.Activated:Connect(function()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	if not metroOn then

		-- Bastığın anda baktığın yön.
		local direction =
			camera.CFrame.LookVector.Unit

		metroOn = true

		Remote:FireServer(
			"Metro",
			direction
		)

		metroButton.Text =
			"🚇 METRO : AKTİF"

		metroButton.BackgroundColor3 =
			Color3.fromRGB(150,0,0)

	else

		metroOn = false

		Remote:FireServer("Metro")

		metroButton.Text =
			"🚇 METRO : KAPALI"

		metroButton.BackgroundColor3 =
			Color3.fromRGB(35,35,45)

	end
end)

--==================================================
-- MENÜ
--==================================================

open.Activated:Connect(function()

	menu.Visible =
		not menu.Visible

end)
