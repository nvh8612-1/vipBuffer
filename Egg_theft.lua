--// RESET CỜ KHÓA ĐỂ TRÁNH LỖI KHÔNG TẢI ĐƯỢC KHI EXECUTE LẠI
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
-- HÀM LƯU SCRIPT KHI HOP SERVER
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
    if queueFunc then
        queueFunc(teleportScript)
    end
end

--------------------------------------------------
-- CẤU HÌNH KEY & FILE STORAGE
--------------------------------------------------
local currentKey = "key-fix-tjjskl"
local oldKey = "win0"
local keyUrl = "https://link4sub.com/notes/cLCN"
local fileName = "FTGSKey_Saved.txt"

local inputKeyText = ""
local isKeyUnlocked = false

local skipPromptActive = false
local autoZoneActive = false
local antiAFKActive = false
local isInteractingPrompt = false

-- Cấu hình Tween
local tweenSpeed = 120
local chunkSize = 3 -- Mặc định đã đổi thành 3 studs/chunk

-- TỌA ĐỘ CHUẨN
local safeZoneCFrame = CFrame.new(519.01, 70.27, -362.74)
local safeZoneGui = nil

local areaCFrames = {
    Volcano = CFrame.new(1879.73, 70.27, -384.79),
    Ocean = CFrame.new(2288.07, 70.27, -345.39),
    Prehistoric = CFrame.new(2809.94, 70.27, -369.17),
    Cosmic = CFrame.new(3393.60, 70.27, -342.13),
    ["Cherry Blossom"] = CFrame.new(4025.85, 70.27, -378.81)
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
-- HÀM TWEEN MẶT ĐẤT PHÂN ĐOẠN (GROUND CHUNK TWEEN)
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

        -- Tắt va chạm tạm thời
        local parts = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(parts, {part = part, canCollide = part.CanCollide})
                part.CanCollide = false
            end
        end

        -- Chia chặng theo chunkSize
        local numSteps = math.max(1, math.floor(totalDistance / chunkSize))
        local direction = (endPos - startPos).Unit
        local currentRotation = hrp.CFrame - hrp.CFrame.Position

        for i = 1, numSteps do
            if not LocalPlayer.Character or not hrp or humanoid.Health <= 0 then break end

            local nextPos
            if i == numSteps then
                nextPos = endPos
            else
                nextPos = startPos + (direction * (i * chunkSize))
            end

            local segmentDistance = (nextPos - hrp.Position).Magnitude
            local segmentTime = segmentDistance / moveSpeed

            local tweenInfo = TweenInfo.new(
                math.max(0.01, segmentTime),
                Enum.EasingStyle.Linear
            )
            
            local targetStepCFrame = CFrame.new(nextPos) * currentRotation
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetStepCFrame})
            
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

        -- Mở lại va chạm
        for _, data in ipairs(parts) do
            if data.part and data.part.Parent then
                data.part.CanCollide = data.canCollide
            end
        end

        tweeningThread = nil
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
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Chức năng cơ bản")

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
        Callback = function(Value)
            tweenSpeed = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Chunk Size (Khoản Cách Chunk Roblox)",
        Range = {2, 38},
        Increment = 1,
        Suffix = "Studs/chunk",
        CurrentValue = chunkSize,
        Flag = "ChunkSize",
        Callback = function(Value)
            chunkSize = Value
        end,
    })

    MainTab:CreateButton({
        Name = "Safe Zone (Dịch chuyển về khu vực an toàn)",
        Callback = function()
            Rayfield:Notify({ Title = "Safe Zone", Content = "Đang di chuyển về Safe Zone...", Duration = 2 })
            SmoothTween(safeZoneCFrame, tweenSpeed)
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
                        SmoothTween(safeZoneCFrame, tweenSpeed)
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

    AreaTab:CreateToggle({
        Name = "Cherry Blossom Mini Toggle",
        CurrentValue = false,
        Flag = "CherryBlossomMini",
        Callback = function(Value)
            if Value then
                CreateMiniAreaButton("Cherry Blossom", areaCFrames["Cherry Blossom"], Color3.fromRGB(235, 90, 160), 0.12, 112)
            else
                RemoveMiniAreaButton("Cherry Blossom")
            end
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

            local function optimize(obj)
                pcall(function()
                    if obj:IsA("ParticleEmitter")
                    or obj:IsA("Trail")
                    or obj:IsA("Beam")
                    or obj:IsA("Smoke")
                    or obj:IsA("Fire")
                    or obj:IsA("Sparkles") then
                        obj.Enabled = false

                    elseif obj:IsA("Explosion") then
                        obj.BlastPressure = 0
                        obj.BlastRadius = 0

                    elseif obj:IsA("BasePart") then
                        obj.CastShadow = false
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0

                    elseif obj:IsA("Texture") then
                        obj.Texture = ""

                    elseif obj:IsA("Decal") then
                        obj.Texture = ""

                    elseif obj:IsA("MeshPart") then
                        obj.TextureID = ""

                    elseif obj:IsA("SpecialMesh") then
                        obj.TextureId = ""

                    elseif obj:IsA("SurfaceAppearance") then
                        obj:Destroy()
                    end
                end)
            end

            for _,v in ipairs(game:GetDescendants()) do
                optimize(v)
            end

            game.DescendantAdded:Connect(function(v)
                task.wait()
                optimize(v)
            end)

            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)

            Rayfield:Notify({
                Title = "Fix Lag",
                Content = "Đã kích hoạt FPS Boost Full thành công! ⚡",
                Duration = 3
            })
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

                table.sort(servers, function(a, b) return a.playing < b.playing end)

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
        Callback = function(Text) inputKeyText = Text end,
    })

    local CheckKeyButton
    CheckKeyButton = KeyTab:CreateButton({
        Name = "Check Key ...",
        Callback = function()
            if isKeyUnlocked then
                Rayfield:Notify({ Title = "System", Content = "Key Hợp Lệ 🎉", Duration = 2 })
                return
            end

            Rayfield:Notify({ Title = "System", Content = "Track key ...", Duration = 1.5 })
            task.wait(1.5)

            if inputKeyText == currentKey then
                isKeyUnlocked = true
                SaveKeyToStorage(currentKey)
                
                Rayfield:Notify({ Title = "System", Content = "Key Hợp Lệ 🎉", Duration = 3 })
                CheckKeyButton:Set("Đã Xác Thực (Đã Lưu Key)")
                LoadMainTabs()
            else
                Rayfield:Notify({ Title = "System", Content = "Key Không Hợp Lệ 💫", Duration = 3 })
            end
        end,
    })

    KeyTab:CreateButton({
        Name = "Get Key (Copy Link)",
        Callback = function()
            if setclipboard then
                setclipboard(keyUrl)
                Rayfield:Notify({ Title = "Get Key", Content = "Đã sao chép Link lấy Key!", Duration = 3 })
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
        Rayfield:Notify({ Title = "System", Content = "Track key ...", Duration = 1.5 })
        task.wait(1.5)

        if savedKey == currentKey then
            isKeyUnlocked = true
            Rayfield:Notify({ Title = "System", Content = "Key Hợp Lệ 🎉", Duration = 3.0 })
            LoadMainTabs()
        else
            Rayfield:Notify({ Title = "System", Content = "Key Không Hợp Lệ 💫", Duration = 3.0 })
            LoadKeyTab()
        end
    else
        LoadKeyTab()
    end
end)

--------------------------------------------------
-- LOGIC PROXIMITY PROMPT
--------------------------------------------------
local function TriggerPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif prompt.InputHoldBegin then
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if skipPromptActive and descendant:IsA("ProximityPrompt") then
        pcall(function() descendant.HoldDuration = 0 end)
    end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, playerWhoTriggered)
    if playerWhoTriggered ~= LocalPlayer or isInteractingPrompt then return end
    
    local promptParent = prompt.Parent
    if not promptParent then return end

    local targetCFrame = nil
    if promptParent:IsA("BasePart") then
        targetCFrame = promptParent.CFrame
    elseif promptParent:IsA("Model") and promptParent.PrimaryPart then
        targetCFrame = promptParent.PrimaryPart.CFrame
    else
        local part = promptParent:FindFirstChildWhichIsA("BasePart")
        if part then targetCFrame = part.CFrame end
    end

    if not targetCFrame then return end

    isInteractingPrompt = true

    task.spawn(function()
        SmoothTween(targetCFrame * CFrame.new(0, 1.5, 0), tweenSpeed)
        task.wait(0.05)

        while prompt and prompt.Parent and prompt.Enabled and isInteractingPrompt do
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then break end

            TriggerPrompt(prompt)
            task.wait(0.03)
        end

        if autoZoneActive then
            SmoothTween(safeZoneCFrame, tweenSpeed)
        end

        isInteractingPrompt = false
    end)
end)

--------------------------------------------------
-- LOGIC ANTI-AFK
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
                        pcall(function() humanoid.InputMoveVector = Vector3.new(0, 0, -1) end)
                        humanoid:Move(Vector3.new(0, 0, -1), true)

                        RunService.RenderStepped:Wait()
                    end

                    if MasterControl and MasterControl.moveFunction then
                        MasterControl.moveFunction(LocalPlayer, Vector3.new(0, 0, 0), false)
                    end
                    humanoid.MoveVector = Vector3.new(0, 0, 0)
                    pcall(function() humanoid.InputMoveVector = Vector3.new(0, 0, 0) end)
                    humanoid:Move(Vector3.new(0, 0, 0), false)
                end
            end)
        end
    end
end)
