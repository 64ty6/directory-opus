#requires -Version 7.0
# Directory Opus 恢复，检查主程序及助手进程。
param(
    [string]$Source = $PSScriptRoot,
    [string]$ProgramDirectory = 'D:\Tools\Directory Opus',
    [string]$SettingsDirectory = (Join-Path $env:APPDATA 'GPSoftware/Directory Opus'),
    [string]$StateDirectory = (Join-Path $env:LOCALAPPDATA 'GPSoftware/Directory Opus/State Data')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts/config-common.ps1')

Assert-ApplicationStopped @('dopus', 'dopusrt')
Assert-RequiredPaths $ProgramDirectory @('dopus.exe')
Assert-RequiredPaths (Join-Path $Source 'program') @('dopus.dat')
Assert-RequiredPaths (Join-Path $Source 'settings') @('prefs.oxc')
Assert-RequiredPaths (Join-Path $Source 'state')
if (Test-Path -LiteralPath (Join-Path $Source '.backup-incomplete')) { throw '该备份尚未完成，不能恢复。' }
Restore-Configuration @(
    @{ Source = (Join-Path $Source 'program'); Destination = $ProgramDirectory },
    @{ Source = (Join-Path $Source 'settings'); Destination = $SettingsDirectory },
    @{ Source = (Join-Path $Source 'state'); Destination = $StateDirectory }
)

