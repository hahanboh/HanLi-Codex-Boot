$ErrorActionPreference='Stop'
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Add-Type -AssemblyName PresentationFramework,System.Web.Extensions
$null=[Reflection.Assembly]::LoadFrom((Join-Path $repo 'build/DragonCodexBoot/DragonCodexBoot.exe'))
$fixture=Join-Path $repo ('.local/preset-tests-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture -Force|Out-Null
$names=@();$checks=0
foreach($name in @('hanli','mupeiling')){
 $preset=Get-Content (Join-Path $repo ('presets/'+$name+'.json')) -Raw -Encoding UTF8|ConvertFrom-Json
 $config=Get-Content (Join-Path $repo 'config/launcher.example.json') -Raw -Encoding UTF8|ConvertFrom-Json
 foreach($item in $preset.config.PSObject.Properties){$config.($item.Name)=$item.Value}
 $config|ConvertTo-Json -Depth 8|Set-Content (Join-Path $fixture 'launcher.json') -Encoding UTF8
 $loaded=[DragonCodexBoot.Entry]::ReadConfig($fixture)
 if($loaded.TextTitle -ne $preset.config.TextTitle -or $loaded.TextSubtitle -ne $preset.config.TextSubtitle){throw 'Preset text did not survive config load.'};$checks++
 foreach($color in @($loaded.TitleColor,$loaded.SubtitleColor)){$null=[Windows.Media.ColorConverter]::ConvertFromString($color);$checks++}
 if($loaded.AutoReplaceEntrypoints -or $loaded.ScanAllLocalDrives){throw 'Unsafe preset defaults.'};$checks++
 $names+=$preset.shortcut
}
if(($names|Select-Object -Unique).Count -ne 2){throw 'Presets share a shortcut.'};$checks++
Write-Output "PASS: $checks preset assertions. No desktop UI opened."
