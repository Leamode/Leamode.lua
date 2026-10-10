--[[
    Roblox - Lag Bombası (Part Fırtınası)
    Amaç: Aşırı sayıda fizik objesi oluşturarak istemci ve sunucuda yoğun CPU/GPU yükü yaratmak
    Ortam: Delta Executor
    Not: Yalnızca kendi istemcinde çalışır, sunucu tarafını doğrudan çökertemez
]]

-- 1) SERVİSLER
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- 2) KONFİGÜRASYON
local COUNT        = 5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009009000000      -- part sayısı
local SPAWN_RADIUS = 60        -- oyuncunun etrafında yayılma yarıçapı
local SIZE         = 4         -- her part boyutu
local LIFETIME     = 999       -- saniye (kalıcı)
local USE_PHYSICS  = true      -- fizik simülasyonu (CPU yükü)
local USE_MESH     = false     -- mesh part kullan (daha ağır)

-- 3) BAŞLANGIÇ POZİSYONU
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return end
local origin = root.Position

-- 4) KONTEYNER OLUŞTUR
local folder = Instance.new("Folder")
folder.Name = "LagFolder_" .. tostring(math.random(100000, 999999))
folder.Parent = Workspace

-- 5) PART ÜRETİCİ
local function spawnPart(i)
    local p
    if USE_MESH then
        p = Instance.new("MeshPart")
        p.MeshId = "rbxassetid://0"
    else
        p = Instance.new("Part")
    end

    p.Size = Vector3.new(SIZE, SIZE, SIZE)
    p.Shape = Enum.PartType.Ball
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    p.Anchored = false
    p.CanCollide = USE_PHYSICS
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth

    local angle = math.random() * math.pi * 2
    local radius = math.random() * SPAWN_RADIUS
    local height = math.random(20, 120)

    p.CFrame = CFrame.new(
        origin.X + math.cos(angle) * radius,
        origin.Y + height,
        origin.Z + math.sin(angle) * radius
    ) * CFrame.Angles(math.random()*6, math.random()*6, math.random()*6)

    p.Parent = folder

    -- 6) FİZİK HAREKETİ (CPU yükü)
    if USE_PHYSICS then
        p.AssemblyLinearVelocity = Vector3.new(
            math.random(-50, 50),
            math.random(-20, 20),
            math.random(-50, 50)
        )
        p.AssemblyAngularVelocity = Vector3.new(
            math.random(-30, 30),
            math.random(-30, 30),
            math.random(-30, 30)
        )
    end

    -- 7) OTOMATİK TEMİZLİK
    game:GetService("Debris"):AddItem(p, LIFETIME)
end

-- 8) TOPLU ÜRETİM (kademeli - istemci donmasın diye)
for i = 1, COUNT do
    spawnPart(i)
    if i % 100 == 0 then
        task.wait() -- her 100 partta bir frame bırak
    end
end

print("[Lag] " .. COUNT .. " part oluşturuldu. Konteyner: " .. folder.Name)
