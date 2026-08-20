--// RAYFIELD UI - ONLY SKIP PROMPT & ANTI-AFK

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- WINDOW CREATION
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
-- TAB MAIN
--------------------------------------------------

local MainTab = Window:CreateTab("Main Features", 4483362458) -- Icon Home

--------------------------------------------------
-- TOGGLES
--------------------------------------------------

local skipPromptActive = false
local antiAFKActive = false

-- 1. Skip Prompt Toggle
MainTab:CreateToggle({
   Name = "Skip Prompt (Instant Hold)",
   CurrentValue = false,
   Flag = "SkipPromptFlag",
   Callback = function(Value)
      skipPromptActive = Value
      if Value then
         for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
               prompt.HoldDuration = 0
            end
         end
      end
   end,
})

-- 2. Anti-AFK Toggle
MainTab:CreateToggle({
   Name = "Anti-AFK (Roblox Joystick)",
   CurrentValue = false,
   Flag = "AntiAFKFlag",
   Callback = function(Value)
      antiAFKActive = Value
   end,
})

--------------------------------------------------
-- SYSTEM LOOPS
--------------------------------------------------

-- Tự động chuyển HoldDuration = 0 khi có ProximityPrompt mới xuất hiện
Workspace.DescendantAdded:Connect(function(descendant)
   if skipPromptActive and descendant:IsA("ProximityPrompt") then
      descendant.HoldDuration = 0
   end
end)

-- Vòng lặp Anti-AFK (Kéo Joystick Roblox Mobile / Tự di chuyển trên PC)
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
               -- Mô phỏng vuốt Joystick cảm ứng Roblox Mobile
               local center = dynamicThumbstick.AbsolutePosition + (dynamicThumbstick.AbsoluteSize / 2)
               local dragTarget = center - Vector2.new(0, 40)

               VirtualInputManager:SendTouchEvent(0, 0, center.X, center.Y)
               task.wait(0.05)
               VirtualInputManager:SendTouchEvent(0, 1, dragTarget.X, dragTarget.Y)
               task.wait(0.4)
               VirtualInputManager:SendTouchEvent(0, 2, dragTarget.X, dragTarget.Y)
            else
               -- Mô phỏng phím di chuyển dành cho PC
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
