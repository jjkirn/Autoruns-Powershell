#
# Copy Delta report to Linux server
#
# Note: Uses Posh-SSH to set up credential
# Install-Module -Name Posh-SSH
# Video: https://www.youtube.com/watch?v=aZT5L_0aepE
# PowerShell Gallery: https://www.powershellgallery.com/packages/Posh-SSH/2.3.0
# github: https://github.com/darkoperator/Posh-SSH
#
#----------------------------------------------------------------------------------
$credential = Import-Clixml -Path 'C:\cred.xml'

if (!$credential) { Write-Host "Credential is blank!" }

Get-Content -Path 'C:\Delta.htm' | Out-File -Encoding utf8 -FilePath 'C:\Delta_L.htm'
Set-SCPFile -ComputerName '192.168.1.163' -Credential $credential -RemotePath '/home/jim/Downloads/' -LocalFile 'C:\Delta_L.htm' -ConnectionTimeout 30 -Force
