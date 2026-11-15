-- Screen center prank overlay — geometric dick + finish + random loop 30-120s
-- LocalScript / executor. No remote calls.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local pg = LocalPlayer:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("ScreenPrankGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ScreenPrankGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.Visible = false
root.Parent = gui

-- skin tones
local SKIN = Color3.fromRGB(232, 190, 150)
local SKIN_D = Color3.fromRGB(200, 155, 120)
local TIP = Color3.fromRGB(220, 140, 150)
local BALL = Color3.fromRGB(210, 170, 130)
local WHITE = Color3.fromRGB(255, 255, 255)

local function circle(parent, size, pos, color, z)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    f.ZIndex = z or 10
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    return f
end

local function rect(parent, size, pos, color, z, radius)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    f.ZIndex = z or 10
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius or 12)
    return f
end

-- group centered on screen
local group = Instance.new("Frame")
group.Name = "DickGroup"
group.Size = UDim2.fromOffset(180, 260)
group.Position = UDim2.fromScale(0.5, 0.5)
group.AnchorPoint = Vector2.new(0.5, 0.5)
group.BackgroundTransparency = 1
group.ZIndex = 10
group.Parent = root

-- balls (two circles at bottom)
local ballL = circle(group, UDim2.fromOffset(70, 70), UDim2.new(0.28, 0, 0.82, 0), BALL, 11)
local ballR = circle(group, UDim2.fromOffset(70, 70), UDim2.new(0.72, 0, 0.82, 0), BALL, 11)
-- ball shade
circle(group, UDim2.fromOffset(28, 22), UDim2.new(0.28, 0, 0.86, 0), SKIN_D, 12)
circle(group, UDim2.fromOffset(28, 22), UDim2.new(0.72, 0, 0.86, 0), SKIN_D, 12)

-- shaft
local shaft = rect(group, UDim2.fromOffset(48, 140), UDim2.new(0.5, 0, 0.48, 0), SKIN, 13, 18)
-- shaft ridge lines (subtle)
for i = 1, 3 do
    local ridge = Instance.new("Frame")
    ridge.Size = UDim2.fromOffset(40, 3)
    ridge.Position = UDim2.new(0.5, 0, 0.28 + i * 0.12, 0)
    ridge.AnchorPoint = Vector2.new(0.5, 0.5)
    ridge.BackgroundColor3 = SKIN_D
    ridge.BackgroundTransparency = 0.55
    ridge.BorderSizePixel = 0
    ridge.ZIndex = 14
    ridge.Parent = group
    Instance.new("UICorner", ridge).CornerRadius = UDim.new(1, 0)
end

-- tip (glans)
local tip = circle(group, UDim2.fromOffset(56, 50), UDim2.new(0.5, 0, 0.18, 0), TIP, 15)
-- tip highlight
circle(group, UDim2.fromOffset(18, 14), UDim2.new(0.42, 0, 0.14, 0), Color3.fromRGB(255, 200, 200), 16)

-- opening (urethra)
local hole = circle(group, UDim2.fromOffset(10, 8), UDim2.new(0.5, 0, 0.12, 0), Color3.fromRGB(90, 50, 55), 17)

-- splash layer (particles parent)
local splash = Instance.new("Frame")
splash.Name = "Splash"
splash.Size = UDim2.fromScale(1, 1)
splash.BackgroundTransparency = 1
splash.ZIndex = 20
splash.Parent = root

local function clearSplash()
    for _, c in ipairs(splash:GetChildren()) do
        c:Destroy()
    end
end

local function spawnDrop(startPos, dir, size, life)
    local d = Instance.new("Frame")
    d.Size = UDim2.fromOffset(size, size)
    d.Position = startPos
    d.AnchorPoint = Vector2.new(0.5, 0.5)
    d.BackgroundColor3 = WHITE
    d.BorderSizePixel = 0
    d.ZIndex = 25
    d.Parent = splash
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)

    local endPos = UDim2.new(
        startPos.X.Scale + dir.X * 0.15 + (math.random() - 0.5) * 0.2,
        startPos.X.Offset + dir.X * 80,
        startPos.Y.Scale + dir.Y * 0.25 + math.random() * 0.15,
        startPos.Y.Offset + dir.Y * 120 + math.random(20, 90)
    )

    local tw = TweenService:Create(d, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos,
        Size = UDim2.fromOffset(size * 0.4, size * 0.4),
        BackgroundTransparency = 1,
    })
    tw:Play()
    tw.Completed:Connect(function()
        d:Destroy()
    end)
end

local function finishEffect()
    clearSplash()
    -- tip is roughly center-top of group → screen center shifted up a bit
    local origin = UDim2.fromScale(0.5, 0.38)
    for i = 1, 28 do
        local ang = math.rad(-110 + math.random() * 40)
        local dir = Vector2.new(math.cos(ang), math.sin(ang))
        task.delay(i * 0.012, function()
            spawnDrop(origin, dir, math.random(8, 18), 0.55 + math.random() * 0.45)
        end)
    end
    -- thicker stream
    for i = 1, 12 do
        task.delay(0.05 + i * 0.02, function()
            spawnDrop(
                UDim2.new(0.5, math.random(-6, 6), 0.36, 0),
                Vector2.new((math.random() - 0.5) * 0.3, 1),
                math.random(14, 22),
                0.7 + math.random() * 0.3
            )
        end)
    end
end

local function showSequence()
    root.Visible = true
    group.Visible = true
    clearSplash()

    -- pop in
    group.Size = UDim2.fromOffset(20, 30)
    local pop = TweenService:Create(group, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(180, 260),
    })
    pop:Play()
    pop.Completed:Wait()

    task.wait(0.35)
    finishEffect()
    task.wait(1.35)

    -- fade out by shrinking + hide
    local out = TweenService:Create(group, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(10, 14),
    })
    out:Play()
    out.Completed:Wait()
    clearSplash()
    root.Visible = false
end

-- loop: random 30–120s
task.spawn(function()
    while gui.Parent do
        local waitSec = math.random(30, 120)
        task.wait(waitSec)
        if not gui.Parent then break end
        pcall(showSequence)
    end
end)

-- optional: first show after short delay so you know it loaded
task.delay(3, function()
    if gui.Parent then pcall(showSequence) end
end)
