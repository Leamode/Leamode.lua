-- HAMSTER METRO - FIXED
-- Kendi Roblox Studio oyununuz icin LocalScript.
-- Anti-cheat bypass / server protection bypass YOK.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("HamsterMetroSafe")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterMetroSafe"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

--========================================================
-- INTRO
--========================================================

local intro = Instance.new("Frame")
intro.Size = UDim2.fromScale(1, 1)
intro.BackgroundColor3 = Color3.fromRGB(3, 3, 8)
intro.BorderSizePixel = 0
intro.ZIndex = 100
intro.Parent = gui

local function planet(size, position, text)
    local p = Instance.new("TextLabel")
    p.Size = UDim2.fromOffset(size, size)
    p.Position = position
    p.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    p.BorderSizePixel = 0
    p.Text = text
    p.TextSize = math.floor(size * 0.45)
    p.ZIndex = 101
    p.Parent = intro

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = p

    return p
end

local leftPlanet = planet(
    160,
    UDim2.new(0.5, -280, 0.5, -80),
    "☀"
)

local rightPlanet = planet(
    160,
    UDim2.new(0.5, 120, 0.5, -80),
    "☀"
)

local glow = Instance.new("TextLabel")
glow.Size = UDim2.fromScale(1, 1)
glow.BackgroundTransparency = 1
glow.Text = "✦"
glow.TextSize = 70
glow.TextColor3 = Color3.new(1, 1, 1)
glow.TextTransparency = 1
glow.ZIndex = 102
glow.Parent = intro

local infoTween = TweenInfo.new(
    0.7,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut
)

TweenService:Create(
    leftPlanet,
    infoTween,
    {Position = UDim2.new(0.5, -80, 0.5, -80)}
):Play()

TweenService:Create(
    rightPlanet,
    infoTween,
    {Position = UDim2.new(0.5, -80, 0.5, -80)}
):Play()

task.wait(0.75)

TweenService:Create(
    glow,
    TweenInfo.new(0.12),
    {
        TextTransparency = 0,
        TextSize = 140
    }
):Play()

task.wait(0.15)

TweenService:Create(
    intro,
    TweenInfo.new(0.4),
    {BackgroundTransparency = 1}
):Play()

TweenService:Create(
    leftPlanet,
    TweenInfo.new(0.4),
    {
        TextTransparency = 1,
        BackgroundTransparency = 1
    }
):Play()

TweenService:Create(
    rightPlanet,
    TweenInfo.new(0.4),
    {
        TextTransparency = 1,
        BackgroundTransparency = 1
    }
):Play()

TweenService:Create(
    glow,
    TweenInfo.new(0.4),
    {TextTransparency = 1}
):Play()

task.wait(0.45)

if intro then
    intro:Destroy()
end

--========================================================
-- MENU
--========================================================

local toggle = Instance.new("TextButton")
toggle.Name = "MenuToggle"
toggle.Size = UDim2.fromOffset(58, 58)
toggle.Position = UDim2.new(1, -75, 0.5, -29)
toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
toggle.BorderSizePixel = 0
toggle.Text = "☰"
toggle.TextSize = 26
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.ZIndex = 20
toggle.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggle

local menu = Instance.new("Frame")
menu.Name = "SideMenu"
menu.Size = UDim2.fromOffset(440, 560)
menu.Position = UDim2.new(1, 20, 0.5, -280)
menu.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
menu.BorderSizePixel = 0
menu.ZIndex = 10
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 16)
menuCorner.Parent = menu

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 46)
title.Position = UDim2.fromOffset(18, 8)
title.BackgroundTransparency = 1
title.Text = "HAMSTER METRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 11
title.Parent = menu

local trash = Instance.new("TextButton")
trash.Size = UDim2.fromOffset(42, 42)
trash.Position = UDim2.new(1, -50, 0, 10)
trash.BackgroundTransparency = 1
trash.Text = "🗑"
trash.TextSize = 22
trash.ZIndex = 12
trash.Parent = menu

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -30, 0, 1)
divider.Position = UDim2.fromOffset(15, 54)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider.BorderSizePixel = 0
divider.ZIndex = 11
divider.Parent = menu

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.5, -12, 1, -70)
leftPanel.Position = UDim2.fromOffset(10, 64)
leftPanel.BackgroundTransparency = 1
leftPanel.ZIndex = 11
leftPanel.Parent = menu

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.5, -12, 1, -70)
rightPanel.Position = UDim2.new(0.5, 2, 0, 64)
rightPanel.BackgroundTransparency = 1
rightPanel.ZIndex = 11
rightPanel.Parent = menu

local function makeButton(parent, text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 44)
    b.Position = UDim2.fromOffset(4, y)
    b.BackgroundColor3 = Color3.fromRGB(31, 31, 42)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 12
    b.AutoButtonColor = true
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = b

    return b
end

local seatButton =
    makeButton(leftPanel, "🪑 SANDALYE OLUSTUR", 0)

local sitButton =
    makeButton(leftPanel, "🪑 OTUR", 50)

local leaveButton =
    makeButton(leftPanel, "⬇ SANDALYEDEN IN", 100)

local wallButton =
    makeButton(leftPanel, "🧱 WALL : KAPALI", 150)

local metroButton =
    makeButton(leftPanel, "🚇 METRO : KAPALI", 200)

local proneButton =
    makeButton(leftPanel, "⬇ IN (YERE) : KAPALI", 250)

local antikillButton =
    makeButton(rightPanel, "❤ ANTIKILL : KAPALI", 0)

local eggLockButton =
    makeButton(rightPanel, "🥚 EGG LOCK : KAPALI", 50)

local antiKnockButton =
    makeButton(rightPanel, "🛡 AYAKTA KAL : KAPALI", 100)

local serverButton =
    makeButton(rightPanel, "👤 1 KISILIK SERVER BUL", 150)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -8, 0, 200)
info.Position = UDim2.fromOffset(4, 205)
info.BackgroundTransparency = 1
info.Text =
    "ANTIKILL: local demo\n" ..
    "EGG LOCK: eldeki egg korunur\n" ..
    "E: yakin egg al\n" ..
    "AYAKTA KAL: local demo\n\n" ..
    "Kendi Studio oyunun icin."
info.TextColor3 = Color3.fromRGB(180, 180, 190)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextYAlignment = Enum.TextYAlignment.Top
info.ZIndex = 12
info.Parent = rightPanel

--========================================================
-- STATE
--========================================================

local seat = nil
local wall = nil

local wallEnabled = false
local metroEnabled = false
local proneEnabled = false
local antikillEnabled = false
local eggLockEnabled = false
local antiKnockEnabled = false

local METRO_SPEED = 180
local WALL_PUSH = 42

-- Daha asagi indirildi.
local PRONE_DROP = 4.2

local EGG_PICK_RANGE = 22

local savedHipHeight = nil
local savedWalkSpeed = nil
local savedJumpPower = nil
local savedJumpHeight = nil

local lockedEggTool = nil
local humanoidConns = {}

--========================================================
-- CHARACTER
--========================================================

local function getCharacter()
    local character = player.Character
    if not character then
        return nil
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if humanoid and root then
        return character, humanoid, root
    end

    return nil
end

local function clearHumanoidConns()
    for _, c in ipairs(humanoidConns) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(humanoidConns)
end

--========================================================
-- EGG HELPERS
--========================================================

local function isEggName(name)
    if not name then
        return false
    end

    local n = string.lower(name)

    return string.find(n, "egg", 1, true) ~= nil
        or string.find(n, "yumurta", 1, true) ~= nil
end

local function getToolHandle(tool)
    if not tool or not tool:IsA("Tool") then
        return nil
    end

    local handle = tool:FindFirstChild("Handle")

    if handle and handle:IsA("BasePart") then
        return handle
    end

    return tool:FindFirstChildWhichIsA("BasePart")
end

local function findEggTool(container)
    if not container then
        return nil
    end

    for _, obj in ipairs(container:GetChildren()) do
        if obj:IsA("Tool") and isEggName(obj.Name) then
            return obj
        end
    end

    return nil
end

local function equipEgg(tool)
    local character, humanoid = getCharacter()

    if not character or not humanoid or not tool then
        return false
    end

    if not tool:IsA("Tool") then
        return false
    end

    pcall(function()
        tool.CanBeDropped = false
    end)

    if tool.Parent ~= character then
        local backpack = player:FindFirstChild("Backpack")

        if backpack and tool.Parent == backpack then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
        end
    end

    return true
end--========================================================
-- SANDALYE
--========================================================

seatButton.Activated:Connect(function()
    local _, _, root = getCharacter()

    if not root then
        return
    end

    if seat then
        pcall(function()
            seat:Destroy()
        end)
        seat = nil
    end

    local newSeat = Instance.new("Seat")
    newSeat.Name = "HamsterMetroSeat"
    newSeat.Size = Vector3.new(2.5, 1, 2.5)
    newSeat.Anchored = true
    newSeat.CanCollide = true
    newSeat.CanTouch = true
    newSeat.CFrame =
        root.CFrame * CFrame.new(0, -2.5, 0)

    newSeat.Parent = workspace
    seat = newSeat

    seatButton.Text = "✓ SANDALYE HAZIR"

    task.delay(1, function()
        if seatButton.Parent then
            seatButton.Text = "🪑 SANDALYE OLUSTUR"
        end
    end)
end)

sitButton.Activated:Connect(function()
    local _, humanoid, root = getCharacter()

    if not humanoid or not root then
        return
    end

    if not seat or not seat.Parent then
        sitButton.Text = "ONCE SANDALYE"

        task.delay(1, function()
            if sitButton.Parent then
                sitButton.Text = "🪑 OTUR"
            end
        end)

        return
    end

    root.CFrame =
        seat.CFrame * CFrame.new(0, 2.5, 0)

    task.wait()

    pcall(function()
        seat:Sit(humanoid)
    end)
end)

leaveButton.Activated:Connect(function()
    local _, humanoid = getCharacter()

    if not humanoid then
        return
    end

    pcall(function()
        humanoid.Sit = false
        humanoid:ChangeState(
            Enum.HumanoidStateType.GettingUp
        )
    end)
end)

--========================================================
-- WALL
--========================================================

local function createWall()
    local _, _, root = getCharacter()

    if not root then
        return
    end

    if wall then
        pcall(function()
            wall:Destroy()
        end)
    end

    wall = Instance.new("Part")
    wall.Name = "HamsterMetroWall"
    wall.Size = Vector3.new(16, 12, 4)
    wall.Anchored = true
    wall.CanCollide = true
    wall.CanTouch = true
    wall.CanQuery = false
    wall.Transparency = 1
    wall.Parent = workspace

    wallEnabled = true
end

wallButton.Activated:Connect(function()
    if wallEnabled then
        wallEnabled = false

        if wall then
            pcall(function()
                wall:Destroy()
            end)
            wall = nil
        end

        wallButton.Text = "🧱 WALL : KAPALI"
    else
        createWall()

        if wall then
            wallButton.Text = "🧱 WALL : AKTIF"
        end
    end
end)

--========================================================
-- METRO
--========================================================

local function getFlatCameraDirection(root)
    local camera = workspace.CurrentCamera

    if not camera then
        return Vector3.new(
            root.CFrame.LookVector.X,
            0,
            root.CFrame.LookVector.Z
        ).Unit
    end

    local look = camera.CFrame.LookVector

    local flat = Vector3.new(
        look.X,
        0,
        look.Z
    )

    if flat.Magnitude < 0.01 then
        local fallback = root.CFrame.LookVector

        flat = Vector3.new(
            fallback.X,
            0,
            fallback.Z
        )
    end

    if flat.Magnitude < 0.01 then
        return Vector3.new(0, 0, -1)
    end

    return flat.Unit
end

metroButton.Activated:Connect(function()
    metroEnabled = not metroEnabled

    if metroEnabled then
        metroButton.Text = "🚇 METRO : AKTIF"
    else
        metroButton.Text = "🚇 METRO : KAPALI"

        local _, _, root = getCharacter()

        if root then
            pcall(function()
                root.AssemblyLinearVelocity =
                    Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end)
        end
    end
end)

--========================================================
-- IN / YERE
--========================================================

local function saveMovement(humanoid)
    if savedHipHeight == nil then
        savedHipHeight = humanoid.HipHeight
    end

    if savedWalkSpeed == nil then
        savedWalkSpeed = humanoid.WalkSpeed
    end

    if humanoid.UseJumpPower then
        if savedJumpPower == nil then
            savedJumpPower = humanoid.JumpPower
        end
    else
        if savedJumpHeight == nil then
            savedJumpHeight = humanoid.JumpHeight
        end
    end
end

local function lowerCharacterToGround(root, humanoid)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        player.Character
    }

    local origin =
        root.Position + Vector3.new(0, 3, 0)

    local result = workspace:Raycast(
        origin,
        Vector3.new(0, -25, 0),
        params
    )

    if not result then
        -- Zemin bulunamazsa eskisinden daha asagi indir.
        root.CFrame =
            root.CFrame * CFrame.new(0, -PRONE_DROP, 0)

        return
    end

    -- HumanoidRootPart'in zeminden uzakligini dusuruyoruz.
    -- Fazla yukarida kalmamasi icin offset kucuk tutuldu.
    local targetY = result.Position.Y + 0.35

    local current = root.Position

    if current.Y > targetY then
        root.CFrame =
            CFrame.new(
                current.X,
                targetY,
                current.Z
            ) *
            (root.CFrame - root.CFrame.Position)
    end

    pcall(function()
        root.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)
    end)
end

local function setProne(on)
    local _, humanoid, root = getCharacter()

    if not humanoid or not root then
        return
    end

    if on then
        if not proneEnabled then
            saveMovement(humanoid)
        end

        proneEnabled = true

        pcall(function()
            humanoid.HipHeight = 0
        end)

        humanoid.WalkSpeed = math.min(
            humanoid.WalkSpeed,
            8
        )

        if humanoid.UseJumpPower then
            humanoid.JumpPower = 0
        else
            humanoid.JumpHeight = 0
        end

        lowerCharacterToGround(
            root,
            humanoid
        )

        proneButton.Text =
            "⬇ IN (YERE) : AKTIF"
    else
        proneEnabled = false

        if savedHipHeight ~= nil then
            pcall(function()
                humanoid.HipHeight =
                    savedHipHeight
            end)
        end

        if savedWalkSpeed ~= nil then
            humanoid.WalkSpeed =
                savedWalkSpeed
        end

        if humanoid.UseJumpPower then
            if savedJumpPower ~= nil then
                humanoid.JumpPower =
                    savedJumpPower
            end
        else
            if savedJumpHeight ~= nil then
                humanoid.JumpHeight =
                    savedJumpHeight
            end
        end

        -- Ayağa kalkarken karakteri tekrar yukari al.
        root.CFrame =
            root.CFrame *
            CFrame.new(0, 3, 0)

        proneButton.Text =
            "⬇ IN (YERE) : KAPALI"
    end
end

proneButton.Activated:Connect(function()
    setProne(not proneEnabled)
end)

--========================================================
-- EGG PICKUP
--========================================================

local function findNearestEgg()
    local character, _, root = getCharacter()

    if not character or not root then
        return nil
    end

    local nearest = nil
    local nearestDistance = EGG_PICK_RANGE

    -- Once Tool'leri ara.
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and isEggName(obj.Name) then
            local handle = getToolHandle(obj)

            if handle then
                local distance =
                    (handle.Position - root.Position).Magnitude

                if distance <= nearestDistance then
                    nearest = obj
                    nearestDistance = distance
                end
            end
        end
    end

    -- Modellerin icindeki Tool'leri de ara.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool")
            and isEggName(obj.Name)
            and not obj:IsDescendantOf(character)
        then
            local handle = getToolHandle(obj)

            if handle then
                local distance =
                    (handle.Position - root.Position).Magnitude

                if distance <= nearestDistance then
                    nearest = obj
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

local function tryPickupNearestEgg()
    local character, humanoid, root = getCharacter()

    if not character or not humanoid or not root then
        return
    end

    local egg = findNearestEgg()

    if not egg then
        return
    end

    -- Kendi Studio oyununuzda Tool zaten oyuncuya
    -- veriliyorsa bunu EquipTool ile al.
    local backpack = player:FindFirstChild("Backpack")

    if egg.Parent == backpack or egg.Parent == character then
        lockedEggTool = egg
        equipEgg(egg)
        return
    end

    -- Workspace'teki Tool'u client tarafinda zorla
    -- oyuncuya vermek yerine normal Roblox akisini
    -- kullanmasi icin dokunma/equip denemesi yap.
    local handle = getToolHandle(egg)

    if handle then
        pcall(function()
            firetouchinterest(
                root,
                handle,
                0
            )
        end)

        task.wait(0.08)

        pcall(function()
            firetouchinterest(
                root,
                handle,
                1
            )
        end)
    end

    task.wait(0.08)

    local newTool =
        findEggTool(character)
        or findEggTool(backpack)

    if newTool then
        lockedEggTool = newTool
        equipEgg(newTool)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.E then
        tryPickupNearestEgg()
    end
end)--========================================================
-- EGG LOCK
--========================================================

local function maintainEggLock()
    if not eggLockEnabled then
        return
    end

    local character, humanoid = getCharacter()

    if not character or not humanoid then
        return
    end

    local backpack =
        player:FindFirstChild("Backpack")

    local characterEgg =
        findEggTool(character)

    local backpackEgg =
        findEggTool(backpack)

    -- Once eldeki egg'i kaydet.
    if characterEgg then
        lockedEggTool = characterEgg
    elseif backpackEgg and not lockedEggTool then
        lockedEggTool = backpackEgg
    end

    local tool = lockedEggTool

    if not tool then
        return
    end

    if not tool.Parent then
        lockedEggTool = nil
        return
    end

    -- Backpack'e gittiyse tekrar Equip et.
    if tool.Parent == backpack then
        equipEgg(tool)
    end

    pcall(function()
        tool.CanBeDropped = false
    end)
end

eggLockButton.Activated:Connect(function()
    eggLockEnabled = not eggLockEnabled

    if eggLockEnabled then
        eggLockButton.Text =
            "🥚 EGG LOCK : AKTIF"

        local character = player.Character
        local backpack =
            player:FindFirstChild("Backpack")

        local tool =
            findEggTool(character)

        if not tool then
            tool = findEggTool(backpack)
        end

        if tool then
            lockedEggTool = tool
            equipEgg(tool)
        end
    else
        eggLockButton.Text =
            "🥚 EGG LOCK : KAPALI"

        lockedEggTool = nil
    end
end)

--========================================================
-- ANTIKILL - LOCAL DEMO
--========================================================

local function bindAntikill(humanoid)
    if not humanoid then
        return
    end

    table.insert(
        humanoidConns,
        humanoid.HealthChanged:Connect(function(health)
            if not antikillEnabled then
                return
            end

            if health <= humanoid.MaxHealth * 0.15 then
                pcall(function()
                    humanoid.Health =
                        humanoid.MaxHealth
                end)
            end
        end)
    )
end

antikillButton.Activated:Connect(function()
    antikillEnabled =
        not antikillEnabled

    if antikillEnabled then
        antikillButton.Text =
            "❤ ANTIKILL : AKTIF"

        local _, humanoid = getCharacter()

        if humanoid then
            pcall(function()
                humanoid.Health =
                    humanoid.MaxHealth
            end)
        end
    else
        antikillButton.Text =
            "❤ ANTIKILL : KAPALI"
    end
end)

--========================================================
-- AYAKTA KAL
--========================================================

antiKnockButton.Activated:Connect(function()
    antiKnockEnabled =
        not antiKnockEnabled

    if antiKnockEnabled then
        antiKnockButton.Text =
            "🛡 AYAKTA KAL : AKTIF"
    else
        antiKnockButton.Text =
            "🛡 AYAKTA KAL : KAPALI"
    end
end)

local function maintainAntiKnock(humanoid, root)
    if not antiKnockEnabled then
        return
    end

    if not humanoid or not root then
        return
    end

    local state =
        humanoid:GetState()

    if state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.Physics
    then
        pcall(function()
            humanoid:ChangeState(
                Enum.HumanoidStateType.Running
            )
        end)
    end

    pcall(function()
        humanoid.PlatformStand = false
    end)

    local velocity =
        root.AssemblyLinearVelocity

    if math.abs(velocity.X) > 28
        or math.abs(velocity.Z) > 28
    then
        root.AssemblyLinearVelocity =
            Vector3.new(
                0,
                math.min(velocity.Y, 12),
                0
            )
    end

    root.AssemblyAngularVelocity =
        Vector3.zero
end

--========================================================
-- SERVER BULUCU
--========================================================

local function findOnePlayerServer()
    local placeId = game.PlaceId

    if not placeId or placeId <= 0 then
        return nil
    end

    local cursor = ""

    for _ = 1, 10 do
        local url =
            "https://games.roblox.com/v1/games/"
            .. tostring(placeId)
            .. "/servers/Public?sortOrder=Asc&limit=100"

        if cursor ~= "" then
            url =
                url ..
                "&cursor=" ..
                HttpService:UrlEncode(cursor)
        end

        local ok, body = pcall(function()
            return game:HttpGet(url)
        end)

        if not ok or type(body) ~= "string" then
            return nil
        end

        local decodeOk, data =
            pcall(function()
                return HttpService:JSONDecode(body)
            end)

        if not decodeOk or type(data) ~= "table" then
            return nil
        end

        for _, server in ipairs(data.data or {}) do
            local playing =
                tonumber(server.playing) or 0

            local maxPlayers =
                tonumber(server.maxPlayers) or 0

            if server.id
                and playing == 1
                and maxPlayers > 1
            then
                return server.id
            end
        end

        cursor =
            data.nextPageCursor or ""

        if cursor == "" then
            break
        end
    end

    return nil
end

serverButton.Activated:Connect(function()
    if serverButton:GetAttribute("Busy") then
        return
    end

    serverButton:SetAttribute("Busy", true)
    serverButton.Text =
        "🔎 SERVER ARANIYOR..."

    task.spawn(function()
        local serverId =
            findOnePlayerServer()

        if not serverId then
            serverButton.Text =
                "SERVER BULUNAMADI"

            task.wait(1.2)

            if serverButton.Parent then
                serverButton.Text =
                    "👤 1 KISILIK SERVER BUL"
            end

            serverButton:SetAttribute(
                "Busy",
                false
            )

            return
        end

        serverButton.Text =
            "✓ SERVER BULUNDU"

        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                serverId,
                player
            )
        end)

        if not ok then
            serverButton.Text =
                "TELEPORT BASARISIZ"

            task.wait(1.2)

            if serverButton.Parent then
                serverButton.Text =
                    "👤 1 KISILIK SERVER BUL"
            end
        end

        serverButton:SetAttribute(
            "Busy",
            false
        )
    end)
end)

--========================================================
-- RENDER LOOP
--========================================================

RunService.RenderStepped:Connect(function(dt)
    local character, humanoid, root =
        getCharacter()

    if not character or not humanoid or not root then
        return
    end

    local flatLook =
        getFlatCameraDirection(root)

    -- METRO
    if metroEnabled then
        -- Kamera yonunde stabil hareket.
        local velocity =
            flatLook * METRO_SPEED

        pcall(function()
            root.AssemblyLinearVelocity =
                Vector3.new(
                    velocity.X,
                    root.AssemblyLinearVelocity.Y,
                    velocity.Z
                )
        end)

        -- Karakteri kameranin baktigi yone dondur.
        pcall(function()
            root.CFrame =
                CFrame.lookAt(
                    root.Position,
                    root.Position + flatLook
                )
        end)

        if seat and seat.Parent then
            seat.CFrame =
                root.CFrame *
                CFrame.new(0, -2.5, 0)
        end
    end

    -- WALL
    if wallEnabled and wall and wall.Parent then
        local behind =
            root.Position - flatLook * 5

        wall.CFrame =
            CFrame.lookAt(
                behind,
                behind + flatLook
            )

        if not metroEnabled then
            pcall(function()
                root.AssemblyLinearVelocity =
                    Vector3.new(
                        flatLook.X * WALL_PUSH,
                        root.AssemblyLinearVelocity.Y,
                        flatLook.Z * WALL_PUSH
                    )
            end)
        end

        if seat and seat.Parent and not metroEnabled then
            seat.CFrame =
                root.CFrame *
                CFrame.new(0, -2.5, 0)
        end
    end

    -- YERE IN
    if proneEnabled then
        pcall(function()
            humanoid.HipHeight = 0
        end)

        lowerCharacterToGround(
            root,
            humanoid
        )
    end

    maintainEggLock()
    maintainAntiKnock(
        humanoid,
        root
    )
end)

--========================================================
-- CHARACTER BIND
--========================================================

local function onCharacter(character)
    clearHumanoidConns()

    metroEnabled = false
    wallEnabled = false
    proneEnabled = false

    if seat then
        pcall(function()
            seat:Destroy()
        end)
        seat = nil
    end

    if wall then
        pcall(function()
            wall:Destroy()
        end)
        wall = nil
    end

    metroButton.Text =
        "🚇 METRO : KAPALI"

    wallButton.Text =
        "🧱 WALL : KAPALI"

    proneButton.Text =
        "⬇ IN (YERE) : KAPALI"

    local humanoid =
        character:WaitForChild(
            "Humanoid",
            8
        )

    if humanoid then
        bindAntikill(humanoid)

        if antikillEnabled then
            pcall(function()
                humanoid.Health =
                    humanoid.MaxHealth
            end)
        end
    end

    character.ChildAdded:Connect(function(child)
        if eggLockEnabled
            and child:IsA("Tool")
            and isEggName(child.Name)
        then
            lockedEggTool = child

            pcall(function()
                child.CanBeDropped = false
            end)
        end
    end)
end

if player.Character then
    task.spawn(
        onCharacter,
        player.Character
    )
end

player.CharacterAdded:Connect(onCharacter)

--========================================================
-- MENU ANIMATION
--========================================================

local menuOpen = false

local function setMenu(value)
    menuOpen = value

    local target

    if menuOpen then
        target =
            UDim2.new(
                1,
                -455,
                0.5,
                -280
            )
    else
        target =
            UDim2.new(
                1,
                20,
                0.5,
                -280
            )
    end

    TweenService:Create(
        menu,
        TweenInfo.new(
            0.28,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        {
            Position = target
        }
    ):Play()
end

toggle.Activated:Connect(function()
    setMenu(not menuOpen)
end)

trash.Activated:Connect(function()
    setMenu(false)
end)

print(
    "[HamsterMetro] Fixed v4 loaded"
	) 
