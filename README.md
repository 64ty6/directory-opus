# Directory Opus 配置备份

本仓库保存 Directory Opus 文件管理器的完整用户配置快照（工具栏按钮、布局、脚本、首选项、快捷键、主题、文件类型等），用于换新电脑后把界面与行为还原到与旧机一致。

## 前置要求

- 已在 Windows 上把 **Directory Opus 安装到 `D:\Tools\Directory Opus`**。该路径由配置中的绝对路径决定，请勿安装到其它位置。
- 还原前必须**完全退出** Directory Opus，包括主程序 `dopus.exe` 和托盘/助手进程 `dopusrt.exe`。
- 已把本仓库 clone 到本地任意目录（下文用 `$Repo` 指代仓库根目录，例如 `D:\Tools\directory-opus`）。
- 若新电脑上已有旧配置且想保留，先自行备份 `%APPDATA%\GPSoftware\Directory Opus` 与 `%LOCALAPPDATA%\GPSoftware\Directory Opus` 两个目录。
- 本手册命令均为 **PowerShell**。

## 还原步骤（AI 操作指引）

> 写给 AI 助手：按顺序执行，每步确认“期望结果”后再继续；遇到与预期不符的情况（路径不存在、进程仍在运行、复制报错等），**立即停下并询问用户**，不要自行猜测或跳步。以下路径、文件名均取自本仓库实际内容。

### 第 0 步：设定仓库路径

**目的**：后续命令统一使用一个变量，避免路径写错。

```powershell
$Repo = "D:\Tools\directory-opus"   # 改成你实际 clone 的位置
Test-Path $Repo
Test-Path "$Repo\program"; Test-Path "$Repo\settings"; Test-Path "$Repo\state"
```

**期望结果**：全部输出 `True`，且 `$Repo` 下能看到 `program`、`settings`、`state` 三个子目录。

**不满足时**：说明 clone 路径不对或仓库不完整。向用户确认实际 clone 位置后再继续，不要凭猜测改路径。

### 第 1 步：检查 Opus 安装

**目的**：确认目标机已安装 Opus，且安装路径与配置匹配。

```powershell
Test-Path "D:\Tools\Directory Opus\dopus.exe"
```

**期望结果**：输出 `True`。

**不满足时**：说明安装路径不对或未安装。提示用户把 Opus 安装到 `D:\Tools\Directory Opus` 后重试；不要试图改动配置里的路径去迁就错误安装位置。

### 第 2 步：确认 Opus 进程已退出

**目的**：Opus 运行时会把配置写回磁盘。若未退出，还原出的文件可能被即时覆盖或被占用导致复制失败。

```powershell
Get-Process dopus, dopusrt -ErrorAction SilentlyContinue
```

**期望结果**：没有任何输出（两个进程都不存在）。

**不满足时**：先请用户关闭所有 Opus 窗口并退出托盘图标；若仍存在，执行 `Stop-Process -Name dopus,dopusrt -Force`，然后重新运行上面的命令确认无输出。

### 第 3 步：复制安装目录配置 `program/` → `D:\Tools\Directory Opus\`

**目的**：还原随程序目录保存的配置与资源（`dopus.dat`、`Images`、`Language`、`Policies`）。

```powershell
Get-ChildItem "$Repo\program" | Copy-Item -Destination "D:\Tools\Directory Opus" -Recurse -Force
```

**期望结果**：无报错；`D:\Tools\Directory Opus\dopus.dat` 存在，修改时间为刚刚。

**不满足时**：确认目标目录存在且有写权限。若报“文件正在使用”，通常仍是 Opus 没退干净，回到第 2 步。

### 第 4 步：复制用户设置 `settings/` → `%APPDATA%\GPSoftware\Directory Opus\`

**目的**：还原按钮工具栏、布局、脚本、首选项（`prefs.oxc`）、快捷键、主题、文件类型等核心配置。

```powershell
$dst = "$env:APPDATA\GPSoftware\Directory Opus"
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Get-ChildItem "$Repo\settings" | Copy-Item -Destination $dst -Recurse -Force
```

**期望结果**：无报错；`$dst\ConfigFiles\prefs.oxc` 存在。

**不满足时**：检查 `$Repo\settings` 是否为空；确认 `%APPDATA%` 可写；报占用则回到第 2 步。

### 第 5 步：复制状态数据 `state/` → `%LOCALAPPDATA%\GPSoftware\Directory Opus\State Data\`

**目的**：还原窗口/会话状态（窗口位置、最近路径、搜索历史等）。

```powershell
$dst = "$env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data"
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Get-ChildItem "$Repo\state" | Copy-Item -Destination $dst -Recurse -Force
```

**期望结果**：无报错；`$dst\windowstate.osd` 存在。

**不满足时**：确认 `$Repo\state` 非空、目标可写；报占用回到第 2 步。

### 第 6 步：补建缺失的空目录

**目的**：git 不跟踪空目录，clone 后 `settings/` 下若干目录不会存在（例如 `Scripts`、`Toolbar Sets`、`Sounds`、`TabGroups`、`Translations`、`Icons`、`Filters` 等）。Opus 或用户脚本可能依赖这些目录，需手动补建。

```powershell
$s = "$env:APPDATA\GPSoftware\Directory Opus"
@(
    'Buttons\Script Defaults',
    'Collections\%%Lister-Quick-Find-Results%%',
    'Collections\标记的图片',
    'Filters',
    'Icons',
    'Images',
    'Manual Sort',
    'Program State',
    'Rename Presets\Default',
    'Script AddIns',
    'Script AddIns\CLI',
    'Script AddIns\Templates',
    'Script Snippets',
    'Scripts',
    'Sounds',
    'TabGroups',
    'Toolbar Sets',
    'Translations',
    'Tree Expansions',
    'User Data',
    'Util Presets',
    'Util Presets\Dupe',
    'Util Presets\Find',
    'Util Presets\ImageCvt',
    'Util Presets\PrintDir',
    'Util Presets\Sync'
) | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $s $_) -Force | Out-Null }
```

**期望结果**：命令无报错。可抽查：`Test-Path "$s\Scripts"` 应为 `True`。

**不满足时**：确认 `$s` 已存在（即第 4 步已成功）。若某个目录不确定是否需要，可先跳过——Opus 启动时通常会自动重建大部分目录；但 `Scripts`、`Script AddIns` 等被用户脚本引用的目录建议保留。

> 说明：以上清单是仓库中**实际存在但未被 git 跟踪**的全部空目录（克隆后都会缺失）。除用户点名的 `Scripts`、`Toolbar Sets`、`Sounds`、`TabGroups`、`Translations`、`Icons`、`Filters` 外，其余目录是否被 Opus 强依赖**需确认**；补建空目录无副作用，建议照单全建。

### 第 7 步：验证关键文件到位

**目的**：确认三大块配置都已落地，尤其核心的 `prefs.oxc`。

```powershell
$ap = "$env:APPDATA\GPSoftware\Directory Opus"
$la = "$env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data"
@(
    "D:\Tools\Directory Opus\dopus.dat",
    "$ap\dopus.dat",
    "$ap\ConfigFiles\prefs.oxc",
    "$ap\ConfigFiles\toolbars.oxc",
    "$ap\ConfigFiles\global_hotkeys.oxc",
    "$ap\Layouts\System\default.oll",
    "$la\windowstate.osd"
) | ForEach-Object { "{0,-6} {1}" -f (Test-Path $_), $_ }

# 进一步确认 prefs.oxc 是可解析的 XML（能解析说明复制完整）
[xml](Get-Content "$ap\ConfigFiles\prefs.oxc" -Raw) | Out-Null; "prefs.oxc OK"
```

**期望结果**：所有行均为 `True ...`，最后输出 `prefs.oxc OK`。

**不满足时**：对应文件为 `False` 或解析失败，说明该文件复制不完整，回到相应复制步骤（第 3/4/5 步）重做；仍失败则检查 Opus 是否仍在运行。

## 还原后要做的事

1. 启动 Directory Opus（开始菜单，或运行 `D:\Tools\Directory Opus\dopus.exe`）。
2. 逐项确认还原效果：
   - **工具栏/按钮**：菜单 设置 → 自定义工具栏，确认自定义按钮组已出现。
   - **布局与列表样式**：查看窗口布局菜单、列表样式菜单。
   - **快捷键**：设置 → 自定义快捷键（全局 / 列表 / 树 / 查看器）。
   - **主题与图标**：设置 → 主题。
   - **文件类型**：设置 → 文件类型。
   - **重命名预设**：打开重命名对话框，查看预设列表。
3. 若个别项未生效：先确认 Opus 版本一致（见「注意事项」），必要时退出并重启 Opus；仍不行再排查对应的 `.oxc` / `.dop` / `.oll` 文件是否复制成功（回到第 7 步验证）。
4. 确认无误后即可正常使用。

> **备选方式**：也可在仓库目录直接运行 `.\restore.ps1` 完成第 3~5 步的等价复制。注意两点差异：它只检查 `dopus` 进程、不检查 `dopusrt`；且**不会补建空目录**（仍需执行本手册第 6 步）。

## 目录对照表

| 仓库内路径 | 目标路径 | 说明 |
|---|---|---|
| `program/` | `D:\Tools\Directory Opus\` | 安装目录侧配置：`dopus.dat`、`Images\`、`Language\`、`Policies\` |
| `settings/` | `%APPDATA%\GPSoftware\Directory Opus\` | 用户设置，详见下方 |
| `state/` | `%LOCALAPPDATA%\GPSoftware\Directory Opus\State Data\` | 窗口/会话状态：`windowstate.osd`、`recent.osd`、`MRU\*`、`quicksearch.osd`、`openlisters.oll` 等 |

`settings/` 内的主要配置：

| 子路径 | 内容 |
|---|---|
| `Buttons\*.dop` | 自定义按钮与工具栏（含 `Menus\TrayMenu.dop`） |
| `ConfigFiles\prefs.oxc` | **全部首选项（核心文件）** |
| `ConfigFiles\*_hotkeys.oxc` | 快捷键（global / lister / tree / viewer） |
| `ConfigFiles\toolbars.oxc`、`menus.oxc`、`docks.oxc` | 工具栏、菜单、停靠面板 |
| `ConfigFiles\favorites.ofv`、`smartfav.osf` | 收藏夹、智能收藏 |
| `ConfigFiles\iconsets.oxc`、`colorgroups.oxc`、`viewer*.oxc` 等 | 图标集、颜色组、查看器及插件等设置 |
| `Layouts\*.oll`（含 `System\default.oll`）、`Layouts\order.xml` | 窗口布局 |
| `ListerStyles\*.osy` | 列表样式 |
| `Themes\*.dlt` | 主题 |
| `FileTypes\*.oxr` | 自定义文件类型 |
| `Formats\*.off` | 文件格式 / 内容类型定义 |
| `Rename Presets\*.orp` | 重命名预设 |
| `UserCommands\*.ouc` | 用户自定义命令 |
| `UISpacings\*.uis` | 界面间距设置 |
| `Collections\*.cct`、`*.col` | 文件集合（标记） |

## 备份范围

**包含**：Opus 的全部可移植用户配置——安装目录侧的 `dopus.dat`、`Images`、`Language`、`Policies`；`%APPDATA%` 下的用户设置（见上表）；`%LOCALAPPDATA%\...\State Data` 下的状态数据。

**排除**：

- `settings\Icon Cache Roaming\`、`settings\Logs\` —— 图标缓存与日志，与还原无关（`backup.ps1` 显式排除）。
- Opus **程序二进制**（`dopus.exe` 等）—— 程序本体由新机自行安装，备份只保存配置，不含可执行文件。
- `%LOCALAPPDATA%` 下的 `Icon Cache`、`Thumbnail Cache`、`Help Cache` 等缓存。

> 说明：`program\Language\` 内除 `.opusml` 语言文件外还包含一个 `english.dll`（界面语言资源，非 Opus 程序主体）；它属于配置资源，会一并备份与还原。

## 更新备份

在旧机配置变更后刷新备份：

1. **先完全退出 Opus（含 `dopusrt.exe`）**，否则文件被占用，可能复制到不完整的内容。
2. 更新仓库内容，二选一：

   运行脚本（会在仓库下 `Backup\<时间戳>\` 生成一份快照；注意 `Backup/` 已被 `.gitignore` 忽略，需再手动同步进 `program/settings/state`）：

   ```powershell
   .\backup.ps1
   ```

   或直接手动复制到仓库目录：

   ```powershell
   Copy-Item "D:\Tools\Directory Opus\dopus.dat","D:\Tools\Directory Opus\Images","D:\Tools\Directory Opus\Language","D:\Tools\Directory Opus\Policies" program/ -Recurse -Force
   Copy-Item "$env:APPDATA\GPSoftware\Directory Opus\*" settings/ -Recurse -Force -Exclude "Icon Cache Roaming","Logs"
   Copy-Item "$env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data\*" state/ -Recurse -Force
   ```

3. 提交并推送。

> 注意：`.gitignore` 只忽略 `Backup/`，不会忽略 `settings/` 与 `state/` 的内容，可放心提交。

## 注意事项

- **空目录问题**：git 不跟踪空目录，clone 后 `settings\` 下的 `Scripts`、`Toolbar Sets`、`Sounds`、`TabGroups`、`Translations`、`Icons`、`Filters` 等空目录不会存在，必须按第 6 步补建。完整缺失清单见第 6 步；其中哪些被 Opus 强依赖**需确认**，补建无副作用，建议全部创建。
- **版本兼容**：`ConfigFiles\prefs.oxc` 记录的生成版本为 Opus **13.22**（`opus_version_major=13`、`opus_version_minor=22`）。新机建议安装**同版本或更高**的 Opus；大版本跨度（如 12→13）可能导致部分设置无法识别或丢失。
- **`prefs.oxc` 是核心**：它是全部首选项的集合文件，还原后务必确认它已到位且可被解析（第 7 步验证），否则很多设置会回到默认值。
- **安装路径固定**：配置内含有指向 `D:\Tools\Directory Opus` 的绝对路径，务必安装到同一位置；否则需在 Opus 中手动修正相关路径。
- **覆盖式还原**：复制使用 `-Force`，会替换目标机上的同名配置。若想保留旧配置，请在还原前自行备份。
- **权限 / 占用报错**：复制时报“正在使用”基本都是 Opus 没退干净，回到第 2 步重新确认进程。
