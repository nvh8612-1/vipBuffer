-- LocalScript tối ưu hoàn chỉnh cho Delta Executor
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Biến lưu trạng thái
local speedPercentage = 0
local speedActive = false
local skipPromptActive = false
local antiAFKActive = false

-- Lấy Parent GUI chuẩn của Delta để Menu chắc chắn hiển thị
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Xóa Menu cũ nếu đã tồn tại để tránh đè giao diện
if parentGui:FindFirstChild("DeltaFullMenu") then
	parentGui.DeltaFullMenu:Destroy()
end

-- ==========================================
-- 1. TẠO GIAO DIỆN CHÍNH (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFullMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 210)
MainFrame.Position = UDim2.new(0.5, -125, 0.35, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Control Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Nút Thu Gọn (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

-- Thanh Nút Chuyển Tab (Main | Speed)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
MainTabBtn.Position = UDim2.new(0, 0, 0, 0)
MainTabBtn.Text = "Main"
MainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabBtn.Font = Enum.Font.SourceSansBold
MainTabBtn.Parent = TabBar

local SpeedTabBtn = Instance.new("TextButton")
SpeedTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
SpeedTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
SpeedTabBtn.Text = "Speed"
SpeedTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedTabBtn.Font = Enum.Font.SourceSansBold
SpeedTabBtn.Parent = TabBar

-- Container Nội Dung Tab Main
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, -65)
MainContent.Position = UDim2.new(0, 0, 0, 65)
MainContent.BackgroundTransparency = 1
MainContent.Visible = true
MainContent.Parent = MainFrame

-- Container Nội Dung Tab Speed
local SpeedContent = Instance.new("Frame")
SpeedContent.Size = UDim2.new(1, 0, 1, -65)
SpeedContent.Position = UDim2.new(0, 0, 0, 65)
SpeedContent.BackgroundTransparency = 1
SpeedContent.Visible = false
SpeedContent.Parent = MainFrame

-- ==========================================
-- 2. CÁC NÚT TRONG TAB MAIN
-- ==========================================
-- Nút Bật/Tắt Skip Prompt
local PromptToggle = Instance.new("TextButton")
PromptToggle.Size = UDim2.new(0.9, 0, 0, 35)
PromptToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
PromptToggle.Text = "Skip Prompt: OFF"
PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
PromptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptToggle.Font = Enum.Font.SourceSansBold
PromptToggle.Parent = MainContent

-- Nút Bật/Tắt Anti-AFK
local AFKToggle = Instance.new("TextButton")
AFKToggle.Size = UDim2.new(0.9, 0, 0, 35)
AFKToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
AFKToggle.Text = "Anti-AFK: OFF"
AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKToggle.Font = Enum.Font.SourceSansBold
AFKToggle.Parent = MainContent

-- ==========================================
-- 3. CÁC THÀNH PHẦN TRONG TAB SPEED
-- ==========================================
-- Ô Nhập % Tốc Độ
local PercentInput = Instance.new("TextBox")
PercentInput.Size = UDim2.new(0.9, 0, 0, 30)
PercentInput.Position = UDim2.new(0.05, 0, 0.08, 0)
PercentInput.PlaceholderText = "Nhập % tăng tốc (ví dụ: 10)"
PercentInput.Text = ""
PercentInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PercentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentInput.Font = Enum.Font.SourceSans
PercentInput.Parent = SpeedContent

-- Nút Bật/Tắt Tốc Độ
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0.9, 0, 0, 32)
SpeedToggle.Position = UDim2.new(0.05, 0, 0.35, 0)
SpeedToggle.Text = "Speed: OFF"
SpeedToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.Parent = SpeedContent

-- Ô Thông Báo Cảnh Báo Nhiễu
local SpeedNotice = Instance.new("TextLabel")
SpeedNotice.Size = UDim2.new(0.9, 0, 0, 40)
SpeedNotice.Position = UDim2.new(0.05, 0, 0.65, 0)
SpeedNotice.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpeedNotice.Text = "Đây chỉ là gây nhiễu không cho server quét thôi không có tác dụng đâu bật cũng như không"
SpeedNotice.TextColor3 = Color3.fromRGB(255, 180, 50)
SpeedNotice.TextSize = 10
SpeedNotice.TextWrapped = true
SpeedNotice.Font = Enum.Font.SourceSans
SpeedNotice.Parent = SpeedContent

-- Nút Chữ "S" Thu Gọn
local SmallBtn = Instance.new("TextButton")
SmallBtn.Size = UDim2.new(0, 40, 0, 40)
SmallBtn.Position = MainFrame.Position
SmallBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SmallBtn.Text = "S"
SmallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallBtn.TextSize = 20
SmallBtn.Font = Enum.Font.SourceSansBold
SmallBtn.Visible = false
SmallBtn.Active = true
SmallBtn.Draggable = true
SmallBtn.Parent = ScreenGui

-- ==========================================
-- 4. XỬ LÝ CHUYỂN TAB & THU GỌN
-- ==========================================
MainTabBtn.MouseButton1Click:Connect(function()
	MainContent.Visible = true
	SpeedContent.Visible = false
	MainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	SpeedTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	SpeedTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

SpeedTabBtn.MouseButton1Click:Connect(function()
	MainContent.Visible = false
	SpeedContent.Visible = true
	SpeedTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	SpeedTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	MainTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	MainTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

MinimizeBtn.MouseButton1Click:Connect(function()
	SmallBtn.Position = MainFrame.Position
	MainFrame.Visible = false
	SmallBtn.Visible = true
end)

SmallBtn.MouseButton1Click:Connect(function()
	MainFrame.Position = SmallBtn.Position
	SmallBtn.Visible = false
	MainFrame.Visible = true
end)

-- ==========================================
-- 5. LOGIC SKIP PROMPT & ANTI-AFK (TAB MAIN)
-- ==========================================
PromptToggle.MouseButton1Click:Connect(function()
	skipPromptActive = not skipPromptActive
	if skipPromptActive then
		PromptToggle.Text = "Skip Prompt: ON"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
			end
		end
	else
		PromptToggle.Text = "Skip Prompt: OFF"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

workspace.DescendantAdded:Connect(function(descendant)
	if skipPromptActive and descendant:IsA("ProximityPrompt") then
		descendant.HoldDuration = 0
	end
end)

AFKToggle.MouseButton1Click:Connect(function()
	antiAFKActive = not antiAFKActive
	if antiAFKActive then
		AFKToggle.Text = "Anti-AFK: ON"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		AFKToggle.Text = "Anti-AFK: OFF"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

LocalPlayer.Idled:Connect(function()
	if antiAFKActive then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end)
	end
end)

-- ==========================================
-- 6. LOGIC SPEED (TAB SPEED)
-- ==========================================
PercentInput.FocusLost:Connect(function()
	local val = tonumber(PercentInput.Text)
	if val then
		speedPercentage = val
	end
end)

SpeedToggle.MouseButton1Click:Connect(function()
	speedActive = not speedActive
	if speedActive then
		SpeedToggle.Text = "Speed: ON"
		SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		SpeedToggle.Text = "Speed: OFF"
		SpeedToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

RunService.Stepped:Connect(function()
	if speedActive and speedPercentage > 0 then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid
			local currentBase = humanoid.WalkSpeed
			humanoid.WalkSpeed = currentBase * (1 + (speedPercentage / 100))
		end
	end
end)
