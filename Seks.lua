--============================================================
-- HAMSTER METRO SYSTEM
-- SERVER SCRIPT
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--============================================================
-- REMOTE EVENT
--============================================================

local Remote = ReplicatedStorage:FindFirstChild("MetroRemote")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "MetroRemote"
	Remote.Parent = ReplicatedStorage
end

--============================================================
-- AYARLAR
--============================================================

local WALL_SIZE = Vector3.new(150, 80, 4)
local WALL_DISTANCE = 8

-- Aşırı yüksek fizik değerleri Roblox fiziğini bozabilir.
local MAX_SPEED = 5000

--============================================================
-- OYUNCU VERİLERİ
--============================================================

local PlayerData = {}

local function GetData(Player)

	if not PlayerData[Player] then
		PlayerData[Player] = {
			Seat = nil,
			Wall = nil,
			SpeedEnabled = false,
			Direction = nil
		}
	end

	return PlayerData[Player]
end

--============================================================
-- KARAKTER
--============================================================

local function GetCharacter(Player)

	local Character = Player.Character

	if not Character then
		return nil, nil, nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")

	return Character, Humanoid, RootPart
end

--============================================================
-- SANDALYE OLUŞTUR
--============================================================

local function CreateSeat(Player)

	local Character, Humanoid, RootPart = GetCharacter(Player)

	if not Character or not Humanoid or not RootPart then
		warn("Karakter hazır değil:", Player.Name)
		return
	end

	local Data = GetData(Player)

	-- Önce eski sandalyeyi temizle
	if Data.Seat and Data.Seat.Parent then
		Data.Seat:Destroy()
	end

	local Seat = Instance.new("Seat")

	Seat.Name = "MetroSeat"

	Seat.Size = Vector3.new(2, 1, 2)

	-- Oyuncunun bulunduğu yere yakın oluştur
	Seat.CFrame =
		RootPart.CFrame *
		CFrame.new(0, -2.5, 0)

	Seat.Anchored = true
	Seat.CanCollide = true
	Seat.CanTouch = true
	Seat.Transparency = 1

	Seat.Parent = workspace

	Data.Seat = Seat

	print("[Metro] Seat oluşturuldu:", Player.Name)
end

--============================================================
-- SANDALYEYE OTUR
--============================================================

local function SitOnSeat(Player)

	local Character, Humanoid, RootPart = GetCharacter(Player)

	if not Character or not Humanoid or not RootPart then
		return
	end

	local Data = GetData(Player)

	-- Sandalye yoksa oluştur
	if not Data.Seat or not Data.Seat.Parent then
		CreateSeat(Player)
	end

	local Seat = Data.Seat

	if not Seat or not Seat.Parent then
		return
	end

	-- Karakteri sandalyenin üzerine getir
	Character:PivotTo(
		Seat.CFrame *
		CFrame.new(0, 2.5, 0)
	)

	task.wait(0.1)

	-- Oturt
	Seat:Sit(Humanoid)

	print("[Metro] Oyuncu sandalyeye oturdu:", Player.Name)
end

--============================================================
-- WALL OLUŞTUR
--============================================================

local function CreateWall(Player)

	local Character, Humanoid, RootPart = GetCharacter(Player)

	if not Character or not RootPart then
		return
	end

	local Data = GetData(Player)

	-- Eski wall varsa sil
	if Data.Wall and Data.Wall.Parent then
		Data.Wall:Destroy()
	end

	local Wall = Instance.new("Part")

	Wall.Name = "MetroRearWall_" .. Player.UserId

	Wall.Size = WALL_SIZE

	Wall.Anchored = true

	-- Görünmez
	Wall.Transparency = 1

	-- Çarpışmalı
	Wall.CanCollide = true

	Wall.CanTouch = false
	Wall.CanQuery = false

	Wall.CastShadow = false

	Wall.Parent = workspace

	Data.Wall = Wall

	-- İlk konum
	Wall.CFrame =
		RootPart.CFrame *
		CFrame.new(
			0,
			0,
			WALL_DISTANCE + (WALL_SIZE.Z / 2)
		)

	print("[Metro] Wall açıldı:", Player.Name)
end

--============================================================
-- WALL KAPAT
--============================================================

local function RemoveWall(Player)

	local Data = GetData(Player)

	if Data.Wall then

		Data.Wall:Destroy()

		Data.Wall = nil

	end

	print("[Metro] Wall kapandı:", Player.Name)
end

--============================================================
-- WALL TOGGLE
--============================================================

local function ToggleWall(Player)

	local Data = GetData(Player)

	if Data.Wall and Data.Wall.Parent then

		RemoveWall(Player)

	else

		CreateWall(Player)

	end
end

--============================================================
-- HIZI AÇ
--============================================================

local function EnableSpeed(Player, Direction)

	local Data = GetData(Player)

	if typeof(Direction) ~= "Vector3" then
		return
	end

	if Direction.Magnitude <= 0 then
		return
	end

	Data.SpeedEnabled = true
	Data.Direction = Direction.Unit

	print("[Metro] Hız açıldı:", Player.Name)
end

--============================================================
-- HIZI KAPAT
--============================================================

local function DisableSpeed(Player)

	local Data = GetData(Player)

	Data.SpeedEnabled = false
	Data.Direction = nil

	local Character, Humanoid, RootPart = GetCharacter(Player)

	if RootPart then
		RootPart.AssemblyLinearVelocity = Vector3.zero
	end

	print("[Metro] Hız kapandı:", Player.Name)
end

--============================================================
-- REMOTE EVENT
--============================================================

Remote.OnServerEvent:Connect(function(Player, Action, Value)

	if Action == "CreateSeat" then

		CreateSeat(Player)

	elseif Action == "Sit" then

		SitOnSeat(Player)

	elseif Action == "Wall" then

		ToggleWall(Player)

	elseif Action == "SpeedOn" then

		EnableSpeed(Player, Value)

	elseif Action == "SpeedOff" then

		DisableSpeed(Player)

	end
end)

--============================================================
-- SÜREKLİ SİSTEM
--============================================================

RunService.Heartbeat:Connect(function()

	for Player, Data in pairs(PlayerData) do

		local Character, Humanoid, RootPart =
			GetCharacter(Player)

		if RootPart then

			--==================================================
			-- WALL TAKİP
			--==================================================

			if Data.Wall and Data.Wall.Parent then

				Data.Wall.CFrame =
					RootPart.CFrame *
					CFrame.new(
						0,
						0,
						WALL_DISTANCE + (WALL_SIZE.Z / 2)
					)

			end

			--==================================================
			-- HIZ
			--==================================================

			if Data.SpeedEnabled
				and Data.Direction
				and Data.Direction.Magnitude > 0 then

				RootPart.AssemblyLinearVelocity =
					Data.Direction * MAX_SPEED

			end
		end
	end
end)

--============================================================
-- KARAKTER YENİLENMESİ
--============================================================

local function SetupPlayer(Player)

	GetData(Player)

	Player.CharacterAdded:Connect(function()

		local Data = GetData(Player)

		-- Eski wall yeni karaktere taşınmasın
		if Data.Wall then
			Data.Wall:Destroy()
			Data.Wall = nil
		end

		Data.SpeedEnabled = false
		Data.Direction = nil
		Data.Seat = nil

	end)
end

Players.PlayerAdded:Connect(SetupPlayer)

for _, Player in ipairs(Players:GetPlayers()) do
	SetupPlayer(Player)
end

--============================================================
-- OYUNCU ÇIKIŞI
--============================================================

Players.PlayerRemoving:Connect(function(Player)

	local Data = PlayerData[Player]

	if Data then

		if Data.Seat then
			Data.Seat:Destroy()
		end

		if Data.Wall then
			Data.Wall:Destroy()
		end

	end

	PlayerData[Player] = nil
end)

print("============================================")
print("🚇 HAMSTER METRO SERVER SYSTEM HAZIR")
print("============================================")--============================================================
-- HAMSTER METRO SYSTEM
-- CLIENT / MOBILE GUI
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Remote = ReplicatedStorage:WaitForChild("MetroRemote")

--============================================================
-- ESKİ GUI TEMİZLE
--============================================================

local OldGui = PlayerGui:FindFirstChild("HamsterMetroUI")

if OldGui then
	OldGui:Destroy()
end

--============================================================
-- ANA GUI
--============================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "HamsterMetroUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

Gui.Parent = PlayerGui

--============================================================
-- AÇMA BUTONU
--============================================================

local OpenButton = Instance.new("TextButton")

OpenButton.Name = "OpenButton"

OpenButton.Size = UDim2.fromOffset(55, 55)

OpenButton.Position =
	UDim2.new(1, -70, 0, 80)

OpenButton.BackgroundColor3 =
	Color3.fromRGB(170, 0, 0)

OpenButton.Text = "🚇"

OpenButton.TextColor3 =
	Color3.fromRGB(255, 255, 255)

OpenButton.TextSize = 25

OpenButton.Font =
	Enum.Font.GothamBold

OpenButton.Active = true

OpenButton.AutoButtonColor = true

OpenButton.Parent = Gui

local OpenCorner = Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(1, 0)

OpenCorner.Parent = OpenButton

--============================================================
-- ANA PANEL
--============================================================

local Panel = Instance.new("Frame")

Panel.Name = "MetroPanel"

Panel.Size =
	UDim2.fromOffset(240, 250)

Panel.Position =
	UDim2.new(1, -255, 0, 145)

Panel.BackgroundColor3 =
	Color3.fromRGB(15, 15, 20)

Panel.Visible = false

Panel.Active = true

Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")

PanelCorner.CornerRadius =
	UDim.new(0, 10)

PanelCorner.Parent = Panel

local PanelStroke = Instance.new("UIStroke")

PanelStroke.Thickness = 2

PanelStroke.Transparency = 0.25

PanelStroke.Parent = Panel

--============================================================
-- BAŞLIK
--============================================================

local Title = Instance.new("TextLabel")

Title.Name = "Title"

Title.Size =
	UDim2.new(1, 0, 0, 40)

Title.BackgroundColor3 =
	Color3.fromRGB(150, 0, 0)

Title.Text = "🚇 METRO SYSTEM"

Title.TextColor3 =
	Color3.fromRGB(255, 255, 255)

Title.TextSize = 15

Title.Font =
	Enum.Font.GothamBold

Title.Parent = Panel

local TitleCorner = Instance.new("UICorner")

TitleCorner.CornerRadius =
	UDim.new(0, 10)

TitleCorner.Parent = Title

--============================================================
-- BUTON FONKSİYONU
--============================================================

local function CreateButton(Name, Text, Y)

	local Button = Instance.new("TextButton")

	Button.Name = Name

	Button.Size =
		UDim2.new(1, -20, 0, 42)

	Button.Position =
		UDim2.fromOffset(10, Y)

	Button.BackgroundColor3 =
		Color3.fromRGB(35, 35, 45)

	Button.Text = Text

	Button.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	Button.TextSize = 12

	Button.Font =
		Enum.Font.GothamBold

	Button.Active = true

	Button.AutoButtonColor = true

	Button.Parent = Panel

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0, 7)

	Corner.Parent = Button

	return Button
end

--============================================================
-- BUTONLAR
--============================================================

local CreateSeatButton =
	CreateButton(
		"CreateSeat",
		"🪑 SANDALYE OLUŞTUR",
		50
	)

local SitButton =
	CreateButton(
		"Sit",
		"🪑 OTUR",
		100
	)

local WallButton =
	CreateButton(
		"Wall",
		"🧱 WALL: KAPALI",
		150
	)

local SpeedButton =
	CreateButton(
		"Speed",
		"🚀 HIZ: KAPALI",
		200
	)

--============================================================
-- MENÜ AÇ / KAPAT
--============================================================

OpenButton.Activated:Connect(function()

	Panel.Visible =
		not Panel.Visible

end)

--============================================================
-- SANDALYE OLUŞTUR
--============================================================

CreateSeatButton.Activated:Connect(function()

	CreateSeatButton.Text =
		"⏳ OLUŞTURULUYOR..."

	Remote:FireServer(
		"CreateSeat"
	)

	task.wait(0.4)

	CreateSeatButton.Text =
		"✅ SANDALYE OLUŞTURULDU"

	task.wait(1)

	if CreateSeatButton.Parent then

		CreateSeatButton.Text =
			"🪑 SANDALYE OLUŞTUR"

	end

end)

--============================================================
-- OTUR
--============================================================

SitButton.Activated:Connect(function()

	SitButton.Text =
		"🪑 OTURUYOR..."

	Remote:FireServer(
		"Sit"
	)

	task.wait(0.5)

	if SitButton.Parent then

		SitButton.Text =
			"🪑 OTUR"

	end

end)

--============================================================
-- WALL
--============================================================

local WallActive = false

WallButton.Activated:Connect(function()

	WallActive =
		not WallActive

	Remote:FireServer(
		"Wall"
	)

	if WallActive then

		WallButton.Text =
			"🧱 WALL: AÇIK"

		WallButton.BackgroundColor3 =
			Color3.fromRGB(150, 0, 0)

	else

		WallButton.Text =
			"🧱 WALL: KAPALI"

		WallButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 45)

	end

end)

--============================================================
-- HIZ
--============================================================

local SpeedActive = false

SpeedButton.Activated:Connect(function()

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	SpeedActive =
		not SpeedActive

	if SpeedActive then

		-- Kameranın baktığı yön
		local Look =
			Camera.CFrame.LookVector

		-- Y eksenini çıkar
		local Direction =
			Vector3.new(
				Look.X,
				0,
				Look.Z
			)

		if Direction.Magnitude <= 0 then

			SpeedActive = false

			return

		end

		Direction =
			Direction.Unit

		Remote:FireServer(
			"SpeedOn",
			Direction
		)

		SpeedButton.Text =
			"🚀 HIZ: AÇIK"

		SpeedButton.BackgroundColor3 =
			Color3.fromRGB(150, 0, 0)

	else

		Remote:FireServer(
			"SpeedOff"
		)

		SpeedButton.Text =
			"🚀 HIZ: KAPALI"

		SpeedButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 45)

	end

end)

--============================================================
-- RESPAWN
--============================================================

Player.CharacterAdded:Connect(function()

	task.wait(1)

	SpeedActive = false
	WallActive = false

	SpeedButton.Text =
		"🚀 HIZ: KAPALI"

	SpeedButton.BackgroundColor3 =
		Color3.fromRGB(35, 35, 45)

	WallButton.Text =
		"🧱 WALL: KAPALI"

	WallButton.BackgroundColor3 =
		Color3.fromRGB(35, 35, 45)

end)

print("============================================")
print("🚇 HAMSTER METRO CLIENT HAZIR")
print("📱 Mobil Activated desteği aktif")
print("🪑 Seat sistemi aktif")
print("🧱 Wall sistemi aktif")
print("🚀 Speed sistemi aktif")
print("============================================")
