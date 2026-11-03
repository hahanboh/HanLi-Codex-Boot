[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)][string]$MediaDirectory,
 [string]$InstallDirectory,
 [ValidateSet('hanli','mupeiling')][string]$Preset='hanli',
 [switch]$EnableSkin
)
$ErrorActionPreference='Stop'
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$themePreset=Get-Content (Join-Path $repo ('presets/'+$Preset+'.json')) -Encoding UTF8 -Raw|ConvertFrom-Json
if(-not $InstallDirectory){$InstallDirectory=Join-Path $env:LOCALAPPDATA $themePreset.installFolder}
$target=[IO.Path]::GetFullPath($InstallDirectory)
$local=[IO.Path]::GetFullPath($env:LOCALAPPDATA).TrimEnd('\')+'\'
if(-not $target.StartsWith($local,[StringComparison]::OrdinalIgnoreCase)){throw 'Install inside your LOCALAPPDATA directory.'}
if(Test-Path -LiteralPath $target){throw 'Install directory already exists. Use Import-Animation.ps1 to update media, or choose an empty new directory.'}
$media=(Resolve-Path -LiteralPath $MediaDirectory).Path
if(-not(Test-Path -LiteralPath (Join-Path $media 'startup.mp4'))){throw 'Missing startup.mp4.'}
if(-not(Get-AppxPackage -Name OpenAI.Codex)){throw 'Install the official Codex desktop app first.'}
if($EnableSkin){
 $runtime=Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/manager-runtime/1.7.3'
 if(-not(Test-Path (Join-Path $runtime 'payload/scripts/common-windows.ps1'))){throw 'Set up Codex-Dynamic-Skin v1.7.3 first. Read docs/SKIN.md.'}
 if(-not(Test-Path (Join-Path $media 'background.jpg'))){throw 'Skin requires background.jpg in media pack.'}
}
$prebuilt=Join-Path $repo 'bin/DragonCodexBoot.exe'
if(-not(Test-Path $prebuilt)){& (Join-Path $PSScriptRoot 'build.ps1')}
New-Item -ItemType Directory -Path $target,(Join-Path $target 'media'),(Join-Path $target 'assets'),(Join-Path $target 'logs')|Out-Null
$build=Join-Path $repo 'build/DragonCodexBoot'
if(Test-Path $prebuilt){Copy-Item $prebuilt $target}else{Copy-Item (Join-Path $build 'DragonCodexBoot.exe') $target}
Copy-Item (Join-Path $repo 'config/launcher.example.json') (Join-Path $target 'launcher.json')
Copy-Item (Join-Path $repo 'runtime/Concurrent-Skin.ps1') $target
New-Item -ItemType Directory -Path (Join-Path $target 'skin-tools')|Out-Null
Copy-Item (Join-Path $repo 'runtime/Restore-Skin.ps1') (Join-Path $target 'skin-tools')
Copy-Item (Join-Path $PSScriptRoot 'Restore-HanLi.ps1') $target
Copy-Item (Join-Path $repo 'LICENSE') $target
& (Join-Path $PSScriptRoot 'Import-Animation.ps1') -VideoPath (Join-Path $media 'startup.mp4') -AppRoot $target
if(Test-Path (Join-Path $media 'background.jpg')){Copy-Item (Join-Path $media 'background.jpg') (Join-Path $target 'assets/hanli-background.jpg')}
if(Test-Path (Join-Path $media 'icon.ico')){Copy-Item (Join-Path $media 'icon.ico') (Join-Path $target 'assets/hanli.ico')}
$configPath=Join-Path $target 'launcher.json'
$config=Get-Content $configPath -Encoding UTF8 -Raw|ConvertFrom-Json
foreach($item in $themePreset.config.PSObject.Properties){$config.($item.Name)=$item.Value}
if(Test-Path (Join-Path $media 'launcher-timing.json')){
 $timing=Get-Content (Join-Path $media 'launcher-timing.json') -Encoding UTF8 -Raw|ConvertFrom-Json
 foreach($key in @('HoldAt','TransitionStart','TransitionEnd')){$config.$key=$timing.$key}
}
if($EnableSkin){
 $config.AppLaunchScript='Concurrent-Skin.ps1';$config.ThemeDirectory='skin-theme'
 $skinRoot=Join-Path $target 'skin-theme';New-Item -ItemType Directory -Path $skinRoot|Out-Null
 Copy-Item (Join-Path $media 'background.jpg') (Join-Path $skinRoot 'background.jpg')
 $theme=@{schemaVersion=1;id=$themePreset.id;name=$themePreset.name;appearance='dark';image='background.jpg';art=@{focusX=0.5;focusY=0.5;safeArea='left';taskMode='ambient'};media=@{type='image';playbackRate=1;opacity=0.45}}
 [IO.File]::WriteAllText((Join-Path $skinRoot 'theme.json'),($theme|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
}
$config|ConvertTo-Json -Depth 8|Set-Content $configPath -Encoding UTF8
$check=Start-Process (Join-Path $target 'DragonCodexBoot.exe') -ArgumentList '--self-test' -WindowStyle Hidden -Wait -PassThru
if($check.ExitCode -ne 0){throw 'Installed config validation failed. No shortcut created.'}
$desktop=[Environment]::GetFolderPath('Desktop')
$shortcut=Join-Path $desktop ($themePreset.shortcut+'.lnk')
if(Test-Path $shortcut){throw 'Shortcut exists; preserved. Installation files are ready.'}
$shell=New-Object -ComObject WScript.Shell
$link=$shell.CreateShortcut($shortcut);$link.TargetPath=Join-Path $target 'DragonCodexBoot.exe';$link.WorkingDirectory=$target
if(Test-Path (Join-Path $target 'assets/hanli.ico')){$link.IconLocation=(Join-Path $target 'assets/hanli.ico')+',0'}
$link.Save()
@{Path=$shortcut;SHA256=(Get-FileHash $shortcut).Hash}|ConvertTo-Json|Set-Content (Join-Path $target 'shortcut-owned.json') -Encoding UTF8
Write-Output "Installed: $target. Open the new theme shortcut on Desktop. Original shortcuts were preserved."
