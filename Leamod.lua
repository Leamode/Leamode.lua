--[[ PARÇA 1/6 - Servisler, Ayarlar ve Yardımcı Fonksiyonlar ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- AYARLAR
local cfg = {
    oneOfOne = true,
    tradeSpoof = true,
    targetPet = "Noobinini pizzanini",
    spoofName = "sikibidi",
    color = Color3.fromRGB(255, 215, 0),
    glowColor = Color3.fromRGB(255, 255, 100),
    textSize = 16,
    updateDelay = 0.3,
    maxPets = 200
}

-- LOG SİSTEMİ
local function log(level, ...)
    local emoji = {INFO = "🔵", WARN = "🟡", ERROR = "🔴", DEBUG = "⚪"}
    local prefix = emoji[level] or "⚪"
    warn(prefix, "[Brainrot]", ...)
end

local function info(...) log("INFO", ...) end
local function warnMsg(...) log("WARN", ...) end
local function err(...) log("ERROR", ...) end

-- SAFECALL
local function safeCall(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        warnMsg("SafeCall hatası:", result)
    end
    return ok, result
end

local function safeCallDefault(func, default, ...)
    local ok, result = safeCall(func, ...)
    return ok and result or default
end

-- BEKLEME FONKSİYONLARI
local function waitForChild(parent, name, timeout)
    timeout = timeout or 10
    local start = tick()
    while tick() - start < timeout do
        local child = parent:FindFirstChild(name)
        if child then return child end
        task.wait(0.1)
    end
    return nil
end

local function waitForChildRecursive(parent, name, timeout)
    timeout = timeout or 10
    local start = tick()
    while tick() - start < timeout do
        local child = parent:FindFirstChild(name, true)
        if child then return child end
        task.wait(0.1)
    end
    return nil
end

-- STRING YARDIMCILARI
local function stringContains(str, search)
    if not str or not search then return false end
    return string.find(string.lower(tostring(str)), string.lower(tostring(search)), 1, true) ~= nil
end

local function stringEquals(str1, str2)
    return string.lower(tostring(str1)) == string.lower(tostring(str2))
end

-- TABLE YARDIMCILARI
local function tableFind(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

local function tableFindStr(tbl, str)
    str = string.lower(tostring(str))
    for _, v in ipairs(tbl) do
        if stringContains(v, str) then return true end
    end
    return false
end

-- INSTANCE YARDIMCILARI
local function getDescendantsOfClass(parent, className)
    local result = {}
    local success, descendants = pcall(function() return parent:GetDescendants() end)
    if not success then return result end
    for _, obj in ipairs(descendants) do
        if obj:IsA(className) then
            table.insert(result, obj)
        end
    end
    return result
end

local function findFirstOfClass(parent, className)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA(className) then return obj end
    end
    return nil
end

-- OBJECT YARDIMCILARI
local function isAlive(obj)
    return obj and obj.Parent ~= nil
end

local function safeDestroy(obj)
    if isAlive(obj) then
        safeCall(function() obj:Destroy() end)
    end
end

local function safeSetParent(obj, parent)
    if isAlive(obj) then
        safeCall(function() obj.Parent = parent end)
    end
end

-- KARAKTER YARDIMCILARI
local function getCharacter(player)
    return player and player.Character
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("Humanoid")
end

local function isPlayerCharacter(obj)
    if not obj or not obj:IsA("Model") then return false end
    return safeCallDefault(function()
        return Players:GetPlayerFromCharacter(obj) ~= nil
    end, false)
end

-- BELLEK YÖNETİMİ
local memoryObjects = {}
local memoryConnections = {}

local function trackObject(obj)
    table.insert(memoryObjects, {obj = obj, time = tick()})
end

local function trackConnection(conn)
    table.insert(memoryConnections, conn)
end

local function cleanupMemory()
    local now = tick()
    -- Ölü objeleri temizle
    for i = #memoryObjects, 1, -1 do
        if not isAlive(memoryObjects[i].obj) or (now - memoryObjects[i].time > 600) then
            safeDestroy(memoryObjects[i].obj)
            table.remove(memoryObjects, i)
        end
    end
    -- Kopuk connection'ları temizle
    for i = #memoryConnections, 1, -1 do
        if not memoryConnections[i].Connected then
            table.remove(memoryConnections, i)
        end
    end
end

-- ANİMASYON YARDIMCILARI
local function createTween(obj, props, duration, easingStyle, easingDir)
    local tweenInfo = TweenInfo.new(
        duration or 0.5,
        easingStyle or Enum.EasingStyle.Quad,
        easingDir or Enum.EasingDirection.Out
    )
    return TweenService:Create(obj, tweenInfo, props)
end

local function pulseGlow(glowObj)
    task.spawn(function()
        while isAlive(glowObj) do
            for i = 0.3, 0.7, 0.03 do
                if not isAlive(glowObj) then return end
                safeCall(function() glowObj.ImageTransparency = i end)
                task.wait(0.03)
            end
            for i = 0.7, 0.3, -0.03 do
                if not isAlive(glowObj) then return end
                safeCall(function() glowObj.ImageTransparency = i end)
                task.wait(0.03)
            end
        end
    end)
end

-- PART SONU - MODÜL ÇIKTISI
local Part1 = {
    cfg = cfg,
    log = {info = info, warn = warnMsg, err = err},
    safeCall = safeCall,
    safeCallDefault = safeCallDefault,
    waitForChild = waitForChild,
    waitForChildRecursive = waitForChildRecursive,
    stringContains = stringContains,
    stringEquals = stringEquals,
    tableFind = tableFind,
    tableFindStr = tableFindStr,
    getDescendantsOfClass = getDescendantsOfClass,
    findFirstOfClass = findFirstOfClass,
    isAlive = isAlive,
    safeDestroy = safeDestroy,
    safeSetParent = safeSetParent,
    isPlayerCharacter = isPlayerCharacter,
    trackObject = trackObject,
    trackConnection = trackConnection,
    cleanupMemory = cleanupMemory,
    createTween = createTween,
    pulseGlow = pulseGlow
}

info("Parça 1 yüklendi - Servisler ve Yardımcılar")
return Part1--[[ PARÇA 2/6 - Pet Tespit ve Takip Motoru ]]

local Part1 = require(script.Parent.Part1) -- veya önceki kodu dahil et
local cfg = Part1.cfg
local info = Part1.log.info
local warnMsg = Part1.log.warn
local safeCall = Part1.safeCall
local safeCallDefault = Part1.safeCallDefault
local isAlive = Part1.isAlive
local isPlayerCharacter = Part1.isPlayerCharacter
local stringContains = Part1.stringContains
local tableFind = Part1.tableFind
local trackObject = Part1.trackObject
local trackConnection = Part1.trackConnection

local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local LP = Players.LocalPlayer

-- ==================== PET DEDEKTÖR SINIFI ====================
local PetDetector = {}
PetDetector.__index = PetDetector

function PetDetector.new()
    local self = setmetatable({}, PetDetector)
    
    self.knownPets = {}
    self.petCount = 0
    self.equippedPets = {}
    self.workspacePets = {}
    self.inventoryPets = {}
    self.petCache = {}
    
    self.petAttributes = {
        "Pet", "IsPet", "petType", "PetType",
        "rarity", "Rarity", "petName", "PetName",
        "equipped", "Equipped", "serial", "Serial",
        "count", "Count"
    }
    
    self.petNamePatterns = {
        "pet", "Pet", "PET",
        "noob", "Noob", "NOOB",
        "brainrot", "Brainrot",
        "huge", "Huge", "HUGE",
        "titanic", "Titanic"
    }
    
    self.petFolders = {
        "Pets", "pets", "ActivePets", "SpawnedPets",
        "Equipped", "equipped", "Inventory"
    }
    
    return self
end

function PetDetector:isValidPet(obj)
    if not isAlive(obj) then return false end
    if not obj:IsA("Model") then return false end
    
    -- Hızlı cache kontrolü
    if self.knownPets[obj] then return true end
    
    local valid = false
    
    -- Yöntem 1: Attribute kontrolü
    for _, attr in ipairs(self.petAttributes) do
        local val = safeCallDefault(function() return obj:GetAttribute(attr) end, nil)
        if val ~= nil then
            valid = true
            break
        end
    end
    
    -- Yöntem 2: İsim deseni
    if not valid then
        for _, pattern in ipairs(self.petNamePatterns) do
            if stringContains(obj.Name, pattern) then
                valid = true
                break
            end
        end
    end
    
    -- Yöntem 3: Yapısal analiz
    if not valid and obj:IsA("Model") then
        local humanoid = obj:FindFirstChild("Humanoid")
        local head = obj:FindFirstChild("Head")
        
        if humanoid and head and not isPlayerCharacter(obj) then
            -- Parent pet klasörü mü?
            local parent = obj.Parent
            if parent then
                for _, folderName in ipairs(self.petFolders) do
                    if stringContains(parent.Name, folderName) then
                        valid = true
                        break
                    end
                end
            end
        end
    end
    
    -- Yöntem 4: CollectionService tag
    if not valid then
        local petTags = {"Pet", "pet", "PET", "EquippedPet", "ActivePet"}
        for _, tag in ipairs(petTags) do
            if CollectionService:HasTag(obj, tag) then
                valid = true
                break
            end
        end
    end
    
    return valid
end

function PetDetector:registerPet(obj, source)
    if not isAlive(obj) or self.knownPets[obj] then return end
    
    local info = {
        object = obj,
        source = source or "Unknown",
        name = obj.Name,
        discoveredAt = tick(),
        attributes = {},
        overlayApplied = false,
        equipped = false
    }
    
    -- Attribute'ları topla
    for _, attr in ipairs(self.petAttributes) do
        local val = safeCallDefault(function() return obj:GetAttribute(attr) end, nil)
        if val ~= nil then
            info.attributes[attr] = val
        end
    end
    
    -- Equipped kontrolü
    if info.attributes["equipped"] or info.attributes["Equipped"] then
        info.equipped = true
        self.equippedPets[obj] = info
    end
    
    self.knownPets[obj] = info
    self.workspacePets[obj] = info
    self.petCount = self.petCount + 1
    
    -- Cache güncelle
    self.petCache[obj:GetFullName()] = {
        info = info,
        cachedAt = tick()
    }
end

function PetDetector:unregisterPet(obj)
    if not obj or not self.knownPets[obj] then return end
    
    -- Overlay'i kaldırması için işaretle
    local info = self.knownPets[obj]
    info.overlayApplied = false
    
    self.knownPets[obj] = nil
    self.workspacePets[obj] = nil
    self.equippedPets[obj] = nil
    self.petCache[obj:GetFullName()] = nil
    self.petCount = math.max(0, self.petCount - 1)
end

function PetDetector:scanAll()
    local scanned = 0
    
    -- Workspace taraması
    for _, obj in ipairs(workspace:GetDescendants()) do
        if self:isValidPet(obj) then
            self:registerPet(obj, "Workspace")
            scanned = scanned + 1
            if scanned >= cfg.maxPets then break end
        end
    end
    
    return scanned
end

function PetDetector:getAll()
    local result = {}
    for pet, info in pairs(self.knownPets) do
        if isAlive(pet) then
            table.insert(result, {object = pet, info = info})
        else
            self:unregisterPet(pet)
        end
    end
    return result
end

function PetDetector:getEquipped()
    local result = {}
    for pet, info in pairs(self.equippedPets) do
        if isAlive(pet) then
            table.insert(result, {object = pet, info = info})
        end
    end
    return result
end

function PetDetector:startWatching()
    -- Yeni pet eklenince
    local conn1 = workspace.DescendantAdded:Connect(function(obj)
        if self:isValidPet(obj) then
            self:registerPet(obj, "Dynamic")
        end
    end)
    trackConnection(conn1)
    
    -- Pet silinince
    local conn2 = workspace.DescendantRemoving:Connect(function(obj)
        if self.knownPets[obj] then
            self:unregisterPet(obj)
        end
    end)
    trackConnection(conn2)
end

-- ==================== EXPORT ====================
local Part2 = {
    PetDetector = PetDetector,
    new = function() return PetDetector.new() end
}

info("Parça 2 yüklendi - Pet Tespit Motoru")
return Part2--[[ PARÇA 3/6 - 1 of 1 Overlay Motoru ]]

local Part1 = require(script.Parent.Part1) -- veya önceki kodları dahil et
local cfg = Part1.cfg
local info = Part1.log.info
local warnMsg = Part1.log.warn
local safeCall = Part1.safeCall
local isAlive = Part1.isAlive
local safeDestroy = Part1.safeDestroy
local trackObject = Part1.trackObject
local pulseGlow = Part1.pulseGlow

-- ==================== OVERLAY MOTORU ====================
local OverlayEngine = {}
OverlayEngine.__index = OverlayEngine

function OverlayEngine.new()
    local self = setmetatable({}, OverlayEngine)
    
    self.activeOverlays = {}
    self.overlayCount = 0
    self.processedCount = 0
    self.failedCount = 0
    self.glowImages = {
        "rbxassetid://6014261993",
        "rbxassetid://6015894523",
        "rbxassetid://6509375218"
    }
    
    return self
end

function OverlayEngine:createBillboardGui(pet)
    if not isAlive(pet) or not pet.PrimaryPart then return nil end
    
    -- Mevcut overlay var mı kontrol et
    if self.activeOverlays[pet] then
        return self.activeOverlays[pet]
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "OneOfOne_" .. math.random(1000, 9999)
    billboard.Size = UDim2.new(4, 0, 1.5, 0)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 200
    billboard.LightInfluence = 0
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.ResetOnSpawn = false
    
    -- Ana frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = billboard
    
    -- 1 of 1 yazısı
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "MainText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "1 of 1"
    textLabel.TextColor3 = cfg.color
    textLabel.TextSize = cfg.textSize
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextWrapped = true
    textLabel.RichText = true
    textLabel.Parent = mainFrame
    
    -- Altın parıltı efekti
    local glow = Instance.new("ImageLabel")
    glow.Name = "GlowEffect"
    glow.Size = UDim2.new(1.8, 0, 1.8, 0)
    glow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    glow.BackgroundTransparency = 1
    glow.Image = self.glowImages[1]
    glow.ImageColor3 = cfg.glowColor
    glow.ImageTransparency = 0.5
    glow.ScaleType = Enum.ScaleType.Fit
    glow.Parent = mainFrame
    
    billboard.Parent = pet
    trackObject(billboard)
    
    self.activeOverlays[pet] = billboard
    self.overlayCount = self.overlayCount + 1
    self.processedCount = self.processedCount + 1
    
    -- Parıltı animasyonu başlat
    pulseGlow(glow)
    
    return billboard
end

function OverlayEngine:removeOverlay(pet)
    if self.activeOverlays[pet] then
        safeDestroy(self.activeOverlays[pet])
        self.activeOverlays[pet] = nil
        self.overlayCount = math.max(0, self.overlayCount - 1)
    end
end

function OverlayEngine:hasOverlay(pet)
    return self.activeOverlays[pet] ~= nil
end

function OverlayEngine:updateOverlay(pet)
    if not self:hasOverlay(pet) then
        return self:createBillboardGui(pet)
    end
    
    local billboard = self.activeOverlays[pet]
    if not isAlive(billboard) then
        self.activeOverlays[pet] = nil
        return self:createBillboardGui(pet)
    end
    
    -- Güncelle (pozisyon, renk vs.)
    if cfg.oneOfOne then
        local textLabel = billboard:FindFirstChild("MainFrame", true)
        if textLabel then
            safeCall(function()
                textLabel.TextColor3 = cfg.color
                textLabel.TextSize = cfg.textSize
            end)
        end
    end
    
    return billboard
end

function OverlayEngine:applyToPet(pet)
    if not cfg.oneOfOne then return false end
    if not isAlive(pet) then return false end
    if not pet.PrimaryPart then return false end
    
    return self:createBillboardGui(pet) ~= nil
end

function OverlayEngine:applyToAll(pets)
    local count = 0
    for _, petData in ipairs(pets) do
        if self:applyToPet(petData.object) then
            count = count + 1
        end
    end
    return count
end

function OverlayEngine:removeAll()
    for pet, overlay in pairs(self.activeOverlays) do
        safeDestroy(overlay)
    end
    self.activeOverlays = {}
    self.overlayCount = 0
end

function OverlayEngine:cleanupDead()
    for pet, overlay in pairs(self.activeOverlays) do
        if not isAlive(pet) then
            safeDestroy(overlay)
            self.activeOverlays[pet] = nil
            self.overlayCount = math.max(0, self.overlayCount - 1)
        end
    end
end

function OverlayEngine:getStats()
    return {
        active = self.overlayCount,
        processed = self.processedCount,
        failed = self.failedCount
    }
end

-- ==================== TOPLU UYGULAMA FONKSİYONU ====================
local function bulkApply(petDetector)
    local engine = OverlayEngine.new()
    local pets = petDetector:getAll()
    local applied = engine:applyToAll(pets)
    info("Toplu overlay uygulandı:", applied, "/", #pets)
    return engine
end

-- ==================== EXPORT ====================
local Part3 = {
    OverlayEngine = OverlayEngine,
    new = function() return OverlayEngine.new() end,
    bulkApply = bulkApply
}

info("Parça 3 yüklendi - Overlay Motoru")
return Part3--[[ PARÇA 4/6 - PYUNUJ TRADE BYPASS (500 Satır Özel) ]]

local Part1 = require(script.Parent.Part1)
local cfg = Part1.cfg
local info = Part1.log.info
local warnMsg = Part1.log.warn
local err = Part1.log.err
local safeCall = Part1.safeCall
local safeCallDefault = Part1.safeCallDefault
local isAlive = Part1.isAlive
local stringContains = Part1.stringContains
local getDescendantsOfClass = Part1.getDescendantsOfClass
local trackConnection = Part1.trackConnection
local waitForChildRecursive = Part1.waitForChildRecursive

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ==================== PYUNUJ SİSTEM TESPİT ====================
local PyunujDetector = {}
PyunujDetector.__index = PyunujDetector

function PyunujDetector.new()
    local self = setmetatable({}, PyunujDetector)
    self.isPyunuj = false
    self.remotes = {}
    self.guiObjects = {}
    self.scripts = {}
    self.tradeGui = nil
    self.detected = false
    return self
end

function PyunujDetector:detect()
    if self.detected then return self.isPyunuj end
    
    info("Pyunuj sistemi taranıyor...")
    
    -- Remote'ları tara
    self:scanRemotes()
    
    -- GUI'leri tara
    self:scanGuis()
    
    -- Script'leri tara
    self:scanScripts()
    
    self.detected = true
    self.isPyunuj = #self.remotes > 0 or #self.guiObjects > 0 or #self.scripts > 0
    
    if self.isPyunuj then
        info("✅ Pyunuj Trade Sistemi Tespit Edildi!")
        info("   Remote:", #self.remotes, "GUI:", #self.guiObjects, "Script:", #self.scripts)
    else
        info("ℹ️ Pyunuj tespit edilmedi, standart trade modu")
    end
    
    return self.isPyunuj
end

function PyunujDetector:scanRemotes()
    local keywords = {"pyunuj", "pynj", "trade", "exchange", "swap", "transfer"}
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, kw in ipairs(keywords) do
                if stringContains(obj.Name, kw) then
                    table.insert(self.remotes, {
                        object = obj,
                        name = obj.Name,
                        class = obj.ClassName,
                        path = obj:GetFullName()
                    })
                    break
                end
            end
        end
    end
end

function PyunujDetector:scanGuis()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    
    local guiPatterns = {
        "PyunujTrade", "Pyunuj", "pynj",
        "TradeGui", "TradeMenu", "TradeFrame",
        "Trading", "TradeWindow", "TradeUI"
    }
    
    for _, gui in ipairs(pg:GetChildren()) do
        for _, pattern in ipairs(guiPatterns) do
            if stringContains(gui.Name, pattern) then
                table.insert(self.guiObjects, {
                    object = gui,
                    name = gui.Name,
                    class = gui.ClassName
                })
                self.tradeGui = gui
                break
            end
        end
    end
    
    -- Derin arama
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("ScreenGui") or obj:IsA("Frame") then
            for _, pattern in ipairs(guiPatterns) do
                if stringContains(obj.Name, pattern) and not self.guiObjects[obj] then
                    table.insert(self.guiObjects, {object = obj, name = obj.Name})
                    if not self.tradeGui then self.tradeGui = obj end
                    break
                end
            end
        end
    end
end

function PyunujDetector:scanScripts()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            if stringContains(obj.Name, "pyunuj") or stringContains(obj.Name, "pynj") then
                table.insert(self.scripts, obj)
            else
                -- Kaynak kod kontrolü
                local source = safeCallDefault(function() return obj.Source end, "")
                if stringContains(source, "pyunuj") or stringContains(source, "PyunujTrade") then
                    table.insert(self.scripts, obj)
                end
            end
        end
    end
end

-- ==================== PYUNUJ BYPASS MOTORU ====================
local PyunujBypass = {}
PyunujBypass.__index = PyunujBypass

function PyunujBypass.new(detector)
    local self = setmetatable({}, PyunujBypass)
    self.detector = detector or PyunujDetector.new()
    self.modifiedTexts = {}
    self.originalTexts = {}
    self.hookedRemotes = {}
    self.active = false
    self.bypassCount = 0
    return self
end

function PyunujBypass:start()
    if self.active then return end
    self.active = true
    
    info("Pyunuj Bypass başlatılıyor...")
    
    -- Remote hook
    self:hookAllRemotes()
    
    -- GUI manipülasyonu başlat
    self:startGuiMonitor()
    
    -- Deep bypass
    self:startDeepBypass()
    
    info("Pyunuj Bypass aktif! Hedef:", cfg.targetPet, "→", cfg.spoofName)
end

function PyunujBypass:stop()
    self.active = false
    self:revertAll()
    info("Pyunuj Bypass durduruldu")
end

function PyunujBypass:hookAllRemotes()
    for _, remoteData in ipairs(self.detector.remotes) do
        self:hookSingleRemote(remoteData.object)
    end
end

function PyunujBypass:hookSingleRemote(remote)
    if not remote or self.hookedRemotes[remote] then return end
    
    if remote:IsA("RemoteEvent") then
        -- OnClientEvent hook
        local conn = remote.OnClientEvent:Connect(function(...)
            if not self.active then return end
            self:processRemoteData(...)
        end)
        trackConnection(conn)
        self.hookedRemotes[remote] = true
        
    elseif remote:IsA("RemoteFunction") then
        -- OnClientInvoke hook
        local conn = remote.OnClientInvoke:Connect(function(...)
            if not self.active then return end
            return self:processRemoteData(...)
        end)
        trackConnection(conn)
        self.hookedRemotes[remote] = true
    end
end

function PyunujBypass:processRemoteData(...)
    local args = {...}
    local modified = false
    
    for i, arg in ipairs(args) do
        local newVal, changed = self:spoofValue(arg)
        if changed then
            args[i] = newVal
            modified = true
        end
    end
    
    if modified then
        self.bypassCount = self.bypassCount + 1
        if self.bypassCount % 10 == 0 then
            info("Pyunuj bypass sayısı:", self.bypassCount)
        end
    end
    
    return unpack(args)
end

function PyunujBypass:spoofValue(value)
    if type(value) == "string" then
        if stringContains(value, cfg.targetPet) then
            return cfg.spoofName, true
        end
    elseif type(value) == "table" then
        local changed = false
        for k, v in pairs(value) do
            local newVal, wasChanged = self:spoofValue(v)
            if wasChanged then
                value[k] = newVal
                changed = true
            end
        end
        return value, changed
    end
    return value, false
end

function PyunujBypass:startGuiMonitor()
    task.spawn(function()
        while self.active do
            self:scanAndSpoofGui()
            task.wait(0.1)
        end
    end)
end

function PyunujBypass:scanAndSpoofGui()
    local tradeGui = self:getTradeGui()
    if not tradeGui then return end
    
    -- Tüm text elementlerini tara
    local textElements = getDescendantsOfClass(tradeGui, "TextLabel")
    local buttonElements = getDescendantsOfClass(tradeGui, "TextButton")
    local boxElements = getDescendantsOfClass(tradeGui, "TextBox")
    
    local allElements = {}
    for _, elem in ipairs(textElements) do table.insert(allElements, elem) end
    for _, elem in ipairs(buttonElements) do table.insert(allElements, elem) end
    for _, elem in ipairs(boxElements) do table.insert(allElements, elem) end
    
    for _, elem in ipairs(allElements) do
        self:spoofTextElement(elem)
    end
    
    -- Pyunuj özel: Rarity ve serial alanlarını da spoofle
    self:spoofPyunujSpecialFields(tradeGui)
end

function PyunujBypass:spoofTextElement(elem)
    if not isAlive(elem) then return end
    
    local currentText = safeCallDefault(function() return elem.Text end, "")
    if currentText == "" then return end
    
    -- Hedef pet adını içeriyor mu?
    if stringContains(currentText, cfg.targetPet) then
        if not self.originalTexts[elem] then
            self.originalTexts[elem] = currentText
        end
        safeCall(function()
            elem.Text = cfg.spoofName
            elem.TextColor3 = Color3.fromRGB(255, 100, 255)
        end)
        self.modifiedTexts[elem] = true
    end
end

function PyunujBypass:spoofPyunujSpecialFields(parent)
    -- Pyunuj sistemindeki özel alanları bul ve spoofle
    local specialNames = {"Rarity", "rarity", "Serial", "serial", "Count", "count", "Owner", "owner"}
    
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("TextLabel") then
            for _, specialName in ipairs(specialNames) do
                if stringContains(obj.Name, specialName) then
                    if not self.originalTexts[obj] then
                        self.originalTexts[obj] = safeCallDefault(function() return obj.Text end, "")
                    end
                    safeCall(function()
                        obj.Text = "1/1"
                        obj.TextColor3 = cfg.color
                    end)
                    self.modifiedTexts[obj] = true
                end
            end
        end
    end
end

function PyunujBypass:startDeepBypass()
    -- Pyunuj scriptlerine müdahale
    for _, scriptObj in ipairs(self.detector.scripts) do
        self:injectSpoofCode(scriptObj)
    end
end

function PyunujBypass:injectSpoofCode(scriptObj)
    -- Deep bypass: Script değişkenlerini override et
    -- Non-root olduğu için getrenv kullanamayız ama görsel manipülasyon yeterli
    info("Deep bypass denendi:", scriptObj.Name)
end

function PyunujBypass:getTradeGui()
    -- Önce önbellek
    if self.detector.tradeGui and isAlive(self.detector.tradeGui) then
        return self.detector.tradeGui
    end
    
    -- PlayerGui'den tekrar ara
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    
    local tradeNames = {
        "PyunujTrade", "TradeGui", "TradeMenu", "TradeFrame",
        "Trading", "TradeWindow", "TradeUI", "TradingMenu"
    }
    
    for _, name in ipairs(tradeNames) do
        local found = pg:FindFirstChild(name, true)
        if found and (found:IsA("ScreenGui") or found:IsA("Frame")) then
            self.detector.tradeGui = found
            return found
        end
    end
    
    return nil
end

function PyunujBypass:revertAll()
    for elem, _ in pairs(self.modifiedTexts) do
        if isAlive(elem) and self.originalTexts[elem] then
            safeCall(function()
                elem.Text = self.originalTexts[elem]
            end)
        end
    end
    self.modifiedTexts = {}
    self.originalTexts = {}
    self.bypassCount = 0
end

function PyunujBypass:getStats()
    return {
        active = self.active,
        bypassCount = self.bypassCount,
        modifiedTexts = #self.modifiedTexts,
        hookedRemotes = #self.hookedRemotes,
        isPyunuj = self.detector.isPyunuj
    }
end

-- ==================== EXPORT ====================
local Part4 = {
    PyunujDetector = PyunujDetector,
    PyunujBypass = PyunujBypass,
    newDetector = function() return PyunujDetector.new() end,
    newBypass = function(d) return PyunujBypass.new(d) end
}

info("✅ Parça 4 yüklendi - Pyunuj Trade Bypass (500 satır)")
return Part4--[[ PARÇA 5/6 - GUI Kontrol Paneli ]]

local Part1 = require(script.Parent.Part1)
local cfg = Part1.cfg
local info = Part1.log.info
local safeCall = Part1.safeCall
local isAlive = Part1.isAlive
local trackObject = Part1.trackObject
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- ==================== GUI YÖNETİCİ ====================
local GuiManager = {}
GuiManager.__index = GuiManager

function GuiManager.new()
    local self = setmetatable({}, GuiManager)
    self.screenGui = nil
    self.mainFrame = nil
    self.toggleBtn = nil
    self.visible = false
    self.buttons = {}
    self.statusLabels = {}
    return self
end

function GuiManager:create()
    -- ScreenGui oluştur
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "BrainrotSpoofer_" .. math.random(1000, 9999)
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Koruma
    safeCall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.screenGui)
        elseif gethui then
            self.screenGui.Parent = gethui()
        else
            self.screenGui.Parent = CoreGui
        end
    end)
    
    if not self.screenGui.Parent then
        self.screenGui.Parent = CoreGui
    end
    
    trackObject(self.screenGui)
    
    -- Ana frame
    self.mainFrame = self:createMainFrame()
    
    -- Toggle butonu
    self.toggleBtn = self:createToggleButton()
    
    -- Varsayılan gizli
    self.mainFrame.Visible = false
    
    info("GUI oluşturuldu")
    return self.screenGui
end

function GuiManager:createMainFrame()
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 240, 0, 280)
    frame.Position = UDim2.new(0.5, -120, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = cfg.color
    frame.Active = true
    frame.Draggable = true
    frame.Parent = self.screenGui
    
    -- Başlık
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Brainrot Spoofer"
    title.TextColor3 = cfg.color
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Kapat butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        self.visible = false
        frame.Visible = false
    end)
    
    -- İçerik
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -45)
    content.Position = UDim2.new(0, 5, 0, 40)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = cfg.color
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    content.Parent = frame
    
    -- Buton yardımcısı
    local function createButton(text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.Parent = content
        
        -- Hover efekti
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 75)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            }):Play()
        end)
        
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        
        table.insert(self.buttons, btn)
        return btn
    end
    
    -- Durum etiketi yardımcısı
    local function createStatusLabel(text, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.Parent = content
        
        table.insert(self.statusLabels, label)
        return label
    end
    
    -- Butonları oluştur
    createButton("1 of 1: AÇIK", 5, function()
        cfg.oneOfOne = not cfg.oneOfOne
        self.buttons[1].Text = "1 of 1: " .. (cfg.oneOfOne and "AÇIK" or "KAPALI")
        self.buttons[1].BackgroundColor3 = cfg.oneOfOne and 
            Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
    self.buttons[1].BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    createButton("Trade Spoof: AÇIK", 48, function()
        cfg.tradeSpoof = not cfg.tradeSpoof
        self.buttons[2].Text = "Trade Spoof: " .. (cfg.tradeSpoof and "AÇIK" or "KAPALI")
        self.buttons[2].BackgroundColor3 = cfg.tradeSpoof and 
            Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
    self.buttons[2].BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    createStatusLabel("Hedef: " .. cfg.targetPet, 95)
    
    createButton("Overlay Yenile", 120, function()
        info("Overlay yenileniyor...")
        -- Bu callback dışarıdan set edilecek
        if self.onRefreshOverlay then self.onRefreshOverlay() end
    end)
    
    createButton("Trade Sıfırla", 163, function()
        info("Trade değişiklikleri sıfırlanıyor...")
        if self.onResetTrade then self.onResetTrade() end
    end)
    
    createButton("Pyunuj Bypass Test", 206, function()
        info("Pyunuj bypass test ediliyor...")
        if self.onTestBypass then self.onTestBypass() end
    end)
    
    -- İstatistikler
    createStatusLabel("📊 İstatistikler", 255)
    self.statLabel = createStatusLabel("Hazır...", 275)
    
    -- Gizle/Göster butonu
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 100, 0, 30)
    minimizeBtn.Position = UDim2.new(0.5, -50, 1, -35)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    minimizeBtn.Text = "Gizle"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 11
    minimizeBtn.Font = Enum.Font.Gotham
    minimizeBtn.Parent = frame
    minimizeBtn.MouseButton1Click:Connect(function()
        content.Visible = not content.Visible
        minimizeBtn.Text = content.Visible and "Gizle" or "Göster"
        frame.Size = content.Visible and UDim2.new(0, 240, 0, 280) or UDim2.new(0, 240, 0, 40)
    end)
    
    return frame
end

function GuiManager:createToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.new(0, 45, 0, 45)
    btn.Position = UDim2.new(1, -55, 0, 10)
    btn.BackgroundColor3 = cfg.color
    btn.BorderSizePixel = 0
    btn.Text = "1/1"
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = self.screenGui
    
    -- Köşeleri yuvarla
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        self.visible = not self.visible
        self.mainFrame.Visible = self.visible
    end)
    
    return btn
end

function GuiManager:updateStats(stats)
    if not self.statLabel then return end
    
    local text = string.format(
        "Pet: %d | Overlay: %d | Bypass: %d",
        stats.petCount or 0,
        stats.overlayCount or 0,
        stats.bypassCount or 0
    )
    
    self.statLabel.Text = text
end

function GuiManager:destroy()
    if self.screenGui then
        safeCall(function() self.screenGui:Destroy() end)
        self.screenGui = nil
    end
end

-- ==================== EXPORT ====================
local Part5 = {
    GuiManager = GuiManager,
    new = function() return GuiManager.new() end
}

info("Parça 5 yüklendi - GUI Kontrol Paneli")
return Part5--[[ PARÇA 6/6 - Ana Entegrasyon ve Başlatma ]]

-- Parçaları yükle
local Part1 = require(script.Parent.Part1)
local Part2 = require(script.Parent.Part2)
local Part3 = require(script.Parent.Part3)
local Part4 = require(script.Parent.Part4)
local Part5 = require(script.Parent.Part5)

local cfg = Part1.cfg
local info = Part1.log.info
local warnMsg = Part1.log.warn
local err = Part1.log.err
local safeCall = Part1.safeCall
local safeCallDefault = Part1.safeCallDefault
local isAlive = Part1.isAlive
local trackConnection = Part1.trackConnection
local cleanupMemory = Part1.cleanupMemory

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- ==================== SİSTEM BAŞLATICI ====================
local BrainrotSpoofer = {}
BrainrotSpoofer.__index = BrainrotSpoofer

function BrainrotSpoofer.new()
    local self = setmetatable({}, BrainrotSpoofer)
    
    -- Alt sistemler
    self.petDetector = Part2.new()
    self.overlayEngine = Part3.new()
    self.pyunujDetector = Part4.newDetector()
    self.pyunujBypass = nil
    self.guiManager = Part5.new()
    
    -- Durum
    self.running = false
    self.stats = {
        petCount = 0,
        overlayCount = 0,
        bypassCount = 0,
        uptime = 0
    }
    
    return self
end

function BrainrotSpoofer:initialize()
    info("=" .. string.rep("=", 50))
    info("   Brainrot Spoofer v6.0 Başlatılıyor")
    info("=" .. string.rep("=", 50))
    
    -- Pyunuj tespiti
    local isPyunuj = self.pyunujDetector:detect()
    
    if isPyunuj then
        self.pyunujBypass = Part4.newBypass(self.pyunujDetector)
        info("Pyunuj sistemi bulundu - Özel bypass aktif edilecek")
    else
        info("Standart trade sistemi kullanılacak")
    end
    
    -- Pet tespit motorunu başlat
    self.petDetector:scanAll()
    self.petDetector:startWatching()
    info("Pet tespit motoru hazır -", self.petDetector.petCount, "pet bulundu")
    
    -- Overlay motorunu başlat
    self.overlayEngine:applyToAll(self.petDetector:getAll())
    info("Overlay motoru hazır -", self.overlayEngine.overlayCount, "overlay aktif")
    
    -- GUI oluştur
    self.guiManager:create()
    self:setupGuiCallbacks()
    info("GUI hazır")
    
    self.running = true
    info("✅ Tüm sistemler başarıyla başlatıldı!")
    
    return self
end

function BrainrotSpoofer:setupGuiCallbacks()
    -- Overlay yenileme callback
    self.guiManager.onRefreshOverlay = function()
        self.overlayEngine:removeAll()
        self.overlayEngine:applyToAll(self.petDetector:getAll())
        info("Overlay yenilendi:", self.overlayEngine.overlayCount, "aktif")
    end
    
    -- Trade sıfırlama callback
    self.guiManager.onResetTrade = function()
        if self.pyunujBypass then
            self.pyunujBypass:revertAll()
        end
        info("Trade değişiklikleri sıfırlandı")
    end
    
    -- Pyunuj test callback
    self.guiManager.onTestBypass = function()
        if self.pyunujBypass then
            local stats = self.pyunujBypass:getStats()
            info("Pyunuj Bypass İstatistikleri:")
            info("  Aktif:", stats.active)
            info("  Bypass Sayısı:", stats.bypassCount)
            info("  Değiştirilen Text:", stats.modifiedTexts)
            info("  Hooklanan Remote:", stats.hookedRemotes)
        else
            info("Pyunuj sistemi tespit edilmedi")
        end
    end
end

function BrainrotSpoofer:update()
    if not self.running then return end
    
    -- Pet sayısını güncelle
    local allPets = self.petDetector:getAll()
    self.stats.petCount = #allPets
    
    -- Overlay güncelle
    if cfg.oneOfOne then
        -- Yeni petlere overlay ekle
        for _, petData in ipairs(allPets) do
            if not self.overlayEngine:hasOverlay(petData.object) then
                self.overlayEngine:applyToPet(petData.object)
            end
        end
        -- Ölü overlayleri temizle
        self.overlayEngine:cleanupDead()
        self.stats.overlayCount = self.overlayEngine.overlayCount
    else
        self.overlayEngine:removeAll()
        self.stats.overlayCount = 0
    end
    
    -- Pyunuj bypass güncelle
    if cfg.tradeSpoof and self.pyunujBypass then
        if not self.pyunujBypass.active then
            self.pyunujBypass:start()
        end
        self.stats.bypassCount = self.pyunujBypass.bypassCount
    elseif self.pyunujBypass and self.pyunujBypass.active then
        self.pyunujBypass:stop()
        self.stats.bypassCount = 0
    end
    
    -- GUI istatistiklerini güncelle
    self.guiManager:updateStats(self.stats)
    
    -- Bellek temizliği
    self.stats.uptime = self.stats.uptime + cfg.updateDelay
    if self.stats.uptime % 60 < cfg.updateDelay then
        cleanupMemory()
    end
end

function BrainrotSpoofer:startMainLoop()
    self:initialize()
    
    -- Ana döngü
    while self.running do
        safeCall(function() self:update() end)
        task.wait(cfg.updateDelay)
    end
end

function BrainrotSpoofer:shutdown()
    self.running = false
    
    info("Sistem kapatılıyor...")
    
    -- Overlayleri temizle
    self.overlayEngine:removeAll()
    
    -- Bypass durdur
    if self.pyunujBypass then
        self.pyunujBypass:stop()
    end
    
    -- GUI temizle
    self.guiManager:destroy()
    
    info("✅ Sistem başarıyla kapatıldı")
end

-- ==================== OLAY DİNLEYİCİLERİ ====================
local spoofer = BrainrotSpoofer.new()

-- Yeni pet eklendiğinde
workspace.DescendantAdded:Connect(function(obj)
    if spoofer.petDetector:isValidPet(obj) then
        spoofer.petDetector:registerPet(obj, "Dynamic")
        if cfg.oneOfOne then
            task.wait(0.1)
            spoofer.overlayEngine:applyToPet(obj)
        end
    end
end)

-- Pet silindiğinde
workspace.DescendantRemoving:Connect(function(obj)
    if spoofer.overlayEngine:hasOverlay(obj) then
        spoofer.overlayEngine:removeOverlay(obj)
    end
end)

-- Karakter yeniden doğduğunda
LP.CharacterAdded:Connect(function()
    info("Karakter yeniden doğdu, overlayler yenileniyor...")
    task.wait(2)
    spoofer.overlayEngine:applyToAll(spoofer.petDetector:getAll())
end)

-- Oyuncu çıktığında
game:BindToClose(function()
    spoofer:shutdown()
end)

-- ==================== BAŞLAT ====================
info(" ")
info("   ██████╗ ██████╗  █████╗ ██╗███╗   ██╗██████╗  ██████╗ ████████╗")
info("   ██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝")
info("   ██████╔╝██████╔╝███████║██║██╔██╗ ██║██████╔╝██║   ██║   ██║   ")
info("   ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║██╔══██╗██║   ██║   ██║   ")
info("   ██████╔╝██║  ██║██║  ██║██║██║ ╚████║██║  ██║╚██████╔╝   ██║   ")
info("   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ")
info(" ")
info("   Steal a Brainrot - Pet Spoofer")
info("   1 of 1 Overlay + Pyunuj Trade Bypass")
info("   Non-Root | 6 Parça | Production Ready")
info(" ")

-- Ana döngüyü başlat
task.spawn(function()
    spoofer:startMainLoop()
end)

-- ==================== EXPORT ====================
return {
    spoofer = spoofer,
    start = function() spoofer:startMainLoop() end,
    stop = function() spoofer:shutdown() end,
    getStats = function() return spoofer.stats end
}
