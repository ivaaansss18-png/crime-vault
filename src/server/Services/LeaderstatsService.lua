--!strict
-- CRIME VAULT — LeaderstatsService
-- Создаёт стандартный Roblox leaderstats для отображения денег в правом верхнем углу.
-- Синхронизирует Money с профилем через PlayerDataService:GetChangedSignal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LeaderstatsService = Knit.CreateService({
	Name = "LeaderstatsService",
	Client = {},
})

function LeaderstatsService:KnitStart()
	local PlayerDataService = Knit.GetService("PlayerDataService")

	local function setup(player: Player)
		local profile = PlayerDataService:WaitFor(player, 10)
		if not profile then
			warn("[LeaderstatsService] Profile not loaded for " .. player.Name)
			return
		end

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"

		local money = Instance.new("IntValue")
		money.Name = "Money"
		money.Value = profile.Data.Money
		money.Parent = leaderstats

		leaderstats.Parent = player

		-- Подписываемся на изменения профиля → обновляем leaderstat
		local signal = PlayerDataService:GetChangedSignal(player)
		if signal then
			signal:Connect(function(data)
				money.Value = data.Money
			end)
		end
	end

	Players.PlayerAdded:Connect(setup)

	-- Догнать тех, кто уже на сервере (актуально при hot-reload в Studio)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setup, player)
	end
end

return LeaderstatsService
