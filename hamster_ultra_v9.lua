--[[
    HAMSTER LIVES  -  ULTRA V9  |  TR EDITION
    Executor LocalScript.  RightShift = menu ac/kapa  (mobilde: yuzen bayrak butonu)
    Tekrar calistirirsan eski surum otomatik kapanir.
]]

local env = (getgenv and getgenv()) or _G
if env.HL_V9_UNLOAD then pcall(env.HL_V9_UNLOAD) end

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local VIM          = game:GetService("VirtualInputManager")
local VirtualUser  = game:GetService("VirtualUser")
local LocalPlayer  = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local kAtaturkImage = ""   -- FILL: Ataturk fotografini Roblox'a Decal/Image olarak yukle, id'yi buraya yaz: "rbxassetid://123456789"
local kToggleKey    = Enum.KeyCode.RightShift
local kEspTick      = 0.10
local kHitboxTick   = 0.20
local kRapidDelay   = 0.06
local kIntroQuote   = "\"Hayatta en hakiki murside ilimdir.\""
local kIntroQuoteTR = "“Hayatta en hakiki mürşit ilimdir.”"

-- ============================================================
-- UTIL
-- ============================================================
local conns, alive = {}, true
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local function getCam() return Workspace.CurrentCamera end

local function resolveGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = game:GetService("CoreGui")
        t:Destroy()
    end)
    if ok then return game:GetService("CoreGui") end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local GUI_PARENT = resolveGuiParent()

local function new(class, props)
    local o = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else o[k] = v end
    end
    o.Parent = parent
    return o
end

local function tw(obj, t, props, style)
    local tween = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function circ(o) new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = o}) end
local function round(o, r) new("UICorner", {CornerRadius = UDim.new(0, r), Parent = o}) end

local C = {
    red      = Color3.fromRGB(227, 10, 23),
    white    = Color3.new(1, 1, 1),
    bg       = Color3.fromRGB(16, 10, 30),
    row      = Color3.fromRGB(34, 22, 62),
    pink     = Color3.fromRGB(255, 60, 170),
    cyan     = Color3.fromRGB(60, 230, 255),
    text     = Color3.fromRGB(238, 232, 255),
    dim      = Color3.fromRGB(160, 150, 195),
    off      = Color3.fromRGB(70, 60, 100),
    green    = Color3.fromRGB(60, 255, 120),
}

-- ============================================================
-- TURK BAYRAGI (frame ile cizilir, emoji'ye bagimli degil)
-- ============================================================
local function makeFlag(parent, size, position, anchor)
    local f = new("Frame", {
        Name = "TRFlag", Size = size, Position = position or UDim2.new(),
        AnchorPoint = anchor or Vector2.zero, BackgroundColor3 = C.red,
        BorderSizePixel = 0, ClipsDescendants = true, Parent = parent,
    })
    -- hilal: beyaz dis daire + kirmizi ic daire (resmi oranlar, h=1 w=1.5)
    local outer = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0.3333, 0.5),
        Size = UDim2.fromScale(0.3333, 0.5), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = f})
    circ(outer)
    local inner = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0.3667, 0.5),
        Size = UDim2.fromScale(0.2667, 0.4), BackgroundColor3 = C.red, BorderSizePixel = 0, Parent = f})
    circ(inner)
    new("TextLabel", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0.59, 0.5),
        Size = UDim2.fromScale(0.2, 0.34), BackgroundTransparency = 1, Text = "★", TextScaled = true,
        TextColor3 = C.white, Font = Enum.Font.SourceSansBold, Rotation = -18, Parent = f})
    return f
end

local function makeAtaturk(parent, size, position, anchor, asCircle)
    if kAtaturkImage == "" then return nil end
    local img = new("ImageLabel", {Size = size, Position = position, AnchorPoint = anchor or Vector2.zero,
        BackgroundColor3 = C.red, Image = kAtaturkImage, ScaleType = Enum.ScaleType.Crop,
        BorderSizePixel = 0, Parent = parent})
    new("UICorner", {CornerRadius = asCircle and UDim.new(0.5, 0) or UDim.new(0, 12), Parent = img})
    new("UIStroke", {Color = C.white, Thickness = 2, Parent = img})
    return img
end

-- ============================================================
-- ZORUNLU GIRIS  (TAMAM'a basilmadan hicbir sey baslamaz)
-- ============================================================
local function runIntro()
    local g = new("ScreenGui", {Name = "HL_V9_Intro", IgnoreGuiInset = true, ResetOnSpawn = false,
        DisplayOrder = 10000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})
    local root = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(12, 6, 22),
        BorderSizePixel = 0, Active = true, GroupTransparency = 1, Parent = g})
    new("UIGradient", {Rotation = 90, Parent = root, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 0, 18)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 8, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 22)),
    })})

    local content = new("Frame", {Size = UDim2.fromOffset(520, 650), Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5), BackgroundTransparency = 1, Parent = root})
    local scale = new("UIScale", {Parent = content})
    local function fit()
        local vp = getCam().ViewportSize
        scale.Scale = math.clamp(math.min(vp.X / 560, vp.Y / 680), 0.4, 1.3)
    end
    fit()

    local flag = makeFlag(content, UDim2.fromOffset(330, 220), UDim2.new(0.5, 0, 0, 0), Vector2.new(.5, 0))
    new("UIStroke", {Color = C.white, Thickness = 2, Parent = flag})

    local y = 236
    local img = makeAtaturk(content, UDim2.fromOffset(112, 132), UDim2.new(0.5, 0, 0, y), Vector2.new(.5, 0), false)
    if not img then
        new("TextLabel", {Size = UDim2.fromOffset(460, 64), Position = UDim2.new(0.5, 0, 0, y + 20),
            AnchorPoint = Vector2.new(.5, 0), BackgroundTransparency = 1, Text = kIntroQuoteTR,
            TextColor3 = C.dim, Font = Enum.Font.GothamMedium, TextSize = 18, TextWrapped = true, Parent = content})
    end
    new("TextLabel", {Size = UDim2.fromOffset(480, 28), Position = UDim2.new(0.5, 0, 0, 372),
        AnchorPoint = Vector2.new(.5, 0), BackgroundTransparency = 1, Text = "MUSTAFA KEMAL ATATÜRK",
        TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 22, Parent = content})
    new("TextLabel", {Size = UDim2.fromOffset(480, 20), Position = UDim2.new(0.5, 0, 0, 400),
        AnchorPoint = Vector2.new(.5, 0), BackgroundTransparency = 1, Text = "1881 – 1938",
        TextColor3 = C.dim, Font = Enum.Font.Gotham, TextSize = 15, Parent = content})

    local title = new("TextLabel", {Size = UDim2.fromOffset(500, 96), Position = UDim2.new(0.5, 0, 0, 436),
        AnchorPoint = Vector2.new(.5, 0), BackgroundTransparency = 1, Text = "NE MUTLU TÜRKÜM DİYENE 🇹🇷",
        TextColor3 = C.white, Font = Enum.Font.GothamBlack, TextScaled = true, TextWrapped = true, Parent = content})
    new("UIStroke", {Color = C.red, Thickness = 3, Parent = title})

    local btn = new("TextButton", {Size = UDim2.fromOffset(260, 60), Position = UDim2.new(0.5, 0, 0, 556),
        AnchorPoint = Vector2.new(.5, 0), BackgroundColor3 = C.red, Text = "TAMAM", TextColor3 = C.white,
        Font = Enum.Font.GothamBlack, TextSize = 26, AutoButtonColor = true, Parent = content})
    round(btn, 14)
    new("UIStroke", {Color = C.white, Thickness = 2, Parent = btn})

    -- bayrak dalgalanma
    local t0 = os.clock()
    local wave = RunService.RenderStepped:Connect(function()
        flag.Rotation = math.sin((os.clock() - t0) * 2) * 1.6
        fit()
    end)

    tw(root, 0.5, {GroupTransparency = 0})
    local done = Instance.new("BindableEvent")
    btn.Activated:Connect(function() done:Fire() end)
    done.Event:Wait()

    tw(root, 0.45, {GroupTransparency = 1})
    task.wait(0.5)
    wave:Disconnect()
    g:Destroy()
    done:Destroy()
end

runIntro()   -- <<< TAMAM'a basilana kadar asagisi calismaz

-- ============================================================
-- STATE
-- ============================================================
local S = {
    -- savas
    Aim = false, AimFov = 160, AimSmooth = 0.30, AimPart = "Head", AimVisible = true, ShowFov = true,
    Trigger = false, TriggerDelay = 0.08, RapidFire = false,
    Hitbox = false, HitboxSize = 14, HitboxTransp = 0.7, TeamCheck = true,
    -- gorsel
    Esp = false, EspInfo = true, Crosshair = false, Fullbright = false, FovOn = false, Fov = 90,
    -- hareket
    Speed = false, WalkSpeed = 40, InfJump = false, HighJump = false, JumpPower = 90,
    Fly = false, FlySpeed = 60, Noclip = false, LowGrav = false, Gravity = 60,
    Spin = false, SpinSpeed = 10,
    -- ekstra
    AntiAfk = true,
}
local Hooks, Toggles, Orig = {}, {}, {}

local function me()
    local c = LocalPlayer.Character
    return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end
local function humOf(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function rootOf(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function isAlive(c) local h = humOf(c); return h ~= nil and h.Health > 0 end

local function isEnemy(p)
    if p == LocalPlayer then return false end
    if not S.TeamCheck then return true end
    local a, b = LocalPlayer.Team, p.Team
    if a and b then return a ~= b end
    return true
end

-- ============================================================
-- OVERLAY (FOV dairesi, nisangah, filigran, bildirim)
-- ============================================================
local overlay = new("ScreenGui", {Name = "HL_V9_Overlay", IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 900, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})

local fovCircle = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundTransparency = 1, Visible = false, Parent = overlay})
circ(fovCircle)
new("UIStroke", {Color = C.red, Thickness = 1.5, Transparency = 0.2, Parent = fovCircle})

local cross = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Visible = false, Parent = overlay})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(22, 2),
    BackgroundColor3 = C.red, BorderSizePixel = 0, Parent = cross})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(2, 22),
    BackgroundColor3 = C.red, BorderSizePixel = 0, Parent = cross})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(4, 4),
    BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = cross})

local wm = new("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(0.5, 0, 0, 6),
    Size = UDim2.fromOffset(150, 26), BackgroundColor3 = C.bg, BackgroundTransparency = 0.35,
    BorderSizePixel = 0, Parent = overlay})
round(wm, 8)
new("UIStroke", {Color = C.red, Thickness = 1, Parent = wm})
makeFlag(wm, UDim2.fromOffset(30, 20), UDim2.fromOffset(4, 3))
new("TextLabel", {Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -42, 1, 0), BackgroundTransparency = 1,
    Text = "ULTRA V9 · TÜRKİYE", TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = wm})

local function notify(text)
    local f = new("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(0.5, 0, 0, 40),
        Size = UDim2.fromOffset(260, 28), BackgroundColor3 = C.bg, BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = overlay})
    round(f, 8)
    local st = new("UIStroke", {Color = C.pink, Thickness = 1, Transparency = 1, Parent = f})
    local l = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "★ " .. text,
        TextColor3 = C.white, Font = Enum.Font.GothamMedium, TextSize = 13, TextTransparency = 1, Parent = f})
    tw(f, 0.2, {BackgroundTransparency = 0.2, Position = UDim2.new(0.5, 0, 0, 44)})
    tw(l, 0.2, {TextTransparency = 0}); tw(st, 0.2, {Transparency = 0.2})
    task.delay(1.4, function()
        tw(f, 0.3, {BackgroundTransparency = 1}); tw(l, 0.3, {TextTransparency = 1}); tw(st, 0.3, {Transparency = 1})
        task.wait(0.35); f:Destroy()
    end)
end

-- ============================================================
-- HITBOX  (orijinal degerler saklanir, kapaninca geri yuklenir)
-- ============================================================
local hitOrig = setmetatable({}, {__mode = "k"})
local function applyHitbox(r)
    if not hitOrig[r] then
        hitOrig[r] = {Size = r.Size, Transparency = r.Transparency, CanCollide = r.CanCollide,
            Color = r.Color, Material = r.Material}
    end
    local s = S.HitboxSize
    r.Size = Vector3.new(s, s, s)
    r.Transparency = S.HitboxTransp
    r.Color = C.red
    r.Material = Enum.Material.Neon
    r.CanCollide = false
end
local function restoreHitbox(r)
    local o = hitOrig[r]
    if not o then return end
    for k, v in pairs(o) do pcall(function() r[k] = v end) end
    hitOrig[r] = nil
end
local function restoreAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        local r = rootOf(p.Character)
        if r then restoreHitbox(r) end
    end
end
local function hitboxStep()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            local r = rootOf(c)
            if r then
                if S.Hitbox and isEnemy(p) and isAlive(c) then applyHitbox(r) else restoreHitbox(r) end
            end
        end
    end
end
Hooks.Hitbox = function(v) if not v then restoreAllHitboxes() end end

-- ============================================================
-- ESP  (oyuncu basina bir kez kurulur, sadece guncellenir)
-- ============================================================
local espFolder = new("Folder", {Name = "HL_V9_ESP", Parent = GUI_PARENT})
local esp = {}

local function clearEsp(p)
    local e = esp[p]
    if e then pcall(function() e.hl:Destroy(); e.bb:Destroy() end); esp[p] = nil end
end
local function clearAllEsp() for p in pairs(esp) do clearEsp(p) end end

local function buildEsp(p, char)
    clearEsp(p)
    local head = char:FindFirstChild("Head") or rootOf(char)
    if not head then return end
    local hl = new("Highlight", {Adornee = char, FillTransparency = 0.55, OutlineTransparency = 0,
        OutlineColor = C.white, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = espFolder})
    local bb = new("BillboardGui", {Adornee = head, AlwaysOnTop = true, Size = UDim2.fromOffset(160, 34),
        StudsOffset = Vector3.new(0, 2.6, 0), ResetOnSpawn = false, Parent = espFolder})
    local name = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white, TextStrokeTransparency = 0.3, Parent = bb})
    local barBg = new("Frame", {Position = UDim2.new(.5, 0, 0, 24), AnchorPoint = Vector2.new(.5, 0),
        Size = UDim2.fromOffset(100, 5), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, Parent = bb})
    local fill = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.green, BorderSizePixel = 0, Parent = barBg})
    esp[p] = {hl = hl, bb = bb, name = name, fill = fill, char = char}
end

local function espStep()
    local cam = getCam()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            local r = rootOf(c)
            if S.Esp and c and r and isAlive(c) then
                local e = esp[p]
                if not e or e.char ~= c or not e.hl.Parent then buildEsp(p, c); e = esp[p] end
                if e then
                    e.hl.FillColor = isEnemy(p) and C.red or C.green
                    e.bb.Enabled = S.EspInfo
                    local h = humOf(c)
                    local dist = math.floor((cam.CFrame.Position - r.Position).Magnitude)
                    e.name.Text = string.format("%s [%dm]", p.DisplayName, dist)
                    local frac = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
                    e.fill.Size = UDim2.fromScale(frac, 1)
                    e.fill.BackgroundColor3 = Color3.fromRGB(255 * (1 - frac), 255 * frac, 60)
                end
            else
                clearEsp(p)
            end
        end
    end
end
Hooks.Esp = function(v) if not v then clearAllEsp() end end
bind(Players.PlayerRemoving, function(p) clearEsp(p); local r = rootOf(p.Character); if r then restoreHitbox(r) end end)

-- ============================================================
-- AIMBOT / TRIGGERBOT / SERI ATES
-- ============================================================
local function visibleCheck(part, char)
    local cam = getCam()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char}
    params.IgnoreWater = true
    local o = cam.CFrame.Position
    return Workspace:Raycast(o, part.Position - o, params) == nil
end

local function getAimTarget()
    local cam = getCam()
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestD = nil, S.AimFov
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local c = p.Character
            if c and isAlive(c) then
                local part = c:FindFirstChild(S.AimPart) or rootOf(c)
                if part then
                    local sp, on = cam:WorldToViewportPoint(part.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD and (not S.AimVisible or visibleCheck(part, c)) then
                            best, bestD = part, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local function aimActive()
    if isMobile then return true end
    return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

local function crosshairEnemy()
    local cam = getCam()
    local vp = cam.ViewportSize
    local ray = cam:ViewportPointToRay(vp.X / 2, vp.Y / 2)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not hit then return false end
    local inst = hit.Instance
    while inst and inst ~= Workspace do
        local p = Players:GetPlayerFromCharacter(inst)
        if p then return isEnemy(p) and isAlive(p.Character) end
        inst = inst.Parent
    end
    return false
end

local function fireOnce()
    local c = LocalPlayer.Character
    local tool = c and c:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    elseif mouse1click then
        pcall(mouse1click)
    else
        pcall(function()
            local m = UIS:GetMouseLocation()
            VIM:SendMouseButtonEvent(m.X, m.Y, 0, true, game, 0)
            VIM:SendMouseButtonEvent(m.X, m.Y, 0, false, game, 0)
        end)
    end
end

-- ============================================================
-- HAREKET
-- ============================================================
local flyBV
local function flyStep()
    local _, h, r = me()
    if not (S.Fly and h and r) then
        if flyBV then flyBV:Destroy(); flyBV = nil end
        return
    end
    if not flyBV or flyBV.Parent ~= r then
        if flyBV then flyBV:Destroy() end
        flyBV = new("BodyVelocity", {MaxForce = Vector3.new(1e6, 1e6, 1e6), Velocity = Vector3.zero, Parent = r})
    end
    h.PlatformStand = true
    local cf = getCam().CFrame
    local md = h.MoveDirection
    local vel = Vector3.zero
    if md.Magnitude > 0 then
        local rel = cf:VectorToObjectSpace(md)
        vel = cf.LookVector * (-rel.Z) + cf.RightVector * rel.X
    end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.yAxis end
    flyBV.Velocity = vel * S.FlySpeed
end
Hooks.Fly = function(v)
    if not v then
        if flyBV then flyBV:Destroy(); flyBV = nil end
        local _, h = me()
        if h then h.PlatformStand = false end
    end
end

Hooks.Speed = function(v)
    local _, h = me()
    if not h then return end
    if v then Orig.WalkSpeed = h.WalkSpeed else h.WalkSpeed = Orig.WalkSpeed or 16 end
end
Hooks.HighJump = function(v)
    local _, h = me()
    if not h then return end
    if v then Orig.JumpPower = h.JumpPower; Orig.UseJumpPower = h.UseJumpPower
    else h.UseJumpPower = Orig.UseJumpPower ~= false; h.JumpPower = Orig.JumpPower or 50 end
end
Hooks.LowGrav = function(v)
    if v then Orig.Gravity = Workspace.Gravity else Workspace.Gravity = Orig.Gravity or 196.2 end
end
Hooks.Spin = function(v)
    if not v then local _, h = me(); if h then h.AutoRotate = true end end
end

local noclipOrig = setmetatable({}, {__mode = "k"})
local function noclipStep()
    local c = LocalPlayer.Character
    if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipOrig[part] == nil then noclipOrig[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end
Hooks.Noclip = function(v)
    if not v then
        for part, was in pairs(noclipOrig) do pcall(function() part.CanCollide = was end) end
        table.clear(noclipOrig)
    end
end

bind(UIS.JumpRequest, function()
    if S.InfJump then
        local _, h = me()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
-- GORSEL
-- ============================================================
local lightProps = {"Brightness", "ClockTime", "FogEnd", "GlobalShadows", "Ambient", "OutdoorAmbient"}
Hooks.Fullbright = function(v)
    if v then
        for _, k in ipairs(lightProps) do Orig["L_" .. k] = Lighting[k] end
    else
        for _, k in ipairs(lightProps) do
            if Orig["L_" .. k] ~= nil then pcall(function() Lighting[k] = Orig["L_" .. k] end) end
        end
    end
end
local function lightStep()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e9
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
end
Hooks.FovOn = function(v)
    local cam = getCam()
    if v then Orig.Fov = cam.FieldOfView else cam.FieldOfView = Orig.Fov or 70 end
end

-- ============================================================
-- ANA DONGULER
-- ============================================================
local acc = {esp = 0, hit = 0, light = 0, rapid = 0}
local lastShot = 0

bind(RunService.Heartbeat, function(dt)
    if not alive then return end
    local _, h, r = me()

    if h then
        if S.Speed then h.WalkSpeed = S.WalkSpeed end
        if S.HighJump then h.UseJumpPower = true; h.JumpPower = S.JumpPower end
        if S.Spin then h.AutoRotate = false end
    end
    if S.LowGrav then Workspace.Gravity = S.Gravity end
    if S.Spin and r then
        r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(S.SpinSpeed * dt * 60), 0)   -- Mevlana
    end
    flyStep()

    acc.esp += dt; acc.hit += dt; acc.light += dt; acc.rapid += dt
    if acc.esp >= kEspTick then acc.esp = 0; espStep() end
    if acc.hit >= kHitboxTick then acc.hit = 0; if S.Hitbox then hitboxStep() end end
    if S.Fullbright and acc.light >= 1 then acc.light = 0; lightStep() end

    if S.Trigger and os.clock() - lastShot >= S.TriggerDelay and crosshairEnemy() then
        lastShot = os.clock()
        fireOnce()
    end
    if S.RapidFire and acc.rapid >= kRapidDelay and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        acc.rapid = 0
        local c = LocalPlayer.Character
        local tool = c and c:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end
end)

bind(RunService.Stepped, function() if alive and S.Noclip then noclipStep() end end)

bind(RunService.RenderStepped, function(dt)
    if not alive then return end
    local cam = getCam()
    if S.FovOn then cam.FieldOfView = S.Fov end

    fovCircle.Visible = S.Aim and S.ShowFov
    fovCircle.Size = UDim2.fromOffset(S.AimFov * 2, S.AimFov * 2)
    cross.Visible = S.Crosshair

    if S.Aim and aimActive() then
        local part = getAimTarget()
        if part then
            local alpha = 1 - (1 - math.clamp(S.AimSmooth, 0.02, 1)) ^ (dt * 60)
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, part.Position), alpha)
        end
    end
end)

-- anti-afk
bind(LocalPlayer.Idled, function()
    if S.AntiAfk then
        pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end
end)

-- respawn: dongu zaten her frame uyguluyor, sadece hitbox/noclip tablolarini sifirla
bind(LocalPlayer.CharacterAdded, function()
    table.clear(noclipOrig)
    if flyBV then flyBV:Destroy(); flyBV = nil end
end)

-- ============================================================
-- MENU
-- ============================================================
local ui = new("ScreenGui", {Name = "HL_V9_UI", IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 950, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})

local PANEL_W = 460
local panel = new("CanvasGroup", {Name = "Panel", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromOffset(PANEL_W, 560), BackgroundColor3 = C.bg, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, Active = true, GroupTransparency = 1, Visible = false, Parent = ui})
round(panel, 18)
local panelScale = new("UIScale", {Parent = panel})
local bgGrad = new("UIGradient", {Rotation = 45, Parent = panel, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 14, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 10, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 8, 28)),
})})
local stroke = new("UIStroke", {Color = C.white, Thickness = 2, Parent = panel})
local strokeGrad = new("UIGradient", {Parent = stroke, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.pink), ColorSequenceKeypoint.new(0.5, C.cyan), ColorSequenceKeypoint.new(1, C.red),
})})

-- header
local header = new("Frame", {Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, Parent = panel})
local hFlag = makeFlag(header, UDim2.fromOffset(54, 36), UDim2.fromOffset(14, 14))
round(hFlag, 6)
new("TextLabel", {Position = UDim2.fromOffset(78, 10), Size = UDim2.fromOffset(250, 24), BackgroundTransparency = 1,
    Text = "HAMSTER LIVES", TextColor3 = C.white, Font = Enum.Font.GothamBlack, TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header})
new("TextLabel", {Position = UDim2.fromOffset(78, 34), Size = UDim2.fromOffset(280, 18), BackgroundTransparency = 1,
    Text = "ULTRA V9 · NE MUTLU TÜRKÜM DİYENE", TextColor3 = C.pink, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header})
makeAtaturk(header, UDim2.fromOffset(40, 40), UDim2.new(1, -104, 0, 12), Vector2.zero, true)
local closeBtn = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14),
    Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.row, Text = "—", TextColor3 = C.white,
    Font = Enum.Font.GothamBlack, TextSize = 18, Parent = header})
circ(closeBtn)

-- sekmeler
local tabBar = new("Frame", {Position = UDim2.fromOffset(12, 68), Size = UDim2.fromOffset(436, 36),
    BackgroundTransparency = 1, Parent = panel})
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = tabBar})

local pageHolder = new("Frame", {Position = UDim2.fromOffset(12, 112), Size = UDim2.new(1, -24, 1, -142),
    BackgroundTransparency = 1, Parent = panel})
new("TextLabel", {AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -6), Size = UDim2.fromOffset(420, 18),
    BackgroundTransparency = 1, Text = "★  RightShift: menü aç/kapa  ★", TextColor3 = C.dim,
    Font = Enum.Font.Gotham, TextSize = 11, Parent = panel})

local pages, tabBtns, order = {}, {}, {"SAVAŞ", "GÖRSEL", "HAREKET", "EKSTRA", "TÜRKİYE"}

local function newPage(name)
    local sf = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.pink, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(), Visible = false, Parent = pageHolder})
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sf})
    new("UIPadding", {PaddingBottom = UDim.new(0, 8), Parent = sf})
    pages[name] = sf
    return sf
end

local function showTab(name)
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        tw(b, 0.2, {BackgroundColor3 = (n == name) and C.pink or C.row})
        b.TextColor3 = (n == name) and C.white or C.dim
    end
end

for _, name in ipairs(order) do
    newPage(name)
    local b = new("TextButton", {Size = UDim2.fromOffset(84, 36), BackgroundColor3 = C.row, Text = name,
        TextColor3 = C.dim, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = tabBar})
    round(b, 10)
    tabBtns[name] = b
    b.Activated:Connect(function() showTab(name) end)
end

-- satir kurucular
local function addSection(page, text)
    new("TextLabel", {Size = UDim2.new(1, -8, 0, 20), BackgroundTransparency = 1, Text = "—  " .. text .. "  —",
        TextColor3 = C.cyan, Font = Enum.Font.GothamBold, TextSize = 12, Parent = page})
end

local function addToggle(page, text, key)
    local row = new("Frame", {Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = C.row, BackgroundTransparency = 0.2,
        BorderSizePixel = 0, Parent = page})
    round(row, 10)
    new("TextLabel", {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -84, 1, 0), BackgroundTransparency = 1,
        Text = text, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row})
    local sw = new("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0),
        Size = UDim2.fromOffset(46, 24), BackgroundColor3 = C.off, Text = "", AutoButtonColor = false, Parent = row})
    circ(sw)
    local knob = new("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = sw})
    circ(knob)
    local function render()
        local on = S[key]
        tw(sw, 0.18, {BackgroundColor3 = on and C.pink or C.off})
        tw(knob, 0.18, {Position = on and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)})
    end
    local function set(v, silent)
        S[key] = v
        render()
        if Hooks[key] then task.spawn(Hooks[key], v) end
        if not silent then notify(text .. (v and ": AÇIK" or ": KAPALI")) end
    end
    Toggles[key] = set
    render()
    sw.Activated:Connect(function() set(not S[key]) end)
end

local function addSlider(page, text, key, minV, maxV, step, fmt)
    fmt = fmt or "%d"
    local row = new("Frame", {Size = UDim2.new(1, -8, 0, 56), BackgroundColor3 = C.row, BackgroundTransparency = 0.2,
        BorderSizePixel = 0, Parent = page})
    round(row, 10)
    new("TextLabel", {Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -90, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
    local valLbl = new("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6),
        Size = UDim2.fromOffset(70, 20), BackgroundTransparency = 1, Text = "", TextColor3 = C.cyan,
        Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = row})
    local track = new("Frame", {Position = UDim2.new(0, 14, 0, 38), Size = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = C.off, BorderSizePixel = 0, Parent = row})
    circ(track)
    local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.pink, BorderSizePixel = 0, Parent = track})
    circ(fill)
    local knob = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5),
        Size = UDim2.fromOffset(18, 18), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = track})
    circ(knob)
    local hit = new("TextButton", {Position = UDim2.new(0, 8, 0, 26), Size = UDim2.new(1, -16, 0, 30),
        BackgroundTransparency = 1, Text = "", Parent = row})

    local function visual()
        local a = (S[key] - minV) / (maxV - minV)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, .5)
        valLbl.Text = string.format(fmt, S[key])
    end
    visual()

    local dragging = false
    local function setFromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local v = minV + a * (maxV - minV)
        S[key] = math.clamp(math.floor(v / step + 0.5) * step, minV, maxV)
        visual()
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            page.ScrollingEnabled = false
            setFromX(i.Position.X)
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end)
    bind(UIS.InputEnded, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            page.ScrollingEnabled = true
        end
    end)
end

local function addChoice(page, text, key, values, labels)
    local row = new("TextButton", {Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = C.row, BackgroundTransparency = 0.2,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = page})
    round(row, 10)
    local lbl = new("TextLabel", {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1,
        Text = "", TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
    local function render()
        for i, v in ipairs(values) do
            if v == S[key] then lbl.Text = text .. ":  " .. labels[i] .. "  ▸"; return end
        end
    end
    render()
    row.Activated:Connect(function()
        local idx = table.find(values, S[key]) or 1
        S[key] = values[idx % #values + 1]
        render()
    end)
end

local function addButton(page, text, color, cb)
    local b = new("TextButton", {Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = color or C.row, BackgroundTransparency = 0.1,
        BorderSizePixel = 0, Text = text, TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 14, Parent = page})
    round(b, 10)
    b.Activated:Connect(cb)
end

-- ---- SAVAS
do
    local p = pages["SAVAŞ"]
    addSection(p, "NİŞAN")
    addToggle(p, "Aimbot  (PC: sağ tık basılı)", "Aim")
    addSlider(p, "Aimbot FOV", "AimFov", 40, 400, 5)
    addSlider(p, "Yumuşatma  (1 = sert kilit)", "AimSmooth", 0.05, 1, 0.05, "%.2f")
    addChoice(p, "Hedef bölge", "AimPart", {"Head", "HumanoidRootPart"}, {"Kafa", "Gövde"})
    addToggle(p, "Sadece görünenleri hedefle", "AimVisible")
    addToggle(p, "FOV dairesini göster", "ShowFov")
    addSection(p, "ATEŞ")
    addToggle(p, "Triggerbot", "Trigger")
    addSlider(p, "Trigger gecikmesi (sn)", "TriggerDelay", 0.02, 0.5, 0.01, "%.2f")
    addToggle(p, "Seri ateş  (sol tık basılı)", "RapidFire")
    addSection(p, "HİTBOX")
    addToggle(p, "Hitbox genişletici", "Hitbox")
    addSlider(p, "Hitbox boyutu", "HitboxSize", 4, 40, 1)
    addSlider(p, "Hitbox saydamlığı", "HitboxTransp", 0, 1, 0.05, "%.2f")
    addToggle(p, "Takım kontrolü", "TeamCheck")
end

-- ---- GORSEL
do
    local p = pages["GÖRSEL"]
    addSection(p, "ESP")
    addToggle(p, "ESP  (highlight)", "Esp")
    addToggle(p, "İsim / can / mesafe", "EspInfo")
    addSection(p, "EKRAN")
    addToggle(p, "Nişangah", "Crosshair")
    addToggle(p, "Fullbright", "Fullbright")
    addToggle(p, "FOV değiştirici", "FovOn")
    addSlider(p, "Kamera FOV", "Fov", 50, 120, 1)
end

-- ---- HAREKET
do
    local p = pages["HAREKET"]
    addSection(p, "KOŞU / ZIPLAMA")
    addToggle(p, "Hız", "Speed")
    addSlider(p, "Yürüme hızı", "WalkSpeed", 16, 200, 1)
    addToggle(p, "Sonsuz zıplama", "InfJump")
    addToggle(p, "Yüksek zıplama", "HighJump")
    addSlider(p, "Zıplama gücü", "JumpPower", 50, 300, 5)
    addSection(p, "UÇUŞ")
    addToggle(p, "Fly  (Space yukarı / Ctrl aşağı)", "Fly")
    addSlider(p, "Uçuş hızı", "FlySpeed", 20, 200, 5)
    addToggle(p, "Noclip", "Noclip")
    addToggle(p, "Düşük yerçekimi", "LowGrav")
    addSlider(p, "Yerçekimi", "Gravity", 10, 196, 2)
    addSection(p, "MEVLANA")
    addToggle(p, "Dönüş (Mevlana)", "Spin")
    addSlider(p, "Dönüş hızı", "SpinSpeed", 1, 60, 1)
end

-- ---- EKSTRA
local function unload()
    alive = false
    for k in pairs(S) do if S[k] == true and Hooks[k] then pcall(Hooks[k], false) end end
    restoreAllHitboxes(); clearAllEsp()
    if flyBV then flyBV:Destroy() end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() ui:Destroy(); overlay:Destroy(); espFolder:Destroy() end)
    env.HL_V9_UNLOAD = nil
end
env.HL_V9_UNLOAD = unload

do
    local p = pages["EKSTRA"]
    addSection(p, "GENEL")
    addToggle(p, "Anti-AFK", "AntiAfk")
    addButton(p, "Tüm modülleri kapat", C.row, function()
        for key, set in pairs(Toggles) do
            if key ~= "AntiAfk" and S[key] == true then set(false, true) end
        end
        notify("Tüm modüller kapatıldı")
    end)
    addButton(p, "Scripti tamamen kaldır", Color3.fromRGB(150, 10, 30), unload)
end

-- ---- TURKIYE
do
    local p = pages["TÜRKİYE"]
    local box = new("Frame", {Size = UDim2.new(1, -8, 0, 170), BackgroundTransparency = 1, Parent = p})
    local f = makeFlag(box, UDim2.fromOffset(240, 160), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
    round(f, 10)
    new("UIStroke", {Color = C.white, Thickness = 2, Parent = f})
    if kAtaturkImage ~= "" then
        local b2 = new("Frame", {Size = UDim2.new(1, -8, 0, 150), BackgroundTransparency = 1, Parent = p})
        makeAtaturk(b2, UDim2.fromOffset(120, 146), UDim2.fromScale(.5, .5), Vector2.new(.5, .5), false)
    end
    local function line(text, size, color, font, h)
        new("TextLabel", {Size = UDim2.new(1, -8, 0, h or 24), BackgroundTransparency = 1, Text = text, TextColor3 = color or C.white,
            Font = font or Enum.Font.GothamBold, TextSize = size or 15, TextWrapped = true, Parent = p})
    end
    line("MUSTAFA KEMAL ATATÜRK", 20, C.white, Enum.Font.GothamBlack, 28)
    line("1881 – 1938", 13, C.dim, Enum.Font.Gotham, 18)
    line("“Egemenlik kayıtsız şartsız milletindir.”", 14, C.cyan, Enum.Font.GothamMedium, 34)
    line("“Yurtta sulh, cihanda sulh.”", 14, C.cyan, Enum.Font.GothamMedium, 24)
    line("“Ne mutlu Türküm diyene!”", 16, C.pink, Enum.Font.GothamBlack, 30)
end

-- ---- layout / responsive
local function layout()
    local vp = getCam().ViewportSize
    local s = math.clamp(vp.X / 480, 0.5, 1.1)
    panelScale.Scale = s
    local h = math.clamp(vp.Y / s - 24, 260, 560)
    panel.Size = UDim2.fromOffset(PANEL_W, h)
    return s
end

-- yuzen bayrak butonu (surukle = tasi, dokun = ac/kapa)
local fab = new("Frame", {Name = "FAB", Position = UDim2.new(0, 14, 0.5, -22), Size = UDim2.fromOffset(66, 44),
    BackgroundTransparency = 1, Parent = ui})
local fabScale = new("UIScale", {Parent = fab})
local fabFlag = makeFlag(fab, UDim2.fromScale(1, 1))
round(fabFlag, 10)
new("UIStroke", {Color = C.white, Thickness = 2, Parent = fabFlag})
local fabHit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = fab})

local menuOpen = false
local function setMenu(open)
    menuOpen = open
    if open then
        panel.Visible = true
        panel.Position = UDim2.new(0.5, 0, 0.5, 14)
        tw(panel, 0.25, {GroupTransparency = 0, Position = UDim2.fromScale(.5, .5)})
    else
        tw(panel, 0.2, {GroupTransparency = 1})
        task.delay(0.22, function() if not menuOpen then panel.Visible = false end end)
    end
end

local function makeDraggable(handle, target, scaleObj, onTap)
    local dragging, moved, startMouse, startPos = false, 0, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, startMouse, startPos = true, 0, i.Position, target.Position
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startMouse
            moved = math.max(moved, d.Magnitude)
            local s = scaleObj.Scale
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / s,
                startPos.Y.Scale, startPos.Y.Offset + d.Y / s)
        end
    end)
    bind(UIS.InputEnded, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if onTap and moved < 8 then onTap() end
        end
    end)
end

makeDraggable(header, panel, panelScale, nil)
makeDraggable(fabHit, fab, fabScale, function() setMenu(not menuOpen) end)
closeBtn.Activated:Connect(function() setMenu(false) end)

bind(UIS.InputBegan, function(i, gp)
    if i.KeyCode == kToggleKey then setMenu(not menuOpen) end
end)

-- vaybe: gradient donusu + bayrak nefesi
local tStart, lastLayout = os.clock(), 0
bind(RunService.RenderStepped, function()
    local t = os.clock() - tStart
    strokeGrad.Rotation = (t * 60) % 360
    bgGrad.Rotation = 45 + math.sin(t * 0.6) * 25
    fabFlag.Rotation = math.sin(t * 2) * 2
    if t - lastLayout > 0.4 then
        lastLayout = t
        fabScale.Scale = layout()
    end
end)

layout()
showTab("SAVAŞ")
setMenu(true)
notify("Ne mutlu Türküm diyene!")
