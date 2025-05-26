<#
.SYNOPSIS
Enables WinRM on the host

.DESCRIPTION
Enables WinRM on the host. This grants packer management access to the machine. WinRM is required for packer
to administer the machine so this is the first script to execute on the host.
#>

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# Set network to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private 

# Set up WinRM and configure some things
winrm quickconfig -q
winrm s "winrm/config" '@{MaxTimeoutms="1800000"}'
winrm s "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
winrm s "winrm/config/service" '@{AllowUnencrypted="true"}'
winrm s "winrm/config/service/auth" '@{Basic="true"}'

# Enable the WinRM Firewall rule, which will likely already be enabled due to the 'winrm quickconfig' command above
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

# Set windows to dark theme
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0 -Force

sc.exe config winrm start= auto