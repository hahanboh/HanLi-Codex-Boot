$ErrorActionPreference='Stop'
$root=$PSScriptRoot
$log=Join-Path $root 'logs/concurrent-start.log'
$mutex=New-Object Threading.Mutex($false,'Local\HanLiCodexSkinStartup')
if(-not $mutex.WaitOne(0)){exit}
$resultLog=Join-Path $root ('logs/skin-apply-'+$PID+'.log')
function Invoke-HanLiUtf8Native {
 param([string]$FilePath,[string[]]$ArgumentList)
 $info=New-Object Diagnostics.ProcessStartInfo
 $info.FileName=$FilePath
 $info.Arguments=ConvertTo-DreamSkinArgumentLine -Arguments $ArgumentList
 $info.UseShellExecute=$false;$info.CreateNoWindow=$true
 $info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
 $info.StandardOutputEncoding=[Text.Encoding]::UTF8;$info.StandardErrorEncoding=[Text.Encoding]::UTF8
 $process=New-Object Diagnostics.Process;$process.StartInfo=$info
 $null=$process.Start()
 $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync()
 if(-not $process.WaitForExit(18000)){$process.Kill();throw 'Skin preparation command timed out'}
 $output=$stdout.Result;$errorText=$stderr.Result;$code=$process.ExitCode;$process.Dispose()
 return [pscustomobject]@{Output=$output;ExitCode=$code;Diagnostic=$errorText}
}
function Log($message){Add-Content $log ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')+' '+$message)}
# Request the real UI immediately, before any skin discovery or validation.
Log 'codex-skin-session-requested'

try {
 $runtime=Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/manager-runtime/1.7.3'
 $env:PATH=(Join-Path $runtime 'node')+';'+$env:PATH
 . (Join-Path $runtime 'payload/scripts/common-windows.ps1')
 $settings=Get-Content (Join-Path $root 'launcher.json') -Encoding UTF8 -Raw|ConvertFrom-Json
 $themeDir=Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/active-theme'
 if($settings.ThemeDirectory){
  $themeDir=[IO.Path]::GetFullPath((Join-Path $root $settings.ThemeDirectory))
  if(-not $themeDir.StartsWith([IO.Path]::GetFullPath($root).TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'ThemeDirectory must stay inside launcher directory'}
 }
 $expectedThemeId=(Get-Content (Join-Path $themeDir 'theme.json') -Encoding UTF8 -Raw|ConvertFrom-Json).id
 if(-not $expectedThemeId){throw 'Theme id missing'}
 $app=Get-DreamSkinCodexInstall
 $identity=Get-DreamSkinVerifiedCdpIdentity -Port 9335 -Codex $app
 # Launch/reopen the validated Store executable, then prepare the theme on its actual session.
 $null=Start-DreamSkinCodexDirect -Codex $app -Arguments @('--remote-debugging-address=127.0.0.1','--remote-debugging-port=9335',('--user-data-dir='+(Join-Path $env:LOCALAPPDATA 'CodexDreamSkin/cdp-profile')))
 Log 'real-ui-requested'
 $deadline=(Get-Date).AddSeconds(25)
 while(-not $identity -and (Get-Date) -lt $deadline){
  Start-Sleep -Milliseconds 500
  $identity=Get-DreamSkinVerifiedCdpIdentity -Port 9335 -Codex $app
 }
 if(-not $identity){throw 'Codex debug session did not become available within 25 seconds'}
 if($identity){
  Log 'skin-apply-started-existing-session'
  $node=Get-DreamSkinNodeRuntime
  $prepared=$false
  for($attempt=0;$attempt -lt 4;$attempt++){
  $result=Invoke-HanLiUtf8Native -FilePath $node.Path -ArgumentList @(
    (Join-Path $runtime 'payload/scripts/injector.mjs'),'--once','--port','9335','--browser-id',$identity.BrowserId,
    '--theme-dir',$themeDir,'--timeout-ms','5000')
  $result.Output | Set-Content $resultLog -Encoding UTF8
  $raw=[string]$result.Output
  $jsonStart=[regex]::Match($raw,'(?m)^\{\s*$')
  if(-not $jsonStart.Success){Log 'renderer-not-ready-retrying';Start-Sleep -Milliseconds 700;continue}
  $last=$raw.LastIndexOf('}')
  try {$report=$raw.Substring($jsonStart.Index,$last-$jsonStart.Index+1)|ConvertFrom-Json}
  catch {Log 'skin-report-not-ready-retrying';Start-Sleep -Milliseconds 700;continue}
  $prepared=@($report.targets|Where-Object {
    $v=$_.result
    $v.pass -or ($v.installed -and $v.stylePresent -and $v.themeId -eq $expectedThemeId -and
      $v.documentHidden -and $v.readiness.structurePass -and $v.readiness.viewportPass)
  }).Count -gt 0
  if($prepared){break}
  Start-Sleep -Milliseconds 700
  }
  if($prepared){
   [IO.File]::WriteAllText((Join-Path $root '.skin-ready'),'prepared-under-splash')
   Log 'skin-prepared-under-splash'
  }else {throw ('Skin preparation failed, exit='+$result.ExitCode)}
 }

}catch{
 Log ('skin-error '+$_.Exception.Message)
 [IO.File]::WriteAllText((Join-Path $root '.skin-failed'),$_.Exception.Message)
 Start-Process explorer.exe 'shell:AppsFolder\OpenAI.Codex_2p2nqsd0c76g0!App'
}finally{$mutex.ReleaseMutex();$mutex.Dispose()}
