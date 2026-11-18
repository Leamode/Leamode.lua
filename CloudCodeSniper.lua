--[[
    CloudCodeSniper v1.3
    Instant mode
    - "this code" / "code" dedikten sonraki 3 kelimeyi anında alır
    - 0 delay ile peş peşe yazar
    - Parça bekleme yok, timeout yok
    Admin: 14tza
]]

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LOCAL_PLAYER = Players.LocalPlayer
local PlayerGui = LOCAL_PLAYER:WaitForChild("PlayerGui")
local Mouse = LOCAL_PLAYER:GetMouse()

-- ══════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════
local CONFIG = {
    AdminName = "14tza",
    ToggleKey = Enum.KeyCode.RightShift,

    InstantPaste = true,
    AutoEnter = true,
    EnableNotifications = true,

    -- "this code" sonrası kaç kelime alınacak
    WordsAfterTrigger = 3,
}

-- ══════════════════════════════════════
-- STATE
-- ══════════════════════════════════════
local State = {
    Enabled = true,
    TargetBox = nil,
    Tried = {},
    TotalCaught = 0,
    LastCode = "",
    GuiVisible = false,
}

-- ══════════════════════════════════════
-- UTIL
-- ══════════════════════════════════════
local function notify(title, text)
    if not CONFIG.EnableNotifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2.8
        })
    end)
end

local function log(msg)
    print("[CloudSniper]", msg)
end

local function clean(s)
    if typeof(s) ~= "string" then return "" end
    s = s:gsub("[^%w%s%-%_%.]", "")
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

-- ══════════════════════════════════════
-- TEXTBOX
-- ══════════════════════════════════════
local function isTextBox(obj)
    return obj and obj:IsA("TextBox")
end

local function setTarget(box)
    if isTextBox(box) then
        State.TargetBox = box
        log("Hedef kilitlendi")
        notify("Hedef Alındı", "Kod kutusu kilitlendi")
        if State.RefreshTarget then pcall(State.RefreshTarget) end
        return true
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not State.Enabled then return end

    local objs = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
    for _, obj in ipairs(objs) do
        if isTextBox(obj) then
            setTarget(obj)
            return
        end
        local p = obj
        for _ = 1, 6 do
            p = p and p.Parent
            if not p then break end
            if isTextBox(p) then
                setTarget(p)
                return
            end
        end
    end
end)

local function typeIntoBox(box, text)
    if not isTextBox(box) or not box.Parent then return false end

    local ok = pcall(function()
        box:CaptureFocus()
        box.Text = text

        if CONFIG.AutoEnter then
            task.defer(function()
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end)
            end)
        end
    end)
    return ok
end

local function writeCode(code)
    code = clean(code)
    if #code < 2 then return end

    local key = code:lower():gsub("%s+", "")
    if State.Tried[key] then return end
    State.Tried[key] = true
    State.TotalCaught += 1
    State.LastCode = code

    log("YAZILIYOR → " .. code)
    notify("Sniped", code)

    if State.TargetBox and State.TargetBox.Parent then
        typeIntoBox(State.TargetBox, code)
    else
        log("Hedef yok! Kutuya tıkla.")
        notify("Hedef Yok", "Önce kod kutusuna tıkla")
    end

    if State.RefreshStats then pcall(State.RefreshStats) end
end

-- ══════════════════════════════════════
-- INSTANT EXTRACTION
-- "this code" / "code" sonrası 3 kelimeyi al
-- ══════════════════════════════════════
local Triggers = {
    "this code",
    "the code",
    "code is",
    "code:",
    "code =",
    "kod",
    "kod:",
    "redeem",
    "claim",
    "strawberry",
    "strawbery",
}

local function extractInstant(msg)
    local lower = msg:lower()
    local results = {}

    -- 1. Tırnak içi (en net)
    for c in msg:gmatch('"([^"]+)"') do
        local cl = clean(c)
        if #cl >= 2 then table.insert(results, cl) end
    end
    for c in msg:gmatch("'([^']+)'") do
        local cl = clean(c)
        if #cl >= 2 then table.insert(results, cl) end
    end

    -- 2. Trigger kelimesinden sonraki 3 kelime
    for _, trig in ipairs(Triggers) do
        local pos = lower:find(trig, 1, true)
        if pos then
            local after = msg:sub(pos + #trig)
            after = after:gsub("^[%s:=%-]+", "")

            local words = {}
            for word in after:gmatch("[%w%-%_]+") do
                table.insert(words, word)
                if #words >= CONFIG.WordsAfterTrigger then break end
            end

            if #words > 0 then
                for _, w in ipairs(words) do
                    table.insert(results, w)
                end
                if #words >= 2 then
                    table.insert(results, table.concat(words, " "))
                    table.insert(results, table.concat(words, ""))
                end
            end
        end
    end

    -- 3. Hiçbir şey yoksa ve mesaj kısaysa direkt al
    if #results == 0 then
        local cleaned = clean(msg)
        if #cleaned >= 2 and #cleaned <= 30 and not cleaned:find(" ") then
            table.insert(results, cleaned)
        end
    end

    return results
end

-- ══════════════════════════════════════
-- PROCESS (ANINDA)
-- ══════════════════════════════════════
local function process(msg, name)
    if not State.Enabled then return end
    if name:lower() ~= CONFIG.AdminName:lower() then return end

    local codes = extractInstant(msg)
    if #codes == 0 then return end

    -- anında peş peşe yaz (delay yok)
    for i, code in ipairs(codes) do
        task.defer(function()
            writeCode(code)
        end)
    end
end

-- ══════════════════════════════════════
-- CHAT
-- ══════════════════════════════════════
if TextChatService then
    TextChatService.MessageReceived:Connect(function(m)
        local src = m.TextSource
        if src then
            local plr = Players:GetPlayerByUserId(src.UserId)
            if plr then process(m.Text, plr.Name) end
        end
    end)
end

Players.PlayerChatted:Connect(function(plr, msg)
    process(msg, plr.Name)
end)

-- ══════════════════════════════════════
-- GUI
-- ══════════════════════════════════════
local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CloudCodeSniper"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Enabled = false
    gui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 360, 0, 270)
    main.Position = UDim2.new(0.5, -180, 0.5, -135)
    main.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    main.BackgroundTransparency = 0.12
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 1.1
    stroke.Transparency = 0.35
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 34)
    title.Position = UDim2.new(0, 16, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "☁  Cloud Code Sniper"
    title.TextColor3 = Color3.fromRGB(195, 215, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -36, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(170, 50, 60)
    close.BackgroundTransparency = 0.2
    close.Text = "✕"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 14
    close.Font = Enum.Font.GothamBold
    close.Parent = main
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = close
    close.MouseButton1Click:Connect(function()
        gui.Enabled = false
        State.GuiVisible = false
    end)

    local function lbl(text, y, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -32, 0, 19)
        l.Position = UDim2.new(0, 16, 0, y)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or Color3.fromRGB(170, 180, 210)
        l.TextSize = 13
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = main
        return l
    end

    local statusLbl = lbl("Durum: AKTİF", 50, Color3.fromRGB(120, 220, 150))
    local targetLbl = lbl("Hedef: Yok (kutuya tıkla)", 74)
    local caughtLbl = lbl("Yakalanan: 0", 98)
    local lastLbl   = lbl("Son Code: -", 122)

    State.RefreshStats = function()
        statusLbl.Text = State.Enabled and "Durum: AKTİF" or "Durum: KAPALI"
        statusLbl.TextColor3 = State.Enabled and Color3.fromRGB(120, 220, 150) or Color3.fromRGB(220, 110, 110)
        caughtLbl.Text = "Yakalanan: " .. State.TotalCaught
        lastLbl.Text = "Son Code: " .. (State.LastCode ~= "" and State.LastCode or "-")
    end

    State.RefreshTarget = function()
        if State.TargetBox and State.TargetBox.Parent then
            targetLbl.Text = "Hedef: Kilitlendi ✓"
            targetLbl.TextColor3 = Color3.fromRGB(120, 220, 160)
        else
            targetLbl.Text = "Hedef: Yok (kutuya tıkla)"
            targetLbl.TextColor3 = Color3.fromRGB(220, 170, 100)
        end
    end

    local function btn(text, y, color, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -32, 0, 30)
        b.Position = UDim2.new(0, 16, 0, y)
        b.BackgroundColor3 = color
        b.BackgroundTransparency = 0.2
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.Parent = main
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 8)
        bc.Parent = b
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local toggleBtn = btn("Sistemi Kapat", 160, Color3.fromRGB(40, 130, 70), function()
        State.Enabled = not State.Enabled
        toggleBtn.Text = State.Enabled and "Sistemi Kapat" or "Sistemi Aç"
        toggleBtn.BackgroundColor3 = State.Enabled and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(140, 50, 50)
        State.RefreshStats()
    end)

    btn("Tried Temizle", 198, Color3.fromRGB(85, 80, 140), function()
        State.Tried = {}
        log("Tried temizlendi")
        notify("Temiz", "Liste sıfırlandı")
    end)

    btn("Hedefi Sıfırla", 236, Color3.fromRGB(120, 80, 40), function()
        State.TargetBox = nil
        State.RefreshTarget()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == CONFIG.ToggleKey then
            State.GuiVisible = not State.GuiVisible
            gui.Enabled = State.GuiVisible
            if State.GuiVisible then
                State.RefreshStats()
                State.RefreshTarget()
            end
        end
    end)

    log("GUI hazır | RightShift = menü")
end

-- ══════════════════════════════════════
-- START
-- ══════════════════════════════════════
createGUI()
log("CloudCodeSniper v1.3 Instant aktif")
log("Admin: " .. CONFIG.AdminName)
log('"this code" sonrası 3 kelime anında yazılır')
notify("Cloud Sniper", "Instant mode | RightShift = Menü")
