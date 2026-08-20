--// RAYFIELD - SKIP PROMPT & DRAGGABLE JOYSTICK ZONE ANTI-AFK
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- WINDOW
--------------------------------------------------

local Window = Rayfield:CreateWindow({
    Name = "Super Hub",
    LoadingTitle = "VIP Buffer Hub",
    LoadingSubtitle = "by ftgs",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

--------------------------------------------------
-- TAB
--------------------------------------------------

local MainTab = Window:CreateTab("Main Features", 4483362458)

--------------------------------------------------
-- Ô DI CHUYỂN TÙY CHỈNH (JOYSTICK TARGET ZONE)
--------------------------------------------------

local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("JoystickZoneGui") then
    parentGui.JoystickZoneGui:Destroy()
end

local ZoneGui = Instance.new("ScreenGui")
ZoneGui.Name = "JoystickZoneGui"
ZoneGui.ResetOnSpawn = false
ZoneGui.Parent = parentGui

-- Khung hiển thị vị trí kéo (Có thể kéo thả)
local DragFrame = Instance.new("Frame")
DragFrame.Size = UDim2.new(0, 80, 0, 80)
DragFrame.Position = UDim2.new(0.1, 0, 0.6, 0) -- Vị trí mặc định góc dưới trái
DragFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
DragFrame.BackgroundTransparency = 0.5
DragFrame.BorderSizePixel = 2
DragFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
DragFrame.Active = true
DragFrame.Draggable = true
DragFrame.Visible = false -- Ẩn mặc định
DragFrame.Parent = ZoneGui

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "Kéo vào Joystick"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 12
Label.Font = Enum.Font.SourceSansBold
Label.Parent = DragFrame

--------------------------------------------------
-- SKIP PROMPT
--------------------------------------------------

local skipPromptActive = false

MainTab:CreateToggle({
    Name = "Skip Prompt",
    CurrentValue = false,
    Flag = "SkipPrompt",
    Callback = function(Value)
        skipPromptActive = Value

        if Value then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.HoldDuration = 0
                    end)
                end
            end

            Rayfield:Notify({
                Title = "Skip Prompt",
                Content = "Skip Prompt: ON",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Skip Prompt",
                Content = "Skip Prompt: OFF",
                Duration = 2
            })
        end
    end
})

--------------------------------------------------
-- ANTI AFK (KÉO Ô TÙY CHỈNH)
--------------------------------------------------

local antiAFKActive = false

MainTab:CreateToggle({
    Name = "Anti-AFK (Custom Drag Zone)",
    CurrentValue = false,
    Flag = "AntiAFKZone",
    Callback = function(Value)
        antiAFKActive = Value
        DragFrame.Visible = Value -- Hiện ô màu xanh khi Bật, Ẩn khi Tắt

        Rayfield:Notify({
            Title = "Anti-AFK",
            Content = Value and "Anti-AFK Zone: ON (Đặt ô vào Joystick)" or "Anti-AFK Zone: OFF",
            Duration = 3
        })
    end
})

--------------------------------------------------
-- PROMPT MỚI
--------------------------------------------------

Workspace.DescendantAdded:Connect(function(descendant)
    if not skipPromptActive then return end

    if descendant:IsA("ProximityPrompt") then
        pcall(function()
            descendant.HoldDuration = 0
        end)
    end
end)

--------------------------------------------------
-- VÒNG LẶP VUỐT TỪ VỊ TRÍ Ô KÉO
--------------------------------------------------

task.spawn(function()
    local touchId = 2002

    while true do
        task.wait(30) -- Thực hiện mỗi 30 giây
        if antiAFKActive and DragFrame.Visible then
            pcall(function()
                -- Lấy vị trí tâm của Ô vuông tùy chỉnh
                local center = DragFrame.AbsolutePosition + (DragFrame.AbsoluteSize / 2)
                -- Điểm kéo vuốt thẳng lên phía trước (Y giảm 50 pixel)
                local target = Vector2.new(center.X, center.Y - 50)

                -- Mô phỏng thao tác vuốt từ tâm ô lên trên
                VirtualInputManager:SendTouchEvent(touchId, 0, center.X, center.Y)
                task.wait(0.05)
                VirtualInputManager:SendTouchEvent(touchId, 1, target.X, target.Y)
                task.wait(0.3)
                VirtualInputManager:SendTouchEvent(touchId, 2, target.X, target.Y)
            end)
        end
    end
end)
