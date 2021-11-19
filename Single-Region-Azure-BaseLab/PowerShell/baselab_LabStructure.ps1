#Setup Variables
$DCRoot = "DC=fmc,DC=vysiioncloudlab,DC=co,DC=uk"
$LabDCRoot = "DC=fmc,DC=vysiioncloudlab,DC=co,DC=uk"
#Create Root Lab OU
New-ADOrganizationalUnit -Name "Azure" -Path $DCRoot -ProtectedFromAccidentalDeletion $False -Description "FMC Lab Environment"
#Create Other OUs
New-ADOrganizationalUnit -Name "Users" -Path $LabDCRoot -ProtectedFromAccidentalDeletion $False -Description "Users"
New-ADOrganizationalUnit -Name "Service Accounts" -Path $LabDCRoot -ProtectedFromAccidentalDeletion $False -Description "Service Accounts"
New-ADOrganizationalUnit -Name "Servers" -Path $LabDCRoot -ProtectedFromAccidentalDeletion $False -Description "Servers"
New-ADOrganizationalUnit -Name "Computers" -Path $LabDCRoot -ProtectedFromAccidentalDeletion $False -Description "Computers"
New-ADOrganizationalUnit -Name "ANF" -Path $LabDCRoot -ProtectedFromAccidentalDeletion $False -Description "ANF Objects"