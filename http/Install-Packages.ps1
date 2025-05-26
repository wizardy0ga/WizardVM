<#
.DESCRIPTION
Installs requires packages with choco. If there are any packages from choco you wish to add, add them here.
#>
choco feature enable -n allowGlobalConfirmation
choco install wireshark
# choco install winpcap # Seems to be breaking on auto hot key installation. Commented out for now.
choco install x64dbg.portable 
choco install systeminformer-nightlybuilds 
choco install apimonitor 
choco install pestudio 
choco install explorersuite 
choco install vscode 
choco install processhacker.install  
choco install dnspy 
choco install dnspyex 
choco install ida-free  
choco install resourcehacker.portable 
choco install hxd 
choco install python3 
choco install vscode-python
choco install vscode-powershell
choco install firefox
choco install hollowshunter
choco install pebear
choco install ollydbg
choco install sysinternals --version=2025.2.13
choco install microsoft-windows-terminal
choco install "windows-sdk-10-version-2004-windbg"
choco install de4dot
choco install 7zip.install --pre 