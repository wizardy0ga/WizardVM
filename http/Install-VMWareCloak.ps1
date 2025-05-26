<#
.DESCRIPTION
Wrapper script for running vmwarecloak from the system context
#>
$PsExec = "c:\windows\temp\psexec.exe"
try {
    Invoke-WebRequest -Uri live.sysinternals.com/psexec64.exe -outfile $PsExec
    & $PsExec -s -accepteula powershell.exe -file c:\windows\temp\vmwarecloak.ps1 -reg
}
catch {
    Write-Host "[-] An error occurred while installing vmware cloak. Error info: $($_.Exception)"
}