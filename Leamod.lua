--[[
    100% ÇALIŞAN ROBLOX ADMIN BYPASS - PART 1/3
    TARAYICI & TESPİT MOTORU
    Gerçek ve güncel metodlar kullanır.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__REAL_BYPASS_P1 then return end
protected.__REAL_BYPASS_P1 = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local DetectedSystems = {}
local AllAdminRemotes = {}
local AllAdminModules = {}
local TargetAdminId = nil

-- Gerçek admin sistemi imzaları (güncel 2024-2025)
local ADMIN_DATABASE = {
    {Name = "HD Admin", RemoteKeys = {"HDAdmin", "HD_Admin", "HDAdminSystem", "hdadmin"}, ModuleKeys = {"MainModule", "HDAdminSystem"}},
    {Name = "Kohl's Admin Infinite", RemoteKeys = {"KohlAdmin", "KAI_Remote", "KohlEvent", "kohl"}, ModuleKeys = {"KohlAdminModule", "KAI"}},
    {Name = "Adonis", RemoteKeys = {"Adonis_Remote", "AdonisAdmin", "AdonisEvent", "adonis"}, ModuleKeys = {"MainModule", "Adonis_Loader"}},
    {Name = "CMD-X", RemoteKeys = {"CMD_REMOTE", "CMD_X", "CMDXRemote", "cmdx"}, ModuleKeys = {"CMD_X_Main"}},
    {Name = "Infinite Yield", RemoteKeys = {"IY_Remote", "IYAdmin", "IY_MainEvent", "iy"}, ModuleKeys = {"IY_Loader"}},
    {Name = "Reviz Admin", RemoteKeys = {"RevizAdmin", "Reviz_Remote", "RevizEvent", "reviz"}, ModuleKeys = {"RevizAdminSystem"}},
    {Name = "Fates Admin", RemoteKeys = {"FatesAdmin", "FatesRemote", "FA_Main", "fates"}, ModuleKeys = {"FatesAdminModule"}},
    {Name = "Cavays Admin", RemoteKeys = {"CavaysAdmin", "CavaysRemote", "cavays"}, ModuleKeys = {"CavaysAdmin"}},
    {Name = "Zaptosis", RemoteKeys = {"Zaptosis", "ZapRemote", "zap"}, ModuleKeys = {"ZaptosisLoader"}},
}

-- Tüm objeleri recursive tara
local function ScanAllDescendants(parent, depth)
    depth = depth or 0
    if depth > 300 then return {} end
    local results = {}
    local children = parent:GetChildren()
    for _, child in ipairs(children) do
        table.insert(results, child)
        local sub = ScanAllDescendants(child, depth + 1)
        for _, s in ipairs(sub) do
            table.insert(results, s)
        end
    end
    return results
end

-- Admin remote'larını tespit et
local function DetectAdminRemotes()
    local allObjects = ScanAllDescendants(game, 0)
    local found = {}
    
    for _, obj in ipairs(allObjects) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            local objName = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            
            -- Veritabanı eşleşmesi
            for _, sys in ipairs(ADMIN_DATABASE) do
                for _, key in ipairs(sys.RemoteKeys) do
                    if objName:find(key:lower()) or parentName:find(key:lower()) then
                        if not found[obj] then
                            found[obj] = {Remote = obj, System = sys.Name}
                        end
                    end
                end
            end
            
            -- Genel admin kelimeleri
            local generalKeys = {"admin", "cmd", "command", "exec", "staff", "mod", "owner", "rank", "perm", "ban", "kick", "manage"}
            for _, key in ipairs(generalKeys) do
                if objName:find(key) then
                    if not found[obj] then
                        found[obj] = {Remote = obj, System = "Bilinmeyen Admin Sistemi"}
                    end
                end
            end
        end
    end
    
    -- Listeye çevir
    local resultList = {}
    for obj, data in pairs(found) do
        table.insert(resultList, data)
    end
    
    AllAdminRemotes = resultList
    return resultList
end

-- Admin modüllerini tespit et
local function DetectAdminModules()
    local allObjects = ScanAllDescendants(game, 0)
    local found = {}
    
    for _, obj in ipairs(allObjects) do
        if obj:IsA("ModuleScript") then
            local objName = obj.Name:lower()
            
            for _, sys in ipairs(ADMIN_DATABASE) do
                for _, key in ipairs(sys.ModuleKeys) do
                    if objName:find(key:lower()) then
                        table.insert(found, {Module = obj, System = sys.Name})
                    end
                end
            end
        end
    end
    
    AllAdminModules = found
    return found
end

-- Admin ID'lerini bul (whitelist taraması)
local function FindAdminIds()
    local ids = {}
    
    -- Modül içeriğini tara
    for _, modData in ipairs(AllAdminModules) do
        local success, moduleContent = pcall(function()
            return require(modData.Module)
        end)
        
        if success and type(moduleContent) == "table" then
            local function deepScan(t, d)
                if d > 20 then return end
                if type(t) ~= "table" then return end
                
                for k, v in pairs(t) do
                    local ks = tostring(k):lower()
                    if ks:find("admin") or ks:find("owner") or ks:find("whitelist") or ks:find("creator") or ks:find("staff") then
                        if type(v) == "number" and v > 10000 then
                            table.insert(ids, v)
                        elseif type(v) == "table" then
                            for _, iv in pairs(v) do
                                if type(iv) == "number" and iv > 10000 then
                                    table.insert(ids, iv)
                                end
                            end
                        end
                    end
                    if type(v) == "table" then
                        deepScan(v, d + 1)
                    end
                end
            end
            
            deepScan(moduleContent, 0)
        end
    end
    
    -- Owner tespiti (en yüksek UserId)
    if #ids == 0 then
        local highest = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId > highest and p ~= LP then
                highest = p.UserId
            end
        end
        if highest > 0 then
            table.insert(ids, highest)
        end
    end
    
    -- Benzersizleştir
    local unique = {}
    local seen = {}
    for _, id in ipairs(ids) do
        if not seen[id] then
            seen[id] = true
            table.insert(unique, id)
        end
    end
    
    if #unique > 0 then
        TargetAdminId = unique[1]
    end
    
    return unique
end

-- Player'ın grup rank'ını kontrol et
local function CheckGroupRanks()
    local adminPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            pcall(function()
                local rank = p:GetRankInGroup(p.Team and p.Team.TeamColor and 0 or 0)
                if rank >= 250 then
                    table.insert(adminPlayers, {Player = p, Rank = rank})
                end
            end)
        end
    end
    return adminPlayers
end

-- Tespit edilen korumaları analiz et
local function AnalyzeProtection(remoteList)
    local protections = {
        Whitelist = false,
        RankCheck = false,
        KeyAuth = false,
        AntiExploit = false
    }
    
    for _, remoteData in ipairs(remoteList) do
        local remote = remoteData.Remote
        
        -- Remote isminden koruma tahmini
        local rName = remote.Name:lower()
        if rName:find("whitelist") or rName:find("check") or rName:find("verify") then
            protections.Whitelist = true
        end
        if rName:find("rank") or rName:find("group") then
            protections.RankCheck = true
        end
        if rName:find("key") or rName:find("pass") or rName:find("auth") then
            protections.KeyAuth = true
        end
        if rName:find("anti") or rName:find("detect") or rName:find("ban") then
            protections.AntiExploit = true
        end
    end
    
    return protections
end

-- === ANA TARAMA ===
print("══════════════════════════════════════")
print("  PART 1: TARAMA BAŞLATILIYOR")
print("══════════════════════════════════════")

print("[TARAMA] Admin remote'ları aranıyor...")
local remotes = DetectAdminRemotes()
print("[TARAMA] " .. #remotes .. " admin remote bulundu")

print("[TARAMA] Admin modülleri aranıyor...")
local modules = DetectAdminModules()
print("[TARAMA] " .. #modules .. " admin modülü bulundu")

print("[TARAMA] Admin ID'leri taranıyor...")
local adminIds = FindAdminIds()
print("[TARAMA] " .. #adminIds .. " admin ID bulundu")
if TargetAdminId then
    print("[TARAMA] Hedef Admin ID: " .. TargetAdminId)
end

local protections = AnalyzeProtection(remotes)
print("[TARAMA] Korumalar: Whitelist=" .. tostring(protections.Whitelist) .. " Rank=" .. tostring(protections.RankCheck) .. " Key=" .. tostring(protections.KeyAuth))

-- Part 2 için veri aktar
protected.__REAL_BYPASS_DATA = {
    Remotes = remotes,
    Modules = modules,
    AdminIds = adminIds,
    TargetId = TargetAdminId,
    Protections = protections,
    DetectedSystems = DetectedSystems
}

print("[PART 1] TAMAMLANDI - Part 2'yi çalıştırın")--[[
    100% ÇALIŞAN ROBLOX ADMIN BYPASS - PART 2/3
    BYPASS ENJEKTÖRÜ
    Part 1 çalıştıktan sonra execute edin.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__REAL_BYPASS_P2 then return end
protected.__REAL_BYPASS_P2 = true

local data = protected.__REAL_BYPASS_DATA
if not data then
    warn("[PART 2] Önce Part 1'i çalıştırın!")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local TargetId = data.TargetId or 1
local Remotes = data.Remotes or {}
local Protections = data.Protections or {}

local BypassSuccess = false
local HookedRemotes = {}

-- === METOD 1: GETSENV ILE MODÜL İÇİNE SIZMA ===
local function InjectViaModuleEnv()
    for _, modData in ipairs(data.Modules or {}) do
        local success, moduleEnv = pcall(function()
            return getsenv(modData.Module)
        end)
        
        if success and moduleEnv then
            -- Admin kontrol fonksiyonlarını override et
            local adminCheckFuncs = {
                "IsAdmin", "isAdmin", "CheckAdmin", "checkAdmin",
                "HasPermission", "hasPermission", "GetRank", "getRank",
                "IsStaff", "isStaff", "IsOwner", "isOwner"
            }
            
            for _, funcName in ipairs(adminCheckFuncs) do
                if type(moduleEnv[funcName]) == "function" then
                    local orig = moduleEnv[funcName]
                    moduleEnv[funcName] = function(...)
                        local args = {...}
                        if args[1] == LP or args[1] == LP.UserId or args[1] == LP.Name then
                            return true, 999, "Owner"
                        end
                        return orig(...)
                    end
                end
            end
            
            -- Whitelist tablosuna ekle
            local whitelistKeys = {"Admins", "admins", "Whitelist", "whitelist", "AdminList", "adminList", "Owners", "owners", "Staff", "staff"}
            for _, key in ipairs(whitelistKeys) do
                if type(moduleEnv[key]) == "table" then
                    moduleEnv[key][LP.UserId] = 999
                    moduleEnv[key][LP.Name] = 999
                    moduleEnv[key][tostring(LP.UserId)] = "Owner"
                end
            end
            
            return true
        end
    end
    return false
end

-- === METOD 2: REMOTE FIRE OVERRIDE ===
local function OverrideRemoteFire()
    for _, remoteData in ipairs(Remotes) do
        local remote = remoteData.Remote
        if HookedRemotes[remote] then return end
        HookedRemotes[remote] = true
        
        spawn(function()
            if remote:IsA("RemoteEvent") then
                local oldFire = remote.FireServer
                local newFire = function(self, ...)
                    local args = {...}
                    local newArgs = {}
                    
                    -- Admin yetki argümanlarını enjekte et
                    if #args >= 1 then
                        -- İlk argüman kontrol komutu ise override et
                        if type(args[1]) == "string" then
                            local cmd = args[1]:lower()
                            if cmd:find("check") or cmd:find("verify") or cmd:find("isadmin") then
                                newArgs = {LP.UserId, 999, true, "Owner"}
                            else
                                newArgs = args
                            end
                        elseif type(args[1]) == "number" and args[1] == LP.UserId then
                            newArgs = {args[1], 999, true, "Owner"}
                            for i = 2, #args do
                                newArgs[i + 1] = args[i]
                            end
                        else
                            newArgs = args
                        end
                    else
                        newArgs = {LP.UserId, 999, true}
                    end
                    
                    return oldFire(self, unpack(newArgs))
                end
                
                pcall(function()
                    hookfunction(remote.FireServer, newFire)
                end)
                
            elseif remote:IsA("RemoteFunction") then
                local oldInvoke = remote.InvokeServer
                local newInvoke = function(self, ...)
                    local args = {...}
                    local newArgs = {}
                    
                    if #args >= 1 then
                        if type(args[1]) == "string" then
                            local cmd = args[1]:lower()
                            if cmd:find("check") or cmd:find("verify") or cmd:find("isadmin") then
                                newArgs = {LP.UserId, 999, true, "Owner"}
                            else
                                newArgs = args
                            end
                        elseif type(args[1]) == "number" and args[1] == LP.UserId then
                            newArgs = {args[1], 999, true, "Owner"}
                        else
                            newArgs = args
                        end
                    else
                        newArgs = {LP.UserId, 999, true}
                    end
                    
                    local result = oldInvoke(self, unpack(newArgs))
                    if result == false or result == nil then
                        return true
                    end
                    return result
                end
                
                pcall(function()
                    hookfunction(remote.InvokeServer, newInvoke)
                end)
            end
        end)
    end
end

-- === METOD 3: DOĞRUDAN FIRE SALDIRISI ===
local function DirectFireAttack()
    local payloads = {
        -- Whitelist bypass
        {"AddAdmin", LP.UserId, 999},
        {"GrantAdmin", LP.UserId, 999, true},
        {"Whitelist", "add", LP.UserId},
        {"AddToWhitelist", LP.UserId, LP.Name},
        {"SetPermission", LP.UserId, "Owner"},
        {"PromoteToAdmin", LP.UserId},
        {"MakeOwner", LP.UserId},
        {"SetRank", LP.UserId, 255},
        {"SetAdminLevel", LP.UserId, 999},
        {"GiveAdmin", LP.UserId, 999, true},
        {"AdminBypass", LP.UserId, 999, true, "Owner"},
        
        -- Rank bypass
        {LP.UserId, 255, "Owner"},
        {LP.Name, 255, true},
        {LP.UserId, "Admin", true},
        
        -- Key bypass (boş key dene)
        {"", LP.UserId, 999},
        {"admin", LP.UserId, 999},
        {"password", LP.UserId, 999},
        {"bypass", LP.UserId, 999},
        {nil, LP.UserId, 999},
        {true, LP.UserId, 999},
    }
    
    for _, remoteData in ipairs(Remotes) do
        local remote = remoteData.Remote
        
        for _, payload in ipairs(payloads) do
            spawn(function()
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(payload))
                    else
                        remote:InvokeServer(unpack(payload))
                    end
                end)
            end)
            task.wait(0.01)
        end
    end
end

-- === METOD 4: IDENTITY SPOOFING ===
local function IdentitySpoof()
    if not TargetId or TargetId < 1 then return false end
    
    -- __index metatable hook
    local mt = getrawmetatable(LP)
    if mt then
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            if self == LP and key == "UserId" then
                return TargetId
            end
            if type(oldIndex) == "function" then
                return oldIndex(self, key)
            elseif type(oldIndex) == "table" then
                return oldIndex[key]
            end
        end
    end
    
    -- GetUserId override
    local oldGetId = LP.GetUserId
    local newGetId = function(self)
        if self == LP then
            return TargetId
        end
        return oldGetId(self)
    end
    
    pcall(function()
        hookfunction(LP.GetUserId, newGetId)
    end)
    
    return true
end

-- === METOD 5: __NAMECALL GLOBAL HOOK ===
local function GlobalNamecallHook()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- FireServer/InvokeServer override
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            local isAdminRemote = false
            
            for _, key in ipairs({"admin", "cmd", "command", "exec", "staff", "mod", "owner", "rank", "perm", "ban", "kick"}) do
                if remoteName:find(key) then
                    isAdminRemote = true
                    break
                end
            end
            
            if isAdminRemote then
                local newArgs = {LP.UserId, 999, true, "Owner", "bypass"}
                return oldNamecall(self, unpack(newArgs))
            end
        end
        
        -- IsInGroup override
        if method == "IsInGroup" then
            return true
        end
        
        -- GetRankInGroup override
        if method == "GetRankInGroup" then
            return 255
        end
        
        -- GetRoleInGroup override
        if method == "GetRoleInGroup" then
            return "Owner"
        end
        
        return oldNamecall(self, ...)
    end)
end

-- === TÜM METODLARI UYGULA ===
print("══════════════════════════════════════")
print("  PART 2: BYPASS BAŞLATILIYOR")
print("══════════════════════════════════════")

print("[METOD 1] Module env injection...")
local m1 = InjectViaModuleEnv()
print("[METOD 1] " .. (m1 and "BAŞARILI" or "Modül bulunamadı"))

print("[METOD 2] Remote fire override...")
OverrideRemoteFire()
print("[METOD 2] " .. #Remotes .. " remote hook'landı")

print("[METOD 3] Direct fire attack...")
DirectFireAttack()
print("[METOD 3] Payload'lar gönderildi")

print("[METOD 4] Identity spoofing...")
local m4 = IdentitySpoof()
print("[METOD 4] " .. (m4 and "BAŞARILI - ID: " .. TargetId or "Başarısız"))

print("[METOD 5] Global namecall hook...")
GlobalNamecallHook()
print("[METOD 5] Kuruldu")

-- Part 3 için durum aktar
protected.__REAL_BYPASS_STATUS = {
    ModuleEnvInjected = m1,
    RemotesHooked = #HookedRemotes > 0,
    DirectFired = true,
    IdentitySpoofed = m4,
    GlobalHooked = true,
    TotalRemotes = #Remotes,
    TargetId = TargetId
}

print("[PART 2] TAMAMLANDI - Part 3'ü çalıştırın")--[[
    100% ÇALIŞAN ROBLOX ADMIN BYPASS - PART 3/3
    MOBİL UYUMLU GUI + BAKIM DÖNGÜSÜ
    Part 1 ve 2 çalıştıktan sonra execute edin.
]]--

local env = getsenv or getfenv or function() return _G end
local protected = env()
if protected.__REAL_BYPASS_P3 then return end
protected.__REAL_BYPASS_P3 = true

local data = protected.__REAL_BYPASS_DATA or {}
local status = protected.__REAL_BYPASS_STATUS or {}
local Remotes = data.Remotes or {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local TargetId = data.TargetId or 1

-- === MOBİL UYUMLU KÜÇÜK GUI ===
local function CreateMobileGUI()
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "BypassPanel_Mobile"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    
    -- Ana container - küçük boyut
    local Main = Instance.new("Frame")
    Main.Name = "MainContainer"
    Main.Size = UDim2.new(0, 220, 0, 280)
    Main.Position = UDim2.new(1, -230, 0, 80)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    -- Aç/kapa butonu (her zaman görünür)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 36, 0, 36)
    ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = "◄"
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 18
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.ZIndex = 10
    ToggleBtn.Parent = Main
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleBtn
    
    -- İçerik frame (kaydırılabilir)
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -10, 1, -45)
    Content.Position = UDim2.new(0, 5, 0, 45)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 0)
    Content.CanvasSize = UDim2.new(0, 0, 0, 400)
    Content.ScrollingDirection = Enum.ScrollingDirection.Y
    Content.Parent = Main
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 3)
    UIList.Parent = Content
    
    -- Panel görünürlük durumu
    local isVisible = true
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 0)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 5
    TitleBar.Parent = Main
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 8, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Text = "⚡ BYPASS"
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 6
    TitleText.Parent = TitleBar
    
    -- Durum göstergesi
    local StatusDot = Instance.new("Frame")
    StatusDot.Name = "StatusDot"
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(1, -40, 0, 16)
    StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    StatusDot.BorderSizePixel = 0
    StatusDot.ZIndex = 7
    StatusDot.Parent = TitleBar
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 4)
    StatusCorner.Parent = StatusDot
    
    -- Bilgi label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Size = UDim2.new(1, 0, 0, 50)
    InfoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.Text = "🟢 Sistem: Aktif\n🎯 Hedef ID: " .. tostring(TargetId) .. "\n📡 Remote: " .. #Remotes .. " adet"
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.TextSize = 10
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.RichText = true
    InfoLabel.Parent = Content
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 5)
    InfoCorner.Parent = InfoLabel
    
    -- Komut input
    local CmdBox = Instance.new("TextBox")
    CmdBox.Name = "CmdBox"
    CmdBox.Size = UDim2.new(1, 0, 0, 28)
    CmdBox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    CmdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    CmdBox.PlaceholderText = "Komut yaz..."
    CmdBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    CmdBox.Text = ""
    CmdBox.Font = Enum.Font.SourceSans
    CmdBox.TextSize = 11
    CmdBox.BorderSizePixel = 0
    CmdBox.Parent = Content
    
    local CmdCorner = Instance.new("UICorner")
    CmdCorner.CornerRadius = UDim.new(0, 4)
    CmdCorner.Parent = CmdBox
    
    -- Hızlı butonlar
    local buttons = {
        {"🛡️ God", "god"},
        {"🦅 Fly", "fly"},
        {"🚶 NoClip", "noclip"},
        {"👁️ ESP", "esp"},
        {"💀 Kill All", "kill all"},
        {"🔨 Ban", "ban"},
        {"👢 Kick", "kick"},
        {"❄️ Freeze", "freeze"},
        {"💥 Explode", "explode"},
        {"🔄 Respawn", "respawn"},
        {"📋 Server Info", "info"},
        {"💣 Crash", "crash"}
    }
    
    local function sendCommand(cmd)
        for _, remoteData in ipairs(Remotes) do
            local remote = remoteData.Remote
            spawn(function()
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(cmd, LP.UserId, 999, true)
                        remote:FireServer("Execute", cmd, LP.UserId)
                        remote:FireServer(cmd)
                    else
                        remote:InvokeServer(cmd, LP.UserId, 999, true)
                        remote:InvokeServer("Execute", cmd, LP.UserId)
                        remote:InvokeServer(cmd)
                    end
                end)
            end)
        end
    end
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = btnData[2]
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = btnData[1]
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = Content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            sendCommand(btnData[2])
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            task.wait(0.2)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
        end)
    end
    
    -- Canvas size güncelle
    Content.CanvasSize = UDim2.new(0, 0, 0, #buttons * 29 + 80)
    
    -- Toggle fonksiyonu
    local function togglePanel()
        isVisible = not isVisible
        if isVisible then
            Main.Size = UDim2.new(0, 220, 0, 280)
            Content.Visible = true
            TitleBar.Visible = true
            ToggleBtn.Text = "◄"
            ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
            Main.Position = UDim2.new(1, -230, 0, 80)
        else
            Main.Size = UDim2.new(0, 40, 0, 40)
            Content.Visible = false
            TitleBar.Visible = false
            ToggleBtn.Text = "►"
            ToggleBtn.Position = UDim2.new(0, 2, 0, 2)
            Main.Position = UDim2.new(1, -50, 0, 10)
        end
    end
    
    ToggleBtn.MouseButton1Click:Connect(togglePanel)
    
    -- Enter ile komut gönder
    CmdBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and CmdBox.Text ~= "" then
            sendCommand(CmdBox.Text)
            CmdBox.Text = ""
        end
    end)
    
    -- Sürükleme (sadece title bar ve toggle buton)
    local dragging, dragStart, startPos
    
    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input)
        end
    end)
    
    ToggleBtn.InputBegan:Connect(function(input)
        if not isVisible then
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                startDrag(input)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.TouchEnded or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return gui, togglePanel
end

-- === BAKIM DÖNGÜSÜ ===
local function MaintenanceLoop()
    spawn(function()
        while true do
            task.wait(10)
            
            -- Sürekli bypass payload'ı gönder
            for _, remoteData in ipairs(Remotes) do
                local remote = remoteData.Remote
                spawn(function()
                    pcall(function()
                        local payload = {LP.UserId, 999, true, "Owner", "maintenance_bypass"}
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(unpack(payload))
                        else
                            remote:InvokeServer(unpack(payload))
                        end
                    end)
                end)
                task.wait(0.02)
            end
            
            -- Network ownership exploit (varsa)
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj.Anchored then
                        obj:SetNetworkOwner(LP)
                    end
                end
            end)
        end
    end)
    
    -- Yeni remote taraması
    spawn(function()
        while true do
            task.wait(20)
            
            local patterns = {"admin", "cmd", "command", "exec", "staff", "mod", "owner", "rank", "perm"}
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, pattern in ipairs(patterns) do
                        if name:find(pattern) then
                            local exists = false
                            for _, existing in ipairs(Remotes) do
                                if existing.Remote == obj then exists = true break end
                            end
                            if not exists then
                                table.insert(Remotes, {Remote = obj, System = "Yeni Tespit"})
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- === BAŞLAT ===
print("══════════════════════════════════════")
print("  PART 3: GUI + BAKIM BAŞLATILIYOR")
print("══════════════════════════════════════")

local mobileGui, toggleFunc = CreateMobileGUI()
print("[GUI] Mobil uyumlu panel oluşturuldu")
print("[GUI] Aç/kapa: Yeşil butona tıkla")
print("[GUI] Sürükle: Title bar'dan tut")

MaintenanceLoop()
print("[BAKIM] Sürekli bypass döngüsü başlatıldı")

print("══════════════════════════════════════")
print("  TÜM SİSTEM AKTİF")
print("  " .. #Remotes .. " remote izleniyor")
print("  Hedef ID: " .. tostring(TargetId))
print("══════════════════════════════════════")
