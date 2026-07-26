-- // Zombie Mayhem - Basit ve Çalışan Hack
-- // Mesafe bazlı algılama + direkt öldürme + gerçek para

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- GUI OLUŞTUR
-- ============================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 180)
Frame.Position = UDim2.new(0.5, -100, 0.6, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Başlık
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Title.Text = "ZOMBIE HACK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

-- Buton 1: Yakındakileri Öldür
local Button1 = Instance.new("TextButton", Frame)
Button1.Size = UDim2.new(0.9, 0, 0, 40)
Button1.Position = UDim2.new(0.05, 0, 0.2, 0)
Button1.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Button1.Text = "💀 ETRAFI TEMİZLE"
Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
Button1.Font = Enum.Font.GothamBold
Button1.TextSize = 11

local Btn1Corner = Instance.new("UICorner", Button1)
Btn1Corner.CornerRadius = UDim.new(0, 5)

-- Buton 2: Para Ekle
local Button2 = Instance.new("TextButton", Frame)
Button2.Size = UDim2.new(0.9, 0, 0, 40)
Button2.Position = UDim2.new(0.05, 0, 0.48, 0)
Button2.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Button2.Text = "💰 PARA EKLE"
Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
Button2.Font = Enum.Font.GothamBold
Button2.TextSize = 11

local Btn2Corner = Instance.new("UICorner", Button2)
Btn2Corner.CornerRadius = UDim.new(0, 5)

-- Durum yazısı
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.78, 0)
Status.BackgroundTransparency = 1
Status.Text = "Hazır"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10

-- ============================================
-- REMOTE BUL (TÜM REMOTELARI DENE)
-- ============================================
local AllRemotes = {}

for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        table.insert(AllRemotes, v)
    end
end

print("Bulunan remotelar: " .. #AllRemotes)
for i, r in ipairs(AllRemotes) do
    print(i, r.Name, r:GetFullName())
end

-- ============================================
-- ETRAFI TEMİZLE FONKSİYONU
-- ============================================
local function KillAllNearby()
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character
        if Character then
            HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        end
    end
    
    if not HumanoidRootPart then
        Status.Text = "Karakter bulunamadı!"
        return 0
    end
    
    local myPos = HumanoidRootPart.Position
    local killed = 0
    
    -- Workspace'teki TÜM modelleri tara
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            -- Kendimizi atla
            if obj == Character then continue end
            
            -- Oyuncu mu kontrol et
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character == obj then
                    isPlayer = true
                    break
                end
            end
            if isPlayer then continue end
            
            -- Humanoid var mı?
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Mesafe kontrolü (1000 stud = yaklaşık 1000 metre oyun içi)
                local objRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if objRoot then
                    local distance = (myPos - objRoot.Position).Magnitude
                    
                    if distance <= 1000 then
                        -- REMOTE İLE ÖLDÜRME DENE
                        for _, remote in ipairs(AllRemotes) do
                            spawn(function()
                                pcall(function()
                                    remote:FireServer(obj)
                                    remote:FireServer(humanoid)
                                    remote:FireServer(objRoot)
                                end)
                            end)
                        end
                        
                        -- DİREKT HASAR VER
                        spawn(function()
                            pcall(function()
                                humanoid.Health = 0
                                humanoid:TakeDamage(99999)
                            end)
                        end)
                        
                        -- PARÇALA
                        spawn(function()
                            pcall(function()
                                for _, part in ipairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part:BreakJoints()
                                    end
                                end
                            end)
                        end)
                        
                        killed = killed + 1
                    end
                end
            end
        end
    end
    
    return killed
end

-- ============================================
-- PARA EKLEME FONKSİYONU
-- ============================================
local function AddMoney()
    -- Yöntem 1: leaderstats'taki para değerini direkt değiştir
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in ipairs(leaderstats:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("cash") or name:find("money") or name:find("coin") or 
                   name:find("point") or name:find("credit") then
                    v.Value = v.Value + 100000
                    return true, "leaderstats: " .. v.Name
                end
            end
        end
    end
    
    -- Yöntem 2: Player altındaki tüm değerleri dene
    for _, v in ipairs(LocalPlayer:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local name = v.Name:lower()
            if name:find("cash") or name:find("money") or name:find("coin") then
                v.Value = v.Value + 100000
                return true, "Player değer: " .. v.Name
            end
        end
    end
    
    -- Yöntem 3: Karakter altındaki değerleri dene
    if Character then
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("cash") or name:find("money") or name:find("coin") then
                    v.Value = v.Value + 100000
                    return true, "Karakter değer: " .. v.Name
                end
            end
        end
    end
    
    -- Yöntem 4: TÜM remotelara para sinyali gönder
    for _, remote in ipairs(AllRemotes) do
        spawn(function()
            for i = 1, 100 do
                pcall(function()
                    remote:FireServer(1000)
                    remote:FireServer("Money")
                    remote:FireServer("Cash")
                    remote:FireServer(1000, "Kill")
                    remote:FireServer(1000, "Reward")
                end)
            end
        end)
    end
    
    return false, "Remote sinyali gönderildi"
end

-- ============================================
-- BUTON TIKLAMALARI
-- ============================================
Button1.MouseButton1Click:Connect(function()
    Button1.Text = "Temizleniyor..."
    Button1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Status.Text = "Tarama başladı..."
    
    local killed = KillAllNearby()
    
    if killed > 0 then
        Status.Text = killed .. " hedef öldürüldü!"
        Button1.Text = "✅ " .. killed .. " ÖLDÜRÜLDÜ"
        Button1.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        Status.Text = "Yakında hedef yok!"
        Button1.Text = "❌ HEDEF YOK"
        Button1.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end
    
    wait(2)
    Button1.Text = "💀 ETRAFI TEMİZLE"
    Button1.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end)

Button2.MouseButton1Click:Connect(function()
    Button2.Text = "Ekleniyor..."
    Button2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Status.Text = "Para ekleniyor..."
    
    local success, method = AddMoney()
    
    if success then
        Status.Text = "✅ Para eklendi! (" .. method .. ")"
        Button2.Text = "✅ +100K"
        Button2.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        Status.Text = "⚠️ " .. method
        Button2.Text = "⚠️ DENE"
        Button2.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    end
    
    wait(2)
    Button2.Text = "💰 PARA EKLE"
    Button2.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end)

-- ============================================
-- KAPATMA BUTONU
-- ============================================
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0, 22, 0, 22)
Close.Position = UDim2.new(1, -24, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", Close)
CloseCorner.CornerRadius = UDim.new(0, 4)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("====================================")
print("✅ HACK AKTİF")
print("🔴 Buton 1: 1000m içindeki tüm NPC'leri öldürür")
print("🟢 Buton 2: Para değerini direkt değiştirir")
print("📋 " .. #AllRemotes .. " remote bulundu")
print("====================================")
