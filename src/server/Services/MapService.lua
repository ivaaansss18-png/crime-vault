--!strict
-- CRIME VAULT — MapService
-- Гарантирует наличие базовых элементов карты при старте сервера.
-- На ранних этапах это просто Baseplate, чтобы было на чём стоять.
-- Позже сюда переедет генерация плотов и общих зон (тюрьма, нейтральная зона).

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BASEPLATE_NAME = "Baseplate"
local BASEPLATE_SIZE = Vector3.new(2048, 1, 2048)
local BASEPLATE_POSITION = Vector3.new(0, 0, 0)

local MapService = Knit.CreateService({
	Name = "MapService",
	Client = {},
})

function MapService:KnitInit()
	-- Если Baseplate уже есть в сцене — ничего не делаем.
	local existing = Workspace:FindFirstChild(BASEPLATE_NAME)
	if existing and existing:IsA("BasePart") then
		print("[MapService] Baseplate уже есть в сцене, пропускаем создание")
		return
	end

	local baseplate = Instance.new("Part")
	baseplate.Name = BASEPLATE_NAME
	baseplate.Size = BASEPLATE_SIZE
	baseplate.Position = BASEPLATE_POSITION
	baseplate.Anchored = true
	baseplate.Material = Enum.Material.Grass
	baseplate.Color = Color3.fromRGB(56, 130, 56)
	baseplate.TopSurface = Enum.SurfaceType.Smooth
	baseplate.BottomSurface = Enum.SurfaceType.Smooth
	baseplate.Locked = true
	baseplate.Parent = Workspace

	print("[MapService] Baseplate создан программно (2048×1×2048 у (0,0,0))")
end

return MapService
