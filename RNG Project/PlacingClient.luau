-- Client-side of a placing system ! (like in "rob a" games)

local module = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local tag = "UmaPlacing"

local function onTagAdded(prompt: ProximityPrompt)
	prompt.Triggered:Connect(function(player)
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then
			return
		end
		local uma = character:FindFirstChildWhichIsA("Tool")
		if not uma then
			return
		end
		RemoteEvent:FireServer("UmaPlacing", prompt, uma)
	end)
end
for _, prompt in CollectionService:GetTagged(tag) do
	onTagAdded(prompt)
end
CollectionService:GetInstanceAddedSignal(tag):Connect(onTagAdded)

return module
