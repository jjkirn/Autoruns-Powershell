#
# Move all the files in ar_latest directory to ar_baseline
#
	$from_path = "C:\ar_latest\"
	$to_path = "C:\ar_baselines\"

	$from_files = Get-ChildItem $from_path -Filter *.csv
	for ($i=0; $i -lt $from_files.Count; $i++) {
       $base_file = $from_files[$i].BaseName
       $new_file = $base_file+".csv"
       $mypath1 = $from_files[$i].FullName
       $mypath2 = $to_path+$new_file
       Write-Host  "Copy-Files: from:" $mypath1 "to:" $mypath2
       Copy-Item $mypath1 $mypath2
       Write-Host "Files moved to " $to_path " at " $mydate
    }
