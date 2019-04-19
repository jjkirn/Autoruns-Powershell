# Autoruns-Powershell
![Architecture](/Architecture.jpg "Architecture")
[Complete Documentation can be found via this link](/Autoruns-Powershell-MySQL.doc "Autoruns-Powershell-MySQL.doc")

## This project is based on several items:
1. Windows 7 Pro instance that runs scrips periodically
   1. This computer should have at least PowerShell 5.1 installed and Remoting enabled.
   1. A directory C:/sysinternals with the following tools installed at C:/sysinternals/autoruns/...
      * Microsoft Sysinternals Autoruns
   1. A directory C:/ with the following folders created:
      * C:/ar_archive
      * C:/ar_baseline
      * C:/ar_latest
      * C:/ar_scripts
   1. The ar_scripts folder should have the following scripts uploaded:
      * ArData-Archive.ps1
      * Baseline-Archive.ps1
      * Check-Hashes.ps1
      * Collect-AR-Data.ps1
      * Create-Baseline.ps1
      * Create-HTML.ps1
      * CreateLinuxCred.ps1
      * Delta2-Hashes_V2.ps1
      * Dump-DB_v3.ps1
      * Find-UnVerified.ps1
      * host-list.txt
      * Latest-To-Baseline_v1.ps1
      * Move-to-Linux.ps1
      * Send-Slack-Msg.psm1
      * SetSlackToken.ps1
      * Slack-Test.ps1
      * slack-token.txt

1. Several Windows computers that will be monitored
   1. Each monitored computer should have at least PowerShell 5.1 installed and Remoting enabled
   1. A directory C:/sysinternals with the following tools installed:
      * C:/sysinternals/autoruns/...

1. A Ubuntu Linux 16.04 LTS instance running MySQL server.
   * Read the Autoruns-Powershell-MySQL.doc to see how to set up this server.
