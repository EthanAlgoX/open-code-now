# OpenCode Now

Quick launcher utility for [OpenCode](https://github.com/opencode-ai/opencode) - eliminates repetitive terminal commands when starting OpenCode in different directories.

**English** | [中文](README.zh.md)

---

## Overview

**Problem**: Starting OpenCode requires opening a terminal, navigating to the target directory, and typing commands each time.

**Solution**: OpenCode Now provides platform-native launchers (macOS app, Windows context menu) that detect your OpenCode installation and launch it instantly in the desired directory.

### Key Capabilities

| Feature | Implementation |
| :--- | :--- |
| **Auto-detection** | Searches npm, yarn, pnpm, nvm, Go bin, and system paths |
| **Context-aware** | Launches in current Finder window or specified directory |
| **Terminal agnostic** | Supports iTerm2, Warp, Kitty, Alacritty, Terminal.app |
| **Permission bypass** | Uses `--dangerously-skip-permissions` flag |
| **Cross-platform** | macOS (app bundle + shell) and Windows (PowerShell + batch) |

---

## Requirements

- **OpenCode CLI** must be installed and accessible in your PATH

```bash
# Install OpenCode (example - adjust for actual installation method)
go install github.com/opencode-ai/opencode@latest

# Verify
which opencode
opencode --version
```

---

## Quick Start

### macOS

#### Method 1: App Bundle (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/EthanAlgoX/open-code-now.git
cd open-code-now

# 2. Set executable permissions
chmod +x "OpenCode Now.app/Contents/MacOS/OpenCodeLauncher"

# 3. Copy to Applications folder
cp -R "OpenCode Now.app" /Applications/

# 4. Refresh icon cache (if icon doesn't appear)
killall Finder

# 5. Launch methods:
#    - **Launchpad**: Search and click OpenCode Now
#    - **Dock**: Drag from Applications to Dock, click to launch
#    - **Finder Toolbar**: Hold ⌘ and drag app to toolbar for folder-specific launches
```

#### Method 2: Shell Script (Command Line)

```bash
# 1. Clone repository
git clone https://github.com/EthanAlgoX/open-code-now.git
cd open-code-now

# 2. Set executable permissions
chmod +x macos/opencode-now.sh

# 3. Direct execution (specify directory)
./macos/opencode-now.sh ~/Documents/MyProject

# Or install globally (callable from anywhere)
sudo cp macos/opencode-now.sh /usr/local/bin/opencode-now
# Usage: opencode-now /path/to/project
```

### Windows

```powershell
# 1. Clone or download repository
# 2. Run installation
.\windows\install.bat

# 3. (Optional) Add context menu integration
.\windows\install-context-menu.bat  # Run as Administrator

# Usage: Right-click any folder → "OpenCode Now"
```

---

## Architecture

### macOS Components

```text
OpenCode Now.app/
├── Contents/
│   ├── Info.plist              # Bundle metadata, CFBundleIdentifier: com.opencode.launcher
│   └── MacOS/
│       └── OpenCodeLauncher    # Launcher script (detects Finder window, terminal preference)

macos/
├── opencode-now.sh             # Core launcher (PATH detection, OpenCode execution)
└── set-terminal.sh             # Terminal preference configuration
```

**Execution Flow**:

1. App launched → `OpenCodeLauncher` executes
2. Detects current Finder window path via AppleScript
3. Reads terminal preference from `~/.opencode-now-terminal`
4. Calls `opencode-now.sh` with target directory
5. Script searches for OpenCode binary (npm/yarn/pnpm/nvm/Go)
6. Launches OpenCode with `--dangerously-skip-permissions`

### Windows Components

```text
windows/
├── opencode-now.ps1            # PowerShell launcher (OpenCode detection + execution)
├── install.bat                 # Copies script to %USERPROFILE%\bin
├── install-context-menu.bat    # Registry modifications for right-click menu
├── uninstall-context-menu.bat  # Registry cleanup
└── diagnose.bat                # Environment diagnostics
```

**Registry Keys** (Context Menu):

- `HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow`
- `HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow`
- `HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow`

---

## Configuration

### Terminal Preference (macOS)

```bash
./macos/set-terminal.sh
```

Stores preference in `~/.opencode-now-terminal`. Auto-detects if not set.

**Priority**: iTerm2 → Warp → Kitty → Alacritty → Terminal.app

### Last Directory Memory

Both macOS and Windows remember the last-used directory:

- **macOS**: `~/.opencode-now-last-dir`
- **Windows**: `%USERPROFILE%\.opencode-now-last-dir`

---

## Troubleshooting

### OpenCode Not Found

**Search Paths** (in order):

1. Current `$PATH` / `%PATH%`
2. Package manager global bins (npm, yarn, pnpm)
3. nvm Node.js versions (`~/.nvm/versions/node/*/bin`)
4. Common installation directories:
   - macOS: `~/.local/bin`, `/usr/local/bin`, `/opt/homebrew/bin`, `~/go/bin`
   - Windows: `%APPDATA%\npm`, `%LOCALAPPDATA%\npm`, `%USERPROFILE%\go\bin`

**Diagnostics**:

```bash
# macOS: Run launcher in terminal to see search output
./macos/opencode-now.sh

# Windows: Run diagnostic tool
.\windows\diagnose.bat
```

### Permission Errors (macOS)

```bash
# Fix executable permissions
chmod +x macos/opencode-now.sh
chmod +x macos/set-terminal.sh
chmod +x "OpenCode Now.app/Contents/MacOS/OpenCodeLauncher"
```

### Context Menu Not Appearing (Windows)

1. Verify script installation: Check `%USERPROFILE%\bin\opencode-now.ps1` exists
2. Re-run `install-context-menu.bat` as Administrator
3. Restart Explorer: `taskkill /f /im explorer.exe && start explorer.exe`

---

## Development

### Project Structure

```text
.
├── macos/
│   ├── opencode-now.sh          # Launcher implementation
│   └── set-terminal.sh          # Terminal config utility
├── windows/
│   ├── opencode-now.ps1         # PowerShell launcher
│   ├── install.bat              # Installation script
│   ├── install-context-menu.bat # Context menu setup
│   ├── uninstall-context-menu.bat
│   └── diagnose.bat             # Diagnostic tool
├── OpenCode Now.app/            # macOS app bundle
│   └── Contents/
│       ├── Info.plist
│       └── MacOS/OpenCodeLauncher
├── README.md
├── README.zh.md
└── .gitignore
```

### Testing

```bash
# macOS: Syntax check
bash -n macos/opencode-now.sh
bash -n macos/set-terminal.sh

# Validate Info.plist
plutil -lint "OpenCode Now.app/Contents/Info.plist"

# Test launcher (dry run)
./macos/opencode-now.sh /tmp
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Test on target platform(s)
4. Submit pull request with description of changes

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Technical Notes

- **CLI Flag**: Uses `--dangerously-skip-permissions` instead of interactive prompts
- **Bundle ID**: `com.opencode.launcher` (macOS)
- **Minimum macOS**: 10.13 (High Sierra)
- **Windows**: Requires PowerShell 5.0+
