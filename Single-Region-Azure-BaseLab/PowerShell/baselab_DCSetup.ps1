#Set Execution Policy to allow script to run
Set-ExecutionPolicy Bypass -Scope Process -Force 
#Choco install and Choco Apps
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install putty -y
choco install notepadplusplus -y
choco install winscp -y
choco install sysinternals -y
choco install bginfo -y
#Download Scripts to Set the rest of the Domain up when logged in
New-Item -Path "c:\" -Name "BaselabSetup" -ItemType "directory" -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vys99AZBuild/Terraform-Azure/main/Single-Region-Azure-BaseLab/PowerShell/baselab_DomainSetup.ps1" -OutFile "C:\BaselabSetup\baselab_DomainSetup.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vys99AZBuild/Terraform-Azure/main/Single-Region-Azure-BaseLab/PowerShell/baselab_LabStructure.ps1" -OutFile "C:\BaselabSetup\baselab_LabStructure.ps1"
#Allow Ping
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -enabled True
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv6-In)" -enabled True
#Install Roles to make Server a Domain Controller
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools
Install-windowsfeature -name DNS -IncludeManagementTools
