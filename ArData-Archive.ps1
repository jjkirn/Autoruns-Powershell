#
# Create a zip archive of ar_latest contents and delete old files
#

$SourcePath = "C:\ar_latest\"

$Dest = "C:\ar_archive\myArchive"

$mydate = Get-Date -format "yyyyMMdd-HHmmss"
$Destination = $Dest+"-"+$mydate+".zip"

# If file already exsits - remove it
If (Test-Path $Destination) {
    Remove-Item $Destination
}

# Create the archive of all files
Add-Type -AssemblyName "system.IO.Compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($SourcePath,$Destination)
Write-Host "Created zip archive - " $Destination

# Get rid of old *csv files
$sourceFiles = Get-ChildItem $SourcePath -Filter *.csv
for ($i=0; $i -lt $sourceFiles.Count; $i++) {
	$myRemove = $sourceFiles[$i].FullName
    Remove-Item $myRemove
	Write-Host "Removed file = " $myRemove
}

Write-Host "Completed archive operation - " $Destination
