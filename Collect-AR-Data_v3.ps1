#
#  Collect (using PSexec) all the autoruns files specified in "host-list.txt"
#
$files = Get-Content -Path C:\ar_scripts\host-list.txt
foreach ($file in $files) {
    $computer = "\\"+$file
    $myFile =  "C:\ar_latest\"+$file+".csv"
    $myTfile = "C:\ar_latest\"+$file+".txt"
    PSexec $computer -accepteula autorunsc -accepteula -a * -s -m -t -h -ct *  2> $null 1> $myFile
    
    # Get rid of nulls in the file
    (Get-Content $myfile) -replace "`0","" | Set-Content $myFile
 
    # Get rid of empty lines in the file and skip 4 lines (PSexec header)
    Get-Content $myfile | where {$_ -ne ""} | select -Skip 4 | Set-Content $myTfile
    If (![System.IO.File]::Exists($myTfile)) {
        Write-Host "Collect-AR-Data: temporary file - " $myTfile " does not exist - Is machine - " $computer " online?" -ForegroundColor Yellow
    }
    else {
        Move-Item $myTfile $myFile -Force
        Write-Host "Collect-AR-Data: file name = " $file " autoruns data collected."
    }
	
}
