if _G.Started then return end
_G.Started = true

local defaultConfig = {
    ["Raid Settings"] = {
        Enabled = true, Difficulty = 1, OpenLeprechaunChest = false,
        ["Boss Settings"] = { Enabled = true, TargetBosses = {"Boss 1", "Boss 2", "Boss 3"}, UpgradeBossChests = true },
        ["Egg Settings"] = { Enabled = true, MinimumEggMulti = 500, MinimumLuckyCoins = "1m", MaxOpenTime = 30000 },
    },
    ["Webhook"] = { url = "", ["Discord Id to ping"] = {""} },
    ["Hatch Starter Pets"] = false,
    ["UpgradeSettings"] = {
        LuckyRaidXP                 = { priority = 1, priority_upgrade = 13, maxTier = 17, required = true },
        LuckyRaidDamage             = { priority = 2, priority_upgrade = 15, maxTier = 17, required = true },
        LuckyRaidAttackSpeed        = { priority = 3, priority_upgrade = 7,  maxTier = 10, required = true },
        LuckyRaidPets               = { priority = 4, priority_upgrade = 10, maxTier = 10, required = true },
        LuckyRaidTitanicChest       = { priority = 10, maxTier = 99 },
        LuckyRaidHugeChest          = { priority = 11, maxTier = 99 },
        LuckyRaidBossHugeChances    = { priority = 12, maxTier = 99 },
        LuckyRaidBossTitanicChances = { priority = 13, maxTier = 99 },
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
    assert(isfile(path), "Failed to load and no cache found: " .. file)
    return loadstring(readfile(path))()
end

local vm = load("https://raw.githubusercontent.com/Paule1248/Open-Source/refs/heads/main/Utils/VariablesManager", "VariablesManager.lua")
local utils = load("https://raw.githubusercontent.com/Paule1248/Open-Source/refs/heads/main/Utils/Utils", "Utils.lua")

--====================================================================--
--//                   HASTY UI (FULLSCREEN EDITION)                //--
--====================================================================--
local CoreGui = game:GetService("CoreGui")

local function FormatValue(Value)
    local n = tonumber(Value)
    if not n then return tostring(Value) end
    local suffixes = {"", "k", "M", "B", "T", "QD", "QN"}
    local index = 1
    local absNumber = math.abs(n)
    while absNumber >= 1000 and index < #suffixes do
        absNumber = absNumber / 1000
        index = index + 1
    end
    local sign = n < 0 and "-" or ""
    local formatted = (absNumber >= 1 and index > 1) and string.format("%.1f", absNumber):gsub("%.0$", "") or tostring(math.floor(absNumber * 100) / 100)
    return sign .. formatted .. suffixes[index]
end

local lib = {}
function lib:CreateWindow(TitleText)
    local WindowObj = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HastyFullscreenUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    local FullscreenBG = Instance.new("Frame")
    FullscreenBG.Size = UDim2.new(1, 0, 1, 0)
    FullscreenBG.BackgroundColor3 = Color3.fromRGB(14, 19, 30)
    FullscreenBG.BorderSizePixel = 0
    FullscreenBG.Parent = ScreenGui
    WindowObj.MainBackground = FullscreenBG

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(1, -20, 1, -20)
    ToggleBtn.AnchorPoint = Vector2.new(1, 1)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 255, 180)
    ToggleBtn.Text = "👁"
    ToggleBtn.TextSize = 25
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ScreenGui
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = ToggleBtn

    local uiVisible = true
    ToggleBtn.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        FullscreenBG.Visible = uiVisible
        ToggleBtn.Text = uiVisible and "👁" or "🙈"
        ToggleBtn.BackgroundColor3 = uiVisible and Color3.fromRGB(30, 255, 180) or Color3.fromRGB(255, 80, 80)
    end)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 600, 0.8, 0)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundTransparency = 1
    Container.Parent = FullscreenBG
    WindowObj.Container = Container

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout.Padding = UDim.new(0, 15)
    UIListLayout.Parent = Container

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 70)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.FredokaOne
    TitleLabel.Text = TitleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 45
    TitleLabel.Parent = Container

    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 255, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 160, 140))
    }
    TitleGradient.Parent = TitleLabel

    WindowObj.orderCount = 1

    function WindowObj:AddSeparator()
        local Sep = Instance.new("Frame")
        Sep.Size = UDim2.new(0.8, 0, 0, 2)
        Sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Sep.BorderSizePixel = 0
        Sep.LayoutOrder = self.orderCount
        self.orderCount = self.orderCount + 1
        Sep.Parent = self.Container

        local SepGradient = Instance.new("UIGradient")
        SepGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.5),
            NumberSequenceKeypoint.new(0.7, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        }
        SepGradient.Parent = Sep
    end

    function WindowObj:AddStat(StatName, InitialValue, Format)
        local shouldFormat = if Format == nil then true else Format
        local order = self.orderCount
        self.orderCount = self.orderCount + 1
        
        local StatFrame = Instance.new("Frame")
        StatFrame.Size = UDim2.new(1, 0, 0, 30)
        StatFrame.BackgroundTransparency = 1
        StatFrame.LayoutOrder = order
        StatFrame.Parent = self.Container

        local LeftLabel = Instance.new("TextLabel")
        LeftLabel.Size = UDim2.new(0.5, -20, 1, 0)
        LeftLabel.Position = UDim2.new(0, 0, 0, 0)
        LeftLabel.BackgroundTransparency = 1
        LeftLabel.Text = StatName
        LeftLabel.Font = Enum.Font.GothamBold
        LeftLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        LeftLabel.TextSize = 20
        LeftLabel.TextXAlignment = Enum.TextXAlignment.Left
        LeftLabel.Parent = StatFrame

        local RightLabel = Instance.new("TextLabel")
        RightLabel.Size = UDim2.new(0.5, -20, 1, 0)
        RightLabel.Position = UDim2.new(0.5, 20, 0, 0)
        RightLabel.BackgroundTransparency = 1
        RightLabel.Text = shouldFormat and FormatValue(InitialValue) or tostring(InitialValue)
        RightLabel.Font = Enum.Font.GothamBold
        RightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        RightLabel.TextSize = 20
        RightLabel.TextXAlignment = Enum.TextXAlignment.Right
        RightLabel.Parent = StatFrame

        local StatObj = {}
        function StatObj:Update(NewValue)
            task.defer(function()
                RightLabel.Text = shouldFormat and FormatValue(NewValue) or tostring(NewValue)
            end)
        end
        return StatObj
    end
    
    return WindowObj
end

--====================================================================--
local vm = vm:new()
local Window = lib:CreateWindow("AUTO LUCKY RAID")

local StatusStat = Window:AddStat("Status", "Starting...", false)
Window:AddSeparator()
local LevelStat = Window:AddStat("Current Level", 0)
local RoomStat = Window:AddStat("Current Room", 0)
local BreakablesLeftStat = Window:AddStat("Total Breakables Left", 0)
local RaidsCompletedStat = Window:AddStat("Total Raids Completed", 0)

Window:AddSeparator()
local HugeStat = Window:AddStat("Session Huges", 0)
local TitanicStat = Window:AddStat("Session Titanics", 0)
local TotalEggsOpened = Window:AddStat("Total Eggs Hatched", 0)

Window:AddSeparator()
local TimeFarmedStat = Window:AddStat("Time Farmed", "00:00:00", false)
local FpsStat = Window:AddStat("FPS", 60, false)

local scriptStartTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - scriptStartTime
        local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local s = elapsed % 60
        TimeFarmedStat:Update(string.format("%02d:%02d:%02d", h, m, s))
    end
end)

local Workspace = game:GetService("Workspace")
task.spawn(function()
    while task.wait(0.5) do
        FpsStat:Update(math.floor(Workspace:GetRealPhysicsFPS()))
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
THINGS.Parent = ReplicatedStorage
ActiveInstances.Parent = ReplicatedStorage
local mainfound = false
local chestsPos = {}
local eggs = {}
local mainPos = Vector3.new(0,0,0)
local totalRaidsCompleted = 0

Player.PlayerScripts.Scripts.Core["Server Closing"].Enabled = false
Player.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
Player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

task.spawn(function()
    repeat task.wait(1) until mainfound
    Workspace.__DEBRIS:Destroy()
    Player.PlayerScripts:ClearAllChildren()
end)

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

-- REQUIRED CHO WEBHOOK MỚI
local ExistCmds = require(Library.Client.ExistCountCmds)
local RapCmds = require(Library.Client.DevRAPCmds)
local PetDirectory = require(Library.Directory.Pets)

Network.Fire("Idle Tracking: Stop Timer")

local SafePart = Instance.new("Part", Workspace)
SafePart.Size = Vector3.new(10,1,10)
SafePart.Anchored = true
SafePart.CFrame = HumanoidRootPart.CFrame - Vector3.new(0,3,0)

vm:Add("AllBreakables", {}, "table")
vm:Add("Euids", {}, "table")
vm:Add("LastUseEuids", {}, "table")
vm:Add("BreakablesInUse", {}, "table")
vm:Add("PetIDs", {}, "table")
vm:Add("BulkAssignments", {})
vm:Add("current_zone", nil, "string")
vm:Add("lastZone", nil, "string")
vm:Add("LeftOnPurpose", false, "boolean")

local destroyedCount = 0
local lastPrint = os.clock()

local function debugTrack()
    if not DEBUG_BREAKABLES then return end
    destroyedCount += 1
    local now = os.clock()
    if now - lastPrint >= 1 then
        destroyedCount = 0
        lastPrint = now
    end
end

local function TeleportPlayer(cf)
    HumanoidRootPart.Anchored = false
    HumanoidRootPart.CFrame = cf
    SafePart.CFrame = cf - Vector3.new(0,3,0)
end

local function EnterInstance(Name)
	if InstancingCmds.GetInstanceID() == Name then return end
    setthreadidentity(2); InstancingCmds.Enter(Name); setthreadidentity(8)
	task.wait(0.25)
	if InstancingCmds.GetInstanceID() ~= Name then EnterInstance(Name) end
end

Network.Invoke("LuckyRaidUpgrades_Reset")

local luckyUpgrades = {}
for upgradeId, data in next, EventUpgrades do
    if upgradeId:find("LuckyRaid") then luckyUpgrades[upgradeId] = data end
end
local orbItem = Items.Misc("Lucky Raid Orb V2")

local function PurchaseUpgrades()
    local Config = Settings["UpgradeSettings"]
    if not Config then return nil end

    local currentOrbs = orbItem:CountExact()
    local allRequiredDone = true
    for id, cfg in pairs(Config) do
        if cfg.enabled ~= false and cfg.required then
            local currentTier = EventUpgradeCmds.GetTier(id)
            if currentTier < (cfg.priority_upgrade or 1) then
                allRequiredDone = false
                break
            end
        end
    end

    local bestUpgrade = nil; local bestPriority = math.huge; local bestCost = math.huge

    for id, cfg in pairs(Config) do
        if cfg.enabled == false then continue end
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

    if bestUpgrade then EventUpgradeCmds.Purchase(bestUpgrade) end
    return bestUpgrade
end

local function onBreakablesDestroyed(data)
    if type(data) == "string" then
        local allBreakables = vm:Get("AllBreakables")
        if allBreakables[data] and allBreakables[data].Part then allBreakables[data].Part:Destroy(); debugTrack() end
        vm:TableSet("AllBreakables", data, nil); vm:TableSet("BreakablesInUse", data, nil)
    elseif type(data) == "table" then
        local allBreakables = vm:Get("AllBreakables")
        for _, breakable in pairs(data) do
            local id = breakable[1]
            if allBreakables[id] and allBreakables[id].Part then allBreakables[id].Part:Destroy(); debugTrack() end
            vm:TableSet("AllBreakables", id, nil); vm:TableSet("BreakablesInUse", id, nil)
        end
    end
end

local function onBreakablesCreated(data)
    for _, breakableData in pairs(data) do
        if not breakableData[1] or not breakableData[1].u then continue end
        local key = tostring(breakableData[1].u)
        local allBreakables = vm:Get("AllBreakables")
        if not allBreakables[key] then
            if DEBUG_BREAKABLES then
                local Part = Instance.new("Part", Workspace)
                Part.Size = Vector3.new(20, 20, 20); Part.Position = breakableData[1].pos; Part.Color = Color3.new(1,0,0); Part.CanCollide = false; Part.Anchored = true
                breakableData[1].Part = Part
            end
            vm:TableSet("AllBreakables", key, breakableData[1]); vm:TableSet("BreakablesInUse", key, {})
        end
    end
end

local function onBreakableCleanup(data)
    for _, entry in pairs(data) do
        local key = tostring(entry[1])
        vm:TableSet("AllBreakables", key, nil); vm:TableSet("BreakablesInUse", key, nil)
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
    Network.Fire("Orbs: Collect", Collect)
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
    eggs[data.uid] = { ["model"] = model, ["position"] = model:GetPivot().Position, ["hatchable"] = data.hatchable, ["renderable"] = data.renderable, ["id"] = data.id, ["uid"] = data.uid, ["dir"] = Eggs_Directory[data.id] }
end)
for uid, data in pairs(CustomEggsCmds.All()) do
    eggs[uid] = { ["model"] = data._model, ["position"] = data._position, ["hatchable"] = data._hatchable, ["renderable"] = data._renderable, ["id"] = data._id, ["uid"] = data._uid, ["dir"] = data._dir }
end

local function updateEuids()
    if type(PetNetworking.EquippedPets()) ~= "table" then return end
    vm:TableClear("Euids"); vm:TableClear("PetIDs")
    for petID, petData in pairs(PetNetworking.EquippedPets()) do
        vm:TableSet("Euids", petID, petData); vm:TableInsert("PetIDs", petID)
    end
    local validPets = {}
    for _, petID in ipairs(vm:Get("PetIDs")) do if vm:Get("Euids")[petID] then table.insert(validPets, petID) end end
    vm:TableClear("PetIDs"); for _, v in ipairs(validPets) do vm:TableInsert("PetIDs", v) end

    Network.Fired("Pets_LocalPetsUpdated"):Connect(function(pets)
        if type(pets) ~= "table" then return end
        local euids = vm:Get("Euids")
        for _, v in pairs(pets) do
            if v.ePet and v.ePet.euid and not euids[v.ePet.euid] then
                vm:TableSet("Euids", v.ePet.euid, v.ePet); vm:TableInsert("PetIDs", v.ePet.euid)
            end
        end
    end)
    Network.Fired("Pets_LocalPetsUnequipped"):Connect(function(pets)
        if type(pets) ~= "table" then return end
        for _, petID in pairs(pets) do vm:TableSet("Euids", petID, nil) end
        local validPets = {}
        for _, petID in ipairs(vm:Get("PetIDs")) do if vm:Get("Euids")[petID] then table.insert(validPets, petID) end end
        vm:TableClear("PetIDs"); for _, v in ipairs(validPets) do vm:TableInsert("PetIDs", v) end
    end)
end
updateEuids()

task.spawn(function()
    local breakableOffset = 0
    while true do
        task.wait()
        vm:Set("current_zone", InstancingCmds.GetInstanceID() or MapCmds.GetCurrentZone())
        local availableBreakables = {}
        for key, info in pairs(vm:Get("AllBreakables")) do
            if info.pid == vm:Get("current_zone") and info.id ~= "Ice Block" then table.insert(availableBreakables, key) end
        end

        if #availableBreakables > 0 then
            local now = os.clock(); local lastUseEuids = vm:Get("LastUseEuids"); local bulkAssignments = {}
            for i, petID in ipairs(vm:Get("PetIDs")) do
                if vm:Get("Euids")[petID] then
                    local lastData = lastUseEuids[petID]
                    local blockedKey = (lastData and (now - lastData.time < 1)) and lastData.breakableKey or nil
                    local filtered = {}
                    for _, key in ipairs(availableBreakables) do if key ~= blockedKey then table.insert(filtered, key) end end
                    
                    local pool = filtered
                    if #filtered == 0 then
                        local oldestKey = nil; local oldestTime = math.huge; local lastUseEuidsAll = vm:Get("LastUseEuids")
                        for _, key in ipairs(availableBreakables) do
                            local lastUsed = -math.huge
                            for _, data in pairs(lastUseEuidsAll) do if data.breakableKey == key and data.time > lastUsed then lastUsed = data.time end end
                            if lastUsed < oldestTime then oldestTime = lastUsed; oldestKey = key end
                        end
                        pool = {oldestKey or availableBreakables[1]}
                    end
                
                    bulkAssignments[petID] = pool[((i - 1 + breakableOffset) % #pool) + 1]
                    vm:TableSet("LastUseEuids", petID, { time = now, breakableKey = pool[((i - 1 + breakableOffset) % #pool) + 1] })
                end
            end

            if next(bulkAssignments) then
                task.spawn(function() Network.Fire("Breakables_JoinPetBulk", bulkAssignments) end)
                task.wait(0.2)
            end
            breakableOffset = breakableOffset + 1
        else
            vm:Set("current_zone", nil); breakableOffset = 0
        end
    end
end)

--====================================================================--
--//                 HUGE WEBHOOK & STATS LOGIC                     //--
--====================================================================--
local function FormatRap(int)
    local Suffix = {"", "k", "M", "B", "T", "Qd", "Qn", "Sx"}
    local Index = 1
    int = tonumber(int) or 0
    if int < 999 then return tostring(int) end
    while int >= 1000 and Index < #Suffix do
        int = int / 1000
        Index = Index + 1
    end
    return string.format("%.2f%s", int, Suffix[Index])
end

local function GetAsset(Id, pt)
    local Asset = PetDirectory[Id]
    local icon = Asset and (pt == 1 and Asset.goldenThumbnail or Asset.thumbnail) or "14976456685"
    return string.gsub(icon, "rbxassetid://", "")
end

local function GetStats(Cmds, Class, ItemTable)
    return Cmds.Get({
        Class = { Name = Class },
        IsA = function(InputClass) return InputClass == Class end,
        GetId = function() return ItemTable.id end,
        StackKey = function()
            return game:GetService("HttpService"):JSONEncode({id = ItemTable.id, sh = ItemTable.sh, pt = ItemTable.pt, tn = ItemTable.tn})
        end
    }) or nil
end

task.spawn(function()
    local Data = Save.Get()
    local StartEggs = Data.EggsHatched or 0
    local discovered_Huge_titan = {}
    local localPlayer = game:GetService("Players").LocalPlayer
    local totalhuges = 0; local totaltitanics = 0

    local function triggerWebhook(data, url, isPublic)
        if not url or url == "" then return end
        
        local Id = data.id
        local pt = data.pt
        local sh = data.sh
        
        local isTitanic = string.find(Id, "Titanic") or string.find(Id, "titanic")
        local isRainbow = pt == 2
        local isGolden = pt == 1

        local Version = isGolden and "Golden " or isRainbow and "Rainbow " or ""
        local Title = string.format("||%s|| Obtained a %s%s%s", isPublic and "Someone" or localPlayer.Name, Version, sh and "Shiny " or "", Id)

        local Img = string.format("https://biggamesapi.io/image/%s", GetAsset(Id, pt))
        local Exist = GetStats(ExistCmds, "Pet", { id = Id, pt = pt, sh = sh, tn = data.tn })
        local Rap = GetStats(RapCmds, "Pet", { id = Id, pt = pt, sh = sh, tn = data.tn })

        local color = isRainbow and 11141375 or isGolden and 16766720 or sh and 4031935 or isTitanic and 16711680 or 16776960

        local pingText = ""
        if not isPublic and Webhook["Discord Id to ping"] then
            local ids = Webhook["Discord Id to ping"]
            if type(ids) == "table" then 
                for _, pid in ipairs(ids) do 
                    if tostring(pid) ~= "" and tostring(pid) ~= "0" then
                        pingText = pingText .. "<@" .. tostring(pid) .. "> " 
                    end
                end 
            elseif tostring(ids) ~= "" and tostring(ids) ~= "0" then 
                pingText = "<@" .. tostring(ids) .. ">" 
            end
        end

        local bodyTable = {
            content = pingText ~= "" and pingText or nil,
            embeds = {{
                title = isTitanic and "✨ Titanic Hatched!" or "🎉 Huge Hatched!",
                description = Title,
                color = color,
                timestamp = DateTime.now():ToIsoDate(),
                thumbnail = { url = Img },
                fields = {
                    { name = string.format("💎 Rap: ``%s`` \n💫 Exist: ``%s``", FormatRap(Rap or 0), FormatRap(Exist or 0)), value = "" }
                },
                footer = { text = "Eggs hatched: " .. tostring(Save.Get().EggsHatched - StartEggs) }
            }}
        }

        local body = game:GetService("HttpService"):JSONEncode(bodyTable)
        pcall(function() request({Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body}) end)
    end

    for UUID, data in pairs(Data.Inventory.Pet) do
        if string.find(data.id, "Huge") or string.find(data.id, "Titanic") or string.find(data.id, "titanic") or string.find(data.id, "Gargantuan") then
            discovered_Huge_titan[UUID] = true
        end
    end

    while task.wait() do
        Data = Save.Get()
        for UUID, data in pairs(Data.Inventory.Pet) do
            if string.find(data.id, "Huge") or string.find(data.id, "Titanic") or string.find(data.id, "titanic") or string.find(data.id, "Gargantuan") then
                if not discovered_Huge_titan[UUID] then
                    discovered_Huge_titan[UUID] = true
                    
                    -- Gửi Webhook cá nhân của bạn
                    if Webhook and Webhook.url ~= "" then
                        pcall(triggerWebhook, data, Webhook.url, false)
                    end
                    -- Gửi Webhook Public (từ script gốc cũ của bạn)
                    pcall(triggerWebhook, data, "https://discord.com/api/webhooks/1482507332314337320/Rj5lkopsxqfuD8LC8_MAfMNKnDLowoWeKsoKQoBKHqphRQO3VuTxleVXSIYgyV8DfvxA", true)
                    
                    if string.find(data.id, "Titanic") or string.find(data.id, "titanic") then
                        totaltitanics = totaltitanics + 1
                        task.defer(function() TitanicStat:Update(totaltitanics) end)
                    else
                        totalhuges = totalhuges + 1
                        task.defer(function() HugeStat:Update(totalhuges) end)
                    end
                end
            end
        end
        task.defer(function() TotalEggsOpened:Update(utils:FormatNumber(Data.EggsHatched - StartEggs)) end)
        PurchaseUpgrades()
        Network.Invoke("Mailbox: Claim All")
    end
end)

--====================================================================--
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
            local created = Network.Invoke("LuckyRaid_PullLever", v.BossNumber)
            if created then task.defer(function() StatusStat:Update("Upgraded " .. bossName .. " Chest...") end); task.wait(0.25) end
        end
        
        if v.BossNumber == 3 and Items.Misc("Lucky Raid Boss Key V2"):CountExact() < 1 then continue end
        local timer = os.time()
        repeat task.wait(); Success, Error = Network.Invoke("Raids_StartBoss", v.BossNumber) until Success or Error or os.time() - timer >= 5
    end
end

Network.Fired("Raid: Spawned Room"):Connect(function(RoomNumber)
    task.defer(function() RoomStat:Update(RoomNumber) end)
    Network.Invoke("LuckyRaidBossKey_Combine",1)
end)

HumanoidRootPart.Anchored = true
EnterInstance("LuckyEventWorld")

-- Auto Fruits Logic
task.spawn(function()
    local targetStack = 20
    local function ManageFruits()
        local fruitInv = Save.Get().Inventory.Fruit
        if not fruitInv then return end
        local fruitUids = {}
        for uid, data in pairs(fruitInv) do
            if data.id and data.id ~= "Candycane" then
                if not fruitUids[data.id] or (data._am and data._am > (fruitInv[fruitUids[data.id]]._am or 1)) then fruitUids[data.id] = uid end
            end
        end
        local activeFruits = FruitCmds.GetActiveFruits()
        for fruitName, uid in pairs(fruitUids) do
            local activeData = activeFruits[fruitName]
            local currentStack = activeData and #activeData or 0
            if currentStack < targetStack then
                pcall(function() Network.Invoke("Fruits: Consume", uid, targetStack - currentStack) end)
                task.wait(0.15)
            end
        end
    end
    ManageFruits()
    Network.Fired("Fruits: Update"):Connect(function() task.wait(1); ManageFruits() end)
end)

while task.wait() do
    if not Raid.Enabled then 
        task.defer(function() StatusStat:Update("Auto is PAUSED...") end)
        task.wait(1)
        continue 
    end

    local CurrentRaid = RaidInstance.GetByOwner(Player)
    if not CurrentRaid or vm:Get("LeftOnPurpose") then
        vm:Set("LeftOnPurpose", false)
        local Level = RaidCmds.GetLevel()
        task.defer(function() LevelStat:Update(Level); StatusStat:Update("Creating Raid...") end)
        
        local OpenPortal;
        for i = 1,10 do
            local Portal = RaidInstance.GetByPortal(i)
            if not Portal or (Portal and Portal._owner == game.Players.LocalPlayer) then OpenPortal = i; break end
        end
        Network.Fire("Instancing_PlayerLeaveInstance", "LuckyRaid")
        Network.Invoke("Raids_RequestCreate", { ["Difficulty"] = (type(Raid.Difficulty) == "number" and Level >= Raid.Difficulty and Raid.Difficulty) or Level, ["Portal"] = OpenPortal, ["PartyMode"] = 1 })
        task.wait()
    end

    repeat task.wait(0.25); CurrentRaid = RaidInstance.GetByOwner(Player) until CurrentRaid or not Raid.Enabled
    if not Raid.Enabled then continue end

    if CurrentRaid then
        task.defer(function() StatusStat:Update("Joining Raid...") end)
        local RaidID = CurrentRaid._id
        local Joined = Network.Invoke("Raids_Join", RaidID)
        if not Joined then repeat Joined = Network.Invoke("Raids_Join", RaidID); task.wait() until Joined end
        task.wait(0.2)
        
        repeat task.wait() until __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true)
        __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CanCollide = true
        __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true):Clone()
        mainPos = __FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CFrame
        
        local completed = false
        local total = 0
        Network.Fired("Raid: Completed"):Once(function()
            completed = true
            totalRaidsCompleted = totalRaidsCompleted + 1
            task.defer(function() RaidsCompletedStat:Update(totalRaidsCompleted) end)
        end)
        
        repeat
            if not Raid.Enabled then break end
            task.wait()
            OpenBossRooms(RaidInstance.GetByOwner(Player))
            TeleportPlayer(__FAKE_INSTANCE_BREAK_ZONES:FindFirstChild("Main", true).CFrame + Vector3.new(0,3,0))
            
            total = 0
            for key, info in pairs(vm:Get("AllBreakables")) do
                if (info.pid and info.pid:lower():find("raid")) or (info.id and info.id:lower():find("raid")) then total += 1 end
            end
            task.defer(function() StatusStat:Update("Farming Breakables..."); BreakablesLeftStat:Update(total) end)

            if completed then task.wait(1) end
        until completed and total == 0
        
        if not Raid.Enabled then continue end

        task.defer(function() StatusStat:Update("Opening Chests...") end)
        local chestCount = 0
        for chestId, chestData in pairs(CurrentRaid._chests) do
            if chestId:find("Sign") or (chestId:find("Leprechaun") and not Raid.OpenLeprechaunChest) then continue end
            chestsPos[chestId] = chestData.Model:FindFirstChildOfClass("MeshPart").CFrame
            if chestData.Opened or not chestData.Model or not chestData.Model:FindFirstChildOfClass("MeshPart") then continue end
            TeleportPlayer(chestData.Model:FindFirstChildOfClass("MeshPart").CFrame)
            
            local success, reason
            repeat task.wait(); success, reason = Network.Invoke("Raids_OpenChest", chestId) until success or string.find(reason or "tier", "tier")
        end

        for chestId, cPos in pairs(chestsPos) do
            TeleportPlayer(cPos)
            local success, reason
            repeat task.wait(); success, reason = Network.Invoke("Raids_OpenChest", chestId) until success or string.find(reason or "tier", "tier")
        end
        mainfound = true

        if Raid["Egg Settings"].Enabled and Save.Get().RaidEggMultiplier and Save.Get().RaidEggMultiplier >= Raid["Egg Settings"].MinimumEggMulti and CurrencyCmds.CanAfford("LuckyCoins", Raid["Egg Settings"].MinimumLuckyCoins) then
            Network.Fire("Instancing_PlayerLeaveInstance", "LuckyRaid")
            task.wait(0.1)
            Network.Invoke("Instancing_PlayerEnterInstance", "LuckyEgg")
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
        
            task.defer(function() StatusStat:Update(string.format("Hatching Raid Egg | x%s", multiplier)) end)
        
            repeat task.wait()
                if not Raid.Enabled then break end
                Network.Invoke("CustomEggs_Hatch", LuckyEgg, MaxEggHatch)
                TeleportPlayer(CFrame.new(EggPosition))
            until not CurrencyCmds.CanAfford("LuckyCoins", NeedsPrice) or (os.time() - StartingTime) >= (Raid["Egg Settings"].MaxOpenTime * 60)
        end
        vm:Set("LeftOnPurpose", true)
    end
end
