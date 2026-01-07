# OpenCode Now

[OpenCode](https://github.com/opencode-ai/opencode) 快速启动工具 - 消除在不同目录启动 OpenCode 时的重复终端命令。

[English](README.md) | **中文**

---

## 概述

**问题**：每次启动 OpenCode 都需要打开终端、导航到目标目录、输入命令。

**解决方案**：OpenCode Now 提供平台原生启动器（macOS 应用、Windows 右键菜单），自动检测 OpenCode 安装位置并在指定目录即时启动。

### 核心能力

| 功能 | 实现方式 |
|------|---------|
| **自动检测** | 搜索 npm、yarn、pnpm、nvm、Go bin 和系统路径 |
| **上下文感知** | 在当前 Finder 窗口或指定目录启动 |
| **终端无关** | 支持 iTerm2、Warp、Kitty、Alacritty、Terminal.app |
| **权限绕过** | 使用 `--dangerously-skip-permissions` 参数 |
| **跨平台** | macOS（应用包 + shell）和 Windows（PowerShell + 批处理） |

---

## 环境要求

- **OpenCode CLI** 必须已安装并在 PATH 中可访问

```bash
# 安装 OpenCode（示例 - 根据实际安装方法调整）
go install github.com/opencode-ai/opencode@latest

# 验证
which opencode
opencode --version
```

---

## 快速开始

### macOS

#### 方式一：应用包（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/EthanAlgoX/open-code-now.git
cd open-code-now

# 2. 设置可执行权限
chmod +x "OpenCode Now.app/Contents/MacOS/OpenCodeLauncher"

# 3. 复制到应用程序文件夹
cp -R "OpenCode Now.app" /Applications/

# 4. 刷新图标缓存（如果图标未显示）
killall Finder

# 5. 启动方式：
#    - **启动台 (Launchpad)**：搜索并点击 OpenCode Now
#    - **Dock 栏**：从应用程序文件夹拖动到 Dock，点击启动
#    - **Finder 工具栏**：按住 ⌘ 拖动应用到工具栏，在任意文件夹点击即可
```

#### 方式二：Shell 脚本（命令行）

```bash
# 1. 克隆仓库
git clone https://github.com/EthanAlgoX/open-code-now.git
cd open-code-now

# 2. 设置可执行权限
chmod +x macos/opencode-now.sh

# 3. 直接执行（指定目录）
./macos/opencode-now.sh ~/Documents/MyProject

# 或全局安装（可在任何位置调用）
sudo cp macos/opencode-now.sh /usr/local/bin/opencode-now
# 使用：opencode-now /path/to/project
```

### Windows

```powershell
# 1. 克隆或下载仓库
# 2. 运行安装
.\windows\install.bat

# 3. （可选）添加右键菜单集成
.\windows\install-context-menu.bat  # 以管理员身份运行

# 使用：右键任意文件夹 → "OpenCode Now"
```

---

## 架构设计

### macOS 组件

```text
OpenCode Now.app/
├── Contents/
│   ├── Info.plist              # Bundle 元数据，CFBundleIdentifier: com.opencode.launcher
│   └── MacOS/
│       └── OpenCodeLauncher    # 启动器脚本（检测 Finder 窗口、终端偏好）

macos/
├── opencode-now.sh             # 核心启动器（PATH 检测、OpenCode 执行）
└── set-terminal.sh             # 终端偏好配置
```

**执行流程**：

1. 应用启动 → `OpenCodeLauncher` 执行
2. 通过 AppleScript 检测当前 Finder 窗口路径
3. 从 `~/.opencode-now-terminal` 读取终端偏好
4. 调用 `opencode-now.sh` 并传入目标目录
5. 脚本搜索 OpenCode 二进制文件（npm/yarn/pnpm/nvm/Go）
6. 使用 `--dangerously-skip-permissions` 启动 OpenCode

### Windows 组件

```text
windows/
├── opencode-now.ps1            # PowerShell 启动器（OpenCode 检测 + 执行）
├── install.bat                 # 复制脚本到 %USERPROFILE%\bin
├── install-context-menu.bat    # 注册表修改（右键菜单）
├── uninstall-context-menu.bat  # 注册表清理
└── diagnose.bat                # 环境诊断
```

**注册表键**（右键菜单）：

- `HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow`
- `HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow`
- `HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow`

---

## 配置

### 终端偏好（macOS）

```bash
./macos/set-terminal.sh
```

偏好存储在 `~/.opencode-now-terminal`。未设置时自动检测。

**优先级**：iTerm2 → Warp → Kitty → Alacritty → Terminal.app

### 目录记忆

macOS 和 Windows 都会记住上次使用的目录：

- **macOS**: `~/.opencode-now-last-dir`
- **Windows**: `%USERPROFILE%\.opencode-now-last-dir`

---

## 故障排除

### 找不到 OpenCode

**搜索路径**（按顺序）：

1. 当前 `$PATH` / `%PATH%`
2. 包管理器全局 bin（npm、yarn、pnpm）
3. nvm Node.js 版本（`~/.nvm/versions/node/*/bin`）
4. 常见安装目录：
   - macOS: `~/.local/bin`、`/usr/local/bin`、`/opt/homebrew/bin`、`~/go/bin`
   - Windows: `%APPDATA%\npm`、`%LOCALAPPDATA%\npm`、`%USERPROFILE%\go\bin`

**诊断**：

```bash
# macOS：在终端运行启动器查看搜索输出
./macos/opencode-now.sh

# Windows：运行诊断工具
.\windows\diagnose.bat
```

### 权限错误（macOS）

```bash
# 修复可执行权限
chmod +x macos/opencode-now.sh
chmod +x macos/set-terminal.sh
chmod +x "OpenCode Now.app/Contents/MacOS/OpenCodeLauncher"
```

### 右键菜单未出现（Windows）

1. 验证脚本安装：检查 `%USERPROFILE%\bin\opencode-now.ps1` 是否存在
2. 以管理员身份重新运行 `install-context-menu.bat`
3. 重启资源管理器：`taskkill /f /im explorer.exe && start explorer.exe`

---

## 开发

### 项目结构

```
.
├── macos/
│   ├── opencode-now.sh          # 启动器实现
│   └── set-terminal.sh          # 终端配置工具
├── windows/
│   ├── opencode-now.ps1         # PowerShell 启动器
│   ├── install.bat              # 安装脚本
│   ├── install-context-menu.bat # 右键菜单设置
│   ├── uninstall-context-menu.bat
│   └── diagnose.bat             # 诊断工具
├── OpenCode Now.app/            # macOS 应用包
│   └── Contents/
│       ├── Info.plist
│       └── MacOS/OpenCodeLauncher
├── README.md
├── README.zh.md
└── .gitignore
```

### 测试

```bash
# macOS：语法检查
bash -n macos/opencode-now.sh
bash -n macos/set-terminal.sh

# 验证 Info.plist
plutil -lint "OpenCode Now.app/Contents/Info.plist"

# 测试启动器（试运行）
./macos/opencode-now.sh /tmp
```

---

## 贡献

1. Fork 仓库
2. 创建功能分支（`git checkout -b feature/improvement`）
3. 在目标平台测试
4. 提交 Pull Request 并描述更改

---

## 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 技术说明

- **CLI 参数**：使用 `--dangerously-skip-permissions` 而非交互式提示
- **Bundle ID**：`com.opencode.launcher`（macOS）
- **最低 macOS 版本**：10.13（High Sierra）
- **Windows 要求**：PowerShell 5.0+
