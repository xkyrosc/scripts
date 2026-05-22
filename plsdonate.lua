-- ============================================
-- FIREBASE KEY SYSTEM v1.0
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ========== CONFIGURATION ==========
local CONFIG = {
    databaseURL = "https://plsdonate-e7fb8-default-rtdb.firebaseio.com/",
    secret = "4QNe3gcaBgb1oIyVJ9JwKp8KyDqfeB03ac3yKXMV",
    scriptName = "ZyrtecHub",
    scriptVersion = "1.0.0",
    developerDiscord = "https://discord.gg/Sqk57CrUC9", -- Optional
    keyPlaceholder = "XXXX-XXXX-XXXX"
}

-- ========== HWID GENERATION ==========
local function getHWID()
    local parts = {}
    
    -- Try to get unique identifiers
    pcall(function()
        local success, result = pcall(function()
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end)
        if success then
            table.insert(parts, result)
        end
    end)
    
    -- Fallback identifiers
    table.insert(parts, tostring(Players.LocalPlayer.UserId))
    table.insert(parts, tostring(game.PlaceId))
    table.insert(parts, tostring(game.GameId))
    table.insert(parts, tostring(os.time()):sub(1, 5))
    
    return HttpService:JSONEncode(parts)
end

-- ========== FIREBASE API FUNCTIONS ==========
local Firebase = {}

function Firebase:request(path, method, data)
    local url = CONFIG.databaseURL .. path .. ".json?auth=" .. CONFIG.secret
    
    local options = {
        Url = url,
        Method = method or "GET",
        Headers = {
            ["Content-Type"] = "application/json"
        }
    }
    
    if data then
        options.Body = HttpService:JSONEncode(data)
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync(options)
    end)
    
    if success and response.Success then
        local body = response.Body
        if body and body ~= "null" then
            return HttpService:JSONDecode(body)
        end
    end
    
    return nil
end

function Firebase:verifyKey(key)
    return self:request("keys/" .. key)
end

function Firebase:updateKeyUsage(key, hwid)
    local data = {
        hwid = hwid,
        hwidLocked = true,
        lastUsed = os.time()
    }
    
    -- Update key data
    self:request("keys/" .. key, "PATCH", data)
    
    -- Increment usage count
    local keyData = self:verifyKey(key)
    if keyData then
        local uses = (keyData.uses or 0) + 1
        self:request("keys/" .. key .. "/uses", "PUT", uses)
    end
end

function Firebase:saveUserData(hwid, key)
    local data = {
        hwid = hwid,
        key = key,
        lastLogin = os.time(),
        gameId = game.PlaceId,
        username = Players.LocalPlayer.Name
    }
    
    self:request("users/" .. hwid, "PUT", data)
end

function Firebase:getSettings()
    return self:request("settings")
end

-- ========== KEY VALIDATION ==========
local function validateKey(key)
    -- Check if maintenance mode
    local settings = Firebase:getSettings()
    if settings and settings.maintenanceMode then
        return false, settings.maintenanceMessage or "Script is under maintenance."
    end
    
    -- Verify key exists
    local keyData = Firebase:verifyKey(key)
    if not keyData then
        return false, "Invalid key. Please check and try again."
    end
    
    -- Check if banned
    if keyData.banned then
        return false, "This key has been banned."
    end
    
    -- Check expiry
    if keyData.expiryTime and keyData.expiryTime < os.time() then
        return false, "This key has expired. Please get a new one."
    end
    
    -- Check usage limits
    if keyData.maxUses and keyData.maxUses > 0 then
        if keyData.uses and keyData.uses >= keyData.maxUses then
            return false, "This key has reached its maximum usage limit."
        end
    end
    
    -- Check HWID lock
    local hwid = getHWID()
    if keyData.hwidLocked and keyData.hwid and keyData.hwid ~= "" then
        if keyData.hwid ~= hwid then
            return false, "This key is locked to a different device."
        end
    end
    
    -- Update key usage and HWID
    Firebase:updateKeyUsage(key, hwid)
    Firebase:saveUserData(hwid, key)
    
    return true, "Key verified successfully!", keyData
end

-- ========== UI CREATION ==========
local function createKeyUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove existing UI
    local oldUI = playerGui:FindFirstChild("KeySystemUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Background overlay
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.7
    background.Parent = screenGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Gradient accent at top
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 0, 4)
    accentBar.BackgroundColor3 = Color3.fromRGB(49, 93, 254)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = mainFrame
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 12)
    accentCorner.Parent = accentBar
    
    -- Fix bottom corners
    local accentFix = Instance.new("Frame")
    accentFix.Size = UDim2.new(1, 0, 0, 8)
    accentFix.Position = UDim2.new(0, 0, 1, -8)
    accentFix.BackgroundColor3 = Color3.fromRGB(49, 93, 254)
    accentFix.BorderSizePixel = 0
    accentFix.Parent = accentBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 60)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 28
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = CONFIG.scriptName
    titleLabel.Parent = mainFrame
    
    -- Version label
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "VersionLabel"
    versionLabel.Size = UDim2.new(1, 0, 0, 20)
    versionLabel.Position = UDim2.new(0, 0, 0, 75)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 12
    versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionLabel.Text = "v" .. CONFIG.scriptVersion
    versionLabel.Parent = mainFrame
    
    -- Key input
    local keyInput = Instance.new("Frame")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(0, 320, 0, 45)
    keyInput.Position = UDim2.new(0.5, -160, 0, 115)
    keyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    keyInput.BorderSizePixel = 0
    keyInput.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = keyInput
    
    local keyTextBox = Instance.new("TextBox")
    keyTextBox.Name = "KeyTextBox"
    keyTextBox.Size = UDim2.new(1, -20, 1, 0)
    keyTextBox.Position = UDim2.new(0, 10, 0, 0)
    keyTextBox.BackgroundTransparency = 1
    keyTextBox.Font = Enum.Font.GothamBold
    keyTextBox.TextSize = 16
    keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTextBox.PlaceholderText = CONFIG.keyPlaceholder
    keyTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    keyTextBox.Text = ""
    keyTextBox.TextXAlignment = Enum.TextXAlignment.Center
    keyTextBox.Parent = keyInput
    
    -- Verify button
    local verifyButton = Instance.new("TextButton")
    verifyButton.Name = "VerifyButton"
    verifyButton.Size = UDim2.new(0, 320, 0, 40)
    verifyButton.Position = UDim2.new(0.5, -160, 0, 175)
    verifyButton.BackgroundColor3 = Color3.fromRGB(49, 93, 254)
    verifyButton.BorderSizePixel = 0
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.TextSize = 16
    verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyButton.Text = "VERIFY KEY"
    verifyButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = verifyButton
    
    -- Status message
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 235)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = ""
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Discord link (optional)
    if CONFIG.developerDiscord then
        local discordButton = Instance.new("TextButton")
        discordButton.Name = "DiscordButton"
        discordButton.Size = UDim2.new(0, 150, 0, 20)
        discordButton.Position = UDim2.new(0.5, -75, 0, 270)
        discordButton.BackgroundTransparency = 1
        discordButton.Font = Enum.Font.Gotham
        discordButton.TextSize = 11
        discordButton.TextColor3 = Color3.fromRGB(100, 150, 255)
        discordButton.Text = "Get Key | Discord Server"
        discordButton.Parent = mainFrame
        
        discordButton.MouseButton1Click:Connect(function()
            setclipboard(CONFIG.developerDiscord)
            statusLabel.Text = "Discord link copied to clipboard!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
            task.wait(3)
            statusLabel.Text = ""
        end)
    end
    
    -- Button effects
    verifyButton.MouseEnter:Connect(function()
        TweenService:Create(verifyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(72, 112, 255)
        }):Play()
    end)
    
    verifyButton.MouseLeave:Connect(function()
        TweenService:Create(verifyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(49, 93, 254)
        }):Play()
    end)
    
    -- Verify button click
    verifyButton.MouseButton1Click:Connect(function()
        local key = keyTextBox.Text:gsub("%s", "") -- Remove spaces
        
        if key == "" then
            statusLabel.Text = "⚠ Please enter a key"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        -- Show loading
        verifyButton.Text = "VERIFYING..."
        verifyButton.Interactable = false
        statusLabel.Text = "Connecting to server..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Verify key
        local success, message, keyData = validateKey(key)
        
        if success then
            -- Success animation
            statusLabel.Text = "✅ " .. message
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            verifyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            verifyButton.Text = "SUCCESS!"
            
            task.wait(1)
            
            -- Fade out UI
            TweenService:Create(screenGui, TweenInfo.new(0.5), {
                Enabled = false
            }):Play()
            
            task.wait(0.5)
            screenGui:Destroy()
            
            -- LOAD THE MAIN SCRIPT HERE
            loadMainScript(keyData)
        else
            -- Error feedback
            statusLabel.Text = "❌ " .. message
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            verifyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            verifyButton.Text = "FAILED"
            
            task.wait(1.5)
            
            verifyButton.BackgroundColor3 = Color3.fromRGB(49, 93, 254)
            verifyButton.Text = "VERIFY KEY"
            verifyButton.Interactable = true
        end
    end)
    
    -- Allow Enter key to submit
    keyTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyButton.MouseButton1Click:Fire()
        end
    end)
    
    return screenGui
end

-- ========== LOAD MAIN SCRIPT ==========
function loadMainScript(keyData)
    print("Key verified! Type: " .. (keyData and keyData.type or "standard"))
    print("Loading main script...")
    
    -- LOAD YOUR ACTUAL SCRIPT HERE
    -- This is where your original script loads
    pcall(function()
        loadstring(game:HttpGet("https://zyrtec.vercel.app/scripts/plsdonate.lua"))()
    end)
end

-- ========== INITIALIZE ==========
-- Check if already verified (optional - for auto-login)
local function checkExistingSession()
    local hwid = getHWID()
    local userData = Firebase:request("users/" .. hwid)
    
    if userData and userData.key then
        -- Verify existing key
        local success, message, keyData = validateKey(userData.key)
        if success then
            print("Auto-login successful!")
            loadMainScript(keyData)
            return true
        end
    end
    
    return false
end

-- Start the key system
task.spawn(function()
    -- Try auto-login first
    local autoLoginSuccess = checkExistingSession()
    
    if not autoLoginSuccess then
        -- Show key input UI
        createKeyUI()
    end
end)
