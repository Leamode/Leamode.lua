-- ============================================================
-- LeaMode_Ultra_v7.lua — HamsterHub v7
-- ============================================================
-- FIXED vs v6:
--  · Single combined namecall hook (bypass + silent aim — never double-installed)
--  · Speed: RunService.Stepped pre-physics + WalkSpeedChanged signal guard
--  · CarFly: single Heartbeat conn (if M.carFlyConn guard); ownership throttled
--    0.25s, full scan only on model change; full actuator destroy on exit
--  · AntiTeleport: no false-positive snap during Fly/CarFly; continuously tracks
--  · Fly ↔ CarFly mutual exclusion: CarFly active → player Fly suppressed
--  · CharacterAdded: full reinit of every layer + speed guard re-wire
--  · Toggle onD callbacks: all call proper destroy/stop functions (no UI drift)
--  · getVehicle: SeatPart primary + Occupant scan fallback
--  · No print() calls anywhere (no F6 output log)
-- CarFly controls: W=up  S=forward  A/D=strafe  Space=down  Shift=boost
-- Bypass: merged namecall hook, kill list protects move/stance/vehicle remotes
-- Speed: Stepped + WalkSpeedChanged guard, walkBoost=68 configurable
-- Menu: HamsterHub v7 · dark + orange neon · accent stripe · active count
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer
local Mouse             = LocalPlayer:GetMouse()

-- ==================== CONFIG ====================
local CFG = {
    flySpeed         = 95,
    walkBoost        = 68,
    jumpBoost        = 110,
    carFlySpeed      = 140,
    carFlyBoost      = 220,
    eggRange         = 130,
    guardRange       = 18,
    arenaDelay       = 0.28,
    arenaName        = "arena",
    giftDelay        = 0.20,
    aimKey           = Enum.KeyCode.Q,
    aimSmooth        = 4.5,
    aimFovStuds      = 110,
    aimBone          = "Head",
    aimTeamCheck     = true,
    aimVisCheck      = true,
    aimMethod        = "CameraLock",
    antiTPSnap       = 13,
    ownerThrottleSec = 0.25,
    footstepPatterns = {"step","foot","walk","run","sprint","footprint","land","stomp"},
}

-- ==================== STATE ====================
local ON = {}
for _, k in ipairs({
    "AutoEgg","Speed","Fly","MobPush","AutoBed","Noclip","InfJump","ClickTP",
    "ESP","Fullbright","HighJump","NoFall","EggGuard","EggMagnet","EggAnchor",
    "EggBuddy","AutoArena","GiftMode","Aimbot","SilentAim","SoundBypass",
    "AntiTeleport","HardOwnership","GodMode","CarFly",
}) do ON[k] = false end

local M = {
    saved=nil, startPos=nil,
    flyBV=nil, flyBG=nil, flyAtt=nil, flyConn=nil,
    carFlyConn=nil, carBV=nil, carBG=nil, carAtt=nil, _carModel=nil,
    noclipConn=nil, espFolder=nil, buddyFolder=nil,
    arenaList={}, arenaIdx=0, arenaBusy=false,
    giftPhase=0, giftWait=0,
    lit={},
    aimGyro=nil,
    mutedSounds={}, lastMoveState=nil, soundScanConn=nil,
    lastGoodCFrame=nil, antiTPConn=nil, ownershipConn=nil,
    godConn=nil, speedGuardConn=nil,
    _ownerThrottleT=0,
    updateStatusFn=nil,
}

-- ==================== HELPERS ====================
local EGG = {"egg","goldenegg","petegg","eggmodel"}
local BED = {"bed","bad"}

local function char()  return LocalPlayer.Character end
local function hrp()   local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end

local function nameHit(o, list)
    local n = string.lower(o.Name)
    for _, k in ipairs(list) do if string.find(n, k, 1, true) then return true end end
    return false
end

local function hardTP(pos)
    local r = hrp()
    if not r or not pos then return end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity  = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    M.lastGoodCFrame = r.CFrame
end

local function savePos()
    local r = hrp()
    if r then M.saved = r.Position; M.lastGoodCFrame = r.CFrame; return true end
    return false
end

local function zeroVelocity(r)
    if not r then return end
    pcall(function()
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- robust seat detection: SeatPart primary → Occupant scan fallback
local function getVehicle()
    local h = hum()
    if not h then return nil end
    local seat = h.SeatPart
    if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
        local model   = seat:FindFirstAncestorOfClass("Model")
        local primary = (model and model.PrimaryPart) or seat
        return seat, model, primary
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("VehicleSeat") or obj:IsA("Seat")) and obj.Occupant == h then
            local model   = obj:FindFirstAncestorOfClass("Model")
            local primary = (model and model.PrimaryPart) or obj
            return obj, model, primary
        end
    end
    return nil
end

-- ============================================================
-- BYPASS
-- ============================================================
local Bypass = {killed = 0}

local KILL_PAT = {
    "reset","kick","ban","detect","scan","integrity","violation","correction",
    "tamper","cheat","exploit","hack","inject","clientchar","analytics",
    "afk","admin","sync","heartbeat","report","verify","validate","ping",
    "hook","monitor","watchdog","audit","trace","log","event","flag","warn",
    "block","filter","anticheat","ac","vac","eac","fairplay","battleye",
    "antiteleport","teleportback","positioncheck","velocitycheck","speedcheck",
    "flycheck","noclipcheck","godmode","infinitehealth","healthcheck",
    "antifly","antispeed","antihack","security","moderation",
    "invalidated","cheatdetect","xray","wallhack","aimhack",
}

local PROTECT = {
    "move","stance","walk","jump","input","character","humanoid","root",
    "replicate","physics","network","cframe","position","velocity","vehicle","seat","drive",
}

local SILENT_PAT = {
    "gun","fire","shoot","bullet","hit","damage","ray","projectile",
    "attack","weapon","muzzle","shot","cast",
}

local function isProtected(n)
    n = string.lower(n)
    for _, p in ipairs(PROTECT) do if string.find(n, p, 1, true) then return true end end
    return false
end

local function isKillTarget(n)
    if isProtected(n) then return false end
    n = string.lower(n)
    for _, p in ipairs(KILL_PAT) do if string.find(n, p, 1, true) then return true end end
    return false
end

local function isSilentTarget(n)
    n = string.lower(n)
    for _, p in ipairs(SILENT_PAT) do if string.find(n, p, 1, true) then return true end end
    return false
end

-- forward declaration — assigned in COMBAT section, captured by hook closure
local getBestTarget

-- ============================================================
-- COMBINED NAMECALL HOOK — bypass + silent aim, single install
-- ============================================================
local _hookDone = false
local function installCombinedHook()
    if _hookDone then return end
    _hookDone = true
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local n = tostring(self.Name or "")
                -- bypass: kill detection remotes
                if isKillTarget(n) then return end
                -- silent aim: redirect weapon remotes
                if ON.SilentAim and isSilentTarget(n) and getBestTarget then
                    local target = getBestTarget()
                    if target then
                        local args   = {...}
                        local r      = hrp()
                        local origin = r and r.Position or target.Position
                        for i, v in ipairs(args) do
                            if typeof(v) == "Vector3" then
                                local mag = v.Magnitude > 0.1 and v.Magnitude or 120
                                args[i] = (target.Position - origin).Unit * mag
                            elseif typeof(v) == "CFrame" then
                                args[i] = CFrame.new(v.Position, target.Position)
                            end
                        end
                        return old(self, unpack(args))
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function killRemotes()
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                    if isKillTarget(obj.Name) then
                        pcall(function() obj:Destroy() end)
                        Bypass.killed += 1
                    end
                end
            end
        end)
    end
end

local function watchNewRemotes(root)
    root.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
            if isKillTarget(obj.Name) then
                task.defer(function()
                    pcall(function() obj:Destroy() end)
                    Bypass.killed += 1
                end)
            end
        end
    end)
end

local function claimOwnership(c)
    c = c or char()
    if not c then return end
    local r = hrp()
    if r then
        pcall(function() r:SetNetworkOwner(LocalPlayer) end)
        pcall(function() r.CanTouch = false end)
    end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p:SetNetworkOwner(LocalPlayer) end)
        end
    end
end

local function startHardOwnership()
    if M.ownershipConn then M.ownershipConn:Disconnect() end
    -- only HRP per tick; full character scan is done on startup + CharacterAdded
    M.ownershipConn = RunService.Heartbeat:Connect(function()
        if not ON.HardOwnership then return end
        local r = hrp()
        if r then pcall(function() r:SetNetworkOwner(LocalPlayer) end) end
    end)
end

local function stopHardOwnership()
    if M.ownershipConn then M.ownershipConn:Disconnect() M.ownershipConn = nil end
end

local function startAntiTeleport()
    if M.antiTPConn then M.antiTPConn:Disconnect() end
    M.antiTPConn = RunService.Heartbeat:Connect(function()
        if not ON.AntiTeleport then return end
        local r = hrp()
        if not r then return end
        pcall(function() r:SetNetworkOwner(LocalPlayer) end)
        if M.lastGoodCFrame then
            local dist = (r.Position - M.lastGoodCFrame.Position).Magnitude
            if ON.Fly or ON.CarFly then
                -- active flight: track continuously, never snap (car physics can jump)
                M.lastGoodCFrame = r.CFrame
            elseif dist > CFG.antiTPSnap then
                -- sudden server correction while grounded
                r.CFrame = M.lastGoodCFrame
                zeroVelocity(r)
                pcall(function() r:SetNetworkOwner(LocalPlayer) end)
            else
                M.lastGoodCFrame = r.CFrame
            end
        else
            M.lastGoodCFrame = r.CFrame
        end
    end)
end

local function stopAntiTeleport()
    if M.antiTPConn then M.antiTPConn:Disconnect() M.antiTPConn = nil end
end

local function startGodMode()
    if M.godConn then M.godConn:Disconnect() end
    local h = hum()
    if not h then return end
    pcall(function() h.BreakJointsOnDeath = false end)
    M.godConn = h.HealthChanged:Connect(function(hp)
        if not ON.GodMode then return end
        if hp < h.MaxHealth then pcall(function() h.Health = h.MaxHealth end) end
    end)
end

local function stopGodMode()
    if M.godConn then M.godConn:Disconnect() M.godConn = nil end
end

local function scriptCleaner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local n = string.lower(obj.Name)
                if  string.find(n,"detect") or string.find(n,"scan") or
                    string.find(n,"integrity") or string.find(n,"anticheat") or
                    string.find(n,"antitamper") or string.find(n,"monitor") or
                    string.find(n,"watchdog") or string.find(n,"antiteleport") or
                    string.find(n,"security") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local function wireAntiReset(c)
    c = c or char()
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    pcall(function() h.BreakJointsOnDeath = false end)
    h.HealthChanged:Connect(function(hp)
        if hp <= 0 then
            pcall(function()
                h.Health = h.MaxHealth
                h:ChangeState(Enum.HumanoidStateType.Running)
            end)
        elseif hp < 8 then
            pcall(function() h.Health = h.MaxHealth end)
        end
    end)
    h:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if h.PlatformStand and not ON.Fly then
            pcall(function() h.PlatformStand = false end)
        end
    end)
end

local function StartBypass()
    installCombinedHook()
    killRemotes()
    claimOwnership()
    scriptCleaner()
    wireAntiReset()
    watchNewRemotes(ReplicatedStorage)
    watchNewRemotes(Workspace)
    ON.HardOwnership = true
    ON.AntiTeleport  = true
    startHardOwnership()
    startAntiTeleport()
end

-- ============================================================
-- SPEED — Stepped pre-physics + WalkSpeedChanged guard
-- ============================================================
local function applySpeed()
    local h = hum()
    if not h then return end
    h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
    if ON.HighJump then
        h.JumpPower = CFG.jumpBoost
        pcall(function() h.JumpHeight = 24 end)
    else
        h.JumpPower = 50
        pcall(function() h.JumpHeight = 7.2 end)
    end
end

local function wireSpeedGuard()
    if M.speedGuardConn then M.speedGuardConn:Disconnect() M.speedGuardConn = nil end
    local h = hum()
    if not h then return end
    -- if game resets our WalkSpeed, immediately re-apply via deferred call
    M.speedGuardConn = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if ON.Speed and h.WalkSpeed ~= CFG.walkBoost then
            task.defer(function()
                local hh = hum()
                if hh and hh.Parent and ON.Speed then hh.WalkSpeed = CFG.walkBoost end
            end)
        end
    end)
end

-- Pre-physics enforcement: Stepped fires before physics sim, most reliable slot
RunService.Stepped:Connect(function()
    if not (ON.Speed or ON.HighJump) then return end
    pcall(function()
        local h = hum()
        if not h then return end
        if ON.Speed   then h.WalkSpeed = CFG.walkBoost end
        if ON.HighJump then
            h.JumpPower = CFG.jumpBoost
            pcall(function() h.JumpHeight = 24 end)
        end
    end)
end)

-- ============================================================
-- PLAYER FLY
-- ============================================================
local function flyDestroy()
    if M.flyConn then M.flyConn:Disconnect() M.flyConn = nil end
    pcall(function() if M.flyBV  then M.flyBV:Destroy()  end end)
    pcall(function() if M.flyBG  then M.flyBG:Destroy()  end end)
    pcall(function() if M.flyAtt then M.flyAtt:Destroy() end end)
    M.flyBV, M.flyBG, M.flyAtt = nil, nil, nil
    local h = hum()
    if h and not ON.Fly then pcall(function() h.PlatformStand = false end) end
end

local function flyEnsure()
    -- CarFly active → suppress player fly entirely
    if ON.CarFly   then flyDestroy() return end
    if not ON.Fly  then flyDestroy() return end
    local r, h = hrp(), hum()
    if not r or not h then return end
    pcall(function() h.PlatformStand = true end)
    if not M.flyAtt or M.flyAtt.Parent ~= r then
        flyDestroy()
        local att = Instance.new("Attachment")
        att.Name = "LeaFlyAtt"; att.Parent = r
        M.flyAtt = att
        local lv = Instance.new("LinearVelocity")
        lv.Name = "LeaFlyLV"; lv.Attachment0 = att
        lv.MaxForce = 1e9; lv.VectorVelocity = Vector3.zero
        lv.RelativeTo = Enum.ActuatorRelativeTo.World; lv.Parent = r
        M.flyBV = lv
        local ao = Instance.new("AlignOrientation")
        ao.Name = "LeaFlyAO"; ao.Attachment0 = att
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.MaxTorque = 1e9; ao.Responsiveness = 80; ao.Parent = r
        M.flyBG = ao
    end
    if M.flyConn then return end
    M.flyConn = RunService.Heartbeat:Connect(function()
        if not ON.Fly or ON.CarFly then flyDestroy() return end
        local rr = hrp()
        if not rr then return end
        if not M.flyBV or M.flyBV.Parent ~= rr then
            flyDestroy(); flyEnsure(); return
        end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local uis = UserInputService
        local v   = Vector3.zero
        local f, rt = cam.CFrame.LookVector, cam.CFrame.RightVector
        if uis:IsKeyDown(Enum.KeyCode.W)         then v += f  end
        if uis:IsKeyDown(Enum.KeyCode.S)         then v -= f  end
        if uis:IsKeyDown(Enum.KeyCode.A)         then v -= rt end
        if uis:IsKeyDown(Enum.KeyCode.D)         then v += rt end
        if uis:IsKeyDown(Enum.KeyCode.Space)     then v += Vector3.yAxis end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then v -= Vector3.yAxis end
        local spd = uis:IsKeyDown(Enum.KeyCode.LeftControl) and CFG.flySpeed * 1.6 or CFG.flySpeed
        M.flyBV.VectorVelocity = v.Magnitude > 0 and v.Unit * spd or Vector3.zero
        if M.flyBG then M.flyBG.CFrame = cam.CFrame end
        local hh = hum()
        if hh then pcall(function() hh.PlatformStand = true end) end
        M.lastGoodCFrame = rr.CFrame
        pcall(function() rr:SetNetworkOwner(LocalPlayer) end)
    end)
end

-- ============================================================
-- CAR FLY — full vehicle + character
-- W=up  S=forward  A/D=strafe  Space=down  Shift=boost
-- ============================================================
local function _carCleanActuators()
    pcall(function() if M.carBV  then M.carBV:Destroy()  end end)
    pcall(function() if M.carBG  then M.carBG:Destroy()  end end)
    pcall(function() if M.carAtt then M.carAtt:Destroy() end end)
    M.carBV, M.carBG, M.carAtt = nil, nil, nil
end

local function carFlyDestroy()
    if M.carFlyConn then M.carFlyConn:Disconnect() M.carFlyConn = nil end
    _carCleanActuators()
    M._carModel      = nil
    M._ownerThrottleT = 0
end

local function _carAttach(primary)
    if not primary then return end
    if M.carAtt and M.carAtt.Parent ~= primary then _carCleanActuators() end
    if M.carAtt and M.carAtt.Parent == primary  then return end

    local att = Instance.new("Attachment")
    att.Name = "LeaCarAtt"; att.Parent = primary
    M.carAtt = att

    local lv = Instance.new("LinearVelocity")
    lv.Name = "LeaCarLV"; lv.Attachment0 = att
    lv.MaxForce = 1e10; lv.VectorVelocity = Vector3.zero
    lv.RelativeTo = Enum.ActuatorRelativeTo.World; lv.Parent = primary
    M.carBV = lv

    local ao = Instance.new("AlignOrientation")
    ao.Name = "LeaCarAO"; ao.Attachment0 = att
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = 1e10; ao.Responsiveness = 40; ao.Parent = primary
    M.carBG = ao
end

local function carFlyEnsure()
    if not ON.CarFly then carFlyDestroy() return end
    if M.carFlyConn  then return end  -- single connection guarantee

    M.carFlyConn = RunService.Heartbeat:Connect(function()
        if not ON.CarFly then carFlyDestroy() return end

        local seat, model, primary = getVehicle()

        -- not seated → clean actuators and idle
        if not seat or not primary then
            if M.carBV then _carCleanActuators() M._carModel = nil end
            return
        end

        -- vehicle changed → rebuild actuators + full ownership claim
        if M._carModel ~= model then
            M._carModel = model
            _carCleanActuators()
            if model then
                for _, p in ipairs(model:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(LocalPlayer) end) end
                end
            else
                pcall(function() primary:SetNetworkOwner(LocalPlayer) end)
            end
            _carAttach(primary)
            M._ownerThrottleT = os.clock()
        end

        -- throttled ownership refresh (every 0.25s, direct children only)
        local now = os.clock()
        if now - M._ownerThrottleT >= CFG.ownerThrottleSec then
            M._ownerThrottleT = now
            pcall(function() primary:SetNetworkOwner(LocalPlayer) end)
            if model then
                for _, p in ipairs(model:GetChildren()) do
                    if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(LocalPlayer) end) end
                end
            end
        end

        -- actuator health check
        if not M.carBV or M.carBV.Parent ~= primary then _carAttach(primary) end
        if not M.carBV then return end

        local cam = Workspace.CurrentCamera
        if not cam then return end
        local uis  = UserInputService
        local look = cam.CFrame.LookVector
        local rght = cam.CFrame.RightVector
        local fwd  = Vector3.new(look.X, 0, look.Z)
        fwd  = fwd.Magnitude  > 0.05 and fwd.Unit  or Vector3.new(0, 0, -1)
        local lat  = Vector3.new(rght.X, 0, rght.Z)
        lat  = lat.Magnitude  > 0.05 and lat.Unit  or Vector3.new(1, 0,  0)

        -- W=up  S=forward  A=left  D=right  Space=down  Shift=boost
        local v = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W)         then v = v + Vector3.yAxis end
        if uis:IsKeyDown(Enum.KeyCode.S)         then v = v + fwd end
        if uis:IsKeyDown(Enum.KeyCode.A)         then v = v - lat end
        if uis:IsKeyDown(Enum.KeyCode.D)         then v = v + lat end
        if uis:IsKeyDown(Enum.KeyCode.Space)     then v = v - Vector3.yAxis end
        local spd = uis:IsKeyDown(Enum.KeyCode.LeftShift) and CFG.carFlyBoost or CFG.carFlySpeed

        M.carBV.VectorVelocity = v.Magnitude > 0.05 and v.Unit * spd or Vector3.zero
        if M.carBG then
            M.carBG.CFrame = CFrame.lookAt(primary.Position, primary.Position + fwd)
        end
        pcall(function() primary.AssemblyAngularVelocity = Vector3.zero end)

        local r = hrp()
        if r then M.lastGoodCFrame = r.CFrame end
    end)
end

-- ============================================================
-- NOCLIP / INF JUMP / CLICK TP
-- ============================================================
local function setNoclip(on)
    if M.noclipConn then M.noclipConn:Disconnect() M.noclipConn = nil end
    if not on then return end
    M.noclipConn = RunService.Stepped:Connect(function()
        local c = char()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if ON.InfJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Mouse.Button1Down:Connect(function()
    if not ON.ClickTP then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService.TouchEnabled then
        if Mouse.Hit then hardTP(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

-- ============================================================
-- EGG / ARENA / GIFT / BUDDY / GUARD
-- ============================================================
local function grabEgg()
    local r = hrp()
    if not r then return false end
    local range = ON.EggMagnet and CFG.eggRange or 85
    local best, bestD = nil, range
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and nameHit(obj, EGG) then
            local d = (obj.Position - r.Position).Magnitude
            if d < bestD then bestD, best = d, obj end
        end
    end
    if not best then return false end
    best.Anchored = false; best.CanCollide = false
    best.CFrame = r.CFrame * CFrame.new(0, 2.5, 0)
    best.AssemblyLinearVelocity = Vector3.zero
    if ON.EggAnchor or ON.AutoEgg or ON.GiftMode then
        if not best:FindFirstChild("LeaWeld") then
            local w = Instance.new("WeldConstraint")
            w.Name = "LeaWeld"; w.Part0 = r; w.Part1 = best; w.Parent = best
        end
    end
    return true
end

local function dropEggAt(pos)
    local r = hrp()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and nameHit(obj, EGG) then
            local w = obj:FindFirstChild("LeaWeld")
            if w then w:Destroy() end
            if r and (obj.Position - r.Position).Magnitude < 15 then
                obj.Anchored = true; obj.CanCollide = true
                obj.AssemblyLinearVelocity = Vector3.zero
                obj.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
            end
        end
    end
end

local function eggTick()
    if ON.AutoEgg then
        if M.saved then hardTP(M.saved) end
        grabEgg()
    elseif ON.EggMagnet or ON.EggAnchor then
        grabEgg()
    end
end

local function guardTick()
    if not ON.EggGuard then return end
    local r = hrp()
    if not r then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local o = plr.Character:FindFirstChild("HumanoidRootPart")
            if o then
                local d = (o.Position - r.Position).Magnitude
                if d > 0.5 and d <= CFG.guardRange then
                    local away = o.Position - r.Position
                    if away.Magnitude > 0 then
                        o.AssemblyLinearVelocity = away.Unit * 110 + Vector3.new(0, 48, 0)
                    end
                end
            end
        end
    end
end

local function mobTick()
    if not ON.MobPush then return end
    local r = hrp()
    if not r then return end
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m ~= char() and not Players:GetPlayerFromCharacter(m) then
            local mh = m:FindFirstChildOfClass("Humanoid")
            local mr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if mh and mr and mh.Health > 0 then
                local d = (mr.Position - r.Position).Magnitude
                if d > 0.4 and d <= 18 then
                    local away = r.Position - mr.Position
                    if away.Magnitude > 0 then
                        r.AssemblyLinearVelocity = away.Unit * 95 + Vector3.new(0, 42, 0)
                    end
                end
            end
        end
    end
end

local function bedTick()
    if not ON.AutoBed then return end
    local c = char()
    if not c then return end
    local has = false
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and nameHit(t, BED) then has = true; break end
    end
    if not has then return end
    local r = hrp()
    if not r then return end
    local best, bd = nil, 18
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local o  = plr.Character:FindFirstChild("HumanoidRootPart")
            local oh = plr.Character:FindFirstChildOfClass("Humanoid")
            if o and oh and oh.Health > 0 then
                local d = (o.Position - r.Position).Magnitude
                if d < bd then bd, best = d, o end
            end
        end
    end
    if best then
        r.CFrame = CFrame.lookAt(r.Position:Lerp(best.Position, 0.4), best.Position)
    end
end

local function arenaCenter(model)
    if model:IsA("BasePart") then return model.Position end
    if model:IsA("Model") then
        local ok, cf = pcall(function() return model:GetBoundingBox() end)
        if ok and cf then return cf.Position end
        if model.PrimaryPart then return model.PrimaryPart.Position end
    end
    return nil
end

local function findArenas()
    local list, key = {}, string.lower(CFG.arenaName)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), key, 1, true) then
            local c = arenaCenter(obj)
            if c then table.insert(list, {center=c, name=obj.Name}) end
        end
    end
    table.sort(list, function(a, b)
        local na = tonumber(string.match(a.name, "%d+"))
        local nb = tonumber(string.match(b.name, "%d+"))
        if na and nb then return na < nb end
        return a.name < b.name
    end)
    return list
end

local function arenaTick()
    if not ON.AutoArena or M.arenaBusy then return end
    if #M.arenaList == 0 then
        M.arenaList = findArenas(); M.arenaIdx = 0
        if #M.arenaList == 0 then return end
    end
    M.arenaBusy = true
    M.arenaIdx += 1
    if M.arenaIdx > #M.arenaList then M.arenaList = findArenas(); M.arenaIdx = 1 end
    local a = M.arenaList[M.arenaIdx]
    if a then hardTP(a.center + Vector3.new(0, 3, 0)) end
    task.delay(CFG.arenaDelay, function() M.arenaBusy = false end)
end

local function giftTick()
    if not ON.GiftMode then M.giftPhase = 0; return end
    local now = os.clock()
    if now < M.giftWait then return end
    if M.giftPhase == 0 then
        M.startPos  = M.saved or (hrp() and hrp().Position)
        M.arenaList = findArenas()
        if #M.arenaList == 0 then M.giftWait = now + 1; return end
        M.giftPhase = 1; M.giftWait = now + 0.05; return
    end
    if M.giftPhase == 1 then
        local last = M.arenaList[#M.arenaList]
        if last then hardTP(last.center + Vector3.new(0, 3, 0)) end
        M.giftPhase = 2; M.giftWait = now + CFG.giftDelay; return
    end
    if M.giftPhase == 2 then
        if grabEgg() then M.giftPhase = 3; M.giftWait = now + 0.1
        else M.giftWait = now + 0.2 end
        return
    end
    if M.giftPhase == 3 then
        local dest = M.startPos or M.saved
        if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
        if dest then hardTP(dest + Vector3.new(0, 3, 0)) end
        M.giftPhase = 4; M.giftWait = now + CFG.giftDelay; return
    end
    if M.giftPhase == 4 then
        local dest = M.startPos or M.saved
        if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
        if dest then dropEggAt(dest) end
        M.giftPhase = 1; M.giftWait = now + 0.15
    end
end

local function buddyTick()
    if not ON.EggBuddy then
        if M.buddyFolder then pcall(function() M.buddyFolder:Destroy() end) M.buddyFolder = nil end
        return
    end
    local r = hrp(); if not r then return end
    if not M.buddyFolder then
        local f = Instance.new("Folder"); f.Name = "LeaBuddy"; f.Parent = Workspace
        M.buddyFolder = f
        for i = 1, 3 do
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball; p.Size = Vector3.one
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(255, 140, 60)
            p.Anchored = true; p.CanCollide = false; p.Parent = f
        end
    end
    local t = os.clock(); local i = 0
    for _, p in ipairs(M.buddyFolder:GetChildren()) do
        if p:IsA("BasePart") then
            i += 1
            local a = t * 3 + i * 2.1
            p.CFrame = CFrame.new(r.Position + Vector3.new(math.cos(a)*5, 2, math.sin(a)*5))
        end
    end
end

-- ============================================================
-- VISUAL
-- ============================================================
local function clearESP()
    if M.espFolder then pcall(function() M.espFolder:Destroy() end) end
    M.espFolder = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local x = plr.Character:FindFirstChild("LeaHL")
            if x then x:Destroy() end
        end
    end
end

local function doESP()
    clearESP()
    if not ON.ESP then return end
    local f = Instance.new("Folder"); f.Name = "LeaESP"; f.Parent = Workspace
    M.espFolder = f
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = Instance.new("Highlight")
            hl.Name = "LeaHL"
            hl.FillColor = Color3.fromRGB(255, 140, 50)
            hl.OutlineColor = Color3.fromRGB(255, 220, 180)
            hl.FillTransparency = 0.5
            hl.Parent = plr.Character
        end
    end
end

local function fullbright(on)
    if on then
        M.lit.b, M.lit.c, M.lit.f = Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
        Lighting.Brightness = 3.2; Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6; Lighting.GlobalShadows = false
    else
        if M.lit.b then Lighting.Brightness = M.lit.b end
        if M.lit.c then Lighting.ClockTime  = M.lit.c end
        if M.lit.f then Lighting.FogEnd     = M.lit.f end
        Lighting.GlobalShadows = true; M.lit = {}
    end
end

local function noFall()
    if not ON.NoFall then return end
    local h = hum()
    if h and h:GetState() == Enum.HumanoidStateType.Freefall then
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- ============================================================
-- COMBAT — aimbot + silent aim
-- (hook already installed above; SilentAim just needs the flag toggled)
-- ============================================================
local function isSameTeam(plr)
    if not CFG.aimTeamCheck then return false end
    local myTeam = LocalPlayer.Team
    if not myTeam then return false end
    return plr.Team == myTeam
end

local function isVisible(part)
    if not CFG.aimVisCheck then return true end
    local r = hrp(); if not r then return true end
    local origin = r.Position + Vector3.new(0, 2, 0)
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {char()}
    local result = Workspace:Raycast(origin, part.Position - origin, ray)
    if not result then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end

-- assign forward declaration (closure in hook captures this upvalue)
getBestTarget = function()
    local cam = Workspace.CurrentCamera; if not cam then return nil end
    local best, bestDist = nil, CFG.aimFovStuds
    local myPos = (hrp() and hrp().Position) or Vector3.zero
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
            local h    = plr.Character:FindFirstChildOfClass("Humanoid")
            local bone = plr.Character:FindFirstChild(CFG.aimBone) or plr.Character:FindFirstChild("HumanoidRootPart")
            if h and bone and h.Health > 0 and isVisible(bone) then
                local d = (bone.Position - myPos).Magnitude
                if d < bestDist then bestDist = d; best = bone end
            end
        end
    end
    return best
end

local function cleanAimGyro()
    if M.aimGyro then pcall(function() M.aimGyro:Destroy() end) M.aimGyro = nil end
end

local function aimbot_CameraLock(target)
    local cam = Workspace.CurrentCamera; if not cam then return end
    cam.CFrame = cam.CFrame:Lerp(
        CFrame.new(cam.CFrame.Position, target.Position + Vector3.new(0, 0.35, 0)),
        1 / CFG.aimSmooth)
end

local function aimbot_BodyGyro(target)
    local r = hrp(); if not r then return end
    if not M.aimGyro or M.aimGyro.Parent ~= r then
        pcall(function() if M.aimGyro then M.aimGyro:Destroy() end end)
        local bg = Instance.new("BodyGyro")
        bg.Name = "LeaAimGyro"; bg.MaxTorque = Vector3.new(0, 1e6, 0)
        bg.D = 40; bg.P = 1.4e4; bg.Parent = r
        M.aimGyro = bg
    end
    M.aimGyro.CFrame = CFrame.lookAt(r.Position, target.Position)
end

local function aimbotTick()
    if not ON.Aimbot then cleanAimGyro() return end
    local held = UserInputService:IsKeyDown(CFG.aimKey)
    if not held and UserInputService.TouchEnabled then
        for _, touch in ipairs(UserInputService:GetTouches()) do
            if touch.Position.X > Workspace.CurrentCamera.ViewportSize.X / 2 then
                held = true; break
            end
        end
    end
    if not held then cleanAimGyro() return end
    local target = getBestTarget()
    if not target then cleanAimGyro() return end
    if CFG.aimMethod == "CameraLock" then aimbot_CameraLock(target) else aimbot_BodyGyro(target) end
end

-- ============================================================
-- SOUND BYPASS
-- ============================================================
local function isFootstepSound(sound)
    if not sound:IsA("Sound") then return false end
    local n = string.lower(sound.Name)
    for _, p in ipairs(CFG.footstepPatterns) do
        if string.find(n, p, 1, true) then return true end
    end
    return false
end

local function muteFootsteps()
    local c = char(); if not c then return end
    for _, obj in ipairs(c:GetDescendants()) do
        if isFootstepSound(obj) and not M.mutedSounds[obj] then
            M.mutedSounds[obj] = obj.Volume
            pcall(function() obj.Volume = 0 end)
        end
    end
end

local function restoreFootsteps()
    for sound, vol in pairs(M.mutedSounds) do
        pcall(function() if sound and sound.Parent then sound.Volume = vol end end)
    end
    M.mutedSounds = {}
end

local function getMoveState()
    local h = hum(); if not h then return "still" end
    if h.MoveDirection.Magnitude < 0.1 then return "still" end
    return (h.WalkSpeed > 20 or ON.Speed) and "run" or "walk"
end

local function soundBypassTick()
    if not ON.SoundBypass then
        if next(M.mutedSounds) then restoreFootsteps() end
        M.lastMoveState = nil; return
    end
    local state = getMoveState()
    if state == M.lastMoveState then return end
    M.lastMoveState = state
    if state == "still" then restoreFootsteps() else muteFootsteps() end
end

local function startSoundBypass()
    if M.soundScanConn then M.soundScanConn:Disconnect() end
    M.soundScanConn = LocalPlayer.CharacterAdded:Connect(function()
        M.mutedSounds = {}; M.lastMoveState = nil
    end)
end

local function stopSoundBypass()
    restoreFootsteps(); M.lastMoveState = nil
    if M.soundScanConn then M.soundScanConn:Disconnect() M.soundScanConn = nil end
end

-- ============================================================
-- CHARACTER ADDED — full layer reinit
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.35)
    claimOwnership(c)
    wireAntiReset(c)
    killRemotes()
    scriptCleaner()
    task.wait(0.08)
    flyDestroy()
    carFlyDestroy()
    if ON.Fly          then flyEnsure()     end
    if ON.CarFly       then carFlyEnsure()  end
    if ON.Speed or ON.HighJump then applySpeed() end
    if ON.Noclip       then setNoclip(true)      end
    if ON.ESP          then doESP()              end
    if ON.HardOwnership  then startHardOwnership() end
    if ON.AntiTeleport   then startAntiTeleport()  end
    if ON.GodMode        then startGodMode()       end
    task.defer(wireSpeedGuard)
    M.mutedSounds = {}; M.lastMoveState = nil; M.lastGoodCFrame = nil
    if M.updateStatusFn then M.updateStatusFn() end
end)

-- ============================================================
-- MAIN HEARTBEAT — game-logic batch (not movement enforcement)
-- ============================================================
local _hbAccum = 0
local _espAccum = 0
local HB_STEP  = 1 / 60

RunService.Heartbeat:Connect(function(dt)
    _hbAccum  += dt
    _espAccum += dt
    -- periodic ESP rebuild without while-true loop
    if _espAccum >= 2 then
        _espAccum = 0
        if ON.ESP then pcall(doESP) end
    end
    if _hbAccum < HB_STEP then return end
    _hbAccum = 0
    pcall(function()
        if ON.AutoEgg or ON.EggMagnet or ON.EggAnchor then eggTick() end
        if ON.EggGuard    then guardTick() end
        if ON.MobPush     then mobTick()   end
        if ON.AutoBed     then bedTick()   end
        if ON.NoFall      then noFall()    end
        if ON.EggBuddy    then buddyTick() end
        if ON.Aimbot      then aimbotTick()      end
        if ON.SoundBypass then soundBypassTick() end
        if ON.AutoArena   then arenaTick()  end
        if ON.GiftMode    then giftTick()   end
    end)
end)

-- ============================================================
-- GUI — HamsterHub v7
-- dark + orange neon · glass cards · accent stripe · active count
-- ============================================================
local function buildGui()
    local pg  = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HamsterHubGui")
    if old then old:Destroy() end

    local C = {
        bg          = Color3.fromRGB(10,  10,  14),
        panel       = Color3.fromRGB(16,  16,  22),
        card        = Color3.fromRGB(21,  21,  29),
        cardActive  = Color3.fromRGB(28,  22,  16),
        accent      = Color3.fromRGB(255, 148, 42),
        accentBright= Color3.fromRGB(255, 185, 95),
        accentDim   = Color3.fromRGB(165, 82,  18),
        textPrim    = Color3.fromRGB(248, 242, 235),
        textSec     = Color3.fromRGB(148, 143, 138),
        textOn      = Color3.fromRGB(255, 202, 122),
        green       = Color3.fromRGB(80,  232, 152),
        red         = Color3.fromRGB(255, 80,  95),
        tabInactive = Color3.fromRGB(22,  22,  30),
        tabActive   = Color3.fromRGB(34,  24,  12),
        statusBg    = Color3.fromRGB(8,   8,   12),
        sep         = Color3.fromRGB(50,  42,  32),
    }

    local g = Instance.new("ScreenGui")
    g.Name = "HamsterHubGui"; g.ResetOnSpawn = false
    g.IgnoreGuiInset = true; g.DisplayOrder = 999
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; g.Parent = pg

    -- floating toggle button
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.fromOffset(54, 54)
    openBtn.Position = UDim2.new(1, -66, 0.5, -27)
    openBtn.BackgroundColor3 = C.panel
    openBtn.Text = "🐹"; openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 24; openBtn.TextColor3 = C.accent
    openBtn.ZIndex = 100; openBtn.Parent = g
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 15)
    local ost = Instance.new("UIStroke", openBtn)
    ost.Color = C.accent; ost.Thickness = 2; ost.Transparency = 0.22

    -- main panel
    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(310, 532)
    panel.Position = UDim2.new(0.5, -155, 0.5, -266)
    panel.BackgroundColor3 = C.bg; panel.Visible = false
    panel.ZIndex = 50; panel.ClipsDescendants = true; panel.Parent = g
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
    local pst = Instance.new("UIStroke", panel)
    pst.Color = C.accent; pst.Thickness = 1.6; pst.Transparency = 0.38

    -- neon top line
    local glowLine = Instance.new("Frame")
    glowLine.Size = UDim2.new(0.65, 0, 0, 2)
    glowLine.Position = UDim2.new(0.175, 0, 0, 0)
    glowLine.BackgroundColor3 = C.accentBright
    glowLine.BackgroundTransparency = 0.05
    glowLine.BorderSizePixel = 0; glowLine.ZIndex = 55; glowLine.Parent = panel
    Instance.new("UICorner", glowLine).CornerRadius = UDim.new(1, 0)

    -- title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = C.panel
    titleBar.BorderSizePixel = 0; titleBar.ZIndex = 51; titleBar.Parent = panel
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 18)
    -- subtle gradient on title bar
    local tgrad = Instance.new("UIGradient")
    tgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 20, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 20)),
    })
    tgrad.Rotation = 90; tgrad.Parent = titleBar
    -- bottom fill to mask bottom-round corners
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 20); fix.Position = UDim2.new(0, 0, 1, -20)
    fix.BackgroundColor3 = C.panel; fix.BorderSizePixel = 0
    fix.ZIndex = 51; fix.Parent = titleBar
    -- separator below title bar
    local titleSep = Instance.new("Frame")
    titleSep.Size = UDim2.new(1, -18, 0, 1); titleSep.Position = UDim2.new(0, 9, 0, 44)
    titleSep.BackgroundColor3 = C.sep; titleSep.BackgroundTransparency = 0.15
    titleSep.ZIndex = 51; titleSep.Parent = panel

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -82, 1, 0); titleLbl.Position = UDim2.fromOffset(16, 0)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = "🐹  HAMSTER HUB"
    titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 15
    titleLbl.TextColor3 = C.accent
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 52; titleLbl.Parent = titleBar

    local vBadge = Instance.new("TextLabel")
    vBadge.Size = UDim2.fromOffset(32, 18); vBadge.Position = UDim2.new(1, -78, 0.5, -9)
    vBadge.BackgroundColor3 = C.accentDim; vBadge.Text = "v7"
    vBadge.Font = Enum.Font.GothamBold; vBadge.TextSize = 10
    vBadge.TextColor3 = Color3.new(1, 1, 1); vBadge.ZIndex = 52; vBadge.Parent = titleBar
    Instance.new("UICorner", vBadge).CornerRadius = UDim.new(0, 5)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28); closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 22)
    closeBtn.Text = "×"; closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 17; closeBtn.TextColor3 = C.red
    closeBtn.ZIndex = 52; closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)

    -- drag
    local drag, dragStart, panStart = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = i.Position; panStart = panel.Position
        end
    end)
    titleBar.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - dragStart
            panel.Position = UDim2.new(
                panStart.X.Scale, panStart.X.Offset + d.X,
                panStart.Y.Scale, panStart.Y.Offset + d.Y)
        end
    end)

    -- tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -14, 0, 36); tabBar.Position = UDim2.fromOffset(7, 50)
    tabBar.BackgroundColor3 = C.panel; tabBar.ZIndex = 51; tabBar.Parent = panel
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)
    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2); tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local tabPad = Instance.new("UIPadding", tabBar)
    tabPad.PaddingLeft = UDim.new(0, 3); tabPad.PaddingRight  = UDim.new(0, 3)
    tabPad.PaddingTop  = UDim.new(0, 3); tabPad.PaddingBottom = UDim.new(0, 3)

    -- scroll area
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -14, 1, -120); scroll.Position = UDim2.fromOffset(7, 92)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.accent; scroll.CanvasSize = UDim2.fromOffset(0, 0)
    scroll.ZIndex = 51; scroll.Parent = panel
    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.Padding = UDim.new(0, 5); scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local scrollPad = Instance.new("UIPadding", scroll)
    scrollPad.PaddingTop = UDim.new(0, 2); scrollPad.PaddingBottom = UDim.new(0, 6)
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.fromOffset(0, scrollLayout.AbsoluteContentSize.Y + 14)
    end)

    -- status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -14, 0, 26); statusBar.Position = UDim2.new(0, 7, 1, -32)
    statusBar.BackgroundColor3 = C.statusBg; statusBar.ZIndex = 51; statusBar.Parent = panel
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 9)
    local sst = Instance.new("UIStroke", statusBar)
    sst.Color = C.accentDim; sst.Thickness = 1; sst.Transparency = 0.55
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -14, 1, 0); statusLbl.Position = UDim2.fromOffset(9, 0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "ready · hamsterhub v7"
    statusLbl.Font = Enum.Font.GothamMedium; statusLbl.TextSize = 11
    statusLbl.TextColor3 = C.green
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 52; statusLbl.Parent = statusBar

    local function countActive()
        local n = 0
        for _, v in pairs(ON) do if v then n += 1 end end
        return n
    end
    local function updateStatus(msg)
        if msg then
            statusLbl.Text = msg; statusLbl.TextColor3 = C.accentBright
            task.delay(2.2, function()
                local n = countActive()
                statusLbl.Text = n > 0 and ("● " .. n .. "  active") or "ready · hamsterhub v7"
                statusLbl.TextColor3 = n > 0 and C.accentBright or C.green
            end)
        else
            local n = countActive()
            statusLbl.Text = n > 0 and ("● " .. n .. "  active") or "ready · hamsterhub v7"
            statusLbl.TextColor3 = n > 0 and C.accentBright or C.green
        end
    end
    local function say(t) updateStatus(t) end
    M.updateStatusFn = function() updateStatus() end

    -- tab definitions
    local TAB_DEFS = {
        {id="bypass",  icon="🛡"},
        {id="combat",  icon="🔫"},
        {id="move",    icon="🏃"},
        {id="vehicle", icon="🚗"},
        {id="visual",  icon="👁"},
        {id="farm",    icon="🥚"},
    }

    local pages = {}
    for _, td in ipairs(TAB_DEFS) do
        local page = Instance.new("Frame")
        page.Name = "page_"..td.id
        page.Size = UDim2.new(1, 0, 0, 0); page.BackgroundTransparency = 1
        page.LayoutOrder = 1; page.Visible = false
        page.AutomaticSize = Enum.AutomaticSize.Y; page.ZIndex = 52; page.Parent = scroll
        local pl = Instance.new("UIListLayout", page)
        pl.Padding = UDim.new(0, 5); pl.SortOrder = Enum.SortOrder.LayoutOrder
        pages[td.id] = {frame=page, layout=pl, order=0}
    end

    local tabs = {}; local activeTab = nil
    local function switchTab(id)
        if activeTab == id then return end
        activeTab = id
        for _, td in ipairs(TAB_DEFS) do
            if pages[td.id] then pages[td.id].frame.Visible = (td.id == id) end
        end
        for tid, tbtn in pairs(tabs) do
            tbtn.BackgroundColor3 = (tid == id) and C.tabActive or C.tabInactive
            tbtn.TextColor3 = (tid == id) and C.accent or C.textSec
        end
        scroll.CanvasPosition = Vector2.zero
    end

    local N = #TAB_DEFS
    for _, td in ipairs(TAB_DEFS) do
        local tbtn = Instance.new("TextButton")
        tbtn.Size = UDim2.new(1/N, -2, 1, 0)
        tbtn.BackgroundColor3 = C.tabInactive
        tbtn.Text = td.icon; tbtn.Font = Enum.Font.GothamBold
        tbtn.TextSize = 16; tbtn.TextColor3 = C.textSec
        tbtn.ZIndex = 52; tbtn.Parent = tabBar
        Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0, 8)
        tabs[td.id] = tbtn
        local tid = td.id
        tbtn.MouseButton1Click:Connect(function() switchTab(tid) end)
        tbtn.MouseEnter:Connect(function()
            if activeTab ~= tid then tbtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
        end)
        tbtn.MouseLeave:Connect(function()
            if activeTab ~= tid then tbtn.BackgroundColor3 = C.tabInactive end
        end)
    end

    -- ===== WIDGET BUILDERS =====

    local function newTog(pageId, name, key, onE, onD)
        local p = pages[pageId]; if not p then return end
        p.order += 1
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 38)
        row.BackgroundColor3 = C.card; row.LayoutOrder = p.order
        row.ZIndex = 52; row.Parent = p.frame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local rst = Instance.new("UIStroke", row)
        rst.Color = C.accent; rst.Thickness = 1; rst.Transparency = 0.82
        -- left accent bar (shows when active)
        local stripe = Instance.new("Frame")
        stripe.Size = UDim2.new(0, 3, 0.62, 0); stripe.Position = UDim2.new(0, 0, 0.19, 0)
        stripe.BackgroundColor3 = C.accent; stripe.BackgroundTransparency = 1
        stripe.ZIndex = 54; stripe.Parent = row
        Instance.new("UICorner", stripe).CornerRadius = UDim.new(1, 0)
        -- label
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -62, 1, 0); lbl.Position = UDim2.fromOffset(14, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = name
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
        lbl.TextColor3 = C.textSec
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 53; lbl.Parent = row
        -- pill toggle
        local pill = Instance.new("Frame")
        pill.Size = UDim2.fromOffset(44, 24); pill.Position = UDim2.new(1, -52, 0.5, -12)
        pill.ZIndex = 53; pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(18, 18); dot.ZIndex = 54; dot.Parent = pill
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function refresh()
            local on = ON[key]
            pill.BackgroundColor3 = on and C.accent or Color3.fromRGB(38, 38, 50)
            dot.BackgroundColor3  = on and Color3.new(1,1,1) or Color3.fromRGB(95, 90, 85)
            dot.Position  = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
            lbl.TextColor3 = on and C.textOn or C.textSec
            row.BackgroundColor3 = on and C.cardActive or C.card
            rst.Transparency = on and 0.48 or 0.82
            stripe.BackgroundTransparency = on and 0 or 1
        end

        local function toggle()
            ON[key] = not ON[key]; refresh()
            if ON[key]     and onE then pcall(onE) end
            if not ON[key] and onD then pcall(onD) end
            updateStatus(name .. (ON[key] and "  · on" or "  · off"))
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
        btn.Text = ""; btn.ZIndex = 55; btn.Parent = row
        btn.MouseButton1Click:Connect(toggle)
        refresh()
    end

    local function newAct(pageId, name, fn)
        local p = pages[pageId]; if not p then return end
        p.order += 1
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 36)
        btn.BackgroundColor3 = C.card; btn.LayoutOrder = p.order
        btn.ZIndex = 52; btn.Parent = p.frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local bst = Instance.new("UIStroke", btn)
        bst.Color = C.accent; bst.Thickness = 1; bst.Transparency = 0.65
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -18, 1, 0); lbl.Position = UDim2.fromOffset(14, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = "▶  "..name
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
        lbl.TextColor3 = C.textPrim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 53; lbl.Parent = btn
        btn.MouseButton1Click:Connect(function()
            pcall(fn)
            btn.BackgroundColor3 = Color3.fromRGB(36, 26, 14)
            task.delay(0.14, function() btn.BackgroundColor3 = C.card end)
        end)
    end

    local function newSec(pageId, name)
        local p = pages[pageId]; if not p then return end
        p.order += 1
        local hdr = Instance.new("Frame")
        hdr.Size = UDim2.new(1, -4, 0, 22); hdr.BackgroundTransparency = 1
        hdr.LayoutOrder = p.order; hdr.ZIndex = 52; hdr.Parent = p.frame
        -- orange micro-bar
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0.7, 0); bar.Position = UDim2.new(0, 0, 0.15, 0)
        bar.BackgroundColor3 = C.accentDim; bar.ZIndex = 53; bar.Parent = hdr
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.fromOffset(9, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = string.upper(name)
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
        lbl.TextColor3 = C.accentDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 53; lbl.Parent = hdr
        -- separator line
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.9, 0, 0, 1); line.Position = UDim2.new(0, 10, 1, -1)
        line.BackgroundColor3 = C.sep; line.BackgroundTransparency = 0.3
        line.ZIndex = 52; line.Parent = hdr
    end

    local function sp(pageId, h)
        local p = pages[pageId]; if not p then return end
        p.order += 1
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -4, 0, h or 4)
        f.BackgroundTransparency = 1; f.LayoutOrder = p.order; f.Parent = p.frame
    end

    -- ===== BYPASS =====
    newSec("bypass", "protection")
    newAct("bypass", "Apply Full Bypass", function()
        StartBypass(); say("bypass live · killed "..Bypass.killed)
    end)
    newAct("bypass", "Clean Remotes", function()
        killRemotes(); say("remotes cleaned · "..Bypass.killed)
    end)
    newTog("bypass", "Hard Ownership", "HardOwnership", startHardOwnership, stopHardOwnership)
    newTog("bypass", "Anti-Teleport",  "AntiTeleport",  startAntiTeleport,  stopAntiTeleport)
    newTog("bypass", "God Mode",       "GodMode",       startGodMode,       stopGodMode)

    -- ===== COMBAT =====
    newSec("combat", "aim")
    newTog("combat", "Aimbot  [hold Q]", "Aimbot")
    newTog("combat", "Silent Aim",       "SilentAim")
    sp("combat", 4)
    newSec("combat", "survival")
    newTog("combat", "Mob Push", "MobPush")
    newTog("combat", "No Fall",  "NoFall")

    -- ===== MOVE =====
    newSec("move", "movement")
    newTog("move", "Speed  (monster run)", "Speed",
        function() applySpeed(); wireSpeedGuard() end,
        function() applySpeed() end)
    newTog("move", "High Jump", "HighJump",
        function() applySpeed() end,
        function() applySpeed() end)
    newTog("move", "Fly",    "Fly",    flyEnsure,  flyDestroy)
    newTog("move", "Noclip", "Noclip",
        function() setNoclip(true) end,
        function() setNoclip(false) end)
    newTog("move", "Inf Jump",            "InfJump")
    newTog("move", "Click TP  [Ctrl+Click]", "ClickTP")
    sp("move", 4)
    newSec("move", "position")
    newAct("move", "Save Position  [F4]", function()
        say(savePos() and "position saved" or "no character")
    end)
    newAct("move", "TP to Saved", function()
        if M.saved then hardTP(M.saved); say("tp done") else say("save first") end
    end)

    -- ===== CAR FLY =====
    newSec("vehicle", "car fly")
    newTog("vehicle", "Car Fly", "CarFly", carFlyEnsure, carFlyDestroy)
    sp("vehicle", 6)
    newSec("vehicle", "controls")
    local infoV = pages["vehicle"]; infoV.order += 1
    local cardV = Instance.new("Frame")
    cardV.Size = UDim2.new(1, -4, 0, 92)
    cardV.BackgroundColor3 = Color3.fromRGB(16, 13, 10)
    cardV.LayoutOrder = infoV.order; cardV.ZIndex = 52; cardV.Parent = infoV.frame
    Instance.new("UICorner", cardV).CornerRadius = UDim.new(0, 10)
    local cst = Instance.new("UIStroke", cardV)
    cst.Color = C.accentDim; cst.Thickness = 1; cst.Transparency = 0.5
    local infoTxtV = Instance.new("TextLabel")
    infoTxtV.Size = UDim2.new(1, -16, 1, -10); infoTxtV.Position = UDim2.fromOffset(10, 6)
    infoTxtV.BackgroundTransparency = 1
    infoTxtV.Text = "Arabaya bin → Car Fly aç.\nW = yukarı  |  S = ileri\nA / D = sol / sağ\nSpace = aşağı  |  Shift = boost\nAraç + sen birlikte uçar."
    infoTxtV.Font = Enum.Font.Gotham; infoTxtV.TextSize = 11.5
    infoTxtV.TextColor3 = C.textSec; infoTxtV.TextWrapped = true
    infoTxtV.TextXAlignment = Enum.TextXAlignment.Left
    infoTxtV.TextYAlignment = Enum.TextYAlignment.Top
    infoTxtV.ZIndex = 53; infoTxtV.Parent = cardV

    -- ===== VISUAL =====
    newSec("visual", "visual")
    newTog("visual", "ESP Highlight", "ESP",        doESP,                   clearESP)
    newTog("visual", "Fullbright",    "Fullbright",
        function() fullbright(true) end,
        function() fullbright(false) end)
    newTog("visual", "Sound Bypass",  "SoundBypass", startSoundBypass, stopSoundBypass)

    -- ===== FARM =====
    newSec("farm", "egg")
    newTog("farm", "Auto Egg",   "AutoEgg")
    newTog("farm", "Egg Magnet", "EggMagnet")
    newTog("farm", "Egg Anchor", "EggAnchor")
    newTog("farm", "Egg Guard",  "EggGuard")
    newTog("farm", "Egg Buddy",  "EggBuddy")
    newTog("farm", "Gift Mode",  "GiftMode", function()
        M.giftPhase = 0
        M.startPos = M.saved or (hrp() and hrp().Position)
    end)
    sp("farm", 4)
    newSec("farm", "arena")
    newTog("farm", "Auto Arena", "AutoArena", function()
        M.arenaList = findArenas(); M.arenaIdx = 0; M.arenaBusy = false
        say("arenas: "..#M.arenaList)
    end)
    newAct("farm", "Scan Arenas", function()
        M.arenaList = findArenas(); say("arenas: "..#M.arenaList)
    end)
    newTog("farm", "Auto Bed", "AutoBed")

    -- open button + hotkeys
    openBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
        if panel.Visible and not activeTab then switchTab("bypass") end
    end)

    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            panel.Visible = not panel.Visible
            if panel.Visible and not activeTab then switchTab("bypass") end
        elseif i.KeyCode == Enum.KeyCode.F4 then
            say(savePos() and "position saved" or "no char")
        elseif i.KeyCode == Enum.KeyCode.F7 then
            ON.SoundBypass = not ON.SoundBypass
            if ON.SoundBypass then startSoundBypass() else stopSoundBypass() end
            updateStatus("Sound "..(ON.SoundBypass and "ON" or "OFF"))
        elseif i.KeyCode == Enum.KeyCode.F8 then
            ON.ESP = not ON.ESP
            if ON.ESP then doESP() else clearESP() end
            updateStatus("ESP "..(ON.ESP and "ON" or "OFF"))
        elseif i.KeyCode == Enum.KeyCode.F9 then
            ON.Aimbot = not ON.Aimbot
            updateStatus("Aimbot "..(ON.Aimbot and "ON" or "OFF"))
        elseif i.KeyCode == Enum.KeyCode.F10 then
            ON.AutoEgg = not ON.AutoEgg
            updateStatus("AutoEgg "..(ON.AutoEgg and "ON" or "OFF"))
        end
    end)

    switchTab("bypass")
end

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.3)
StartBypass()
wireSpeedGuard()
buildGui()
