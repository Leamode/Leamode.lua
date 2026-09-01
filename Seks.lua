--========================================================
-- HAMSTER METRO V3
-- TEK PARÇA LOCAL SCRIPT
-- OnServerEvent YOK
-- Mevcut GUI'leri SİLMEZ
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- ESKİ KENDİ MENÜMÜZ VARSA SADECE ONU TEMİZLE
-- BAŞKA HİÇBİR GUI'YE DOKUNMAZ
--========================================================

local old = PlayerGui:FindFirstChild("HamsterMetro_V3")

if old then
	old:Destroy()
end

--========================================================
-- DEĞİŞKENLER
--========================================================

local Seat = nil
local Wall = nil

local WallEnabled = false
local MetroEnabled = false

local MetroDirection = nil

local MetroSpeed = 30000

--========================================================
-- CHARACTER
--========================================================

local function GetCharacter()

	local Character = Player.Character

	if not Character then
		return nil, nil, nil
	end

	local Humanoid =
		Character:FindFirstChildOfClass("Humanoid")

	local Root =
		Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not Root then
		return nil, nil, nil
	end

	return Character, Humanoid, Root
end

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "HamsterMetro_V3"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false

Gui.Parent = PlayerGui

--========================================================
-- OPEN BUTTON
--========================================================

local Open = Instance.new("TextButton")

Open.Name = "Open"
Open.Size = UDim2.fromOffset(58,58)
Open.Position = UDim2.new(1,-72,0,90)

Open.BackgroundColor3 =
	Color3.fromRGB(170,0,0)

Open.BorderSizePixel = 0

Open.Text = "🚇"
Open.TextSize = 25

Open.TextColor3 =
	Color3.new(1,1,1)

Open.Font =
	Enum.Font.GothamBold

Open.Parent = Gui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(1,0)

OpenCorner.Parent = Open

--========================================================
-- MENU
--========================================================

local Menu = Instance.new("Frame")

Menu.Name = "Menu"

Menu.Size =
	UDim2.fromOffset(280,310)

Menu.Position =
	UDim2.new(1,-295,0,160)

Menu.BackgroundColor3 =
	Color3.fromRGB(15,15,20)

Menu.BorderSizePixel = 0

Menu.Visible = false

Menu.Parent = Gui

local MenuCorner =
	Instance.new("UICorner")

MenuCorner.CornerRadius =
	UDim.new(0,12)

MenuCorner.Parent = Menu

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(1,-55,0,45)

Title.Position =
	UDim2.fromOffset(12,5)

Title.BackgroundTransparency = 1

Title.Text =
	"🚇 HAMSTER METRO"

Title.TextColor3 =
	Color3.new(1,1,1)

Title.TextSize = 16

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent = Menu

--========================================================
-- CLOSE
--========================================================

local Close = Instance.new("TextButton")

Close.Size =
	UDim2.fromOffset(38,38)

Close.Position =
	UDim2.new(1,-43,0,6)

Close.BackgroundTransparency = 1

Close.Text = "✕"

Close.TextColor3 =
	Color3.new(1,1,1)

Close.TextSize = 20

Close.Font =
	Enum.Font.GothamBold

Close.Parent = Menu

Close.Activated:Connect(function()
	Menu.Visible = false
end)

--========================================================
-- BUTTON
--========================================================

local function MakeButton(Name,Text,Y)

	local Button =
		Instance.new("TextButton")

	Button.Name = Name

	Button.Size =
		UDim2.new(1,-20,0,50)

	Button.Position =
		UDim2.fromOffset(10,Y)

	Button.BackgroundColor3 =
		Color3.fromRGB(35,35,45)

	Button.BorderSizePixel = 0

	Button.Text = Text

	Button.TextColor3 =
		Color3.new(1,1,1)

	Button.TextSize = 13

	Button.Font =
		Enum.Font.GothamBold

	Button.Parent = Menu

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,8)

	Corner.Parent = Button

	return Button
end

local SeatButton =
	MakeButton(
		"SeatButton",
		"🪑 SANDALYE OLUŞTUR",
		55
	)

local SitButton =
	MakeButton(
		"SitButton",
		"🪑 OTUR",
		110
	)

local WallButton =
	MakeButton(
		"WallButton",
		"🧱 WALL : KAPALI",
		165
	)

local MetroButton =
	MakeButton(
		"MetroButton",
		"🚇 METRO : KAPALI",
		220
	)

--========================================================
-- SANDALYE OLUŞTUR
--========================================================

SeatButton.Activated:Connect(function()

	local Character,Humanoid,Root =
		GetCharacter()

	if not Root then
		return
	end

	-- Sadece bizim oluşturduğumuz eski sandalyeyi kaldır.
	if Seat then
		Seat:Destroy()
		Seat = nil
	end

	local NewSeat =
		Instance.new("Seat")

	NewSeat.Name =
		"HamsterMetroSeat"

	NewSeat.Size =
		Vector3.new(2.5,1,2.5)

	NewSeat.Anchored = true

	NewSeat.CanCollide = true
	NewSeat.CanTouch = true

	NewSeat.Transparency = 0

	NewSeat.CFrame =
		Root.CFrame *
		CFrame.new(0,-2.5,0)

	NewSeat.Parent =
		workspace

	Seat = NewSeat

	SeatButton.Text =
		"✓ SANDALYE OLUŞTURULDU"

	task.delay(1,function()

		if SeatButton.Parent then
			SeatButton.Text =
				"🪑 SANDALYE OLUŞTUR"
		end

	end)
end)

--========================================================
-- OTUR
--========================================================

SitButton.Activated:Connect(function()

	local Character,Humanoid,Root =
		GetCharacter()

	if not Character then
		return
	end

	if not Seat or not Seat.Parent then

		SitButton.Text =
			"ÖNCE SANDALYE OLUŞTUR"

		task.delay(1,function()

			if SitButton.Parent then
				SitButton.Text = "🪑 OTUR"
			end

		end)

		return
	end

	-- Sandalyenin üzerine götür.
	Root.CFrame =
		Seat.CFrame *
		CFrame.new(0,2.6,0)

	task.wait(0.15)

	-- Gerçek Seat oturma sistemi.
	Seat:Sit(Humanoid)

	SitButton.Text =
		"✓ OTURULDU"

	task.delay(1,function()

		if SitButton.Parent then
			SitButton.Text = "🪑 OTUR"
		end

	end)
end)

--========================================================
-- WALL
--========================================================

local function CreateWall()

	local Character,Humanoid,Root =
		GetCharacter()

	if not Root then
		return
	end

	if Wall then
		Wall:Destroy()
		Wall = nil
	end

	local NewWall =
		Instance.new("Part")

	NewWall.Name =
		"HamsterMetroWall"

	NewWall.Size =
		Vector3.new(500,300,10)

	NewWall.Anchored = true

	NewWall.CanCollide = true
	NewWall.CanTouch = false
	NewWall.CanQuery = false

	NewWall.Transparency = 1

	NewWall.CastShadow = false

	NewWall.Parent =
		workspace

	Wall = NewWall
	WallEnabled = true
end

local function RemoveWall()

	WallEnabled = false

	if Wall then
		Wall:Destroy()
		Wall = nil
	end
end

WallButton.Activated:Connect(function()

	if WallEnabled then

		RemoveWall()

		WallButton.Text =
			"🧱 WALL : KAPALI"

		WallButton.BackgroundColor3 =
			Color3.fromRGB(35,35,45)

	else

		CreateWall()

		WallButton.Text =
			"🧱 WALL : AKTİF"

		WallButton.BackgroundColor3 =
			Color3.fromRGB(0,120,70)

	end
end)

--========================================================
-- METRO
--========================================================

MetroButton.Activated:Connect(function()

	local Character,Humanoid,Root =
		GetCharacter()

	if not Root then
		return
	end

	if not MetroEnabled then

		local Camera =
			workspace.CurrentCamera

		if not Camera then
			return
		end

		-- Bastığın anda kameranın baktığı yön.
		MetroDirection =
			Camera.CFrame.LookVector.Unit

		MetroEnabled = true

		MetroButton.Text =
			"🚇 METRO : AKTİF"

		MetroButton.BackgroundColor3 =
			Color3.fromRGB(150,0,0)

	else

		MetroEnabled = false
		MetroDirection = nil

		Root.AssemblyLinearVelocity =
			Vector3.zero

		MetroButton.Text =
			"🚇 METRO : KAPALI"

		MetroButton.BackgroundColor3 =
			Color3.fromRGB(35,35,45)

	end
end)

--========================================================
-- METRO + WALL UPDATE
--========================================================

local Connection

Connection =
	RunService.RenderStepped:Connect(function(Delta)

		local Character,Humanoid,Root =
			GetCharacter()

		if not Root then
			return
		end

		-- METRO
		if MetroEnabled and MetroDirection then

			local Movement =
				MetroDirection *
				MetroSpeed *
				Delta

			Root.CFrame =
				Root.CFrame +
				Movement

			-- Sandalyeyi karakterin altında tut.
			if Seat and Seat.Parent then

				Seat.CFrame =
					Root.CFrame *
					CFrame.new(0,-2.5,0)

			end
		end

		-- WALL
		if WallEnabled and Wall then

			local Position =
				Root.Position -
				Root.CFrame.LookVector * 6

			Wall.CFrame =
				CFrame.lookAt(
					Position,
					Position +
					Root.CFrame.LookVector
				)
		end
	end)

--========================================================
-- MENU AÇ/KAPA
--========================================================

Open.Activated:Connect(function()

	Menu.Visible =
		not Menu.Visible

end)

--========================================================
-- RESPAWN
--========================================================

Player.CharacterAdded:Connect(function()

	MetroEnabled = false
	MetroDirection = nil

	if Seat then
		Seat:Destroy()
		Seat = nil
	end

	if Wall then
		Wall:Destroy()
		Wall = nil
	end

	WallEnabled = false

	WallButton.Text =
		"🧱 WALL : KAPALI"

	WallButton.BackgroundColor3 =
		Color3.fromRGB(35,35,45)

	MetroButton.Text =
		"🚇 METRO : KAPALI"

	MetroButton.BackgroundColor3 =
		Color3.fromRGB(35,35,45)
end)
