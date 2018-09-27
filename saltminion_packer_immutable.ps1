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
Set-Service "salt-minion" -StartupType "Automatic"
Start-Service "salt-minion"
c:\salt\salt-call.bat state.highstate -l debug
Start-ScheduledTask -TaskName InstallWindowsUpdates
Start-ScheduledTask -TaskName InstallPSWinUpdate
Restart-Computer -Wait -For PowerShell -Timeout 300 -Delay 2
Install-WindowsUpdate -IgnoreUserInput -AcceptAll -AutoReboot
