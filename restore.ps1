# Directory Opus 配置还原

param([string]$Source = $PSScriptRoot)

Write-Host "=== Directory Opus 配置还原 ===" -ForegroundColor Cyan

# 检查进程
if (Get-Process dopus -ErrorAction SilentlyContinue) {
    Write-Host "请先关闭 Directory Opus" -ForegroundColor Red; exit 1
}

# program/ → D:\Tools\Directory Opus
Write-Host "[1/3] 安装目录配置..." -ForegroundColor Yellow
$src = Join-Path $Source "program"
if (Test-Path $src) {
    Get-ChildItem $src | Copy-Item -Destination "D:\Tools\Directory Opus" -Recurse -Force
    Write-Host "  D:\Tools\Directory Opus\" -ForegroundColor Green
}

# settings/ → %APPDATA%\GPSoftware\Directory Opus
Write-Host "[2/3] 用户设置..." -ForegroundColor Yellow
$src = Join-Path $Source "settings"
$dst = "$env:APPDATA\GPSoftware\Directory Opus"
if (Test-Path $src) {
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
    Get-ChildItem $src | Copy-Item -Destination $dst -Recurse -Force
    Write-Host "  $dst" -ForegroundColor Green
}

# state/ → %LOCALAPPDATA%\GPSoftware\Directory Opus\State Data
Write-Host "[3/3] 状态数据..." -ForegroundColor Yellow
$src = Join-Path $Source "state"
$dst = "$env:LOCALAPPDATA\GPSoftware\Directory Opus\State Data"
if (Test-Path $src) {
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
    Get-ChildItem $src | Copy-Item -Destination $dst -Recurse -Force
    Write-Host "  $dst" -ForegroundColor Green
}

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
