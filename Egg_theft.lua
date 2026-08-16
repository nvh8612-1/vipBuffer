-- LocalScript: Đặt vào StarterPlayerScripts hoặc chạy bằng Executor
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local speedPercentage = 0
local speedActive = false
local skipPromptActive = false

-- 1. Tạo Giao Diện (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedAndPromptMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Control Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Input % Tốc độ
local PercentInput = Instance.new("TextBox")
PercentInput.Size = UDim2.new(0.9, 0, 0, 30)
PercentInput.Position = UDim2.new(0.05, 0, 0.22, 0)
PercentInput.PlaceholderText = "Nhập % tăng thêm (vd: 5)"
PercentInput.Text = ""
PercentInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PercentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentInput.Parent = MainFrame

-- Nút Bật/Tắt Tốc Độ
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0.9, 0, 0, 35)
SpeedToggle.Position = UDim2.new(0.05, 0, 0.42, 0)
SpeedToggle.Text = "Speed: OFF"
SpeedToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.Parent = MainFrame

-- Nút Bật/Tắt Bỏ qua Prompt
local PromptToggle = Instance.new("TextButton")
PromptToggle.Size = UDim2.new(0.9, 0, 0, 35)
PromptToggle.Position = UDim2.new(0.05, 0, 0.63, 0)
PromptToggle.Text = "Skip Prompt: OFF"
PromptToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
PromptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptToggle.Font = Enum.Font.SourceSansBold
PromptToggle.Parent = MainFrame

-- 2. Xử lý Lấy tốc độ Server & Tăng theo %
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

-- Vòng lặp liên tục nhân % trên tốc độ gốc của nhân vật
RunService.Stepped:Connect(function()
	if speedActive and speedPercentage > 0 then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid
			-- Lấy WalkSpeed hiện tại và nhân thêm %
			local currentBase = humanoid.WalkSpeed
			humanoid.WalkSpeed = currentBase * (1 + (speedPercentage / 100))
		end
	end
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
