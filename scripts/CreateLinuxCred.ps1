#
# This file only needs to be run once - before you plan to access the Ubuntu MySQL host via Posh-SSH.
# A prerequisite is the installation of Posh-SSH via "Install-Module -Name Posh-SSH" - 
#  - if you have already done this you are ready to run this script.
#----------------------------------------------------------------------------------------------------
#
$credential = Get-Credential
$credential | Export-Clixml -Path 'C:\cred.xml'
