-- Server script !

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.RemoteEvent
local RemoteFunction = ReplicatedStorage.RemoteFunction
local BindableEvent = ReplicatedStorage.BindableEvent
local BindableFunction = ReplicatedStorage.BindableFunction
local ServerScriptService = game:GetService("ServerScriptService")
local Data = ServerScriptService:WaitForChild("Data")
local DataManager = require(Data:WaitForChild("DataManager"))
local Packages = ServerScriptService:WaitForChild("Packages")
local Systems = ServerScriptService:WaitForChild("Systems")

local Mining = require(ServerScriptService.Systems.Mining)
local Drop = require(ServerScriptService.Systems.Drop)

local function getProfile(player)
	local profile = DataManager.Profiles[player]
	local startTime = os.clock()

	while not profile and player.Parent do
		task.wait(0.1)
		profile = DataManager.Profiles[player]

		-- Timeout de seguridad: si tarda más de 15 segundos, cancelamos
		if os.clock() - startTime > 15 then 
			warn("Failed to load profile for player: " .. player.Name)
			return nil 
		end
	end
	return profile
end

Mining:Init()

RemoteEvent.OnServerEvent:Connect(function(player, action, ...)
	local args = {...}
	if action == "StartMining" then
		local target = args[1]
		Mining:Start(player, target)
	elseif action == "StopMining" then
		Mining:Stop(player)
	end
end)

RemoteFunction.OnServerInvoke = function(player, action, ...)
	local args = {...}
	print(player, action, args)
	if action == "Profile" then
		local profile = getProfile(player)
		print(getProfile(player))
		return profile.Data
	else
		print("no action")
	end
end

BindableEvent.Event:Connect(function(player, action, ...)
	local profile = getProfile(player)
	local data = profile.Data
	
	if action == "Drop" then
		local drop, isNew = ...
		print(player, action, drop, isNew)
		if not drop then return end
		if isNew then
			Mining:PickDrop(player, drop)
		else
			Mining:PickDrop(player, drop)
		end
	end
end)

BindableFunction.OnInvoke = function(player, action, ...)
	local args = {...}
	print(player, action, args)
	if action == "Profile" then
		print(player)
		local profile = getProfile(player)
		print(getProfile(player))
		print(profile)
		return profile.Data
	else
		print("no action")
	end
end

task.spawn(function()
	while true do
		Mining:Reset()
		task.wait(15 * 60)
	end
end)
