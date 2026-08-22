-- ============================================================
-- PART 1: 10 KATMAN ANTI-KICK + ULTRA BYPASS (400+ SATIR)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ==================== 10 KATMAN ANTI-KICK ====================
local AntiKickLayers = {
    Active = false,
    LayerCount = 10,
    BlockCount = 0,
    Layers = {}
}

-- Katman 1: Remote Destroyer
local function Layer1_RemoteDestroyer()
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            for _, obj in ipairs(network:GetDescendants()) do
                if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                    local name = string.lower(obj.Name)
                    local killList = {
                        "kick", "ban", "integrity", "violation", "correction",
                        "detect", "clientcharacter", "antitamper", "exploit",
                        "reset", "sync", "admin", "moderation", "denetim",
                        "guard", "forest", "speedhit", "wakeup", "unequip",
                        "runtimeowner", "ping", "heartbeat", "validation"
                    }
                    for _, kw in ipairs(killList) do
                        if string.find(name, kw) then
                            pcall(function() obj:Destroy() end)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- Katman 2: LocalPlayer Koruyucu
local function Layer2_LocalPlayerProtect()
    pcall(function()
        if not LocalPlayer:IsDescendantOf(Players) then
            LocalPlayer.Parent = Players
            AntiKickLayers.BlockCount = AntiKickLayers.BlockCount + 1
        end
    end)
end

-- Katman 3: GUI Temizleyici
local function Layer3_GUICleaner()
    pcall(function()
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if gui then
            for _, c in pairs(gui:GetChildren()) do
                local n = string.lower(c.Name)
                if string.find(n, "kick") or string.find(n, "ban") or
                   string.find(n, "error") or string.find(n, "integrity") or
                   string.find(n, "violation") or string.find(n, "denetim") or
                   string.find(n, "moderation") or string.find(n, "warning") or
                   string.find(n, "detection") or string.find(n, "exploit") then
                    c:Destroy()
                end
            end
        end
    end)
end

-- Katman 4: Character Koruyucu
local function Layer4_CharacterProtect()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.BreakJointsOnDeath = false
                if hum.Health <= 0 then
                    hum.Health = hum.MaxHealth
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                if hum.Health < 10 then
                    hum.Health = hum.MaxHealth
                end
            end
        end
    end)
end

-- Katman 5: Workspace Temizleyici
local function Layer5_WorkspaceCleaner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local name = string.lower(obj.Name)
                if string.find(name, "detect") or string.find(name, "scan") or
                   string.find(name, "check") or string.find(name, "verify") or
                   string.find(name, "integrity") or string.find(name, "violation") or
                   string.find(name, "antitamper") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- Katman 6: ReplicatedStorage Koruyucu
local function Layer6_StorageProtect()
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if string.find(name, "kick") or string.find(name, "ban") or
                   string.find(name, "integrity") or string.find(name, "violation") or
                   string.find(name, "correction") or string.find(name, "detect") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- Katman 7: Lighting Temizleyici
local function Layer7_LightingCleaner()
    pcall(function()
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    end)
end

-- Katman 8: Sound Temizleyici
local function Layer8_SoundCleaner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Sound") or obj:IsA("SoundGroup") then
                pcall(function() obj:Stop() end)
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

-- Katman 9: Model Temizleyici
local function Layer9_ModelCleaner()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local name = string.lower(obj.Name)
                if string.find(name, "guard") or string.find(name, "boss") or
                   string.find(name, "enemy") or string.find(name, "monster") or
                   string.find(name, "creature") or string.find(name, "detect") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

-- Katman 10: CFrame Koruyucu (son savunma)
local function Layer10_CFrameProtect()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if root.Position.Y < -100 then
                    root.CFrame = CFrame.new(0, 100, 0)
                end
            end
        end
    end)
end

-- ==================== 10 KATMAN ANTI-KICK BAŞLAT ====================
local function Start10LayerAntiKick()
    if AntiKickLayers.Active then return end
    AntiKickLayers.Active = true
    
    print("========================================")
    print("🛡️ 10 KATMAN ANTI-KICK AKTİF!")
    print("   Katman 1: Remote Destroyer")
    print("   Katman 2: LocalPlayer Koruyucu")
    print("   Katman 3: GUI Temizleyici")
    print("   Katman 4: Character Koruyucu")
    print("   Katman 5: Workspace Temizleyici")
    print("   Katman 6: Storage Koruyucu")
    print("   Katman 7: Lighting Temizleyici")
    print("   Katman 8: Sound Temizleyici")
    print("   Katman 9: Model Temizleyici")
    print("   Katman 10: CFrame Koruyucu")
    print("========================================")
    
    -- Tüm katmanları sürekli çalıştır
    task.spawn(function()
        while AntiKickLayers.Active do
            -- Katman 1-10 sırayla çalıştır (çok hızlı)
            pcall(Layer1_RemoteDestroyer)
            pcall(Layer2_LocalPlayerProtect)
            pcall(Layer3_GUICleaner)
            pcall(Layer4_CharacterProtect)
            pcall(Layer5_WorkspaceCleaner)
            pcall(Layer6_StorageProtect)
            pcall(Layer7_LightingCleaner)
            pcall(Layer8_SoundCleaner)
            pcall(Layer9_ModelCleaner)
            pcall(Layer10_CFrameProtect)
            task.wait(0.01)
        end
    end)
    
    -- 5 katman daha hızlı (paralel)
    task.spawn(function()
        while AntiKickLayers.Active do
            pcall(Layer1_RemoteDestroyer)
            pcall(Layer2_LocalPlayerProtect)
            pcall(Layer3_GUICleaner)
            pcall(Layer4_CharacterProtect)
            pcall(Layer5_WorkspaceCleaner)
            task.wait(0.005)
        end
    end)
    
    task.spawn(function()
        while AntiKickLayers.Active do
            pcall(Layer6_StorageProtect)
            pcall(Layer7_LightingCleaner)
            pcall(Layer8_SoundCleaner)
            pcall(Layer9_ModelCleaner)
            pcall(Layer10_CFrameProtect)
            task.wait(0.005)
        end
    end)
end

local function Stop10LayerAntiKick()
    AntiKickLayers.Active = false
    print("🛡️ 10 KATMAN ANTI-KICK PASİF!")
end

-- ==================== ULTRA BYPASS ====================
local UltraBypass = {
    Active = false
}

local function StartUltraBypass()
    if UltraBypass.Active then return end
    UltraBypass.Active = true
    
    print("🚀 ULTRA BYPASS AKTİF!")
    
    task.spawn(function()
        while UltraBypass.Active do
            pcall(function()
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network then
                    for _, obj in ipairs(network:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local name = string.lower(obj.Name)
                            local bypassList = {
                                "integrity", "violation", "correction", "detect",
                                "kick", "ban", "admin", "antitamper", "exploit",
                                "clientcharacter", "analytics", "reset", "sync",
                                "guard", "forest", "speedhit", "wakeup",
                                "ping", "heartbeat", "validation", "verification"
                            }
                            for _, kw in ipairs(bypassList) do
                                if string.find(name, kw) then
                                    pcall(function() obj:Destroy() end)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.01)
        end
    end)
end

local function StopUltraBypass()
    UltraBypass.Active = false
    print("🚀 ULTRA BYPASS PASİF!")
end

-- ==================== BAŞLAT ====================
task.wait(0.5)
Start10LayerAntiKick()
StartUltraBypass()

print("")
print("========================================")
print("🛡️ 10 KATMAN ANTI-KICK + ULTRA BYPASS")
print("========================================")
print("✅ 10 katman anti-kick aktif")
print("✅ Ultra bypass aktif")
print("✅ Tüm detection sistemleri devre dışı")
print("========================================")-- ============================================================
-- PART 2: ANA MODLAR + KONTROLLER
-- ============================================================

local CFG = {
    flySpeed = 70,
    walkBoost = 48,
    jumpBoost = 80,
    eggRange = 120,
    guardRange = 16,
    arenaDelay = 0.35,
    arenaName = "arena",
    giftDelay = 0.25,
}

local ON = {}
for _, k in ipairs({
    "AutoEgg","Speed","Fly","MobPush","AutoBed","Noclip","InfJump","ClickTP",
    "ESP","Fullbright","HighJump","NoFall","EggGuard","EggMagnet","EggAnchor",
    "EggBuddy","AutoArena","GiftMode","SmoothTP"
}) do ON[k] = false end

local M = {
    saved = nil, startPos = nil,
    flyBV = nil, flyBG = nil, flyAtt = nil, flyConn = nil,
    noclipConn = nil, espFolder = nil, buddyFolder = nil,
    arenaList = {}, arenaIdx = 0, arenaBusy = false,
    giftPhase = 0, giftWait = 0,
    lit = {},
}

local EGG = {"egg","goldenegg","petegg","eggmodel"}
local BED = {"bed","bad"}

local function char() return LocalPlayer.Character end
local function hrp() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hit(o, list)
    local n = string.lower(o.Name)
    for _,k in ipairs(list) do if string.find(n,k,1,true) then return true end end
    return false
end

local function hardTP(pos)
    local r = hrp()
    if not r or not pos then return end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end

local function savePos()
    local r = hrp()
    if r then M.saved = r.Position return true end
    return false
end

local function applySpeed()
    local h = hum()
    if not h then return end
    h.WalkSpeed = ON.Speed and CFG.walkBoost or 16
    if ON.HighJump then
        h.JumpPower = CFG.jumpBoost
        pcall(function() h.JumpHeight = 18 end)
    else
        h.JumpPower = 50
        pcall(function() h.JumpHeight = 7.2 end)
    end
end

local function flyDestroy()
    if M.flyConn then M.flyConn:Disconnect() M.flyConn = nil end
    if M.flyBV then pcall(function() M.flyBV:Destroy() end) M.flyBV = nil end
    if M.flyBG then pcall(function() M.flyBG:Destroy() end) M.flyBG = nil end
    if M.flyAtt then pcall(function() M.flyAtt:Destroy() end) M.flyAtt = nil end
    local h = hum()
    if h and not ON.Fly then h.PlatformStand = false end
end

local function flyEnsure()
    if not ON.Fly then flyDestroy() return end
    local r, h = hrp(), hum()
    if not r or not h then return end
    h.PlatformStand = true
    if not M.flyAtt or M.flyAtt.Parent ~= r then
        flyDestroy()
        local att = Instance.new("Attachment")
        att.Name = "LeaFlyAtt"
        att.Parent = r
        M.flyAtt = att
        local lv = Instance.new("LinearVelocity")
        lv.Name = "LeaFlyLV"
        lv.Attachment0 = att
        lv.MaxForce = 1e7
        lv.VectorVelocity = Vector3.zero
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.Parent = r
        M.flyBV = lv
        local ao = Instance.new("AlignOrientation")
        ao.Name = "LeaFlyAO"
        ao.Attachment0 = att
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.MaxTorque = 1e7
        ao.Responsiveness = 50
        ao.Parent = r
        M.flyBG = ao
    end
    if not M.flyConn then
        M.flyConn = RunService.Heartbeat:Connect(function()
            if not ON.Fly then return end
            local rr = hrp()
            if not rr then return end
            if not M.flyBV or M.flyBV.Parent ~= rr then
                flyDestroy()
                flyEnsure()
                return
            end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local v = Vector3.zero
            local f, rt = cam.CFrame.LookVector, cam.CFrame.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then v += f end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then v -= f end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then v -= rt end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then v += rt end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v -= Vector3.yAxis end
            if UserInputService.TouchEnabled and v.Magnitude < 0.05 then v = f end
            M.flyBV.VectorVelocity = v.Magnitude > 0 and v.Unit * CFG.flySpeed or Vector3.zero
            if M.flyBG then M.flyBG.CFrame = cam.CFrame end
            local hh = hum()
            if hh then hh.PlatformStand = true end
        end)
    end
end

local function grabEgg()
    local r = hrp()
    if not r then return false end
    local range = ON.EggMagnet and CFG.eggRange or 80
    local best, bestD = nil, range
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and hit(obj, EGG) then
            local d = (obj.Position - r.Position).Magnitude
            if d < bestD then bestD, best = d, obj end
        end
    end
    if not best then return false end
    best.Anchored = false
    best.CanCollide = false
    best.CFrame = r.CFrame * CFrame.new(0, 2.5, 0)
    best.AssemblyLinearVelocity = Vector3.zero
    if ON.EggAnchor or ON.AutoEgg or ON.GiftMode then
        if not best:FindFirstChild("LeaWeld") then
            local w = Instance.new("WeldConstraint")
            w.Name = "LeaWeld"
            w.Part0 = r
            w.Part1 = best
            w.Parent = best
        end
    end
    return true
end

local function dropEggAt(pos)
    local r = hrp()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and hit(obj, EGG) then
            local w = obj:FindFirstChild("LeaWeld")
            if w then w:Destroy() end
            if r and (obj.Position - r.Position).Magnitude < 15 then
                obj.Anchored = true
                obj.CanCollide = true
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
                        o.AssemblyLinearVelocity = away.Unit * 90 + Vector3.new(0, 40, 0)
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
                if d > 0.4 and d <= 14 then
                    local away = r.Position - mr.Position
                    if away.Magnitude > 0 then
                        r.AssemblyLinearVelocity = away.Unit * 75 + Vector3.new(0, 35, 0)
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
        if t:IsA("Tool") and hit(t, BED) then has = true break end
    end
    if not has then return end
    local r = hrp()
    if not r then return end
    local best, bd = nil, 18
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local o = plr.Character:FindFirstChild("HumanoidRootPart")
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

local Mouse = LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if not ON.ClickTP then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService.TouchEnabled then
        if Mouse.Hit then hardTP(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

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
    local f = Instance.new("Folder")
    f.Name = "LeaESP"
    f.Parent = Workspace
    M.espFolder = f
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = Instance.new("Highlight")
            hl.Name = "LeaHL"
            hl.FillColor = Color3.fromRGB(170, 80, 255)
            hl.OutlineColor = Color3.new(1,1,1)
            hl.FillTransparency = 0.55
            hl.Parent = plr.Character
        end
    end
end

local function fullbright(on)
    if on then
        M.lit.b, M.lit.c, M.lit.f = Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        if M.lit.b then Lighting.Brightness = M.lit.b end
        if M.lit.c then Lighting.ClockTime = M.lit.c end
        if M.lit.f then Lighting.FogEnd = M.lit.f end
        Lighting.GlobalShadows = true
        M.lit = {}
    end
end

local function noFall()
    if not ON.NoFall then return end
    local h = hum()
    if h and h:GetState() == Enum.HumanoidStateType.Freefall then
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end-- ============================================================
-- PART 3: ARENA + GİFT + SÜRÜKLENEBİLİR MENÜ + ANA LOOP
-- ============================================================

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
    table.sort(list, function(a,b)
        local na, nb = tonumber(string.match(a.name,"%d+")), tonumber(string.match(b.name,"%d+"))
        if na and nb then return na < nb end
        return a.name < b.name
    end)
    return list
end

local function arenaTick()
    if not ON.AutoArena or M.arenaBusy then return end
    if #M.arenaList == 0 then
        M.arenaList = findArenas()
        M.arenaIdx = 0
        if #M.arenaList == 0 then return end
    end
    M.arenaBusy = true
    M.arenaIdx += 1
    if M.arenaIdx > #M.arenaList then
        M.arenaList = findArenas()
        M.arenaIdx = 1
    end
    local a = M.arenaList[M.arenaIdx]
    if a then hardTP(a.center + Vector3.new(0, 3, 0)) end
    task.delay(CFG.arenaDelay, function() M.arenaBusy = false end)
end

local function giftTick()
    if not ON.GiftMode then M.giftPhase = 0 return end
    local now = os.clock()
    if now < M.giftWait then return end

    if M.giftPhase == 0 then
        M.startPos = M.saved or (hrp() and hrp().Position)
        M.arenaList = findArenas()
        if #M.arenaList == 0 then M.giftWait = now + 1 return end
        M.giftPhase = 1
        M.giftWait = now + 0.05
        return
    end
    if M.giftPhase == 1 then
        local last = M.arenaList[#M.arenaList]
        if last then hardTP(last.center + Vector3.new(0, 3, 0)) end
        M.giftPhase = 2
        M.giftWait = now + CFG.giftDelay
        return
    end
    if M.giftPhase == 2 then
        if grabEgg() then
            M.giftPhase = 3
            M.giftWait = now + 0.1
        else
            M.giftWait = now + 0.2
        end
        return
    end
    if M.giftPhase == 3 then
        local dest = M.startPos or M.saved
        if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
        if dest then hardTP(dest + Vector3.new(0, 3, 0)) end
        M.giftPhase = 4
        M.giftWait = now + CFG.giftDelay
        return
    end
    if M.giftPhase == 4 then
        local dest = M.startPos or M.saved
        if not dest and #M.arenaList > 0 then dest = M.arenaList[1].center end
        if dest then dropEggAt(dest) end
        M.giftPhase = 1
        M.giftWait = now + 0.15
    end
end

local function buddyTick()
    if not ON.EggBuddy then
        if M.buddyFolder then pcall(function() M.buddyFolder:Destroy() end) M.buddyFolder = nil end
        return
    end
    local r = hrp()
    if not r then return end
    if not M.buddyFolder then
        local f = Instance.new("Folder")
        f.Name = "LeaBuddy"
        f.Parent = Workspace
        M.buddyFolder = f
        for i = 1, 3 do
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(1,1,1)
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(160, 80, 255)
            p.Anchored = true
            p.CanCollide = false
            p.Parent = f
        end
    end
    local t = os.clock()
    local i = 0
    for _, p in ipairs(M.buddyFolder:GetChildren()) do
        if p:IsA("BasePart") then
            i += 1
            local a = t * 3 + i * 2.1
            p.CFrame = CFrame.new(r.Position + Vector3.new(math.cos(a)*5, 2, math.sin(a)*5))
        end
    end
end

-- ==================== ANA LOOP ====================
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
end)

-- ==================== SÜRÜKLENEBİLİR MENÜ ====================
local function buildGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaModeGui")
    if old then old:Destroy() end

    local g = Instance.new("ScreenGui")
    g.Name = "LeaModeGui"
    g.ResetOnSpawn = false
    g.Parent = pg

    local open = Instance.new("TextButton")
    open.Size = UDim2.fromOffset(44, 44)
    open.Position = UDim2.new(1, -52, 0.35, 0)
    open.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
    open.TextColor3 = Color3.fromRGB(200, 140, 255)
    open.Text = "LEA"
    open.Font = Enum.Font.GothamBold
    open.TextSize = 12
    open.Parent = g
    Instance.new("UICorner", open).CornerRadius = UDim.new(0, 10)

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(200, 340)
    panel.Position = UDim2.new(1, -212, 0.5, -170)
    panel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    panel.Visible = false
    panel.Parent = g
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", panel)
    st.Color = Color3.fromRGB(130, 70, 220)
    st.Thickness = 1

    -- Sürükleme için başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -8, 0, 22)
    title.Position = UDim2.fromOffset(6, 4)
    title.BackgroundTransparency = 1
    title.Text = "LEA MODE"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(220, 180, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    -- Sürükleme işlevi
    local drag, dragStart, startPos
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = i.Position
            startPos = panel.Position
        end
    end)
    title.InputEnded:Connect(function() drag = false end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -6, 1, -48)
    scroll.Position = UDim2.fromOffset(3, 26)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.Parent = panel
    local lay = Instance.new("UIListLayout", scroll)
    lay.Padding = UDim.new(0, 3)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -8, 0, 16)
    status.Position = UDim2.new(0, 6, 1, -18)
    status.BackgroundTransparency = 1
    status.Text = "ok"
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(140, 255, 170)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = panel
    local function say(t) status.Text = tostring(t) end

    local order = 0
    local function tog(name, key, onE, onD)
        order += 1
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
        b.TextColor3 = Color3.fromRGB(230, 230, 240)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 11
        b.LayoutOrder = order
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local function ref()
            b.Text = name .. (ON[key] and " ON" or " OFF")
            b.BackgroundColor3 = ON[key] and Color3.fromRGB(70, 40, 110) or Color3.fromRGB(30, 30, 44)
        end
        b.MouseButton1Click:Connect(function()
            ON[key] = not ON[key]
            ref()
            if ON[key] and onE then onE() end
            if not ON[key] and onD then onD() end
            say(name .. (ON[key] and " ON" or " OFF"))
        end)
        ref()
    end

    local function act(name, fn)
        order += 1
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(38, 38, 56)
        b.Text = name
        b.TextColor3 = Color3.fromRGB(230, 230, 240)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 11
        b.LayoutOrder = order
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(fn)
    end

    -- MODLAR
    tog("AutoEgg", "AutoEgg")
    tog("Egg Magnet", "EggMagnet")
    tog("Egg Anchor", "EggAnchor")
    tog("Egg Guard", "EggGuard")
    tog("Gift Mode", "GiftMode", function()
        M.giftPhase = 0
        M.startPos = M.saved or (hrp() and hrp().Position)
    end)
    tog("Auto Arena", "AutoArena", function()
        M.arenaList = findArenas()
        M.arenaIdx = 0
        M.arenaBusy = false
        say("arena "..#M.arenaList)
    end)
    tog("Speed", "Speed", applySpeed, applySpeed)
    tog("Fly", "Fly", flyEnsure, flyDestroy)
    tog("MobPush", "MobPush")
    tog("AutoBed", "AutoBed")
    tog("Noclip", "Noclip", function() setNoclip(true) end, function() setNoclip(false) end)
    tog("InfJump", "InfJump")
    tog("HighJump", "HighJump", applySpeed, applySpeed)
    tog("ClickTP", "ClickTP")
    tog("ESP", "ESP", doESP, clearESP)
    tog("Fullbright", "Fullbright", function() fullbright(true) end, function() fullbright(false) end)
    tog("NoFall", "NoFall")

    -- ANTI-KICK KONTROL (10 KATMAN)
    act("🛡️ 10 AK AÇ", function()
        Start10LayerAntiKick()
        say("10 Katman Anti-Kick Aktif")
    end)
    act("🛡️ 10 AK KAPAT", function()
        Stop10LayerAntiKick()
        say("10 Katman Anti-Kick Pasif")
    end)

    -- BYPASS KONTROL
    act("🚀 BYPASS AÇ", function()
        StartUltraBypass()
        say("Ultra Bypass Aktif")
    end)
    act("🚀 BYPASS KAPAT", function()
        StopUltraBypass()
        say("Ultra Bypass Pasif")
    end)

    act("Kaydet (F4)", function() say(savePos() and "kayıt OK" or "yok") end)
    act("Base TP", function()
        if M.saved then hardTP(M.saved) say("base") else say("F4 kaydet") end
    end)
    act("Arena tara", function()
        M.arenaList = findArenas()
        say("arena "..#M.arenaList)
    end)

    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 6)
    end)

    open.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)

    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            panel.Visible = not panel.Visible
        elseif i.KeyCode == Enum.KeyCode.F4 then
            say(savePos() and "kayıt OK" or "yok")
        elseif i.KeyCode == Enum.KeyCode.F10 then
            ON.AutoEgg = not ON.AutoEgg
            say(ON.AutoEgg and "AutoEgg ON" or "OFF")
        end
    end)
end

buildGui()
print("[LEA] 10 KATMAN ANTI-KICK | ULTRA BYPASS | SÜRÜKLENEBİLİR MENÜ")
