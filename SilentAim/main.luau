local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local S = {
	Enabled         = false,
	ESPEnabled      = false,
	WallCheck       = true,
	TeamCheck       = false,
	SmoothAim       = true,
	PredictMovement = false,
	ShowFOV         = true,
	RequireKey      = false,
	TargetPart      = "Head",
	AimKey          = "MouseButton2",
	SortMethod      = "Distance2D",
	FOVRadius       = 150,
	AimSpeed        = 15,
	MaxDistance     = 800,
	PredictStr      = 5,
}

local TargetParts = {"Head","HumanoidRootPart","UpperTorso","LowerTorso","LeftArm","RightArm"}
local AimKeys     = {"MouseButton2","E","Q","Z","X","C","G","Always"}
local SortMethods = {"Distance2D","Distance3D","LowestHP","HighestHP"}

local gui = Instance.new("ScreenGui")
gui.Name           = "SilentAim"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer.PlayerGui

local W = Instance.new("Frame", gui)
W.Size              = UDim2.new(0, 300, 0, 480)
W.Position          = UDim2.new(0, 60, 0, 60)
W.BackgroundColor3  = Color3.fromRGB(9, 9, 13)
W.BorderSizePixel   = 0
W.ClipsDescendants  = false
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 12)
local wStroke = Instance.new("UIStroke", W)
wStroke.Color       = Color3.fromRGB(140, 18, 18)
wStroke.Thickness   = 1.4
wStroke.Transparency = 0.35

local topBar = Instance.new("Frame", W)
topBar.Size             = UDim2.new(1, 0, 0, 3)
topBar.BackgroundColor3 = Color3.fromRGB(210, 30, 30)
topBar.BorderSizePixel  = 0
topBar.ZIndex           = 2
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 2)
local tg = Instance.new("UIGradient", topBar)
tg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(160, 18, 18)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 65, 65)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(160, 18, 18)),
})

local bgImg = Instance.new("ImageLabel", W)
bgImg.Size                   = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image                  = "rbxasset://icons/background.png"
bgImg.ImageTransparency      = 0.55
bgImg.ScaleType              = Enum.ScaleType.Crop
bgImg.ZIndex                 = 0
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 12)

local hdr = Instance.new("Frame", W)
hdr.Size            = UDim2.new(1, 0, 0, 50)
hdr.Position        = UDim2.new(0, 0, 0, 3)
hdr.BackgroundColor3 = Color3.fromRGB(13, 11, 18)
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 3

local ico = Instance.new("ImageLabel", hdr)
ico.Size                   = UDim2.new(0, 26, 0, 26)
ico.Position               = UDim2.new(0, 12, 0.5, -13)
ico.BackgroundTransparency = 1
ico.Image                  = "rbxasset://icons/icon.png"
ico.ZIndex                 = 4

local ttl = Instance.new("TextLabel", hdr)
ttl.Size               = UDim2.new(0, 150, 0, 22)
ttl.Position           = UDim2.new(0, 46, 0, 7)
ttl.BackgroundTransparency = 1
ttl.Text               = "SILENT AIM"
ttl.TextColor3         = Color3.fromRGB(235, 235, 235)
ttl.TextSize           = 13
ttl.Font               = Enum.Font.GothamBold
ttl.TextXAlignment     = Enum.TextXAlignment.Left
ttl.ZIndex             = 4

local sub = Instance.new("TextLabel", hdr)
sub.Size               = UDim2.new(0, 150, 0, 14)
sub.Position           = UDim2.new(0, 46, 0, 31)
sub.BackgroundTransparency = 1
sub.Text               = "by FrontEvill"
sub.TextColor3         = Color3.fromRGB(75, 22, 22)
sub.TextSize           = 10
sub.Font               = Enum.Font.Gotham
sub.TextXAlignment     = Enum.TextXAlignment.Left
sub.ZIndex             = 4

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size             = UDim2.new(0, 24, 0, 24)
closeBtn.Position         = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(26, 10, 10)
closeBtn.BorderSizePixel  = 0
closeBtn.Text             = "x"
closeBtn.TextColor3       = Color3.fromRGB(180, 40, 40)
closeBtn.TextSize         = 12
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.ZIndex           = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
local cs = Instance.new("UIStroke", closeBtn)
cs.Color = Color3.fromRGB(70, 16, 16) cs.Thickness = 1

local tabBar = Instance.new("Frame", W)
tabBar.Size             = UDim2.new(1, 0, 0, 32)
tabBar.Position         = UDim2.new(0, 0, 0, 53)
tabBar.BackgroundColor3 = Color3.fromRGB(11, 9, 16)
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 3

local tabDiv = Instance.new("Frame", tabBar)
tabDiv.Size             = UDim2.new(1, 0, 0, 1)
tabDiv.Position         = UDim2.new(0, 0, 1, -1)
tabDiv.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
tabDiv.BorderSizePixel  = 0
tabDiv.ZIndex           = 3

local pages    = {}
local tabBtns  = {}
local curTab   = nil

local function switchTab(name)
	if curTab then
		pages[curTab].Visible          = false
		tabBtns[curTab].BackgroundColor3 = Color3.fromRGB(13, 9, 18)
		tabBtns[curTab].TextColor3       = Color3.fromRGB(110, 38, 38)
	end
	curTab = name
	pages[name].Visible          = true
	tabBtns[name].BackgroundColor3 = Color3.fromRGB(130, 16, 16)
	tabBtns[name].TextColor3       = Color3.fromRGB(255, 255, 255)
end

local tabNames = {"Toggles", "Lists", "Sliders"}
for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", tabBar)
	btn.Size             = UDim2.new(0, 84, 0, 24)
	btn.Position         = UDim2.new(0, 6 + (i-1) * 90, 0.5, -12)
	btn.BackgroundColor3 = Color3.fromRGB(13, 9, 18)
	btn.BorderSizePixel  = 0
	btn.Text             = name
	btn.TextColor3       = Color3.fromRGB(110, 38, 38)
	btn.TextSize         = 11
	btn.Font             = Enum.Font.GothamBold
	btn.ZIndex           = 4
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local bs = Instance.new("UIStroke", btn)
	bs.Color = Color3.fromRGB(45, 12, 12) bs.Thickness = 1

	local page = Instance.new("ScrollingFrame", W)
	page.Size                   = UDim2.new(1, 0, 1, -88)
	page.Position               = UDim2.new(0, 0, 0, 88)
	page.BackgroundTransparency = 1
	page.BorderSizePixel        = 0
	page.ScrollBarThickness     = 2
	page.ScrollBarImageColor3   = Color3.fromRGB(140, 20, 20)
	page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	page.CanvasSize             = UDim2.new(0, 0, 0, 0)
	page.Visible                = false
	page.ZIndex                 = 3

	local layout = Instance.new("UIListLayout", page)
	layout.Padding             = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local pad = Instance.new("UIPadding", page)
	pad.PaddingTop    = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.PaddingLeft   = UDim.new(0, 12)
	pad.PaddingRight  = UDim.new(0, 12)

	pages[name]   = page
	tabBtns[name] = btn

	btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Toggles")

local function SecLabel(page, txt)
	local f = Instance.new("Frame", page)
	f.Size             = UDim2.new(1, 0, 0, 20)
	f.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
	f.BorderSizePixel  = 0
	f.ZIndex           = 4
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
	local l = Instance.new("TextLabel", f)
	l.Size               = UDim2.new(1, -10, 1, 0)
	l.Position           = UDim2.new(0, 8, 0, 0)
	l.BackgroundTransparency = 1
	l.Text               = txt
	l.TextColor3         = Color3.fromRGB(170, 35, 35)
	l.TextSize           = 10
	l.Font               = Enum.Font.GothamBold
	l.TextXAlignment     = Enum.TextXAlignment.Left
	l.ZIndex             = 4
end

local function Toggle(page, label, default, cb)
	local row = Instance.new("Frame", page)
	row.Size             = UDim2.new(1, 0, 0, 38)
	row.BackgroundColor3 = Color3.fromRGB(13, 11, 19)
	row.BorderSizePixel  = 0
	row.ZIndex           = 4
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(28, 12, 12) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(1, -58, 1, 0)
	lbl.Position           = UDim2.new(0, 11, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(200, 200, 200)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 4

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(0, 38, 0, 19)
	track.Position         = UDim2.new(1, -48, 0.5, -9.5)
	track.BackgroundColor3 = default and Color3.fromRGB(155, 20, 20) or Color3.fromRGB(28, 14, 14)
	track.BorderSizePixel  = 0
	track.ZIndex           = 4
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", track)
	knob.Size             = UDim2.new(0, 13, 0, 13)
	knob.Position         = default and UDim2.new(1, -16, 0.5, -6.5) or UDim2.new(0, 3, 0.5, -6.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel  = 0
	knob.ZIndex           = 5
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = default
	local hit = Instance.new("TextButton", row)
	hit.Size               = UDim2.new(1, 0, 1, 0)
	hit.BackgroundTransparency = 1
	hit.Text               = ""
	hit.ZIndex             = 6
	hit.MouseButton1Click:Connect(function()
		state = not state
		track.BackgroundColor3 = state and Color3.fromRGB(155, 20, 20) or Color3.fromRGB(28, 14, 14)
		knob.Position = state and UDim2.new(1, -16, 0.5, -6.5) or UDim2.new(0, 3, 0.5, -6.5)
		if cb then cb(state) end
	end)
end

local function Dropdown(page, label, options, default, cb)
	local wrap = Instance.new("Frame", page)
	wrap.Size               = UDim2.new(1, 0, 0, 38)
	wrap.BackgroundTransparency = 1
	wrap.ClipsDescendants   = false
	wrap.ZIndex             = 5

	local row = Instance.new("Frame", wrap)
	row.Size             = UDim2.new(1, 0, 0, 38)
	row.BackgroundColor3 = Color3.fromRGB(13, 11, 19)
	row.BorderSizePixel  = 0
	row.ZIndex           = 5
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(28, 12, 12) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(0, 100, 1, 0)
	lbl.Position           = UDim2.new(0, 11, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(200, 200, 200)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 5

	local sel = Instance.new("TextButton", row)
	sel.Size             = UDim2.new(0, 110, 0, 24)
	sel.Position         = UDim2.new(1, -120, 0.5, -12)
	sel.BackgroundColor3 = Color3.fromRGB(20, 9, 9)
	sel.BorderSizePixel  = 0
	sel.Text             = default .. " v"
	sel.TextColor3       = Color3.fromRGB(190, 40, 40)
	sel.TextSize         = 11
	sel.Font             = Enum.Font.GothamBold
	sel.ZIndex           = 6
	Instance.new("UICorner", sel).CornerRadius = UDim.new(0, 5)
	local ss = Instance.new("UIStroke", sel)
	ss.Color = Color3.fromRGB(75, 18, 18) ss.Thickness = 1

	local drop = Instance.new("Frame", row)
	drop.Size             = UDim2.new(0, 110, 0, #options * 26)
	drop.Position         = UDim2.new(1, -120, 1, 3)
	drop.BackgroundColor3 = Color3.fromRGB(11, 7, 7)
	drop.BorderSizePixel  = 0
	drop.ZIndex           = 20
	drop.Visible          = false
	Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 6)
	local ds = Instance.new("UIStroke", drop)
	ds.Color = Color3.fromRGB(75, 18, 18) ds.Thickness = 1
	Instance.new("UIListLayout", drop).Padding = UDim.new(0, 0)

	for _, opt in ipairs(options) do
		local item = Instance.new("TextButton", drop)
		item.Size             = UDim2.new(1, 0, 0, 26)
		item.BackgroundColor3 = Color3.fromRGB(11, 7, 7)
		item.BorderSizePixel  = 0
		item.Text             = opt
		item.TextColor3       = Color3.fromRGB(185, 185, 185)
		item.TextSize         = 11
		item.Font             = Enum.Font.Gotham
		item.ZIndex           = 21
		item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(30, 10, 10) end)
		item.MouseLeave:Connect(function() item.BackgroundColor3 = Color3.fromRGB(11, 7, 7) end)
		item.MouseButton1Click:Connect(function()
			sel.Text     = opt .. " v"
			drop.Visible = false
			if cb then cb(opt) end
		end)
	end

	sel.MouseButton1Click:Connect(function()
		drop.Visible = not drop.Visible
	end)
end

local function Slider(page, label, min, max, default, suffix, cb)
	local row = Instance.new("Frame", page)
	row.Size             = UDim2.new(1, 0, 0, 52)
	row.BackgroundColor3 = Color3.fromRGB(13, 11, 19)
	row.BorderSizePixel  = 0
	row.ZIndex           = 4
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(28, 12, 12) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(0.6, 0, 0, 20)
	lbl.Position           = UDim2.new(0, 11, 0, 7)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(200, 200, 200)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 4

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size               = UDim2.new(0.38, 0, 0, 20)
	valLbl.Position           = UDim2.new(0.6, 0, 0, 7)
	valLbl.BackgroundTransparency = 1
	valLbl.Text               = tostring(default) .. (suffix or "")
	valLbl.TextColor3         = Color3.fromRGB(195, 40, 40)
	valLbl.TextSize           = 12
	valLbl.Font               = Enum.Font.GothamBold
	valLbl.TextXAlignment     = Enum.TextXAlignment.Right
	valLbl.ZIndex             = 4

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(1, -22, 0, 5)
	track.Position         = UDim2.new(0, 11, 0, 36)
	track.BackgroundColor3 = Color3.fromRGB(25, 12, 12)
	track.BorderSizePixel  = 0
	track.ZIndex           = 4
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(175, 28, 28)
	fill.BorderSizePixel  = 0
	fill.ZIndex           = 4
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local fg = Instance.new("UIGradient", fill)
	fg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 55, 55)),
	})

	local knob = Instance.new("Frame", track)
	knob.Size         = UDim2.new(0, 13, 0, 13)
	knob.AnchorPoint  = Vector2.new(0.5, 0.5)
	knob.Position     = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel  = 0
	knob.ZIndex       = 5
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function update(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local val = math.floor(min + rel * (max - min))
		valLbl.Text   = tostring(val) .. (suffix or "")
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if cb then cb(val) end
	end

	local hit = Instance.new("TextButton", track)
	hit.Size               = UDim2.new(1, 0, 0, 22)
	hit.Position           = UDim2.new(0, 0, 0.5, -11)
	hit.BackgroundTransparency = 1
	hit.Text               = ""
	hit.ZIndex             = 6

	hit.MouseButton1Down:Connect(function()
		dragging = true
		update(UserInputService:GetMouseLocation().X)
	end)

	hit.TouchLongPress:Connect(function()
		dragging = true
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
			update(i.Position.X)
		end
	end)
end

SecLabel(pages["Toggles"], "AIM")
Toggle(pages["Toggles"], "Aimbot",          false, function(v) S.Enabled        = v end)
Toggle(pages["Toggles"], "Smooth Aim",      true,  function(v) S.SmoothAim       = v end)
Toggle(pages["Toggles"], "Require Key",     false, function(v) S.RequireKey      = v end)
Toggle(pages["Toggles"], "Predict Movement",false, function(v) S.PredictMovement = v end)
SecLabel(pages["Toggles"], "FILTERS")
Toggle(pages["Toggles"], "Wall Check",      true,  function(v) S.WallCheck  = v end)
Toggle(pages["Toggles"], "Team Check",      false, function(v) S.TeamCheck  = v end)
SecLabel(pages["Toggles"], "VISUAL")
Toggle(pages["Toggles"], "Show FOV",        true,  function(v) S.ShowFOV    = v end)
Toggle(pages["Toggles"], "ESP Names",       false, function(v) S.ESPEnabled = v end)

SecLabel(pages["Lists"], "TARGET")
Dropdown(pages["Lists"], "Target Part", TargetParts, S.TargetPart, function(v) S.TargetPart = v end)
Dropdown(pages["Lists"], "Sort Method", SortMethods, S.SortMethod, function(v) S.SortMethod = v end)
SecLabel(pages["Lists"], "CONTROLS")
Dropdown(pages["Lists"], "Aim Key",     AimKeys,     S.AimKey,     function(v) S.AimKey     = v end)

SecLabel(pages["Sliders"], "AIM")
Slider(pages["Sliders"], "FOV Radius",    40,  600,  S.FOVRadius,   "px", function(v) S.FOVRadius    = v end)
Slider(pages["Sliders"], "Aim Speed",     1,   60,   S.AimSpeed,    "",   function(v) S.AimSpeed     = v end)
Slider(pages["Sliders"], "Max Distance",  50,  2000, S.MaxDistance, "st", function(v) S.MaxDistance  = v end)
Slider(pages["Sliders"], "Predict Str",   1,   20,   S.PredictStr,  "",   function(v) S.PredictStr   = v end)

local oGui = Instance.new("ScreenGui")
oGui.Name           = "SilentAim_Overlay"
oGui.ResetOnSpawn   = false
oGui.IgnoreGuiInset = true
oGui.Parent         = LocalPlayer.PlayerGui

local oFrame = Instance.new("Frame", oGui)
oFrame.Size                   = UDim2.new(1, 0, 1, 0)
oFrame.BackgroundTransparency = 1

local fovCircle = Instance.new("Frame", oFrame)
fovCircle.AnchorPoint      = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel  = 0
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color     = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.2
fovStroke.Transparency = 0.25

local espFolder = Instance.new("Folder", oGui)

local espTags = {}

local function makeESP(pl)
	if espTags[pl] then return end
	local function tryBind()
		local char = pl.Character or pl.CharacterAdded:Wait()
		local hrp  = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end
		local bb = Instance.new("BillboardGui")
		bb.Name          = "ESP"
		bb.Adornee       = hrp
		bb.Size          = UDim2.new(0, 70, 0, 18)
		bb.StudsOffset   = Vector3.new(0, 3.4, 0)
		bb.AlwaysOnTop   = true
		bb.LightInfluence = 0
		bb.Parent        = espFolder
		local tag = Instance.new("TextLabel", bb)
		tag.Size               = UDim2.new(1, 0, 1, 0)
		tag.BackgroundTransparency = 1
		tag.Text               = pl.Name
		tag.TextColor3         = Color3.fromRGB(255, 255, 255)
		tag.TextSize           = 11
		tag.Font               = Enum.Font.GothamBold
		tag.TextStrokeTransparency = 0.3
		tag.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
		tag.TextXAlignment     = Enum.TextXAlignment.Center
		espTags[pl] = bb
		pl.CharacterAdded:Connect(function(newChar)
			local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
			if newHRP and espTags[pl] then
				espTags[pl].Adornee = newHRP
			end
		end)
	end
	task.spawn(tryBind)
end

local function removeESP(pl)
	if espTags[pl] then
		espTags[pl]:Destroy()
		espTags[pl] = nil
	end
end

for _, pl in ipairs(Players:GetPlayers()) do
	if pl ~= LocalPlayer then makeESP(pl) end
end
Players.PlayerAdded:Connect(function(pl) makeESP(pl) end)
Players.PlayerRemoving:Connect(removeESP)

local function toggleESPVisibility()
	for pl, bb in pairs(espTags) do
		bb.Enabled = S.ESPEnabled
	end
end

local dragging   = false
local dragOffset = Vector2.new()

local function startDrag(pos)
	dragging   = true
	dragOffset = Vector2.new(pos.X - W.AbsolutePosition.X, pos.Y - W.AbsolutePosition.Y)
end

local function moveDrag(pos)
	if not dragging then return end
	W.Position = UDim2.new(0, pos.X - dragOffset.X, 0, pos.Y - dragOffset.Y)
end

local function stopDrag()
	dragging = false
end

hdr.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		startDrag(i.Position)
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement
	or i.UserInputType == Enum.UserInputType.Touch then
		moveDrag(i.Position)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		stopDrag()
	end
end)

closeBtn.MouseButton1Click:Connect(function() W.Visible = false end)
UserInputService.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.F then W.Visible = not W.Visible end
end)

local function keyActive()
	if not S.RequireKey then return true end
	if S.AimKey == "Always" then return true end
	if S.AimKey == "MouseButton2" then
		return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end
	local ok, kc = pcall(function() return Enum.KeyCode[S.AimKey] end)
	return ok and UserInputService:IsKeyDown(kc)
end

local function canSee(part)
	if not S.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local rp     = RaycastParams.new()
	rp.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
	rp.FilterType = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(origin, part.Position - origin, rp) == nil
end

local function getBest()
	local cx, cy   = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
	local center   = Vector2.new(cx, cy)
	local best, bestScore = nil, math.huge

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl == LocalPlayer then continue end
		if S.TeamCheck and pl.Team == LocalPlayer.Team then continue end
		local char = pl.Character if not char then continue end
		local part = char:FindFirstChild(S.TargetPart) if not part then continue end
		local hum  = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		if (part.Position - Camera.CFrame.Position).Magnitude > S.MaxDistance then continue end
		if not canSee(part) then continue end
		local sp, vis = Camera:WorldToViewportPoint(part.Position)
		if not vis then continue end
		local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if d2 > S.FOVRadius then continue end
		local score = d2
		if S.SortMethod == "Distance3D" then score = (part.Position - Camera.CFrame.Position).Magnitude
		elseif S.SortMethod == "LowestHP"  then score = hum.Health
		elseif S.SortMethod == "HighestHP" then score = -hum.Health end
		if score < bestScore then bestScore = score best = part end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	local cx = Camera.ViewportSize.X / 2
	local cy = Camera.ViewportSize.Y / 2
	local r  = S.FOVRadius

	fovCircle.Visible  = S.ShowFOV
	fovCircle.Position = UDim2.new(0, cx, 0, cy)
	fovCircle.Size     = UDim2.new(0, r * 2, 0, r * 2)

	toggleESPVisibility()

	if not S.Enabled or not keyActive() then return end

	local target = getBest()
	if not target then return end

	local aimPos = target.Position
	if S.PredictMovement then
		local vel  = target.AssemblyLinearVelocity
		local ping = LocalPlayer:GetNetworkPing()
		aimPos     = target.Position + vel * ping * (S.PredictStr / 10)
	end

	local _, vis = Camera:WorldToViewportPoint(aimPos)
	if not vis then return end

	local newCF = CFrame.new(Camera.CFrame.Position, aimPos)
	if S.SmoothAim then
		Camera.CFrame = Camera.CFrame:Lerp(newCF, S.AimSpeed / 100)
	else
		Camera.CFrame = newCF
	end
end)
