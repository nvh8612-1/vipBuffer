--// WINDUI FULL HUB (STEAL AN EGG)

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- WINDOW
--------------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "Steal an Egg - Super Hub",
    Icon = "egg",
    Author = "ftgs",
    Folder = "MySuperHub",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(900, 600),

    ToggleKey = Enum.KeyCode.LeftShift,
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 200
})

--------------------------------------------------
-- TABS
--------------------------------------------------

local Main = Window:Tab({
    Title = "Main",
    Icon = "home"
})

local Player = Window:Tab({
    Title = "Player",
    Icon = "user"
})

local Misc = Window:Tab({
    Title = "Misc",
    Icon = "settings"
})

local Spotify = Window:Tab({
    Title = "Spotify",
    Icon = "music"
})

--------------------------------------------------
-- JOYSTICK ẢO (ANTI-AFK)
--------------------------------------------------

local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("EggAFKJoystick") then
	parentGui.EggAFKJoystick:Destroy()
end

local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "EggAFKJoystick"
JoyGui.ResetOnSpawn = false
JoyGui.DisplayOrder = 999999
JoyGui.Parent = parentGui

local BaseJoystick = Instance.new("Frame")
BaseJoystick.Size = UDim2.new(0, 65, 0, 65)
BaseJoystick.Position = UDim2.new(0.08, 0, 0.68, 0)
BaseJoystick.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BaseJoystick.BackgroundTransparency = 0.5
BaseJoystick.Active = false
BaseJoystick.Parent = JoyGui

local BaseCorner = Instance.new("UICorner")
BaseCorner.CornerRadius = UDim2.new(1, 0)
BaseCorner.Parent = BaseJoystick

local Stick = Instance.new("Frame")
Stick.Size = UDim2.new(0, 26, 0, 26)
Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
Stick.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Stick.BackgroundTransparency = 0.2
Stick.Active = false
Stick.Parent = BaseJoystick

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim2.new(1, 0)
StickCorner.Parent = Stick

--------------------------------------------------
-- MAIN : STEAL EGG & ANTI-AFK
--------------------------------------------------

local autoStealActive = false
local skipPromptActive = false
local antiAFKActive = false

Main:Toggle({
    Title = "Instant Steal (Skip Hold)",
    Value = false,
    Callback = function(v)
        skipPromptActive = v
        if v then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
        end

        if WindUI.Notify then
            WindUI:Notify({
                Title = "Main",
                Content = v and "Instant Steal Enabled" or "Instant Steal Disabled",
                Duration = 2
            })
        end
    end
})

Main:Toggle({
    Title = "Auto Steal Nearby Eggs",
    Value = false,
    Callback = function(v)
        autoStealActive = v

        if WindUI.Notify then
            WindUI:Notify({
                Title = "Main",
                Content = v and "Auto Steal Enabled" or "Auto Steal Disabled",
                Duration = 2
            })
        end
    end
})

Main:Toggle({
    Title = "Anti-AFK (JoyStick)",
    Value = false,
    Callback = function(v)
        antiAFKActive = v
        if not v then
            Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
        end

        if WindUI.Notify then
            WindUI:Notify({
                Title = "Main",
                Content = v and "Anti-AFK Enabled" or "Anti-AFK Disabled",
                Duration = 2
            })
        end
    end
})

--------------------------------------------------
-- PLAYER : SPEED SLIDER
--------------------------------------------------

local targetSpeed = 16
local currentSpeed = 16

Player:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 120,
        Default = 16
    },
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
-- MISC : FPS + REJOIN
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

Misc:Button({
    Title = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

--------------------------------------------------
-- SPOTIFY : LOCAL MUSIC
--------------------------------------------------

local SoundService = game:GetService("SoundService")

local Music = Instance.new("Sound")
Music.Name = "SpotifyHubMusic"
Music.Parent = SoundService
Music.Looped = true
Music.Volume = 0.5

local MusicEnabled = false

Spotify:Toggle({
    Title = "Music",
    Value = false,
    Callback = function(v)
        MusicEnabled = v
        if not v then
            Music:Stop()
        end
    end
})

local function AddSong(name, id)
    Spotify:Button({
        Title = name,
        Callback = function()
            if not MusicEnabled then return end
            Music:Stop()
            Music.SoundId = "rbxassetid://" .. tostring(id)
            Music:Play()

            if WindUI.Notify then
                WindUI:Notify({
                    Title = "Spotify",
                    Content = "Playing: " .. name,
                    Duration = 2
                })
            end
        end
    })
end

AddSong("Quên Đi Câu Chuyện Khô Gà", 99152674992699)
AddSong("Đừng Đóng Vai Anh", 133758365650956)
AddSong("DreamCore 核", 82149511707056)

Spotify:Slider({
    Title = "Volume",
    Step = 1,
    Value = { Min = 0, Max = 10, Default = 5 },
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

-- Vòng lặp Auto Steal Egg
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

-- Vòng lặp Anti-AFK
task.spawn(function()
    while true do
        task.wait(40)
        if antiAFKActive then
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                Stick:TweenPosition(UDim2.new(0.5, -13, 0.05, -13), "Out", "Quad", 0.2, true)
                if humanoid then humanoid:Move(Vector3.new(0, 0, -1), true) end
                
                task.wait(0.5)

                Stick:TweenPosition(UDim2.new(0.5, -13, 0.5, -13), "Out", "Quad", 0.2, true)
                if humanoid then humanoid:Move(Vector3.new(0, 0, 0), true) end
            end)
        end
    end
end)
