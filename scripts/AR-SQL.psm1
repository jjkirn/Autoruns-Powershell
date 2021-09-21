#
# Several SQL related functions
# Get-Files, Fill-Table, Insert-ODBC-Data, Get-ODBC-Data, Check-Table
#---------------------------------------------------------------------
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
Function Get_Date([String] $myDateTime )
{
    Write-Host "Get_Date: " $myDateTime
    $myDate = $myDateTime
    $myYear = $myDate.Substring(0,4)
    $myMonth = $myDate.Substring(4,2)
    $myDay = $myDate.Substring(6,2)

    # Write-Host "Get_Date: " $myYear"-"$myMonth"-"$myDay
    $myDate = $myYear + "-" + $myMonth +"-" +$myDay
    Write-Host "Get_Date: " $myDate
    Return $myDate
}

#
# Creates a Time Formatted as HH:MM:SS from a Time formated as HHMMSS (assunes 24 HR format)
#
Function Get_Time([String] $myDateTime )
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
# Get a list of files from $fpath
# Call Fill-Table for each file to create the MySql DB
#
Function Get-Files {
    param(
        [string]$fpath
	)

    $myTest = 0
    $myTotal = 0
    $files = Get-ChildItem $fpath -Filter *.csv
    for ($i=0; $i -lt $files.Count; $i++) {

        $mypath = $files[$i].FullName
        if( $myTest -eq 1) {
            Write-Host  "Get-Files: file = " $mypath
        }
        $mySubTotal = Fill-Table($mypath)
        $myTotal = $myTotal + $mySubTotal
    }
    Return $myTotal
}

#
# Get a list of files from $fpath
#  and call Check_Table for each file
#
Function Compare-Files {
param(
    [Parameter(Position=0,Mandatory=$True)][string]$fpath
    )

    $myTotal = 0
    $files = Get-ChildItem $fpath -Filter *.csv
    for ($i=0; $i -lt $files.Count; $i++) {
        # $outfile = $files[$i].FullName
        $mypath = $files[$i].FullName
        # Write-Host  "File = " $mypath
        $mySubTotal = Check-Table($mypath)
        $myTotal = $myTotal + $mySubTotal
    }
    Return $myTotal
}

#
# Function Fills in the MySQL DB for a specified file
#

Function Fill-Table ($fpath) 
{
    #$D = Get-Content $fpath
    # Write-Host $fpath
    # Number of lines until the data portion
    #
    $myTest = 0
    $mySubTotal = 0
    $myOffset = 4
    $D = (Get-Content $fpath)

    $myFname = $fpath -split "\\"
    $fname = $myFname[2]
	$mydate = Get-Date -format "yyyyMMdd-HHmmss"
    Write-Host "Fill-Table: File Name = " $fname "Started at = " $mydate

    if ($myTest -eq 1) {
        Write-Host "Fill-Table: Offset to Data portion = " $myOffset
        Write-Host "Fill-Table: Line Count = " $D.Length
    }

    # Calculate length of Data portion
    $myDlength = $D.Length - $myOffset
    # $D | Out-File -FilePath c:\ar_latest\test.log
    
    if ($myTest -eq 1) {
        Write-Host "Fill-Table: Line Count of Data portion = " $myDlength
        #
        # Show header values
        Write-Host $D[$myOffset-1]
        Write-Host "Header Values below:"
        # Split header Values
        $myHdr = $D[$myOffset-1] -split '\|'
        # Set the number of header elements
        $myHdrCnt = 17
        Write-Host "Fill-Table: Header Count = " $myHdrCnt

        # Show all header values from array
        for ($i=0; $i -le $myHdrCnt; $i++) {
            Write-Host $myHdr[$i]
        }
        Write-Host "myOffset = " $myOffset
    }

    if( $myTest -eq 1) {
        Write-Host "*******************************************************************************************************"
        Write-Host "CNT DATE     Time     MD5 of EntryLocation+Entry                       SHA1                     Entry"
    }

    $y = 0
    for($i=$myOffset; $i -le $myDlength+$myOffset -1; $i++) {
        $myData = $D[$i] -split "\|"
        $myDateTime = $myData[0] -split '-'
        # Write-Host "myData[0] = " $myData[0] "------------------------------------------------------------------" $i
        # Write-Host "myData[4] = " $myData[4] "------------------------------------------------------------------" $i
        
        
        $y = $y +1
        # Entry Location\Entry+Profile+Launch String+fname is used to calculate a unique ID hash for indexing  
		$myStr = $myData[1] + "\"  + $myData[2] + $myData[5] + $myData[11] + $fname 
        $id_hash = Get-StringHash($myStr, "MD5")
        $mydate = Get_Date( $myDateTime )
        $mytime = Get_Time( $myDateTime )

        # Clean up some embedded text to prevent SQL issues
        $ar_entryloc = $myData[1]
        $ar_entry = $myData[2]
        $ar_enabled = $myData[3]
        $ar_category = $myData[4]
        $ar_profile = $myData[5]
        $ar_desc = $myData[6] -replace "'",""
        $ar_desc = $ar_desc -replace "@",""
        $ar_desc = $ar_desc -replace ","," "
        $ar_desc = $ar_desc -replace "%",""
        $ar_signer = $myData[7]
        $ar_company = $myData[8]
        $ar_ipath = $myData[9]
        $ar_ver = $myData[10]
        $ar_lstr = $myData[11] -replace '"',''
        $ar_hash = $myData[13]  # SHA-1

        # Make sure there are no null values
        if(!$ar_entryloc) {$ar_entryloc="Blank"}
        if(!$ar_entry) {$ar_entry="Blank"}
        if(!$ar_enabled) {$ar_enabled="Blank"}
        if(!$ar_category) {$ar_category="Blank"}
        if(!$ar_profile) {$ar_profile="Blank"}
        if(!$ar_desc) {$ar_desc="Blank"}
        if(!$ar_signer) {$ar_signer="Blank "}
        if(!$ar_company) {$ar_company="Blank"}
        if(!$ar_ipath) {$ar_ipath="Blank"}
        if(!$ar_ver) {$ar_ver="Blank"}
        if(!$ar_lstr) {$ar_lstr="Blank"}
        if(!$ar_hash) {$ar_hash="Blank"}

        #----------
        if ($myTest -eq 1) {
            Write-Host $i $y $fname $myDate $mytime $id_hash $ar_hash $ar_entry "--" $ar_category 
        }
           
        $rc = Insert-ODBC-Data $fname $myDate $mytime $id_hash $ar_entryloc $ar_entry $ar_enabled $ar_category $ar_profile $ar_desc $ar_signer $ar_company $ar_ipath $ar_ver $ar_lstr $ar_hash 
        if ($myTest -eq 1) {
            Write-Host "Fill-Table: = " $rc
        }
        #----------
        $mySubtotal = $mySubTotal + 1
        
    # End of For loop
    }
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"
    Write-Host "Fill-Table: File Name = " $fname "Ended at = " $mydate " Records added = " $mySubTotal
	Return $mySubTotal
}

#
# Function inserts a record into the MySQL database
#
# Populate the MySQL Database (DSN=MySQLlinux), DB=autoruns, table=ar_data
#--------------------------------------------------------------------------
Function Insert-ODBC-Data {
	param(
    [string]$fname,
    [string]$mydate,
    [string]$mytime,
    [string]$id_hash,
    [string]$ar_entryloc,
    [string]$ar_entry,
    [string]$ar_enabled,
    [string]$ar_category,
    [string]$ar_profile,
    [string]$ar_desc,
    [string]$ar_signer,
    [string]$ar_company,
    [string]$ar_ipath,
    [string]$ar_ver,
    [string]$ar_lstr,
    [string]$ar_hash
	)

    $myDebug = 1
  # fname $myDate $mytime $id_hash $ar_entryloc $ar_entry $ar_enabled $ar_category $ar_profile $ar_desc $ar_signer $ar_company $ar_ipath $ar_ver $ar_lstr $ar_hash 
    $myDSN = "MySQLlinux"
    $dsn="DSN=$myDSN;"

    # Write-Host "Insert-ODBC-Data: DSN = " $dsn
	$conn = New-Object System.Data.Odbc.OdbcConnection
	$conn.ConnectionString = $dsn
    $conn.open()
  
    $cmd = New-Object System.Data.Odbc.OdbcCommand

    $cmd.Connection = $conn
    if( $myDebug -eq 1) {
        Write-Host "Insert-ODBC-Data: fname,mydate,mytime,id_hash,ar_hash,ar_entry,ar_category" $fname $mydate $mytime $id_hash $ar_hash $ar_entry $ar_category
    }

	$cmd.CommandText = "INSERT INTO ar_data (fname,mydate,mytime,id_hash,ar_entryloc,ar_entry,ar_enabled,ar_category,ar_profile,ar_desc,ar_signer,ar_company,ar_ipath,ar_ver,ar_lstr,ar_hash) VALUES('$fname','$mydate','$mytime','$id_hash','$ar_entryloc','$ar_entry','$ar_enabled','$ar_category','$ar_profile','$ar_desc','$ar_signer','$ar_company','$ar_ipath','$ar_ver','$ar_lstr','$ar_hash');"
    if( $myDebug -eq 1) {
        Write-Host "Insert-ODBC-Data: cmd.CommandText =" $cmd.CommandText
    }

	$dr=$cmd.ExecuteNonQuery()

    $conn.Close()
    Return $dr
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
# Function Compares file contents to the MySQL DB for a particular file specified in "fpath"
#
Function Check-Table {
param(
    [Parameter(Position=1,Mandatory=$True)][string]$fpath
    )
    #
    $myTest =  0
    $mySubTotal = 0
    $LogFileName = "C:\Delta.log"
    # Number of lines until the data portion
    $myOffset = 4
    $D = (Get-Content $fpath)
    
    if ($myTest -eq 1) {
        Write-Host "Check-Table: fpath = " $fpath
    }
    
    $myFname = $fpath -split "\\"
    $fname = $myFname[2]
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"

    if ($myTest -eq 1) {
        $text = "Check-Table: File Name = " + $fname + " Started at = " +  $mydate + " ++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        Write-Host $text
        # $text | Out-File $LogFileName -Append

        $text = "Check-Table: Offset to Data portion = " + $myOffset
        Write-Host $text
        # $text | Out-File $LogFileName -Append

        $text = "Check-Table: Line Count = " + $D.Length
        Write-Host $text
        # $text | Out-File $LogFileName -Append
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
    $MisMatch = 0

    for($i=$myOffset; $i -le $myDlength+$myOffset-1; $i++) {
        $myData = $D[$i] -split "\|"  
        $myDateTime = $myData[0] -split '-'
        # Write-Host "myData[0] = " $myData[0] "------------------------------------------------------------------" $i
        # Write-Host "myData[4] = " $myData[4] "------------------------------------------------------------------" $i
        
        $y = $y +1

        # Entry Location\Entry+Profile+Launch String+fname is used to calculate a unique ID hash for indexing  
		$myStr = $myData[1] + "\"  + $myData[2] + $myData[5] + $myData[11] + $fname 

        $id_hash = Get-StringHash($myStr, "MD5")
        $mydate = Get_Date( $myDateTime )
        $mytime = Get_Time( $myDateTime )
        # Use SHA-1 for ar_hash
        $ar_hash = $myData[13]
        $ar_entry = $myData[2]
        $ar_category = $myData[4]
        
        #----------
        if ($myTest -eq 1) {
            Write-Host "Check_Table: " $i $y $fname $myDate $mytime $id_hash $ar_hash $ar_entry "--" $ar_category 
            $text = "Check_Table: " + " " + $i + " " + $y +" " + $fname + " " +  $myDate + " " + $mytime + " " + $id_hash + " " + $ar_hash + " " + $ar_entry + " -- " + $ar_category 
            # $text | Out-File $LogFileName -Append
        }
        #----------
       
        $sql = "SELECT * FROM ar_data WHERE id_hash='$id_hash';"
        $myRows = Get-ODBC-Data $sql

        if ($myTest -eq 1) {
            $text = "Check_Table:= row count = " + $myRows[0]
            Write-Host $text
            # $text | Out-File $LogFileName -Append

            $text = "Check_Table: id_hash = " + $myRows[1].id_hash
            Write-Host $text
            # $text | Out-File $LogFileName -Append
        }

        # Compare DB id_hash to file id_hash
        if ($myRows[1].id_hash -eq $id_hash) {
            # OK they match - continue!
            if ($myTest -eq 1) {
                $text = "Check_Table: id_hash in DB table!"
                Write-Host $text
                # $text | Out-File $LogFileName -Append
            }
            
            # Great, but do the ar_hashes (SHA-1) match?
            if ($myRows[1].ar_hash -eq $ar_hash) {
                if ($myTest -eq 1) {
                    $text = "Check_Table: ar_hashes match!"
                    Write-Host $text -ForegroundColor DarkGreen
                    # $text | Out-File $LogFileName -Append
                }
                # OK looks like we have a good match - Do nothing!
                $mySubTotal = $mySubTotal + 1
            }
            Else {
                # Otherwise we have no match
                $text = "DM: (line = "+($myOffset+$y+2)+") (ar_entry = "+$ar_entry+") (ar_category = "+$ar_category+") (SHA1 = "+$ar_hash+")"
                Write-Host $text -ForegroundColor Red -BackgroundColor White
                $text | Out-File $LogFileName -Append
                $MisMatch += 1
            }
        }
        Else {
            # We can't find the id_hash in the DB then it may be a new item to be added
            $text = "NF: (line = "+($myOffset+$y+2)+") (ar_entry = "+$ar_entry+") (ar_category = "+$ar_category+") (SHA1 = "+$ar_hash+")"
            Write-Host $text -ForegroundColor Yellow
            $text | Out-File $LogFileName -Append
            $MisMatch += 1
        }
            #----------
    # End of For loop
    }
    $mydate = Get-Date -format "yyyyMMdd-HHmmss"
    $text = "File Name = " + $fname + " (Records = " + $mySubTotal + ") (Mismatches = " + $MisMatch + ") Ended at = " +  $mydate
    Write-Host $text
    Write-Host " "
    $text | Out-File $LogFileName -Append
    $text = "---------------------------------------------------------------------- "
    $text | Out-File $LogFileName -Append
    Return $mySubTotal
}
