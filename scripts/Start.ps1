[CmdletBinding()]
param(
 [ValidateSet('hanli','mupeiling','custom')][string]$Theme='hanli',
 [string]$VideoPath,
 [string]$RuntimeRoot=(Join-Path $env:LOCALAPPDATA 'FanrenCodexBoot'),
 [switch]$PrepareOnly
)
$ErrorActionPreference='Stop'
function Get-VideoHash([string]$Path){
 $stream=[IO.File]::OpenRead($Path);$sha=[Security.Cryptography.SHA256]::Create()
 try{return [BitConverter]::ToString($sha.ComputeHash($stream))}finally{$stream.Dispose();$sha.Dispose()}
}
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$target=Join-Path ([IO.Path]::GetFullPath($RuntimeRoot)) $Theme
if(-not $PrepareOnly -and (Get-Process DragonCodexBoot -ErrorAction SilentlyContinue)){Write-Output 'An opening animation is already playing.';return}
$binary=Join-Path $repo 'bin/DragonCodexBoot.exe'
if(-not(Test-Path $binary)){
 $binary=Join-Path $repo 'build/DragonCodexBoot/DragonCodexBoot.exe'
 if(-not(Test-Path $binary)){& (Join-Path $PSScriptRoot 'build.ps1')}
}
$cached=Join-Path $target 'media/startup.mp4'
if(-not $VideoPath){
 $bundled=Join-Path $repo ('media/'+$Theme+'.mp4')
 if(Test-Path -LiteralPath $bundled){$VideoPath=$bundled}
 elseif($Theme -eq 'custom' -and (Test-Path -LiteralPath $cached)){$VideoPath=$cached}
 elseif($Theme -eq 'custom' -and -not $PrepareOnly){
  Add-Type -AssemblyName System.Windows.Forms
  $picker=New-Object Windows.Forms.OpenFileDialog
  $picker.Filter='MP4 video (*.mp4)|*.mp4';$picker.Title='Choose your opening video'
  if($picker.ShowDialog() -ne [Windows.Forms.DialogResult]::OK){return}
  $VideoPath=$picker.FileName;$picker.Dispose()
 }else{throw 'MP4 file missing.'}
}
$video=(Resolve-Path -LiteralPath $VideoPath).Path
if([IO.Path]::GetExtension($video) -ine '.mp4'){throw 'Please choose an MP4 video.'}
New-Item -ItemType Directory -Path $target,(Join-Path $target 'media'),(Join-Path $target 'logs') -Force|Out-Null
Copy-Item -LiteralPath $binary -Destination (Join-Path $target 'DragonCodexBoot.exe') -Force
if($video -ine $cached){
 if(-not(Test-Path -LiteralPath $cached) -or (Get-VideoHash $video) -ne (Get-VideoHash $cached)){
  [IO.File]::WriteAllBytes($cached,[IO.File]::ReadAllBytes($video))
 }
 if((Get-VideoHash $video) -ne (Get-VideoHash $cached)){throw 'Video copy verification failed.'}
}
$config=Get-Content (Join-Path $repo 'config/launcher.example.json') -Raw -Encoding UTF8|ConvertFrom-Json
$presetName=if($Theme -eq 'custom'){'hanli'}else{$Theme}
$preset=Get-Content (Join-Path $repo ('presets/'+$presetName+'.json')) -Raw -Encoding UTF8|ConvertFrom-Json
foreach($item in $preset.config.PSObject.Properties){$config.($item.Name)=$item.Value}
if($Theme -eq 'custom'){$config.DisplayName='Custom Codex opening'}
$config|Add-Member -NotePropertyName UseVideoDuration -NotePropertyValue $true -Force
$config.AppLaunchScript=$null;$config.ThemeDirectory=$null;$config.Video='media/startup.mp4'
$config.AutoReplaceEntrypoints=$false;$config.ScanAllLocalDrives=$false
$config|ConvertTo-Json -Depth 8|Set-Content (Join-Path $target 'launcher.json') -Encoding UTF8
if($PrepareOnly){Write-Output $target;return}
if(-not(Get-AppxPackage -Name OpenAI.Codex)){throw 'Install the official Windows Codex desktop app first.'}
Start-Process (Join-Path $target 'DragonCodexBoot.exe') -WorkingDirectory $target
