--============================================================--
-- HAMSTER LIVES - METRO / SEAT / WALL
-- DELTA CLIENT
--============================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================--
-- AYARLAR
--============================================================--

local METRO_SPEED = 100000000000000 -- 100 TRİLYON

local WALL_DISTANCE = 7
local WALL_WIDTH = 250
local WALL_HEIGHT = 250
local WALL_THICKNESS = 12

local SEAT_HEIGHT = 2.5

--============================================================--
-- DEĞİŞKENLER
--============================================================--

local MetroEnabled = false
local WallEnabled = false

local MetroDirection = nil

local CreatedSeat = nil
local Wall = nil

local MetroConnection = nil
local WallConnection = nil

--============================================================--
-- KARAKTER
--============================================================--

local function GetCharacter()
    local Character = Player.Character
    if not Character then
        return nil
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return nil
    end

    return Character, Humanoid, Root
end

--============================================================--
-- GUI
--============================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HamsterLivesMetro"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--============================================================--
-- AÇMA BUTONU
--============================================================--

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenMetro"
OpenButton.Size = UDim2.fromOffset(55,55)
OpenButton.Position = UDim2.new(1,-70,0,80)
OpenButton.BackgroundColor3 = Color3.fromRGB(170,0,0)
OpenButton.Text = "METRO"
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.TextSize = 11
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1,0)
OpenCorner.Parent = OpenButton

--============================================================--
-- MENÜ
--============================================================--

local Menu = Instance.new("Frame")
Menu.Name = "MetroMenu"
Menu.Size = UDim2.fromOffset(260,300)
Menu.Position = UDim2.new(1,-275,0,145)
Menu.BackgroundColor3 = Color3.fromRGB(15,15,18)
Menu.BackgroundTransparency = 0.05
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0,10)
MenuCorner.Parent = Menu

local Border = Instance.new("UIStroke")
Border.Thickness = 2
Border.Color = Color3.fromRGB(255,180,0)
Border.Parent = Menu

--============================================================--
-- BAŞLIK
--============================================================--

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,40)
Title.Position = UDim2.fromOffset(12,5)
Title.BackgroundTransparency = 1
Title.Text = "HAMSTER METRO"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Menu

--============================================================--
-- KAPAT
--============================================================--

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(35,35)
CloseButton.Position = UDim2.new(1,-40,0,5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Menu

CloseButton.Activated:Connect(function()
    Menu.Visible = false
end)

--============================================================--
-- BUTON OLUŞTURUCU
--============================================================--

local function CreateButton(Name, Text, PositionY)

    local Button = Instance.new("TextButton")

    Button.Name = Name

    Button.Size = UDim2.new(1,-20,0,48)

    Button.Position = UDim2.fromOffset(10,PositionY)

    Button.BackgroundColor3 =
        Color3.fromRGB(35,35,45)

    Button.Text = Text

    Button.TextColor3 =
        Color3.new(1,1,1)

    Button.TextSize = 13

    Button.Font =
        Enum.Font.GothamBold

    Button.AutoButtonColor = true

    Button.Parent = Menu

    local Corner = Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0,7)

    Corner.Parent = Button

    return Button
end

--============================================================--
-- BUTONLAR
--============================================================--

local SeatCreateButton =
    CreateButton(
        "CreateSeat",
        "SANDALYE OLUŞTUR",
        50
    )

local SitButton =
    CreateButton(
        "Sit",
        "OTUR",
        105
    )

local WallButton =
    CreateButton(
        "Wall",
        "WALL : KAPALI",
        160
    )

local MetroButton =
    CreateButton(
        "Metro",
        "METRO : KAPALI",
        215
    )

--============================================================--
-- DURUM
--============================================================--

local Status = Instance.new("TextLabel")

Status.Size =
    UDim2.new(1,-20,0,25)

Status.Position =
    UDim2.fromOffset(10,267)

Status.BackgroundTransparency = 1

Status.Text =
    "Hazır"

Status.TextColor3 =
    Color3.fromRGB(150,150,150)

Status.TextSize = 10

Status.Font =
    Enum.Font.Gotham

Status.Parent = Menu

--============================================================--
-- SANDALYE OLUŞTUR
--============================================================--

local function CreateSeat()

    local Character, Humanoid, Root =
        GetCharacter()

    if not Root then
        Status.Text = "Karakter bulunamadı"
        return
    end

    -- Önceki oluşturulan sandalyeyi kaldır.
    if CreatedSeat then
        pcall(function()
            CreatedSeat:Destroy()
        end)

        CreatedSeat = nil
    end

    local Seat = Instance.new("Seat")

    Seat.Name = "HamsterSeat"

    Seat.Size =
        Vector3.new(2.5,1,2.5)

    Seat.CFrame =
        Root.CFrame *
        CFrame.new(0,-SEAT_HEIGHT,0)

    Seat.Anchored = true

    Seat.CanCollide = true

    Seat.CanTouch = true

    Seat.CanQuery = true

    Seat.Transparency = 0.15

    Seat.Material =
        Enum.Material.Metal

    Seat.Parent = workspace

    CreatedSeat = Seat

    Status.Text =
        "Sandalye oluşturuldu"

    SitButton.Text =
        "OTUR"

end

--============================================================--
-- OTUR
--============================================================--

local function SitOnCreatedSeat()

    if not CreatedSeat or
       not CreatedSeat.Parent then

        Status.Text =
            "Önce sandalye oluştur"

        return
    end

    local Character, Humanoid, Root =
        GetCharacter()

    if not Character then
        return
    end

    -- Sandalyenin konumunu al.
    local SeatCFrame =
        CreatedSeat.CFrame

    -- Karakteri sandalyenin üstüne taşı.
    Root.CFrame =
        SeatCFrame *
        CFrame.new(0,2.5,0)

    task.wait()

    -- Gerçek Seat oturması.
    pcall(function()
        CreatedSeat:Sit(Humanoid)
    end)

    task.wait(0.1)

    pcall(function()
        Humanoid.Sit = true
    end)

    Status.Text =
        "Sandalyeye oturuldu"

end

--============================================================--
-- WALL OLUŞTUR
--============================================================--

local function CreateWall()

    if Wall and Wall.Parent then
        return
    end

    Wall = Instance.new("Part")

    Wall.Name =
        "HamsterInvisibleWall"

    Wall.Size =
        Vector3.new(
            WALL_WIDTH,
            WALL_HEIGHT,
            WALL_THICKNESS
        )

    Wall.Anchored = true

    Wall.CanCollide = true

    Wall.CanTouch = false

    Wall.CanQuery = false

    Wall.CastShadow = false

    Wall.Transparency = 1

    Wall.Parent = workspace

end

--============================================================--
-- WALL SİL
--============================================================--

local function RemoveWall()

    if Wall then

        pcall(function()
            Wall:Destroy()
        end)

        Wall = nil

    end

end

--============================================================--
-- WALL TAKİP
--============================================================--

local function StartWall()

    if WallConnection then
        WallConnection:Disconnect()
        WallConnection = nil
    end

    CreateWall()

    WallEnabled = true

    WallButton.Text =
        "WALL : AKTİF"

    WallButton.BackgroundColor3 =
        Color3.fromRGB(0,120,70)

    WallConnection =
        RunService.RenderStepped:Connect(function()

            if not WallEnabled then
                return
            end

            local Character, Humanoid, Root =
                GetCharacter()

            if not Root then
                return
            end

            if not Wall or not Wall.Parent then
                CreateWall()
            end

            -- Duvar karakterin tam arkasında.
            local Behind =
                Root.Position -
                Root.CFrame.LookVector *
                WALL_DISTANCE

            Wall.CFrame =
                CFrame.lookAt(
                    Behind,
                    Behind +
                    Root.CFrame.LookVector
                )

        end)

end

--============================================================--
-- WALL DURDUR
--============================================================--

local function StopWall()

    WallEnabled = false

    if WallConnection then

        WallConnection:Disconnect()

        WallConnection = nil

    end

    RemoveWall()

    WallButton.Text =
        "WALL : KAPALI"

    WallButton.BackgroundColor3 =
        Color3.fromRGB(35,35,45)

end

--============================================================--
-- METRO BAŞLAT
--============================================================--

local function StartMetro()

    local Character, Humanoid, Root =
        GetCharacter()

    if not Root then
        Status.Text =
            "Karakter bulunamadı"

        return
    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        Status.Text =
            "Kamera bulunamadı"

        return
    end

    -- BUTONA BASILDIĞI ANDAKİ BAKIŞ YÖNÜ.
    MetroDirection =
        Camera.CFrame.LookVector.Unit

    MetroEnabled = true

    MetroButton.Text =
        "METRO : AKTİF"

    MetroButton.BackgroundColor3 =
        Color3.fromRGB(150,0,0)

    Status.Text =
        "Metro hareketi aktif"

    if MetroConnection then
        MetroConnection:Disconnect()
    end

    MetroConnection =
        RunService.RenderStepped:Connect(function(dt)

            if not MetroEnabled then
                return
            end

            local Character2, Humanoid2, Root2 =
                GetCharacter()

            if not Root2 then
                return
            end

            if not MetroDirection then
                return
            end

            -- Çok büyük sayıyı doğrudan fizik hızına
            -- vermek yerine CFrame ile yönlü taşıyoruz.
            local Distance =
                METRO_SPEED * dt

            -- Aşırı büyük sayıların NaN/Inf
            -- oluşturmasını engelle.
            if Distance ~= Distance then
                return
            end

            if Distance == math.huge then
                return
            end

            -- Karakteri havada ileri taşı.
            local NewPosition =
                Root2.Position +
                MetroDirection * Distance

            Root2.CFrame =
                CFrame.lookAt(
                    NewPosition,
                    NewPosition +
                    MetroDirection
                )

            -- Fizik hızını da destekle.
            pcall(function()
                Root2.AssemblyLinearVelocity =
                    MetroDirection *
                    math.min(
                        METRO_SPEED,
                        1000000
                    )
            end)

            -- Eğer oluşturulan sandalye varsa
            -- onu da karakterin altında tut.
            if CreatedSeat and
               CreatedSeat.Parent then

                CreatedSeat.CFrame =
                    Root2.CFrame *
                    CFrame.new(
                        0,
                        -SEAT_HEIGHT,
                        0
                    )

            end

        end)

end

--============================================================--
-- METRO DURDUR
--============================================================--

local function StopMetro()

    MetroEnabled = false

    MetroDirection = nil

    if MetroConnection then

        MetroConnection:Disconnect()

        MetroConnection = nil

    end

    local Character, Humanoid, Root =
        GetCharacter()

    if Root then

        pcall(function()
            Root.AssemblyLinearVelocity =
                Vector3.zero
        end)

    end

    MetroButton.Text =
        "METRO : KAPALI"

    MetroButton.BackgroundColor3 =
        Color3.fromRGB(35,35,45)

    Status.Text =
        "Metro durduruldu"

end

--============================================================--
-- SANDALYE OLUŞTUR BUTONU
--============================================================--

SeatCreateButton.Activated:Connect(function()

    CreateSeat()

end)

--============================================================--
-- OTUR BUTONU
--============================================================--

SitButton.Activated:Connect(function()

    SitOnCreatedSeat()

end)

--============================================================--
-- WALL BUTONU
--============================================================--

WallButton.Activated:Connect(function()

    if WallEnabled then

        StopWall()

    else

        StartWall()

    end

end)

--============================================================--
-- METRO BUTONU
--============================================================--

MetroButton.Activated:Connect(function()

    if MetroEnabled then

        StopMetro()

    else

        StartMetro()

    end

end)

--============================================================--
-- AÇ / KAPAT
--============================================================--

OpenButton.Activated:Connect(function()

    Menu.Visible =
        not Menu.Visible

end)

--============================================================--
-- RESPAWN
--============================================================--

Player.CharacterAdded:Connect(function()

    task.wait(1)

    MetroDirection = nil

    if MetroEnabled then
        StopMetro()
    end

end)

--============================================================--
-- BAŞLANGIÇ
--============================================================--

print("================================")
print("HAMSTER METRO YUKLENDI")
print("SANDALYE: HAZIR")
print("OTUR: HAZIR")
print("WALL: HAZIR")
print("METRO: HAZIR")
print("PLAYERGUI: AKTIF")
print("================================")
