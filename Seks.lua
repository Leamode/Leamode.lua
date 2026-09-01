--// HAMSTER METRO V2 - SERVER
--// ServerScriptService içine normal Script olarak koy.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Sadece kendi RemoteEvent'imizi kullanıyoruz.
local remote = ReplicatedStorage:FindFirstChild("HamsterMetroRemote")

if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "HamsterMetroRemote"
	remote.Parent = ReplicatedStorage
end

local playerData = {}

local METRO_SPEED = 30000
local SEAT_OFFSET = CFrame.new(0, -2.5, 0)

local function getCharacter(player)
	local character = player.Character
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return nil
	end

	return character, humanoid, root
end

local function getData(player)
	if not playerData[player] then
		playerData[player] = {
			seat = nil,
			metro = false,
			direction = nil,
			wall = nil,
			wallEnabled = false
		}
	end

	return playerData[player]
end

--==================================================
-- SANDALYE
--==================================================

local function createSeat(player)

	local character, humanoid, root = getCharacter(player)
	if not root then
		return
	end

	local data = getData(player)

	if data.seat then
		data.seat:Destroy()
		data.seat = nil
	end

	local seat = Instance.new("Seat")

	seat.Name = "HamsterMetroSeat_" .. player.UserId
	seat.Size = Vector3.new(2.5, 1, 2.5)

	seat.Anchored = true
	seat.CanCollide = true
	seat.CanTouch = true

	seat.CFrame = root.CFrame * SEAT_OFFSET

	seat.Parent = workspace

	data.seat = seat
end

--==================================================
-- OTUR
--==================================================

local function sitPlayer(player)

	local character, humanoid, root = getCharacter(player)
	if not root then
		return
	end

	local data = getData(player)
	local seat = data.seat

	if not seat or not seat.Parent then
		return
	end

	-- Önce karakteri sandalyenin üzerine götür.
	root.CFrame = seat.CFrame * CFrame.new(0, 2.5, 0)

	task.wait(0.1)

	-- Gerçek Roblox Seat.
	seat:Sit(humanoid)
end

--==================================================
-- WALL
--==================================================

local function enableWall(player)

	local character, humanoid, root = getCharacter(player)
	if not root then
		return
	end

	local data = getData(player)

	if data.wall then
		data.wall:Destroy()
	end

	local wall = Instance.new("Part")

	wall.Name = "HamsterMetroWall_" .. player.UserId

	wall.Size = Vector3.new(500, 100, 5)

	wall.Anchored = true
	wall.CanCollide = true
	wall.CanTouch = false
	wall.CanQuery = false

	wall.Transparency = 1

	wall.Parent = workspace

	data.wall = wall
	data.wallEnabled = true
end

local function disableWall(player)

	local data = getData(player)

	data.wallEnabled = false

	if data.wall then
		data.wall:Destroy()
		data.wall = nil
	end
end

--==================================================
-- REMOTE
--==================================================

remote.OnServerEvent:Connect(function(player, action, value)

	if typeof(action) ~= "string" then
		return
	end

	local data = getData(player)

	if action == "CreateSeat" then

		createSeat(player)

	elseif action == "Sit" then

		sitPlayer(player)

	elseif action == "Wall" then

		if data.wallEnabled then
			disableWall(player)
		else
			enableWall(player)
		end

	elseif action == "Metro" then

		if typeof(value) ~= "Vector3" then
			return
		end

		if value.Magnitude < 0.01 then
			return
		end

		data.metro = true
		data.direction = value.Unit

	elseif action == "StopMetro" then

		data.metro = false
		data.direction = nil

		local character, humanoid, root = getCharacter(player)

		if root then
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end)

--==================================================
-- METRO / WALL UPDATE
--==================================================

RunService.Heartbeat:Connect(function(deltaTime)

	for player, data in pairs(playerData) do

		local character, humanoid, root = getCharacter(player)

		if root then

			-- METRO
			if data.metro and data.direction then

				local movement =
					data.direction *
					METRO_SPEED *
					deltaTime

				root.CFrame =
					root.CFrame + movement

				-- Sandalye karakterle beraber hareket eder.
				if data.seat and data.seat.Parent then
					data.seat.CFrame =
						root.CFrame *
						SEAT_OFFSET
				end
			end

			-- WALL
			if data.wallEnabled and data.wall then

				local position =
					root.Position -
					root.CFrame.LookVector * 6

				data.wall.CFrame =
					CFrame.lookAt(
						position,
						position + root.CFrame.LookVector
					)
			end
		end
	end
end)

--==================================================
-- PLAYER
--==================================================

Players.PlayerAdded:Connect(function(player)

	playerData[player] = {
		seat = nil,
		metro = false,
		direction = nil,
		wall = nil,
		wallEnabled = false
	}

	player.CharacterRemoving:Connect(function()

		local data = playerData[player]

		if data then
			data.metro = false
			data.direction = nil

			if data.seat then
				data.seat:Destroy()
				data.seat = nil
			end

			if data.wall then
				data.wall:Destroy()
				data.wall = nil
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)

	local data = playerData[player]

	if data then

		if data.seat then
			data.seat:Destroy()
		end

		if data.wall then
			data.wall:Destroy()
		end
	end

	playerData[player] = nil
end)--// HAMSTER METRO V2 - CLIENT
--// StarterPlayer > StarterPlayerScripts içine LocalScript koy.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Server'ın oluşturduğu RemoteEvent'i bekle.
local remote = ReplicatedStorage:WaitForChild(
	"HamsterMetroRemote",
	15
)

if not remote then
	warn("HamsterMetroRemote bulunamadı.")
	return
end

--==================================================
-- SADECE KENDİ GUI'MİZ
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterMetro_V2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false

-- ÖNEMLİ:
-- Mevcut GUI'lere dokunmuyoruz.
-- Hiçbir GUI Destroy edilmiyor.
gui.Parent = playerGui

--==================================================
-- AÇ/KAPA
--==================================================

local openButton = Instance.new("TextButton")

openButton.Name = "OpenButton"
openButton.Size = UDim2.fromOffset(55, 55)
openButton.Position = UDim2.new(1, -70, 0, 100)

openButton.BackgroundColor3 =
	Color3.fromRGB(170, 0, 0)

openButton.Text = "🚇"
openButton.TextSize = 24
openButton.TextColor3 = Color3.new(1, 1, 1)

openButton.Font =
	Enum.Font.GothamBold

openButton.Parent = gui

local openCorner =
	Instance.new("UICorner")

openCorner.CornerRadius =
	UDim.new(1, 0)

openCorner.Parent =
	openButton

--==================================================
-- ANA MENÜ
--==================================================

local menu = Instance.new("Frame")

menu.Name = "MetroMenu"

menu.Size =
	UDim2.fromOffset(270, 300)

menu.Position =
	UDim2.new(1, -285, 0, 165)

menu.BackgroundColor3 =
	Color3.fromRGB(15, 15, 20)

menu.BorderSizePixel = 0

menu.Visible = false

menu.Parent = gui

local menuCorner =
	Instance.new("UICorner")

menuCorner.CornerRadius =
	UDim.new(0, 12)

menuCorner.Parent =
	menu

--==================================================
-- BAŞLIK
--==================================================

local title = Instance.new("TextLabel")

title.Name = "Title"

title.Size =
	UDim2.new(1, -50, 0, 45)

title.Position =
	UDim2.fromOffset(12, 5)

title.BackgroundTransparency = 1

title.Text =
	"🚇 HAMSTER METRO"

title.TextColor3 =
	Color3.new(1, 1, 1)

title.TextSize = 16

title.Font =
	Enum.Font.GothamBold

title.TextXAlignment =
	Enum.TextXAlignment.Left

title.Parent =
	menu

--==================================================
-- KAPAT
--==================================================

local closeButton =
	Instance.new("TextButton")

closeButton.Name = "Close"

closeButton.Size =
	UDim2.fromOffset(35, 35)

closeButton.Position =
	UDim2.new(1, -42, 0, 7)

closeButton.BackgroundTransparency = 1

closeButton.Text = "X"

closeButton.TextSize = 18

closeButton.TextColor3 =
	Color3.new(1, 1, 1)

closeButton.Font =
	Enum.Font.GothamBold

closeButton.Parent =
	menu

--==================================================
-- BUTTON FONKSİYONU
--==================================================

local function makeButton(name, text, y)

	local button =
		Instance.new("TextButton")

	button.Name = name

	button.Size =
		UDim2.new(1, -20, 0, 48)

	button.Position =
		UDim2.fromOffset(10, y)

	button.BackgroundColor3 =
		Color3.fromRGB(35, 35, 45)

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextSize = 13

	button.Font =
		Enum.Font.GothamBold

	button.Parent =
		menu

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 8)

	corner.Parent =
		button

	return button
end

--==================================================
-- BUTONLAR
--==================================================

local seatButton =
	makeButton(
		"SeatButton",
		"🪑 SANDALYE OLUŞTUR",
		55
	)

local sitButton =
	makeButton(
		"SitButton",
		"🪑 OTUR",
		110
	)

local wallButton =
	makeButton(
		"WallButton",
		"🧱 WALL : KAPALI",
		165
	)

local metroButton =
	makeButton(
		"MetroButton",
		"🚇 METRO : KAPALI",
		220
	)

--==================================================
-- SANDALYE
--==================================================

seatButton.Activated:Connect(function()

	remote:FireServer("CreateSeat")

	seatButton.Text =
		"✓ SANDALYE OLUŞTURULDU"

	task.delay(1.2, function()

		if seatButton.Parent then

			seatButton.Text =
				"🪑 SANDALYE OLUŞTUR"

		end
	end)
end)

--==================================================
-- OTUR
--==================================================

sitButton.Activated:Connect(function()

	remote:FireServer("Sit")

	sitButton.Text =
		"✓ OTURULDU"

	task.delay(1, function()

		if sitButton.Parent then
			sitButton.Text = "🪑 OTUR"
		end

	end)
end)

--==================================================
-- WALL
--==================================================

local wallEnabled = false

wallButton.Activated:Connect(function()

	wallEnabled =
		not wallEnabled

	remote:FireServer("Wall")

	if wallEnabled then

		wallButton.Text =
			"🧱 WALL : AKTİF"

		wallButton.BackgroundColor3 =
			Color3.fromRGB(0, 120, 70)

	else

		wallButton.Text =
			"🧱 WALL : KAPALI"

		wallButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 45)

	end
end)

--==================================================
-- METRO
--==================================================

local metroEnabled = false

metroButton.Activated:Connect(function()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	if not metroEnabled then

		local direction =
			camera.CFrame.LookVector.Unit

		metroEnabled = true

		-- Kameranın o anda baktığı yönü server'a gönder.
		remote:FireServer(
			"Metro",
			direction
		)

		metroButton.Text =
			"🚇 METRO : AKTİF"

		metroButton.BackgroundColor3 =
			Color3.fromRGB(150, 0, 0)

	else

		metroEnabled = false

		remote:FireServer(
			"StopMetro"
		)

		metroButton.Text =
			"🚇 METRO : KAPALI"

		metroButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 45)

	end
end)

--==================================================
-- MENÜ AÇ / KAPA
--==================================================

openButton.Activated:Connect(function()

	menu.Visible =
		not menu.Visible

end)

closeButton.Activated:Connect(function()

	menu.Visible = false

end)
