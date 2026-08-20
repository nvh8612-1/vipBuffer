--// RAYFIELD - SKIP PROMPT & DIRECT MOVE ANTI-AFK
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
-- ANTI AFK (TỰ DI CHUYỂN TIẾN LÊN)
--------------------------------------------------

local antiAFKActive = false

MainTab:CreateToggle({
    Name = "Anti-AFK (Auto Move Forward)",
    CurrentValue = false,
    Flag = "AutoMoveAFK",
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
-- VÒNG LẶP ÉP DI CHUYỂN TIẾN LÊN (CỨ 30S)
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(30) -- Thực hiện mỗi 30 giây
        if antiAFKActive then
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if humanoid and rootPart then
                        -- Tự tạo lực di chuyển hướng về phía trước của nhân vật trong 0.3 giây
                        local moveDirection = rootPart.CFrame.LookVector
                        
                        local startTime = tick()
                        while tick() - startTime < 0.3 do
                            humanoid:Move(moveDirection, false)
                            task.wait()
                        end
                        
                        -- Dừng di chuyển
                        humanoid:Move(Vector3.new(0, 0, 0), false)
                    end
                end
            end)
        end
    end
end)
