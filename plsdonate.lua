-- by zyrtechub
-- FIXED: Left button text = "Buy item", Right balance = CustomBalance + Robux logo
-- FIXED: Both popup logos use official Robux icon
-- FIXED: Balance spoof Robux logo is white and positioned closer to text
-- ADDED: Small compact donation popup after purchase

getgenv().Settings = {
    CopyButton = false,
    AutoButton = false,
    AutoInterval = 0.1,
    InstantPurchase = false,
    AutoMassPurchase = false,
    CustomBalance = "9,999,999",
    Debug = false
}

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- Store the price of the item being purchased
local currentItemPrice = 0

-- ========== SMALL COMPACT DONATION POPUP ==========
local function createDonatePopup(amount)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- remove old popup
    local old = playerGui:FindFirstChild("DonatePopup")
    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DonatePopup"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.Position = UDim2.new(0.5, -125, 0.75, 0)
    frame.BackgroundColor3 = Color3.fromRGB(28, 255, 73)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- FIXED: Left logo now uses official Robux icon (white version for dark bg contrast)
    local leftLogo = Instance.new("ImageLabel")
    leftLogo.Name = "LeftLogo"
    leftLogo.Size = UDim2.new(0, 20, 0, 20)
    leftLogo.Position = UDim2.new(0, 10, 0.5, -10)
    leftLogo.BackgroundTransparency = 1
    leftLogo.Image = "rbxasset://textures/ui/common/robux@3x.png"
    leftLogo.ImageColor3 = Color3.fromRGB(0, 80, 20)  -- Dark green to match popup theme
    leftLogo.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 85, 1, 0)
    text.Position = UDim2.new(0, 35, 0, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextColor3 = Color3.fromRGB(0, 50, 10)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Text = "you donated"
    text.Parent = frame

    -- FIXED: Robux logo uses official built-in texture path
    local robuxLogo = Instance.new("ImageLabel")
    robuxLogo.Name = "RobuxLogo"
    robuxLogo.Size = UDim2.new(0, 16, 0, 16)
    robuxLogo.Position = UDim2.new(0, 130, 0.5, -8)
    robuxLogo.BackgroundTransparency = 1
    robuxLogo.Image = "rbxasset://textures/ui/common/robux@3x.png"
    robuxLogo.ImageColor3 = Color3.fromRGB(0, 80, 20)
    robuxLogo.Parent = frame

    local amountText = Instance.new("TextLabel")
    amountText.Size = UDim2.new(0, 70, 1, 0)
    amountText.Position = UDim2.new(0, 150, 0, 0)
    amountText.BackgroundTransparency = 1
    amountText.Font = Enum.Font.GothamBold
    amountText.TextSize = 14
    amountText.TextColor3 = Color3.fromRGB(0, 50, 10)
    amountText.TextXAlignment = Enum.TextXAlignment.Left
    amountText.Text = tostring(amount)
    amountText.Parent = frame

    -- popup animation (slide in from right)
    frame.Position = UDim2.new(1, 0, 0.75, 0)

    TweenService:Create(
        frame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(0.5, -125, 0.75, 0)
        }
    ):Play()

    -- auto remove after 1.5 seconds
    task.delay(1.5, function()
        local tween = TweenService:Create(
            frame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Position = UDim2.new(1, 0, 0.75, 0)
            }
        )

        tween:Play()

        for _, v in ipairs(frame:GetDescendants()) do
            if v:IsA("TextLabel") then
                TweenService:Create(v, TweenInfo.new(0.15), {
                    TextTransparency = 1
                }):Play()
            elseif v:IsA("ImageLabel") then
                TweenService:Create(v, TweenInfo.new(0.15), {
                    ImageTransparency = 1
                }):Play()
            end
        end

        tween.Completed:Wait()
        gui:Destroy()
    end)
end
-- ========== END DONATION POPUP ==========

local COLORS = {
    IDLE = Color3.fromRGB(34, 214, 78),
    HOVER = Color3.fromRGB(42, 232, 90),
}

local TWEEN_SPEED = TweenInfo.new(
    0.045,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local OVERLAY_RESCAN_INTERVAL = 0.05

local LastPrompt = {
    Id = nil,
    Type = nil,
    Nonce = 0,
    Price = 0
}

local function getSettings()
    local ok, envSettings = pcall(function()
        return getgenv().Settings
    end)

    if not ok or type(envSettings) ~= "table" then
        return {}
    end

    return envSettings
end

local RuntimeState = nil

pcall(function()
    local env = type(getgenv) == "function" and getgenv() or nil

    if type(env) == "table" then
        env.__FreeGamepassRuntime =
            env.__FreeGamepassRuntime or {
                runId = 0,
                connections = {}
            }

        for _, conn in ipairs(env.__FreeGamepassRuntime.connections) do
            pcall(function()
                if conn and conn.Disconnect then
                    conn:Disconnect()
                end
            end)
        end

        env.__FreeGamepassRuntime.connections = {}
        env.__FreeGamepassRuntime.runId += 1

        RuntimeState = env.__FreeGamepassRuntime
    end
end)

local CURRENT_RUN_ID =
    RuntimeState and RuntimeState.runId or os.clock()

local ParentButtonState = setmetatable({}, {
    __mode = "k"
})

local ScriptConnections =
    RuntimeState and RuntimeState.connections or {}

local function isCurrentRun()
    return not RuntimeState or
        RuntimeState.runId == CURRENT_RUN_ID
end

local function trackConnection(conn)
    if conn then
        table.insert(ScriptConnections, conn)
    end

    return conn
end

local function toggleRobloxMenu()
    pcall(function()
        GuiService:SetMenuIsOpen(true)
        GuiService:SetMenuIsOpen(false)
    end)
end

local function applyVisualState(root, color)
    local props = {
        BackgroundColor3 = color
    }

    if root:IsA("ImageButton") then
        props.ImageColor3 = color
    end

    TweenService:Create(root, TWEEN_SPEED, props):Play()

    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("ImageLabel")
        or desc:IsA("ImageButton")
        or desc:IsA("Frame") then

            local p = {
                BackgroundColor3 = color
            }

            if desc:IsA("ImageLabel")
            or desc:IsA("ImageButton") then
                p.ImageColor3 = color
            end

            TweenService:Create(desc, TWEEN_SPEED, p):Play()
        end
    end
end

local function getItemPrice(id, itemType)
    local price = 0

    if itemType == "GamePass" then
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
        end)
        if ok and info then
            price = info.PriceInRobux or 0
        end
    elseif itemType == "Asset" or itemType == "Product" then
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(id)
        end)
        if ok and info then
            price = info.PriceInRobux or 0
        end
    end

    return price
end

local function finishPurchase(id)
    local price = LastPrompt.Price or 0

    pcall(function()
        if price and price > 0 then
            createDonatePopup(price)
        else
            createDonatePopup(0)
        end
    end)

    if LastPrompt.Type == "GamePass" then
        pcall(function()
            MarketplaceService:SignalPromptGamePassPurchaseFinished(
                LocalPlayer.UserId,
                id,
                true
            )
        end)

    elseif LastPrompt.Type == "Product" then
        pcall(function()
            MarketplaceService:SignalPromptProductPurchaseFinished(
                LocalPlayer.UserId,
                id,
                true
            )
        end)

    elseif LastPrompt.Type == "Asset" then
        pcall(function()
            MarketplaceService:SignalPromptPurchaseFinished(
                LocalPlayer.UserId,
                id,
                true
            )
        end)

    elseif LastPrompt.Type == "Bundle" then
        pcall(function()
            MarketplaceService:SignalPromptBundlePurchaseFinished(
                LocalPlayer.UserId,
                id,
                true
            )
        end)
    end
end

trackConnection(
    MarketplaceService.PromptGamePassPurchaseRequested:Connect(function(p, id)
        if p == LocalPlayer then
            task.spawn(function()
                local price = getItemPrice(id, "GamePass")
                LastPrompt = {
                    Id = id,
                    Type = "GamePass",
                    Price = price
                }
            end)
        end
    end)
)

trackConnection(
    MarketplaceService.PromptProductPurchaseRequested:Connect(function(p, id)
        if p == LocalPlayer then
            task.spawn(function()
                local price = getItemPrice(id, "Product")
                LastPrompt = {
                    Id = id,
                    Type = "Product",
                    Price = price
                }
            end)
        end
    end)
)

trackConnection(
    MarketplaceService.PromptPurchaseRequested:Connect(function(p, id)
        if p == LocalPlayer then
            task.spawn(function()
                local price = getItemPrice(id, "Asset")
                LastPrompt = {
                    Id = id,
                    Type = "Asset",
                    Price = price
                }
            end)
        end
    end)
)

trackConnection(
    MarketplaceService.PromptBundlePurchaseRequested:Connect(function(p, id)
        if p == LocalPlayer then
            LastPrompt = {
                Id = id,
                Type = "Bundle",
                Price = 0
            }
        end
    end)
)

-- FIXED: Robux logo uses official built-in texture path, WHITE color, CLOSER to balance
local function createRobuxLogo(parent, position)
    local logo = Instance.new("ImageLabel")
    logo.Name = "RobuxLogo"
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = position
    logo.BackgroundTransparency = 1
    logo.Image = "rbxasset://textures/ui/common/robux@3x.png"
    logo.ImageColor3 = Color3.fromRGB(255, 255, 255)  -- WHITE for visibility on dark backgrounds
    logo.Parent = parent

    return logo
end

local function applyBalanceSpoof(overlay)
    local customBal = getSettings().CustomBalance

    if not customBal or customBal == "" then
        return
    end

    local textLabels = {}

    local function collectLabels(container)
        for _, desc in ipairs(container:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
                local absPos = desc.AbsolutePosition
                table.insert(textLabels, {
                    label = desc,
                    x = absPos.X,
                    y = absPos.Y
                })
            end
        end
    end

    collectLabels(overlay)

    table.sort(textLabels, function(a, b)
        return a.x < b.x
    end)

    local balanceLabels = {}
    local buttonLabels = {}

    for _, item in ipairs(textLabels) do
        local text = item.label.Text
        if text:match("%d+['%,]?%d+") or text:match("^%d+$") and #text > 3 then
            table.insert(balanceLabels, item)
        end
        if text:lower():find("buy") or text:lower():find("purchase") or text:lower():find("get") then
            table.insert(buttonLabels, item)
        end
    end

    table.sort(balanceLabels, function(a, b) return a.x > b.x end)
    table.sort(buttonLabels, function(a, b) return a.x < b.x end)

    if #buttonLabels > 0 then
        local buyButtonLabel = buttonLabels[1].label
        buyButtonLabel.Text = "Buy item"
        trackConnection(
            buyButtonLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if buyButtonLabel.Text ~= "Buy item" then
                    buyButtonLabel.Text = "Buy item"
                end
            end)
        )
    end

    if #balanceLabels > 0 then
        local balanceLabel = balanceLabels[1].label
        local balanceParent = balanceLabel.Parent
        local labelPos = balanceLabel.Position

        -- FIXED: Logo positioned much closer to balance text (only 4px gap instead of 25px)
        local logo = balanceParent:FindFirstChild("RobuxLogo")
        if not logo then
            logo = createRobuxLogo(balanceParent, UDim2.new(
                labelPos.X.Scale, 
                labelPos.X.Offset - 22,  -- CLOSER: was -25, now -22
                labelPos.Y.Scale, 
                labelPos.Y.Offset + 1      -- CLOSER vertical alignment
            ))
        end

        trackConnection(
            balanceLabel:GetPropertyChangedSignal("Position"):Connect(function()
                if logo and logo.Parent then
                    local newPos = balanceLabel.Position
                    logo.Position = UDim2.new(
                        newPos.X.Scale, 
                        newPos.X.Offset - 22,  -- CLOSER
                        newPos.Y.Scale, 
                        newPos.Y.Offset + 1
                    )
                end
            end)
        )

        balanceLabel.Text = customBal
        trackConnection(
            balanceLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if balanceLabel.Text ~= customBal then
                    balanceLabel.Text = customBal
                end
            end)
        )
    end

    trackConnection(
        overlay.DescendantAdded:Connect(function(newDesc)
            task.wait(0.1)
            if newDesc:IsA("TextLabel") and newDesc.Visible then
                local absPos = newDesc.AbsolutePosition
                local text = newDesc.Text

                if absPos.X > 500 and (text:match("%d+['%,]?%d+") or text:match("^%d+$") and #text > 3) then
                    local balanceParent = newDesc.Parent
                    local labelPos = newDesc.Position

                    -- FIXED: Closer positioning for dynamically added labels too
                    local logo = balanceParent:FindFirstChild("RobuxLogo")
                    if not logo then
                        logo = createRobuxLogo(balanceParent, UDim2.new(
                            labelPos.X.Scale, 
                            labelPos.X.Offset - 22,
                            labelPos.Y.Scale, 
                            labelPos.Y.Offset + 1
                        ))
                    end

                    trackConnection(
                        newDesc:GetPropertyChangedSignal("Position"):Connect(function()
                            if logo and logo.Parent then
                                local newPos = newDesc.Position
                                logo.Position = UDim2.new(
                                    newPos.X.Scale, 
                                    newPos.X.Offset - 22,
                                    newPos.Y.Scale, 
                                    newPos.Y.Offset + 1
                                )
                            end
                        end)
                    )

                    newDesc.Text = customBal
                    trackConnection(
                        newDesc:GetPropertyChangedSignal("Text"):Connect(function()
                            if newDesc.Text ~= customBal then
                                newDesc.Text = customBal
                            end
                        end)
                    )
                end

                if absPos.X < 500 and (text:lower():find("buy") or text:lower():find("purchase")) then
                    newDesc.Text = "Buy item"
                    trackConnection(
                        newDesc:GetPropertyChangedSignal("Text"):Connect(function()
                            if newDesc.Text ~= "Buy item" then
                                newDesc.Text = "Buy item"
                            end
                        end)
                    )
                end
            end
        end)
    )
end

local function destroyOriginalButton(btn)
    pcall(function()
        btn.Visible = false
        btn.Size = UDim2.new(0, 0, 0, 0)
        btn.BackgroundTransparency = 1

        if btn:IsA("ImageButton") then
            btn.ImageTransparency = 1
        end

        btn.Interactable = false
        btn.Active = false

        for _, v in ipairs(btn:GetDescendants()) do
            if v:IsA("TextLabel") then
                v.Text = ""
                v.TextTransparency = 1

            elseif v:IsA("GuiObject") then
                v.BackgroundTransparency = 1
            end
        end

        trackConnection(
            btn:GetPropertyChangedSignal("Visible"):Connect(function()
                if btn.Visible then
                    btn.Visible = false
                end
            end)
        )
    end)
end

local function decorateButton(btn, text)
    btn.Visible = true
    btn.Active = true
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = COLORS.IDLE
    btn.BackgroundTransparency = 0.1

    if btn:IsA("ImageButton") then
        btn.ImageColor3 = COLORS.IDLE
        btn.ImageTransparency = 0
    end

    pcall(function()
        btn.Interactable = true
    end)

    for _, desc in ipairs(btn:GetDescendants()) do
        if desc:IsA("LocalScript")
        or desc:IsA("Script") then

            desc:Destroy()

        elseif desc:IsA("GuiObject") then
            desc.Active = true

            pcall(function()
                desc.Interactable = true
            end)

            if desc:IsA("TextLabel")
            or desc:IsA("TextButton") then

                desc.Text = text
                desc.TextTransparency = 0
            end
        end
    end
end

local function processParentButtons(parent)
    if not parent then
        return
    end

    local state = ParentButtonState[parent] or {}
    ParentButtonState[parent] = state

    if state.Injecting then
        return
    end

    state.Injecting = true

    task.spawn(function()
        local template = state.TemplateButton

        if not template or template.Parent ~= parent then
            state.Injecting = false
            return
        end

        if not parent:FindFirstChild("FreeButton") then
            local freeBtn = template:Clone()

            freeBtn.Name = "FreeButton"
            freeBtn.Parent = parent

            if parent:FindFirstChildOfClass("UIListLayout") then
                freeBtn.LayoutOrder =
                    template.LayoutOrder or 0
            else
                freeBtn.Position = template.Position

                trackConnection(
                    template:GetPropertyChangedSignal("Position"):Connect(function()
                        freeBtn.Position = template.Position
                    end)
                )
            end

            decorateButton(freeBtn, "Buy")
            destroyOriginalButton(template)

            freeBtn.MouseEnter:Connect(function()
                applyVisualState(
                    freeBtn,
                    COLORS.HOVER
                )
            end)

            freeBtn.MouseLeave:Connect(function()
                applyVisualState(
                    freeBtn,
                    COLORS.IDLE
                )
            end)

            freeBtn.Activated:Connect(function()
                if not LastPrompt.Id then
                    return
                end

                applyVisualState(
                    freeBtn,
                    COLORS.HOVER
                )

                local price = LastPrompt.Price or 0
                if price and price > 0 then
                    createDonatePopup(price)
                else
                    createDonatePopup(0)
                end

                finishPurchase(LastPrompt.Id)

                applyVisualState(
                    freeBtn,
                    COLORS.IDLE
                )

                toggleRobloxMenu()
            end)
        end

        state.Injecting = false
    end)
end

local function injectButtons(originalBtn)
    if not originalBtn
    or originalBtn.Name == "FreeButton" then
        return
    end

    local parent = originalBtn.Parent

    if not parent then
        return
    end

    local state = ParentButtonState[parent] or {}

    if not state.TemplateButton
    or state.TemplateButton.Parent ~= parent then
        state.TemplateButton = originalBtn
    end

    ParentButtonState[parent] = state

    processParentButtons(parent)
end

local function scanActions(actionsFolder)
    for _, child in ipairs(actionsFolder:GetChildren()) do
        if tonumber(child.Name) then
            for _, inner in ipairs(child:GetDescendants()) do
                if inner:IsA("ImageButton") then
                    injectButtons(inner)
                end
            end
        end
    end
end

local ProcessedOverlays = setmetatable({}, {
    __mode = "k"
})

local function handleOverlay(child)
    if child.Name ~= "FoundationOverlay" then
        return
    end

    if ProcessedOverlays[child] then
        return
    end

    ProcessedOverlays[child] = true

    applyBalanceSpoof(child)

    local function getActions()
        local a = child:FindFirstChild("SafeAreaFrame")
        a = a and a:FindFirstChild("OverlayPortal")
        a = a and a:FindFirstChild("SheetContainer")
        a = a and a:FindFirstChild("Frame")
        a = a and a:FindFirstChild("Sheet")
        a = a and a:FindFirstChild("Content")
        a = a and a:FindFirstChild("Actions")

        return a or child:FindFirstChild("Actions", true)
    end

    local conn

    conn = trackConnection(
        child.DescendantAdded:Connect(function()
            if not isCurrentRun() then
                conn:Disconnect()
                return
            end

            local actions = getActions()

            if actions then
                scanActions(actions)
            end
        end)
    )
end

trackConnection(
    CoreGui.DescendantAdded:Connect(handleOverlay)
)

for _, child in ipairs(CoreGui:GetDescendants()) do
    task.spawn(handleOverlay, child)
end

task.spawn(function()
    while isCurrentRun() do
        for _, child in ipairs(CoreGui:GetDescendants()) do
            if child:IsA("ScreenGui")
            and child.Name == "FoundationOverlay" then

                local a = child:FindFirstChild("Actions", true)

                if a then
                    scanActions(a)
                end
            end
        end

        task.wait(OVERLAY_RESCAN_INTERVAL)
    end
end)
