--[[
    HAMSTER LIVES  -  ULTRA V10  |  TR EDITION
    Executor LocalScript.  RightShift = menu ac/kapa  (mobilde: yuzen bayrak butonu)
    Tekrar calistirirsan eski surum otomatik kapanir.
]]

local env = (getgenv and getgenv()) or _G
if env.HL_UNLOAD then pcall(env.HL_UNLOAD) end

local cref = cloneref or function(x) return x end
local function svc(n) return cref(game:GetService(n)) end

local Players      = svc("Players")
local RunService   = svc("RunService")
local UIS          = svc("UserInputService")
local TweenService = svc("TweenService")
local Workspace    = svc("Workspace")
local Lighting     = svc("Lighting")
local VIM          = svc("VirtualInputManager")
local VirtualUser  = svc("VirtualUser")
local HttpService  = svc("HttpService")
local LocalPlayer  = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local kAtaturkImage = ""   -- FILL: Ataturk fotografini Roblox'a Image olarak yukle, id'yi yaz: "rbxassetid://123456789"
local kToggleKey    = Enum.KeyCode.RightShift
local kEspTick      = 0.10
local kHitboxTick   = 0.20
local kCacheTick    = 0.10
local kRapidDelay   = 0.06
local kAutoShotPx   = 28      -- silent aim kapaliyken auto atis icin nisangaha max piksel mesafe
local kShotWindow   = 0.5     -- tiklamadan sonra mermi raycast'i icin gecerli sure (sn)
local kShotRadius   = 40      -- raycast origin'i kameraya/karaktere bu kadar yakinsa "benim atisim"

-- ============================================================
-- UTIL
-- ============================================================
local conns, alive = {}, true
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end
local function rn() return HttpService:GenerateGUID(false) end
local function getCam() return Workspace.CurrentCamera end

local function resolveGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = svc("CoreGui")
        t:Destroy()
    end)
    if ok then return svc("CoreGui") end
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
    red   = Color3.fromRGB(227, 10, 23),
    white = Color3.new(1, 1, 1),
    text  = Color3.fromRGB(255, 255, 255),
    dim   = Color3.fromRGB(215, 205, 240),
    green = Color3.fromRGB(70, 255, 130),
}

local Themes = {
    {name = "Neon Vaybe",     a = Color3.fromRGB(255, 70, 180),  b = Color3.fromRGB(70, 235, 255),
     g = {Color3.fromRGB(130, 50, 215), Color3.fromRGB(55, 45, 150), Color3.fromRGB(215, 35, 110)}},
    {name = "Türk Kırmızısı", a = Color3.fromRGB(255, 60, 70),   b = Color3.fromRGB(255, 255, 255),
     g = {Color3.fromRGB(205, 25, 45), Color3.fromRGB(120, 15, 40), Color3.fromRGB(240, 55, 60)}},
    {name = "Okyanus",        a = Color3.fromRGB(50, 205, 255),  b = Color3.fromRGB(130, 255, 205),
     g = {Color3.fromRGB(25, 125, 215), Color3.fromRGB(20, 60, 140), Color3.fromRGB(10, 185, 180)}},
    {name = "Gün Batımı",     a = Color3.fromRGB(255, 160, 50),  b = Color3.fromRGB(255, 90, 130),
     g = {Color3.fromRGB(255, 120, 70), Color3.fromRGB(140, 40, 125), Color3.fromRGB(255, 70, 110)}},
}
local Theme = Themes[1]

-- ============================================================
-- TURK BAYRAGI
-- ============================================================
local function makeFlag(parent, size, position, anchor)
    local f = new("Frame", {Name = "f", Size = size, Position = position or UDim2.new(),
        AnchorPoint = anchor or Vector2.zero, BackgroundColor3 = C.red, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = parent})
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
    local g = new("ScreenGui", {Name = rn(), IgnoreGuiInset = true, ResetOnSpawn = false,
        DisplayOrder = 10000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})
    local root = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white,
        BorderSizePixel = 0, Active = true, GroupTransparency = 1, Parent = g})
    new("UIGradient", {Rotation = 90, Parent = root, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 10, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 14, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 15, 35)),
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
            AnchorPoint = Vector2.new(.5, 0), BackgroundTransparency = 1, Text = "“Hayatta en hakiki mürşit ilimdir.”",
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
    Aim = false, AimFov = 160, AimSmooth = 0.30, AimPart = "Head", AimVisible = true, ShowFov = true, TeamCheck = true,
    -- silah
    SilentAim = false, Wallbang = false, PassTeam = false,
    AutoShot = false, Trigger = false, TriggerDelay = 0.08, RapidFire = false,
    Hitbox = false, HitboxSize = 14, HitboxTransp = 0.6,
    -- gorsel
    Esp = false, EspInfo = true, EspEnemyOnly = false, Crosshair = false, Fullbright = false, FovOn = false, Fov = 90,
    -- hareket
    Speed = false, WalkSpeed = 40, InfJump = false, HighJump = false, JumpPower = 90,
    Fly = false, FlySpeed = 60, Noclip = false, LowGrav = false, Gravity = 60,
    Spin = false, SpinSpeed = 10,
    -- ekstra
    AntiAfk = true, AntiKick = false, Mask = false, Theme = 1,
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

-- hook'larin namecall icermemesi icin onbellek (hook icinde Instance metodu cagirmiyoruz)
local enemyChars, friendChars = {}, {}
local myRootPos, curHum = nil, nil
local curTarget, curDist = nil, nil
local mouseDown, shotUntil = false, 0

-- ============================================================
-- OVERLAY
-- ============================================================
local overlay = new("ScreenGui", {Name = rn(), IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 900, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})

local fovCircle = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundTransparency = 1, Visible = false, Parent = overlay})
circ(fovCircle)
new("UIStroke", {Color = C.red, Thickness = 1.5, Transparency = 0.1, Parent = fovCircle})

local cross = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Visible = false, Parent = overlay})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(22, 2),
    BackgroundColor3 = C.red, BorderSizePixel = 0, Parent = cross})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(2, 22),
    BackgroundColor3 = C.red, BorderSizePixel = 0, Parent = cross})
new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(4, 4),
    BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = cross})

local wm = new("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(0.5, 0, 0, 6),
    Size = UDim2.fromOffset(160, 28), BackgroundColor3 = Color3.fromRGB(30, 20, 55), BackgroundTransparency = 0.25,
    BorderSizePixel = 0, Parent = overlay})
round(wm, 8)
new("UIStroke", {Color = C.red, Thickness = 1.5, Parent = wm})
makeFlag(wm, UDim2.fromOffset(32, 22), UDim2.fromOffset(4, 3))
new("TextLabel", {Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
    Text = "ULTRA V10 · TÜRKİYE", TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = wm})

local function notify(text)
    local f = new("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(0.5, 0, 0, 40),
        Size = UDim2.fromOffset(280, 30), BackgroundColor3 = Color3.fromRGB(30, 20, 55), BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = overlay})
    round(f, 8)
    local st = new("UIStroke", {Color = Theme.a, Thickness = 1.5, Transparency = 1, Parent = f})
    local l = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "★ " .. text,
        TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 13, TextTransparency = 1, Parent = f})
    tw(f, 0.2, {BackgroundTransparency = 0.15, Position = UDim2.new(0.5, 0, 0, 44)})
    tw(l, 0.2, {TextTransparency = 0}); tw(st, 0.2, {Transparency = 0})
    task.delay(1.4, function()
        tw(f, 0.3, {BackgroundTransparency = 1}); tw(l, 0.3, {TextTransparency = 1}); tw(st, 0.3, {Transparency = 1})
        task.wait(0.35); f:Destroy()
    end)
end

-- ============================================================
-- HITBOX
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
-- ESP  (DOST yesil / DUSMAN kirmizi)
-- ============================================================
local espFolder = new("Folder", {Name = rn(), Parent = GUI_PARENT})
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
    local hl = new("Highlight", {Adornee = char, FillTransparency = 0.5, OutlineTransparency = 0,
        OutlineColor = C.white, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = espFolder})
    local bb = new("BillboardGui", {Adornee = head, AlwaysOnTop = true, Size = UDim2.fromOffset(170, 34),
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
            local enemy = isEnemy(p)
            if S.Esp and c and r and isAlive(c) and (enemy or not S.EspEnemyOnly) then
                local e = esp[p]
                if not e or e.char ~= c or not e.hl.Parent then buildEsp(p, c); e = esp[p] end
                if e then
                    e.hl.FillColor = enemy and C.red or C.green
                    e.bb.Enabled = S.EspInfo
                    local h = humOf(c)
                    local dist = math.floor((cam.CFrame.Position - r.Position).Magnitude)
                    e.name.Text = string.format("%s %s [%dm]", enemy and "DÜŞMAN" or "DOST", p.DisplayName, dist)
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
-- HEDEF / AIM / TRIGGER
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

local function getAimTarget(ignoreVis)
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
                        if d < bestD and (ignoreVis or not S.AimVisible or visibleCheck(part, c)) then
                            best, bestD = part, d
                        end
                    end
                end
            end
        end
    end
    return best, best and bestD or nil
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
    shotUntil = os.clock() + kShotWindow
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
-- SIHIRLI MERMI / WALLBANG / DOST GECIR  (Raycast hook)
-- Oyunun silah scripti Workspace:Raycast kullaniyorsa calisir.
-- ============================================================
local ncc = newcclosure or function(f) return f end
local oldNamecall, oldIndex
local ncInstalled, idxInstalled = false, false

local function isMyShot(origin)
    if not (mouseDown or os.clock() < shotUntil) then return false end
    local cam = Workspace.CurrentCamera
    if cam and (origin - cam.CFrame.Position).Magnitude < kShotRadius then return true end
    return myRootPos ~= nil and (origin - myRootPos).Magnitude < kShotRadius
end

local function buildParams(src)
    local p = RaycastParams.new()
    if src then
        p.IgnoreWater = src.IgnoreWater
        p.RespectCanCollide = src.RespectCanCollide
        p.CollisionGroup = src.CollisionGroup
    end
    if S.Wallbang then
        -- sadece dusman karakterleri: duvar ve dost mermiyi durdurmaz
        p.FilterType = Enum.RaycastFilterType.Include
        p.FilterDescendantsInstances = enemyChars
    else
        local list = src and table.clone(src.FilterDescendantsInstances) or {}
        p.FilterType = src and src.FilterType or Enum.RaycastFilterType.Exclude
        if S.PassTeam and p.FilterType == Enum.RaycastFilterType.Exclude then
            for _, ch in ipairs(friendChars) do list[#list + 1] = ch end
        end
        p.FilterDescendantsInstances = list
    end
    return p
end

local function ensureNamecall()
    if ncInstalled then return true end
    if not (hookmetamethod and getnamecallmethod and checkcaller) then
        notify("Executor hookmetamethod desteklemiyor")
        return false
    end
    ncInstalled = true
    oldNamecall = hookmetamethod(game, "__namecall", ncc(function(self, ...)
        local method = getnamecallmethod()
        if alive and not checkcaller() then
            if method == "Raycast" and self == Workspace and (S.Wallbang or S.PassTeam or S.SilentAim) then
                local origin, dir, params = ...
                if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" and isMyShot(origin) then
                    if S.SilentAim and curTarget then
                        local to = curTarget.Position - origin
                        dir = to.Unit * math.max(dir.Magnitude, to.Magnitude + 5)
                    end
                    return oldNamecall(self, origin, dir, buildParams(params))
                end
            elseif method == "Kick" and S.AntiKick and self == LocalPlayer then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end))
    return true
end

local function ensureIndex()
    if idxInstalled then return true end
    if not (hookmetamethod and checkcaller) then notify("Executor hookmetamethod desteklemiyor"); return false end
    idxInstalled = true
    oldIndex = hookmetamethod(game, "__index", ncc(function(self, key)
        if alive and S.Mask and (key == "WalkSpeed" or key == "JumpPower") and self == curHum and not checkcaller() then
            if key == "WalkSpeed" then return Orig.WalkSpeed or 16 end
            return Orig.JumpPower or 50
        end
        return oldIndex(self, key)
    end))
    return true
end

for _, k in ipairs({"Wallbang", "PassTeam", "SilentAim", "AntiKick"}) do
    Hooks[k] = function(v)
        if v and not ensureNamecall() then Toggles[k](false, true) end
    end
end
Hooks.Mask = function(v)
    if v and not ensureIndex() then Toggles.Mask(false, true) end
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
local acc = {esp = 0, hit = 0, light = 0, rapid = 0, cache = 0}
local lastShot = 0

local function refreshCache()
    local ec, fc = {}, {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and isAlive(c) then
                if isEnemy(p) then ec[#ec + 1] = c else fc[#fc + 1] = c end
            end
        end
    end
    enemyChars, friendChars = ec, fc
end

bind(RunService.Heartbeat, function(dt)
    if not alive then return end
    local _, h, r = me()
    curHum = h
    myRootPos = r and r.Position or nil

    if h then
        if S.Speed then h.WalkSpeed = S.WalkSpeed end
        if S.HighJump then h.UseJumpPower = true; h.JumpPower = S.JumpPower end
        if S.Spin then h.AutoRotate = false end
    end
    if S.LowGrav then Workspace.Gravity = S.Gravity end
    if S.Spin and r then
        r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(S.SpinSpeed * dt * 60), 0)
    end
    flyStep()

    acc.esp += dt; acc.hit += dt; acc.light += dt; acc.rapid += dt; acc.cache += dt
    if acc.cache >= kCacheTick then acc.cache = 0; refreshCache() end
    if acc.esp >= kEspTick then acc.esp = 0; espStep() end
    if acc.hit >= kHitboxTick then acc.hit = 0; if S.Hitbox then hitboxStep() end end
    if S.Fullbright and acc.light >= 1 then acc.light = 0; lightStep() end

    local now = os.clock()
    if S.Trigger and now - lastShot >= S.TriggerDelay and crosshairEnemy() then
        lastShot = now
        fireOnce()
    end
    if S.AutoShot and curTarget and now - lastShot >= S.TriggerDelay
        and (S.SilentAim or (curDist or 1e9) <= kAutoShotPx) then
        lastShot = now
        fireOnce()
    end
    if S.RapidFire and acc.rapid >= kRapidDelay and mouseDown then
        acc.rapid = 0
        shotUntil = now + kShotWindow
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

    fovCircle.Visible = (S.Aim or S.SilentAim or S.AutoShot) and S.ShowFov
    fovCircle.Size = UDim2.fromOffset(S.AimFov * 2, S.AimFov * 2)
    cross.Visible = S.Crosshair

    if S.Aim or S.SilentAim or S.AutoShot then
        curTarget, curDist = getAimTarget(S.Wallbang)
    else
        curTarget, curDist = nil, nil
    end

    if S.Aim and curTarget and aimActive() then
        local alpha = 1 - (1 - math.clamp(S.AimSmooth, 0.02, 1)) ^ (dt * 60)
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, curTarget.Position), alpha)
    end
end)

bind(LocalPlayer.Idled, function()
    if S.AntiAfk then
        pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end
end)

bind(LocalPlayer.CharacterAdded, function()
    table.clear(noclipOrig)
    if flyBV then flyBV:Destroy(); flyBV = nil end
end)

-- ============================================================
-- MENU  (parlak, opak cam, 4 tema)
-- ============================================================
local ui = new("ScreenGui", {Name = rn(), IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 950, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = GUI_PARENT})

local accents, rerenders = {}, {}
local function reg(inst, prop, which)
    accents[#accents + 1] = {inst, prop, which or "a"}
    inst[prop] = Theme[which or "a"]
end

local PANEL_W = 480
local panel = new("CanvasGroup", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromOffset(PANEL_W, 560), BackgroundTransparency = 1, BorderSizePixel = 0, Active = true,
    GroupTransparency = 1, Visible = false, Parent = ui})
round(panel, 20)
local panelScale = new("UIScale", {Parent = panel})

local bgFrame = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = panel})
local bgGrad = new("UIGradient", {Rotation = 45, Parent = bgFrame})
-- ust parlama seridi
local shine = new("Frame", {Size = UDim2.new(1, 0, 0, 90), BackgroundColor3 = C.white, BackgroundTransparency = 0.88,
    BorderSizePixel = 0, Parent = panel})
new("UIGradient", {Rotation = 90, Parent = shine, Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1)})})

local stroke = new("UIStroke", {Color = C.white, Thickness = 3, Parent = panel})
local strokeGrad = new("UIGradient", {Parent = stroke})

-- header
local header = new("Frame", {Size = UDim2.new(1, 0, 0, 66), BackgroundTransparency = 1, Parent = panel})
local hFlag = makeFlag(header, UDim2.fromOffset(57, 38), UDim2.fromOffset(14, 14))
round(hFlag, 6)
new("UIStroke", {Color = C.white, Thickness = 1.5, Parent = hFlag})
local title = new("TextLabel", {Position = UDim2.fromOffset(82, 8), Size = UDim2.fromOffset(250, 28), BackgroundTransparency = 1,
    Text = "HAMSTER LIVES", TextColor3 = C.white, Font = Enum.Font.GothamBlack, TextSize = 23,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header})
local titleGrad = new("UIGradient", {Parent = title})
local sub = new("TextLabel", {Position = UDim2.fromOffset(82, 38), Size = UDim2.fromOffset(300, 18), BackgroundTransparency = 1,
    Text = "ULTRA V10 · NE MUTLU TÜRKÜM DİYENE", TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = header})
reg(sub, "TextColor3", "b")
makeAtaturk(header, UDim2.fromOffset(42, 42), UDim2.new(1, -108, 0, 12), Vector2.zero, true)
local closeBtn = new("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14),
    Size = UDim2.fromOffset(38, 38), BackgroundColor3 = C.white, BackgroundTransparency = 0.8, Text = "—",
    TextColor3 = C.white, Font = Enum.Font.GothamBlack, TextSize = 18, Parent = header})
circ(closeBtn)

-- sekmeler
local tabBar = new("Frame", {Position = UDim2.fromOffset(12, 72), Size = UDim2.fromOffset(456, 36),
    BackgroundTransparency = 1, Parent = panel})
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = tabBar})

local pageHolder = new("Frame", {Position = UDim2.fromOffset(12, 116), Size = UDim2.new(1, -24, 1, -146),
    BackgroundTransparency = 1, Parent = panel})
new("TextLabel", {AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -6), Size = UDim2.fromOffset(440, 18),
    BackgroundTransparency = 1, Text = "★  RightShift: menü aç/kapa  ★", TextColor3 = C.dim,
    Font = Enum.Font.GothamMedium, TextSize = 11, Parent = panel})

local pages, tabBtns = {}, {}
local order = {"SAVAŞ", "SİLAH", "GÖRSEL", "HAREKET", "EKSTRA", "TÜRKİYE"}
local currentTab = "SAVAŞ"

local function newPage(name)
    local sf = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        Visible = false, Parent = pageHolder})
    reg(sf, "ScrollBarImageColor3", "b")
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sf})
    new("UIPadding", {PaddingBottom = UDim.new(0, 8), Parent = sf})
    pages[name] = sf
    return sf
end

local function showTab(name)
    currentTab = name
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        local on = (n == name)
        tw(b, 0.2, {BackgroundColor3 = on and Theme.a or C.white, BackgroundTransparency = on and 0 or 0.8})
    end
end

for _, name in ipairs(order) do
    newPage(name)
    local b = new("TextButton", {Size = UDim2.fromOffset(72, 36), BackgroundColor3 = C.white, BackgroundTransparency = 0.8,
        Text = name, TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, Parent = tabBar})
    round(b, 10)
    tabBtns[name] = b
    b.Activated:Connect(function() showTab(name) end)
end

-- satir kurucular (cam gibi, beyaz saydam satirlar = okunakli)
local function rowFrame(page, h)
    local row = new("Frame", {Size = UDim2.new(1, -8, 0, h), BackgroundColor3 = C.white, BackgroundTransparency = 0.82,
        BorderSizePixel = 0, Parent = page})
    round(row, 12)
    new("UIStroke", {Color = C.white, Transparency = 0.65, Thickness = 1, Parent = row})
    return row
end
local function label(parent, props)
    props.BackgroundTransparency = 1
    props.TextColor3 = props.TextColor3 or C.text
    props.Font = props.Font or Enum.Font.GothamBold
    props.TextStrokeTransparency = 0.75
    props.Parent = parent
    return new("TextLabel", props)
end

local function addSection(page, text)
    local l = label(page, {Size = UDim2.new(1, -8, 0, 22), Text = "━━  " .. text .. "  ━━", TextSize = 12})
    reg(l, "TextColor3", "b")
end

local function addNote(page, text)
    label(page, {Size = UDim2.new(1, -8, 0, 40), Text = text, TextSize = 12, TextWrapped = true,
        TextColor3 = C.dim, Font = Enum.Font.GothamMedium})
end

local function addToggle(page, text, key)
    local row = rowFrame(page, 46)
    label(row, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -84, 1, 0), Text = text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
    local sw = new("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0),
        Size = UDim2.fromOffset(48, 26), BackgroundColor3 = Color3.fromRGB(95, 85, 140), Text = "",
        AutoButtonColor = false, Parent = row})
    circ(sw)
    local knob = new("Frame", {Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = sw})
    circ(knob)
    local function render()
        local on = S[key]
        tw(sw, 0.18, {BackgroundColor3 = on and Theme.a or Color3.fromRGB(95, 85, 140)})
        tw(knob, 0.18, {Position = on and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)})
    end
    rerenders[#rerenders + 1] = render
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
    local row = rowFrame(page, 58)
    label(row, {Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -90, 0, 20), Text = text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left})
    local valLbl = label(row, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6),
        Size = UDim2.fromOffset(70, 20), Text = "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
    reg(valLbl, "TextColor3", "b")
    local track = new("Frame", {Position = UDim2.new(0, 14, 0, 40), Size = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = Color3.fromRGB(70, 60, 110), BorderSizePixel = 0, Parent = row})
    circ(track)
    local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = track})
    reg(fill, "BackgroundColor3", "a")
    circ(fill)
    local knob = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5),
        Size = UDim2.fromOffset(20, 20), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = track})
    circ(knob)
    new("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.7, Thickness = 1, Parent = knob})
    local hit = new("TextButton", {Position = UDim2.new(0, 8, 0, 28), Size = UDim2.new(1, -16, 0, 30),
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

local function addChoice(page, text, key, values, labels, onChange)
    local row = rowFrame(page, 46)
    local btn = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row})
    local lbl = label(row, {Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0), Text = "", TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left})
    local function render()
        for i, v in ipairs(values) do
            if v == S[key] then lbl.Text = text .. ":  " .. labels[i] .. "  ▸"; return end
        end
    end
    render()
    btn.Activated:Connect(function()
        local idx = table.find(values, S[key]) or 1
        S[key] = values[idx % #values + 1]
        render()
        if onChange then onChange(S[key]) end
    end)
end

local function addButton(page, text, danger, cb)
    local b = new("TextButton", {Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = danger and Color3.fromRGB(215, 30, 55) or C.white,
        BackgroundTransparency = danger and 0.1 or 0.78, BorderSizePixel = 0, Text = text, TextColor3 = C.white,
        Font = Enum.Font.GothamBold, TextSize = 14, Parent = page})
    round(b, 12)
    new("UIStroke", {Color = C.white, Transparency = 0.6, Thickness = 1, Parent = b})
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
    addSection(p, "DOST / DÜŞMAN")
    addToggle(p, "Takım kontrolü (dosta dokunma)", "TeamCheck")
end

-- ---- SILAH
do
    local p = pages["SİLAH"]
    addSection(p, "MERMİ")
    addToggle(p, "Sihirli mermi  (silent aim)", "SilentAim")
    addToggle(p, "Wallbang  (duvarı delip geçer)", "Wallbang")
    addToggle(p, "Dostu delip geç  (duvar kalır)", "PassTeam")
    addNote(p, "Wallbang açıkken mermi sadece düşmana çarpar: duvar ve dost mermiyi durdurmaz. Oyun Raycast kullanıyorsa çalışır.")
    addSection(p, "ATEŞ")
    addToggle(p, "Auto atış  (hedef FOV'daysa ateş)", "AutoShot")
    addToggle(p, "Triggerbot  (nişangah düşmanda)", "Trigger")
    addSlider(p, "Atış gecikmesi (sn)", "TriggerDelay", 0.02, 0.5, 0.01, "%.2f")
    addToggle(p, "Seri ateş  (sol tık basılı)", "RapidFire")
    addSection(p, "HİTBOX")
    addToggle(p, "Hitbox genişletici", "Hitbox")
    addSlider(p, "Hitbox boyutu", "HitboxSize", 4, 40, 1)
    addSlider(p, "Hitbox saydamlığı", "HitboxTransp", 0, 1, 0.05, "%.2f")
end

-- ---- GORSEL
do
    local p = pages["GÖRSEL"]
    addSection(p, "ESP")
    addToggle(p, "ESP  (dost yeşil / düşman kırmızı)", "Esp")
    addToggle(p, "Sadece düşmanları göster", "EspEnemyOnly")
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
local applyTheme
local function unload()
    alive = false
    for k, v in pairs(S) do if v == true and Hooks[k] then pcall(Hooks[k], false) end end
    restoreAllHitboxes(); clearAllEsp()
    if flyBV then flyBV:Destroy() end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() ui:Destroy(); overlay:Destroy(); espFolder:Destroy() end)
    env.HL_UNLOAD = nil
end
env.HL_UNLOAD = unload

do
    local p = pages["EKSTRA"]
    addSection(p, "TEMA")
    local names, idxs = {}, {}
    for i, t in ipairs(Themes) do names[i] = t.name; idxs[i] = i end
    addChoice(p, "Tema", "Theme", idxs, names, function(i) applyTheme(i) end)
    addSection(p, "KORUMA (client tarafı)")
    addToggle(p, "Anti-AFK", "AntiAfk")
    addToggle(p, "Anti-Kick", "AntiKick")
    addToggle(p, "Değer maskeleme (hız/zıplama)", "Mask")
    addNote(p, "Bunlar sadece oyunun client script kontrollerini atlatır. Sunucu taraflı doğrulama ve Roblox'un kendi koruması aşılmaz.")
    addSection(p, "GENEL")
    addButton(p, "Tüm modülleri kapat", false, function()
        for key, set in pairs(Toggles) do
            if key ~= "AntiAfk" and S[key] == true then set(false, true) end
        end
        notify("Tüm modüller kapatıldı")
    end)
    addButton(p, "Scripti tamamen kaldır", true, unload)
end

-- ---- TURKIYE
do
    local p = pages["TÜRKİYE"]
    local box = new("Frame", {Size = UDim2.new(1, -8, 0, 176), BackgroundTransparency = 1, Parent = p})
    local f = makeFlag(box, UDim2.fromOffset(255, 170), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
    round(f, 10)
    new("UIStroke", {Color = C.white, Thickness = 2, Parent = f})
    if kAtaturkImage ~= "" then
        local b2 = new("Frame", {Size = UDim2.new(1, -8, 0, 156), BackgroundTransparency = 1, Parent = p})
        makeAtaturk(b2, UDim2.fromOffset(124, 150), UDim2.fromScale(.5, .5), Vector2.new(.5, .5), false)
    end
    local function line(text, size, color, font, h)
        label(p, {Size = UDim2.new(1, -8, 0, h or 24), Text = text, TextColor3 = color or C.white,
            Font = font or Enum.Font.GothamBold, TextSize = size or 15, TextWrapped = true})
    end
    line("MUSTAFA KEMAL ATATÜRK", 20, C.white, Enum.Font.GothamBlack, 28)
    line("1881 – 1938", 13, C.dim, Enum.Font.Gotham, 18)
    line("“Egemenlik kayıtsız şartsız milletindir.”", 14, C.dim, Enum.Font.GothamMedium, 34)
    line("“Yurtta sulh, cihanda sulh.”", 14, C.dim, Enum.Font.GothamMedium, 24)
    line("“Ne mutlu Türküm diyene!”", 17, C.white, Enum.Font.GothamBlack, 32)
end

-- ---- tema uygulama
applyTheme = function(i)
    Theme = Themes[i] or Themes[1]
    for _, r in ipairs(accents) do
        if r[1] and r[1].Parent then r[1][r[2]] = Theme[r[3]] end
    end
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.g[1]), ColorSequenceKeypoint.new(0.5, Theme.g[2]),
        ColorSequenceKeypoint.new(1, Theme.g[3])})
    local seam = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.a), ColorSequenceKeypoint.new(0.5, Theme.b),
        ColorSequenceKeypoint.new(1, Theme.a)})
    strokeGrad.Color = seam
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.white), ColorSequenceKeypoint.new(0.5, Theme.b),
        ColorSequenceKeypoint.new(1, C.white)})
    for _, f in ipairs(rerenders) do f() end
    showTab(currentTab)
end

-- ---- responsive layout
local function layout()
    local vp = getCam().ViewportSize
    local s = math.clamp(vp.X / 500, 0.5, 1.1)
    panelScale.Scale = s
    panel.Size = UDim2.fromOffset(PANEL_W, math.clamp(vp.Y / s - 24, 270, 580))
    return s
end

-- yuzen bayrak butonu (surukle = tasi, dokun = ac/kapa)
local fab = new("Frame", {Position = UDim2.new(0, 14, 0.5, -22), Size = UDim2.fromOffset(68, 46),
    BackgroundTransparency = 1, Parent = ui})
local fabScale = new("UIScale", {Parent = fab})
local fabFlag = makeFlag(fab, UDim2.fromScale(1, 1))
round(fabFlag, 10)
local fabStroke = new("UIStroke", {Color = C.white, Thickness = 2.5, Parent = fabFlag})
local fabHit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = fab})

local menuOpen = false
local function setMenu(open)
    menuOpen = open
    if open then
        panel.Visible = true
        panel.Position = UDim2.new(0.5, 0, 0.5, 16)
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

-- giris: menu tusu + atis penceresi takibi
bind(UIS.InputBegan, function(i)
    if i.KeyCode == kToggleKey then setMenu(not menuOpen) end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mouseDown = true
        shotUntil = os.clock() + kShotWindow
    end
end)
bind(UIS.InputEnded, function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mouseDown = false
    end
end)

-- vaybe: donen gradientler, bayrak nefesi
local tStart, lastLayout = os.clock(), 0
bind(RunService.RenderStepped, function()
    local t = os.clock() - tStart
    strokeGrad.Rotation = (t * 70) % 360
    titleGrad.Rotation = (t * 40) % 360
    bgGrad.Rotation = 45 + math.sin(t * 0.6) * 30
    fabFlag.Rotation = math.sin(t * 2) * 2
    fabStroke.Color = Theme.b:Lerp(Theme.a, (math.sin(t * 3) + 1) / 2)
    if t - lastLayout > 0.4 then
        lastLayout = t
        fabScale.Scale = layout()
    end
end)

applyTheme(S.Theme)
layout()
setMenu(true)
notify("Ne mutlu Türküm diyene!")
