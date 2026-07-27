-- =====================================================================
-- LEA MOD: ULTRA ADVANCED AI CODE INTEGRATION & COMBINATORIAL EXECUTION ENGINE
-- Target Game: Steal a Brainrot
-- Target Platform: Mobile (Infinix Note 30 Pro Optimized)
-- Engine Version: 10.0 (Full Architecture, Zero Truncation)
-- =====================================================================

-- [1. GLOBAL SERVICES & STATE MANAGEMENT]
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global kontrol ve bellek alanları
getgenv().LeaEngine = {
    Active = true,
    DebugMode = true,
    DetectedFragments = {},
    TestedCombinations = {},
    ExecutionQueue = {},
    CurrentTargetInput = nil,
    AutoScanInterval = 0.05,
    LastExecutionTime = 0,
    TotalAttempts = 0
}

local Engine = getgenv().LeaEngine

-- [2. AI PATTERN MATCHER & CHARACTER DICTIONARY]
local AIDictionary = {
    Alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"},
    Numbers = {"0","1","2","3","4","5","6","7","8","9"},
    NoisePhrases = {
        "THE CODE IS", "THE CODE", "CODES", "CODE IS", "NEW CODE", 
        "SAMMY SAYS", "SAMMY CODE", "SECRET CODE", "ENTER CODE", 
        "USE CODE", "NEXT CODE", "TODAY CODE", "LIMITED CODE"
    }
}

-- Metinden gürültüleri ayıran ve saf karakter dizilimi çıkaran gelişmiş AI ayrıştırıcı
local function AI_ParseText(rawInput)
    if not rawInput or type(rawInput) ~= "string" or #rawInput == 0 then return "" end
    
    local cleanUpper = string.upper(rawInput)
    
    -- 1. Aşama: Bilinen tüm gürültü kalıplarını temizle
    for _, noise in ipairs(AIDictionary.NoisePhrases) do
        cleanUpper = string.gsub(cleanUpper, noise, "")
    end
    
    -- 2. Aşama: Regex ile sadece A-Z ve 0-9 arasındaki karakterleri süz
    local parsedBuffer = {}
    for i = 1, #cleanUpper do
        local char = string.sub(cleanUpper, i, i)
        if string.match(char, "[A-Z0-9]") then
            table.insert(parsedBuffer, char)
        end
    end
    
    return table.concat(parsedBuffer, "")
end

-- [3. COMBINATORIAL ENGINE & PERMUTATION GENERATOR]
-- Parçaları birleştirip X, XY, XYZ ve alternatif varyasyon ağaçları üretir
local function AI_GenerateCombinations(fragmentsTable)
    if #fragmentsTable == 0 then return {} end
    
    local queue = {}
    
    -- Ana Lineer Akış (X -> XY -> XYZ -> XYZ1)
    local linearCumulative = ""
    for index = 1, #fragmentsTable do
        linearCumulative = linearCumulative .. fragmentsTable[index]
        table.insert(queue, linearCumulative)
    end
    
    -- Ters Akış Varyasyonu (Son gelen parçaların öncelikli olması durumu)
    if #fragmentsTable > 1 then
        local reverseCumulative = ""
        for index = #fragmentsTable, 1, -1 do
            reverseCumulative = fragmentsTable[index] .. reverseCumulative
            if not table.find(queue, reverseCumulative) then
                table.insert(queue, reverseCumulative)
            end
        end
    end
    
    return queue
end

-- [4. UI ADVANCED INTERACTION & INPUT FINDER ENGINE]
local function DeepFindTextBox()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local bestCandidate = nil
    
    -- PlayerGui altındaki tüm arayüz ağacını tara
    local function ScanTree(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextBox") and child.Visible then
                -- Ekranda görünür ve aktif olan ilk geçerli input alanını seç
                bestCandidate = child
                break
            end
            ScanTree(child)
        end
    end
    
    ScanTree(playerGui)
    return bestCandidate
end

-- Otomatik girdi simülasyonu ve tetikleme mekanizması
local function AI_ExecuteInput(textToSubmit)
    if not Engine.Active then return false end
    
    local targetInput = DeepFindTextBox()
    Engine.CurrentTargetInput = targetInput
    
    if not targetInput then return false end
    
    -- Klavye/TextBox durumunu kontrol et ve metni bas
    targetInput.Text = textToSubmit
    
    -- Tetikleme Protokolü (FocusLost ve Signal Simülasyonu)
    local success, _ = pcall(function()
        targetInput:CaptureFocus()
        task.wait(0.01)
        
        if typeof(firesignal) == "function" then
            firesignal(targetInput.FocusLost, true)
        else
            targetInput:ReleaseFocus(true)
        end
    end)
    
    Engine.TotalAttempts = Engine.TotalAttempts + 1
    Engine.TestedCombinations[textToSubmit] = true
    return success
end

-- [5. COMPACT MOBILE GUI ENGINE (OPTIMIZED FOR INFINIX NOTE 30 PRO)]
local UI_Elements = {}

local function BuildEngineUI()
    if CoreGui:FindFirstChild("LeaModMasterGui") then
        CoreGui.LeaModMasterGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaModMasterGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Ana Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 240, 0, 180)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 1.5
    Stroke.Parent = MainFrame
    
    -- Başlık Barı
    local Header = Instance.new("Frame")
    Header.Parent = MainFrame
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA MOD - AI CODE ENGINE v10"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Canlı Bilgi Ekranı
    local ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Parent = MainFrame
    ConsoleFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
    ConsoleFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    
    local ConsoleCorner = Instance.new("UICorner")
    ConsoleCorner.CornerRadius = UDim.new(0, 6)
    ConsoleCorner.Parent = ConsoleFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Parent = ConsoleFrame
    StatusText.Position = UDim2.new(0.05, 0, 0.05, 0)
    StatusText.Size = UDim2.new(0.9, 0, 0.9, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Sistem Hazır.\nSammy Akışı Bekleniyor..."
    StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
    StatusText.TextSize = 10
    StatusText.Font = Enum.Font.Code
    StatusText.TextWrapped = true
    StatusText.TextYAlignment = Enum.TextYAlignment.Top
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    
    UI_Elements.StatusText = StatusText
    
    -- Kontrol Butonu
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Parent = MainFrame
    ActionBtn.Position = UDim2.new(0.05, 0, 0.77, 0)
    ActionBtn.Size = UDim2.new(0.9, 0, 0, 32)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
    ActionBtn.Text = "DURDUR"
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 11
    ActionBtn.Font = Enum.Font.GothamBold
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        Engine.Active = not Engine.Active
        if Engine.Active then
            ActionBtn.Text = "DURDUR"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
            StatusText.Text = "Sistem Aktif.\nAkış Dinleniyor..."
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            ActionBtn.Text = "BAŞLAT"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
            StatusText.Text = "Sistem Durduruldu."
            StatusText.TextColor3 = Color3.fromRGB(255, 180, 0)
        end
    end)
end

-- [6. STREAM MONITOR & SAMMY DATA CAPTURE]
local function ProcessIncomingData(rawString)
    if not Engine.Active then return end
    
    local parsed = AI_ParseText(rawString)
    if parsed == "" or #parsed == 0 then return end
    
    -- Eğer bu parça listenin en sonunda zaten varsa tekrar ekleme
    if #Engine.DetectedFragments > 0 and Engine.DetectedFragments[#Engine.DetectedFragments] == parsed then
        return
    end
    
    -- Parçayı kaydet
    table.insert(Engine.DetectedFragments, parsed)
    
    -- Yeni kombinasyon listesini üret
    local comboList = AI_GenerateCombinations(Engine.DetectedFragments)
    
    -- Kombinasyonları anında dene
    for _, combo in ipairs(comboList) do
        if not Engine.TestedCombinations[combo] then
            if UI_Elements.StatusText then
                UI_Elements.StatusText.Text = "Son Parça: " .. parsed .. "\nDeneniyor: " .. combo .. "\nToplam Deneme: " .. Engine.TotalAttempts
            end
            
            AI_ExecuteInput(combo)
            task.wait(0.02) -- Mobil takılmayı önleyen ultra kısa gecikme
        end
    end
end

-- Arayüzdeki tüm metin değişimlerini (TextLabel, TextButton) anlık izleyen tarayıcı
local function StartStreamMonitoring()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local function ConnectLabel(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj:GetPropertyChangedSignal("Text"):Connect(function()
                ProcessIncomingData(obj.Text)
            end)
        end
    end
    
    -- Mevcut elemanları bağla
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        ConnectLabel(descendant)
    end
    
    -- Sonradan eklenen elemanları takip et
    playerGui.DescendantAdded:Connect(function(descendant)
        ConnectLabel(descendant)
    end)
end

-- [7. INITIALIZATION & SYSTEM EXECUTION]
task.spawn(function()
    pcall(BuildEngineUI)
    pcall(StartStreamMonitoring)
    print("LEA MOD: ULTRA AI ENGINE SUCCESSFULLY LOADED.")
end)
