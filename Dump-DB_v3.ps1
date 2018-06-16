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
# Function retruns a record from the MySQL database based on "sql"
#
Function Get-ODBC-Data{
    param(
    [Parameter(Position=0,Mandatory=$True)][string]$sql
    )

    $myDebug = 0
	
    $dname = "MySQLlinux"
    $dsn = "DSN=$dname;"
	
    #$sql = "SELECT * FROM ar_data WHERE id_hash='$id_hash';"
    #$sql = "SELECT * FROM ar_data WHERE ar_category='Explorer';"
    
    if( $myDebug -eq 1) {
        Write-Host "Get-ODBC-Data: DSN = " $dsn
		Write-Host "Get-ODBC-Data: sql= " $sql
    }

    $conn = New-Object System.Data.Odbc.OdbcConnection
    $conn.ConnectionString = $dsn
    $conn.open()

    $SqlCmd = New-Object System.Data.Odbc.OdbcCommand
   
    $SqlCmd.CommandText = $sql
    $SqlAdapter = New-Object System.Data.Odbc.OdbcDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $SqlCmd.Connection = $conn
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)

    $conn.Close()

    if( $myDebug -eq 1) {
        Write-Host "Get-ODBC-Data: ds.Tables[0] =" $DataSet.Tables[0]
    }
    Return $DataSet.Tables[0]
}

#
# Dump out the contents of the autoruns DB table
#
$MyRows = Dump-Table
Write-Host "Dump Table: Database has " $MyRows[0] " records." -ForegroundColor Green
