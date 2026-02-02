-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ZyrtecHub"
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

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.05, 0)
corner.Parent = mainFrame

-- Border effect
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(0, 150, 255)
border.Thickness = 2
border.Transparency = 0.7
border.Parent = mainFrame

-- GUI State
local guiVisible = true

-- Toggle Functionality
toggleButton.MouseButton1Click:Connect(function()
    if guiVisible then
        local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.4), {Position = UDim2.new(1.5, 0, 0.5, 0)})
        tweenOut:Play()
        toggleButton.Text = "≡"
    else
        mainFrame.Visible = true
        local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.4), {Position = UDim2.new(0.5, 0, 0.5, 0)})
        tweenIn:Play()
        toggleButton.Text = "☰"
    end
    guiVisible = not guiVisible
end)

-- Tab System
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Size = UDim2.new(1, 0, 0.1, 0)
tabButtonsFrame.Position = UDim2.new(0, 0, 0.12, 0)
tabButtonsFrame.BackgroundTransparency = 1
tabButtonsFrame.Parent = mainFrame

local tabButtonsLayout = Instance.new("UIListLayout")
tabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
tabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabButtonsLayout.Padding = UDim.new(0.02, 0)
tabButtonsLayout.Parent = tabButtonsFrame

-- Tab content frame
local tabContentFrame = Instance.new("Frame")
tabContentFrame.Size = UDim2.new(1, 0, 0.78, 0)
tabContentFrame.Position = UDim2.new(0, 0, 0.22, 0)
tabContentFrame.BackgroundTransparency = 1
tabContentFrame.ClipsDescendants = true
tabContentFrame.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.12, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ZYRTEC HUB - COMBAT"
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 18
title.Parent = mainFrame

-- Tabs
local tabs = {
    Main = {
        Name = "🔥 Main",
        Color = Color3.fromRGB(255, 100, 100),
        Content = {}
    },
    Config = {
        Name = "⚙️ Config",
        Color = Color3.fromRGB(0, 150, 255),
        Content = {}
    }
}

local currentTab = "Main"
local tabButtons = {}

-- Create tab buttons
for tabName, tabInfo in pairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.4, 0, 0.9, 0)
    tabButton.BackgroundColor3 = tabInfo.Color
    tabButton.BackgroundTransparency = 0.5
    tabButton.Text = tabInfo.Name
    tabButton.Font = Enum.Font.SciFi
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextSize = 13
    tabButton.AutoButtonColor = false
    tabButton.Parent = tabButtonsFrame
    
    local tabButtonCorner = Instance.new("UICorner")
    tabButtonCorner.CornerRadius = UDim.new(0.2, 0)
    tabButtonCorner.Parent = tabButton
    
    -- Highlight current tab
    if tabName == currentTab then
        tabButton.BackgroundTransparency = 0.2
    else
        tabButton.BackgroundTransparency = 0.7
    end
    
    tabButton.MouseButton1Click:Connect(function()
        if currentTab ~= tabName then
            -- Hide current tab
            if tabs[currentTab].Content.Container then
                tabs[currentTab].Content.Container.Visible = false
            end
            
            -- Update tab button transparency
            tabButtons[currentTab].BackgroundTransparency = 0.7
            tabButton.BackgroundTransparency = 0.2
            
            -- Show new tab
            currentTab = tabName
            if tabs[tabName].Content.Container then
                tabs[tabName].Content.Container.Visible = true
            end
        end
    end)
    
    tabButtons[tabName] = tabButton
end

-- Create Main Tab Content
local mainTabContainer = Instance.new("Frame")
mainTabContainer.Size = UDim2.new(1, 0, 1, 0)
mainTabContainer.BackgroundTransparency = 1
mainTabContainer.Visible = currentTab == "Main"
mainTabContainer.Parent = tabContentFrame

tabs.Main.Content.Container = mainTabContainer

-- Main Tab Title
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(0.8, 0, 0.08, 0)
mainTitle.Position = UDim2.new(0.1, 0, 0.02, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "🎯 TARGET SELECTION"
mainTitle.Font = Enum.Font.SciFi
mainTitle.TextColor3 = Color3.fromRGB(255, 150, 100)
mainTitle.TextSize = 14
mainTitle.Parent = mainTabContainer

-- Boss Dropdown
local bossDropdown = Instance.new("TextButton")
bossDropdown.Name = "BossDropdown"
bossDropdown.Size = UDim2.new(0.8, 0, 0.1, 0)
bossDropdown.Position = UDim2.new(0.1, 0, 0.11, 0)
bossDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
bossDropdown.Text = "Select Boss (Priority)"
bossDropdown.Font = Enum.Font.SciFi
bossDropdown.TextColor3 = Color3.fromRGB(200, 200, 255)
bossDropdown.TextSize = 12
bossDropdown.Parent = mainTabContainer

local bossCorner = Instance.new("UICorner")
bossCorner.CornerRadius = UDim.new(0.1, 0)
bossCorner.Parent = bossDropdown

-- Mob Dropdown
local mobDropdown = Instance.new("TextButton")
mobDropdown.Name = "MobDropdown"
mobDropdown.Size = UDim2.new(0.8, 0, 0.1, 0)
mobDropdown.Position = UDim2.new(0.1, 0, 0.22, 0)
mobDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
mobDropdown.Text = "Select Mob (Farm)"
mobDropdown.Font = Enum.Font.SciFi
mobDropdown.TextColor3 = Color3.fromRGB(200, 200, 255)
mobDropdown.TextSize = 12
mobDropdown.Parent = mainTabContainer

local mobCorner = Instance.new("UICorner")
mobCorner.CornerRadius = UDim.new(0.1, 0)
mobCorner.Parent = mobDropdown

-- Refresh Button
local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0.8, 0, 0.08, 0)
refreshButton.Position = UDim2.new(0.1, 0, 0.34, 0)
refreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
refreshButton.Text = "🔄 Refresh Enemy Lists"
refreshButton.Font = Enum.Font.SciFi
refreshButton.TextColor3 = Color3.fromRGB(200, 200, 255)
refreshButton.TextSize = 12
refreshButton.Parent = mainTabContainer

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0.1, 0)
refreshCorner.Parent = refreshButton

-- Combat Section Title
local combatTitle = Instance.new("TextLabel")
combatTitle.Size = UDim2.new(0.8, 0, 0.08, 0)
combatTitle.Position = UDim2.new(0.1, 0, 0.44, 0)
combatTitle.BackgroundTransparency = 1
combatTitle.Text = "⚔️ COMBAT & EXECUTION"
combatTitle.Font = Enum.Font.SciFi
combatTitle.TextColor3 = Color3.fromRGB(255, 150, 100)
combatTitle.TextSize = 14
combatTitle.Parent = mainTabContainer

-- Hotkey Info
local hotkeyInfo = Instance.new("TextLabel")
hotkeyInfo.Size = UDim2.new(0.8, 0, 0.08, 0)
hotkeyInfo.Position = UDim2.new(0.1, 0, 0.53, 0)
hotkeyInfo.BackgroundTransparency = 1
hotkeyInfo.Text = "Hotkey: [Right Control] to RUN/STOP"
hotkeyInfo.Font = Enum.Font.SciFi
hotkeyInfo.TextColor3 = Color3.fromRGB(150, 200, 255)
hotkeyInfo.TextSize = 11
hotkeyInfo.Parent = mainTabContainer

-- Auto Farm Toggle
local farmToggle = Instance.new("TextButton")
farmToggle.Name = "FarmToggle"
farmToggle.Size = UDim2.new(0.8, 0, 0.08, 0)
farmToggle.Position = UDim2.new(0.1, 0, 0.62, 0)
farmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
farmToggle.Text = "ENABLE AUTO-FARM: OFF"
farmToggle.Font = Enum.Font.SciFi
farmToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
farmToggle.TextSize = 12
farmToggle.Parent = mainTabContainer

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0.1, 0)
farmCorner.Parent = farmToggle

-- Auto Click Toggle
local clickToggle = Instance.new("TextButton")
clickToggle.Name = "ClickToggle"
clickToggle.Size = UDim2.new(0.8, 0, 0.08, 0)
clickToggle.Position = UDim2.new(0.1, 0, 0.71, 0)
clickToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
clickToggle.Text = "Auto Left-Click: OFF"
clickToggle.Font = Enum.Font.SciFi
clickToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
clickToggle.TextSize = 12
clickToggle.Parent = mainTabContainer

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0.1, 0)
clickCorner.Parent = clickToggle

-- Skill 1 Toggle
local skill1Toggle = Instance.new("TextButton")
skill1Toggle.Name = "Skill1Toggle"
skill1Toggle.Size = UDim2.new(0.8, 0, 0.08, 0)
skill1Toggle.Position = UDim2.new(0.1, 0, 0.8, 0)
skill1Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
skill1Toggle.Text = "Spam Skill [1]: OFF"
skill1Toggle.Font = Enum.Font.SciFi
skill1Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
skill1Toggle.TextSize = 12
skill1Toggle.Parent = mainTabContainer

local skill1Corner = Instance.new("UICorner")
skill1Corner.CornerRadius = UDim.new(0.1, 0)
skill1Corner.Parent = skill1Toggle

-- Skill 2 Toggle
local skill2Toggle = Instance.new("TextButton")
skill2Toggle.Name = "Skill2Toggle"
skill2Toggle.Size = UDim2.new(0.8, 0, 0.08, 0)
skill2Toggle.Position = UDim2.new(0.1, 0, 0.89, 0)
skill2Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
skill2Toggle.Text = "Spam Skill [2]: OFF"
skill2Toggle.Font = Enum.Font.SciFi
skill2Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
skill2Toggle.TextSize = 12
skill2Toggle.Parent = mainTabContainer

local skill2Corner = Instance.new("UICorner")
skill2Corner.CornerRadius = UDim.new(0.1, 0)
skill2Corner.Parent = skill2Toggle

-- Create Config Tab Content
local configTabContainer = Instance.new("Frame")
configTabContainer.Size = UDim2.new(1, 0, 1, 0)
configTabContainer.BackgroundTransparency = 1
configTabContainer.Visible = currentTab == "Config"
configTabContainer.Parent = tabContentFrame

tabs.Config.Content.Container = configTabContainer

-- Config Tab Title
local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(0.8, 0, 0.08, 0)
configTitle.Position = UDim2.new(0.1, 0, 0.02, 0)
configTitle.BackgroundTransparency = 1
configTitle.Text = "⚙️ CONFIGURATION"
configTitle.Font = Enum.Font.SciFi
configTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
configTitle.TextSize = 14
configTitle.Parent = configTabContainer

-- Speeds Section Title
local speedsTitle = Instance.new("TextLabel")
speedsTitle.Size = UDim2.new(0.8, 0, 0.06, 0)
speedsTitle.Position = UDim2.new(0.1, 0, 0.11, 0)
speedsTitle.BackgroundTransparency = 1
speedsTitle.Text = "Speeds"
speedsTitle.Font = Enum.Font.SciFi
speedsTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
speedsTitle.TextSize = 13
speedsTitle.Parent = configTabContainer

-- Click Speed Slider
local clickSpeedLabel = Instance.new("TextLabel")
clickSpeedLabel.Size = UDim2.new(0.8, 0, 0.06, 0)
clickSpeedLabel.Position = UDim2.new(0.1, 0, 0.18, 0)
clickSpeedLabel.BackgroundTransparency = 1
clickSpeedLabel.Text = "Click Speed: 0.1s"
clickSpeedLabel.Font = Enum.Font.SciFi
clickSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
clickSpeedLabel.TextSize = 12
clickSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
clickSpeedLabel.Parent = configTabContainer

-- Click Speed Slider Bar
local speedSliderBar = Instance.new("Frame")
speedSliderBar.Size = UDim2.new(0.8, 0, 0.02, 0)
speedSliderBar.Position = UDim2.new(0.1, 0, 0.25, 0)
speedSliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedSliderBar.Parent = configTabContainer

local speedSliderFill = Instance.new("Frame")
speedSliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- 50% default (0.1s)
speedSliderFill.Position = UDim2.new(0, 0, 0, 0)
speedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
speedSliderFill.Parent = speedSliderBar

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(1, 0)
speedSliderCorner.Parent = speedSliderBar

-- Slider buttons
local speedSliderContainer = Instance.new("Frame")
speedSliderContainer.Size = UDim2.new(0.8, 0, 0.06, 0)
speedSliderContainer.Position = UDim2.new(0.1, 0, 0.28, 0)
speedSliderContainer.BackgroundTransparency = 1
speedSliderContainer.Parent = configTabContainer

local speedMinusBtn = Instance.new("TextButton")
speedMinusBtn.Size = UDim2.new(0.1, 0, 1, 0)
speedMinusBtn.Position = UDim2.new(0, 0, 0, 0)
speedMinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedMinusBtn.Text = "-"
speedMinusBtn.Font = Enum.Font.SciFi
speedMinusBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
speedMinusBtn.TextSize = 18
speedMinusBtn.Parent = speedSliderContainer

local speedMinusCorner = Instance.new("UICorner")
speedMinusCorner.CornerRadius = UDim.new(0.2, 0)
speedMinusCorner.Parent = speedMinusBtn

local speedDisplay = Instance.new("TextLabel")
speedDisplay.Size = UDim2.new(0.6, 0, 1, 0)
speedDisplay.Position = UDim2.new(0.2, 0, 0, 0)
speedDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedDisplay.Text = "0.1s"
speedDisplay.Font = Enum.Font.SciFi
speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDisplay.TextSize = 13
speedDisplay.Parent = speedSliderContainer

local speedDisplayCorner = Instance.new("UICorner")
speedDisplayCorner.CornerRadius = UDim.new(0.2, 0)
speedDisplayCorner.Parent = speedDisplay

local speedPlusBtn = Instance.new("TextButton")
speedPlusBtn.Size = UDim2.new(0.1, 0, 1, 0)
speedPlusBtn.Position = UDim2.new(0.9, 0, 0, 0)
speedPlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedPlusBtn.Text = "+"
speedPlusBtn.Font = Enum.Font.SciFi
speedPlusBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
speedPlusBtn.TextSize = 18
speedPlusBtn.Parent = speedSliderContainer

local speedPlusCorner = Instance.new("UICorner")
speedPlusCorner.CornerRadius = UDim.new(0.2, 0)
speedPlusCorner.Parent = speedPlusBtn

-- Safety Section Title
local safetyTitle = Instance.new("TextLabel")
safetyTitle.Size = UDim2.new(0.8, 0, 0.06, 0)
safetyTitle.Position = UDim2.new(0.1, 0, 0.36, 0)
safetyTitle.BackgroundTransparency = 1
safetyTitle.Text = "Safety & System"
safetyTitle.Font = Enum.Font.SciFi
safetyTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
safetyTitle.TextSize = 13
safetyTitle.Parent = configTabContainer

-- Noclip Toggle
local noclipToggle = Instance.new("TextButton")
noclipToggle.Size = UDim2.new(0.8, 0, 0.08, 0)
noclipToggle.Position = UDim2.new(0.1, 0, 0.43, 0)
noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
noclipToggle.Text = "Noclip: ON"
noclipToggle.Font = Enum.Font.SciFi
noclipToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
noclipToggle.TextSize = 12
noclipToggle.Parent = configTabContainer

local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0.1, 0)
noclipCorner.Parent = noclipToggle

-- Destroy Script Button
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(0.8, 0, 0.08, 0)
destroyButton.Position = UDim2.new(0.1, 0, 0.85, 0)
destroyButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
destroyButton.Text = "❌ Destroy Script"
destroyButton.Font = Enum.Font.SciFi
destroyButton.TextColor3 = Color3.fromRGB(255, 150, 150)
destroyButton.TextSize = 12
destroyButton.Parent = configTabContainer

local destroyCorner = Instance.new("UICorner")
destroyCorner.CornerRadius = UDim.new(0.1, 0)
destroyCorner.Parent = destroyButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0.08, 0)
statusLabel.Position = UDim2.new(0.1, 0, 0.86, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.Font = Enum.Font.SciFi
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Final parenting
toggleButton.Parent = gui
mainFrame.Parent = gui

-- States
local Config = {
    FarmStatus = false,
    Skill1 = false,
    Skill2 = false,
    AutoClick = false,
    ClickSpeed = 0.1,
    BossName = "",
    MobName = "",
    Distance = 5,
    Height = 2,
    Noclip = true
}

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Get enemy list
local enemyFolder = workspace:WaitForChild("Enemies")

local function getUniqueEnemies()
    local names = {}
    local seen = {}
    for _, v in pairs(enemyFolder:GetChildren()) do
        if not seen[v.Name] then
            table.insert(names, v.Name)
            seen[v.Name] = true
        end
    end
    return names
end

-- Dropdown lists
local bossDropdownList = Instance.new("ScrollingFrame")
bossDropdownList.Size = UDim2.new(0.8, 0, 0.3, 0)
bossDropdownList.Position = UDim2.new(0.1, 0, 0.21, 0)
bossDropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
bossDropdownList.BorderSizePixel = 0
bossDropdownList.Visible = false
bossDropdownList.ScrollBarThickness = 4
bossDropdownList.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
bossDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bossDropdownList.Parent = mainTabContainer

local bossListLayout = Instance.new("UIListLayout")
bossListLayout.Padding = UDim.new(0, 2)
bossListLayout.SortOrder = Enum.SortOrder.LayoutOrder
bossListLayout.Parent = bossDropdownList

local bossListCorner = Instance.new("UICorner")
bossListCorner.CornerRadius = UDim.new(0.1, 0)
bossListCorner.Parent = bossDropdownList

local mobDropdownList = Instance.new("ScrollingFrame")
mobDropdownList.Size = UDim2.new(0.8, 0, 0.3, 0)
mobDropdownList.Position = UDim2.new(0.1, 0, 0.32, 0)
mobDropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
mobDropdownList.BorderSizePixel = 0
mobDropdownList.Visible = false
mobDropdownList.ScrollBarThickness = 4
mobDropdownList.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
mobDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
mobDropdownList.Parent = mainTabContainer

local mobListLayout = Instance.new("UIListLayout")
mobListLayout.Padding = UDim.new(0, 2)
mobListLayout.SortOrder = Enum.SortOrder.LayoutOrder
mobListLayout.Parent = mobDropdownList

local mobListCorner = Instance.new("UICorner")
mobListCorner.CornerRadius = UDim.new(0.1, 0)
mobListCorner.Parent = mobDropdownList

-- Create dropdown items
local function createDropdownItems(listFrame, dropdownButton, callback)
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local enemies = getUniqueEnemies()
    
    for _, enemyName in ipairs(enemies) do
        local enemyBtn = Instance.new("TextButton")
        enemyBtn.Size = UDim2.new(1, 0, 0, 25)
        enemyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        enemyBtn.BackgroundTransparency = 0.5
        enemyBtn.Text = enemyName
        enemyBtn.Font = Enum.Font.SciFi
        enemyBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        enemyBtn.TextSize = 11
        enemyBtn.Parent = listFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0.1, 0)
        btnCorner.Parent = enemyBtn
        
        enemyBtn.MouseEnter:Connect(function()
            TweenService:Create(enemyBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            }):Play()
        end)
        
        enemyBtn.MouseLeave:Connect(function()
            TweenService:Create(enemyBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            }):Play()
        end)
        
        enemyBtn.MouseButton1Click:Connect(function()
            dropdownButton.Text = enemyName
            listFrame.Visible = false
            callback(enemyName)
            
            statusLabel.Text = "Selected: " .. enemyName
            statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            
            task.spawn(function()
                task.wait(2)
                if statusLabel.Text == "Selected: " .. enemyName then
                    statusLabel.Text = ""
                end
            end)
        end)
    end
end

-- Toggle dropdown visibility
bossDropdown.MouseButton1Click:Connect(function()
    if not bossDropdownList.Visible then
        createDropdownItems(bossDropdownList, bossDropdown, function(name)
            Config.BossName = name
        end)
    end
    mobDropdownList.Visible = false
    bossDropdownList.Visible = not bossDropdownList.Visible
end)

mobDropdown.MouseButton1Click:Connect(function()
    if not mobDropdownList.Visible then
        createDropdownItems(mobDropdownList, mobDropdown, function(name)
            Config.MobName = name
        end)
    end
    bossDropdownList.Visible = false
    mobDropdownList.Visible = not mobDropdownList.Visible
end)

-- Close dropdown when clicking outside
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        
        local bossAbsPos = bossDropdownList.AbsolutePosition
        local bossSize = bossDropdownList.AbsoluteSize
        local mobAbsPos = mobDropdownList.AbsolutePosition
        local mobSize = mobDropdownList.AbsoluteSize
        
        if bossDropdownList.Visible and 
           (mousePos.X < bossAbsPos.X or 
            mousePos.X > bossAbsPos.X + bossSize.X or 
            mousePos.Y < bossAbsPos.Y or 
            mousePos.Y > bossAbsPos.Y + bossSize.Y) then
            bossDropdownList.Visible = false
        end
        
        if mobDropdownList.Visible and 
           (mousePos.X < mobAbsPos.X or 
            mousePos.X > mobAbsPos.X + mobSize.X or 
            mousePos.Y < mobAbsPos.Y or 
            mousePos.Y > mobAbsPos.Y + mobSize.Y) then
            mobDropdownList.Visible = false
        end
    end
end)

-- Refresh button
refreshButton.MouseButton1Click:Connect(function()
    bossDropdownList.Visible = false
    mobDropdownList.Visible = false
    
    createDropdownItems(bossDropdownList, bossDropdown, function(name)
        Config.BossName = name
    end)
    
    createDropdownItems(mobDropdownList, mobDropdown, function(name)
        Config.MobName = name
    end)
    
    statusLabel.Text = "Enemy lists refreshed"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text == "Enemy lists refreshed" then
            statusLabel.Text = ""
        end
    end)
end)

-- Toggle button functionality
local function updateToggleButton(button, isOn, textPrefix)
    if isOn then
        button.Text = textPrefix .. ": ON"
        button.TextColor3 = Color3.fromRGB(100, 255, 100)
        button.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        button.Text = textPrefix .. ": OFF"
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

-- Farm toggle
farmToggle.MouseButton1Click:Connect(function()
    Config.FarmStatus = not Config.FarmStatus
    updateToggleButton(farmToggle, Config.FarmStatus, "ENABLE AUTO-FARM")
    
    if Config.FarmStatus then
        statusLabel.Text = "Auto-Farm enabled"
    else
        statusLabel.Text = "Auto-Farm disabled"
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Auto-Farm") then
            statusLabel.Text = ""
        end
    end)
end)

-- Click toggle
clickToggle.MouseButton1Click:Connect(function()
    Config.AutoClick = not Config.AutoClick
    updateToggleButton(clickToggle, Config.AutoClick, "Auto Left-Click")
    
    if Config.AutoClick then
        statusLabel.Text = "Auto-Click enabled"
    else
        statusLabel.Text = "Auto-Click disabled"
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Auto-Click") then
            statusLabel.Text = ""
        end
    end)
end)

-- Skill toggles
skill1Toggle.MouseButton1Click:Connect(function()
    Config.Skill1 = not Config.Skill1
    updateToggleButton(skill1Toggle, Config.Skill1, "Spam Skill [1]")
    
    if Config.Skill1 then
        statusLabel.Text = "Skill [1] enabled"
    else
        statusLabel.Text = "Skill [1] disabled"
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Skill") then
            statusLabel.Text = ""
        end
    end)
end)

skill2Toggle.MouseButton1Click:Connect(function()
    Config.Skill2 = not Config.Skill2
    updateToggleButton(skill2Toggle, Config.Skill2, "Spam Skill [2]")
    
    if Config.Skill2 then
        statusLabel.Text = "Skill [2] enabled"
    else
        statusLabel.Text = "Skill [2] disabled"
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Skill") then
            statusLabel.Text = ""
        end
    end)
end)

-- Noclip toggle
noclipToggle.MouseButton1Click:Connect(function()
    Config.Noclip = not Config.Noclip
    updateToggleButton(noclipToggle, Config.Noclip, "Noclip")
end)

-- Speed slider functionality
local function updateSpeedDisplay(value)
    Config.ClickSpeed = math.clamp(value, 0.05, 1)
    local percentage = (Config.ClickSpeed - 0.05) / 0.95 -- 0.05 to 1 range
    speedSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    speedDisplay.Text = string.format("%.2fs", Config.ClickSpeed)
    clickSpeedLabel.Text = "Click Speed: " .. string.format("%.2fs", Config.ClickSpeed)
end

speedMinusBtn.MouseButton1Click:Connect(function()
    local newSpeed = Config.ClickSpeed - 0.05
    if newSpeed < 0.05 then newSpeed = 0.05 end
    updateSpeedDisplay(newSpeed)
end)

speedPlusBtn.MouseButton1Click:Connect(function()
    local newSpeed = Config.ClickSpeed + 0.05
    if newSpeed > 1 then newSpeed = 1 end
    updateSpeedDisplay(newSpeed)
end)

-- Button hover effects
local function setupButtonEffects(button)
    button.MouseEnter:Connect(function()
        if button.Text:find(": ON") then
            return
        end
        
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if button.Text:find(": ON") then
            if button == farmToggle and Config.FarmStatus then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            elseif button == clickToggle and Config.AutoClick then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            elseif (button == skill1Toggle and Config.Skill1) or (button == skill2Toggle and Config.Skill2) then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            elseif button == noclipToggle and Config.Noclip then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            end
        else
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            }):Play()
        end
    end)
end

-- Apply hover effects
local allButtons = {
    farmToggle, clickToggle, skill1Toggle, skill2Toggle, 
    bossDropdown, mobDropdown, refreshButton, noclipToggle, destroyButton,
    speedMinusBtn, speedPlusBtn
}

for _, button in ipairs(allButtons) do
    setupButtonEffects(button)
end

-- Destroy button
destroyButton.MouseButton1Click:Connect(function()
    Config.FarmStatus = false
    Config.AutoClick = false
    gui:Destroy()
    
    -- Show notification before destroying
    local notification = Instance.new("ScreenGui")
    notification.Name = "DestroyNotification"
    notification.Parent = game.Players.LocalPlayer.PlayerGui
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
    notificationFrame.Position = UDim2.new(0.35, 0, 0.45, 0)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.Parent = notification
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0.1, 0)
    notifCorner.Parent = notificationFrame
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(255, 100, 100)
    notifStroke.Thickness = 2
    notifStroke.Parent = notificationFrame
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, 0, 1, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = "Script Destroyed"
    notifText.Font = Enum.Font.SciFi
    notifText.TextColor3 = Color3.fromRGB(255, 100, 100)
    notifText.TextSize = 16
    notifText.Parent = notificationFrame
    
    task.wait(1.5)
    notification:Destroy()
end)

-- KEYBIND LOGIC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        Config.AutoClick = not Config.AutoClick
        updateToggleButton(clickToggle, Config.AutoClick, "Auto Left-Click")
        
        local stateText = Config.AutoClick and "RUNNING" or "STOPPED"
        statusLabel.Text = "Auto-Clicker " .. stateText .. " (RightControl)"
        statusLabel.TextColor3 = Config.AutoClick and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
        
        task.spawn(function()
            task.wait(2)
            if statusLabel.Text:find("RightControl") then
                statusLabel.Text = ""
            end
        end)
    end
    
    -- T key to toggle GUI
    if input.KeyCode == Enum.KeyCode.T then
        if guiVisible then
            local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.4), {Position = UDim2.new(1.5, 0, 0.5, 0)})
            tweenOut:Play()
            toggleButton.Text = "≡"
            guiVisible = false
        else
            mainFrame.Visible = true
            local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.4), {Position = UDim2.new(0.5, 0, 0.5, 0)})
            tweenIn:Play()
            toggleButton.Text = "☰"
            guiVisible = true
        end
    end
end)

--- CORE LOGIC ---

function getTarget()
    local boss, nearestMob = nil, nil
    local minMobDist = math.huge
    for _, enemy in pairs(enemyFolder:GetChildren()) do
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if root and (not hum or hum.Health > 0) then
            if Config.BossName ~= "" and enemy.Name == Config.BossName then
                boss = enemy; break 
            elseif Config.MobName ~= "" and enemy.Name == Config.MobName then
                local dist = (rootPart.Position - root.Position).Magnitude
                if dist < minMobDist then minMobDist = dist; nearestMob = enemy end
            end
        end
    end
    return boss or nearestMob
end

-- Noclip functionality
local noclipConnection
if Config.Noclip then
    noclipConnection = RunService.Stepped:Connect(function()
        if character and Config.Noclip then
            for _, v in ipairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end

-- Click Loop
task.spawn(function()
    while true do
        if Config.AutoClick and Config.FarmStatus and getTarget() then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
        task.wait(Config.ClickSpeed)
    end
end)

-- Skill Loop
task.spawn(function()
    while true do
        if Config.FarmStatus and getTarget() then
            if Config.Skill1 then 
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            end
            if Config.Skill2 then 
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
            end
        end
        task.wait(0.2)
    end
end)

-- Movement
RunService.Heartbeat:Connect(function()
    if not Config.FarmStatus or not rootPart or not rootPart.Parent then return end
    local target = getTarget()
    if target and target:FindFirstChild("HumanoidRootPart") then
        local tRoot = target.HumanoidRootPart
        rootPart.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, Config.Height, Config.Distance)).Position, tRoot.Position)
    end
end)

-- Noclip toggle update
noclipToggle.MouseButton1Click:Connect(function()
    Config.Noclip = not Config.Noclip
    
    if Config.Noclip then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if character and Config.Noclip then
                    for _, v in ipairs(character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
        noclipToggle.Text = "Noclip: ON"
        noclipToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        noclipToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        noclipToggle.Text = "Noclip: OFF"
        noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

-- Initialize speed display
updateSpeedDisplay(0.1)

-- Cleanup when player leaves
Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if Players.LocalPlayer.Parent == nil then
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

print("Zyrtec Hub Combat loaded successfully!")
