-- Syntax Corp MM2 - no key + external visual models

-- MM2 Trade & Spawner - Improved UI with Spawn All

-- ============================================================



local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")

local HttpService = game:GetService("HttpService")

local RunService = game:GetService("RunService")

local VirtualInputManager = game:GetService("VirtualInputManager")



local Player = Players.LocalPlayer

local LastTradePartner = nil



local function FormatValue(v)

if v == nil then return "?" end

if type(v) == "number" then

local s = tostring(math.floor(v))

local k

repeat s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2") until k == 0

return s

end

return tostring(v)

end



setthreadidentity(2)

local ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)

local InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)

local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)

local Sync = require(game.ReplicatedStorage.Database.Sync)

local ItemPopupService = require(game.ReplicatedStorage.ClientServices.ItemPopupService)

setthreadidentity(8)



local TradeRemotes = game.ReplicatedStorage.Trade

local TradeGUI = Player.PlayerGui.TradeGUI

local TheirOffer = TradeGUI.Container.Trade.TheirOffer

local YourOffer = TradeGUI.Container.Trade.YourOffer



local SearchTextSignal

local TradeInventory

local functions = {}



local Config = {

["item"] = "",

["in_trade"] = false,

["player2"] = nil

}



local UntradableRarities = { Unique = true }

local UntradableRarityExceptions = { corrupt = true }



local UntradableFamilies = { "reaver", "gingerscythe", "icecrusher", "synthwave" }



local EvoPrefixes = {

Blue = true, Bronze = true, Silver = true, Gold = true,

Platinum = true, Diamond = true, Emerald = true, Ruby = true,

Obsidian = true, Crystal = true,

}



local function _isEvoWeapon(name, data)

if type(data) == "table" then

if data.Evo == true or data.Evolution == true then return true end

if data.IsEvo == true or data.EvoTier ~= nil then return true end

if type(data.MaxStack) == "number" and data.MaxStack <= 1 then return true end

if type(data.MaxAmount) == "number" and data.MaxAmount <= 1 then return true end

end

if name then

local firstWord = string.match(tostring(name), "^(%S+)")

if firstWord and EvoPrefixes[firstWord] then return true end

end

return false

end



local function _isTradable(data)

if type(data) ~= "table" then return false end

if data.Tradable == false then return false end

if data.CanTrade == false then return false end

if data.Untradable == true then return false end

if data.NonTradable == true then return false end

if data.Locked == true then return false end

return true

end



local function _blockKey(s)

return (string.gsub(string.lower(tostring(s or "")), "[^%a%d]", ""))

end



local function WeaponBlockReason(name, rarity, data)

local flat = _blockKey(name)

if flat == "" or string.find(tostring(name or ""), "?", 1, true) then

return "unreleased placeholder"

end

for _, family in ipairs(UntradableFamilies) do

if string.find(flat, family, 1, true) then

return "Evo gamepass weapon"

end

end

if UntradableRarities[rarity] and not UntradableRarityExceptions[flat] then

return "untradable " .. tostring(rarity)

end

if not _isTradable(data) then

return "flagged untradable"

end

if _isEvoWeapon(name, data) then

return "Evo variant"

end

return nil

end



local BlockedWeaponKeys = {}

local WeaponCatalog = {}

local WeaponByKey = {}

local WeaponByName = {}

local RareWeaponKeys = {}

local RareRarities = { Godly = true, Ancient = true, Unique = true, Chroma = true, Legendary = true, Classic = true }



do

local source = Sync.Weapons or Sync.Item

local blockedCount = 0

for key, data in pairs(source) do

if type(data) == "table" and (data.ItemType == "Knife" or data.ItemType == "Gun") then

local rarity = data.Rarity or "Common"

local isChroma = data.Chroma == true

local name = data.ItemName or key

local blockReason = WeaponBlockReason(name, rarity, data)

if blockReason then

BlockedWeaponKeys[key] = blockReason

blockedCount = blockedCount + 1

else

local effectiveRarity = isChroma and "Chroma" or rarity

local entry = {

key = key,

name = name,

rarity = effectiveRarity,

type = data.ItemType,

chroma = isChroma,

}

table.insert(WeaponCatalog, entry)

WeaponByKey[key] = entry

WeaponByName[string.lower(entry.name)] = entry

if RareRarities[effectiveRarity] then

table.insert(RareWeaponKeys, key)

end

end

end

end

local rarityOrder = {

Chroma = 1, Godly = 2, Ancient = 3, Unique = 4, Legendary = 5, Classic = 6,

Vintage = 7, Rare = 8, Uncommon = 9, Common = 10,

}

table.sort(WeaponCatalog, function(a, b)

local ra = rarityOrder[a.rarity] or 99

local rb = rarityOrder[b.rarity] or 99

if ra ~= rb then return ra < rb end

if a.type ~= b.type then return a.type < b.type end

return a.name < b.name

end)

end



local function _ownedEntry(k, v)

if type(k) == "number" then

if type(v) == "string" then return v, 1 end

if type(v) == "table" then

return (v.Name or v.ItemName or v.Key or v.Id), (tonumber(v.Amount) or 1)

end

return nil, 0

end

if type(v) == "number" then return k, v end

if type(v) == "table" then return k, (tonumber(v.Amount) or 1) end

return k, 1

end



local function PurgeBlockedFromInventory()

local removed = 0

pcall(function()

local owned = ProfileData.Weapons and ProfileData.Weapons.Owned

if type(owned) ~= "table" then return end

local kill = {}

for k, v in pairs(owned) do

local itemKey, amount = _ownedEntry(k, v)

if itemKey then

local data = Sync.Weapons and Sync.Weapons[itemKey]

local displayName = (type(data) == "table" and data.ItemName) or tostring(itemKey)

local reason

if type(data) ~= "table" then

reason = "no entry"

else

reason = WeaponBlockReason(displayName, data.Rarity or "Common", data)

end

if reason then

table.insert(kill, { k = k })

end

end

end

for _, item in ipairs(kill) do

owned[item.k] = nil

removed = removed + 1

end

end)

if removed > 0 then

pcall(function()

game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()

end)

end

return removed

end



local function CheckForItem(ItemName, Type)

local Owned = ProfileData[Type].Owned

for Index, Value in pairs(Owned) do

if Index == ItemName then

return true, Value

end

if Value == ItemName then

return true, 1

end

end

return false

end



local function SpawnItem(ItemName, Amount, ItemType)

Amount = Amount or 1

ItemType = ItemType or "Weapons"

if ItemType == "Weapons" and BlockedWeaponKeys[ItemName] then

return

end

pcall(function()

if ProfileData[ItemType].Owned[ItemName] == nil then

ProfileData[ItemType].Owned[ItemName] = Amount

else

ProfileData[ItemType].Owned[ItemName] = ProfileData[ItemType].Owned[ItemName] + Amount

end

game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()

end)

end



local function GiveItem(ItemName, Amount, ItemType)

pcall(function()

if ProfileData[ItemType].Owned[ItemName] == nil then

ProfileData[ItemType].Owned[ItemName] = Amount

else

ProfileData[ItemType].Owned[ItemName] = ProfileData[ItemType].Owned[ItemName] + Amount

end

ItemPopupService.ItemReceived:Fire(ItemName, ItemType)

game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()

end)

end



local function RemoveItem(ItemName, Amount, ItemType)

pcall(function()

local owned = ProfileData[ItemType].Owned[ItemName]

if not owned then return end

if owned - Amount > 0 then

ProfileData[ItemType].Owned[ItemName] = owned - Amount

else

ProfileData[ItemType].Owned[ItemName] = nil

end

game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()

end)

end



local TradeTable = {

["LastOffer"] = os.time(),

["Locked"] = false,

["Player1"] = {

["Player"] = Player,

["Accepted"] = false,

["Offer"] = {}

},

["Player2"] = {

["Player"] = "Syntax Corp",

["Accepted"] = false,

["Offer"] = {}

},

}



local function AcceptTrade()

if not TradeTable then return end

if TradeTable["Player1"]["Accepted"] == true and TradeTable["Player2"]["Accepted"] == true then

TradeTable["Locked"] = true

task.wait(0.2)

if TradeTable["Player1"]["Offer"] and next(TradeTable["Player1"]["Offer"]) ~= nil then

for _, item in pairs(TradeTable["Player1"]["Offer"]) do

pcall(function()

RemoveItem(item[1], item[2], item[3])

end)

end

end

if TradeTable["Player2"]["Offer"] and next(TradeTable["Player2"]["Offer"]) ~= nil then

for _, item in pairs(TradeTable["Player2"]["Offer"]) do

pcall(function()

GiveItem(item[1], item[2], item[3])

end)

end

end

pcall(function()

TradeGUI.Enabled = false

end)

local partner = "m0_3a"

if TradeTable.Player2 and TradeTable.Player2.Player then

partner = TradeTable.Player2.Player

end

if partner and partner ~= "" and partner ~= "m0_3a" then

LastTradePartner = partner

end

TradeTable = {

["LastOffer"] = os.time(),

["Locked"] = false,

["Player1"] = {

["Player"] = Player,

["Accepted"] = false,

["Offer"] = {}

},

["Player2"] = {

["Player"] = partner,

["Accepted"] = false,

["Offer"] = {}

},

}

Config.in_trade = false

end

end



local function OfferItemLocalPlayer(ItemName, ItemType)

if not TradeTable then return end

if TradeTable["Locked"] == true then return end

local AlreadyOffered = 0

for _, Item in pairs(TradeTable["Player1"]["Offer"]) do

if Item[1] == ItemName and Item[3] == ItemType then

AlreadyOffered = Item[2]

end

end

local HasItem, Amount = CheckForItem(ItemName, ItemType)

if HasItem and Amount - AlreadyOffered > 0 then

if AlreadyOffered == 0 then

if #TradeTable["Player1"]["Offer"] < 4 then

table.insert(TradeTable["Player1"]["Offer"], {ItemName, 1, ItemType})

end

else

for Index, Item in pairs(TradeTable["Player1"]["Offer"]) do

if Item[1] == ItemName then

TradeTable["Player1"]["Offer"][Index][2] = TradeTable["Player1"]["Offer"][Index][2] + 1

break

end

end

end

end

TradeTable["LastOffer"] = os.time()

TradeTable["Player1"]["Accepted"] = false

TradeTable["Player2"]["Accepted"] = false

pcall(function() functions.UpdateTrade() end)

end



local function RemoveItemLocalPlayer(ItemName, ItemType)

if not TradeTable then return end

if TradeTable["Locked"] == true then return end

if TradeTable["Player1"]["Accepted"] then return end

TradeTable["LastOffer"] = os.time()

TradeTable["Player1"]["Accepted"] = false

TradeTable["Player2"]["Accepted"] = false

for Index, Item in pairs(TradeTable["Player1"]["Offer"]) do

if Item[1] == ItemName and Item[3] == ItemType then

TradeTable["Player1"]["Offer"][Index][2] = TradeTable["Player1"]["Offer"][Index][2] - 1

if TradeTable["Player1"]["Offer"][Index][2] <= 0 then

table.remove(TradeTable["Player1"]["Offer"], Index)

end

break

end

end

pcall(function() functions.UpdateTrade() end)

end



local function OfferItemAnotherPlayer(ItemName, ItemType)

if not ItemName or ItemName == "" then return false end

if not TradeTable then return false end

if TradeTable["Locked"] == true then return false end

if #TradeTable["Player2"]["Offer"] >= 4 then

local foundExisting = false

for _, Item in pairs(TradeTable["Player2"]["Offer"]) do

if Item[1] == ItemName and Item[3] == ItemType then

foundExisting = true

break

end

end

if not foundExisting then return false end

end

local AlreadyOffered = 0

for _, Item in pairs(TradeTable["Player2"]["Offer"]) do

if Item[1] == ItemName and Item[3] == ItemType then

AlreadyOffered = Item[2]

end

end

if AlreadyOffered == 0 then

table.insert(TradeTable["Player2"]["Offer"], {ItemName, 1, ItemType})

else

for Index, Item in pairs(TradeTable["Player2"]["Offer"]) do

if Item[1] == ItemName and Item[3] == ItemType then

TradeTable["Player2"]["Offer"][Index][2] = TradeTable["Player2"]["Offer"][Index][2] + 1

break

end

end

end

TradeTable["LastOffer"] = os.time()

TradeTable["Player1"]["Accepted"] = false

TradeTable["Player2"]["Accepted"] = false

pcall(function() functions.UpdateTrade() end)

return true

end



local function RemoveItemAnotherPlayer()

if not TradeTable then return end

if not TradeTable["Player2"] then return end

if not TradeTable["Player2"]["Offer"] then return end

if #TradeTable["Player2"]["Offer"] > 0 then

if TradeTable["Player2"]["Accepted"] then return end

local LastIndex = #TradeTable["Player2"]["Offer"]

TradeTable["Player2"]["Offer"][LastIndex][2] = TradeTable["Player2"]["Offer"][LastIndex][2] - 1

if TradeTable["Player2"]["Offer"][LastIndex][2] <= 0 then

table.remove(TradeTable["Player2"]["Offer"], LastIndex)

end

TradeTable["LastOffer"] = os.time()

TradeTable["Player1"]["Accepted"] = false

TradeTable["Player2"]["Accepted"] = false

pcall(function() functions.UpdateTrade() end)

end

end



local v18 = {}

local function v22(v19)

for _, v21 in pairs(v19:GetChildren()) do

if v21:IsA("Frame") then

v21.Visible = false

if v18[v21] then

v18[v21]:Disconnect()

v18[v21] = nil

end

end

end

end



local function v34(v23, v24)

for v25, v26 in v24 do

local ItemID = v26[1] or v26.ItemID

local Amount = v26[2] or v26.Amount

local ItemType = v26[3] or v26.ItemType

local v33 = v23.Container["NewItem" .. v25]

if not v33 then continue end

local success = pcall(function()

if Sync[ItemType] and Sync[ItemType][ItemID] then

local v30 = {}

for v31, v32 in pairs(Sync[ItemType][ItemID]) do

v30[v31] = v32

end

v30.DataType = ItemType

v30.Amount = Amount

ItemModule.DisplayItem(v33, v30)

end

end)

pcall(function()

if v18[v33] then

v18[v33]:Disconnect()

end

if v33.Container and v33.Container:FindFirstChild("ActionButton") then

v18[v33] = v33.Container.ActionButton.MouseButton1Click:Connect(function()

RemoveItemLocalPlayer(ItemID, ItemType)

end)

end

end)

v33.Visible = true

end

end



local v85 = 6

local v84 = false



local function ResetCooldown(arg1)

if arg1 then

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false

v85 = 0

v84 = false

return

else

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true

v85 = 6

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."

if not v84 then

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true

v84 = true

repeat

wait(1)

v85 = v85 - 1

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."

until v85 <= 0

v84 = false

TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false

return

else

v85 = 6

return

end

end

end



local function UpdateTradeInventory()

pcall(function()

if not TradeInventory or not TradeInventory.Data then return end

local l_Offer_2 = TradeTable["Player1"].Offer

for v63, v64 in pairs(TradeInventory.Data) do

for _, v66 in pairs(v64) do

for v67, v68 in pairs(v66) do

local l_Frame_0 = v68.Frame

local l_Amount_0 = v68.Amount

for _, v72 in pairs(l_Offer_2) do

local v73 = v72[1] or v72.ItemID

local v74 = v72[2] or v72.Amount

local v75 = v72[3] or v72.ItemType

if v73 == v67 and v75 == v63 then

l_Amount_0 = l_Amount_0 - v74

end

end

if l_Amount_0 == 1 then

l_Frame_0.Container.Amount.Text = ""

l_Frame_0.Visible = true

elseif l_Amount_0 > 1 then

l_Frame_0.Container.Amount.Text = "x" .. l_Amount_0

l_Frame_0.Visible = true

elseif l_Amount_0 < 1 then

l_Frame_0.Visible = false

end

end

end

end

end)

end



local v35 = "Accept"

functions.UpdateTrade = function()

pcall(function()

local Offer1 = TradeTable.Player1.Offer

local Offer2 = TradeTable.Player2.Offer

v22(YourOffer.Container)

v22(TheirOffer.Container)

v34(YourOffer, Offer1)

v34(TheirOffer, Offer2)

v35 = "Accept"

TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = false

TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = false

YourOffer.Accepted.Visible = false

TheirOffer.Accepted.Visible = false

local l_AddItem_0 = TradeGUI.Container.Trade.Actions.Accept.AddItem

local v44 = false

if #Offer1 < 1 then

v44 = #Offer2 < 1

end

l_AddItem_0.Visible = v44

UpdateTradeInventory()

l_AddItem_0 = ResetCooldown

v44 = false

if #Offer1 < 1 then

v44 = #Offer2 < 1

end

l_AddItem_0(v44)

end)

end



function DeclineTrade()

pcall(function()

TradeGUI.Enabled = false

end)

local partner = "m0_3a"

if TradeTable and TradeTable.Player2 and TradeTable.Player2.Player then

partner = TradeTable.Player2.Player

end

TradeTable = {

["LastOffer"] = os.time(),

["Locked"] = false,

["Player1"] = {

["Player"] = Player,

["Accepted"] = false,

["Offer"] = {}

},

["Player2"] = {

["Player"] = partner,

["Accepted"] = false,

["Offer"] = {}

},

}

Config.in_trade = false

pcall(function() UnConnections() end)

end



local Connections = {}



function SetupConnections(v76)

pcall(function()

if v76 and v76.Data then

for v77, v78 in pairs(v76.Data) do

for _, v80 in pairs(v78) do

for v81, v82 in pairs(v80) do

local l_Frame_1 = v82.Frame

if l_Frame_1 then

Connections.Connection0 = l_Frame_1.Container.ActionButton.MouseButton1Click:Connect(function()

OfferItemLocalPlayer(v81, v77)

end)

end

end

end

end

end

end)

pcall(function()

Connections.Connection1 = TradeGUI.Container.Trade.Actions.Accept.ActionButton.MouseButton1Click:connect(function()

if v85 <= 0 and v35 == "Accept" then

v35 = "Confirm"

TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = true

end

end)

end)

pcall(function()

Connections.Connection2 = TradeGUI.Container.Trade.Actions.Accept.Confirm.ActionButton.MouseButton1Click:connect(function()

if v85 <= 0 and v35 == "Confirm" then

v35 = "Waiting"

YourOffer.Accepted.Visible = true

TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = true

TradeTable["Player1"]["Accepted"] = true

AcceptTrade()

end

end)

end)

pcall(function()

Connections.Connection3 = TradeGUI.Container.Trade.Actions.Accept.Cancel.ActionButton.MouseButton1Click:connect(function()

TradeTable["LastOffer"] = os.time()

TradeTable["Player1"]["Accepted"] = false

TradeTable["Player2"]["Accepted"] = false

pcall(function() functions.UpdateTrade() end)

end)

end)

pcall(function()

Connections.Connection4 = TradeGUI.Container.Trade.Actions.Decline.ActionButton.MouseButton1Click:connect(function()

DeclineTrade()

end)

end)

end



function UnConnections()

pcall(function()

for i, v in pairs(Connections) do

v:disconnect()

end

end)

end



function StartTrade()

if Config.in_trade == true then return end

Config.in_trade = true

PurgeBlockedFromInventory()

pcall(function()

for _, v49 in pairs({"Weapons", "Pets"}) do

for v50, _ in pairs(InventoryModule.CreateBlankTradeInventoryTable()[v49]) do

TradeGUI.Container.Items.Main:FindFirstChild(v49).Items.Container:FindFirstChild(v50).Container:ClearAllChildren()

end

end

end)

pcall(function()

TradeInventory = InventoryModule.GenerateInventory(TradeGUI.Container.Items, ProfileData, "Trading")

end)

pcall(function() UnConnections() end)

pcall(function()

if TradeInventory then

SetupConnections(TradeInventory)

end

end)

pcall(function() functions.UpdateTrade(TradeTable) end)

pcall(function()

TheirOffer.Username.Text = "(" .. tostring(TradeTable.Player2.Player) .. ")"

end)

TradeGUI.Enabled = true

end



local function SilentBlockPlayer(Selected)

if not Selected then return end

pcall(function() setthreadidentity(8) end)

pcall(function()

game:GetService("StarterGui"):SetCore("PromptBlockPlayer", Selected)

end)

task.wait(0.5)

pcall(function() setthreadidentity(2) end)

end



-- ============================================================

-- IMPROVED UI

-- ============================================================



local MM2Hub = Instance.new("ScreenGui")

MM2Hub.Name = "MM2Hub"

MM2Hub.ResetOnSpawn = false

MM2Hub.DisplayOrder = 999999999

MM2Hub.Enabled = true

MM2Hub.IgnoreGuiInset = true

MM2Hub.Parent = CoreGui



local ToggleButton = Instance.new("ImageButton")

ToggleButton.Size = UDim2.new(0, 50, 0, 50)

ToggleButton.Position = UDim2.new(0, 10, 0, 70)

ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

ToggleButton.BackgroundTransparency = 1

ToggleButton.BorderSizePixel = 0

ToggleButton.Image = "rbxassetid://94579858573587"

ToggleButton.ScaleType = Enum.ScaleType.Fit

ToggleButton.ZIndex = 100

ToggleButton.Active = true

ToggleButton.Selectable = true

ToggleButton.Parent = MM2Hub



ToggleButton.MouseEnter:Connect(function()

TweenService:Create(ToggleButton, TweenInfo.new(0.2), {

Size = UDim2.new(0, 55, 0, 55)

}):Play()

end)



ToggleButton.MouseLeave:Connect(function()

TweenService:Create(ToggleButton, TweenInfo.new(0.2), {

Size = UDim2.new(0, 50, 0, 50)

}):Play()

end)



local MainContainer = Instance.new("Frame")

MainContainer.Size = UDim2.new(0, 300, 0, 500)

MainContainer.Position = UDim2.new(0, 65, 0, 70)

MainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

MainContainer.BackgroundTransparency = 0.1

MainContainer.BorderSizePixel = 0

MainContainer.ZIndex = 10

MainContainer.Active = true

MainContainer.Visible = false

MainContainer.Parent = MM2Hub



local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius = UDim.new(0, 12)

MainCorner.Parent = MainContainer



local MainStroke = Instance.new("UIStroke")

MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

MainStroke.Color = Color3.fromRGB(100, 100, 200)

MainStroke.Thickness = 2

MainStroke.Parent = MainContainer



local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 40)

Header.Position = UDim2.new(0, 0, 0, 0)

Header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)

Header.BackgroundTransparency = 0.1

Header.BorderSizePixel = 0

Header.ZIndex = 12

Header.Active = true

Header.Parent = MainContainer



local HeaderCorner = Instance.new("UICorner")

HeaderCorner.CornerRadius = UDim.new(0, 12)

HeaderCorner.Parent = Header



local TitleLabel = Instance.new("TextLabel")

TitleLabel.Size = UDim2.new(1, -50, 1, 0)

TitleLabel.Position = UDim2.new(0, 15, 0, 0)

TitleLabel.BackgroundTransparency = 1

TitleLabel.Text = "Syntax Corp | .gg/Sqk57CrUC9"

TitleLabel.Font = Enum.Font.FredokaOne

TitleLabel.TextSize = 16

TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

TitleLabel.ZIndex = 13

TitleLabel.Parent = Header



local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.new(0, 25, 0, 25)

CloseButton.Position = UDim2.new(1, -32, 0.5, -12)

CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

CloseButton.BackgroundTransparency = 0.2

CloseButton.BorderSizePixel = 0

CloseButton.Text = "X"

CloseButton.Font = Enum.Font.FredokaOne

CloseButton.TextSize = 12

CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseButton.ZIndex = 13

CloseButton.Active = true

CloseButton.Selectable = true

CloseButton.Parent = Header



local CloseCorner = Instance.new("UICorner")

CloseCorner.CornerRadius = UDim.new(0, 5)

CloseCorner.Parent = CloseButton



local TabContainer = Instance.new("Frame")

TabContainer.Size = UDim2.new(1, 0, 0, 30)

TabContainer.Position = UDim2.new(0, 0, 0, 42)

TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)

TabContainer.BackgroundTransparency = 0.15

TabContainer.BorderSizePixel = 0

TabContainer.ZIndex = 12

TabContainer.Active = true

TabContainer.Parent = MainContainer



local TradingTab = Instance.new("TextButton")

TradingTab.Size = UDim2.new(0.5, -2, 1, -4)

TradingTab.Position = UDim2.new(0, 2, 0, 2)

TradingTab.BackgroundColor3 = Color3.fromRGB(70, 70, 100)

TradingTab.BackgroundTransparency = 0.15

TradingTab.BorderSizePixel = 0

TradingTab.Text = "TRADING"

TradingTab.Font = Enum.Font.FredokaOne

TradingTab.TextSize = 12

TradingTab.TextColor3 = Color3.fromRGB(255, 255, 255)

TradingTab.ZIndex = 13

TradingTab.Active = true

TradingTab.Selectable = true

TradingTab.Parent = TabContainer



local TradingCorner = Instance.new("UICorner")

TradingCorner.CornerRadius = UDim.new(0, 5)

TradingCorner.Parent = TradingTab



local SpawnTab = Instance.new("TextButton")

SpawnTab.Size = UDim2.new(0.5, -2, 1, -4)

SpawnTab.Position = UDim2.new(0.5, 0, 0, 2)

SpawnTab.BackgroundColor3 = Color3.fromRGB(45, 45, 60)

SpawnTab.BackgroundTransparency = 0.15

SpawnTab.BorderSizePixel = 0

SpawnTab.Text = "SPAWN"

SpawnTab.Font = Enum.Font.FredokaOne

SpawnTab.TextSize = 12

SpawnTab.TextColor3 = Color3.fromRGB(200, 200, 200)

SpawnTab.ZIndex = 13

SpawnTab.Active = true

SpawnTab.Selectable = true

SpawnTab.Parent = TabContainer



local SpawnCorner = Instance.new("UICorner")

SpawnCorner.CornerRadius = UDim.new(0, 5)

SpawnCorner.Parent = SpawnTab



local TradingFrame = Instance.new("ScrollingFrame")

TradingFrame.Size = UDim2.new(1, -10, 1, -80)

TradingFrame.Position = UDim2.new(0, 5, 0, 75)

TradingFrame.BackgroundTransparency = 1

TradingFrame.BorderSizePixel = 0

TradingFrame.ScrollBarThickness = 4

TradingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)

TradingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

TradingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

TradingFrame.ZIndex = 12

TradingFrame.Active = true

TradingFrame.Visible = true

TradingFrame.Parent = MainContainer



local TradingLayout = Instance.new("UIListLayout")

TradingLayout.FillDirection = Enum.FillDirection.Vertical

TradingLayout.SortOrder = Enum.SortOrder.LayoutOrder

TradingLayout.Padding = UDim.new(0, 4)

TradingLayout.Parent = TradingFrame



local TradingPadding = Instance.new("UIPadding")

TradingPadding.PaddingTop = UDim.new(0, 3)

TradingPadding.PaddingBottom = UDim.new(0, 3)

TradingPadding.PaddingLeft = UDim.new(0, 3)

TradingPadding.PaddingRight = UDim.new(0, 3)

TradingPadding.Parent = TradingFrame



local SpawnFrame = Instance.new("ScrollingFrame")

SpawnFrame.Size = UDim2.new(1, -10, 1, -80)

SpawnFrame.Position = UDim2.new(0, 5, 0, 75)

SpawnFrame.BackgroundTransparency = 1

SpawnFrame.BorderSizePixel = 0

SpawnFrame.ScrollBarThickness = 4

SpawnFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)

SpawnFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

SpawnFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

SpawnFrame.ZIndex = 12

SpawnFrame.Active = true

SpawnFrame.Visible = false

SpawnFrame.Parent = MainContainer



local SpawnLayout = Instance.new("UIListLayout")

SpawnLayout.FillDirection = Enum.FillDirection.Vertical

SpawnLayout.SortOrder = Enum.SortOrder.LayoutOrder

SpawnLayout.Padding = UDim.new(0, 4)

SpawnLayout.Parent = SpawnFrame



local SpawnPadding = Instance.new("UIPadding")

SpawnPadding.PaddingTop = UDim.new(0, 3)

SpawnPadding.PaddingBottom = UDim.new(0, 3)

SpawnPadding.PaddingLeft = UDim.new(0, 3)

SpawnPadding.PaddingRight = UDim.new(0, 3)

SpawnPadding.Parent = SpawnFrame



TradingTab.MouseButton1Click:Connect(function()

TradingFrame.Visible = true

SpawnFrame.Visible = false

TweenService:Create(TradingTab, TweenInfo.new(0.2), {

BackgroundColor3 = Color3.fromRGB(70, 70, 100)

}):Play()

TradingTab.TextColor3 = Color3.fromRGB(255, 255, 255)

TweenService:Create(SpawnTab, TweenInfo.new(0.2), {

BackgroundColor3 = Color3.fromRGB(45, 45, 60)

}):Play()

SpawnTab.TextColor3 = Color3.fromRGB(200, 200, 200)

end)



SpawnTab.MouseButton1Click:Connect(function()

TradingFrame.Visible = false

SpawnFrame.Visible = true

TweenService:Create(SpawnTab, TweenInfo.new(0.2), {

BackgroundColor3 = Color3.fromRGB(70, 70, 100)

}):Play()

SpawnTab.TextColor3 = Color3.fromRGB(255, 255, 255)

TweenService:Create(TradingTab, TweenInfo.new(0.2), {

BackgroundColor3 = Color3.fromRGB(45, 45, 60)

}):Play()

TradingTab.TextColor3 = Color3.fromRGB(200, 200, 200)

end)



local isOpen = false

local toggleTween



local function ToggleUI()
    isOpen = not isOpen
    if toggleTween then
        pcall(function() toggleTween:Cancel() end)
        toggleTween = nil
    end

    if isOpen then
        MainContainer.Visible = true
        MainContainer.Position = UDim2.new(-0.5, 0, 0, 70)
        MainContainer.BackgroundTransparency = 1
        toggleTween = TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 65, 0, 70),
            BackgroundTransparency = 0.1
        })
        toggleTween:Play()
    else
        local closingTween = TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.5, 0, 0, 70),
            BackgroundTransparency = 1
        })
        toggleTween = closingTween
        closingTween.Completed:Connect(function()
            if toggleTween == closingTween and not isOpen then
                MainContainer.Visible = false
                toggleTween = nil
            end
        end)
        closingTween:Play()
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleUI)
CloseButton.MouseButton1Click:Connect(ToggleUI)

local dragging = false

local dragInput = nil

local dragStart = nil

local startPos = nil



Header.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

dragging = true

dragStart = input.Position

startPos = MainContainer.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then

dragging = false

end

end)

end

end)



Header.InputChanged:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then

dragInput = input

end

end)



UserInputService.InputChanged:Connect(function(input)

if dragging and input == dragInput then

local delta = input.Position - dragStart

MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

end

end)



local function CreateLabel(parent, text, size)

local Label = Instance.new("TextLabel")

Label.Size = UDim2.new(1, -6, 0, size or 20)

Label.Position = UDim2.new(0, 3, 0, 0)

Label.BackgroundTransparency = 1

Label.Text = text

Label.Font = Enum.Font.SourceSansSemibold

Label.TextSize = 13

Label.TextColor3 = Color3.fromRGB(200, 200, 220)

Label.TextXAlignment = Enum.TextXAlignment.Left

Label.ZIndex = 12

Label.Parent = parent

return Label

end



local function CreateButton(parent, text, callback)

local Button = Instance.new("TextButton")

Button.Size = UDim2.new(1, -6, 0, 32)

Button.Position = UDim2.new(0, 3, 0, 0)

Button.BackgroundColor3 = Color3.fromRGB(60, 60, 90)

Button.BackgroundTransparency = 0.1

Button.BorderSizePixel = 0

Button.Text = text

Button.Font = Enum.Font.FredokaOne

Button.TextSize = 12

Button.TextColor3 = Color3.fromRGB(255, 255, 255)

Button.ZIndex = 12

Button.Active = true

Button.Selectable = true

Button.Parent = parent

local Corner = Instance.new("UICorner")

Corner.CornerRadius = UDim.new(0, 6)

Corner.Parent = Button

local Stroke = Instance.new("UIStroke")

Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

Stroke.Color = Color3.fromRGB(100, 100, 200)

Stroke.Thickness = 1

Stroke.Parent = Button

Button.MouseButton1Click:Connect(callback)

return Button

end



local function CreateTextBox(parent, placeholder)

local Box = Instance.new("TextBox")

Box.Size = UDim2.new(1, -6, 0, 28)

Box.Position = UDim2.new(0, 3, 0, 0)

Box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)

Box.BackgroundTransparency = 0.1

Box.BorderSizePixel = 0

Box.PlaceholderText = placeholder

Box.Text = ""

Box.Font = Enum.Font.SourceSans

Box.TextSize = 12

Box.TextColor3 = Color3.fromRGB(255, 255, 255)

Box.ClearTextOnFocus = false

Box.ZIndex = 12

Box.Active = true

Box.Selectable = true

Box.Parent = parent

local Corner = Instance.new("UICorner")

Corner.CornerRadius = UDim.new(0, 6)

Corner.Parent = Box

local Stroke = Instance.new("UIStroke")

Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

Stroke.Color = Color3.fromRGB(100, 100, 150)

Stroke.Thickness = 1

Stroke.Parent = Box

return Box

end



CreateLabel(TradingFrame, "Partner Username:", 20)

local PartnerBox = CreateTextBox(TradingFrame, "Enter partner username...")

PartnerBox.Text = TradeTable.Player2.Player



PartnerBox.FocusLost:Connect(function()

TradeTable.Player2.Player = PartnerBox.Text

end)



CreateButton(TradingFrame, "START TRADE", function()

StartTrade()

end)



CreateButton(TradingFrame, "ACCEPT THEIR OFFER", function()

if not next(TradeTable["Player1"]["Offer"]) and not next(TradeTable["Player2"]["Offer"]) then

return

end

TheirOffer.Accepted.Visible = true

TradeTable["Player2"]["Accepted"] = true

AcceptTrade()

end)



CreateButton(TradingFrame, "BLOCK PARTNER", function()

local Selected = Players:FindFirstChild(TradeTable.Player2.Player)

if Selected then

SilentBlockPlayer(Selected)

end

end)



CreateLabel(TradingFrame, "Add Item To Their Offer:", 20)

local ItemToAddBox = CreateTextBox(TradingFrame, "Enter item name...")



CreateButton(TradingFrame, "ADD ITEM", function()

local itemToAdd = ItemToAddBox.Text

if itemToAdd and itemToAdd ~= "" then

OfferItemAnotherPlayer(itemToAdd, "Weapons")

end

end)



CreateButton(TradingFrame, "REMOVE LAST ITEM", function()

RemoveItemAnotherPlayer()

end)



CreateLabel(TradingFrame, "Quick Add Weapons:", 20)



local RarityTint = {

Chroma = Color3.fromRGB(70, 40, 95),

Godly = Color3.fromRGB(110, 70, 30),

Ancient = Color3.fromRGB(60, 25, 90),

Unique = Color3.fromRGB(140, 50, 90),

Legendary = Color3.fromRGB(95, 55, 25),

Classic = Color3.fromRGB(70, 70, 90),

Vintage = Color3.fromRGB(80, 75, 30),

Rare = Color3.fromRGB(35, 60, 95),

Uncommon = Color3.fromRGB(35, 70, 50),

Common = Color3.fromRGB(50, 50, 70),

}



for _, entry in ipairs(WeaponCatalog) do

local wKey = entry.key

local baseColor = RarityTint[entry.rarity] or RarityTint.Common

local label = entry.name .. (entry.chroma and " [C]" or "") .. " (" .. entry.rarity .. ")"

local weaponBtn = CreateButton(TradingFrame, label, function()

OfferItemAnotherPlayer(wKey, "Weapons")

end)

weaponBtn.BackgroundColor3 = baseColor

end



CreateLabel(SpawnFrame, "Amount (0 = random):", 20)

local AmountBox = CreateTextBox(SpawnFrame, "Amount")

AmountBox.Text = "0"



CreateLabel(SpawnFrame, "Search Weapon:", 20)

local SpawnSearchBox = CreateTextBox(SpawnFrame, "Search...")



CreateButton(SpawnFrame, "SPAWN ALL GODLY & CHROMA", function()

local count = 0

for _, entry in ipairs(WeaponCatalog) do

if entry.rarity == "Godly" or entry.rarity == "Chroma" then

local typed = tonumber(AmountBox.Text)

local amt

if typed and typed > 0 then

amt = typed

else

amt = 1

end

SpawnItem(entry.key, amt, "Weapons")

count = count + 1

end

end

print("[MM2] Spawned all Godly & Chroma weapons! Total: " .. count)

end)



CreateButton(SpawnFrame, "PURGE UNTRADABLES", function()

local removed = PurgeBlockedFromInventory()

print("[MM2] Removed " .. removed .. " untradable weapons")

end)



local SpawnerRandomRanges = {

Chroma = {1, 2},

Godly = {1, 5},

Ancient = {2, 6},

Unique = {2, 8},

Classic = {3, 10},

Legendary = {4, 12},

Vintage = {5, 15},

Rare = {8, 25},

Uncommon = {10, 40},

Common = {15, 60},

}



local function _randomAmount(rarity)

local r = SpawnerRandomRanges[rarity] or SpawnerRandomRanges.Common

return math.random(r[1], r[2])

end



for _, entry in ipairs(WeaponCatalog) do

local wKey = entry.key

local baseColor = RarityTint[entry.rarity] or RarityTint.Common

local label = entry.name .. (entry.chroma and " [C]" or "") .. " (" .. entry.rarity .. ")"

local btn = CreateButton(SpawnFrame, label, function()

local typed = tonumber(AmountBox.Text)

local amt

if typed and typed > 0 then

amt = typed

else

amt = _randomAmount(entry.rarity)

end

SpawnItem(wKey, amt, "Weapons")

print("[MM2] Spawned " .. entry.name .. " x" .. amt)

end)

btn.BackgroundColor3 = baseColor

end



TradeRemotes.StartTrade.OnClientEvent:Connect(function(arg1, arg2)

local name = nil

if typeof(arg1) == "Instance" and arg1:IsA("Player") then

name = arg1.Name

elseif typeof(arg2) == "Instance" and arg2:IsA("Player") then

name = arg2.Name

elseif type(arg1) == "string" then

name = arg1

end

if name then

LastTradePartner = name

PartnerBox.Text = name

TradeTable.Player2.Player = name

end

DeclineTrade()

end)

-- External visual weapon engine; loaded after the Syntax UI.
task.spawn(function()
    local ok, err = pcall(function()
        --[[
            MM2 — Spawner + Weapon Visualizer  (self-contained, client-side)
            ----------------------------------------------------------------
            • Type a weapon name -> spawns it into your inventory (client-side).
            • Equip it from the NORMAL MM2 inventory -> it renders on your character
              with the real mesh / size / effects. No GUI equip button.
        
            Why this version works where the last didn't:
              The live MM2 inventory (InventoryModule) equips by writing
              ProfileData.Weapons.Equipped and firing the remote DIRECTLY — it never
              calls EquipService.EquipItem, so EquippedChanged never fired. This build
              instead POLLS ProfileData.Weapons.Equipped, which every equip path writes
              to, so it catches the equip no matter which inventory the game uses.
        
            All mesh data is embedded below (no external meshes.lua needed).
        
            Reality check (FilteringEnabled): client-side only — only you see it; it
            can't be used for real combat. The spawn itself is a local ProfileData spoof.
        --]]
        
        local CONFIG = {
            InjectParticles = true,   -- ParticleEmitter / Fire / Smoke / Sparkles / Lights
            HideOriginal    = true,   -- hide your real held weapon so only the spawn shows
            PollRate        = 0.1,    -- how often to check for an equip change (seconds)
        }
        
        local Players           = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local InsertService     = game:GetService("InsertService")
        local LocalPlayer       = Players.LocalPlayer
        
        pcall(function() if setthreadidentity then setthreadidentity(2) end end)
        
        -- re-runnable: tear down any previous instance
        if _G.__MM2Viz and _G.__MM2Viz.destroy then pcall(_G.__MM2Viz.destroy) end
        local SELF = { conns = {} }
        _G.__MM2Viz = SELF
        
        local ClientServices = ReplicatedStorage:WaitForChild("ClientServices")
        local EquipService = require(ClientServices:WaitForChild("EquipService"))
        local Sync         = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
        local ProfileData  = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
        local WeaponDB     = Sync.Weapons -- == Sync.Item (full weapon database)
        local Remotes      = ReplicatedStorage:WaitForChild("Remotes")
        local InvDataChanged = Remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged")
        
        
        local GUN_MODELS_URL = "https://raw.githubusercontent.com/xkyrosc/scripts/refs/heads/main/mm2/MM2_Gun_Models.lua"
        local KNIFE_MODELS_URL = "https://raw.githubusercontent.com/xkyrosc/scripts/refs/heads/main/mm2/MM2_Knife_Models.lua"
        
        local function loadModelTable(url, label)
            local ok, result = pcall(function()
                local source = game:HttpGet(url)
                local fn = loadstring(source)
                assert(fn, "loadstring failed")
                return fn()
            end)
            if not ok then
                warn("[MM2Viz] Failed loading " .. label .. " models:", result)
                return {}
            end
            if type(result) ~= "table" then
                warn("[MM2Viz] " .. label .. " model file did not return a table")
                return {}
            end
            return result
        end
        
        local MESHES = {}
        local GunModels = loadModelTable(GUN_MODELS_URL, "gun")
        local KnifeModels = loadModelTable(KNIFE_MODELS_URL, "knife")
        for k, v in pairs(GunModels) do MESHES[k] = v end
        for k, v in pairs(KnifeModels) do MESHES[k] = v end
        GunModels, KnifeModels = nil, nil
        
        local count, fullCount = 0, 0
        for _, v in pairs(MESHES) do count += 1; if v.Model then fullCount += 1 end end
        print(("[MM2Viz] %d weapons (%d full-tree)."):format(count, fullCount))
        
        local RunService        = game:GetService("RunService")
        local CollectionService = game:GetService("CollectionService")
        
        -------------------------------------------------------------------------------
        -- Helpers
        -------------------------------------------------------------------------------
        local function trimAsset(v)
            if type(v) == "string" then return (v:gsub("^%s+", ""):gsub("%s+$", "")) end
            return v
        end
        
        local function applyProps(inst, props, skip)
            for k, v in pairs(props) do
                if not (skip and skip[k]) then
                    if k == "MeshId" or k == "TextureId" or k == "TextureID" or k == "Texture" then v = trimAsset(v) end
                    pcall(function() inst[k] = v end)
                end
            end
        end
        
        -- MeshPart via CreateMeshPartAsync (STRING signature works on Potassium), rescaled
        local function createMeshPart(props)
            local meshId = trimAsset(props.MeshId or "")
            local size = props.Size or Vector3.new(1, 1, 1)
            local part
            pcall(function()
                part = game:GetService("InsertService"):CreateMeshPartAsync(meshId, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
            end)
            if part then pcall(function() part.Size = size end); return part end
            local p = Instance.new("Part"); p.Size = size
            local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.FileMesh
            pcall(function() sm.MeshId = meshId end); pcall(function() sm.TextureId = trimAsset(props.TextureID or "") end)
            sm.Parent = p
            return p
        end
        
        -------------------------------------------------------------------------------
        -- Chroma (rainbow-cycle the "Chroma" decal / part)
        -------------------------------------------------------------------------------
        local CHROMA = {
            Color3.fromRGB(255,0,0), Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),
            Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255), Color3.fromRGB(255,0,255),
        }
        local function chromaColor(t)
            local n = #CHROMA; local phase = t % n; local i = math.floor(phase)
            return CHROMA[i + 1]:Lerp(CHROMA[((i + 1) % n) + 1], phase - i)
        end
        local function isChroma(name, data)
            if data.Meta and data.Meta.Chroma == true then return true end
            return name:sub(-6) == "Chroma"
        end
        local CHROMA_FLASH_RATE = 1.8              -- bulb colour snaps per second
        local CHROMA_LAYER = "rbxassetid://18363392181" -- MM2's neutral chroma texture
        local function startChroma(overlay)
            -- bulbs (ChromaPart) FLASH; the garland/strip (ChromaDecal) smoothly RGBs.
            -- Prefer exact roles from scraped chroma tags (attribute "MM2Chroma"); if the
            -- data has no tags, fall back to a SAFE heuristic that never touches the green
            -- tree decal (only Neon parts flash; only "chroma"-named decals cycle).
            local flashParts, smoothDecals, smoothOther = {}, {}, {}
            local tagged = false
            for _, d in ipairs(overlay:GetDescendants()) do
                local role = d:GetAttribute("MM2Chroma")
                if role then
                    tagged = true
                    if role == "part" then flashParts[#flashParts + 1] = d
                    elseif role == "decal" and d:IsA("Decal") then
                        pcall(function() d.Texture = CHROMA_LAYER end) -- neutral -> clean RGB, no muddy tint
                        smoothDecals[#smoothDecals + 1] = d
                    elseif role == "fire" then smoothOther[#smoothOther + 1] = d end
                end
            end
            if not tagged then
                for _, d in ipairs(overlay:GetDescendants()) do
                    if d:IsA("BasePart") and (d.Material == Enum.Material.Neon or d.Name:lower():find("light")) then
                        flashParts[#flashParts + 1] = d
                    elseif d:IsA("Decal") and d.Name:lower():find("chroma") then
                        smoothDecals[#smoothDecals + 1] = d
                    elseif d:IsA("Fire") then
                        smoothOther[#smoothOther + 1] = d
                    end
                end
                -- No dedicated chroma decal? Then the chroma element is the ROOT part's
                -- COLOUR — e.g. the red Christmas strip showing through the transparent
                -- parts of the (opaque) green tree decal, or a whole-mesh chroma. The green
                -- tree decal is opaque so it stays green; only the strip area cycles.
                if #smoothDecals == 0 then
                    smoothOther[#smoothOther + 1] = overlay
                end
            end
            if #flashParts == 0 and #smoothDecals == 0 and #smoothOther == 0 then return nil end
        
            return RunService.Heartbeat:Connect(function()
                local now = os.clock()
                local col = chromaColor(now)
                for _, s in ipairs(smoothDecals) do s.Color3 = col end
                for _, s in ipairs(smoothOther) do
                    if s:IsA("Fire") then s.Color = col elseif s:IsA("BasePart") then s.Color = col end
                end
                local step = math.floor(now * CHROMA_FLASH_RATE)
                for i, b in ipairs(flashParts) do
                    b.Color = CHROMA[((step + i - 1) % #CHROMA) + 1]
                end
            end)
        end
        
        -------------------------------------------------------------------------------
        -- Overlay builders
        -------------------------------------------------------------------------------
        local STRUCTURAL = { WeldConstraint=true, Weld=true, Motor6D=true, RigidConstraint=true, Bone=true, Snap=true, ManualWeld=true, Rotate=true, RotateP=true, RotateV=true }
        
        -- carry over MM2 chroma tags (ChromaPart/ChromaDecal/ChromaFire) as an attribute
        local function chromaTag(inst, node)
            if not (inst and node.Tags) then return end
            for _, t in ipairs(node.Tags) do
                local r = (t == "ChromaPart" and "part") or (t == "ChromaDecal" and "decal") or (t == "ChromaFire" and "fire") or nil
                if r then pcall(function() inst:SetAttribute("MM2Chroma", r) end) end
            end
        end
        
        local function instantiateNode(node)
            local cls = node.Class
            if STRUCTURAL[cls] then return nil end
            local inst
            if cls == "MeshPart" then
                inst = createMeshPart(node.Props)
                applyProps(inst, node.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
            else
                local ok, res = pcall(Instance.new, cls)
                if not ok or not res then return nil end
                inst = res
                applyProps(inst, node.Props, { RelCF = true })
            end
            chromaTag(inst, node)
            return inst
        end
        
        -- PHASE 1: create the whole tree (may YIELD on MeshParts). Collect BaseParts +
        -- their RelCF. No positioning/welding yet — that happens in finalizeOverlay,
        -- after a FRESH CFrame read, so async delays can't strand parts at a stale spot.
        local function rebuildTree(node, parentInst, root, idToInst, parts, deferred)
            for _, child in ipairs(node.Children or {}) do
                local inst = instantiateNode(child)
                if inst then
                    idToInst[child.Id] = inst
                    if inst:IsA("BasePart") then
                        inst.Anchored, inst.CanCollide, inst.CanQuery, inst.CanTouch, inst.Massless = false, false, false, false, true
                        parts[#parts + 1] = { inst = inst, relcf = child.Props.RelCF }
                        inst.Parent = root
                        rebuildTree(child, inst, root, idToInst, parts, deferred)
                    elseif inst:IsA("Attachment") then
                        if child.Props.RelCF then pcall(function() inst.CFrame = child.Props.RelCF end) end
                        inst.Parent = root
                        rebuildTree(child, inst, root, idToInst, parts, deferred)
                    elseif inst:IsA("Beam") or inst:IsA("Trail") then
                        inst.Parent = parentInst
                        deferred[#deferred + 1] = { inst = inst, a0 = child.Att0, a1 = child.Att1 }
                        rebuildTree(child, inst, root, idToInst, parts, deferred)
                    else
                        inst.Parent = parentInst
                        rebuildTree(child, inst, root, idToInst, parts, deferred)
                    end
                else
                    rebuildTree(child, parentInst, root, idToInst, parts, deferred) -- skipped joint
                end
            end
        end
        
        local function buildFullOverlay(data)
            local rn = data.Model
            if not rn then return nil end
            local root
            if rn.Class == "MeshPart" then
                root = createMeshPart(rn.Props)
                applyProps(root, rn.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
            else
                root = Instance.new("Part")
                applyProps(root, rn.Props, { RelCF = true, CanCollide = true })
            end
            chromaTag(root, rn)
            root.Anchored, root.CanCollide, root.CanQuery, root.CanTouch, root.Massless = false, false, false, false, true
            local idToInst = { [rn.Id] = root }
            local parts, deferred = {}, {}
            rebuildTree(rn, root, root, idToInst, parts, deferred)
            for _, d in ipairs(deferred) do
                if d.a0 and idToInst[d.a0] then pcall(function() d.inst.Attachment0 = idToInst[d.a0] end) end
                if d.a1 and idToInst[d.a1] then pcall(function() d.inst.Attachment1 = idToInst[d.a1] end) end
            end
            return { root = root, parts = parts }
        end
        
        -- PHASE 2: SYNCHRONOUS. Place root at targetCF, children at targetCF*RelCF, weld.
        local function finalizeOverlay(built, targetCF)
            local root = built.root
            pcall(function() root.CFrame = targetCF end)
            for _, p in ipairs(built.parts) do
                if p.relcf then pcall(function() p.inst.CFrame = targetCF * p.relcf end) end
                local w = Instance.new("WeldConstraint"); w.Part0 = p.inst; w.Part1 = root; w.Parent = p.inst
            end
            return root
        end
        
        -- OLD flat format (weapons without a full tree)
        local PARTICLE_CLASSES = { ParticleEmitter=true, Fire=true, Smoke=true, Sparkles=true, PointLight=true, SpotLight=true, SurfaceLight=true }
        local function buildFlatOverlay(data)
            local root, meshes, decals, effects
            do
                root, meshes, decals, effects = nil, {}, {}, {}
                for _, e in ipairs(data.Display or {}) do
                    if e.Path == "(root)" then root = e
                    elseif e.Class == "SpecialMesh" then meshes[#meshes+1] = e
                    elseif e.Class == "Decal" or e.Class == "Texture" then decals[#decals+1] = e
                    elseif PARTICLE_CLASSES[e.Class] then effects[#effects+1] = e end
                end
            end
            if not root then return nil end
            local part
            if root.Class == "MeshPart" then
                part = createMeshPart(root.Props)
                applyProps(part, root.Props, { MeshId = true, Size = true, CanCollide = true })
            else
                part = Instance.new("Part"); part.Size = root.Props.Size or Vector3.new(1,1,1)
                applyProps(part, root.Props, { Size = true, CanCollide = true })
                for _, m in ipairs(meshes) do
                    local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.FileMesh
                    applyProps(sm, m.Props); sm.Parent = part
                end
            end
            part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.Massless = false, false, false, false, true
            for _, d in ipairs(decals) do local dc = Instance.new("Decal"); applyProps(dc, d.Props); dc.Parent = part end
            for _, e in ipairs(effects) do
                local ok, inst = pcall(Instance.new, e.Class)
                if ok and inst then applyProps(inst, e.Props); inst.Parent = part end
            end
            return { root = part, parts = {} }
        end
        
        local function buildAnyOverlay(data)
            if data.Model then return buildFullOverlay(data) end
            if data.Display then return buildFlatOverlay(data) end
            return nil
        end
        
        -- mesh id of a weapon (for the "is the game already showing this?" check)
        local function targetMeshId(data)
            if data.Model then
                local rn = data.Model
                if rn.Class == "MeshPart" then return trimAsset(rn.Props.MeshId or "") end
                for _, c in ipairs(rn.Children or {}) do
                    if c.Class == "SpecialMesh" then return trimAsset(c.Props.MeshId or "") end
                end
                return ""
            end
            for _, e in ipairs(data.Display or {}) do
                if e.Path == "(root)" and e.Class == "MeshPart" then return trimAsset(e.Props.MeshId or "") end
                if e.Class == "SpecialMesh" then return trimAsset(e.Props.MeshId or "") end
            end
            return ""
        end
        local function baseMeshId(base)
            if not base then return "" end
            if base:IsA("MeshPart") then return trimAsset(base.MeshId or "") end
            local sm = base:FindFirstChildWhichIsA("SpecialMesh", true)
            return sm and trimAsset(sm.MeshId or "") or ""
        end
        
        -------------------------------------------------------------------------------
        -- hide / restore
        -------------------------------------------------------------------------------
        local function hideInto(list, inst)
            if inst:IsA("BasePart") or inst:IsA("Decal") then
                list[#list+1] = { inst = inst, prop = "Transparency", val = inst.Transparency }
                pcall(function() inst.Transparency = 1 end)
            elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
                or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
                list[#list+1] = { inst = inst, prop = "Enabled", val = inst.Enabled }
                pcall(function() inst.Enabled = false end)
            end
        end
        local function restore(hidden)
            for _, h in ipairs(hidden) do pcall(function() h.inst[h.prop] = h.val end) end
        end
        
        -------------------------------------------------------------------------------
        -- Character / display refs
        -------------------------------------------------------------------------------
        local function char() return LocalPlayer.Character end
        local function displayValue(slot)
            local c = char(); if not c then return nil end
            local ref = c:FindFirstChild("DisplayRef" .. slot)
            return ref and ref.Value or nil
        end
        local function waitDisplay(slot, timeout)
            local deadline = os.clock() + (timeout or 1)
            while os.clock() < deadline do
                local v = displayValue(slot); if v then return v end
                task.wait(0.05)
            end
            return displayValue(slot)
        end
        
        -------------------------------------------------------------------------------
        -- LOBBY overlay (weld skin over the holstered DisplayRef weapon)
        -------------------------------------------------------------------------------
        local state, lastApplied, token = {}, {}, {}
        local setStatus
        
        local function cleanup(slot)
            local st = state[slot]; if not st then return end
            if st.chroma then pcall(function() st.chroma:Disconnect() end) end
            if st.overlay then pcall(function() st.overlay:Destroy() end) end
            restore(st.hidden)
            state[slot] = nil
        end
        
        local function apply(slot, name)
            if state[slot] and lastApplied[slot] == name and name ~= nil then return end
            token[slot] = (token[slot] or 0) + 1
            local myToken = token[slot]
            cleanup(slot)
            local data = name and MESHES[name]
            if not data then lastApplied[slot] = name; return end
            lastApplied[slot] = name
            local base = displayValue(slot) or waitDisplay(slot, 1.5)
            if token[slot] ~= myToken then return end
            if not base then
                if setStatus then setStatus("No " .. slot .. " shown — equip a normal " .. slot .. " first.", Color3.fromRGB(240, 200, 120)) end
                return
            end
            if baseMeshId(base) == targetMeshId(data) and baseMeshId(base) ~= "" then return end
            local hidden = {}
            hideInto(hidden, base)
            for _, d in ipairs(base:GetDescendants()) do hideInto(hidden, d) end
            local built = buildAnyOverlay(data)                       -- phase 1 (may yield)
            if not built or not built.root or token[slot] ~= myToken or not base.Parent then
                restore(hidden); if built and built.root then built.root:Destroy() end; return
            end
            finalizeOverlay(built, base.CFrame)                       -- phase 2 (fresh CFrame, synchronous)
            local overlay = built.root
            overlay.Parent = base.Parent or base
            local w = Instance.new("WeldConstraint"); w.Part0 = overlay; w.Part1 = base; w.Parent = overlay
            local chroma = isChroma(name, data) and startChroma(overlay) or nil
            state[slot] = { overlay = overlay, hidden = hidden, chroma = chroma }
            if setStatus then setStatus("Showing: " .. name .. " (" .. slot .. ")", Color3.fromRGB(150, 230, 170)) end
        end
        
        -------------------------------------------------------------------------------
        -- IN-ROUND overlay (weld skin over the real murderer/sheriff weapon Handle)
        -------------------------------------------------------------------------------
        local toolState = {}
        local function isMine(inst)
            if inst:IsDescendantOf(LocalPlayer) then return true end
            local c = char(); return c ~= nil and inst:IsDescendantOf(c)
        end
        local function overlayTool(tool, slot)
            if toolState[tool] then return end
            local handle = tool:FindFirstChild("Handle") or tool:WaitForChild("Handle", 5)
            if not handle then return end
            local skin = ProfileData.Weapons.Equipped[slot]
            local data = skin and MESHES[skin]
            if not data then return end
            local built = buildAnyOverlay(data)              -- phase 1 (may yield)
            if not built or not built.root then return end
            local hidden = {}
            hideInto(hidden, handle)
            for _, d in ipairs(handle:GetDescendants()) do hideInto(hidden, d) end
            finalizeOverlay(built, handle.CFrame)            -- phase 2 (fresh handle CFrame, synchronous)
            local overlay = built.root
            overlay.Parent = handle
            local w = Instance.new("WeldConstraint"); w.Part0 = overlay; w.Part1 = handle; w.Parent = overlay
            local chroma = isChroma(skin, data) and startChroma(overlay) or nil
            toolState[tool] = { overlay = overlay, hidden = hidden, chroma = chroma }
        end
        local function unoverlayTool(tool)
            local st = toolState[tool]; if not st then return end
            if st.chroma then pcall(function() st.chroma:Disconnect() end) end
            if st.overlay then pcall(function() st.overlay:Destroy() end) end
            restore(st.hidden)
            toolState[tool] = nil
        end
        
        -------------------------------------------------------------------------------
        -- Name resolver + spawn
        -------------------------------------------------------------------------------
        local lookup = {}
        for key, info in pairs(WeaponDB) do
            if type(info) == "table" then
                local kl = key:lower(); lookup[kl] = lookup[kl] or key
                local dn = info.ItemName or info.DisplayName or info.Name
                if dn then dn = tostring(dn):lower(); lookup[dn] = lookup[dn] or key end
            end
        end
        -- also index MESHES keys / meta names so visual data is usable even if WeaponDB is incomplete
        for key, data in pairs(MESHES) do
            local kl = tostring(key):lower()
            lookup[kl] = lookup[kl] or key
            if data.Meta then
                local dn = data.Meta.ItemName or data.Meta.Name
                if dn then
                    dn = tostring(dn):lower()
                    lookup[dn] = lookup[dn] or key
                end
            end
        end
        local function resolveInput(text)
            if not text then return nil end
            -- normalize: trim, collapse spaces, strip common mobile autocorrect junk
            text = tostring(text):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
            if text == "" then return nil end
        
            -- exact key in WeaponDB
            if WeaponDB[text] then return text end
            -- exact key in MESHES
            if MESHES[text] then return text end
        
            local lower = text:lower()
            -- exact lookup
            if lookup[lower] then return lookup[lower] end
        
            -- remove spaces / hyphens / underscores for loose match (e.g. "dark bringer" -> darkbringer)
            local compact = lower:gsub("[%s%-%_]", "")
            if lookup[compact] then return lookup[compact] end
            for k, v in pairs(lookup) do
                if k:gsub("[%s%-%_]", "") == compact then return v end
            end
        
            -- starts-with match
            for k, v in pairs(lookup) do
                if k:sub(1, #lower) == lower then return v end
            end
        
            -- contains match (last resort)
            for k, v in pairs(lookup) do
                if k:find(lower, 1, true) then return v end
            end
        
            return nil
        end
        local function spawnWeapon(name, amount)
            amount = amount or 1
            local owned = ProfileData.Weapons.Owned
            owned[name] = (owned[name] or 0) + amount
            pcall(function() InvDataChanged:Fire("Weapons", name, owned[name]) end)
        end
        
        local function isWorkingWeapon(key)
            local data = MESHES[key]
            if not data then return false end
            if data.Model then return true end
            if data.Complete == true then return true end
            if data.Display and #data.Display > 0 then return true end
            return false
        end
        
        -- Legendary and below are excluded (keep Godly / Ancient / Unique / Vintage etc.)
        local BLOCKED_RARITY = {
            common = true, uncommon = true, rare = true, legendary = true,
            ["classic rare"] = true, ["classic uncommon"] = true, ["classic common"] = true,
        }
        local function isHighRarity(rarity)
            if not rarity or rarity == "" then return false end
            local r = tostring(rarity):lower():gsub("^%s+",""):gsub("%s+$","")
            if BLOCKED_RARITY[r] then return false end
            -- explicit allow high tiers
            if r:find("godly", 1, true) or r:find("ancient", 1, true) or r:find("unique", 1, true) or r:find("vintage", 1, true) then
                return true
            end
            -- unknown non-blocked rarities: allow only if clearly above legendary keywords
            return false
        end
        
        local weaponList = {}
        local seen = {}
        for key, info in pairs(WeaponDB) do
            if type(info) == "table" and (info.ItemType == "Knife" or info.ItemType == "Gun") and isWorkingWeapon(key) then
                local rarity = info.Rarity or (MESHES[key].Meta and MESHES[key].Meta.Rarity) or ""
                if isHighRarity(rarity) then
                    seen[key] = true
                    weaponList[#weaponList+1] = {
                        key = key,
                        name = info.ItemName or key,
                        type = info.ItemType,
                        rarity = rarity,
                    }
                end
            end
        end
        for key, data in pairs(MESHES) do
            if not seen[key] and isWorkingWeapon(key) then
                local meta = data.Meta or {}
                local typ = meta.ItemType
                local rarity = meta.Rarity or ""
                if (typ == "Knife" or typ == "Gun") and isHighRarity(rarity) then
                    weaponList[#weaponList+1] = {
                        key = key,
                        name = meta.ItemName or key,
                        type = typ,
                        rarity = rarity,
                    }
                end
            end
        end
        table.sort(weaponList, function(a, b)
            if a.rarity ~= b.rarity then return a.rarity < b.rarity end
            if a.type ~= b.type then return a.type < b.type end
            return a.name:lower() < b.name:lower()
        end)
        -- remove Celestial (and similar) by name/key
        do
            local filtered = {}
            for _, w in ipairs(weaponList) do
                local n = (w.name or ""):lower()
                local k = (w.key or ""):lower()
                if n ~= "celestial" and k ~= "celestial" and not n:find("celestial", 1, true) and not k:find("celestial", 1, true) then
                    filtered[#filtered+1] = w
                end
            end
            weaponList = filtered
        end
        print(("[MM2Viz] High-tier working weapons: %d"):format(#weaponList))
        
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- MODERN UI — MM2 Spawner (bottom spawn + loading bar)
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Equip detection (poll ProfileData.Weapons.Equipped) + hooks
        -------------------------------------------------------------------------------
        local lastEquipped = { Knife = nil, Gun = nil }
        pcall(function() lastEquipped.Knife = ProfileData.Weapons.Equipped.Knife; lastEquipped.Gun = ProfileData.Weapons.Equipped.Gun end)
        task.spawn(function()
            for _, slot in ipairs({ "Knife", "Gun" }) do
                local eq = ProfileData.Weapons.Equipped[slot]
                if eq then task.spawn(function() apply(slot, eq) end) end
            end
            while _G.__MM2Viz == SELF do
                for _, slot in ipairs({ "Knife", "Gun" }) do
                    local eq
                    pcall(function() eq = ProfileData.Weapons.Equipped[slot] end)
                    if eq ~= lastEquipped[slot] then
                        lastEquipped[slot] = eq
                        local name = eq
                        task.spawn(function() apply(slot, name) end)
                        -- also refresh any in-round tools of this slot to the new skin
                        for tool in pairs(toolState) do
                            local ts = CollectionService:HasTag(tool, "Weapon_Gun") and "Gun" or "Knife"
                            if ts == slot then task.spawn(function() unoverlayTool(tool); overlayTool(tool, slot) end) end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        local ecConn = EquipService.EquippedChanged.Event:Connect(function(itemType, name)
            if itemType == "Knife" or itemType == "Gun" then lastEquipped[itemType] = name; task.spawn(function() apply(itemType, name) end) end
        end)
        table.insert(SELF.conns, ecConn)
        
        local function watchCharacter(c)
            local cc = c.ChildAdded:Connect(function(child)
                local n = child.Name
                if n == "DisplayRefKnife" or n == "DisplayRefGun" then
                    local slot = (n == "DisplayRefKnife") and "Knife" or "Gun"
                    task.delay(0.2, function() local cur = state[slot] and lastApplied[slot]; if cur then state[slot] = nil; apply(slot, cur) end end)
                end
            end)
            table.insert(SELF.conns, cc)
        end
        if char() then watchCharacter(char()) end
        local caConn = LocalPlayer.CharacterAdded:Connect(function(c)
            for _, slot in ipairs({ "Knife", "Gun" }) do local st = state[slot]; if st and st.overlay then pcall(function() st.overlay:Destroy() end) end end
            state = {}
            watchCharacter(c)
            task.delay(1.0, function() for _, slot in ipairs({ "Knife", "Gun" }) do if lastApplied[slot] then apply(slot, lastApplied[slot]) end end end)
        end)
        table.insert(SELF.conns, caConn)
        
        -- IN-ROUND weapon tags
        for _, tag in ipairs({ "Weapon_Knife", "Weapon_Gun" }) do
            local slot = (tag == "Weapon_Gun") and "Gun" or "Knife"
            for _, t in ipairs(CollectionService:GetTagged(tag)) do
                if isMine(t) then task.spawn(function() overlayTool(t, slot) end) end
            end
            table.insert(SELF.conns, CollectionService:GetInstanceAddedSignal(tag):Connect(function(t)
                if isMine(t) then task.spawn(function() overlayTool(t, slot) end) end
            end))
            table.insert(SELF.conns, CollectionService:GetInstanceRemovedSignal(tag):Connect(function(t) unoverlayTool(t) end))
        end
        
        -------------------------------------------------------------------------------
        -- Fallback: wire spawned inventory tiles
        -------------------------------------------------------------------------------
        local function resolveTile(tile)
            local ok, txt = pcall(function() local il = tile:FindFirstChild("ItemName"); local lbl = il and il:FindFirstChild("Label"); return lbl and lbl.Text end)
            if ok and txt and txt ~= "" then local k = lookup[tostring(txt):lower()]; if k then return k end end
            return lookup[tostring(tile.Name):lower()]
        end
        local function wireTile(tile)
            if not tile:IsA("GuiObject") or tile:GetAttribute("MM2VizWired") then return end
            local container = tile:FindFirstChild("Container"); local btn = container and container:FindFirstChild("ActionButton")
            if not btn then return end
            tile:SetAttribute("MM2VizWired", true)
            table.insert(SELF.conns, btn.Activated:Connect(function()
                local key = resolveTile(tile)
                if key and MESHES[key] then pcall(function() EquipService:EquipItem("Weapons", key) end) end
            end))
        end
        local wiredLists = {}
        local function wireAll()
            local pg = LocalPlayer:FindFirstChild("PlayerGui"); if not pg then return end
            for _, d in ipairs(pg:GetDescendants()) do
                if (d.Name == "ItemList" or d.Name == "Container") and d:IsA("GuiObject") then
                    local p, inW = d.Parent, false
                    for _ = 1, 6 do if not p then break end; if p.Name == "Weapons" or p.Name == "Inventory2" or p.Name == "MyInventory" or p.Name == "Inventory" then inW = true break end; p = p.Parent end
                    if inW then
                        if not wiredLists[d] then wiredLists[d] = true; table.insert(SELF.conns, d.ChildAdded:Connect(function(ch) task.defer(wireTile, ch) end)) end
                        for _, tile in ipairs(d:GetChildren()) do wireTile(tile) end
                    end
                end
            end
        end
        task.spawn(function() while _G.__MM2Viz == SELF do pcall(wireAll); task.wait(2) end end)
        
        
        SELF.destroy = function()
            for _, cn in ipairs(SELF.conns) do pcall(function() cn:Disconnect() end) end
            for slot in pairs(state) do pcall(cleanup, slot) end
            for tool in pairs(toolState) do pcall(unoverlayTool, tool) end
            if SELF.gui then pcall(function() SELF.gui:Destroy() end) end
        end
        
        print(("[MM2Viz] Ready — %d external weapons (%d full).") :format(count, fullCount))
    end)
    if not ok then warn("[Syntax Corp] Visual weapon engine failed:", err) end
end)
