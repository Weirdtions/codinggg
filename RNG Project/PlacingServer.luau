-- Server-side of a placing system ! (like in "rob a" games)

local module = {}

local ServerStorage = game:GetService("ServerStorage")
local Characters = ServerStorage.Storage.Characters
local UmasData = require(ServerStorage.Data.Umas)
local UmaClass = require(ServerStorage.Classes.UmaClass)

function module:Place(player: Player, prompt: ProximityPrompt, tool: Tool, plot)
	local part = prompt.Parent
	if not plot:IsInside(part.Position) then
		return
	end
	local config = UmasData[tool.Name]
	local umaChar = Characters:FindFirstChild(tool.Name):Clone()

	umaChar.Parent = part
	umaChar:PivotTo(part.CFrame + Vector3.new(0, 5, 0))

	local uma = UmaClass.new(player, umaChar, config)
	uma:GenerateMoney()

	part.MoneyPart.Touched:Connect(function(hit)
		local char = player.Character
		if char and hit:IsDescendantOf(char) then
			uma:Collect()
		end
	end)

	tool:Destroy()
end

return module
