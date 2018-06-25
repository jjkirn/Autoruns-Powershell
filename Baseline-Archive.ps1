#
# Create a zip archive of ar_baseline contents
#

$SourcePath = "C:\ar_baselines\"

$Dest = "C:\ar_archive\Baseline"

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

Write-Host "Completed archive operation - " $Destination
