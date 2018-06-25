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
# Read DB
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
    $myText = "Found "+ $myRows.Count+" Rows."
    Write-Host $myText

    # Locate all the un-Verified items
    for($i=1; $i -lt $myRows.count; $i++)  {
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
