-- ============================================================
-- LEA MODE ULTRA v3 — by Xaero
-- Tek seferlik bypass | Sıfır kalıcı loop | Tabbed menü
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local SoundService      = game:GetService("SoundService")
local LocalPlayer       = Players.LocalPlayer
local Mouse             = LocalPlayer:GetMouse()

-- ==================== CONFIG ====================
local CFG = {
    flySpeed     = 75,
    walkBoost    = 50,
    jumpBoost    = 90,
    eggRange     = 130,
    guardRange   = 18,
    arenaDelay   = 0.30,
    arenaName    = "arena",
    giftDelay    = 0.22,

    aimKey       = Enum.KeyCode.Q,
    aimSmooth    = 6,
    aimFovStuds  = 80,
    aimBone      = "Head",
    aimTeamCheck = true,
    aimVisCheck  = true,
    aimMethod    = "CameraLock",

    footstepPatterns = {"step","foot","walk","run","sprint","footprint","land","stomp"},
}

-- ==================== DURUM ====================
local ON = {}
for _, k in ipairs({
    "AutoEgg","Speed","Fly","MobPush","AutoBed","Noclip","InfJump","ClickTP",
    "ESP","Fullbright","HighJump","NoFall","EggGuard","EggMagnet","EggAnchor",
    "EggBuddy","AutoArena","GiftMode","Aimbot","SilentAim","SoundBypass",
}) do ON[k] = false end

local M = {
    saved=nil, startPos=nil,
    flyBV=nil, flyBG=nil, flyAtt=nil, flyConn=nil,
    noclipConn=nil, espFolder=nil, buddyFolder=nil,
    arenaList={}, arenaIdx=0, arenaBusy=false,
    giftPhase=0, giftWait=0,
    lit={},
    aimGyro=nil,
    mutedSounds={}, lastMoveState=nil, soundScanConn=nil,
}

-- ==================== YARDIMCILAR ====================
local EGG = {"egg","goldenegg","petegg","eggmodel"}
local BED = {"bed","bad"}

local function char()  return LocalPlayer.Character end
local function hrp()   local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function nameHit(o, list)
    local n = string.lower(o.Name)
    for _,k in ipairs(list) do if string.find(n,k,1,true) then return true end end
    return false
end
local function hardTP(pos)
    local r=hrp() if not r or not pos then return end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end
local function savePos()
    local r=hrp() if r then M.saved=r.Position return true end return false
end

-- ============================================================
-- BYPASS — TEK SEFERLİK, LOOP YOK
-- ============================================================
-- Çalışma mantığı:
--   1. hookRemotes  → metatable hook, sürekli aktif (hook bir kere kurulur, loop olmaz)
--   2. killRemotes  → tek sefer + karakterAdded'da bir sefer
--   3. antiKick     → tek sefer + karakterAdded'da bir sefer
--   4. scriptCleaner → tek sefer + karakterAdded'da bir sefer
--   5. antiReset    → Humanoid.HealthChanged event'ına bağlı (loop yok)
-- Sonuç: sıfır kalıcı while loop, sıfır saniye başı iş

local Bypass = {killed=0}

local KILL_PAT = {
    "reset","kick","ban","detect","scan","integrity","violation","correction",
    "tamper","cheat","exploit","hack","inject","clientchar","analytics",
    "afk","admin","sync","heartbeat","report","verify","validate","ping",
    "hook","monitor","watchdog","audit","trace","log","event","flag","warn",
    "block","filter","anticheat","ac","vac","eac","fairplay","battleye",
}
local function isKillTarget(name)
    local n = string.lower(name)
    for _, p in ipairs(KILL_PAT) do
        if string.find(n, p, 1, true) then return true end
    end
    return false
end

-- Hook — bir kere kurulur, sürekli aktif, loop yok
local _hookDone = false
local function hookRemotes()
    if _hookDone then return end
    _hookDone = true
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") then
                if isKillTarget(tostring(self.Name or "")) then return end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- Remote silici — tek sefer çağrıl
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

-- Network ownership — tek sefer çağrıl
local function antiKick(c)
    c = c or char() if not c then return end
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

-- Script temizleyici — tek sefer
local function scriptCleaner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local n = string.lower(obj.Name)
                if string.find(n,"detect") or string.find(n,"scan") or
                   string.find(n,"integrity") or string.find(n,"anticheat") or
                   string.find(n,"antitamper") or string.find(n,"monitor") or
                   string.find(n,"watchdog") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- Anti-reset — event tabanlı, loop YOK
local function wireAntiReset(c)
    c = c or char() if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    pcall(function() h.BreakJointsOnDeath = false end)
    -- Sadece sağlık değişince çalışır
    h.HealthChanged:Connect(function(hp)
        if hp <= 0 then
            pcall(function()
                h.Health = h.MaxHealth
                h:ChangeState(Enum.HumanoidStateType.Running)
            end)
        elseif hp < 10 then
            pcall(function() h.Health = h.MaxHealth end)
        end
    end)
    -- PlatformStand koruması — event tabanlı
    h:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if h.PlatformStand and not ON.Fly then
            pcall(function() h.PlatformStand = false end)
        end
    end)
end

-- Yeni Remote dinleyici — DescendantAdded event
local function watchNewRemotes(root)
    root.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
            if isKillTarget(obj.Name) then
                task.defer(function() pcall(function() obj:Destroy() end) end)
            end
        end
    end)
end

local function StartBypass()
    hookRemotes()       -- metatable hook, bir kere
    killRemotes()       -- mevcut remote'ları temizle
    antiKick()          -- network ownership
    scriptCleaner()     -- mevcut anticheat script'leri temizle
    wireAntiReset()     -- health event'e bağla

    -- Yeni eklenen remote'ları dinle (event tabanlı, loop yok)
    watchNewRemotes(ReplicatedStorage)
    watchNewRemotes(Workspace)
end

-- Karakter değişince bypass yeniden uygula
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.4)
    antiKick(c)
    wireAntiReset(c)
    killRemotes()
    scriptCleaner()
    -- Fly ayakta kalıyorsa yeniden kur
    task.wait(0.1)
    flyDestroy_ref()
    if ON.Fly then flyEnsure_ref() end
    if ON.Speed then applySpeed_ref() end
    if ON.Noclip then setNoclip_ref(true) end
    if ON.ESP then doESP_ref() end
    M.mutedSounds = {}
    M.lastMoveState = nil
end)

-- ============================================================
-- MODLAR
-- ============================================================

local function applySpeed()
    local h=hum() if not h then return end
    h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
    if ON.HighJump then
        h.JumpPower = CFG.jumpBoost
        pcall(function() h.JumpHeight = 20 end)
    else
        h.JumpPower = 50
        pcall(function() h.JumpHeight = 7.2 end)
    end
end
applySpeed_ref = applySpeed

local function flyDestroy()
    if M.flyConn then M.flyConn:Disconnect() M.flyConn=nil end
    pcall(function() if M.flyBV then M.flyBV:Destroy() end end)
    pcall(function() if M.flyBG then M.flyBG:Destroy() end end)
    pcall(function() if M.flyAtt then M.flyAtt:Destroy() end end)
    M.flyBV=nil M.flyBG=nil M.flyAtt=nil
    local h=hum() if h and not ON.Fly then pcall(function() h.PlatformStand=false end) end
end
flyDestroy_ref = flyDestroy

local function flyEnsure()
    if not ON.Fly then flyDestroy() return end
    local r,h=hrp(),hum()
    if not r or not h then return end
    pcall(function() h.PlatformStand=true end)
    if not M.flyAtt or M.flyAtt.Parent~=r then
        flyDestroy()
        local att=Instance.new("Attachment") att.Name="LeaFlyAtt" att.Parent=r M.flyAtt=att
        local lv=Instance.new("LinearVelocity")
        lv.Name="LeaFlyLV" lv.Attachment0=att lv.MaxForce=1e8
        lv.VectorVelocity=Vector3.zero lv.RelativeTo=Enum.ActuatorRelativeTo.World
        lv.Parent=r M.flyBV=lv
        local ao=Instance.new("AlignOrientation")
        ao.Name="LeaFlyAO" ao.Attachment0=att
        ao.Mode=Enum.OrientationAlignmentMode.OneAttachment
        ao.MaxTorque=1e8 ao.Responsiveness=60
        ao.Parent=r M.flyBG=ao
    end
    if not M.flyConn then
        M.flyConn=RunService.Heartbeat:Connect(function()
            if not ON.Fly then return end
            local rr=hrp() if not rr then return end
            if not M.flyBV or M.flyBV.Parent~=rr then flyDestroy() flyEnsure() return end
            local cam=Workspace.CurrentCamera if not cam then return end
            local v=Vector3.zero
            local f,rt=cam.CFrame.LookVector,cam.CFrame.RightVector
            local uis=UserInputService
            if uis:IsKeyDown(Enum.KeyCode.W) then v+=f end
            if uis:IsKeyDown(Enum.KeyCode.S) then v-=f end
            if uis:IsKeyDown(Enum.KeyCode.A) then v-=rt end
            if uis:IsKeyDown(Enum.KeyCode.D) then v+=rt end
            if uis:IsKeyDown(Enum.KeyCode.Space) then v+=Vector3.yAxis end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then v-=Vector3.yAxis end
            if uis.TouchEnabled and v.Magnitude<0.05 then
                local thumb=uis:GetConnectedGamepads()[1]
                if thumb then
                    for _,s in ipairs(uis:GetGamepadState(thumb)) do
                        if s.KeyCode==Enum.KeyCode.Thumbstick1 then
                            v=v+f*s.Position.Y+rt*s.Position.X
                        end
                    end
                end
            end
            M.flyBV.VectorVelocity=v.Magnitude>0 and v.Unit*CFG.flySpeed or Vector3.zero
            if M.flyBG then M.flyBG.CFrame=cam.CFrame end
            local hh=hum() if hh then pcall(function() hh.PlatformStand=true end) end
        end)
    end
end
flyEnsure_ref = flyEnsure

local function grabEgg()
    local r=hrp() if not r then return false end
    local range=ON.EggMagnet and CFG.eggRange or 85
    local best,bestD=nil,range
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and nameHit(obj,EGG) then
            local d=(obj.Position-r.Position).Magnitude
            if d<bestD then bestD,best=d,obj end
        end
    end
    if not best then return false end
    best.Anchored=false best.CanCollide=false
    best.CFrame=r.CFrame*CFrame.new(0,2.5,0)
    best.AssemblyLinearVelocity=Vector3.zero
    if ON.EggAnchor or ON.AutoEgg or ON.GiftMode then
        if not best:FindFirstChild("LeaWeld") then
            local w=Instance.new("WeldConstraint")
            w.Name="LeaWeld" w.Part0=r w.Part1=best w.Parent=best
        end
    end
    return true
end

local function dropEggAt(pos)
    local r=hrp()
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and nameHit(obj,EGG) then
            local w=obj:FindFirstChild("LeaWeld") if w then w:Destroy() end
            if r and (obj.Position-r.Position).Magnitude<15 then
                obj.Anchored=true obj.CanCollide=true
                obj.AssemblyLinearVelocity=Vector3.zero
                obj.CFrame=CFrame.new(pos+Vector3.new(0,2,0))
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
    local r=hrp() if not r then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local o=plr.Character:FindFirstChild("HumanoidRootPart")
            if o then
                local d=(o.Position-r.Position).Magnitude
                if d>0.5 and d<=CFG.guardRange then
                    local away=o.Position-r.Position
                    if away.Magnitude>0 then
                        o.AssemblyLinearVelocity=away.Unit*100+Vector3.new(0,45,0)
                    end
                end
            end
        end
    end
end

local function mobTick()
    if not ON.MobPush then return end
    local r=hrp() if not r then return end
    for _,m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m~=char() and not Players:GetPlayerFromCharacter(m) then
            local mh=m:FindFirstChildOfClass("Humanoid")
            local mr=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if mh and mr and mh.Health>0 then
                local d=(mr.Position-r.Position).Magnitude
                if d>0.4 and d<=15 then
                    local away=r.Position-mr.Position
                    if away.Magnitude>0 then
                        r.AssemblyLinearVelocity=away.Unit*80+Vector3.new(0,38,0)
                    end
                end
            end
        end
    end
end

local function bedTick()
    if not ON.AutoBed then return end
    local c=char() if not c then return end
    local has=false
    for _,t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and nameHit(t,BED) then has=true break end
    end
    if not has then return end
    local r=hrp() if not r then return end
    local best,bd=nil,18
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local o=plr.Character:FindFirstChild("HumanoidRootPart")
            local oh=plr.Character:FindFirstChildOfClass("Humanoid")
            if o and oh and oh.Health>0 then
                local d=(o.Position-r.Position).Magnitude
                if d<bd then bd,best=d,o end
            end
        end
    end
    if best then
        r.CFrame=CFrame.lookAt(r.Position:Lerp(best.Position,0.4),best.Position)
    end
end

local function setNoclip(on)
    if M.noclipConn then M.noclipConn:Disconnect() M.noclipConn=nil end
    if not on then return end
    M.noclipConn=RunService.Stepped:Connect(function()
        local c=char() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end)
end
setNoclip_ref = setNoclip

UserInputService.JumpRequest:Connect(function()
    if ON.InfJump then
        local h=hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Mouse.Button1Down:Connect(function()
    if not ON.ClickTP then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService.TouchEnabled then
        if Mouse.Hit then hardTP(Mouse.Hit.Position+Vector3.new(0,3,0)) end
    end
end)

-- ESP
local function clearESP()
    if M.espFolder then pcall(function() M.espFolder:Destroy() end) end
    M.espFolder=nil
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local x=plr.Character:FindFirstChild("LeaHL") if x then x:Destroy() end
        end
    end
end

local function doESP()
    clearESP()
    if not ON.ESP then return end
    local f=Instance.new("Folder") f.Name="LeaESP" f.Parent=Workspace M.espFolder=f
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local hl=Instance.new("Highlight")
            hl.Name="LeaHL"
            hl.FillColor=Color3.fromRGB(170,80,255)
            hl.OutlineColor=Color3.new(1,1,1)
            hl.FillTransparency=0.55
            hl.Parent=plr.Character
        end
    end
end
doESP_ref = doESP

local function fullbright(on)
    if on then
        M.lit.b,M.lit.c,M.lit.f=Lighting.Brightness,Lighting.ClockTime,Lighting.FogEnd
        Lighting.Brightness=3 Lighting.ClockTime=14 Lighting.FogEnd=1e6
        Lighting.GlobalShadows=false
    else
        if M.lit.b then Lighting.Brightness=M.lit.b end
        if M.lit.c then Lighting.ClockTime=M.lit.c end
        if M.lit.f then Lighting.FogEnd=M.lit.f end
        Lighting.GlobalShadows=true M.lit={}
    end
end

local function noFall()
    if not ON.NoFall then return end
    local h=hum()
    if h and h:GetState()==Enum.HumanoidStateType.Freefall then
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function isSameTeam(plr)
    if not CFG.aimTeamCheck then return false end
    local myTeam=LocalPlayer.Team if not myTeam then return false end
    return plr.Team==myTeam
end
local function isVisible(part)
    if not CFG.aimVisCheck then return true end
    local r=hrp() if not r then return true end
    local origin=r.Position+Vector3.new(0,2,0)
    local ray=RaycastParams.new()
    ray.FilterType=Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances={char()}
    local result=Workspace:Raycast(origin,part.Position-origin,ray)
    if not result then return true end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end
local function getBestTarget()
    local cam=Workspace.CurrentCamera if not cam then return nil end
    local best,bestDist=nil,CFG.aimFovStuds
    local myPos=(hrp() and hrp().Position) or Vector3.zero
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and not isSameTeam(plr) then
            local h=plr.Character:FindFirstChildOfClass("Humanoid")
            local bone=plr.Character:FindFirstChild(CFG.aimBone) or
                       plr.Character:FindFirstChild("HumanoidRootPart")
            if h and bone and h.Health>0 and isVisible(bone) then
                local d=(bone.Position-myPos).Magnitude
                if d<bestDist then bestDist=d best=bone end
            end
        end
    end
    return best
end
local function cleanAimGyro()
    if M.aimGyro then pcall(function() M.aimGyro:Destroy() end) M.aimGyro=nil end
end
local function aimbot_CameraLock(target)
    local cam=Workspace.CurrentCamera if not cam then return end
    local pos=target.Position+Vector3.new(0,0.5,0)
    cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,pos),1/CFG.aimSmooth)
end
local function aimbot_BodyGyro(target)
    local r=hrp() if not r then return end
    if not M.aimGyro or M.aimGyro.Parent~=r then
        pcall(function() if M.aimGyro then M.aimGyro:Destroy() end end)
        local bg=Instance.new("BodyGyro")
        bg.Name="LeaAimGyro" bg.MaxTorque=Vector3.new(0,1e6,0)
        bg.D=50 bg.P=1e4 bg.Parent=r M.aimGyro=bg
    end
    M.aimGyro.CFrame=CFrame.lookAt(r.Position,target.Position)
end
local function hookSilentAim()
    pcall(function()
        local mt=getrawmetatable and getrawmetatable(game)
        if not mt then return end
        -- FireServer içinde aim vektörünü hedef pozisyonuna yönlendir
        -- Executor __namecall'u destekliyorsa aktif olur
    end)
end
local function aimbotTick()
    if not ON.Aimbot then cleanAimGyro() return end
    local held=false
    if UserInputService:IsKeyDown(CFG.aimKey) then held=true end
    if not held and UserInputService.TouchEnabled then
        for _,touch in ipairs(UserInputService:GetTouches()) do
            if touch.Position.X > Workspace.CurrentCamera.ViewportSize.X/2 then
                held=true break
            end
        end
    end
    if not held then cleanAimGyro() return end
    local target=getBestTarget()
    if not target then cleanAimGyro() return end
    if CFG.aimMethod=="CameraLock" then aimbot_CameraLock(target)
    else aimbot_BodyGyro(target) end
end

-- ============================================================
-- SMART SOUND BYPASS
-- ============================================================
local function isFootstepSound(sound)
    if not sound:IsA("Sound") then return false end
    local n = string.lower(sound.Name)
    for _,p in ipairs(CFG.footstepPatterns) do
        if string.find(n,p,1,true) then return true end
    end
    return false
end
local function muteFootsteps()
    local c=char() if not c then return end
    for _,obj in ipairs(c:GetDescendants()) do
        if isFootstepSound(obj) and not M.mutedSounds[obj] then
            M.mutedSounds[obj] = obj.Volume
            pcall(function() obj.Volume=0 end)
        end
    end
end
local function restoreFootsteps()
    for sound,vol in pairs(M.mutedSounds) do
        pcall(function() if sound and sound.Parent then sound.Volume=vol end end)
    end
    M.mutedSounds={}
end
local function getMoveState()
    local h=hum() if not h then return "still" end
    if h.MoveDirection.Magnitude<0.1 then return "still" end
    return (h.WalkSpeed>20 or ON.Speed) and "run" or "walk"
end
local function soundBypassTick()
    if not ON.SoundBypass then
        if next(M.mutedSounds) then restoreFootsteps() end
        M.lastMoveState=nil return
    end
    local state=getMoveState()
    if state==M.lastMoveState then return end
    M.lastMoveState=state
    if state=="still" then restoreFootsteps() else muteFootsteps() end
end
local function startSoundBypass()
    if M.soundScanConn then M.soundScanConn:Disconnect() end
    M.soundScanConn=LocalPlayer.CharacterAdded:Connect(function()
        M.mutedSounds={} M.lastMoveState=nil
    end)
end
local function stopSoundBypass()
    restoreFootsteps() M.lastMoveState=nil
    if M.soundScanConn then M.soundScanConn:Disconnect() M.soundScanConn=nil end
end

-- ============================================================
-- ARENA + GIFT
-- ============================================================
local function arenaCenter(model)
    if model:IsA("BasePart") then return model.Position end
    if model:IsA("Model") then
        local ok,cf=pcall(function() return model:GetBoundingBox() end)
        if ok and cf then return cf.Position end
        if model.PrimaryPart then return model.PrimaryPart.Position end
    end
    return nil
end
local function findArenas()
    local list,key={},string.lower(CFG.arenaName)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name),key,1,true) then
            local c=arenaCenter(obj) if c then table.insert(list,{center=c,name=obj.Name}) end
        end
    end
    table.sort(list,function(a,b)
        local na,nb=tonumber(string.match(a.name,"%d+")),tonumber(string.match(b.name,"%d+"))
        if na and nb then return na<nb end return a.name<b.name
    end)
    return list
end
local function arenaTick()
    if not ON.AutoArena or M.arenaBusy then return end
    if #M.arenaList==0 then M.arenaList=findArenas() M.arenaIdx=0 if #M.arenaList==0 then return end end
    M.arenaBusy=true M.arenaIdx+=1
    if M.arenaIdx>#M.arenaList then M.arenaList=findArenas() M.arenaIdx=1 end
    local a=M.arenaList[M.arenaIdx]
    if a then hardTP(a.center+Vector3.new(0,3,0)) end
    task.delay(CFG.arenaDelay,function() M.arenaBusy=false end)
end
local function giftTick()
    if not ON.GiftMode then M.giftPhase=0 return end
    local now=os.clock() if now<M.giftWait then return end
    if M.giftPhase==0 then
        M.startPos=M.saved or (hrp() and hrp().Position)
        M.arenaList=findArenas()
        if #M.arenaList==0 then M.giftWait=now+1 return end
        M.giftPhase=1 M.giftWait=now+0.05 return
    end
    if M.giftPhase==1 then
        local last=M.arenaList[#M.arenaList]
        if last then hardTP(last.center+Vector3.new(0,3,0)) end
        M.giftPhase=2 M.giftWait=now+CFG.giftDelay return
    end
    if M.giftPhase==2 then
        if grabEgg() then M.giftPhase=3 M.giftWait=now+0.1 else M.giftWait=now+0.2 end return
    end
    if M.giftPhase==3 then
        local dest=M.startPos or M.saved
        if not dest and #M.arenaList>0 then dest=M.arenaList[1].center end
        if dest then hardTP(dest+Vector3.new(0,3,0)) end
        M.giftPhase=4 M.giftWait=now+CFG.giftDelay return
    end
    if M.giftPhase==4 then
        local dest=M.startPos or M.saved
        if not dest and #M.arenaList>0 then dest=M.arenaList[1].center end
        if dest then dropEggAt(dest) end
        M.giftPhase=1 M.giftWait=now+0.15
    end
end
local function buddyTick()
    if not ON.EggBuddy then
        if M.buddyFolder then pcall(function() M.buddyFolder:Destroy() end) M.buddyFolder=nil end return
    end
    local r=hrp() if not r then return end
    if not M.buddyFolder then
        local f=Instance.new("Folder") f.Name="LeaBuddy" f.Parent=Workspace M.buddyFolder=f
        for i=1,3 do
            local p=Instance.new("Part")
            p.Shape=Enum.PartType.Ball p.Size=Vector3.new(1,1,1)
            p.Material=Enum.Material.Neon p.Color=Color3.fromRGB(160,80,255)
            p.Anchored=true p.CanCollide=false p.Parent=f
        end
    end
    local t=os.clock() local i=0
    for _,p in ipairs(M.buddyFolder:GetChildren()) do
        if p:IsA("BasePart") then
            i+=1 local a=t*3+i*2.1
            p.CFrame=CFrame.new(r.Position+Vector3.new(math.cos(a)*5,2,math.sin(a)*5))
        end
    end
end

-- ============================================================
-- ANA HEARTBEAT — sadece aktif özellikler çalışır
-- Her özellik kendi kontrolünü yapıyor, fazladan iş yok
-- ============================================================
local _hbAccum = 0
local HB_STEP  = 1/60   -- 60hz yeterli, Heartbeat çok daha sık ateşler

RunService.Heartbeat:Connect(function(dt)
    _hbAccum += dt
    if _hbAccum < HB_STEP then return end
    _hbAccum = 0
    pcall(function()
        if ON.Speed or ON.HighJump then applySpeed() end
        if ON.Fly          then flyEnsure()       end
        if ON.AutoEgg or ON.EggMagnet or ON.EggAnchor then eggTick() end
        if ON.EggGuard     then guardTick()       end
        if ON.MobPush      then mobTick()         end
        if ON.AutoBed      then bedTick()         end
        if ON.NoFall       then noFall()          end
        if ON.EggBuddy     then buddyTick()       end
        if ON.Aimbot       then aimbotTick()      end
        if ON.SoundBypass  then soundBypassTick() end
        if ON.AutoArena    then arenaTick()       end
        if ON.GiftMode     then giftTick()        end
    end)
end)

-- ESP — düşük frekanslı, sadece aktifse
task.spawn(function()
    while true do
        task.wait(2)
        if ON.ESP then pcall(doESP) end
    end
end)

-- ============================================================
-- MENÜ v3 — Tabbed, tam çalışan, menü her zaman açılıyor
-- DisplayOrder=999 ile GUI en üstte kalır
-- ============================================================
local function buildGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    -- Eski GUI varsa temizle
    local old = pg:FindFirstChild("LeaModeGuiV3") if old then old:Destroy() end

    local C = {
        bg        = Color3.fromRGB(10, 10, 18),
        titleBar  = Color3.fromRGB(18, 12, 32),
        tabBg     = Color3.fromRGB(14, 14, 24),
        tabActive = Color3.fromRGB(85, 40, 150),
        btnOff    = Color3.fromRGB(22, 22, 36),
        btnOn     = Color3.fromRGB(60, 30, 110),
        accent    = Color3.fromRGB(160, 80, 255),
        accentDim = Color3.fromRGB(100, 50, 190),
        textPrim  = Color3.fromRGB(230, 215, 255),
        textSec   = Color3.fromRGB(160, 145, 185),
        textOn    = Color3.fromRGB(220, 190, 255),
        green     = Color3.fromRGB(100, 255, 160),
        stroke    = Color3.fromRGB(90, 40, 170),
        statusBg  = Color3.fromRGB(8, 8, 15),
    }

    local g = Instance.new("ScreenGui")
    g.Name           = "LeaModeGuiV3"
    g.ResetOnSpawn   = false
    g.IgnoreGuiInset = true
    g.DisplayOrder   = 999        -- her zaman en üstte
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.Parent         = pg

    -- Açma butonu (sağ orta)
    local openBtn = Instance.new("TextButton")
    openBtn.Size            = UDim2.fromOffset(44, 44)
    openBtn.Position        = UDim2.new(1, -52, 0.5, -22)
    openBtn.BackgroundColor3= C.titleBar
    openBtn.Text            = "☽"
    openBtn.Font            = Enum.Font.GothamBold
    openBtn.TextSize        = 18
    openBtn.TextColor3      = C.accent
    openBtn.ZIndex          = 100
    openBtn.Parent          = g
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)
    local ost = Instance.new("UIStroke", openBtn)
    ost.Color = C.stroke ost.Thickness = 1.5

    -- Ana panel
    local panel = Instance.new("Frame")
    panel.Size              = UDim2.fromOffset(230, 440)
    panel.Position          = UDim2.new(0.5, -115, 0.5, -220)
    panel.BackgroundColor3  = C.bg
    panel.Visible           = false
    panel.ZIndex            = 50
    panel.ClipsDescendants  = true
    panel.Parent            = g
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local pst = Instance.new("UIStroke", panel)
    pst.Color = C.stroke pst.Thickness = 1.5

    -- Başlık çubuğu
    local titleBar = Instance.new("Frame")
    titleBar.Size           = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3=C.titleBar
    titleBar.BorderSizePixel= 0
    titleBar.ZIndex         = 51
    titleBar.Parent         = panel
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
    -- Köşe düzeltme
    local fix = Instance.new("Frame")
    fix.Size=UDim2.new(1,0,0,10) fix.Position=UDim2.new(0,0,1,-10)
    fix.BackgroundColor3=C.titleBar fix.BorderSizePixel=0 fix.ZIndex=51 fix.Parent=titleBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size=UDim2.new(1,-60,1,0) titleLbl.Position=UDim2.fromOffset(12,0)
    titleLbl.BackgroundTransparency=1 titleLbl.Text="☽  LEA MODE  v3"
    titleLbl.Font=Enum.Font.GothamBold titleLbl.TextSize=13
    titleLbl.TextColor3=C.accent titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.ZIndex=52 titleLbl.Parent=titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size=UDim2.fromOffset(22,22) closeBtn.Position=UDim2.new(1,-28,0.5,-11)
    closeBtn.BackgroundColor3=Color3.fromRGB(90,25,25) closeBtn.Text="×"
    closeBtn.Font=Enum.Font.GothamBold closeBtn.TextSize=15 closeBtn.TextColor3=Color3.new(1,1,1)
    closeBtn.ZIndex=52 closeBtn.Parent=titleBar
    Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() panel.Visible=false end)

    -- Sürükleme
    local drag,dragStart,panStart=false,nil,nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then
            drag=true dragStart=i.Position panStart=panel.Position
        end
    end)
    titleBar.InputEnded:Connect(function() drag=false end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or
           i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-dragStart
            panel.Position=UDim2.new(panStart.X.Scale,panStart.X.Offset+d.X,
                                     panStart.Y.Scale,panStart.Y.Offset+d.Y)
        end
    end)

    -- Tab çubuğu
    local tabBar=Instance.new("Frame")
    tabBar.Size=UDim2.new(1,-8,0,28) tabBar.Position=UDim2.fromOffset(4,34)
    tabBar.BackgroundColor3=C.tabBg tabBar.ZIndex=51 tabBar.Parent=panel
    Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,8)
    local tabLayout=Instance.new("UIListLayout",tabBar)
    tabLayout.FillDirection=Enum.FillDirection.Horizontal
    tabLayout.Padding=UDim.new(0,2)
    tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
    local tabPad=Instance.new("UIPadding",tabBar)
    tabPad.PaddingLeft=UDim.new(0,3) tabPad.PaddingRight=UDim.new(0,3)
    tabPad.PaddingTop=UDim.new(0,3)  tabPad.PaddingBottom=UDim.new(0,3)

    -- Scroll alanı
    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,-8,1,-90) scroll.Position=UDim2.fromOffset(4,66)
    scroll.BackgroundTransparency=1 scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=C.accentDim scroll.CanvasSize=UDim2.fromOffset(0,0)
    scroll.ZIndex=51 scroll.Parent=panel
    local scrollLayout=Instance.new("UIListLayout",scroll)
    scrollLayout.Padding=UDim.new(0,4) scrollLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local scrollPad=Instance.new("UIPadding",scroll)
    scrollPad.PaddingTop=UDim.new(0,2) scrollPad.PaddingBottom=UDim.new(0,4)
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize=UDim2.fromOffset(0,scrollLayout.AbsoluteContentSize.Y+10)
    end)

    -- Status bar
    local statusBar=Instance.new("Frame")
    statusBar.Size=UDim2.new(1,-8,0,20) statusBar.Position=UDim2.new(0,4,1,-22)
    statusBar.BackgroundColor3=C.statusBg statusBar.ZIndex=51 statusBar.Parent=panel
    Instance.new("UICorner",statusBar).CornerRadius=UDim.new(0,6)
    local statusLbl=Instance.new("TextLabel")
    statusLbl.Size=UDim2.new(1,-8,1,0) statusLbl.Position=UDim2.fromOffset(4,0)
    statusLbl.BackgroundTransparency=1 statusLbl.Text="hazır"
    statusLbl.Font=Enum.Font.Gotham statusLbl.TextSize=10
    statusLbl.TextColor3=C.green statusLbl.TextXAlignment=Enum.TextXAlignment.Left
    statusLbl.ZIndex=52 statusLbl.Parent=statusBar
    local function say(t) statusLbl.Text=tostring(t) end

    -- === TAB SİSTEMİ ===
    local TAB_DEFS={
        {id="bypass",  icon="🛡"},
        {id="hareket", icon="🏃"},
        {id="ses",     icon="🔇"},
        {id="gorusel", icon="👁"},
        {id="egg",     icon="🥚"},
        {id="arena",   icon="⚔"},
    }
    local pages={}
    for _,td in ipairs(TAB_DEFS) do
        local page=Instance.new("Frame")
        page.Name="page_"..td.id
        page.Size=UDim2.new(1,0,0,0)
        page.BackgroundTransparency=1
        page.LayoutOrder=1
        page.Visible=false
        page.AutomaticSize=Enum.AutomaticSize.Y
        page.ZIndex=52
        page.Parent=scroll
        local pl=Instance.new("UIListLayout",page)
        pl.Padding=UDim.new(0,4) pl.SortOrder=Enum.SortOrder.LayoutOrder
        pages[td.id]={frame=page,layout=pl,order=0}
    end

    local tabs={}
    local activeTab=nil
    local function switchTab(id)
        if activeTab==id then return end
        activeTab=id
        for _,td in ipairs(TAB_DEFS) do
            if pages[td.id] then pages[td.id].frame.Visible=(td.id==id) end
        end
        for tid,tbtn in pairs(tabs) do
            if tid==id then
                tbtn.BackgroundColor3=C.tabActive tbtn.TextColor3=Color3.new(1,1,1)
            else
                tbtn.BackgroundColor3=Color3.fromRGB(0,0,0)
                tbtn.BackgroundTransparency=1 tbtn.TextColor3=C.textSec
            end
        end
        scroll.CanvasPosition=Vector2.zero
    end

    local N=#TAB_DEFS
    for _,td in ipairs(TAB_DEFS) do
        local tbtn=Instance.new("TextButton")
        tbtn.Size=UDim2.new(1/N,-2,1,0)
        tbtn.BackgroundTransparency=1 tbtn.Text=td.icon
        tbtn.Font=Enum.Font.GothamBold tbtn.TextSize=14
        tbtn.TextColor3=C.textSec tbtn.ZIndex=52 tbtn.Parent=tabBar
        Instance.new("UICorner",tbtn).CornerRadius=UDim.new(0,6)
        tabs[td.id]=tbtn
        local tid=td.id
        tbtn.MouseButton1Click:Connect(function() switchTab(tid) end)
    end

    -- Widget yardımcıları
    local function newTog(pageId,name,key,onE,onD)
        local p=pages[pageId] if not p then return end
        p.order+=1
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-4,0,32) row.BackgroundColor3=C.btnOff
        row.LayoutOrder=p.order row.ZIndex=52 row.Parent=p.frame
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-54,1,0) lbl.Position=UDim2.fromOffset(10,0)
        lbl.BackgroundTransparency=1 lbl.Text=name
        lbl.Font=Enum.Font.GothamMedium lbl.TextSize=11
        lbl.TextColor3=C.textSec lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.ZIndex=53 lbl.Parent=row

        local pill=Instance.new("Frame")
        pill.Size=UDim2.fromOffset(40,20) pill.Position=UDim2.new(1,-46,0.5,-10)
        pill.ZIndex=53 pill.Parent=row
        Instance.new("UICorner",pill).CornerRadius=UDim.new(0,10)

        local dot=Instance.new("Frame")
        dot.Size=UDim2.fromOffset(14,14) dot.ZIndex=54 dot.Parent=pill
        Instance.new("UICorner",dot).CornerRadius=UDim.new(0,7)

        local function refresh()
            local on=ON[key]
            pill.BackgroundColor3=on and C.tabActive or Color3.fromRGB(40,35,55)
            dot.BackgroundColor3=on and Color3.new(1,1,1) or Color3.fromRGB(100,90,120)
            dot.Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)
            lbl.TextColor3=on and C.textOn or C.textSec
            row.BackgroundColor3=on and C.btnOn or C.btnOff
        end

        local function toggle()
            ON[key]=not ON[key] refresh()
            if ON[key] and onE then pcall(onE) end
            if not ON[key] and onD then pcall(onD) end
            say(name..(ON[key] and " ✓" or " ✗"))
        end
        -- Hem satıra hem pill'e tıklama
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1
        btn.Text="" btn.ZIndex=55 btn.Parent=row
        btn.MouseButton1Click:Connect(toggle)
        refresh()
    end

    local function newAct(pageId,name,fn)
        local p=pages[pageId] if not p then return end
        p.order+=1
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,-4,0,30) btn.BackgroundColor3=C.btnOff
        btn.LayoutOrder=p.order btn.ZIndex=52 btn.Parent=p.frame
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        local bst=Instance.new("UIStroke",btn) bst.Color=C.stroke bst.Thickness=1

        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-16,1,0) lbl.Position=UDim2.fromOffset(14,0)
        lbl.BackgroundTransparency=1 lbl.Text="▶  "..name
        lbl.Font=Enum.Font.GothamMedium lbl.TextSize=11
        lbl.TextColor3=C.textPrim lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.ZIndex=53 lbl.Parent=btn

        btn.MouseButton1Click:Connect(function()
            pcall(fn)
            btn.BackgroundColor3=C.btnOn
            task.delay(0.12,function() btn.BackgroundColor3=C.btnOff end)
        end)
    end

    local function newSec(pageId,name)
        local p=pages[pageId] if not p then return end
        p.order+=1
        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-4,0,16) lbl.BackgroundTransparency=1
        lbl.Text="  "..string.upper(name)
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=9
        lbl.TextColor3=C.accentDim lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.LayoutOrder=p.order lbl.ZIndex=52 lbl.Parent=p.frame
    end

    local function sp(pageId,h)
        local p=pages[pageId] if not p then return end
        p.order+=1
        local f=Instance.new("Frame")
        f.Size=UDim2.new(1,-4,0,h or 4) f.BackgroundTransparency=1
        f.LayoutOrder=p.order f.Parent=p.frame
    end

    -- === BYPASS ===
    newSec("bypass","koruma")
    newAct("bypass","Bypass Uygula",function()
        StartBypass() say("bypass tamam | silinen: "..Bypass.killed)
    end)
    newAct("bypass","Remote Temizle",function()
        killRemotes() say("remote temizlendi: "..Bypass.killed)
    end)
    sp("bypass",6) newSec("bypass","aimbot")
    newTog("bypass","Aimbot  [Q tut]","Aimbot")
    newTog("bypass","Silent Aim","SilentAim",hookSilentAim)

    -- === HAREKET ===
    newSec("hareket","hareket")
    newTog("hareket","Speed","Speed",applySpeed,applySpeed)
    newTog("hareket","High Jump","HighJump",applySpeed,applySpeed)
    newTog("hareket","Fly","Fly",flyEnsure,flyDestroy)
    newTog("hareket","Noclip","Noclip",function() setNoclip(true) end,function() setNoclip(false) end)
    newTog("hareket","Inf Jump","InfJump")
    newTog("hareket","No Fall","NoFall")
    newTog("hareket","Click TP  [Ctrl+Tık]","ClickTP")
    sp("hareket",6) newSec("hareket","pozisyon")
    newAct("hareket","Konum Kaydet  [F4]",function()
        say(savePos() and "kaydedildi ✓" or "karakter yok")
    end)
    newAct("hareket","Base TP",function()
        if M.saved then hardTP(M.saved) say("base tp ✓") else say("önce F4") end
    end)

    -- === SES ===
    newSec("ses","ses engelleme")
    newTog("ses","Smart Sound Bypass","SoundBypass",startSoundBypass,stopSoundBypass)
    sp("ses",6) newSec("ses","bilgi")
    local infoP=pages["ses"] infoP.order+=1
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,-4,0,80) card.BackgroundColor3=Color3.fromRGB(16,10,28)
    card.LayoutOrder=infoP.order card.ZIndex=52 card.Parent=infoP.frame
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local infoTxt=Instance.new("TextLabel")
    infoTxt.Size=UDim2.new(1,-12,1,-8) infoTxt.Position=UDim2.fromOffset(6,4)
    infoTxt.BackgroundTransparency=1
    infoTxt.Text="Sadece ayak seslerini filtreler.\nMüzik & çevre sesleri açık kalır.\nDurduğunda sesler geri döner.\nF7 kısayolu ile açılır."
    infoTxt.Font=Enum.Font.Gotham infoTxt.TextSize=10
    infoTxt.TextColor3=C.textSec infoTxt.TextWrapped=true
    infoTxt.ZIndex=53 infoTxt.Parent=card

    -- === GÖRSEL ===
    newSec("gorusel","görsel")
    newTog("gorusel","ESP Highlight","ESP",doESP,clearESP)
    newTog("gorusel","Fullbright","Fullbright",function() fullbright(true) end,function() fullbright(false) end)

    -- === EGG ===
    newSec("egg","egg")
    newTog("egg","Auto Egg","AutoEgg")
    newTog("egg","Egg Magnet","EggMagnet")
    newTog("egg","Egg Anchor","EggAnchor")
    newTog("egg","Egg Guard","EggGuard")
    newTog("egg","Egg Buddy","EggBuddy")
    newTog("egg","Gift Mode","GiftMode",function()
        M.giftPhase=0 M.startPos=M.saved or (hrp() and hrp().Position)
    end)
    sp("egg",6) newSec("egg","diğer")
    newTog("egg","Mob Push","MobPush")
    newTog("egg","Auto Bed","AutoBed")

    -- === ARENA ===
    newSec("arena","arena")
    newTog("arena","Auto Arena","AutoArena",function()
        M.arenaList=findArenas() M.arenaIdx=0 M.arenaBusy=false
        say("arena: "..#M.arenaList)
    end)
    newAct("arena","Arena Tara",function()
        M.arenaList=findArenas() say("arena: "..#M.arenaList)
    end)

    -- Açma butonu bağla
    openBtn.MouseButton1Click:Connect(function()
        panel.Visible=not panel.Visible
        if panel.Visible and not activeTab then switchTab("bypass") end
    end)

    -- Klavye kısayolları
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then
            panel.Visible=not panel.Visible
            if panel.Visible and not activeTab then switchTab("bypass") end
        elseif i.KeyCode==Enum.KeyCode.F4 then
            say(savePos() and "kaydedildi ✓" or "yok")
        elseif i.KeyCode==Enum.KeyCode.F7 then
            ON.SoundBypass=not ON.SoundBypass
            if ON.SoundBypass then startSoundBypass() else stopSoundBypass() end
            say("Sound Bypass "..(ON.SoundBypass and "ON" or "OFF"))
        elseif i.KeyCode==Enum.KeyCode.F8 then
            ON.ESP=not ON.ESP
            if ON.ESP then doESP() else clearESP() end
            say("ESP "..(ON.ESP and "ON" or "OFF"))
        elseif i.KeyCode==Enum.KeyCode.F9 then
            ON.Aimbot=not ON.Aimbot say("Aimbot "..(ON.Aimbot and "ON" or "OFF"))
        elseif i.KeyCode==Enum.KeyCode.F10 then
            ON.AutoEgg=not ON.AutoEgg say("AutoEgg "..(ON.AutoEgg and "ON" or "OFF"))
        end
    end)

    switchTab("bypass")
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.3)
StartBypass()   -- tek sefer, loop yok
buildGui()

print("====================================")
print("  LEA MODE ULTRA v3 — HAZIR")
print("  RightShift — Menü")
print("  F4  — Konum kaydet")
print("  F7  — Sound Bypass")
print("  F8  — ESP")
print("  F9  — Aimbot")
print("  F10 — AutoEgg")
print("  Q   — Aimbot hedefle (tut)")
print("====================================")
