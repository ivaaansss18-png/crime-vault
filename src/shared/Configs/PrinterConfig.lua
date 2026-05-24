--!strict
-- CRIME VAULT — PrinterConfig
-- 25 уровней печатного станка. Источник истины: CLAUDE.md → секция «Печатный станок».
-- Levels[N] = { Price = цена апгрейда до этого уровня, DollarsPerSec = доход $/сек на этом уровне }

local PrinterConfig = {}

PrinterConfig.MAX_LEVEL = 25

-- Цена апгрейда до этого уровня (Price для уровня 1 = 0, т.к. это старт).
-- DollarsPerSec — сколько долларов в секунду генерирует станок на этом уровне.
PrinterConfig.Levels = {
	[1] = { Price = 0, DollarsPerSec = 10 },
	[2] = { Price = 100, DollarsPerSec = 20 },
	[3] = { Price = 500, DollarsPerSec = 30 },
	[4] = { Price = 2000, DollarsPerSec = 40 },
	[5] = { Price = 5000, DollarsPerSec = 50 },
	[6] = { Price = 10000, DollarsPerSec = 60 },
	[7] = { Price = 25000, DollarsPerSec = 70 },
	[8] = { Price = 50000, DollarsPerSec = 80 },
	[9] = { Price = 100000, DollarsPerSec = 90 },
	[10] = { Price = 500000, DollarsPerSec = 100 },
	[11] = { Price = 1_000_000, DollarsPerSec = 150 },
	[12] = { Price = 2_000_000, DollarsPerSec = 200 },
	[13] = { Price = 5_000_000, DollarsPerSec = 300 },
	[14] = { Price = 10_000_000, DollarsPerSec = 400 },
	[15] = { Price = 20_000_000, DollarsPerSec = 500 },
	[16] = { Price = 50_000_000, DollarsPerSec = 750 },
	[17] = { Price = 80_000_000, DollarsPerSec = 1000 },
	[18] = { Price = 130_000_000, DollarsPerSec = 1250 },
	[19] = { Price = 200_000_000, DollarsPerSec = 1500 },
	[20] = { Price = 250_000_000, DollarsPerSec = 1750 },
	[21] = { Price = 500_000_000, DollarsPerSec = 2000 },
	[22] = { Price = 1_000_000_000, DollarsPerSec = 2500 },
	[23] = { Price = 2_500_000_000, DollarsPerSec = 3000 },
	[24] = { Price = 5_000_000_000, DollarsPerSec = 4000 },
	[25] = { Price = 10_000_000_000, DollarsPerSec = 5000 },
}

-- Хелперы

function PrinterConfig.GetDollarsPerSec(level: number): number
	local entry = PrinterConfig.Levels[level]
	if not entry then
		return 0
	end
	return entry.DollarsPerSec
end

function PrinterConfig.GetUpgradeCost(currentLevel: number): number?
	local nextLevel = currentLevel + 1
	local entry = PrinterConfig.Levels[nextLevel]
	if not entry then
		return nil -- уже на максимуме
	end
	return entry.Price
end

function PrinterConfig.IsMaxLevel(level: number): boolean
	return level >= PrinterConfig.MAX_LEVEL
end

return PrinterConfig
