[CmdletBinding()]
param([switch]$IncludeBinary)
$ErrorActionPreference='Stop'
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path $PSScriptRoot 'verify-repository.ps1')
$files=@(Get-PublicGitFiles -Repository $repo)
$stage=Join-Path $repo ('.local/package-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force|Out-Null
foreach($name in $files){
 $target=Join-Path $stage $name
 New-Item -ItemType Directory -Path (Split-Path $target) -Force|Out-Null
 Copy-Item -LiteralPath (Join-Path $repo $name) -Destination $target
}
if($IncludeBinary){
 $binary=Join-Path $repo 'build/DragonCodexBoot/DragonCodexBoot.exe'
 if(-not(Test-Path $binary)){throw 'Build and test first.'}
 New-Item -ItemType Directory -Path (Join-Path $stage 'bin')|Out-Null
 Copy-Item -LiteralPath $binary -Destination (Join-Path $stage 'bin/DragonCodexBoot.exe')
}
$dist=Join-Path $repo 'dist'
New-Item -ItemType Directory -Path $dist -Force|Out-Null
$version=(Get-Content (Join-Path $repo 'VERSION') -Raw).Trim()
$flavor=if($IncludeBinary){'windows-x64'}else{'source'}
$zip=Join-Path $dist ('HanLi-Codex-Boot-v'+$version+'-'+$flavor+'.zip')
if(Test-Path $zip){throw 'Generated package already exists. Remove that file explicitly or choose a new version.'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($stage,$zip)
((Get-FileHash $zip).Hash.ToLowerInvariant()+'  '+(Split-Path $zip -Leaf))|Set-Content ($zip+'.sha256') -Encoding ASCII
Write-Output $zip
