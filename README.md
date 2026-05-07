# Directory Opus 配置备份

## 快速还原

```powershell
# 1. 安装 Directory Opus 到 D:\Tools\Directory Opus
# 2. 执行还原
.\restore.ps1
```

## 目录说明

| 目录 | 目标路径 |
|------|---------|
| `program/` | `D:\Tools\Directory Opus\` |
| `settings/` | `%APPDATA%\GPSoftware\Directory Opus\` |
| `state/` | `%LOCALAPPDATA%\GPSoftware\Directory Opus\State Data\` |

## 配置内容

- **按钮和工具栏** — 自定义工具栏按钮、菜单
- **布局** — 窗口布局、列表样式、标签组
- **脚本** — 用户脚本和脚本插件
- **首选项** — prefs.oxc（全部偏好设置）
- **快捷键** — 全局和列表快捷键
- **主题和图标** — 自定义主题、图标集
- **文件类型** — 自定义文件类型和过滤器
- **窗口状态** — 窗口位置、搜索历史、最近路径

## 备份

```powershell
.\backup.ps1
```
