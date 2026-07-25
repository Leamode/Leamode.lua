-- // ============================================
-- // BRAINROT NEW - SAMMY EVENT SCANNER v2.0
-- // Parça 1: Remote tarama ve format yakalama
-- // Amaç: Sammy'nin mesaj gönderme eventini bul
-- // ============================================

-- // Servisler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // Global değişkenler (Parça 2 ile paylaşılacak)
getgenv().SammyData = {
    MessageRemote = nil,       -- Sammy'nin mesaj RemoteEvent/RemoteFunction'ı
    CapturedFormat = nil,      -- Yakalanan mesaj formatı
    AllRemotes = {},           -- Tüm remote listesi
    IsScanning = false,        -- Tarama aktif mi
    ScanComplete = false,      -- Tarama tamamlandı mı
    HookedCount = 0,           -- Hooklanan remote sayısı
    MessageLog = {}            -- Mesaj geçmişi
}

local SammyData = getgenv().SammyData

-- // Log fonksiyonu
local function Log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] [%s] %s", timestamp, level, message)
    print(logEntry)
    table.insert(SammyData.MessageLog, logEntry)
    if #SammyData.MessageLog > 100 then
        table.remove(SammyData.MessageLog, 1)
    end
end

-- // Tüm RemoteEvent ve RemoteFunction'ları tara
local function ScanAllRemotes()
    Log("INFO", "Tüm Remote'lar taranıyor...")
    local foundRemotes = {}
    
    -- Taranacak konteynerler
    local containers = {
        {Name = "ReplicatedStorage", Object = ReplicatedStorage},
        {Name = "ReplicatedFirst", Object = ReplicatedFirst},
        {Name = "Workspace", Object = workspace},
        {Name = "PlayerGui", Object = LocalPlayer:WaitForChild("PlayerGui")},
        {Name = "PlayerScripts", Object = LocalPlayer:WaitForChild("PlayerScripts")},
        {Name = "Backpack", Object = LocalPlayer:WaitForChild("Backpack")}
    }
    
    -- Sammy ile ilgili anahtar kelimeler
    local sammyKeywords = {
        "message", "msg", "broadcast", "announce", "admin", 
        "sammy", "owner", "send", "notify", "alert", "global",
        "server", "event", "display", "text", "show", "chat",
        "system", "popup", "overhead", "banner", "screen"
    }
    
    for _, container in ipairs(containers) do
        pcall(function()
            if not container.Object then return end
            
            for _, obj in ipairs(container.Object:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local objName = obj.Name:lower()
                    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                    local fullPath = obj:GetFullName():lower()
                    
                    -- Öncelik hesapla
                    local priority = "LOW"
                    local matchReason = "Genel Remote"
                    
                    for _, keyword in ipairs(sammyKeywords) do
                        if objName:find(keyword) or parentName:find(keyword) then
                            priority = "HIGH"
                            matchReason = string.format("Eşleşme: '%s'", keyword)
                            break
                        end
                    end
                    
                    -- Özel admin klasörü kontrolü
                    if fullPath:find("admin") or fullPath:find("sammy") or fullPath:find("owner") then
                        priority = "HIGH"
                        matchReason = "Admin/Sammy yolu"
                    end
                    
                    local remoteInfo = {
                        Object = obj,
                        Name = obj.Name,
                        FullPath = obj:GetFullName(),
                        Type = obj.ClassName,
                        ParentName = obj.Parent and obj.Parent.Name or "Bilinmiyor",
                        Priority = priority,
                        Reason = matchReason,
                        IsSelected = false
                    }
                    
                    table.insert(foundRemotes, remoteInfo)
                    Log("DEBUG", string.format("Bulundu [%s]: %s (%s) - %s", 
                        priority, obj.Name, obj.ClassName, matchReason))
                end
            end
        end)
    end
    
    -- Sonuçları kaydet
    SammyData.AllRemotes = foundRemotes
    
    -- İstatistik
    local highCount = 0
    for _, r in ipairs(foundRemotes) do
        if r.Priority == "HIGH" then highCount = highCount + 1 end
    end
    
    Log("SUCCESS", string.format("Tarama tamamlandı: %d Remote bulundu (%d yüksek öncelikli)", 
        #foundRemotes, highCount))
    
    return foundRemotes
end

-- // Metatable hook ile tüm FireServer/InvokeServer çağrılarını yakala
local function HookNamecallMethod()
    Log("INFO", "Namecall hook kuruluyor...")
    
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then
            error("Metatable bulunamadı!")
        end
        
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- FireServer / InvokeServer yakalama
            if (method == "FireServer" or method == "InvokeServer") and 
               (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                
                local remotePath = self:GetFullName():lower()
                local remoteName = self.Name:lower()
                
                -- Sammy ile ilgili mi kontrol et
                local isSammyRelated = false
                local sammyKeywords = {"message", "msg", "broadcast", "announce", 
                                        "admin", "sammy", "owner", "send", "notify"}
                
                for _, kw in ipairs(sammyKeywords) do
                    if remotePath:find(kw) or remoteName:find(kw) then
                        isSammyRelated = true
                        break
                    end
                end
                
                if isSammyRelated and args[1] then
                    Log("INTERCEPT", string.format("YAKALANDI: %s | Argüman: %s", 
                        self.Name, HttpService:JSONEncode(args)))
                    
                    -- Format yakala
                    if not SammyData.CapturedFormat then
                        local format = {
                            RemoteObject = self,
                            RemoteName = self.Name,
                            RemoteFullPath = self:GetFullName(),
                            ArgCount = #args,
                            Args = {},
                            ArgTypes = {}
                        }
                        
                        for i, arg in ipairs(args) do
                            format.ArgTypes[i] = typeof(arg)
                            format.Args[i] = arg
                            
                            -- Eğer tablo ise iç yapısını da kaydet
                            if typeof(arg) == "table" then
                                local tableStructure = {}
                                for k, v in pairs(arg) do
                                    tableStructure[tostring(k)] = typeof(v)
                                end
                                format.ArgTypes[i] = "table"
                                format["TableStructure"] = tableStructure
                            end
                        end
                        
                        SammyData.CapturedFormat = format
                        SammyData.MessageRemote = self
                        
                        Log("SUCCESS", "==================== FORMAT YAKALANDI ====================")
                        Log("SUCCESS", string.format("Remote: %s", self:GetFullName()))
                        Log("SUCCESS", string.format("Argüman Sayısı: %d", #args))
                        for i, arg in ipairs(args) do
                            Log("SUCCESS", string.format("Arg[%d]: %s = %s", 
                                i, typeof(arg), typeof(arg) == "string" and arg or HttpService:JSONEncode(arg)))
                        end
                        Log("SUCCESS", "==========================================================")
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
    
    if success then
        SammyData.HookedCount = SammyData.HookedCount + 1
        Log("SUCCESS", "Namecall hook başarıyla kuruldu")
    else
        Log("ERROR", string.format("Namecall hook başarısız: %s", tostring(err)))
    end
    
    return success
end

-- // OnClientEvent dinleyicileri kur
local function HookOnClientEvents()
    Log("INFO", "OnClientEvent dinleyicileri kuruluyor...")
    local hookCount = 0
    
    for _, remoteInfo in ipairs(SammyData.AllRemotes) do
        if remoteInfo.Priority == "HIGH" and remoteInfo.Object:IsA("RemoteEvent") then
            pcall(function()
                remoteInfo.Object.OnClientEvent:Connect(function(...)
                    local args = {...}
                    
                    Log("EVENT", string.format("SERVER->CLIENT: %s | Args: %s", 
                        remoteInfo.Name, HttpService:JSONEncode(args)))
                    
                    -- Format yakalanmamışsa ve gelen veri varsa formatı kaydet
                    if not SammyData.CapturedFormat and args[1] then
                        local format = {
                            RemoteObject = remoteInfo.Object,
                            RemoteName = remoteInfo.Name,
                            RemoteFullPath = remoteInfo.FullPath,
                            ArgCount = #args,
                            Args = {},
                            ArgTypes = {}
                        }
                        
                        for i, arg in ipairs(args) do
                            format.ArgTypes[i] = typeof(arg)
                            format.Args[i] = arg
                            
                            if typeof(arg) == "table" then
                                local tableStructure = {}
                                for k, v in pairs(arg) do
                                    tableStructure[tostring(k)] = typeof(v)
                                end
                                format["TableStructure"] = tableStructure
                            end
                        end
                        
                        SammyData.CapturedFormat = format
                        SammyData.MessageRemote = remoteInfo.Object
                        
                        Log("SUCCESS", "==================== FORMAT YAKALANDI (OnClientEvent) ====================")
                        Log("SUCCESS", string.format("Remote: %s", remoteInfo.FullPath))
                        Log("SUCCESS", string.format("Argüman Sayısı: %d", #args))
                        Log("SUCCESS", "==========================================================")
                    end
                end)
                hookCount = hookCount + 1
            end)
        end
    end
    
    SammyData.HookedCount = SammyData.HookedCount + hookCount
    Log("SUCCESS", string.format("%d OnClientEvent dinleyici kuruldu", hookCount))
    return hookCount
end

-- // Sürekli tarama döngüsü (yeni remote'lar için)
local function StartContinuousScan()
    if SammyData.IsScanning then return end
    SammyData.IsScanning = true
    
    Log("INFO", "Sürekli tarama başlatıldı (3 saniyede bir)")
    
    spawn(function()
        while SammyData.IsScanning do
            wait(3)
            
            local newRemotes = ScanAllRemotes()
            
            -- Yeni HIGH priority remote var mı?
            for _, newRemote in ipairs(newRemotes) do
                if newRemote.Priority == "HIGH" then
                    local exists = false
                    for _, existing in ipairs(SammyData.AllRemotes) do
                        if existing.Object == newRemote.Object then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        Log("ALERT", string.format("YENI REMOTE: %s (%s)", 
                            newRemote.Name, newRemote.FullPath))
                        SammyData.AllRemotes = newRemotes
                        
                        -- Yeni remote için OnClientEvent kur
                        if newRemote.Object:IsA("RemoteEvent") then
                            pcall(function()
                                newRemote.Object.OnClientEvent:Connect(function(...)
                                    local args = {...}
                                    if not SammyData.CapturedFormat and args[1] then
                                        SammyData.CapturedFormat = {
                                            RemoteObject = newRemote.Object,
                                            RemoteName = newRemote.Name,
                                            RemoteFullPath = newRemote.FullPath,
                                            ArgCount = #args,
                                            Args = {},
                                            ArgTypes = {}
                                        }
                                        for i, arg in ipairs(args) do
                                            SammyData.CapturedFormat.ArgTypes[i] = typeof(arg)
                                            SammyData.CapturedFormat.Args[i] = arg
                                        end
                                        SammyData.MessageRemote = newRemote.Object
                                        Log("SUCCESS", "FORMAT YAKALANDI (Yeni Remote): " .. newRemote.Name)
                                    end
                                end)
                            end)
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- // Ana başlatma fonksiyonu
local function InitializeScanner()
    Log("INFO", "========================================")
    Log("INFO", "BRAINROT SAMMY SCANNER - BAŞLATILIYOR")
    Log("INFO", "========================================")
    
    -- Adım 1: Remote'ları tara
    ScanAllRemotes()
    
    -- Adım 2: Namecall hook kur
    HookNamecallMethod()
    
    -- Adım 3: OnClientEvent dinleyicileri kur
    HookOnClientEvents()
    
    -- Adım 4: Sürekli taramayı başlat
    StartContinuousScan()
    
    SammyData.ScanComplete = true
    
    Log("SUCCESS", "========================================")
    Log("SUCCESS", "TARAMA SISTEMI HAZIR")
    Log("SUCCESS", string.format("Toplam Remote: %d", #SammyData.AllRemotes))
    Log("SUCCESS", string.format("Hooklanan: %d", SammyData.HookedCount))
    Log("SUCCESS", "Sammy'nin mesaj göndermesi bekleniyor...")
    Log("SUCCESS", "Format yakalandığında Parça 2'yi çalıştırabilirsiniz")
    Log("SUCCESS", "========================================")
    
    return true
end

-- // Manuel tarama tetikleme fonksiyonu (Parça 2'den çağrılabilir)
function getgenv().RescanRemotes()
    Log("INFO", "Manuel yeniden tarama başlatıldı...")
    ScanAllRemotes()
    HookOnClientEvents()
    return SammyData.AllRemotes
end

-- // Scanner durumunu döndür
function getgenv().GetScannerStatus()
    return {
        ScanComplete = SammyData.ScanComplete,
        TotalRemotes = #SammyData.AllRemotes,
        HighPriority = (function()
            local count = 0
            for _, r in ipairs(SammyData.AllRemotes) do
                if r.Priority == "HIGH" then count = count + 1 end
            end
            return count
        end)(),
        HookedCount = SammyData.HookedCount,
        FormatCaptured = SammyData.CapturedFormat ~= nil,
        SelectedRemote = SammyData.MessageRemote and SammyData.MessageRemote.Name or "Seçilmedi"
    }
end

-- // Başlat
InitializeScanner()

print([[
============================================
 PARÇA 1 - SCANNER AKTIF
 Sammy mesaj gönderene kadar BEKLE
 Format yakalanınca konsolda göreceksin
 Sonra Parça 2'yi çalıştır
============================================
]])-- // ============================================
-- // BRAINROT NEW - SAMMY MESSAGE SENDER v2.0
-- // Parça 2: GUI ve mesaj gönderme sistemi
-- // Gereksinim: Parça 1 çalışmış olmalı
-- // ============================================

-- // Parça 1'den gelen veriyi kontrol et
local SammyData = getgenv().SammyData

if not SammyData then
    warn("[HATA] Parça 1 çalıştırılmamış! Önce Scanner'ı çalıştırın.")
    warn("[HATA] getgenv().SammyData bulunamadı.")
    return
end

if not SammyData.ScanComplete then
    warn("[UYARI] Tarama henüz tamamlanmadı, bekleyin...")
    repeat wait(0.5) until SammyData.ScanComplete
end

-- // Servisler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // GUI Oluştur
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SammyMessagePanel"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Ana çerçeve
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderColor3 = Color3.fromRGB(200, 30, 30)
    MainFrame.BorderSizePixel = 2
    MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 520, 0, 380)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Gradient arka plan efekti
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = MainFrame
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
    })
    UIGradient.Rotation = 45
    
    -- Başlık
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.Text = "🔴 SAMMY MESSAGE SYSTEM - AKTIF"
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.TextSize = 15
    
    -- Durum etiketi
    local StatusBar = Instance.new("TextLabel")
    StatusBar.Name = "StatusBar"
    StatusBar.Parent = MainFrame
    StatusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    StatusBar.BorderSizePixel = 0
    StatusBar.Position = UDim2.new(0, 0, 0, 36)
    StatusBar.Size = UDim2.new(1, 0, 0, 24)
    StatusBar.Font = Enum.Font.SourceSans
    StatusBar.Text = "⏳ Bağlantı kontrol ediliyor..."
    StatusBar.TextColor3 = Color3.fromRGB(255, 200, 0)
    StatusBar.TextSize = 12
    StatusBar.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Bilgi çerçevesi
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Name = "InfoFrame"
    InfoFrame.Parent = MainFrame
    InfoFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    InfoFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    InfoFrame.BorderSizePixel = 1
    InfoFrame.Position = UDim2.new(0.02, 0, 0.18, 0)
    InfoFrame.Size = UDim2.new(0.96, 0, 0, 70)
    
    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Name = "InfoTitle"
    InfoTitle.Parent = InfoFrame
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Position = UDim2.new(0.02, 0, 0, 0)
    InfoTitle.Size = UDim2.new(0.96, 0, 0, 18)
    InfoTitle.Font = Enum.Font.SourceSansBold
    InfoTitle.Text = "📋 SISTEM BILGISI"
    InfoTitle.TextColor3 = Color3.fromRGB(255, 150, 150)
    InfoTitle.TextSize = 12
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Name = "InfoText"
    InfoText.Parent = InfoFrame
    InfoText.BackgroundTransparency = 1
    InfoText.Position = UDim2.new(0.02, 0, 0.3, 0)
    InfoText.Size = UDim2.new(0.96, 0, 0, 45)
    InfoText.Font = Enum.Font.SourceSans
    InfoText.Text = "Yükleniyor..."
    InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoText.TextSize = 11
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextWrapped = true
    InfoText.RichText = true
    
    -- Mesaj giriş alanı
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "MessageLabel"
    MessageLabel.Parent = MainFrame
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Position = UDim2.new(0.02, 0, 0.39, 0)
    MessageLabel.Size = UDim2.new(0.96, 0, 0, 18)
    MessageLabel.Font = Enum.Font.SourceSansBold
    MessageLabel.Text = "✏️ MESAJ:"
    MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    MessageLabel.TextSize = 12
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local MessageInput = Instance.new("TextBox")
    MessageInput.Name = "MessageInput"
    MessageInput.Parent = MainFrame
    MessageInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MessageInput.BorderColor3 = Color3.fromRGB(200, 0, 0)
    MessageInput.BorderSizePixel = 1
    MessageInput.Position = UDim2.new(0.02, 0, 0.44, 0)
    MessageInput.Size = UDim2.new(0.96, 0, 0, 80)
    MessageInput.Font = Enum.Font.SourceSans
    MessageInput.PlaceholderText = "Sammy olarak gönderilecek mesajı buraya yaz..."
    MessageInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    MessageInput.Text = ""
    MessageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    MessageInput.TextSize = 14
    MessageInput.TextWrapped = true
    MessageInput.MultiLine = true
    MessageInput.ClearTextOnFocus = false
    
    -- Butonlar
    local SendButton = Instance.new("TextButton")
    SendButton.Name = "SendButton"
    SendButton.Parent = MainFrame
    SendButton.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    SendButton.BorderSizePixel = 0
    SendButton.Position = UDim2.new(0.02, 0, 0.68, 0)
    SendButton.Size = UDim2.new(0.47, 0, 0, 36)
    SendButton.Font = Enum.Font.GothamBold
    SendButton.Text = "📨 SAMMY OLARAK GÖNDER"
    SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendButton.TextSize = 13
    SendButton.AutoButtonColor = false
    
    -- Hover efekti
    SendButton.MouseEnter:Connect(function()
        TweenService:Create(SendButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        }):Play()
    end)
    SendButton.MouseLeave:Connect(function()
        TweenService:Create(SendButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 20, 20)
        }):Play()
    end)
    
    local RescanButton = Instance.new("TextButton")
    RescanButton.Name = "RescanButton"
    RescanButton.Parent = MainFrame
    RescanButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RescanButton.BorderSizePixel = 0
    RescanButton.Position = UDim2.new(0.51, 0, 0.68, 0)
    RescanButton.Size = UDim2.new(0.47, 0, 0, 36)
    RescanButton.Font = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    RescanButton.Text = "🔄 REMOTE'LARI YENILE"
    RescanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RescanButton.TextSize = 13
    RescanButton.AutoButtonColor = false
    
    RescanButton.MouseEnter:Connect(function()
        TweenService:Create(RescanButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        }):Play()
    end)
    RescanButton.MouseLeave:Connect(function()
        TweenService:Create(RescanButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    -- Mesaj geçmişi
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Name = "LogLabel"
    LogLabel.Parent = MainFrame
    LogLabel.BackgroundTransparency = 1
    LogLabel.Position = UDim2.new(0.02, 0, 0.79, 0)
    LogLabel.Size = UDim2.new(0.96, 0, 0, 16)
    LogLabel.Font = Enum.Font.SourceSansBold
    LogLabel.Text = "📜 LOG:"
    LogLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    LogLabel.TextSize = 11
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local LogFrame = Instance.new("ScrollingFrame")
    LogFrame.Name = "LogFrame"
    LogFrame.Parent = MainFrame
    LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LogFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    LogFrame.BorderSizePixel = 1
    LogFrame.Position = UDim2.new(0.02, 0, 0.83, 0)
    LogFrame.Size = UDim2.new(0.96, 0, 0, 55)
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogFrame.ScrollBarThickness = 6
    LogFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
    
    local LogList = Instance.new("UIListLayout")
    LogList.Name = "LogList"
    LogList.Parent = LogFrame
    LogList.SortOrder = Enum.SortOrder.Name
    LogList.Padding = UDim.new(0, 2)
    
    -- Kapatma butonu
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.93, 0, 0, 0)
    CloseButton.Size = UDim2.new(0, 32, 0, 20)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.AutoButtonColor = false
    
    CloseButton.MouseEnter:Connect(function()
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end)
    CloseButton.MouseLeave:Connect(function()
        CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    end)
    
    -- GUI referanslarını döndür
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        StatusBar = StatusBar,
        InfoText = InfoText,
        MessageInput = MessageInput,
        SendButton = SendButton,
        RescanButton = RescanButton,
        LogFrame = LogFrame,
        LogList = LogList,
        CloseButton = CloseButton
    }
end

-- // GUI'yi oluştur
local GUI = CreateGUI()

-- // Log ekleme fonksiyonu
local function AddGUILog(message, color)
    color = color or Color3.fromRGB(200, 200, 200)
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "Log_" .. #GUI.LogFrame:GetChildren()
    logLabel.Parent = GUI.LogFrame
    logLabel.BackgroundTransparency = 1
    logLabel.Size = UDim2.new(1, -10, 0, 16)
    logLabel.Font = Enum.Font.SourceSans
    logLabel.Text = os.date("%H:%M:%S") .. " | " .. message
    logLabel.TextColor3 = color
    logLabel.TextSize = 10
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextWrapped = false
    
    GUI.LogFrame.CanvasSize = UDim2.new(0, 0, 0, GUI.LogList.AbsoluteContentSize.Y + 5)
    GUI.LogFrame.CanvasPosition = Vector2.new(0, GUI.LogFrame.CanvasSize.Y.Offset)
end

-- // Bilgi metnini güncelle
local function UpdateInfoText()
    local status = getgenv().GetScannerStatus and getgenv().GetScannerStatus() or {}
    
    local info = string.format([[
<b>Toplam Remote:</b> %d | <b>Yüksek Öncelik:</b> %d | <b>Hook:</b> %d
<b>Format:</b> %s | <b>Seçili Remote:</b> %s
%s
    ]],
        status.TotalRemotes or 0,
        status.HighPriority or 0,
        status.HookedCount or 0,
        status.FormatCaptured and '<font color="#00ff00">✓ YAKALANDI</font>' or '<font color="#ff0000">✗ Bekleniyor...</font>',
        status.SelectedRemote or "Yok",
        SammyData.CapturedFormat and string.format(
            '<font color="#ffff00">Arg sayısı: %d | İlk arg tipi: %s</font>',
            SammyData.CapturedFormat.ArgCount,
            SammyData.CapturedFormat.ArgTypes[1] or "?"
        ) or '<font color="#ff8888">Sammy mesaj gönderene kadar bekle</font>'
    )
    
    GUI.InfoText.Text = info
    GUI.InfoText.RichText = true
end

-- // Mesaj gönderme fonksiyonu
local function SendMessageAsSammy(message)
    if not message or message:gsub("%s+", "") == "" then
        AddGUILog("HATA: Mesaj boş olamaz!", Color3.fromRGB(255, 80, 80))
        return false
    end
    
    local remote = SammyData.MessageRemote
    local format = SammyData.CapturedFormat
    
    if not remote then
        AddGUILog("HATA: Sammy Remote'u bulunamadı! Önce Parça 1'i çalıştırın.", Color3.fromRGB(255, 80, 80))
        GUI.StatusBar.Text = "❌ Remote bulunamadı!"
        GUI.StatusBar.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    end
    
    -- Format yakalanmışsa kullan
    if format then
        AddGUILog(string.format("Format kullanılıyor: %s (%d argüman)", 
            format.RemoteName, format.ArgCount), Color3.fromRGB(100, 200, 255))
        
        local argsToSend = {}
        
        for i = 1, format.ArgCount do
            local argType = format.ArgTypes[i]
            
            if i == 1 then
                if argType == "string" then
                    table.insert(argsToSend, message)
                elseif argType == "table" then
                    local newTable = {}
                    local structure = format.TableStructure or {}
                    
                    for key, valType in pairs(structure) do
                        local keyLower = tostring(key):lower()
                        
                        if keyLower:find("message") or keyLower:find("msg") or 
                           keyLower:find("text") or keyLower:find("content") then
                            newTable[key] = message
                        elseif keyLower:find("name") or keyLower:find("sender") or 
                               keyLower:find("user") or keyLower:find("from") then
                            newTable[key] = "Spydersammy"
                        elseif valType == "boolean" then
                            newTable[key] = true
                        elseif valType == "number" then
                            newTable[key] = 10
                        elseif valType == "string" then
                            newTable[key] = "Spydersammy"
                        else
                            newTable[key] = true
                        end
                    end
                    table.insert(argsToSend, newTable)
                end
            else
                if argType == "string" then
                    table.insert(argsToSend, "Spydersammy")
                elseif argType == "boolean" then
                    table.insert(argsToSend, true)
                elseif argType == "number" then
                    table.insert(argsToSend, 10)
                elseif argType == "table" then
                    table.insert(argsToSend, {FromAdmin = true, Sender = "Spydersammy"})
                else
                    table.insert(argsToSend, nil)
                end
            end
        end
        
        -- Gönder
        local success, err = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(argsToSend))
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(unpack(argsToSend))
            end
        end)
        
        if success then
            AddGUILog("✓ MESAJ GÖNDERILDI: " .. message, Color3.fromRGB(0, 255, 100))
            GUI.StatusBar.Text = "✅ Mesaj gönderildi!"
            GUI.StatusBar.TextColor3 = Color3.fromRGB(0, 255, 0)
            return true
        else
            AddGUILog("HATA: " .. tostring(err), Color3.fromRGB(255, 80, 80))
            GUI.StatusBar.Text = "❌ Gönderme başarısız!"
            GUI.StatusBar.TextColor3 = Color3.fromRGB(255, 0, 0)
            return false
        end
    end
    
    -- Format yoksa tüm varyasyonları dene (fallback)
    AddGUILog("Format bilinmiyor, tüm varyasyonlar deneniyor...", Color3.fromRGB(255, 200, 0))
    
    local variants = {
        {message},
        {message, "Spydersammy"},
        {message, true},
        {message, "Spydersammy", true},
        {message, Color3.fromRGB(255, 0, 0)},
        {message, 10},
        {{Message = message, Sender = "Spydersammy", FromAdmin = true}},
        {{Text = message, From = "Spydersammy", Admin = true}},
        {{msg = message, user = "Spydersammy", isAdmin = true}},
        {{Content = message, SenderName = "Spydersammy", IsAdmin = true}},
    }
    
    local sent = false
    for i, variant in ipairs(variants) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(variant))
            else
                remote:InvokeServer(unpack(variant))
            end
        end)
        wait(0.03)
        sent = true
    end
    
    if sent then
        AddGUILog("✓ Mesaj gönderildi (fallback mod): " .. message, Color3.fromRGB(0, 200, 100))
        GUI.StatusBar.Text = "✅ Mesaj gönderildi (fallback)"
        GUI.StatusBar.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
    
    return sent
end

-- // Buton event'lerini bağla
GUI.SendButton.MouseButton1Click:Connect(function()
    local msg = GUI.MessageInput.Text
    if msg and msg:gsub("%s+", "") ~= "" then
        SendMessageAsSammy(msg)
        GUI.MessageInput.Text = ""
    else
        AddGUILog("UYARI: Lütfen bir mesaj yazın!", Color3.fromRGB(255, 200, 0))
    end
end)

GUI.RescanButton.MouseButton1Click:Connect(function()
    AddGUILog("Remote'lar yeniden taranıyor...", Color3.fromRGB(200, 200, 0))
    
    if getgenv().RescanRemotes then
        getgenv().RescanRemotes()
        AddGUILog("Tarama tamamlandı!", Color3.fromRGB(0, 255, 0))
    else
        AddGUILog("Tarama fonksiyonu bulunamadı (Parça 1 eksik)", Color3.fromRGB(255, 100, 0))
    end
    
    UpdateInfoText()
end)

GUI.CloseButton.MouseButton1Click:Connect(function()
    GUI.ScreenGui:Destroy()
end)

-- // Enter tuşu ile gönderme
GUI.MessageInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local msg = GUI.MessageInput.Text
        if msg and msg:gsub("%s+", "") ~= "" then
            SendMessageAsSammy(msg)
            GUI.MessageInput.Text = ""
        end
    end
end)

-- // Periyodik güncelleme
spawn(function()
    while GUI.ScreenGui and GUI.ScreenGui.Parent do
        UpdateInfoText()
        
        -- Durum kontrolü
        if SammyData.CapturedFormat then
            GUI.StatusBar.Text = string.format("🟢 Format Yakalandı | Remote: %s", 
                SammyData.CapturedFormat.RemoteName)
            GUI.StatusBar.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            GUI.StatusBar.Text = "🟡 Format bekleniyor... Sammy'nin mesaj göndermesini bekleyin"
            GUI.StatusBar.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
        
        wait(1)
    end
end)

-- // Başlangıç
AddGUILog("========================================", Color3.fromRGB(255, 100, 100))
AddGUILog("SAMMY MESSAGE SENDER - AKTIF", Color3.fromRGB(255, 50, 50))
AddGUILog("Parça 1 verileri başarıyla alındı", Color3.fromRGB(0, 255, 0))

if SammyData.CapturedFormat then
    AddGUILog(string.format("Format hazır: %s", SammyData.CapturedFormat.RemoteName), 
        Color3.fromRGB(0, 255, 100))
else
    AddGUILog("Format henüz yakalanmadı - Sammy'nin mesaj atmasını bekleyin", 
        Color3.fromRGB(255, 200, 0))
end

AddGUILog("========================================", Color3.fromRGB(255, 100, 100))

UpdateInfoText()

print([[
============================================
 PARÇA 2 - MESSAGE SENDER AKTIF
 GUI yüklendi, mesaj göndermeye hazır
 Format yakalanmadıysa Sammy'nin
 mesaj atmasını bekleyin
============================================
]])
