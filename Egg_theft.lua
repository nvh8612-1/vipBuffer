getgenv().FTGS_HUB_LOADED = nil
getgenv().FTGS_HUB_LOADED = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- CẤU HÌNH KEY & TẢI LOGIC
--------------------------------------------------
local KEY_OLD_LOGIC = "key-fix-tjjskl" -- Bản cũ: Bay thẳng
local KEY_NEW_LOGIC = "test-1"          -- Bản mới: Teleport theo Waypoint
local keyUrl = "https://link4sub.com/notes/cLCN"
local fileName = "FTGSKey_Saved.txt"

local activeLogicMode = nil -- "OLD" hoặc "NEW"
local inputKeyText = ""
local isKeyUnlocked = false

local skipPromptActive = false
local autoZoneActive = false
local antiAFKActive = false
local isInteractingPrompt = false

local tweenSpeed = 120
local chunkSize = 3

-- DỮ LIỆU TỌA ĐỘ BẢN CŨ (Bay thẳng)
local oldSafeZoneCFrame = CFrame.new(519.01, 70.27, -362.74)
local oldAreaCFrames = {
    Volcano = CFrame.new(1879.73, 70.27, -384.79),
    Ocean = CFrame.new(2288.07, 70.27, -345.39),
    Prehistoric = CFrame.new(2809.94, 70.27, -369.17),
    Cosmic = CFrame.new(3393.60, 70.27, -342.13),
    ["Cherry Blossom"] = CFrame.new(4025.85, 70.27, -378.81)
}

-- DỮ LIỆU WAYPOINTS BẢN MỚI
local waypoints = {
    [0]  = CFrame.new(536.83, 70.27, -364.87),
    [1]  = CFrame.new(569.26, 70.27, -361.94),
    [2]  = CFrame.new(611.89, 70.27, -358.83),
    [3]  = CFrame.new(649.32, 70.27, -356.99),
    [4]  = CFrame.new(693.84, 70.27, -354.80),
    [5]  = CFrame.new(752.83, 70.27, -356.79),
    [6]  = CFrame.new(791.41, 70.27, -359.95),
    [7]  = CFrame.new(833.30, 70.27, -356.90),
    [8]  = CFrame.new(864.51, 70.27, -362.49),
    [9]  = CFrame.new(936.46, 70.27, -353.53),
    [10] = CFrame.new(1005.90, 70.27, -352.01),
    [11] = CFrame.new(1032.72, 70.27, -359.86),
    [12] = CFrame.new(1102.30, 70.27, -358.66),
    [13] = CFrame.new(1176.73, 70.27, -358.06),
    [14] = CFrame.new(1245.15, 70.27, -359.76),
    [15] = CFrame.new(1290.05, 70.27, -363.28),
    [16] = CFrame.new(1354.54, 70.27, -363.67),
    [17] = CFrame.new(1444.64, 70.27, -363.69),
    [18] = CFrame.new(1543.50, 70.27, -364.79),
    [19] = CFrame.new(1601.66, 70.27, -363.93),
    [20] = CFrame.new(1661.70, 70.27, -356.25),
    [21] = CFrame.new(1728.34, 70.27, -353.12),
    [22] = CFrame.new(1803.55, 70.27, -355.61),
    [23] = CFrame.new(1907.31, 70.27, -357.09),
    [24] = CFrame.new(1966.49, 70.27, -356.37),
    [25] = CFrame.new(2033.94, 70.27, -359.50),
    [26] = CFrame.new(2132.99, 70.27, -357.18),
    [27] = CFrame.new(2217.25, 70.27, -356.72),
    [28] = CFrame.new(2322.15, 70.27, -351.91),
    [29] = CFrame.new(2387.37, 70.27, -361.21),
    [30] = CFrame.new(2460.88, 70.27, -358.36),
    [31] = CFrame.new(2525.06, 70.27, -359.24),
    [32] = CFrame.new(2578.51, 70.27, -358.98),
    [33] = CFrame.new(2679.42, 70.27, -367.14),
    [34] = CFrame.new(2771.02, 70.27, -366.29),
    [35] = CFrame.new(2868.75, 70.27, -365.80),
    [36] = CFrame.new(2955.53, 70.27, -366.25),
    [37] = CFrame.new(3023.96, 70.27, -364.56),
    [38] = CFrame.new(3143.82, 70.27, -366.19),
    [39] = CFrame.new(3240.29, 70.27, -365.25),
    [40] = CFrame.new(3331.90, 70.27, -364.96),
    [41] = CFrame.new(3472.10, 70.27, -352.43),
    [42] = CFrame.new(3530.58, 70.27, -359.51),
    [43] = CFrame.new(3594.67, 70.27, -363.98),
    [44] = CFrame.new(3657.86, 70.27, -362.45),
    [45] = CFrame.new(3741.10, 70.27, -358.54),
    [46] = CFrame.new(3834.00, 70.27, -359.13),
    [47] = CFrame.new(3964.82, 70.27, -358.81),
    [48] = CFrame.new(4085.16, 70.27, -362.97)
}

local newAreaCFrames = {
    Volcano = waypoints[23],
    Ocean = waypoints[27],
    Prehistoric = waypoints[35],
    Cosmic = waypoints[40],
    ["Cherry Blossom"] = waypoints[48]
}

local areaGuis = {}
local safeZoneGui = nil
local hiddenAssetsFolder = nil

--------------------------------------------------
-- HÀM LƯU / ĐỌC FILE KEY
--------------------------------------------------
local function GetSavedKey()
    if isfile and isfile(fileName) then return readfile(fileName) end
    return nil
end

local function SaveKeyToStorage(keyToSave)
    if writefile then writefile(fileName, keyToSave) end
end

--------------------------------------------------
-- HÀM HOP SERVER
--------------------------------------------------
local isTeleporting = false
local function QueueScriptForTeleport()
    if isTeleporting then return end
    isTeleporting = true
    local teleportScript = [[
        if not getgenv().FTGS_HUB_LOADED then
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/nvh8612-1/vipBuffer/refs/heads/main/Egg_theft.lua"))()
        end
    ]]
    local queueFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if queueFunc then queueFunc(teleportScript) end
end

--------------------------------------------------
-- HÀM TWEEN MẶT ĐẤT PHÂN ĐOẠN
--------------------------------------------------
local tweeningThread = nil
local function SmoothTween(targetCFrame, speed)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    if tweeningThread then
        task.cancel(tweeningThread)
        tweeningThread = nil
    end

    tweeningThread = task.spawn(function()
        local moveSpeed = speed or tweenSpeed
        local startPos = hrp.Position
        local endPos = targetCFrame.Position
        local totalDistance = (endPos - startPos).Magnitude

        if totalDistance < 1 then
            hrp.CFrame = targetCFrame
            tweeningThread = nil
            return
        end

        local parts = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(parts, {part = part, canCollide = part.CanCollide})
                part.CanCollide = false
            end
        end

        local numSteps = math.max(1, math.floor(totalDistance / chunkSize))
        local direction = (endPos - startPos).Unit
        local currentRotation = hrp.CFrame - hrp.CFrame.Position

        for i = 1, numSteps do
            if not LocalPlayer.Character or not hrp or humanoid.Health <= 0 then break end

            local nextPos = (i == numSteps) and endPos or (startPos + (direction * (i * chunkSize)))
            local segmentDistance = (nextPos - hrp.Position).Magnitude
            local segmentTime = segmentDistance / moveSpeed

            local tween = TweenService:Create(hrp, TweenInfo.new(math.max(0.01, segmentTime), Enum.EasingStyle.Linear), {CFrame = CFrame.new(nextPos) * currentRotation})
            tween:Play()
            tween.Completed:Wait()

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        if hrp and humanoid and humanoid.Health > 0 then
            hrp.CFrame = targetCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        for _, data in ipairs(parts) do
            if data.part and data.part.Parent then data.part.CanCollide = data.canCollide end
        end

        tweeningThread = nil
    end)
end

--------------------------------------------------
-- HÀM DỊCH CHUYỂN VỀ SAFE ZONE DỰA TRÊN KEY
--------------------------------------------------
local function SmartReturnToSafeZone()
    if activeLogicMode == "NEW" then
        -- LOGIC MỚI: QUÉT VỊ TRÍ GẦN NHẤT & CHẠY LÙI VỀ WAYPOINT [0]
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local currentPos = hrp.Position
        local nearestIndex = 0
        local minDistance = math.huge

        for index, cf in pairs(waypoints) do
            local dist = (currentPos - cf.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestIndex = index
            end
        end

        task.spawn(function()
            for i = nearestIndex, 0, -1 do
                SmoothTween(waypoints[i], tweenSpeed)
                repeat task.wait() until tweeningThread == nil
            end
        end)
    else
        -- LOGIC CỦI: BAY THẲNG VỀ SAFE ZONE CỦ
        SmoothTween(oldSafeZoneCFrame, tweenSpeed)
    end
end

--------------------------------------------------
-- HÀM TẠO NÚT MINI AREA
--------------------------------------------------
local function CreateMiniAreaButton(areaName, targetCFrame, bgColor, yScale, yOffsetPixel)
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
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Size = UDim2.new(0, 110, 0, 26)
    btn.Position = UDim2.new(1, -15, yScale, yOffsetPixel)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = areaName
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Active = true
    btn.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = btn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        SmoothTween(targetCFrame, tweenSpeed)
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
-- RAYFIELD WINDOW
--------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "FTGS HUB",
    LoadingTitle = "LOADING SYSTEM",
    LoadingSubtitle = "by ftgs",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

--------------------------------------------------
-- TẢI CÁC TAB CHÍNH
--------------------------------------------------
local function LoadMainTabs()
    local MainTab = Window:CreateTab("Main", 4483362458)

    local modeInfo = (activeLogicMode == "NEW") and "Logic Mới (Waypoints Nối Đuôi)" or "Logic Cũ (Bay Thẳng Tọa Độ)"
    MainTab:CreateSection("Đang Chạy: " .. modeInfo)

    MainTab:CreateToggle({
        Name = "Skip Prompt (Bỏ qua thời gian giữ phím nhặt)",
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
        Name = "Auto Zone (Nhặt xong tự bay về Safe Zone)",
        CurrentValue = false,
        Flag = "AutoZone",
        Callback = function(Value)
            autoZoneActive = Value
            Rayfield:Notify({ Title = "Auto Zone", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2 })
        end,
    })

    MainTab:CreateSection("Tính Năng Farm & Safe Zone")

    MainTab:CreateSlider({
        Name = "Tốc độ di chuyển (Move Speed MAX 600)",
        Range = {50, 600},
        Increment = 10,
        Suffix = "Studs/s",
        CurrentValue = tweenSpeed,
        Flag = "TweenSpeed",
        Callback = function(Value) tweenSpeed = Value end,
    })

    MainTab:CreateSlider({
        Name = "Chunk Size (Khoảng Cách Chunk Roblox)",
        Range = {2, 38},
        Increment = 1,
        Suffix = "Studs/chunk",
        CurrentValue = chunkSize,
        Flag = "ChunkSize",
        Callback = function(Value) chunkSize = Value end,
    })

    MainTab:CreateButton({
        Name = "Safe Zone (Dịch chuyển về khu vực an toàn)",
        Callback = function()
            Rayfield:Notify({ Title = "Safe Zone", Content = "Đang di chuyển về Safe Zone...", Duration = 2 })
            SmartReturnToSafeZone()
        end,
    })

    MainTab:CreateToggle({
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
                    SafeBtn.AnchorPoint = Vector2.new(1, 0.5)
                    SafeBtn.Size = UDim2.new(0, 52, 0, 52)
                    SafeBtn.Position = UDim2.new(1, -132, 0.12, 0)
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
                    UIStroke.Thickness = 1.5
                    UIStroke.Color = Color3.fromRGB(255, 255, 255)
                    UIStroke.Parent = SafeBtn

                    SafeBtn.MouseButton1Click:Connect(function()
                        SmartReturnToSafeZone()
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

    -- TAB AREA
    local AreaTab = Window:CreateTab("Area", 4483362458)
    AreaTab:CreateSection("Nút Bay Nhanh Khu Vực (Mini Toggle)")

    local targetAreaMap = (activeLogicMode == "NEW") and newAreaCFrames or oldAreaCFrames

    AreaTab:CreateToggle({
        Name = "Volcano Mini Toggle",
        CurrentValue = false,
        Flag = "VolcanoMini",
        Callback = function(Value)
            if Value then CreateMiniAreaButton("Volcano", targetAreaMap.Volcano, Color3.fromRGB(225, 68, 0), 0.12, 0)
            else RemoveMiniAreaButton("Volcano") end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Ocean Mini Toggle",
        CurrentValue = false,
        Flag = "OceanMini",
        Callback = function(Value)
            if Value then CreateMiniAreaButton("Ocean", targetAreaMap.Ocean, Color3.fromRGB(0, 119, 182), 0.12, 28)
            else RemoveMiniAreaButton("Ocean") end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Prehistoric Mini Toggle",
        CurrentValue = false,
        Flag = "PrehistoricMini",
        Callback = function(Value)
            if Value then CreateMiniAreaButton("Prehistoric", targetAreaMap.Prehistoric, Color3.fromRGB(34, 139, 34), 0.12, 56)
            else RemoveMiniAreaButton("Prehistoric") end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Cosmic Mini Toggle",
        CurrentValue = false,
        Flag = "CosmicMini",
        Callback = function(Value)
            if Value then CreateMiniAreaButton("Cosmic", targetAreaMap.Cosmic, Color3.fromRGB(138, 43, 226), 0.12, 84)
            else RemoveMiniAreaButton("Cosmic") end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Cherry Blossom Mini Toggle",
        CurrentValue = false,
        Flag = "CherryBlossomMini",
        Callback = function(Value)
            if Value then CreateMiniAreaButton("Cherry Blossom", targetAreaMap["Cherry Blossom"], Color3.fromRGB(235, 90, 160), 0.12, 112)
            else RemoveMiniAreaButton("Cherry Blossom") end
        end,
    })

    -- TAB MISC
    local MiscTab = Window:CreateTab("Misc", 4483362458)
    MiscTab:CreateSection("Tính Năng Hỗ Trợ & Tối Ưu")

    MiscTab:CreateButton({
        Name = "Fix Lag / Boost FPS Full 🚀",
        Callback = function()
            local Lighting = game:GetService("Lighting")
            local Terrain = Workspace.Terrain

            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 1
                Lighting.EnvironmentDiffuseScale = 0
                Lighting.EnvironmentSpecularScale = 0
                if Lighting:FindFirstChild("Bloom") then Lighting.Bloom.Enabled = false end
                if Lighting:FindFirstChild("ColorCorrection") then Lighting.ColorCorrection.Enabled = false end
                if Lighting:FindFirstChild("SunRays") then Lighting.SunRays.Enabled = false end
                if Lighting:FindFirstChild("DepthOfField") then Lighting.DepthOfField.Enabled = false end
                if Lighting:FindFirstChild("Blur") then Lighting.Blur.Enabled = false end
            end)

            pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end)

            for _,v in ipairs(game:GetDescendants()) do
                pcall(function()
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Material = Enum.Material.SmoothPlastic
                    elseif v:IsA("Texture") or v:IsA("Decal") then
                        v.Texture = ""
                    end
                end)
            end

            Rayfield:Notify({ Title = "Fix Lag", Content = "Đã kích hoạt FPS Boost Full thành công! ⚡", Duration = 3 })
        end,
    })

    MiscTab:CreateToggle({
        Name = "Anti-AFK (Giả Lập Joystick 3 Cách)",
        CurrentValue = false,
        Flag = "AntiAFK",
        Callback = function(Value)
            antiAFKActive = Value
            Rayfield:Notify({ Title = "Anti-AFK", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2 })
        end,
    })

    MiscTab:CreateToggle({
        Name = "Ẩn Toàn bộ Pet",
