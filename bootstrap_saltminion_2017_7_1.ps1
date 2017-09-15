param([string]$MasterHost)

$SourceURI = 'https://repo.saltstack.com/windows/Salt-Minion-2017.7.1-Py2-AMD64-Setup.exe'

Write-Verbose 'Installing Salt... please wait'
$InstallerFile = 'C:\Packages\Salt.exe'
$ConfigFile = 'C:\salt\conf\minion'

Write-Verbose "Downloading salt installer from $SourceURI to $InstallerFile"
$WebClient = New-Object System.Net.WebClient
$webclient.DownloadFile($SourceURI, $InstallerFile)
Write-Verbose 'Salt installer downloaded.'

Write-Verbose 'Installing Salt'

$minionId = $env:COMPUTERNAME.ToLower()

Start-Process $InstallerFile -Wait `
                             -NoNewWindow `
                             -PassThru `
                             -ArgumentList "/S /master=$MasterHost /minion-name=$minionId"
Write-Verbose "Salt is installed"
Add-Content $ConfigFile "startup_states: highstate"
Restart-Service salt-minion