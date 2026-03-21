if _G.Started then return end
_G.Started = true

local defaultConfig = {
    ["Raid Settings"] = {
        Enabled = true, Difficulty = 1, OpenLeprechaunChest = false,
        ["Boss Settings"] = { Enabled = true, TargetBosses = {"Boss 1", "Boss 2", "Boss 3"}, UpgradeBossChests = true },
        ["Egg Settings"] = { Enabled = true, MinimumEggMulti = 500, MinimumLuckyCoins = "1m", MaxOpenTime = 30 },
    },
    ["Webhook"] = { url = "", ["Discord Id to ping"] = {""} },
    ["UpgradeSettings"] = {
		Enabled = true,
        LuckyRaidXP                 = { priority = 1, priority_upgrade = 13, maxTier = 17, required = true },
        LuckyRaidDamage             = { priority = 2, priority_upgrade = 15, maxTier = 17, required = true },
        LuckyRaidAttackSpeed        = { priority = 3, priority_upgrade = 7,  maxTier = 10, required = true },
        LuckyRaidPets               = { priority = 4, priority_upgrade = 10, maxTier = 10, required = true },
        LuckyRaidTitanicChest       = { priority = 10, maxTier = 99 }, LuckyRaidHugeChest = { priority = 11, maxTier = 99 },
        LuckyRaidBossHugeChances    = { priority = 12, maxTier = 99 }, LuckyRaidBossTitanicChances = { priority = 13, maxTier = 99 },
        LuckyRaidBetterLoot      = { enabled = false }, LuckyRaidPetSpeed = { enabled = false }, LuckyRaidMoreCurrency = { enabled = false },
        LuckyRaidEggCost         = { enabled = false }, LuckyRaidKeyDrops = { enabled = false },
    },
}

local function mergeConfig(default, user)
    local result = {}
    for k, v in pairs(default) do
        if type(v) == "table" and type(user[k]) == "table" then result[k] = mergeConfig(v, user[k])
        elseif user[k] ~= nil then result[k] = user[k] else result[k] = v end
    end
    for k, v in pairs(user) do if result[k] == nil then result[k] = v end end
    return result
end

local Settings = mergeConfig(defaultConfig, getgenv().Settings or {})
local Raid = Settings["Raid Settings"]
local Webhook = Settings["Webhook"]

local SuffixesLower = {"k", "m", "b", "t"}
local SuffixesUpper = {"K", "M", "B", "T"}
local function RemoveSuffix(Amount)
	local a, Suffix = Amount:gsub("%a", ""), Amount:match("%a")	
	local b = table.find(SuffixesUpper, Suffix) or table.find(SuffixesLower, Suffix) or 0
	return tonumber(a) * math.pow(10, b * 3)
end
if type(Raid["Egg Settings"].MinimumLuckyCoins) ~= "number" then
	Raid["Egg Settings"].MinimumLuckyCoins = RemoveSuffix(Raid["Egg Settings"].MinimumLuckyCoins)
end

local function load(url, file)
    local path = "Hasty-Utils/" .. file
    local ok, res = pcall(game.HttpGet, game, url)
    if ok and res then
        if not isfolder("Hasty-Utils") then makefolder("Hasty-Utils") end
        writefile(path, res)
        return loadstring(res)()
    end
    return loadstring(readfile(path))()
end

local vm = load("https://raw.githubusercontent.com/Paule1248/Open-Source/refs/heads/main/Utils/VariablesManager", "VariablesManager.lua")

--====================================================================--
--//                   PIRA UI FULLSCREEN                           //--
--====================================================================--
local FarmUI = {}
FarmUI.__index = FarmUI

function FarmUI.new(Config)
	local Self = setmetatable({}, FarmUI)
	Self.Player = game.Players.LocalPlayer
	Self.GuiName = "PiraFullscreenGui"
	Self.Elements = {}
	Self.Parent = game:GetService("CoreGui")
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = Self.GuiName
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = Self.Parent
	ScreenGui.ResetOnSpawn = false
	Self.ScreenGui = ScreenGui

    -- MÀN HÌNH ĐEN TOÀN MÀN HÌNH
	local Background = Instance.new("Frame")
	Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Background.BorderColor3 = Color3.fromRGB(255, 0, 255)
	Background.BorderMode = Enum.BorderMode.Inset
	Background.Parent = ScreenGui
	Background.Size = UDim2.new(1, 0, 1, 0)
	Background.Position = UDim2.new(0.5, 0, 0.5, 0)
	Background.AnchorPoint = Vector2.new(0.5, 0.5)

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 1, 0)
	Container.BackgroundTransparency = 1
	Container.Parent = Background
	Self.Container = Container

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0.015, 0)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Container

    -- NÚT TẮT BẬT MÀN HÌNH
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
    ToggleBtn.Position = UDim2.new(1, -20, 1, -20)
    ToggleBtn.AnchorPoint = Vector2.new(1, 1)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ToggleBtn.Text = "👁"
    ToggleBtn.TextSize = 22
    ToggleBtn.Parent = ScreenGui
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(1, 0)
    UICornerBtn.Parent = ToggleBtn
    
    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.fromRGB(255, 0, 255)
    UIStrokeBtn.Thickness = 2
    UIStrokeBtn.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Background.Visible = not Background.Visible
        ToggleBtn.Text = Background.Visible and "👁" or "🙈"
    end)

	local Sorted = {}
	for Name, Data in pairs(Config.UI) do table.insert(Sorted, {Name = Name, Order = Data[1], Text = Data[2], Size = Data[3]}) end
	table.sort(Sorted, function(A, B) return A.Order < B.Order end)

	for Index, Item in ipairs(Sorted) do
		local Label = Instance.new("TextLabel")
		Label.Name = Item.Name
		Label.LayoutOrder = Item.Order
		Label.Size = Item.Size and UDim2.new(unpack(Item.Size)) or UDim2.new(0.6, 0, 0.045, 0)
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.FredokaOne
		Label.Text = Item.Text
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.TextScaled = true
		Label.Parent = Self.Container
		Self.Elements[Item.Name] = Label

		if Index < #Sorted then
			local Spacer = Instance.new("Frame")
			Spacer.LayoutOrder = Item.Order + 0.5
			Spacer.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
			Spacer.Size = UDim2.new(0.4, 0, 0, 2)
			Spacer.Parent = Self.Container
		end
	end
	return Self
end

function FarmUI:SetText(Name, Text) 
    if self.Elements[Name] then 
        task.defer(function() self.Elements[Name].Text = Text end)
    end 
end
function FarmUI:Format(Int)
	local Index = 1; local Suffix = {"", "K", "M", "B", "T"}
	while Int >= 1000 and Index < #Suffix do Int = Int / 1000; Index = Index + 1 end
	if Index == 1 then return string.format("%d", Int) end
	return string.format("%.2f%s", Int, Suffix[Index])
end

--====================================================================--
local UI = FarmUI.new({
    UI = {
        ["Title"]           = {1, "🌟 AUTO LUCKY RAID", {0.8, 0, 0.08, 0}},
        ["Status"]          = {2, "Status: Starting..."},
        ["Level"]           = {3, "Current Level: 0"},
        ["Room"]            = {4, "Current Room: 0"},
        ["BreakablesLeft"]  = {5, "Total Breakables Left: 0"},
        ["RaidsCompleted"]  = {6, "Total Raids Completed: 0"},
        ["Huges"]           = {7, "Session Huges: 0"},
        ["Titanics"]        = {8, "Session Titanics: 0"},
        ["Eggs"]            = {9, "Total Eggs Hatched: 0"},
        ["TimeFarmed"]      = {10, "Time Farmed: 00:00:00"},
        ["FPS"]             = {11, "FPS: 60"}
    }
})

-- BỘ ĐẾM THỜI GIAN VÀ FPS CHẠY NGẦM
local scriptStartTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - scriptStartTime
        local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local s = elapsed % 60
        UI:SetText("TimeFarmed", string.format("Time Farmed: %02d:%02d:%02d", h, m, s))
    end
end)

local Workspace = game:GetService("Workspace")
task.spawn(function()
    while task.wait(0.5) do
        UI:SetText("FPS", "FPS: " .. math.floor(Workspace:GetRealPhysicsFPS()))
    end
end)

local DEBUG_BREAKABLES = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local THINGS = Workspace:FindFirstChild("__THINGS")
local ActiveInstances = workspace.__THINGS.__INSTANCE_CONTAINER.Active
local __FAKE_INSTANCE_BREAK_ZONES = workspace.__THINGS.__FAKE_INSTANCE_BREAK_ZONES
local mainfound = false
local chestsPos = {}
local eggs = {}
local mainPos = Vector3.new(0,0,0)
local totalRaidsCompleted = 0
local totaltitanics = 0

pcall(function()
    Player.PlayerScripts.Scripts.Core["Server Closing"].Enabled = false
    Player.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
end)
Player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

local Library = ReplicatedStorage.Library
local Network = require(Library.Client.Network)
local Save = require(Library.Client.Save)
local InstancingCmds = require(Library.Client.InstancingCmds)
local PetNetworking = require(Library.Client.PetNetworking)
local MapCmds = require(Library.Client.MapCmds)
local CustomEggsCmds = require(Library.Client.CustomEggsCmds)
local EggCmds = require(Library.Client.EggCmds)
local HatchingCmds = require(Library.Client.HatchingCmds)
local RaidCmds = require(Library.Client.RaidCmds)
local RaidInstance = require(Library.Client.RaidCmds.ClientRaidInstance)
local Raids = require(Library.Types.Raids)
local Items = require(Library.Items)
local CurrencyCmds = require(Library.Client.CurrencyCmds)
local EventUpgradeCmds = require(Library.Client.EventUpgradeCmds)
local MasteryCmds = require(Library.Client.MasteryCmds)
local CalcEggPrice = require(Library.Balancing.CalcEggPrice)
local EventUpgrades = require(Library.Directory.EventUpgrades)
local Eggs_Directory = require(Library.Directory.Eggs)
local FruitCmds = require(Library.Client.FruitCmds)

Network.Fire("Idle Tracking: Stop Timer")

local SafePart = Instance.new("Part", Workspace)
SafePart.Size = Vector3.new(10,1,10)
SafePart.Anchored = true
SafePart.CFrame = HumanoidRootPart.CFrame - Vector3.new(0,3,0)

local vmInst = vm:new()
vmInst:Add("AllBreakables", {}, "table")
vmInst:Add("Euids", {}, "table")
vmInst:Add("LastUseEuids", {}, "table")
vmInst:Add("BreakablesInUse", {}, "table")
vmInst:Add("PetIDs", {}, "table")
vmInst:Add("BulkAssignments", {})
vmInst:Add("current_zone", nil, "string")
vmInst:Add("lastZone", nil, "string")
vmInst:Add("LeftOnPurpose", false, "boolean")

local destroyedCount = 0
local lastPrint = os.clock()

local function TeleportPlayer(cf)
    HumanoidRootPart.Anchored = false
    HumanoidRootPart.CFrame = cf
    SafePart.CFrame = cf - Vector3.new(0,3,0)
end

local function EnterInstance(Name)
    local retries = 0
    while InstancingCmds.GetInstanceID() ~= Name and retries < 5 do
        pcall(function()
            setthreadidentity(2); InstancingCmds.Enter(Name); setthreadidentity(8)
        end)
        task.wait(1)
        retries = retries + 1
    end
end
-- CHỈ TỰ ĐỘNG RESET ORB NẾU CÔNG TẮC ENABLED = TRUE
if Settings["UpgradeSettings"] and Settings["UpgradeSettings"].Enabled then
    task.spawn(function() pcall(function() Network.Invoke("LuckyRaidUpgrades_Reset") end) end)
end

local luckyUpgrades = {}
for upgradeId, data in next, EventUpgrades do
    if upgradeId:find("LuckyRaid") then luckyUpgrades[upgradeId] = data end
end
local orbItem = Items.Misc("Lucky Raid Orb V2")

local function PurchaseUpgrades()
    local Config = Settings["UpgradeSettings"]
    -- KIỂM TRA CÔNG TẮC: Nếu tắt (false) thì bỏ qua không làm gì cả
    if not Config or Config.Enabled == false then return nil end 

    local currentOrbs = orbItem:CountExact()
    local allRequiredDone = true
    for id, cfg in pairs(Config) do
        if type(cfg) == "table" and cfg.enabled ~= false and cfg.required then
            local currentTier = EventUpgradeCmds.GetTier(id)
            if currentTier < (cfg.priority_upgrade or 1) then
                allRequiredDone = false; break
            end
        end
    end

    local bestUpgrade = nil; local bestPriority = math.huge; local bestCost = math.huge
    for id, cfg in pairs(Config) do
        if type(cfg) ~= "table" or cfg.enabled == false then continue end
        local currentTier = EventUpgradeCmds.GetTier(id)
        local maxTier = cfg.maxTier or 99
        local priority = cfg.priority or 99
        if currentTier >= maxTier then continue end
        if not allRequiredDone and (not cfg.required or currentTier >= (cfg.priority_upgrade or maxTier)) then continue end

        local data = luckyUpgrades[id]
        if not data then continue end
        local nextTierData = data.TierCosts[currentTier + 1]
        if not nextTierData or not nextTierData._data then continue end
        
        local cost = nextTierData._data._am or 1
        if currentOrbs >= cost then
            if priority < bestPriority or (priority == bestPriority and cost < bestCost) then
                bestPriority = priority; bestCost = cost; bestUpgrade = id
            end
        end
    end
    if bestUpgrade then pcall(function() EventUpgradeCmds.Purchase(bestUpgrade) end) end
    return bestUpgrade
end

local function onBreakablesDestroyed(data)
    if type(data) == "string" then
        local allBreakables = vmInst:Get("AllBreakables")
        if allBreakables[data] and allBreakables[data].Part then allBreakables[data].Part:Destroy() end
        vmInst:TableSet("AllBreakables", data, nil); vmInst:TableSet("BreakablesInUse", data, nil)
    elseif type(data) == "table" then
        local allBreakables = vmInst:Get("AllBreakables")
        for _, breakable in pairs(data) do
            local id = breakable[1]
            if allBreakables[id] and allBreakables[id].Part then allBreakables[id].Part:Destroy() end
            vmInst:TableSet("AllBreakables", id, nil); vmInst:TableSet("BreakablesInUse", id, nil)
        end
    end
end

local function onBreakablesCreated(data)
    for _, breakableData in pairs(data) do
        if not breakableData[1] or not breakableData[1].u then continue end
        local key = tostring(breakableData[1].u)
        local allBreakables = vmInst:Get("AllBreakables")
        if not allBreakables[key] then
            vmInst:TableSet("AllBreakables", key, breakableData[1]); vmInst:TableSet("BreakablesInUse", key, {})
        end
    end
end

local function onBreakableCleanup(data)
    for _, entry in pairs(data) do
        local key = tostring(entry[1])
        vmInst:TableSet("AllBreakables", key, nil); vmInst:TableSet("BreakablesInUse", key, nil)
    end
end

local events = {"Breakables_Created", "Breakables_Ping", "Breakables_DestroyDueToReplicationFail", "Breakables_Cleanup", "Orbs: Create"}
for _, event in ipairs(events) do
    for _, connection in ipairs(getconnections(Network.Fired(event))) do connection:Disconnect() end
end

Network.Fired("Breakables_Created"):Connect(onBreakablesCreated)
Network.Fired("Breakables_Ping"):Connect(onBreakablesCreated)
Network.Fired("Breakables_Destroyed"):Connect(onBreakablesDestroyed)
Network.Fired("Breakables_DestroyDueToReplicationFail"):Connect(onBreakablesDestroyed)
Network.Fired("Breakables_Cleanup"):Connect(onBreakableCleanup)

Network.Fired("Orbs: Create"):Connect(function(Orbs)
    local Collect = {}
    for _, v in ipairs(Orbs) do
        local ID = tonumber(v.id)
        if ID then table.insert(Collect, ID) end
    end
    if #Collect > 0 then pcall(function() Network.Fire("Orbs: Collect", Collect) end) end
end)

Network.Fired("CustomEggs_Updated"):Connect(function(p194)
    for id, data in pairs(p194) do
		if eggs[id] then
			if data.hatchable then eggs[id].hatchable = data.hatchable end
            if data.renderable then eggs[id].renderable = data.renderable end
		end
	end
end)

Network.Fired("CustomEggs_Broadcast"):Connect(function(data)
    local model = THINGS.CustomEggs:WaitForChild(data.uid, 60)
    if model then
        eggs[data.uid] = { ["model"] = model, ["position"] = model:GetPivot().Position, ["hatchable"] = data.hatchable, ["renderable"] = data.renderable, ["id"] = data.id, ["uid"] = data.uid, ["dir"] = Eggs_Directory[data.id] }
    end
end)

for uid, data in pairs(CustomEggsCmds.All()) do
    eggs[uid] = { ["model"] = data._model, ["position"] = data._position, ["hatchable"] = data._hatchable, ["renderable"] = data._renderable, ["id"] = data._id, ["uid"] = data._uid, ["dir"] = data._dir }
end

local function updateEuids()
    if type(PetNetworking.EquippedPets()) ~= "table" then return end
    vmInst:TableClear("Euids"); vmInst:TableClear("PetIDs")
    for petID, petData in pairs(PetNetworking.EquippedPets()) do
        vmInst:TableSet("Euids", petID, petData); vmInst:TableInsert("PetIDs", petID)
    end
    local validPets = {}
    for _, petID in ipairs(vmInst:Get("PetIDs")) do if vmInst:Get("Euids")[petID] then table.insert(validPets, petID) end end
    vmInst:TableClear("PetIDs"); for _, v in ipairs(validPets) do vmInst:TableInsert("PetIDs", v) end

    Network.Fired("Pets_LocalPetsUpdated"):Connect(function(pets)
        if type(pets) ~= "table" then return end
        local euids = vmInst:Get("Euids")
        for _, v in pairs(pets) do
            if v.ePet and v.ePet.euid and not euids[v.ePet.euid] then
                vmInst:TableSet("Euids", v.ePet.euid, v.ePet); vmInst:TableInsert("PetIDs", v.ePet.euid)
            end
        end
    end)
    Network.Fired("Pets_LocalPetsUnequipped"):Connect(function(pets)
        if type(pets) ~= "table" then return end
        for _, petID in pairs(pets) do vmInst:TableSet("Euids", petID, nil) end
        local validPets = {}
        for _, petID in ipairs(vmInst:Get("PetIDs")) do if vmInst:Get("Euids")[petID] then table.insert(validPets, petID) end end
        vmInst:TableClear("PetIDs"); for _, v in ipairs(validPets) do vmInst:TableInsert("PetIDs", v) end
    end)
end
updateEuids()

--====================================================================--
--//                   AUTO TRÁI CÂY (ƯU TIÊN SHINY) ĐÃ FIX         //--
--====================================================================--
task.spawn(function()
    local targetStack = 20
    local function ManageFruits()
        local fruitInv = Save.Get().Inventory.Fruit
        if not fruitInv then return end
        
        local bestFruits = {}
        
        for uid, data in pairs(fruitInv) do
            if data.id and data.id ~= "Candycane" then
                local baseId = data.id
                local currentBestUid = bestFruits[baseId]
                
                if not currentBestUid then
                    bestFruits[baseId] = uid
                else
                    local currentBestData = fruitInv[currentBestUid]
                    local isNewShiny = data.sh == true
                    local isOldShiny = currentBestData.sh == true
                    
                    if isNewShiny and not isOldShiny then
                        bestFruits[baseId] = uid
                    elseif isNewShiny == isOldShiny then
                        local newAmt = data._am or 1
                        local oldAmt = currentBestData._am or 1
                        if newAmt > oldAmt then
                            bestFruits[baseId] = uid
                        end
                    end
                end
            end
        end
        
        local activeFruits = FruitCmds.GetActiveFruits()
        for fruitName, uid in pairs(bestFruits) do
            local activeData = activeFruits[fruitName]
            local currentStack = activeData and type(activeData) == "table" and #activeData or 0
            if currentStack < targetStack then
                local amountNeeded = targetStack - currentStack
                -- Sửa từ Invoke sang gọi trực tiếp hàm Consume của game và Fire
                pcall(function() FruitCmds.Consume(uid, amountNeeded) end)
                pcall(function() Network.Fire("Fruits: Consume", uid, amountNeeded) end)
                task.wait(0.15)
            end
        end
    end
    
    ManageFruits()
    Network.Fired("Fruits: Update"):Connect(function() 
        task.wait(1)
        ManageFruits() 
    end)
end)

-- TỐI ƯU TỐC ĐỘ NÉM THÚ CƯNG & AUTO CLICK TAY
task.spawn(function()
    local breakableOffset = 0
    while true do
        task.wait()
        vmInst:Set("current_zone", InstancingCmds.GetInstanceID() or MapCmds.GetCurrentZone())
        local availableBreakables = {}
        for key, info in pairs(vmInst:Get("AllBreakables")) do
            if info.pid == vmInst:Get("current_zone") and info.id ~= "Ice Block" then table.insert(availableBreakables, key) end
        end

        if #availableBreakables > 0 then
            local now = os.clock(); local lastUseEuids = vmInst:Get("LastUseEuids"); local bulkAssignments = {}
            for i, petID in ipairs(vmInst:Get("PetIDs")) do
                if vmInst:Get("Euids")[petID] then
                    local lastData = lastUseEuids[petID]
                    local blockedKey = (lastData and (now - lastData.time < 1)) and lastData.breakableKey or nil
                    local filtered = {}
                    for _, key in ipairs(availableBreakables) do if key ~= blockedKey then table.insert(filtered, key) end end
                    
                    local pool = filtered
                    if #filtered == 0 then
                        local oldestKey = nil; local oldestTime = math.huge; local lastUseEuidsAll = vmInst:Get("LastUseEuids")
                        for _, key in ipairs(availableBreakables) do
                            local lastUsed = -math.huge
                            for _, data in pairs(lastUseEuidsAll) do if data.breakableKey == key and data.time > lastUsed then lastUsed = data.time end end
                            if lastUsed < oldestTime then oldestTime = lastUsed; oldestKey = key end
                        end
                        pool = {oldestKey or availableBreakables[1]}
                    end
                
                    bulkAssignments[petID] = pool[((i - 1 + breakableOffset) % #pool) + 1]
                    vmInst:TableSet("LastUseEuids", petID, { time = now, breakableKey = pool[((i - 1 + breakableOffset) % #pool) + 1] })
                end
            end

            if next(bulkAssignments) then
                -- Lệnh gọi Thú cưng lao vào đánh
                task.spawn(function() pcall(function() Network.Fire("Breakables_JoinPetBulk", bulkAssignments) end) end)
                
                -- Lệnh giả lập Click tay (Tap) thẳng vào mục tiêu với tốc độ ánh sáng
                pcall(function()
                    Network.UnreliableFire("Breakables_PlayerDealDamage", tostring(availableBreakables[1]))
                end)
                
                task.wait(0.1) 
            end
            breakableOffset = breakableOffset + 1
        else
            vmInst:Set("current_zone", nil); breakableOffset = 0
        end
    end
end)

-- WEBHOOK CƠ BẢN
task.spawn(function()
    local Data = Save.Get()
    local StartEggs = Data.EggsHatched or 0
    local discovered_Huge_titan = {}
    local localPlayer = game:GetService("Players").LocalPlayer
    local totalhuges = 0

    local function getPetLabel(data)
        local prefix = ""
        if data.sh then prefix = "Shiny " end
        if data.pt == 1 then prefix = prefix .. "Golden " elseif data.pt == 2 then prefix = prefix .. "Rainbow " end
        return prefix .. data.id
    end

    local function sendWebhook(data)
        if not Webhook or not Webhook.url or Webhook.url == "" then return end
        local isTitanic = string.find(data.id, "Titanic") or string.find(data.id, "titanic")
        local isShiny = data.sh; local isRainbow = data.pt == 2; local isGolden = data.pt == 1
        local color = isRainbow and 11141375 or isGolden and 16766720 or isShiny and 4031935 or isTitanic and 16711680 or 16776960

        local pingText = ""
        if Webhook["Discord Id to ping"] then
            local ids = Webhook["Discord Id to ping"]
            if type(ids) == "table" then 
                for _, id in ipairs(ids) do if tostring(id) ~= "" and tostring(id) ~= "0" then pingText = pingText .. "<@" .. tostring(id) .. "> " end end 
            elseif tostring(ids) ~= "" and tostring(ids) ~= "0" then pingText = "<@" .. tostring(ids) .. ">" end
        end

        local body = game:GetService("HttpService"):JSONEncode({
            content = pingText ~= "" and pingText or nil,
            embeds = {{
                title = isTitanic and "✨ Titanic Hatched!" or "🎉 Huge Hatched!",
                description = "**" .. localPlayer.Name .. "** hatched a **" .. getPetLabel(data) .. "**",
                color = color,
                footer = { text = "Eggs hatched: " .. tostring(Data.EggsHatched - StartEggs) }
            }}
        })
        pcall(function() request({Url = Webhook.url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body}) end)
    end

    for UUID, data in pairs(Data.Inventory.Pet or {}) do
        if string.find(data.id, "Huge") or string.find(data.id, "Titanic") or string.find(data.id, "titanic") then
            discovered_Huge_titan[UUID] = true
        end
    end

    while task.wait() do
        Data = Save.Get()
        for UUID, data in pairs(Data.Inventory.Pet or {}) do
            if string.find(data.id, "Huge") or string.find(data.id, "Titanic") or string.find(data.id, "titanic") then
                if not discovered_Huge_titan[UUID] then
                    discovered_Huge_titan[UUID] = true
                    pcall(sendWebhook, data)
                    if string.find(data.id, "Titanic") or string.find(data.id, "titanic") then
                        totaltitanics = totaltitanics + 1
                        UI:SetText("Titanics", "Session Titanics: " .. tostring(totaltitanics))
                    else
                        totalhuges = totalhuges + 1
                        UI:SetText("Huges", "Session Huges: " .. tostring(totalhuges))
                    end
                end
            end
        end
        UI:SetText("Eggs", "Total Eggs Hatched: " .. UI:Format(Data.EggsHatched - StartEggs))
        PurchaseUpgrades()
        pcall(function() Network.Invoke("Mailbox: Claim All") end)
    end
end)

local function OpenBossRooms(CurrentRaid)
    if not CurrentRaid then return end
    local BossSettings = Raid["Boss Settings"]
    if not BossSettings or not BossSettings.Enabled then return end
    local targetBosses = BossSettings.TargetBosses or {}
    
    for i, v in pairs(Raids.BossDirectory) do
        if CurrentRaid._roomNumber < v.RequiredRoom then continue end
        local bossName = "Boss " .. tostring(v.BossNumber)
        if not table.find(targetBosses, bossName) then continue end
        
        if BossSettings.UpgradeBossChests then
            local created
            pcall(function() created = Network.Invoke("LuckyRaid_PullLever", v.BossNumber) end)
            if created then UI:SetText("Status", "Status: Upgraded " .. bossName .. " Chest..."); task.wait(0.25) end
        end
        
        if v.BossNumber == 3 and Items.Misc("Lucky Raid Boss Key V2"):CountExact() < 1 then continue end
        local timer = os.clock()
        local Success, Error
        repeat 
            task.wait()
            pcall(function() Success, Error = Network.Invoke("Raids_StartBoss", v.BossNumber) end)
        until Success or Error or os.clock() - timer >= 3
    end
end

Network.Fired("Raid: Spawned Room"):Connect(function(RoomNumber)
    UI:SetText("Room", "Current Room: " .. tostring(RoomNumber))
    pcall(function() Network.Invoke("LuckyRaidBossKey_Combine",1) end)
end)

HumanoidRootPart.Anchored = true
EnterInstance("LuckyEventWorld")

if Raid.Enabled then
    while task.wait() do
        local CurrentRaid = RaidInstance.GetByOwner(Player)
        if not CurrentRaid or vmInst:Get("LeftOnPurpose") then
            vmInst:Set("LeftOnPurpose", false)
            local Level = RaidCmds.GetLevel()
            UI:SetText("Level", "Current Level: " .. tostring(Level))
            UI:SetText("Status", "Status: Creating Raid...")
            
            local OpenPortal;
            for i = 1,10 do
                local Portal = RaidInstance.GetByPortal(i)
                if not Portal or (Portal and Portal._owner == game.Players.LocalPlayer) then OpenPortal = i; break end
            end
            pcall(function() Network.Fire("Instancing_PlayerLeaveInstance", "LuckyRaid") end)
            pcall(function() Network.Invoke("Raids_RequestCreate", { ["Difficulty"] = (type(Raid.Difficulty) == "number" and Level >= Raid.Difficulty and Raid.Difficulty) or Level, ["Portal"] = OpenPortal, ["PartyMode"] = 1 }) end)
            task.wait()
        end

        repeat task.wait(0.25); CurrentRaid = RaidInstance.GetByOwner(Player) until CurrentRaid

        if CurrentRaid then
            UI:SetText("Status", "Status: Joining Raid...")
            local RaidID = CurrentRaid._id
            local Joined = false
            pcall(function() Joined = Network.Invoke("Raids_Join", RaidID) end)
            if not Joined then 
                repeat 
                    task.wait(0.5)
                    pcall(function() Joined = Network.Invoke("Raids_Join", RaidID) end)
                until Joined 
            end
            task.wait(0.2)
            
            repeat task.wait() until __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true)
            __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CanCollide = true
            mainPos = __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CFrame
            
            local completed = false
            local completedTime = 0
            local total = 0
            Network.Fired("Raid: Completed"):Once(function()
                completed = true
                completedTime = os.clock()
                totalRaidsCompleted = totalRaidsCompleted + 1
                UI:SetText("RaidsCompleted", "Total Raids Completed: " .. tostring(totalRaidsCompleted))
            end)
            
            UI:SetText("Status", "Status: Farming Breakables...")
            repeat
                task.wait()
                OpenBossRooms(RaidInstance.GetByOwner(Player))
                TeleportPlayer(__FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CFrame + Vector3.new(0,3,0))
                
                total = 0
                for key, info in pairs(vmInst:Get("AllBreakables")) do
                    if (info.pid and info.pid:lower():find("raid")) or (info.id and info.id:lower():find("raid")) then total += 1 end
                end
                UI:SetText("BreakablesLeft", "Total Breakables Left: " .. tostring(total))
                
                -- TỐI ƯU TỐC ĐỘ: Ép dừng đập gạch sau 3s nếu Raid báo xong
                if completed and os.clock() - completedTime >= 3 then break end
            until completed and total == 0

            UI:SetText("Status", "Status: Opening Chests...")
            for chestId, chestData in pairs(CurrentRaid._chests) do
                if chestId:find("Sign") or (chestId:find("Leprechaun") and not Raid.OpenLeprechaunChest) then continue end
                chestsPos[chestId] = chestData.Model:FindFirstChildOfClass("MeshPart").CFrame
                if chestData.Opened or not chestData.Model or not chestData.Model:FindFirstChildOfClass("MeshPart") then continue end
                TeleportPlayer(chestData.Model:FindFirstChildOfClass("MeshPart").CFrame)
                
                local success, reason
                local chestRetries = 0
                repeat 
                    task.wait()
                    pcall(function() success, reason = Network.Invoke("Raids_OpenChest", chestId) end)
                    chestRetries = chestRetries + 1
                -- TỐI ƯU TỐC ĐỘ: Chống kẹt Rương (thử tối đa 10 lần ~ 0.5s)
                until success or string.find(reason or "tier", "tier") or chestRetries > 10
            end

            for chestId, cPos in pairs(chestsPos) do
                TeleportPlayer(cPos)
                local success, reason
                local chestRetries = 0
                repeat 
                    task.wait()
                    pcall(function() success, reason = Network.Invoke("Raids_OpenChest", chestId) end)
                    chestRetries = chestRetries + 1
                until success or string.find(reason or "tier", "tier") or chestRetries > 10
            end
            
            mainfound = true

            if Raid["Egg Settings"].Enabled and Save.Get().RaidEggMultiplier and Save.Get().RaidEggMultiplier >= Raid["Egg Settings"].MinimumEggMulti and CurrencyCmds.CanAfford("LuckyCoins", Raid["Egg Settings"].MinimumLuckyCoins) then
                pcall(function() Network.Fire("Instancing_PlayerLeaveInstance", "LuckyRaid") end)
                task.wait(0.1)
                pcall(function() Network.Invoke("Instancing_PlayerEnterInstance", "LuckyEgg") end)
                TeleportPlayer(CFrame.new(3443, -167, 3534))
                local LuckyEgg, EggPrice, EggPosition
                repeat task.wait()
                    for UID, data in pairs(eggs) do
                        if not (data.hatchable and data.renderable and data.position) then continue end
                        local Power = EventUpgradeCmds.GetPower("LuckyRaidEggCost")
                        local CheaperEggs = MasteryCmds.HasPerk("Eggs", "CheaperEggs") and MasteryCmds.GetPerkPower("Eggs", "CheaperEggs") or 0
                        EggPrice = CalcEggPrice(data.dir) * (1 - Power / 100) * (1 - CheaperEggs / 100)
                        LuckyEgg = UID; EggPosition = data.position; break
                    end
                until LuckyEgg and EggPrice

                local StartingTime = os.time()
                local MaxEggHatch = EggCmds.GetMaxHatch()
                local NeedsPrice = EggPrice * MaxEggHatch
                local multiplier = Save.Get().RaidEggMultiplier
            
                UI:SetText("Status", "Status: Hatching Egg | x" .. tostring(multiplier))
            
                repeat task.wait()
                    pcall(function() Network.Invoke("CustomEggs_Hatch", LuckyEgg, MaxEggHatch) end)
                    TeleportPlayer(CFrame.new(EggPosition))
                until not CurrencyCmds.CanAfford("LuckyCoins", NeedsPrice) or (os.time() - StartingTime) >= (Raid["Egg Settings"].MaxOpenTime * 60)
            end
            vmInst:Set("LeftOnPurpose", true)
        end
    end
end
