#
#  Creates a Hash (MD5, SHA1, SHA256, SHA384, SHA512, RIPEMD160) of a String
#  Source: https://gallery.technet.microsoft.com/scriptcenter/Get-StringHash-aa843f71
#
Function Get-StringHash([String] $String,$HashName = "MD5") 
{ 
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
        [Void]$StringBuilder.Append($_.ToString("x2"))  
    } 
    Return $StringBuilder.ToString() 
}

#
# Creates a Date Formatted as YYYY-MM-DD from a Date formated as YYYYMMDD
#
Function Get_Date ([String] $myDateTime )
{
    # Write-Host "Get_Date: " $myDateTime
    $myDate = $myDateTime
    $myYear = $myDate.Substring(0,4)
    $myMonth = $myDate.Substring(4,2)
    $myDay = $myDate.Substring(6,2)

    # Write-Host "Get_Date: " $myYear"-"$myMonth"-"$myDay
    $myDate = $myYear + "-" + $myMonth +"-" +$myDay
    # Write-Host "Get_Date: " $myDate
    Return $myDate
}

#
# Creates a Time Formatted as HH:MM:SS from a Time formated as HHMMSS (assunes 24 HR format)
#
Function Get_Time ([String] $myDateTime )
{
    # Write-Host "Get_Time: " $myDateTime
    $myTime = $myDateTime
    $myHour = $myTime.Substring(9,2)
    $myMin = $myTime.Substring(11,2)
    $mySec = $myTime.Substring(13,2)

    # Write-Host "Get_Time: " $myHour":"$myMin":"$mySec
    $myTime = $myHour + ":" + $myMin + ":" + $mySec
    # Write-Host "Get_Time: " $myTime
    Return $myTime
}

#
# Function Fills in the MySQL DB for a particular file specified in "fpath"
#
Function Check-Table {
param(
    [Parameter(Position=1,Mandatory=$True)][string]$fpath
    )
    #
    $myTest =  0
    $mySubTotal = 0

    #Number of lines until the data portion
    $myOffset = 4
    $D = (Get-Content $fpath) -replace "\t","|"
    # Remove Sub headers
    $D = $D -notmatch "\|\|\|\|\|\|\|\|\|\|"
    # Remove "file not found problems"
    $D = $D -notmatch "\|\|\|\|\|\|"
    # $D | Out-File -FilePath C:\ar_latest\test2.log
    
    if ($myTest -eq 1) {
        Write-Host "Check-Table: fpath = " $fpath
    }
    
    $myFname = $fpath -split "\\"
    $fname = $myFname[2]
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"

    if ($myTest -eq 1) {
        $text = "Check-Table: File Name = " + $fname + " Started at = " +  $mydate + " ++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        Write-Host $text
        # $text | Out-File 'C:\Check_Table.log' -Append

        $text = "Check-Table: Offset to Data portion = " + $myOffset
        Write-Host $text
        # $text | Out-File 'C:\Check_Table.log' -Append

        $text = "Check-Table: Line Count = " + $D.Length
        Write-Host $text
        # $text | Out-File 'C:\Check_Table.log' -Append
    }

    # Calculate length of Data portion
    $myDlength = $D.Length - $myOffset
    
    if ($myTest -eq 2) {
        Write-Host "Check-Table: Line Count of Data portion = " $myDlength
        #
        # Show header values
        Write-Host $D[$myOffset-1]
        Write-Host "Header Values below:"
        # Split header Values
        $myHdr = $D[$myOffset-1] -split '\|'
        # Set the number of header elements
        $myHdrCnt = 17
        Write-Host "Check-Table: Header Count = " $myHdrCnt

        # Show all header values from array
        for ($i=0; $i -le $myHdrCnt; $i++) {
            Write-Host $myHdr[$i]
        }
        Write-Host "myOffset = " $myOffset
    }

    if ($myTest -eq 1) {
        Write-Host "*******************************************************************************************************"
        Write-Host "CNT DATE     Time     MD5 of EntryLocation+Entry                       SHA1                     Entry"
    }
    
    $y = 0
    for($i=$myOffset; $i -le $myDlength+$myOffset-1; $i++) {
        $myData = $D[$i] -split "\|"
        
        $myDateTime = $myData[0] -split '-'
        # Write-Host "myData[0] = " $myData[0] "------------------------------------------------------------------" $i
        # Write-Host "myData[4] = " $myData[4] "------------------------------------------------------------------" $i
        
        $y = $y +1
        # Entry Locattion\Entry+fname is used to calculate a unique ID hash for indexing
        # $myStr = $myData[1] + "\"  + $myData[2] + $fname
        $myStr = $myData[1] + "\"  + $myData[2] + $myData[11] + $fname 
        $id_hash = Get-StringHash($myStr, "MD5")
        $mydate = Get_Date( $myDateTime )
        $mytime = Get_Time( $myDateTime )
        $ar_hash = $myData[13]
        $ar_entry = $myData[2]
        $ar_category = $myData[4]
        #----------
        if ($myTest -eq 1) {
            Write-Host "Check_Table: " $i $y $fname $myDate $mytime $id_hash $ar_hash $ar_entry "--" $ar_category 
            $text = "Check_Table: " + " " + $i + " " + $y +" " + $fname + " " +  $myDate + " " + $mytime + " " + $id_hash + " " + $ar_hash + " " + $ar_entry + " -- " + $ar_category 
            # $text | Out-File 'C:\Check_Table.log' -Append
        }
        #----------
        $sql = "SELECT * FROM ar_data WHERE id_hash='$id_hash';"
        $myRows = Get-ODBC-Data $sql

        if ($myTest -eq 1) {
            $text = "Check_Table:= row count = " + $myRows[0]
            Write-Host $text
            # $text | Out-File 'C:\Check_Table.log' -Append

            $text = "Check_Table: id_hash = " + $myRows[1].id_hash
            Write-Host $text
            # $text | Out-File 'C:\Check_Table.log' -Append
        }

        if ($myRows[1].id_hash -eq $id_hash) {
            if ($myTest -eq 1) {
                $text = "Check_Table: id_hash in DB table!"
                Write-Host $text
            }    # $text | Out-File 'C:\Check_Table.log' -Append
            
            # Great, but do the ar_hashes match?
            if ($myRows[1].ar_hash -eq $ar_hash) {
                if ($myTest -eq 1) {
                    $text = "Check_Table: ar_hashes match!"
                    Write-Host $text -ForegroundColor DarkGreen
                    # $text | Out-File 'C:\Check_Table.log' -Append
                }
                $mySubTotal = $mySubTotal + 1
            }
            Else {
                #
                $text = "Check_Table: ar_hashes DO NOT MATCH! - RED ALERT. ar_entry ="+$ar_entry+" ar_category ="+$ar_category
                Write-Host $text -ForegroundColor Red -BackgroundColor White
                # $text | Out-File 'C:\Check_Table.log' -Append
            }
        }
        Else {
            # if you cant find the id_hash in the DB then it may be a new item to be added
            $text = "Check_Table: id_hash CAN NOT be found in DB table! - Time for new baseline? ar_entry ="+$ar_entry+" ar_category ="+$ar_category
            Write-Host $text -ForegroundColor Yellow
            # $text | Out-File 'C:\Check_Table.log' -Append
        }
            #----------
    # End of For loop
    }
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"
    $text = "Check-Table: File Name = " + $fname + " Records = " + $mySubTotal + " Ended at = " +  $mydate
    Write-Host $text
    Write-Host " "
    # $text | Out-File 'C:\Check_Table.log' -Append
    Return $mySubTotal
}


#
# Function retruns a record from the MySQL database based on "id_hash"
#
Function Get-ODBC-Data{
    param(
    [Parameter(Position=0,Mandatory=$True)][string]$sql
    )

    $myDebug = 0
    $mydsn = "MySQLlinux;"
    $dsn = "DSN="+$mydsn
    
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
# Get a list of files from $fpath
#  and call Check_Table for each file
#
Function Get-Files {
param(
    [Parameter(Position=0,Mandatory=$True)][string]$fpath
    )

    $myTotal = 0
    $files = Get-ChildItem $fpath -Filter *.csv
    for ($i=0; $i -lt $files.Count; $i++) {
        # $outfile = $files[$i].FullName
        $mypath = $files[$i].FullName
        Write-Host  "Get-Files: file = " $mypath
        $mySubTotal = Check-Table($mypath)
        $myTotal = $myTotal + $mySubTotal
    }
    Return $myTotal
}

#
# This script compares the contents of files located at $fpath
# to the values stored in the MySQL database (DSN=MySQLlinux;) DB=autoruns, table=ar_data
# 
$fpath = "c:\ar_latest\"
$myrecords = Get-Files($fpath) 
Write-Host "Check Hash: Total records successfuly compared = " $myrecords -ForegroundColor Green

