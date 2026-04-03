-- Class module example ! (oop design wow !!!!)

local DiceClass = {}
DiceClass.__index = DiceClass

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local DiceData = require(game.ServerStorage.Data.Dices)
local UmaData = require(game.ServerStorage.Data.Umas)

function DiceClass.new(name)
	local data = DiceData[name]
	return setmetatable({
		Name = data.Name,
		Items = data.Items,
	}, DiceClass)
end

function DiceClass:Roll(player)
	local roll = Random.new():NextNumber(0, 100)
	local cumulative = 0

	for _, item in ipairs(self.Items) do
		cumulative += item.Chance
		if roll <= cumulative then
			local options = {}
			for nombre, config in pairs(UmaData) do
				if config.Rarity == item.Rarity then
					table.insert(options, nombre)
				end
			end

			local pick = options[math.random(1, #options)]
			GiveUma(player, pick, item.Rarity, UmaData[pick].Type)
			return pick
		end
	end
end

function GiveUma(player: Player, pick, rarity, typee)
	local tool
	print(rarity, typee)
	for _, v in pairs(ServerStorage.Storage.Tools:GetChildren()) do
		if v.Name == pick and CollectionService:HasTag(v, tostring(rarity .. "_" .. typee)) then
			tool = ServerStorage.Storage.Tools:FindFirstChild(pick):Clone()
		end
	end
	tool.Parent = player.Backpack
end

return DiceClass
