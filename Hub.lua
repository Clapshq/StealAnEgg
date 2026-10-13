-- Steal An Egg Hub | Delta Android
-- Client-side utility: egg markers, base navigation, and scanner.
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('StealAnEggHub')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'StealAnEggHub'
gui.ResetOnSpawn = false
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(300, 350)
frame.Position = UDim2.new(.5,-150,.5,-175)
frame.BackgroundColor3 = Color3.fromRGB(25,27,34)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,12)
local layout = Instance.new('UIListLayout',frame)
layout.Padding = UDim.new(0,7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local function label(t,h)
 local v=Instance.new('TextLabel');v.Size=UDim2.new(1,-16,0,h or 30);v.BackgroundTransparency=1;v.Text=t;v.TextWrapped=true;v.TextColor3=Color3.new(1,1,1);v.Font=Enum.Font.Gotham;v.TextSize=14;v.Parent=frame;return v
end
label('STEAL AN EGG | HUB',35)
local status=label('Ready - client-side tools only',45)
local function button(t,fn)
 local b=Instance.new('TextButton');b.Size=UDim2.new(1,-22,0,39);b.BackgroundColor3=Color3.fromRGB(43,111,91);b.TextColor3=Color3.new(1,1,1);b.Text=t;b.TextSize=14;b.Font=Enum.Font.GothamBold;b.Parent=frame;Instance.new('UICorner',b).CornerRadius=UDim.new(0,8)
 b.MouseButton1Click:Connect(function() local ok,err=pcall(fn);if not ok then status.Text='Error: '..tostring(err) end end)
 return b
end
local highlights={}
local esp=false
local function clearESP()
 for _,h in ipairs(highlights) do pcall(function() h:Destroy() end) end
 table.clear(highlights)
end
local function updateESP()
 clearESP()
 if not esp then return end
 local folder=Workspace:FindFirstChild('PlacedEggRenders') or Workspace:FindFirstChild('Eggs')
 if not folder then status.Text='No egg folder currently visible';return end
 local count=0
 for _,obj in ipairs(folder:GetChildren()) do
  if obj:IsA('Model') or obj:IsA('BasePart') then
   local h=Instance.new('Highlight');h.Name='EggHubMarker';h.Adornee=obj;h.FillColor=Color3.fromRGB(255,213,60);h.OutlineColor=Color3.new(1,1,1);h.FillTransparency=.7;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=gui
   table.insert(highlights,h);count=count+1
   if count>=60 then break end
  end
 end
 status.Text='Egg markers: '..count
end
button('Toggle Egg ESP',function() esp=not esp;updateESP() end)
local function root()
 local char=player.Character or player.CharacterAdded:Wait()
 return char:FindFirstChild('HumanoidRootPart')
end
local function teleportTo(part)
 local r=root();if not r then status.Text='Character not ready';return end
 r.CFrame=part.CFrame*CFrame.new(0,4,0)
 status.Text='Moved to '..part:GetFullName()..' (server may reset position)'
end
local plots=Workspace:FindFirstChild('Plots')
local function getPlots()
 local found={}
 if not plots then return found end
 for _,p in ipairs(plots:GetChildren()) do
  local sp=p:FindFirstChild('SpawnPoint')
  if sp and sp:IsA('BasePart') then table.insert(found,{name=p.Name,spawn=sp}) end
 end
 table.sort(found,function(a,b)return a.name<b.name end)
 return found
end
local currentPlot=1
button('Next Plot / Teleport',function()
 local arr=getPlots();if #arr==0 then status.Text='No plots found';return end
 currentPlot=(currentPlot-1)%#arr+1
 local p=arr[currentPlot];teleportTo(p.spawn)
 currentPlot=currentPlot+1
end)
button('Copy Egg / Plot Scan',function()
 local lines={'STEAL AN EGG HUB SCAN','PlaceId: '..game.PlaceId}
 for _,folderName in ipairs({'Eggs','PlacedEggRenders','AreaEggSlotsClient','Plots'}) do
  local folder=Workspace:FindFirstChild(folderName)
  table.insert(lines,folderName..': '..(folder and #folder:GetChildren() or 'missing'))
  if folder then
   for i,obj in ipairs(folder:GetChildren()) do
    if i>30 then break end
    table.insert(lines,obj.ClassName..' | '..obj:GetFullName())
   end
  end
 end
 local data=table.concat(lines,'\n')
 if type(setclipboard)=='function' then setclipboard(data);status.Text='Scan copied to clipboard' else status.Text='Clipboard unsupported; see console';print(data) end
end)
button('Refresh Egg Markers',updateESP)
button('Close Hub',function() clearESP();gui:Destroy() end)
