--// FLUENT UI FULL HUB (STEAL AN EGG - REAL JOYSTICK ANTI-AFK)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- WINDOW CREATION
--------------------------------------------------

local Window = Fluent:CreateWindow({
    Title = "Steal an Egg - Super Hub",
    SubTitle = "by ftgs",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftShift
})

--------------------------------------------------
-- TABS
--------------------------------------------------

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Spotify = Window:AddTab({ Title = "Spotify", Icon = "music" })
}

--------------------------------------------------
-- MAIN TAB : TOGGLES
--------------------------------------------------

local skipPromptActive = false
local autoStealActive = false
local antiAFKActive = false

local SkipToggle = Tabs.Main:AddToggle("SkipHoldToggle", {
    Title = "Instant Steal (Skip Hold)",
    Default = false
})

SkipToggle:OnChanged(function(v)
    skipPromptActive = v
    if v then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
    end
    Fluent:Notify({
        Title = "Main",
        Content = v and "Instant Steal Enabled" or "Instant Steal Disabled",
        Duration = 2
    })
end)

local AutoStealToggle = Tabs.Main:AddToggle("AutoStealToggle", {
    Title = "Auto Steal Nearby Eggs",
    Default = false
})

AutoStealToggle:OnChanged(function(v)
    autoStealActive = v
    Fluent:Notify({
        Title = "Main",
        Content = v and "Auto Steal Enabled" or "Auto Steal Disabled",
        Duration = 2
    })
end)

local AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK (Roblox Joystick)",
    Default = false
})

AntiAFKToggle:OnChanged(function(v)
    antiAFKActive = v
    Fluent:Notify({
        Title = "Main",
        Content = v and "Anti-AFK Enabled" or "Anti-AFK Disabled",
        Duration = 2
    })
end)

--------------------------------------------------
-- PLAYER TAB : SPEED SLIDER
--------------------------------------------------

local targetSpeed = 16
local currentSpeed = 16

local SpeedSlider = Tabs.Player:AddSlider("SpeedSlider", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 120,
    Default = 16,
    Rounding = 0,
    Callback = function(v)
        targetSpeed = v
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        currentSpeed += (targetSpeed - currentSpeed) * 0.15
        hum.WalkSpeed = currentSpeed
    end
end)

--------------------------------------------------
-- MISC TAB : FPS & REJOIN
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "FPSCounter"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.Position = UDim2.new(0, 5, 0, 5)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = gui

local frames = 0
local last = tick()

game:GetService("RunService").RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        last = tick()
    end
end)

Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

--------------------------------------------------
-- SPOTIFY TAB : MUSIC
--------------------------------------------------

local SoundService = game:GetService("SoundService")

local Music = Instance.new("Sound")
Music.Name = "SpotifyHubMusic"
Music.Parent = SoundService
Music.Looped = true
Music.Volume = 0.5

local MusicEnabled = false

local MusicToggle = Tabs.Spotify:AddToggle("MusicToggle", {
    Title = "Enable Music",
    Default = false
})

MusicToggle:OnChanged(function(v)
    MusicEnabled = v
    if not v then
        Music:Stop()
    end
end)

local function AddSong(name, id)
    Tabs.Spotify:AddButton({
        Title = name,
        Callback = function()
            if not MusicEnabled then return end
            Music:Stop()
            Music.SoundId = "rbxassetid://" .. tostring(id)
            Music:Play()
            Fluent:Notify({
                Title = "Spotify",
                Content = "Playing: " .. name,
                Duration = 2
            })
        end
    })
end

AddSong("Quên Đi Câu Chuyện Khô Gà", 99152674992699)
AddSong("Đừng Đóng Vai Anh", 133758365650956)
AddSong("DreamCore 核", 82149511707056)

Tabs.Spotify:AddSlider("VolumeSlider", {
    Title = "Volume",
    Min = 0,
    Max = 10,
    Default = 5,
    Rounding = 0,
    Callback = function(v)
        Music.Volume = v / 10
    end
})

--------------------------------------------------
-- SYSTEM LOOPS
--------------------------------------------------

Workspace.DescendantAdded:Connect(function(descendant)
    if skipPromptActive and descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

-- Loop Auto Steal Egg
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoStealActive then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local parentPart = prompt.Parent
                            if parentPart and parentPart:IsA("BasePart") then
                                local dist = (root.Position - parentPart.Position).Magnitude
                                if dist <= prompt.MaxActivationDistance then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop Anti-AFK (Kéo Joystick thật của Roblox)
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    while true do
        task.wait(35)
        if antiAFKActive then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
                local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
                local dynamicThumbstick = touchFrame and (touchFrame:FindFirstChild("DynamicThumbstickFrame") or touchFrame:FindFirstChild("ThumbstickFrame"))

                if dynamicThumbstick and dynamicThumbstick.AbsoluteSize.X > 0 then
                    -- Mô phỏng kéo Joystick ảo của Roblox Mobile
                    local center = dynamicThumbstick.AbsolutePosition + (dynamicThumbstick.AbsoluteSize / 2)
                    local dragTarget = center - Vector2.new(0, 40)

                    VirtualInputManager:SendTouchEvent(0, 0, center.X, center.Y)
                    task.wait(0.05)
                    VirtualInputManager:SendTouchEvent(0, 1, dragTarget.X, dragTarget.Y)
                    task.wait(0.4)
                    VirtualInputManager:SendTouchEvent(0, 2, dragTarget.X, dragTarget.Y)
                else
                    -- Fallback dành cho PC / Device không xài Touch Controls
                    local char = LocalPlayer.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:Move(Vector3.new(0, 0, -1), true)
                        task.wait(0.5)
                        humanoid:Move(Vector3.new(0, 0, 0), true)
                    end
                end
            end)
        end
    end
end)

Window:SelectTab(1)
