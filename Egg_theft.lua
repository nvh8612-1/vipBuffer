--// WINDUI FULL HUB (ANTI-AFK & SKIP PROMPT)

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- WINDOW
--------------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "VIP Buffer Hub",
    Icon = "zap",
    Author = "VIP Buffer",
    Folder = "VIPBufferConfig",

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
    Title = "Main Features",
    Icon = "home"
})

--------------------------------------------------
-- JOYSTICK ẢO TRÊN MÀN HÌNH (CHO ANTI-AFK)
--------------------------------------------------

local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("WindAFKJoystick") then
	parentGui.WindAFKJoystick:Destroy()
end

local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "WindAFKJoystick"
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
-- MAIN TOGGLES
--------------------------------------------------

local antiAFKActive = false
local skipPromptActive = false

-- 1. Anti-AFK Toggle
Main:Toggle({
    Title = "Anti-AFK (JoyStick)",
    Desc = "Tự động trượt nhẹ lên phía trước để tránh bị Kick AFK",
    Value = false,

    Callback = function(v)
        antiAFKActive = v
        if not v then
            Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
        end

        if WindUI.Notify then
            WindUI:Notify({
                Title = "Anti-AFK",
                Content = v and "Đã BẬT Anti-AFK" or "Đã TẮT Anti-AFK",
                Duration = 2
            })
        end
    end
})

-- 2. Skip Prompt Toggle
Main:Toggle({
    Title = "Skip Prompt",
    Desc = "Xóa thời gian giữ phím tương tác (ProximityPrompt)",
    Value = false,

    Callback = function(v)
        skipPromptActive = v

        if v then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
        end

        if WindUI.Notify then
            WindUI:Notify({
                Title = "Skip Prompt",
                Content = v and "Đã BẬT Skip Prompt" or "Đã TẮT Skip Prompt",
                Duration = 2
            })
        end
    end
})

--------------------------------------------------
-- LOGIC TÍNH NĂNG
--------------------------------------------------

-- Tự áp dụng HoldDuration = 0 khi vật thể mới xuất hiện
workspace.DescendantAdded:Connect(function(descendant)
    if skipPromptActive and descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
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

                -- Kéo nhẹ Joystick ảo tiến lên
                Stick:TweenPosition(UDim2.new(0.5, -13, 0.05, -13), "Out", "Quad", 0.2, true)
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, -1), true)
                end
                
                task.wait(0.5)

                -- Buông Joystick về chỗ cũ
                Stick:TweenPosition(UDim2.new(0.5, -13, 0.5, -13), "Out", "Quad", 0.2, true)
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, 0), true)
                end
            end)
        end
    end
end)
