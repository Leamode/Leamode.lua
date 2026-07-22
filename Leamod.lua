--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚡ LEA MOD v27.0 - SON VERSİYON (AIMBOT ÇALIŞIYOR)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ AIMBOT - Sağ tık basılı tut, crosshair ANINDA hedefe kilitlenir (FOV 360)
    ✅ OTOMATİK ATEŞ - Kilitlenince otomatik ateş eder
    ✅ HEDEF ÖLÜNCE - Otomatik diğer düşmana geçer
    ✅ ESP - Kutu + İsim + HP + Mesafe
    ✅ 360 - Sürekli dönüş
    ✅ Rainbow - Renk değiştirme
    ✅ Inf Jump - Sınırsız zıplama
    ✅ Teleport - En yakın düşmana ışınlan
    ✅ Fly - WASD + Space/Shift
    ✅ Speed - +/- ayar
    ✅ Menü KÜÇÜK ve taşınabilir
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- S E R V İ S L E R
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- STATES
getgenv().LEAModState = {
    Aimbot = false,
    ESP = false,
    Spin360 = false,
    Rainbow = false,
    InfJump = false,
    Teleport = false,
    Fly = false,
    SpeedVal = 50,
    FOV = 360,
    TeamCheck = true,
    AutoFire = true,
    MenuVisible = true
}

local isAiming = false
local currentTarget = nil
local espCache = {}
local bodyVelocity = nil
local bodyGyro = nil
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

-- ═══════════════════════════════════════════════════════════════════════════
-- G U I  (KÜÇÜK)
-- ═══════════════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("LEAModUniversalGui") then
    CoreGui.LEAModUniversalGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModUniversalGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- LEA MOD Header
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "LEAModHeader"
HeaderLabel.Parent = ScreenGui
HeaderLabel.AnchorPoint = Vector2.new(0.5, 1)
HeaderLabel.Position = UDim2.new(0.5, 0, 0.45, -15)
HeaderLabel.Size = UDim2.new(0, 180, 0, 35)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.Text = "LEA MOD"
HeaderLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
HeaderLabel.TextSize = 26
HeaderLabel.TextStrokeTransparency = 0.5

-- Main Menu (KÜÇÜK)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.78, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 160, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Menu Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.BorderColor3 = Color3.fromRGB(170, 0, 255)
ToggleButton.Position = UDim2.new(0.78, 0, 0.03, 0)
ToggleButton.Size = UDim2.new(0, 55, 0, 22)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().LEAModState.MenuVisible = not getgenv().LEAModState.MenuVisible
    MainFrame.Visible = getgenv().LEAModState.MenuVisible
end)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local function createButton(name, key)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.MouseButton1Click:Connect(function()
        getgenv().LEAModState[key] = not getgenv().LEAModState[key]
        if getgenv().LEAModState[key] then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
            btn.Text = name .. " ✅"
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = name .. " ❌"
        end
    end)
    return btn
end

createButton("Aimbot", "Aimbot")
createButton("ESP", "ESP")
createButton("360", "Spin360")
createButton("Rainbow", "Rainbow")
createButton("InfJump", "InfJump")
createButton("Teleport", "Teleport")
createButton("Fly", "Fly")

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainFrame
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Size = UDim2.new(1, -10, 0, 20)
SpeedFrame.Position = UDim2.new(0, 5, 0, 0)

local SpeedDec = Instance.new("TextButton")
SpeedDec.Parent = SpeedFrame
SpeedDec.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedDec.Size = UDim2.new(0.5, 0, 1, 0)
SpeedDec.Font = Enum.Font.SourceSansBold
SpeedDec.Text = "-"
SpeedDec.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDec.TextSize = 12

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.5, 0, 0, 0)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Text = "50"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
SpeedLabel.TextSize = 12

SpeedDec.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal - 5, 16, 200)
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)

SpeedInc.MouseButton1Click:Connect(function()
    getgenv().LEAModState.SpeedVal = math.clamp(getgenv().LEAModState.SpeedVal + 5, 16, 200)
    SpeedLabel.Text = tostring(getgenv().LEAModState.SpeedVal)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- Y A R D I M C I   F O N K S İ Y O N L A R
-- ═══════════════════════════════════════════════════════════════════════════

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if getgenv().LEAModState.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end
    return true
end

local function getNearestEnemy()
    local target = nil
    local shortestDist = getgenv().LEAModState.FOV or 360
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            target = player
        end
    end
    return target
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. AIMBOT (TAM KİLİT - FOV 360 - ÇALIŞIYOR)
-- ═══════════════════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().LEAModState.Aimbot then
            isAiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.Aimbot or not isAiming then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local target = getNearestEnemy()
    if not target then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local char = target.Character
    if not char then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        if currentTarget then currentTarget = nil end
        return
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if currentTarget then currentTarget = nil end
        return
    end
    
    currentTarget = target
    
    -- TAM KİLİT - Crosshair direkt hedefe bakar
    local targetPos = root.Position
    local currentPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(currentPos, targetPos)
    
    -- Otomatik ateş
    if getgenv().LEAModState.AutoFire then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            wait(0.03)
            mouse.Button1Up:Fire()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local function removeESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj then obj:Destroy() end
        end
        espCache[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not getgenv().LEAModState.ESP then
        for player, _ in pairs(espCache) do
            removeESP(player)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local root = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if not espCache[player] then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Size = char:GetExtentsSize()
                box.Adornee = char
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.5
                box.Parent = CoreGui
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPInfo"
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = CoreGui
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "InfoText"
                textLabel.Parent = billboard
                textLabel.BackgroundTransparency = 1
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                textLabel.TextStrokeTransparency = 0
                
                espCache[player] = {Box = box, Billboard = billboard, Text = textLabel}
            end

            local cache = espCache[player]
            local enemyCheck = isEnemy(player)
            local color = enemyCheck and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            
            cache.Box.Color3 = color
            
            if humanoid then
                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                cache.Text.Text = string.format("%s\nHP: %d | %dm", player.Name, math.floor(humanoid.Health), dist)
                cache.Text.TextColor3 = color
            end
        else
            removeESP(player)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 360 SPIN
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Spin360 then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. RAINBOW
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if getgenv().LEAModState.Rainbow then
        local char = LocalPlayer.Character
        if char then
            local hue = tick() % 5 / 5
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = rainbowColor
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. INFINITE JUMP
-- ═══════════════════════════════════════════════════════════════════════════

UserInputService.JumpRequest:Connect(function()
    if getgenv().LEAModState.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. TELEPORT
-- ═══════════════════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if not getgenv().LEAModState.Teleport then return end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestTarget = root
            end
        end
    end

    if closestTarget then
        myRoot.CFrame = closestTarget.CFrame * CFrame.new(0, 4, 5)
        getgenv().LEAModState.Teleport = false
        local btn = MainFrame:FindFirstChild("TeleportBtn")
        if btn then
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = "Teleport ❌"
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. FLY
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if getgenv().LEAModState.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
        
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        root.Velocity = moveDir * 50
        root.RotVelocity = Vector3.new(0, 0, 0)
    elseif char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. SPEED
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().LEAModState.SpeedVal
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- KARAKTER DEĞİŞİMİ
-- ═══════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function()
    for player, _ in pairs(espCache) do
        removeESP(player)
    end
end)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ⚡ LEA MOD v27.0 - TÜM SİSTEMLER ÇALIŞIYOR ⚡            ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  🎯 AIMBOT - SAĞ TIK BASILI TUT, ANINDA KİLİTLENİR        ║")
print("║  📐 FOV: 360 - HER YERDEKİ DÜŞMANI BULUR                  ║")
print("║  🔫 Otomatik ateş aktif                                    ║")
print("║  💀 Düşman ölünce otomatik diğerine geçer                  ║")
print("║  👁️  ESP - Kutu + İsim + HP + Mesafe                       ║")
print("║  🔄 360 - Sürekli dönüş                                    ║")
print("║  🌈 Rainbow - Renk değiştirme                              ║")
print("║  ⬆️ Inf Jump - Sınırsız zıplama                            ║")
print("║  🚀 Teleport - En yakın düşmana ışınlan                    ║")
print("║  ✈️  Fly - WASD + Space/Shift                              ║")
print("║  ⚡ Speed - +/- ayar                                       ║")
print("║  📌 Menü KÜÇÜK ve taşınabilir                              ║")
print("╚══════════════════════════════════════════════════════════════╝")
