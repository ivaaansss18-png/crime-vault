--!strict
-- CRIME VAULT — PlayerDataService
-- Обёртка над ProfileStore. Загружает/сохраняет профиль игрока, держит сессионные локи.
-- Источник истины по полям профиля: CLAUDE.md → секция «СОХРАНЕНИЕ ДАННЫХ».

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

local Constants = require(ReplicatedStorage.Shared.Constants)

-- Если хотим обнулить всем профиль (например, после ломающего изменения схемы) —
-- увеличиваем версию в имени стора, старые данные останутся в DataStore-е под старым ключом.
local PROFILE_STORE_NAME = "PlayerData_v1"

local PROFILE_TEMPLATE = {
	-- Деньги и прогресс
	Money = Constants.START_MONEY,
	PrinterLevel = 1,

	-- Rebirth
	RebirthLevel = 0,
	RebirthPoints = 0,
	RPShopUpgrades = {},

	-- Инвентарь
	Inventory = {
		Weapons = {}, -- [weaponId] = true
		Armor = nil, -- "Light" | "Medium" | "Heavy" | nil
		Ammo = {}, -- [ammoType] = count
	},

	-- Состояние плота (для Tycoon-Builder, Этап 7)
	PlotState = {
		Buildings = {}, -- массив { buildingId, posX, posY, posZ, rotY, customColor }
	},

	-- Защита (быстрый lookup, конкретика в Buildings)
	Defense = {
		Cameras = {},
		Lasers = {},
		Traps = {},
		Guards = {},
	},

	-- Статистика
	Stats = {
		TotalRobbed = 0,
		TimesRobbed = 0,
		Kills = 0,
		Deaths = 0,
		JailTime = 0,
		TotalMoneyEarned = 0,
		RebirthsCompleted = 0,
	},

	-- Достижения
	Achievements = {},

	-- Косметика
	Cosmetics = {
		Title = nil,
		WeaponSkins = {},
		BaseTheme = "default",
	},

	-- Время
	FirstJoinTime = 0,
	LastSeenTime = 0,
	TotalPlaytime = 0,

	-- Оффлайн-доход (применяется при следующем входе)
	PendingOfflineIncome = 0,
}

local PlayerDataService = Knit.CreateService({
	Name = "PlayerDataService",
	Client = {},

	_profileStore = nil :: any,
	_profiles = {} :: { [Player]: any },
	_changedSignals = {} :: { [Player]: any },
})

function PlayerDataService:KnitInit()
	self._profileStore = ProfileStore.New(PROFILE_STORE_NAME, PROFILE_TEMPLATE)
end

function PlayerDataService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		self:_loadProfile(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_releaseProfile(player)
	end)

	-- Догнать игроков, которые зашли до старта Knit
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:_loadProfile(player)
		end)
	end
end

function PlayerDataService:_loadProfile(player: Player)
	local profile = self._profileStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		player:Kick("[CRIME VAULT] Не удалось загрузить профиль. Перезайди.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		self._profiles[player] = nil
		player:Kick("[CRIME VAULT] Профиль занят другой сессией. Перезайди.")
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	-- Первый вход — фиксируем время
	if profile.Data.FirstJoinTime == 0 then
		profile.Data.FirstJoinTime = os.time()
	end
	profile.Data.LastSeenTime = os.time()

	self._profiles[player] = profile
	self._changedSignals[player] = Signal.new()

	-- Сразу фаерим, чтобы подписчики получили начальное состояние
	self._changedSignals[player]:Fire(profile.Data)

	print(
		string.format(
			"[CRIME VAULT] Profile loaded: %s — $%d, Printer Lv%d, Rebirth %d",
			player.Name,
			profile.Data.Money,
			profile.Data.PrinterLevel,
			profile.Data.RebirthLevel
		)
	)
end

function PlayerDataService:_releaseProfile(player: Player)
	local profile = self._profiles[player]
	if profile then
		profile.Data.LastSeenTime = os.time()
		profile:EndSession()
	end
	local signal = self._changedSignals[player]
	if signal then
		signal:Destroy()
		self._changedSignals[player] = nil
	end
end

-- ═══════════════════════ ПУБЛИЧНЫЙ API (для других сервисов) ═══════════════════════

-- Получить профиль игрока (или nil если ещё не загружен / уже выгружен).
function PlayerDataService:Get(player: Player)
	return self._profiles[player]
end

-- Дождаться загрузки профиля с таймаутом. Возвращает profile или nil.
function PlayerDataService:WaitFor(player: Player, timeout: number?): any
	local deadline = os.clock() + (timeout or 10)
	while os.clock() < deadline do
		local profile = self._profiles[player]
		if profile then
			return profile
		end
		task.wait(0.1)
	end
	return nil
end

-- Атомарно обновить данные профиля.
-- fn получает profile.Data и может его мутировать. После выполнения fn фаерится Changed.
function PlayerDataService:Update(player: Player, fn: (any) -> ())
	local profile = self._profiles[player]
	if not profile then
		return
	end
	fn(profile.Data)
	local signal = self._changedSignals[player]
	if signal then
		signal:Fire(profile.Data)
	end
end

-- Сигнал на изменения профиля. Фаерится с (profile.Data) при каждом Update + при первой загрузке.
function PlayerDataService:GetChangedSignal(player: Player)
	return self._changedSignals[player]
end

return PlayerDataService
