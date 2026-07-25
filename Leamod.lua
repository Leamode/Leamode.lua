-- =====================================================================
-- Steal a Brainrot - Advanced 1 of 1 & Trade Spoof Engine v2.4
-- Author: V. / Secure Operations Context
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- SETTINGS & CONFIGURATION
local CONFIG = {
    ENABLED_1OF1 = true,
    ENABLED_SPOOF = true,
    TARGET_PET = "Noobinini pizzanini",
    SPOOF_NAME = "sikibidi",
    GLOW_COLOR = Color3.fromRGB(255, 215, 0),
    SCAN_INTERVAL = 0.15,
    DEBUG_MODE = true
}

local function debugPrint(...)
    if CONFIG.DEBUG_MODE then
        print("[Brainrot Advanced Engine]:", ...)
    end
end

-- =====================================================================
-- MODULE 1: ADVANCED 1 OF 1 OVERLAY SYSTEM
-- =====================================================================
local ActiveOverlays = {}

local function createOverlay(petModel)
    if not petModel or not petModel:IsA("Model") then return end
    if ActiveOverlays[petModel] then return end

    -- Find optimal attachment part
    local targetPart = petModel.PrimaryPart 
        or petModel:FindFirstChild("HumanoidRootPart") 
        or petModel:FindFirstChild("Head") 
        or petModel:FindFirstChildWhichIsA("BasePart")

    if not targetPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Brainrot_1of1_Overlay"
    billboard.Size = UDim2.new(0, 140, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 600
    billboard.LightInfluence = 0
    billboard.Adornee = targetPart
    billboard.Parent = targetPart

    -- Main Text Label with Golden Gradient/Stroke
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "OverlayText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "★ 1 of 1 ★"
    textLabel.TextColor3 = CONFIG.GLOW_COLOR
    textLabel.TextSize = 22
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextStrokeTransparency = 0.15
    textLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    textLabel.TextWrapped = true
    textLabel.Parent = billboard

    -- Pulsing / Shimmer Effect via RunService connection inside attributes
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not billboard or not billboard.Parent then
            if connection then connection:Disconnect() end
            return
        end
        local alpha = math.sin((tick() - startTime) * 5) * 0.2 + 0.8
        textLabel.TextTransparency = 1 - alpha
    end)

    ActiveOverlays[petModel] = {
        Gui = billboard,
        Connection = connection
    }
    
    debugPrint("Overlay attached to pet model:", petModel.Name)
end

local function removeOverlay(petModel)
    if ActiveOverlays[petModel] then
        if ActiveOverlays[petModel].Connection then
            ActiveOverlays[petModel].Connection:Disconnect()
        end
        pcall(function() ActiveOverlays[petModel].Gui:Destroy() end)
        ActiveOverlays[petModel] = nil
    end
end

local function identifyPets()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant ~= LP.Character then
            local nameLower = descendant.Name:lower()
            local parentName = descendant.Parent and descendant.Parent.Name:lower() or ""
            
            local isTargetPet = nameLower:find("pet") 
                or nameLower:find("noob") 
                or nameLower:find("pizzanini")
                or parentName:find("pet") 
                or parentName:find("inventory") 
                or parentName:find("active")

            if isTargetPet then
                if not ActiveOverlays[descendant] then
                    createOverlay(descendant)
                end
            end
        end
    end

    -- Garbage collect missing or deleted pets
    for petModel, data in pairs(ActiveOverlays) do
        if not petModel or not petModel.Parent then
            removeOverlay(petModel)
        end
    end
end

-- =====================================================================
-- MODULE 2: DEEP TRADE SPOOF & REMOTE INTERCEPTION
-- =====================================================================
local SpoofedTextObjects = {}
local OriginalTextValues = {}

-- Attempting to hook network remotes if environment supports it (FireServer spoofing)
local originalFireServer
if syn and syn.hookmetamethod then
    pcall(function()
        originalFireServer = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" or method == "InvokeServer" then
                -- Intercept trade data structures containing pet names
                for i, v in ipairs(args) do
                    if type(v) == "table" then
                        for k, val in pairs(v) do
                            if type(val) == "string" and val:lower() == CONFIG.TARGET_PET:lower() then
                                v[k] = CONFIG.SPOOF_NAME
                                debugPrint("Intercepted & spoofed network payload property:", k)
                            end
                        end
                    elseif type(v) == "string" and v:lower() == CONFIG.TARGET_PET:lower() then
                        args[i] = CONFIG.SPOOF_NAME
                        debugPrint("Intercepted & spoofed network argument string")
                    end
                end
            end
            return originalFireServer(self, unpack(args))
        end)
        debugPrint("Network Remote hook initialized successfully.")
    end)
end

local function scanAndSpoofTradeUI()
    local playerGui = LP:FindFirstChild("PlayerGui")
    if not playerGui then return end

    -- Find trade interfaces dynamically
    local tradeGuiFound = nil
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local gName = gui.Name:lower()
            if gName:find("trade") or gName:find("exchange") or gName:find("deal") then
                tradeGuiFound = gui
                break
            end
        end
    end

    if not tradeGuiFound then
        -- Clean up spoof cache if trade window closes
        if next(SpoofedTextObjects) ~= nil then
            for obj, origText in pairs(OriginalTextValues) do
                if obj and obj.Parent then
                    pcall(function() obj.Text = origText end)
                end
            end
            table.clear(SpoofedTextObjects)
            table.clear(OriginalTextValues)
        end
        return
    end

    -- Deep traversal of trade GUI descendants to catch all label instances
    for _, element in ipairs(tradeGuiFound:GetDescendants()) do
        if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
            local success, textVal = pcall(function() return element.Text end)
            if success and type(textVal) == "string" and textVal ~= "" then
                if textVal:lower():find(CONFIG.TARGET_PET:lower()) then
                    if not OriginalTextValues[element] then
                        OriginalTextValues[element] = textVal
                    end
                    pcall(function()
                        element.Text = textVal:gsub(CONFIG.TARGET_PET, CONFIG.SPOOF_NAME)
                    end)
                    SpoofedTextObjects[element] = true
                    debugPrint("Spoofed Trade UI text element:", textVal, "->", CONFIG.SPOOF_NAME)
                end
            end
        end
    end
end

-- =====================================================================
-- MAIN EXECUTION THREADS
-- =====================================================================

task.spawn(function()
    if not LP.Character then LP.CharacterAdded:Wait() end
    task.wait(1.5)
    
    debugPrint("Core loops starting...")
    while true do
        if CONFIG.ENABLED_1OF1 then
            pcall(identifyPets)
        end
        if CONFIG.ENABLED_SPOOF then
            pcall(scanAndSpoofTradeUI)
        end
        task.wait(CONFIG.SCAN_INTERVAL)
    end
end)

-- Workspace Event Listeners
workspace.DescendantAdded:Connect(function(child)
    if CONFIG.ENABLED_1OF1 and child:IsA("Model") then
        task.wait(0.2)
        pcall(function()
            if child.Name:lower():find("pet") or child.Name:lower():find("noob") then
                createOverlay(child)
            end
        end)
    end
end)

workspace.DescendantRemoving:Connect(function(child)
    if child:IsA("Model") and ActiveOverlays[child] then
        removeOverlay(child)
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(2)
    pcall(identifyPets)
end)

debugPrint("Steal a Brainrot Advanced Script Loaded Successfully.")
