-- =====================================================================
-- LEA MOD: SPYDERSAMMY ULTRA-FAST DETECTOR & DIRECT SUBMIT ENGINE
-- Platform: Mobile (Infinix Note 30 Pro Optimized)
-- Target Game: Steal a Brainrot
-- Feature: Zero-Delay, Hide Text on Catch, Chat + Panel Dual Scanning
-- =====================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

getgenv().LeaSammyConfig = {
    Active = true,
    TestedCodes = {},
    LastExtracted = "",
    TotalAttempts = 0
}

local Config = getgenv().LeaSammyConfig

-- [0. CORE GUI HIZLI YÜKLEME]
local function SafeProtectGui(gui)
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
    else
        gui.Parent = CoreGui
    end
end

-- [1. NET KOD TEMİZLEYİCİ]
local function CleanCodeOnly(rawText)
    if not rawText or type(rawText) ~= "string" or #rawText == 0 then return "" end
    
    local upperText = string.upper(rawText)
    
    -- Temizlik Etiketleri
    upperText = upperText:gsub("@SPYDERSAMMY", ""):gsub("SPYDERSAMMY", ""):gsub("SAMMY", "")
    upperText = upperText:gsub("CODE", ""):gsub("CODES", ""):gsub("REDEEM", "")
    
    local cleanBuffer = {}
    for i = 1, #upperText do
        local char = string.sub(upperText, i, i)
        if string.match(char, "[A-Z0-9]") then
            table.insert(cleanBuffer, char)
        end
    end
    
    return table.concat(cleanBuffer, "")
end

-- [2. AÇIK KLAVYE KUTUSUNU ANINDA BULMA]
local function GetCurrentFocusedTextBox()
    return UserInputService:GetFocusedTextBox()
end

-- [3. SIFIR GECİKMELİ METİN YAZMA VE GÖNDERME]
local function SubmitToActiveKeyboard(code)
    if #code == 0 or Config.TestedCodes[code] then return end
    
    local activeBox = GetCurrentFocusedTextBox()
    if not activeBox then return end
    
    Config.TestedCodes[code] = true
    Config.TotalAttempts = Config.TotalAttempts + 1
    Config.LastExtracted = code
    
    -- SIFIR DELAY: Doğrudan yaz ve tetikle
    activeBox.Text = code
    
    pcall(function()
        if typeof(firesignal) == "function" then
            firesignal(activeBox.FocusLost, true)
        else
            activeBox:ReleaseFocus(true)
        end
    end)
end

-- [4. MESAJ VE EKRAN METNİ İŞLEYİCİ]
local function EvaluateTargetText(senderName, rawText, guiElement)
    if not Config.Active or not rawText or #rawText == 0 then return end
    
    local lowerSender = string.lower(senderName or "")
    local lowerMsg = string.lower(rawText)
    
    -- Spydersammy / Sammy tespiti
    local isSammy = string.find(lowerSender, "spydersammy") 
                 or string.find(lowerSender, "sammy") 
                 or string.find(lowerMsg, "spydersammy") 
                 or string.find(lowerMsg, "@spydersammy")
                 or string.find(lowerMsg, "sammy")
    
    if isSammy then
        local extractedCode = CleanCodeOnly(rawText)
        if #extractedCode > 0 then
            -- Eğer ekrandaki bir TextLabel/TextButton ise ekranda görünmesini engelle
            if guiElement and typeof(guiElement) == "Instance" and guiElement:IsA("GuiObject") then
                pcall(function()
                    guiElement.Visible = false
                end)
            end
            
            -- Beklemeden klavyeye yaz
            SubmitToActiveKeyboard(extractedCode)
        end
    end
end

-- [5. ULTRA-HIZLI CANLI TESPİT ENGINE]
local function StartUltraEngine()
    
    -- MOTOR A: Modern TextChatService Dinleyici
    pcall(function()
        TextChatService.MessageReceived:Connect(function(textChatMessage)
            if textChatMessage then
                local sender = textChatMessage.TextSource and Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
                local senderName = sender and sender.Name or ""
                EvaluateTargetText(senderName, textChatMessage.Text, nil)
            end
        end)
    end)

    -- MOTOR B: Klasik Chat Event Dinleyici
    pcall(function()
        local DefaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if DefaultChat then
            local OnMessage = DefaultChat:FindFirstChild("OnMessageDoneFiltering")
            if OnMessage then
                OnMessage.OnClientEvent:Connect(function(data)
                    if data then
                        EvaluateTargetText(data.FromSpeaker or "", data.Message or "", nil)
                    end
                end)
            end
        end
    end)

    -- MOTOR C: Ekran, Kontrol Paneli ve Duyuru Yazılarını Anlık Tarayıcı
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        local function FastScanElement(elem)
            if elem:IsA("TextLabel") or elem:IsA("TextButton") then
                -- Metin değiştiği an (0ms)
                elem:GetPropertyChangedSignal("Text"):Connect(function()
                    EvaluateTargetText("", elem.Text, elem)
                end)
                -- Mevcut metin
                if #elem.Text > 0 then
                    EvaluateTargetText("", elem.Text, elem)
                end
            end
        end

        -- PlayerGui altındaki tüm mevcut ve yeni eklenen elementleri bağla
        for _, desc in ipairs(playerGui:GetDescendants()) do
            FastScanElement(desc)
        end
        
        playerGui.DescendantAdded:Connect(FastScanElement)
    end)
end

-- [6. KONTROL MENÜSÜ (GUI)]
local function BuildGui()
    if CoreGui:FindFirstChild("LeaSammyUltraGui") then CoreGui.LeaSammyUltraGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaSammyUltraGui"
    SafeProtectGui(ScreenGui)
    
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 210, 0, 95)
    Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Frame.Active = true
    Frame.Draggable = true
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA MOD: ULTRA FAST SAMMY ENGINE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 9
    Title.Font = Enum.Font.GothamBold
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Frame
    ToggleBtn.Size = UDim2.new(0.9, 0, 0, 26)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    ToggleBtn.Text = "TARAMA: AKTİF (0ms)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 9
    ToggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Config.Active = not Config.Active
        ToggleBtn.Text = Config.Active and "TARAMA: AKTİF (0ms)" or "TARAMA: KAPALI"
        ToggleBtn.BackgroundColor3 = Config.Active and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(200, 40, 50)
    end)
    
    local Status = Instance.new("TextLabel")
    Status.Parent = Frame
    Status.Size = UDim2.new(0.9, 0, 0, 25)
    Status.Position = UDim2.new(0.05, 0, 0.65, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Son Kod: -\nDeneme: 0"
    Status.TextColor3 = Color3.fromRGB(0, 255, 180)
    Status.TextSize = 8
    Status.Font = Enum.Font.Code
    
    task.spawn(function()
        while task.wait(0.3) do
            if Status.Parent then
                Status.Text = "Son Kod: " .. (Config.LastExtracted ~= "" and Config.LastExtracted or "Bekleniyor") .. " | Toplam: " .. Config.TotalAttempts
            end
        end
    end)
end

-- BAŞLAT
task.spawn(function()
    pcall(BuildGui)
    pcall(StartUltraEngine)
    print("LEA MOD: ULTRA FAST SAMMY DETECTOR READY.")
end)
