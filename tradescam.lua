-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ZyrtecHubTrade"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Notification System
local function createNotification(title, message, color, duration)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NotificationGui"
    notificationGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0.25, 0, 0.08, 0)
    notification.Position = UDim2.new(1, 0, 0.9, 0) -- Start off screen to the right
    notification.AnchorPoint = Vector2.new(1, 0.5)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notification.BackgroundTransparency = 0.1
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0.05, 0)
    notifCorner.Parent = notification
    
    local notifBorder = Instance.new("UIStroke")
    notifBorder.Color = color
    notifBorder.Thickness = 2
    notifBorder.Transparency = 0.3
    notifBorder.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.SciFi
    titleLabel.TextColor3 = color
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0.4, 0)
    messageLabel.Position = UDim2.new(0, 10, 0.4, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.SciFi
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    messageLabel.TextSize = 11
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notification
    
    -- Animate in
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.98, 0, 0.9, 0)
    })
    tweenIn:Play()
    
    -- Wait and animate out
    task.spawn(function()
        task.wait(duration or 3)
        
        local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1.2, 0, 0.9, 0)
        })
        tweenOut:Play()
        
        tweenOut.Completed:Wait()
        notificationGui:Destroy()
    end)
end

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
mainFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
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
title.Text = "ZYRTEC HUB - TRADE"
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
    Settings = {
        Name = "⚙️ Settings",
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
mainTitle.Size = UDim2.new(0.8, 0, 0.1, 0)
mainTitle.Position = UDim2.new(0.1, 0, 0.05, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "ADM TRADE SCAM"
mainTitle.Font = Enum.Font.SciFi
mainTitle.TextColor3 = Color3.fromRGB(255, 150, 100)
mainTitle.TextSize = 16
mainTitle.Parent = mainTabContainer

-- Made by label
local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(0.8, 0, 0.06, 0)
authorLabel.Position = UDim2.new(0.1, 0, 0.16, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "made by zyrtec"
authorLabel.Font = Enum.Font.SciFi
authorLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
authorLabel.TextSize = 12
authorLabel.Parent = mainTabContainer

-- Bypass info
local bypassLabel = Instance.new("TextLabel")
bypassLabel.Size = UDim2.new(0.8, 0, 0.06, 0)
bypassLabel.Position = UDim2.new(0.1, 0, 0.23, 0)
bypassLabel.BackgroundTransparency = 1
bypassLabel.Text = "BYPASS"
bypassLabel.Font = Enum.Font.SciFi
bypassLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
bypassLabel.TextSize = 12
bypassLabel.Parent = mainTabContainer

-- Warning label
local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(0.8, 0, 0.08, 0)
warningLabel.Position = UDim2.new(0.1, 0, 0.3, 0)
warningLabel.BackgroundTransparency = 1
warningLabel.Text = "⚠ Must be on trade before using!"
warningLabel.Font = Enum.Font.SciFi
warningLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
warningLabel.TextSize = 11
warningLabel.Parent = mainTabContainer

-- ON/OFF Buttons Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(0.8, 0, 0.3, 0)
toggleContainer.Position = UDim2.new(0.1, 0, 0.4, 0)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = mainTabContainer

-- ON Button
local onButton = Instance.new("TextButton")
onButton.Name = "ONButton"
onButton.Size = UDim2.new(0.4, 0, 0.8, 0)
onButton.Position = UDim2.new(0.05, 0, 0.1, 0)
onButton.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
onButton.Text = "ON"
onButton.Font = Enum.Font.SciFi
onButton.TextColor3 = Color3.fromRGB(100, 255, 100)
onButton.TextSize = 16
onButton.Parent = toggleContainer

local onCorner = Instance.new("UICorner")
onCorner.CornerRadius = UDim.new(0.2, 0)
onCorner.Parent = onButton

-- OFF Button
local offButton = Instance.new("TextButton")
offButton.Name = "OFFButton"
offButton.Size = UDim2.new(0.4, 0, 0.8, 0)
offButton.Position = UDim2.new(0.55, 0, 0.1, 0)
offButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
offButton.Text = "OFF"
offButton.Font = Enum.Font.SciFi
offButton.TextColor3 = Color3.fromRGB(255, 100, 100)
offButton.TextSize = 16
offButton.Parent = toggleContainer

local offCorner = Instance.new("UICorner")
offCorner.CornerRadius = UDim.new(0.2, 0)
offCorner.Parent = offButton

-- Status Indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0.2, 0, 0.05, 0)
statusIndicator.Position = UDim2.new(0.4, 0, 0.8, 0)
statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
statusIndicator.Parent = toggleContainer

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusIndicator

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "OFF"
statusLabel.Font = Enum.Font.SciFi
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 10
statusLabel.Parent = statusIndicator

-- Create Settings Tab Content
local settingsTabContainer = Instance.new("Frame")
settingsTabContainer.Size = UDim2.new(1, 0, 1, 0)
settingsTabContainer.BackgroundTransparency = 1
settingsTabContainer.Visible = currentTab == "Settings"
settingsTabContainer.Parent = tabContentFrame

tabs.Settings.Content.Container = settingsTabContainer

-- Settings Tab Title
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(0.8, 0, 0.1, 0)
settingsTitle.Position = UDim2.new(0.1, 0, 0.05, 0)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ SETTINGS"
settingsTitle.Font = Enum.Font.SciFi
settingsTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
settingsTitle.TextSize = 16
settingsTitle.Parent = settingsTabContainer

-- Auto-Trade Toggle
local autoTradeToggle = Instance.new("TextButton")
autoTradeToggle.Name = "AutoTradeToggle"
autoTradeToggle.Size = UDim2.new(0.8, 0, 0.1, 0)
autoTradeToggle.Position = UDim2.new(0.1, 0, 0.18, 0)
autoTradeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
autoTradeToggle.Text = "Auto Accept Trades: OFF"
autoTradeToggle.Font = Enum.Font.SciFi
autoTradeToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
autoTradeToggle.TextSize = 12
autoTradeToggle.Parent = settingsTabContainer

local autoTradeCorner = Instance.new("UICorner")
autoTradeCorner.CornerRadius = UDim.new(0.1, 0)
autoTradeCorner.Parent = autoTradeToggle

-- Whitelist Friends Toggle
local friendsToggle = Instance.new("TextButton")
friendsToggle.Name = "FriendsToggle"
friendsToggle.Size = UDim2.new(0.8, 0, 0.1, 0)
friendsToggle.Position = UDim2.new(0.1, 0, 0.32, 0)
friendsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
friendsToggle.Text = "Whitelist Friends: ON"
friendsToggle.Font = Enum.Font.SciFi
friendsToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
friendsToggle.TextSize = 12
friendsToggle.Parent = settingsTabContainer

local friendsCorner = Instance.new("UICorner")
friendsCorner.CornerRadius = UDim.new(0.1, 0)
friendsCorner.Parent = friendsToggle

-- Status Label
local mainStatusLabel = Instance.new("TextLabel")
mainStatusLabel.Size = UDim2.new(0.8, 0, 0.08, 0)
mainStatusLabel.Position = UDim2.new(0.1, 0, 0.86, 0)
mainStatusLabel.BackgroundTransparency = 1
mainStatusLabel.Text = ""
mainStatusLabel.Font = Enum.Font.SciFi
mainStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
mainStatusLabel.TextSize = 12
mainStatusLabel.Parent = mainFrame

-- Final parenting
toggleButton.Parent = gui
mainFrame.Parent = gui

-- State
local isActive = false
local autoAcceptTrades = false
local whitelistFriends = true
local bypassTypes = {"a", "b", "c", "d", "e", "f", "g", "h", "i"}
local currentBypass = ""

-- Simulated bypass functions (placeholder - you'd replace with actual trade exploit methods)
local function attemptBypassA()
    -- Placeholder for bypass method A
    return math.random() > 0.3  -- 70% success rate
end

local function attemptBypassB()
    -- Placeholder for bypass method B
    return math.random() > 0.4  -- 60% success rate
end

local function attemptBypassC()
    -- Placeholder for bypass method C
    return math.random() > 0.2  -- 80% success rate
end

local function executeTradeBypass()
    local attempts = 0
    local maxAttempts = 9
    local success = false
    
    for i = 1, maxAttempts do
        attempts = attempts + 1
        currentBypass = bypassTypes[i] or "unknown"
        
        -- Show bypass attempt notification
        createNotification(
            "BYPASS ATTEMPT",
            "Trying bypass: " .. currentBypass .. " (" .. attempts .. "/" .. maxAttempts .. ")",
            Color3.fromRGB(255, 200, 100),
            1.5
        )
        
        -- Simulate bypass attempt
        local bypassSuccess = false
        if i == 1 then
            bypassSuccess = attemptBypassA()
        elseif i == 2 then
            bypassSuccess = attemptBypassB()
        elseif i == 3 then
            bypassSuccess = attemptBypassC()
        else
            -- Random success for other bypasses
            bypassSuccess = math.random() > 0.5
        end
        
        if bypassSuccess then
            success = true
            break
        end
        
        task.wait(0.5) -- Wait between attempts
    end
    
    return success, attempts, currentBypass
end

-- ON/OFF Button Functionality
onButton.MouseButton1Click:Connect(function()
    if not isActive then
        -- Show activation notification
        createNotification(
            "TRADE SCAM ACTIVATED",
            "Starting bypass sequence...",
            Color3.fromRGB(100, 255, 100),
            2
        )
        
        -- Update GUI
        isActive = true
        onButton.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
        offButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        statusLabel.Text = "ON"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Show status
        mainStatusLabel.Text = "Bypass active - Looking for trade..."
        mainStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Simulate trade detection and bypass
        task.spawn(function()
            task.wait(1) -- Simulate detection time
            
            -- Check if in trade (simulated)
            local inTrade = math.random() > 0.2  -- 80% chance of being in trade
            
            if inTrade then
                createNotification(
                    "TradeScam now working!",
                    "Initiating bypass protocol...",
                    Color3.fromRGB(0, 200, 255),
                    2
                )
                
                mainStatusLabel.Text = "Trade detected - Starting bypass..."
                
                -- Execute bypass sequence
                local success, attempts, bypassUsed = executeTradeBypass()
                
                if success then
                    -- Show success notification
                    createNotification(
                        "BYPASS SUCCESSFUL!",
                        "Bypass " .. bypassUsed .. " worked! (" .. attempts .. " attempts)",
                        Color3.fromRGB(100, 255, 100),
                        4
                    )
                    
                    mainStatusLabel.Text = "Bypass successful! Trade manipulated."
                    mainStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    
                    -- Simulate trade completion
                    task.wait(1.5)
                    createNotification(
                        "TradeScam now working!",
                        "You can now trade with players!",
                        Color3.fromRGB(0, 255, 150),
                        3
                    )
                else
                    -- Show failure notification
                    createNotification(
                        "BYPASS FAILED",
                        "All " .. attempts .. " attempts failed",
                        Color3.fromRGB(255, 100, 100),
                        3
                    )
                    
                    mainStatusLabel.Text = "Bypass failed - Try again"
                    mainStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            else
                createNotification(
                    "Start a trade",
                    "You can now trade with players!",
                    Color3.fromRGB(255, 100, 100),
                    3
                )
                
                mainStatusLabel.Text = "No trade detected - Start a trade first"
                mainStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                
                -- Auto turn off after notification
                task.wait(3)
                offButton.MouseButton1Click:Fire()
            end
        end)
    else
        createNotification(
            "ALREADY ACTIVE",
            "Bypass is already running",
            Color3.fromRGB(255, 200, 100),
            2
        )
    end
end)

offButton.MouseButton1Click:Connect(function()
    if isActive then
        -- Show deactivation notification
        createNotification(
            "TRADE SCAM DEACTIVATED",
            "Bypass sequence stopped",
            Color3.fromRGB(255, 100, 100),
            2
        )
        
        -- Update GUI
        isActive = false
        onButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        offButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        statusLabel.Text = "OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        mainStatusLabel.Text = "Bypass inactive"
        mainStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        createNotification(
            "ALREADY INACTIVE",
            "Bypass is already off",
            Color3.fromRGB(150, 150, 200),
            2
        )
    end
end)

-- Auto Trade Toggle
autoTradeToggle.MouseButton1Click:Connect(function()
    autoAcceptTrades = not autoAcceptTrades
    
    if autoAcceptTrades then
        autoTradeToggle.Text = "Auto Accept Trades: ON"
        autoTradeToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        autoTradeToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        createNotification(
            "AUTO ACCEPT ENABLED",
            "Will auto-accept incoming trades",
            Color3.fromRGB(100, 255, 100),
            2
        )
    else
        autoTradeToggle.Text = "Auto Accept Trades: OFF"
        autoTradeToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        autoTradeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        
        createNotification(
            "AUTO ACCEPT DISABLED",
            "Will not auto-accept trades",
            Color3.fromRGB(255, 100, 100),
            2
        )
    end
end)

-- Friends Toggle
friendsToggle.MouseButton1Click:Connect(function()
    whitelistFriends = not whitelistFriends
    
    if whitelistFriends then
        friendsToggle.Text = "Whitelist Friends: ON"
        friendsToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        friendsToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        createNotification(
            "FRIENDS WHITELISTED",
            "Friends will not be targeted",
            Color3.fromRGB(100, 255, 100),
            2
        )
    else
        friendsToggle.Text = "Whitelist Friends: OFF"
        friendsToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        friendsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        
        createNotification(
            "FRIENDS NOT WHITELISTED",
            "All players may be targeted",
            Color3.fromRGB(255, 100, 100),
            2
        )
    end
end)

-- Button hover effects
local function setupButtonEffects(button)
    button.MouseEnter:Connect(function()
        if button == onButton and isActive then
            return
        elseif button == offButton and not isActive then
            return
        elseif button == autoTradeToggle and autoTradeToggle.Text:find(": ON") then
            return
        elseif button == friendsToggle and friendsToggle.Text:find(": ON") then
            return
        end
        
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if button == onButton then
            if isActive then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 100, 60)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        elseif button == offButton then
            if not isActive then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        elseif button == autoTradeToggle then
            if autoTradeToggle.Text:find(": ON") then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                }):Play()
            end
        elseif button == friendsToggle then
            if friendsToggle.Text:find(": ON") then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 80)
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
setupButtonEffects(onButton)
setupButtonEffects(offButton)
setupButtonEffects(autoTradeToggle)
setupButtonEffects(friendsToggle)

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
    
    -- Quick ON/OFF with O/P keys
    if input.KeyCode == Enum.KeyCode.O then
        onButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.P then
        offButton.MouseButton1Click:Fire()
    end
end)

-- Auto accept trade simulation (if enabled)
task.spawn(function()
    while true do
        if autoAcceptTrades and not isActive then
            -- Simulate incoming trade detection
            if math.random() > 0.8 then  -- 20% chance per check
                createNotification(
                    "INCOMING TRADE",
                    "Auto-accepting trade request...",
                    Color3.fromRGB(0, 200, 255),
                    2
                )
                
                -- Simulate delay before activating bypass
                task.wait(1)
                onButton.MouseButton1Click:Fire()
            end
        end
        task.wait(2) -- Check every 2 seconds
    end
end)

-- Cleanup
Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if Players.LocalPlayer.Parent == nil then
        gui:Destroy()
    end
end)

-- Initial notification
task.wait(1)
createNotification(
    "ZYRTEC HUB LOADED",
    "Trade scam script ready to use",
    Color3.fromRGB(0, 200, 255),
    3
)

print("Zyrtec Hub Trade Scam loaded successfully!")
