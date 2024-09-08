local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local workspace = game:GetService("Workspace")

-- Create a ScreenGui and TextLabel to display rush status
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
local sizecon = Instance.new("UIAspectRatioConstraint")
sizecon.AspectRatio = 2

local textLabel = Instance.new("TextLabel")
sizecon.Parent = textLabel
textLabel.Parent = screenGui
textLabel.Size = UDim2.fromScale(0.1, 0.1)
textLabel.Position = UDim2.fromScale(0, 0.5)
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
textLabel.BackgroundTransparency = 0.5
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSans
textLabel.Text = "Entities: "
textLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Table defining highlight colors for specific model names
local highlightColors = {
    ["PickupItem"] = {OutlineColor = Color3.fromRGB(200, 0, 200), FillColor = Color3.fromRGB(175, 0, 175)},
    ["Door"] = {OutlineColor = Color3.fromRGB(0, 220, 255), FillColor = Color3.fromRGB(0, 128, 128)},
    ["RushMoving"] = {OutlineColor = Color3.fromRGB(255, 0, 0), FillColor = Color3.fromRGB(200, 0, 0)},
    ["Eyes"] = {OutlineColor = Color3.fromRGB(255, 0, 0), FillColor = Color3.fromRGB(200, 0, 0)},
    ["FigureRig"] = {OutlineColor = Color3.fromRGB(255, 0, 0), FillColor = Color3.fromRGB(200, 0, 0)},
    ["LeverForGate"] = {OutlineColor = Color3.fromRGB(0, 220, 255), FillColor = Color3.fromRGB(128, 128, 128)},
    ["KeyObtain"] = {OutlineColor = Color3.fromRGB(255, 255, 100), FillColor = Color3.fromRGB(255, 255, 0)},
    ["LiveBreakerPolePickup"] = {OutlineColor = Color3.fromRGB(200, 0, 200), FillColor = Color3.fromRGB(175, 0, 175)},
    ["LiveHintBook"] = {OutlineColor = Color3.fromRGB(200, 0, 200), FillColor = Color3.fromRGB(175, 0, 175)},
    ["Snare"] = {OutlineColor = Color3.fromRGB(0, 200, 0), FillColor = Color3.fromRGB(0, 150, 0)},
}

local isEnabled = true
local shouldstop = false

-- Function to check for RushNew or RushPart and update the TextLabel
local function entcheck()
    local ents = ""
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "RushMoving" then
            ents = ents .. "Rush "
        elseif v.Name == "FigureRig" then
            ents = ents .. "Figure "
        elseif v.Name == "AmbushMoving" then
            ents = ents .. "Ambush "
        elseif v.Name == "Eyes" and v.Parent == workspace then
            ents = ents .. "Eyes "
        elseif v.Name == "Screech" then
            ents = ents .. "Screech "
        end
    end

    -- Update the TextLabel based on entities found
    textLabel.Text = "Entities: " .. ents
end

-- Function to toggle highlights
local function toggleHighlight()
    isEnabled = not isEnabled
    if not isEnabled then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("Folder") then
                local highlight = v:FindFirstChild("zhi")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Function to stop the script
local function stopScript()
    isEnabled = false
    shouldstop = true
end

-- Listen for key presses
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Z then
        if shouldstop then return end
        toggleHighlight()
    elseif input.KeyCode == Enum.KeyCode.Minus then
        stopScript()
    end
end)

local function weldPartToRushPart(rushPart)
    if rushPart:FindFirstChild("AttachedPart") then return end
    local newPart = Instance.new("Part")
    newPart.Size = Vector3.new(4, 4, 4)
    newPart.Position = rushPart.Position
    newPart.Anchored = false
    newPart.CanCollide = false
    newPart.Transparency = 0.75
    newPart.Name = "AttachedPart"
    newPart.Shape = Enum.PartType.Ball

    -- Create a weld
    local weld = Instance.new("Weld")
    weld.Part0 = rushPart
    weld.Part1 = newPart
    weld.C0 = rushPart.CFrame:inverse() * newPart.CFrame
    weld.Parent = rushPart

    -- Create a highlight
    local h = Instance.new("Highlight")
    h.Adornee = newPart
    h.Name = "zhi"
    h.Enabled = true
    h.Parent = newPart

    local mesh = Instance.new("SpecialMesh")
    mesh.Parent = newPart

    -- Parent the new part to rushPart
    newPart.Parent = rushPart
end

-- Main loop
while task.wait(0.4) do
    if isEnabled then
        entcheck()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("Folder") then
                local highlightData = highlightColors[v.Name]
                if highlightData then
                    if not v:FindFirstChildOfClass("Highlight") then
                        local h = Instance.new("Highlight")
                        h.Adornee = v
                        h.Name = "zhi"
                        h.Enabled = true
                        if v.Name == "Door" and v:FindFirstChild("Door") then
                            h.Adornee = v.Door
                        elseif v.Name == "RushNew" then
                            local rushPart = v:FindFirstChild("RushPart")
                            if rushPart then
                                weldPartToRushPart(rushPart)
                            end
                        elseif v.Name == "Eyes" and v.Parent ~= workspace then
                            return
                        elseif v.Name == "Eyes" and v.Parent == workspace then
                            h.Adornee = v:FindFirstChild("Core")
                        end
                        h.OutlineColor = highlightData.OutlineColor
                        h.FillColor = highlightData.FillColor
                        h.Parent = v
                    end
                end
            end
        end
    end
    if shouldstop then
        screenGui:Destroy()
        isEnabled = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("Folder") then
                local highlight = v:FindFirstChild("zhi")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        break
    end
end