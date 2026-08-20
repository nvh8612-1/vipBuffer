-- LocalScript Menu AFK Joystick (Fix lỗi không bấm được nút)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local antiAFKActive = false
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("DeltaAFKMenu") then
	parentGui.DeltaAFKMenu:Destroy()
end

-- ==========================================
-- 1. GIAO DIỆN SCREEN GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAFKMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999 -- Ép hiển thị lên trên cùng để không bị đè
ScreenGui.Parent = parentGui

-- Khung Menu Chữ P
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 110)
MainFrame.Position = UDim2.new(0.5, 130, 0.35, -55)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "AFK Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.ZIndex = 11
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.ZIndex = 11
MinimizeBtn.Parent = MainFrame

local AFKToggle = Instance.new("TextButton")
AFKToggle.Size = UDim2.new(0.9, 0, 0, 40)
AFKToggle.Position = UDim2.new(0.05, 0, 0, 50)
AFKToggle.Text = "Anti-AFK: OFF"
AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKToggle.Font = Enum.Font.SourceSansBold
AFKToggle.ZIndex = 12 -- Cao nhất trong Menu để nhận Cảm ứng/Click
AFKToggle.Parent = MainFrame

-- Nút "P" Thu Gọn
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
SmallBtn.ZIndex = 15
SmallBtn.Parent = ScreenGui

-- ------------------------------------------
-- JOYSTICK ẢO HIỂN THỊ RIÊNG BÊN NGOÀI
-- ------------------------------------------
local BaseJoystick = Instance.new("Frame")
BaseJoystick.Size = UDim2.new(0, 75, 0, 75)
BaseJoystick.Position = UDim2.new(0.08, 0, 0.65, 0)
BaseJoystick.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BaseJoystick.BackgroundTransparency = 0.4
BaseJoystick.Active = false -- Tắt Active để không cản trở tương tác xung quanh
BaseJoystick.ZIndex = 5
BaseJoystick.Parent = ScreenGui

local BaseCorner = Instance.new("UICorner")
BaseCorner.CornerRadius = UDim2.new(1, 0)
BaseCorner.Parent = BaseJoystick

local Stick = Instance.new("Frame")
Stick.Size = UDim2.new(0, 30, 0, 30)
Stick.Position = UDim2.new(0.5, -15, 0.5, -15)
Stick.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Stick.BackgroundTransparency = 0.2
Stick.Active = false
Stick.ZIndex = 6
Stick.Parent = BaseJoystick

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim2.new(1, 0)
StickCorner.Parent = Stick

-- ==========================================
-- 2. XỬ LÝ SỰ KIỆN NÚT BẤM (DÙNG ACTIVATED)
-- ==========================================
MinimizeBtn.Activated:Connect(function()
	SmallBtn.Position = MainFrame.Position
	MainFrame.Visible = false
	SmallBtn.Visible = true
end)

SmallBtn.Activated:Connect(function()
	MainFrame.Position = SmallBtn.Position
	SmallBtn.Visible = false
	MainFrame.Visible = true
end)

AFKToggle.Activated:Connect(function()
	antiAFKActive = not antiAFKActive
	if antiAFKActive then
		AFKToggle.Text = "Anti-AFK: ON"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		AFKToggle.Text = "Anti-AFK: OFF"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		Stick.Position = UDim2.new(0.5, -15, 0.5, -15)
	end
end)

-- ==========================================
-- 3. LOGIC ANTI-AFK TIẾN TỚI
-- ==========================================
task.spawn(function()
	while true do
		task.wait(40)
		if antiAFKActive then
			pcall(function()
				local character = LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				-- Đẩy Joystick ảo lên phía trước
				Stick:TweenPosition(UDim2.new(0.5, -15, 0.05, -15), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, -1), true)
				end
				
				task.wait(0.5)

				-- Trả Joystick về giữa
				Stick:TweenPosition(UDim2.new(0.5, -15, 0.5, -15), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, 0), true)
				end
			end)
		end
	end
end)
