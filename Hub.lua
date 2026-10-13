-- Steal An Egg Hub v1.1
-- Client-side world egg highlighting and diagnostics.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local previous = guiParent:FindFirstChild("StealAnEggHub")
if previous then previous:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "StealAnEggHub"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(310, 280)
frame.Position = UDim2.new(0.5, -155, 0.5, -140)
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
button("Close", function()
    clearMarkers()
    gui:Destroy()
end)
