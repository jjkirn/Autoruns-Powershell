<#
Original Author: Jim Kirn
Version: 2018.06.18-Rev1

This script is licensed under the terms of the MIT license.
#>

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

    $SourceFile = "C:\Users\jim\Desktop\AR-Normalize\lulu777.csv"
    $TargetFile = "C:\Users\jim\Desktop\AR-Normalize\test.htm"


$import = Import-Csv $SourceFile -Delimiter "`t"
$import | ConvertTo-Html -Head $Header -Body "&lt;H2&gt;Delta Report&lt;/H2&gt;"| Out-File $TargetFile
