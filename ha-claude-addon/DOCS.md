# Claude Code — Home Assistant Addon Documentation

## Installation

1. **Add the repository** to your Home Assistant installation:
   - Go to **Settings → Add-ons → Add-on Store**
   - Click the three-dot menu → **Repositories**
   - Add `https://github.com/littlegrizmin/Home-Assistant-Claude` and click OK

2. **Install the addon:**
   - Search for **"Claude Code"** in the Add-on Store
   - Click the addon, then click **Install**

3. **Configure the addon:**
   - Go to **Settings → Add-ons → Claude Code → Configuration**
   - Adjust options as needed (all have sensible defaults)

4. **Start the addon:**
   - Click **Start**
   - The Claude Code panel will appear in the left sidebar

---

## First Login

The first time you start the addon you need to authenticate with your claude.ai account:

1. Open the **Claude Code** panel in HA
2. Type `claude login` in the terminal and press Enter
3. A URL will appear — open it in your browser
4. Sign in with your claude.ai account (Free, Pro, or Max)
5. Authentication is saved to `/data/claude/` and persists across restarts

**No API key is required.** This addon uses your claude.ai account subscription.

---

## Configuration Options

| Option | Default | Description |
|---|---|---|
| `watchdog_enabled` | `true` | Restart the addon automatically on crash |
| `auto_start_claude` | `true` | Launch `claude` immediately when terminal opens |
| `font_size` | `14` | Terminal font size (8–32 px) |
| `theme` | `dark` | Terminal color theme: `dark` or `light` |
| `tmux_enabled` | `true` | Keep session alive across browser refreshes |
| `scrollback_lines` | `5000` | Lines of terminal history to retain (1000–50000) |
| `max_death_tally` | `3` | Max consecutive crashes before watchdog stops restarting (1–10) |

---

## Terminal Shortcuts

### tmux (when `tmux_enabled: true`)

| Shortcut | Action |
|---|---|
| `Ctrl+b c` | Create new window |
| `Ctrl+b n` | Switch to next window |
| `Ctrl+b p` | Switch to previous window |
| `Ctrl+b "` | Split pane horizontally |
| `Ctrl+b %` | Split pane vertically |
| `Ctrl+b` + arrow keys | Navigate between panes |
| `Ctrl+b d` | Detach session (keeps running in background) |

### Claude Code

| Shortcut | Action |
|---|---|
| `Tab` | Autocomplete command or filename |
| `Esc` | Cancel current operation |
| `Ctrl+c` | Interrupt running process |
| `Ctrl+d` | Exit terminal session |

---

## Troubleshooting

**Addon does not start**
Check the logs: Settings → Add-ons → Claude Code → **Logs**

**"Not authenticated" or claude login required**
Run `claude login` in the terminal and follow the URL shown.

**Session lost on browser refresh**
Enable `tmux_enabled: true` in the addon configuration. With tmux, closing the browser tab does not terminate the Claude session.

**Claude cannot see or edit HA files**
The addon mounts the HA config directory at `/homeassistant/` with read-write access by default. If you see permission errors, check that the addon has `config:rw` in Settings → Add-ons → Claude Code → Info.

**Addon keeps restarting**
Check `watchdog_enabled` and `max_death_tally` settings. If the process is crashing repeatedly, review the logs for the root cause before increasing the tally limit.

**Re-authenticate after logout**
Run `claude login` again. Auth data is stored in `/data/claude/` and survives addon restarts. To fully reset authentication, stop the addon and delete `/data/claude/` via the HA file editor or SSH.
