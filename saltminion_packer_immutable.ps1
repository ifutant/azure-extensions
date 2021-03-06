Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$MasterHost = "not-specified",

    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$nms_app_zip = "not-specified"
)
Write-Verbose 'Configuring Salt... please wait'
$ConfigFile = 'C:\salt\conf\minion'
$IdFile = 'C:\salt\conf\minion_id'
$minionId = $env:COMPUTERNAME.ToLower()
$nms_app_id = $nms_app_zip

$grainString = @"
grains:
  nms_app_id: $nms_app_id
  deployment_method: packer_post_deploy
"@

Set-Content $ConfigFile "master: $MasterHost"
Add-Content $ConfigFile "startup_states: highstate"
Add-Content $ConfigFile $grainString
Set-Content $IdFile "$minionId"
Remove-Item -Path C:\salt\conf\minion.d\f_defaults.conf -Force
Set-Service "salt-minion" -StartupType "Automatic"
Start-Service "salt-minion"
Start-Process powershell { c:\salt\salt-call.bat state.highstate -l debug; Start-ScheduledTask -TaskName InstallWindowsUpdates; Start-ScheduledTask -TaskName InstallPSWinUpdate; Install-WindowsUpdate -IgnoreUserInput -AcceptAll -IgnoreReboot -verbose  }
c:\salt\salt-call.bat system.reboot 12
