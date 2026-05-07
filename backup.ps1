# Directory Opus 配置备份

$dest = Join-Path $PSScriptRoot "Backup" (Get-Date -Format "yyyyMMdd-HHmmss")

Write-Host "=== Directory Opus 配置备份 ===" -ForegroundColor Cyan

# program/
Write-Host "[1/3] 安装目录配置..." -ForegroundColor Yellow
$dst = Join-Path $dest "program"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
@("dopus.dat","Images","Language","Policies") | ForEach-Object {
    $s = Join-Path "D:\Tools\Directory Opus" $_
    if (Test-Path $s) { Copy-Item $s -Destination $dst -Recurse -Force }
}

# settings/
Write-Host "[2/3] 用户设置..." -ForegroundColor Yellow
$s = "$env:APPDATA\GPSoftware\Directory Opus"
$d = Join-Path $dest "settings"
if (Test-Path $s) {
    Copy-Item $s -Destination $d -Recurse -Force
    Remove-Item "$d\Icon Cache Roaming","$d\Logs" -Recurse -Force -ErrorAction SilentlyContinue
}

# state/
Write-Host "[3/3] 状态数据..." -ForegroundColor Yellow
$s = "$env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data"
if (Test-Path $s) { Copy-Item $s -Destination (Join-Path $dest "state") -Recurse -Force }

Write-Host "`n=== 完成: $dest ===" -ForegroundColor Cyan
