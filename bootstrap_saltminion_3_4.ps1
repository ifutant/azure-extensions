param([string]$MasterHost)

$SourceURI = 'https://archive.repo.saltstack.com/windows/archive/Salt-Minion-2016.3.4-AMD64-Setup.exe'

Write-Verbose 'Installing Salt... please wait'
$InstallerFile = 'C:\Packages\Salt.exe'

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
