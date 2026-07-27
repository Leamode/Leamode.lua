-- =====================================================================
-- LEA MOD: MEGA FULL VERSION - DUAL ENGINE SAMMY CODE DETECTOR
-- Target Game: Steal a Brainrot
-- Platform: Mobile Optimized (Infinix Note 30 Pro Compatible)
-- Architecture: Deep Filtering (Pet Base / Log / World UI / Auto-Submit)
-- =====================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [1. GLOBAL STATE & CONFIGURATION]
getgenv().LeaMegaConfig = {
    Engine1_Screen = true,  -- Motor 1: Ekran ve Dünya Nesneleri Tarayıcısı
    Engine2_Log = true,     -- Motor 2: Chat, Server Log ve Filtre İnceleyici
    
    ChainFragments = {},    -- Yakalanan kod parçaları (X, Y, Z)
    TestedCombinations = {},-- Denediğimiz kodların hafızası
    LastExtractedText = "",
    TotalSubmitAttempts = 0
}

local Config = getgenv().LeaMegaConfig

-- [2. ADVANCED NOISE FILTER & CHARACTER EXTRACTOR]
-- Pet Base, Pet Alındı Bildirimleri ve Log Gürültülerini Eleme Listesi
local NoiseDictionary = {
    "SPYDERSAMMY", "@SPYDERSAMMY", "SAMMY", "BOUGHT A PET", "GOT A PET",
    "PET BASE", "PET UNLOCKED", "HAS UNLOCKED", "SPAWNED", "REDEEM ANY DLC CODES",
    "CODES FROM SAMMY HERE", "CODE HERE...", "CODES", "SUBMIT", "THE CODE IS",
    "THE CODE", "NEW CODE", "SECRET CODE", "CHAT", "SYSTEM", "SERVER"
}

local function MegaCleanAndExtract(rawText)
    if not rawText or type(rawText) ~= "string" or #rawText == 0 then return "" end
    
    local upperText = string.upper(rawText)
    
    -- 1. AŞAMA: Bilinen tüm gürültü cümlelerini ve Pet Base mesajlarını temizle
    for _, noise in ipairs(NoiseDictionary) do
        upperText = string.gsub(upperText, noise, "")
    end
    
    -- Noktalama işaretlerini ve ek karakterleri kaldır
    upperText = upperText:gsub(":", ""):gsub("!", ""):gsub("%[", ""):gsub("%]", ""):gsub("%(", ""):gsub("%)", "")
    
    -- 2. AŞAMA: Sadece İngilizce A-Z Harflerini ve 0-9 Sayıları Ayıkla
    local cleanBuffer = {}
    for i = 1, #upperText do
        local char = string.sub(upperText, i, i)
        if string.match(char, "[A-Z0-9]") then
            table.insert(cleanBuffer, char)
        end
    end
    
    return table.concat(cleanBuffer, "")
end

-- [3. CODE INPUT & AUTOMATIC SUBMITTER ENGINE]
local function FindGameCodeElements()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil, nil end
    
    local targetInput = nil
    local submitButton = nil
    
    for _, desc in ipairs(playerGui:GetDescendants()) do
        if desc:IsA("TextBox") and desc.Visible then
            local fullName = string.lower(desc:GetFullName())
            -- Chat input kutusu olmadığından emin ol
            if not string.find(fullName, "chat") then
                targetInput = desc
            end
        elseif desc:IsA("TextButton") and desc.Visible then
            local btnText = string.upper(desc.Text)
            local btnName = string.upper(desc.Name)
            if btnText == "SUBMIT" or string.find(btnName, "SUBMIT") then
                submitButton = desc
            end
        end
    end
    
    return targetInput, submitButton
end

local function ExecuteCodeSubmission(codeToTry)
    if #codeToTry == 0 or Config.TestedCombinations[codeToTry] then return end
    
    local targetInput, submitBtn = FindGameCodeElements()
    if not targetInput then return end
    
    Config.TestedCombinations[codeToTry] = true
    Config.TotalSubmitAttempts = Config.TotalSubmitAttempts + 1
    
    -- Kodu kutuya yaz
    targetInput.Text = codeToTry
    
    -- Otomatik Gönderme ve Yeşil Submit Butonuna Tıklama Tetikleyicisi
    task.spawn(function()
        pcall(function()
            targetInput:CaptureFocus()
            task.wait(0.01)
            
            if typeof(firesignal) == "function" then
                firesignal(targetInput.FocusLost, true)
            else
                targetInput:ReleaseFocus(true)
            end
            
            if submitBtn then
                task.wait(0.01)
                if typeof(firesignal) == "function" then
                    firesignal(submitBtn.MouseButton1Click)
                    firesignal(submitBtn.Activated)
                end
            end
        end)
    end)
end

-- Parçaları Kümülatif Olarak Birleştirme (X -> XY -> XYZ)
local function RegisterFragmentAndRun(rawText)
    local cleaned = MegaCleanAndExtract(rawText)
    if #cleaned > 0 and cleaned ~= Config.LastExtractedText then
        Config.LastExtractedText = cleaned
        
        -- Daha önce eklenmemişse zincire ekle
        local isAlreadyAdded = false
        for _, frag in ipairs(Config.ChainFragments) do
            if frag == cleaned then
                isAlreadyAdded = true
                break
            end
        end
        
        if not isAlreadyAdded then
            table.insert(Config.ChainFragments, cleaned)
            
            -- X -> XY -> XYZ zincirini boşluksuz oluştur
            local cumulativeCode = table.concat(Config.ChainFragments, "")
            ExecuteCodeSubmission(cumulativeCode)
        end
    end
end

-- [4. MOTOR 1: EKRAN VE WORLD UI TARAYICISI (SCREEN ENGINE)]
local function InitScreenEngine()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local function BindScreenElement(element)
        if (element:IsA("TextLabel") or element:IsA("TextButton")) and element.Visible then
            local fullName = string.lower(element:GetFullName())
            
            -- Chat ve Kod Penceresinin Kendi İçindeki Statik Metinlerini Hariç Tut
            if not string.find(fullName, "chat") and not string.find(fullName, "codes") then
                element:GetPropertyChangedSignal("Text"):Connect(function()
                    if Config.Engine1_Screen then
                        RegisterFragmentAndRun(element.Text)
                    end
                end)
            end
        end
    end
    
    -- Mevcut tüm ekran elemanlarını bağla
    for _, desc in ipairs(playerGui:GetDescendants()) do
        BindScreenElement(desc)
    end
    
    -- Dinamik eklenen ekran elemanlarını bağla
    playerGui.DescendantAdded:Connect(function(desc)
        BindScreenElement(desc)
    end)
end

-- [5. MOTOR 2: LOG, CHAT VE DETAYLI İNCELEYİCİ (LOG ENGINE)]
local function InitLogEngine()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local function BindLogElement(element)
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            local fullName = string.lower(element:GetFullName())
            
            -- Chat veya Log alanına düşen metinleri tara
            if string.find(fullName, "chat") or string.find(fullName, "log") or string.find(fullName, "message") then
                element:GetPropertyChangedSignal("Text"):Connect(function()
                    if Config.Engine2_Log then
                        local raw = string.lower(element.Text)
                        
                        -- Pet Base veya Pet alma duyurusu içeriyorsa kesinlikle iptal et
                        if string.find(raw, "bought") or string.find(raw, "pet base") or string.find(raw, "unlocked") then
                            return
                        end
                        
                        -- SpyderSammy veya Sammy ile ilgili mesaj düşmüşse çalıştır
                        if string.find(raw, "spydersammy") or string.find(raw, "sammy") then
                            RegisterFragmentAndRun(element.Text)
                        end
                    end
                end)
            end
        end
    end
    
    for _, desc in ipairs(playerGui:GetDescendants()) do
        BindLogElement(desc)
    end
    
    playerGui.DescendantAdded:Connect(function(desc)
        BindLogElement(desc)
    end)
end

-- [6. ADVANCED DUAL ENGINE CONTROL PANEL (GUI)]
local function BuildMegaControlPanel()
    if CoreGui:FindFirstChild("LeaMegaMasterGui") then
        CoreGui.LeaMegaMasterGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaMegaMasterGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 220, 0, 130)
    MainFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 220, 130)
    Stroke.Thickness = 1.2
    Stroke.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA MOD: MEGA FULL ENGINE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 10
    Title.Font = Enum.Font.GothamBold
    
    -- Buton 1: Motor 1 (Ekran Tarayıcı)
    local BtnEngine1 = Instance.new("TextButton")
    BtnEngine1.Parent = MainFrame
    BtnEngine1.Size = UDim2.new(0.43, 0, 0, 32)
    BtnEngine1.Position = UDim2.new(0.05, 0, 0.25, 0)
    BtnEngine1.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    BtnEngine1.Text = "M1: EKRAN\n[AÇIK]"
    BtnEngine1.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnEngine1.TextSize = 9
    BtnEngine1.Font = Enum.Font.GothamBold
    Instance.new("UICorner", BtnEngine1).CornerRadius = UDim.new(0, 6)
    
    BtnEngine1.MouseButton1Click:Connect(function()
        Config.Engine1_Screen = not Config.Engine1_Screen
        BtnEngine1.Text = Config.Engine1_Screen and "M1: EKRAN\n[AÇIK]" or "M1: EKRAN\n[KAPALI]"
        BtnEngine1.BackgroundColor3 = Config.Engine1_Screen and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(200, 40, 50)
    end)
    
    -- Buton 2: Motor 2 (Log ve Chat İnceleyici)
    local BtnEngine2 = Instance.new("TextButton")
    BtnEngine2.Parent = MainFrame
    BtnEngine2.Size = UDim2.new(0.43, 0, 0, 32)
    BtnEngine2.Position = UDim2.new(0.52, 0, 0.25, 0)
    BtnEngine2.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    BtnEngine2.Text = "M2: LOG/CHAT\n[AÇIK]"
    BtnEngine2.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnEngine2.TextSize = 9
    BtnEngine2.Font = Enum.Font.GothamBold
    Instance.new("UICorner", BtnEngine2).CornerRadius = UDim.new(0, 6)
    
    BtnEngine2.MouseButton1Click:Connect(function()
        Config.Engine2_Log = not Config.Engine2_Log
        BtnEngine2.Text = Config.Engine2_Log and "M2: LOG/CHAT\n[AÇIK]" or "M2: LOG/CHAT\n[KAPALI]"
        BtnEngine2.BackgroundColor3 = Config.Engine2_Log and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(200, 40, 50)
    end)
    
    -- Bilgi Ekranı
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = MainFrame
    InfoLabel.Size = UDim2.new(0.9, 0, 0, 38)
    InfoLabel.Position = UDim2.new(0.05, 0, 0.62, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Son Parça: Bekleniyor...\nToplam Deneme: 0"
    InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    InfoLabel.TextSize = 9
    InfoLabel.Font = Enum.Font.Code
    InfoLabel.TextWrapped = true
    
    task.spawn(function()
        while task.wait(0.4) do
            if InfoLabel.Parent then
                local last = Config.LastExtractedText ~= "" and Config.LastExtractedText or "Bekleniyor"
                InfoLabel.Text = "Son Parça: " .. last .. "\nDeneme: " .. Config.TotalSubmitAttempts .. " | Parça: " .. #Config.ChainFragments
            end
        end
    end)
end

-- [7. START ALL SYSTEMS]
task.spawn(function()
    pcall(BuildMegaControlPanel)
    pcall(InitScreenEngine)
    pcall(InitLogEngine)
    print("LEA MOD: MEGA DUAL ENGINE SYSTEM READY.")
end)
