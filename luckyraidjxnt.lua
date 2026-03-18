if _G.PiraRaidStarted then return end
_G.PiraRaidStarted = true

local defaultConfig = {
	["Raid Settings"] = {
		Enabled = true, JoinRaid = "", Difficulty = "Max", Type = "Solo", LeaveRaid = {}, OpenBosses = {}, UpgradeBossChests = true, OpenLeprechaunChest = false,
		["Egg Settings"] = { Enabled = true, MinimumEggMulti = 700, MinimumLuckyCoins = "1m", MaxOpenTime = 50 }
	},
	["Main Area Settings"] = { FarmArea = false, PurchaseUpgrades = false },
    ["Webhook"] = { url = "", ["Discord Id to ping"] = {"0"} }
}

local function mergeConfig(default, user)
    local result = {}
    for k, v in pairs(default) do
        if type(v) == "table" and type(user[k]) == "table" then
            result[k] = mergeConfig(v, user[k])
        elseif user[k] ~= nil then result[k] = user[k]
        else result[k] = v end
    end
    for k, v in pairs(user) do
        if result[k] == nil then result[k] = v end
    end
    return result
end

local Settings = mergeConfig(defaultConfig, getgenv().Settings or {})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer and LocalPlayer.GetAttribute and LocalPlayer:GetAttribute("__LOADED")
if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart

--====================================================================--
--//                     PIRA UI LIBRARY (MODDED)                   //--
--====================================================================--
local FarmUI = {}
FarmUI.__index = FarmUI

function FarmUI.new(Config)
	local Self = setmetatable({}, FarmUI)
	Self.Player = LocalPlayer
	Self.GuiName = "PiraScreenGui"
	Self.Logo = "rbxassetid://83339153494444"
	Self.Elements = {}
	Self.Parent = Self.Player:WaitForChild("PlayerGui")
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = Self.GuiName
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = Self.Parent
	ScreenGui.ResetOnSpawn = false
	Self.ScreenGui = ScreenGui

	local Background = Instance.new("Frame")
	Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Background.BorderColor3 = Color3.fromRGB(255, 0, 255)
	Background.BorderMode = Enum.BorderMode.Inset
	Background.Parent = ScreenGui
	Background.Size = UDim2.new(0.2, 0, 0.25, 0)
	Background.Position = UDim2.new(0.5, 0, 0.5, 0)
	Background.AnchorPoint = Vector2.new(0.5, 0.5)

	local Logo = Instance.new("ImageLabel")
	Logo.Position = UDim2.new(0.02, 0, 0.05, 0)
	Logo.BackgroundTransparency = 1
	Logo.Image = Self.Logo
	Logo.Size = UDim2.new(0.15, 0, 0.2, 0)
	Logo.Parent = Background
	Instance.new("UIAspectRatioConstraint", Logo).AspectRatio = 1

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 1, 0)
	Container.BackgroundTransparency = 1
	Container.Parent = Background
	Self.Container = Container

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0.02, 0)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Container

	local Dragging, DragInput, DragStart, StartPos
	Background.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = Input.Position
			StartPos = Background.Position
			Input.Changed:Connect(function() if Input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	Background.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - DragStart
			Background.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
		end
	end)

	local Sorted = {}
	for Name, Data in pairs(Config.UI) do table.insert(Sorted, {Name = Name, Order = Data[1], Text = Data[2], Size = Data[3]}) end
	table.sort(Sorted, function(A, B) return A.Order < B.Order end)

	for Index, Item in ipairs(Sorted) do
		local Label = Instance.new("TextLabel")
		Label.Name = Item.Name
		Label.LayoutOrder = Item.Order
		Label.Size = Item.Size and UDim2.new(unpack(Item.Size)) or UDim2.new(0.7, 0, 0.1, 0)
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
			Spacer.Size = UDim2.new(0.5, 0, 0, 1)
			Spacer.Parent = Self.Container
		end
	end
	return Self
end

function FarmUI:SetText(Name, Text) if self.Elements[Name] then self.Elements[Name].Text = Text end end
function FarmUI:Format(Int)
	local Index = 1; local Suffix = {"", "K", "M", "B", "T"}
	while Int >= 1000 and Index < #Suffix do Int = Int / 1000; Index = Index + 1 end
	if Index == 1 then return string.format("%d", Int) end
	return string.format("%.2f%s", Int, Suffix[Index])
end

local UI = FarmUI.new({
    UI = {
        ["Title"] = {1, "🌟 AUTO LUCKY RAID", {0.8, 0, 0.15, 0}},
        ["Level"] = {2, "Current Level: 0"},
        ["Room"]  = {3, "Current Room: 0"},
        ["Status"]= {4, "Status: Starting..."},
        ["Huges"] = {5, "Session Huges: 0"},
        ["Eggs"]  = {6, "Eggs Hatched: 0"}
    }
})

--====================================================================--
--//                   CORE SCRIPT LOGIC & WEBHOOK                  //--
--====================================================================--
local NLibrary = game.ReplicatedStorage.Library
local Network = require(NLibrary.Client.Network)
local PlayerSave = require(NLibrary.Client.Save) 

local RaidCmds = require(NLibrary.Client.RaidCmds)
local RaidInstance = require(NLibrary.Client.RaidCmds.RaidInstance)
local EventUpgradeCmds = require(NLibrary.Client.EventUpgradeCmds)
local EventUpgrades = require(NLibrary.Directory.EventUpgrades)
local Items = require(NLibrary.Items)
local PetNetworking = require(NLibrary.Client.PetNetworking)
local InstancingCmds = require(NLibrary.Client.InstancingCmds)
local EggCmds = require(NLibrary.Client.EggCmds)
local MapCmds = require(NLibrary.Client.MapCmds)
local CurrencyCmds = require(NLibrary.Client.CurrencyCmds)
local CustomEggsCmds = require(NLibrary.Client.CustomEggsCmds)
local CalcEggPrice = require(NLibrary.Balancing.CalcEggPrice)
local MasteryCmds = require(NLibrary.Client.MasteryCmds)
local EggFrontend = getsenv(LocalPlayer.PlayerScripts.Scripts.Game:WaitForChild("Egg Opening Frontend"))
local Raids = require(NLibrary.Types.Raids)

local function EnterInstance(Name)
	if InstancingCmds.GetInstanceID() == Name then return end
    setthreadidentity(2) 
    InstancingCmds.Enter(Name) 
    setthreadidentity(8)
	task.wait(0.25)
	if InstancingCmds.GetInstanceID() ~= Name then EnterInstance(Name) end
end

local SuffixesLower = {"k", "m", "b", "t"}
local SuffixesUpper = {"K", "M", "B", "T"}
local function RemoveSuffix(Amount)
	local a, Suffix = Amount:gsub("%a", ""), Amount:match("%a")	
	local b = table.find(SuffixesUpper, Suffix) or table.find(SuffixesLower, Suffix) or 0
	return tonumber(a) * math.pow(10, b * 3)
end

local ActiveInstances = workspace.__THINGS.__INSTANCE_CONTAINER.Active
local Raid = Settings["Raid Settings"]
local Main = Settings["Main Area Settings"]
if type(Raid["Egg Settings"].MinimumLuckyCoins) ~= "number" then
	Raid["Egg Settings"].MinimumLuckyCoins = RemoveSuffix(Raid["Egg Settings"].MinimumLuckyCoins)
end

local BreakablesFolder = workspace.__THINGS.Breakables
local BreakablesList = {}
for _,v in pairs(BreakablesFolder:GetChildren()) do
    if v:IsA("Model") then
        local UID, Zone = v:GetAttribute("BreakableUID"), v:GetAttribute("ParentID")
        if (Raid.Enabled and Zone == "LuckyRaid") or (not Raid.Enabled and Zone == "LuckyEventWorld") then BreakablesList[UID] = v end
    end
end
BreakablesFolder.ChildAdded:Connect(function(Breakable)
    task.wait()
    if Breakable:IsA("Model") then
        local UID, Zone = Breakable:GetAttribute("BreakableUID"), Breakable:GetAttribute("ParentID")
        if (Raid.Enabled and Zone == "LuckyRaid") or (not Raid.Enabled and Zone == "LuckyEventWorld") then BreakablesList[UID] = Breakable end
    end
end)
BreakablesFolder.ChildRemoved:Connect(function(Breakable)
    task.wait()
    local UID = Breakable:GetAttribute("BreakableUID")
    if BreakablesList[UID] then BreakablesList[UID] = nil end
end)

local EquippedPets = {}
for _,v in pairs(PetNetworking.EquippedPets()) do if not EquippedPets[v.euid] then table.insert(EquippedPets, v.euid) end end
Network.Fired("Pets_LocalPetsUpdated"):Connect(function(Pet) for _,v in pairs(Pet) do if not EquippedPets[v.ePet.euid] then table.insert(EquippedPets, v.ePet.euid) end end end)
Network.Fired("Pets_LocalPetsUnequipped"):Connect(function(Pet) for _,v in pairs(Pet) do if EquippedPets[v] then EquippedPets[v] = nil end end end)
Network.Fired("Orbs: Create"):Connect(function(Orbs)
    local Collect = {}
    for _, v in ipairs(Orbs) do
        local ID = tonumber(v.id)
        if ID then table.insert(Collect, ID) end
    end
    if #Collect > 0 then
        Network.Fire("Orbs: Collect", Collect)
        for _, ID in ipairs(Collect) do
            local Orb = workspace.__THINGS.Orbs:FindFirstChild(tostring(ID))
            if Orb then Orb:Destroy() end
        end
    end
end)

Network.Fired("Raid: Spawned Room"):Connect(function(RoomNumber)
    task.defer(function() UI:SetText("Room", "Current Room: " .. tostring(RoomNumber)) end)
    Network.Invoke("LuckyRaidBossKey_Combine",1)
end)

local function GetUpgradeTypes(ID)
    if ID:find("XP") then return "XP" end
    if ID:find("Damage") then return "Damage" end
    if ID:find("AttackSpeed") then return "AttackSpeed" end
    if ID:find("Pets") then return "Pets" end
    return "Other"
end
local RequiredUpgrades = {XP = false, Damage = false, AttackSpeed = false, Pets = false}
local LuckyUpgrades = {}
for ID, Data in next, EventUpgrades do if ID:find("LuckyRaid") then LuckyUpgrades[ID] = Data end end
local OrbItem = Items.Misc("Lucky Raid Orb V2")

local function PurchaseUpgrades()
    local Upgrade, LowestCost = nil, math.huge
	for ID, Data in next, LuckyUpgrades do
        local UpgradeType = GetUpgradeTypes(ID)
        local Tier = EventUpgradeCmds.GetTier(ID)
        if not Data.TierCosts[Tier + 1] or not Data.TierCosts[Tier + 1]._data then
			if RequiredUpgrades[UpgradeType] ~= nil then RequiredUpgrades[UpgradeType] = true end
			continue
		end
		if UpgradeType ~= "Other" or (UpgradeType == "Other" and RequiredUpgrades["XP"] and RequiredUpgrades["Damage"] and RequiredUpgrades["AttackSpeed"] and RequiredUpgrades["Pets"]) then
            local Cost = Data.TierCosts[Tier + 1]._data._am or 1
            if Cost and Cost < LowestCost and OrbItem:CountExact() >= Cost then
                LowestCost = Cost
                Upgrade = ID
            end
        end
    end
	if Upgrade then EventUpgradeCmds.Purchase(Upgrade) end
    return Upgrade
end

local function FarmBreakables()
    local RemoteList, PetArray, BreakableArray = {}, {}, {}
    for _,ID in pairs(EquippedPets) do table.insert(PetArray, ID) end
    for UID, Breakable in pairs(BreakablesList) do
		local Name = Breakable:GetAttribute("BreakableID")
		Name = (Name:gsub("LuckyRaid", ""):gsub("(%l)(%u)", "%1 %2"))
		if Raid.LeaveRaid and table.find(Raid.LeaveRaid, Name) then continue end
        table.insert(BreakableArray, UID)
    end
    local PetIndex, BreakableIndex = 1, 1
    local BreakableCount, PetCount = #BreakableArray, #PetArray
    if PetCount == 0 or BreakableCount == 0 then return end
    while PetIndex <= PetCount do
        RemoteList[PetArray[PetIndex]] = BreakableArray[BreakableIndex]
        PetIndex = PetIndex + 1
        BreakableIndex = BreakableIndex + 1
        if BreakableIndex > BreakableCount then BreakableIndex = 1 end
    end
    if next(RemoteList) then
		Network.UnreliableFire("Breakables_PlayerDealDamage", BreakableArray[1])
		Network.Fire("Breakables_JoinPetBulk", RemoteList)
    end
end

local PortalIDs = { ["Solo"] = 1, ["Friends"] = 2, ["Friends & Clan"] = 3, ["Open"] = 4 }
LocalPlayer.PlayerScripts.Scripts.Core["Server Closing"].Enabled = false
LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
Network.Fire("Idle Tracking: Stop Timer")
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
EggFrontend.PlayEggAnimation = function(...) return end

local function OpenBossRooms(CurrentRaid)
	if not CurrentRaid then return end
	for i,v in pairs(Raids.BossDirectory) do
		if CurrentRaid._roomNumber >= v.RequiredRoom and table.find(Raid.OpenBosses, "Boss "..v.BossNumber) then
			if Raid.UpgradeBossChests then Network.Invoke("LuckyRaid_PullLever", v.BossNumber); task.wait(0.25) end
			if v.BossNumber ~= 3 or (v.BossNumber == 3 and Items.Misc("Lucky Raid Boss Key V2"):CountExact() >= 1) then
				local timer = os.time()
				repeat task.wait(); Success, Error = Network.Invoke("Raids_StartBoss", v.BossNumber) until Success or Error or os.time()-timer >= 5
				if Success then task.wait(v.BossNumber == 3 and 1 or 0.25) end
			end
		end
	end
end

task.spawn(function()
    local Data = PlayerSave.Get()
    local StartEggs = Data.EggsHatched or 0
    local discovered_Huge_titan = {}
    local totalhuges = 0

    local function getPetLabel(data)
        local prefix = ""
        if data.sh then prefix = "Shiny " end
        if data.pt == 1 then prefix = prefix .. "Golden " elseif data.pt == 2 then prefix = prefix .. "Rainbow " end
        return prefix .. data.id
    end

    local function sendWebhook(data)
        local WebhookSettings = Settings["Webhook"]
        if not WebhookSettings or not string.find(WebhookSettings.url or "", "https://discord.com/api/webhooks") then return end

        local isTitanic = string.find(data.id, "Titanic") or string.find(data.id, "titanic")
        local isShiny = data.sh
        local isRainbow = data.pt == 2
        local isGolden = data.pt == 1

        local color = 16776960
        if isRainbow then color = 11141375 elseif isGolden then color = 16766720 elseif isShiny then color = 4031935 elseif isTitanic then color = 16711680 end

        local pingText = ""
        if WebhookSettings["Discord Id to ping"] then
            local ids = WebhookSettings["Discord Id to ping"]
            if type(ids) == "table" then
                for _, id in ipairs(ids) do pingText = pingText .. "<@" .. tostring(id) .. "> " end
            else pingText = "<@" .. tostring(ids) .. ">" end
        end

        local bodyTable = {
            content = pingText ~= "" and pingText or nil,
            embeds = {{
                title = isTitanic and "✨ Titanic Hatched!" or "🎉 Huge Hatched!",
                description = "**" .. LocalPlayer.Name .. "** hatched a **" .. getPetLabel(data) .. "**",
                color = color,
                footer = { text = "Eggs hatched: " .. tostring(PlayerSave.Get().EggsHatched - StartEggs) }
            }}
        }
        
        local ok, body = pcall(function() return HttpService:JSONEncode(bodyTable) end)
        if ok then pcall(function() request({Url = WebhookSettings.url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end) end
    end

    if Data.Inventory and Data.Inventory.Pet then
        for UUID, petData in pairs(Data.Inventory.Pet) do
            if string.find(petData.id, "Huge") or string.find(petData.id, "Titanic") then discovered_Huge_titan[UUID] = true end
        end
    end

    while task.wait(1) do
        Data = PlayerSave.Get()
        UI:SetText("Eggs", "Eggs Hatched: " .. UI:Format(Data.EggsHatched - StartEggs))
        if Data.Inventory and Data.Inventory.Pet then
            for UUID, petData in pairs(Data.Inventory.Pet) do
                if string.find(petData.id, "Huge") or string.find(petData.id, "Titanic") then
                    if not discovered_Huge_titan[UUID] then
                        discovered_Huge_titan[UUID] = true
                        totalhuges = totalhuges + 1
                        UI:SetText("Huges", "Session Huges: " .. tostring(totalhuges))
                        pcall(sendWebhook, petData)
                    end
                end
            end
        end
    end
end)

EnterInstance("LuckyEventWorld")
if Raid.Enabled then
	while task.wait() and Raid.Enabled do
		if Main and Main.PurchaseUpgrades then PurchaseUpgrades() end

		local CurrentRaid = RaidInstance.GetByOwner(LocalPlayer)
		local JoinRaid = Raid.JoinRaid and Raid.JoinRaid ~= "Username" and Raid.JoinRaid ~= "" and Raid.JoinRaid
		
        if not JoinRaid and (not CurrentRaid or (CurrentRaid and (CurrentRaid._completed or LeftOnPurpose))) then
			LeftOnPurpose = false
			local Level = RaidCmds.GetLevel()
            UI:SetText("Level", "Current Level: " .. tostring(Level))
            UI:SetText("Status", "Status: Creating Raid...")
            
			local OpenPortal;
			for i = 1,10 do
				local Portal = RaidInstance.GetByPortal(i)
				if not Portal or (Portal and Portal._owner == game.Players.LocalPlayer) then OpenPortal = i; break end
			end
			Network.Fire("Instancing_PlayerLeaveInstance", "LuckyRaid")
			Network.Invoke("Raids_RequestCreate", {
				["Difficulty"] = (type(Raid.Difficulty) == "number" and Level >= Raid.Difficulty and Raid.Difficulty) or Level,
				["Portal"] = OpenPortal,
				["PartyMode"] = PortalIDs[Raid.Type]
			})
		end
        
		repeat task.wait(0.25); CurrentRaid = RaidInstance.GetByOwner(JoinRaid or LocalPlayer) until CurrentRaid
		if CurrentRaid then
			local RaidID = CurrentRaid._id
            UI:SetText("Status", "Status: Joining Raid...")
			Network.Invoke("Raids_Join", RaidID)
			repeat task.wait() until ActiveInstances:FindFirstChild("LuckyRaid")
            
			local StartingTime = os.time()
			local LastBreakable, Name, Breakable, Data
            
            UI:SetText("Status", "Status: Farming Breakables...")
			repeat task.wait(0.1)
				OpenBossRooms(CurrentRaid)
				Breakable, Data = next(BreakablesList)
				if not Data and (os.time()-StartingTime) >= 10 then LeftOnPurpose = true; break end
				
                if (LastBreakable ~= Breakable or not MapCmds.IsInDottedBox()) and Data and Data:FindFirstChildOfClass("MeshPart") then
					Name = Data:GetAttribute("BreakableID")
					Name = (Name:gsub("LuckyRaid", ""):gsub("(%l)(%u)", "%1 %2"))
					if Raid.LeaveRaid and table.find(Raid.LeaveRaid, Name) then LeftOnPurpose = true; break end
					LastBreakable = Breakable
					HumanoidRootPart.CFrame = Data:FindFirstChildOfClass("MeshPart").CFrame * CFrame.new(0,2,0)
				end
				FarmBreakables()
			until ActiveInstances.LuckyRaid.INTERACT:FindFirstChild("LootChest") and not Breakable
			
            UI:SetText("Status", "Status: Opening Chests...")
			for _, Chest in pairs(ActiveInstances.LuckyRaid.INTERACT:GetChildren()) do
				if Chest.Name:find("Sign") or (Chest.Name:find("Leprechaun") and (not Raid.OpenLeprechaunChest or Items.Misc("Lucky Key"):CountExact() < 1)) then continue end
				local Success
				HumanoidRootPart.CFrame = Chest:FindFirstChildOfClass("MeshPart").CFrame
				repeat task.wait(); Success = Network.Invoke("Raids_OpenChest", Chest.Name) until Success
			end

			if Raid["Egg Settings"].Enabled and PlayerSave.Get().RaidEggMultiplier and PlayerSave.Get().RaidEggMultiplier >= Raid["Egg Settings"].MinimumEggMulti and CurrencyCmds.CanAfford("LuckyCoins", Raid["Egg Settings"].MinimumLuckyCoins) then
				EnterInstance("LuckyEgg")
                UI:SetText("Status", "Status: Hatching Raid Egg...")

				local LuckyEgg, EggPrice
				repeat task.wait()
					for UID, Info in next, CustomEggsCmds.All() do
						if workspace.__THINGS.CustomEggs:FindFirstChild(UID) then
							local Power = EventUpgradeCmds.GetPower("LuckyRaidEggCost")
							local CheaperEggs = MasteryCmds.HasPerk("Eggs", "CheaperEggs") and MasteryCmds.GetPerkPower("Eggs", "CheaperEggs") or 0
							EggPrice = CalcEggPrice(Info._dir) * (1 - Power / 100) * (1 - CheaperEggs / 100)
							LuckyEgg = UID
							break
						end
					end
				until LuckyEgg and EggPrice
				
                local MaxEggHatch = EggCmds.GetMaxHatch()
				local NeedsPrice = EggPrice * MaxEggHatch
                StartingTime = os.time()
                
				repeat task.wait(0.1)
					Network.Invoke("CustomEggs_Hatch", LuckyEgg, MaxEggHatch)
				until not CurrencyCmds.CanAfford("LuckyCoins", NeedsPrice) or (os.time() - StartingTime) >= (Raid["Egg Settings"].MaxOpenTime * 60)
			end
		end
	end
else
    while task.wait() and Main.FarmArea do
        UI:SetText("Status", "Status: Farming Main Area...")
        FarmBreakables()
        if not MapCmds.IsInDottedBox() then
			local _, v = next(BreakablesList)
			if v and v:FindFirstChildOfClass("MeshPart") then
				HumanoidRootPart.CFrame = v:FindFirstChildOfClass("MeshPart").CFrame * CFrame.new(0,2,0)
			end
		end
    end
end
