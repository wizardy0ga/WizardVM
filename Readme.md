# WizardVM, A Malware Analysis Box via IaC

<p align=center>
    <img src=data/banner.png></img>
</p>

## About

This repository contains an infrastructure as code recipe for a windows 10 malware analysis environment. The recipe uses [hashicorp packer](https://developer.hashicorp.com/packer) as the image builder. At this time, only [VMWare](https://www.vmware.com/) is supported.

For those unfamiliar, infrastructure as code allows an environment to be defined through code and built through automation. This code is processed by another software which configures the environment according to how it's defined in the code. This has the benefit of automating the setup of a virtual machine that will be created with the exact same properties, each time it's built.

At this time, the project only supports VMWare on Windows. 
## Features

:white_check_mark: Fully automated virtual machine setup  
:white_check_mark: Anti-analysis counter measures  
:white_check_mark: Sysmon & powershell logging  
:white_check_mark: Sysinternals  
:white_check_mark: Various reverse engineering & analysis softwares

## Control Variables
In this context, control defined as variables which control how the analysis environment is configured by packer. The table below highlights some of the variables. A full list of the variables can be found in [template.pkr.hcl](template.pkr.hcl).

| Variable | Default Value | Description
| - | - | - |
| update_windows | 0 | Run the [update-windows](floppy/update-windows.ps1) script to fully patch windows.
| disable_defender | 1 | Disable windows defender on the vm

## Setup instructions

> [!NOTE]
> This recipe has been tested with packer version 1.12.0, vmware-iso plugin version 1.1.0.

<details closed>
<summary><h3>Setting up packer</h3></summary>
<br>

1. If you trust this repository, you can use the copy of packer provided. Alternatively, you can retrieve your own copy of packer [here](https://developer.hashicorp.com/packer/install).

2. You'll need to install the [vmware-iso](https://github.com/hashicorp/packer-plugin-vmware) plugin. This allows packer to interact with VMWare. This can be done via the command below.

```
packer.exe init template.pkr.hcl 
```
</details>

<details>
<summary><h3>Acquiring a Windows 10 ISO</h3></summary>

1. If you don't already have an ISO file, one can be created with the [Windows 10 installation media](https://www.microsoft.com/en-us/software-download/windows10) tool.

</details>

<details>
<summary><h3>Modifying the configuration file (template.pkr.hcl)</h3></summary>

The [configuration file](template.pkr.hcl) specifies a set of variables, each with a default value. This default value can be overridden by specifying a new value in packers command line when building the recipe.  

The following variables don't come with a default value: **http_server_ip**, **iso_path** and **iso_checksum**. You'll either need to specify a default value for these variables in the configuration file or specify their value at build time in packers command line.  

| Variable | Description | 
| - | - |
| http_server_ip | The IP address of the machine hosting the http server. This is will be the machine that packer is running on.
| iso_path | The full file path of the windows 10 iso file to be used for the installation.
| iso_checksum | A hash of the iso file. The hash algo is specified in via **checksum_type** & defaults to MD5

1. Set **http_server_ip** to the local ip of the system you will be running packer on.

2. Set the **iso_path** variable to the path of your Windows 10 iso.

2. Get an MD5 hash of the iso file and add this to **iso_checksum**. 

```powershell
Get-FileHash -Path c:\path\to\your\windows10_22H2.iso -Algorithm MD5 | Select -ExpandProperty Hash
```
</details>

<details>
<summary><h3>Building the image with Packer</h3></summary>

Now we're ready to build the packer image. 

1. In a terminal, navigate to the root of this repo.

2. Packers syntax is `packer <command> <args> recipe.pkr.hcl`.
At a minumum, we'll need to execute this command to begin the build. 

```
packer.exe build template.pkr.hcl
```

3. If there are other variables you would like to change, they can be specified in this command. For example, if we wanted to change the name of the vm & build location, we would use the following command line:
```
packer.exe build -var vmname=my-malware-vm -var outdir=X:\VM_Storage\Windows\my-malware-vm template.pkr.hcl
```

4. When you've built your command line, execute it to begin the build.

> [!IMPORTANT]
> Depending on your host system specs & the operations performed in the build, it could take anywhere from a half hour to many hours for the build to complete. The most time intensive operation is the windows updates. By default, these are disabled but can be enabled by setting the **update_windows** variable value to any unsigned integer value other than 0. 


5. Enjoy a cup of coffee while your analysis environment is created.

</details>

<details>
<summary><h3>Finishing up</h3></summary>

When the build is complete, there's a few settings we'll need to tweak on the virtual machine within VMWare.

1. Either remove the network adapter interface if you don't want an internet connection OR connect the interface to an isolated network.

> [!CAUTION]
> It is not recommended to have this machine bridged to your local network or communicating via host based NAT. This could allow malware samples to infect other systems on your live network. If you need an internet connection but don't have a network segment for malware analyis, you can create one with any virtual router solution such as [pfsense](https://www.pfsense.org) or [OpenWRT](https://openwrt.org/). It is strongly recommended to only analyze malware samples on an isolated network segment. 

2. Configure the VM to revert to a snapshot when the vm is powered off. This ensures the VM is loaded from a clean state each time it's booted from the hypervisor.

<p align=center>
    <img src=data/snapshot.png></img>
    <h6 align=center>Figure 1: Enabling the 'Revert to Snapshot' feature on a machine in VMWare</h6>
</p>

3. Remove the CD & Floppy disk drives from the machine. This minimizes the attack surface for potential VM escape exploits.

4. Power on the virtual machine, configure anything else you would like to be included in the base image and take a snapshot. This snapshot serves as the clean state for the system. Each time the system boots from the hypervisor, it will boot from this image.

</details>

## Default Credentials
| Username | Password |
| - | - |
| Admin | password123

## Architecture

This section will describe the code components & the build control flow for those who would like to understand and modify the recipe for their own purposes.

:construction: Under development :construction:

## Credits

[VMWareCloak](https://github.com/d4rksystem/VMwareCloak) - [d4rksystem](https://github.com/d4rksystem/)  
[Sysmon-Modular](https://github.com/olafhartong/sysmon-modular) - [olafhartong](https://github.com/olafhartong/)  
[Update-Windows.ps1](floppy/update-windows.ps1) - Unknown, i've seen this script in variety of other repositories

## Documentation
[Packer](https://developer.hashicorp.com/packer/docs)  
[Packer | VMware ISO Plugin](https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso)  