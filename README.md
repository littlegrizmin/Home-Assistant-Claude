# Claude Code — Home Assistant Addon

Addon за Home Assistant, който стартира [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) директно на твоята HA машина и го прави достъпен като интерактивен терминал в HA UI — без SSH, без отделни приложения.

Claude има достъп до целия Home Assistant конфиг (`/homeassistant/`), може да чете и редактира автоматизации, скриптове, `configuration.yaml` и всичко останало.

![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Supervised-blue)
![Architecture](https://img.shields.io/badge/arch-amd64%20%7C%20aarch64-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Как изглежда

```
HA UI (браузър)
    └── Claude Code panel
            └── Интерактивен терминал
                    └── Claude Code CLI
                            └── /homeassistant/  ← целият HA конфиг
```

Отваряш панела в HA, пишеш команди на Claude, той чете/редактира твоите автоматизации.

---

## Изисквания

- **Home Assistant Supervised** на Linux (Ubuntu, Debian и др.)
- **claude.ai акаунт** (Free, Pro или Max) — не се изисква API ключ
- Архитектура: **amd64** (Intel/AMD) или **aarch64** (Raspberry Pi 4/5)

---

## Инсталация

### 1. Добави репозитория

В Home Assistant:
**Settings → Add-ons → Add-on Store → ⋮ → Repositories**

Добави URL:
```
https://github.com/littlegrizmin/Home-Assistant-Claude
```

### 2. Инсталирай addon-а

Намери **"Claude Code"** в Add-on Store → **Install**.

### 3. Стартирай

Натисни **Start**. Addon-ът ще стартира и ще е достъпен като панел в лявото меню.

### 4. Първи вход (само веднъж)

Отвори панела **Claude Code** в HA → пишеш в терминала:

```
claude login
```

Ще получиш URL → отвори го в браузъра → влез с claude.ai акаунта си → готово.

**Auth-ът се запазва между рестарти** — не е нужно да се логваш отново.

---

## Настройки

| Настройка | По подразбиране | Описание |
|---|---|---|
| `watchdog_enabled` | `true` | Рестартира addon-а при crash |
| `auto_start_claude` | `true` | Стартира `claude` веднага при отваряне на терминала |
| `font_size` | `14` | Размер на шрифта в терминала (8–32) |
| `theme` | `dark` | Тема на терминала: `dark` или `light` |
| `tmux_enabled` | `true` | Persistent сесия — не губиш работата при refresh на страницата |
| `scrollback_lines` | `5000` | Брой редове история в терминала |
| `max_death_tally` | `3` | Брой рестарти преди watchdog-ът се отказва |

---

## Полезни команди в терминала

```bash
# Провери версията на Claude Code
claude --version

# Стартирай нова Claude сесия
claude

# Ре-аутентикирай се
claude login

# Виж конфигурацията
claude config list
```

### tmux shortcuts (при `tmux_enabled: true`)

| Клавиш | Действие |
|---|---|
| `Ctrl+b c` | Нов прозорец |
| `Ctrl+b n / p` | Следващ / предишен прозорец |
| `Ctrl+b "` | Раздели хоризонтално |
| `Ctrl+b %` | Раздели вертикално |
| `Ctrl+b d` | Откачи сесията (Claude продължава да работи) |

---

## Как работи

**Auth persistence:**
При всеки старт addon-ът създава symlink `/root/.claude → /data/claude/`. Папката `/data/` е persistent storage на addon-а — оцелява при рестарти и ъпдейти.

**MCP интеграция:**
Addon-ът автоматично регистрира Home Assistant като MCP сървър в Claude. Това дава на Claude директен достъп до entities, services и automations чрез структурирани инструменти.

**Watchdog:**
S6-overlay следи ttyd процеса. При crash се рестартира автоматично. След `max_death_tally` поредни провала спира и логва грешката.

---

## Troubleshooting

**Addon не стартира**
→ Settings → Add-ons → Claude Code → **Logs**

**"Not authenticated"**
→ Отвори терминала → `claude login`

**Терминалът се затваря при refresh**
→ Включи `tmux_enabled: true` в настройките

**Claude не вижда HA файловете**
→ Провери дали addon-ът има `config:rw` в мапинга (по подразбиране е включено)

---

## Лиценз

MIT — виж [LICENSE](LICENSE)
