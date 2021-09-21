#
# This script loops throuth the Ubuntu MySQL database looking for entries that
#  do not have ar_signer filed set to "(Verified)" and provides a list of those items.
# This is a test function - not direcly part of AutoRuns
#---------------------------------------------------------------------------------------

Import-Module C:\ar_scripts\AR-SQL.psm1
#
# Read DB - searching for un-Verified items
#
    # If log file exists - delete it
    $LogFileName = "C:\NotVerified.log"
    if (Test-Path $LogFileName) {
        Remove-Item $LogFileName
    }

    # Retrieve the whole DB
    $sql = "SELECT * FROM ar_data;"
    $myRows = Get-ODBC-Data $sql
    $myVer = "(Verified)"
    $myText = "Found "+ ($myRows.Count-1) +" Rows."
    Write-Host $myText

    # Locate all the un-Verified items
    for($i=1; $i -lt $myRows.count; $i++)  {
        #Write-Host "DB Row = [$i]:"
        #Write-Host "Verified = ", $myRows[$i].ar_signer

        if ($myRows[$i].ar_signer.length -eq $null) {
            $myText = "[fname = "+$myRows[$i].fname+"] [ar_signer = "+$myRows[$i].ar_signer+"] [ar_entry = "+$myRows[$i].ar_entry+"] [ar_version = "+$myRows[$i].ar_ver +"] [MD5 = "+ $myRows[$i].id_hash+"]"
            Write-Host $myText
            $myText | Out-File $LogFileName -Append
        }
        ElseIf ($myRows[$i].ar_signer.length -lt 10){
            $myText = "[fname = "+$myRows[$i].fname+"] [ar_signer = "+$myRows[$i].ar_signer+"] [ar_entry = "+$myRows[$i].ar_entry+"] [ar_version = "+$myRows[$i].ar_ver +"] [MD5 = "+ $myRows[$i].id_hash+"]"
            Write-Host $myText
            $myText | Out-File $LogFileName -Append
        }
        ElseIf ( ($myRows[$i].ar_signer).Substring(0,10) -ne $myVer ) {
            $myText = "[fname = "+$myRows[$i].fname+"] [ar_signer = "+$myRows[$i].ar_signer+"] [ar_entry = "+$myRows[$i].ar_entry+"] [ar_version = "+$myRows[$i].ar_ver +"] [MD5 = "+ $myRows[$i].id_hash+"]"
            Write-Host $myText
            $myText | Out-File $LogFileName -Append
        }
    }

$myText = "----------------------------------------------------------------------"
$myText | Out-File $LogFileName -Append
