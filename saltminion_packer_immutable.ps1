param([string]$MasterHost)
Write-Verbose 'Configuring Salt... please wait'
$ConfigFile = 'C:\salt\conf\minion'
$IdFile = 'C:\salt\conf\minion_id'
$minionId = $env:COMPUTERNAME.ToLower()

Set-Content $ConfigFile "master: $MasterHost"
Add-Content $ConfigFile "startup_states: highstate"
Set-Content $IdFile "$minionId"
Set-Service "salt-minion" -StartupType "Automatic"
Start-Service "salt-minion"
