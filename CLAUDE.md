# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Directory Opus configuration backup. Files here are a clean snapshot for version control and portability — NOT the live installation.

## Directory to target mapping

| Repo dir | Target path |
|---|---|
| `program/` | `D:\Tools\Directory Opus\` (dopus.dat, Images, Language — configs only) |
| `settings/` | `%APPDATA%\GPSoftware\Directory Opus\` (buttons, layouts, prefs, scripts, themes) |
| `state/` | `%LOCALAPPDATA%\GPSoftware\Directory Opus\State Data\` (window state, recent, search) |

## Excluded from backup

- Install dir: `.exe`, `.dll`, `.bak` — program binaries
- AppData: `Icon Cache Roaming/`, `Logs/` — caches
- LocalAppData: `Icon Cache/`, `Thumbnail Cache/`, `Help Cache/` — caches

## Updating the backup

```powershell
# program
Copy-Item D:\Tools\Directory Opus\dopus.dat, Images, Language, Policies program/ -Recurse

# settings
Copy-Item $env:APPDATA\GPSoftware\Directory Opus\* settings/ -Recurse -Exclude "Icon Cache Roaming","Logs"

# state
Copy-Item $env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data\* state/ -Recurse
```

## Critical rules

- NEVER run destructive commands (rm, mv) inside `D:\Tools\Directory Opus\` or any AppData path
- Create a separate temp directory for any restructuring work
- Ask user permission before deleting any file outside this repo
