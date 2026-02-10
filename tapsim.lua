-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

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
title.Text = "ZYRTEC HUB"
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 18
title.Parent = mainFrame

-- Tabs
local tabs = {
    Main = {
        Name = "Main",
        Color = Color3.fromRGB(255, 100, 100),
        Content = {}
    },
    Eggs = {
        Name = "Eggs",
        Color = Color3.fromRGB(0, 150, 255),
        Content = {}
    },
    Clicker = {
        Name = "Auto Clicker",
        Color = Color3.fromRGB(0, 255, 150),
        Content = {}
    }
}

local currentTab = "Main"
local tabButtons = {}

-- Create tab buttons
for tabName, tabInfo in pairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.3, 0, 0.9, 0)
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
mainTitle.Size = UDim2.new(0.8, 0, 0.1, 0)
mainTitle.Position = UDim2.new(0.1, 0, 0.05, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "MAIN"
mainTitle.Font = Enum.Font.SciFi
mainTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
mainTitle.TextSize = 18
mainTitle.Parent = mainTabContainer

-- Infinite Jump Toggle
local infiniteJumpToggle = Instance.new("TextButton")
infiniteJumpToggle.Name = "InfiniteJumpToggle"
infiniteJumpToggle.Size = UDim2.new(0.8, 0, 0.12, 0)
infiniteJumpToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
infiniteJumpToggle.Text = "INFINITE JUMP: OFF"
infiniteJumpToggle.Font = Enum.Font.SciFi
infiniteJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
infiniteJumpToggle.TextSize = 16
infiniteJumpToggle.Parent = mainTabContainer

local infiniteJumpCorner = Instance.new("UICorner")
infiniteJumpCorner.CornerRadius = UDim.new(0.2, 0)
infiniteJumpCorner.Parent = infiniteJumpToggle

-- Speed Changer with + and - buttons
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.8, 0, 0.2, 0)
speedFrame.Position = UDim2.new(0.1, 0, 0.38, 0)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = mainTabContainer

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0.4, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Walk Speed: 30"
speedLabel.Font = Enum.Font.SciFi
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

-- Speed buttons container
local speedButtonsContainer = Instance.new("Frame")
speedButtonsContainer.Size = UDim2.new(1, 0, 0.6, 0)
speedButtonsContainer.Position = UDim2.new(0, 0, 0.4, 0)
speedButtonsContainer.BackgroundTransparency = 1
speedButtonsContainer.Parent = speedFrame

-- Speed value display
local speedValueDisplay = Instance.new("TextLabel")
speedValueDisplay.Size = UDim2.new(0.4, 0, 1, 0)
speedValueDisplay.Position = UDim2.new(0.3, 0, 0, 0)
speedValueDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedValueDisplay.Text = "30"
speedValueDisplay.Font = Enum.Font.SciFi
speedValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
speedValueDisplay.TextSize = 16
speedValueDisplay.Parent = speedButtonsContainer

local speedValueCorner = Instance.new("UICorner")
speedValueCorner.CornerRadius = UDim.new(0.2, 0)
speedValueCorner.Parent = speedValueDisplay

-- Minus button
local minusButton = Instance.new("TextButton")
minusButton.Size = UDim2.new(0.2, 0, 1, 0)
minusButton.Position = UDim2.new(0, 0, 0, 0)
minusButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minusButton.Text = "-"
minusButton.Font = Enum.Font.SciFi
minusButton.TextColor3 = Color3.fromRGB(255, 100, 100)
minusButton.TextSize = 20
minusButton.Parent = speedButtonsContainer

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0.2, 0)
minusCorner.Parent = minusButton

-- Plus button
local plusButton = Instance.new("TextButton")
plusButton.Size = UDim2.new(0.2, 0, 1, 0)
plusButton.Position = UDim2.new(0.8, 0, 0, 0)
plusButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
plusButton.Text = "+"
plusButton.Font = Enum.Font.SciFi
plusButton.TextColor3 = Color3.fromRGB(100, 255, 100)
plusButton.TextSize = 20
plusButton.Parent = speedButtonsContainer

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0.2, 0)
plusCorner.Parent = plusButton

-- Speed info text
local speedInfo = Instance.new("TextLabel")
speedInfo.Size = UDim2.new(1, 0, 0.6, 0)
speedInfo.Position = UDim2.new(0, 0, 0.4, 0)
speedInfo.BackgroundTransparency = 1
speedInfo.Text = "Tap or hold +/- to adjust (16-100)"
speedInfo.Font = Enum.Font.SciFi
speedInfo.TextColor3 = Color3.fromRGB(150, 150, 200)
speedInfo.TextSize = 10
speedInfo.TextXAlignment = Enum.TextXAlignment.Center
speedInfo.Parent = speedFrame

-- Hotkeys Info
local hotkeysInfo = Instance.new("TextLabel")
hotkeysInfo.Size = UDim2.new(0.8, 0, 0.25, 0)
hotkeysInfo.Position = UDim2.new(0.1, 0, 0.65, 0)
hotkeysInfo.BackgroundTransparency = 1
hotkeysInfo.Text = "Hotkeys:\nT - Toggle GUI\nF - Auto Clicker\nRightShift - Auto Hatch"
hotkeysInfo.Font = Enum.Font.SciFi
hotkeysInfo.TextColor3 = Color3.fromRGB(150, 200, 255)
hotkeysInfo.TextSize = 12
hotkeysInfo.TextXAlignment = Enum.TextXAlignment.Left
hotkeysInfo.Parent = mainTabContainer

-- Create Egg Tab Content
local eggsTabContainer = Instance.new("Frame")
eggsTabContainer.Size = UDim2.new(1, 0, 1, 0)
eggsTabContainer.BackgroundTransparency = 1
eggsTabContainer.Visible = currentTab == "Eggs"
eggsTabContainer.Parent = tabContentFrame

tabs.Eggs.Content.Container = eggsTabContainer

-- Egg Selection Dropdown
local eggDropdown = Instance.new("TextButton")
eggDropdown.Name = "EggDropdown"
eggDropdown.Size = UDim2.new(0.8, 0, 0.12, 0)
eggDropdown.Position = UDim2.new(0.1, 0, 0.05, 0)
eggDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
eggDropdown.Text = "Select Egg"
eggDropdown.Font = Enum.Font.SciFi
eggDropdown.TextColor3 = Color3.fromRGB(200, 200, 255)
eggDropdown.TextSize = 14
eggDropdown.Parent = eggsTabContainer

local eggCorner = Instance.new("UICorner")
eggCorner.CornerRadius = UDim.new(0.1, 0)
eggCorner.Parent = eggDropdown

-- Dropdown list
local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(0.8, 0, 0.3, 0)
dropdownList.Position = UDim2.new(0.1, 0, 0.18, 0)
dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.ScrollBarThickness = 4
dropdownList.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.Parent = eggsTabContainer

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownList

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0.1, 0)
listCorner.Parent = dropdownList

-- Hatch Amount Selection
local amountFrame = Instance.new("Frame")
amountFrame.Size = UDim2.new(0.8, 0, 0.1, 0)
amountFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
amountFrame.BackgroundTransparency = 1
amountFrame.Parent = eggsTabContainer

local amountLabel = Instance.new("TextLabel")
amountLabel.Size = UDim2.new(0.4, 0, 1, 0)
amountLabel.Position = UDim2.new(0, 0, 0, 0)
amountLabel.BackgroundTransparency = 1
amountLabel.Text = "Amount:"
amountLabel.Font = Enum.Font.SciFi
amountLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
amountLabel.TextSize = 14
amountLabel.TextXAlignment = Enum.TextXAlignment.Left
amountLabel.Parent = amountFrame

-- Amount buttons - Always show 1, 3, 8
local amounts = {1, 3, 8}
local amountButtons = {}

for i, amount in ipairs(amounts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.18, 0, 0.9, 0)
    btn.Position = UDim2.new(0.4 + (i-1) * 0.2, 0, 0.05, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = tostring(amount)
    btn.Font = Enum.Font.SciFi
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    btn.TextSize = 13
    btn.Parent = amountFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.2, 0)
    btnCorner.Parent = btn
    
    amountButtons[i] = btn
end

-- Hatch Delay Slider
local delayFrame = Instance.new("Frame")
delayFrame.Size = UDim2.new(0.8, 0, 0.15, 0)
delayFrame.Position = UDim2.new(0.1, 0, 0.62, 0)
delayFrame.BackgroundTransparency = 1
delayFrame.Parent = eggsTabContainer

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, 0, 0.4, 0)
delayLabel.Position = UDim2.new(0, 0, 0, 0)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Hatch Delay: 0s"
delayLabel.Font = Enum.Font.SciFi
delayLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
delayLabel.TextSize = 14
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = delayFrame

-- Delay slider
local delaySlider = Instance.new("Frame")
delaySlider.Name = "DelaySlider"
delaySlider.Size = UDim2.new(1, 0, 0.3, 0)
delaySlider.Position = UDim2.new(0, 0, 0.5, 0)
delaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
delaySlider.BorderSizePixel = 0
delaySlider.Parent = delayFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0.2, 0)
sliderCorner.Parent = delaySlider

-- Slider fill
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = delaySlider

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0.2, 0)
fillCorner.Parent = sliderFill

-- Slider thumb
local sliderThumb = Instance.new("TextButton")
sliderThumb.Name = "SliderThumb"
sliderThumb.Size = UDim2.new(0, 15, 0, 15)
sliderThumb.Position = UDim2.new(0, 0, 0.5, 0)
sliderThumb.AnchorPoint = Vector2.new(0, 0.5)
sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderThumb.Text = ""
sliderThumb.ZIndex = 2
sliderThumb.Parent = delaySlider

local thumbCorner = Instance.new("UICorner")
thumbCorner.CornerRadius = UDim.new(1, 0)
thumbCorner.Parent = sliderThumb

-- Delay value display
local delayValueDisplay = Instance.new("TextLabel")
delayValueDisplay.Size = UDim2.new(1, 0, 0.3, 0)
delayValueDisplay.Position = UDim2.new(0, 0, 0.85, 0)
delayValueDisplay.BackgroundTransparency = 1
delayValueDisplay.Text = "0 seconds"
delayValueDisplay.Font = Enum.Font.SciFi
delayValueDisplay.TextColor3 = Color3.fromRGB(0, 200, 255)
delayValueDisplay.TextSize = 12
delayValueDisplay.TextXAlignment = Enum.TextXAlignment.Center
delayValueDisplay.Parent = delayFrame

-- Egg Hatch Toggle Button
local hatchToggle = Instance.new("TextButton")
hatchToggle.Name = "HatchToggle"
hatchToggle.Size = UDim2.new(0.8, 0, 0.12, 0)
hatchToggle.Position = UDim2.new(0.1, 0, 0.8, 0)
hatchToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
hatchToggle.Text = "AUTO HATCH: OFF"
hatchToggle.Font = Enum.Font.SciFi
hatchToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
hatchToggle.TextSize = 16
hatchToggle.Parent = eggsTabContainer

local hatchCorner = Instance.new("UICorner")
hatchCorner.CornerRadius = UDim.new(0.2, 0)
hatchCorner.Parent = hatchToggle

-- Create Auto Clicker Tab Content
local clickerTabContainer = Instance.new("Frame")
clickerTabContainer.Size = UDim2.new(1, 0, 1, 0)
clickerTabContainer.BackgroundTransparency = 1
clickerTabContainer.Visible = currentTab == "Clicker"
clickerTabContainer.Parent = tabContentFrame

tabs.Clicker.Content.Container = clickerTabContainer

-- Auto Clicker Title
local clickerTitle = Instance.new("TextLabel")
clickerTitle.Size = UDim2.new(0.8, 0, 0.1, 0)
clickerTitle.Position = UDim2.new(0.1, 0, 0.05, 0)
clickerTitle.BackgroundTransparency = 1
clickerTitle.Text = "AUTO CLICKER"
clickerTitle.Font = Enum.Font.SciFi
clickerTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
clickerTitle.TextSize = 18
clickerTitle.Parent = clickerTabContainer

-- Auto Clicker Toggle
local clickerToggle = Instance.new("TextButton")
clickerToggle.Name = "ClickerToggle"
clickerToggle.Size = UDim2.new(0.8, 0, 0.12, 0)
clickerToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
clickerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
clickerToggle.Text = "AUTO CLICKER: OFF"
clickerToggle.Font = Enum.Font.SciFi
clickerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
clickerToggle.TextSize = 16
clickerToggle.Parent = clickerTabContainer

local clickerToggleCorner = Instance.new("UICorner")
clickerToggleCorner.CornerRadius = UDim.new(0.2, 0)
clickerToggleCorner.Parent = clickerToggle

-- Click Delay Info
local clickDelayInfo = Instance.new("TextLabel")
clickDelayInfo.Size = UDim2.new(0.8, 0, 0.1, 0)
clickDelayInfo.Position = UDim2.new(0.1, 0, 0.4, 0)
clickDelayInfo.BackgroundTransparency = 1
clickDelayInfo.Text = "Click Delay: 0s (Instant)"
clickDelayInfo.Font = Enum.Font.SciFi
clickDelayInfo.TextColor3 = Color3.fromRGB(200, 200, 255)
clickDelayInfo.TextSize = 14
clickDelayInfo.Parent = clickerTabContainer

-- Status Label (Shared between tabs)
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
local MainState = {
    InfiniteJump = false,
    WalkSpeed = 30,
    OriginalWalkSpeed = 16,
    IsAdjustingSpeed = false,
    SpeedMonitorActive = true  -- New state for speed monitor
}

local EggState = {
    AutoHatch = false,
    SelEgg = nil,
    EggAmt = 1,
    HatchDelay = 0,  -- New: Delay between hatches in seconds
    IsDraggingDelay = false
}

local ClickerState = {
    AutoClickerEnabled = false,
    AutoClickerRunning = false,
    ClickDelay = 0  -- Instant clicks
}

-- Infinite Jump Functionality
local infiniteJumpConnection
local function toggleInfiniteJump(enabled)
    MainState.InfiniteJump = enabled
    
    if enabled then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local character = Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        infiniteJumpToggle.Text = "INFINITE JUMP: ON"
        infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        infiniteJumpToggle.TextColor3 = Color3.fromRGB(255, 150, 150)
        statusLabel.Text = "Infinite Jump enabled"
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
        
        infiniteJumpToggle.Text = "INFINITE JUMP: OFF"
        infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        infiniteJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Infinite Jump disabled"
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Infinite Jump") then
            statusLabel.Text = ""
        end
    end)
end

-- Speed Changer Functionality
local function updateSpeed(value)
    value = math.floor(math.clamp(value, 16, 100))
    MainState.WalkSpeed = value
    speedLabel.Text = "Walk Speed: " .. value
    speedValueDisplay.Text = tostring(value)
    
    -- Apply speed to character immediately
    local character = Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
    
    -- Update display color based on speed
    if value <= 30 then
        speedValueDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    elseif value <= 60 then
        speedValueDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 40)
    else
        speedValueDisplay.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    end
end

-- Continuous speed monitor to prevent reset
local speedMonitorThread
local function startSpeedMonitor()
    if speedMonitorThread then return end
    
    MainState.SpeedMonitorActive = true
    speedMonitorThread = task.spawn(function()
        while MainState.SpeedMonitorActive do
            local character = Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.WalkSpeed ~= MainState.WalkSpeed then
                    -- Speed was reset by the game, reapply it
                    humanoid.WalkSpeed = MainState.WalkSpeed
                end
            end
            task.wait(0.1)  -- Check every 0.1 seconds
        end
    end)
end

local function stopSpeedMonitor()
    MainState.SpeedMonitorActive = false
    if speedMonitorThread then
        task.cancel(speedMonitorThread)
        speedMonitorThread = nil
    end
end

-- Speed adjustment function
local function adjustSpeed(amount, isHold)
    if MainState.IsAdjustingSpeed and not isHold then return end
    
    MainState.IsAdjustingSpeed = isHold
    
    if isHold then
        -- Hold mode: continuously adjust while holding
        local interval = 0.05  -- 20 times per second
        local acceleration = 0.5  -- Start slow
        
        while MainState.IsAdjustingSpeed do
            local newSpeed = MainState.WalkSpeed + (amount * acceleration)
            updateSpeed(newSpeed)
            
            -- Increase acceleration over time for faster holding
            acceleration = math.min(acceleration + 0.2, 5)
            
            statusLabel.Text = "Speed: " .. math.floor(MainState.WalkSpeed)
            task.wait(interval)
        end
    else
        -- Tap mode: single adjustment
        local newSpeed = MainState.WalkSpeed + amount
        updateSpeed(newSpeed)
        statusLabel.Text = "Speed: " .. math.floor(MainState.WalkSpeed)
        
        task.spawn(function()
            task.wait(1)
            if statusLabel.Text == "Speed: " .. math.floor(MainState.WalkSpeed) then
                statusLabel.Text = ""
            end
        end)
    end
end

-- Monitor character for speed application
local function monitorCharacter()
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        if MainState.WalkSpeed ~= 16 then
            task.wait(0.5)  -- Wait a bit for character to load
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = MainState.WalkSpeed
            end
        end
    end)
end

-- Speed buttons functionality
local function setupSpeedButton(button, amount)
    local isHolding = false
    
    button.MouseButton1Down:Connect(function()
        isHolding = true
        adjustSpeed(amount, true)
    end)
    
    button.MouseButton1Up:Connect(function()
        isHolding = false
        MainState.IsAdjustingSpeed = false
    end)
    
    button.MouseLeave:Connect(function()
        if isHolding then
            isHolding = false
            MainState.IsAdjustingSpeed = false
        end
    end)
    
    -- Single click functionality
    button.MouseButton1Click:Connect(function()
        if not isHolding then  -- Prevent double fire
            adjustSpeed(amount, false)
        end
    end)
    
    -- Button hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        }):Play()
    end)
end

-- Setup speed buttons
setupSpeedButton(minusButton, -1)
setupSpeedButton(plusButton, 1)

-- Toggle infinite jump
infiniteJumpToggle.MouseButton1Click:Connect(function()
    toggleInfiniteJump(not MainState.InfiniteJump)
end)

-- Get egg list
local function getEggList()
    local Eggs = {}
    local gameFolder = ReplicatedStorage:FindFirstChild("Game")
    if gameFolder then
        local eggsModule = gameFolder:FindFirstChild("Eggs")
        if eggsModule then
            local ok, res = pcall(require, eggsModule)
            if ok and type(res) == "table" then
                Eggs = res
            end
        end
    end
    
    local eggNames = {}
    if type(Eggs) == "table" then
        for name in pairs(Eggs) do
            table.insert(eggNames, name)
        end
    else
        eggNames = {
            "Starter Egg", "Forest Egg", "Desert Egg", "Arctic Egg", 
            "Mythical Egg", "Galaxy Egg", "Rainbow Egg", "Dragon Egg"
        }
    end
    
    table.sort(eggNames)
    return eggNames
end

-- Delay slider functionality
local function updateHatchDelay(delayValue)
    -- Clamp value between 0 and 5 seconds
    delayValue = math.clamp(delayValue, 0, 5)
    EggState.HatchDelay = delayValue
    
    -- Update slider visuals
    local fillPercentage = delayValue / 5
    sliderFill.Size = UDim2.new(fillPercentage, 0, 1, 0)
    sliderThumb.Position = UDim2.new(fillPercentage, 0, 0.5, 0)
    
    -- Update display text
    local displayText = string.format("%.1f", delayValue)
    delayLabel.Text = "Hatch Delay: " .. displayText .. "s"
    
    if delayValue == 0 then
        delayValueDisplay.Text = "Instant"
        delayValueDisplay.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        delayValueDisplay.Text = displayText .. " seconds"
        delayValueDisplay.TextColor3 = Color3.fromRGB(0, 200, 255)
    end
    
    statusLabel.Text = "Hatch delay: " .. displayText .. "s"
    statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    
    task.spawn(function()
        task.wait(1)
        if statusLabel.Text:find("Hatch delay") then
            statusLabel.Text = ""
        end
    end)
end

-- Setup delay slider
local function setupDelaySlider()
    local isDragging = false
    
    local function updateFromMouse(mouseX)
        local sliderAbsolutePos = delaySlider.AbsolutePosition.X
        local sliderWidth = delaySlider.AbsoluteSize.X
        
        -- Calculate relative position (0 to 1)
        local relativePos = math.clamp((mouseX - sliderAbsolutePos) / sliderWidth, 0, 1)
        
        -- Convert to delay value (0 to 5 seconds)
        local delayValue = relativePos * 5
        
        updateHatchDelay(delayValue)
    end
    
    -- Mouse down on slider
    delaySlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            EggState.IsDraggingDelay = true
            updateFromMouse(input.Position.X)
        end
    end)
    
    -- Mouse down on thumb
    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            EggState.IsDraggingDelay = true
        end
    end)
    
    -- Mouse movement while dragging
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(input.Position.X)
        end
    end)
    
    -- Mouse up
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            EggState.IsDraggingDelay = false
        end
    end)
    
    -- Click on slider (without dragging)
    delaySlider.MouseButton1Click:Connect(function()
        if not isDragging then
            updateFromMouse(UserInputService:GetMouseLocation().X)
        end
    end)
end

-- Auto hatch functions
local autoHatchThread = nil

local function openEgg(name, amt)
    if not name then return end
    
    local NetworkModule
    local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
    if modulesFolder then
        local network = modulesFolder:FindFirstChild("Network")
        if network then
            local ok, res = pcall(require, network)
            if ok and res then
                NetworkModule = res
            end
        end
    end
    
    if NetworkModule and NetworkModule.InvokeServer then
        pcall(function()
            NetworkModule:InvokeServer("OpenEgg", name, tonumber(amt) or 1, {})
        end)
        return
    end
    
    local openEggRemote = ReplicatedStorage:FindFirstChild("OpenEgg") 
        or ReplicatedStorage:FindFirstChild("OpenEggEvent")
        or ReplicatedStorage:FindFirstChild("OpenEggFunction")
    
    if openEggRemote then
        if openEggRemote:IsA("RemoteFunction") then
            pcall(function()
                openEggRemote:InvokeServer(name, tonumber(amt) or 1, {})
            end)
        elseif openEggRemote:IsA("RemoteEvent") then
            pcall(function()
                openEggRemote:FireServer(name, tonumber(amt) or 1, {})
            end)
        end
    end
end

local function startAutoHatch()
    if autoHatchThread then
        autoHatchThread = nil
    end
    
    autoHatchThread = task.spawn(function()
        while EggState.AutoHatch and EggState.SelEgg do
            -- Open eggs multiple times per cycle for faster hatching when delay is 0
            if EggState.HatchDelay == 0 then
                for _ = 1, 3 do
                    openEgg(EggState.SelEgg, EggState.EggAmt)
                end
            else
                -- Single hatch when delay is > 0
                openEgg(EggState.SelEgg, EggState.EggAmt)
            end
            
            -- Wait for the specified delay (0-5 seconds)
            if EggState.HatchDelay > 0 then
                task.wait(EggState.HatchDelay)
            else
                RunService.Heartbeat:Wait()  -- Minimal wait for instant hatches
            end
        end
    end)
end

local function stopAutoHatch()
    if autoHatchThread then
        task.cancel(autoHatchThread)
        autoHatchThread = nil
    end
end

-- Auto Clicker functions
local autoClickerThread = nil

local function startAutoClicker()
    if autoClickerThread then return end
    
    ClickerState.AutoClickerEnabled = true
    ClickerState.AutoClickerRunning = true
    
    autoClickerThread = task.spawn(function()
        local success, NetworkModule = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules", math.huge).Network)
        end)
        
        if not success then
            statusLabel.Text = "Failed to load Network module"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ClickerState.AutoClickerEnabled = false
            ClickerState.AutoClickerRunning = false
            clickerToggle.Text = "AUTO CLICKER: OFF"
            clickerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            clickerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        while ClickerState.AutoClickerEnabled do
            pcall(function()
                if NetworkModule.FireServer then
                    NetworkModule.FireServer(NetworkModule, "Tap", true)
                end
            end)
            -- Instant clicks (0 delay)
            task.wait(ClickerState.ClickDelay)
        end
        
        ClickerState.AutoClickerRunning = false
    end)
end

local function stopAutoClicker()
    ClickerState.AutoClickerEnabled = false
    if autoClickerThread then
        task.cancel(autoClickerThread)
        autoClickerThread = nil
    end
end

-- Initialize amount buttons - SIMPLIFIED: Always show all buttons
local function updateAmountButtons()
    for i, btn in ipairs(amountButtons) do
        if amounts[i] then
            btn.Visible = true  -- Always visible
            if amounts[i] == EggState.EggAmt then
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            end
        end
    end
end

-- Create dropdown items
local function createDropdownItems()
    local eggList = getEggList()
    
    for _, child in ipairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, eggName in ipairs(eggList) do
        local eggBtn = Instance.new("TextButton")
        eggBtn.Size = UDim2.new(1, 0, 0, 30)
        eggBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        eggBtn.BackgroundTransparency = 0.5
        eggBtn.Text = eggName
        eggBtn.Font = Enum.Font.SciFi
        eggBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        eggBtn.TextSize = 12
        eggBtn.Parent = dropdownList
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0.1, 0)
        btnCorner.Parent = eggBtn
        
        eggBtn.MouseEnter:Connect(function()
            TweenService:Create(eggBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            }):Play()
        end)
        
        eggBtn.MouseLeave:Connect(function()
            if eggName == EggState.SelEgg then
                TweenService:Create(eggBtn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.1,
                    BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                }):Play()
            else
                TweenService:Create(eggBtn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.5,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                }):Play()
            end
        end)
        
        eggBtn.MouseButton1Click:Connect(function()
            EggState.SelEgg = eggName
            eggDropdown.Text = eggName
            dropdownList.Visible = false
            
            for _, btn in ipairs(dropdownList:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn.Text == eggName then
                        TweenService:Create(btn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.1,
                            BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                        }):Play()
                    else
                        TweenService:Create(btn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.5,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                        }):Play()
                    end
                end
            end
            
            statusLabel.Text = "Selected: " .. eggName
            statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            
            task.spawn(function()
                task.wait(2)
                if statusLabel.Text == "Selected: " .. eggName then
                    statusLabel.Text = ""
                end
            end)
        end)
    end
end

-- Initialize amount buttons
for i, btn in ipairs(amountButtons) do
    btn.MouseButton1Click:Connect(function()
        EggState.EggAmt = amounts[i]
        updateAmountButtons()
        
        statusLabel.Text = "Amount: " .. EggState.EggAmt .. "x"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        
        task.spawn(function()
            task.wait(2)
            if statusLabel.Text == "Amount: " .. EggState.EggAmt .. "x" then
                statusLabel.Text = ""
            end
        end)
    end)
end

-- Toggle dropdown visibility
eggDropdown.MouseButton1Click:Connect(function()
    if not dropdownList.Visible then
        createDropdownItems()
    end
    dropdownList.Visible = not dropdownList.Visible
end)

-- Close dropdown when clicking outside
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        local dropdownAbsPos = dropdownList.AbsolutePosition
        local dropdownSize = dropdownList.AbsoluteSize
        
        if dropdownList.Visible and 
           (mousePos.X < dropdownAbsPos.X or 
            mousePos.X > dropdownAbsPos.X + dropdownSize.X or 
            mousePos.Y < dropdownAbsPos.Y or 
            mousePos.Y > dropdownAbsPos.Y + dropdownSize.Y) then
            dropdownList.Visible = false
        end
    end
end)

-- Auto hatch toggle functionality
hatchToggle.MouseButton1Click:Connect(function()
    EggState.AutoHatch = not EggState.AutoHatch
    
    if EggState.AutoHatch then
        if not EggState.SelEgg then
            statusLabel.Text = "Select an egg first!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            EggState.AutoHatch = false
            task.wait(2)
            statusLabel.Text = ""
            return
        end
        
        hatchToggle.Text = "AUTO HATCH: ON"
        hatchToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        hatchToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        local delayText = EggState.HatchDelay == 0 and "Instant" or string.format("%.1fs", EggState.HatchDelay)
        statusLabel.Text = "Auto hatching: " .. EggState.SelEgg .. " x" .. EggState.EggAmt .. " (" .. delayText .. " delay)"
        startAutoHatch()
    else
        hatchToggle.Text = "AUTO HATCH: OFF"
        hatchToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        hatchToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        statusLabel.Text = "Auto hatch stopped"
        stopAutoHatch()
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text:find("Auto hatching") or 
           statusLabel.Text == "Auto hatch stopped" then
            statusLabel.Text = ""
        end
    end)
end)

-- Auto Clicker toggle functionality
clickerToggle.MouseButton1Click:Connect(function()
    if ClickerState.AutoClickerEnabled then
        stopAutoClicker()
        clickerToggle.Text = "AUTO CLICKER: OFF"
        clickerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        clickerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        statusLabel.Text = "Auto Clicker stopped"
    else
        startAutoClicker()
        if ClickerState.AutoClickerEnabled then
            clickerToggle.Text = "AUTO CLICKER: ON"
            clickerToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
            clickerToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            statusLabel.Text = "Auto Clicker enabled"
        end
    end
    
    task.spawn(function()
        task.wait(2)
        if statusLabel.Text == "Auto Clicker enabled" or 
           statusLabel.Text == "Auto Clicker stopped" then
            statusLabel.Text = ""
        end
    end)
end)

-- Hotkey support
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- RightShift for Auto Hatch
    if input.KeyCode == Enum.KeyCode.RightShift then
        EggState.AutoHatch = not EggState.AutoHatch
        
        if EggState.AutoHatch then
            if not EggState.SelEgg then
                statusLabel.Text = "Select an egg first!"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                EggState.AutoHatch = false
                task.wait(2)
                statusLabel.Text = ""
                return
            end
            
            hatchToggle.Text = "AUTO HATCH: ON"
            hatchToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
            hatchToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            
            local delayText = EggState.HatchDelay == 0 and "Instant" or string.format("%.1fs", EggState.HatchDelay)
            statusLabel.Text = "Auto hatching (RightShift) - " .. delayText .. " delay"
            startAutoHatch()
        else
            hatchToggle.Text = "AUTO HATCH: OFF"
            hatchToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
            hatchToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            statusLabel.Text = "Auto hatch stopped (RightShift)"
            stopAutoHatch()
        end
        
        task.spawn(function()
            task.wait(2)
            if statusLabel.Text:find("RightShift") then
                statusLabel.Text = ""
            end
        end)
    
    -- F for Auto Clicker
    elseif input.KeyCode == Enum.KeyCode.F then
        if ClickerState.AutoClickerEnabled then
            stopAutoClicker()
            clickerToggle.Text = "AUTO CLICKER: OFF"
            clickerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
            clickerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            statusLabel.Text = "Auto Clicker stopped (F)"
        else
            startAutoClicker()
            if ClickerState.AutoClickerEnabled then
                clickerToggle.Text = "AUTO CLICKER: ON"
                clickerToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
                clickerToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                statusLabel.Text = "Auto Clicker enabled (F)"
            end
        end
        
        task.spawn(function()
            task.wait(2)
            if statusLabel.Text:find("F") then
                statusLabel.Text = ""
            end
        end)
    end
end)

-- Button hover effects
local function setupButtonEffects(button)
    button.MouseEnter:Connect(function()
        if button == hatchToggle and EggState.AutoHatch then
            return
        end
        if button == clickerToggle and ClickerState.AutoClickerEnabled then
            return
        end
        if button == infiniteJumpToggle and MainState.InfiniteJump then
            return
        end
        
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if button == hatchToggle then
            if EggState.AutoHatch then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        elseif button == clickerToggle then
            if ClickerState.AutoClickerEnabled then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        elseif button == infiniteJumpToggle then
            if MainState.InfiniteJump then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        else
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            }):Play()
        end
    end)
end

setupButtonEffects(eggDropdown)
setupButtonEffects(hatchToggle)
setupButtonEffects(clickerToggle)
setupButtonEffects(infiniteJumpToggle)

for _, btn in ipairs(amountButtons) do
    setupButtonEffects(btn)
end

-- Hide GUI with T key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
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

-- Initialize
updateAmountButtons()
updateSpeed(30)  -- Set default speed to 30
setupDelaySlider()  -- Setup the delay slider
updateHatchDelay(0)  -- Set default hatch delay to 0
monitorCharacter()  -- Start monitoring character for speed updates
startSpeedMonitor()  -- Start continuous speed monitor

-- Cleanup on character change
Players.LocalPlayer.CharacterAdded:Connect(function()
    stopAutoClicker()
    stopAutoHatch()
    toggleInfiniteJump(false)
    
    clickerToggle.Text = "AUTO CLICKER: OFF"
    clickerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    clickerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    hatchToggle.Text = "AUTO HATCH: OFF"
    hatchToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    hatchToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    ClickerState.AutoClickerEnabled = false
    EggState.AutoHatch = false
    MainState.InfiniteJump = false
    
    -- Reapply walk speed to new character
    if MainState.WalkSpeed ~= 16 then
        task.wait(0.5)
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = MainState.WalkSpeed
            end
        end
    end
end)

-- Cleanup when player leaves
Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if Players.LocalPlayer.Parent == nil then
        stopSpeedMonitor()
        stopAutoClicker()
        stopAutoHatch()
        toggleInfiniteJump(false)
    end
end)

print("Zyrtec Hub loaded successfully! (With Hatch Delay Slider)")
