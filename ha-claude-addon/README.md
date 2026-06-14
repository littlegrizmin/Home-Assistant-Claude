# Claude Code — Home Assistant Addon

> **Disclaimer:** This is an **unofficial, community-made addon** and is not affiliated with, endorsed by, or supported by Anthropic. Claude and Claude Code are trademarks of Anthropic, PBC. Use at your own risk.

A Home Assistant addon that runs [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) directly on your HA machine and exposes it as an interactive terminal inside the HA UI — no SSH, no separate applications required.

Claude has full read/write access to your Home Assistant config directory (`/homeassistant/`), including automations, scripts, `configuration.yaml`, and everything else.

![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Supervised-blue)
![Architecture](https://img.shields.io/badge/arch-amd64%20%7C%20aarch64-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

---

## How It Works

```
HA UI (browser)
    └── Claude Code panel
            └── Interactive terminal
                    └── Claude Code CLI
                            └── /homeassistant/  ← your entire HA config
```

Open the panel in HA, type commands to Claude, and it reads/edits your automations directly.

---

## Requirements

- **Home Assistant Supervised** on Linux (Ubuntu, Debian, etc.)
- **claude.ai account** (Free, Pro, or Max) — no API key required
- Architecture: **amd64** (Intel/AMD) or **aarch64** (Raspberry Pi 4/5)

---

## Installation

### 1. Add the repository

In Home Assistant:
**Settings → Add-ons → Add-on Store → ⋮ → Repositories**

Add this URL:
```
https://github.com/littlegrizmin/Home-Assistant-Claude
```

### 2. Install the addon

Find **"Claude Code"** in the Add-on Store → click **Install**.

### 3. Start the addon

Click **Start**. The addon will initialize and appear as a panel in the left sidebar.

### 4. First login (one time only)

Open the **Claude Code** panel in HA and type in the terminal:

```
claude login
```

You'll receive a URL → open it in your browser → sign in with your claude.ai account → done.

**Authentication persists between restarts** — no need to log in again.

---

## Configuration

| Option | Default | Description |
|---|---|---|
| `watchdog_enabled` | `true` | Automatically restart the addon on crash |
| `auto_start_claude` | `true` | Launch `claude` immediately when the terminal opens |
| `font_size` | `14` | Terminal font size (8–32) |
| `theme` | `dark` | Terminal theme: `dark` or `light` |
| `tmux_enabled` | `true` | Persistent session — keeps your work on browser refresh |
| `scrollback_lines` | `5000` | Number of lines kept in terminal history |
| `max_death_tally` | `3` | Number of restarts before the watchdog gives up |

---

## Useful Commands

```bash
# Check Claude Code version
claude --version

# Start a new Claude session
claude

# Re-authenticate
claude login

# Show current configuration
claude config list
```

### Terminal copy/paste

| Action | Shortcut |
|---|---|
| Copy | Select text with mouse, or `Ctrl+Shift+C` |
| Paste | Right-click, or `Ctrl+Shift+V` |

### tmux shortcuts (when `tmux_enabled: true`)

| Key | Action |
|---|---|
| `Ctrl+b c` | New window |
| `Ctrl+b n / p` | Next / previous window |
| `Ctrl+b "` | Split pane horizontally |
| `Ctrl+b %` | Split pane vertically |
| `Ctrl+b d` | Detach session (Claude keeps running in background) |

---

## How It Works Under the Hood

**Auth persistence:**
On every start, the addon creates a symlink `/root/.claude → /data/claude/`. The `/data/` directory is the addon's persistent storage — it survives restarts and updates.

**MCP integration:**
The addon automatically registers Home Assistant as an MCP server in Claude, giving it structured access to entities, services, and automations.

**Watchdog:**
S6-overlay monitors the ttyd process. On crash it restarts automatically. After `max_death_tally` consecutive failures it stops and logs the error.

---

## Troubleshooting

**Addon won't start**
→ Settings → Add-ons → Claude Code → **Logs**

**"Not authenticated"**
→ Open the terminal → run `claude login`

**Terminal resets on browser refresh**
→ Enable `tmux_enabled: true` in addon settings

**Claude can't see HA files**
→ Verify the addon has `config:rw` in its volume mapping (enabled by default)

**`claude login` URL is split across multiple lines**
→ The terminal is set to 220 columns — if it still wraps, zoom out your browser slightly

---

## License

MIT — see [LICENSE](LICENSE)
