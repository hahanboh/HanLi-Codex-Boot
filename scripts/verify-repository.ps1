$ErrorActionPreference='Stop'
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
function Get-PublicGitFiles {
 param([string]$Repository)
 $info=New-Object Diagnostics.ProcessStartInfo
 $info.FileName='git.exe';$info.Arguments='-c core.quotepath=false -C "'+$Repository+'" ls-files'
 $info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.RedirectStandardOutput=$true
 $info.StandardOutputEncoding=[Text.Encoding]::UTF8
 $process=New-Object Diagnostics.Process;$process.StartInfo=$info
 $null=$process.Start();$output=$process.StandardOutput.ReadToEnd();$process.WaitForExit()
 $code=$process.ExitCode;$process.Dispose()
 if($code -ne 0 -or -not $output){throw 'Initialize Git and stage reviewed source first.'}
 return @(($output -split '\r?\n')|Where-Object {$_.Length -gt 0})
}
$files=@(Get-PublicGitFiles -Repository $repo)
$blocked='(?i)(^|/)(private|media|logs|qa|\.integration|cdp-profile)(/|$)|\.(mp4|m4s|webm|mov|mkv|gif|jpg|jpeg|png|ico|exe|dll|lnk|sqlite|log|zip)$|(^|/)\.env($|\.)'
foreach($relative in $files){
 if($relative -match $blocked){throw "Private/generated file tracked: $relative"}
 $text=[IO.File]::ReadAllText((Join-Path $repo $relative))
 if($text -match '(?i)C:[\\/]Users[\\/][^\\/\s"'']+|E:[\\/]WpSystem|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}'){
  throw "Personal path or credential pattern found: $relative"
 }
}
Write-Output "PASS: $($files.Count) tracked source files. No blocked media/private paths/credential patterns. Manual review still required."
