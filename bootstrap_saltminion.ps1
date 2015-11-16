param([string]$MasterHost)

$SourceURI = 'https://repo.saltstack.com/windows/Salt-Minion-2015.8.1-AMD64-Setup.exe'

Write-Verbose 'Installing Salt... please wait'
$InstallerFile = 'C:\Packages\Salt.exe'

Write-Verbose "Downloading salt installer from $SourceURI to $InstallerFile"
$WebClient = New-Object System.Net.WebClient
$webclient.DownloadFile($SourceURI, $InstallerFile)
Write-Verbose 'Salt installer downloaded.'

Write-Verbose 'Installing Salt'
Start-Process $InstallerFile -Wait `
                             -NoNewWindow `
                             -PassThru `
                             -ArgumentList "/S /master=$MasterHost /minion-name=$env:COMPUTERNAME1"
Write-Verbose "Salt is installed"
