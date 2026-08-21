--// RAYFIELD - SCRIPT HUB BY FTGS (AUTO KEY CONFIG)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- CẤU HÌNH KEY (ĐỔI KEY TẠI ĐÂY LÀ FILENAME TỰ ĐỔI THEO)
--------------------------------------------------
local currentKey = "21/8/2026-tjjsk" -- Key giữ nguyên như cũ
local keyUrl = "https://link4sub.com/notes/IqR0"

--------------------------------------------------
-- CẤU HÌNH BIẾN GAME
--------------------------------------------------
local skipPromptActive = false
local antiAFKActive = false
local tweenSpeed = 250
local safeZoneCFrame = CFrame.new(534.61, 70.27, -366.91, 0.051, 0, -0.999, 0, 1, 0, 0.999, 0, 0.051)
local safeZoneGui = nil

--------------------------------------------------
-- HÀM TWEEN MƯỢT
--------------------------------------------------
local function SmoothTween(targetCFrame, speed)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local startCFrame = hrp.CFrame
    local distance = (startCFrame.Position - targetCFrame.Position).Magnitude
    local duration = distance / (speed or 250)
    
    if duration <= 0 then return end

    local startTime = os.clock()
    local conn

    conn = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            conn:Disconnect()
            return
        end

        local elapsed = os.clock() - startTime
        local alpha = math.clamp(elapsed / duration, 0, 1)

        hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if alpha >= 1 then
            conn:Disconnect()
        end
    end)
end

--------------------------------------------------
-- WINDOW RAYFIELD TÍCH HỢP KEY SYSTEM
--------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "FTGS HUB",
    LoadingTitle = "LOADING SYSTEM",
    LoadingSubtitle = "by ftgs",
    ConfigurationSaving = { Enabled = false },
    KeySystem = true,
    KeySettings = {
        Title = "FTGS HUB | Key System",
        Subtitle = "Hãy lấy key để sử dụng (Reset 12h/day)",
        Note = "",
        FileName = "FTGSKey_" .. currentKey, -- Tự động gán tên File theo tên Key!
        SaveKey = true,                       -- Tự động bỏ qua bước nhập nếu đã nhập Key trước đó
        GrabKeyFromSite = false,
        Key = {currentKey},
        KeyLink = keyUrl,
        Actions = {
            {
                Text = "Get Key",
                OnPressed = function()
                    if setclipboard then
                        setclipboard(keyUrl)
                        Rayfield:Notify({
                            Title = "Get Key",
                            Content = "Đã sao chép Link lấy Key!",
                            Duration = 3
                        })
                    end
                end
            }
        }
    }
})

--------------------------------------------------
-- TAB 1: MAIN
--------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Skip Prompt (Bỏ qua nhặt ngay lập tức)",
    CurrentValue = false,
    Flag = "SkipPrompt",
    Callback = function(Value)
        skipPromptActive = Value
        if Value then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function() prompt.HoldDuration = 0 end)
                end
            end
            Rayfield:Notify({ Title = "Skip Prompt", Content = "Đã BẬT", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Skip Prompt", Content = "Đã TẮT", Duration = 2 })
        end
    end,
})

MainTab:CreateToggle({
    Name = "Anti-AFK (Khuyến khích đứng ở máy chạy bộ)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFKActive = Value
        Rayfield:Notify({ Title = "Anti-AFK", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2 })
    end,
})

--------------------------------------------------
-- TAB 2: FARM
--------------------------------------------------
local FarmTab = Window:CreateTab("Farm", 4483362458)

FarmTab:CreateSection("Tính Năng Farm")

FarmTab:CreateSlider({
    Name = "Tốc độ bay (Tween Speed)",
    Range = {50, 600},
    Increment = 10,
    Suffix = "Studs/s",
    CurrentValue = 250,
    Flag = "TweenSpeed",
    Callback = function(Value)
        tweenSpeed = Value
    end,
})

FarmTab:CreateButton({
    Name = "Safe Zone (Bay về khu vực an toàn)",
    Callback = function()
        Rayfield:Notify({ Title = "Safe Zone", Content = "Đang bay về Safe Zone...", Duration = 2 })
        task.spawn(function()
            SmoothTween(safeZoneCFrame, tweenSpeed)
        end)
    end,
})

FarmTab:CreateToggle({
    Name = "Mini Toggle (Nút bay nhanh về Safe Zone)",
    CurrentValue = false,
    Flag = "SafeZoneMiniToggle",
    Callback = function(Value)
        if Value then
            if not safeZoneGui then
                safeZoneGui = Instance.new("ScreenGui")
                safeZoneGui.Name = "SafeZoneMiniBtn"
                safeZoneGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
                safeZoneGui.ResetOnSpawn = false

                local SafeBtn = Instance.new("TextButton")
                SafeBtn.Name = "SafeBtn"
                SafeBtn.Parent = safeZoneGui
                SafeBtn.Size = UDim2.new(0, 50, 0, 50)
                SafeBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
                SafeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
                SafeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                SafeBtn.Text = "SAFE"
                SafeBtn.TextSize = 14
                SafeBtn.Font = Enum.Font.SourceSansBold
                SafeBtn.Active = true
                SafeBtn.Draggable = true

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = SafeBtn

                local UIStroke = Instance.new("UIStroke")
                UIStroke.Thickness = 2
                UIStroke.Color = Color3.fromRGB(255, 255, 255)
                UIStroke.Parent = SafeBtn

                SafeBtn.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        SmoothTween(safeZoneCFrame, tweenSpeed)
                    end)
                end)
            end
            safeZoneGui.Enabled = true
            Rayfield:Notify({ Title = "Mini Toggle", Content = "Đã BẬT nút SAFE", Duration = 2 })
        else
            if safeZoneGui then
                safeZoneGui:Destroy()
                safeZoneGui = nil
            end
            Rayfield:Notify({ Title = "Mini Toggle", Content = "Đã TẮT nút SAFE", Duration = 2 })
        end
    end,
})

--------------------------------------------------
-- TAB 3: OP
--------------------------------------------------
local OPTab = Window:CreateTab("OP", 4483362458)

OPTab:CreateButton({
    Name = "Freeze HP (0 Máu không die)",
    Callback = function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            humanoid.Health = 0

            Rayfield:Notify({
                Title = "Freeze HP",
                Content = "Đã đóng băng HP về 0 thành công!",
                Duration = 2.5
            })
        end
    end,
})

--------------------------------------------------
-- NOTIFICATION CẢM ƠN
--------------------------------------------------
Rayfield:Notify({
    Title = "FTGS HUB",
    Content = "Thank you using 🔥",
    Duration = 5
})

--------------------------------------------------
-- LOGIC PHỤ
--------------------------------------------------
Workspace.DescendantAdded:Connect(function(descendant)
    if skipPromptActive and descendant:IsA("ProximityPrompt") then
        pcall(function() descendant.HoldDuration = 0 end)
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        if antiAFKActive then
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    humanoid.MoveVector = Vector3.new(0, 0, -1)
                    task.wait(0.5)
                    humanoid.MoveVector = Vector3.new(0, 0, 0)

                    Rayfield:Notify({
                        Title = "Anti-AFK",
                        Content = "Đã Thực hiện hành động AFK",
                        Duration = 2
                    })
                end
            end)
        end
    end
end)
