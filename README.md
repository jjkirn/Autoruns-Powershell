# Autoruns-Powershell
# Heading 1
This project is based on several items:
A Windows 7 Pro instance that runs scrips periodically
# Heading 1.1
# Bullet 1
This computer should have at least PowerShell 5.1 installed and Remoting enabled.
# Heading 1.1.1
A directory C:/sysinternals with the following tools installed at C:/sysinternals/autoruns/...
# Bullet 1
Microsoft Sysinternals Autoruns
# Bullet 2
A directory C:/ with the following folders created:
# Bullet 2.1
C:/ar_archive
# Bullet 2.2
--- C:/ar_baseline
# Bullet 2.3
--- C:/ar_latest
# Bullet 2.4
--- c:/ar_scripts
# Heading 1.1.2
The ar_scripts folder should have the following scripts uploaded:
--- ArData-Archive.ps1
--- Baseline-Archive.ps1
--- Check-Hashes.ps1
--- Collect-AR-Data.ps1
--- Create-Baseline.ps1
--- Create-HTML.ps1
--- CreateLinuxCred.ps1
--- Delta2-Hashes_V2.ps1
--- Dump-DB_v3.ps1
--- Find-UnVerified.ps1
--- host-list.txt
--- Latest-To-Baseline_v1.ps1
--- Move-to-Linux.ps1
--- Send-Slack-Msg.psm1
--- SetSlackToken.ps1
--- Slack-Test.ps1
--- slack-token.txt

2. Several Windows computers that will be monitored
2.1 Each monitored computer should have at lease PowerShell 5.1 installed and Remoting enabled
2.2 A directory C:/sysinternals with the following tools installed:
---C:/sysinternals/autoruns/...

3. A Ubuntu Linux 16.04 LTS instance running MySQL server.
Read the Autoruns-Powershell-MySQL.doc to see how to set up this server.
