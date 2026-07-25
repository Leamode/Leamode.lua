-- // ============================================================
-- // Axiom - Game Infrastructure Analyzer v5.0
-- // PARÇA 1/2: Veri Toplama & Anti-Cheat Analiz Motoru
-- // Amaç: Tüm client-side verileri toplar, analiz eder
-- // Çıktı: getgenv().AxiomData (Parça 2 bunu kullanır)
-- // ============================================================

-- // === SERVICE BINDINGS ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")

-- // === GLOBAL DATA STORE (Parça 2 burayı okur) ===
getgenv().AxiomData = {
    Meta = {
        GameId = game.GameId,
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        GameName = "",
        ExtractTime = os.date("%Y-%m-%d %H:%M:%S"),
        ClientVersion = 0,
        TotalPlayers = 0
    },
    Scripts = {
        LocalScripts = {},
        ModuleScripts = {},
        ServerScripts = {},
        TotalCount = 0,
        WithSource = 0,
        BytecodeCount = 0
    },
    Remotes = {
        RemoteEvents = {},
        RemoteFunctions = {},
        BindableEvents = {},
        BindableFunctions = {},
        TotalCount = 0,
        SuspiciousRemotes = {}
    },
    GUI = {
        ScreenGuis = {},
        TotalElements = 0,
        AdminPanels = {}
    },
    AntiCheat = {
        Detections = {},
        Patterns = {},
        Scripts_With_Protection = {},
        RiskAssessment = "NONE",
        TotalFindings = 0
    },
    Network = {
        Hooks = {Active = false},
        TrafficLog = {}
    },
    LogBuffer = {}
}

local D = getgenv().AxiomData

-- // === INTERNAL LOGGING ===
local function Log(level, category, message)
    local entry = {
        Time = os.date("%H:%M:%S"),
        Level = level,
        Category = category,
        Message = tostring(message)
    }
    table.insert(D.LogBuffer, entry)
    if #D.LogBuffer > 1000 then table.remove(D.LogBuffer, 1) end
    print(string.format("[%s][%s][%s] %s", entry.Time, level, category, message))
end

-- // === UTILITY: Safe pcall ===
local function SafeCall(func, context)
    local s, r = pcall(func)
    if not s then Log("ERROR", context or "UNKNOWN", tostring(r)); return nil end
    return r
end

-- // === UTILITY: Script source extraction ===
local function GetSource(obj)
    local s, src = pcall(function()
        if obj:IsA("BaseScript") then return obj.Source end
        return nil
    end)
    if s and src and src ~= "" then return src end
    return nil
end

-- // === UTILITY: Bytecode detection ===
local function IsBytecode(source)
    if not source or #source < 10 then return false end
    local readable, total = 0, math.min(#source, 200)
    for i = 1, total do
        local b = source:byte(i)
        if (b >= 32 and b <= 126) or b == 10 or b == 13 or b == 9 then
            readable = readable + 1
        end
    end
    return (readable / total) < 0.25
end

-- // === ANTI-CHEAT PATTERN LIBRARY ===
local AC_Patterns = {
    {Name = "UserId Owner Check", Patterns = {"UserId", "userid"}, Category = "Yetkilendirme", Severity = "CRITICAL", Desc = "Belirli kullanıcı ID'si ile sahiplik doğrulaması"},
    {Name = "Group Rank Verification", Patterns = {"GetRankInGroup", "GetRoleInGroup"}, Category = "Yetkilendirme", Severity = "HIGH", Desc = "Grup rank seviyesine göre yetki kontrolü"},
    {Name = "PlayerGui Parent Validation", Patterns = {"PlayerGui", "playergui"}, Category = "Anti-Exploit", Severity = "HIGH", Desc = "GUI elementinin doğru parent'ta olup olmadığını kontrol eder"},
    {Name = "Name-Specific Authorization", Patterns = {"Spyder", "spyder", "Sammy", "sammy"}, Category = "Yetkilendirme", Severity = "CRITICAL", Desc = "Spesifik kullanıcı adına özel yetkilendirme"},
    {Name = "Remote Security Validation", Patterns = {"FireServer", "InvokeServer", "validate", "authorize"}, Category = "İletişim", Severity = "HIGH", Desc = "Remote event/function çağrılarında güvenlik doğrulaması"},
    {Name = "Anti-Tamper Protection", Patterns = {"Destroy", "Disconnect", "Remove", "Kill"}, Category = "Anti-Exploit", Severity = "MEDIUM", Desc = "Yetkisiz değişiklik tespit ve imha sistemi"},
    {Name = "Require Module Authorization", Patterns = {"require", "Require", "waitForChild"}, Category = "Yetkilendirme", Severity = "MEDIUM", Desc = "ModuleScript üzerinden yetki doğrulaması"},
    {Name = "CoreGui Access Control", Patterns = {"CoreGui", "coregui"}, Category = "Anti-Exploit", Severity = "MEDIUM", Desc = "CoreGui erişim ve koruma kontrolleri"},
    {Name = "Client-Side Detection", Patterns = {"FindFirstChildOfClass", "GetDescendants"}, Category = "Anti-Cheat", Severity = "MEDIUM", Desc = "Client-side obje tarama ile exploit tespiti"},
    {Name = "Memory/Value Monitoring", Patterns = {"GetPropertyChangedSignal", "AttributeChanged"}, Category = "Anti-Cheat", Severity = "LOW", Desc = "Değer değişimlerini izleyerek hile tespiti"}
}

-- // ============================================================
-- // EXTRACTION: Meta veriler
-- // ============================================================
local function ExtractMetadata()
    Log("INFO", "META", "Oyun meta verileri çıkarılıyor...")
    SafeCall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        D.Meta.GameName = info.Name or "Unknown"
    end, "GameName")
    SafeCall(function()
        D.Meta.TotalPlayers = #Players:GetPlayers()
    end, "PlayerCount")
    SafeCall(function()
        D.Meta.ClientVersion = game.PlaceVersion or 0
    end, "PlaceVersion")
    Log("OK", "META", string.format("Oyun: %s | Place: %d | Oyuncu: %d", D.Meta.GameName, D.Meta.PlaceId, D.Meta.TotalPlayers))
end

-- // ============================================================
-- // EXTRACTION: Script kaynakları
-- // ============================================================
local function ExtractScripts()
    Log("INFO", "SCRIPTS", "Script kaynakları taranıyor...")
    local containers = {
        {Name = "ReplicatedStorage", Obj = ReplicatedStorage},
        {Name = "ReplicatedFirst", Obj = ReplicatedFirst},
        {Name = "StarterGui", Obj = StarterGui},
        {Name = "StarterPlayer", Obj = StarterPlayer},
        {Name = "PlayerScripts", Obj = LocalPlayer:FindFirstChild("PlayerScripts")},
        {Name = "PlayerGui", Obj = LocalPlayer:FindFirstChild("PlayerGui")},
        {Name = "Workspace", Obj = workspace},
        {Name = "CoreGui", Obj = game:FindFirstChild("CoreGui")}
    }
    local adminKw = {"admin", "owner", "sammy", "spyder", "panel", "control", "permission", "rank", "role", "command", "ban", "kick", "message", "broadcast", "announce", "protection", "security", "bypass", "check", "verify", "validate", "authorize", "mod", "manager", "staff"}

    for _, c in ipairs(containers) do
        SafeCall(function()
            if not c.Obj then return end
            for _, obj in ipairs(c.Obj:GetDescendants()) do
                local st = nil
                if obj:IsA("Script") then st = "ServerScript"
                elseif obj:IsA("LocalScript") then st = "LocalScript"
                elseif obj:IsA("ModuleScript") then st = "ModuleScript" end
                if not st then continue end

                D.Scripts.TotalCount = D.Scripts.TotalCount + 1
                local src = GetSource(obj)
                local isBC = false
                if src then
                    D.Scripts.WithSource = D.Scripts.WithSource + 1
                    isBC = IsBytecode(src)
                    if isBC then D.Scripts.BytecodeCount = D.Scripts.BytecodeCount + 1 end
                end

                local nl, pl = obj.Name:lower(), obj:GetFullName():lower()
                local isAdmin, mk = false, {}
                for _, kw in ipairs(adminKw) do
                    if nl:find(kw) or pl:find(kw) then isAdmin = true; table.insert(mk, kw) end
                end

                local si = {Name = obj.Name, FullPath = obj:GetFullName(), Type = st, Container = c.Name, Source = (not isBC) and src or nil, SourceLength = src and #src or 0, IsBytecode = isBC, IsAdminRelated = isAdmin, MatchedKeywords = mk, HasSource = src ~= nil and not isBC, ACFindings = {}}

                if st == "LocalScript" then table.insert(D.Scripts.LocalScripts, si)
                elseif st == "ModuleScript" then table.insert(D.Scripts.ModuleScripts, si)
                else table.insert(D.Scripts.ServerScripts, si) end

                if src and not isBC then
                    for _, pat in ipairs(AC_Patterns) do
                        local found = false
                        for _, p in ipairs(pat.Patterns) do
                            if src:lower():find(p:lower()) then found = true; break end
                        end
                        if found then
                            table.insert(si.ACFindings, pat)
                            D.AntiCheat.TotalFindings = D.AntiCheat.TotalFindings + 1
                        end
                    end
                    if #si.ACFindings > 0 then table.insert(D.AntiCheat.Scripts_With_Protection, si) end
                end
            end
        end, "ScriptExtraction: " .. c.Name)
    end

    local adminCount = 0
    for _, s in ipairs(D.Scripts.LocalScripts) do if s.IsAdminRelated then adminCount = adminCount + 1 end end
    for _, s in ipairs(D.Scripts.ModuleScripts) do if s.IsAdminRelated then adminCount = adminCount + 1 end end
    Log("OK", "SCRIPTS", string.format("Total:%d | Source:%d | Bytecode:%d | Admin:%d | Protected:%d", D.Scripts.TotalCount, D.Scripts.WithSource, D.Scripts.BytecodeCount, adminCount, #D.AntiCheat.Scripts_With_Protection))
end

-- // ============================================================
-- // EXTRACTION: Remote Event/Function
-- // ============================================================
local function ExtractRemotes()
    Log("INFO", "REMOTES", "Remote yapısı çıkarılıyor...")
    local containers = {
        {Name = "ReplicatedStorage", Obj = ReplicatedStorage},
        {Name = "ReplicatedFirst", Obj = ReplicatedFirst},
        {Name = "Workspace", Obj = workspace},
        {Name = "PlayerGui", Obj = LocalPlayer:FindFirstChild("PlayerGui")},
        {Name = "PlayerScripts", Obj = LocalPlayer:FindFirstChild("PlayerScripts")}
    }
    local suspiciousKw = {"admin", "ban", "kick", "message", "announce", "broadcast", "server", "control", "owner", "sammy", "spyder", "mod", "command", "execute", "script"}

    for _, c in ipairs(containers) do
        SafeCall(function()
            if not c.Obj then return end
            for _, obj in ipairs(c.Obj:GetDescendants()) do
                local rt = nil
                if obj:IsA("RemoteEvent") then rt = "RemoteEvent"
                elseif obj:IsA("RemoteFunction") then rt = "RemoteFunction"
                elseif obj:IsA("BindableEvent") then rt = "BindableEvent"
                elseif obj:IsA("BindableFunction") then rt = "BindableFunction" end
                if not rt then continue end

                D.Remotes.TotalCount = D.Remotes.TotalCount + 1
                local nl, pl = obj.Name:lower(), obj:GetFullName():lower()
                local isSusp, sr = false, {}
                for _, kw in ipairs(suspiciousKw) do
                    if nl:find(kw) or pl:find(kw) then isSusp = true; table.insert(sr, kw) end
                end

                local ri = {Name = obj.Name, FullPath = obj:GetFullName(), Type = rt, Container = c.Name, Parent = obj.Parent and obj.Parent.Name or "Unknown", IsSuspicious = isSusp, SuspiciousReasons = sr}

                if rt == "RemoteEvent" then table.insert(D.Remotes.RemoteEvents, ri)
                elseif rt == "RemoteFunction" then table.insert(D.Remotes.RemoteFunctions, ri)
                elseif rt == "BindableEvent" then table.insert(D.Remotes.BindableEvents, ri)
                else table.insert(D.Remotes.BindableFunctions, ri) end
                if isSusp then table.insert(D.Remotes.SuspiciousRemotes, ri) end
            end
        end, "RemoteExtraction: " .. c.Name)
    end
    Log("OK", "REMOTES", string.format("Event:%d | Func:%d | Bindable:%d | Suspicious:%d", #D.Remotes.RemoteEvents, #D.Remotes.RemoteFunctions, #D.Remotes.BindableEvents + #D.Remotes.BindableFunctions, #D.Remotes.SuspiciousRemotes))
end

-- // ============================================================
-- // EXTRACTION: GUI Yapısı
-- // ============================================================
local function ExtractGUI()
    Log("INFO", "GUI", "GUI yapısı analiz ediliyor...")
    local guiContainers = {
        {Name = "PlayerGui", Obj = LocalPlayer:FindFirstChild("PlayerGui")},
        {Name = "CoreGui", Obj = game:FindFirstChild("CoreGui")}
    }
    local adminGuiKw = {"admin", "panel", "control", "owner", "sammy", "spyder", "mod", "command", "manage"}

    local function scanGUI(parent, depth, cn)
        if depth > 15 or not parent then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                D.GUI.TotalElements = D.GUI.TotalElements + 1
                local nl = child.Name:lower()
                local isAdmin = false
                for _, kw in ipairs(adminGuiKw) do if nl:find(kw) then isAdmin = true; break end end

                local gi = {Name = child.Name, Class = child.ClassName, Container = cn, Depth = depth, Visible = child.Visible, Active = child:IsA("GuiObject") and child.Active or false, Position = child:IsA("GuiObject") and tostring(child.Position) or "N/A", Size = child:IsA("GuiObject") and tostring(child.Size) or "N/A", IsAdmin = isAdmin, HasChildren = #child:GetChildren() > 0}
                if child:IsA("ScreenGui") then table.insert(D.GUI.ScreenGuis, gi) end
                if isAdmin then table.insert(D.GUI.AdminPanels, gi) end
                scanGUI(child, depth + 1, cn)
            end
        end
    end

    for _, c in ipairs(guiContainers) do
        SafeCall(function() if c.Obj then scanGUI(c.Obj, 0, c.Name) end end, "GUIScan: " .. c.Name)
    end
    Log("OK", "GUI", string.format("Total:%d | ScreenGui:%d | AdminPanel:%d", D.GUI.TotalElements, #D.GUI.ScreenGuis, #D.GUI.AdminPanels))
end

-- // ============================================================
-- // NETWORK: Traffic Hook
-- // ============================================================
local function HookNetworkTraffic()
    Log("INFO", "NETWORK", "Network traffic hook kuruluyor...")
    SafeCall(function()
        local mt = getrawmetatable(game)
        if not mt then D.Network.Hooks.Active = false; Log("WARN", "NETWORK", "Metatable bulunamadı"); return end
        local oldNc = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                local te = {Time = os.date("%H:%M:%S"), RemoteName = self.Name, RemotePath = self:GetFullName(), Method = method, ArgCount = #args, ArgTypes = {}}
                for i, arg in ipairs(args) do te.ArgTypes[i] = typeof(arg) end
                table.insert(D.Network.TrafficLog, te)
                if #D.Network.TrafficLog > 500 then table.remove(D.Network.TrafficLog, 1) end
            end
            return oldNc(self, ...)
        end)
        setreadonly(mt, true)
        D.Network.Hooks.Active = true
        Log("OK", "NETWORK", "Namecall hook başarıyla kuruldu")
    end, "NetworkHook")
end

-- // ============================================================
-- // RISK: Değerlendirme
-- // ============================================================
local function AssessRisk()
    local score = 0
    local pc = #D.AntiCheat.Scripts_With_Protection
    if pc > 10 then score = score + 30 elseif pc > 5 then score = score + 20 elseif pc > 0 then score = score + 10 end
    local sc = #D.Remotes.SuspiciousRemotes
    if sc > 5 then score = score + 25 elseif sc > 2 then score = score + 15 end
    local ac = #D.GUI.AdminPanels
    if ac > 3 then score = score + 20 elseif ac > 0 then score = score + 10 end
    if D.Scripts.BytecodeCount > 5 then score = score + 15 end
    if score >= 60 then D.AntiCheat.RiskAssessment = "HIGH"
    elseif score >= 30 then D.AntiCheat.RiskAssessment = "MEDIUM"
    elseif score > 0 then D.AntiCheat.RiskAssessment = "LOW"
    else D.AntiCheat.RiskAssessment = "NONE" end
    Log("INFO", "RISK", string.format("Değerlendirme: %s (Skor: %d)", D.AntiCheat.RiskAssessment, score))
end

-- // ============================================================
-- // HTML: Escape utility
-- // ============================================================
local function HtmlEscape(str)
    return tostring(str):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("\n", "<br>")
end

-- // BU FONKSİYON PARÇA 2 İÇİN REFERANS - HTML üretimi Parça 2'de
getgenv().AxiomData.HtmlEscape = HtmlEscape
getgenv().AxiomData.AC_Patterns = AC_Patterns

-- // ============================================================
-- // MAIN: Çalıştırma
-- // ============================================================
local function RunExtraction()
    Log("INFO", "MAIN", "═══════════════════════════════════")
    Log("INFO", "MAIN", "Axiom Engine Parça 1 - Veri Toplama")
    Log("INFO", "MAIN", "═══════════════════════════════════")
    ExtractMetadata()
    ExtractScripts()
    ExtractRemotes()
    ExtractGUI()
    HookNetworkTraffic()
    AssessRisk()
    Log("DONE", "MAIN", string.format("Script:%d | Remote:%d | AC:%d | GUI:%d | Risk:%s", D.Scripts.TotalCount, D.Remotes.TotalCount, D.AntiCheat.TotalFindings, D.GUI.TotalElements, D.AntiCheat.RiskAssessment))
    Log("DONE", "MAIN", "Veriler getgenv().AxiomData içinde hazır")
    Log("DONE", "MAIN", "Şimdi Parça 2'yi çalıştırarak HTML raporu oluşturun")
    Log("DONE", "MAIN", "═══════════════════════════════════")
    return true
end

-- // Execute
RunExtraction()

-- // Public API
getgenv().AxiomData.RunExtraction = RunExtraction
getgenv().AxiomData.GetStats = function()
    return {
        Scripts = D.Scripts.TotalCount,
        WithSource = D.Scripts.WithSource,
        Remotes = D.Remotes.TotalCount,
        SuspiciousRemotes = #D.Remotes.SuspiciousRemotes,
        ACFindings = D.AntiCheat.TotalFindings,
        ACProtected = #D.AntiCheat.Scripts_With_Protection,
        GUIElements = D.GUI.TotalElements,
        AdminPanels = #D.GUI.AdminPanels,
        Risk = D.AntiCheat.RiskAssessment,
        NetworkHooks = D.Network.Hooks.Active,
        TrafficEntries = #D.Network.TrafficLog
    }
end
getgenv().AxiomData.RefreshData = function()
    -- Reset data
    D.Scripts = {LocalScripts = {}, ModuleScripts = {}, ServerScripts = {}, TotalCount = 0, WithSource = 0, BytecodeCount = 0}
    D.Remotes = {RemoteEvents = {}, RemoteFunctions = {}, BindableEvents = {}, BindableFunctions = {}, TotalCount = 0, SuspiciousRemotes = {}}
    D.GUI = {ScreenGuis = {}, TotalElements = 0, AdminPanels = {}}
    D.AntiCheat = {Detections = {}, Patterns = {}, Scripts_With_Protection = {}, RiskAssessment = "NONE", TotalFindings = 0}
    D.Network.TrafficLog = {}
    return RunExtraction()
end

print([[
╔═══════════════════════════════════════╗
║ PARÇA 1/2 TAMAMLANDI                 ║
║ Veriler toplandı ve analiz edildi    ║
║ getgenv().AxiomData hazır            ║
║ Şimdi Parça 2'yi çalıştırın          ║
╚═══════════════════════════════════════╝
]])-- // ============================================================
-- // Axiom - Game Infrastructure Analyzer v5.0
-- // PARÇA 2/2: HTML Rapor Üretici
-- // Gereksinim: Parça 1 çalışmış olmalı (getgenv().AxiomData)
-- // Amaç: Toplanan verilerden beyaz tema HTML raporu üretir
-- // Çıktı: Panoya kopyalanmış HTML + getgenv().AxiomReport
-- // ============================================================

-- // Parça 1 verilerini kontrol et
if not getgenv().AxiomData then
    error("[HATA] Parça 1 çalıştırılmamış! Önce Parça 1'i çalıştırın.")
end

local D = getgenv().AxiomData
local HE = D.HtmlEscape or function(s) return tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("\n", "<br>") end

-- // İstatistik kontrolü
local stats = D.GetStats and D.GetStats() or {
    Scripts = D.Scripts.TotalCount or 0,
    WithSource = D.Scripts.WithSource or 0,
    Remotes = D.Remotes.TotalCount or 0,
    SuspiciousRemotes = #(D.Remotes.SuspiciousRemotes or {}),
    ACFindings = D.AntiCheat.TotalFindings or 0,
    ACProtected = #(D.AntiCheat.Scripts_With_Protection or {}),
    GUIElements = D.GUI.TotalElements or 0,
    AdminPanels = #(D.GUI.AdminPanels or {}),
    Risk = D.AntiCheat.RiskAssessment or "NONE",
    NetworkHooks = D.Network.Hooks.Active or false,
    TrafficEntries = #(D.Network.TrafficLog or {})
}

print(string.format("[INFO] Stats: Scripts=%d Remotes=%d AC=%d GUI=%d Risk=%s", 
    stats.Scripts, stats.Remotes, stats.ACFindings, stats.GUIElements, stats.Risk))

-- // ============================================================
-- // CSS TEMPLATE
-- // ============================================================
local CSS = [[
:root {
    --bg-primary: #ffffff; --bg-secondary: #f8f9fa; --bg-tertiary: #e9ecef;
    --text-primary: #212529; --text-secondary: #495057; --text-muted: #6c757d;
    --border: #dee2e6; --accent: #2563eb; --accent-hover: #1d4ed8;
    --critical: #dc2626; --high: #ea580c; --medium: #ca8a04; --low: #16a34a; --none: #6b7280;
    --code-bg: #f1f5f9; --code-border: #cbd5e1;
    --shadow: 0 1px 3px rgba(0,0,0,0.1); --shadow-lg: 0 4px 6px rgba(0,0,0,0.1);
    --radius: 8px; --radius-sm: 4px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: var(--bg-secondary); color: var(--text-primary); line-height: 1.6; }
.container { max-width: 1400px; margin: 0 auto; padding: 20px; }
.header { background: var(--bg-primary); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 24px; box-shadow: var(--shadow); }
.header h1 { font-size: 24px; font-weight: 700; margin-bottom: 8px; }
.header .meta { display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px; color: var(--text-muted); }
.risk-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
.risk-HIGH { background: #fef2f2; color: var(--critical); border: 1px solid #fecaca; }
.risk-MEDIUM { background: #fffbeb; color: var(--medium); border: 1px solid #fde68a; }
.risk-LOW { background: #f0fdf4; color: var(--low); border: 1px solid #bbf7d0; }
.risk-NONE { background: #f9fafb; color: var(--none); border: 1px solid #e5e7eb; }
.nav { display: flex; gap: 4px; margin-bottom: 24px; flex-wrap: wrap; background: var(--bg-primary); border: 1px solid var(--border); border-radius: var(--radius); padding: 4px; box-shadow: var(--shadow); }
.nav button { padding: 10px 20px; border: none; background: transparent; border-radius: var(--radius-sm); cursor: pointer; font-size: 13px; font-weight: 500; color: var(--text-secondary); transition: all 0.2s; }
.nav button:hover { background: var(--bg-tertiary); }
.nav button.active { background: var(--accent); color: white; }
.section { display: none; background: var(--bg-primary); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 24px; box-shadow: var(--shadow); }
.section.active { display: block; }
.section h2 { font-size: 18px; font-weight: 600; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 2px solid var(--border); }
.stat-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; margin-bottom: 24px; }
.stat-card { background: var(--bg-secondary); border: 1px solid var(--border); border-radius: var(--radius); padding: 16px; text-align: center; }
.stat-card .value { font-size: 28px; font-weight: 700; color: var(--accent); }
.stat-card .label { font-size: 11px; color: var(--text-muted); margin-top: 4px; text-transform: uppercase; letter-spacing: 0.5px; }
.code-block { background: var(--code-bg); border: 1px solid var(--code-border); border-radius: var(--radius-sm); margin-bottom: 12px; overflow: hidden; }
.code-header { display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background: var(--bg-tertiary); border-bottom: 1px solid var(--border); font-size: 12px; font-weight: 600; color: var(--text-secondary); }
.badge { padding: 2px 8px; border-radius: 12px; font-size: 10px; font-weight: 600; }
.badge-admin { background: #fef2f2; color: var(--critical); }
.badge-module { background: #eff6ff; color: var(--accent); }
.badge-local { background: #f0fdf4; color: var(--low); }
.badge-server { background: #fefce8; color: var(--medium); }
.copy-btn { padding: 4px 12px; background: var(--accent); color: white; border: none; border-radius: var(--radius-sm); cursor: pointer; font-size: 11px; font-weight: 500; transition: background 0.2s; }
.copy-btn:hover { background: var(--accent-hover); }
.copy-btn.copied { background: var(--low); }
.code-content { padding: 12px; font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace; font-size: 12px; line-height: 1.5; overflow-x: auto; white-space: pre; max-height: 400px; overflow-y: auto; }
table { width: 100%; border-collapse: collapse; font-size: 13px; }
th { text-align: left; padding: 10px 12px; background: var(--bg-tertiary); border-bottom: 2px solid var(--border); font-weight: 600; color: var(--text-secondary); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }
td { padding: 10px 12px; border-bottom: 1px solid var(--border); }
tr:hover td { background: var(--bg-secondary); }
.filter-bar { display: flex; gap: 8px; margin-bottom: 16px; }
.filter-bar input { flex: 1; padding: 8px 12px; border: 1px solid var(--border); border-radius: var(--radius-sm); font-size: 13px; outline: none; transition: border 0.2s; }
.filter-bar input:focus { border-color: var(--accent); }
.severity-CRITICAL { color: var(--critical); font-weight: 700; }
.severity-HIGH { color: var(--high); font-weight: 600; }
.severity-MEDIUM { color: var(--medium); font-weight: 500; }
.severity-LOW { color: var(--low); }
.footer { text-align: center; padding: 16px; font-size: 11px; color: var(--text-muted); }
@media (max-width: 768px) { .container { padding: 10px; } .header .meta { flex-direction: column; gap: 8px; } .nav { overflow-x: auto; } .stat-grid { grid-template-columns: repeat(2, 1fr); } }
]]

-- // ============================================================
-- // HTML HEADER
-- // ============================================================
local function BuildHeader()
    return string.format([[
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Game Report - %s</title>
<style>%s</style>
</head>
<body>
<div class="container">
<div class="header">
    <h1>🔍 %s - Infrastructure Report</h1>
    <div class="meta">
        <span>🆔 Game: %s</span>
        <span>📍 Place: %s</span>
        <span>📋 Job: %s</span>
        <span>🕐 %s</span>
        <span>👥 %d players</span>
        <span>Risk: <span class="risk-badge risk-%s">%s</span></span>
    </div>
</div>
<div class="nav">
    <button class="active" onclick="showSection('overview', this)">📊 Genel Bakış</button>
    <button onclick="showSection('scripts', this)">📜 Scripts</button>
    <button onclick="showSection('remotes', this)">📡 Remotes</button>
    <button onclick="showSection('antichat', this)">🛡️ Anti-Cheat</button>
    <button onclick="showSection('gui', this)">🖥️ GUI</button>
    <button onclick="showSection('network', this)">🌐 Network</button>
</div>
]], HE(D.Meta.GameName), CSS, HE(D.Meta.GameName), D.Meta.GameId, D.Meta.PlaceId, HE(D.Meta.JobId), D.Meta.ExtractTime, D.Meta.TotalPlayers, stats.Risk, stats.Risk)
end

-- // ============================================================
-- // OVERVIEW SECTION
-- // ============================================================
local function BuildOverview()
    return string.format([[
<div id="overview" class="section active">
    <h2>Genel Bakış</h2>
    <div class="stat-grid">
        <div class="stat-card"><div class="value">%d</div><div class="label">Toplam Script</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Kaynak Alınan</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Remote Events</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Anti-Cheat Bulgusu</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">GUI Elementi</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Aktif Oyuncu</div></div>
    </div>
    <h3>Risk Değerlendirmesi: <span class="risk-badge risk-%s">%s</span></h3>
    <p style="color: var(--text-muted); font-size: 13px;">
        %d adet anti-cheat/koruma mekanizması tespit edildi. 
        %d adet şüpheli remote event bulundu.
        Network hook: %s.
    </p>
</div>
]], stats.Scripts, stats.WithSource, stats.Remotes, stats.ACFindings, stats.GUIElements, D.Meta.TotalPlayers,
   stats.Risk, stats.Risk, stats.ACFindings, stats.SuspiciousRemotes, stats.NetworkHooks and "✅ Aktif" or "❌ Pasif")
end

-- // ============================================================
-- // SCRIPTS SECTION
-- // ============================================================
local function BuildScriptsSection()
    local html = [[
<div id="scripts" class="section">
    <h2>Script Kaynak Kodları</h2>
    <div class="filter-bar"><input type="text" placeholder="Script ara..." oninput="filterTable('scripts-table', this.value)"></div>
    <div style="overflow-x: auto;">
    <table id="scripts-table">
        <thead><tr><th>#</th><th>Ad</th><th>Tür</th><th>Kaynak</th><th>Karakter</th><th>Admin</th><th>Kod</th></tr></thead>
        <tbody>
]]
    local idx = 0
    local allScripts = {}
    for _, s in ipairs(D.Scripts.LocalScripts or {}) do table.insert(allScripts, s) end
    for _, s in ipairs(D.Scripts.ModuleScripts or {}) do table.insert(allScripts, s) end
    for _, s in ipairs(D.Scripts.ServerScripts or {}) do table.insert(allScripts, s) end

    for _, s in ipairs(allScripts) do
        idx = idx + 1
        local tb = s.Type == "LocalScript" and '<span class="badge badge-local">Local</span>' or
                   (s.Type == "ModuleScript" and '<span class="badge badge-module">Module</span>' or
                   '<span class="badge badge-server">Server</span>')
        local ab = s.IsAdminRelated and '<span class="badge badge-admin">ADMIN</span>' or '-'
        local ss = s.HasSource and "✅" or (s.IsBytecode and "🔒 Bytecode" or "❌")
        local cb = s.HasSource and s.Source and string.format('<button class="copy-btn" onclick="copyCode(this, `%s`)">Kopyala</button>', HE(s.Source):gsub("`", "\\`")) or "-"
        html = html .. string.format('<tr><td>%d</td><td><strong>%s</strong></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>',
            idx, HE(s.Name), tb, ss, s.SourceLength > 0 and (s.SourceLength .. " chars") or "-", ab, cb)
        if s.HasSource and s.Source then
            html = html .. string.format('<tr><td colspan="7"><div class="code-block"><div class="code-header"><span>📄 %s</span><span>%d karakter</span></div><div class="code-content">%s</div></div></td></tr>',
                HE(s.FullPath), s.SourceLength, HE(s.Source))
        end
    end
    html = html .. '</tbody></table></div></div>'
    return html
end

-- // ============================================================
-- // REMOTES SECTION
-- // ============================================================
local function BuildRemotesSection()
    local html = string.format([[
<div id="remotes" class="section">
    <h2>Remote Events & Functions</h2>
    <div class="stat-grid">
        <div class="stat-card"><div class="value">%d</div><div class="label">RemoteEvents</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">RemoteFunctions</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Bindable</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">⚠️ Şüpheli</div></div>
    </div>
    <h3>Şüpheli Remote Listesi</h3>
    <table><thead><tr><th>Ad</th><th>Tür</th><th>Path</th><th>Şüphe Sebebi</th></tr></thead><tbody>
]], #(D.Remotes.RemoteEvents or {}), #(D.Remotes.RemoteFunctions or {}),
   #(D.Remotes.BindableEvents or {}) + #(D.Remotes.BindableFunctions or {}), stats.SuspiciousRemotes)

    for _, r in ipairs(D.Remotes.SuspiciousRemotes or {}) do
        html = html .. string.format('<tr><td><strong>%s</strong></td><td>%s</td><td style="font-size:11px;color:var(--text-muted)">%s</td><td>%s</td></tr>',
            HE(r.Name), r.Type, HE(r.FullPath), table.concat(r.SuspiciousReasons or {}, ", "))
    end
    html = html .. '</tbody></table></div>'
    return html
end

-- // ============================================================
-- // ANTI-CHEAT SECTION
-- // ============================================================
local function BuildAntiCheatSection()
    local html = string.format([[
<div id="antichat" class="section">
    <h2>Anti-Cheat & Koruma Analizi</h2>
    <div class="stat-grid">
        <div class="stat-card"><div class="value">%d</div><div class="label">Toplam Bulgu</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Korumalı Script</div></div>
    </div>
    <table><thead><tr><th>Script</th><th>Path</th><th>Tespitler</th><th>Risk</th></tr></thead><tbody>
]], stats.ACFindings, stats.ACProtected)

    for _, s in ipairs(D.AntiCheat.Scripts_With_Protection or {}) do
        local detections, maxSev = {}, "LOW"
        if s.ACFindings then
            for _, f in ipairs(s.ACFindings) do
                table.insert(detections, f.Name)
                if f.Severity == "CRITICAL" then maxSev = "CRITICAL"
                elseif f.Severity == "HIGH" and maxSev ~= "CRITICAL" then maxSev = "HIGH"
                elseif f.Severity == "MEDIUM" and maxSev ~= "CRITICAL" and maxSev ~= "HIGH" then maxSev = "MEDIUM" end
            end
        end
        html = html .. string.format('<tr><td><strong>%s</strong></td><td style="font-size:11px;color:var(--text-muted)">%s</td><td>%s</td><td><span class="severity-%s">%s</span></td></tr>',
            HE(s.Name), HE(s.FullPath), table.concat(detections, ", "), maxSev, maxSev)
    end
    html = html .. '</tbody></table></div>'
    return html
end

-- // ============================================================
-- // GUI SECTION
-- // ============================================================
local function BuildGUISection()
    local html = string.format([[
<div id="gui" class="section">
    <h2>GUI Yapısı</h2>
    <div class="stat-grid">
        <div class="stat-card"><div class="value">%d</div><div class="label">Toplam Element</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">ScreenGui</div></div>
        <div class="stat-card"><div class="value">%d</div><div class="label">Admin Paneli</div></div>
    </div>
    <table><thead><tr><th>Ad</th><th>Sınıf</th><th>Görünür</th><th>Pozisyon</th><th>Boyut</th></tr></thead><tbody>
]], stats.GUIElements, #(D.GUI.ScreenGuis or {}), stats.AdminPanels)

    for _, g in ipairs(D.GUI.ScreenGuis or {}) do
        html = html .. string.format('<tr><td><strong>%s</strong>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>',
            HE(g.Name), g.IsAdmin and ' <span class="badge badge-admin">ADMIN</span>' or '',
            g.Class, g.Visible and "✅" or "❌", g.Position, g.Size)
    end
    html = html .. '</tbody></table></div>'
    return html
end

-- // ============================================================
-- // NETWORK SECTION
-- // ============================================================
local function BuildNetworkSection()
    local html = string.format([[
<div id="network" class="section">
    <h2>Network Trafiği</h2>
    <p style="color:var(--text-muted);margin-bottom:16px;">Son %d remote çağrısı loglandı. Hook: %s</p>
    <table><thead><tr><th>Zaman</th><th>Remote</th><th>Method</th><th>Args</th><th>Tipler</th></tr></thead><tbody>
]], stats.TrafficEntries, stats.NetworkHooks and "✅ Aktif" or "❌ Pasif")

    for _, t in ipairs(D.Network.TrafficLog or {}) do
        html = html .. string.format('<tr><td>%s</td><td>%s</td><td>%s</td><td>%d</td><td>%s</td></tr>',
            t.Time, HE(t.RemoteName), t.Method, t.ArgCount, table.concat(t.ArgTypes or {}, ", "))
    end
    html = html .. '</tbody></table></div>'
    return html
end

-- // ============================================================
-- // FOOTER + JAVASCRIPT
-- // ============================================================
local function BuildFooter()
    return string.format([[
<div class="footer">
    Generated by Axiom Extraction Engine | %s | Game: %s | Place: %s
</div>
<script>
function showSection(id, btn) {
    document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
    document.querySelectorAll('.nav button').forEach(b => b.classList.remove('active'));
    document.getElementById(id).classList.add('active');
    btn.classList.add('active');
}
function filterTable(tableId, query) {
    document.querySelectorAll('#' + tableId + ' tbody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(query.toLowerCase()) ? '' : 'none';
    });
}
function copyCode(btn, code) {
    navigator.clipboard.writeText(code).then(() => {
        btn.textContent = 'Kopyalandı!'; btn.classList.add('copied');
        setTimeout(() => { btn.textContent = 'Kopyala'; btn.classList.remove('copied'); }, 2000);
    });
}
</script>
</div>
</body>
</html>
]], os.date("%Y-%m-%d %H:%M:%S"), HE(D.Meta.GameName), D.Meta.PlaceId)
end

-- // ============================================================
-- // BUILD COMPLETE HTML
-- // ============================================================
local function BuildHTML()
    print("[INFO] HTML raporu oluşturuluyor...")
    local parts = {
        BuildHeader(),
        BuildOverview(),
        BuildScriptsSection(),
        BuildRemotesSection(),
        BuildAntiCheatSection(),
        BuildGUISection(),
        BuildNetworkSection(),
        BuildFooter()
    }
    local html = table.concat(parts, "\n")
    print(string.format("[OK] HTML raporu oluşturuldu (%d karakter)", #html))
    return html
end

-- // ============================================================
-- // EXECUTE
-- // ============================================================
local report = BuildHTML()

-- Panoya kopyala
pcall(function()
    setclipboard(report)
    print("[OK] Rapor panoya kopyalandı!")
end)

-- Global değişkene kaydet
getgenv().AxiomReport = report

-- Public API
getgenv().AxiomData.GetHTMLReport = function() return report end
getgenv().AxiomData.RegenerateHTML = function()
    report = BuildHTML()
    getgenv().AxiomReport = report
    pcall(function() setclipboard(report) end)
    return report
end

print([[
╔═══════════════════════════════════════╗
║ PARÇA 2/2 TAMAMLANDI                 ║
║ HTML raporu oluşturuldu              ║
║ ✅ 


return report
