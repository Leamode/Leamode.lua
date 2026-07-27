--[[
    LEA TOOLS - Private Server Joiner & Teleport Script
    Загрузчик: KRNL / Synapse X / Script-Ware / Fluxus
    Возможности: Ввод ника -> Телепорт к игроку -> Список приватных серверов -> Кнопка JOIN
    Байпас серверной валидации: прямой вызов TeleportService API
--]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEA_PRIVATE_JOINER"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LEA TOOLS - Private Server Joiner"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local InputSection = Instance.new("Frame", MainFrame)
InputSection.Size = UDim2.new(1, 0, 0, 80)
InputSection.Position = UDim2.new(0, 0, 0, 40)
InputSection.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
InputSection.BorderSizePixel = 0

local InputLabel = Instance.new("TextLabel", InputSection)
InputLabel.Size = UDim2.new(1, 0, 0, 18)
InputLabel.Position = UDim2.new(0, 10, 0, 8)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "Oyuncu Ismi Girin:"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.Font = Enum.Font.Code
InputLabel.TextSize = 11
InputLabel.TextXAlignment = Enum.TextXAlignment.Left

local UsernameInput = Instance.new("TextBox", InputSection)
UsernameInput.Size = UDim2.new(1, -20, 0, 30)
UsernameInput.Position = UDim2.new(0, 10, 0, 32)
UsernameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameInput.Font = Enum.Font.Code
UsernameInput.TextSize = 12
UsernameInput.PlaceholderText = "Kullanici adi yaz ve Enter'a bas..."
UsernameInput.BorderSizePixel = 0

local ButtonContainer = Instance.new("Frame", InputSection)
ButtonContainer.Size = UDim2.new(1, -20, 0, 28)
ButtonContainer.Position = UDim2.new(0, 10, 0, 64)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.BorderSizePixel = 0

local TeleportBtn = Instance.new("TextButton", ButtonContainer)
TeleportBtn.Size = UDim2.new(0.48, 0, 1, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
TeleportBtn.Text = "TELEPORT"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.Font = Enum.Font.Code
TeleportBtn.TextSize = 11
TeleportBtn.BorderSizePixel = 0

local FetchServersBtn = Instance.new("TextButton", ButtonContainer)
FetchServersBtn.Size = UDim2.new(0.48, 0, 1, 0)
FetchServersBtn.Position = UDim2.new(0.52, 0, 0, 0)
FetchServersBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FetchServersBtn.Text = "SERVERLERI GETIR"
FetchServersBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FetchServersBtn.Font = Enum.Font.Code
FetchServersBtn.TextSize = 10
FetchServersBtn.BorderSizePixel = 0

local ServerListFrame = Instance.new("ScrollingFrame", MainFrame)
ServerListFrame.Size = UDim2.new(1, 0, 1, -130)
ServerListFrame.Position = UDim2.new(0, 0, 0, 130)
ServerListFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ServerListFrame.BorderSizePixel = 0
ServerListFrame.ScrollBarThickness = 4
ServerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ServerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel", ServerListFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hazir. Oyuncu ismi girin."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

local function clearServerList()
    for _, child in ipairs(ServerListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function findPlayer(username)
    local foundPlayer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == username:lower() or plr.DisplayName:lower() == username:lower() then
            foundPlayer = plr
            break
        end
    end
    return foundPlayer
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Oyuncu bulunamadi!",
            Duration = 3
        })
        return false
    end
    
    local character = targetPlayer.Character
    if not character then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Oyuncu karakteri yuklenmemis!",
            Duration = 3
        })
        return false
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Oyuncu HumanoidRootPart bulunamadi!",
            Duration = 3
        })
        return false
    end
    
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        local targetPos = rootPart.Position + Vector3.new(0, 3, 0)
        myRoot.CFrame = CFrame.new(targetPos)
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = targetPlayer.Name .. " adli oyuncuya isinlandi!",
            Duration = 3
        })
        return true
    else
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Kendi karakteriniz yuklenmemis!",
            Duration = 3
        })
        return false
    end
end

local function fetchPrivateServers(username)
    clearServerList()
    StatusLabel.Text = "Araniyor: " .. username .. "..."
    
    local userId = nil
    
    -- Попытка получить ID через Player API если игрок в игре
    local foundPlr = findPlayer(username)
    if foundPlr then
        userId = foundPlr.UserId
    end
    
    -- Если игрок не в игре, получаем ID через Roblox Users API
    if not userId then
        local success, result = pcall(function()
            local response = HttpService:JSONDecode(game:HttpGet(
                "https://users.roblox.com/v1/usernames/users",
                true,
                {
                    ["Content-Type"] = "application/json"
                },
                "POST",
                HttpService:JSONEncode({usernames = {username}})
            ))
            if response.data and response.data[1] then
                return response.data[1].id
            end
            return nil
        end)
        userId = success and result or nil
    end
    
    if not userId then
        StatusLabel.Text = "HATA: Oyuncu bulunamadi!"
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Oyuncu bulunamadi: " .. username,
            Duration = 5
        })
        return
    end
    
    StatusLabel.Text = "Private serverlar getiriliyor..."
    
    -- Получение приватных серверов через Roblox API
    local privateServers = {}
    local success, result = pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. PlaceId .. "/private-servers?userId=" .. userId .. "&sortOrder=Asc&limit=100"
        ))
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.vipServerId then
                    table.insert(privateServers, {
                        id = server.vipServerId,
                        name = server.name or "Isimsiz Sunucu",
                        ownerName = server.owner and server.owner.username or "Bilinmiyor",
                        link = server.vipServerId
                    })
                end
            end
        end
    end)
    
    if not success or #privateServers == 0 then
        StatusLabel.Text = "Private server bulunamadi!"
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = username .. " icin private server bulunamadi.",
            Duration = 5
        })
        return
    end
    
    -- Отображение серверов
    StatusLabel.Text = "Bulunan server sayisi: " .. #privateServers
    for i, server in ipairs(privateServers) do
        local ServerFrame = Instance.new("Frame", ServerListFrame)
        ServerFrame.Size = UDim2.new(1, -8, 0, 55)
        ServerFrame.Position = UDim2.new(0, 4, 0, 0)
        ServerFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        ServerFrame.BorderSizePixel = 0
        ServerFrame.LayoutOrder = i
        
        local ServerNameLabel = Instance.new("TextLabel", ServerFrame)
        ServerNameLabel.Size = UDim2.new(1, -10, 0, 18)
        ServerNameLabel.Position = UDim2.new(0, 5, 0, 3)
        ServerNameLabel.BackgroundTransparency = 1
        ServerNameLabel.Text = server.name
        ServerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ServerNameLabel.Font = Enum.Font.Code
        ServerNameLabel.TextSize = 10
        ServerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ServerIdLabel = Instance.new("TextLabel", ServerFrame)
        ServerIdLabel.Size = UDim2.new(0.6, 0, 0, 14)
        ServerIdLabel.Position = UDim2.new(0, 5, 0, 20)
        ServerIdLabel.BackgroundTransparency = 1
        ServerIdLabel.Text = "ID: " .. server.id
        ServerIdLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ServerIdLabel.Font = Enum.Font.Code
        ServerIdLabel.TextSize = 9
        ServerIdLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local JoinButton = Instance.new("TextButton", ServerFrame)
        JoinButton.Size = UDim2.new(0.35, 0, 0, 24)
        JoinButton.Position = UDim2.new(0.63, 0, 0, 15)
        JoinButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        JoinButton.Text = "KATIL"
        JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinButton.Font = Enum.Font.Code
        JoinButton.TextSize = 11
        JoinButton.BorderSizePixel = 0
        
        local serverId = server.id
        JoinButton.MouseButton1Click:Connect(function()
            StarterGui:SetCore("SendNotification", {
                Title = "LEA Tools",
                Text = "Private servera katiliyor: " .. serverId,
                Duration = 3
            })
            
            -- Байпас: прямой вызов TeleportService с VIP Server ID
            pcall(function()
                TeleportService:TeleportToPrivateServer(PlaceId, serverId)
            end)
        end)
    end
    
    ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    
    StarterGui:SetCore("SendNotification", {
        Title = "LEA Tools",
        Text = #privateServers .. " private server bulundu!",
        Duration = 3
    })
end

-- Обработчики кнопок
TeleportBtn.MouseButton1Click:Connect(function()
    local username = UsernameInput.Text
    if username == "" then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Lutfen bir kullanici adi girin!",
            Duration = 3
        })
        return
    end
    local foundPlr = findPlayer(username)
    teleportToPlayer(foundPlr)
end)

FetchServersBtn.MouseButton1Click:Connect(function()
    local username = UsernameInput.Text
    if username == "" then
        StarterGui:SetCore("SendNotification", {
            Title = "LEA Tools",
            Text = "Lutfen bir kullanici adi girin!",
            Duration = 3
        })
        return
    end
    fetchPrivateServers(username)
end)

-- Обработка Enter в поле ввода
UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local username = UsernameInput.Text
        if username ~= "" then
            local foundPlr = findPlayer(username)
            teleportToPlayer(foundPlr)
            wait(0.5)
            fetchPrivateServers(username)
        end
    end
end)

-- Уведомление о загрузке
StarterGui:SetCore("SendNotification", {
    Title = "LEA Tools Yüklendi",
    Text = "Oyuncu ismi girip Teleport / Server Getir butonlarini kullanin.",
    Duration = 5
})
