-- ==============================================================================
-- LEA MOD V20.0 - PART 1 (ANA İSKELET & MOTORLAR)
-- ==============================================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    getgenv().LeaStateV20 = getgenv().LeaStateV20 or {
        Active = true,
        Cube = false,
        Fly = false,
        Follow = false,
        Medusa = false,
        AntiKick = true,
        AntiReset = true,
        Connections = {},
        Cache = { Cubes = {} }
    }

    local S = getgenv().LeaStateV20

    for _, c in pairs(S.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    S.Connections = {}

    -- CUBE SİSTEMİ MOTORU
    local EngineState = { LastCubeTick = 0 }
    table.insert(S.Connections, RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if S.Cube then
            local velocityY = hrp.AssemblyLinearVelocity.Y
            if velocityY < 2 and (os.clock() - EngineState.LastCubeTick > 0.12) then
                if #S.Cache.Cubes >= 5 then
                    local oldCube = table.remove(S.Cache.Cubes, 1)
                    if oldCube and oldCube.Parent then oldCube:Destroy() end
                end

                local newCube = Instance.new("Part")
                newCube.Name = "ValidGroundPlatform"
                newCube.Size = Vector3.new(4.2, 0.4, 4.2)
                newCube.Position = hrp.Position - Vector3.new(0, 3.3, 0)
                newCube.Anchored = true
                newCube.CanCollide = true
                newCube.Transparency = 0.35
                newCube.Material = Enum.Material.Neon
                newCube.Color = Color3.fromRGB(0, 255, 200)
                newCube.Parent = Workspace

                table.insert(S.Cache.Cubes, newCube)
                EngineState.LastCubeTick = os.clock()
            end
        else
            for _, c in ipairs(S.Cache.Cubes) do
                if c and c.Parent then c:Destroy() end
            end
            S.Cache.Cubes = {}
        end
    end))

    -- FLY SÜZÜLME MOTORU
    local FlyPhysics = { Speed = 28, BV = nil, BG = nil }
    table.insert(S.Connections, RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if S.Fly then
            hum.PlatformStand = true
            
            if not FlyPhysics.BV or not FlyPhysics.BV.Parent then
                FlyPhysics.BV = Instance.new("BodyVelocity")
                FlyPhysics.BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                FlyPhysics.BV.Velocity = Vector3.zero
                FlyPhysics.BV.Parent = hrp
            end

            if not FlyPhysics.BG or not FlyPhysics.BG.Parent then
                FlyPhysics.BG = Instance.new("BodyGyro")
                FlyPhysics.BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                FlyPhysics.BG.CFrame = hrp.CFrame
                FlyPhysics.BG.Parent = hrp
            end

            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if FlyPhysics.BV and FlyPhysics.BG then
                FlyPhysics.BV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * FlyPhysics.Speed) or Vector3.new(0, 0.05, 0)
                FlyPhysics.BG.CFrame = cam.CFrame
            end
        else
            hum.PlatformStand = false
            if FlyPhysics.BV then FlyPhysics.BV:Destroy() FlyPhysics.BV = nil end
            if FlyPhysics.BG then FlyPhysics.BG:Destroy() FlyPhysics.BG = nil end
        end
    end))

    print("✅ Part 1 Ana İskelet Yüklendi!")
end)
-- ==============================================================================
-- LEA MOD V20.0 - PART 2 (UI ARAYÜZ & ÖZEL BYPASS BIRAKMA ALANI)
-- ==============================================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local S = getgenv().LeaStateV20
    if not S then
        warn("❌ Önce Part 1 Kodunu Çalıştırmalısın!")
        return
    end

    pcall(function() if CoreGui:FindFirstChild("LEAMOD_V20_UI") then CoreGui.LEAMOD_V20_UI:Destroy() end end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "LEAMOD_V20_UI"
    Gui.ResetOnSpawn = false
    Gui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 160, 0, 195)
    Main.Position = UDim2.new(0.5, -80, 0.5, -97)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 5)

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 18, 0, 18)
    Close.Position = UDim2.new(0, 4, 0, 4)
    Close.BackgroundTransparency = 0.3
    Close.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 60, 60)
    Close.TextSize = 10
    Close.Font = Enum.Font.SourceSansBold
    Close.Parent = Main
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 3)

    local Open = Instance.new("TextButton")
    Open.Size = UDim2.new(0, 45, 0, 22)
    Open.Position = UDim2.new(1, -50, 0, 4)
    Open.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Open.Text = "LEA"
    Open.TextColor3 = Color3.fromRGB(0, 255, 200)
    Open.TextSize = 11
    Open.Font = Enum.Font.SourceSansBold
    Open.Visible = false
    Open.Parent = Gui
    Instance.new("UICorner", Open).CornerRadius = UDim.new(0, 3)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA V20 CUSTOM"
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.TextSize = 10
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -8, 1, -28)
    Scroll.Position = UDim2.new(0, 4, 0, 26)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Padding = UDim.new(0, 3)
    Layout.Parent = Scroll

    local function AddBtn(name, stateKey, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        b.BorderSizePixel = 0
        b.Text = name .. (S[stateKey] and ": AÇIK" or ": KAPALI")
        b.TextColor3 = S[stateKey] and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
        b.TextSize = 10
        b.Font = Enum.Font.SourceSansBold
        b.Parent = Scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)

        b.MouseButton1Click:Connect(function()
            S[stateKey] = not S[stateKey]
            b.Text = name .. (S[stateKey] and ": AÇIK" or ": KAPALI")
            b.TextColor3 = S[stateKey] and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 80, 80)
            if callback then callback(S[stateKey]) end
        end)
    end

    AddBtn("Anti-Kick", "AntiKick", function(v) S.AntiKick = v end)
    AddBtn("Anti-Reset", "AntiReset", function(v) S.AntiReset = v end)
    AddBtn("Cube Sistemi", "Cube", function(v) S.Cube = v end)
    AddBtn("Fly Süzülme", "Fly", function(v) S.Fly = v end)

    Close.MouseButton1Click:Connect(function() Main.Visible = false; Open.Visible = true end)
    Open.MouseButton1Click:Connect(function() Main.Visible = true; Open.Visible = false end)

    -- ==========================================================================
    -- ⬇️ KENDİ ÖZEL BYPASS KODUNU BURAYA KOPYALA-YAPIŞTIR YAPABİLİRSİN ⬇️
    -- ==========================================================================
    -- Ultimate Bypass v4.0 - Pure Bypass System
-- 50+ Lines of Advanced Anti-Cheat Evasion

local ultimate_bypass = {
    active = true,
    stealth_mode = true,
    memory_patch = true,
    realtime_evasion = true
}

-- Core bypass function - tricks all detection systems
local function core_bypass()
    -- Spoof player state to confuse anti-cheat
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if hrp and humanoid then
            -- Manipulate movement values
            hrp.Velocity = Vector3.new(0, -0.01, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.Health = 100
        end
    end
end

-- Memory manipulation to hide from scanners
local function memory_manipulation()
    local services = {
        game:GetService("Players"),
        game:GetService("RunService"),
        game:GetService("Workspace")
    }
    
    for _, service in pairs(services) do
        for _, child in pairs(service:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                if child.Name:match("Anti") or child.Name:match("Cheat") or child.Name:match("Detect") then
                    child.Disabled = true
                end
            end
        end
    end
end

-- Real-time security loophole scanner
local function loophole_scanner()
    local target_services = {
        "AntiCheat",
        "Security",
        "Protection",
        "Detection",
        "Monitor"
    }
    
    for _, name in pairs(target_services) do
        local service = game:FindFirstChild(name)
        if service then
            for _, item in pairs(service:GetChildren()) do
                if item:IsA("BoolValue") or item:IsA("NumberValue") then
                    item.Value = false
                end
                if item:IsA("Script") then
                    item.Disabled = true
                end
            end
        end
    end
end

-- Bypass remote event detection
local function remote_event_bypass()
    local remote_events = game:GetService("ReplicatedStorage"):GetChildren()
    for _, event in pairs(remote_events) do
        if event:IsA("RemoteEvent") or event:IsA("RemoteFunction") then
            if event.Name:match("Check") or event.Name:match("Verify") then
                event.OnServerEvent:Connect(function()
                    return true
                end)
            end
        end
    end
end

-- Hide script from detection
local function hide_script()
    local script_env = getfenv()
    script_env.script = nil
    script_env.ultimate_bypass = ultimate_bypass
    setfenv(0, script_env)
end

-- Bypass character validation
local function character_bypass()
    local player = game.Players.LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
        end
    end
end

-- Patch global anti-cheat checks
local function patch_global_checks()
    local ac_check = game:GetService("Players").LocalPlayer:FindFirstChild("AntiCheatCheck")
    if ac_check then
        ac_check:Destroy()
    end
    
    local security = game:FindFirstChild("SecurityCheck")
    if security then
        security:Destroy()
    end
end

-- Override detection functions
local function override_detection()
    local player = game.Players.LocalPlayer
    local detect_func = player:FindFirstChild("Detection")
    if detect_func then
        detect_func:Destroy()
    end
end

-- Clean memory to remove traces
local function clean_memory()
    local garbage = game:GetService("Players").LocalPlayer:FindFirstChild("TempData")
    if garbage then
        garbage:Destroy()
    end
end

-- Persistent bypass loop
local function persistent_bypass()
    game:GetService("RunService").Stepped:Connect(function()
        if ultimate_bypass.active then
            core_bypass()
            loophole_scanner()
            character_bypass()
            patch_global_checks()
            override_detection()
            clean_memory()
            memory_manipulation()
            remote_event_bypass()
            hide_script()
            
            -- Additional stealth measures
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(0, -0.01, 0)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

-- Initialize ultimate bypass
ultimate_bypass.active = true
core_bypass()
memory_manipulation()
loophole_scanner()
remote_event_bypass()
hide_script()
character_bypass()
patch_global_checks()
override_detection()
clean_memory()
persistent_bypass()

-- Final protection layer
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    wait(0.1)
    core_bypass()
    character_bypass()
    loophole_scanner()
end)

-- Keep bypass active permanently
while ultimate_bypass.active do
    wait(1)
    core_bypass()
    loophole_scanner()
    memory_manipulation()
    hide_script()
    clean_memory()
    override_detection()
        end
    
    
    -- ==========================================================================

    print("✅ Part 2 UI ve Bypass Alanı Hazır!")
end)
