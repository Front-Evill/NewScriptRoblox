local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WebHook Mng",
    SubTitle = "by FrontEvill",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.F,
})

local Tabs = {
    Detector = Window:AddTab({ Title = "Detector", Icon = "link" }),
    Webhook  = Window:AddTab({ Title = "Webhook",   Icon = "send" }),
    Firewall = Window:AddTab({ Title = "Firewall",  Icon = "shield" }),
    Log      = Window:AddTab({ Title = "Log",       Icon = "file-text" }),
}

local Theme = {
    Panel        = Color3.fromRGB(30, 30, 30),
    Card         = Color3.fromRGB(35, 35, 40),
    CardAlert    = Color3.fromRGB(45, 30, 30),
    ScrollBg     = Color3.fromRGB(20, 20, 20),
    ButtonBg     = Color3.fromRGB(50, 50, 55),

    Accent       = Color3.fromRGB(255, 200, 50),
    Danger       = Color3.fromRGB(255, 80, 80),

    TextPrimary  = Color3.fromRGB(255, 255, 255),
    TextAlert    = Color3.fromRGB(255, 210, 210),
    TextInfo     = Color3.fromRGB(180, 180, 255),
    TextMuted    = Color3.fromRGB(150, 150, 150),
    TextSuccess  = Color3.fromRGB(100, 255, 100),
    TextWarning  = Color3.fromRGB(255, 255, 100),
}

local URL_PATTERN = "(https?://[%w%-%._~:/?#%[%]@!%$&'%(%)%*%+,;=]+)"
local WEBHOOK_URL_PATTERN = "discord[a-z]*%.com/api/webhooks/"
local WEBHOOK_MAX_CHARS = 2000
local TEXT_RESCAN_DEBOUNCE = 0.4
local WEBHOOK_NOTIFY_COOLDOWN = 15

local isScanning = false
local foundLinks = {}
local linkCount = 0
local logCount = 0
local existingGUIs = {}
local guiConnections = {}
local loadUrlIntoWebhookTab


local function showRobloxNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

local function isWebhookUrl(url)
    return string.find(string.lower(url), WEBHOOK_URL_PATTERN) ~= nil
end

local function getFullPath(obj)
    local path = obj.Name
    local current = obj.Parent
    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end
    return path
end

local function extractLinksFromString(str, obj, results)
    if typeof(str) ~= "string" or str == "" then return end
    for url in string.gmatch(str, URL_PATTERN) do
        table.insert(results, {
            url = url,
            objectName = obj.Name,
            fullPath = getFullPath(obj),
            isWebhook = isWebhookUrl(url),
        })
    end
end

local function scanObjectForLinks(obj)
    local results = {}

    local ok, text = pcall(function() return obj.Text end)
    if ok then
        extractLinksFromString(text, obj, results)
    end

    local phOk, placeholder = pcall(function() return obj.PlaceholderText end)
    if phOk then
        extractLinksFromString(placeholder, obj, results)
    end

    local attrOk, attributes = pcall(function() return obj:GetAttributes() end)
    if attrOk and typeof(attributes) == "table" then
        for _, value in pairs(attributes) do
            extractLinksFromString(value, obj, results)
        end
    end

    return results
end

local function createStatusBar(container, defaultStatusText, defaultCountText)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 50)
    bar.BackgroundColor3 = Theme.Panel
    bar.BackgroundTransparency = 0.4
    bar.BorderSizePixel = 0
    bar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent = bar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = bar

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 18)
    statusLabel.Position = UDim2.new(0, 0, 0, 2)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = defaultStatusText
    statusLabel.TextColor3 = Theme.TextWarning
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = bar

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -10, 0, 16)
    countLabel.Position = UDim2.new(0, 0, 0, 22)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = defaultCountText
    countLabel.TextColor3 = Theme.TextPrimary
    countLabel.TextSize = 11
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Parent = bar

    return statusLabel, countLabel
end

local function createScrollList(container, height)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, height)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = container

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.fromScale(1, 1)
    scrollFrame.BackgroundColor3 = Theme.ScrollBg
    scrollFrame.BackgroundTransparency = 0.5
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Theme.TextPrimary
    scrollFrame.ScrollBarImageTransparency = 0.6
    scrollFrame.CanvasSize = UDim2.fromScale(0, 0)
    scrollFrame.Parent = wrapper

    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame

    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingLeft = UDim.new(0, 5)
    innerPad.PaddingRight = UDim.new(0, 5)
    innerPad.PaddingTop = UDim.new(0, 5)
    innerPad.PaddingBottom = UDim.new(0, 5)
    innerPad.Parent = scrollFrame

    return scrollFrame, listLayout
end

local function updateScrollCanvas(scrollFrame, listLayout, extraPadding)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + (extraPadding or 10))
end

-- ===================== Detector tab =====================

local statusLabel
local countLabel
local linkScrollFrame
local linkListLayout

local function updateLinkScrollSize()
    updateScrollCanvas(linkScrollFrame, linkListLayout, 15)
end

local function createLinkEntry(url, objectName, fullPath, isWebhook)
    local entryFrame = Instance.new("Frame")
    entryFrame.Size = UDim2.new(1, -4, 0, 80)
    entryFrame.BackgroundColor3 = isWebhook and Theme.CardAlert or Theme.Card
    entryFrame.BackgroundTransparency = 0.15
    entryFrame.BorderSizePixel = 0
    entryFrame.LayoutOrder = linkCount
    entryFrame.Parent = linkScrollFrame

    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entryFrame

    entryFrame.BackgroundTransparency = 1
    TweenService:Create(entryFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.15 }):Play()

    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 4, 1, 0)
    highlight.BackgroundColor3 = isWebhook and Theme.Danger or Theme.Accent
    highlight.BorderSizePixel = 0
    highlight.Parent = entryFrame

    local hlCorner = Instance.new("UICorner")
    hlCorner.CornerRadius = UDim.new(0, 8)
    hlCorner.Parent = highlight

    if isWebhook then
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 62, 0, 14)
        badge.Position = UDim2.new(1, -100, 0, -6)
        badge.BackgroundColor3 = Theme.Danger
        badge.BorderSizePixel = 0
        badge.Text = "WEBHOOK"
        badge.TextColor3 = Theme.TextPrimary
        badge.TextSize = 9
        badge.Font = Enum.Font.GothamBold
        badge.Parent = entryFrame

        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 4)
        badgeCorner.Parent = badge
    end

    local urlLabel = Instance.new("TextLabel")
    urlLabel.Size = UDim2.new(1, -120, 0, 18)
    urlLabel.Position = UDim2.new(0, 10, 0, 8)
    urlLabel.BackgroundTransparency = 1
    urlLabel.Text = url
    urlLabel.TextColor3 = isWebhook and Theme.TextAlert or Theme.TextPrimary
    urlLabel.TextSize = 11
    urlLabel.Font = Enum.Font.GothamBold
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    urlLabel.TextTruncate = Enum.TextTruncate.AtEnd
    urlLabel.Parent = entryFrame

    local objectLabel = Instance.new("TextLabel")
    objectLabel.Size = UDim2.new(1, -120, 0, 14)
    objectLabel.Position = UDim2.new(0, 10, 0, 30)
    objectLabel.BackgroundTransparency = 1
    objectLabel.Text = "Object: " .. objectName
    objectLabel.TextColor3 = Theme.TextInfo
    objectLabel.TextSize = 9
    objectLabel.Font = Enum.Font.Gotham
    objectLabel.TextXAlignment = Enum.TextXAlignment.Left
    objectLabel.TextTruncate = Enum.TextTruncate.AtEnd
    objectLabel.Parent = entryFrame

    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -120, 0, 14)
    pathLabel.Position = UDim2.new(0, 10, 0, 46)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = "Path: " .. fullPath
    pathLabel.TextColor3 = Theme.TextMuted
    pathLabel.TextSize = 9
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pathLabel.Parent = entryFrame

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -120, 0, 14)
    timeLabel.Position = UDim2.new(0, 10, 0, 62)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Found: " .. os.date("%H:%M:%S")
    timeLabel.TextColor3 = Theme.TextSuccess
    timeLabel.TextSize = 8
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = entryFrame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 90, 0, 24)
    copyBtn.Position = UDim2.new(1, -100, 0, 10)
    copyBtn.BackgroundColor3 = Theme.ButtonBg
    copyBtn.BackgroundTransparency = 0.1
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "Copy Link"
    copyBtn.TextColor3 = Theme.TextPrimary
    copyBtn.TextSize = 10
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = entryFrame

    local copyBtnCorner = Instance.new("UICorner")
    copyBtnCorner.CornerRadius = UDim.new(0, 4)
    copyBtnCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(url)
        end
        copyBtn.Text = "Copied!"
        task.delay(1.5, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "Copy Link"
            end
        end)
    end)

    if isWebhook then
        local useBtn = Instance.new("TextButton")
        useBtn.Size = UDim2.new(0, 90, 0, 24)
        useBtn.Position = UDim2.new(1, -100, 0, 40)
        useBtn.BackgroundColor3 = Theme.Danger
        useBtn.BackgroundTransparency = 0.1
        useBtn.BorderSizePixel = 0
        useBtn.Text = "Use in Webhook"
        useBtn.TextColor3 = Theme.TextPrimary
        useBtn.TextSize = 9
        useBtn.Font = Enum.Font.GothamBold
        useBtn.Parent = entryFrame

        local useBtnCorner = Instance.new("UICorner")
        useBtnCorner.CornerRadius = UDim.new(0, 4)
        useBtnCorner.Parent = useBtn

        useBtn.MouseButton1Click:Connect(function()
            if loadUrlIntoWebhookTab then
                loadUrlIntoWebhookTab(url)
            end
        end)
    end

    return entryFrame
end

-- ===================== Log tab =====================

local logScrollFrame
local logListLayout

local function addLogEntry(url, timestamp, isWebhook)
    logCount = logCount + 1

    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -4, 0, 24)
    row.BackgroundColor3 = isWebhook and Theme.CardAlert or Theme.Card
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.LayoutOrder = logCount
    row.Text = string.format("[%s] #%d %s %s", timestamp, logCount, isWebhook and "[WEBHOOK]" or "", url)
    row.TextColor3 = isWebhook and Theme.TextAlert or Theme.TextPrimary
    row.TextSize = 10
    row.Font = Enum.Font.Gotham
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.Parent = logScrollFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.Parent = row

    updateScrollCanvas(logScrollFrame, logListLayout)
end

-- ===================== Detector: link registration =====================

local function addLink(data)
    if foundLinks[data.url] or not isScanning then return end
    foundLinks[data.url] = true
    linkCount = linkCount + 1
    if countLabel then
        countLabel.Text = "Found: " .. linkCount .. " links"
    end

    createLinkEntry(data.url, data.objectName, data.fullPath, data.isWebhook)
    addLogEntry(data.url, os.date("%H:%M:%S"), data.isWebhook)
    updateLinkScrollSize()

    if data.isWebhook then
        showRobloxNotification("Link Detector", "Webhook link found: " .. data.url, 6)
    else
        showRobloxNotification("Link Detector", "New link found: " .. data.url, 5)
    end
end

-- ===================== Firewall tab =====================
-- Intercepts network requests made by ANY script in this session (not just
-- this tool) and blocks any that target a Discord webhook URL, so exploit
-- scripts that try to exfiltrate player data through a hardcoded webhook
-- can't reach it. Detections are also mirrored into the Detector list/Log.

local isFirewallEnabled = false
local blockedCount = 0
local originalRequestFn = nil
local hookedRequestFn = nil
local originalPostAsync = nil

local firewallStatusLabel
local firewallCountLabel
local firewallScrollFrame
local firewallListLayout
local blockedRows = {} -- url -> { frame, countLabel, attempts, lastNotified }

local function getExecutorRequestFn()
    return (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
end

local function getCallerSource()
    local ok, info = pcall(function() return debug.info(3, "s") end)
    if ok and info then return info end
    return "unknown"
end

local function createBlockedRow(url, source)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Theme.CardAlert
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.LayoutOrder = blockedCount
    row.Parent = firewallScrollFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 4)
    padding.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -180, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.format("[%s] %s\nfrom: %s", os.date("%H:%M:%S"), url, source)
    label.TextColor3 = Theme.TextAlert
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.Parent = row

    local countLabelRow = Instance.new("TextLabel")
    countLabelRow.Size = UDim2.new(0, 60, 1, 0)
    countLabelRow.Position = UDim2.new(1, -178, 0, 0)
    countLabelRow.BackgroundTransparency = 1
    countLabelRow.Text = "x1"
    countLabelRow.TextColor3 = Theme.TextMuted
    countLabelRow.TextSize = 10
    countLabelRow.Font = Enum.Font.GothamBold
    countLabelRow.TextXAlignment = Enum.TextXAlignment.Left
    countLabelRow.TextYAlignment = Enum.TextYAlignment.Top
    countLabelRow.Parent = row

    local useBtn = Instance.new("TextButton")
    useBtn.Size = UDim2.new(0, 88, 0, 24)
    useBtn.Position = UDim2.new(1, -92, 0.5, -12)
    useBtn.BackgroundColor3 = Theme.Danger
    useBtn.BackgroundTransparency = 0.1
    useBtn.BorderSizePixel = 0
    useBtn.Text = "Use in Webhook"
    useBtn.TextColor3 = Theme.TextPrimary
    useBtn.TextSize = 9
    useBtn.Font = Enum.Font.GothamBold
    useBtn.Parent = row

    local useBtnCorner = Instance.new("UICorner")
    useBtnCorner.CornerRadius = UDim.new(0, 4)
    useBtnCorner.Parent = useBtn

    useBtn.MouseButton1Click:Connect(function()
        if loadUrlIntoWebhookTab then
            loadUrlIntoWebhookTab(url)
        end
    end)

    return row, countLabelRow
end

local function addBlockedEntry(url, source)
    local existing = blockedRows[url]

    if existing then
        existing.attempts = existing.attempts + 1
        if existing.countLabel then
            existing.countLabel.Text = "x" .. existing.attempts
        end
    else
        blockedCount = blockedCount + 1
        local row, countLabelRow = createBlockedRow(url, source)
        blockedRows[url] = { frame = row, countLabel = countLabelRow, attempts = 1, lastNotified = 0 }
        existing = blockedRows[url]
        updateScrollCanvas(firewallScrollFrame, firewallListLayout)
    end

    if firewallCountLabel then
        firewallCountLabel.Text = "Blocked: " .. blockedCount .. " webhooks, " .. tostring(
            (function()
                local total = 0
                for _, entry in pairs(blockedRows) do total = total + entry.attempts end
                return total
            end)()
        ) .. " attempts"
    end

    if not foundLinks[url] then
        foundLinks[url] = true
        linkCount = linkCount + 1
        if countLabel then
            countLabel.Text = "Found: " .. linkCount .. " links"
        end
        createLinkEntry(url, "Exploit Script", source, true)
        addLogEntry(url, os.date("%H:%M:%S"), true)
        updateLinkScrollSize()
    end

    local now = os.clock()
    if now - existing.lastNotified >= WEBHOOK_NOTIFY_COOLDOWN then
        existing.lastNotified = now
        showRobloxNotification("Firewall", "Blocked a webhook request: " .. url, 6)
    end
end

local function enableWebhookFirewall()
    if isFirewallEnabled then return end

    if not hookfunction then
        showRobloxNotification("Firewall", "Your executor does not support hookfunction.", 6)
        return
    end

    local target = getExecutorRequestFn()
    if target then
        originalRequestFn = hookfunction(target, function(options)
            local url = options and (options.Url or options.url)
            if url and isWebhookUrl(url) then
                addBlockedEntry(url, getCallerSource())
                return { Success = false, StatusCode = 0, StatusMessage = "Blocked by Link Detector Firewall", Body = "" }
            end
            return originalRequestFn(options)
        end)
        hookedRequestFn = target
    end

    pcall(function()
        originalPostAsync = hookfunction(HttpService.PostAsync, function(self, url, ...)
            if typeof(url) == "string" and isWebhookUrl(url) then
                addBlockedEntry(url, getCallerSource())
                return ""
            end
            return originalPostAsync(self, url, ...)
        end)
    end)

    isFirewallEnabled = true
    if firewallStatusLabel then
        firewallStatusLabel.Text = "Status: Active - Blocking webhook requests"
        firewallStatusLabel.TextColor3 = Theme.TextSuccess
    end
    showRobloxNotification("Firewall", "Webhook firewall enabled.", 4)
end

local function disableWebhookFirewall()
    if not isFirewallEnabled then return end

    if hookfunction and hookedRequestFn and originalRequestFn then
        pcall(function() hookfunction(hookedRequestFn, originalRequestFn) end)
    end
    if hookfunction and originalPostAsync then
        pcall(function() hookfunction(HttpService.PostAsync, originalPostAsync) end)
    end

    isFirewallEnabled = false
    if firewallStatusLabel then
        firewallStatusLabel.Text = "Status: Inactive"
        firewallStatusLabel.TextColor3 = Theme.TextWarning
    end
    showRobloxNotification("Firewall", "Webhook firewall disabled.", 4)
end

local function clearBlockedList()
    for _, entry in pairs(blockedRows) do
        if entry.frame then entry.frame:Destroy() end
    end
    blockedRows = {}
    blockedCount = 0
    if firewallCountLabel then
        firewallCountLabel.Text = "Blocked: 0 webhooks, 0 attempts"
    end
    if firewallScrollFrame then
        firewallScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end

local function buildFirewallTab(container)
    Tabs.Firewall:AddParagraph({
        Title = "Block Webhook Requests From Other Scripts",
        Content = "Intercepts network requests made by any script running in this session (not just this tool) and blocks any that target a Discord webhook URL. Requires an executor that supports hookfunction.",
    })

    firewallStatusLabel, firewallCountLabel = createStatusBar(container, "Status: Inactive", "Blocked: 0 webhooks, 0 attempts")

    Tabs.Firewall:AddButton({
        Title = "Enable Firewall",
        Description = "Start blocking webhook requests from any script in this session",
        Callback = function()
            enableWebhookFirewall()
        end,
    })

    Tabs.Firewall:AddButton({
        Title = "Disable Firewall",
        Description = "Stop blocking and restore normal request behavior",
        Callback = function()
            disableWebhookFirewall()
        end,
    })

    Tabs.Firewall:AddButton({
        Title = "Clear Blocked List",
        Description = "Clear the list below (does not affect protection itself)",
        Callback = function()
            clearBlockedList()
        end,
    })

    firewallScrollFrame, firewallListLayout = createScrollList(container, 220)
end

-- ===================== Webhook tab =====================

local webhookUrl = ""
local webhookMessage = ""
local webhookUsername = ""
local isSendingWebhook = false
local isWebhookDisabled = false
local isDeletingWebhook = false
local deleteConfirmArmed = false

local webhookUrlInputRef
local webhookUsernameInputRef
local messageBoxRef
local charCountLabelRef

local function updateCharCountLabel()
    if not (messageBoxRef and charCountLabelRef) then return end
    local len = #messageBoxRef.Text
    charCountLabelRef.Text = len .. " / " .. WEBHOOK_MAX_CHARS
    charCountLabelRef.TextColor3 = len > WEBHOOK_MAX_CHARS and Theme.Danger or Theme.TextMuted
end

local function sendWebhookMessage(url, message, username)
    if isWebhookDisabled then
        return false, "This webhook has been disabled."
    end
    if isSendingWebhook then
        return false, "A message is already being sent."
    end
    if not url or url == "" then
        return false, "Please enter a webhook URL first."
    end
    if not string.match(url, "^https?://") then
        return false, "Webhook URL must start with http:// or https://"
    end
    if not message or message == "" then
        return false, "Please enter a message first."
    end
    if #message > WEBHOOK_MAX_CHARS then
        return false, "Message is too long (max " .. WEBHOOK_MAX_CHARS .. " characters)."
    end

    isSendingWebhook = true

    local payload = { content = message }
    if username and username ~= "" then
        payload.username = username
    end

    local body = HttpService:JSONEncode(payload)
    local requestFn = (syn and syn.request) or http_request or request
    local ok, result

    if requestFn then
        ok, result = pcall(function()
            return requestFn({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
        end)
    else
        ok, result = pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
    end

    isSendingWebhook = false

    if ok then
        return true
    else
        return false, tostring(result)
    end
end

local function performWebhookDelete(url)
    if not url or url == "" then
        return false, "Please enter or load a webhook URL first."
    end
    if not string.match(url, "^https?://") then
        return false, "Invalid webhook URL."
    end
    if isDeletingWebhook then
        return false, "A delete request is already in progress."
    end

    isDeletingWebhook = true

    local requestFn = (syn and syn.request) or http_request or request
    local ok, result

    if requestFn then
        ok, result = pcall(function()
            return requestFn({ Url = url, Method = "DELETE" })
        end)
    else
        ok, result = pcall(function()
            return HttpService:RequestAsync({ Url = url, Method = "DELETE" })
        end)
    end

    isDeletingWebhook = false

    if not ok then
        return false, tostring(result)
    end

    if typeof(result) == "table" and result.StatusCode then
        if result.StatusCode >= 200 and result.StatusCode < 300 then
            return true
        end
        return false, "Discord returned status " .. tostring(result.StatusCode) .. " (webhook may already be gone or the URL is invalid)."
    end

    return true
end

local function disableWebhook()
    isWebhookDisabled = true
    webhookUrl = ""
    webhookMessage = ""
    webhookUsername = ""

    if webhookUrlInputRef then
        pcall(function() webhookUrlInputRef:SetValue("") end)
    end
    if webhookUsernameInputRef then
        pcall(function() webhookUsernameInputRef:SetValue("") end)
    end
    if messageBoxRef then
        messageBoxRef.Text = ""
    end
    updateCharCountLabel()
end

local function buildWebhookTab(container)
    Tabs.Webhook:AddParagraph({
        Title = "Send a Webhook Message",
        Content = "Enter a webhook URL and your message, then press Send.\nBoth fields are typed by you — nothing is sent automatically or repeatedly.",
    })

    webhookUrlInputRef = Tabs.Webhook:AddInput("WebhookUrlInput", {
        Title = "Webhook URL",
        Default = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(value)
            webhookUrl = value
            if value ~= "" then
                isWebhookDisabled = false
            end
        end,
    })

    webhookUsernameInputRef = Tabs.Webhook:AddInput("WebhookUsernameInput", {
        Title = "Display Name (optional)",
        Default = "",
        Placeholder = "Custom sender name shown on Discord",
        Callback = function(value)
            webhookUsername = value
        end,
    })

    local messageWrapper = Instance.new("Frame")
    messageWrapper.Size = UDim2.new(1, 0, 0, 150)
    messageWrapper.BackgroundTransparency = 1
    messageWrapper.BorderSizePixel = 0
    messageWrapper.Parent = container

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 18)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "Message"
    messageLabel.TextColor3 = Theme.TextPrimary
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.GothamBold
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = messageWrapper

    local messageBoxFrame = Instance.new("Frame")
    messageBoxFrame.Size = UDim2.new(1, 0, 0, 100)
    messageBoxFrame.Position = UDim2.new(0, 0, 0, 22)
    messageBoxFrame.BackgroundColor3 = Theme.ScrollBg
    messageBoxFrame.BackgroundTransparency = 0.3
    messageBoxFrame.BorderSizePixel = 0
    messageBoxFrame.Parent = messageWrapper

    local messageBoxCorner = Instance.new("UICorner")
    messageBoxCorner.CornerRadius = UDim.new(0, 8)
    messageBoxCorner.Parent = messageBoxFrame

    local messagePadding = Instance.new("UIPadding")
    messagePadding.PaddingLeft = UDim.new(0, 8)
    messagePadding.PaddingRight = UDim.new(0, 8)
    messagePadding.PaddingTop = UDim.new(0, 6)
    messagePadding.PaddingBottom = UDim.new(0, 6)
    messagePadding.Parent = messageBoxFrame

    local messageBox = Instance.new("TextBox")
    messageBox.Size = UDim2.new(1, 0, 1, 0)
    messageBox.BackgroundTransparency = 1
    messageBox.Text = ""
    messageBox.PlaceholderText = "Type your message here... (spaces and new lines are preserved)"
    messageBox.PlaceholderColor3 = Theme.TextMuted
    messageBox.TextColor3 = Theme.TextPrimary
    messageBox.TextSize = 12
    messageBox.Font = Enum.Font.Gotham
    messageBox.TextXAlignment = Enum.TextXAlignment.Left
    messageBox.TextYAlignment = Enum.TextYAlignment.Top
    messageBox.TextWrapped = true
    messageBox.MultiLine = true
    messageBox.ClearTextOnFocus = false
    messageBox.Parent = messageBoxFrame
    messageBoxRef = messageBox

    local charCountLabel = Instance.new("TextLabel")
    charCountLabel.Size = UDim2.new(1, 0, 0, 14)
    charCountLabel.Position = UDim2.new(0, 0, 0, 124)
    charCountLabel.BackgroundTransparency = 1
    charCountLabel.Text = "0 / " .. WEBHOOK_MAX_CHARS
    charCountLabel.TextColor3 = Theme.TextMuted
    charCountLabel.TextSize = 10
    charCountLabel.Font = Enum.Font.Gotham
    charCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    charCountLabel.Parent = messageWrapper
    charCountLabelRef = charCountLabel

    messageBox:GetPropertyChangedSignal("Text"):Connect(function()
        webhookMessage = messageBox.Text
        updateCharCountLabel()
    end)

    Tabs.Webhook:AddButton({
        Title = "Send",
        Description = "Send the message above to the webhook URL above",
        Callback = function()
            if isWebhookDisabled then
                showRobloxNotification("Webhook", "This webhook is disabled. Enter a URL to re-enable it.", 5)
                return
            end
            if isSendingWebhook then
                showRobloxNotification("Webhook", "Already sending, please wait...", 3)
                return
            end

            showRobloxNotification("Webhook", "Sending message...", 3)

            task.spawn(function()
                local ok, err = sendWebhookMessage(webhookUrl, webhookMessage, webhookUsername)
                if ok then
                    showRobloxNotification("Webhook", "Message sent.", 4)
                else
                    showRobloxNotification("Webhook", err or "Failed to send message.", 6)
                end
            end)
        end,
    })

    Tabs.Webhook:AddButton({
        Title = "Delete This Webhook",
        Description = nul 
        Callback = function()
            if webhookUrl == "" then
                showRobloxNotification("Webhook", "Enter or load a webhook URL first.", 4)
                return
            end

            if not deleteConfirmArmed then
                deleteConfirmArmed = true
                showRobloxNotification("Webhook", "wait....", 5)
                task.delay(5, function() deleteConfirmArmed = false end)
                return
            end

            deleteConfirmArmed = false
            local urlToDelete = webhookUrl
            showRobloxNotification("Webhook", "Deleting webhook...", 3)

            task.spawn(function()
                local ok, err = performWebhookDelete(urlToDelete)
                if ok then
                    showRobloxNotification("Webhook", "Webhook deleted.", 5)
                    disableWebhook()
                else
                    showRobloxNotification("Webhook", err or "Failed to delete webhook.", 6)
                end
            end)
        end,
    })

    loadUrlIntoWebhookTab = function(url)
        webhookUrl = url
        isWebhookDisabled = false
        deleteConfirmArmed = false
        if webhookUrlInputRef then
            pcall(function() webhookUrlInputRef:SetValue(url) end)
        end
        Window:SelectTab(2)
        showRobloxNotification("Webhook", "Loaded webhook URL into the Webhook tab.", 4)
    end
end


local textWatchers = {}

local function scanNode(obj)
    if not isScanning then return end
    for _, link in pairs(scanObjectForLinks(obj)) do
        addLink(link)
    end
end

local function watchTextChanges(obj)
    if textWatchers[obj] then return end

    local ok = pcall(function() return obj.Text end)
    if not ok then return end

    local pendingRescan = false
    local changedConn = obj:GetPropertyChangedSignal("Text"):Connect(function()
        if pendingRescan then return end
        pendingRescan = true
        task.delay(TEXT_RESCAN_DEBOUNCE, function()
            pendingRescan = false
            scanNode(obj)
        end)
    end)

    textWatchers[obj] = changedConn

    obj.AncestryChanged:Connect(function(_, parent)
        if not parent and textWatchers[obj] then
            textWatchers[obj]:Disconnect()
            textWatchers[obj] = nil
        end
    end)
end

local function scanGuiTree(node)
    scanNode(node)
    watchTextChanges(node)
    for _, child in pairs(node:GetChildren()) do
        scanGuiTree(child)
    end
end

local function registerExistingGUIs()
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            existingGUIs[gui] = true
        end
    end
end

local function watchGui(gui)
    if guiConnections[gui] then return end

    local connection = gui.DescendantAdded:Connect(function(descendant)
        scanNode(descendant)
        watchTextChanges(descendant)
    end)
    guiConnections[gui] = connection

    gui.AncestryChanged:Connect(function(_, parent)
        if not parent and guiConnections[gui] then
            guiConnections[gui]:Disconnect()
            guiConnections[gui] = nil
        end
    end)
end

local function onGuiAdded(gui)
    if not (gui:IsA("ScreenGui") or gui:IsA("GuiBase")) then return end
    if existingGUIs[gui] then return end

    task.spawn(function()
        task.wait(0.5)
        scanGuiTree(gui)
        watchGui(gui)
    end)
end


statusLabel, countLabel = createStatusBar(Tabs.Detector.Container, "Status: Waiting...", "Found: 0 links")
linkScrollFrame, linkListLayout = createScrollList(Tabs.Detector.Container, 320)

Tabs.Detector:AddButton({
    Title = "Rescan Current GUI",
    Description = "Re-scan your current PlayerGui for links",
    Callback = function()
        for _, gui in pairs(playerGui:GetChildren()) do
            scanGuiTree(gui)
        end
    end,
})

Tabs.Detector:AddButton({
    Title = "Clear List",
    Description = "Clear all links from the list (does not affect the log)",
    Callback = function()
        for _, child in pairs(linkScrollFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        foundLinks = {}
        linkCount = 0
        if countLabel then countLabel.Text = "Found: 0 links" end
        linkScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end,
})

buildWebhookTab(Tabs.Webhook.Container)
buildFirewallTab(Tabs.Firewall.Container)
logScrollFrame, logListLayout = createScrollList(Tabs.Log.Container, 400)

Window:SelectTab(1)

task.spawn(function()
    if statusLabel then
        statusLabel.Text = "Status: Waiting 2 seconds..."
        statusLabel.TextColor3 = Theme.TextWarning
    end
    task.wait(2)
    isScanning = true
    if statusLabel then
        statusLabel.Text = "Status: Active - Watching for Links"
        statusLabel.TextColor3 = Theme.TextSuccess
    end
    Fluent:Notify({
        Title = "Link Detector",
        Content = "Started! Press B to hide/show.",
        Duration = 6,
    })
end)

registerExistingGUIs()
playerGui.ChildAdded:Connect(onGuiAdded)
