--!strict
-- CRIME VAULT — централизованные константы.
-- Источник истины: CLAUDE.md (раздел «ЭКОНОМИКА»).
-- Любое расхождение с CLAUDE.md = баг.

local Constants = {}

-- ═══════════════ СТАРТ ═══════════════
Constants.START_MONEY = 10000
Constants.START_HP = 100
Constants.START_WALK_SPEED = 16

-- ═══════════════ ГРАБЁЖ ═══════════════
Constants.HEIST_REWARD_PERCENT = 0.50          -- % от хранилища жертвы
Constants.HEIST_TRANSIT_LOSS = 0.30            -- % теряется в пути → нетто 35%
Constants.HEIST_TIMER_SECONDS = 10 * 60        -- 10 мин на грабёж
Constants.HEIST_BASE_COOLDOWN_SECONDS = 8 * 60 -- 8 мин кулдаун на одну базу
Constants.JAIL_DURATION_SECONDS = 2 * 60       -- 2 мин в тюрьме
Constants.POST_JAIL_INVULN_SECONDS = 60        -- 1 мин неуязвимости после тюрьмы

-- ═══════════════ ОФФЛАЙН-ДОХОД ═══════════════
Constants.OFFLINE_INCOME_RATE = 0.10           -- 10% от $/сек
Constants.OFFLINE_INCOME_CAP_SECONDS = 12 * 60 * 60  -- 12 часов

-- ═══════════════ ЗАЩИТА НОВИЧКОВ ═══════════════
-- До Rebirth 1 игрока нельзя грабить, и он сам грабить не может.
Constants.NEWBIE_PROTECTION_REBIRTH_THRESHOLD = 1

-- ═══════════════ ПОСТРОЙКА (Tycoon-Builder) ═══════════════
Constants.PLOT_SIZE_STUDS = 80
Constants.MAX_BUILDINGS_PER_PLOT = 150
Constants.MAX_BUILD_HEIGHT_STUDS = 50
Constants.BUILD_GRID_STEP = 1                  -- snap-to-grid в studs
Constants.BUILD_REFUND_RATE = 0.80             -- возврат при сносе (80%)
Constants.BUILD_RATE_LIMIT_PER_SEC = 5

-- ═══════════════ RATE LIMITS (anti-cheat) ═══════════════
Constants.RATE_LIMIT_SHOTS_PER_SEC = 10
Constants.RATE_LIMIT_PURCHASES_PER_SEC = 2

return Constants
