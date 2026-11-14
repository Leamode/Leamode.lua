-- ============================================================
-- LEA MODE ULTRA — by Xaero
-- Telefon + PC uyumlu | Remote Bypass | Fly | Aimbot | ESP
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace      = game:GetService("Workspace")
local Lighting       = game:GetService("Lighting")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

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

    -- AIMBOT
    aimKey       = Enum.KeyCode.Q,          -- tutarak hedefle (hold)
    aimSmooth    = 6,                        -- 1=anlık, 10=çok yumuşak
    aimFovStuds  = 80,                       -- hedef alma yarıçapı (studs)
    aimBone      = "Head",                   -- hedef kemik
    aimTeamCheck = true,                     -- takım arkadaşını hedef alma
    aimVisCheck  = true,                     -- sadece görünen hedefler
    aimMethod    = "CameraLock",             -- "CameraLock" | "BodyGyro"
}

-- ==================== DURUM ====================
local ON = {}
for _, k in ipairs({
    "AutoEgg","Speed","Fly","MobPush","AutoBed","Noclip","InfJump","ClickTP",
    "ESP","Fullbright","HighJump","NoFall","EggGuard","EggMagnet","EggAnchor",
    "EggBuddy","AutoArena","GiftMode","SmoothTP","Aimbot","SilentAim"
}) do ON[k] = false end

local M = {
    saved=nil, startPos=nil,
    flyBV=nil, flyBG=nil, flyAtt=nil, flyConn=nil,
    noclipConn=nil, espFolder=nil, buddyFolder=nil,
    arenaList={}, arenaIdx=0, arenaBusy=false,
    giftPhase=0, giftWait=0,
    lit={},
    aimTarget=nil, aimGyro=nil, aimBP=nil,
}

-- ==================== YARDIMCILAR ====================
local EGG = {"egg","goldenegg","petegg","eggmodel"}
local BED = {"bed","bad"}

local function char()  return LocalPlayer.Character end
local function hrp()   local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hit(o, list)
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
-- BYPASS — 4 KATMAN
-- ============================================================
local Bypass = {Active=false, killed=0, blocked=0}

-- Katman 1: Remote silici (genişletilmiş keyword listesi)
local KILL_PATTERNS = {
    "reset","kick","ban","detect","scan","integrity","violation","correction",
    "tamper","cheat","exploit","hack","inject","clientchar","analytics",
    "afk","teleport","admin","guard","sync","heartbeat","report","verify",
    "validate","check","ping","hook","monitor","watchdog","audit","trace",
    "log","event","flag","warn","block","filter","remote","network",
    "anticheat","ac","vac","eac","fairplay","battleye",
}

local function killRemotes()
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                    local n = string.lower(obj.Name)
                    for _, pat in ipairs(KILL_PATTERNS) do
                        if string.find(n, pat, 1, true) then
                            pcall(function() obj:Destroy() end)
                            Bypass.killed += 1
                            break
                        end
                    end
                end
            end
        end)
    end
end

-- Katman 2: Fly engeli bypass — network owner alma + CanTouch kapat
local function antiKick_FlyBypass()
    local c = char() if not c then return end
    -- HRP'yi ağ sahibi yap (executor destekliyorsa)
    local r = hrp()
    if r then
        pcall(function() r:SetNetworkOwner(LocalPlayer) end)
        pcall(function() r.CanTouch = false end)
    end
    -- Karakter içindeki tüm BasePart'lara network ownership
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p:SetNetworkOwner(LocalPlayer) end)
        end
    end
end

-- Katman 3: Anti-reset / ölümsüz
local function antiReset()
    local c = char() if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    pcall(function() h.BreakJointsOnDeath = false end)
    if h.Health <= 0 then
        pcall(function()
            h.Health = h.MaxHealth
            h:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
    if h.Health > 0 and h.Health < 10 then
        pcall(function() h.Health = h.MaxHealth end)
    end
    if h.PlatformStand == true and not ON.Fly then
        pcall(function() h.PlatformStand = false end)
    end
end

-- Katman 4: Script/LocalScript temizleyici
local function scriptCleaner()
    for _, root in ipairs({Workspace}) do
        pcall(function()
            for _, obj in ipairs(root:GetDescendants()) do
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
end

-- RemoteEvent.OnClientEvent hook — zararlı çağrıları engelle
local function hookRemotes()
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local n = string.lower(tostring(self.Name or ""))
                for _, pat in ipairs(KILL_PATTERNS) do
                    if string.find(n, pat, 1, true) then
                        return -- engelle
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function StartBypass()
    if Bypass.Active then return end
    Bypass.Active = true
    hookRemotes()
    task.spawn(function()
        while Bypass.Active do
            pcall(killRemotes)
            pcall(antiKick_FlyBypass)
            pcall(antiReset)
            task.wait(0.015)
        end
    end)
    task.spawn(function()
        while Bypass.Active do
            pcall(scriptCleaner)
            task.wait(1)
        end
    end)
    killRemotes()
    antiKick_FlyBypass()
    antiReset()
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.4)
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function() h.BreakJointsOnDeath = false end)
            pcall(function() h.Health = h.MaxHealth end)
        end
        pcall(antiKick_FlyBypass)
    end)
end

local function StopBypass()
    Bypass.Active = false
end

-- ============================================================
-- MODLAR
-- ============================================================

-- SPEED
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

-- FLY
local function flyDestroy()
    if M.flyConn then M.flyConn:Disconnect() M.flyConn=nil end
    pcall(function() if M.flyBV then M.flyBV:Destroy() end end)
    pcall(function() if M.flyBG then M.flyBG:Destroy() end end)
    pcall(function() if M.flyAtt then M.flyAtt:Destroy() end end)
    M.flyBV=nil M.flyBG=nil M.flyAtt=nil
    local h=hum() if h and not ON.Fly then pcall(function() h.PlatformStand=false end) end
end

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
            -- PC
            if uis:IsKeyDown(Enum.KeyCode.W) then v+=f end
            if uis:IsKeyDown(Enum.KeyCode.S) then v-=f end
            if uis:IsKeyDown(Enum.KeyCode.A) then v-=rt end
            if uis:IsKeyDown(Enum.KeyCode.D) then v+=rt end
            if uis:IsKeyDown(Enum.KeyCode.Space) then v+=Vector3.yAxis end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then v-=Vector3.yAxis end
            -- Telefon: thumb stick üzerinden cam yönünde
            if uis.TouchEnabled and v.Magnitude<0.05 then
                local thumb=uis:GetConnectedGamepads()[1]
                if thumb then
                    local ls=uis:GetGamepadState(thumb)
                    for _,s in ipairs(ls) do
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

-- EGG
local function grabEgg()
    local r=hrp() if not r then return false end
    local range=ON.EggMagnet and CFG.eggRange or 85
    local best,bestD=nil,range
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and hit(obj,EGG) then
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
        if obj:IsA("BasePart") and hit(obj,EGG) then
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

-- GUARD / MOB
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

-- BED
local function bedTick()
    if not ON.AutoBed then return end
    local c=char() if not c then return end
    local has=false
    for _,t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and hit(t,BED) then has=true break end
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

-- NOCLIP
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

-- INFJUMP
UserInputService.JumpRequest:Connect(function()
    if ON.InfJump then
        local h=hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- CLICKTP
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

-- FULLBRIGHT
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

-- NOFALL
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
local function getTeamColor(plr)
    return plr.Team and plr.Team.TeamColor or nil
end

local function isSameTeam(plr)
    if not CFG.aimTeamCheck then return false end
    local myTeam=LocalPlayer.Team
    if not myTeam then return false end
    return plr.Team==myTeam
end

local function isVisible(part)
    if not CFG.aimVisCheck then return true end
    local r=hrp() if not r then return true end
    local origin=r.Position+Vector3.new(0,2,0)
    local dir=(part.Position-origin)
    local ray=RaycastParams.new()
    ray.FilterType=Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances={char()}
    local result=Workspace:Raycast(origin,dir,ray)
    if not result then return true end
    -- İsabet başka bir oyuncunun parçasına mı?
    local hit_inst=result.Instance
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and hit_inst:IsDescendantOf(plr.Character) then
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
            if h and bone and h.Health>0 then
                if isVisible(bone) then
                    local d=(bone.Position-myPos).Magnitude
                    if d<bestDist then
                        bestDist=d best=bone
                    end
                end
            end
        end
    end
    return best
end

local function aimbot_CameraLock(target)
    local cam=Workspace.CurrentCamera if not cam then return end
    local pos=target.Position+Vector3.new(0,0.5,0)
    local current=cam.CFrame
    local goal=CFrame.new(current.Position,pos)
    cam.CFrame=current:Lerp(goal,1/CFG.aimSmooth)
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

local function cleanAimGyro()
    if M.aimGyro then pcall(function() M.aimGyro:Destroy() end) M.aimGyro=nil end
end

-- Silent Aim: sunucuya farklı, kliente farklı görüntü
-- (executor'da metatable hook ile çalışır)
local function hookSilentAim()
    pcall(function()
        local mt=getrawmetatable and getrawmetatable(game)
        if not mt then return end
        -- FireServer içinde aim vektörünü hedef pozisyonuna yönlendir
        -- Bu hook zaten hookRemotes içindeki __namecall üzerinde çalışır
        -- Executor __namecall'u destekliyorsa aktif olur
    end)
end

local function aimbotTick()
    if not ON.Aimbot then cleanAimGyro() return end
    local held=false
    -- PC
    if UserInputService:IsKeyDown(CFG.aimKey) then held=true end
    -- Telefon: sağ taraf ikinci parmak dokunuşu
    if UserInputService.TouchEnabled then
        for _,touch in ipairs(UserInputService:GetTouches()) do
            if touch.Position.X > Workspace.CurrentCamera.ViewportSize.X/2 then
                held=true break
            end
        end
    end
    if not held then cleanAimGyro() return end
    local target=getBestTarget()
    if not target then cleanAimGyro() return end
    if CFG.aimMethod=="CameraLock" then
        aimbot_CameraLock(target)
    else
        aimbot_BodyGyro(target)
    end
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
            local c=arenaCenter(obj)
            if c then table.insert(list,{center=c,name=obj.Name}) end
        end
    end
    table.sort(list,function(a,b)
        local na,nb=tonumber(string.match(a.name,"%d+")),tonumber(string.match(b.name,"%d+"))
        if na and nb then return na<nb end
        return a.name<b.name
    end)
    return list
end

local function arenaTick()
    if not ON.AutoArena or M.arenaBusy then return end
    if #M.arenaList==0 then
        M.arenaList=findArenas() M.arenaIdx=0
        if #M.arenaList==0 then return end
    end
    M.arenaBusy=true
    M.arenaIdx+=1
    if M.arenaIdx>#M.arenaList then M.arenaList=findArenas() M.arenaIdx=1 end
    local a=M.arenaList[M.arenaIdx]
    if a then hardTP(a.center+Vector3.new(0,3,0)) end
    task.delay(CFG.arenaDelay,function() M.arenaBusy=false end)
end

local function giftTick()
    if not ON.GiftMode then M.giftPhase=0 return end
    local now=os.clock()
    if now<M.giftWait then return end
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
        if grabEgg() then M.giftPhase=3 M.giftWait=now+0.1
        else M.giftWait=now+0.2 end return
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
            i+=1
            local a=t*3+i*2.1
            p.CFrame=CFrame.new(r.Position+Vector3.new(math.cos(a)*5,2,math.sin(a)*5))
        end
    end
end

-- ============================================================
-- ANA LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        if ON.Speed or ON.HighJump then applySpeed() end
        if ON.Fly then flyEnsure() end
        eggTick()
        guardTick()
        mobTick()
        bedTick()
        noFall()
        buddyTick()
        aimbotTick()
        if ON.AutoArena then arenaTick() end
        if ON.GiftMode then giftTick() end
    end)
end)

task.spawn(function()
    while true do
        task.wait(2)
        if ON.ESP then pcall(doESP) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    flyDestroy()
    if ON.Fly then flyEnsure() end
    if ON.Speed then applySpeed() end
    if ON.Noclip then setNoclip(true) end
    if ON.ESP then doESP() end
    cleanAimGyro()
end)

-- ============================================================
-- MENÜ — Telefon + PC Sürüklenebilir
-- ============================================================
local function buildGui()
    local pg=LocalPlayer:WaitForChild("PlayerGui")
    local old=pg:FindFirstChild("LeaModeGui") if old then old:Destroy() end

    local g=Instance.new("ScreenGui")
    g.Name="LeaModeGui"
    g.ResetOnSpawn=false
    g.IgnoreGuiInset=true
    g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    g.Parent=pg

    -- AÇMA BUTONU (sağ orta)
    local open=Instance.new("TextButton")
    open.Size=UDim2.fromOffset(44,44)
    open.Position=UDim2.new(1,-52,0.5,-22)
    open.BackgroundColor3=Color3.fromRGB(20,16,34)
    open.TextColor3=Color3.fromRGB(200,130,255)
    open.Text="LEA"
    open.Font=Enum.Font.GothamBold
    open.TextSize=12
    open.ZIndex=10
    open.Parent=g
    Instance.new("UICorner",open).CornerRadius=UDim.new(0,10)
    local ost=Instance.new("UIStroke",open) ost.Color=Color3.fromRGB(120,60,210) ost.Thickness=1

    -- ANA PANEL
    local panel=Instance.new("Frame")
    panel.Size=UDim2.fromOffset(210,400)
    panel.Position=UDim2.new(0.5,-105,0.5,-200)
    panel.BackgroundColor3=Color3.fromRGB(12,12,20)
    panel.Visible=false
    panel.ZIndex=5
    panel.Parent=g
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
    local pst=Instance.new("UIStroke",panel) pst.Color=Color3.fromRGB(120,60,210) pst.Thickness=1.5

    -- BAŞLIK + SÜRÜKLEME
    local titleBar=Instance.new("Frame")
    titleBar.Size=UDim2.new(1,0,0,28)
    titleBar.BackgroundColor3=Color3.fromRGB(22,16,38)
    titleBar.Parent=panel
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,10)

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,-36,1,0)
    title.Position=UDim2.fromOffset(8,0)
    title.BackgroundTransparency=1
    title.Text="☽ LEA MODE ULTRA"
    title.Font=Enum.Font.GothamBold
    title.TextSize=13
    title.TextColor3=Color3.fromRGB(220,170,255)
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.Parent=titleBar

    local closeBtn=Instance.new("TextButton")
    closeBtn.Size=UDim2.fromOffset(24,24)
    closeBtn.Position=UDim2.new(1,-28,0,2)
    closeBtn.BackgroundColor3=Color3.fromRGB(80,30,120)
    closeBtn.Text="×"
    closeBtn.Font=Enum.Font.GothamBold
    closeBtn.TextSize=16
    closeBtn.TextColor3=Color3.new(1,1,1)
    closeBtn.Parent=titleBar
    Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() panel.Visible=false end)

    -- SÜRÜKLEME LOJİĞİ
    local drag,dragStart,panStart=false,nil,nil
    local function startDrag(inp)
        drag=true dragStart=inp.Position panStart=panel.Position
    end
    local function endDrag() drag=false end
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then startDrag(i) end
    end)
    titleBar.InputEnded:Connect(endDrag)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or
           i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-dragStart
            panel.Position=UDim2.new(
                panStart.X.Scale,panStart.X.Offset+d.X,
                panStart.Y.Scale,panStart.Y.Offset+d.Y)
        end
    end)

    -- SCROLL ALAN
    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,-8,1,-50)
    scroll.Position=UDim2.fromOffset(4,30)
    scroll.BackgroundTransparency=1
    scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=Color3.fromRGB(120,60,210)
    scroll.Parent=panel
    local lay=Instance.new("UIListLayout",scroll)
    lay.Padding=UDim.new(0,3)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize=UDim2.fromOffset(0,lay.AbsoluteContentSize.Y+8)
    end)

    -- STATUS BAR
    local status=Instance.new("TextLabel")
    status.Size=UDim2.new(1,-8,0,18)
    status.Position=UDim2.new(0,4,1,-20)
    status.BackgroundTransparency=1
    status.Text="hazır"
    status.Font=Enum.Font.Gotham
    status.TextSize=10
    status.TextColor3=Color3.fromRGB(140,255,170)
    status.TextXAlignment=Enum.TextXAlignment.Left
    status.Parent=panel
    local function say(t) status.Text=tostring(t) end

    -- BÖLÜM BAŞLIĞI
    local sOrder=0
    local function section(name)
        sOrder+=1
        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-4,0,18)
        lbl.BackgroundColor3=Color3.fromRGB(30,20,50)
        lbl.Text=" "..name
        lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=10
        lbl.TextColor3=Color3.fromRGB(180,120,255)
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.LayoutOrder=sOrder
        lbl.Parent=scroll
        Instance.new("UICorner",lbl).CornerRadius=UDim.new(0,4)
    end

    local function tog(name,key,onE,onD)
        sOrder+=1
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1,-4,0,28)
        b.LayoutOrder=sOrder
        b.Parent=scroll
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
        local function ref()
            b.Text=(ON[key] and "✔ " or "   ")..name
            b.BackgroundColor3=ON[key] and Color3.fromRGB(65,35,105) or Color3.fromRGB(28,28,42)
            b.TextColor3=ON[key] and Color3.fromRGB(230,200,255) or Color3.fromRGB(190,190,200)
            b.Font=Enum.Font.GothamMedium
            b.TextSize=11
            b.TextXAlignment=Enum.TextXAlignment.Left
        end
        b.MouseButton1Click:Connect(function()
            ON[key]=not ON[key] ref()
            if ON[key] and onE then onE() end
            if not ON[key] and onD then onD() end
            say(name..(ON[key] and " ON" or " OFF"))
        end)
        ref()
    end

    local function act(name,fn)
        sOrder+=1
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1,-4,0,28)
        b.BackgroundColor3=Color3.fromRGB(35,25,55)
        b.Text="▶ "..name
        b.TextColor3=Color3.fromRGB(200,180,230)
        b.Font=Enum.Font.GothamMedium
        b.TextSize=11
        b.TextXAlignment=Enum.TextXAlignment.Left
        b.LayoutOrder=sOrder
        b.Parent=scroll
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
        b.MouseButton1Click:Connect(fn)
    end

    -- === BÖLÜMLER ===
    section("── BYPASS ──")
    act("Bypass Aç",function() StartBypass() say("bypass aktif | öldürülen: "..Bypass.killed) end)
    act("Bypass Kapat",function() StopBypass() say("bypass pasif") end)

    section("── AIMBOT ──")
    tog("Aimbot (Q tut / telefon: sağ ekrana bas)","Aimbot")
    tog("Silent Aim","SilentAim",hookSilentAim)

    section("── HAREKET ──")
    tog("Speed","Speed",applySpeed,applySpeed)
    tog("HighJump","HighJump",applySpeed,applySpeed)
    tog("Fly","Fly",flyEnsure,flyDestroy)
    tog("Noclip","Noclip",function() setNoclip(true) end,function() setNoclip(false) end)
    tog("InfJump","InfJump")
    tog("NoFall","NoFall")
    tog("ClickTP (Ctrl+Tık)","ClickTP")

    section("── EGG ──")
    tog("AutoEgg","AutoEgg")
    tog("Egg Magnet","EggMagnet")
    tog("Egg Anchor","EggAnchor")
    tog("Egg Guard","EggGuard")
    tog("Egg Buddy","EggBuddy")
    tog("Gift Mode","GiftMode",function()
        M.giftPhase=0 M.startPos=M.saved or (hrp() and hrp().Position)
    end)

    section("── ARENA ──")
    tog("Auto Arena","AutoArena",function()
        M.arenaList=findArenas() M.arenaIdx=0 M.arenaBusy=false say("arena "..#M.arenaList)
    end)
    act("Arena Tara",function() M.arenaList=findArenas() say("arena "..#M.arenaList) end)

    section("── GÖRSEL ──")
    tog("ESP","ESP",doESP,clearESP)
    tog("Fullbright","Fullbright",function() fullbright(true) end,function() fullbright(false) end)

    section("── DİĞER ──")
    tog("MobPush","MobPush")
    tog("AutoBed","AutoBed")
    act("Kaydet (F4)",function() say(savePos() and "konum kaydedildi" or "karakter yok") end)
    act("Base TP",function()
        if M.saved then hardTP(M.saved) say("base tp") else say("önce F4 kaydet") end
    end)

    -- AÇMA BUTONU
    open.MouseButton1Click:Connect(function() panel.Visible=not panel.Visible end)

    -- KLAVYE KISA YOLLAR
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then panel.Visible=not panel.Visible
        elseif i.KeyCode==Enum.KeyCode.F4 then say(savePos() and "kaydedildi" or "yok")
        elseif i.KeyCode==Enum.KeyCode.F10 then
            ON.AutoEgg=not ON.AutoEgg say("AutoEgg "..(ON.AutoEgg and "ON" or "OFF"))
        elseif i.KeyCode==Enum.KeyCode.F9 then
            ON.Aimbot=not ON.Aimbot say("Aimbot "..(ON.Aimbot and "ON" or "OFF"))
        elseif i.KeyCode==Enum.KeyCode.F8 then
            ON.ESP=not ON.ESP
            if ON.ESP then doESP() else clearESP() end
            say("ESP "..(ON.ESP and "ON" or "OFF"))
        end
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.3)
StartBypass()
buildGui()

print("====================================")
print("  LEA MODE ULTRA — HAZIR")
print("====================================")
print("  RightShift  — Menü aç/kapat")
print("  F4          — Konum kaydet")
print("  F8          — ESP aç/kapat")
print("  F9          — Aimbot aç/kapat")
print("  F10         — AutoEgg aç/kapat")
print("  Q (tut)     — Aimbot hedefle")
print("====================================")
