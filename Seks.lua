--============================================================
-- HAMSTER LIVES - GUARD SEAT + WALL
-- PLAYERGUI VERSION
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[METRO] LocalPlayer bulunamadı.")
    return
end

--============================================================
-- PLAYER GUI
--============================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

if not PlayerGui then
    warn("[METRO] PlayerGui bulunamadı.")
    return
end

-- Eski sistemi temizle
pcall(function()
    local old = PlayerGui:FindFirstChild("GuardRideSystem")
    if old then
        old:Destroy()
    end
end)

--============================================================
-- DEĞİŞKENLER
--============================================================

local WallEnabled = false
local SeatEnabled = false

local WallPart = nil
local RideSeat = nil

local Character = nil
local Root = nil
local Humanoid = nil

local Connections = {}

--============================================================
-- KARAKTER
--============================================================

local function UpdateCharacter()

    Character = LocalPlayer.Character

    if not Character then
        Root = nil
        Humanoid = nil
        return
    end

    Root = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChildOfClass("Humanoid")

end

UpdateCharacter()

--============================================================
-- GUI
--============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "GuardRideSystem"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--============================================================
-- AÇ/KAPAT BUTONU
--============================================================

local OpenButton = Instance.new("TextButton")

OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(52, 52)
OpenButton.Position = UDim2.new(1, -65, 0, 70)

OpenButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "⚙"
OpenButton.TextSize = 24
OpenButton.Font = Enum.Font.GothamBold

OpenButton.Active = true
OpenButton.Selectable = true
OpenButton.ZIndex = 100

OpenButton.Parent = Gui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

--============================================================
-- PANEL
--============================================================

local Panel = Instance.new("Frame")

Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(260, 230)
Panel.Position = UDim2.new(1, -280, 0, 135)

Panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Panel.BackgroundTransparency = 0.05

Panel.Visible = true
Panel.Active = true
Panel.ZIndex = 50

Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local Border = Instance.new("UIStroke")
Border.Thickness = 2
Border.Color = Color3.fromRGB(210, 40, 40)
Border.Parent = Panel

--============================================================
-- BAŞLIK
--============================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.fromOffset(12, 5)

Title.BackgroundTransparency = 1
Title.Text = "GUARD RIDE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

Title.ZIndex = 51
Title.Parent = Panel

--============================================================
-- KAPAT
--============================================================

local Close = Instance.new("TextButton")

Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -40, 0, 5)

Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold

Close.ZIndex = 52
Close.Parent = Panel

--============================================================
-- YARDIMCI BUTON
--============================================================

local function MakeButton(name, text, y)

    local Button = Instance.new("TextButton")

    Button.Name = name
    Button.Size = UDim2.new(1, -30, 0, 42)
    Button.Position = UDim2.fromOffset(15, y)

    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold

    Button.Active = true
    Button.Selectable = true
    Button.ZIndex = 52

    Button.Parent = Panel

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    return Button
end

local WallButton = MakeButton(
    "WallButton",
    "🧱 WALL: KAPALI",
    50
)

local SeatButton = MakeButton(
    "SeatButton",
    "🪑 SANDALYE OLUŞTUR",
    100
)

local SitButton = MakeButton(
    "SitButton",
    "🪑 SANDALYEYE OTUR",
    150
)

--============================================================
-- DURUM
--============================================================

local Status = Instance.new("TextLabel")

Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.fromOffset(10, 200)

Status.BackgroundTransparency = 1
Status.Text = "Hazır"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham

Status.ZIndex = 52
Status.Parent = Panel

--============================================================
-- GUARD BUL
--============================================================

local function IsGuardName(name)

    name = string.lower(name)

    -- Guard
    if name == "guard" then
        return true
    end

    -- Guard1 / Guard2 / Guard_1 / Guard-1
    if string.match(name, "^guard[%d_%- ]*$") then
        return true
    end

    return false
end

local function FindGuard()

    -- Önce doğrudan Workspace çocuklarını kontrol et
    for _, obj in ipairs(Workspace:GetChildren()) do

        if IsGuardName(obj.Name) then
            return obj
        end

    end

    -- Sonra tüm descendantları kontrol et
    for _, obj in ipairs(Workspace:GetDescendants()) do

        if IsGuardName(obj.Name) then
            return obj
        end

    end

    return nil
end

--============================================================
-- MODEL POZİSYONU
--============================================================

local function GetObjectPosition(obj)

    if not obj then
        return nil
    end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then

        local Primary = obj.PrimaryPart

        if Primary then
            return Primary.Position
        end

        local Part = obj:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

        if Part then
            return Part.Position
        end

    end

    return nil
end

--============================================================
-- GUARD ÜSTÜNDEKİ NOKTA
--============================================================

local function GetGuardSeatPosition()

    local Guard = FindGuard()

    if not Guard then
        return nil
    end

    local Position = GetObjectPosition(Guard)

    if not Position then
        return nil
    end

    -- Yaklaşık 1 stud yukarı
    return Position + Vector3.new(0, 3, 0)

end

--============================================================
-- SANDALYE OLUŞTUR
--============================================================

local function CreateSeat()

    if RideSeat then
        RideSeat:Destroy()
        RideSeat = nil
    end

    local Position = GetGuardSeatPosition()

    if not Position then

        Status.Text = "Guard bulunamadı!"
        warn("[GUARD RIDE] Guard bulunamadı.")

        return false
    end

    local Seat = Instance.new("Seat")

    Seat.Name = "GuardRideSeat"

    Seat.Size = Vector3.new(2, 1, 2)

    Seat.Anchored = true
    Seat.CanCollide = true

    Seat.Transparency = 0.35

    Seat.CFrame = CFrame.new(Position)

    Seat.Parent = Workspace

    RideSeat = Seat
    SeatEnabled = true

    Status.Text = "Sandalye oluşturuldu."

    return true
end

--============================================================
-- SANDALYEYİ GUARD'A TAKİP ETTİR
--============================================================

local function UpdateSeat()

    if not SeatEnabled then
        return
    end

    if not RideSeat then
        return
    end

    if not RideSeat.Parent then
        RideSeat = nil
        SeatEnabled = false
        return
    end

    local Position = GetGuardSeatPosition()

    if not Position then
        return
    end

    RideSeat.CFrame = CFrame.new(Position)

end

--============================================================
-- OTUR
--============================================================

local function SitOnSeat()

    if not Humanoid then
        UpdateCharacter()
    end

    if not Humanoid then
        Status.Text = "Humanoid bulunamadı."
        return
    end

    if not RideSeat or not RideSeat.Parent then

        if not CreateSeat() then
            return
        end

    end

    -- Sandalyeye yaklaş
    if Root then
        Root.CFrame = RideSeat.CFrame + Vector3.new(0, 2, 0)
    end

    task.wait(0.15)

    if Humanoid and RideSeat then
        RideSeat:Sit(Humanoid)
        Status.Text = "Sandalyeye oturuldu."
    end

end

--============================================================
-- WALL OLUŞTUR
--============================================================

local function CreateWall()

    if WallPart then
        WallPart:Destroy()
        WallPart = nil
    end

    local Wall = Instance.new("Part")

    Wall.Name = "InvisiblePushWall"

    -- Büyük hitbox
    Wall.Size = Vector3.new(30, 30, 2)

    Wall.Transparency = 1

    Wall.CanCollide = true
    Wall.CanTouch = false
    Wall.CanQuery = false

    Wall.Anchored = true

    Wall.Parent = Workspace

    WallPart = Wall

    return Wall
end

--============================================================
-- WALL KONUMU
--============================================================

local function UpdateWall()

    if not WallEnabled then
        return
    end

    if not Root then
        UpdateCharacter()
    end

    if not Root then
        return
    end

    if not WallPart or not WallPart.Parent then
        CreateWall()
    end

    if not WallPart then
        return
    end

    -- Karakterin baktığı yönün arkasına koy
    local BackPosition =
        Root.Position - Root.CFrame.LookVector * 4

    WallPart.CFrame =
        CFrame.lookAt(
            BackPosition,
            Root.Position
        )

end

--============================================================
-- WALL AÇ/KAPAT
--============================================================

WallButton.Activated:Connect(function()

    WallEnabled = not WallEnabled

    if WallEnabled then

        CreateWall()

        WallButton.Text = "🧱 WALL: AÇIK"
        WallButton.BackgroundColor3 =
            Color3.fromRGB(150, 0, 0)

        Status.Text = "Wall aktif."

    else

        if WallPart then
            WallPart:Destroy()
            WallPart = nil
        end

        WallButton.Text = "🧱 WALL: KAPALI"
        WallButton.BackgroundColor3 =
            Color3.fromRGB(40, 40, 50)

        Status.Text = "Wall kapalı."

    end

end)

--============================================================
-- SANDALYE OLUŞTUR
--============================================================

SeatButton.Activated:Connect(function()

    if CreateSeat() then
        SeatButton.Text = "🪑 SANDALYE HAZIR"
        SeatButton.BackgroundColor3 =
            Color3.fromRGB(0, 120, 70)
    end

end)

--============================================================
-- OTUR
--============================================================

SitButton.Activated:Connect(function()

    SitOnSeat()

end)

--============================================================
-- MENÜ
--============================================================

OpenButton.Activated:Connect(function()

    Panel.Visible = not Panel.Visible

end)

Close.Activated:Connect(function()

    Panel.Visible = false

end)

--============================================================
-- KARAKTER DEĞİŞİNCE
--============================================================

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)

    Character = NewCharacter

    task.wait(0.5)

    UpdateCharacter()

end)

--============================================================
-- ANA DÖNGÜ
--============================================================

RunService.Heartbeat:Connect(function()

    UpdateSeat()
    UpdateWall()

end)

--============================================================
-- BAŞLANGIÇ
--============================================================

Status.Text = "Sistem hazır."

print("======================================")
print("[GUARD RIDE] Sistem başlatıldı.")
print("[GUARD RIDE] PlayerGui kullanılıyor.")
print("[GUARD RIDE] CoreGui kullanılmıyor.")
print("[GUARD RIDE] Guard arama sistemi hazır.")
print("[GUARD RIDE] Wall sistemi hazır.")
print("[GUARD RIDE] Seat sistemi hazır.")
print("======================================")
