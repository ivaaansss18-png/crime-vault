# CRIME VAULT

Roblox Tycoon-Builder + Heist Simulator.

> 📖 **Дизайн-документ** — единственный источник истины: [`CLAUDE.md`](./CLAUDE.md).
> Любые расхождения между кодом и дизайн-доком = баг.

---

## 🚀 Quick Start (для второго разработчика)

### 1. Установить тулинг

**Aftman** (менеджер версий для Rojo/Wally) — ставится один раз глобально:
- Windows: скачать [`aftman-windows.zip`](https://github.com/LPGhatguy/aftman/releases/latest), распаковать `aftman.exe` в `C:\Users\<you>\bin\`, добавить эту папку в PATH.
- Проверить: `aftman --version`

### 2. Клонировать репо

```powershell
git clone https://github.com/<owner>/crime-vault.git
cd crime-vault
aftman install      # подтянет rojo и wally нужных версий
wally install       # подтянет пакеты (ProfileStore, Knit, TestEZ)
```

### 3. Подключить Studio через Rojo

1. В Roblox Studio: установить плагин **Rojo** (через Toolbox или с https://rojo.space).
2. В терминале репозитория:
   ```powershell
   rojo serve
   ```
3. В Studio: открыть Rojo plugin → Connect (localhost:34872).
4. Готово — изменения скриптов в VS Code мгновенно синкаются в Studio.

### 4. VS Code

Рекомендуемые расширения подсказаны в `.vscode/extensions.json`.

---

## 📁 Структура

```
src/
├── server/      → ServerScriptService.Server
├── client/      → StarterPlayer.StarterPlayerScripts.Client
├── shared/      → ReplicatedStorage.Shared (доступно и серверу и клиенту)
└── gui/         → StarterGui
assets/          → .rbxm бэкапы моделей (коммитятся)
docs/            → внутренняя документация
```

## 🔀 Git-workflow

- `main` — стабильная beta-готовая ветка
- `dev` — текущая работа
- `feat/<name>` — фичебранчи, мержатся в `dev` через PR
- Никаких force-push в `main`

## 🧪 Тесты

```powershell
# TODO: настроить run-script для TestEZ через Lemur/Lune
```

## 📞 Команда

- Разработчик 1: _TODO_
- Разработчик 2: _TODO_
- AI: Claude Code
