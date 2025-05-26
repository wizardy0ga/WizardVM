<#
.DESCRIPTION
Installs sysmon on the host.

.PARAMETER ConfigURL
A URL for a sysmon configuration file. This will be downloaded & used as the config for sysmon.
#>
param (
    $ConfigURL
)

$SysmonConfigs = @(
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml',
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig-with-filedelete.xml',
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig-excludes-only.xml',
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig-research.xml',
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig-mde-augment.xml'
)

# Install Sysmon
Write-Host "[*] Installing sysmon"
try {
    
    # Create program directory & necessary file paths
    $SysmonDir      = (New-Item "C:\Program Files\Sysmon\" -ItemType Directory -Force).FullName
    $SysmonExe      = (Join-Path -Path $SysmonDir -ChildPath "Sysmon64.exe")
    $SysmonConfig   = (Join-Path -Path $SysmonDir -ChildPath "config.xml")
    
    # Download sysmon & the configuration file specified by the user
    Invoke-WebRequest -Uri "https://live.sysinternals.com/sysmon64.exe" -OutFile $SysmonExe
    Invoke-WebRequest -Uri $ConfigURL -OutFile $SysmonConfig
    
    # Create sysmon config directory & store other configs
    New-Item 'C:\Program Files\Sysmon\Configs' -ItemType Directory
    foreach ($ConfigUrl in $SysmonConfigs) {
        Invoke-WebRequest -Uri $ConfigUrl -OutFile "C:\Program Files\Sysmon\Configs\$($ConfigURL.Split('/')[-1])"
    }

    # Install sysmon 
    & $SysmonExe -i $SysmonConfig -accepteula
    
    # Validate sysmon service is running
    if ((Get-Service Sysmon64).Status -eq "Running") {
        Write-Host "[+] Installation success."
    }
    else {
        Write-Host "[-] Installation failed"
    }
}
catch {
    Write-Host "[-] Failed to install sysmon. Error Info: $($_.Exception)"
}
