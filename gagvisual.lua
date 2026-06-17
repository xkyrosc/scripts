-- Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local SeedPackController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SeedPackController"))
local SeedPackData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedPackData"))
local CalculatePlantValue = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CalculatePlantValue"))
local Comma = require(ReplicatedStorage:WaitForChild("Comma_Module"))

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AllInOneESP"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Toggle System
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.AnchorPoint = Vector2.new(0, 0.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleButton.TextColor3 = Color3.fromRGB(200, 200, 255)
toggleButton.Text = "☰"
toggleButton.Font = Enum.Font.SciFi
toggleButton.TextSize = 24
toggleButton.ZIndex = 10

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.2, 0)
toggleCorner.Parent = toggleButton

-- Sound Effects
local openSound = Instance.new("Sound")
openSound.SoundId = "rbxassetid://9045567253"
openSound.Volume = 0.5
openSound.Parent = gui

local closeSound = Instance.new("Sound")
closeSound.SoundId = "rbxassetid://9045566887"
closeSound.Volume = 0.5
closeSound.Parent = gui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.05, 0)
corner.Parent = mainFrame

-- GUI State
local guiVisible = true

-- Toggle Functionality
toggleButton.MouseButton1Click:Connect(function()
    if guiVisible then
        local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(1.5, 0, 0.5, 0)})
        tweenOut:Play()
        closeSound:Play()
        toggleButton.Text = "≡"
    else
        mainFrame.Visible = true
        local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 0.5, 0)})
        tweenIn:Play()
        openSound:Play()
        toggleButton.Text = "☰"
    end
    guiVisible = not guiVisible
end)

-- Tab System
local tabButtons = {}
local tabFrames = {}

-- Create a scroll frame for tabs
local tabScrollFrame = Instance.new("ScrollingFrame")
tabScrollFrame.Name = "TabScrollFrame"
tabScrollFrame.Size = UDim2.new(0.2, 0, 1, 0)
tabScrollFrame.Position = UDim2.new(0, 0, 0, 0)
tabScrollFrame.BackgroundTransparency = 1
tabScrollFrame.ScrollBarThickness = 6
tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabScrollFrame.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.Parent = tabScrollFrame

local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name.."Tab"
    tabButton.Size = UDim2.new(0.9, 0, 0, 40)
    tabButton.Position = UDim2.new(0.05, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tabButton.Text = name
    tabButton.Font = Enum.Font.SciFi
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    tabButton.TextSize = 14
    tabButton.ZIndex = 2
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0.05, 0)
    tabCorner.Parent = tabButton
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name.."Frame"
    tabFrame.Size = UDim2.new(0.8, 0, 1, 0)
    tabFrame.Position = UDim2.new(0.2, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    
    tabButton.Parent = tabScrollFrame
    tabFrame.Parent = mainFrame
    
    tabButtons[name] = tabButton
    tabFrames[name] = tabFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(tabFrames) do frame.Visible = false end
        tabFrame.Visible = true
        for _, button in pairs(tabButtons) do button.BackgroundColor3 = Color3.fromRGB(40, 40, 60) end
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)
    
    return tabFrame
end

-- Create Tabs (added Main tab first)
local mainTab = createTab("Main")
local seedTab = createTab("Seed")
local plantTab = createTab("Plant")
local eggTab = createTab("Egg")
local dupeTab = createTab("Dupe")

-- Main Tab Content
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, 0, 0.15, 0)
mainTitle.Position = UDim2.new(0, 0, 0, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "ALL IN ONE ESP"
mainTitle.Font = Enum.Font.SciFi
mainTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
mainTitle.TextSize = 24
mainTitle.Parent = mainTab

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
creditsLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Created by: ScriptMaster\nVersion: 2.0"
creditsLabel.Font = Enum.Font.SciFi
creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
creditsLabel.TextSize = 16
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.TextYAlignment = Enum.TextYAlignment.Top
creditsLabel.Parent = mainTab

-- Social Links
local youtubeButton = Instance.new("TextButton")
youtubeButton.Name = "YoutubeButton"
youtubeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
youtubeButton.Position = UDim2.new(0.1, 0, 0.4, 0)
youtubeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
youtubeButton.Text = "YOUTUBE"
youtubeButton.Font = Enum.Font.SciFi
youtubeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
youtubeButton.TextSize = 16
youtubeButton.Parent = mainTab

local youtubeCorner = Instance.new("UICorner")
youtubeCorner.CornerRadius = UDim.new(0.2, 0)
youtubeCorner.Parent = youtubeButton

local discordButton = youtubeButton:Clone()
discordButton.Name = "DiscordButton"
discordButton.Position = UDim2.new(0.1, 0, 0.55, 0)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.Text = "DISCORD"
discordButton.Parent = mainTab

local githubButton = youtubeButton:Clone()
githubButton.Name = "GithubButton"
githubButton.Position = UDim2.new(0.1, 0, 0.7, 0)
githubButton.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
githubButton.Text = "GITHUB"
githubButton.Parent = mainTab

-- Social Link Functionality
youtubeButton.MouseButton1Click:Connect(function()
    setclipboard("https://www.youtube.com/c/ScriptMaster")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Link Copied!",
        Text = "YouTube link copied to clipboard",
        Duration = 3
    })
end)

discordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/scriptmaster")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Link Copied!",
        Text = "Discord link copied to clipboard",
        Duration = 3
    })
end)

githubButton.MouseButton1Click:Connect(function()
    setclipboard("https://github.com/ScriptMaster")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Link Copied!",
        Text = "GitHub link copied to clipboard",
        Duration = 3
    })
end)

-- Activate Main tab first
tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(60, 60, 80)
mainTab.Visible = true

-- Seed Spinner Tab
local seedTitle = Instance.new("TextLabel")
seedTitle.Size = UDim2.new(1, 0, 0.15, 0)
seedTitle.Position = UDim2.new(0, 0, 0, 0)
seedTitle.BackgroundTransparency = 1
seedTitle.Text = "SEED SPINNER"
seedTitle.Font = Enum.Font.SciFi
seedTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
seedTitle.TextSize = 18
seedTitle.Parent = seedTab

local packDropdown = Instance.new("TextButton")
packDropdown.Name = "PackDropdown"
packDropdown.Size = UDim2.new(0.8, 0, 0.15, 0)
packDropdown.Position = UDim2.new(0.1, 0, 0.2, 0)
packDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
packDropdown.Text = "SELECT PACK"
packDropdown.Font = Enum.Font.SciFi
packDropdown.TextColor3 = Color3.fromRGB(200, 200, 255)
packDropdown.TextSize = 14
packDropdown.ZIndex = 2
packDropdown.Parent = seedTab

local packCorner = Instance.new("UICorner")
packCorner.CornerRadius = UDim.new(0.2, 0)
packCorner.Parent = packDropdown

local seedDropdown = packDropdown:Clone()
seedDropdown.Name = "SeedDropdown"
seedDropdown.Position = UDim2.new(0.1, 0, 0.4, 0)
seedDropdown.Text = "SELECT SEED"
seedDropdown.Parent = seedTab

local spinButton = Instance.new("TextButton")
spinButton.Size = UDim2.new(0.6, 0, 0.15, 0)
spinButton.Position = UDim2.new(0.2, 0, 0.65, 0)
spinButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
spinButton.Text = "SPIN"
spinButton.Font = Enum.Font.SciFi
spinButton.TextColor3 = Color3.fromRGB(200, 255, 255)
spinButton.TextSize = 16
spinButton.Parent = seedTab

local spinCorner = Instance.new("UICorner")
spinCorner.CornerRadius = UDim.new(0.2, 0)
spinCorner.Parent = spinButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
statusLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.Font = Enum.Font.SciFi
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 14
statusLabel.Parent = seedTab

-- Seed Spinner Functionality
local selectedPack = ""
local selectedSeed = ""

local function showDropdown(options, position, callback)
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child.Name == "DropdownFrame" then
            child:Destroy()
        end
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "DropdownFrame"
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    frame.BorderSizePixel = 0
    frame.ZIndex = 5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 5
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    
    for _, option in ipairs(options) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.Text = option.text
        button.Font = Enum.Font.SciFi
        button.TextColor3 = Color3.fromRGB(200, 200, 255)
        button.TextSize = 14
        button.ZIndex = 6
        
        button.MouseButton1Click:Connect(function()
            callback(option.value, option.text)
            frame:Destroy()
        end)
        
        button.Parent = scroll
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    scroll.Parent = frame
    frame.Parent = mainFrame
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            
            if pos.X < absPos.X or pos.X > absPos.X + absSize.X or
               pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
                frame:Destroy()
                connection:Disconnect()
            end
        end
    end)
end

packDropdown.MouseButton1Click:Connect(function()
    local packOptions = {}
    for packName, _ in pairs(SeedPackData.Packs) do
        table.insert(packOptions, {text = packName, value = packName})
    end
    table.sort(packOptions, function(a, b) return a.text < b.text end)
    
    showDropdown(packOptions, UDim2.new(0.1, 0, 0.2, 0), function(value, text)
        selectedPack = value
        packDropdown.Text = text
        seedDropdown.Text = "SELECT SEED"
        selectedSeed = ""
    end)
end)

seedDropdown.MouseButton1Click:Connect(function()
    if selectedPack == "" or not SeedPackData.Packs[selectedPack] then
        statusLabel.Text = "Select a pack first!"
        task.delay(2, function() statusLabel.Text = "" end)
        return
    end
    
    local seedOptions = {}
    for _, seedData in ipairs(SeedPackData.Packs[selectedPack].Items) do
        local seedName = seedData.Name or seedData.RewardId or "Unknown"
        table.insert(seedOptions, {text = seedName, value = seedName})
    end
    
    showDropdown(seedOptions, UDim2.new(0.1, 0, 0.4, 0), function(value, text)
        selectedSeed = value
        seedDropdown.Text = text
    end)
end)

spinButton.MouseButton1Click:Connect(function()
    if selectedPack == "" or selectedSeed == "" then
        statusLabel.Text = "Select both pack and seed!"
        task.delay(2, function() statusLabel.Text = "" end)
        return
    end
    
    if not SeedPackData.Packs[selectedPack] then
        statusLabel.Text = "Invalid pack selected!"
        task.delay(2, function() statusLabel.Text = "" end)
        return
    end
    
    local items = SeedPackData.Packs[selectedPack].Items
    local index = 1
    local seedData = nil
    
    for i, item in ipairs(items) do
        if (item.Name and item.Name == selectedSeed) or (item.RewardId and item.RewardId == selectedSeed) then
            index = i
            seedData = item
            break
        end
    end
    
    if not seedData then
        statusLabel.Text = "Seed not found in pack!"
        task.delay(2, function() statusLabel.Text = "" end)
        return
    end
    
    local success, err = pcall(function()
        SeedPackController:Spin({
            seedPackType = selectedPack,
            resultIndex = index
        })
        
        statusLabel.Text = "Obtained: "..selectedSeed
        task.delay(2, function() statusLabel.Text = "" end)
    end)
    
    if not success then
        statusLabel.Text = "Error: "..tostring(err)
        task.delay(2, function() statusLabel.Text = "" end)
    end
end)

-- Plant ESP Tab
local plantTitle = Instance.new("TextLabel")
plantTitle.Size = UDim2.new(1, 0, 0.15, 0)
plantTitle.Position = UDim2.new(0, 0, 0, 0)
plantTitle.BackgroundTransparency = 1
plantTitle.Text = "PLANT ESP"
plantTitle.Font = Enum.Font.SciFi
plantTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
plantTitle.TextSize = 18
plantTitle.Parent = plantTab

local plantToggle = Instance.new("TextButton")
plantToggle.Name = "PlantToggle"
plantToggle.Size = UDim2.new(0.6, 0, 0.2, 0)
plantToggle.Position = UDim2.new(0.2, 0, 0.2, 0)
plantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
plantToggle.Text = "PLANT ESP: OFF"
plantToggle.Font = Enum.Font.SciFi
plantToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
plantToggle.TextSize = 16
plantToggle.Parent = plantTab

local plantToggleCorner = Instance.new("UICorner")
plantToggleCorner.CornerRadius = UDim.new(0.2, 0)
plantToggleCorner.Parent = plantToggle

local plantRangeLabel = Instance.new("TextLabel")
plantRangeLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
plantRangeLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
plantRangeLabel.BackgroundTransparency = 1
plantRangeLabel.Text = "Range: 50"
plantRangeLabel.Font = Enum.Font.SciFi
plantRangeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
plantRangeLabel.TextSize = 14
plantRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
plantRangeLabel.Parent = plantTab

local plantRangeSlider = Instance.new("TextButton")
plantRangeSlider.Size = UDim2.new(0.8, 0, 0.1, 0)
plantRangeSlider.Position = UDim2.new(0.1, 0, 0.55, 0)
plantRangeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
plantRangeSlider.Text = ""
plantRangeSlider.Font = Enum.Font.SciFi
plantRangeSlider.TextColor3 = Color3.fromRGB(200, 200, 255)
plantRangeSlider.TextSize = 14
plantRangeSlider.Parent = plantTab

local plantRangeSliderCorner = Instance.new("UICorner")
plantRangeSliderCorner.CornerRadius = UDim.new(0.2, 0)
plantRangeSliderCorner.Parent = plantRangeSlider

local plantRangeFill = Instance.new("Frame")
plantRangeFill.Size = UDim2.new(0.5, 0, 1, 0)
plantRangeFill.Position = UDim2.new(0, 0, 0, 0)
plantRangeFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
plantRangeFill.BorderSizePixel = 0
plantRangeFill.Parent = plantRangeSlider

local plantRangeFillCorner = Instance.new("UICorner")
plantRangeFillCorner.CornerRadius = UDim.new(0.2, 0)
plantRangeFillCorner.Parent = plantRangeFill

local plantStatusLabel = Instance.new("TextLabel")
plantStatusLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
plantStatusLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
plantStatusLabel.BackgroundTransparency = 1
plantStatusLabel.Text = ""
plantStatusLabel.Font = Enum.Font.SciFi
plantStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
plantStatusLabel.TextSize = 14
plantStatusLabel.Parent = plantTab

-- Plant ESP Functionality
local plantESPEnabled = false
local PLANT_RANGE = 50
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local PlantESPs = {}
local PlantUpdateQueue = {}

local function createPlantBillboard(model)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "esp"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.ResetOnSpawn = false
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Name = "money"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "..."
    label.Parent = billboard

    return billboard
end

local function updatePlantESP(model)
    if not plantESPEnabled then return end
    local esp = PlantESPs[model]
    if not esp or not model:IsDescendantOf(workspace) then return end
    local label = esp:FindFirstChild("money")
    if label then
        local success, value = pcall(CalculatePlantValue, model)
        if success and typeof(value) == "number" then
            label.Text = Comma.Comma(value) .. "Â¢"
        end
    end
end

local function trackPlant(model)
    if PlantESPs[model] then return end
    PlantUpdateQueue[model] = tick() + math.random()
end

local function untrackPlant(model)
    if PlantESPs[model] then
        PlantESPs[model]:Destroy()
        PlantESPs[model] = nil
    end
    PlantUpdateQueue[model] = nil
end

local function createPlantESP(model)
    if not plantESPEnabled then return end
    if PlantESPs[model] then return end
    if not model:IsDescendantOf(workspace) then return end
    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    if (part.Position - RootPart.Position).Magnitude <= PLANT_RANGE then
        local esp = createPlantBillboard(model)
        PlantESPs[model] = esp
        updatePlantESP(model)
    end
end

local function removePlantESP(model)
    local esp = PlantESPs[model]
    if esp and model:IsDescendantOf(workspace) then
        local part = model:FindFirstChildWhichIsA("BasePart")
        if part and (part.Position - RootPart.Position).Magnitude > PLANT_RANGE + 10 then
            esp:Destroy()
            PlantESPs[model] = nil
        end
    end
end

local function clearAllPlantESP()
    for model, esp in pairs(PlantESPs) do
        esp:Destroy()
        PlantESPs[model] = nil
    end
    PlantUpdateQueue = {}
end

local function scanPlants()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and CollectionService:HasTag(obj, "Harvestable") then
            trackPlant(obj)
        end
    end
end

plantToggle.MouseButton1Click:Connect(function()
    plantESPEnabled = not plantESPEnabled
    if plantESPEnabled then
        plantToggle.Text = "PLANT ESP: ON"
        plantToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        plantStatusLabel.Text = "Plant ESP enabled!"
        scanPlants()
    else
        plantToggle.Text = "PLANT ESP: OFF"
        plantToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        plantStatusLabel.Text = "Plant ESP disabled!"
        clearAllPlantESP()
    end
    task.delay(2, function() plantStatusLabel.Text = "" end)
end)

-- Plant Range Slider
local plantSliderDragging = false
plantRangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        plantSliderDragging = true
    end
end)

plantRangeSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        plantSliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if plantSliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local sliderPos = plantRangeSlider.AbsolutePosition.X
        local sliderSize = plantRangeSlider.AbsoluteSize.X
        local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        PLANT_RANGE = math.floor(10 + relativePos * 190) -- Range from 10 to 200
        plantRangeFill.Size = UDim2.new(relativePos, 0, 1, 0)
        plantRangeLabel.Text = "Range: "..PLANT_RANGE
        
        if plantESPEnabled then
            clearAllPlantESP()
            scanPlants()
        end
    end
end)

-- Egg ESP Tab
local eggTitle = Instance.new("TextLabel")
eggTitle.Size = UDim2.new(1, 0, 0.15, 0)
eggTitle.Position = UDim2.new(0, 0, 0, 0)
eggTitle.BackgroundTransparency = 1
eggTitle.Text = "EGG ESP"
eggTitle.Font = Enum.Font.SciFi
eggTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
eggTitle.TextSize = 18
eggTitle.Parent = eggTab

local eggToggle = Instance.new("TextButton")
eggToggle.Name = "EggToggle"
eggToggle.Size = UDim2.new(0.6, 0, 0.2, 0)
eggToggle.Position = UDim2.new(0.2, 0, 0.2, 0)
eggToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
eggToggle.Text = "EGG ESP: OFF"
eggToggle.Font = Enum.Font.SciFi
eggToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
eggToggle.TextSize = 16
eggToggle.Parent = eggTab

local eggToggleCorner = Instance.new("UICorner")
eggToggleCorner.CornerRadius = UDim.new(0.2, 0)
eggToggleCorner.Parent = eggToggle

local eggStatusLabel = Instance.new("TextLabel")
eggStatusLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
eggStatusLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
eggStatusLabel.BackgroundTransparency = 1
eggStatusLabel.Text = ""
eggStatusLabel.Font = Enum.Font.SciFi
eggStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
eggStatusLabel.TextSize = 14
eggStatusLabel.Parent = eggTab

-- Egg ESP Functionality
local eggESPEnabled = false
local espCache = {}
local activeEggs = {}
local currentCamera = workspace.CurrentCamera
local eggModels = {}
local eggPets = {}

local function setupEggData()
    if not ReplicatedStorage:FindFirstChild("GameEvents") then return false end
    if not ReplicatedStorage.GameEvents:FindFirstChild("PetEggService") then return false end
    
    local connections = getconnections(ReplicatedStorage.GameEvents.PetEggService.OnClientEvent)
    if #connections == 0 then return false end
    
    local hatchFunction = getupvalue(getupvalue(connections[1].Function, 1), 2)
    if not hatchFunction then return false end
    
    eggModels = getupvalue(hatchFunction, 1)
    eggPets = getupvalue(hatchFunction, 2)
    
    return true
end

local function getObjectFromId(objectId)
    for _, eggModel in pairs(eggModels) do
        if eggModel:GetAttribute("OBJECT_UUID") ~= objectId then continue end
        return eggModel
    end
end

local function updateEsp(objectId, petName)
    local object = getObjectFromId(objectId)
    if not object or not espCache[objectId] then return end

    local eggName = object:GetAttribute("EggName")
    espCache[objectId].Text = string.format("%s | %s", eggName, petName)
end

local function addEsp(object)
    if not eggESPEnabled or not object:IsA("Model") then return end
    if object:GetAttribute("OWNER") ~= LocalPlayer.Name then return end

    local objectId = object:GetAttribute("OBJECT_UUID")
    if not objectId then return end

    local eggName = object:GetAttribute("EggName")
    local petName = eggPets[objectId] or "?"

    local label = Drawing.new("Text")
    label.Text = string.format("%s | %s", eggName, petName)
    label.Size = 18
    label.Color = Color3.new(1, 1, 1)
    label.Outline = true
    label.OutlineColor = Color3.new(0, 0, 0)
    label.Center = true
    label.Visible = false

    espCache[objectId] = label
    activeEggs[objectId] = object
end

local function removeEsp(object)
    if not object:IsA("Model") then return end
    local objectId = object:GetAttribute("OBJECT_UUID")
    if not objectId then return end

    if espCache[objectId] then
        espCache[objectId]:Remove()
        espCache[objectId] = nil
    end

    activeEggs[objectId] = nil
end

local function updateAllEsp()
    if not eggESPEnabled then return end
    
    for objectId, object in pairs(activeEggs) do
        if not object or not object:IsDescendantOf(workspace) then
            activeEggs[objectId] = nil
            if espCache[objectId] then
                espCache[objectId].Visible = false
            end
            continue
        end

        local label = espCache[objectId]
        if label then
            local pos, onScreen = currentCamera:WorldToViewportPoint(object:GetPivot().Position)
            if onScreen then
                label.Position = Vector2.new(pos.X, pos.Y)
                label.Visible = true
            else
                label.Visible = false
            end
        end
    end
end

local function clearAllEggESP()
    for objectId, label in pairs(espCache) do
        label:Remove()
    end
    espCache = {}
    activeEggs = {}
end

local function scanEggs()
    for _, object in pairs(CollectionService:GetTagged("PetEggServer")) do
        addEsp(object)
    end
end

eggToggle.MouseButton1Click:Connect(function()
    eggESPEnabled = not eggESPEnabled
    if eggESPEnabled then
        if setupEggData() then
            eggToggle.Text = "EGG ESP: ON"
            eggToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
            eggStatusLabel.Text = "Egg ESP enabled!"
            scanEggs()
        else
            eggESPEnabled = false
            eggToggle.Text = "EGG ESP: FAILED"
            eggToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
            eggStatusLabel.Text = "Failed to load pet data"
            task.delay(2, function()
                eggToggle.Text = "EGG ESP: OFF"
                eggStatusLabel.Text = ""
            end)
        end
    else
        eggToggle.Text = "EGG ESP: OFF"
        eggToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        eggStatusLabel.Text = "Egg ESP disabled!"
        clearAllEggESP()
        task.delay(2, function() eggStatusLabel.Text = "" end)
    end
end)

-- Hook the egg ready event
local function hookEggReadyEvent()
    if not ReplicatedStorage:FindFirstChild("GameEvents") then return end
    if not ReplicatedStorage.GameEvents:FindFirstChild("EggReadyToHatch_RE") then return end
    
    local connections = getconnections(ReplicatedStorage.GameEvents.EggReadyToHatch_RE.OnClientEvent)
    if #connections == 0 then return end
    
    local oldFunction = connections[1].Function
    local newFunction = newcclosure(function(objectId, petName)
        updateEsp(objectId, petName)
        return oldFunction(objectId, petName)
    end)
    
    hookfunction(oldFunction, newFunction)
end

hookEggReadyEvent()

-- Dupe Tab
local dupeTitle = Instance.new("TextLabel")
dupeTitle.Size = UDim2.new(1, 0, 0.15, 0)
dupeTitle.Position = UDim2.new(0, 0, 0, 0)
dupeTitle.BackgroundTransparency = 1
dupeTitle.Text = "PET DUPLICATOR"
dupeTitle.Font = Enum.Font.SciFi
dupeTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
dupeTitle.TextSize = 18
dupeTitle.Parent = dupeTab

local dupeButton = Instance.new("TextButton")
dupeButton.Name = "DupeButton"
dupeButton.Size = UDim2.new(0.6, 0, 0.2, 0)
dupeButton.Position = UDim2.new(0.2, 0, 0.3, 0)
dupeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
dupeButton.Text = "DUPLICATE PET"
dupeButton.Font = Enum.Font.SciFi
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.TextSize = 16
dupeButton.Parent = dupeTab

local dupeStatusLabel = Instance.new("TextLabel")
dupeStatusLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
dupeStatusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
dupeStatusLabel.BackgroundTransparency = 1
dupeStatusLabel.Text = ""
dupeStatusLabel.Font = Enum.Font.SciFi
dupeStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
dupeStatusLabel.TextSize = 14
dupeStatusLabel.Parent = dupeTab

-- Dupe Functions
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local backpack = LocalPlayer:WaitForChild("Backpack")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
end)

local function getTool()
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    return nil
end

local function duplicatePet()
    local tool = getTool()
    if not tool then 
        dupeStatusLabel.Text = "No pet tool found!"
        task.delay(2, function() dupeStatusLabel.Text = "" end)
        return false 
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local visual = tool:Clone()
        visual.Parent = workspace
        
        if visual:IsA("Tool") and visual:FindFirstChild("Handle") then
            visual.Handle.CFrame = root.CFrame * CFrame.new(3, 0, 0)
        elseif visual:IsA("Model") then
            local part = visual:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CFrame = root.CFrame * CFrame.new(3, 0, 0)
            end
        end
        
        game:GetService("Debris"):AddItem(visual, 2)
    end

    local clone = tool:Clone()
    clone.Parent = backpack
    
    dupeStatusLabel.Text = "Successfully duplicated pet!"
    task.delay(2, function() dupeStatusLabel.Text = "" end)
    return true
end

dupeButton.MouseButton1Click:Connect(duplicatePet)

-- CollectionService events
CollectionService:GetInstanceAddedSignal("Harvestable"):Connect(function(obj)
    if obj:IsA("Model") and plantESPEnabled then
        trackPlant(obj)
    end
end)

CollectionService:GetInstanceRemovedSignal("Harvestable"):Connect(function(obj)
    if obj:IsA("Model") then
        untrackPlant(obj)
    end
end)

CollectionService:GetInstanceAddedSignal("PetEggServer"):Connect(function(obj)
    if eggESPEnabled then
        addEsp(obj)
    end
end)

CollectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(function(obj)
    removeEsp(obj)
end)

-- Character handling
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Plant ESP update loop
task.spawn(function()
    while true do
        if plantESPEnabled then
            local now = tick()
            for model, _ in pairs(PlantUpdateQueue) do
                if not model:IsDescendantOf(workspace) then
                    untrackPlant(model)
                else
                    createPlantESP(model)
                    removePlantESP(model)
                    if PlantESPs[model] and now >= PlantUpdateQueue[model] then
                        updatePlantESP(model)
                        PlantUpdateQueue[model] = now + 3 + math.random()
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Egg ESP update loop
RunService.PreRender:Connect(updateAllEsp)

-- Final parenting
toggleButton.Parent = gui
mainFrame.Parent = gui
