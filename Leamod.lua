--[[
    STEAL A BRIANROT - ULTIMATE ANTI RESET v3.0
    Otomatik baslar, menu yok, sessiz calisir.
    7 katmanli koruma + full bypass.
    Hicbir resetleme yontemi karakteri sifirlayamaz.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- // KORUMA KATMANI 1: Karakter koruma kilidi
local function lockCharacter(character)
    if not character then return end
    
    -- Humanoid korumasi
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        hum.AutoRotate = false
        
        -- Olum engelleme
        hum.Died:Connect(function()
            hum.BreakJointsOnDeath = false
            task.wait(0.01)
            -- Karakteri zorla geri yukle
            if character.Parent ~= workspace then
                character.Parent = workspace
            end
        end)
        
        -- Health sifirlanmasini engelle
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then
                hum.Health = hum.MaxHealth
            end
        end)
        
        -- WalkSpeed/ JumpPower resetleme engelle
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
        end)
        hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if hum.JumpPower < 50 then
                hum.JumpPower = 50
            end
        end)
    end
    
    -- RootPart korumasi
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
            rootPart.Anchored = false
        end)
        rootPart:GetPropertyChangedSignal("CanCollide"):Connect(function()
            rootPart.CanCollide = true
        end)
    end
    
    -- Tum parcalari koru
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part:GetPropertyChangedSignal("Anchored"):Connect(function()
                part.Anchored = false
            end)
            part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                part.CanCollide = true
            end)
            part:GetPropertyChangedSignal("Transparency"):Connect(function()
                if part.Transparency > 0.5 then
                    part.Transparency = 0
                end
            end)
            part:GetPropertyChangedSignal("Locked"):Connect(function()
                part.Locked = false
            end)
        end
    end
end

-- // KORUMA KATMANI 2: Karakter yukleme/zorla tutma
local function forceCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        -- Karakter yoksa yeniden yukle
        LocalPlayer.CharacterAdded:Wait()
        char = LocalPlayer.Character
    end
    return char
end

-- // KORUMA KATMANI 3: Reset sinyallerini engelleme (BYPASS)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- :Destroy() engelle
    if method == "Destroy" and self == LocalPlayer.Character then
        return nil
    end
    
    -- :Remove() engelle
    if method == "Remove" and self == LocalPlayer.Character then
        return nil
    end
    
    -- :ClearAllChildren() engelle
    if method == "ClearAllChildren" and self == LocalPlayer.Character then
        return nil
    end
    
    -- :BreakJoints() engelle
    if method == "BreakJoints" and self:IsDescendantOf(LocalPlayer.Character) then
        return nil
    end
    
    -- :LoadCharacter() engelle
    if method == "LoadCharacter" and self == LocalPlayer then
        return nil
    end
    
    -- Player:Kill() engelle
    if method == "Kill" and self == LocalPlayer then
        return nil
    end
    
    -- Humanoid:TakeDamage() engelle
    if method == "TakeDamage" and self:IsDescendantOf(LocalPlayer.Character) then
        return nil
    end
    
    -- Humanoid.Health = 0 engelle
    if method == "Health" and self:IsDescendantOf(LocalPlayer.Character) then
        local hum = self
        if hum:IsA("Humanoid") and tonumber(args[1]) and tonumber(args[1]) <= 0 then
            return nil
        end
    end
    
    return oldNamecall(self, ...)
end)

-- // KORUMA KATMANI 4: Remote olaylari engelleme
local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local remoteName = self.Name:lower()
        local remotePath = self:GetFullName():lower()
        
        -- Reset/kill/remove remote'lari engelle
        local blockedKeywords = {"reset", "kill", "remove", "destroy", "delete", "kick", "ban", "death", "die", "respawn", "clear"}
        for _, keyword in ipairs(blockedKeywords) do
            if string.find(remoteName, keyword) or string.find(remotePath, keyword) then
                return nil
            end
        end
        
        -- Karaktere zarar veren her turlu remote'u engelle
        if args[1] == LocalPlayer or args[1] == LocalPlayer.Character then
            return nil
        end
    end
    
    return oldFireServer(self, ...)
end)

-- // KORUMA KATMANI 5: __index / __newindex bypass
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == LocalPlayer and key == "Character" then
        local char = oldIndex(self, key)
        if not char then
            -- Karakter yoksa nil donme, bekle ve tekrar dene
            return forceCharacter()
        end
        return char
    end
    return oldIndex(self, key)
end)

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    -- Player.Character = nil engelle
    if self == LocalPlayer and key == "Character" and value == nil then
        return nil
    end
    
    -- Humanoid.Health = 0 engelle
    if key == "Health" and self:IsA("Humanoid") and self:IsDescendantOf(LocalPlayer.Character) then
        if value <= 0 then
            return nil
        end
    end
    
    -- Parent = nil engelle
    if key == "Parent" and value == nil and self:IsDescendantOf(LocalPlayer.Character) then
        return nil
    end
    
    return oldNewIndex(self, key, value)
end)

-- // KORUMA KATMANI 6: CharacterAdded / CharacterRemoving dinleme
LocalPlayer.CharacterAdded:Connect(function(character)
    lockCharacter(character)
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
    -- Karakter silinmesini engelle
    task.wait(0.01)
    if character.Parent ~= workspace then
        character.Parent = workspace
    end
    lockCharacter(character)
end)

-- // KORUMA KATMANI 7: Sürekli tarama ve onarma
spawn(function()
    while true do
        task.wait(0.1)
        
        local char = forceCharacter()
        if char then
            -- Parent kontrolu
            if char.Parent ~= workspace then
                char.Parent = workspace
            end
            
            -- Humanoid kontrolu
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.Health <= 0 then
                    hum.Health = hum.MaxHealth
                end
                if hum.BreakJointsOnDeath == true then
                    hum.BreakJointsOnDeath = false
                end
                -- Sit durumunu kontrol et
                if hum:GetState() == Enum.HumanoidStateType.Dead then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            else
                -- Humanoid yoksa zorla ekle
                local newHum = Instance.new("Humanoid")
                newHum.Parent = char
            end
            
            -- RootPart kontrolu
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                local newRoot = Instance.new("Part")
                newRoot.Name = "HumanoidRootPart"
                newRoot.Size = Vector3.new(2, 2, 2)
                newRoot.CanCollide = true
                newRoot.Anchored = false
                newRoot.Parent = char
            end
            
            -- Tum parcalari kontrol et
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Anchored then
                        part.Anchored = false
                    end
                    if not part.CanCollide then
                        part.CanCollide = true
                    end
                    if part.Transparency > 0.9 then
                        part.Transparency = 0
                    end
                    if part.Locked then
                        part.Locked = false
                    end
                end
            end
        end
    end
end)

-- // COK GUCLU BYPASS: Workspace korumasi
workspace.ChildRemoved:Connect(function(child)
    if child == LocalPlayer.Character then
        task.wait(0.01)
        child.Parent = workspace
    end
end)

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == LocalPlayer.Name then
        lockCharacter(child)
    end
end)

-- // BILDIRIM (Sessiz, sadece yuklendigini belirtir)
local function silentNotify()
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "ANTI RESET AKTIF",
            Text = "Karakteriniz 7 katmanli koruma altinda. Hicbir reset calismaz.",
            Duration = 4
        })
    end)
end

-- Ilk karakteri kilitle
if LocalPlayer.Character then
    lockCharacter(LocalPlayer.Character)
end

silentNotify()

-- Sonsuz dongu: Script asla durmasin
while true do
    task.wait(5)
    -- Periyodik olarak baglantilari kontrol et
    if not oldNamecall then
        oldNamecall = hookmetamethod(game, "__namecall", oldNamecall)
    end
end
