$ErrorActionPreference='Stop'
function Test-VideoHash([string]$Path){
 $stream=[IO.File]::OpenRead($Path);$sha=[Security.Cryptography.SHA256]::Create()
 try{return [BitConverter]::ToString($sha.ComputeHash($stream))}finally{$stream.Dispose();$sha.Dispose()}
}
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$fixture=Join-Path $repo ('.local/quick-start-'+[guid]::NewGuid().ToString('N'))
$checks=0
foreach($theme in @('hanli','mupeiling','custom')){
 $arguments=@{Theme=$theme;RuntimeRoot=$fixture;PrepareOnly=$true}
 if($theme -eq 'custom'){$arguments.VideoPath=Join-Path $repo 'media/mupeiling.mp4'}
 $null=& (Join-Path $repo 'scripts/Start.ps1') @arguments
 $root=Join-Path $fixture $theme
 $config=Get-Content (Join-Path $root 'launcher.json') -Raw -Encoding UTF8|ConvertFrom-Json
 if(-not $config.UseVideoDuration -or $config.AppLaunchScript -or $config.AutoReplaceEntrypoints){throw 'Quick start must use duration-aware video with no injection or shortcut scan.'};$checks++
 if(-not(Test-Path (Join-Path $root 'media/startup.mp4'))){throw 'Runtime video missing.'};$checks++
 $p=Start-Process (Join-Path $root 'DragonCodexBoot.exe') -ArgumentList '--self-test' -WindowStyle Hidden -PassThru -Wait
 if($p.ExitCode -ne 0){throw 'Prepared runtime self-test failed.'};$checks++
}
$before=(Test-VideoHash (Join-Path $fixture 'custom/media/startup.mp4'))
$null=& (Join-Path $repo 'scripts/Start.ps1') -Theme custom -RuntimeRoot $fixture -PrepareOnly
$after=(Test-VideoHash (Join-Path $fixture 'custom/media/startup.mp4'))
if($before -ne $after){throw 'Cached custom video changed unexpectedly.'};$checks++
Write-Output "PASS: $checks quick-start assertions. No desktop UI, actual shortcut or Codex session changed."
