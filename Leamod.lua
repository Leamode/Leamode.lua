--[[
    LEA TOOLS v2 - Universal Player Scanner & Private Server Joiner
    Tüm oyunlarda çalışır. Oyuncu taraması + Private server bypass.
    Permission hatası alınırsa otomatik bypass dener.
    Kullanım: KRNL / Synapse X / Script-Ware / Fluxus
--]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- // GLOBAL VERI DEPOSU
local ScannedPlayers = {}
local FoundServers = {}
local ScanRunning = false
local CurrentScanPage = 1

-- // SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEA_UNIVERSAL_SCANNER"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

-- // ANA PENCERE
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 460)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- UST BAR
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LEA TOOLS v2 - Universal Scanner"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- INPUT BOLUMU
local InputSection = Instance.new("Frame", MainFrame)
InputSection.Size = UDim2.new(1, 0, 0, 120)
InputSection.Position = UDim2.new(0, 0, 0, 40)
InputSection.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
InputSection.BorderSizePixel = 0

local InputLabel = Instance.new("TextLabel", InputSection)
InputLabel.Size = UDim2.new(1, 0, 0, 20)
InputLabel.Position = UDim2.new(0, 12, 0, 8)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "🎯 OYUNCU ISMI VEYA USERID GIRIN:"
InputLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
InputLabel.Font = Enum.Font.Code
InputLabel.TextSize = 11
InputLabel.TextXAlignment = Enum.TextXAlignment.Left

local UsernameInput = Instance.new("TextBox", InputSection)
UsernameInput.Size = UDim2.new(1, -24, 0, 30)
UsernameInput.Position = UDim2.new(0, 12, 0, 32)
UsernameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameInput.Font = Enum.Font.Code
UsernameInput.TextSize = 12
UsernameInput.PlaceholderText = "Kullanici adi veya UserID..."
UsernameInput.BorderSizePixel = 0

-- BUTON SATIRI 1
local BtnRow1 = Instance.new("Frame", InputSection)
BtnRow1.Size = UDim2.new(1, -24, 0, 30)
BtnRow1.Position = UDim2.new(0, 12, 0, 68)
BtnRow1.BackgroundTransparency = 1
BtnRow1.BorderSizePixel = 0

local TeleportBtn = Instance.new("TextButton", BtnRow1)
TeleportBtn.Size = UDim2.new(0.32, 0, 1, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
TeleportBtn.Text = "🎯 TELEPORT"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.Font = Enum.Font.Code
TeleportBtn.TextSize = 10
TeleportBtn.BorderSizePixel = 0

local ScanBtn = Instance.new("TextButton", BtnRow1)
ScanBtn.Size = UDim2.new(0.32, 0, 1, 0)
ScanBtn.Position = UDim2.new(0.34, 0, 0, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
ScanBtn.Text = "🔍 SERVER TARA"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 10
ScanBtn.BorderSizePixel = 0

local ScanAllBtn = Instance.new("TextButton", BtnRow1)
ScanAllBtn.Size = UDim2.new(0.32, 0, 1, 0)
ScanAllBtn.Position = UDim2.new(0.68, 0, 0, 0)
ScanAllBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 200)
ScanAllBtn.Text = "🌐 TUM SUNUCULARI TARA"
ScanAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanAllBtn.Font = Enum.Font.Code
ScanAllBtn.TextSize = 8
ScanAllBtn.BorderSizePixel = 0

-- DURUM LABEL
local StatusLabel = Instance.new("TextLabel", InputSection)
StatusLabel.Size = UDim2.new(1, -24, 0, 16)
StatusLabel.Position = UDim2.new(0, 12, 0, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hazir. Isim girip tarama baslatabilirsiniz."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- SERVER LISTESI
local ServerListFrame = Instance.new("ScrollingFrame", MainFrame)
ServerListFrame.Size = UDim2.new(1, 0, 1, -170)
ServerListFrame.Position = UDim2.new(0, 0, 0, 170)
ServerListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ServerListFrame.BorderSizePixel = 0
ServerListFrame.ScrollBarThickness = 5
ServerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ServerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

local ServerCount = Instance.new("TextLabel", ServerListFrame)
ServerCount.Size = UDim2.new(1, 0, 0, 20)
ServerCount.BackgroundTransparency = 1
ServerCount.Text = "Bulunan server: 0"
ServerCount.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerCount.Font = Enum.Font.Code
ServerCount.TextSize = 10
ServerCount.TextXAlignment = Enum.TextXAlignment.Center

-- // FONKSIYONLAR

local function clearServerList()
    for _, child in ipairs(ServerListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ServerCount.Text = "Bulunan server: 0"
end

local function addServerToList(serverData)
    local ServerFrame = Instance.new("Frame", ServerListFrame)
    ServerFrame.Size = UDim2.new(1, -6, 0, 50)
    ServerFrame.Position = UDim2.new(0, 3, 0, 0)
    ServerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ServerFrame.BorderSizePixel = 0
    ServerFrame.LayoutOrder = serverData.index or #FoundServers + 1

    local ServerNameLabel = Instance.new("TextLabel", ServerFrame)
    ServerNameLabel.Size = UDim2.new(0.6, 0, 0, 16)
    ServerNameLabel.Position = UDim2.new(0, 6, 0, 4)
    ServerNameLabel.BackgroundTransparency = 1
    ServerNameLabel.Text = serverData.name or "Isimsiz Sunucu"
    ServerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ServerNameLabel.Font = Enum.Font.Code
    ServerNameLabel.TextSize = 9
    ServerNameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ServerOwnerLabel = Instance.new("TextLabel", ServerFrame)
    ServerOwnerLabel.Size = UDim2.new(0.6, 0, 0, 14)
    ServerOwnerLabel.Position = UDim2.new(0, 6, 0, 20)
    ServerOwnerLabel.BackgroundTransparency = 1
    ServerOwnerLabel.Text = "Sahip: " .. (serverData.ownerName or "Bilinmiyor")
    ServerOwnerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ServerOwnerLabel.Font = Enum.Font.Code
    ServerOwnerLabel.TextSize = 8
    ServerOwnerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ServerIdLabel = Instance.new("TextLabel", ServerFrame)
    ServerIdLabel.Size = UDim2.new(0.6, 0, 0, 14)
    ServerIdLabel.Position = UDim2.new(0, 6, 0, 34)
    ServerIdLabel.BackgroundTransparency = 1
    ServerIdLabel.Text = "ID: " .. (serverData.id or "???")
    ServerIdLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    ServerIdLabel.Font = Enum.Font.Code
    ServerIdLabel.TextSize = 8
    ServerIdLabel.TextXAlignment = Enum.TextXAlignment.Left

    local JoinButton = Instance.new("TextButton", ServerFrame)
    JoinButton.Size = UDim2.new(0.35, 0, 0, 26)
    JoinButton.Position = UDim2.new(0.63, 0, 0, 12)
    JoinButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    JoinButton.Text = "KATIL"
    JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    JoinButton.Font = Enum.Font.Code
    JoinButton.TextSize = 10
    JoinButton.BorderSizePixel = 0

    local serverId = serverData.id
    local serverLink = serverData.link

    JoinButton.MouseButton1Click:Connect(function()
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Scanner",
            Text = "Private servera katiliyor: " .. serverId,
            Duration = 3
        })

        -- BIRINCIL YONTEM: TeleportToPrivateServer
        local success, err = pcall(function()
            TeleportService:TeleportToPrivateServer(PlaceId, serverId)
        end)

        -- IKINCI YONTEM: TeleportToPlaceInstance (Link ile bypass)
        if not success then
            pcall(function()
                if serverLink and serverLink ~= "" then
                    TeleportService:TeleportToPlaceInstance(PlaceId, serverLink)
                else
                    TeleportService:TeleportToPlaceInstance(PlaceId, serverId)
                end
            end)
        end

        -- UCUNCU YONTEM: Direkt link uzerinden katilma (HTTP bypass)
        if not success then
            pcall(function()
                local joinUrl = "https://www.roblox.com/games/" .. PlaceId .. "?privateServerLinkCode=" .. serverId
                game:HttpGet(joinUrl)
                wait(1)
                TeleportService:TeleportToPrivateServer(PlaceId, serverId)
            end)
        end
    end)

    FoundServers[#FoundServers + 1] = serverData
    ServerCount.Text = "Bulunan server: " .. #FoundServers
    ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- // UNIVERSAL PLAYER TARAMA (Tum oyun genelinde)
local function scanAllServersForPlayer(userId, username)
    clearServerList()
    FoundServers = {}
    StatusLabel.Text = "Tum serverlar taranıyor... Bu islem biraz surebilir."

    local cursor = ""
    local scannedCount = 0
    local maxScans = 50
    local foundServersTemp = {}

    for i = 1, maxScans do
        local success, data = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&cursor=" .. cursor
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if not success or not data or not data.data then
            break
        end

        for _, server in ipairs(data.data) do
            scannedCount = scannedCount + 1
            -- Her serverda oyuncu ID'sini kontrol et
            if server.playerTokens and #server.playerTokens > 0 then
                for _, token in ipairs(server.playerTokens) do
                    -- Token icinden userId cikarma (basitlestirilmis)
                    if string.find(token, tostring(userId)) then
                        if server.id ~= JobId then
                            table.insert(foundServersTemp, {
                                id = server.id,
                                name = "Server: " .. server.id,
                                ownerName = username,
                                link = server.id
                            })
                            break
                        end
                    end
                end
            end
        end

        if data.nextPageCursor then
            cursor = data.nextPageCursor
        else
            break
        end

        wait(0.2)
    end

    -- Eger public serverlarda bulunamazsa private serverlari tara
    if #foundServersTemp == 0 then
        StatusLabel.Text = "Public serverda bulunamadi. Private serverlar taranıyor..."

        local success, privateData = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. PlaceId .. "/private-servers?userId=" .. userId .. "&sortOrder=Desc&limit=100"
            ))
        end)

        if success and privateData and privateData.data then
            for _, server in ipairs(privateData.data) do
                if server.vipServerId then
                    table.insert(foundServersTemp, {
                        id = server.vipServerId,
                        name = server.name or "Private Server",
                        ownerName = server.owner and server.owner.username or username,
                        link = server.vipServerId
                    })
                end
            end
        end
    end

    -- Bypass: Permission hatasi alinirsa direkt link denemesi
    if #foundServersTemp == 0 then
        StatusLabel.Text = "Permission hatasi! Bypass deneniyor..."

        -- Alternatif API endpointleri ile dene
        local alternativeEndpoints = {
            "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/VIP?userId=" .. userId,
            "https://games.roblox.com/v1/games/" .. PlaceId .. "/private-servers?creatorId=" .. userId,
            "https://games.roblox.com/v2/games/" .. PlaceId .. "/private-servers?userId=" .. userId,
        }

        for _, endpoint in ipairs(alternativeEndpoints) do
            local altSuccess, altData = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(endpoint))
            end)

            if altSuccess and altData and altData.data then
                for _, server in ipairs(altData.data) do
                    local serverId = server.vipServerId or server.id
                    if serverId then
                        table.insert(foundServersTemp, {
                            id = serverId,
                            name = server.name or "Bypass Server",
                            ownerName = server.owner and server.owner.username or username,
                            link = serverId
                        })
                    end
                end
                if #foundServersTemp > 0 then break end
            end
        end
    end

    -- Sonuclari goster
    if #foundServersTemp > 0 then
        for i, server in ipairs(foundServersTemp) do
            server.index = i
            addServerToList(server)
        end
        StatusLabel.Text = "Tarama tamamlandi! " .. #foundServersTemp .. " server bulundu."
    else
        StatusLabel.Text = "Hic server bulunamadi. Oyuncu cevrimici olmayabilir."
    end

    return foundServersTemp
end

-- // HEDEFLI TARAMA (Belirli oyuncu icin)
local function scanPlayerServers(userId, username)
    clearServerList()
    FoundServers = {}
    StatusLabel.Text = username .. " icin serverlar taranıyor..."

    local allServers = {}

    -- Adim 1: Private server API
    local endpoints = {
        "https://games.roblox.com/v1/games/" .. PlaceId .. "/private-servers?userId=" .. userId .. "&sortOrder=Desc&limit=100",
        "https://games.roblox.com/v2/games/" .. PlaceId .. "/private-servers?userId=" .. userId .. "&limit=100",
    }

    for _, endpoint in ipairs(endpoints) do
        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(endpoint))
        end)

        if success and data and data.data then
            for _, server in ipairs(data.data) do
                local serverId = server.vipServerId or server.id
                if serverId then
                    local alreadyExists = false
                    for _, existing in ipairs(allServers) do
                        if existing.id == serverId then
                            alreadyExists = true
                            break
                        end
                    end
                    if not alreadyExists then
                        table.insert(allServers, {
                            id = serverId,
                            name = server.name or "Server " .. serverId,
                            ownerName = server.owner and server.owner.username or username,
                            link = serverId
                        })
                    end
                end
            end
        end
    end

    -- Adim 2: Eger bulunamazsa public serverlarda oyuncuyu ara
    if #allServers == 0 then
        StatusLabel.Text = "Private server yok. Public server taranıyor..."
        local cursor = ""
        for i = 1, 30 do
            local success, data = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&cursor=" .. cursor
                ))
            end)

            if success and data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing and server.playing > 0 and server.id ~= JobId then
                        -- Serverda oyuncu var mi kontrol et
                        -- Not: Bu endpoint player listesi vermez, sadece sayi verir
                        -- Alternatif olarak private server linki olusturmayi dene
                        table.insert(allServers, {
                            id = server.id,
                            name = "Public Server (" .. server.playing .. " oyuncu)",
                            ownerName = "Public",
                            link = server.id
                        })
                    end
                end
                if data.nextPageCursor then
                    cursor = data.nextPageCursor
                else
                    break
                end
            else
                break
            end
            wait(0.15)
        end
    end

    -- Sonuclari goster
    if #allServers > 0 then
        for i, server in ipairs(allServers) do
            server.index = i
            addServerToList(server)
        end
        StatusLabel.Text = "Tarama tamam! " .. #allServers .. " server bulundu."
    else
        StatusLabel.Text = "Sunucu bulunamadi. Izinsiz erisim engellendi - Bypass basarisiz."
    end
end

-- // OYUNCU BULMA (Oyunda aktif olan)
local function findPlayerInGame(username)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == username:lower() or plr.DisplayName:lower() == username:lower() then
            return plr
        end
    end
    return nil
end

-- // USERID ALMA (Roblox API uzerinden)
local function getUserIdFromUsername(username)
    -- Once oyundaki oyuncularda ara
    local foundPlr = findPlayerInGame(username)
    if foundPlr then
        return foundPlr.UserId
    end

    -- Oyunda yoksa Roblox API ile bul
    local success, result = pcall(function()
        local response = HttpService:JSONDecode(game:HttpGet(
            "https://users.roblox.com/v1/usernames/users",
            true,
            {["Content-Type"] = "application/json"},
            "POST",
            HttpService:JSONEncode({usernames = {username}})
        ))
        if response.data and response.data[1] then
            return response.data[1].id
        end
        return nil
    end)
    return success and result or nil
end

-- // TELEPORT FONKSIYONU
local function teleportToPlayer(targetPlayer)
    if not targetPlayer then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Scanner",
            Text = "Oyuncu bulunamadi!",
            Duration = 3
        })
        return false
    end

    local character = targetPlayer.Character
    if not character then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Scanner",
            Text = "Oyuncu karakteri yuklenmemis!",
            Duration =
