-- LocalScript Menu AFK Giả Lập Phím Delta Keyboard (Nút "P")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Biến lưu trạng thái
local antiAFKActive = false

-- Lấy Parent GUI chuẩn của Delta
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Xóa Menu AFK cũ nếu đã chạy trước đó
if parentGui:FindFirstChild("DeltaAFKMenu") then
	parentGui.DeltaAFKMenu:Destroy()
end

-- ==========================================
-- 1. TẠO GIAO DIỆN MENU AFK (NÚT P)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAFKMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Khung Menu AFK
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 110)
MainFrame.Position = UDim2.new(0.5, 130, 0.35, -55) -- Đặt lệch bên phải
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
Title.Text = "AFK Menu"
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

-- Nút Bật/Tắt Anti-AFK
local AFKToggle = Instance.new("TextButton")
AFKToggle.Size = UDim2.new(0.9, 0, 0, 40)
AFKToggle.Position = UDim2.new(0.05, 0, 0, 50)
AFKToggle.Text = "Anti-AFK: OFF"
AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKToggle.Font = Enum.Font.SourceSansBold
AFKToggle.Parent = MainFrame

-- Nút Chữ "P" Thu Gọn (Ban đầu ẩn)
local SmallBtn = Instance.new("TextButton")
SmallBtn.Size = UDim2.new(0, 40, 0, 40)
SmallBtn.Position = MainFrame.Position
SmallBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SmallBtn.Text = "P"
SmallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallBtn.TextSize = 20
SmallBtn.Font = Enum.Font.SourceSansBold
SmallBtn.Visible = false
SmallBtn.Active = true
SmallBtn.Draggable = true
SmallBtn.Parent = ScreenGui

-- ==========================================
-- 2. XỬ LÝ NÚT THU GỌN / MỞ RỘNG
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
-- 3. LOGIC ANTI-AFK GIẢ LẬP BẤM PHÍM DẠNG DELTA KEYBOARD
-- ==========================================
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

-- Vòng lặp mô phỏng đè phím W rồi lùi lại bằng phím S mỗi 45 giây
task.spawn(function()
	while true do
		task.wait(45)
		if antiAFKActive then
			pcall(function()
				-- Bấm giữ phím W (Đi tới)
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
				task.wait(0.3)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
				
				task.wait(0.1)
				
				-- Bấm giữ phím S (Thùi lại)
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
				task.wait(0.3)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
			end)
		end
	end
end)
