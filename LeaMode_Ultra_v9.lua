-- ============================================================
-- LeaMode Ultra v9 — Final
-- Real bypass (hook not destroy) | Center-lock aimbot
-- ESP+Tracers | Radar | Whitelist | CarFly | Speed/Fly
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ===================== CONFIG =====================
local CFG = {
    flySpeed      = 100,
    walkBoost     = 70,
    jumpBoost     = 110,
    carFlySpeed   = 170,
    carFlyBoost   = 280,

    aimKey        = Enum.KeyCode.Q,
    aimFovPx      = 320,       -- screen FOV radius
    aimMaxDist    = 1e9,
    aimBone       = "Head",
    aimPredict    = 0.12,
    aimSmooth     = 0.85,      -- 0.85 = strong pull toward target per frame

    mapSize       = 170,
    mapRange      = 450,
    ownerHz       = 0.2,
    carSnap       = 14,
}

-- ===================== STATE =====================
local ON = {
    Speed=false, Fly=false, Noclip=false, InfJump=false, ClickTP=false,
    HighJump=false, NoFall=false, MobPush=false,
    ESP=false, Tracers=false, Fullbright=false, Minimap=true, ShowFov=true,
    Aimbot=false, SilentAim=false,
    AntiTP=true, Ownership=true, God=false, CarFly=false, Bypass=false,
}

local WHITELIST = {} -- [UserId] = true

local S = {
    flyBV=nil, flyBG=nil, flyAtt=nil, flyConn=nil,
    carConn=nil, carBV=nil, carBG=nil, carAtt=nil, carModel=nil, carCF=nil,
    noclipConn=nil, ownerConn=nil, antiConn=nil, godConn=nil, speedConn=nil,
    espFolder=nil, tracerFolder=nil,
    aimTarget=nil, lastCF=nil, lit={},
    gui=nil, fov=nil, map=nil, mapDots=nil, status=nil,
    ownerT=0,
}

local COL_E = Color3.fromRGB(255, 60, 60)
local COL_F = Color3.fromRGB(70, 255, 110)
local COL_ME = Color3.fromRGB(90, 170, 255)
local ACCENT = Color3.fromRGB(255, 145, 45)

local function char() return LocalPlayer.Character end
local function hrp() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function wl(p) return WHITELIST[p.UserId] == true end
local function low(s) return string.lower(tostring(s or "")) end

-- ===================== BYPASS (real) =====================
local BLOCK = {
    "kick","ban","detect","anticheat","watchdog","antitamper","antiteleport",
    "teleportback","positioncheck","velocitycheck","speedcheck","flycheck",
    "noclipcheck","cheatdetect","securitycheck","clientcheck","integrity",
    "violation","punish",
}
local ALLOW = {
    "move","stance","walk","jump","input","character","humanoid","replicate",
    "physics","network","cframe","position","velocity","vehicle","seat","drive",
    "car","chassis","engine","wheel",
}

local function blockRemote(name)
    local n = low(name)
    for _, a in ipairs(ALLOW) do if string.find(n, a, 1, true) then return false end end
    for _, b in ipairs(BLOCK) do if string.find(n, b, 1, true) then return true end end
    return false
end

local getBestTarget
local _hook = false
local function installHook()
    if _hook then return end
    _hook = true
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == LocalPlayer then return end
            if method == "FireServer" or method == "InvokeServer" then
                local n = self and self.Name
                if blockRemote(n) then
                    if method == "InvokeServer" then return nil end
                    return
                end
                if ON.SilentAim and getBestTarget then
                    local ln = low(n)
                    if string.find(ln,"gun") or string.find(ln,"fire") or string.find(ln,"shoot")
                        or string.find(ln,"hit") or string.find(ln,"damage") or string.find(ln,"ray")
                        or string.find(ln,"bullet") or string.find(ln,"weapon") then
                        local t = getBestTarget()
                        if t then
                            local args = {...}
                            local r = hrp()
                            local origin = r and r.Position or t.Position
                            for i,v in ipairs(args) do
                                if typeof(v)=="Vector3" then
                                    local mag = v.Magnitude>0.1 and v.Magnitude or 120
                                    args[i] = (t.Position-origin).Unit * mag
                                elseif typeof(v)=="CFrame" then
                                    args[i] = CFrame.new(v.Position, t.Position)
                                end
                            end
                            return old(self, unpack(args))
                        end
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function stripConns()
    if not getconnections then return end
    pcall(function()
        local h = hum()
        if not h then return end
        for _, sig in ipairs({
            h.HealthChanged, h.Died, h.StateChanged,
            h:GetPropertyChangedSignal("WalkSpeed"),
            h:GetPropertyChangedSignal("JumpPower"),
        }) do
            for _, c in ipairs(getconnections(sig)) do
                pcall(function()
                    if c.Disable then c:Disable() elseif c.Disconnect then c:Disconnect() end
                end)
            end
        end
    end)
end

local function claim(root)
    if not root then return end
    for _, p in ipairs(root:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(LocalPlayer) end) end
    end
    if root:IsA("BasePart") then pcall(function() root:SetNetworkOwner(LocalPlayer) end) end
end

local function startBypass()
    installHook()
    stripConns()
    claim(char())
    ON.Bypass = true
    ON.Ownership = true
    ON.AntiTP = true
    if not S.ownerConn then
        S.ownerConn = RunService.Heartbeat:Connect(function()
            if not ON.Ownership then return end
            local now = os.clock()
            if now - S.ownerT < CFG.ownerHz then return end
            S.ownerT = now
            claim(char())
            if S.carModel then claim(S.carModel) end
        end)
    end
    if not S.antiConn then
        S.antiConn = RunService.Heartbeat:Connect(function()
            if not ON.AntiTP then return end
            local r = hrp()
            if not r then return end
            if ON.Fly or ON.CarFly then
                S.lastCF = r.CFrame
            elseif S.lastCF then
                if (r.Position - S.lastCF.Position).Magnitude > 16 then
                    r.CFrame = S.lastCF
                    r.AssemblyLinearVelocity = Vector3.zero
                else
                    S.lastCF = r.CFrame
                end
            else
                S.lastCF = r.CFrame
            end
        end)
    end
end

local function startGod()
    if S.godConn then S.godConn:Disconnect() end
    local h = hum()
    if not h then return end
    pcall(function() h.BreakJointsOnDeath = false end)
    S.godConn = h.HealthChanged:Connect(function(hp)
        if ON.God and hp < h.MaxHealth then pcall(function() h.Health = h.MaxHealth end) end
    end)
end

-- ===================== MOVEMENT =====================
local function applySpeed()
    local h = hum()
    if not h then return end
    h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
    if ON.HighJump then
        h.JumpPower = CFG.jumpBoost
        pcall(function() h.JumpHeight = 24 end)
    else
        h.JumpPower = 50
    end
end

RunService.Stepped:Connect(function()
    if ON.Speed then
        local h = hum()
        if h then h.WalkSpeed = CFG.walkBoost end
    end
end)

local function flyStop()
    if S.flyConn then S.flyConn:Disconnect() S.flyConn=nil end
    pcall(function() if S.flyBV then S.flyBV:Destroy() end end)
    pcall(function() if S.flyBG then S.flyBG:Destroy() end end)
    pcall(function() if S.flyAtt then S.flyAtt:Destroy() end end)
    S.flyBV,S.flyBG,S.flyAtt=nil,nil,nil
    local h=hum(); if h and not ON.Fly then pcall(function() h.PlatformStand=false end) end
end

local function flyStart()
    if ON.CarFly or not ON.Fly then flyStop() return end
    local r,h = hrp(),hum()
    if not r or not h then return end
    pcall(function() h.PlatformStand=true end)
    if not S.flyAtt or S.flyAtt.Parent~=r then
        flyStop()
        local att=Instance.new("Attachment"); att.Name="LeaFlyAtt"; att.Parent=r; S.flyAtt=att
        local lv=Instance.new("LinearVelocity"); lv.Name="LeaFlyLV"; lv.Attachment0=att
        lv.MaxForce=1e9; lv.RelativeTo=Enum.ActuatorRelativeTo.World; lv.Parent=r; S.flyBV=lv
        local ao=Instance.new("AlignOrientation"); ao.Name="LeaFlyAO"; ao.Attachment0=att
        ao.Mode=Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque=1e9; ao.Responsiveness=80; ao.Parent=r; S.flyBG=ao
    end
    if S.flyConn then return end
    S.flyConn = RunService.Heartbeat:Connect(function()
        if not ON.Fly or ON.CarFly then flyStop() return end
        local rr=hrp(); if not rr or not S.flyBV then return end
        local cam=Workspace.CurrentCamera; if not cam then return end
        local uis=UserInputService
        local v=Vector3.zero
        local f,rt=cam.CFrame.LookVector,cam.CFrame.RightVector
        if uis:IsKeyDown(Enum.KeyCode.W) then v+=f end
        if uis:IsKeyDown(Enum.KeyCode.S) then v-=f end
        if uis:IsKeyDown(Enum.KeyCode.A) then v-=rt end
        if uis:IsKeyDown(Enum.KeyCode.D) then v+=rt end
        if uis:IsKeyDown(Enum.KeyCode.Space) then v+=Vector3.yAxis end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then v-=Vector3.yAxis end
        S.flyBV.VectorVelocity = v.Magnitude>0 and v.Unit*CFG.flySpeed or Vector3.zero
        if S.flyBG then S.flyBG.CFrame=cam.CFrame end
        S.lastCF = rr.CFrame
    end)
end

local function setNoclip(on)
    if S.noclipConn then S.noclipConn:Disconnect() S.noclipConn=nil end
    if not on then return end
    S.noclipConn = RunService.Stepped:Connect(function()
        local c=char(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if ON.InfJump then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

Mouse.Button1Down:Connect(function()
    if not ON.ClickTP then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Mouse.Hit then
            local r=hrp(); if r then r.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,3,0)) end
        end
    end
end)

-- ===================== CAR FLY =====================
local function getVehicle()
    local h=hum(); if not h then return nil end
    local seat=h.SeatPart
    if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
        local m=seat:FindFirstAncestorOfClass("Model")
        return seat,m,(m and m.PrimaryPart) or seat
    end
    for _,o in ipairs(Workspace:GetDescendants()) do
        if (o:IsA("VehicleSeat") or o:IsA("Seat")) and o.Occupant==h then
            local m=o:FindFirstAncestorOfClass("Model")
            return o,m,(m and m.PrimaryPart) or o
        end
    end
end

local function carClean()
    pcall(function() if S.carBV then S.carBV:Destroy() end end)
    pcall(function() if S.carBG then S.carBG:Destroy() end end)
    pcall(function() if S.carAtt then S.carAtt:Destroy() end end)
    S.carBV,S.carBG,S.carAtt=nil,nil,nil
end

local function carNoclip(model, primary)
    local function strip(p)
        if p:IsA("BasePart") then
            p.CanCollide=false; p.CanTouch=false
            pcall(function() p.CanQuery=false end)
        end
    end
    if model then for _,p in ipairs(model:GetDescendants()) do strip(p) end
    elseif primary then strip(primary) end
    local c=char(); if c then for _,p in ipairs(c:GetDescendants()) do strip(p) end end
end

local function carAttach(primary)
    if not primary then return end
    if S.carAtt and S.carAtt.Parent~=primary then carClean() end
    if S.carAtt and S.carAtt.Parent==primary then return end
    local att=Instance.new("Attachment"); att.Name="LeaCarAtt"; att.Parent=primary; S.carAtt=att
    local lv=Instance.new("LinearVelocity"); lv.Name="LeaCarLV"; lv.Attachment0=att
    lv.MaxForce=1e10; lv.RelativeTo=Enum.ActuatorRelativeTo.World; lv.Parent=primary; S.carBV=lv
    local ao=Instance.new("AlignOrientation"); ao.Name="LeaCarAO"; ao.Attachment0=att
    ao.Mode=Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque=1e10; ao.Responsiveness=55; ao.Parent=primary; S.carBG=ao
end

local function carStop()
    if S.carConn then S.carConn:Disconnect() S.carConn=nil end
    carClean(); S.carModel=nil; S.carCF=nil; ON.CarFly=false
end

local function carStart()
    if not ON.Bypass then startBypass() end
    ON.CarFly=true
    if S.carConn then return end
    S.carConn = RunService.Heartbeat:Connect(function()
        if not ON.CarFly then carStop() return end
        local seat,model,primary = getVehicle()
        if not seat or not primary then
            if S.carBV then carClean(); S.carModel=nil; S.carCF=nil end
            return
        end
        local h=hum()
        if h and seat:IsA("VehicleSeat") and seat.Occupant~=h then pcall(function() seat:Sit(h) end) end
        if S.carModel~=model then
            S.carModel=model; S.carCF=nil; carClean()
            claim(model or primary); carNoclip(model,primary); carAttach(primary)
        end
        carNoclip(model,primary); claim(model or primary)
        if not S.carBV or S.carBV.Parent~=primary then carAttach(primary) end
        if not S.carBV then return end
        if seat:IsA("VehicleSeat") then pcall(function() seat.Torque=0; seat.TurnSpeed=0; seat.MaxSpeed=0 end) end
        pcall(function() primary.AssemblyAngularVelocity=Vector3.zero end)

        local cam=Workspace.CurrentCamera; if not cam then return end
        local uis=UserInputService
        local look=cam.CFrame.LookVector; local rght=cam.CFrame.RightVector
        local fwd=Vector3.new(look.X,0,look.Z); fwd=fwd.Magnitude>0.05 and fwd.Unit or Vector3.new(0,0,-1)
        local lat=Vector3.new(rght.X,0,rght.Z); lat=lat.Magnitude>0.05 and lat.Unit or Vector3.new(1,0,0)
        local v=Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then v=v+Vector3.yAxis end
        if uis:IsKeyDown(Enum.KeyCode.S) then v=v+fwd end
        if uis:IsKeyDown(Enum.KeyCode.A) then v=v-lat end
        if uis:IsKeyDown(Enum.KeyCode.D) then v=v+lat end
        if uis:IsKeyDown(Enum.KeyCode.Space) then v=v-Vector3.yAxis end
        local spd=uis:IsKeyDown(Enum.KeyCode.LeftShift) and CFG.carFlyBoost or CFG.carFlySpeed
        if v.Magnitude>0.05 then
            S.carBV.VectorVelocity=v.Unit*spd; S.carCF=primary.CFrame
        else
            S.carBV.VectorVelocity=Vector3.zero
            if not S.carCF then S.carCF=primary.CFrame end
        end
        if S.carBG then S.carBG.CFrame=CFrame.lookAt(primary.Position, primary.Position+fwd) end
        if S.carCF and (primary.Position-S.carCF.Position).Magnitude>CFG.carSnap then
            primary.CFrame=S.carCF
            primary.AssemblyLinearVelocity=Vector3.zero
            claim(model or primary)
            S.carBV.VectorVelocity=v.Magnitude>0.05 and v.Unit*spd or Vector3.zero
        elseif v.Magnitude>0.05 then
            S.carCF=primary.CFrame
        end
        local r=hrp()
        if r and (r.Position-primary.Position).Magnitude>12 then
            pcall(function() r.CFrame=primary.CFrame*CFrame.new(0,2,0); r.AssemblyLinearVelocity=Vector3.zero end)
        end
    end)
end

-- ===================== AIMBOT (center lock — RenderStepped) =====================
getBestTarget = function()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local cx, cy = vp.X*0.5, vp.Y*0.5
    local best, bestPx = nil, CFG.aimFovPx
    local myPos = (hrp() and hrp().Position) or cam.CFrame.Position

    -- sticky
    if S.aimTarget and S.aimTarget.Parent then
        local plr = Players:GetPlayerFromCharacter(S.aimTarget.Parent)
        if plr and not wl(plr) then
            local h = S.aimTarget.Parent:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local sp, on = cam:WorldToViewportPoint(S.aimTarget.Position)
                if on and sp.Z>0 then
                    local px = (Vector2.new(sp.X,sp.Y)-Vector2.new(cx,cy)).Magnitude
                    if px < CFG.aimFovPx*1.5 then return S.aimTarget end
                end
            end
        end
        S.aimTarget = nil
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and not wl(plr) then
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            local bone = plr.Character:FindFirstChild(CFG.aimBone)
                or plr.Character:FindFirstChild("HumanoidRootPart")
            if h and bone and h.Health>0 then
                if (bone.Position-myPos).Magnitude <= CFG.aimMaxDist then
                    local sp, on = cam:WorldToViewportPoint(bone.Position)
                    if on and sp.Z>0 then
                        local px = (Vector2.new(sp.X,sp.Y)-Vector2.new(cx,cy)).Magnitude
                        if px < bestPx then
                            bestPx = px
                            best = bone
                        end
                    end
                end
            end
        end
    end
    S.aimTarget = best
    return best
end

-- CRITICAL: camera lock on RenderStepped (not Heartbeat) so it wins over camera scripts
RunService.RenderStepped:Connect(function()
    if not ON.Aimbot then S.aimTarget=nil return end
    if not UserInputService:IsKeyDown(CFG.aimKey) then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local target = getBestTarget()
    if not target then return end

    local aim = target.Position
    if target.Name=="Head" then aim = aim + Vector3.new(0,0.1,0) end
    if CFG.aimPredict>0 and target.Parent then
        local root = target.Parent:FindFirstChild("HumanoidRootPart") or target
        aim = aim + root.AssemblyLinearVelocity * CFG.aimPredict
    end

    -- hard pull to center: lerp factor high
    local goal = CFrame.new(cam.CFrame.Position, aim)
    cam.CFrame = cam.CFrame:Lerp(goal, CFG.aimSmooth)
end)

-- ===================== ESP =====================
local function clearESP()
    if S.espFolder then pcall(function() S.espFolder:Destroy() end) end
    if S.tracerFolder then pcall(function() S.tracerFolder:Destroy() end) end
    S.espFolder,S.tracerFolder=nil,nil
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local x=plr.Character:FindFirstChild("LeaHL"); if x then x:Destroy() end
        end
    end
end

local function doESP()
    clearESP()
    if not (ON.ESP or ON.Tracers) then return end
    local f=Instance.new("Folder"); f.Name="LeaESP"; f.Parent=Workspace; S.espFolder=f
    local tf=Instance.new("Folder"); tf.Name="LeaTr"; tf.Parent=Workspace; S.tracerFolder=tf
    local originAtt
    local my=hrp()
    if my and ON.Tracers then
        originAtt=my:FindFirstChild("LeaTO") or Instance.new("Attachment")
        originAtt.Name="LeaTO"; originAtt.Parent=my
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local h=plr.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local friend=wl(plr)
                local col=friend and COL_F or COL_E
                if ON.ESP then
                    local hl=Instance.new("Highlight")
                    hl.Name="LeaHL"; hl.FillColor=col; hl.OutlineColor=col
                    hl.FillTransparency=0.55; hl.OutlineTransparency=0
                    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent=plr.Character
                end
                if ON.Tracers and originAtt then
                    local bone=plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
                    if bone then
                        local a1=bone:FindFirstChild("LeaTE") or Instance.new("Attachment")
                        a1.Name="LeaTE"; a1.Parent=bone
                        local beam=Instance.new("Beam")
                        beam.Attachment0=originAtt; beam.Attachment1=a1
                        beam.Width0=0.09; beam.Width1=0.09; beam.FaceCamera=true
                        beam.Color=ColorSequence.new(col)
                        beam.Transparency=NumberSequence.new(0.2)
                        beam.LightEmission=1; beam.Parent=tf
                    end
                end
            end
        end
    end
end

local function fullbright(on)
    if on then
        S.lit.b,S.lit.c,S.lit.f=Lighting.Brightness,Lighting.ClockTime,Lighting.FogEnd
        Lighting.Brightness=3.2; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.GlobalShadows=false
    else
        if S.lit.b then Lighting.Brightness=S.lit.b end
        if S.lit.c then Lighting.ClockTime=S.lit.c end
        if S.lit.f then Lighting.FogEnd=S.lit.f end
        Lighting.GlobalShadows=true; S.lit={}
    end
end

-- ===================== MINIMAP =====================
local function buildMap(parent)
    if S.map then S.map:Destroy() end
    local size=CFG.mapSize
    local frame=Instance.new("Frame")
    frame.Name="Radar"
    frame.Size=UDim2.fromOffset(size,size)
    frame.Position=UDim2.new(1,-size-12,0,12)
    frame.BackgroundColor3=Color3.fromRGB(8,8,10)
    frame.BackgroundTransparency=0.2
    frame.BorderSizePixel=0
    frame.ZIndex=90
    frame.Parent=parent
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",frame)
    stroke.Color=ACCENT; stroke.Thickness=1.2; stroke.Transparency=0.4

    -- crosshair lines
    local hline=Instance.new("Frame")
    hline.Size=UDim2.new(1,0,0,1); hline.Position=UDim2.new(0,0,0.5,0)
    hline.BackgroundColor3=Color3.fromRGB(60,60,70); hline.BackgroundTransparency=0.5
    hline.BorderSizePixel=0; hline.ZIndex=91; hline.Parent=frame
    local vline=Instance.new("Frame")
    vline.Size=UDim2.new(0,1,1,0); vline.Position=UDim2.new(0.5,0,0,0)
    vline.BackgroundColor3=Color3.fromRGB(60,60,70); vline.BackgroundTransparency=0.5
    vline.BorderSizePixel=0; vline.ZIndex=91; vline.Parent=frame

    local me=Instance.new("Frame")
    me.Size=UDim2.fromOffset(6,6); me.AnchorPoint=Vector2.new(0.5,0.5)
    me.Position=UDim2.fromScale(0.5,0.5); me.BackgroundColor3=COL_ME
    me.BorderSizePixel=0; me.ZIndex=93; me.Parent=frame
    Instance.new("UICorner",me).CornerRadius=UDim.new(1,0)

    local dots=Instance.new("Folder"); dots.Name="Dots"; dots.Parent=frame
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,0,0,14); label.BackgroundTransparency=1
    label.Text="RADAR"; label.Font=Enum.Font.GothamBold; label.TextSize=9
    label.TextColor3=ACCENT; label.ZIndex=92; label.Parent=frame

    S.map=frame; S.mapDots=dots
end

local function updateMap()
    if not ON.Minimap or not S.map or not S.mapDots then
        if S.map then S.map.Visible=false end
        return
    end
    S.map.Visible=true
    local my=hrp(); if not my then return end
    local myPos=my.Position
    local range=CFG.mapRange
    local half=CFG.mapSize*0.5
    for _,d in ipairs(S.mapDots:GetChildren()) do d:Destroy() end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local root=plr.Character:FindFirstChild("HumanoidRootPart")
            local h=plr.Character:FindFirstChildOfClass("Humanoid")
            if root and h and h.Health>0 then
                local dlt=root.Position-myPos
                local dx=math.clamp(dlt.X/range*half, -half+5, half-5)
                local dz=math.clamp(dlt.Z/range*half, -half+5, half-5)
                local dot=Instance.new("Frame")
                dot.Size=UDim2.fromOffset(6,6); dot.AnchorPoint=Vector2.new(0.5,0.5)
                dot.Position=UDim2.new(0.5,dx,0.5,dz)
                dot.BackgroundColor3=wl(plr) and COL_F or COL_E
                dot.BorderSizePixel=0; dot.ZIndex=92; dot.Parent=S.mapDots
                Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            end
        end
    end
end

local function updateFov()
    if not S.fov then return end
    if ON.Aimbot and ON.ShowFov then
        S.fov.Visible=true
        local d=CFG.aimFovPx*2
        S.fov.Size=UDim2.fromOffset(d,d)
    else
        S.fov.Visible=false
    end
end

-- ===================== LOOPS =====================
local _espT,_mapT=0,0
RunService.Heartbeat:Connect(function(dt)
    _espT+=dt; _mapT+=dt
    if _espT>=1.2 then _espT=0; if ON.ESP or ON.Tracers then pcall(doESP) end end
    if _mapT>=0.1 then _mapT=0; pcall(updateMap); pcall(updateFov) end
    if ON.NoFall then
        local h=hum()
        if h and h:GetState()==Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    if ON.MobPush then
        local r=hrp(); if r then
            for _,m in ipairs(Workspace:GetChildren()) do
                if m:IsA("Model") and m~=char() and not Players:GetPlayerFromCharacter(m) then
                    local mh=m:FindFirstChildOfClass("Humanoid")
                    local mr=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mh and mr and mh.Health>0 then
                        local d=(mr.Position-r.Position).Magnitude
                        if d>0.4 and d<=16 then
                            local away=r.Position-mr.Position
                            if away.Magnitude>0 then
                                r.AssemblyLinearVelocity=away.Unit*90+Vector3.new(0,40,0)
                            end
                        end
                    end
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
    claim(char()); stripConns()
    flyStop(); carStop()
    if ON.Fly then flyStart() end
    if ON.CarFly then carStart() end
    if ON.Speed then applySpeed() end
    if ON.Noclip then setNoclip(true) end
    if ON.ESP or ON.Tracers then doESP() end
    if ON.God then startGod() end
    S.aimTarget=nil; S.lastCF=nil
end)

-- ===================== UI =====================
local function say(t)
    if S.status then
        S.status.Text=tostring(t)
        task.delay(2, function()
            if S.status then S.status.Text="v9" end
        end)
    end
end

local function buildGui()
    local pg=LocalPlayer:WaitForChild("PlayerGui")
    local old=pg:FindFirstChild("LeaHub")
    if old then old:Destroy() end

    local g=Instance.new("ScreenGui")
    g.Name="LeaHub"; g.ResetOnSpawn=false; g.IgnoreGuiInset=true
    g.DisplayOrder=999; g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; g.Parent=pg
    S.gui=g

    -- FOV ring
    local fov=Instance.new("Frame")
    fov.Name="FOV"; fov.AnchorPoint=Vector2.new(0.5,0.5)
    fov.Position=UDim2.fromScale(0.5,0.5); fov.BackgroundTransparency=1
    fov.ZIndex=40; fov.Parent=g
    local fs=Instance.new("UIStroke",fov)
    fs.Color=ACCENT; fs.Thickness=1.2; fs.Transparency=0.45
    Instance.new("UICorner",fov).CornerRadius=UDim.new(1,0)
    S.fov=fov

    buildMap(g)

    -- open btn
    local open=Instance.new("TextButton")
    open.Size=UDim2.fromOffset(42,42); open.Position=UDim2.new(1,-54,0.5,-21)
    open.BackgroundColor3=Color3.fromRGB(18,18,22)
    open.Text="L"; open.Font=Enum.Font.GothamBlack; open.TextSize=16
    open.TextColor3=ACCENT; open.ZIndex=100; open.Parent=g
    Instance.new("UICorner",open).CornerRadius=UDim.new(0,10)
    local os_=Instance.new("UIStroke",open); os_.Color=ACCENT; os_.Thickness=1.2; os_.Transparency=0.3

    -- panel
    local panel=Instance.new("Frame")
    panel.Size=UDim2.fromOffset(280,500); panel.Position=UDim2.new(0.5,-140,0.5,-250)
    panel.BackgroundColor3=Color3.fromRGB(12,12,15); panel.Visible=false
    panel.ClipsDescendants=true; panel.ZIndex=50; panel.Parent=g
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
    local ps=Instance.new("UIStroke",panel); ps.Color=Color3.fromRGB(40,40,48); ps.Thickness=1

    -- header
    local head=Instance.new("Frame")
    head.Size=UDim2.new(1,0,0,40); head.BackgroundColor3=Color3.fromRGB(16,16,20)
    head.BorderSizePixel=0; head.ZIndex=51; head.Parent=panel
    Instance.new("UICorner",head).CornerRadius=UDim.new(0,12)
    local headFix=Instance.new("Frame")
    headFix.Size=UDim2.new(1,0,0,12); headFix.Position=UDim2.new(0,0,1,-12)
    headFix.BackgroundColor3=Color3.fromRGB(16,16,20); headFix.BorderSizePixel=0; headFix.ZIndex=51; headFix.Parent=head

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,-50,1,0); title.Position=UDim2.fromOffset(14,0)
    title.BackgroundTransparency=1; title.Text="LEA  ·  v9"
    title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextColor3=Color3.fromRGB(230,230,235)
    title.TextXAlignment=Enum.TextXAlignment.Left; title.ZIndex=52; title.Parent=head

    local close=Instance.new("TextButton")
    close.Size=UDim2.fromOffset(26,26); close.Position=UDim2.new(1,-34,0.5,-13)
    close.BackgroundColor3=Color3.fromRGB(30,20,22); close.Text="×"
    close.Font=Enum.Font.GothamBold; close.TextSize=14; close.TextColor3=Color3.fromRGB(255,100,110)
    close.ZIndex=52; close.Parent=head
    Instance.new("UICorner",close).CornerRadius=UDim.new(0,6)
    close.MouseButton1Click:Connect(function() panel.Visible=false end)

    -- drag
    local dragging,d0,p0=false,nil,nil
    head.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; d0=i.Position; p0=panel.Position
        end
    end)
    head.InputEnded:Connect(function() dragging=false end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-d0
            panel.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X, p0.Y.Scale,p0.Y.Offset+d.Y)
        end
    end)

    -- tabs
    local tabBar=Instance.new("Frame")
    tabBar.Size=UDim2.new(1,-12,0,30); tabBar.Position=UDim2.fromOffset(6,44)
    tabBar.BackgroundColor3=Color3.fromRGB(16,16,20); tabBar.ZIndex=51; tabBar.Parent=panel
    Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,8)
    local tabLay=Instance.new("UIListLayout",tabBar)
    tabLay.FillDirection=Enum.FillDirection.Horizontal; tabLay.Padding=UDim.new(0,2)
    tabLay.VerticalAlignment=Enum.VerticalAlignment.Center
    local tabPad=Instance.new("UIPadding",tabBar)
    tabPad.PaddingLeft=UDim.new(0,3); tabPad.PaddingRight=UDim.new(0,3)
    tabPad.PaddingTop=UDim.new(0,3); tabPad.PaddingBottom=UDim.new(0,3)

    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,-12,1,-108); scroll.Position=UDim2.fromOffset(6,80)
    scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=2
    scroll.ScrollBarImageColor3=ACCENT; scroll.CanvasSize=UDim2.fromOffset(0,0)
    scroll.ZIndex=51; scroll.Parent=panel
    local sLay=Instance.new("UIListLayout",scroll)
    sLay.Padding=UDim.new(0,4); sLay.SortOrder=Enum.SortOrder.LayoutOrder
    sLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize=UDim2.fromOffset(0, sLay.AbsoluteContentSize.Y+10)
    end)

    local status=Instance.new("TextLabel")
    status.Size=UDim2.new(1,-12,0,20); status.Position=UDim2.new(0,6,1,-26)
    status.BackgroundColor3=Color3.fromRGB(10,10,12); status.Text="v9"
    status.Font=Enum.Font.Gotham; status.TextSize=11; status.TextColor3=Color3.fromRGB(120,200,140)
    status.TextXAlignment=Enum.TextXAlignment.Left; status.ZIndex=52; status.Parent=panel
    Instance.new("UICorner",status).CornerRadius=UDim.new(0,6)
    local sp=Instance.new("UIPadding",status); sp.PaddingLeft=UDim.new(0,8)
    S.status=status

    local TABS={
        {id="main", t="Main"},
        {id="combat", t="Aim"},
        {id="move", t="Move"},
        {id="visual", t="ESP"},
        {id="list", t="List"},
    }
    local pages,tabs,active={},{},nil

    for _,td in ipairs(TABS) do
        local page=Instance.new("Frame")
        page.Name=td.id; page.Size=UDim2.new(1,0,0,0); page.BackgroundTransparency=1
        page.Visible=false; page.AutomaticSize=Enum.AutomaticSize.Y; page.ZIndex=52; page.Parent=scroll
        local pl=Instance.new("UIListLayout",page); pl.Padding=UDim.new(0,4); pl.SortOrder=Enum.SortOrder.LayoutOrder
        pages[td.id]={f=page, o=0}
    end

    local function switch(id)
        if active==id then return end
        active=id
        for _,td in ipairs(TABS) do
            if pages[td.id] then pages[td.id].f.Visible=(td.id==id) end
        end
        for tid,b in pairs(tabs) do
            b.BackgroundColor3=(tid==id) and Color3.fromRGB(36,28,18) or Color3.fromRGB(22,22,28)
            b.TextColor3=(tid==id) and ACCENT or Color3.fromRGB(140,140,150)
        end
        scroll.CanvasPosition=Vector2.zero
    end

    local n=#TABS
    for _,td in ipairs(TABS) do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1/n,-2,1,0); b.BackgroundColor3=Color3.fromRGB(22,22,28)
        b.Text=td.t; b.Font=Enum.Font.GothamMedium; b.TextSize=11
        b.TextColor3=Color3.fromRGB(140,140,150); b.ZIndex=52; b.Parent=tabBar
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        tabs[td.id]=b
        local id=td.id
        b.MouseButton1Click:Connect(function() switch(id) end)
    end

    local function tog(page, name, key, onE, onD)
        local p=pages[page]; if not p then return end
        p.o+=1
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-2,0,34); row.BackgroundColor3=Color3.fromRGB(18,18,22)
        row.LayoutOrder=p.o; row.ZIndex=52; row.Parent=p.f
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-54,1,0); lbl.Position=UDim2.fromOffset(10,0)
        lbl.BackgroundTransparency=1; lbl.Text=name; lbl.Font=Enum.Font.GothamMedium
        lbl.TextSize=12; lbl.TextColor3=Color3.fromRGB(160,160,170)
        lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=53; lbl.Parent=row
        local pill=Instance.new("Frame")
        pill.Size=UDim2.fromOffset(38,20); pill.Position=UDim2.new(1,-46,0.5,-10)
        pill.ZIndex=53; pill.Parent=row
        Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local dot=Instance.new("Frame")
        dot.Size=UDim2.fromOffset(14,14); dot.ZIndex=54; dot.Parent=pill
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local function ref()
            local on=ON[key]
            pill.BackgroundColor3=on and ACCENT or Color3.fromRGB(40,40,48)
            dot.BackgroundColor3=on and Color3.new(1,1,1) or Color3.fromRGB(100,100,110)
            dot.Position=on and UDim2.fromOffset(20,3) or UDim2.fromOffset(3,3)
            lbl.TextColor3=on and Color3.fromRGB(255,210,150) or Color3.fromRGB(160,160,170)
            row.BackgroundColor3=on and Color3.fromRGB(28,24,18) or Color3.fromRGB(18,18,22)
        end
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=55; btn.Parent=row
        btn.MouseButton1Click:Connect(function()
            ON[key]=not ON[key]; ref()
            if ON[key] and onE then pcall(onE) end
            if not ON[key] and onD then pcall(onD) end
            say(name..(ON[key] and " on" or " off"))
        end)
        ref()
    end

    local function act(page, name, fn)
        local p=pages[page]; if not p then return end
        p.o+=1
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1,-2,0,32); b.BackgroundColor3=Color3.fromRGB(18,18,22)
        b.LayoutOrder=p.o; b.ZIndex=52; b.Parent=p.f
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        b.Text="  "..name; b.Font=Enum.Font.GothamMedium; b.TextSize=12
        b.TextColor3=Color3.fromRGB(220,220,225); b.TextXAlignment=Enum.TextXAlignment.Left
        b.MouseButton1Click:Connect(function()
            pcall(fn)
            b.BackgroundColor3=Color3.fromRGB(32,28,20)
            task.delay(0.1,function() b.BackgroundColor3=Color3.fromRGB(18,18,22) end)
        end)
    end

    local function sec(page, name)
        local p=pages[page]; if not p then return end
        p.o+=1
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,0,0,16); l.BackgroundTransparency=1
        l.Text=string.upper(name); l.Font=Enum.Font.GothamBold; l.TextSize=9
        l.TextColor3=Color3.fromRGB(100,90,80); l.TextXAlignment=Enum.TextXAlignment.Left
        l.LayoutOrder=p.o; l.ZIndex=52; l.Parent=p.f
    end

    -- MAIN
    sec("main","bypass")
    act("main","Enable Bypass", function() startBypass(); say("bypass live") end)
    tog("main","Ownership", "Ownership")
    tog("main","Anti-Teleport", "AntiTP")
    tog("main","God Mode", "God", startGod, function() if S.godConn then S.godConn:Disconnect() end end)

    -- COMBAT
    sec("combat","aimbot")
    tog("combat","Aimbot [hold Q]", "Aimbot")
    tog("combat","FOV Circle", "ShowFov")
    tog("combat","Silent Aim", "SilentAim")
    act("combat","FOV +50", function() CFG.aimFovPx=math.clamp(CFG.aimFovPx+50,80,700); say("fov "..CFG.aimFovPx); updateFov() end)
    act("combat","FOV -50", function() CFG.aimFovPx=math.clamp(CFG.aimFovPx-50,80,700); say("fov "..CFG.aimFovPx); updateFov() end)
    act("combat","Lock harder", function() CFG.aimSmooth=math.clamp(CFG.aimSmooth+0.05,0.5,1); say("smooth "..string.format("%.2f",CFG.aimSmooth)) end)
    act("combat","Lock softer", function() CFG.aimSmooth=math.clamp(CFG.aimSmooth-0.05,0.5,1); say("smooth "..string.format("%.2f",CFG.aimSmooth)) end)
    sec("combat","extra")
    tog("combat","Mob Push", "MobPush")
    tog("combat","No Fall", "NoFall")

    -- MOVE
    sec("move","movement")
    tog("move","Speed", "Speed", applySpeed, applySpeed)
    tog("move","High Jump", "HighJump", applySpeed, applySpeed)
    tog("move","Fly", "Fly", flyStart, flyStop)
    tog("move","Noclip", "Noclip", function() setNoclip(true) end, function() setNoclip(false) end)
    tog("move","Inf Jump", "InfJump")
    tog("move","Click TP", "ClickTP")
    sec("move","vehicle")
    tog("move","Car Fly", "CarFly", carStart, carStop)

    -- VISUAL
    sec("visual","esp")
    tog("visual","ESP", "ESP", doESP, function() if not ON.Tracers then clearESP() else doESP() end end)
    tog("visual","Tracers", "Tracers", doESP, function() if not ON.ESP then clearESP() else doESP() end end)
    tog("visual","Minimap", "Minimap")
    tog("visual","Fullbright", "Fullbright", function() fullbright(true) end, function() fullbright(false) end)

    -- LIST
    sec("list","whitelist")
    local lp=pages["list"]; lp.o+=1
    local box=Instance.new("ScrollingFrame")
    box.Size=UDim2.new(1,-2,0,220); box.BackgroundColor3=Color3.fromRGB(14,14,16)
    box.LayoutOrder=lp.o; box.ZIndex=52; box.ScrollBarThickness=2; box.Parent=lp.f
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,8)
    local bl=Instance.new("UIListLayout",box); bl.Padding=UDim.new(0,3)
    bl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        box.CanvasSize=UDim2.fromOffset(0, bl.AbsoluteContentSize.Y+6)
    end)

    local function refreshList()
        for _,c in ipairs(box:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer then
                local friend=wl(plr)
                local b=Instance.new("TextButton")
                b.Size=UDim2.new(1,-6,0,26)
                b.BackgroundColor3=friend and Color3.fromRGB(18,36,22) or Color3.fromRGB(36,18,18)
                b.Text=(friend and "[WL] " or "")..plr.Name
                b.Font=Enum.Font.Gotham; b.TextSize=11
                b.TextColor3=friend and COL_F or COL_E; b.ZIndex=53; b.Parent=box
                Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
                local p=plr
                b.MouseButton1Click:Connect(function()
                    if WHITELIST[p.UserId] then WHITELIST[p.UserId]=nil else WHITELIST[p.UserId]=true end
                    refreshList()
                    if ON.ESP or ON.Tracers then doESP() end
                    say(p.Name..(wl(p) and " friend" or " enemy"))
                end)
            end
        end
    end
    act("list","Refresh", refreshList)
    Players.PlayerAdded:Connect(function() task.defer(refreshList) end)
    Players.PlayerRemoving:Connect(function(p) WHITELIST[p.UserId]=nil; task.defer(refreshList) end)
    task.defer(refreshList)

    open.MouseButton1Click:Connect(function()
        panel.Visible=not panel.Visible
        if panel.Visible then if not active then switch("main") end; refreshList() end
    end)
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then
            panel.Visible=not panel.Visible
            if panel.Visible then if not active then switch("main") end; refreshList() end
        elseif i.KeyCode==Enum.KeyCode.F9 then
            ON.Aimbot=not ON.Aimbot; say("aimbot "..(ON.Aimbot and "on" or "off"))
        elseif i.KeyCode==Enum.KeyCode.F8 then
            ON.ESP=not ON.ESP
            if ON.ESP or ON.Tracers then doESP() else clearESP() end
            say("esp "..(ON.ESP and "on" or "off"))
        end
    end)

    switch("main")
end

-- ===================== INIT =====================
task.wait(0.25)
startBypass()
buildGui()
ON.Minimap=true
ON.ShowFov=true
updateFov()
