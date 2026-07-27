local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevConsole"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 380)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(40, 40, 40)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 28)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 6)
topBarCorner.Parent = topBar

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -100, 1, 0)
title.Font = Enum.Font.Code
title.Text = "C:\\Console>"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local hideButton = Instance.new("ImageButton")
hideButton.Name = "HideButton"
hideButton.Size = UDim2.new(0, 20, 0, 20)
hideButton.Position = UDim2.new(1, -56, 0.5, -10)
hideButton.BackgroundTransparency = 1
hideButton.Image = "rbxassetid://6031094667"
hideButton.ImageColor3 = Color3.fromRGB(220, 220, 220)
hideButton.Parent = topBar

local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -28, 0.5, -10)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://6031094678"
closeButton.ImageColor3 = Color3.fromRGB(220, 220, 220)
closeButton.Parent = topBar

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 26)
tabBar.Position = UDim2.new(0, 0, 0, 28)
tabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local logsTab = Instance.new("TextButton")
logsTab.Name = "LogsTab"
logsTab.Size = UDim2.new(0, 100, 1, 0)
logsTab.Position = UDim2.new(0, 0, 0, 0)
logsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
logsTab.BorderSizePixel = 0
logsTab.AutoButtonColor = false
logsTab.Font = Enum.Font.Code
logsTab.Text = "Logs"
logsTab.TextColor3 = Color3.fromRGB(240, 240, 240)
logsTab.TextSize = 14
logsTab.Parent = tabBar

local remotesTab = Instance.new("TextButton")
remotesTab.Name = "RemotesTab"
remotesTab.Size = UDim2.new(0, 100, 1, 0)
remotesTab.Position = UDim2.new(0, 100, 0, 0)
remotesTab.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
remotesTab.BorderSizePixel = 0
remotesTab.AutoButtonColor = false
remotesTab.Font = Enum.Font.Code
remotesTab.Text = "Remotes"
remotesTab.TextColor3 = Color3.fromRGB(180, 180, 180)
remotesTab.TextSize = 14
remotesTab.Parent = tabBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -54)
contentFrame.Position = UDim2.new(0, 0, 0, 54)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local logsFrame = Instance.new("ScrollingFrame")
logsFrame.Name = "LogsFrame"
logsFrame.Size = UDim2.new(1, 0, 1, 0)
logsFrame.BackgroundTransparency = 1
logsFrame.BorderSizePixel = 0
logsFrame.ScrollBarThickness = 4
logsFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
logsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logsFrame.Visible = true
logsFrame.Parent = contentFrame

local logsLayout = Instance.new("UIListLayout")
logsLayout.SortOrder = Enum.SortOrder.LayoutOrder
logsLayout.Padding = UDim.new(0, 2)
logsLayout.Parent = logsFrame

local logsPadding = Instance.new("UIPadding")
logsPadding.PaddingLeft = UDim.new(0, 6)
logsPadding.PaddingTop = UDim.new(0, 4)
logsPadding.PaddingRight = UDim.new(0, 6)
logsPadding.Parent = logsFrame

local remotesFrame = Instance.new("ScrollingFrame")
remotesFrame.Name = "RemotesFrame"
remotesFrame.Size = UDim2.new(1, 0, 1, 0)
remotesFrame.BackgroundTransparency = 1
remotesFrame.BorderSizePixel = 0
remotesFrame.ScrollBarThickness = 4
remotesFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
remotesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
remotesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
remotesFrame.Visible = false
remotesFrame.Parent = contentFrame

local remotesLayout = Instance.new("UIListLayout")
remotesLayout.SortOrder = Enum.SortOrder.LayoutOrder
remotesLayout.Padding = UDim.new(0, 2)
remotesLayout.Parent = remotesFrame

local remotesPadding = Instance.new("UIPadding")
remotesPadding.PaddingLeft = UDim.new(0, 6)
remotesPadding.PaddingTop = UDim.new(0, 4)
remotesPadding.PaddingRight = UDim.new(0, 6)
remotesPadding.Parent = remotesFrame

local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 18, 0, 18)
resizeHandle.Position = UDim2.new(1, -18, 1, -18)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = ""
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 5
resizeHandle.Parent = mainFrame

local resizeIcon = Instance.new("Frame")
resizeIcon.Size = UDim2.new(0, 9, 0, 9)
resizeIcon.Position = UDim2.new(1, -12, 1, -12)
resizeIcon.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
resizeIcon.Rotation = 45
resizeIcon.BorderSizePixel = 0
resizeIcon.ZIndex = 5
resizeIcon.Parent = mainFrame

local function selectTab(tab)
	if tab == "logs" then
		logsFrame.Visible = true
		remotesFrame.Visible = false
		logsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		logsTab.TextColor3 = Color3.fromRGB(240, 240, 240)
		remotesTab.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		remotesTab.TextColor3 = Color3.fromRGB(180, 180, 180)
	else
		logsFrame.Visible = false
		remotesFrame.Visible = true
		remotesTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		remotesTab.TextColor3 = Color3.fromRGB(240, 240, 240)
		logsTab.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		logsTab.TextColor3 = Color3.fromRGB(180, 180, 180)
	end
end

logsTab.MouseButton1Click:Connect(function()
	selectTab("logs")
end)

remotesTab.MouseButton1Click:Connect(function()
	selectTab("remotes")
end)

local dragging = false
local dragInput
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local resizing = false
local resizeStart
local startSize

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStart = input.Position
		startSize = mainFrame.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - resizeStart
		local newWidth = math.clamp(startSize.X.Offset + delta.X, 340, 900)
		local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 220, 640)
		mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
	end
end)

local function scrollToBottom(frame)
	task.defer(function()
		frame.CanvasPosition = Vector2.new(0, math.huge)
	end)
end

local function createEntry(parent, message, textColor)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 18)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0, 4)
	rowLayout.Parent = row

	local braces = Instance.new("TextLabel")
	braces.Size = UDim2.new(0, 16, 1, 0)
	braces.BackgroundTransparency = 1
	braces.Font = Enum.Font.Code
	braces.Text = "{}"
	braces.TextColor3 = Color3.fromRGB(255, 255, 255)
	braces.TextSize = 14
	braces.TextXAlignment = Enum.TextXAlignment.Left
	braces.Parent = row

	local plus = Instance.new("TextLabel")
	plus.Size = UDim2.new(0, 12, 1, 0)
	plus.BackgroundTransparency = 1
	plus.Font = Enum.Font.Code
	plus.Text = "+"
	plus.TextColor3 = Color3.fromRGB(220, 40, 40)
	plus.TextSize = 14
	plus.TextXAlignment = Enum.TextXAlignment.Left
	plus.Parent = row

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -36, 1, 0)
	textBox.BackgroundTransparency = 1
	textBox.Font = Enum.Font.Code
	textBox.Text = message
	textBox.TextColor3 = textColor
	textBox.TextSize = 14
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextTruncate = Enum.TextTruncate.AtEnd
	textBox.ClearTextOnFocus = false
	textBox.TextEditable = false
	textBox.MultiLine = false
	textBox.Parent = row

	return textBox
end

local function addLog(message, isError)
	local color = isError and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(255, 200, 90)
	createEntry(logsFrame, message, color)
	scrollToBottom(logsFrame)
end

LogService.MessageOut:Connect(function(message, messageType)
	if messageType == Enum.MessageType.MessageError then
		addLog(message, true)
	elseif messageType == Enum.MessageType.MessageWarning then
		addLog(message, false)
	end
end)

local remoteEntries = {}

local function logRemote(remoteInstance, kind)
	local key = remoteInstance:GetFullName()
	local data = remoteEntries[key]
	if data then
		data.count = data.count + 1
		data.textBox.Text = string.format("[%s] %s (x%d)", kind, key, data.count)
		return
	end

	local textBox = createEntry(remotesFrame, string.format("[%s] %s", kind, key), Color3.fromRGB(120, 200, 255))
	remoteEntries[key] = { textBox = textBox, count = 1 }
	scrollToBottom(remotesFrame)
end

local function hookRemote(instance)
	if instance:IsA("RemoteEvent") then
		instance.OnClientEvent:Connect(function()
			logRemote(instance, "RemoteEvent")
		end)
	elseif instance:IsA("RemoteFunction") then
		local originalCallback = instance.OnClientInvoke
		instance.OnClientInvoke = function(...)
			logRemote(instance, "RemoteFunction")
			if originalCallback then
				return originalCallback(...)
			end
		end
	end
end

for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
	hookRemote(instance)
end

ReplicatedStorage.DescendantAdded:Connect(hookRemote)

local function notifyReopen()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Console",
			Text = "Press F to show the interface again",
			Duration = 5
		})
	end)
end

local function hideInterface()
	mainFrame.Visible = false
	notifyReopen()
end

hideButton.MouseButton1Click:Connect(hideInterface)
closeButton.MouseButton1Click:Connect(hideInterface)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		mainFrame.Visible = true
	end
end)
