--!strict
-- CRIME VAULT — серверный entry point.
-- Поднимает Knit и регистрирует все сервисы из папки Services.

print("[CRIME VAULT] Server bootstrap starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServices(script.Services)

Knit.Start()
	:andThen(function()
		print("[CRIME VAULT] Knit started — all services initialized")
	end)
	:catch(function(err)
		warn("[CRIME VAULT] Knit start failed:", err)
	end)

print("[CRIME VAULT] Server bootstrap finished.")
