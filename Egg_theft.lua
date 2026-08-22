--// RAYFIELD - SCRIPT HUB BY FTGS (AUTO EXECUTE ON TELEPORT)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--------------------------------------------------
-- HÀM LƯU SCRIPT ĐỂ TỰ ĐỘNG CHẠY KHI HOP SERVER
--------------------------------------------------
local function QueueScriptForTeleport()
    local teleportScript = [[
        task.wait(3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LINK_SCRIPT_CUA_BAN_TAI_DAY.lua"))()
    ]]
    
    local queueFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if queueFunc then
        queueFunc(teleportScript)
    end
end

--------------------------------------------------
-- CẤU HÌNH KEY & FILE STORAGE
--------------------------------------------------
local currentKey = "2026-tjjsk"
local keyUrl = "https://link4sub.com/notes/cLCN"
local fileName = "FTGSKey_Saved.txt"

local inputKeyText = ""
local isKeyUnlocked = false

local skipPromptActive = false
local autoZoneActive = false
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
    btn.Size = UDim2.new(0, 90, 0, 26)
    btn.Position = UDim2.new(1, -15, yScale, yOffsetPixel)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = areaName
    btn.TextSize = 13
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
-- HÀM TẠO CÁC TAB TÍNH NĂNG
--------------------------------------------------
local function LoadMainTabs()
    -- TAB MAIN
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Tính Năng Cơ Bản")

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
        Name = "Auto Zone (Đụng Prompt Tự Bay Về Safe Zone)",
        CurrentValue = false,
        Flag = "AutoZone",
        Callback = function(Value)
            autoZoneActive = Value
            Rayfield:Notify({ Title = "Auto Zone", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2 })
        end,
    })

    MainTab:CreateSection("Tính Năng Farm & Safe Zone")

    MainTab:CreateSlider({
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

    MainTab:CreateButton({
        Name = "Safe Zone (Bay về khu vực an toàn)",
        Callback = function()
            Rayfield:Notify({ Title = "Safe Zone", Content = "Đang bay về Safe Zone...", Duration = 2 })
            task.spawn(function()
                SmoothTween(safeZoneCFrame, tweenSpeed)
            end)
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
                    SafeBtn.Position = UDim2.new(1, -112, 0.12, 0)
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

    -- TAB AREA
    local AreaTab = Window:CreateTab("Area", 4483362458)
    AreaTab:CreateSection("Nút Bay Nhanh Khu Vực (Mini Toggle)")

    AreaTab:CreateToggle({
        Name = "Volcano Mini Toggle",
        CurrentValue = false,
        Flag = "VolcanoMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Volcano", areaCFrames.Volcano, Color3.fromRGB(225, 68, 0), 0.12, 0)
            else
                RemoveMiniAreaButton("Volcano")
            end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Ocean Mini Toggle",
        CurrentValue = false,
        Flag = "OceanMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Ocean", areaCFrames.Ocean, Color3.fromRGB(0, 119, 182), 0.12, 28)
            else
                RemoveMiniAreaButton("Ocean")
            end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Prehistoric Mini Toggle",
        CurrentValue = false,
        Flag = "PrehistoricMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Prehistoric", areaCFrames.Prehistoric, Color3.fromRGB(34, 139, 34), 0.12, 56)
            else
                RemoveMiniAreaButton("Prehistoric")
            end
        end,
    })

    AreaTab:CreateToggle({
        Name = "Cosmic Mini Toggle",
        CurrentValue = false,
        Flag = "CosmicMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Cosmic", areaCFrames.Cosmic, Color3.fromRGB(138, 43, 226), 0.12, 84)
            else
                RemoveMiniAreaButton("Cosmic")
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
    MiscTab:CreateSection("Chuyển Server")

    MiscTab:CreateButton({
        Name = "Server Hop (Dịch chuyển đến Server khác)",
        Callback = function()
            Rayfield:Notify({ Title = "Server Hop", Content = "Đang tìm Server ngẫu nhiên...", Duration = 3 })
            QueueScriptForTeleport()
            pcall(function()
                local placeId = game.PlaceId
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/0?sortOrder=Asc&limit=100")).data
                local validServers = {}
                
                for _, s in ipairs(servers) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        table.insert(validServers, s.id)
                    end
                end

                if #validServers > 0 then
                    TeleportService:TeleportToPlaceInstance(placeId, validServers[math.random(1, #validServers)], LocalPlayer)
                else
                    Rayfield:Notify({ Title = "Server Hop", Content = "Không tìm thấy Server khả thi!", Duration = 3 })
                end
            end)
        end,
    })

    MiscTab:CreateButton({
        Name = "Server Small (Dịch chuyển đến Server ít người)",
        Callback = function()
            Rayfield:Notify({ Title = "Server Small", Content = "Đang tìm Server ít người nhất...", Duration = 3 })
            QueueScriptForTeleport()
            pcall(function()
                local placeId = game.PlaceId
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/0?sortOrder=Asc&limit=100")).data
                local targetServer = nil

                table.sort(servers, function(a, b)
                    return a.playing < b.playing
                end)

                for _, s in ipairs(servers) do
                    if s.id ~= game.JobId and s.playing > 0 and s.playing < s.maxPlayers then
                        targetServer = s.id
                        break
                    end
                end

                if targetServer then
                    TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
                else
                    Rayfield:Notify({ Title = "Server Small", Content = "Không tìm thấy Server ít người!", Duration = 3 })
                end
            end)
        end,
    })

    MiscTab:CreateSection("Tính Năng Khác")

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
-- LOGIC TRACK KEY
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
-- LOGIC PROXIMITY PROMPT & AUTO ZONE
--------------------------------------------------
Workspace.DescendantAdded:Connect(function(descendant)
    if skipPromptActive and descendant:IsA("ProximityPrompt") then
        pcall(function() descendant.HoldDuration = 0 end)
    end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
    if autoZoneActive and playerWhoTriggered == LocalPlayer then
        task.spawn(function()
            SmoothTween(safeZoneCFrame, tweenSpeed)
        end)
    end
end)

--------------------------------------------------
-- LOGIC ANTI-AFK (KẾT HỢP 3 CÁCH)
--------------------------------------------------
task.spawn(function()
    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local MasterControl = nil
    
    pcall(function()
        local ControlModule = require(PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        MasterControl = ControlModule
    end)

    while true do
        task.wait(15)
        if antiAFKActive then
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if humanoid and hrp and humanoid.Health > 0 then
                    local duration = 0.6
                    local startTime = os.clock()

                    while os.clock() - startTime < duration do
                        if MasterControl and MasterControl.moveFunction then
                            MasterControl.moveFunction(LocalPlayer, Vector3.new(0, 0, -1), true)
                        end

                        humanoid.MoveVector = Vector3.new(0, 0, -1)
                        pcall(function()
                            humanoid.InputMoveVector = Vector3.new(0, 0, -1)
                        end)

                        humanoid:Move(Vector3.new(0, 0, -1), true)

                        RunService.RenderStepped:Wait()
                    end

                    if MasterControl and MasterControl.moveFunction then
                        MasterControl.moveFunction(LocalPlayer, Vector3.new(0, 0, 0), false)
                    end
                    humanoid.MoveVector = Vector3.new(0, 0, 0)
                    pcall(function()
                        humanoid.InputMoveVector = Vector3.new(0, 0, 0)
                    end)
                    humanoid:Move(Vector3.new(0, 0, 0), false)
                end
            end)
        end
    end
end)
