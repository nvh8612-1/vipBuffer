--// RAYFIELD - SKIP PROMPT & ANTI-AFK
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

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
            -- Áp dụng cho các Prompt đang tồn tại
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
-- ANTI AFK (JOYSTICK)
--------------------------------------------------

local antiAFKActive = false

MainTab:CreateToggle({
    Name = "Anti-AFK (Virtual Joystick)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFKActive = Value

        Rayfield:Notify({
            Title = "Anti-AFK",
            Content = Value and "Anti-AFK: ON" or "Anti-AFK: OFF",
            Duration = 2
        })
    end
})

--------------------------------------------------
-- PROMPT MỚI
--------------------------------------------------

Workspace.DescendantAdded:Connect(function(descendant)

    if not skipPromptActive then
        return
    end

    if descendant:IsA("ProximityPrompt") then
        pcall(function()
            descendant.HoldDuration = 0
        end)
    end
end)

--------------------------------------------------
-- VÒNG LẶP ANTI-AFK JOYSTICK
--------------------------------------------------

task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")

    while true do
        task.wait(30) -- Thực hiện vuốt Joystick mỗi 30 giây
        if antiAFKActive then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
                local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
                local dynamicThumbstick = touchFrame and (touchFrame:FindFirstChild("DynamicThumbstickFrame") or touchFrame:FindFirstChild("ThumbstickFrame"))

                if dynamicThumbstick and dynamicThumbstick.AbsoluteSize.X > 0 then
                    -- Vuốt nút Joystick ảo trên Mobile/Cảm ứng về phía trước
                    local center = dynamicThumbstick.AbsolutePosition + (dynamicThumbstick.AbsoluteSize / 2)
                    local dragTarget = center - Vector2.new(0, 50) -- Kéo lên trên (tiến về trước)

                    VirtualInputManager:SendTouchEvent(0, 0, center.X, center.Y)
                    task.wait(0.05)
                    VirtualInputManager:SendTouchEvent(0, 1, dragTarget.X, dragTarget.Y)
                    task.wait(0.3)
                    VirtualInputManager:SendTouchEvent(0, 2, dragTarget.X, dragTarget.Y)
                else
                    -- Dự phòng cho PC / Thiết bị không hiện Joystick
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
