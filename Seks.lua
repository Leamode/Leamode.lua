
--========================================================--
-- HAMSTER LIVES - DELTA METRO / WALL / SEAT
-- CLIENT SIDE - PLAYERGUI
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--========================================================--
-- AYARLAR
--========================================================--

local FORWARD_SPEED = 100000000000000 -- 100 TRİLYON
local WALL_DISTANCE = 5
local WALL_SIZE = Vector3.new(100, 100, 10)

local MetroEnabled = false
local WallEnabled = false
local SeatEnabled = false

local MetroDirection = nil
local WallPart = nil
local SeatPart = nil
local Connection = nil

--========================================================--
-- KARAKTER
--========================================================--

local function Character()
    local char = LP.Character
    if not char then
        return nil
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum then
        return nil
    end

    return char, hrp, hum
end

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "HamsterMetroDelta"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PG

-- AÇ/KAPA BUTONU

local Open = Instance.new("TextButton")
Open.Name = "OpenButton"
Open.Size = UDim2.fromOffset(55,55)
Open.Position = UDim2.new(1,-70,0,80)
Open.BackgroundColor3 = Color3.fromRGB(170,0,0)
Open.Text = "🚇"
Open.TextSize = 24
Open.TextColor3 = Color3.new(1,1,1)
Open.Font = Enum.Font.GothamBold
Open.Parent = Gui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1,0)
OpenCorner.Parent = Open

-- ANA MENÜ

local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(250,250)
Menu.Position = UDim2.new(1,-265,0,145)
Menu.BackgroundColor3 = Color3.fromRGB(15,15,20)
Menu.BackgroundTransparency = 0.05
Menu.Visible = false
Menu.Parent = Gui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0,10)
MenuCorner.Parent = Menu

local Border = Instance.new("UIStroke")
Border.Thickness = 2
Border.Color = Color3.fromRGB(220,170,0)
Border.Parent = Menu

-- BAŞLIK

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,40)
Title.Position = UDim2.fromOffset(10,5)
Title.BackgroundTransparency = 1
Title.Text = "🚇 METRO MOD"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Menu

-- KAPAT

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35,35)
Close.Position = UDim2.new(1,-40,0,5)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.Parent = Menu

Close.Activated:Connect(function()
    Menu.Visible = false
end)

--========================================================--
-- BUTON OLUŞTURUCU
--========================================================--

local function MakeButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,45)
    b.Position = UDim2.fromOffset(10,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,50)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = Menu

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,7)
    c.Parent = b

    return b
end

local MetroButton = MakeButton("🚇 METRO : KAPALI",50)
local WallButton = MakeButton("🧱 WALL : KAPALI",100)
local SeatButton = MakeButton("🪑 OTUR : OLUŞTUR",150)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1,-20,0,35)
Info.Position = UDim2.fromOffset(10,205)
Info.BackgroundTransparency = 1
Info.Text = "Yön = butona bastığın anda baktığın yön"
Info.TextColor3 = Color3.fromRGB(160,160,160)
Info.TextSize = 10
Info.Font = Enum.Font.Gotham
Info.TextWrapped = true
Info.Parent = Menu

--========================================================--
-- DUVAR
--========================================================--

local function CreateWall()
    if WallPart and WallPart.Parent then
        return
    end

    WallPart = Instance.new("Part")
    WallPart.Name = "MetroInvisibleWall"
    WallPart.Size = WALL_SIZE
    WallPart.Transparency = 1
    WallPart.Anchored = true
    WallPart.CanCollide = true
    WallPart.CanTouch = false
    WallPart.CanQuery = false
    WallPart.CastShadow = false
    WallPart.Parent = workspace
end

local function DestroyWall()
    if WallPart then
        pcall(function()
            WallPart:Destroy()
        end)
        WallPart = nil
    end
end

local function UpdateWall(hrp)
    if not WallEnabled or not WallPart then
        return
    end

    -- Karakterin tam arkasında
    local pos = hrp.Position - hrp.CFrame.LookVector * WALL_DISTANCE

    WallPart.CFrame =
        CFrame.lookAt(
            pos,
            pos + hrp.CFrame.LookVector
        )
end

--========================================================--
-- SANDALYE
--========================================================--

local function CreateSeat(hrp)
    if SeatPart and SeatPart.Parent then
        SeatPart.CFrame = hrp.CFrame * CFrame.new(0,-2.5,0)
        return
    end

    SeatPart = Instance.new("Seat")
    SeatPart.Name = "MetroSeat"
    SeatPart.Size = Vector3.new(2,1,2)
    SeatPart.Anchored = true
    SeatPart.CanCollide = true
    SeatPart.Transparency = 0.35
    SeatPart.Material = Enum.Material.Metal

    SeatPart.CFrame =
        hrp.CFrame * CFrame.new(0,-2.5,0)

    SeatPart.Parent = workspace

    task.wait()

    local _, _, hum = Character()

    if hum and SeatPart.Parent then
        SeatPart:Sit(hum)
    end
end

local function DestroySeat()
    if SeatPart then
        pcall(function()
            SeatPart:Destroy()
        end)

        SeatPart = nil
    end
end

--========================================================--
-- METRO
--========================================================--

local function StartMetro()
    local char, hrp, hum = Character()

    if not char or not hrp or not hum then
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    -- SADECE AKTİF EDİLDİĞİ ANDAKİ YÖN
    MetroDirection = camera.CFrame.LookVector.Unit

    MetroEnabled = true

    MetroButton.Text = "🚇 METRO : AKTİF"
    MetroButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
end

local function StopMetro()
    MetroEnabled = false
    MetroDirection = nil

    MetroButton.Text = "🚇 METRO : KAPALI"
    MetroButton.BackgroundColor3 = Color3.fromRGB(35,35,50)

    local _, hrp = Character()

    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

--========================================================--
-- METRO HAREKETİ
--========================================================--

if Connection then
    Connection:Disconnect()
end

Connection = RunService.RenderStepped:Connect(function(dt)

    local char, hrp, hum = Character()

    if not char or not hrp or not hum then
        return
    end

    -- WALL
    if WallEnabled then
        if not WallPart or not WallPart.Parent then
            CreateWall()
        end

        UpdateWall(hrp)
    end

    -- SANDALYE
    if SeatEnabled then
        if not SeatPart or not SeatPart.Parent then
            CreateSeat(hrp)
        end
    end

    -- METRO
    if MetroEnabled and MetroDirection then

        -- Çok yüksek değeri tek fizik adımında
        -- uygulamak yerine yönlü hareket yapıyoruz.
        local distance = FORWARD_SPEED * dt

        -- Roblox fizik motorunu tamamen bozabilecek
        -- sonsuz/NaN değerleri engelle.
        if distance ~= distance or math.abs(distance) == math.huge then
            return
        end

        -- Karakterin yönünü de metro yönüne çevir.
        local newPosition =
            hrp.Position + MetroDirection * distance

        hrp.CFrame =
            CFrame.lookAt(
                newPosition,
                newPosition + MetroDirection
            )

        hrp.AssemblyLinearVelocity =
            MetroDirection * math.min(FORWARD_SPEED, 1000000)
    end
end)

--========================================================--
-- METRO BUTONU
--========================================================--

MetroButton.Activated:Connect(function()

    if MetroEnabled then
        StopMetro()
    else
        StartMetro()
    end

end)

--========================================================--
-- WALL BUTONU
--========================================================--

WallButton.Activated:Connect(function()

    WallEnabled = not WallEnabled

    if WallEnabled then

        CreateWall()

        WallButton.Text = "🧱 WALL : AKTİF"
        WallButton.BackgroundColor3 =
            Color3.fromRGB(0,120,70)

    else

        DestroyWall()

        WallButton.Text = "🧱 WALL : KAPALI"
        WallButton.BackgroundColor3 =
            Color3.fromRGB(35,35,50)

    end

end)

--========================================================--
-- SEAT BUTONU
--========================================================--

SeatButton.Activated:Connect(function()

    local _, hrp = Character()

    if not hrp then
        return
    end

    if SeatPart and SeatPart.Parent then

        local _, _, hum = Character()

        if hum then
            SeatPart:Sit(hum)
        end

        SeatButton.Text = "🪑 OTUR : OTURULDU"

    else

        SeatEnabled = true

        CreateSeat(hrp)

        SeatButton.Text = "🪑 OTUR : OTURULDU"

    end

end)

--========================================================--
-- ANA GUI BUTONU
--========================================================--

Open.Activated:Connect(function()
    Menu.Visible = not Menu.Visible
end)

--========================================================--
-- RESPAWN
--========================================================--

LP.CharacterAdded:Connect(function()

    task.wait(1)

    MetroDirection = nil

    if SeatPart then
        pcall(function()
            SeatPart:Destroy()
        end)
        SeatPart = nil
    end

    if WallEnabled then
        CreateWall()
    end

end)

--========================================================--
-- BAŞLANGIÇ
--========================================================--

print("====================================")
print("🚇 HAMSTER METRO DELTA BAŞLADI")
print("🧱 WALL hazır")
print("🪑 SEAT hazır")
print("🚇 METRO hazır")
print("📱 PlayerGui / Activated")
print("====================================")
