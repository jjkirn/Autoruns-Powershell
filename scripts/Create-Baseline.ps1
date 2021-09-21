# JJK 6/22/21
# This script performs several steps to create a baseline of the autoruns data for all hosts listed in file "host-list.txt".
# 1) Create a Zip archive of the old files at ar_latest and place it into ar_archive directory
# 2) Collect the new ar_data from each host and put it into ar_latest
# 3) Create new Zip archive of the files downloaded in step 2) above and lable it a baseline
# 4) Copy the the files downloaded in step 2) to ar_baselines directory
# 5) Clear out old data from DB Table=ar_data in the Ubuntu MySQL database
# 6) Populate new ar_data into the DB Table=ar_data in the Ubuntu MySQL database
# 7) Send Slack message indicating baseline completed successfully
# -----------------------------------------------------------------------------------------------------------------
Import-Module C:\ar_scripts\Send-Slack-Msg.psm1
Import-Module C:\ar_scripts\AR-SQL.psm1

# 1. Archive the old file at ar_data
Invoke-Expression "C:\ar_scripts\AR-Data-Archive.ps1"
Write-Host "Create-Baseline: old ar_data archived." -ForegroundColor Green

# 2. Collect the new ar_data
Invoke-Expression "C:\ar_scripts\Collect-AR-Data.ps1"
Write-Host "Create-Baseline: new ar_data collected." -ForegroundColor Green

# 3. Create new Archive of new Baselines
Invoke-Expression "C:\ar_scripts\Baseline-Archive.ps1"
Write-Host "Create-Baseline: Archive of \ar_baseline created." -ForegroundColor Green

# 4. Copy the new ar_data to ar_baselines
Invoke-Expression "C:\ar_scripts\Latest-To-Baseline.ps1"
Write-Host "Create-Baseline: new ar_data copied to \ar_baselines." -ForegroundColor Green

# Path to where the file is located
$fpath = "c:\ar_baselines\"

# 5. Clear out old data from DB Table=ar_data
$mySQL = "TRUNCATE TABLE ar_data;"
$test = Get-ODBC-Data $mySQL
Write-Host "Create-Baseline: ar_data DB table cleared." -ForegroundColor Green

# 6.Populate new data into the DB/Table
$myTotal = Get-Files $fpath
$myMessage = "Create-Baseline: Total records = "
$myMessage += $myTotal 
$myMessage += " inserted into Database."
Write-Host $myMessage -ForegroundColor Green

# 7. Send it to Slack
$myPretext = "`r"+"`n"+"AutoRuns Baseline Report"
# located at C:\Program Files\WindowsPowerShell\Modules\Slackjjk.psm1
Send-Slack-Msg($myMessage,"",$myPretext)
