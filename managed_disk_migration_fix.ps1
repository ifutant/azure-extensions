# (1) PnP Clean
Write-Host "Running: PnP Clean."
RUNDLL32.exe  pnpclean.dll,RunDLL_PnpClean /devices /maxclean
 
# (2) Configure the startup type of the storflt service
Write-Host "Running: Setting boot type of storflt service."
$output = sc.exe config storflt start=boot
if($output.Contains("SUCCESS") -eq $false)
{
                Write-Host "Error while setting the boot type of the service. [$output]"
                Exit
}
 
# (3) Read the registry key for LowerFilters
Write-Host "Running: Reading registry value."
$regValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e967-e325-11ce-bfc1-08002be10318}\" -Name "LowerFilters"
if($regValue.LowerFilters.Contains("storflt") -eq $false)
{
                Write-Host "Running: storflt not present. Setting registry value."
                $regValue.LowerFilters += "storflt"
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e967-e325-11ce-bfc1-08002be10318}\" -Name "LowerFilters" -Value $regValue.LowerFilters
                Write-Host "Required values set. Please reboot the VM for the settings to take effect. "
}
else
{
                Write-Host "storflt already present. Exiting."
}