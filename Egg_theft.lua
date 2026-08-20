--// STEAL AN EGG - SUPER HUB (WINDUI)

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- WINDOW CONFIG
--------------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "Steal an Egg - Super Hub",
    Icon = "egg",
    Author = "VIP Buffer",
    Folder = "StealAnEggConfig",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(900, 600),

    ToggleKey = Enum.KeyCode.LeftShift,
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 200
})

Window:EditOpenButton({
    Title = "Open Hub",
    Icon = "menu",
    CornerRadius = UDim2.new(0, 8),
    StrokeThickness = 2,
    Draggable = true,
})

--------------------------------------------------
-- TABS
--------------------------------------------------

local MainTab = Window:Tab({
    Title = "Auto Egg",
    Icon = "egg"
})

local PlayerTab = Window:Tab({
    Title = "Player & Misc",
    Icon = "user"
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
-- CHỨC NĂNG CHÍNH (AUTO EGG)
--------------------------------------------------

local autoStealActive = false
local skipPromptActive = false
local antiAFKActive = false

-- 1. Skip Hold Time (Prompt)
MainTab:Toggle({
    Title = "Skip Hold (Instant Steal)",
    Desc = "Hủy thời gian chờ đè phím E khi nhặt/cướp trứng",
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
            WindUI:Notify({ Title = "Steal an Egg", Content = v and "Đã BẬT Instant Steal" or "Đã TẮT Instant Steal", Duration = 2 })
        end
    end
})

-- 2. Auto Steal ProximityPrompts
MainTab:Toggle({
    Title = "Auto Steal Nearby Eggs",
    Desc = "Tự động nhặt trứng xung quanh vị trí nhân vật",
    Value = false,
    Callback = function(v)
        autoStealActive = v
        if WindUI.Notify then
            WindUI:Notify({ Title = "Steal an Egg", Content = v and "Đã BẬT Auto Steal" or "Đã TẮT Auto Steal", Duration = 2 })
        end
    end
})

-- 3. Anti-AFK
MainTab:Toggle({
    Title = "Anti-AFK (JoyStick)",
    Desc = "Giữ kết nối máy chủ không bị Kick AFK",
    Value = false,
    Callback = function(v)
        antiAFKActive = v
        if not v then
            Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
        end
    end
})

--------------------------------------------------
-- PLAYER & MISC TAB
--------------------------------------------------

local walkSpeedVal = 16

PlayerTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 150, Default = 16 },
    Callback = function(v)
        walkSpeedVal = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

PlayerTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

--------------------------------------------------
-- SYSTEM LOOPS
--------------------------------------------------

-- Cập nhật ProximityPrompt mới xuất hiện
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
