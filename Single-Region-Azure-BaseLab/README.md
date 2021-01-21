# Single Region Base Lab Environment for Azure

## Overview
This code creates a simple Lab environment within a Single Azure Region. The idea here is that it allows for quick deployment of VNETs, Subnets, and a Domain Controller to simulate smaller environments or provide a quick lab for infrastructure testing. 

## Actions
The following resources are deployed:

1. Two Resource Groups, one for the Lab infrastructure, and another for Security related items
2. Two VNETs, a Hub and a Spoke, which are peered. DNS is set on the VNETs to the Domain Controller IP, Azure DNS, and finally, Google DNS. 
3. Three Subnets in each VNET, with a Subnet delegated to Azure NetApp Files in the Spoke VNET. 
4. Uses the [Automatic-ClientIP-NSG](../Automatic-ClientIP-NSG) to setup a Network Security Group that allows RDP access in - this NSG rule uses the external IP of the machine that runs Terraform. 
5. Associates the created NSG to all Lab Subnets
6. Creates a Key Vault with a randomised name, using [Azure-KeyVault-with-Secret](../Azure-KeyVault-with-Secret), and then creates a password as a Secret within the Key Vault that is used later to setup a VM.
7. Creates a Public IP for the Domain Controller VM
8. Creates a Network Interface Card and associates the above Public IP. 
9. Creates a Data Disk for NTDS Storage on the Domain Controller VM
10. Creates a Windows 2019 VM to act as a Domain Controller. The Username for this VM is a Variable, and the Password is saved as a Secret in the Key Vault. (It was automatically generated in Step 6).
11. Attaches the Data Disk created in step 9, with caching Turned off. 
12. Runs a Setup script on the Domain Controller VM - that carries out the following actions:
  - Uses Chocolatey to install Google Chrome, Putty, Notepad++, WinSCP, Sysinternals, and bginfo
  - Creates a directory - c:\BaselabSetup
  - Downloads two further PowerShell scripts (which are in the root of this repository) which setup the Domain Controller, and create a Lab OU Structure. 
  - Sets a Windows Firewall Rule to allow File/Printer sharing
  - Installs the Windows Features required for Active Directory and DNS. 

### The two powershell scripts should be run to complete the setup as a Domain Controller - in this order:

1. baselab_DomainSetup.ps1 - the machine will reboot after this
2. baselab_LabStructure.ps1 - this will setup a basic OU structure