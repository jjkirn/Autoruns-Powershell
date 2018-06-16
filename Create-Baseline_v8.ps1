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
# Function Fills in the MySQL DB for a specified file
#
Function Fill-Table ($fpath) 
{
    #$D = Get-Content $fpath
    Write-Host $fpath
    # Number of lines until the data portion
    #
    $myTest = 0
    $mySubTotal = 0
    $myOffset = 4
    $D = (Get-Content $fpath) -replace "\t","|"
    # $D = $D -replace "'",""
    
    # Remove Sub headers
    $D = $D -notmatch "\|\|\|\|\|\|\|\|\|\|"
    # Remove "file not found problems"
    $D = $D -notmatch "\|\|\|\|\|\|"
    $D = $D -replace "'", ""
    # $D = $D -replace "(",""
    # $D = $D -replace ")",""

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
        $myHdr = $D[$myOffset-1] -split '\t'
        # Set the number of header elements
        $myHdrCnt = 17
        Write-Host "Fill-Table: Header Count = " $myHdrCnt

        # Show all header values from array
        for ($i=0; $i -le $myHdrCnt; $i++) {
            Write-Host $myHdr[$i]
        }
        Write-Host "myOffset = " $myOffset
    }

    Write-Host "*******************************************************************************************************"
    Write-Host "CNT DATE     Time     MD5 of EntryLocation+Entry                       SHA1                     Entry"
    $y = 0
    for($i=$myOffset; $i -le $myDlength+$myOffset -1; $i++) {
        $myData = $D[$i] -split "\|"
        $myDateTime = $myData[0] -split '-'
        # Write-Host "myData[0] = " $myData[0] "------------------------------------------------------------------" $i
        # Write-Host "myData[4] = " $myData[4] "------------------------------------------------------------------" $i
        
        $y = $y +1
        # Entry Location\Entry+fname is used to calculate a unique ID hash for indexing
        #$myStr = $myData[1] + "\"  + $myData[2] + $fname   
		$myStr = $myData[1] + "\"  + $myData[2] + $myData[11] + $fname 
        $id_hash = Get-StringHash($myStr, "MD5")
        $mydate = Get_Date( $myDateTime )
        $mytime = Get_Time( $myDateTime )
        $ar_hash = $myData[13]
        $ar_entryloc = $myData[1]
        $ar_entry = $myData[2]
        $ar_enabled = $myData[3]
        $ar_category = $myData[4]
        $ar_profile = $myData[5]
        $ar_desc = $myData[6]
        $ar_signer = $myData[7]
        $ar_company = $myData[8]
        $ar_ipath = $myData[9]
        $ar_ver = $myData[10]
        $ar_lstr = $myData[11]

        #----------
        Write-Host $i $y $fname $myDate $mytime $id_hash $ar_hash $ar_entry "--" $ar_category 
           
        $rc = Insert-ODBC-Data $fname $myDate $mytime $id_hash $ar_entryloc $ar_entry $ar_enabled $ar_category $ar_profile $ar_desc $ar_signer $ar_company $ar_ipath $ar_ver $ar_lstr $ar_hash 
        Write-Host "Fill-Table: = " $rc
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
  # fname $myDate $mytime $id_hash $ar_entryloc $ar_entry $ar_enabled $ar_category $ar_profile $ar_desc $ar_signer $ar_company $ar_ipath $ar_ver $ar_lstr $ar_hash 
    $myDSN = "MySQLlinux"
    $dsn="DSN=$myDSN;"

    # Write-Host "Insert-ODBC-Data: DSN = " $dsn
	$conn = New-Object System.Data.Odbc.OdbcConnection
	$conn.ConnectionString = $dsn
    $conn.open()
  
    $cmd = New-Object System.Data.Odbc.OdbcCommand

    $cmd.Connection = $conn
    Write-Host "Insert-ODBC-Data: fname,mydate,mytime,id_hash,ar_hash,ar_entry,ar_category" $fname $mydate $mytime $id_hash $ar_hash $ar_entry $ar_category

	$cmd.CommandText = "INSERT INTO ar_data (fname,mydate,mytime,id_hash,ar_entryloc,ar_entry,ar_enabled,ar_category,ar_profile,ar_desc,ar_signer,ar_company,ar_ipath,ar_ver,ar_lstr,ar_hash) VALUES('$fname','$mydate','$mytime','$id_hash','$ar_entryloc','$ar_entry','$ar_enabled','$ar_category','$ar_profile','$ar_desc','$ar_signer','$ar_company','$ar_ipath','$ar_ver','$ar_lstr','$ar_hash');"
    Write-Host "Insert-ODBC-Data: cmd.CommandText =" $cmd.CommandText

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
# Get a list of files from $fpath
# Call Fill-Table for each file to create the MySql DB
#
Function Get-Files{
    param(
        [string]$fpath
	)

    $myTotal = 0
    $files = Get-ChildItem $fpath -Filter *.csv
    for ($i=0; $i -lt $files.Count; $i++) {

        $mypath = $files[$i].FullName
        Write-Host  "Get-Files: file = " $mypath
        $mySubTotal = Fill-Table($mypath)
        $myTotal = $myTotal + $mySubTotal
    }
    Return $myTotal
}

#
# Populate the MySQL Database (DSN=MySQLlinux), DB=autoruns, table=ar_data
#  from the *.csv files located at $fpath
#
#-----------------------
# Path to where the file is located
$fpath = "c:\ar_baselines\"
#
# Clear out old data from Table=ar_data
$mySQL = "TRUNCATE TABLE ar_data;"
$test = Get-ODBC-Data $mySQL
Write-Host "Create-Baseline: ar_data DB table cleared." -ForegroundColor Green
#
# Populate new data into the DB/Table
$myTotal = Get-Files($fpath)
Write-Host "Create-Baseline: Total records = " $myTotal " inserted into Database." -ForegroundColor Green
