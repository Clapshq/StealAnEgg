-- Steal An Egg Hub v1.3
-- Client-side world egg highlighting and diagnostics.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
-- Clean up previous runs, including old GUI copies and their ESP markers.
local shared = (type(getgenv) == "function" and getgenv()) or _G
if type(shared.StealAnEggHubCleanup) == "function" then
    pcall(shared.StealAnEggHubCleanup)
end
for _, child in ipairs(guiParent:GetChildren()) do
    if child:IsA("ScreenGui") and child.Name == "StealAnEggHub" then
        child:Destroy()
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "StealAnEggHub"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(310, 340)
frame.Position = UDim2.new(0.5, -155, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function label(text, height)
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1, -20, 0, height)
    item.BackgroundTransparency = 1
    item.TextColor3 = Color3.new(1, 1, 1)
    item.Font = Enum.Font.Gotham
    item.TextSize = 14
    item.TextWrapped = true
    item.Text = text
    item.Parent = frame
    return item
end

label("STEAL AN EGG | WORLD SCANNER", 38)
local status = label("Teleport removed to prevent deaths.", 50)
local markers = {}
local enabled = false
shared.StealAnEggHubCleanup = function()
    enabled = false
    for _, marker in ipairs(markers) do
        pcall(function() marker:Destroy() end)
    end
    table.clear(markers)
    if gui and gui.Parent then gui:Destroy() end
end

local function clearMarkers()
    for _, marker in ipairs(markers) do
        marker:Destroy()
    end
    table.clear(markers)
end

local function updateMarkers()
    clearMarkers()
    if not enabled then
        status.Text = "World egg ESP off"
        return
    end
    local worldEggs = Workspace:FindFirstChild("Eggs")
    if not worldEggs then
        status.Text = "Workspace.Eggs not found"
        return
    end
    local count = 0
    for _, object in ipairs(worldEggs:GetChildren()) do
        if object:IsA("Model") or object:IsA("BasePart") then
            local marker = Instance.new("Highlight")
            marker.Adornee = object
            marker.FillColor = Color3.fromRGB(255, 207, 55)
            marker.OutlineColor = Color3.new(1, 1, 1)
            marker.FillTransparency = 0.65
            marker.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            marker.Parent = gui
            table.insert(markers, marker)
            count = count + 1
            if count >= 60 then break end
        end
    end
    status.Text = "World egg candidates: " .. count .. " (verify in-game)"
end

local function button(title, callback)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -20, 0, 40)
    item.BackgroundColor3 = Color3.fromRGB(43, 111, 91)
    item.TextColor3 = Color3.new(1, 1, 1)
    item.Font = Enum.Font.GothamBold
    item.TextSize = 14
    item.Text = title
    item.Parent = frame
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    item.MouseButton1Click:Connect(callback)
end

button("Toggle World Egg ESP", function()
    enabled = not enabled
    updateMarkers()
end)
button("Refresh Egg Markers", updateMarkers)
button("Copy World Egg Scan", function()
    local lines = {"PlaceId: " .. tostring(game.PlaceId)}
    local folder = Workspace:FindFirstChild("Eggs")
    if folder then
        table.insert(lines, "Workspace.Eggs: " .. tostring(#folder:GetChildren()))
        for index, object in ipairs(folder:GetChildren()) do
            if index > 80 then break end
            table.insert(lines, object.ClassName .. " | " .. object:GetFullName())
        end
    else
        table.insert(lines, "Workspace.Eggs missing")
    end
    local report = table.concat(lines, "\n")
    if type(setclipboard) == "function" then
        setclipboard(report)
        status.Text = "Scan copied to clipboard"
    else
        print(report)
        status.Text = "Scan printed to console"
    end
end)

-- Read-only client-visible world diagnostics. No remote invocation or source extraction.
local function deepScan()
    local output = {
        "STEAL AN EGG | DEEP SCAN v1.3",
        "PlaceId: " .. tostring(game.PlaceId),
        "Local player: " .. tostring(player.Name),
        "Client-visible data only; server internals are not accessible."
    }
    local limits = {maxObjects = 12000, maxLines = 2500}
    local scanned, emitted = 0, 0
    local function add(line)
        if emitted < limits.maxLines then
            table.insert(output, line)
            emitted = emitted + 1
        end
    end
    local roots = {
        Workspace,
        game:GetService("ReplicatedStorage"),
        player:FindFirstChild("PlayerGui")
    }
    local interesting = {
        Model = true, ProximityPrompt = true, ClickDetector = true,
        RemoteEvent = true, RemoteFunction = true, TouchTransmitter = true,
        StringValue = true, ObjectValue = true, IntValue = true,
        NumberValue = true, BoolValue = true
    }
    for _, root in ipairs(roots) do
        if root then
            add("===== " .. root:GetFullName() .. " =====")
            local descendants = root:GetDescendants()
            for _, obj in ipairs(descendants) do
                scanned = scanned + 1
                if scanned > limits.maxObjects then break end
                local name = obj.Name:lower()
                local relevant = interesting[obj.ClassName]
                    or name:find("egg", 1, true)
                    or name:find("steal", 1, true)
                    or name:find("carry", 1, true)
                    or name:find("deliver", 1, true)
                    or name:find("plot", 1, true)
                if relevant then
                    local line = obj.ClassName .. " | " .. obj:GetFullName()
                    if obj:IsA("BasePart") then
                        line = line .. " | pos=" .. tostring(obj.Position)
                    elseif obj:IsA("ProximityPrompt") then
                        line = line .. " | action=" .. tostring(obj.ActionText)
                            .. " | object=" .. tostring(obj.ObjectText)
                    end
                    local attrs = obj:GetAttributes()
                    local attrParts = {}
                    local attrCount = 0
                    for key, value in pairs(attrs) do
                        attrCount = attrCount + 1
                        if attrCount > 8 then break end
                        table.insert(attrParts, tostring(key) .. "=" .. tostring(value))
                    end
                    if #attrParts > 0 then
                        line = line .. " | attrs={" .. table.concat(attrParts, ",") .. "}"
                    end
                    add(line)
                end
            end
        end
    end
    add("Scanned objects: " .. tostring(scanned))
    if scanned > limits.maxObjects or emitted >= limits.maxLines then
        add("TRUNCATED: scan limits reached")
    end
    return table.concat(output, "\n")
end

button("Deep Scan + Copy Results", function()
    status.Text = "Scanning client-visible game objects..."
    local ok, report = pcall(deepScan)
    if not ok then
        status.Text = "Scan error: " .. tostring(report)
        return
    end
    if type(setclipboard) == "function" then
        setclipboard(report)
        status.Text = "Deep scan copied! Paste it into chat."
    elseif type(writefile) == "function" then
        writefile("StealAnEgg_DeepScan.txt", report)
        status.Text = "Saved: StealAnEgg_DeepScan.txt"
    else
        print(report)
        status.Text = "Clipboard unavailable; printed to console."
    end
end)

button("Close", function()
    shared.StealAnEggHubCleanup()
    shared.StealAnEggHubCleanup = nil
end)
