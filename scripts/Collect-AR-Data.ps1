#
#  Collect all the autoruns files based on contents of "host-list.txt"
#
# ---------------------------------------------------------
$files = Get-Content -Path C:\ar_scripts\host-list.txt
foreach ($file in $files) {
    $computer = "\\"+$file
    $myFile =  "C:\ar_latest\"+$file+".csv"
    $myTfile = "C:\ar_latest\"+$file+".txt"
	# Use PSexec to execute autoruns on each host and collect the output
    PSexec $computer -accepteula autorunsc -accepteula -a * -s -m -t -h -ct *  2> $null 1> $myFile
    # below is for debug only
    # Copy-Item $myFile "C:\ar_latest\orig.txt" -Force

	# Clean the text file from empty lines, nulls and tabs and add semicoln as a delimiter
    If ([System.IO.File]::Exists($myfile)) {
        # Remove nulls - Convert to ASCII
        $myInput = (Get-Content $myFile) -replace "`0","" | Out-File -Encoding ascii $myTfile
        # Add semicoln as a delimiter
        $myInput = (Get-Content $myTfile) -replace "`t","|" | Out-File -Encoding ascii $myfile

        # Get rid of empty lines in the file and skip 4 lines (PSexec header)
        $myInput = Get-Content $myfile | where {$_ -ne ""} | select -Skip 4 |  Out-File -Encoding ascii $myTfile

###########
        # Remove Sub headers
        $myInput = Get-Content $myTfile | Where { $_ -notmatch "\|\|\|\|\|\|" } | Set-Content $myfile
###########
        $myInput = Get-Content $myfile
		# Handle missing data
        if ([string]::IsNullOrEmpty($myInput)) {
            Write-Host "Collect-AR-Data: " $myfile " does not have any data - Is machine - " $computer " online?" -ForegroundColor Yellow 
            # Remove all temp files
            if (Test-Path $myFile) {
                Remove-Item $myFile
            }
            if (Test-Path $myTfle) {
                Remove-Item $myTfile
            }
        }
        else {
            # OK - good file with content
            $myInput | Out-File $myTfile
            #######
            # remove lines at end
            $content = Get-Content $myTFile
            $content[0..($content.length-6)] | Set-Content $myTfile
            #######

            Move-Item $myTfile $myFile -Force
            Write-Host "Collect-AR-Data: file name = " $file " autoruns data collected."
        }
    }
    else {

        Write-Host "Collect-AR-Data: temporary file - " $myfile " does not exist - Is machine - " $computer " online?" -ForegroundColor Yellow 
    }
	
}
