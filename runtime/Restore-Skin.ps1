$ErrorActionPreference='Stop'
$launcherRoot=Split-Path -Parent $PSScriptRoot
$configPath=Join-Path $launcherRoot 'launcher.json'
$config=Get-Content -LiteralPath $configPath -Raw -Encoding UTF8|ConvertFrom-Json
if($config.PSObject.Properties['AppLaunchScript']){$config.AppLaunchScript=$null}
$config|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $configPath -Encoding UTF8
$runtime=Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/manager-runtime/1.7.3'
$env:PATH=(Join-Path $runtime 'node')+';'+$env:PATH
& (Join-Path $runtime 'payload/scripts/restore-dream-skin.ps1') -RestoreBaseTheme -PromptRestart
