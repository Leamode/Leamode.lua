--==================================================
-- GUARD RIDE + REAR WALL
-- SERVER SCRIPT
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remote = ReplicatedStorage:FindFirstChild("GuardRideRemote")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "GuardRideRemote"
	Remote.Parent = ReplicatedStorage
end

local SEAT_HEIGHT = 3
local WALL_DISTANCE = 8
local WALL_SIZE = Vector3.new(100, 100, 4)

local playerData = {}

--==================================================
-- GUARD BUL
--==================================================

local function GetGuards()
	local guards = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and string.lower(obj.Name):match("^guard") then
			table.insert(guards, obj)
		end
	end

	return guards
end

local function GetGuardRoot(guard)
	if guard.PrimaryPart then
		return guard.PrimaryPart
	end

	return guard:FindFirstChild("HumanoidRootPart")
		or guard:FindFirstChild("Head")
		or guard:FindFirstChildWhichIsA("BasePart", true)
end

--==================================================
-- GUARD SEAT
--==================================================

local function CreateGuardSeat(guard)
	if guard:FindFirstChild("GuardRideSeat") then
		return guard.GuardRideSeat
	end

	local root = GetGuardRoot(guard)

	if not root then
		return nil
	end

	local seat = Instance.new("Seat")
	seat.Name = "GuardRideSeat"

	seat.Size = Vector3.new(2, 1, 2)
	seat.Transparency = 1
	seat.CanCollide = true
	seat.CanTouch = true

	seat.CFrame = root.CFrame * CFrame.new(0, SEAT_HEIGHT, 0)
	seat.Parent = guard

	local weld = Instance.new("WeldConstraint")
	weld.Name = "GuardRideWeld"
	weld.Part0 = seat
	weld.Part1 = root
	weld.Parent = seat

	return seat
end

--==================================================
-- TÜM GUARDLARA SEAT
--==================================================

local function SetupGuards()
	for _, guard in ipairs(GetGuards()) do
		CreateGuardSeat(guard)
	end
end

SetupGuards()

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Model") and string.lower(obj.Name):match("^guard") then
		task.wait(0.1)
		CreateGuardSeat(obj)
	end
end)

--==================================================
-- EN YAKIN GUARD
--==================================================

local function GetNearestGuard(player)
	local character = player.Character

	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local nearest = nil
	local nearestDistance = math.huge

	for _, guard in ipairs(GetGuards()) do
		local guardRoot = GetGuardRoot(guard)

		if guardRoot then
			local distance = (root.Position - guardRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearest = guard
			end
		end
	end

	return nearest
end

--==================================================
-- GUARD'A OTUR
--==================================================

local function RideGuard(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local guard = GetNearestGuard(player)

	if not guard then
		warn("Guard bulunamadı:", player.Name)
		return
	end

	local seat = CreateGuardSeat(guard)

	if not seat then
		warn("Guard için Seat oluşturulamadı:", guard.Name)
		return
	end

	humanoid.Sit = false
	task.wait()

	-- Oyuncuyu seat'in üstüne getir
	character:PivotTo(
		seat.CFrame * CFrame.new(0, 2, 0)
	)

	task.wait(0.1)

	seat:Sit(humanoid)

	playerData[player] = playerData[player] or {}
	playerData[player].Guard = guard
	playerData[player].Seat = seat

	print(player.Name, "->", guard.Name, "üzerine oturdu")
end

--==================================================
-- WALL
--==================================================

local function CreateWall(player)
	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	playerData[player] = playerData[player] or {}

	if playerData[player].Wall then
		playerData[player].Wall:Destroy()
	end

	local wall = Instance.new("Part")

	wall.Name = "RearWall_" .. player.UserId
	wall.Size = WALL_SIZE

	wall.Transparency = 1
	wall.CanCollide = true
	wall.CanTouch = false
	wall.CanQuery = false

	wall.Anchored = true
	wall.Parent = workspace

	playerData[player].Wall = wall

	-- İlk konum
	wall.CFrame =
		root.CFrame
		* CFrame.new(0, 0, WALL_DISTANCE + WALL_SIZE.Z / 2)

	print("Wall aktif:", player.Name)
end

local function RemoveWall(player)
	if playerData[player] and playerData[player].Wall then
		playerData[player].Wall:Destroy()
		playerData[player].Wall = nil
	end
end

--==================================================
-- WALL TAKİP
--==================================================

RunService.Heartbeat:Connect(function()
	for player, data in pairs(playerData) do

		if data.Wall then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")

			if root then
				-- Oyuncunun tam arkasında kalır
				data.Wall.CFrame =
					root.CFrame
					* CFrame.new(
						0,
						0,
						WALL_DISTANCE + WALL_SIZE.Z / 2
					)
			end
		end
	end
end)

--==================================================
-- REMOTE
--==================================================

Remote.OnServerEvent:Connect(function(player, action)

	if action == "RideGuard" then
		RideGuard(player)

	elseif action == "Wall" then

		local data = playerData[player]

		if data and data.Wall then
			RemoveWall(player)
		else
			CreateWall(player)
		end

	end
end)

--==================================================
-- TEMİZLİK
--==================================================

Players.PlayerRemoving:Connect(function(player)

	if playerData[player] then

		if playerData[player].Wall then
			playerData[player].Wall:Destroy()
		end

		playerData[player] = nil
	end
end)
