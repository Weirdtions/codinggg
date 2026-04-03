-- Mining system, in ServerScriptService

local Mining = {}

local Players = game:GetService("Players")
local Zones = workspace:WaitForChild("Zones")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Blocks = ReplicatedStorage.Storage.Blocks
local DataFolder = ReplicatedStorage:WaitForChild("Data")
local BlocksFolder = DataFolder:WaitForChild("Blocks")
local BlocksData = require(BlocksFolder:WaitForChild("BlocksData"))
local preferredTools = require(BlocksFolder:WaitForChild("PreferredTools"))
local ServerScriptService = game:GetService("ServerScriptService")
local Drop = require(ServerScriptService.Systems.Drop)
local ServerStorage = game:GetService("ServerStorage")
local DropsData = require(ServerStorage.Data.DropsData)
local DataManager = require(ServerScriptService.Data.DataManager)
local RemoteEvent = ReplicatedStorage.RemoteEvent
local BindableEvent = ReplicatedStorage.BindableEvent
local TICK = 0.05
local MiningPlayers = {}


local function calculateDamage(player, block)

	local function getTool()
		return player.Character:FindFirstChildOfClass("Tool")
	end

	local function getMaterialDamage(material)
		if material == "Wooden" then
			return 2
		elseif material == "Stone" then
			return 4
		elseif material == "Copper" then
			return 5
		elseif material == "Iron" then
			return 6
		end
	end

	local tool = getTool()
	if not tool then return 1 end
	local toolType = tool:GetAttribute("Type")
	local toolMaterial = tool:GetAttribute("Material")
	local blockType = BlocksData[block.Name].Type

	if toolMaterial and table.find(preferredTools[toolType], blockType) then
		return getMaterialDamage(toolMaterial)
	else
		return 1
	end
end

function Mining:Start(player, block)
	if not block or not block:IsDescendantOf(Zones) then return end
	MiningPlayers[player] = {
		block = block,
		damage = 1501 --calculateDamage(player, block)
	}
	block:SetAttribute("Health", BlocksData[block.Name].Hardness * 30)
end

function Mining:Stop(player, block)
	MiningPlayers[player] = nil
end

function Mining:DropCall(player, block, blockName)
	local drop = DropsData[blockName]
	if not drop then return end
	local itemName = drop()
	if not itemName then return end
	self:Drop(block, blockName)
end

function Mining:Drop(block, blockName)
	local toClone = Blocks:FindFirstChild(blockName)
	print(toClone)
	if not toClone then
		warn("Block not found: " .. blockName)
		return
	end
	local clone = toClone:Clone()
	clone.Parent = workspace.Drops
	clone.Position = block.Position
	block:Destroy()
	--clone.Anchored = false
	clone.CanCollide = true
	clone.Transparency = 0
	clone.Size = Vector3.new(1, 1, 1)
	task.spawn(function()
		while true do
			for i=-180, 180 do
				clone.Orientation = Vector3.new(0, i, 0)
				clone.Position = clone.Position + Vector3.new(0, 0.00005 * i, 0)
				task.wait(0.01)
			end
		end
	end)

	clone.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)
		if not player then return end
		local profile = DataManager.Profiles[player]
		if not profile then return end

		if #profile.Data.Slots >= 9 then return end

		clone:Destroy()
		self:DropGive(player, blockName)
	end)
end

function Mining:DropGive(player, itemName)
	local profile = DataManager.Profiles[player]
	if profile then
		if not profile.Data.Slots[itemName] then
			DataManager.AddSlot(player, itemName)
		else
			DataManager.AddSlot(player, itemName)
		end
	end
	print(profile.Data.Slots)
end

function Mining:PickDrop(player, itemName)
	RemoteEvent:FireClient(player, "UpdateHotbar")
	local profile = DataManager.Profiles[player]
	print(profile.Data)
end

function Mining:Init()
	task.spawn(function()
		while true do
			task.wait(TICK)

			for player, data in pairs(MiningPlayers) do
				local block = data.block
				if not block or not block.Parent then
					MiningPlayers[player] = nil
					continue
				end
				local hardness = BlocksData[block.Name].Hardness * 30
				local health = block:GetAttribute("Health")
				health -= data.damage
				block:SetAttribute("Health", health)
				print(health, data.damage)
				if health <= 0 then
					self:DropCall(player, block, block.Name)
					MiningPlayers[player] = nil
				end
			end
		end
	end)
end

local ServerStorage = game:GetService("ServerStorage")
local Blocks = ServerStorage:WaitForChild("Blocks")
local stone = Blocks:WaitForChild("Stone")
local andesite = Blocks:WaitForChild("Andesite")
local granite = Blocks:WaitForChild("Granite")
local diorite = Blocks:WaitForChild("Diorite")
local coal = Blocks:WaitForChild("Coal_Ore")
local iron = Blocks:WaitForChild("Iron_Ore")

function Mining:Reset()
	local function random(options)
		local totalWeight = 0
		for _, item in ipairs(options) do
			totalWeight = totalWeight + item.weight
		end

		local roll = math.random(1, totalWeight)
		local cursor = 0

		for _, item in ipairs(options) do
			cursor = cursor + item.weight
			if roll <= cursor then
				return item
			end
		end
	end
	-- Zone 1
	local blocks1 = {
		{stone, weight = 35},
		{andesite, weight = 15},
		{granite, weight = 15},
		{diorite, weight = 15},
		{coal, weight = 15},
		{iron, weight = 5},
	}
	for _, part in pairs(Zones:WaitForChild("1"):GetChildren()) do
		if part:IsA("MeshPart") then
			part:Destroy()
		elseif part:IsA("Part") then
			local pick = random(blocks1)[1]
			print(pick)
			local block = pick:Clone()
			block.Parent = part.Parent
			block.Position = part.Position
		end
	end
end

return Mining
