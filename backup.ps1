#requires -Version 7.0
# Directory Opus 配置备份。
param(
    [string]$ProgramDirectory = 'D:\Tools\Directory Opus',
    [string]$SettingsDirectory = (Join-Path $env:APPDATA 'GPSoftware/Directory Opus'),
    [string]$StateDirectory = (Join-Path $env:LOCALAPPDATA 'GPSoftware/Directory Opus/State Data'),
    [string]$Destination = (Join-Path $PSScriptRoot 'Backup' (Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'))
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts/config-common.ps1')

Assert-ApplicationStopped @('dopus', 'dopusrt')
Assert-RequiredPaths $ProgramDirectory @('dopus.dat')
Assert-RequiredPaths $SettingsDirectory @('ConfigFiles/prefs.oxc')
Assert-RequiredPaths $StateDirectory
foreach ($src in @($ProgramDirectory, $SettingsDirectory, $StateDirectory)) { Assert-SeparatePaths $src $Destination }
New-BackupDirectory $Destination
Copy-SelectedItems $ProgramDirectory (Join-Path $Destination 'program') @('dopus.dat', 'Images', 'Language', 'Policies')
Copy-DirectoryContents $SettingsDirectory (Join-Path $Destination 'settings') @('Icon Cache Roaming', 'Logs', 'Backup')
Copy-DirectoryContents $StateDirectory (Join-Path $Destination 'state')
Complete-Backup $Destination

