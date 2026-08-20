-- LocalScript Menu AFK chữ P (Fix 100% lỗi bấm nút)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local antiAFKActive = false
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("DeltaAFKMenu") then
	parentGui.DeltaAFKMenu:Destroy()
end

-- ==========================================
-- 1. TẠO GIAO DIỆN
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAFKMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = parentGui

-- Frame Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 110)
MainFrame.Position = UDim2.new(0.5, 130, 0.35, -55)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = false -- Tắt Active của Frame để không chặn bấm nút con
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "AFK Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.ZIndex = 101
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
MinimizeBtn.ZIndex = 102
MinimizeBtn.Parent = MainFrame

-- Nút Bật/Tắt Anti-AFK
local AFKToggle = Instance.new("TextButton")
AFKToggle.Size = UDim2.new(0.9, 0, 0, 40)
AFKToggle.Position = UDim2.new(0.05, 0, 0, 50)
AFKToggle.Text = "Anti-AFK: OFF"
AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKToggle.Font = Enum.Font.SourceSansBold
AFKToggle.ZIndex = 102
AFKToggle.Parent = MainFrame

-- Nút Chữ "P" Thu Gọn
local SmallBtn = Instance.new("TextButton")
SmallBtn.Size = UDim2.new(0, 40, 0, 40)
SmallBtn.Position = MainFrame.Position
SmallBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SmallBtn.Text = "P"
SmallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallBtn.TextSize = 20
SmallBtn.Font = Enum.Font.SourceSansBold
SmallBtn.Visible = false
SmallBtn.ZIndex = 105
SmallBtn.Parent = ScreenGui

-- Joystick Ảo Hiển Thị
local BaseJoystick = Instance.new("Frame")
BaseJoystick.Size = UDim2.new(0, 75, 0, 75)
BaseJoystick.Position = UDim2.new(0.08, 0, 0.65, 0)
BaseJoystick.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BaseJoystick.BackgroundTransparency = 0.4
BaseJoystick.Active = false
BaseJoystick.ZIndex = 10
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
Stick.ZIndex = 11
Stick.Parent = BaseJoystick

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim2.new(1, 0)
StickCorner.Parent = Stick

-- ==========================================
-- 2. HỆ THỐNG KÉO THẢ (DRAG) CHUẨN KHÔNG LỖI
-- ==========================================
local function enableDrag(frame, dragHandle)
	local dragging, dragInput, dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

enableDrag(MainFrame, Title)
enableDrag(SmallBtn, SmallBtn)

-- ==========================================
-- 3. XỬ LÝ NÚT BẤM (BẬT/TẮT & THU GỌN)
-- ==========================================
local function onMinimize()
	SmallBtn.Position = MainFrame.Position
	MainFrame.Visible = false
	SmallBtn.Visible = true
end

local function onExpand()
	MainFrame.Position = SmallBtn.Position
	SmallBtn.Visible = false
	MainFrame.Visible = true
end

local function onToggleAFK()
	antiAFKActive = not antiAFKActive
	if antiAFKActive then
		AFKToggle.Text = "Anti-AFK: ON"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	else
		AFKToggle.Text = "Anti-AFK: OFF"
		AFKToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		Stick.Position = UDim2.new(0.5, -15, 0.5, -15)
	end
end

MinimizeBtn.MouseButton1Click:Connect(onMinimize)
MinimizeBtn.Activated:Connect(onMinimize)

SmallBtn.MouseButton1Click:Connect(onExpand)
SmallBtn.Activated:Connect(onExpand)

AFKToggle.MouseButton1Click:Connect(onToggleAFK)
AFKToggle.Activated:Connect(onToggleAFK)

-- ==========================================
-- 4. LOGIC ANTI-AFK TIẾN TỚI
-- ==========================================
task.spawn(function()
	while true do
		task.wait(20)
		if antiAFKActive then
			pcall(function()
				local character = LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				Stick:TweenPosition(UDim2.new(0.5, -15, 0.05, -15), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, -1), true)
				end
				
				task.wait(0.5)

				Stick:TweenPosition(UDim2.new(0.5, -15, 0.5, -15), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, 0), true)
				end
			end)
		end
	end
end)
