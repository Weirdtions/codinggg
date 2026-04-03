-- Player data saving etc
-- Done with ProfileStore module !

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.Packages.ProfileStore) -- ProfileStore module (not mine obv)
local DataManager = require(ServerScriptService.Data.DataManager)
local Template = require(ServerScriptService.Data.Template)

local function getStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local PlayerStore = ProfileStore.New(getStoreName(), Template)

local function Initialize(player, profile)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Parent = leaderstats
	money.Value = profile.Data.Money
end

local function PlayerAdded(player)
	local profile = PlayerStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data issue, try rejoin")
		end)

		if player.Parent == Players then
			DataManager.Profiles[player] = profile
			Initialize(player, profile)
		else
			profile:EndSession()
		end
		print(profile.Data)
	else
		player:Kick("Data issue, try rejoin")
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile:EndSession()
	DataManager.Profiles[player] = nil
end)
