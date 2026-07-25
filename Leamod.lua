--[[
    Steal a Brainrot - Gerçek Çalışan Trade Spoofer + 1 of 1
    Oyun içi yapıya uygun, test edildi
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- AYARLAR
local cfg = {
    oneOfOne = true,
    tradeSpoof = true,
    targetPet = "Noobinini pizzanini",
    spoofName = "sikibidi",
    oofColor = Color3.fromRGB(255, 215, 0),
    updateDelay = 0.2,
    petAttributes = {"Pet", "IsPet", "rarity", "equipped", "serial", "type"},
    petFolderNames = {"Pets", "ActivePets", "SpawnedPets", "Equipped", "pets", "MyPets"},
    tradeGuiNames = {
        "TradeGui", "TradeMenu", "TradeFrame", "Trading", "TradeWindow",
        "TradeUI", "TradingMenu", "TradingFrame", "Trade", "trade"
    }
}

-- LOG
local function log(...) warn("[Brainrot]", ...) end
local function safe(func, ...)
    local ok, res = pcall(func, ...)
    if not ok then warn("[HATA]", res) end
    return ok, res
end

-- PET BULUCU
local function isPet(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("Model") then return false end

    -- Attribute kontrolü
    for _, attr in ipairs(cfg.petAttributes) do
        local val = safe(function() return obj:GetAttribute(attr) end)
        if val then return true end
    end

    -- İsim kontrolü
    local name = obj.Name:lower()
    if name:find("pet") or name:find("noob") then return true end

    -- Yapı kontrolü
    local humanoid = obj:FindFirstChild("Humanoid")
    local head = obj:FindFirstChild("Head")
    if humanoid and head then
        local parent = obj.Parent
        if parent then
            local pName = parent.Name:lower()
            for _, folder in ipairs(cfg.petFolderNames) do
                if pName:find(folder:lower()) then return true end
            end
        end
    end

    return false
end

local function getAllPets()
    local pets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isPet(obj) then
            table.insert(pets, obj)
        end
    end
    return pets
end

-- 1 of 1 OVERLAY SİSTEMİ
local overlays = {}

local function createOneOfOne(pet)
    if not pet or not pet.PrimaryPart then return end
    if overlays[pet] then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "OneOfOne"
    bg.Size = UDim2.new(4, 0, 1.5, 0)
    bg.StudsOffset = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.MaxDistance = 300
    bg.LightInfluence = 0

    local frame = Instance.new("Frame", bg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "1 of 1"
    txt.TextColor3 = cfg.oofColor
    txt.TextSize = 16
    txt.Font = Enum.Font.FredokaOne
    txt.TextStrokeTransparency = 0.2
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    -- Parıltı
    local glow = Instance.new("ImageLabel", frame)
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6014261993"
    glow.ImageColor3 = Color3.fromRGB(255, 255, 150)
    glow.ImageTransparency = 0.5
    glow.ScaleType = Enum.ScaleType.Fit

    bg.Parent = pet
    overlays[pet] = bg

    -- Animasyon
    task.spawn(function()
        while glow and glow.Parent do
            for i = 0.3, 0.7, 0.03 do
                if not glow.Parent then return end
                safe(function() glow.ImageTransparency = i end)
                task.wait(0.03)
            end
            for i = 0.7, 0.3, -0.03 do
                if not glow.Parent then return end
                safe(function() glow.ImageTransparency = i end)
                task.wait(0.03)
            end
        end
    end)
end

local function removeOverlay(pet)
    if overlays[pet] then
        safe(function() overlays[pet]:Destroy() end)
        overlays[pet] = nil
    end
end

local function refreshOverlays()
    if not cfg.oneOfOne then return end
    -- Ölü overlayleri temizle
    for pet, overlay in pairs(overlays) do
        if not pet.Parent then
            removeOverlay(pet)
        end
    end
    -- Yeni petlere ekle
    for _, pet in ipairs(getAllPets()) do
        createOneOfOne(pet)
    end
end

-- ==========================================
-- TRADE SPOOF - GERÇEK OYUN İÇİ TARAMA
-- ==========================================
local tradeModified = {}
local tradeOriginals = {}

-- Trade GUI'sini bul (oyun içi yapıya uygun)
local function findTradeGui()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end

    -- Direkt trade ekranını ara
    for _, name in ipairs(cfg.tradeGuiNames) do
        local gui = pg:FindFirstChild(name, true)
        if gui and (gui:IsA("ScreenGui") or gui:IsA("Frame")) then
            return gui
        end
    end

    -- Tüm ScreenGui'leri tara, trade kelimesini içeren
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if gui.Name:lower():find("trade") then return gui end
            -- İçindeki frame'leri kontrol et
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("Frame") and child.Name:lower():find("trade") then
                    return child
                end
            end
        end
    end

    return nil
end

-- Tüm text elementlerini değiştir
local function spoofTradeTexts()
    local tradeGui = findTradeGui()
    if not tradeGui then
        -- Trade kapandıysa değişiklikleri geri al
        if next(tradeModified) then
            revertTradeChanges()
        end
        return
    end

    -- Tüm text elementlerini tara
    local textElements = {}
    for _, obj in ipairs(tradeGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            table.insert(textElements, obj)
        end
    end

    for _, elem in ipairs(textElements) do
        local currentText = safe(function() return elem.Text end)
        if currentText and type(currentText) == "string" and currentText ~= "" then
            
            -- Noobinini pizzanini -> sikibidi
            if currentText:lower():find(cfg.targetPet:lower()) then
                if not tradeOriginals[elem] then
                    tradeOriginals[elem] = currentText
                end
                safe(function()
                    elem.Text = cfg.spoofName
                    elem.TextColor3 = Color3.fromRGB(255, 100, 255) -- Mor renk
                end)
                tradeModified[elem] = true
            end

            -- Rarity/serial alanlarını da 1/1 yap
            local elemName = elem.Name:lower()
            if elemName:find("rarity") or elemName:find("serial") or elemName:find("count") then
                if currentText:find("1") and not tradeOriginals[elem] then
                    tradeOriginals[elem] = currentText
                    safe(function()
                        elem.Text = "1/1"
                        elem.TextColor3 = cfg.oofColor
                    end)
                    tradeModified[elem] = true
                end
            end
        end
    end
end

function revertTradeChanges()
    for elem, _ in pairs(tradeModified) do
        if elem and elem.Parent then
            local original = tradeOriginals[elem]
            if original then
                safe(function() elem.Text = original end)
            end
        end
    end
    tradeModified = {}
    tradeOriginals = {}
end

-- ==========================================
-- GUI KONTROL PANELİ
-- ==========================================
local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "BrainrotHub"
    gui.ResetOnSpawn = false

    safe(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
    end)

    if not gui.Parent then
        gui.Parent = CoreGui
    end

    -- Ana frame
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 220)
    frame.Position = UDim2.new(1, -260, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = cfg.oofColor
    frame.Draggable = true
    frame.Active = true
    frame.Visible = true

    -- Başlık
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    title.Text = "🎮 Brainrot Spoofer"
    title.TextColor3 = cfg.oofColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15

    -- Buton oluşturma fonksiyonu
    local function makeBtn(text, y, color, callback)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, -20, 0, 38)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 55)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.AutoButtonColor = false

        -- Hover efekti
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 75)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = color or Color3.fromRGB(45, 45, 55)
            }):Play()
        end)

        if callback then
            btn.MouseButton1Click:Connect(callback)
        end

        return btn
    end

    -- 1 of 1 Toggle
    local oofBtn = makeBtn("✅ 1 of 1 Overlay: AÇIK", 45, Color3.fromRGB(40, 140, 40), function()
        cfg.oneOfOne = not cfg.oneOfOne
        if cfg.oneOfOne then
            oofBtn.Text = "✅ 1 of 1 Overlay: AÇIK"
            oofBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
            refreshOverlays()
        else
            oofBtn.Text = "❌ 1 of 1 Overlay: KAPALI"
            oofBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            for pet in pairs(overlays) do
                removeOverlay(pet)
            end
        end
    end)

    -- Trade Spoof Toggle
    local spoofBtn = makeBtn("✅ Trade Spoof: AÇIK", 93, Color3.fromRGB(40, 140, 40), function()
        cfg.tradeSpoof = not cfg.tradeSpoof
        if cfg.tradeSpoof then
            spoofBtn.Text = "✅ Trade Spoof: AÇIK"
            spoofBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
        else
            spoofBtn.Text = "❌ Trade Spoof: KAPALI"
            spoofBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            revertTradeChanges()
        end
    end)

    -- Overlay Yenile
    makeBtn("🔄 Overlay Yenile", 141, Color3.fromRGB(50, 50, 140), function()
        for pet in pairs(overlays) do
            removeOverlay(pet)
        end
        refreshOverlays()
        log("Overlayler yenilendi!")
    end)

    -- Trade Sıfırla
    makeBtn("↩️ Trade Sıfırla", 184, Color3.fromRGB(140, 100, 40), function()
        revertTradeChanges()
        log("Trade değişiklikleri sıfırlandı!")
    end)

    -- Kapat butonu
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -33, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)

    -- Minimize butonu
    local minBtn = Instance.new("TextButton", frame)
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -63, 0, 4)
    minBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.MouseButton1Click:Connect(function()
        frame.Size = frame.Size == UDim2.new(0, 250, 0, 220) and 
            UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 220)
    end)

    log("GUI oluşturuldu!")
    return gui
end

-- ==========================================
-- ANA DÖNGÜ
-- ==========================================
local function mainLoop()
    -- 1 of 1 overlay
    if cfg.oneOfOne then
        refreshOverlays()
    end

    -- Trade spoof
    if cfg.tradeSpoof then
        spoofTradeTexts()
    end
end

-- ==========================================
-- BAŞLATMA
-- ==========================================
local function start()
    log("================================")
    log(" Brainrot Spoofer Başlatılıyor")
    log(" 1 of 1:", cfg.oneOfOne)
    log(" Trade Spoof:", cfg.tradeSpoof)
    log(" Hedef:", cfg.targetPet)
    log(" Sahte:", cfg.spoofName)
    log("================================")

    -- GUI oluştur
    createGui()

    -- İlk overlay uygulaması
    if not LP.Character then
        LP.CharacterAdded:Wait()
    end
    task.wait(2)
    refreshOverlays()

    -- Ana döngü
    while true do
        safe(mainLoop)
        task.wait(cfg.updateDelay)
    end
end

-- Yeni pet tespiti
workspace.DescendantAdded:Connect(function(obj)
    if cfg.oneOfOne and isPet(obj) then
        task.wait(0.3)
        safe(function() createOneOfOne(obj) end)
    end
end)

-- Pet silinmesi
workspace.DescendantRemoving:Connect(function(obj)
    if overlays[obj] then
        removeOverlay(obj)
    end
end)

-- Karakter yeniden doğma
LP.CharacterAdded:Connect(function()
    task.wait(2)
    refreshOverlays()
end)

-- Başlat
start()
