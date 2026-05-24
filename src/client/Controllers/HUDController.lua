--!strict
-- CRIME VAULT — HUDController
-- Показывает баланс в кастомном HUD слева сверху.
-- Использует ScreenGui "HUD" из StarterGui если он есть (Dev B сделает в Studio),
-- иначе создаёт минимальный HUD в коде (fallback на ранних этапах).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalPlayer = Players.LocalPlayer

local HUDController = Knit.CreateController({ Name = "HUDController" })

-- ═══════════════════════ ХЕЛПЕРЫ ═══════════════════════

-- Форматирование денег: 10000 → "$10,000"
local function formatMoney(amount: number): string
	local negative = amount < 0
	local digits = tostring(math.floor(math.abs(amount)))
	-- Вставляем запятые каждые 3 цифры справа
	while true do
		local replaced, count = string.gsub(digits, "^(%d+)(%d%d%d)", "%1,%2")
		digits = replaced
		if count == 0 then
			break
		end
	end
	return (negative and "-$" or "$") .. digits
end

-- ═══════════════════════ HUD СБОРКА ═══════════════════════

-- Найти или создать ScreenGui "HUD"
local function getOrCreateHUD(playerGui: PlayerGui): ScreenGui
	local hud = playerGui:FindFirstChild("HUD")
	if hud and hud:IsA("ScreenGui") then
		return hud
	end
	hud = Instance.new("ScreenGui")
	hud.Name = "HUD"
	hud.ResetOnSpawn = false
	hud.IgnoreGuiInset = false
	hud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	hud.Parent = playerGui
	return hud
end

-- Найти или создать MoneyFrame внутри HUD
local function getOrCreateMoneyFrame(hud: ScreenGui): Frame
	local frame = hud:FindFirstChild("MoneyFrame")
	if frame and frame:IsA("Frame") then
		return frame
	end
	frame = Instance.new("Frame")
	frame.Name = "MoneyFrame"
	frame.Size = UDim2.fromOffset(220, 60)
	frame.Position = UDim2.fromOffset(16, 16)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = hud

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Thickness = 2
	stroke.Transparency = 0.4
	stroke.Parent = frame

	return frame
end

-- Найти или создать MoneyText внутри MoneyFrame
local function getOrCreateMoneyText(frame: Frame): TextLabel
	local label = frame:FindFirstChild("MoneyText")
	if label and label:IsA("TextLabel") then
		return label
	end
	label = Instance.new("TextLabel")
	label.Name = "MoneyText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 215, 0) -- gold
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "$0"
	label.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = label

	return label
end

-- ═══════════════════════ KNIT LIFECYCLE ═══════════════════════

function HUDController:KnitStart()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

	local hud = getOrCreateHUD(playerGui)
	local moneyFrame = getOrCreateMoneyFrame(hud)
	local moneyText = getOrCreateMoneyText(moneyFrame)

	-- Подписываемся на leaderstats.Money
	task.spawn(function()
		local leaderstats = LocalPlayer:WaitForChild("leaderstats", 30) :: Folder?
		if not leaderstats then
			warn("[HUDController] leaderstats not found")
			return
		end
		local money = leaderstats:WaitForChild("Money", 10) :: IntValue?
		if not money then
			warn("[HUDController] leaderstats.Money not found")
			return
		end

		local function update()
			moneyText.Text = formatMoney(money.Value)
		end

		update()
		money.Changed:Connect(update)
	end)
end

return HUDController
