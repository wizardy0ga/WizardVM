<#
.SYNOPSIS
Executes all required operations prior to first system reboot.

.DESCRIPTION
Executes all required operations prior to first system reboot. If something needs to run before the first
reboot, it should be done here.

- Retrieves required files from the http server
- Installs vmware tools
- Installs choco
- Performs other minor tasks

.PARAMETER HttpServerIp
The IP address of the HTTP server

.PARAMETER HttpServerPort
The port of the HTTP server

.PARAMETER NewHostname
A new name for the device

.PARAMETER UpdateWindows
Instructs the script to run the windows update script if the value is not 0.

.PARAMETER DisableDefender
Instructs the script to disable defender if value is not 0.
#>
param (
    $HttpServerIp,
    $HttpServerPort,
    $NewHostname,
    $UpdateWindows,
    $DisableDefender
)

$Server = "http://$($HttpServerIp):$($HttpServerPort)/"

# Make temp directory on Admin accounts desktop. This will be removed later.
$SysTemp = "C:\Windows\Temp"

# Download files from http_directory to the temp directory
Write-Host "[*] Getting files from the http_directory."
$Files = (Invoke-WebRequest -Uri $Server -UseBasicParsing).Links.HREF
foreach ($file in $Files) {
    Invoke-WebRequest -Uri "$($Server)$($file)" -OutFile (Join-Path -Path $SysTemp -ChildPath $file)
    Write-Host "`t[+] Got: $($file)"
}

# Install vmware tools. Computer will reboot after this.
Write-Host "[*] Installing Vmware Tools."
Expand-Archive -Path (Join-Path -Path $SysTemp -ChildPath "vmware_tools.zip") -DestinationPath $SysTemp
Start-Process -FilePath (join-path -path $SysTemp -childpath "vmware_tools\Setup64.exe") -ArgumentList "/s", "/v", "/qn", "REBOOT=R" -Wait
if (!(Get-Item -Path "C:\Program Files\VMware\VMware Tools\vmtoolsd.exe")) {
    Write-Host "[-] Installation failed." -NoNewline
}
else {
    Write-Host "[+] Installation Successful." -NoNewline
}

Remove-Item "C:\Users\Public\Desktop\VMware Shared Folders.lnk" -Force

# Install choco dependency for Install-Packages.ps1 script
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Enable UAC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1

# Enable PowerShell scripts
Set-ExecutionPolicy -ExecutionPolicy Bypass

# Set wallpaper
$Wallpaper = 'c:\users\admin\documents\wallpaper.jpeg'
Move-Item 'c:\windows\temp\wallpaper.jpeg' $Wallpaper
$Acl = Get-Acl -Path $Wallpaper
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$(hostname)\Admin", 'FullControl', 'Allow')
$Acl.AddAccessRule($AccessRule)
Set-Acl -Path $Wallpaper -AclObject $Acl 
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallPaper -Value $Wallpaper
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Disable defender via local gpo
if ($DisableDefender -ne 0) {
    new-item 'hklm:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'
    new-itemproperty -Path 'hklm:\SOFTWARE\Policies\Microsoft\Windows Defender\' -Name DisableAntiSpyware -PropertyType DWORD -Value 1
    new-itemproperty -Path 'hklm:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name DisableBehaviorMonitoring -PropertyType DWORD -Value 1
}

# Enable powershell logging
New-Item "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\"
New-Item "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1 -PropertyType DWORD 

gpupdate /force

# Set hostname
Rename-Computer -NewName $NewHostname -Force

# Update windows
if ($UpdateWindows -ne 0) {
    Write-Host "[+] Starting windows updates"
    Start-Process 'powershell.exe' -ArgumentList '-File a:/update-windows.ps1' -Wait
}

Write-Host "Rebooting."