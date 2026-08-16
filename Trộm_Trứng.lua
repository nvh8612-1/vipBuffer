-- LocalScript: Đặt vào StarterPlayerScripts hoặc chạy bằng Executor
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

local skipPromptActive = false

-- 1. Tạo Giao Diện (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PromptMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 110)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

-- Nút Bật/Tắt Skip Prompt
local PromptToggle = Instance.new("TextButton")
PromptToggle.Size = UDim2.new(0.9, 0, 0, 40)
PromptToggle.Position = UDim2.new(0.05, 0, 0.45, 0)
PromptToggle.Text = "Skip Prompt: OFF"
PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
PromptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptToggle.Font = Enum.Font.SourceSansBold
PromptToggle.Parent = MainFrame

-- Nút Chữ "S" Thu Gọn (Ban đầu ẩn)
local SmallBtn = Instance.new("TextButton")
SmallBtn.Size = UDim2.new(0, 40, 0, 40)
SmallBtn.Position = MainFrame.Position
SmallBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SmallBtn.Text = "S"
SmallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallBtn.TextSize = 20
SmallBtn.Font = Enum.Font.SourceSansBold
SmallBtn.Visible = false
SmallBtn.Active = true
SmallBtn.Draggable = true
SmallBtn.Parent = ScreenGui

-- 2. Xử lý Logic Thu Gọn / Mở Rộng
MinimizeBtn.MouseButton1Click:Connect(function()
	SmallBtn.Position = MainFrame.Position -- Giữ nguyên vị trí khi thu gọn
	MainFrame.Visible = false
	SmallBtn.Visible = true
end)

SmallBtn.MouseButton1Click:Connect(function()
	MainFrame.Position = SmallBtn.Position -- Cập nhật lại vị trí nếu đã kéo thả nút "S"
	SmallBtn.Visible = false
	MainFrame.Visible = true
end)

-- 3. Xử lý Skip Prompt
PromptToggle.MouseButton1Click:Connect(function()
	skipPromptActive = not skipPromptActive
	if skipPromptActive then
		PromptToggle.Text = "Skip Prompt: ON"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		PromptToggle.Text = "Skip Prompt: OFF"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	if skipPromptActive then
		fireproximityprompt(prompt)
	end
end)
