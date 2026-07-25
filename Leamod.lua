-- // BRAINROT NEW - KORUMA SİSTEMİ ÇIKARICI v4.0
-- // PARÇA 1/3: Veri Toplama Motoru
-- // Amaç: Tüm script kaynaklarını, remote'ları, koruma verilerini topla
-- // ============================================================

local S = {
    Players = game:GetService("Players"),
    RepStorage = game:GetService("ReplicatedStorage"),
    RepFirst = game:GetService("ReplicatedFirst"),
    ServerScript = game:GetService("ServerScriptService"),
    ServerStorage = game:GetService("ServerStorage"),
    StarterGui = game:GetService("StarterGui"),
    StarterPlayer = game:GetService("StarterPlayer"),
    Http = game:GetService("HttpService"),
    LP = game:GetService("Players").LocalPlayer
}

-- Global veri havuzu (Parça 2 ve 3 buradan okur)
getgenv().BE = {
    Evt = {}, Fnc = {}, All = {}, Mod = {}, Loc = {}, Srv = {},
    Gui = {}, Prot = {}, Raw = {}, Log = {}, Cfg = {MaxDepth=20, ScanCore=true}
}
local D = getgenv().BE

-- Log
local function L(l,m) local e=string.format("[%s][%s]%s",os.date("%H:%M:%S"),l,m);table.insert(D.Log,e);print(e) end

-- Güvenli kaynak kodu alma
local function GS(o)
    local r,s = pcall(function() if o:IsA("BaseScript") then return o.Source end return nil end)
    if r and s and s~="" then return s end
    return nil
end

-- REMOTE TOPLAMA
L("INFO","Remote Event/Function toplanıyor...")
local cnt = {S.RepStorage,S.RepFirst,workspace,S.LP:FindFirstChild("PlayerGui"),S.LP:FindFirstChild("PlayerScripts")}
for _,c in ipairs(cnt) do pcall(function()
    if not c then return end
    for _,o in ipairs(c:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            table.insert(D.Evt,{N=o.Name,P=o:GetFullName(),S=o.Name:lower():find("sammy") or o:GetFullName():lower():find("sammy")})
        elseif o:IsA("RemoteFunction") then
            table.insert(D.Fnc,{N=o.Name,P=o:GetFullName(),S=o.Name:lower():find("sammy") or o:GetFullName():lower():find("sammy")})
        end
    end
end) end
L("OK",string.format("Remote: %d Event + %d Function",#D.Evt,#D.Fnc))

-- SCRIPT TOPLAMA
L("INFO","Scriptler taranıyor...")
local kw = {"admin","owner","sammy","spyder","panel","control","permission","rank","role","command","ban","kick","message","broadcast","announce","protection","bypass","check","verify","mod","staff"}
local containers = {
    {N="RepStorage",O=S.RepStorage},{N="RepFirst",O=S.RepFirst},{N="ServerScript",O=S.ServerScript},
    {N="ServerStorage",O=S.ServerStorage},{N="StarterGui",O=S.StarterGui},{N="StarterPlayer",O=S.StarterPlayer},
    {N="PlayerScripts",O=S.LP:FindFirstChild("PlayerScripts")},{N="PlayerGui",O=S.LP:FindFirstChild("PlayerGui")},
    {N="Workspace",O=workspace}
}

for _,c in ipairs(containers) do pcall(function()
    if not c.O then return end
    for _,o in ipairs(c.O:GetDescendants()) do
        local t = nil
        if o:IsA("Script") then t="Server" elseif o:IsA("LocalScript") then t="Local" elseif o:IsA("ModuleScript") then t="Module" end
        if not t then continue end
        local nl,pl = o.Name:lower(),o:GetFullName():lower()
        local ia, mk = false, {}
        for _,k in ipairs(kw) do if nl:find(k) or pl:find(k) then ia=true;table.insert(mk,k) end end
        local src = GS(o)
        local si = {N=o.Name,P=o:GetFullName(),T=t,C=c.N,A=ia,K=mk,Kc=#mk,Src=src,Len=src and #src or 0,Ok=src~=nil}
        table.insert(D.All,si)
        if t=="Server" then table.insert(D.Srv,si) elseif t=="Local" then table.insert(D.Loc,si) elseif t=="Module" then table.insert(D.Mod,si) end
        if src then table.insert(D.Raw,si) end
    end
end) end
L("OK",string.format("Script: %d toplam | %d kaynak alindi | %d admin ilgili",#D.All,#D.Raw,(function()local c=0;for _,s in ipairs(D.All)do if s.A then c=c+1 end end;return c end)()))

-- KORUMA ANALİZİ
L("INFO","Koruma sistemleri analiz ediliyor...")
local ptrn = {
    {N="UserId Kontrol",P={"UserId","userid"},"CRITICAL"},
    {N="Grup Rank Kontrol",P={"GetRankInGroup","GetRoleInGroup"},"HIGH"},
    {N="PlayerGui Konum",P={"PlayerGui","playergui"},"HIGH"},
    {N="Isim Kontrol",P={"Spyder","spyder","Sammy","sammy"},"CRITICAL"},
    {N="Remote Yetki",P={"FireServer","InvokeServer"},"HIGH"},
    {N="Anti-Tamper",P={"Destroy","Remove"},"MEDIUM"},
    {N="Require Yetki",P={"require","Require"},"MEDIUM"},
    {N="Admin Panel GUI",P={"admin","panel","Admin"},"HIGH"},
    {N="Mesaj Sistemi",P={"message","broadcast","announce"},"HIGH"},
    {N="CoreGui Erisim",P={"CoreGui","coregui"},"MEDIUM"}
}
for _,sc in ipairs(D.Raw) do
    if not sc.Src then goto nxt end
    local dt = {}
    for _,pt in ipairs(ptrn) do
        local fd,ln = false,{}
        for _,p in ipairs(pt.P) do if sc.Src:find(p) then fd=true;for l in sc.Src:gmatch("[^\r\n]+") do if l:find(p) then local t2=l:gsub("^%s+",""):gsub("%s+$","");if #t2>0 and #t2<200 then table.insert(ln,t2) end end end;break end end
        if fd then table.insert(dt,{Pt=pt,Ln=ln,Lc=#ln}) end
    end
    if #dt>0 then local rl="MEDIUM";for _,d in ipairs(dt) do if d.Pt[3]=="CRITICAL" then rl="CRITICAL";break elseif d.Pt[3]=="HIGH" then rl="HIGH" end end;table.insert(D.Prot,{Sc=sc,Dc=#dt,Dt=dt,Rl=rl}) end
    ::nxt::
end
L("OK",string.format("Koruma: %d sistem tespit edildi",#D.Prot))

-- GUI YAPISI
L("INFO","GUI yapisi toplaniyor...")
local function scn(p,d) if d>20 or not p then return end;for _,c in ipairs(p:GetChildren()) do if c:IsA("GuiObject") then table.insert(D.Gui,{N=c.Name,Cl=c.ClassName,V=c.Visible,A=c.Active,P=tostring(c.Position),S=tostring(c.Size),Ad=c.Name:lower():find("admin") or c.Name:lower():find("panel") or c.Name:lower():find("sammy")});scn(c,d+1) end end end
pcall(function() scn(S.LP:FindFirstChild("PlayerGui"),0) end)
pcall(function() scn(game.CoreGui,0) end)
L("OK",string.format("GUI: %d nesne bulundu",#D.Gui))

-- ANALİZ ÖZETİ
D.Anl = {
    TS=#D.All, RS=#D.Raw, TE=#D.Evt, TF=#D.Fnc, PS=#D.Prot, GO=#D.Gui,
    AS=(function()local c=0;for _,s in ipairs(D.All)do if s.A then c=c+1 end end;return c end)(),
    SR={}, TP={}
}
for _,e in ipairs(D.Evt) do if e.S then table.insert(D.Anl.SR,e) end end
for _,f in ipairs(D.Fnc) do if f.S then table.insert(D.Anl.SR,f) end end
local sp={};for _,p in ipairs(D.Prot) do table.insert(sp,p) end
table.sort(sp,function(a,b)local ro={CRITICAL=3,HIGH=2,MEDIUM=1};return(ro[a.Rl]or 0)>(ro[b.Rl]or 0)end)
for i=1,math.min(10,#sp) do table.insert(D.Anl.TP,{N=sp[i].Sc.N,P=sp[i].Sc.P,R=sp[i].Rl,Dc=sp[i].Dc}) end

getgenv().BE.Ready = true
L("DONE","========================================")
L("DONE",string.format("TARAMA BITTI: Script:%d Remote:%d Koruma:%d GUI:%d",#D.All,#D.Evt+#D.Fnc,#D.Prot,#D.Gui))
L("DONE","Parça 2'yi calistirarak GUI'yi acabilirsiniz")
L("DONE","========================================")

print([[
=== PARÇA 1/3 TAMAMLANDI ===
Veriler toplandi: getgenv().BE
Simdi Parca 2'yi calistir
=============================
]])-- // BRAINROT NEW - KORUMA SİSTEMİ ÇIKARICI v4.0
-- // PARÇA 2/3: GUI Arayüzü
-- // Amaç: Kopyalanabilir kod bloklarıyla arayüz oluşturur
-- // Gereksinim: Parça 1 çalışmış olmalı (getgenv().BE.Ready == true)
-- // ============================================================

if not getgenv().BE or not getgenv().BE.Ready then error("Parça 1 calistirilmamis! Once Parca 1'i calistir.") end

local BE = getgenv().BE
local S = {
    Players = game:GetService("Players"),
    Http = game:GetService("HttpService"),
    Tween = game:GetService("TweenService"),
    LP = game:GetService("Players").LocalPlayer
}

-- GUI Ana Yapı
local SG = Instance.new("ScreenGui");SG.Name="BE_GUI";SG.Parent=game.CoreGui;SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;SG.ResetOnSpawn=false

local MF = Instance.new("Frame");MF.Name="Main";MF.Parent=SG;MF.BackgroundColor3=Color3.fromRGB(8,8,8);MF.BorderColor3=Color3.fromRGB(0,255,0);MF.BorderSizePixel=2;MF.Position=UDim2.new(0.08,0,0.04,0);MF.Size=UDim2.new(0,820,0,510);MF.Active=true;MF.Draggable=true

-- Gradient
local GD = Instance.new("UIGradient");GD.Parent=MF;GD.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,20,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,5,5))});GD.Rotation=45

-- Başlık
local TB = Instance.new("TextLabel");TB.Name="Title";TB.Parent=MF;TB.BackgroundColor3=Color3.fromRGB(0,70,0);TB.BorderSizePixel=0;TB.Size=UDim2.new(1,0,0,36);TB.Font=Enum.Font.SciFi;TB.Text="BRAINROT NEW - KORUMA KOD CIKARICI";TB.TextColor3=Color3.fromRGB(0,255,0);TB.TextSize=15

-- Durum
local SB = Instance.new("TextLabel");SB.Name="Status";SB.Parent=MF;SB.BackgroundColor3=Color3.fromRGB(15,15,15);SB.BorderColor3=Color3.fromRGB(0,100,0);SB.Position=UDim2.new(0,0,0.07,0);SB.Size=UDim2.new(1,0,0,22);SB.Font=Enum.Font.SourceSansBold;SB.Text=string.format("Script:%d Remote:%d Koruma:%d",#BE.All,#BE.Evt+#BE.Fnc,#BE.Prot);SB.TextColor3=Color3.fromRGB(0,255,0);SB.TextSize=11;SB.TextXAlignment=Enum.TextXAlignment.Left

-- Sekmeler
local TC = Instance.new("Frame");TC.Name="Tabs";TC.Parent=MF;TC.BackgroundColor3=Color3.fromRGB(10,10,10);TC.BorderSizePixel=0;TC.Position=UDim2.new(0,0,0.113,0);TC.Size=UDim2.new(1,0,0,32)

local tabs = {
    {N="KORUMA",I="S",C=Color3.fromRGB(255,80,0)},
    {N="SCRIPTS",I="P",C=Color3.fromRGB(0,200,0)},
    {N="ADMIN",I="A",C=Color3.fromRGB(255,0,0)},
    {N="REMOTE",I="R",C=Color3.fromRGB(0,150,255)},
    {N="GUI",I="G",C=Color3.fromRGB(200,200,0)},
    {N="OZET",I="O",C=Color3.fromRGB(200,0,200)}
}
local sel = "KORUMA"
local tbs = {}
for i,t in ipairs(tabs) do
    local b = Instance.new("TextButton");b.Name="Tab_"+t.N;b.Parent=TC;b.BackgroundColor3=(t.N==sel)and Color3.fromRGB(20,60,20)or Color3.fromRGB(20,20,20);b.BorderSizePixel=1;b.BorderColor3=t.C;b.Position=UDim2.new((i-1)*(1/#tabs),2,0,0);b.Size=UDim2.new(1/#tabs,-4,1,0);b.Font=Enum.Font.SourceSansBold;b.Text="["+t.I+"] "+t.N;b.TextColor3=t.C;b.TextSize=10;b.AutoButtonColor=false
    b.MouseButton1Click:Connect(function()sel=t.N;for _,x in ipairs(tbs)do x.BackgroundColor3=Color3.fromRGB(20,20,20)end;b.BackgroundColor3=Color3.fromRGB(20,60,20);Upd()end)
    tbs[#tbs+1]=b
end

-- İçerik
local CS = Instance.new("ScrollingFrame");CS.Name="Content";CS.Parent=MF;CS.BackgroundColor3=Color3.fromRGB(5,5,5);CS.BorderColor3=Color3.fromRGB(0,70,0);CS.BorderSizePixel=1;CS.Position=UDim2.new(0.01,0,0.18,0);CS.Size=UDim2.new(0.98,0,0,310);CS.CanvasSize=UDim2.new(0,0,0,0);CS.ScrollBarThickness=8;CS.ScrollBarImageColor3=Color3.fromRGB(0,170,0)
local CL = Instance.new("UIListLayout");CL.Name="Layout";CL.Parent=CS;CL.SortOrder=Enum.SortOrder.Name;CL.Padding=UDim.new(0,4)

-- Alt bar
local BB = Instance.new("Frame");BB.Name="Bottom";BB.Parent=MF;BB.BackgroundColor3=Color3.fromRGB(10,10,10);BB.BorderColor3=Color3.fromRGB(0,100,0);BB.BorderSizePixel=1;BB.Position=UDim2.new(0.01,0,0.81,0);BB.Size=UDim2.new(0.98,0,0,80)

local CA = Instance.new("TextButton");CA.Name="CopyAll";CA.Parent=BB;CA.BackgroundColor3=Color3.fromRGB(0,90,0);CA.BorderColor3=Color3.fromRGB(0,255,0);CA.BorderSizePixel=2;CA.Position=UDim2.new(0.05,0,0.3,0);CA.Size=UDim2.new(0.4,0,0,36);CA.Font=Enum.Font.SciFi;CA.Text="TUM KODLARI KOPYALA";CA.TextColor3=Color3.fromRGB(0,255,0);CA.TextSize=13

local RF = Instance.new("TextButton");RF.Name="Refresh";RF.Parent=BB;RF.BackgroundColor3=Color3.fromRGB(70,40,0);RF.BorderColor3=Color3.fromRGB(255,150,0);RF.BorderSizePixel=2;RF.Position=UDim2.new(0.5,0,0.3,0);RF.Size=UDim2.new(0.4,0,0,36);RF.Font=Enum.Font.SciFi;RF.Text="YENIDEN TARA";RF.TextColor3=Color3.fromRGB(255,200,0);RF.TextSize=13

-- Kod bloğu oluşturucu
local function CB(tl,cd,ac)
    local bl = Instance.new("Frame");bl.Name="Block";bl.BackgroundColor3=Color3.fromRGB(10,10,10);bl.BorderColor3=ac or Color3.fromRGB(0,150,0);bl.BorderSizePixel=1;bl.Size=UDim2.new(1,-16,0,160)
    local hd = Instance.new("Frame");hd.Name="Head";hd.Parent=bl;hd.BackgroundColor3=Color3.fromRGB(18,28,18);hd.BorderSizePixel=0;hd.Size=UDim2.new(1,0,0,26)
    local tl2 = Instance.new("TextLabel");tl2.Name="Title";tl2.Parent=hd;tl2.BackgroundTransparency=1;tl2.Size=UDim2.new(0.68,0,1,0);tl2.Font=Enum.Font.SourceSansBold;tl2.Text=" "+tl;tl2.TextColor3=ac;tl2.TextSize=11;tl2.TextXAlignment=Enum.TextXAlignment.Left
    local cb2 = Instance.new("TextButton");cb2.Name="Copy";cb2.Parent=hd;cb2.BackgroundColor3=ac;cb2.BorderSizePixel=0;cb2.Position=UDim2.new(0.72,0,0.08,0);cb2.Size=UDim2.new(0,105,0,22);cb2.Font=Enum.Font.SourceSansBold;cb2.Text="KOPYALA";cb2.TextColor3=Color3.fromRGB(0,0,0);cb2.TextSize=10;cb2.AutoButtonColor=false
    local bx = Instance.new("TextBox");bx.Name="Code";bx.Parent=bl;bx.BackgroundColor3=Color3.fromRGB(2,2,2);bx.BorderColor3=Color3.fromRGB(25,25,25);bx.BorderSizePixel=1;bx.Position=UDim2.new(0,0,0,26);bx.Size=UDim2.new(1,0,1,-26);bx.Font=Enum.Font.Code;bx.Text=cd;bx.TextColor3=Color3.fromRGB(170,255,170);bx.TextSize=11;bx.TextXAlignment=Enum.TextXAlignment.Left;bx.TextYAlignment=Enum.TextYAlignment.Top;bx.MultiLine=true;bx.ClearTextOnFocus=false;bx.TextEditable=false
    cb2.MouseButton1Click:Connect(function()pcall(function()setclipboard(cd);cb2.Text="KOPYALANDI!";cb2.BackgroundColor3=Color3.fromRGB(0,200,0);wait(1.5);cb2.Text="KOPYALA";cb2.BackgroundColor3=ac end)end)
    local lc=0;for _ in cd:gmatch("\n")do lc=lc+1 end;local h=math.max(140,(lc+2)*15+30);bl.Size=UDim2.new(1,-16,0,h)
    return bl
end

local function IL(tx,cl)
    local l=Instance.new("TextLabel");l.Name="Info";l.BackgroundTransparency=1;l.Size=UDim2.new(1,-20,0,18);l.Font=Enum.Font.SourceSansBold;l.Text=tx;l.TextColor3=cl or Color3.fromRGB(200,200,200);l.TextSize=11;l.TextXAlignment=Enum.TextXAlignment.Left
    return l
end

-- İçerik temizleme
local function CC()
    for _,c in ipairs(CS:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")then c:Destroy()end end
end

-- İçerik güncelleme fonksiyonu (Parça 3'te tanımlanacak)
function Upd() if getgenv().BE_Upd then getgenv().BE_Upd(sel,CS,IL,CB,BE) end end

-- Buton eventleri
CA.MouseButton1Click:Connect(function()
    local all="-- BRAINROT NEW - TUM KORUMA KODLARI\n-- Toplam Script: "..#BE.Raw.."\n\n"
    for i,s in ipairs(BE.Raw)do if s.Src then all=all.."--["..i.."] "..s.N.." ["..s.T.."]\n"..s.Src.."\n\n"..string.rep("=",40).."\n\n" end end
    pcall(function()setclipboard(all)end)
    CA.Text="KOPYALANDI!";wait(2);CA.Text="TUM KODLARI KOPYALA"
end)

RF.MouseButton1Click:Connect(function()
    RF.Text="TARANIYOR...";RF.BackgroundColor3=Color3.fromRGB(0,100,0)
    pcall(function()if getgenv().BE_Run then getgenv().BE_Run() end end)
    wait(1);RF.Text="YENIDEN TARA";RF.BackgroundColor3=Color3.fromRGB(70,40,0)
    SB.Text=string.format("Script:%d Remote:%d Koruma:%d",#BE.All,#BE.Evt+#BE.Fnc,#BE.Prot)
    Upd()
end)

-- Minimize
local MN = Instance.new("TextButton");MN.Name="Min";MN.Parent=MF;MN.BackgroundColor3=Color3.fromRGB(0,50,0);MN.BorderSizePixel=0;MN.Position=UDim2.new(0.94,0,0,0);MN.Size=UDim2.new(0,32,0,20);MN.Font=Enum.Font.SciFi;MN.Text="_";MN.TextColor3=Color3.fromRGB(0,255,0);MN.TextSize=14
local min=false
MN.MouseButton1Click:Connect(function()
    min=not min
    if min then MF.Size=UDim2.new(0,820,0,36);for _,c in ipairs(MF:GetChildren())do if c~=TB and c~=MN then c.Visible=false end end;MN.Text="+"
    else MF.Size=UDim2.new(0,820,0,510);for _,c in ipairs(MF:GetChildren())do c.Visible=true end;MN.Text="_" end
end)

print([[
=== PARÇA 2/3 TAMAMLANDI ===
GUI olusturuldu.
Simdi Parca 3'u calistir
(icerik guncelleme fonksiyonu)
=============================
]])-- // BRAINROT NEW - KORUMA SİSTEMİ ÇIKARICI v4.0
-- // PARÇA 3/3: İçerik Görüntüleyici
-- // Amaç: GUI sekmelerini kod bloklarıyla doldurur
-- // Gereksinim: Parça 1 ve 2 çalışmış olmalı
-- // ============================================================

if not getgenv().BE or not getgenv().BE.Ready then error("Parça 1 calistirilmamis!") end

local BE = getgenv().BE

-- İçerik güncelleme fonksiyonu (Parça 2'deki GUI'ye bağlanır)
function getgenv().BE_Upd(sel, CS, IL, CB)
    -- CS: ContentScroll, IL: CreateInfoLine fonksiyonu, CB: CreateCodeBlock fonksiyonu
    -- İçeriği temizle
    for _,c in ipairs(CS:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")then c:Destroy()end end
    CS.CanvasSize = UDim2.new(0,0,0,0)
    
    if sel == "KORUMA" then
        -- Koruma sistemleri sekmesi
        IL("KORUMA SISTEMI ANALIZI ("..#BE.Prot.." sistem)",Color3.fromRGB(255,100,0)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        if #BE.Prot == 0 then
            IL("Koruma sistemi tespit edilemedi (script kaynaklari alinamamis olabilir)",Color3.fromRGB(255,200,0)).Parent=CS
        else
            for _,ps in ipairs(BE.Prot) do
                local code = "-- Script: "..ps.Sc.P.."\n"
                code = code.."-- Risk Seviyesi: "..ps.Rl.."\n"
                code = code.."-- Tespit Sayisi: "..ps.Dc.."\n"
                code = code..string.rep("-",40).."\n\n"
                
                for _,d in ipairs(ps.Dt) do
                    code = code.."-- ["..d.Pt[3].."] "..d.Pt[1].."\n"
                    if d.Lc > 0 then
                        code = code.."-- Ilgili satirlar:\n"
                        for _,l in ipairs(d.Ln) do
                            code = code.."--   "..l.."\n"
                        end
                    end
                    code = code.."\n"
                end
                
                if ps.Sc.Src then
                    code = code.."\n-- TAM KAYNAK KODU:\n"..ps.Sc.Src
                end
                
                local ac = ps.Rl=="CRITICAL" and Color3.fromRGB(255,0,0) or (ps.Rl=="HIGH" and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,200,0))
                CB("["..ps.Rl.."] "..ps.Sc.N.." ("..ps.Dc.." koruma)",code,ac).Parent=CS
            end
        end
        
    elseif sel == "SCRIPTS" then
        -- Tüm scriptler sekmesi
        IL("TUM SCRIPT KAYNAK KODLARI ("..#BE.Raw.." script)",Color3.fromRGB(0,255,0)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        if #BE.Raw == 0 then
            IL("Kaynak kodu alinabilen script bulunamadi",Color3.fromRGB(255,200,0)).Parent=CS
        else
            for i,s in ipairs(BE.Raw) do
                if s.Src and s.Src ~= "" then
                    local hdr = "["..s.T.."] "..s.N
                    if s.A then hdr = "ADMIN "..hdr end
                    CB(hdr.." ("..s.Len.." karakter)",s.Src,s.A and Color3.fromRGB(255,100,0)or Color3.fromRGB(0,180,0)).Parent=CS
                end
            end
        end
        
    elseif sel == "ADMIN" then
        -- Admin scriptleri sekmesi
        local ac = 0;for _,s in ipairs(BE.All)do if s.A then ac=ac+1 end end
        IL("ADMIN ILGILI SCRIPTS ("..ac.." script)",Color3.fromRGB(255,0,0)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        local found = false
        for _,s in ipairs(BE.Raw) do
            if s.A and s.Src then
                found = true
                local kw = table.concat(s.K,", ")
                CB("["..s.T.."] "..s.N.." | Eslesen: "..kw,s.Src,Color3.fromRGB(255,50,0)).Parent=CS
            end
        end
        
        if not found then
            IL("Admin ilgili script bulunamadi veya kaynak kodlari alinamadi",Color3.fromRGB(255,200,0)).Parent=CS
        end
        
    elseif sel == "REMOTE" then
        -- Remote event/function sekmesi
        IL("REMOTE EVENT & FUNCTION LISTESI",Color3.fromRGB(0,150,255)).Parent=CS
        IL("Event: "..#BE.Evt.." | Function: "..#BE.Fnc.." | Sammy: "..#BE.Anl.SR,Color3.fromRGB(200,200,200)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        -- Sammy ilgili olanlar
        if #BE.Anl.SR > 0 then
            IL("SAMMY ILGILI REMOTE'LAR:",Color3.fromRGB(255,100,100)).Parent=CS
            local sc = "Sammy ile ilgili Remote'lar:\n\n"
            for _,r in ipairs(BE.Anl.SR) do
                sc = sc.."• "..r.N.."\n  Yol: "..r.P.."\n\n"
            end
            CB("Sammy Remote'lari ("..#BE.Anl.SR.." adet)",sc,Color3.fromRGB(255,0,0)).Parent=CS
        end
        
        -- Tüm eventler
        local ec = ""
        for _,e in ipairs(BE.Evt) do
            ec = ec.."[Event] "..e.N.."\n  Yol: "..e.P.."\n  Sammy: "..tostring(e.S).."\n\n"
        end
        if #BE.Evt > 0 then CB("RemoteEvent'ler ("..#BE.Evt..")",ec,Color3.fromRGB(0,100,200)).Parent=CS end
        
        -- Tüm function'lar
        local fc = ""
        for _,f in ipairs(BE.Fnc) do
            fc = fc.."[Function] "..f.N.."\n  Yol: "..f.P.."\n  Sammy: "..tostring(f.S).."\n\n"
        end
        if #BE.Fnc > 0 then CB("RemoteFunction'lar ("..#BE.Fnc..")",fc,Color3.fromRGB(150,0,200)).Parent=CS end
        
    elseif sel == "GUI" then
        -- GUI yapısı sekmesi
        local ac2 = 0;for _,g in ipairs(BE.Gui)do if g.Ad then ac2=ac2+1 end end
        IL("GUI YAPISI ("..#BE.Gui.." nesne | "..ac2.." admin)",Color3.fromRGB(200,200,0)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        -- Admin GUI
        if ac2 > 0 then
            local gc = "Admin GUI Elementleri:\n\n"
            for _,g in ipairs(BE.Gui)do
                if g.Ad then
                    gc = gc.."["..g.Cl.."] "..g.N.."\n"
                    gc = gc.."  Gorunur: "..tostring(g.V).." | Aktif: "..tostring(g.A).."\n"
                    gc = gc.."  Pos: "..g.P.." | Size: "..g.S.."\n\n"
                end
            end
            CB("Admin GUI ("..ac2.." element)",gc,Color3.fromRGB(255,150,0)).Parent=CS
        end
        
        -- Tüm GUI
        local ga = "Tum GUI Nesneleri:\n\n"
        for _,g in ipairs(BE.Gui)do
            ga = ga.."["..g.Cl.."] "..g.N..(g.Ad and " [ADMIN]" or "").."\n"
            ga = ga.."  Gorunur: "..tostring(g.V).." | Pos: "..g.P.."\n\n"
        end
        if #BE.Gui > 0 then CB("Tum GUI ("..#BE.Gui.." nesne)",ga,Color3.fromRGB(200,200,0)).Parent=CS end
        
    elseif sel == "OZET" then
        -- Analiz özeti sekmesi
        IL("ANALIZ OZETI",Color3.fromRGB(200,0,200)).Parent=CS
        IL(string.rep("-",60),Color3.fromRGB(100,100,100)).Parent=CS
        
        local oz = "BRAINROT NEW - KORUMA SISTEMI ANALIZ OZETI\n"
        oz = oz..string.rep("=",50).."\n\n"
        oz = oz.."GENEL ISTATISTIK:\n"
        oz = oz..string.rep("-",30).."\n"
        oz = oz.."Toplam Script: "..BE.Anl.TS.."\n"
        oz = oz.."Kaynak Alinan: "..BE.Anl.RS.."\n"
        oz = oz.."Bytecode: "..(BE.Anl.TS-BE.Anl.RS).."\n"
        oz = oz.."Admin Ilgili: "..BE.Anl.AS.."\n"
        oz = oz.."RemoteEvent: "..BE.Anl.TE.."\n"
        oz = oz.."RemoteFunction: "..BE.Anl.TF.."\n"
        oz = oz.."Koruma Sistemi: "..BE.Anl.PS.."\n"
        oz = oz.."GUI Nesnesi: "..BE.Anl.GO.."\n"
        oz = oz.."Sammy Remote: "..#BE.Anl.SR.."\n\n"
        
        oz = oz.."EN KRITIK KORUMA SCRIPTLERI:\n"
        oz = oz..string.rep("-",30).."\n"
        for i,tp in ipairs(BE.Anl.TP)do
            oz = oz..i..". ["..tp.R.."] "..tp.N.." ("..tp.Dc.." tespit)\n"
            oz = oz.."   Yol: "..tp.P.."\n\n"
        end
        
        oz = oz.."SAMMY REMOTE LISTESI:\n"
        oz = oz..string.rep("-",30).."\n"
        if #BE.Anl.SR > 0 then
            for _,sr in ipairs(BE.Anl.SR)do
                oz = oz.."• "..sr.N.."\n  "..sr.P.."\n\n"
            end
        else
            oz = oz.."Sammy ilgili remote bulunamadi\n\n"
        end
        
        oz = oz.."SCRIPT DETAYLARI:\n"
        oz = oz..string.rep("-",30).."\n"
        oz = oz.."ServerScript: "..#BE.Srv.."\n"
        oz = oz.."LocalScript: "..#BE.Loc.."\n"
        oz = oz.."ModuleScript: "..#BE.Mod.."\n"
        
        CB("ANALIZ OZETI",oz,Color3.fromRGB(200,0,200)).Parent=CS
        
        -- Script listesi
        local sl = "TUM SCRIPT LISTESI:\n\n"
        for i,s in ipairs(BE.All)do
            sl = sl..i..". ["..s.T.."] "..s.N..(s.A and " [ADMIN]" or "").."\n"
            sl = sl.."   Yol: "..s.P.."\n"
            sl = sl.."   Kaynak: "..(s.Ok and "VAR ("..s.Len.." karakter)" or "YOK").."\n\n"
        end
        CB("Script Listesi ("..#BE.All.." script)",sl,Color3.fromRGB(150,0,200)).Parent=CS
    end
    
    CS.CanvasSize = UDim2.new(0,0,0,CS:FindFirstChild("Layout") and CS.Layout.AbsoluteContentSize.Y+10 or 500)
end

-- İlk içerik yüklemesini yap
if getgenv().BE_Upd_Trigger then getgenv().BE_Upd_Trigger() end

-- Parça 2'deki Upd() fonksiyonu için trigger
getgenv().BE_Upd_Trigger = function()
    local gui = game.CoreGui:FindFirstChild("BE_GUI")
    if gui then
        local cs = gui.Main:FindFirstChild("Content")
        if cs then
            -- IL ve CB fonksiyonlarını yeniden tanımla (scope dışı olduğu için)
            local function IL2(tx,cl)
                local l=Instance.new("TextLabel");l.Name="Info";l.BackgroundTransparency=1;l.Size=UDim2.new(1,-20,0,18);l.Font=Enum.Font.SourceSansBold;l.Text=tx;l.TextColor3=cl or Color3.fromRGB(200,200,200);l.TextSize=11;l.TextXAlignment=Enum.TextXAlignment.Left
                return l
            end
            local function CB2(tl,cd,ac)
                local bl=Instance.new("Frame");bl.BackgroundColor3=Color3.fromRGB(10,10,10);bl.BorderColor3=ac or Color3.fromRGB(0,150,0);bl.BorderSizePixel=1;bl.Size=UDim2.new(1,-16,0,160)
                local hd=Instance.new("Frame");hd.Parent=bl;hd.BackgroundColor3=Color3.fromRGB(18,28,18);hd.BorderSizePixel=0;hd.Size=UDim2.new(1,0,0,26)
                local tl2=Instance.new("TextLabel");tl2.Parent=hd;tl2.BackgroundTransparency=1;tl2.Size=UDim2.new(0.68,0,1,0);tl2.Font=Enum.Font.SourceSansBold;tl2.Text=" "+tl;tl2.TextColor3=ac;tl2.TextSize=11;tl2.TextXAlignment=Enum.TextXAlignment.Left
                local cb2=Instance.new("TextButton");cb2.Parent=hd;cb2.BackgroundColor3=ac;cb2.BorderSizePixel=0;cb2.Position=UDim2.new(0.72,0,0.08,0);cb2.Size=UDim2.new(0,105,0,22);cb2.Font=Enum.Font.SourceSansBold;cb2.Text="KOPYALA";cb2.TextColor3=Color3.fromRGB(0,0,0);cb2.TextSize=10;cb2.AutoButtonColor=false
                local bx=Instance.new("TextBox");bx.Parent=bl;bx.BackgroundColor3=Color3.fromRGB(2,2,2);bx.BorderColor3=Color3.fromRGB(25,25,25);bx.BorderSizePixel=1;bx.Position=UDim2.new(0,0,0,26);bx.Size=UDim2.new(1,0,1,-26);bx.Font=Enum.Font.Code;bx.Text=cd;bx.TextColor3=Color3.fromRGB(170,255,170);bx.TextSize=11;bx.TextXAlignment=Enum.TextXAlignment.Left;bx.TextYAlignment=Enum.TextYAlignment.Top;bx.MultiLine=true;bx.ClearTextOnFocus=false;bx.TextEditable=false
                cb2.MouseButton1Click:Connect(function()pcall(function()setclipboard(cd);cb2.Text="KOPYALANDI!";cb2.BackgroundColor3=Color3.fromRGB(0,200,0);wait(1.5);cb2.Text="KOPYALA";cb2.BackgroundColor3=ac end)end)
                local lc=0;for _ in cd:gmatch("\n")do lc=lc+1 end;local h=math.max(140,(lc+2)*15+30);bl.Size=UDim2.new(1,-16,0,h)
                return bl
            end
            getgenv().BE_Upd("KORUMA",cs,IL2,CB2)
        end
    end
end

print([[
=== PARÇA 3/3 TAMAMLANDI ===
Tum icerik goruntuleyici hazir.
GUI uzerindeki sekmelerden:
- KORUMA: Koruma sistemi kodlari
- SCRIPTS: Tum script kaynaklari
- ADMIN: Admin ilgili scriptler
- REMOTE: Remote event/function
- GUI: GUI yapisi
- OZET: Analiz ozeti
Kodlari KOPYALA butonu ile kopyalayin.
=============================
]])
