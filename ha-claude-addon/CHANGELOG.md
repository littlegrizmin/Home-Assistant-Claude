# Changelog

## [1.1.0] - 2026-06-15

### Fixed
- tmux session persistence — browser tab switch no longer resets the terminal session
- s6-overlay v3 service registration (service was not starting after cont-init)
- Terminal width set to 220 columns so `claude login` URL fits on one line and is clickable
- Script permissions (Permission denied on cont-init scripts)
- Death count tracking moved to `/data/watchdog/` (persistent across restarts)

### Added
- Copy/paste shortcuts shown in terminal welcome message (`Ctrl+Shift+C` / `Ctrl+Shift+V`)

## [1.0.0] - 2026-06-14

### Added
- Initial release
- Claude Code CLI running inside Home Assistant via ttyd web terminal
- tmux session support for persistent terminal across browser refreshes
- Auth persistence via `/root/.claude → /data/claude/` symlink
- hass-mcp integration for structured HA entity/service access
- Watchdog with configurable max crash count
- Ingress panel in HA sidebar
- Multi-arch support: amd64 and aarch64
