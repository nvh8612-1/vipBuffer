-- LocalScript tối ưu hoàn chỉnh cho Delta Executor (Bỏ Speed, giữ Skip Prompt chuẩn + Anti-AFK W)
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Biến lưu trạng thái
local skipPromptActive = false
_G.AntiAFK = false

-- Lấy Parent GUI chuẩn của Delta để Menu chắc chắn hiển thị
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Xóa Menu cũ nếu đã tồn tại để tránh đè giao diện
if parentGui:FindFirstChild("DeltaCleanMenu") then
	parentGui.DeltaCleanMenu:Destroy()
end

-- ==========================================
-- 1. TẠO GIAO DIỆN (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCleanMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.35, -75)
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
Title.Text = "Safe Menu"
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

-- Nút Bật/Tắt Skip Prompt (Giữ nguyên logic gốc của bạn)
local PromptToggle = Instance.new("TextButton")
PromptToggle.Size = UDim2.new(0.9, 0, 0, 35)
PromptToggle.Position = UDim2.new(0.05, 0, 0.3, 0)
PromptToggle.Text = "Skip Prompt: OFF"
PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
PromptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptToggle.Font = Enum.Font.SourceSansBold
PromptToggle.Parent = MainFrame

-- Nút Bật/Tắt Anti-AFK (Ấn W mỗi 1 phút)
local AFKToggle = Instance.new("TextButton")
AFKToggle.Size = UDim2.new(0.9, 0, 0, 35)
AFKToggle.Position = UDim2.new(0.05, 0, 0.65, 0)
AFKToggle.Text = "Anti-AFK (W/1p): OFF"
AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKToggle.Font = Enum.Font.SourceSansBold
AFKToggle.Parent = MainFrame

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
-- 3. LOGIC SKIP PROMPT (GIỮ NGUYÊN GỐC)
-- ==========================================
PromptToggle.MouseButton1Click:Connect(function()
	skipPromptActive = not skipPromptActive
	if skipPromptActive then
		PromptToggle.Text = "Skip Prompt: ON"
		PromptToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		
		-- Ép thời gian giữ của tất cả Prompt về 0 giây[cite: 1]
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

-- Tự áp dụng khi có Prompt mới xuất hiện[cite: 1]
workspace.DescendantAdded:Connect(function(descendant)
	if skipPromptActive and descendant:IsA("ProximityPrompt") then
		descendant.HoldDuration = 0
	end
end)

-- ==========================================
-- 4. LOGIC ANTI-AFK (ẤN W MỖI 1 PHÚT)
-- ==========================================
AFKToggle.MouseButton1Click:Connect(function()
	_G.AntiAFK = not _G.AntiAFK
	if _G.AntiAFK then
		AFKToggle.Text = "Anti-AFK (W/1p): ON"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		AFKToggle.Text = "Anti-AFK (W/1p): OFF"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end
end)

task.spawn(function()
	while true do
		task.wait(60) -- 1 phút
		if _G.AntiAFK then
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
				task.wait(0.2)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
			end)
		end
	end
end)
