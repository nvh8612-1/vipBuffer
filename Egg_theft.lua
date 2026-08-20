--// RAYFIELD - SKIP PROMPT & RENDER-LOOP JOYSTICK ANTI-AFK
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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
-- ANTI AFK (RENDER LOOP FORCED DI CHUYỂN)
--------------------------------------------------

local antiAFKActive = false

MainTab:CreateToggle({
    Name = "Anti-AFK (Forced Joystick Move)",
    CurrentValue = false,
    Flag = "AntiAFKForcedMove",
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
-- LOGIC ĐÈ TÍN HIỆU DI CHUYỂN LIÊN TỤC TRÊN FRAME
--------------------------------------------------

local function ForceMoveForward(duration)
    local startTime = tick()
    local connection
    
    -- Lắng nghe mỗi khung hình để ép di chuyển, không cho Mobile Touch reset về 0
    connection = RunService.RenderStepped:Connect(function()
        if tick() - startTime >= duration then
            connection:Disconnect()
            return
        end
        
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum then
                -- Lấy hướng mặt nhân vật đang nhìn và đẩy tiến lên
                local lookVector = char.HumanoidRootPart.CFrame.LookVector
                hum:Move(lookVector, false)
            end
        end)
    end)
end

--------------------------------------------------
-- VÒNG LẶP ANTI-AFK MỖI 30 GIÂY
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(30) -- Thực hiện mỗi 30 giây
        if antiAFKActive then
            -- Ép nhân vật bước tới trong 0.5 giây trên từng khung hình
            ForceMoveForward(0.5)
        end
    end
end)
