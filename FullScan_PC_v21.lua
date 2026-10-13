-- Steal An Egg | Full PC Scan v2.1
-- Enumerates all client-replicated Instances in batches. Does not read scripts or call remotes.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local old = guiParent:FindFirstChild("StealAnEggFullScan")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "StealAnEggFullScan"
gui.ResetOnSpawn = false
gui.Parent = guiParent
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 250)
frame.Position = UDim2.new(0.5,-160,0.5,-125)
frame.BackgroundColor3 = Color3.fromRGB(23,27,35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
local layout = Instance.new("UIListLayout",frame)
layout.Padding = UDim.new(0,7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local function label(t,h)
    local x=Instance.new("TextLabel")
    x.Size=UDim2.new(1,-14,0,h)
    x.BackgroundTransparency=1
    x.TextColor3=Color3.new(1,1,1)
    x.TextWrapped=true
    x.Font=Enum.Font.Gotham
    x.TextSize=13
    x.Text=t
    x.Parent=frame
    return x
end
label("STEAL AN EGG | FULL PC SCAN v2.1",32)
local status=label("Ready. Sends numbered parts to your Windows PC.",48)
local hostIp="10.0.2.2"
local running=false
local cancel=false
local function button(t,fn)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-16,0,40)
    b.BackgroundColor3=Color3.fromRGB(40,108,94)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    b.Text=t
    b.Parent=frame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseButton1Click:Connect(fn)
end
local function safe(v)
    local s=tostring(v)
    return s:gsub("[\\r\\n\\t]"," ")
end
local function describe(obj)
    local line=obj.ClassName.." | "..obj:GetFullName()
    if obj:IsA("BasePart") then
        line=line.." | pos="..safe(obj.Position).." | size="..safe(obj.Size)
    elseif obj:IsA("ProximityPrompt") then
        line=line.." | action="..safe(obj.ActionText).." | object="..safe(obj.ObjectText)
    elseif obj:IsA("ValueBase") then
        local ok,val=pcall(function() return obj.Value end)
        if ok then line=line.." | value="..safe(val) end
    end
    local attrs=obj:GetAttributes()
    local bits={}
    for k,v in pairs(attrs) do
        table.insert(bits,safe(k).."="..safe(v))
    end
    if #bits>0 then line=line.." | attrs={"..table.concat(bits,",").."}" end
    return line
end
local hostBox=Instance.new("TextBox")
hostBox.Size=UDim2.new(1,-16,0,35)
hostBox.BackgroundColor3=Color3.fromRGB(45,48,60)
hostBox.TextColor3=Color3.new(1,1,1)
hostBox.Text="10.0.2.2"
hostBox.PlaceholderText="PC host IP"
hostBox.Parent=frame
local function sendPart(runId,part,content)
    local req=(syn and syn.request) or http_request or request
    if type(req)~="function" then error("Executor has no HTTP request function") end
    local body=game:GetService("HttpService"):JSONEncode({run=runId,part=part,content=content})
    local response=req({Url="http://"..hostBox.Text..":8765/upload",Method="POST",Headers={["Content-Type"]="application/json",["X-Scan-Token"]="eggscan-local-2026"},Body=body})
    if not response or response.StatusCode~=200 then error("PC upload failed: "..tostring(response and response.StatusCode)) end
end
local function scan()
    if running then return end
    
    running=true
    cancel=false
    task.spawn(function()
        local roots={
            workspace,
            game:GetService("ReplicatedStorage"),
            game:GetService("ReplicatedFirst"),
            game:GetService("Lighting"),
            game:GetService("StarterGui"),
            game:GetService("StarterPack"),
            game:GetService("SoundService"),
            game:GetService("Teams"),
            player:FindFirstChild("PlayerGui"),
            player:FindFirstChild("Backpack"),
            player:FindFirstChild("PlayerScripts")
        }
        local runId=tostring(game.PlaceId).."_"..tostring(math.floor(os.clock()*1000))
        local prefix="StealAnEgg_FullScan_"..runId
        local part=0
        local buffer={}
        local summary={"FULL CLIENT SCAN v2.0","PlaceId: "..game.PlaceId,"Client-visible Instances only; no server-only state, script source or remote invocation.","Run: "..runId}
        local counts={}
        local total=0
        local function flush()
            if #buffer==0 then return end
            part=part+1
            local filename=prefix.."_part"..string.format("%03d",part)..".txt"
            local ok,err=pcall(sendPart,runId,part,table.concat(buffer,"\n"))
            if not ok then error("Cannot write "..filename..": "..safe(err)) end
            table.insert(summary,filename.." | lines="..#buffer)
            table.clear(buffer)
        end
        local ok,err=pcall(function()
            for _,root in ipairs(roots) do
                if cancel then break end
                if root then
                    table.insert(buffer,"===== ROOT "..root:GetFullName().." =====")
                    -- Snapshot each root once. Yield while formatting to keep mobile responsive.
                    local objects=root:GetDescendants()
                    table.insert(buffer,"ROOT_COUNT "..#objects)
                    for i,obj in ipairs(objects) do
                        if cancel then break end
                        total=total+1
                        counts[obj.ClassName]=(counts[obj.ClassName] or 0)+1
                        local success,line=pcall(describe,obj)
                        if success then
                            table.insert(buffer,line)
                        else
                            table.insert(buffer,"ERROR | "..safe(obj.Name).." | "..safe(line))
                        end
                        if #buffer>=2500 then flush() end
                        if i%150==0 then
                            status.Text="Scanned "..total.." objects | "..part.." files saved | "..root.Name
                            task.wait()
                        end
                    end
                    table.clear(objects)
                end
            end
            flush()
            table.insert(summary,"Total objects: "..total)
            table.insert(summary,"Cancelled: "..tostring(cancel))
            table.insert(summary,"===== CLASS COUNTS =====")
            local classes={}
            for cls in pairs(counts) do table.insert(classes,cls) end
            table.sort(classes)
            for _,cls in ipairs(classes) do table.insert(summary,cls..": "..counts[cls]) end
            sendPart(runId,part+1,table.concat(summary,"\n"))
        end)
        running=false
        if ok then
            status.Text="Done: "..total.." objects, "..part.." parts. Send SUMMARY + relevant part files."
        else
            status.Text="Stopped after "..total.." objects: "..safe(err)
        end
    end)
end
button("START FULL CLIENT SCAN",scan)
button("STOP SCAN",function() cancel=true; status.Text="Stopping after current batch..." end)
