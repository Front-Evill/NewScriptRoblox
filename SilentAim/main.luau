local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

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

local PARTS   = {"Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso","LeftArm","RightArm"}
local KEYS    = {"Always","MouseButton2","E","Q","Z","X","C","G"}
local SORTS   = {"Distance2D","Distance3D","LowestHP","HighestHP"}

local espHighlights = {}

local function addESP(pl)
    if pl == LP then return end
    local function bind(char)
        if espHighlights[pl] then
            espHighlights[pl]:Destroy()
            espHighlights[pl] = nil
        end
        local hl = Instance.new("Highlight")
        hl.Adornee            = char
        hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillColor          = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency   = 0.45
        hl.OutlineColor       = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Enabled            = S.ESPEnabled
        hl.Parent             = char
        espHighlights[pl]     = hl
    end
    if pl.Character then bind(pl.Character) end
    pl.CharacterAdded:Connect(bind)
end

local function removeESP(pl)
    if espHighlights[pl] then
        espHighlights[pl]:Destroy()
        espHighlights[pl] = nil
    end
end

for _, pl in ipairs(Players:GetPlayers()) do addESP(pl) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

local gui = Instance.new("ScreenGui")
gui.Name           = "SilentAim"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LP.PlayerGui

local W = Instance.new("Frame", gui)
W.Size             = UDim2.new(0, 290, 0, 460)
W.Position         = UDim2.new(0, 50, 0, 50)
W.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
W.BorderSizePixel  = 0
W.ClipsDescendants = false
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 12)
local ws = Instance.new("UIStroke", W)
ws.Color = Color3.fromRGB(130, 16, 16) ws.Thickness = 1.4 ws.Transparency = 0.3

local bgImg = Instance.new("ImageLabel", W)
bgImg.Size                   = UDim2.new(1,0,1,0)
bgImg.BackgroundTransparency = 1
bgImg.Image                  = "rbxasset://111823734811187"
bgImg.ImageTransparency      = 0.6
bgImg.ScaleType              = Enum.ScaleType.Crop
bgImg.ZIndex                 = 0
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 12)

local accentBar = Instance.new("Frame", W)
accentBar.Size             = UDim2.new(1,0,0,3)
accentBar.BackgroundColor3 = Color3.fromRGB(200,30,30)
accentBar.BorderSizePixel  = 0
accentBar.ZIndex           = 5
local ag = Instance.new("UIGradient", accentBar)
ag.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(140,16,16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,60,60)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(140,16,16)),
})

local hdr = Instance.new("Frame", W)
hdr.Size             = UDim2.new(1,0,0,48)
hdr.Position         = UDim2.new(0,0,0,3)
hdr.BackgroundColor3 = Color3.fromRGB(11,9,16)
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 5

local icoLbl = Instance.new("ImageLabel", hdr)
icoLbl.Size                   = UDim2.new(0,24,0,24)
icoLbl.Position               = UDim2.new(0,12,0.5,-12)
icoLbl.BackgroundTransparency = 1
icoLbl.Image                  = "rbxasset://80293187955968"
icoLbl.ZIndex                 = 6

local titleLbl = Instance.new("TextLabel", hdr)
titleLbl.Size               = UDim2.new(0,140,0,20)
titleLbl.Position           = UDim2.new(0,44,0,7)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "SILENT AIM"
titleLbl.TextColor3         = Color3.fromRGB(230,230,230)
titleLbl.TextSize           = 13
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 6

local byLbl = Instance.new("TextLabel", hdr)
byLbl.Size               = UDim2.new(0,140,0,13)
byLbl.Position           = UDim2.new(0,44,0,29)
byLbl.BackgroundTransparency = 1
byLbl.Text               = "by FrontEvill"
byLbl.TextColor3         = Color3.fromRGB(70,20,20)
byLbl.TextSize           = 10
byLbl.Font               = Enum.Font.Gotham
byLbl.TextXAlignment     = Enum.TextXAlignment.Left
byLbl.ZIndex             = 6

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size             = UDim2.new(0,24,0,24)
closeBtn.Position         = UDim2.new(1,-34,0.5,-12)
closeBtn.BackgroundColor3 = Color3.fromRGB(24,10,10)
closeBtn.BorderSizePixel  = 0
closeBtn.Text             = "x"
closeBtn.TextColor3       = Color3.fromRGB(175,38,38)
closeBtn.TextSize         = 12
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.ZIndex           = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
local cs = Instance.new("UIStroke", closeBtn)
cs.Color = Color3.fromRGB(65,15,15) cs.Thickness = 1

local tabBar = Instance.new("Frame", W)
tabBar.Size             = UDim2.new(1,0,0,30)
tabBar.Position         = UDim2.new(0,0,0,51)
tabBar.BackgroundColor3 = Color3.fromRGB(10,8,15)
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 5

local tabDiv = Instance.new("Frame", tabBar)
tabDiv.Size             = UDim2.new(1,0,0,1)
tabDiv.Position         = UDim2.new(0,0,1,-1)
tabDiv.BackgroundColor3 = Color3.fromRGB(32,11,11)
tabDiv.BorderSizePixel  = 0
tabDiv.ZIndex           = 5

local pages   = {}
local tabBtns = {}
local curTab  = nil

local function switchTab(name)
    if curTab then
        pages[curTab].Visible           = false
        tabBtns[curTab].BackgroundColor3 = Color3.fromRGB(12,8,17)
        tabBtns[curTab].TextColor3       = Color3.fromRGB(100,35,35)
    end
    curTab = name
    pages[name].Visible           = true
    tabBtns[name].BackgroundColor3 = Color3.fromRGB(125,15,15)
    tabBtns[name].TextColor3       = Color3.fromRGB(255,255,255)
end

for i, name in ipairs({"Toggles","Lists","Sliders"}) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Size             = UDim2.new(0,80,0,22)
    btn.Position         = UDim2.new(0, 6+(i-1)*86, 0.5,-11)
    btn.BackgroundColor3 = Color3.fromRGB(12,8,17)
    btn.BorderSizePixel  = 0
    btn.Text             = name
    btn.TextColor3       = Color3.fromRGB(100,35,35)
    btn.TextSize         = 11
    btn.Font             = Enum.Font.GothamBold
    btn.ZIndex           = 6
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(40,11,11) bs.Thickness = 1

    local sf = Instance.new("ScrollingFrame", W)
    sf.Size                   = UDim2.new(1,0,1,-84)
    sf.Position               = UDim2.new(0,0,0,84)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel        = 0
    sf.ScrollBarThickness     = 2
    sf.ScrollBarImageColor3   = Color3.fromRGB(130,18,18)
    sf.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    sf.CanvasSize             = UDim2.new(0,0,0,0)
    sf.Visible                = false
    sf.ZIndex                 = 4
    local l = Instance.new("UIListLayout", sf)
    l.Padding             = UDim.new(0,6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local p = Instance.new("UIPadding", sf)
    p.PaddingTop    = UDim.new(0,10)
    p.PaddingBottom = UDim.new(0,14)
    p.PaddingLeft   = UDim.new(0,11)
    p.PaddingRight  = UDim.new(0,11)
    pages[name]   = sf
    tabBtns[name] = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Toggles")

local function Sec(pg, txt)
    local f = Instance.new("Frame", pg)
    f.Size             = UDim2.new(1,0,0,19)
    f.BackgroundColor3 = Color3.fromRGB(18,7,7)
    f.BorderSizePixel  = 0
    f.ZIndex           = 5
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,5)
    local l = Instance.new("TextLabel", f)
    l.Size               = UDim2.new(1,-10,1,0)
    l.Position           = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.TextColor3         = Color3.fromRGB(160,32,32)
    l.TextSize           = 10
    l.Font               = Enum.Font.GothamBold
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.ZIndex             = 5
end

local function Tog(pg, label, default, cb)
    local row = Instance.new("Frame", pg)
    row.Size             = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = Color3.fromRGB(12,10,18)
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke", row)
    rs.Color = Color3.fromRGB(26,11,11) rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1,-54,1,0)
    lbl.Position           = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(195,195,195)
    lbl.TextSize           = 12
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(0,36,0,18)
    track.Position         = UDim2.new(1,-46,0.5,-9)
    track.BackgroundColor3 = default and Color3.fromRGB(145,18,18) or Color3.fromRGB(26,13,13)
    track.BorderSizePixel  = 0
    track.ZIndex           = 5
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0,12,0,12)
    knob.Position         = default and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local state = default
    local hit = Instance.new("TextButton", row)
    hit.Size               = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1
    hit.Text               = ""
    hit.ZIndex             = 7
    hit.MouseButton1Click:Connect(function()
        state = not state
        track.BackgroundColor3 = state and Color3.fromRGB(145,18,18) or Color3.fromRGB(26,13,13)
        knob.Position = state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
        if cb then cb(state) end
    end)
end

local function Drop(pg, label, opts, default, cb)
    local wrap = Instance.new("Frame", pg)
    wrap.Size               = UDim2.new(1,0,0,36)
    wrap.BackgroundTransparency = 1
    wrap.ClipsDescendants   = false
    wrap.ZIndex             = 8

    local row = Instance.new("Frame", wrap)
    row.Size             = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = Color3.fromRGB(12,10,18)
    row.BorderSizePixel  = 0
    row.ZIndex           = 8
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke", row)
    rs.Color = Color3.fromRGB(26,11,11) rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(0,95,1,0)
    lbl.Position           = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(195,195,195)
    lbl.TextSize           = 12
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 8

    local sel = Instance.new("TextButton", row)
    sel.Size             = UDim2.new(0,105,0,22)
    sel.Position         = UDim2.new(1,-115,0.5,-11)
    sel.BackgroundColor3 = Color3.fromRGB(18,8,8)
    sel.BorderSizePixel  = 0
    sel.Text             = default .. " v"
    sel.TextColor3       = Color3.fromRGB(185,38,38)
    sel.TextSize         = 11
    sel.Font             = Enum.Font.GothamBold
    sel.ZIndex           = 9
    Instance.new("UICorner", sel).CornerRadius = UDim.new(0,5)
    local ss = Instance.new("UIStroke", sel)
    ss.Color = Color3.fromRGB(70,16,16) ss.Thickness = 1

    local drop = Instance.new("Frame", gui)
    drop.Size             = UDim2.new(0,105,0,#opts*25)
    drop.BackgroundColor3 = Color3.fromRGB(10,6,6)
    drop.BorderSizePixel  = 0
    drop.ZIndex           = 50
    drop.Visible          = false
    Instance.new("UICorner", drop).CornerRadius = UDim.new(0,6)
    local ds = Instance.new("UIStroke", drop)
    ds.Color = Color3.fromRGB(70,16,16) ds.Thickness = 1
    Instance.new("UIListLayout", drop).Padding = UDim.new(0,0)

    for _, opt in ipairs(opts) do
        local item = Instance.new("TextButton", drop)
        item.Size             = UDim2.new(1,0,0,25)
        item.BackgroundColor3 = Color3.fromRGB(10,6,6)
        item.BorderSizePixel  = 0
        item.Text             = opt
        item.TextColor3       = Color3.fromRGB(185,185,185)
        item.TextSize         = 11
        item.Font             = Enum.Font.Gotham
        item.ZIndex           = 51
        item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(28,9,9) end)
        item.MouseLeave:Connect(function() item.BackgroundColor3 = Color3.fromRGB(10,6,6) end)
        item.MouseButton1Click:Connect(function()
            sel.Text     = opt .. " v"
            drop.Visible = false
            if cb then cb(opt) end
        end)
    end

    sel.MouseButton1Click:Connect(function()
        if drop.Visible then
            drop.Visible = false
            return
        end
        local ap = sel.AbsolutePosition
        local as = sel.AbsoluteSize
        drop.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 3)
        drop.Visible  = true
    end)

    return wrap
end

local function Sld(pg, label, min, max, default, sfx, cb)
    local row = Instance.new("Frame", pg)
    row.Size             = UDim2.new(1,0,0,50)
    row.BackgroundColor3 = Color3.fromRGB(12,10,18)
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke", row)
    rs.Color = Color3.fromRGB(26,11,11) rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(0.58,0,0,18)
    lbl.Position           = UDim2.new(0,10,0,7)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(195,195,195)
    lbl.TextSize           = 12
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size               = UDim2.new(0.4,0,0,18)
    valLbl.Position           = UDim2.new(0.58,0,0,7)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(default)..(sfx or "")
    valLbl.TextColor3         = Color3.fromRGB(185,35,35)
    valLbl.TextSize           = 12
    valLbl.Font               = Enum.Font.GothamBold
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right
    valLbl.ZIndex             = 5

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(1,-20,0,5)
    track.Position         = UDim2.new(0,10,0,34)
    track.BackgroundColor3 = Color3.fromRGB(22,11,11)
    track.BorderSizePixel  = 0
    track.ZIndex           = 5
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(165,25,25)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(130,18,18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(215,52,52)),
    })

    local knob = Instance.new("Frame", track)
    knob.Size         = UDim2.new(0,13,0,13)
    knob.AnchorPoint  = Vector2.new(0.5,0.5)
    knob.Position     = UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel  = 0
    knob.ZIndex       = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function upd(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + rel*(max-min))
        valLbl.Text   = tostring(val)..(sfx or "")
        fill.Size     = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,0,0.5,0)
        if cb then cb(val) end
    end

    local hit = Instance.new("TextButton", track)
    hit.Size               = UDim2.new(1,0,0,22)
    hit.Position           = UDim2.new(0,0,0.5,-11)
    hit.BackgroundTransparency = 1
    hit.Text               = ""
    hit.ZIndex             = 7
    hit.MouseButton1Down:Connect(function()
        dragging = true
        upd(UserInputService:GetMouseLocation().X)
    end)
    hit.TouchLongPress:Connect(function() dragging = true end)
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
            upd(i.Position.X)
        end
    end)
end

Sec(pages["Toggles"], "AIM")
Tog(pages["Toggles"], "Aimbot",           false, function(v) S.Enabled         = v end)
Tog(pages["Toggles"], "Smooth Aim",       true,  function(v) S.SmoothAim        = v end)
Tog(pages["Toggles"], "Require Key",      false, function(v) S.RequireKey       = v end)
Tog(pages["Toggles"], "Predict Movement", false, function(v) S.PredictMovement  = v end)
Sec(pages["Toggles"], "FILTERS")
Tog(pages["Toggles"], "Wall Check",       true,  function(v) S.WallCheck  = v end)
Tog(pages["Toggles"], "Team Check",       false, function(v) S.TeamCheck  = v end)
Sec(pages["Toggles"], "VISUAL")
Tog(pages["Toggles"], "Show FOV",         true,  function(v) S.ShowFOV    = v end)
Tog(pages["Toggles"], "ESP",              false, function(v)
    S.ESPEnabled = v
    for _, hl in pairs(espHighlights) do hl.Enabled = v end
end)

Sec(pages["Lists"], "TARGET")
Drop(pages["Lists"], "Target Part", PARTS, S.TargetPart, function(v) S.TargetPart = v end)
Drop(pages["Lists"], "Sort By",     SORTS, S.SortMethod, function(v) S.SortMethod = v end)
Sec(pages["Lists"], "CONTROLS")
Drop(pages["Lists"], "Aim Key", KEYS, S.AimKey, function(v) S.AimKey = v end)

Sec(pages["Sliders"], "AIM")
Sld(pages["Sliders"], "FOV Radius",    40, 600,  S.FOVRadius,  "px", function(v) S.FOVRadius   = v end)
Sld(pages["Sliders"], "Aim Speed",     1,  60,   S.AimSpeed,   "",   function(v) S.AimSpeed    = v end)
Sld(pages["Sliders"], "Max Distance",  50, 2000, S.MaxDistance,"st", function(v) S.MaxDistance = v end)
Sld(pages["Sliders"], "Predict Str",   1,  20,   S.PredictStr, "",   function(v) S.PredictStr  = v end)

local oGui = Instance.new("ScreenGui")
oGui.Name           = "SilentAim_Overlay"
oGui.ResetOnSpawn   = false
oGui.IgnoreGuiInset = true
oGui.Parent         = LP.PlayerGui

local oFrame = Instance.new("Frame", oGui)
oFrame.Size                   = UDim2.new(1,0,1,0)
oFrame.BackgroundTransparency = 1

local fovCircle = Instance.new("Frame", oFrame)
fovCircle.AnchorPoint         = Vector2.new(0.5,0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel     = 0
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)
local fovS = Instance.new("UIStroke", fovCircle)
fovS.Color       = Color3.fromRGB(255,255,255)
fovS.Thickness   = 1.2
fovS.Transparency = 0.2

local dragging   = false
local dragOffset = Vector2.new()

hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        local pos  = i.Position
        dragOffset = Vector2.new(pos.X - W.AbsolutePosition.X, pos.Y - W.AbsolutePosition.Y)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local p = i.Position
        W.Position = UDim2.new(0, p.X - dragOffset.X, 0, p.Y - dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

closeBtn.MouseButton1Click:Connect(function() W.Visible = false end)
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.F then W.Visible = not W.Visible end
end)

local function keyOK()
    if not S.RequireKey or S.AimKey == "Always" then return true end
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
    rp.FilterDescendantsInstances = {LP.Character, part.Parent}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    return workspace:Raycast(origin, part.Position - origin, rp) == nil
end

local function getTargetPart(char)
    local p = char:FindFirstChild(S.TargetPart)
    if p then return p end
    for _, name in ipairs(PARTS) do
        local found = char:FindFirstChild(name)
        if found then return found end
    end
    return nil
end

local function getBest()
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    local center = Vector2.new(cx, cy)
    local best, bestScore = nil, math.huge

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        if S.TeamCheck and pl.Team == LP.Team then continue end
        local char = pl.Character if not char then continue end
        local part = getTargetPart(char) if not part then continue end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if (part.Position - Camera.CFrame.Position).Magnitude > S.MaxDistance then continue end
        if not canSee(part) then continue end

        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d2 > S.FOVRadius then continue end

        local score = d2
        if S.SortMethod == "Distance3D" then
            score = (part.Position - Camera.CFrame.Position).Magnitude
        elseif S.SortMethod == "LowestHP" then
            score = hum.Health
        elseif S.SortMethod == "HighestHP" then
            score = -hum.Health
        end

        if score < bestScore then
            bestScore = score
            best      = part
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2
    local r  = S.FOVRadius

    fovCircle.Visible  = S.ShowFOV
    fovCircle.Position = UDim2.new(0, cx, 0, cy)
    fovCircle.Size     = UDim2.new(0, r*2, 0, r*2)

    if not S.Enabled or not keyOK() then return end

    local target = getBest()
    if not target then return end

    local aimPos = target.Position
    if S.PredictMovement then
        local vel  = target.AssemblyLinearVelocity
        local ping = LP:GetNetworkPing()
        aimPos = target.Position + vel * ping * (S.PredictStr/10)
    end

    local _, vis = Camera:WorldToViewportPoint(aimPos)
    if not vis then return end

    local newCF = CFrame.new(Camera.CFrame.Position, aimPos)
    if S.SmoothAim then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, S.AimSpeed/100)
    else
        Camera.CFrame = newCF
    end
end)
