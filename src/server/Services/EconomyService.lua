--!strict
-- CRIME VAULT — EconomyService
-- Печатный станок: каждую секунду начисляет игроку деньги исходя из PrinterLevel.
-- Также обслуживает апгрейд станка (валидирует цену, списывает, инкрементит уровень).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PrinterConfig = require(ReplicatedStorage.Shared.Configs.PrinterConfig)

local TICK_INTERVAL = 1.0 -- 1 секунда — главный тик экономики

local EconomyService = Knit.CreateService({
	Name = "EconomyService",
	Client = {
		-- Клиент сможет вызвать EconomyService:RequestPrinterUpgrade()
		RequestPrinterUpgrade = function() end,
		GetPrinterInfo = function() end,
	},
})

function EconomyService:KnitStart()
	local PlayerDataService = Knit.GetService("PlayerDataService")

	-- ═══════════════════ ТИК ═══════════════════
	-- Простой таймер на task.spawn — раз в TICK_INTERVAL секунд начисляем деньги.
	task.spawn(function()
		while true do
			task.wait(TICK_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = PlayerDataService:Get(player)
				if profile then
					local income = PrinterConfig.GetDollarsPerSec(profile.Data.PrinterLevel) * TICK_INTERVAL
					if income > 0 then
						PlayerDataService:Update(player, function(data)
							data.Money += income
							data.Stats.TotalMoneyEarned += income
						end)
					end
				end
			end
		end
	end)

	-- ═══════════════════ API ДЛЯ ДРУГИХ СЕРВИСОВ ═══════════════════
	self._PlayerDataService = PlayerDataService
end

-- Серверный метод: попытаться апгрейдить станок игрока.
-- Возвращает (ok: boolean, message: string).
function EconomyService:TryUpgradePrinter(player: Player): (boolean, string)
	local profile = self._PlayerDataService:Get(player)
	if not profile then
		return false, "Профиль не загружен"
	end

	local currentLevel = profile.Data.PrinterLevel
	if PrinterConfig.IsMaxLevel(currentLevel) then
		return false, "Станок уже на максимальном уровне"
	end

	local cost = PrinterConfig.GetUpgradeCost(currentLevel)
	if not cost then
		return false, "Не удалось рассчитать цену апгрейда"
	end

	if profile.Data.Money < cost then
		return false, string.format("Недостаточно денег ($%d / $%d)", profile.Data.Money, cost)
	end

	self._PlayerDataService:Update(player, function(data)
		data.Money -= cost
		data.PrinterLevel += 1
	end)

	local newLevel = currentLevel + 1
	print(
		string.format(
			"[EconomyService] %s upgraded printer Lv%d → Lv%d (стоимость $%d, новый доход $%d/сек)",
			player.Name,
			currentLevel,
			newLevel,
			cost,
			PrinterConfig.GetDollarsPerSec(newLevel)
		)
	)

	return true, string.format("Станок улучшен до Lv%d", newLevel)
end

-- ═══════════════════ CLIENT API (через Knit RemoteFunction) ═══════════════════

function EconomyService.Client:RequestPrinterUpgrade(player: Player): (boolean, string)
	return self.Server:TryUpgradePrinter(player)
end

-- Клиент может узнать текущий уровень + цену апгрейда + доход без вызова UpgradePrinter.
function EconomyService.Client:GetPrinterInfo(player: Player)
	local profile = self.Server._PlayerDataService:Get(player)
	if not profile then
		return nil
	end
	local level = profile.Data.PrinterLevel
	return {
		Level = level,
		DollarsPerSec = PrinterConfig.GetDollarsPerSec(level),
		UpgradeCost = PrinterConfig.GetUpgradeCost(level),
		IsMaxLevel = PrinterConfig.IsMaxLevel(level),
	}
end

return EconomyService
