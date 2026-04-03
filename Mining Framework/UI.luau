-- UI scripting example, in ReplicatedStorage

local UI = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RemoteEvent = ReplicatedStorage.RemoteEvent
local BindableEvent = ReplicatedStorage.BindableEvent
local BindableFunction = ReplicatedStorage:WaitForChild("BindableFunction")

local function PC(player: Player, data)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local PlayerGui = player:WaitForChild("PlayerGui")
	local gui = PlayerGui:WaitForChild("UI")
	local inventory = gui:WaitForChild("Inventory")
	local hotbar = gui:WaitForChild("Hotbar")
	local healthBar = hotbar:WaitForChild("Health")
	local ImageData = require(ReplicatedStorage.Data.Utility.ImageData)
	
	-- Heatlh bar

	local hearts
  for i = 1, 10 do
  	hearts[i] = healthBar:WaitForChild(tostring(i))
  end
	local HEART_FULL = "rbxassetid://81478136381225"
	local HEART_HALF = "rbxassetid://127600236135640"
	local HEART_EMPTY = "rbxassetid://130003078466084"
	local function updateHearts(health)
		for i = 1, 10 do
			local heart = hearts[i]

			local heartMax = i * 10
			local diff = health - (heartMax - 10)

			if diff >= 10 then
				heart.Image = HEART_FULL
			elseif diff >= 5 then
				heart.Image = HEART_HALF
			else
				heart.Image = HEART_EMPTY
			end
		end
	end
	humanoid.HealthChanged:Connect(updateHearts)
	
	
	
	local slots
  for i = 1, 10 do
  	hearts[i] = hotbar:WaitForChild("Slots"):WaitForChild(tostring(i))
  end
	local selectedFrame = gui:WaitForChild("Selected")

	local keys = {
		[1] = Enum.KeyCode.One,
		[2] = Enum.KeyCode.Two,
		[3] = Enum.KeyCode.Three,
		[4] = Enum.KeyCode.Four,
		[5] = Enum.KeyCode.Five,
		[6] = Enum.KeyCode.Six,
		[7] = Enum.KeyCode.Seven,
		[8] = Enum.KeyCode.Eight,
		[9] = Enum.KeyCode.Nine
	}

	local function moveSelected(i)
		local function moveSelectedFrame(i)
			selectedFrame.Position = UDim2.new(0, slots[i].AbsolutePosition.X, 0, slots[i].AbsolutePosition.Y + 2.5)
		end
		local function unequipTools()
			selectedFrame.Visible = false
			humanoid:UnequipTools()
		end
		selectedFrame.Size = UDim2.new(0, slots[i].AbsoluteSize.X, 0, slots[i].AbsoluteSize.Y)
		local hotbar = data.Slots
		local toolName = hotbar[i]
		if selectedFrame.Position == UDim2.new(0, slots[i].AbsolutePosition.X, 0, slots[i].AbsolutePosition.Y + 2.5) then unequipTools() return end
		if not selectedFrame.Visible then selectedFrame.Visible = true end
		if not toolName then
			humanoid:UnequipTools()
			moveSelectedFrame(i) return
		end
		local tool = player.Backpack:FindFirstChild(toolName)
		humanoid:EquipTool(tool)
		moveSelectedFrame(i)
	end

	moveSelected(1)
	selectedFrame.Size = UDim2.new(0, slots[1].AbsoluteSize.X, 0, slots[1].AbsoluteSize.Y)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.E then
			inventory.Visible = not inventory.Visible
		end

		for i = 1, 9 do
			if input.KeyCode == keys[i] then
				moveSelected(i)
			end
		end
	end)
	for _, v in pairs(slots) do
		v.Activated:Connect(function()
			moveSelected(tonumber(v.Name))
		end)
	end

	local hotbarData = data.Slots
	local slotImages = hotbar:WaitForChild("SlotImages")
	local selectedFrame = gui:WaitForChild("Selected")
	local selected
	
	local function updateSlotVisuals()
		for _, child in ipairs(slotImages:GetChildren()) do
			if child:IsA("GuiObject") and not child:IsA("UIGridLayout") then
				child:Destroy()
			end
		end

		for i = 1, 9 do
			local item = hotbarData[i]
			local slotImage

			if item then
				if item:match("Pickaxe") or item:match("Axe") or item:match("Shovel") or item:match("Sword") then
					slotImage = Instance.new("ImageLabel")
					slotImage.Image = ImageData[item]
					slotImage.ResampleMode = Enum.ResamplerMode.Pixelated
					slotImage.ScaleType = Enum.ScaleType.Fit
				else
					slotImage = Instance.new("ViewportFrame")
					local block = ReplicatedStorage.Storage.Blocks:FindFirstChild(item)
					if block then
						local clone = block:Clone()
						clone.Parent = slotImage
						local camera = Instance.new("Camera")
						slotImage.CurrentCamera = camera
						camera.Parent = slotImage
						local distance = 5
						local offset = Vector3.new(5, 5, 5).Unit * distance
						camera.CFrame = CFrame.new(offset, Vector3.new(0, -0.5, 0))
						slotImage.LightDirection = Vector3.new(-1, -1, -1)
						slotImage.Ambient = Color3.fromRGB(200, 200, 200)
						camera.FieldOfView = 60
					end
				end
			else
				slotImage = Instance.new("Frame")
			end

			if slotImage then
				slotImage.Name = tostring(i)
				slotImage.BackgroundTransparency = 1
				slotImage.Size = UDim2.new(1, 0, 1, 0)
				slotImage.Parent = slotImages
			end
		end
	end

	updateSlotVisuals()
	
	RemoteEvent.OnClientEvent:Connect(function(action)
		print(RemoteEvent, player, action)
		if action == "UpdateHotbar" then
			print("updateHotbar")
			updateSlotVisuals()
		end
	end)
end

function UI:Init(player, data, mouse)
	local isMobile = UserInputService.TouchEnabled
	local isConsole = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
	local isPC = UserInputService.KeyboardEnabled
	print(isMobile, isConsole, isPC)
	if isMobile then
		print("mobile")
	elseif isConsole then
		print("console")
	else
		print("pc")
		PC(player, data)
		if not mouse then return end
		mouse.Icon = "rbxassetid://84016372234839"
	end
end

return UI
