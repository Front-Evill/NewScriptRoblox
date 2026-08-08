if getgenv().DevlyxGrabWin then
    pcall(function() getgenv().DevlyxGrabWin:Destroy() end)
    getgenv().DevlyxGrabWin = nil
end

local UserInput = game:GetService("UserInputService")
local Marketplace = game:GetService("MarketplaceService")

math.randomseed(tick())
local accentColor = Color3.fromHSV(math.random(), 0.55, 0.9)
local isMobile = table.find({ Enum.Platform.IOS, Enum.Platform.Android }, UserInput:GetPlatform()) ~= nil
local windowHeight = isMobile and 380 or 460

local notifySound = "rbxassetid://119393948345399"

local categories = {
    { key = "s", name = "Sounds",     icon = "music" },
    { key = "i", name = "Images",     icon = "image" },
    { key = "m", name = "Meshes",     icon = "box" },
    { key = "a", name = "Animations", icon = "play" },
    { key = "v", name = "Videos",     icon = "video" },
    { key = "f", name = "Fonts",      icon = "type" },
}

local state = {
    seen = {},
    ids = {},
    counts = {},
    sections = {},
    countLabels = {},
    entries = {},
    rawOnly = false,
    notifyOnFind = false,
}
for _, cat in ipairs(categories) do
    state.seen[cat.key] = {}
    state.ids[cat.key] = {}
    state.counts[cat.key] = 0
    state.entries[cat.key] = {}
end

local window
local totalLabel
local visited = setmetatable({}, { __mode = "k" })

local function notify(title, content, duration)
    pcall(function()
        window:Notify({ Title = title, Content = content, Duration = duration or 5, idsound = notifySound })
    end)
end

local function getPath(obj)
    local result = obj.Name
    local current = obj.Parent
    while current and current ~= game do
        result = current.Name .. "." .. result
        current = current.Parent
    end
    return result
end

local function formatId(id)
    return state.rawOnly and id or ("rbxassetid://" .. id)
end

local function refreshTotal()
    local total = 0
    for _, cat in ipairs(categories) do total = total + state.counts[cat.key] end
    if totalLabel then pcall(function() totalLabel:Set(tostring(total)) end) end
end

local function addAsset(key, rawValue, path)
    if typeof(rawValue) ~= "string" or rawValue == "" then return end
    local id = rawValue:match("(%d+)")
    if not id then return end
    if state.seen[key][id] then return end
    state.seen[key][id] = true
    table.insert(state.ids[key], id)

    local section = state.sections[key]
    if section then
        local paragraph = section:AddParagraph({ Title = id, Content = path })
        local button = section:AddButton({
            Name = "Copy",
            Icon = "copy",
            Callback = function()
                if setclipboard then pcall(setclipboard, formatId(id)) end
                notify("Devlyx", "Copied.", 3)
            end,
        })
        table.insert(state.entries[key], { paragraph = paragraph, button = button })
    end

    state.counts[key] = state.counts[key] + 1
    local countLabel = state.countLabels[key]
    if countLabel then pcall(function() countLabel:Set(tostring(state.counts[key])) end) end
    refreshTotal()

    if state.notifyOnFind then notify("Devlyx", key .. ": " .. id, 3) end
end

local function clearCategory(key)
    for _, entry in ipairs(state.entries[key]) do
        pcall(function() entry.paragraph.Frame:Destroy() end)
        pcall(function() entry.button.Frame:Destroy() end)
    end
    state.entries[key] = {}
    state.seen[key] = {}
    state.ids[key] = {}
    state.counts[key] = 0
    local countLabel = state.countLabels[key]
    if countLabel then pcall(function() countLabel:Set("0") end) end
    refreshTotal()
end

local function clearAll()
    for _, cat in ipairs(categories) do clearCategory(cat.key) end
    notify("Devlyx", "All lists cleared.", 4)
end

local function handleObject(obj)
    if visited[obj] then return end
    visited[obj] = true

    pcall(function()
        if obj:IsA("Sound") then
            obj.Played:Connect(function() addAsset("s", obj.SoundId, getPath(obj)) end)
        elseif obj:IsA("VideoFrame") then
            obj:GetPropertyChangedSignal("Playing"):Connect(function()
                if obj.Playing then addAsset("v", obj.Video, getPath(obj)) end
            end)
        elseif obj:IsA("Humanoid") then
            obj.AnimationPlayed:Connect(function(track)
                if track and track.Animation then
                    addAsset("a", track.Animation.AnimationId, getPath(track.Animation))
                end
            end)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            addAsset("i", obj.Texture, getPath(obj))
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            addAsset("i", obj.Image, getPath(obj))
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            if obj.Texture ~= "" then addAsset("i", obj.Texture, getPath(obj)) end
        elseif obj:IsA("Tool") then
            if obj.TextureId ~= "" then addAsset("i", obj.TextureId, getPath(obj)) end
        elseif obj:IsA("Shirt") then
            addAsset("i", obj.ShirtTemplate, getPath(obj))
        elseif obj:IsA("Pants") then
            addAsset("i", obj.PantsTemplate, getPath(obj))
        elseif obj:IsA("ShirtGraphic") then
            addAsset("i", obj.Graphic, getPath(obj))
        elseif obj:IsA("SurfaceAppearance") then
            if obj.ColorMap ~= "" then addAsset("i", obj.ColorMap, getPath(obj)) end
            if obj.NormalMap ~= "" then addAsset("i", obj.NormalMap, getPath(obj)) end
            if obj.MetalnessMap ~= "" then addAsset("i", obj.MetalnessMap, getPath(obj)) end
            if obj.RoughnessMap ~= "" then addAsset("i", obj.RoughnessMap, getPath(obj)) end
        elseif obj:IsA("SpecialMesh") then
            addAsset("m", obj.MeshId, getPath(obj))
            if obj.TextureId ~= "" then addAsset("i", obj.TextureId, getPath(obj)) end
        elseif obj:IsA("MeshPart") then
            addAsset("m", obj.MeshId, getPath(obj))
            if obj.TextureID ~= "" then addAsset("i", obj.TextureID, getPath(obj)) end
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local fontFace = obj.FontFace
            if fontFace and fontFace.Family then addAsset("f", fontFace.Family, getPath(obj)) end
        end
    end)
end

local function copyCategory(key, name)
    local list = state.ids[key]
    if #list == 0 then
        notify("Devlyx", "No " .. name .. " found yet.", 4)
        return
    end
    local out = {}
    for _, id in ipairs(list) do table.insert(out, formatId(id)) end
    if setclipboard then pcall(setclipboard, table.concat(out, "\n")) end
    notify("Devlyx", "Copied " .. #out .. " " .. name .. " link(s).", 4)
end

local function copyAll()
    local out = {}
    for _, cat in ipairs(categories) do
        for _, id in ipairs(state.ids[cat.key]) do table.insert(out, formatId(id)) end
    end
    if #out == 0 then
        notify("Devlyx", "Nothing found yet.", 4)
        return
    end
    if setclipboard then pcall(setclipboard, table.concat(out, "\n")) end
    notify("Devlyx", "Copied " .. #out .. " link(s) total.", 4)
end

local Library = loadstring(game:HttpGet("https://github.com/Front-Evill/Library/releases/download/latest/main.lua"))()

window = Library:Window({
    Title = "Devlyx",
    SubTitle = nil,
    TabWidth = 160,
    Size = UDim2.fromOffset(620, windowHeight),
    Search = false,
    Resize = true,
    Stats = false,
    Acrylic = false,
    Animation = true,
    Theme = { Accent = accentColor },
    MinimizeKey = Enum.KeyCode.B,
    icno = { work = true, IdIcon = "8598068647", Size = 70 },
})

getgenv().DevlyxGrabWin = window

local overviewTab = window:AddTab({ Name = "Overview", Icon = "home" })
local mainSection = overviewTab:AddSection({ Name = "Overview", Icon = "search" })
local optionsSection = overviewTab:AddSection({ Name = "Options", Icon = "settings" })
totalLabel = mainSection:AddParagraph({ Title = "Total Found", Content = "0" })

mainSection:AddButton({ Name = "Copy Everything", Icon = "copy", Callback = copyAll })

mainSection:AddButton({
    Name = "Clear All",
    Icon = "trash-2",
    Confirm = {
        Title = "Clear everything?",
        Content = "This clears all found asset IDs across every category.",
        ConfirmText = "Clear",
        CancelText = "Cancel",
    },
    Callback = clearAll,
})

optionsSection:AddToggle({
    Name = "Copy Raw ID Only",
    Icon = "hash",
    Default = false,
    Callback = function(value) state.rawOnly = value end,
})

optionsSection:AddToggle({
    Name = "Notify On New Find",
    Icon = "bell",
    Default = false,
    Callback = function(value) state.notifyOnFind = value end,
})

optionsSection:AddColorPicker({ Name = "Theme" })

local IniteSection = overviewTab:AddSection({ Name = "Invite Server Discord", Icon = "link" })
IniteSection:AddLinks({
  Icon = "devlyx",
  Title = "Discord Server",
  Description = nil,
  Link = "https://discord.gg/xPMwC2DTeg",
  Tooltip = "Click to copy the invite link",
})

for _, cat in ipairs(categories) do
    local tab = window:AddTab({ Name = cat.name, Icon = cat.icon })
    local top = tab:AddSection({ Name = "Summary", Icon = cat.icon })

    state.countLabels[cat.key] = top:AddParagraph({ Title = "Found", Content = "0" })

    top:AddButton({ Name = "Copy All", Icon = "copy", Callback = function() copyCategory(cat.key, cat.name) end })

    top:AddButton({
        Name = "Clear",
        Icon = "trash-2",
        Confirm = {
            Title = "Clear " .. cat.name .. "?",
            Content = "This clears the " .. cat.name .. " list only.",
            ConfirmText = "Clear",
            CancelText = "Cancel",
        },
        Callback = function() clearCategory(cat.key) end,
    })

    state.sections[cat.key] = tab:AddSection({ Name = cat.name, Icon = cat.icon })
end

window:SelectTab("Overview")

notify("Devlyx", "Listening for sounds, videos, animations and assets...", 6)

for _, obj in ipairs(game:GetDescendants()) do
    handleObject(obj)
end

game.DescendantAdded:Connect(handleObject)
