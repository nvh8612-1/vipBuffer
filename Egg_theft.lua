--// RAYFIELD - SCRIPT HUB BY FTGS (FULL + TAB AREA & MINI TWEEN BUTTONS)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- CẤU HÌNH KEY & FILE STORAGE
--------------------------------------------------
local currentKey = "21/8/2026-tjjsk"
local keyUrl = "https://link4sub.com/notes/IqR0"
local fileName = "FTGSKey_Saved.txt"

local inputKeyText = ""
local isKeyUnlocked = false

local skipPromptActive = false
local antiAFKActive = false
local tweenSpeed = 250
local safeZoneCFrame = CFrame.new(534.61, 70.27, -366.91, 0.051, 0, -0.999, 0, 1, 0, 0.999, 0, 0.051)
local safeZoneGui = nil

-- QUẢN LÝ DỮ LIỆU TỌA ĐỘ AREA
local areaCFrames = {
    Cosmic = CFrame.new(3392.59, 70.27, -337.56, -1.000, 0.000, 0.018, 0.000, 1.000, 0.000, -0.018, 0.000, -1.000),
    Prehistoric = CFrame.new(2813.55, 70.27, -381.25, 1.000, 0.000, 0.024, -0.000, 1.000, -0.000, -0.024, 0.000, 1.000),
    Ocean = CFrame.new(2280.64, 70.27, -343.30, -1.000, 0.000, -0.009, 0.000, 1.000, 0.000, 0.009, 0.000, -1.000),
    Volcano = CFrame.new(1878.76, 70.27, -381.89, 1.000, -0.000, 0.002, 0.000, 1.000, -0.000, -0.002, 0.000, 1.000)
}

local areaGuis = {}
local hiddenAssetsFolder = nil

--------------------------------------------------
-- HÀM XỬ LÝ FILE KEY
--------------------------------------------------
local function GetSavedKey()
    if isfile and isfile(fileName) then
        return readfile(fileName)
    end
    return nil
end

local function SaveKeyToStorage(keyToSave)
    if writefile then
        writefile(fileName, keyToSave)
    end
end

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
-- HÀM TẠO NÚT MINI DỜI VỊ TRÍ TỰ ĐỘNG
--------------------------------------------------
local function CreateMiniAreaButton(areaName, targetCFrame, bgColor, posOffset)
    if areaGuis[areaName] then
        areaGuis[areaName]:Destroy()
        areaGuis[areaName] = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MiniBtn_" .. areaName
    gui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton")
    btn.Name = "Btn"
    btn.Parent = gui
    btn.Size = UDim2.new(0, 75, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0.45 + posOffset, 0)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = areaName
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.Active = true
    btn.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = btn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Rayfield:Notify({ Title = "Teleport", Content = "Đang Tween tới " .. areaName .. "...", Duration = 1.5 })
        task.spawn(function()
            SmoothTween(targetCFrame, tweenSpeed)
        end)
    end)

    areaGuis[areaName] = gui
end

local function RemoveMiniAreaButton(areaName)
    if areaGuis[areaName] then
        areaGuis[areaName]:Destroy()
        areaGuis[areaName] = nil
    end
end

--------------------------------------------------
-- WINDOW RAYFIELD
--------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "FTGS HUB",
    LoadingTitle = "LOADING SYSTEM",
    LoadingSubtitle = "by ftgs",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

--------------------------------------------------
-- HÀM TẠO CÁC TAB TÍNH NĂNG (MAIN, FARM, AREA, OP, MISC)
--------------------------------------------------
local function LoadMainTabs()
    -- TAB MAIN
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

    -- TAB FARM
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
                    SafeBtn.Position = UDim2.new(0.05, 0, 0.33, 0)
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

    -- TAB AREA (KẾ BÊN FARM)
    local AreaTab = Window:CreateTab("Area", 4483362458)
    AreaTab:CreateSection("Nút Bay Nhanh Khu Vực (Mini Toggle)")

    -- 1. Cosmic (Màu Tím)
    AreaTab:CreateToggle({
        Name = "Cosmic Mini Toggle",
        CurrentValue = false,
        Flag = "CosmicMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Cosmic", areaCFrames.Cosmic, Color3.fromRGB(138, 43, 226), 0.00)
                Rayfield:Notify({ Title = "Area", Content = "Đã BẬT Mini Btn: Cosmic", Duration = 1.5 })
            else
                RemoveMiniAreaButton("Cosmic")
                Rayfield:Notify({ Title = "Area", Content = "Đã TẮT Mini Btn: Cosmic", Duration = 1.5 })
            end
        end,
    })

    -- 2. Prehistoric (Màu Xanh Lá Hơi Đậm)
    AreaTab:CreateToggle({
        Name = "Prehistoric Mini Toggle",
        CurrentValue = false,
        Flag = "PrehistoricMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Prehistoric", areaCFrames.Prehistoric, Color3.fromRGB(34, 139, 34), 0.06)
                Rayfield:Notify({ Title = "Area", Content = "Đã BẬT Mini Btn: Prehistoric", Duration = 1.5 })
            else
                RemoveMiniAreaButton("Prehistoric")
                Rayfield:Notify({ Title = "Area", Content = "Đã TẮT Mini Btn: Prehistoric", Duration = 1.5 })
            end
        end,
    })

    -- 3. Volcano (Màu Đỏ Cam Núi Lửa)
    AreaTab:CreateToggle({
        Name = "Volcano Mini Toggle",
        CurrentValue = false,
        Flag = "VolcanoMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Volcano", areaCFrames.Volcano, Color3.fromRGB(225, 68, 0), 0.12)
                Rayfield:Notify({ Title = "Area", Content = "Đã BẬT Mini Btn: Volcano", Duration = 1.5 })
            else
                RemoveMiniAreaButton("Volcano")
                Rayfield:Notify({ Title = "Area", Content = "Đã TẮT Mini Btn: Volcano", Duration = 1.5 })
            end
        end,
    })

    -- 4. Ocean (Màu Đại Dương)
    AreaTab:CreateToggle({
        Name = "Ocean Mini Toggle",
        CurrentValue = false,
        Flag = "OceanMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Ocean", areaCFrames.Ocean, Color3.fromRGB(0, 119, 182), 0.18)
                Rayfield:Notify({ Title = "Area", Content = "Đã BẬT Mini Btn: Ocean", Duration = 1.5 })
            else
                RemoveMiniAreaButton("Ocean")
                Rayfield:Notify({ Title = "Area", Content = "Đã TẮT Mini Btn: Ocean", Duration = 1.5 })
            end
        end,
    })

    -- TAB OP
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

    -- TAB MISC
    local MiscTab = Window:CreateTab("Misc", 4483362458)
    MiscTab:CreateSection("Tính Năng Khác")

    MiscTab:CreateToggle({
        Name = "Anti-AFK (Khuyến khích đứng ở máy chạy bộ)",
        CurrentValue = false,
        Flag = "AntiAFK",
        Callback = function(Value)
            antiAFKActive = Value
            Rayfield:Notify({ Title = "Anti-AFK", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2 })
        end,
    })

    MiscTab:CreateToggle({
        Name = "Ẩn Toàn bộ Pet",
        CurrentValue = false,
        Flag = "HideAllPets",
        Callback = function(Value)
            if Value then
                local assets = Workspace:FindFirstChild("ClientRenderedAssets")
                if assets then
                    hiddenAssetsFolder = assets
                    hiddenAssetsFolder.Parent = nil
                    Rayfield:Notify({ Title = "Misc", Content = "Đã ẨN Toàn bộ Pet", Duration = 2 })
                else
                    Rayfield:Notify({ Title = "Lỗi", Content = "Không tìm thấy ClientRenderedAssets!", Duration = 2.5 })
                end
            else
                if hiddenAssetsFolder then
                    hiddenAssetsFolder.Parent = Workspace
                    hiddenAssetsFolder = nil
                    Rayfield:Notify({ Title = "Misc", Content = "Đã HIỆN LẠI Toàn bộ Pet", Duration = 2 })
                end
            end
        end,
    })
end

--------------------------------------------------
-- HÀM TẠO TAB KEY
--------------------------------------------------
local function LoadKeyTab()
    local KeyTab = Window:CreateTab("Key", 4483362458)

    KeyTab:CreateSection("Hệ Thống Xác Thực Key")

    KeyTab:CreateInput({
        Name = "Nhập Key tại đây",
        PlaceholderText = "Dán mã Key của bạn vào đây...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            inputKeyText = Text
        end,
    })

    local CheckKeyButton
    CheckKeyButton = KeyTab:CreateButton({
        Name = "Check Key",
        Callback = function()
            if isKeyUnlocked then
                Rayfield:Notify({ Title = "Key System", Content = "Key đã được kích hoạt!", Duration = 2 })
                return
            end

            if inputKeyText == currentKey then
                isKeyUnlocked = true
                SaveKeyToStorage(currentKey)
                
                Rayfield:Notify({
                    Title = "Thành Công!",
                    Content = "Key chính xác 🎉 Đã lưu Key!",
                    Duration = 3
                })

                CheckKeyButton:Set("Đã Xác Thực (Đã Lưu Key)")
                LoadMainTabs()
            else
                Rayfield:Notify({
                    Title = "Thất Bại!",
                    Content = "Key không chính xác, vui lòng thử lại!",
                    Duration = 2.5
                })
            end
        end,
    })

    KeyTab:CreateButton({
        Name = "Get Key (Copy Link)",
        Callback = function()
            if setclipboard then
                setclipboard(keyUrl)
                Rayfield:Notify({
                    Title = "Get Key",
                    Content = "Đã sao chép Link lấy Key!",
                    Duration = 3
                })
            end
        end,
    })
end

--------------------------------------------------
-- LOGIC TRACK KEY ĐẾM NGƯỢC (HIỆN 900MS -> NGHỈ 200MS)
--------------------------------------------------
task.spawn(function()
    local savedKey = GetSavedKey()

    if savedKey then
        Rayfield:Notify({ Title = "System", Content = "Đang Track Key 3..", Duration = 0.9 })
        task.wait(1.1)

        Rayfield:Notify({ Title = "System", Content = "Đang Track Key 2..", Duration = 0.9 })
        task.wait(1.1)

        Rayfield:Notify({ Title = "System", Content = "Đang Track Key 1..", Duration = 0.9 })
        task.wait(1.1)

        if savedKey == currentKey then
            isKeyUnlocked = true
            Rayfield:Notify({ Title = "System", Content = "Key Hợp Lệ 🎉", Duration = 3.0 })
            LoadMainTabs()
        else
            Rayfield:Notify({ Title = "System", Content = "Key Đã Cập Nhật Hãy Get Key Mới 💫", Duration = 2.5 })
            LoadKeyTab()
        end
    else
        LoadKeyTab()
    end
end)

--------------------------------------------------
-- LOGIC PHỤ (PROXIMITY PROMPT & ANTI-AFK)
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
                    Rayfield:Notify({ Title = "Anti-AFK", Content = "Đã Thực hiện hành động AFK", Duration = 2 })
                end
            end)
        end
    end
end)
