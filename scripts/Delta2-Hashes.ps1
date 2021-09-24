#
# This script performs several steps:
# 1) Archive old ar_data (ArData-Archive.ps1)
# 2) Collect most recent ar_data (Collect-AR-Data_v3.ps1)
# 3) Compare the contents of files located at $fpath by matching hashes
# to the values stored in the MySQL database
# Find the differences in the hashes and log them to file "Delta.log":
#     a) NF - Not Found (not in database)
#     b) DM - hashes don't match
# 4) Create HTML files (Delta.htm and Delta_L.htm) based on "Dela.log"
# 5) Transfer Delta_L.htm file to Ubuntu server (192.168.1.163) running apache web server
# 6) Send Slack message based on "Delta.log" filer 
# -----------------------------------------------------------------------------------
Import-Module ARSQL
Import-Module SendSlackMsg

# 1. Archive the old ar_data
Invoke-Expression "C:\ar_scripts\AR-Data-Archive.ps1"
Write-Host "Delta2-Hashes: old ar_data archived." -ForegroundColor Green

# 2. Collect latest ar_data
Invoke-Expression "C:\ar_scripts\Collect-AR-Data.ps1"
Write-Host "Delta2-Hashes: new ar_data collected." -ForegroundColor Green

# If log file exists - delete it
$LogFileName = "C:\Delta.log"
if (Test-Path $LogFileName) {
  Remove-Item $LogFileName
}

$mytext = "----------------------------------------------------------------------"
$mytext | Out-File $LogFileName

$fpath = "c:\ar_latest\"
#
# 3. Compare the contents of files located at $fpath by matching hashes
$myrecords = CompareFiles($fpath) 
$mytext = "Total records successfuly compared = "+ $myrecords
Write-Host $mytext  -ForegroundColor Green
$mytext | Out-File $LogFileName -Append
$mytext = "`n"
$mytext | Out-File $LogFileName -Append

#
# 4. Create HTML version of Logfile
#
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$TargetFile = "C:\Delta.htm"

#$Pre = "Delta Report"
$Post = "NF=Not Found, DM=Don't Match"

# Convert Logfile to HTML
$File = Get-Content $LogFileName
$FileLine = @()
Foreach ($Line in $File) {
   $myObject = New-Object -TypeName PSObject
   Add-Member -InputObject $myObject -Type NoteProperty -Name DeltaReport -Value $Line
   $FileLine += $myObject
}

$FileLine | ConvertTo-Html -Property DeltaReport -PostContent $Post -Title "Delta Report" | Out-File $TargetFile

# 5. Transfer HTML file to Ubuntu server at 192.168.1.163
Invoke-Expression "C:\ar_scripts\Move-To-Linux.ps1"
Write-Host "Delta2-Hashes: HTML report moved to Ubuntu web server." -ForegroundColor Green
# End of HTLM stuff ----------------------------------------------------------------------------

#
# Read logfile into string var and send it to Slack
#
#$logfile = Get-Content -Path C:\Delta.log
[String]$logtmp = ""
foreach ($line in [System.IO.File]::ReadLines("C:\Delta.log")) {
    $logtmp += $line + "`r"+"`n"
}
$logtmp += "NF=Not Found, DM=Don't Match"+"`r"+"`n"

# 6. Send it to Slack
$myPretext = "`r"+"`n"+"AutoRuns Delta Report"+"`r"+"`n"
SendSlackMsg($logtmp,"http://192.168.1.163",$myPretext)
Write-Host "Delta2-Hashes: Slack Message Sent." -ForegroundColor Green