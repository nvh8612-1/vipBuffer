-- LocalScript tối ưu hoàn chỉnh cho Delta Executor
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Biến lưu trạng thái
local speedPercentage = 0
local speedActive = false
local skipPromptActive = false

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
MainFrame.Size = UDim2.new(0, 240, 0, 220)
MainFrame.Position = UDim2.new(0.5, -120, 0.35, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo thả Menu
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

-- Ô Nhập % Tốc Độ
local PercentInput = Instance.new("TextBox")
PercentInput.Size = UDim2.new(0.9, 0, 0, 30)
PercentInput.Position = UDim2.new(0.05, 0, 0.20, 0)
PercentInput.PlaceholderText = "Nhập % tăng tốc (ví dụ: 10)"
PercentInput.Text = ""
PercentInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PercentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentInput.Font = Enum.Font.SourceSans
PercentInput.Parent = MainFrame

-- Nút Bật/Tắt Tốc Độ
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0.9, 0, 0, 30)
SpeedToggle.Position = UDim2.new(0.05, 0, 0.38, 0)
SpeedToggle.Text = "Speed: OFF"
SpeedToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.Parent = MainFrame

-- Nút Bật/Tắt Skip Prompt
local PromptToggle = Instance.new("TextButton")
PromptToggle.Size = UDim2.new(0.9, 0, 0, 30)
PromptToggle.Position = UDim2.new(0.05, 0, 0.56, 0)
PromptToggle.Text = "Skip Prompt: OFF"
PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
PromptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptToggle.Font = Enum.Font.SourceSansBold
PromptToggle.Parent = MainFrame

-- Nút Chữ "S" Thu Gọn (Ban đầu ẩn)
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
-- 2. XỬ LÝ NÚT THU GỌN / MỞ RỘNG MENU
-- ==========================================
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
-- 3. LOGIC TĂNG TỐC ĐỘ THEO %
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

-- Tự động nhân % trên tốc độ hiện tại mà server cấp cho nhân vật
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

-- ==========================================
-- 4. LOGIC SKIP PROMPT
-- ==========================================
PromptToggle.MouseButton1Click:Connect(function()
	skipPromptActive = not skipPromptActive
	if skipPromptActive then
		PromptToggle.Text = "Skip Prompt: ON"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		
		-- Ép thời gian giữ của tất cả Prompt về 0 giây
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

-- Tự áp dụng khi có Prompt mới xuất hiện
workspace.DescendantAdded:Connect(function(descendant)
	if skipPromptActive and descendant:IsA("ProximityPrompt") then
		descendant.HoldDuration = 0
	end
end)
