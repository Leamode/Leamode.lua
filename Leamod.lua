-- // Brainrot New - Spydersammy Admin Panel Bypass ve Mesaj Sistemi
-- // Hedef Oyun: Brainrot New (Roblox)
-- // Sahip: Spydersammy
-- // Açıklama: Admin panelini görünür kılar, konum kontrolünü kaldırır,
-- // Spydersammy adına global mesaj gönderme özelliği ekler.

-- // Ana GUI Oluşturma
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MessageInput = Instance.new("TextBox")
local SendButton = Instance.new("TextButton")
local TogglePanelButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- // GUI Ayarları
ScreenGui.Name = "BrainrotAdminBypass"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SciFi
Title.Text = "BRAINROT ADMIN PANEL - SPYDERSAMMY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextScaled = true

MessageInput.Name = "MessageInput"
MessageInput.Parent = MainFrame
MessageInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MessageInput.BorderColor3 = Color3.fromRGB(255, 0, 0)
MessageInput.Position = UDim2.new(0.05, 0, 0.2, 0)
MessageInput.Size = UDim2.new(0.9, 0, 0, 100)
MessageInput.Font = Enum.Font.SourceSans
MessageInput.PlaceholderText = "Mesajınızı buraya yazın..."
MessageInput.Text = ""
MessageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
MessageInput.TextSize = 14
MessageInput.TextWrapped = true
MessageInput.MultiLine = true
MessageInput.ClearTextOnFocus = false

SendButton.Name = "SendButton"
SendButton.Parent = MainFrame
SendButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SendButton.BorderSizePixel = 0
SendButton.Position = UDim2.new(0.05, 0, 0.6, 0)
SendButton.Size = UDim2.new(0.9, 0, 0, 40)
SendButton.Font = Enum.Font.SciFi
SendButton.Text = "SPYDERSAMMY OLARAK GÖNDER"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.TextSize = 14

TogglePanelButton.Name = "TogglePanelButton"
TogglePanelButton.Parent = MainFrame
TogglePanelButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
TogglePanelButton.BorderSizePixel = 0
TogglePanelButton.Position = UDim2.new(0.05, 0, 0.78, 0)
TogglePanelButton.Size = UDim2.new(0.43, 0, 0, 35)
TogglePanelButton.Font = Enum.Font.SciFi
TogglePanelButton.Text = "ORJINAL PANELI GÖSTER"
TogglePanelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePanelButton.TextSize = 12

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusLabel.BorderSizePixel = 0
StatusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Durum: Hazır - Hedef: Spydersammy"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- // Değişkenler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local originalPanel = nil
local panelVisible = false

-- // RemoteEvent bulma fonksiyonu - Spydersammy'nin mesaj sistemini tespit et
local function findMessageRemote()
    local possibleRemotes = {}
    
    -- // ReplicatedStorage içinde ara
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("message") or name:find("msg") or name:find("broadcast") or 
               name:find("admin") or name:find("announce") or name:find("send") or
               name:find("notify") or name:find("sammy") or name:find("owner") then
                table.insert(possibleRemotes, obj)
            end
        end
    end
    
    -- // ReplicatedFirst içinde ara
    local replicatedFirst = game:GetService("ReplicatedFirst")
    for _, obj in ipairs(replicatedFirst:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("message") or name:find("msg") or name:find("broadcast") or 
               name:find("admin") or name:find("announce") or name:find("send") or
               name:find("notify") or name:find("sammy") or name:find("owner") then
                table.insert(possibleRemotes, obj)
            end
        end
    end
    
    return possibleRemotes
end

-- // Spydersammy'nin admin panelini bul ve bypass et
local function findAndBypassAdminPanel()
    -- // PlayerGui içinde ara
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("ScreenGui") or gui:IsA("Frame") then
            local name = gui.Name:lower()
            if name:find("admin") or name:find("panel") or name:find("sammy") or 
               name:find("owner") or name:find("mod") or name:find("control") then
                originalPanel = gui
                break
            end
        end
    end
    
    -- // CoreGui içinde ara (bazı oyunlar burada saklar)
    for _, gui in ipairs(game.CoreGui:GetDescendants()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            if name:find("admin") or name:find("panel") or name:find("sammy") or 
               name:find("owner") or name:find("mod") or name:find("control") then
                originalPanel = gui
                break
            end
        end
    end
    
    if originalPanel then
        StatusLabel.Text = "Durum: Panel bulundu - " .. originalPanel.Name
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "Durum: Panel aranıyor - tüm GUI'ler taranıyor..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- // Tüm GUI'leri tara
        for _, gui in ipairs(game:GetDescendants()) do
            if gui:IsA("ScreenGui") then
                local name = gui.Name:lower()
                if name:find("admin") or name:find("panel") or name:find("sammy") or 
                   name:find("owner") then
                    originalPanel = gui
                    StatusLabel.Text = "Durum: Panel bulundu - " .. originalPanel.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    break
                end
            end
        end
    end
    
    return originalPanel
end

-- // Konum kontrolünü kaldır ve paneli herkese görünür yap
local function bypassPanelVisibility()
    if not originalPanel then return false end
    
    -- // Panelin Parent'ını CoreGui'ye taşı (konum kontrolünü bypass)
    pcall(function()
        originalPanel.Parent = game.CoreGui
    end)
    
    -- // Görünürlük ayarlarını zorla
    pcall(function()
        if originalPanel:IsA("ScreenGui") then
            originalPanel.Enabled = true
            originalPanel.ResetOnSpawn = false
            
            -- // Tüm alt öğeleri görünür yap
            for _, child in ipairs(originalPanel:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("TextButton") or 
                   child:IsA("TextBox") or child:IsA("TextLabel") or
                   child:IsA("ImageLabel") or child:IsA("ScrollingFrame") then
                    child.Visible = true
                end
            end
        end
    end)
    
    -- // Anti-tamper korumasını kaldırmayı dene
    pcall(function()
        for _, script in ipairs(originalPanel:GetDescendants()) do
            if script:IsA("LocalScript") or script:IsA("Script") then
                -- // Konum kontrolü yapan scriptleri devre dışı bırak
                local source = script.Source or ""
                if source:find("PlayerGui") or source:find("LocalPlayer") or 
                   source:find("UserId") or source:find("owner") then
                    script.Disabled = true
                end
            end
        end
    end)
    
    -- // PlayerGui'den CoreGui'ye taşınan panel için metatable koruması
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- // Parent değişikliklerini engelleme
            if method == "FindFirstChild" and tostring(self) == "PlayerGui" then
                if args[1] and originalPanel and 
                   tostring(args[1]) == originalPanel.Name then
                    return nil -- // PlayerGui'de aramayı engelle, CoreGui'de kal
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end
    
    panelVisible = true
    StatusLabel.Text = "Durum: Panel bypass edildi - GÖRÜNÜR"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    return true
end

-- // Mesaj gönderme fonksiyonu - Spydersammy'nin yetkisini taklit et
local function sendMessageAsSammy(message)
    if not message or message == "" then
        StatusLabel.Text = "Durum: HATA - Mesaj boş olamaz!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    end
    
    local remotes = findMessageRemote()
    
    if #remotes == 0 then
        -- // Remote bulunamadı, alternatif yöntemler dene
        
        -- // Yöntem 1: Direkt chat mesajı olarak göndermeyi dene
        pcall(function()
            local chatService = game:GetService("TextChatService")
            if chatService then
                -- // System message olarak gönder
                local textChannel = chatService:FindFirstChild("TextChannels") or 
                                   chatService:FindFirstChild("RBXGeneral")
                if textChannel then
                    -- // Admin etiketi ile gönder
                    local displayMessage = "[Spydersammy - Admin]: " .. message
                    textChannel:DisplaySystemMessage(displayMessage)
                end
            end
        end)
        
        -- // Yöntem 2: StarterGui üzerinden notification gönder
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Spydersammy",
                Text = message,
                Duration = 5,
                Button1 = "Tamam"
            })
        end)
        
        -- // Yöntem 3: Chat sistemini simüle et
        pcall(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local chatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents then
                local sayMessage = chatEvents:FindFirstChild("SayMessageRequest")
                if sayMessage and sayMessage:IsA("RemoteEvent") then
                    -- // Spoof HeadColor ve Name
                    sayMessage:FireServer(
                        "[Spydersammy]: " .. message,
                        "All" -- // Tüm sunucuya
                    )
                end
            end
        end)
        
        -- // Yöntem 4: Billboard GUI oluştur (tüm oyunculara görünür)
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if char and char:FindFirstChild("Head") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "SammyMessage"
                    billboard.Parent = char.Head
                    billboard.Adornee = char.Head
                    billboard.Size = UDim2.new(0, 400, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 1000
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Parent = billboard
                    textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    textLabel.BackgroundTransparency = 0.3
                    textLabel.BorderSizePixel = 0
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Font = Enum.Font.SciFi
                    textLabel.Text = "[Spydersammy]: " .. message
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextScaled = true
                    
                    game:GetService("Debris"):AddItem(billboard, 5)
                end
            end
        end)
        
        StatusLabel.Text = "Durum: Alternatif yöntemle gönderildi"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        return true
    end
    
    -- // Bulunan Remote'ları dene
    local success = false
    for _, remote in ipairs(remotes) do
        pcall(function()
            -- // Farklı parametre formatlarını dene
            -- // Format 1: Sadece mesaj
            remote:FireServer(message)
            success = true
            
            -- // Format 2: Mesaj + sender info
            remote:FireServer(message, "Spydersammy")
            
            -- // Format 3: Table formatı
            remote:FireServer({
                Message = message,
                Sender = "Spydersammy",
                FromAdmin = true,
                MessageType = "Announcement",
                Color = Color3.fromRGB(255, 0, 0),
                DisplayTime = 10
            })
        end)
    end
    
    if success then
        StatusLabel.Text = "Durum: Mesaj Spydersammy olarak gönderildi!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "Durum: Remote bulundu ama gönderme başarısız"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
    
    return success
end

-- // Send butonu işlevi
SendButton.MouseButton1Click:Connect(function()
    local message = MessageInput.Text
    if message and message ~= "" then
        sendMessageAsSammy(message)
        MessageInput.Text = ""
    end
end)

-- // Panel görünürlük toggle butonu
TogglePanelButton.MouseButton1Click:Connect(function()
    if panelVisible and originalPanel then
        -- // Gizle
        pcall(function()
            originalPanel.Enabled = false
            for _, child in ipairs(originalPanel:GetDescendants()) do
                if child:IsA("GuiObject") then
                    child.Visible = false
                end
            end
        end)
        panelVisible = false
        TogglePanelButton.Text = "ORJINAL PANELI GOSTER"
        StatusLabel.Text = "Durum: Panel gizlendi"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        if not originalPanel then
            findAndBypassAdminPanel()
        end
        if originalPanel then
            bypassPanelVisibility()
            TogglePanelButton.Text = "ORJINAL PANELI GIZLE"
        end
    end
end)

-- // Başlangıç otomatik tarama
spawn(function()
    wait(1)
    findAndBypassAdminPanel()
    if originalPanel then
        wait(0.5)
        bypassPanelVisibility()
    end
    
    -- // Sürekli tarama (panel sonradan yüklenebilir)
    while not originalPanel do
        wait(2)
        findAndBypassAdminPanel()
        if originalPanel then
            bypassPanelVisibility()
        end
    end
    
    -- // Periyodik anti-reset koruması
    while true do
        wait(5)
        if originalPanel and panelVisible then
            pcall(function()
                if originalPanel.Parent ~= game.CoreGui then
                    originalPanel.Parent = game.CoreGui
                end
                originalPanel.Enabled = true
            end)
        end
        
        -- // Remote listesini güncelle
        local remotes = findMessageRemote()
        if #remotes > 0 then
            StatusLabel.Text = "Durum: " .. #remotes .. " Remote aktif - Hazır"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- // Kısayol tuşu: Enter ile gönder
MessageInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local message = MessageInput.Text
        if message and message ~= "" then
            sendMessageAsSammy(message)
            MessageInput.Text = ""
        end
    end
end)

-- // GUI'yi minimize etme butonu
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(0.9, 0, 0, 0)
MinimizeButton.Size = UDim2.new(0, 30, 0, 20)
MinimizeButton.Font = Enum.Font.SciFi
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 400, 0, 40)
        MessageInput.Visible = false
        SendButton.Visible = false
        TogglePanelButton.Visible = false
        StatusLabel.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 300)
        MessageInput.Visible = true
        SendButton.Visible = true
        TogglePanelButton.Visible = true
        StatusLabel.Visible = true
        MinimizeButton.Text = "_"
    end
end)

print("// Brainrot Admin Bypass yuklendi - Hedef: Spydersammy")
print("// Panel gorunurluk bypass: Aktif")
print("// Mesaj gonderme: Hazir")
print("// Tum konum kontrolleri kaldirildi")
