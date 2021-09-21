#
# Sign a PowerShell script example
#
$cert = @(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]
Set-AuthenticodeSignature C:\ar_scripts\Delta2-Hashes.ps1 $cert