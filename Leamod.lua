-- =====================================================================
-- LEA MOD: KEYBOARD FOCUS & SAMMY DETECTOR ENGINE
-- Platform: Mobile (Infinix Note 30 Pro Optimized)
-- Target Game: Steal a Brainrot
-- =====================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().LeaTargetConfig = {
    Engine1_Active = true, -- Ekran Yakalayıcı
    Engine2_Active = true, -- Chat/Log Yakalayıcı
    ChainFragments = {},
    TestedCombinations = {},
    LastExtracted = "",
    TotalAttempts = 0
}

local Config = getgenv().LeaTargetConfig

-- [1. SAF SAMMY KODU AYRIŞTIRICI & SIKI FİLTRE]
local function ExtractSammyCode(rawText)
    if not rawText or type(rawText) ~= "string" or #rawText == 0 then return "" end
    
    local upperText = string.upper(rawText)
    
    -- Satın alma, pet base, fiyat, market gürültülerini KESİNLİKLE reddet
    if string.find(upperText, "BUY") or string.find(upperText, "PURCHASE") or string.find(upperText, "PRICE") 
       or string.find(upperText, "PET") or string.find(upperText, "BOUGHT") or string.find(upperText, "UNLOCKED") then
        return ""
    end
    
    -- Sammy ve Sistem takılarını temizle
    upperText = upperText:gsub("@SPYDERSAMMY", ""):gsub("SPYDERSAMMY", ""):gsub("SAMMY", "")
    upperText = upperText:gsub("REDEEM", ""):gsub("CODES", ""):gsub("CODE", ""):gsub("SUBMIT", "")
    
    -- Sadece A-Z ve 0-9 karakterlerini al
    local cleanBuffer = {}
    for i = 1, #upperText do
        local char = string.sub(upperText, i, i)
        if string.match(char, "[A-Z0-9]") then
            table.insert(cleanBuffer, char)
        end
    end
    
    return table.concat(cleanBuffer, "")
end

-- [2. KULLANICININ KLAVYENİN AÇIK OLDUĞU HEDEF KUTUYU YAKALAMA]
local function GetActiveKeyboardInput()
    -- Sadece senin o an tıkladığın / klavyenin açık olduğu kutuyu hedefler
    local focusedBox = UserInputService:GetFocusedTextBox()
    if focusedBox then
        return focusedBox
    end
    
    -- Eğer klavye kapalıysa oyunun aktif açık olan Chat/Kod kutusunu kontrol et
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            if desc:IsA("TextBox") and desc.Visible then
                local name = string.lower(desc:GetFullName())
                -- Satın alma pencerelerini atla, sadece chat ve kod kutusunu kabul et
                if not string.find(name, "shop") and not string.find(name, "buy") and not string.find(name, "store") then
                    return desc
                end
            end
        end
    end
    
    return nil
end

-- [3. YAZIYI DOĞRUDAN KLAVYENİN OLDUĞU YERE YAZMA VE TETİKLEME]
local function DirectInputSubmit(code)
    if #code == 0 or Config.TestedCombinations[code] then return end
    
    local activeInput = GetActiveKeyboardInput()
    if not activeInput then return end -- Klavye veya odak yoksa hiçbir yere yazma
    
    Config.TestedCombinations[code] = true
    Config.TotalAttempts = Config.TotalAttempts + 1
    
    -- Kodu doğrudan klavyenin açık olduğu kutunun metnine bas
    activeInput.Text = code
    
    task.spawn(function()
        pcall(function()
            activeInput:CaptureFocus()
            task.wait(0.01)
            
            if typeof(firesignal) == "function" then
                firesignal(activeInput.FocusLost, true)
            else
                activeInput:ReleaseFocus(true)
            end
        end)
    end)
end

-- Zincirlama Birleştirici (X -> XY -> XYZ)
local function ProcessIncomingText(rawText)
    local cleanCode = ExtractSammyCode(rawText)
    if #cleanCode > 0 and cleanCode ~= Config.LastExtracted then
        Config.LastExtracted = cleanCode
        
        local exists = false
        for _, v in ipairs(Config.ChainFragments) do
            if v == cleanCode then exists = true break end
        end
        
        if not exists then
            table.insert(Config.ChainFragments, cleanCode)
            local combined = table.concat(Config.ChainFragments, "")
            DirectInputSubmit(combined)
        end
    end
end

-- [4. MOTOR 1: EKRAN TARAYICI]
local function StartScreenScanner()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local function BindScreenUI(elem)
        if (elem:IsA("TextLabel") or elem:IsA("TextButton")) and elem.Visible then
            elem:GetPropertyChangedSignal("Text"):Connect(function()
                if Config.Engine1_Active then
                    ProcessIncomingText(elem.Text)
                end
            end)
        end
    end
    
    for _, desc in ipairs(playerGui:GetDescendants()) do BindScreenUI(desc) end
    playerGui.DescendantAdded:Connect(BindScreenUI)
end

-- [5. MOTOR 2: LOG & CHAT TARAYICI]
local function StartLogScanner()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local function BindLogUI(elem)
        if elem:IsA("TextLabel") or elem:IsA("TextButton") then
            elem:GetPropertyChangedSignal("Text"):Connect(function()
                if Config.Engine2_Active then
                    ProcessIncomingText(elem.Text)
                end
            end)
        end
    end
    
    for _, desc in ipairs(playerGui:GetDescendants()) do BindLogUI(desc) end
    playerGui.DescendantAdded:Connect(BindLogUI)
end

-- [6. KONTROL MENÜSÜ (GUI)]
local function BuildTargetGui()
    if CoreGui:FindFirstChild("LeaTargetMasterGui") then CoreGui.LeaTargetMasterGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaTargetMasterGui"
    ScreenGui.Parent = CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 210, 0, 110)
    Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    Frame.Active = true
    Frame.Draggable = true
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA MOD: KEYBOARD TARGET ENGINE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 9
    Title.Font = Enum.Font.GothamBold
    
    -- Motor 1 Butonu
    local Btn1 = Instance.new("TextButton")
    Btn1.Parent = Frame
    Btn1.Size = UDim2.new(0.43, 0, 0, 30)
    Btn1.Position = UDim2.new(0.05, 0, 0.3, 0)
    Btn1.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    Btn1.Text = "M1: EKRAN\n[AÇIK]"
    Btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn1.TextSize = 8
    Btn1.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn1).CornerRadius = UDim.new(0, 5)
    
    Btn1.MouseButton1Click:Connect(function()
        Config.Engine1_Active = not Config.Engine1_Active
        Btn1.Text = Config.Engine1_Active and "M1: EKRAN\n[AÇIK]" or "M1: EKRAN\n[KAPALI]"
        Btn1.BackgroundColor3 = Config.Engine1_Active and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(200, 40, 50)
    end)
    
    -- Motor 2 Butonu
    local Btn2 = Instance.new("TextButton")
    Btn2.Parent = Frame
    Btn2.Size = UDim2.new(0.43, 0, 0, 30)
    Btn2.Position = UDim2.new(0.52, 0, 0.3, 0)
    Btn2.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    Btn2.Text = "M2: LOG/CHAT\n[AÇIK]"
    Btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn2.TextSize = 8
    Btn2.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0, 5)
    
    Btn2.MouseButton1Click:Connect(function()
        Config.Engine2_Active = not Config.Engine2_Active
        Btn2.Text = Config.Engine2_Active and "M2: LOG/CHAT\n[AÇIK]" or "M2: LOG/CHAT\n[KAPALI]"
        Btn2.BackgroundColor3 = Config.Engine2_Active and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(200, 40, 50)
    end)
    
    local Status = Instance.new("TextLabel")
    Status.Parent = Frame
    Status.Size = UDim2.new(0.9, 0, 0, 30)
    Status.Position = UDim2.new(0.05, 0, 0.65, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Durum: Taramalar Aktif\nDeneme: 0"
    Status.TextColor3 = Color3.fromRGB(0, 255, 180)
    Status.TextSize = 9
    Status.Font = Enum.Font.Code
    
    task.spawn(function()
        while task.wait(0.4) do
            if Status.Parent then
                Status.Text = "Son Kod: " .. (Config.LastExtracted ~= "" and Config.LastExtracted or "Bekleniyor") .. "\nToplam Deneme: " .. Config.TotalAttempts
            end
        end
    end)
end

-- Başlat
task.spawn(function()
    pcall(BuildTargetGui)
    pcall(StartScreenScanner)
    pcall(StartLogScanner)
    print("LEA MOD: TARGET ENGINE READY.")
end)
