param([string]$MasterHost),
param([string]$nms_app_zip)
Write-Verbose 'Configuring Salt... please wait'
$ConfigFile = 'C:\salt\conf\minion'
$IdFile = 'C:\salt\conf\minion_id'
$minionId = $env:COMPUTERNAME.ToLower()
$nms_app_id = $nms_app_zip

$grainString = @"
grains:
  nms_app_id: $nms_app_id
"@

Set-Content $ConfigFile "master: $MasterHost"
Add-Content $ConfigFile "startup_states: highstate"
Add-Content $ConfigFile $grainString
Set-Content $IdFile "$minionId"
Set-Service "salt-minion" -StartupType "Automatic"
Start-Service "salt-minion"