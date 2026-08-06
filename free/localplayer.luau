if getgenv().Devlyx then
    pcall(function() getgenv().Devlyx:Destroy() end)
    getgenv().Devlyx = nil
end

getgenv().Ready = false
getgenv().Noclip = nil

local Players = game:GetService('Players')
local Local = Players.LocalPlayer
local Char = Local.Character or Local.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local UserInputService = game:GetService('UserInputService')
local runs = game:GetService("RunService")
local playerspeed
local playerJump
local noclipConnection
local InfiniteJumpConnection

-- function

local function n(title, text, duration)
    pcall(function()
        Window:Notify({ Title = title, Content = text, Duration = duration or 5 })
    end)
end

-- ui
math.randomseed(tick())
local randomAccent = Color3.fromHSV(math.random(), 0.55, 0.9)

local isMobile = table.find({ Enum.Platform.IOS, Enum.Platform.Android }, UserInputService:GetPlatform()) ~= nil
local windowHeight = isMobile and 380 or 460

local Library = loadstring(game:HttpGet("https://github.com/Front-Evill/Library/releases/latest/download/main.lua"))()
local Window = Library:Window({
    Title = "Devlyx",
    SubTitle = "by FrontEvill",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, windowHeight),
    Search = false,
    Resize = true,
    Stats = false,
    Acrylic = true,
    Animation = true,
    Theme = { Accent = randomAccent },
    MinimizeKey = Enum.KeyCode.B,
    icno = { work = true, IdIcon = "8598068647", Size =  80 },
})
getgenv().Devlyx = Window

local Tabs = Window:AddTab({
  Main = { Name = "localPlayer", Icon = "user" },
})

local localPlayerHumanoid = Tabs.Main:AddSection({ Name = "Humanoid", Icon = "user" })
local localPlayerLast = Tabs.Main:AddSection({ Name = "Last", Icon = "user" })

local SpeedPlayer = localPlayerHumanoid:AddInput("SpeedPlayer", {
  Title = "SpeedPlayer",
  Default = "10",
  Placeholder = "Enter the value",
  Numeric = false,
  Finished = false,
  Flag = nil,
  Callback = function(state)
    if getgenv().Ready == true then
        if state then
          playerspeed = tonumber(state)
        end
    end
  end,
})

local JumpPowerPlayer = localPlayerHumanoid:AddInput("JumpPowerPlayer", {
  Title = "JumpPlayer",
  Default = "10",
  Placeholder = "Enter the value",
  Numeric = false,
  Finished = false,
  Flag = nil,
  Callback = function(state)
    if getgenv().Ready == true then
        if state then
          playerJump = tonumber(state)
        end
    end
  end,
})

local SpeedEnable = localPlayerHumanoid:AddToggle({
  Name = "Enable Speed",
  Description = nil,
  Icon = "toggle-right",
  Default = false,
  Flag = nil,
  Callback = function(state)
    if getgenv().Ready == true then
          if state then
            n('Devlyx', 'The speed was turned on', 4)
            Hum.WalkSpeed = playerspeed
          elseif not state then
            Hum.WalkSpeed = 16
            n('Devlyx', 'The speed was turned off', 4)
          end
      end
  end,
})

local JumpEnable = localPlayerHumanoid:AddToggle({
  Name = "Enable Jump",
  Description = nil,
  Icon = "toggle-right",
  Default = false,
  Flag = nil,
  Callback = function(state)
    if getgenv().Ready == true then
          if state then
            n('Devlyx', 'The jump was turned on', 4)
            Hum.JumpPower = playerJump
          elseif not state then
            Hum.JumpPower = 50
            n('Devlyx','The jump was stopped', 4)
          end
      end
  end,
})

local NoclipEnable = localPlayerLast:AddToggle({
    Name = "Noclip",
    Description = nil,
    Icon = "toggle-right",
    Default = false,
    Flag = nil,
    Callback = function(state)
        if getgenv().Ready then
            getgenv().Noclip = state
            if state then
                noclipConnection = runs.Stepped:Connect(function()
                    if not getgenv().Noclip then if noclipConnection then noclipConnection:Disconnect() end return end
                    if Char and Char:FindFirstChild("Humanoid") then
                      for _, part in pairs(Char:GetDescendants()) do if part:IsA("BasePart") then  part.CanCollide = false end end
                    end
                end)
            else
                if noclipConnection then noclipConnection:Disconnect() end
                if Char then
                  for _, part in pairs(Char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end end
                end
            end
        end
    end,
})

local InfiniteJumpToggle = localPlayerLast:AddToggle({
    Name = "Infinite Jump",
    Description = nil,
    Icon = "toggle-right",
    Default = false,
    Flag = nil,
    Callback = function(state)
        if not getgenv().Ready then return end
        if state then
            n("Devlyx", "Infinite Jump enabled", 4)
            InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function() if Char and Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)
        else
            n("Devlyx", "Infinite Jump disabled", 4)
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
                InfiniteJumpConnection = nil
            end
        end
    end,
})

Local.CharacterAdded:Connect(function(newCharacter)
    Char = newCharacter
    Hum = Char:WaitForChild("Humanoid")
    if getgenv().Noclip then
        noclipConnection = runs.Stepped:Connect(function()
            if not getgenv().Noclip then if noclipConnection then noclipConnection:Disconnect() end return end
            if Char and Char:FindFirstChild("Humanoid") then
                for _, part in pairs(Char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end
        end)
    end
end)

getgenv().Ready = true
