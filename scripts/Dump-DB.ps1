#
# This script dumps all the data in the Ubuntu MySQL database (table=ar_data)
# This is a test script - not used directly in AutoRuns
# ----------------------------------------------------------------------
Import-Module C:\ar_scripts\AR-SQL.psm1
#
# Dumps the data from the MySQL database
#
Function Dump-Table {
    
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"
    
    $text = "Dump-Table: Start time = "+$mydate
    Write-Host $text
    $text | Out-File 'C:\Dump_Table.log' -Append

    $sql = "SELECT * FROM ar_data;"
    $myRows = New-Object System.Data.DataSet
    $myRows = Get-ODBC-Data $sql
    
    for ($i=1; $i -lt $myrows.Count; $i++) {
        $text = "Dump-Table: cnt "+$i+" "+$myRows[$i].fname+" "+$myRows[$i].mydate+" "+$myRows[$i].mytime+" "+$myRows[$i].id_hash+" "+$myRows[$i].ar_hash+" "+$myRows[$i].ar_entry+" "+$myRows[$i].ar_category
        Write-Host  $text
        $text | Out-File 'C:\Dump_Table.log' -Append
    }
    #----------

    $mydate = Get-Date -format "yyyyMMdd-HHmmss"
    $text = "Dump-Table: File Name = " + $fname + " Ended at = " +  $mydate + " -------------------------------------------------------"
    Write-Host $text
    $text | Out-File 'C:\Dump_Table.log' -Append
    Return $myRows
}

#
# Dump out the contents of the autoruns DB table
#
$MyRows = Dump-Table
Write-Host "Dump Table: Database has " $MyRows[0] " records." -ForegroundColor Green
