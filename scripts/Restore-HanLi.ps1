$ErrorActionPreference='Stop'
$root=$PSScriptRoot
$configPath=Join-Path $root 'launcher.json'
$config=Get-Content $configPath -Encoding UTF8 -Raw|ConvertFrom-Json
$config.AppLaunchScript=$null
$config|ConvertTo-Json -Depth 8|Set-Content $configPath -Encoding UTF8
$record=Get-Content (Join-Path $root 'shortcut-owned.json') -Encoding UTF8 -Raw|ConvertFrom-Json
$leaf=Split-Path $record.Path -Leaf
if($leaf -notin @('HanLi Codex.lnk','MuPeiling Codex.lnk')){throw 'Unknown shortcut name.'}
$expected=Join-Path ([Environment]::GetFolderPath('Desktop')) $leaf
if($record.Path -ine $expected){throw 'Unexpected shortcut ownership path.'}
if(Test-Path -LiteralPath $expected){
 if((Get-FileHash -LiteralPath $expected).Hash -eq $record.SHA256){Remove-Item -LiteralPath $expected}
 else{Write-Warning 'Shortcut changed; preserved.'}
}
Write-Output 'Launcher shortcut restored. Use the original Codex entry. If skin was enabled, also run skin-tools/Restore-Skin.ps1 before deleting this directory.'
