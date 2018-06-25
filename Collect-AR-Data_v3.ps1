#
#  Collect all the autoruns files based on "host-list.txt"
#
$files = Get-Content -Path C:\ar_scripts\host-list.txt
foreach ($file in $files) {
    $computer = "\\"+$file
    $myFile =  "C:\ar_latest\"+$file+".csv"
    $myTfile = "C:\ar_latest\"+$file+".txt"
    PSexec $computer -accepteula autorunsc -accepteula -a * -s -m -t -h -ct *  2> $null 1> $myFile

    If ([System.IO.File]::Exists($myfile)) {
        #Remove nulls - Convert to ASCII
        $myInput = (Get-Content $myFile) -replace "`0","" | Out-File -Encoding ascii $myTfile

        # Get rid of empty lines in the file and skip 4 lines (PSexec header)
        $myInput = Get-Content $myTfile | where {$_ -ne ""} | select -Skip 4
        

        if ([string]::IsNullOrEmpty($myInput)) {
            Write-Host "Collect-AR-Data: " $myfile " does not have any data - Is machine - " $computer " online?" -ForegroundColor Yellow 
            # Remove all temp files
            if (Test-Path $myFile) {
                Remove-Item $myFile
            }
            if (Test-Path $myTFile) {
                Remove-Item $myTFile
            }
        }
        else {
            $myInput | Out-File $myTFile

            Move-Item $myTfile $myFile -Force
            Write-Host "Collect-AR-Data: file name = " $file " autoruns data collected."
        }
    }
    else {

        Write-Host "Collect-AR-Data: temporary file - " $myfile " does not exist - Is machine - " $computer " online?" -ForegroundColor Yellow 
    }
    
    

    
	
}
