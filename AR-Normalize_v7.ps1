$fpath = "c:/ar_latest/"
$files = Get-ChildItem $fpath -Filter *.csv
$myTotal = 0

for ($i=0; $i -lt $files.Count; $i++) {
    # change the path to where the the .csv files are stored.

    $mySubTotal = 0
    #Store the name of the file & date
    $myFile = $fpath+$files[$i]
    $SystemName = (Get-Item $myfile).BaseName
    $FileDate = (Get-Item $myfile).CreationTime

    #Skips the header row and preapends the following to each message: Unique Identifer, System Name, Date
    # Skip 6 lines - Autoruns header
    $myOffset = 4
    # Replaces tabs with "|" because Security Onion cant handle tabs
    $myContent = (Get-Content $files[$i].fullname) -replace "\t","|"
    # Removes Autoruns file Subheaders
    $myContent = $myContent -notmatch "\|\|\|\|\|\|\|\|\|\|"
    # Remove "file not found problems
    $myContent = $myContent -notmatch "\|\|\|\|\|\|"
    $myDlength = $myContent.Length - $myOffset
    # $myContent | Out-File -Append -Encoding ascii -FilePath c:\ar_latest\test.log
    for ($j=$myOffset; $j -le $myDlength+$myOffset-1; $j++) {
        $myHdr = "AR-LOG|"+$SystemName+"|"+$FileDate+"|"
        $myData = $myHdr+$myContent[$j]
        $myData | Out-File -Append -Encoding ascii -FilePath c:\ar_latest\ar-normalized.log
        $mySubTotal = $mySubTotal+1
    }

    #Appends the resulting message in ascii (OSSEC Windows Client does not support Unicode logs)
    Write-Host "Appended file = " $myfile ", " $mySubTotal "records."
    $myTotal = $myTotal+$mySubTotal

    #Deletes the consumed logfile
    # Remove-Item $_.fullname
}
Write-Host "Total records =" $myTotal
#
# Create a zip archive of contents
#
$source = "C:\ar_latest\"
$dest ="C:\ar_archive\myArchive"
$mydate = Get-Date -format "yyyyMMdd-HHmmss"
$destination = $dest+"-"+$mydate+".zip"
#
If (Test-Path $destination) {
    Remove-Item $destination
}
# Create the archive of all files
Add-Type -AssemblyName "system.IO.Compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($source,$destination)
# Get rid of old *csv files
Write-Host "Created zip archive - " $destination
$sourceFiles = Get-ChildItem $source -Filter *.csv
for ($i=0; $i -lt $sourceFiles.Count; $i++) {
	$myRemove = $sourceFiles[$i].FullName
    # Remove-Item $myRemove
	Write-Host "Removed file = " $myRemove
}
