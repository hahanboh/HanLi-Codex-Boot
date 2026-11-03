[CmdletBinding()]
param([string]$Runtime=(Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/manager-runtime/1.7.3'))
$ErrorActionPreference='Stop'
if((Split-Path $Runtime -Leaf) -ne '1.7.3'){throw 'Only reviewed runtime 1.7.3 is supported.'}
$file=Join-Path $Runtime 'payload/scripts/injector.mjs'
$original=[IO.File]::ReadAllText($file);$text=$original
$start=$text.IndexOf('async function runOneShot(')
if($start -lt 0){throw 'Expected runOneShot not found.'}
$end=$text.IndexOf('async function ', $start+25)
if($end -lt 0){throw 'Cannot bound runOneShot.'}
$section=$text.Substring($start,$end-$start).Replace('applyToSession(session, payload)','applyToSession(session, loadedPayload)')
$text=$text.Substring(0,$start)+$section+$text.Substring($end)
$anchor='  const requested = enabled === true;'
$guard='  if (!requested && session.dreamSkinStreamCspBypass === undefined) { session.dreamSkinStreamCspBypass = false; return false; }'
if(-not $text.Contains($guard)){
 $functionStart=$text.IndexOf('export async function setStreamCspBypass(')
 if($functionStart -lt 0){throw 'Expected CSP function not found.'}
 $where=$text.IndexOf($anchor,$functionStart)
 if($where -lt 0 -or $where-$functionStart -gt 200){throw 'Unexpected CSP layout.'}
 $text=$text.Insert($where+$anchor.Length,"`n"+$guard)
}
if($text -eq $original){Write-Output 'Compatibility changes already present.';return}
$backup=$file+'.backup-'+(Get-Date -Format 'yyyyMMdd-HHmmss')
Copy-Item -LiteralPath $file -Destination $backup
if((Get-FileHash -LiteralPath $file).Hash -ne (Get-FileHash -LiteralPath $backup).Hash){throw 'Backup mismatch.'}
[IO.File]::WriteAllText($file,$text,[Text.UTF8Encoding]::new($false))
Write-Output "Patched. Backup: $backup"
