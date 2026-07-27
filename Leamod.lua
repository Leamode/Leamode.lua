-- ============================================
-- BRAINROT DUEL v5 - SADECE İSTENEN MODLAR
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- DEĞİŞKENLER
-- ============================================
local Data = {
    Fly = false,
    Speed = 35,
    Ghost = false,
    Bad = false,
    Medusa = false,
    Cube = false,
    Target = nil,
    Cubes = {},
    ScreenGui = nil,
    FlyConn = nil,
    GhostConn = nil,
    BadConn = nil,
    MedusaConn = nil,
    CubeConn = nil,
}

-- ============================================
-- KÜÇÜK MOBİL MENÜ (SADECE 5 BUTON)
-- ============================================
local function MenuYap()
    if Data.ScreenGui then Data.ScreenGui:Destroy() end
    
    local plrGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not plrGui then repeat task.wait() plrGui = LocalPlayer:FindFirstChild("PlayerGui") until plrGui end
    
    Data.ScreenGui = Instance.new("ScreenGui")
    Data.ScreenGui.ResetOnSpawn = false
    Data.ScreenGui.Parent = plrGui
    
    -- SADECE 5 MOD: Fly, Ghost, Bad, Medusa, Cube
    local Modlar = {
        {Ad = "Fly", Text = "F", Renk = Color3.fromRGB(60, 140, 255)},
        {Ad = "Ghost", Text = "G", Renk = Color3.fromRGB(255, 60, 60)},
        {Ad = "Bad", Text = "B", Renk = Color3.fromRGB(255, 140, 40)},
        {Ad = "Medusa", Text = "M", Renk = Color3.fromRGB(140, 50, 255)},
        {Ad = "Cube", Text = "C", Renk = Color3.fromRGB(50, 255, 140)},
    }
    
    for i, mod in ipairs(Modlar) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 20, 0, 20) -- Çok küçük buton
        btn.Position = UDim2.new(1, -22, 0, 5 + (i - 1) * 22)
        btn.BackgroundColor3 = mod.Renk
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 0
        btn.Text = mod.Text
        btn.TextSize = 8 -- Küçük yazı
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.ZIndex = 10
        btn.AutoButtonColor = false
        btn.Parent = Data.ScreenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = btn
        
        -- Tıklama olayı
        btn.MouseButton1Click:Connect(function()
            if mod.Ad == "Fly" then
                Data.Fly = not Data.Fly
                btn.BackgroundTransparency = Data.Fly and 0 or 0.4
                if Data.Fly then FlyAc() else FlyKapat() end
            elseif mod.Ad == "Ghost" then
                Data.Ghost = not Data.Ghost
                btn.BackgroundTransparency = Data.Ghost and 0 or 0.4
                if Data.Ghost then GhostAc() else GhostKapat() end
            elseif mod.Ad == "Bad" then
                Data.Bad = not Data.Bad
                btn.BackgroundTransparency = Data.Bad and 0 or 0.4
                if Data.Bad then BadAc() else BadKapat() end
            elseif mod.Ad == "Medusa" then
                Data.Medusa = not Data.Medusa
                btn.BackgroundTransparency = Data.Medusa and 0 or 0.4
                if Data.Medusa then MedusaAc() else MedusaKapat() end
            elseif mod.Ad == "Cube" then
                Data.Cube = not Data.Cube
                btn.BackgroundTransparency = Data.Cube and 0 or 0.4
                if Data.Cube then CubeAc() else CubeKapat() end
            end
        end)
    end
    
    -- Hedef seçme (Mouse sol tık)
    Mouse.Button1Down:Connect(function()
        local t = Mouse.Target
        if t then
            local m = t:FindFirstAncestorOfClass("Model")
            if m then
                local h = m:FindFirstChildOfClass("Humanoid")
                if h then
                    local p = Players:GetPlayerFromCharacter(m)
                    if p and p ~= LocalPlayer then
                        Data.Target = p
                    end
                end
            end
        end
    end)
end

-- ============================================
-- FLY SYSTEM
-- ============================================
function FlyAc()
    Data.Fly = true
end

function FlyKapat()
    Data.Fly = false
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        if h then h.PlatformStand = false end
        if r then r.AssemblyLinearVelocity = Vector3.zero end
    end
end

RunService.Heartbeat:Connect(function()
    if not Data.Fly then return end
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    
    h.PlatformStand = true
    local dir = h.MoveDirection
    if dir.Magnitude > 0 then
        local cf = Camera.CFrame
        local tgt = (cf.RightVector * dir.X) + (cf.LookVector * dir.Z)
        if tgt.Magnitude > 0 then
            r.AssemblyLinearVelocity = tgt.Unit * Data.Speed
        end
    else
        r.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- ============================================
-- GHOST MODE
-- ============================================
function GhostAc()
    Data.Ghost = true
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    
    h.BreakJointsOnDeath = false
    h.Health = 0
    
    local gp = Instance.new("Part")
    gp.Name = "Ghost"
    gp.Size = Vector3.new(2, 2, 1)
    gp.Transparency = 1
    gp.CanCollide = true
    gp.Anchored = false
    gp.Parent = c
    
    local w = Instance.new("WeldConstraint")
    w.Part0 = gp
    w.Part1 = r
    w.Parent = gp
    
    r.Anchored = false
    
    Data.GhostConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if c and c.Parent and h and h.Parent then
                if h.Health > 0 then h.Health = 0 end
                h:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)
    end)
end

function GhostKapat()
    Data.Ghost = false
    if Data.GhostConn then Data.GhostConn:Disconnect() Data.GhostConn = nil end
    local c = LocalPlayer.Character
    if c then
        for _, v in ipairs(c:GetChildren()) do
            if v.Name == "Ghost" then v:Destroy() end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.BreakJointsOnDeath = true h.Health = 100 end
    end
end

-- ============================================
-- AUTO BAD (UÇARAK TAKİP + DİREKT HASAR)
-- ============================================
function BadAc()
    Data.Bad = true
    Data.BadConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Data.Target then return end
            local tc = Data.Target.Character
            if not tc then return end
            local th = tc:FindFirstChildOfClass("Humanoid")
            local tr = tc:FindFirstChild("HumanoidRootPart")
            if not th or not tr or th.Health <= 0 then return end
            
            local mc = LocalPlayer.Character
            if not mc then return end
            local mh = mc:FindFirstChildOfClass("Humanoid")
            local mr = mc:FindFirstChild("HumanoidRootPart")
            if not mh or not mr then return end
            
            mh.PlatformStand = true
            local d = (tr.Position - mr.Position)
            if d.Magnitude > 0 then
                mr.AssemblyLinearVelocity = d.Unit * Data.Speed
            end
            
            if d.Magnitude < 5 then
                th:TakeDamage(10)
                tr.AssemblyLinearVelocity = tr.AssemblyLinearVelocity + (d.Unit * 20)
            end
        end)
    end)
end

function BadKapat()
    Data.Bad = false
    if Data.BadConn then Data.BadConn:Disconnect() Data.BadConn = nil end
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        if h then h.PlatformStand = false end
        if r then r.AssemblyLinearVelocity = Vector3.zero end
    end
end

-- ============================================
-- MEDUSA MODE (1 METRE)
-- ============================================
function MedusaAc()
    Data.Medusa = true
    Data.MedusaConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local mc = LocalPlayer.Character
            if not mc then return end
            local mr = mc:FindFirstChild("HumanoidRootPart")
            if not mr then return end
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local tc = plr.Character
                if not tc then continue end
                local tr = tc:FindFirstChild("HumanoidRootPart")
                local th = tc:FindFirstChildOfClass("Humanoid")
                if not tr or not th or th.Health <= 0 then continue end
                
                if (tr.Position - mr.Position).Magnitude <= 1 then
                    tr.Anchored = true
                    th:TakeDamage(25)
                    task.delay(1, function()
                        if tr and tr.Parent then tr.Anchored = false end
                    end)
                end
            end
        end)
    end)
end

function MedusaKapat()
    Data.Medusa = false
    if Data.MedusaConn then Data.MedusaConn:Disconnect() Data.MedusaConn = nil end
end

-- ============================================
-- CUBE SYSTEM
-- ============================================
function CubeAc()
    Data.Cube = true
    Data.CubeConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local c = LocalPlayer.Character
            if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            
            if h.MoveDirection.Magnitude > 0 or r.AssemblyLinearVelocity.Y > 2 then
                local cube = Instance.new("Part")
                cube.Name = "C"
                cube.Size = Vector3.new(4, 0.5, 4)
                cube.Position = r.Position - Vector3.new(0, 3.5, 0)
                cube.Anchored = true
                cube.CanCollide = true
                cube.Transparency = 1
                cube.Parent = Workspace
                table.insert(Data.Cubes, cube)
                
                task.delay(0.5, function()
                    if cube and cube.Parent then
                        cube:Destroy()
                        local i = table.find(Data.Cubes, cube)
                        if i then table.remove(Data.Cubes, i) end
                    end
                end)
            end
        end)
    end)
end

function CubeKapat()
    Data.Cube = false
    if Data.CubeConn then Data.CubeConn:Disconnect() Data.CubeConn = nil end
    for _, c in ipairs(Data.Cubes) do
        if c and c.Parent then c:Destroy() end
    end
    Data.Cubes = {}
end

-- ============================================
-- YERE İNME (X TUŞU)
-- ============================================
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.X then
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = {c}
        
        local ray = Workspace:Raycast(r.Position, Vector3.new(0, -500, 0), rp)
        if ray then
            r.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end
    
    -- TP (N TUŞU)
    if inp.KeyCode == Enum.KeyCode.N then
        if not Data.Target or not Data.Target.Character then return end
        local th = Data.Target.Character:FindFirstChild("Head")
        if not th then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        r.CFrame = th.CFrame * CFrame.new(0, 0, -2)
        r.AssemblyLinearVelocity = (th.Position - r.Position).Unit * 34
    end
end)

-- ============================================
-- KARAKTER YENİLENİNCE
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    MenuYap()
    if Data.Ghost then task.wait(0.1) GhostAc() end
end)

-- ============================================
-- BAŞLAT
-- ============================================
MenuYap()
print("[Brainrot v5] 5 Mod Hazır: Fly | Ghost | Bad | Medusa | Cube | X:İniş N:TP SolTık:Hedef")-- ============================================
-- BRAINROT DUEL v5 - PART 2: GÜÇLÜ BYPASS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ANTI-KICK: AĞIR VERİ PAKETİ SPAMI
-- ============================================
local function AntiKick()
    while true do
        pcall(function()
            local c = LocalPlayer.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local r = c:FindFirstChild("HumanoidRootPart")
            if not h or not r then return end
            
            -- Sürekli pozisyon verisi yağdır (sunucu timeout yapamaz)
            for i = 1, 20 do
                r.Velocity = Vector3.new(math.random(-500, 500) / 100, 0, math.random(-500, 500) / 100)
                task.wait(0.01)
            end
            r.Velocity = Vector3.zero
            
            -- Meşru hareket sinyali
            h:Move(Vector3.new(0.001, 0, 0.001), false)
            task.wait(0.05)
            h:Move(Vector3.new(-0.001, 0, -0.001), false)
        end)
        task.wait(0.5)
    end
end

-- ============================================
-- ANTI-RESET: KARAKTER SİLİNME KORUMASI
-- ============================================
local function AntiReset()
    LocalPlayer.CharacterAdded:Connect(function(c)
        local h = c:WaitForChild("Humanoid", 5)
        if not h then return end
        
        -- Ölüm engeli
        h.Died:Connect(function()
            pcall(function()
                task.wait(0.01)
                h:ChangeState(Enum.HumanoidStateType.Physics)
                h.BreakJointsOnDeath = false
                h.Health = 0.1
            end)
        end)
        
        -- State değişim engeli
        h.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Dead then
                pcall(function()
                    task.wait(0.01)
                    h:ChangeState(Enum.HumanoidStateType.Physics)
                end)
            end
        end)
        
        -- Health sıfırlanma engeli
        h:GetPropertyChangedSignal("Health"):Connect(function()
            if h.Health <= 0 then
                pcall(function()
                    h.BreakJointsOnDeath = false
                    task.wait(0.01)
                    h.Health = 0.1
                    h:ChangeState(Enum.HumanoidStateType.Physics)
                end)
            end
        end)
        
        -- RootPart silinme engeli
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then
            r.AncestryChanged:Connect(function(_, parent)
                if parent == nil then
                    -- Karakter silindi, yeniden oluşmasını bekle
                end
            end)
        end
    end)
end

-- ============================================
-- REMOTE EVENT TAM BLOKAJ (HATA VERDİRME)
-- ============================================
local yasakli = {"kick", "ban", "cheat", "exploit", "hack", "detect", "flag", "verify", "check", "report", "reset", "teleport", "admin", "mod", "guard"}
local oldNC
oldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        if typeof(self) == "Instance" then
            local nm = self.Name:lower()
            local cls = self.ClassName:lower()
            for _, w in ipairs(yasakli) do
                if nm:find(w) or cls:find(w) then
                    -- Anti-cheat'e hata verdir
                    error("Connection error: invalid packet") 
                    return nil
                end
            end
        end
    end
    return oldNC(self, ...)
end)

-- ============================================
-- ANTI-CRASH: BELLEK YÖNETİMİ
-- ============================================
spawn(function()
    while true do
        pcall(function()
            local count = 0
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "C" or obj.Name == "AntiKickCube" then
                    count = count + 1
                    if count > 30 then obj:Destroy() end
                end
            end
        end)
        task.wait(3)
    end
end)

-- ============================================
-- ANTI-IDLE: KESİNTİSİZ INPUT
-- ============================================
spawn(function()
    while true do
        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(1, 0, game)
            task.wait(0.02)
            VirtualInputManager:SendMouseMoveEvent(-1, 0, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end)
        task.wait(20)
    end
end)

-- ============================================
-- BAĞLANTI KOPMA KORUMASI
-- ============================================
spawn(function()
    while true do
        pcall(function()
            if not LocalPlayer:IsLoaded() then
                LocalPlayer.CharacterAdded:Wait()
            end
        end)
        task.wait(3)
    end
end)

-- ============================================
-- TÜM BYPASSLARI BAŞLAT
-- ============================================
spawn(AntiKick)
AntiReset()

print("[Brainrot v5] Bypass Aktif | Anti-Kick | Anti-Reset | Remote Blokaj | Hata Verdirme")
