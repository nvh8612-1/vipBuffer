--// RAYFIELD - BYPASS ANTI-AFK (CONTROL MODULE METHOD)
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
-- ANTI AFK (CONTROL MODULE BYPASS)
--------------------------------------------------

local antiAFKActive = false

MainTab:CreateToggle({
    Name = "Anti-AFK (Bypass Anti-Cheat)",
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
    if not skipPromptActive then return end

    if descendant:IsA("ProximityPrompt") then
        pcall(function()
            descendant.HoldDuration = 0
        end)
    end
end)

--------------------------------------------------
-- VÒNG LẶP ANTI-AFK QUA CONTROL MODULE
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(30) -- Chạy mỗi 30 giây
        if antiAFKActive then
            pcall(function()
                -- Lấy Module điều khiển di chuyển gốc của Roblox
                local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
                local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
                local Controls = PlayerModule:GetControls()

                -- Mô phỏng đẩy Joystick về phía trước (Hướng Vector: X=0, Y=1)
                Controls:OnDirectionsChanged(Vector2.new(0, 1), false)
                task.wait(0.3)
                
                -- Trả Joystick về vị trí trung tâm (Dừng di chuyển)
                Controls:OnDirectionsChanged(Vector2.new(0, 0), false)
            end)
        end
    end
end)
