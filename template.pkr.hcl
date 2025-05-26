/* 
WizardVM Packer Recipe, a malware analysis environment
    By WizardY0ga

Supports
    VMware on Windows
*/

/* === Begin Variable Definitions === */

variable http_server_ip {
    type    = string
    default = ""
}

variable iso_path {
    type    = string
    default = ""
}

variable iso_checksum {
    type    = string
    default = ""
}

variable "outdir" {
    type    = string
    default = "C:\\wizard-vm"
}

variable "vmname" {
    type    = string
    default = "wizard-vm"
}

variable disksize {
    type    = string
    default = 80000
}

variable ram {
    type    = string
    default = 8196
}

variable cpus {
    type    = string
    default = 1
}

variable cores {
    type    = string
    default = 4
}

variable http_server_port {
    type    = string
    default = 80
}

variable sysmon_config_url {
    type    = string
    default = "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig-with-filedelete.xml"
}

variable hostname {
    type    = string
    default = "LAPTOP-83NDH7A"
}


variable checksum_type {
    type    = string
    default = "md5"
}

variable update_windows {
    type    = string
    default = 0
}

variable disable_defender {
    type    = string
    default = 1
}

/* === End Variable Definitions === */

packer {
    required_version = ">= 1.7.0"
    required_plugins {
        vmware = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/vmware"
        }
    }
}

source "vmware-iso" "malware" {
    
    iso_url             = "${var.iso_path}"
    iso_checksum        = "${var.checksum_type}:${var.iso_checksum}"
    disk_size           = "${var.disksize}"
    guest_os_type       = "windows9-64"
    vm_name             = "${var.vmname}"
    output_directory    = "${var.outdir}"
    cpus                = var.cpus
    cores               = var.cores
    memory              = var.ram
    sound               = false
    usb                 = false
    floppy_files        = ["floppy"]
    shutdown_command    = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
    communicator        = "winrm"
    winrm_username      = "Admin"
    winrm_password      = "password123"
    winrm_timeout       = "6h"
    disk_adapter_type   = "nvme"
    vmx_data            =  {
        "gui.fitguestusingnativedisplayresolution" = "FALSE"
        "isolation.tools.dnd.disable"              = "true"     // Disable drag & drop        
        "isolation.tools.copy.disable"             = "true"     // Disable clipboard
        "isolation.tools.paste.disable"            = "true"     // Disable clipboard
        "isolation.tools.setGUIOptions.enable"     = "false"    // Disable vmware tools tampering
        "isolation.tools.hgfs.disable"             = "true"     // Disable shared folders
    }
    http_directory      = "http"
    http_port_min       = var.http_server_port
    http_port_max       = var.http_server_port
}

build {

    sources = [
        "sources.vmware-iso.malware"
    ]
    
    provisioner "windows-shell" {
        inline = [
            "powershell -nologo -executionpolicy bypass -File a:/configure-system.ps1 -httpserverip ${var.http_server_ip } -httpserverport ${ var.http_server_port} -newhostname ${var.hostname} -UpdateWindows ${var.update_windows} -disabledefender ${var.disable_defender}"
        ]
    }

    provisioner "windows-restart" {
        restart_timeout = "30m"
    }

    provisioner "windows-shell" {
        inline = [
            "powershell -nologo -executionpolicy bypass -File C:\\Windows\\Temp\\Install-Sysmon.ps1 -configurl ${var.sysmon_config_url}"
            , "powershell -nologo -executionpolicy bypass -File C:\\Windows\\Temp\\Install-VMWareCloak.ps1"
            , "powershell -nologo -executionpolicy bypass -File C:\\Windows\\Temp\\Install-Packages.ps1"
        ]
    }

    provisioner "windows-restart" {
        restart_timeout = "30m"
    }
}
