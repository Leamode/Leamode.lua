--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           SmartCodeRedeemer v2.1 - Full Menu System          ║
    ║           Author: C.C.                                       ║
    ║           Target Admin: 14tza                                ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  - Advanced multi-pattern code extraction engine             ║
    ║  - Automatic remote candidate scanner + scoring              ║
    ║  - 8 different FireServer formats                            ║
    ║  - Full GUI menu (RightShift ile aç/kapa)                    ║
    ║  - Live log, real-time stats, remote list                    ║
    ║  - Tried codes / Blacklist support                           ║
    ║  - Near-zero delay fire                                      ║
    ║  - Deduplication + anti-spam                                 ║
    ║  - Manual remote path support                                ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LOCAL_PLAYER = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
--                              CONFIG
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    AdminName = "14tza",
    ToggleKey = Enum.KeyCode.RightShift,

    MinCodeLength = 3,
    MaxCodeLength = 52,

    FireDelay = 0.00003,
    MaxFormats = 8,
    MaxRemotesPerCode = 14,

    AutoScanOnStart = true,
    AutoScanInterval = 40,
    EnableNotifications = true,
    DebugMode = true,

    -- Spy'dan bulduğun path'i buraya yaz (öncelikli kullanılır)
    -- Örnek: "ReplicatedStorage.Packages.Net.RE/XXXX-XXXX-XXXX"
    ManualRemotePath = nil,
}

-- ═══════════════════════════════════════════════════════════════
--                           STATE
-- ═══════════════════════════════════════════════════════════════

local State = {
    Enabled = true,
    TriedCodes = {},
    Blacklist = {},
    CandidateRemotes = {},
    ManualRemote = nil,
    TotalCaught = 0,
    TotalFired = 0,
    LastCode = "",
    LogLines = {},
    MaxLogLines = 150,
    GuiVisible = false,
    Scanning = false,
}

-- ═══════════════════════════════════════════════════════════════
--                        KEYWORD LISTS
-- ═══════════════════════════════════════════════════════════════

local Keywords = {
    "code", "kod", "redeem", "claim", "strawberry", "strawbery",
    "promo", "reward", "gift", "key", "token", "coupon", "voucher",
    "redeemcode", "claimcode", "usecode", "enter", "submit",
    "bonus", "free", "drop", "giveaway", "eventcode", "promo code"
}

local RemoteNameKeywords = {
    "code", "redeem", "claim", "promo", "reward", "gift",
    "key", "coupon", "poll", "admin", "submit", "use", "token"
}

-- ═══════════════════════════════════════════════════════════════
--                           UTILITIES
-- ═══════════════════════════════════════════════════════════════

local function log(level, ...)
    local msg = table.concat({...}, " ")
    local prefix = ({
        INFO  = "[INFO]",
        WARN  = "[WARN]",
        ERROR = "[ERROR]",
        CATCH = "[CATCH]",
        FIRE  = "[FIRE]",
        SCAN  = "[SCAN]",
        SYS   = "[SYS]"
    })[level] or "[LOG]"

    local line = prefix .. " " .. msg
    table.insert(State.LogLines, 1, line)
    if #State.LogLines > State.MaxLogLines then
        table.remove(State.LogLines)
    end

    if CONFIG.DebugMode or level == "ERROR" or level == "CATCH" then
        print("[C.C. Redeemer]", line)
    end

    if State.RefreshLog then
        pcall(State.RefreshLog)
    end
end

local function notify(title, text)
    if not CONFIG.EnableNotifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

local function clean(str)
    if typeof(str) ~= "string" then return "" end
    return str:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[%c%z]", "")
end

local function isValidCode(str)
    if typeof(str) ~= "string" then return false end
    local len = #str
    if len < CONFIG.MinCodeLength or len > CONFIG.MaxCodeLength then return false end
    if str:find("https?://") or str:find("www%.") then return false end
    if str:lower() == CONFIG.AdminName:lower() then return false end
    if State.Blacklist[str:lower()] then return false end
    return true
end

-- ═══════════════════════════════════════════════════════════════
--                     CODE EXTRACTION ENGINE
-- ═══════════════════════════════════════════════════════════════

local function extractCodes(msg)
    local results = {}
    local seen = {}

    local function add(code)
        code = clean(code)
        if isValidCode(code) then
            local key = code:lower()
            if not seen[key] then
                seen[key] = true
                table.insert(results, code)
            end
        end
    end

    -- 1. Çift tırnak
    for code in msg:gmatch('"([^"]+)"') do
        add(code)
    end

    -- 2. Tek tırnak
    for code in msg:gmatch("'([^']+)'") do
        add(code)
    end

    -- 3. Keyword tabanlı yakalama
    local lower = msg:lower()
    for _, kw in ipairs(Keywords) do
        local patterns = {
            kw .. "%s*[:=%-]+%s*([%w%-%_%.]+)",
            kw .. "%s+([%w%-%_%.]+)",
            kw .. "%s*[:=%-]*%s*\"([^\"]+)\"",
            kw .. "%s*[:=%-]*%s*'([^']+)'",
        }
        for _, pat in ipairs(patterns) do
            for match in lower:gmatch(pat) do
                local real = msg:match(pat) or match
                add(real)
            end
        end
    end

    -- 4. Son kelime
    local last = msg:match("([%w%-%_]+)[%s%p]*$")
    if last then add(last) end

    -- 5. Büyük harf + rakam blokları
    for block in msg:gmatch("([A-Z][A-Z0-9%-%_]{3,})") do
        add(block)
    end

    -- 6. İçinde rakam olan olası kodlar
    for block in msg:gmatch("([A-Za-z0-9%-%_]*%d+[A-Za-z0-9%-%_]*)") do
        if #block >= 5 then add(block) end
    end

    return results
end

-- ═══════════════════════════════════════════════════════════════
--                      REMOTE SCANNER
-- ═══════════════════════════════════════════════════════════════

local function isRemote(obj)
    return obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction")
        or obj:IsA("UnreliableRemoteEvent")
end

local function scanRemotes()
    if State.Scanning then return end
    State.Scanning = true
    log("SCAN", "Remote taraması başladı...")

    local newCandidates = {}
    local seen = {}

    local function consider(obj)
        if not isRemote(obj) then return end
        local path = obj:GetFullName()
        if seen[path] then return end
        seen[path] = true

        local nameL = obj.Name:lower()
        local pathL = path:lower()
        local score = 0

        for _, kw in ipairs(RemoteNameKeywords) do
            if nameL:find(kw) then score = score + 4 end
            if pathL:find(kw) then score = score + 1 end
        end

        if pathL:find("packages%.net") then
            score = score + 1
        end

        if score > 0 then
            table.insert(newCandidates, {
                Remote = obj,
                Path = path,
                Score = score,
                Name = obj.Name,
                Class = obj.ClassName
            })
        end
    end

    for _, obj in ipairs(game:GetDescendants()) do
        consider(obj)
    end

    table.sort(newCandidates, function(a, b)
        return a.Score > b.Score
    end)

    State.CandidateRemotes = newCandidates
    State.Scanning = false

    log("SCAN", string.format("%d aday remote bulundu", #newCandidates))
    if State.RefreshStats then pcall(State.RefreshStats) end
end

local function resolveManualRemote()
    if not CONFIG.ManualRemotePath or CONFIG.ManualRemotePath == "" then
        State.ManualRemote = nil
        return
    end

    local ok, result = pcall(function()
        local parts = string.split(CONFIG.ManualRemotePath, ".")
        local current = game
        for _, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then
                -- alternatif index denemesi
                current = current and current[part]
            end
            if not current then return nil end
        end
        return current
    end)

    if ok and result and isRemote(result) then
        State.ManualRemote = result
        log("SYS", "Manuel remote yüklendi:", CONFIG.ManualRemotePath)
    else
        State.ManualRemote = nil
        log("WARN", "Manuel remote resolve edilemedi")
    end
end

-- ═══════════════════════════════════════════════════════════════
--                         FIRE ENGINE
-- ═══════════════════════════════════════════════════════════════

local FireFormats = {
    function(r, c) r:FireServer(c) end,
    function(r, c) r:FireServer({Code = c}) end,
    function(r, c) r:FireServer({code = c}) end,
    function(r, c) r:FireServer(c, true) end,
    function(r, c) r:FireServer({["Code"] = c}) end,
    function(r, c) r:FireServer({Value = c}) end,
    function(r, c) r:FireServer({code = c, redeem = true}) end,
    function(r, c) r:FireServer(c, false) end,
}

local function fireCode(code)
    local key = code:lower()
    if State.TriedCodes[key] then return end
    State.TriedCodes[key] = true
    State.TotalCaught = State.TotalCaught + 1
    State.LastCode = code

    log("CATCH", "Yakalandı → " .. code)
    notify("Code Yakalandı", code)

    local targets = {}
    if State.ManualRemote then
        table.insert(targets, State.ManualRemote)
    end

    local added = 0
    for _, entry in ipairs(State.CandidateRemotes) do
        if added >= CONFIG.MaxRemotesPerCode then break end
        table.insert(targets, entry.Remote)
        added = added + 1
    end

    if #targets == 0 then
        log("WARN", "Ateşlenecek remote yok. Path ayarla veya tarama yap.")
        return
    end

    for _, remote in ipairs(targets) do
        for i, fmt in ipairs(FireFormats) do
            if i > CONFIG.MaxFormats then break end
            task.defer(function()
                local ok = pcall(fmt, remote, code)
                if ok then
                    State.TotalFired = State.TotalFired + 1
                end
            end)
            task.wait(CONFIG.FireDelay)
        end
    end

    if State.RefreshStats then pcall(State.RefreshStats) end
end

-- ═══════════════════════════════════════════════════════════════
--                       CHAT LISTENERS
-- ═══════════════════════════════════════════════════════════════

local function processMessage(text, speakerName)
    if not State.Enabled then return end
    if speakerName:lower() ~= CONFIG.AdminName:lower() then return end

    local codes = extractCodes(text)
    for _, code in ipairs(codes) do
        fireCode(code)
    end
end

local function setupChat()
    if TextChatService then
        TextChatService.MessageReceived:Connect(function(message)
            local src = message.TextSource
            if not src then return end
            local plr = Players:GetPlayerByUserId(src.UserId)
            if plr then
                processMessage(message.Text, plr.Name)
            end
        end)
    end

    Players.PlayerChatted:Connect(function(player, message)
        processMessage(message, player.Name)
    end)

    log("SYS", "Chat dinleyicileri aktif | Admin: " .. CONFIG.AdminName)
end

-- ═══════════════════════════════════════════════════════════════
--                              GUI
-- ═══════════════════════════════════════════════════════════════

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SmartCodeRedeemerGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = false

    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LOCAL_PLAYER:WaitForChild("PlayerGui")
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 540, 0, 440)
    Main.Position = UDim2.new(0.5, -270, 0.5, -220)
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = Main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 75)
    stroke.Thickness = 1.2
    stroke.Parent = Main

    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 38)
    TitleBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 10)
    tCorner.Parent = TitleBar

    local tFix = Instance.new("Frame")
    tFix.Size = UDim2.new(1, 0, 0, 14)
    tFix.Position = UDim2.new(0, 0, 1, -14)
    tFix.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    tFix.BorderSizePixel = 0
    tFix.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SmartCodeRedeemer v2.1  |  C.C."
    Title.TextColor3 = Color3.fromRGB(210, 210, 230)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 34, 0, 24)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 5)
    cCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        State.GuiVisible = false
    end)

    -- Left Panel
    local Left = Instance.new("Frame")
    Left.Size = UDim2.new(0, 190, 1, -52)
    Left.Position = UDim2.new(0, 12, 0, 46)
    Left.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Left.BorderSizePixel = 0
    Left.Parent = Main

    local lCorner = Instance.new("UICorner")
    lCorner.CornerRadius = UDim.new(0, 8)
    lCorner.Parent = Left

    local function makeLabel(parent, text, y, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -16, 0, 18)
        l.Position = UDim2.new(0, 8, 0, y)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or Color3.fromRGB(175, 175, 195)
        l.TextSize = 12
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end

    makeLabel(Left, "İSTATİSTİK", 10, Color3.fromRGB(130, 190, 255)).Font = Enum.Font.GothamBold

    local StatCaught = makeLabel(Left, "Yakalanan: 0", 36)
    local StatFired  = makeLabel(Left, "Ateşlenen: 0", 56)
    local StatLast   = makeLabel(Left, "Son Code: -", 76)
    local StatRemotes= makeLabel(Left, "Aday Remote: 0", 96)

    State.RefreshStats = function()
        StatCaught.Text = "Yakalanan: " .. State.TotalCaught
        StatFired.Text  = "Ateşlenen: " .. State.TotalFired
        StatLast.Text   = "Son Code: " .. (State.LastCode ~= "" and State.LastCode or "-")
        StatRemotes.Text= "Aday Remote: " .. #State.CandidateRemotes
    end

    -- Buttons
    local function makeBtn(text, y, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 30)
        b.Position = UDim2.new(0, 8, 0, y)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.Parent = Left
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = b
        b.MouseButton1Click:Connect(callback)
        return b
    end

    local ToggleBtn = makeBtn("SİSTEM: AÇIK", 140, Color3.fromRGB(35, 145, 65), function()
        State.Enabled = not State.Enabled
        if State.Enabled then
            ToggleBtn.Text = "SİSTEM: AÇIK"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 145, 65)
            log("SYS", "Sistem açıldı")
        else
            ToggleBtn.Text = "SİSTEM: KAPALI"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
            log("SYS", "Sistem kapatıldı")
        end
    end)

    makeBtn("REMOTE TARA", 180, Color3.fromRGB(45, 95, 170), function()
        task.spawn(scanRemotes)
    end)

    makeBtn("TRIED TEMİZLE", 220, Color3.fromRGB(130, 85, 35), function()
        State.TriedCodes = {}
        log("SYS", "Tried listesi temizlendi")
        notify("Temizlendi", "Tried codes sıfırlandı")
    end)

    makeLabel(Left, "Admin: " .. CONFIG.AdminName, 270, Color3.fromRGB(255, 175, 70))
    makeLabel(Left, "Menü: RightShift", 290, Color3.fromRGB(140, 140, 160))

    -- Right Panel (Log)
    local Right = Instance.new("Frame")
    Right.Size = UDim2.new(1, -220, 1, -52)
    Right.Position = UDim2.new(0, 212, 0, 46)
    Right.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Right.BorderSizePixel = 0
    Right.Parent = Main

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 8)
    rCorner.Parent = Right

    local LogTitle = Instance.new("TextLabel")
    LogTitle.Size = UDim2.new(1, -16, 0, 22)
    LogTitle.Position = UDim2.new(0, 8, 0, 6)
    LogTitle.BackgroundTransparency = 1
    LogTitle.Text = "CANLI LOG"
    LogTitle.TextColor3 = Color3.fromRGB(130, 190, 255)
    LogTitle.TextSize = 13
    LogTitle.Font = Enum.Font.GothamBold
    LogTitle.TextXAlignment = Enum.TextXAlignment.Left
    LogTitle.Parent = Right

    local LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Size = UDim2.new(1, -16, 1, -40)
    LogScroll.Position = UDim2.new(0, 8, 0, 32)
    LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    LogScroll.BorderSizePixel = 0
    LogScroll.ScrollBarThickness = 5
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.Parent = Right

    local lsCorner = Instance.new("UICorner")
    lsCorner.CornerRadius = UDim.new(0, 6)
    lsCorner.Parent = LogScroll

    local LogList = Instance.new("UIListLayout")
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 2)
    LogList.Parent = LogScroll

    State.RefreshLog = function()
        for _, child in ipairs(LogScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        for i, line in ipairs(State.LogLines) do
            if i > 50 then break end
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = line
            lbl.TextColor3 = Color3.fromRGB(185, 185, 205)
            lbl.TextSize = 11
            lbl.Font = Enum.Font.Code
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = LogScroll
        end
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 12)
    end

    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == CONFIG.ToggleKey then
            State.GuiVisible = not State.GuiVisible
            ScreenGui.Enabled = State.GuiVisible
            if State.GuiVisible then
                State.RefreshStats()
                State.RefreshLog()
            end
        end
    end)

    log("SYS", "GUI hazır. RightShift ile aç/kapa")
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════
--                            INIT
-- ═══════════════════════════════════════════════════════════════

local function init()
    log("SYS", "SmartCodeRedeemer v2.1 yükleniyor...")

    resolveManualRemote()

    if CONFIG.AutoScanOnStart then
        task.spawn(function()
            task.wait(1.8)
            scanRemotes()
        end)
    end

    task.spawn(function()
        while true do
            task.wait(CONFIG.AutoScanInterval)
            if State.Enabled then
                scanRemotes()
            end
        end
    end)

    setupChat()
    createGUI()

    log("SYS", "Sistem hazır. Dinlenen admin: " .. CONFIG.AdminName)
    notify("SmartCodeRedeemer", "Aktif | RightShift = Menü")
end

init()
]]
