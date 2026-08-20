-- LocalScript Gộp Anti-AFK & Skip Prompt (Fluent GUI Design)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Biến lưu trạng thái
local antiAFKActive = false
local skipPromptActive = false

-- Parent Gui chuẩn
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("VIPBufferHub") then
	parentGui.VIPBufferHub:Destroy()
end

-- ==========================================
-- 1. TẠO GIAO DIỆN CHUẨN FLUENT STYLE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VIPBufferHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentGui

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.5, 100, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim2.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Thanh Tiêu Đề (Header)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim2.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VIP Buffer Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Nút Thu Gọn (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 25)
MinimizeBtn.AnchorPoint = Vector2.new(0, 0.5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

-- ------------------------------------------
-- CÁC NÚT TÍNH NĂNG (TOGGLES)
-- ------------------------------------------
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Nút 1: Anti-AFK
local AFKBtn = Instance.new("TextButton")
AFKBtn.Size = UDim2.new(1, 0, 0, 42)
AFKBtn.Position = UDim2.new(0, 0, 0, 5)
AFKBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
AFKBtn.Text = "  Anti-AFK: OFF"
AFKBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
AFKBtn.TextSize = 12
AFKBtn.Font = Enum.Font.GothamMedium
AFKBtn.TextXAlignment = Enum.TextXAlignment.Left
AFKBtn.Parent = Container

local AFKCorner = Instance.new("UICorner")
AFKCorner.CornerRadius = UDim2.new(0, 6)
AFKCorner.Parent = AFKBtn

-- Nút 2: Skip Prompt
local PromptBtn = Instance.new("TextButton")
PromptBtn.Size = UDim2.new(1, 0, 0, 42)
PromptBtn.Position = UDim2.new(0, 0, 0, 55)
PromptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
PromptBtn.Text = "  Skip Prompt: OFF"
PromptBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
PromptBtn.TextSize = 12
PromptBtn.Font = Enum.Font.GothamMedium
PromptBtn.TextXAlignment = Enum.TextXAlignment.Left
PromptBtn.Parent = Container

local PromptCorner = Instance.new("UICorner")
PromptCorner.CornerRadius = UDim2.new(0, 6)
PromptCorner.Parent = PromptBtn

-- Nút Chữ Tròn Thu Gọn (Icon V)
local SmallBtn = Instance.new("TextButton")
SmallBtn.Size = UDim2.new(0, 45, 0, 45)
SmallBtn.Position = MainFrame.Position
SmallBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
SmallBtn.Text = "V"
SmallBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
SmallBtn.TextSize = 18
SmallBtn.Font = Enum.Font.GothamBold
SmallBtn.Visible = false
SmallBtn.Parent = ScreenGui

local SmallCorner = Instance.new("UICorner")
SmallCorner.CornerRadius = UDim2.new(1, 0)
SmallCorner.Parent = SmallBtn

local SmallStroke = Instance.new("UIStroke")
SmallStroke.Color = Color3.fromRGB(0, 200, 255)
SmallStroke.Thickness = 1.5
SmallStroke.Parent = SmallBtn

-- Joystick Ảo Mô Phỏng Dưới Góc Màn Hình
local BaseJoystick = Instance.new("Frame")
BaseJoystick.Size = UDim2.new(0, 65, 0, 65)
BaseJoystick.Position = UDim2.new(0.08, 0, 0.68, 0)
BaseJoystick.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BaseJoystick.BackgroundTransparency = 0.5
BaseJoystick.Active = false
BaseJoystick.Parent = ScreenGui

local BaseCorner = Instance.new("UICorner")
BaseCorner.CornerRadius = UDim2.new(1, 0)
BaseCorner.Parent = BaseJoystick

local Stick = Instance.new("Frame")
Stick.Size = UDim2.new(0, 26, 0, 26)
Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
Stick.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Stick.BackgroundTransparency = 0.2
Stick.Active = false
Stick.Parent = BaseJoystick

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim2.new(1, 0)
StickCorner.Parent = Stick

-- ==========================================
-- 2. HỆ THỐNG TOUCH BYPASS & DRAG
-- ==========================================
local function bindTouch(btn, callback)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			callback()
		end
	end)
end

-- Kéo thả UI mượt mà
local function enableDrag(frame, dragHandle)
	local dragging, dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

enableDrag(MainFrame, Header)
enableDrag(SmallBtn, SmallBtn)

-- Xử lý Thu gọn / Mở rộng
bindTouch(MinimizeBtn, function()
	SmallBtn.Position = MainFrame.Position
	MainFrame.Visible = false
	SmallBtn.Visible = true
end)

bindTouch(SmallBtn, function()
	MainFrame.Position = SmallBtn.Position
	SmallBtn.Visible = false
	MainFrame.Visible = true
end)

-- ==========================================
-- 3. XỬ LÝ CHỨC NĂNG
-- ==========================================

-- Toggle Anti-AFK
bindTouch(AFKBtn, function()
	antiAFKActive = not antiAFKActive
	if antiAFKActive then
		AFKBtn.Text = "  Anti-AFK: ON"
		AFKBtn.TextColor3 = Color3.fromRGB(80, 220, 120)
		AFKBtn.BackgroundColor3 = Color3.fromRGB(30, 55, 40)
	else
		AFKBtn.Text = "  Anti-AFK: OFF"
		AFKBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
		AFKBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		Stick.Position = UDim2.new(0.5, -13, 0.5, -13)
	end
end)

-- Toggle Skip Prompt
bindTouch(PromptBtn, function()
	skipPromptActive = not skipPromptActive
	if skipPromptActive then
		PromptBtn.Text = "  Skip Prompt: ON"
		PromptBtn.TextColor3 = Color3.fromRGB(80, 220, 120)
		PromptBtn.BackgroundColor3 = Color3.fromRGB(30, 55, 40)
		
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
			end
		end
	else
		PromptBtn.Text = "  Skip Prompt: OFF"
		PromptBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
		PromptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	end
end)

workspace.DescendantAdded:Connect(function(descendant)
	if skipPromptActive and descendant:IsA("ProximityPrompt") then
		descendant.HoldDuration = 0
	end
end)

-- Loop Anti-AFK kéo nhẹ tiến lên
task.spawn(function()
	while true do
		task.wait(40)
		if antiAFKActive then
			pcall(function()
				local character = LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				Stick:TweenPosition(UDim2.new(0.5, -13, 0.05, -13), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, -1), true)
				end
				
				task.wait(0.5)

				Stick:TweenPosition(UDim2.new(0.5, -13, 0.5, -13), "Out", "Quad", 0.2, true)
				if humanoid then
					humanoid:Move(Vector3.new(0, 0, 0), true)
				end
			end)
		end
	end
end)
