# HA Claude Addon Documentation

## Installation Instructions

1. **Add the repository** to your Home Assistant installation:
   - Go to Settings → Add-ons → Add-on Store
   - Click the three dots menu → Repositories
   - Add this repository URL and click OK

2. **Install the addon**:
   - Search for "Claude Code" in the add-on store
   - Click on the addon and then "Install"

3. **Configure the addon**:
   - Go to Settings → Add-ons → Claude Code → Configuration
   - Set your preferred options:
     - `watchdog_enabled`: Enable automatic restart if the service crashes (default: true)
     - `auto_start_claude`: Automatically start the service on boot (default: true)
     - `font_size`: Terminal font size in pixels (8-32, default: 14)
     - `theme`: Terminal theme "dark" or "light" (default: dark)
     - `tmux_enabled`: Enable terminal multiplexer for session persistence (default: true)
     - `scrollback_lines`: Terminal scrollback buffer size (1000-50000, default: 5000)

4. **Start the addon**:
   - Click "Start" to begin the service
   - Wait for initialization to complete

## Initial Claude Login

The first time you start the addon, you'll need to authenticate with Claude:

1. Start the addon and wait for it to initialize
2. Access the web interface via Settings → Add-ons → Claude Code → Web UI
3. You'll see a welcome message with instructions
4. Follow the on-screen prompts to authenticate with your Anthropic account
5. Once authenticated, you can use the terminal interface

The authentication process requires:
- An active Anthropic API key or account credentials
- Internet connectivity for initial authentication
- A modern web browser (Chrome, Firefox, Edge recommended)

## Useful Shortcuts

### Terminal Shortcuts (if tmux is enabled):
| Shortcut | Action |
|----------|--------|
| `Ctrl+b` then `c` | Create new window |
| `Ctrl+b` then `n` | Next window |
| `Ctrl+b` then `p` | Previous window |
| `Ctrl+b` then `"` | Split pane horizontally |
| `Ctrl+b` then `%` | Split pane vertically |
| `Ctrl+b` then arrow keys | Switch between panes |

### Claude Code Shortcuts:
| Shortcut | Action |
|----------|--------|
| `Tab` | Auto-complete command/file suggestions |
| `Esc` | Cancel current operation or exit prompt |
| `Ctrl+c` | Interrupt current process |
| `Ctrl+d` | Exit terminal session |

### Web Interface Shortcuts:
| Shortcut | Action |
|----------|--------|
| `F11` | Toggle fullscreen mode |
| `Ctrl+f` | Find in terminal output |
| `Ctrl+r` | Reload page (if needed) |

## Troubleshooting

- **Service not starting**: Check the addon logs for errors under Settings → Add-ons → Claude Code → Logs
- **Authentication issues**: Ensure your internet connection is stable and Anthropic service status is normal
- **Performance problems**: Try adjusting font_size or disabling tmux if experiencing lag
- **Connection refused**: Verify that port 7681 (ingress) is accessible in your network configuration

## Additional Information

- The addon uses S6-overlay for process management with built-in watchdog functionality
- All data is stored within the Home Assistant container environment
- Regular updates are recommended to stay current with Claude API changes
- For advanced configuration, refer to the dev_plan.md file in the repository