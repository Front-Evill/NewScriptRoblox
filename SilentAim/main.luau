local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera         = workspace.CurrentCamera
local LocalPlayer    = Players.LocalPlayer

local Settings = {
	Enabled         = false,
	WallCheck       = true,
	TeamCheck       = false,
	PredictMovement = false,
	SmoothAim       = true,
	ShowCircle      = true,
	ShowCrosshair   = true,
	ShowTargetBox   = false,
	ESPEnabled      = false,
	TargetPart      = "Head",
	AimKey          = "MouseButton2",
	SortMethod      = "Distance2D",
	CircleRadius    = 120,
	AimSpeed        = 12,
	MaxDistance     = 500,
	PredictStrength = 5,
	CircleOpacity   = 2,
}

local TargetParts  = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm" }
local AimKeys      = { "MouseButton2", "E", "Q", "Z", "X", "C", "V", "G" }
local SortMethods  = { "Distance2D", "Distance3D", "LowestHP", "HighestHP" }

local gui = Instance.new("ScreenGui")
gui.Name           = "SilentAim"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer.PlayerGui

local Main = Instance.new("Frame")
Main.Size              = UDim2.new(0, 310, 0, 500)
Main.Position          = UDim2.new(0.5, -155, 0.5, -250)
Main.BackgroundColor3  = Color3.fromRGB(8, 8, 12)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = false
Main.Parent            = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", Main)
mStroke.Color       = Color3.fromRGB(150, 20, 20)
mStroke.Thickness   = 1.5
mStroke.Transparency = 0.3

local BG = Instance.new("ImageLabel", Main)
BG.Size                  = UDim2.new(1, 0, 1, 0)
BG.BackgroundTransparency = 1
BG.Image                 = "SlientAim/icons/background.png"
BG.ImageTransparency     = 0.6
BG.ScaleType             = Enum.ScaleType.Crop
BG.ZIndex                = 0
Instance.new("UICorner", BG).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame", Main)
TopBar.Size            = UDim2.new(1, 0, 0, 3)
TopBar.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.ZIndex          = 2
local tg = Instance.new("UIGradient", TopBar)
tg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 20, 20)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 70, 70)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 20, 20)),
})

local Header = Instance.new("Frame", Main)
Header.Size            = UDim2.new(1, 0, 0, 52)
Header.Position        = UDim2.new(0, 0, 0, 3)
Header.BackgroundColor3 = Color3.fromRGB(12, 10, 16)
Header.BorderSizePixel = 0
Header.ZIndex          = 2

local Icon = Instance.new("ImageLabel", Header)
Icon.Size                  = UDim2.new(0, 28, 0, 28)
Icon.Position              = UDim2.new(0, 12, 0.5, -14)
Icon.BackgroundTransparency = 1
Icon.Image                 = "SlientAim/icons/icon.png"
Icon.ZIndex                = 3

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size               = UDim2.new(0, 140, 0, 22)
TitleLbl.Position           = UDim2.new(0, 48, 0, 8)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "SILENT AIM"
TitleLbl.TextColor3         = Color3.fromRGB(235, 235, 235)
TitleLbl.TextSize           = 14
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
TitleLbl.ZIndex             = 3

local ByLbl = Instance.new("TextLabel", Header)
ByLbl.Size               = UDim2.new(0, 140, 0, 13)
ByLbl.Position           = UDim2.new(0, 48, 0, 32)
ByLbl.BackgroundTransparency = 1
ByLbl.Text               = "by FrontEvill"
ByLbl.TextColor3         = Color3.fromRGB(80, 25, 25)
ByLbl.TextSize           = 10
ByLbl.Font               = Enum.Font.Gotham
ByLbl.TextXAlignment     = Enum.TextXAlignment.Left
ByLbl.ZIndex             = 3

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size              = UDim2.new(0, 24, 0, 24)
CloseBtn.Position          = UDim2.new(1, -34, 0.5, -12)
CloseBtn.BackgroundColor3  = Color3.fromRGB(28, 12, 12)
CloseBtn.BorderSizePixel   = 0
CloseBtn.Text              = "x"
CloseBtn.TextColor3        = Color3.fromRGB(180, 45, 45)
CloseBtn.TextSize          = 12
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.ZIndex            = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
local cbStroke = Instance.new("UIStroke", CloseBtn)
cbStroke.Color     = Color3.fromRGB(80, 20, 20)
cbStroke.Thickness = 1

local TabFrame = Instance.new("Frame", Main)
TabFrame.Size            = UDim2.new(1, 0, 0, 34)
TabFrame.Position        = UDim2.new(0, 0, 0, 55)
TabFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex          = 2

local TabDiv = Instance.new("Frame", TabFrame)
TabDiv.Size             = UDim2.new(1, 0, 0, 1)
TabDiv.Position         = UDim2.new(0, 0, 1, -1)
TabDiv.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
TabDiv.BorderSizePixel  = 0
TabDiv.ZIndex           = 2

local pages    = {}
local tabBtns  = {}
local activeTab = nil

local function openTab(name)
	if activeTab then
		pages[activeTab].Visible = false
		local b = tabBtns[activeTab]
		b.BackgroundColor3 = Color3.fromRGB(14, 10, 18)
		b.TextColor3       = Color3.fromRGB(120, 45, 45)
	end
	activeTab = name
	pages[name].Visible = true
	local b = tabBtns[name]
	b.BackgroundColor3 = Color3.fromRGB(140, 18, 18)
	b.TextColor3       = Color3.fromRGB(255, 255, 255)
end

local tabNames = { "Toggles", "Lists", "Sliders" }
for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", TabFrame)
	btn.Size              = UDim2.new(0, 90, 0, 26)
	btn.Position          = UDim2.new(0, 8 + (i - 1) * 96, 0.5, -13)
	btn.BackgroundColor3  = Color3.fromRGB(14, 10, 18)
	btn.BorderSizePixel   = 0
	btn.Text              = name
	btn.TextColor3        = Color3.fromRGB(120, 45, 45)
	btn.TextSize          = 11
	btn.Font              = Enum.Font.GothamBold
	btn.ZIndex            = 3
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local bs = Instance.new("UIStroke", btn)
	bs.Color     = Color3.fromRGB(50, 15, 15)
	bs.Thickness = 1

	local sf = Instance.new("ScrollingFrame", Main)
	sf.Size                   = UDim2.new(1, 0, 1, -92)
	sf.Position               = UDim2.new(0, 0, 0, 92)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel        = 0
	sf.ScrollBarThickness     = 3
	sf.ScrollBarImageColor3   = Color3.fromRGB(160, 25, 25)
	sf.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	sf.CanvasSize             = UDim2.new(0, 0, 0, 0)
	sf.Visible                = false
	sf.ZIndex                 = 2
	sf.Parent                 = Main
	local l = Instance.new("UIListLayout", sf)
	l.Padding                = UDim.new(0, 8)
	l.HorizontalAlignment    = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", sf)
	p.PaddingTop    = UDim.new(0, 12)
	p.PaddingBottom = UDim.new(0, 16)
	p.PaddingLeft   = UDim.new(0, 16)
	p.PaddingRight  = UDim.new(0, 16)

	pages[name]   = sf
	tabBtns[name] = btn

	btn.MouseButton1Click:Connect(function()
		openTab(name)
	end)
end

openTab("Toggles")

local function SecLabel(page, txt)
	local f = Instance.new("Frame", page)
	f.Size              = UDim2.new(1, 0, 0, 22)
	f.BackgroundColor3  = Color3.fromRGB(18, 8, 8)
	f.BorderSizePixel   = 0
	f.ZIndex            = 3
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
	local l = Instance.new("TextLabel", f)
	l.Size               = UDim2.new(1, -12, 1, 0)
	l.Position           = UDim2.new(0, 10, 0, 0)
	l.BackgroundTransparency = 1
	l.Text               = txt
	l.TextColor3         = Color3.fromRGB(180, 40, 40)
	l.TextSize           = 10
	l.Font               = Enum.Font.GothamBold
	l.TextXAlignment     = Enum.TextXAlignment.Left
	l.ZIndex             = 3
end

local function Toggle(page, label, default, cb)
	local row = Instance.new("Frame", page)
	row.Size             = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = Color3.fromRGB(14, 12, 20)
	row.BorderSizePixel  = 0
	row.ZIndex           = 3
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(30, 14, 14) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(1, -60, 1, 0)
	lbl.Position           = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(205, 205, 205)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 3

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(0, 40, 0, 20)
	track.Position         = UDim2.new(1, -50, 0.5, -10)
	track.BackgroundColor3 = default and Color3.fromRGB(160, 22, 22) or Color3.fromRGB(30, 16, 16)
	track.BorderSizePixel  = 0
	track.ZIndex           = 3
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", track)
	knob.Size             = UDim2.new(0, 14, 0, 14)
	knob.Position         = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel  = 0
	knob.ZIndex           = 4
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = default
	local btn = Instance.new("TextButton", row)
	btn.Size               = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text               = ""
	btn.ZIndex             = 5
	btn.MouseButton1Click:Connect(function()
		state = not state
		track.BackgroundColor3 = state and Color3.fromRGB(160, 22, 22) or Color3.fromRGB(30, 16, 16)
		knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		if cb then cb(state) end
	end)
end

local function Dropdown(page, label, options, default, cb)
	local wrap = Instance.new("Frame", page)
	wrap.Size               = UDim2.new(1, 0, 0, 40)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex             = 3
	wrap.ClipsDescendants   = false

	local row = Instance.new("Frame", wrap)
	row.Size             = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = Color3.fromRGB(14, 12, 20)
	row.BorderSizePixel  = 0
	row.ZIndex           = 5
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(30, 14, 14) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(0, 110, 1, 0)
	lbl.Position           = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(205, 205, 205)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 5

	local sel = Instance.new("TextButton", row)
	sel.Size             = UDim2.new(0, 120, 0, 26)
	sel.Position         = UDim2.new(1, -130, 0.5, -13)
	sel.BackgroundColor3 = Color3.fromRGB(22, 10, 10)
	sel.BorderSizePixel  = 0
	sel.Text             = default .. " v"
	sel.TextColor3       = Color3.fromRGB(195, 45, 45)
	sel.TextSize         = 11
	sel.Font             = Enum.Font.GothamBold
	sel.ZIndex           = 6
	Instance.new("UICorner", sel).CornerRadius = UDim.new(0, 6)
	local ss = Instance.new("UIStroke", sel)
	ss.Color = Color3.fromRGB(80, 22, 22) ss.Thickness = 1

	local drop = Instance.new("Frame", row)
	drop.Size             = UDim2.new(0, 120, 0, #options * 28)
	drop.Position         = UDim2.new(1, -130, 1, 3)
	drop.BackgroundColor3 = Color3.fromRGB(12, 8, 8)
	drop.BorderSizePixel  = 0
	drop.ZIndex           = 20
	drop.Visible          = false
	Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 6)
	local ds = Instance.new("UIStroke", drop)
	ds.Color = Color3.fromRGB(80, 22, 22) ds.Thickness = 1
	Instance.new("UIListLayout", drop).Padding = UDim.new(0, 0)

	for _, opt in ipairs(options) do
		local item = Instance.new("TextButton", drop)
		item.Size             = UDim2.new(1, 0, 0, 28)
		item.BackgroundColor3 = Color3.fromRGB(12, 8, 8)
		item.BorderSizePixel  = 0
		item.Text             = opt
		item.TextColor3       = Color3.fromRGB(190, 190, 190)
		item.TextSize         = 11
		item.Font             = Enum.Font.Gotham
		item.ZIndex           = 21
		item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(32, 12, 12) end)
		item.MouseLeave:Connect(function() item.BackgroundColor3 = Color3.fromRGB(12, 8, 8) end)
		item.MouseButton1Click:Connect(function()
			sel.Text = opt .. " v"
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
	row.Size             = UDim2.new(1, 0, 0, 54)
	row.BackgroundColor3 = Color3.fromRGB(14, 12, 20)
	row.BorderSizePixel  = 0
	row.ZIndex           = 3
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local rs = Instance.new("UIStroke", row)
	rs.Color = Color3.fromRGB(30, 14, 14) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(0.62, 0, 0, 20)
	lbl.Position           = UDim2.new(0, 12, 0, 8)
	lbl.BackgroundTransparency = 1
	lbl.Text               = label
	lbl.TextColor3         = Color3.fromRGB(205, 205, 205)
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.Gotham
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 3

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size               = UDim2.new(0.36, 0, 0, 20)
	valLbl.Position           = UDim2.new(0.62, 0, 0, 8)
	valLbl.BackgroundTransparency = 1
	valLbl.Text               = tostring(default) .. (suffix or "")
	valLbl.TextColor3         = Color3.fromRGB(200, 45, 45)
	valLbl.TextSize           = 12
	valLbl.Font               = Enum.Font.GothamBold
	valLbl.TextXAlignment     = Enum.TextXAlignment.Right
	valLbl.ZIndex             = 3

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(1, -24, 0, 5)
	track.Position         = UDim2.new(0, 12, 0, 36)
	track.BackgroundColor3 = Color3.fromRGB(28, 14, 14)
	track.BorderSizePixel  = 0
	track.ZIndex           = 3
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
	fill.BorderSizePixel  = 0
	fill.ZIndex           = 3
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local fg = Instance.new("UIGradient", fill)
	fg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 22, 22)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 60, 60)),
	})

	local knob = Instance.new("Frame", track)
	knob.Size         = UDim2.new(0, 13, 0, 13)
	knob.AnchorPoint  = Vector2.new(0.5, 0.5)
	knob.Position     = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel  = 0
	knob.ZIndex       = 4
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local hit = Instance.new("TextButton", track)
	hit.Size               = UDim2.new(1, 0, 0, 22)
	hit.Position           = UDim2.new(0, 0, 0.5, -11)
	hit.BackgroundTransparency = 1
	hit.Text               = ""
	hit.ZIndex             = 5

	local dragging = false
	local function update(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local val = math.floor(min + rel * (max - min))
		valLbl.Text   = tostring(val) .. (suffix or "")
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if cb then cb(val) end
	end

	hit.MouseButton1Down:Connect(function()
		dragging = true
		update(UserInputService:GetMouseLocation().X)
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			update(i.Position.X)
		end
	end)
end

-- TOGGLES
SecLabel(pages["Toggles"], "AIM")
Toggle(pages["Toggles"], "Aimbot",             false, function(v) Settings.Enabled         = v end)
Toggle(pages["Toggles"], "Smooth Aim",          true,  function(v) Settings.SmoothAim        = v end)
Toggle(pages["Toggles"], "Predict Movement",    false, function(v) Settings.PredictMovement  = v end)
SecLabel(pages["Toggles"], "FILTERS")
Toggle(pages["Toggles"], "Wall Check",          true,  function(v) Settings.WallCheck        = v end)
Toggle(pages["Toggles"], "Team Check",          false, function(v) Settings.TeamCheck        = v end)
SecLabel(pages["Toggles"], "VISUAL")
Toggle(pages["Toggles"], "Show FOV Circle",     true,  function(v) Settings.ShowCircle       = v end)
Toggle(pages["Toggles"], "Show Crosshair",      true,  function(v) Settings.ShowCrosshair    = v end)
Toggle(pages["Toggles"], "Target Box",          false, function(v) Settings.ShowTargetBox    = v end)
Toggle(pages["Toggles"], "ESP Names",           false, function(v) Settings.ESPEnabled       = v end)

-- LISTS
SecLabel(pages["Lists"], "TARGET")
Dropdown(pages["Lists"], "Target Part", TargetParts, Settings.TargetPart, function(v) Settings.TargetPart = v end)
Dropdown(pages["Lists"], "Sort By",     SortMethods, Settings.SortMethod, function(v) Settings.SortMethod = v end)
SecLabel(pages["Lists"], "CONTROLS")
Dropdown(pages["Lists"], "Aim Key",     AimKeys,     Settings.AimKey,     function(v) Settings.AimKey     = v end)

-- SLIDERS
SecLabel(pages["Sliders"], "AIM")
Slider(pages["Sliders"], "FOV Radius",       40,  600,  Settings.CircleRadius,    "px", function(v) Settings.CircleRadius    = v end)
Slider(pages["Sliders"], "Aim Speed",        1,   50,   Settings.AimSpeed,        "",   function(v) Settings.AimSpeed        = v end)
Slider(pages["Sliders"], "Max Distance",     50,  1500, Settings.MaxDistance,     "st", function(v) Settings.MaxDistance     = v end)
Slider(pages["Sliders"], "Predict Strength", 1,   20,   Settings.PredictStrength, "",   function(v) Settings.PredictStrength = v end)
SecLabel(pages["Sliders"], "VISUAL")
Slider(pages["Sliders"], "Circle Opacity",   0,   10,   Settings.CircleOpacity,   "",   function(v)
	Settings.CircleOpacity = v
	for _, p in ipairs(circlePoints or {}) do p.BackgroundTransparency = v / 10 end
end)

-- FOV CIRCLE
local circleGui = Instance.new("ScreenGui")
circleGui.Name           = "SilentAim_Overlay"
circleGui.ResetOnSpawn   = false
circleGui.IgnoreGuiInset = true
circleGui.Parent         = LocalPlayer.PlayerGui

local circleFrame = Instance.new("Frame", circleGui)
circleFrame.Size                  = UDim2.new(1, 0, 1, 0)
circleFrame.BackgroundTransparency = 1

local SEGS = 64
local circlePoints = {}
for i = 1, SEGS do
	local p = Instance.new("Frame", circleFrame)
	p.Size             = UDim2.new(0, 3, 0, 3)
	p.AnchorPoint      = Vector2.new(0.5, 0.5)
	p.BackgroundColor3 = Color3.fromRGB(210, 35, 35)
	p.BorderSizePixel  = 0
	p.BackgroundTransparency = 0.2
	Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
	circlePoints[i] = p
end

local centerDot = Instance.new("Frame", circleFrame)
centerDot.Size             = UDim2.new(0, 5, 0, 5)
centerDot.AnchorPoint      = Vector2.new(0.5, 0.5)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
centerDot.BorderSizePixel  = 0
Instance.new("UICorner", centerDot).CornerRadius = UDim.new(1, 0)

local crossH = Instance.new("Frame", circleFrame)
crossH.Size             = UDim2.new(0, 12, 0, 1)
crossH.AnchorPoint      = Vector2.new(0.5, 0.5)
crossH.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
crossH.BorderSizePixel  = 0
crossH.BackgroundTransparency = 0.35

local crossV = Instance.new("Frame", circleFrame)
crossV.Size             = UDim2.new(0, 1, 0, 12)
crossV.AnchorPoint      = Vector2.new(0.5, 0.5)
crossV.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
crossV.BorderSizePixel  = 0
crossV.BackgroundTransparency = 0.35

local targetBox = Instance.new("SelectionBox", circleGui)
targetBox.Color3               = Color3.fromRGB(210, 35, 35)
targetBox.LineThickness        = 0.04
targetBox.SurfaceTransparency  = 0.85
targetBox.SurfaceColor3        = Color3.fromRGB(210, 35, 35)

-- ESP
local espFolder = Instance.new("Folder", circleGui)
espFolder.Name = "ESP"

local espLabels = {}

local function getOrMakeESP(player)
	if espLabels[player] then return espLabels[player] end
	local char = player.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local bb = Instance.new("BillboardGui")
	bb.Name              = "ESP_" .. player.Name
	bb.Size              = UDim2.new(0, 80, 0, 20)
	bb.StudsOffset       = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop       = true
	bb.LightInfluence    = 0
	bb.Adornee           = hrp
	bb.Parent            = espFolder

	local nameTag = Instance.new("TextLabel", bb)
	nameTag.Size               = UDim2.new(1, 0, 1, 0)
	nameTag.BackgroundTransparency = 1
	nameTag.Text               = player.Name
	nameTag.TextColor3         = Color3.fromRGB(255, 255, 255)
	nameTag.TextSize           = 11
	nameTag.Font               = Enum.Font.GothamBold
	nameTag.TextStrokeTransparency = 0.4
	nameTag.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)

	espLabels[player] = bb
	return bb
end

local function clearESP(player)
	if espLabels[player] then
		espLabels[player]:Destroy()
		espLabels[player] = nil
	end
end

Players.PlayerRemoving:Connect(clearESP)

-- DRAG
local dragging = false
local dragOffset = Vector2.new()

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging   = true
		local mp   = UserInputService:GetMouseLocation()
		local mpos = Main.AbsolutePosition
		dragOffset = Vector2.new(mp.X - mpos.X, mp.Y - mpos.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mp = UserInputService:GetMouseLocation()
		Main.Position = UDim2.new(0, mp.X - dragOffset.X, 0, mp.Y - dragOffset.Y)
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		Main.Visible = not Main.Visible
	end
end)

-- AIMBOT
local function isAimKeyHeld()
	if Settings.AimKey == "MouseButton2" then
		return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end
	local ok, key = pcall(function() return Enum.KeyCode[Settings.AimKey] end)
	if ok then return UserInputService:IsKeyDown(key) end
	return false
end

local function canSee(part)
	if not Settings.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local dir    = part.Position - origin
	local rp     = RaycastParams.new()
	rp.FilterDescendantsInstances = { LocalPlayer.Character, part.Parent }
	rp.FilterType                 = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(origin, dir, rp) == nil
end

local function getScore(player, part, d2)
	local char = player.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if Settings.SortMethod == "Distance3D"  then return (part.Position - Camera.CFrame.Position).Magnitude end
	if Settings.SortMethod == "LowestHP"    then return hum and hum.Health or math.huge end
	if Settings.SortMethod == "HighestHP"   then return hum and -hum.Health or math.huge end
	return d2
end

local function getBestTarget()
	local center    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local best      = nil
	local bestScore = math.huge

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl == LocalPlayer then continue end
		if Settings.TeamCheck and pl.Team == LocalPlayer.Team then continue end
		local char = pl.Character if not char then continue end
		local part = char:FindFirstChild(Settings.TargetPart) if not part then continue end
		local hum  = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		if (part.Position - Camera.CFrame.Position).Magnitude > Settings.MaxDistance then continue end
		if not canSee(part) then continue end
		local sp, vis = Camera:WorldToViewportPoint(part.Position)
		if not vis then continue end
		local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if d2 > Settings.CircleRadius then continue end
		local score = getScore(pl, part, d2)
		if score < bestScore then
			bestScore = score
			best = { part = part, char = char }
		end
	end
	return best
end

local function predicted(part)
	if not Settings.PredictMovement then return part.Position end
	local vel = part.AssemblyLinearVelocity
	local ping = LocalPlayer:GetNetworkPing()
	return part.Position + vel * ping * (Settings.PredictStrength / 10)
end

RunService.RenderStepped:Connect(function()
	local cx = Camera.ViewportSize.X / 2
	local cy = Camera.ViewportSize.Y / 2

	for i, p in ipairs(circlePoints) do
		if Settings.ShowCircle then
			local a = (i / SEGS) * (2 * math.pi)
			p.Position = UDim2.new(0, cx + math.cos(a) * Settings.CircleRadius, 0, cy + math.sin(a) * Settings.CircleRadius)
			p.Visible  = true
		else
			p.Visible = false
		end
	end

	centerDot.Position = UDim2.new(0, cx, 0, cy)
	crossH.Position    = UDim2.new(0, cx, 0, cy)
	crossV.Position    = UDim2.new(0, cx, 0, cy)
	centerDot.Visible  = Settings.ShowCrosshair
	crossH.Visible     = Settings.ShowCrosshair
	crossV.Visible     = Settings.ShowCrosshair

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl == LocalPlayer then continue end
		if Settings.ESPEnabled then
			local bb = getOrMakeESP(pl)
			if bb then
				local char = pl.Character
				local hrp  = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then bb.Adornee = hrp bb.Enabled = true end
			end
		else
			if espLabels[pl] then
				espLabels[pl].Enabled = false
			end
		end
	end

	if not Settings.Enabled or not isAimKeyHeld() then
		targetBox.Adornee = nil
		return
	end

	local result = getBestTarget()
	if not result then
		targetBox.Adornee = nil
		return
	end

	targetBox.Adornee = Settings.ShowTargetBox and result.char or nil

	local aimPos = predicted(result.part)
	local _, vis = Camera:WorldToViewportPoint(aimPos)
	if not vis then return end

	local newCF = CFrame.new(Camera.CFrame.Position, aimPos)
	if Settings.SmoothAim then
		Camera.CFrame = Camera.CFrame:Lerp(newCF, Settings.AimSpeed / 100)
	else
		Camera.CFrame = newCF
	end
end)
