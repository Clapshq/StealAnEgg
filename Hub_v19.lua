-- Steal An Egg Hub v19.0 | Delta / MuMu
local P=game:GetService("Players");local U=game:GetService("UserInputService");local L=P.LocalPlayer;local G=L:WaitForChild("PlayerGui")
local env=(getgenv and getgenv()) or _G
if type(env.__SAEHubCleanup)=="function" then pcall(env.__SAEHubCleanup) end
for _,name in ipairs({"StealAnEggHubV18","StealAnEggHubV19"}) do local previous=G:FindFirstChild(name);if previous then previous:Destroy() end end
local S={egg=true,nest=true,labels=true,distance=2500,alive=true,visuals={}}
local c={bg=Color3.fromRGB(12,14,23),panel=Color3.fromRGB(22,25,39),raised=Color3.fromRGB(33,36,55),purple=Color3.fromRGB(151,104,255),green=Color3.fromRGB(89,221,172),white=Color3.fromRGB(241,242,250),muted=Color3.fromRGB(160,166,187)}
local function make(kind,props,parent) local o=Instance.new(kind);for k,v in pairs(props) do o[k]=v end;o.Parent=parent;return o end
local function corner(o,r)make("UICorner",{CornerRadius=UDim.new(0,r or 10)},o)end
local function text(p,str,size,pos,sz,col,bold)
 return make("TextLabel",{BackgroundTransparency=1,Text=str,TextSize=size,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextColor3=col or c.white,TextXAlignment=Enum.TextXAlignment.Left,Position=pos,Size=sz,TextWrapped=true},p)
end
local gui=make("ScreenGui",{Name="StealAnEggHubV19",ResetOnSpawn=false,DisplayOrder=10000,IgnoreGuiInset=true},G)
local main=make("Frame",{BackgroundColor3=c.bg,Position=UDim2.new(.5,-235,.5,-225),Size=UDim2.fromOffset(470,450),Active=true},gui);corner(main,16)
make("UIStroke",{Color=Color3.fromRGB(55,60,85),Thickness=1},main)
local top=make("Frame",{BackgroundColor3=c.panel,Size=UDim2.new(1,0,0,68),Active=true},main);corner(top,16)
make("Frame",{BackgroundColor3=c.panel,BorderSizePixel=0,Position=UDim2.new(0,0,1,-13),Size=UDim2.new(1,0,0,13)},top)
local bar=make("Frame",{BackgroundColor3=c.purple,Position=UDim2.fromOffset(17,17),Size=UDim2.fromOffset(5,34)},top);corner(bar,3)
text(top,"STEAL AN EGG",18,UDim2.fromOffset(32,9),UDim2.fromOffset(280,30),c.white,true)
text(top,"HUB  /  v19.0  •  ADVANCED CLIENT",10,UDim2.fromOffset(33,37),UDim2.fromOffset(300,18),c.muted)
local function btn(parent,name,pos,sz,callback)
 local b=make("TextButton",{Text=name,Position=pos,Size=sz,BackgroundColor3=c.raised,TextColor3=c.white,Font=Enum.Font.GothamBold,TextSize=13},parent);corner(b,9);b.MouseButton1Click:Connect(callback);return b
end
local side=make("Frame",{Position=UDim2.fromOffset(0,68),Size=UDim2.new(0,124,1,-68),BackgroundColor3=c.panel,BorderSizePixel=0},main)
local body=make("Frame",{Position=UDim2.fromOffset(124,68),Size=UDim2.new(1,-124,1,-68),BackgroundTransparency=1},main)
local pages={};local tabs={}
for i,name in ipairs({"Home","ESP","Player","Camera","Tools","Settings","About"}) do
 pages[name]=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=i==1},body)
 tabs[name]=btn(side,name,UDim2.fromOffset(9,15+(i-1)*46),UDim2.fromOffset(105,38),function()
  for k,page in pairs(pages) do page.Visible=k==name;tabs[k].BackgroundColor3=k==name and c.purple or c.raised end
 end)
end
tabs.Home.BackgroundColor3=c.purple
text(side,"CLIENT SIDE",10,UDim2.new(0,13,1,-40),UDim2.fromOffset(100,20),c.muted,true)
local function heading(page,a,b)
 text(page,a,17,UDim2.fromOffset(18,12),UDim2.fromOffset(300,29),c.white,true)
 text(page,b,11,UDim2.fromOffset(18,42),UDim2.fromOffset(310,22),c.muted)
end
heading(pages.ESP,"Visual ESP","Live tracking • client-rendered objects")
local counts={}
local function card(y,name,sub,key)
 local f=make("Frame",{Position=UDim2.fromOffset(15,y),Size=UDim2.new(1,-30,0,80),BackgroundColor3=c.panel},pages.ESP);corner(f,11)
 text(f,name,14,UDim2.fromOffset(13,9),UDim2.fromOffset(200,24),c.white,true)
 text(f,sub,10,UDim2.fromOffset(13,32),UDim2.fromOffset(190,20),c.muted)
 counts[key]=text(f,"Scanning...",10,UDim2.fromOffset(13,56),UDim2.fromOffset(170,18),c.green,true)
 local b=btn(f,"ON",UDim2.new(1,-78,0,24),UDim2.fromOffset(66,30),function()S[key]=not S[key] end)
 task.spawn(function()while S.alive and b.Parent do b.Text=S[key] and "ON" or "OFF";b.BackgroundColor3=S[key] and c.purple or c.raised;task.wait(.2)end end)
end
card(77,"Egg ESP","Area eggs + placed renders","egg")
card(168,"Nest ESP","Guard area nest models","nest")
text(pages.ESP,"Visuals refresh automatically every 1.5 seconds.",10,UDim2.fromOffset(18,270),UDim2.fromOffset(300,38),c.muted)
heading(pages.Settings,"Preferences","Adjust visual display")
local dist=text(pages.Settings,"Max ESP distance: 2500 studs",13,UDim2.fromOffset(18,87),UDim2.fromOffset(310,32),c.white,true)
local function change(n)S.distance=math.clamp(S.distance+n,100,10000);dist.Text="Max ESP distance: "..S.distance.." studs"end
btn(pages.Settings,"−",UDim2.fromOffset(18,130),UDim2.fromOffset(43,36),function()change(-500)end)
btn(pages.Settings,"+",UDim2.fromOffset(72,130),UDim2.fromOffset(43,36),function()change(500)end)
local labels=btn(pages.Settings,"Distance labels: ON",UDim2.fromOffset(18,194),UDim2.new(1,-36,0,44),function()S.labels=not S.labels end)
task.spawn(function()while S.alive do labels.Text="Distance labels: "..(S.labels and "ON" or "OFF");task.wait(.3)end end)
heading(pages.About,"Steal An Egg Hub","Version 18.1 • client-side overlay")
text(pages.About,"Based on Full Scan v4.0.\n\nEggs: Workspace.AreaEggSlotsClient and Workspace.PlacedEggRenders\n\nNests: Workspace.World.Areas.GuardAreas\n\nNo server data is modified.",12,UDim2.fromOffset(18,84),UDim2.new(1,-35,0,200),c.muted)
local function clear(o) local v=S.visuals[o];if v then for _,x in ipairs(v) do pcall(function()x:Destroy()end)end;S.visuals[o]=nil end end
local function add(o,color,label)
 local h=make("Highlight",{Adornee=o,FillColor=color,FillTransparency=.73,OutlineColor=color,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},gui)
 local list={h};local part=o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart",true)
 if part then
  local b=make("BillboardGui",{Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(175,43),StudsOffsetWorldSpace=Vector3.new(0,3,0),MaxDistance=10000},gui)
  local t=text(b,label,13,UDim2.fromScale(0,0),UDim2.fromScale(1,1),c.white,true);t.TextXAlignment=Enum.TextXAlignment.Center;t.TextStrokeTransparency=.35
  list[2]=b
 end
 S.visuals[o]=list
end
local function scanEggs(t)
 local a=workspace:FindFirstChild("AreaEggSlotsClient")
 if a then for _,o in ipairs(a:GetDescendants()) do
  if o:IsA("Model") and not o.Name:find(":Slot_",1,true) and o:FindFirstChildWhichIsA("BasePart",true) then
   local childModel=false;for _,ch in ipairs(o:GetChildren()) do if ch:IsA("Model") then childModel=true;break end end
   if not childModel then t[o]="AREA EGG" end
  end
 end end
 local p=workspace:FindFirstChild("PlacedEggRenders")
 if p then for _,o in ipairs(p:GetChildren()) do
  if (o:IsA("BasePart") or o:IsA("Model")) and (o:IsA("BasePart") or o:FindFirstChildWhichIsA("BasePart",true)) then t[o]="PLACED EGG" end
 end end
end
local function scanNests(t)
 local w=workspace:FindFirstChild("World");local a=w and w:FindFirstChild("Areas");local g=a and a:FindFirstChild("GuardAreas")
 if not g then return end
 for _,area in ipairs(g:GetChildren()) do local n=area:FindFirstChild("Nests")
  if n then for _,o in ipairs(n:GetDescendants()) do if o:IsA("Model") and o.Name=="NestModel" and o:FindFirstChildWhichIsA("BasePart",true) then t[o]=area.Name.." NEST" end end end
 end
end
local function position(o)if o:IsA("BasePart") then return o.Position elseif o:IsA("Model") then return o:GetPivot().Position end end
local function update()
 local eggs,nests,desired={},{},{}
 if S.egg then scanEggs(eggs)end;if S.nest then scanNests(nests)end
 local char=L.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart")
 local function render(items,color)
  for o,label in pairs(items) do
   local p=position(o)
   if o.Parent and p and (not hrp or (hrp.Position-p).Magnitude<=S.distance) then
    desired[o]=true
    if not S.visuals[o] then add(o,color,label)end
    local v=S.visuals[o]
    if v and v[2] then v[2].Enabled=S.labels;local t=v[2]:FindFirstChildOfClass("TextLabel");if t then t.Text=label..(hrp and ("\n"..math.floor((hrp.Position-p).Magnitude).." studs") or "")end end
   end
  end
 end
 render(eggs,c.green);render(nests,c.purple)
 for o in pairs(S.visuals) do if not desired[o] then clear(o)end end
 local e,n=0,0;for _ in pairs(eggs)do e=e+1 end;for _ in pairs(nests)do n=n+1 end
 counts.egg.Text="Detected: "..e;counts.nest.Text="Detected: "..n
end

-- Player controls (local Humanoid properties; server may override)
heading(pages.Player,"Movement controls","Adjust your character's movement")
local movement={speed=16,jump=50,enabled=false}
local speedTitle=text(pages.Player,"WalkSpeed: 16",14,UDim2.fromOffset(18,83),UDim2.fromOffset(290,27),c.white,true)
local jumpTitle=text(pages.Player,"JumpPower: 50",14,UDim2.fromOffset(18,177),UDim2.fromOffset(290,27),c.white,true)
local function humanoid()
 local char=L.Character
 return char and char:FindFirstChildOfClass("Humanoid")
end
local function applyMovement()
 local h=humanoid()
 if not h then return end
 pcall(function()
  h.WalkSpeed=movement.speed
  h.UseJumpPower=true
  h.JumpPower=movement.jump
 end)
end
local function updateMovement()
 speedTitle.Text="WalkSpeed: "..movement.speed
 jumpTitle.Text="JumpPower: "..movement.jump
 movement.enabled=true
 applyMovement()
end
local function movementButton(name,x,y,fn)
 btn(pages.Player,name,UDim2.fromOffset(x,y),UDim2.fromOffset(70,35),fn)
end
movementButton("− 5",18,117,function()movement.speed=math.max(0,movement.speed-5);updateMovement()end)
movementButton("+ 5",96,117,function()movement.speed=math.min(150,movement.speed+5);updateMovement()end)
movementButton("32",174,117,function()movement.speed=32;updateMovement()end)
movementButton("64",252,117,function()movement.speed=64;updateMovement()end)
movementButton("− 10",18,211,function()movement.jump=math.max(0,movement.jump-10);updateMovement()end)
movementButton("+ 10",96,211,function()movement.jump=math.min(200,movement.jump+10);updateMovement()end)
movementButton("75",174,211,function()movement.jump=75;updateMovement()end)
movementButton("100",252,211,function()movement.jump=100;updateMovement()end)
btn(pages.Player,"Reset movement",UDim2.fromOffset(18,272),UDim2.new(1,-36,0,40),function()
 movement.speed=16;movement.jump=50;movement.enabled=false
 speedTitle.Text="WalkSpeed: 16";jumpTitle.Text="JumpPower: 50"
 applyMovement()
end)
task.spawn(function()
 while S.alive and gui.Parent do
  if movement.enabled then applyMovement() end
  task.wait(.65)
 end
end)


-- Dashboard
heading(pages.Home,"Dashboard","Steal An Egg • live client hub")
local homeStats=text(pages.Home,"Loading player data...",13,UDim2.fromOffset(18,82),UDim2.new(1,-36,0,100),c.white)
local statusBox=make("Frame",{BackgroundColor3=c.panel,Position=UDim2.fromOffset(15,188),Size=UDim2.new(1,-30,0,111)},pages.Home);corner(statusBox,12)
text(statusBox,"ACTIVE MODULES",12,UDim2.fromOffset(14,12),UDim2.fromOffset(250,22),c.purple,true)
local statusText=text(statusBox,"Egg ESP • Nest ESP",12,UDim2.fromOffset(14,43),UDim2.fromOffset(275,54),c.white)
task.spawn(function() while S.alive and gui.Parent do
 local h=L.Character and L.Character:FindFirstChildOfClass("Humanoid")
 local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
 homeStats.Text="Player: "..L.DisplayName.."\nHealth: "..(h and math.floor(h.Health).."/"..math.floor(h.MaxHealth) or "N/A").."\nPosition: "..(root and string.format("%.0f, %.0f, %.0f",root.Position.X,root.Position.Y,root.Position.Z) or "N/A")
 statusText.Text="Egg ESP: "..(S.egg and "ON" or "OFF").."   •   Nest ESP: "..(S.nest and "ON" or "OFF").."\nDistance: "..S.distance.." studs"
 task.wait(1) end end)

-- Camera controls
heading(pages.Camera,"Camera & vision","Client-side camera preferences")
local camera=workspace.CurrentCamera
local fov=70
local fovLabel=text(pages.Camera,"Field of view: 70°",14,UDim2.fromOffset(18,88),UDim2.fromOffset(285,30),c.white,true)
local function changeFov(delta)
 fov=math.clamp(fov+delta,40,120);fovLabel.Text="Field of view: "..fov.."°"
 local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=fov end
end
btn(pages.Camera,"− 5",UDim2.fromOffset(18,129),UDim2.fromOffset(90,38),function()changeFov(-5)end)
btn(pages.Camera,"+ 5",UDim2.fromOffset(120,129),UDim2.fromOffset(90,38),function()changeFov(5)end)
btn(pages.Camera,"Reset FOV",UDim2.fromOffset(18,183),UDim2.new(1,-36,0,40),function()fov=70;fovLabel.Text="Field of view: 70°";local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=70 end end)
local cameraLock=false
local cameraToggle=btn(pages.Camera,"Keep FOV: OFF",UDim2.fromOffset(18,236),UDim2.new(1,-36,0,40),function()cameraLock=not cameraLock end)
task.spawn(function()while S.alive do cameraToggle.Text="Keep FOV: "..(cameraLock and "ON" or "OFF");if cameraLock and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=fov end;task.wait(.5)end end)

-- Utility controls
heading(pages.Tools,"Utility tools","Quick actions and visual helpers")
local lighting=game:GetService("Lighting")
local oldLighting={Brightness=lighting.Brightness,ClockTime=lighting.ClockTime,GlobalShadows=lighting.GlobalShadows,Ambient=lighting.Ambient,OutdoorAmbient=lighting.OutdoorAmbient}
local bright=false
local function setBright(on)
 bright=on
 if on then lighting.Brightness=3;lighting.ClockTime=14;lighting.GlobalShadows=false;lighting.Ambient=Color3.fromRGB(200,200,200);lighting.OutdoorAmbient=Color3.fromRGB(200,200,200)
 else for k,v in pairs(oldLighting) do lighting[k]=v end end
end
local lightButton=btn(pages.Tools,"Fullbright: OFF",UDim2.fromOffset(18,83),UDim2.new(1,-36,0,43),function()setBright(not bright)end)
local coords=text(pages.Tools,"Position: waiting...",12,UDim2.fromOffset(18,145),UDim2.new(1,-36,0,47),c.muted)
btn(pages.Tools,"Copy coordinates",UDim2.fromOffset(18,202),UDim2.new(1,-36,0,43),function()
 local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
 if root and setclipboard then setclipboard(string.format("%.2f, %.2f, %.2f",root.Position.X,root.Position.Y,root.Position.Z)) end
end)
btn(pages.Tools,"Refresh ESP now",UDim2.fromOffset(18,260),UDim2.new(1,-36,0,43),function()pcall(update)end)
task.spawn(function()while S.alive do
 lightButton.Text="Fullbright: "..(bright and "ON" or "OFF")
 local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
 coords.Text="Position: "..(root and string.format("%.1f / %.1f / %.1f",root.Position.X,root.Position.Y,root.Position.Z) or "N/A")
 task.wait(.5) end end)

-- Extra movement controls
local sprint=false;local sprintSpeed=48;local infiniteJump=false;local autoJump=false
local sprintButton=btn(pages.Player,"Sprint: OFF",UDim2.fromOffset(18,319),UDim2.fromOffset(145,35),function()sprint=not sprint end)
local jumpButton=btn(pages.Player,"Infinite jump: OFF",UDim2.fromOffset(170,319),UDim2.fromOffset(151,35),function()infiniteJump=not infiniteJump end)
local jumpConnection=U.JumpRequest:Connect(function()
 if not infiniteJump then return end
 local h=humanoid();if h then pcall(function()h:ChangeState(Enum.HumanoidStateType.Jumping)end)end
end)
task.spawn(function()while S.alive do
 sprintButton.Text="Sprint: "..(sprint and "ON" or "OFF")
 jumpButton.Text="Infinite jump: "..(infiniteJump and "ON" or "OFF")
 if sprint then local h=humanoid();if h then h.WalkSpeed=math.max(movement.speed,sprintSpeed)end end
 task.wait(.2)end end)

local drag=false;local dragStart;local startPos
top.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;dragStart=i.Position;startPos=main.Position end end)
local changed=U.InputChanged:Connect(function(i)if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local d=i.Position-dragStart;main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)
local ended=U.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
local function destroy()
 if not S.alive then return end
 S.alive=false
 changed:Disconnect();ended:Disconnect();jumpConnection:Disconnect()
 for o in pairs(S.visuals)do clear(o)end
 if bright then setBright(false)end
 gui:Destroy()
end
env.__SAEHubCleanup=destroy
btn(top,"×",UDim2.new(1,-39,0,19),UDim2.fromOffset(29,29),destroy)
local minimized=false
local mini=btn(top,"−",UDim2.new(1,-75,0,19),UDim2.fromOffset(29,29),function()minimized=not minimized;main.Size=minimized and UDim2.fromOffset(470,68) or UDim2.fromOffset(470,450);side.Visible=not minimized;body.Visible=not minimized end)
task.spawn(function()while S.alive and gui.Parent do pcall(update);task.wait(1.5)end end)
