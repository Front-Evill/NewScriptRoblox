local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

local S = {
	Enabled    = false,
	ESP        = false,
	WallCheck  = false,
	TeamCheck  = false,
	SmoothAim  = true,
	Predict    = false,
	ShowFOV    = true,
	RequireKey = false,
	TargetPart = "Head",
	AimKey     = "MouseButton2",
	Sort       = "Distance2D",
	FOV        = 150,
	Speed      = 15,
	MaxDist    = 900,
	PredStr    = 5,
}

local TARGET_PARTS = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso" }
local AIM_KEYS     = { "Always", "MouseButton2", "E", "Q", "Z", "X", "C" }
local SORT_MODES   = { "Distance2D", "Distance3D", "LowestHP", "HighestHP" }
local TAB_NAMES    = { "Toggles", "Lists", "Sliders" }

local RED_DARK  = Color3.fromRGB(18,  8,  8)
local RED_MID   = Color3.fromRGB(120, 12, 12)
local RED_FULL  = Color3.fromRGB(200, 28, 28)
local BG_DEEP   = Color3.fromRGB(6,   6,  10)
local BG_MID    = Color3.fromRGB(10,  8,  16)
local BG_ELEM   = Color3.fromRGB(14,  11, 22)
local COL_TEXT  = Color3.fromRGB(188, 188, 192)
local COL_WHITE = Color3.fromRGB(255, 255, 255)

local TI_FAST  = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_SLIDE = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function tw(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local espMap = {}

local function applyHL(char, pl)
	if espMap[pl] then pcall(function() espMap[pl]:Destroy() end) end
	local hl               = Instance.new("Highlight")
	hl.Adornee             = char
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillColor           = COL_WHITE
	hl.FillTransparency    = 0.44
	hl.OutlineColor        = COL_WHITE
	hl.OutlineTransparency = 0
	hl.Enabled             = S.ESP
	hl.Parent              = char
	espMap[pl]             = hl
end

local function watchPlayer(pl)
	if pl == LP then return end
	if pl.Character then applyHL(pl.Character, pl) end
	pl.CharacterAdded:Connect(function(char)
		task.wait()
		applyHL(char, pl)
	end)
end

for _, pl in ipairs(Players:GetPlayers()) do watchPlayer(pl) end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(pl)
	if espMap[pl] then
		pcall(function() espMap[pl]:Destroy() end)
		espMap[pl] = nil
	end
end)

local function setESP(v)
	S.ESP = v
	for _, hl in pairs(espMap) do pcall(function() hl.Enabled = v end) end
end

local gui = Instance.new("ScreenGui")
gui.Name           = "SilentAim"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LP.PlayerGui

local Main = Instance.new("Frame", gui)
Main.Size             = UDim2.new(0, 308, 0, 490)
Main.Position         = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = BG_DEEP
Main.BorderSizePixel  = 0
Main.ClipsDescendants = false
local mc = Instance.new("UICorner", Main) mc.CornerRadius = UDim.new(0, 14)
local ms = Instance.new("UIStroke",  Main)
ms.Color = RED_MID ms.Thickness = 1.5 ms.Transparency = 0.15

local bgImg = Instance.new("ImageLabel", Main)
bgImg.Size                   = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image                  = "rbxassetid://111823734811187"
bgImg.ImageTransparency      = 0.48
bgImg.ScaleType              = Enum.ScaleType.Crop
bgImg.ZIndex                 = 0
local bic = Instance.new("UICorner", bgImg) bic.CornerRadius = UDim.new(0, 14)

local dimLayer = Instance.new("Frame", Main)
dimLayer.Size                   = UDim2.new(1, 0, 1, 0)
dimLayer.BackgroundColor3       = BG_DEEP
dimLayer.BackgroundTransparency = 0.52
dimLayer.BorderSizePixel        = 0
dimLayer.ZIndex                 = 1
local dlc = Instance.new("UICorner", dimLayer) dlc.CornerRadius = UDim.new(0, 14)

local topBar = Instance.new("Frame", Main)
topBar.Size             = UDim2.new(1, 0, 0, 3)
topBar.BackgroundColor3 = RED_FULL
topBar.BorderSizePixel  = 0
topBar.ZIndex           = 8
local tg = Instance.new("UIGradient", topBar)
tg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(65, 6, 6)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(248, 50, 50)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(248, 50, 50)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(65, 6, 6)),
})

local Hdr = Instance.new("Frame", Main)
Hdr.Size                   = UDim2.new(1, 0, 0, 58)
Hdr.Position               = UDim2.new(0, 0, 0, 3)
Hdr.BackgroundColor3       = BG_MID
Hdr.BackgroundTransparency = 0.38
Hdr.BorderSizePixel        = 0
Hdr.ZIndex                 = 7

local hdrLine = Instance.new("Frame", Hdr)
hdrLine.Size             = UDim2.new(1, 0, 0, 1)
hdrLine.Position         = UDim2.new(0, 0, 1, -1)
hdrLine.BackgroundColor3 = RED_MID
hdrLine.BackgroundTransparency = 0.4
hdrLine.BorderSizePixel  = 0
hdrLine.ZIndex           = 7

local icoImg = Instance.new("ImageLabel", Hdr)
icoImg.Size                   = UDim2.new(0, 32, 0, 32)
icoImg.Position               = UDim2.new(0, 14, 0.5, -16)
icoImg.BackgroundTransparency = 1
icoImg.Image                  = "rbxassetid://99530762681306"
icoImg.ZIndex                 = 8

local titleLbl = Instance.new("TextLabel", Hdr)
titleLbl.Size               = UDim2.new(0, 180, 0, 28)
titleLbl.Position           = UDim2.new(0, 54, 0.5, -14)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "SILENT AIM"
titleLbl.TextColor3         = Color3.fromRGB(244, 244, 248)
titleLbl.TextSize           = 15
titleLbl.Font               = Enum.Font.GothamBlack
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 8

local closeBtn = Instance.new("TextButton", Hdr)
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
closeBtn.BackgroundTransparency = 0.3
closeBtn.BorderSizePixel  = 0
closeBtn.Text             = "×"
closeBtn.TextColor3       = Color3.fromRGB(160, 30, 30)
closeBtn.TextSize         = 17
closeBtn.Font             = Enum.Font.GothamBlack
closeBtn.ZIndex           = 10
local cbc = Instance.new("UICorner", closeBtn) cbc.CornerRadius = UDim.new(0, 8)
local cbs = Instance.new("UIStroke",  closeBtn) cbs.Color = Color3.fromRGB(55, 10, 10) cbs.Thickness = 1

closeBtn.MouseEnter:Connect(function() tw(closeBtn, TI_FAST, {BackgroundTransparency = 0.1}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, TI_FAST, {BackgroundTransparency = 0.3}) end)

local TabBar = Instance.new("Frame", Main)
TabBar.Size                   = UDim2.new(1, 0, 0, 35)
TabBar.Position               = UDim2.new(0, 0, 0, 61)
TabBar.BackgroundColor3       = BG_MID
TabBar.BackgroundTransparency = 0.5
TabBar.BorderSizePixel        = 0
TabBar.ZIndex                 = 7

local tabLine = Instance.new("Frame", TabBar)
tabLine.Size             = UDim2.new(1, 0, 0, 1)
tabLine.Position         = UDim2.new(0, 0, 1, -1)
tabLine.BackgroundColor3 = RED_MID
tabLine.BackgroundTransparency = 0.38
tabLine.BorderSizePixel  = 0
tabLine.ZIndex           = 7

local tabIndicator = Instance.new("Frame", TabBar)
tabIndicator.Size             = UDim2.new(0, 84, 0, 2)
tabIndicator.Position         = UDim2.new(0, 6, 1, -2)
tabIndicator.BackgroundColor3 = RED_FULL
tabIndicator.BorderSizePixel  = 0
tabIndicator.ZIndex           = 9
local tic = Instance.new("UICorner", tabIndicator) tic.CornerRadius = UDim.new(0, 3)

local pageClip = Instance.new("Frame", Main)
pageClip.Size             = UDim2.new(1, 0, 1, -99)
pageClip.Position         = UDim2.new(0, 0, 0, 99)
pageClip.BackgroundTransparency = 1
pageClip.BorderSizePixel  = 0
pageClip.ClipsDescendants = true
pageClip.ZIndex           = 5

local pages   = {}
local tBtns   = {}
local curTab  = nil
local tabLock = false

local function getIdx(name)
	for i, n in ipairs(TAB_NAMES) do if n == name then return i end end
	return 1
end

local function switchTab(name)
	if tabLock or name == curTab then return end
	tabLock = true

	local nIdx = getIdx(name)
	local pIdx = curTab and getIdx(curTab) or nIdx
	local dir  = (nIdx > pIdx) and 1 or -1
	local W    = pageClip.AbsoluteSize.X

	tw(tabIndicator, TI_MED, { Position = UDim2.new(0, 6 + (nIdx-1)*90, 1, -2) })

	if curTab then
		tw(tBtns[curTab], TI_FAST, {
			BackgroundColor3 = Color3.fromRGB(9, 5, 17),
			TextColor3       = Color3.fromRGB(65, 18, 18),
		})
		local prev = pages[curTab]
		tw(prev, TI_SLIDE, { Position = UDim2.new(0, -dir * W, 0, 0) })
		task.delay(0.22, function()
			if prev and prev.Parent then prev.Visible = false end
		end)
	end

	tw(tBtns[name], TI_FAST, {
		BackgroundColor3 = Color3.fromRGB(110, 10, 10),
		TextColor3       = COL_WHITE,
	})

	local next = pages[name]
	next.Position = UDim2.new(0, dir * W, 0, 0)
	next.Visible  = true
	tw(next, TI_SLIDE, { Position = UDim2.new(0, 0, 0, 0) })

	curTab = name
	task.delay(0.25, function() tabLock = false end)
end

for i, name in ipairs(TAB_NAMES) do
	local btn = Instance.new("TextButton", TabBar)
	btn.Size                   = UDim2.new(0, 84, 0, 26)
	btn.Position               = UDim2.new(0, 6 + (i-1)*90, 0.5, -13)
	btn.BackgroundColor3       = Color3.fromRGB(9, 5, 17)
	btn.BackgroundTransparency = 0.0
	btn.BorderSizePixel        = 0
	btn.Text                   = name
	btn.TextColor3             = Color3.fromRGB(65, 18, 18)
	btn.TextSize               = 11
	btn.Font                   = Enum.Font.GothamBold
	btn.ZIndex                 = 8
	local bc = Instance.new("UICorner", btn) bc.CornerRadius = UDim.new(0, 6)

	local sf = Instance.new("ScrollingFrame", pageClip)
	sf.Size                   = UDim2.new(1, 0, 1, 0)
	sf.Position               = UDim2.new(0, 0, 0, 0)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel        = 0
	sf.ScrollBarThickness     = 2
	sf.ScrollBarImageColor3   = Color3.fromRGB(100, 10, 10)
	sf.ScrollBarImageTransparency = 0.3
	sf.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	sf.CanvasSize             = UDim2.new(0, 0, 0, 0)
	sf.Visible                = false
	sf.ZIndex                 = 5

	local ll = Instance.new("UIListLayout", sf)
	ll.Padding             = UDim.new(0, 7)
	ll.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local lp = Instance.new("UIPadding", sf)
	lp.PaddingTop    = UDim.new(0, 12)
	lp.PaddingBottom = UDim.new(0, 18)
	lp.PaddingLeft   = UDim.new(0, 11)
	lp.PaddingRight  = UDim.new(0, 11)

	pages[name] = sf
	tBtns[name] = btn
	btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Toggles")

local function Section(pg, title)
	local f = Instance.new("Frame", pg)
	f.Size                   = UDim2.new(1, 0, 0, 22)
	f.BackgroundColor3       = Color3.fromRGB(12, 5, 5)
	f.BackgroundTransparency = 0.48
	f.BorderSizePixel        = 0
	f.ZIndex                 = 6
	local fc = Instance.new("UICorner", f) fc.CornerRadius = UDim.new(0, 6)

	local bar = Instance.new("Frame", f)
	bar.Size             = UDim2.new(0, 3, 0.62, 0)
	bar.Position         = UDim2.new(0, 0, 0.19, 0)
	bar.BackgroundColor3 = RED_FULL
	bar.BorderSizePixel  = 0
	bar.ZIndex           = 7
	local bc = Instance.new("UICorner", bar) bc.CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel", f)
	lbl.Size               = UDim2.new(1, -14, 1, 0)
	lbl.Position           = UDim2.new(0, 11, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = title
	lbl.TextColor3         = Color3.fromRGB(155, 26, 26)
	lbl.TextSize           = 10
	lbl.Font               = Enum.Font.GothamBlack
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 7
end

local function Toggle(pg, labelTxt, default, cb)
	local row = Instance.new("Frame", pg)
	row.Size                   = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3       = BG_ELEM
	row.BackgroundTransparency = 0.52
	row.BorderSizePixel        = 0
	row.ZIndex                 = 6
	local rc = Instance.new("UICorner", row) rc.CornerRadius = UDim.new(0, 9)
	local rs = Instance.new("UIStroke",  row) rs.Color = Color3.fromRGB(22, 9, 9) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(1, -56, 1, 0)
	lbl.Position           = UDim2.new(0, 13, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = labelTxt
	lbl.TextColor3         = COL_TEXT
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.GothamSemibold
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 6

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(0, 40, 0, 20)
	track.Position         = UDim2.new(1, -49, 0.5, -10)
	track.BackgroundColor3 = default and RED_MID or RED_DARK
	track.BorderSizePixel  = 0
	track.ZIndex           = 7
	local tc = Instance.new("UICorner", track) tc.CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", track)
	knob.Size             = UDim2.new(0, 14, 0, 14)
	knob.Position         = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = COL_WHITE
	knob.BorderSizePixel  = 0
	knob.ZIndex           = 8
	local kc = Instance.new("UICorner", knob) kc.CornerRadius = UDim.new(1, 0)

	local state = default
	local hit   = Instance.new("TextButton", row)
	hit.Size               = UDim2.new(1, 0, 1, 0)
	hit.BackgroundTransparency = 1
	hit.Text               = ""
	hit.ZIndex             = 9

	hit.MouseButton1Click:Connect(function()
		state = not state
		tw(track, TI_FAST, { BackgroundColor3 = state and RED_MID or RED_DARK })
		tw(knob,  TI_FAST, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
		if cb then cb(state) end
	end)
end

local openDropdown = nil

local function Dropdown(pg, labelTxt, opts, default, cb)
	local wrap = Instance.new("Frame", pg)
	wrap.Size               = UDim2.new(1, 0, 0, 40)
	wrap.BackgroundTransparency = 1
	wrap.BorderSizePixel    = 0
	wrap.ClipsDescendants   = false
	wrap.ZIndex             = 9

	local row = Instance.new("Frame", wrap)
	row.Size                   = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3       = BG_ELEM
	row.BackgroundTransparency = 0.52
	row.BorderSizePixel        = 0
	row.ZIndex                 = 9
	local rc = Instance.new("UICorner", row) rc.CornerRadius = UDim.new(0, 9)
	local rs = Instance.new("UIStroke",  row) rs.Color = Color3.fromRGB(22, 9, 9) rs.Thickness = 1

	local lbl = Instance.new("TextLabel", row)
	lbl.Size               = UDim2.new(0, 95, 1, 0)
	lbl.Position           = UDim2.new(0, 13, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = labelTxt
	lbl.TextColor3         = COL_TEXT
	lbl.TextSize           = 12
	lbl.Font               = Enum.Font.GothamSemibold
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.ZIndex             = 9

	local selBtn = Instance.new("TextButton", row)
	selBtn.Size                   = UDim2.new(0, 112, 0, 28)
	selBtn.Position               = UDim2.new(1, -120, 0.5, -14)
	selBtn.BackgroundColor3       = Color3.fromRGB(10, 4, 4)
	selBtn.BackgroundTransparency = 0.42
	selBtn.BorderSizePixel        = 0
	selBtn.Text                   = default .. "  ▾"
	selBtn.TextColor3             = Color3.fromRGB(165, 28, 28)
	selBtn.TextSize               = 11
	selBtn.Font                   = Enum.Font.GothamBold
	selBtn.ZIndex                 = 10
	local sc = Instance.new("UICorner", selBtn) sc.CornerRadius = UDim.new(0, 7)
	local ss = Instance.new("UIStroke",  selBtn) ss.Color = Color3.fromRGB(55, 10, 10) ss.Thickness = 1

	local dropFrame = Instance.new("Frame", gui)
	dropFrame.Size                   = UDim2.new(0, 112, 0, #opts * 28)
	dropFrame.BackgroundColor3       = Color3.fromRGB(8, 4, 4)
	dropFrame.BackgroundTransparency = 0.3
	dropFrame.BorderSizePixel        = 0
	dropFrame.ZIndex                 = 80
	dropFrame.Visible                = false
	local dfc = Instance.new("UICorner", dropFrame) dfc.CornerRadius = UDim.new(0, 8)
	local dfs = Instance.new("UIStroke",  dropFrame) dfs.Color = Color3.fromRGB(55, 10, 10) dfs.Thickness = 1
	local dfl = Instance.new("UIListLayout", dropFrame) dfl.Padding = UDim.new(0, 0)

	for _, opt in ipairs(opts) do
		local item = Instance.new("TextButton", dropFrame)
		item.Size                   = UDim2.new(1, 0, 0, 28)
		item.BackgroundColor3       = Color3.fromRGB(8, 4, 4)
		item.BackgroundTransparency = 0.0
		item.BorderSizePixel        = 0
		item.Text                   = opt
		item.TextColor3             = Color3.fromRGB(178, 178, 182)
		item.TextSize               = 11
		item.Font                   = Enum.Font.GothamSemibold
		item.ZIndex                 = 81
		item.MouseEnter:Connect(function()
			tw(item, TI_FAST, { BackgroundColor3 = Color3.fromRGB(24, 8, 8) })
		end)
		item.MouseLeave:Connect(function()
			tw(item, TI_FAST, { BackgroundColor3 = Color3.fromRGB(8, 4, 4) })
		end)
		item.MouseButton1Click:Connect(function()
			selBtn.Text       = opt .. "  ▾"
			dropFrame.Visible = false
			openDropdown      = nil
			if cb then cb(opt) end
		end)
	end

	selBtn.MouseButton1Click:Connect(function()
		if openDropdown and openDropdown ~= dropFrame then
			openDropdown.Visible = false
		end
		if dropFrame.Visible then
			dropFrame.Visible = false
			openDropdown      = nil
			return
		end
		local ap          = selBtn.AbsolutePosition
		local as          = selBtn.AbsoluteSize
		dropFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4)
		dropFrame.Visible  = true
		openDropdown       = dropFrame
	end)
end

local function Slider(pg, labelTxt, minV, maxV, default, sfx, cb)
	local row = Instance.new("Frame", pg)
	row.Size                   = UDim2.new(1, 0, 0, 54)
	row.BackgroundColor3       = BG_ELEM
	row.BackgroundTransparency = 0.52
	row.BorderSizePixel        = 0
	row.ZIndex                 = 6
	local rc = Instance.new("UICorner", row) rc.CornerRadius = UDim.new(0, 9)
	local rs = Instance.new("UIStroke",  row) rs.Color = Color3.fromRGB(22, 9, 9) rs.Thickness = 1

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size               = UDim2.new(0.54, 0, 0, 20)
	nameLbl.Position           = UDim2.new(0, 13, 0, 8)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text               = labelTxt
	nameLbl.TextColor3         = COL_TEXT
	nameLbl.TextSize           = 12
	nameLbl.Font               = Enum.Font.GothamSemibold
	nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
	nameLbl.ZIndex             = 6

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size               = UDim2.new(0.44, 0, 0, 20)
	valLbl.Position           = UDim2.new(0.54, 0, 0, 8)
	valLbl.BackgroundTransparency = 1
	valLbl.Text               = tostring(default) .. (sfx or "")
	valLbl.TextColor3         = Color3.fromRGB(165, 26, 26)
	valLbl.TextSize           = 12
	valLbl.Font               = Enum.Font.GothamBold
	valLbl.TextXAlignment     = Enum.TextXAlignment.Right
	valLbl.ZIndex             = 6

	local track = Instance.new("Frame", row)
	track.Size             = UDim2.new(1, -26, 0, 5)
	track.Position         = UDim2.new(0, 13, 0, 39)
	track.BackgroundColor3 = Color3.fromRGB(18, 9, 9)
	track.BorderSizePixel  = 0
	track.ZIndex           = 6
	local trc = Instance.new("UICorner", track) trc.CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Size             = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(145, 18, 18)
	fill.BorderSizePixel  = 0
	fill.ZIndex           = 7
	local flc = Instance.new("UICorner", fill) flc.CornerRadius = UDim.new(1, 0)
	local flg = Instance.new("UIGradient", fill)
	flg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 13, 13)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 46, 46)),
	})

	local knob = Instance.new("Frame", track)
	knob.Size         = UDim2.new(0, 16, 0, 16)
	knob.AnchorPoint  = Vector2.new(0.5, 0.5)
	knob.Position     = UDim2.new((default - minV) / (maxV - minV), 0, 0.5, 0)
	knob.BackgroundColor3 = COL_WHITE
	knob.BorderSizePixel  = 0
	knob.ZIndex       = 8
	local knc = Instance.new("UICorner", knob) knc.CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function update(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local val = math.floor(minV + rel * (maxV - minV))
		valLbl.Text   = tostring(val) .. (sfx or "")
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if cb then cb(val) end
	end

	local hit = Instance.new("TextButton", track)
	hit.Size               = UDim2.new(1, 8, 0, 26)
	hit.Position           = UDim2.new(0, -4, 0.5, -13)
	hit.BackgroundTransparency = 1
	hit.Text               = ""
	hit.ZIndex             = 9

	hit.MouseButton1Down:Connect(function()
		dragging = true
		update(UserInputService:GetMouseLocation().X)
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

local T = pages["Toggles"]
Section(T, "AIM")
Toggle(T, "Aimbot",           false, function(v) S.Enabled    = v end)
Toggle(T, "Smooth Aim",       true,  function(v) S.SmoothAim  = v end)
Toggle(T, "Require Key",      false, function(v) S.RequireKey = v end)
Toggle(T, "Predict Movement", false, function(v) S.Predict    = v end)
Section(T, "FILTERS")
Toggle(T, "Wall Check",       false, function(v) S.WallCheck  = v end)
Toggle(T, "Team Check",       false, function(v) S.TeamCheck  = v end)
Section(T, "VISUAL")
Toggle(T, "Show FOV",         true,  function(v) S.ShowFOV    = v end)
Toggle(T, "ESP Wall Skin",    false, function(v) setESP(v)       end)

local L = pages["Lists"]
Section(L, "TARGET")
Dropdown(L, "Target Part", TARGET_PARTS, "Head",         function(v) S.TargetPart = v end)
Dropdown(L, "Sort By",     SORT_MODES,   "Distance2D",   function(v) S.Sort       = v end)
Section(L, "CONTROLS")
Dropdown(L, "Aim Key",     AIM_KEYS,     "MouseButton2", function(v) S.AimKey     = v end)

local SL = pages["Sliders"]
Section(SL, "AIM")
Slider(SL, "FOV Radius",   40,   600,  150, "px", function(v) S.FOV     = v end)
Slider(SL, "Aim Speed",    1,    60,   15,  "",   function(v) S.Speed   = v end)
Slider(SL, "Max Distance", 50,   2000, 900, "st", function(v) S.MaxDist = v end)
Section(SL, "PREDICT")
Slider(SL, "Predict Str",  1,    20,   5,   "",   function(v) S.PredStr = v end)

local ovGui = Instance.new("ScreenGui")
ovGui.Name           = "SA_Overlay"
ovGui.ResetOnSpawn   = false
ovGui.IgnoreGuiInset = true
ovGui.Parent         = LP.PlayerGui

local ovFrame = Instance.new("Frame", ovGui)
ovFrame.Size                   = UDim2.new(1, 0, 1, 0)
ovFrame.BackgroundTransparency = 1
ovFrame.BorderSizePixel        = 0

local fovCircle = Instance.new("Frame", ovFrame)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel        = 0
fovCircle.AnchorPoint            = Vector2.new(0.5, 0.5)
fovCircle.Size                   = UDim2.new(0, 300, 0, 300)
fovCircle.Position               = UDim2.new(0.5, 0, 0.5, 0)
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Thickness   = 1.6
fovStroke.Transparency = 0
fovStroke.Color        = Color3.fromRGB(255, 60, 60)

local frontLabel = Instance.new("TextLabel", ovFrame)
frontLabel.BackgroundTransparency = 1
frontLabel.Size                   = UDim2.new(0, 120, 0, 18)
frontLabel.AnchorPoint            = Vector2.new(0.5, 1)
frontLabel.Position               = UDim2.new(0.5, 0, 0.5, -160)
frontLabel.Text                   = "FrontEvill"
frontLabel.Font                   = Enum.Font.GothamBlack
frontLabel.TextSize               = 12
frontLabel.TextColor3             = Color3.fromRGB(255, 60, 60)
frontLabel.TextStrokeTransparency = 0.4
frontLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
frontLabel.ZIndex                 = 4

local isDragging = false
local dragOff    = Vector2.new()

Hdr.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		local p   = i.Position
		dragOff   = Vector2.new(p.X - Main.AbsolutePosition.X, p.Y - Main.AbsolutePosition.Y)
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if not isDragging then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement
	or i.UserInputType == Enum.UserInputType.Touch then
		local p = i.Position
		Main.Position = UDim2.new(0, p.X - dragOff.X, 0, p.Y - dragOff.Y)
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.F then
		Main.Visible = not Main.Visible
	end
end)

local function isKeyActive()
	if not S.RequireKey or S.AimKey == "Always" then return true end
	if S.AimKey == "MouseButton2" then
		return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end
	local ok, kc = pcall(function() return Enum.KeyCode[S.AimKey] end)
	return ok and UserInputService:IsKeyDown(kc)
end

local function isVisible(part)
	if not S.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local rp     = RaycastParams.new()
	rp.FilterDescendantsInstances = { LP.Character, part.Parent }
	rp.FilterType                 = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(origin, part.Position - origin, rp) == nil
end

local function findPart(char)
	local p = char:FindFirstChild(S.TargetPart)
	if p then return p end
	for _, n in ipairs(TARGET_PARTS) do
		local f = char:FindFirstChild(n)
		if f then return f end
	end
end

local function getBest()
	local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
	local center = Vector2.new(cx, cy)
	local best, bestScore = nil, math.huge

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl == LP then continue end
		if S.TeamCheck and pl.Team == LP.Team then continue end
		local char = pl.Character
		if not char then continue end
		local part = findPart(char)
		if not part then continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		if not isVisible(part) then continue end
		local cd = (part.Position - Camera.CFrame.Position).Magnitude
		if cd > S.MaxDist then continue end
		local sp, vis = Camera:WorldToViewportPoint(part.Position)
		if not vis then continue end
		local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if d2 > S.FOV then continue end
		local score = d2
		if      S.Sort == "Distance3D" then score = cd
		elseif  S.Sort == "LowestHP"   then score = hum.Health
		elseif  S.Sort == "HighestHP"  then score = -hum.Health
		end
		if score < bestScore then bestScore = score best = part end
	end
	return best
end

local rgbT = 0

RunService.RenderStepped:Connect(function(dt)
	local cx = Camera.ViewportSize.X / 2
	local cy = Camera.ViewportSize.Y / 2
	local r  = S.FOV

	rgbT = (rgbT + dt * 0.55) % 1
	local rgb = Color3.fromHSV(rgbT, 1, 1)

	fovCircle.Visible  = S.ShowFOV
	fovCircle.Size     = UDim2.new(0, r * 2, 0, r * 2)
	fovCircle.Position = UDim2.new(0, cx, 0, cy)
	fovStroke.Color    = rgb

	frontLabel.Visible   = S.ShowFOV
	frontLabel.Position  = UDim2.new(0, cx, 0, cy - r - 8)
	frontLabel.TextColor3 = rgb

	if not S.Enabled or not isKeyActive() then return end

	local target = getBest()
	if not target then return end

	local aimPos = target.Position
	if S.Predict then
		local ok, vel = pcall(function() return target.AssemblyLinearVelocity end)
		if ok then
			aimPos = target.Position + vel * LP:GetNetworkPing() * (S.PredStr / 10)
		end
	end

	local _, onScreen = Camera:WorldToViewportPoint(aimPos)
	if not onScreen then return end

	local goal = CFrame.new(Camera.CFrame.Position, aimPos)
	Camera.CFrame = S.SmoothAim
		and Camera.CFrame:Lerp(goal, S.Speed / 100)
		or  goal
end)
