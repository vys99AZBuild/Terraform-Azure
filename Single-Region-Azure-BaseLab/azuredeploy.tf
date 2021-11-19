#Resource Groups
resource "azurerm_resource_group" "rg1" {
  name     = var.azure-rg-1
  location = var.uks
  tags = {
    Environment = var.environment_tag
    Function    = "baselabv1-resourcegroups"
  }
}
#VNETs and Subnets
#Hub VNET and Subnets
resource "azurerm_virtual_network" "uks-vnet1-hub1" {
  name                = var.uks-vnet1-name
  location            = var.uks
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = [var.uks-vnet1-address-space]
  dns_servers         = ["172.22.1.4", "168.63.129.16", "8.8.8.8"]
  tags = {
    Environment = var.environment_tag
    Function    = "core-network"
  }
}
resource "azurerm_subnet" "uks-vnet1-snet1" {
  name                 = var.uks-vnet1-snet1-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.uks-vnet1-hub1.name
  address_prefixes     = [var.uks-vnet1-snet1-range]
}
resource "azurerm_subnet" "uks-vnet1-snet2" {
  name                 = var.uks-vnet1-snet2-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.uks-vnet1-hub1.name
  address_prefixes     = [var.uks-vnet1-snet2-range]
}
resource "azurerm_subnet" "uks-vnet1-snet3" {
  name                 = var.uks-vnet1-snet3-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.uks-vnet1-hub1.name
  address_prefixes     = [var.uks-vnet1-snet3-range]
}
resource "azurerm_subnet" "uks-vnet1-snet4" {
  name                 = var.uks-vnet1-snet4-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.uks-vnet1-hub1.name
  address_prefixes     = [var.uks-vnet1-snet4-range]
}
#RDP Access Rules for Lab
#Get Client IP Address for NSG
data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}
#Lab NSG
resource "azurerm_network_security_group" "uks-nsg" {
  name                = "uks-nsg"
  location            = var.uks
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "RDP-In"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${chomp(data.http.clientip.body)}/32"
    destination_address_prefix = "*"
  }
  tags = {
    Environment = var.environment_tag
    Function    = "core-security"
  }
}
#NSG Association to all Lab Subnets
resource "azurerm_subnet_network_security_group_association" "vnet1-snet1" {
  subnet_id                 = azurerm_subnet.uks-vnet1-snet1.id
  network_security_group_id = azurerm_network_security_group.uks-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet2" {
  subnet_id                 = azurerm_subnet.uks-vnet1-snet2.id
  network_security_group_id = azurerm_network_security_group.uks-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet3" {
  subnet_id                 = azurerm_subnet.uks-vnet1-snet3.id
  network_security_group_id = azurerm_network_security_group.uks-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet4" {
  subnet_id                 = azurerm_subnet.uks-vnet1-snet4.id
  network_security_group_id = azurerm_network_security_group.uks-nsg.id
}

#Create KeyVault ID
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv1" {
  depends_on                  = [azurerm_resource_group.rg1]
  name                        = random_id.kvname.hex
  location                    = var.uks
  resource_group_name         = var.azure-rg-1
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
    ]

    storage_permissions = [
      "get",
    ]
  }
  tags = {
    Environment = var.environment_tag
    Function    = "core-security"
  }
}
#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on   = [azurerm_key_vault.kv1]
}
#Public IP
resource "azurerm_public_ip" "uks-dc01-pip" {
  name                = "uks-dc01-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.uks
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment_tag
    Function    = "core-activedirectory"
  }
}
#Create NIC and associate the Public IP
resource "azurerm_network_interface" "uks-dc01-nic" {
  name                = "uks-dc01-nic"
  location            = var.uks
  resource_group_name = azurerm_resource_group.rg1.name


  ip_configuration {
    name                          = "uks-dc01-ipconfig"
    subnet_id                     = azurerm_subnet.uks-vnet1-snet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.uks-dc01-pip.id
  }

  tags = {
    Environment = var.environment_tag
    Function    = "core-activedirectory"
  }
}

#Create Domain Controller VM
resource "azurerm_windows_virtual_machine" "uks-dc01-vm" {
  name                = "uks-dc01-vm"
  depends_on          = [azurerm_key_vault.kv1]
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.uks
  size                = var.vmsize-domaincontroller
  admin_username      = var.adminusername
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.uks-dc01-nic.id,
  ]

  tags = {
    Environment = var.environment_tag
    Function    = "core-activedirectory"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
#Run setup script on dc01-vm
resource "azurerm_virtual_machine_extension" "uks-dc01-basesetup" {
  name                 = "uks-dc01-basesetup"
  virtual_machine_id   = azurerm_windows_virtual_machine.uks-dc01-vm.id
  depends_on           = [azurerm_windows_virtual_machine.uks-dc01-vm]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./baselab_DCSetup.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": [
          "https://raw.githubusercontent.com/vys99AZBuild/Terraform-Azure/main/Single-Region-Azure-BaseLab/PowerShell/baselab_DCSetup.ps1"
        ]
    }
  SETTINGS
}
