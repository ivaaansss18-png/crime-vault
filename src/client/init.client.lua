--!strict
-- CRIME VAULT — клиентский entry point.
-- Поднимает Knit и регистрирует все контроллеры из папки Controllers.

print("[CRIME VAULT] Client bootstrap starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Папка Controllers появится на Этапе 1 День 2 (HUDController)
local controllersFolder = script:FindFirstChild("Controllers")
if controllersFolder then
	Knit.AddControllers(controllersFolder)
end

Knit.Start()
	:andThen(function()
		print("[CRIME VAULT] Knit client started")
	end)
	:catch(function(err)
		warn("[CRIME VAULT] Knit client start failed:", err)
	end)

print("[CRIME VAULT] Client bootstrap finished.")
