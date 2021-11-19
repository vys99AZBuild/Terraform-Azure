variable "environment_tag" {
  type        = string
  description = "Environment tag value"
}
variable "azure-rg-1" {
  type        = string
  description = "resource group 1"
}
variable "uks" {
  description = "The location for this Lab environment"
  type        = string
}
variable "uks-vnet1-name" {
  description = "VNET1 Name"
  type        = string
}

variable "uks-vnet1-address-space" {
  description = "VNET address space"
  type        = string
}
variable "uks-vnet1-snet1-name" {
  description = "subnet name"
  type        = string
}
variable "uks-vnet1-snet2-name" {
  description = "subnet name"
  type        = string
}
variable "uks-vnet1-snet3-name" {
  description = "subnet name"
  type        = string
}
variable "uks-vnet1-snet4-name" {
  description = "subnet name"
  type        = string
}
variable "uks-vnet1-snet1-range" {
  description = "subnet range"
  type        = string
}
variable "uks-vnet1-snet2-range" {
  description = "subnet range"
  type        = string
}
variable "uks-vnet1-snet3-range" {
  description = "subnet range"
  type        = string
}
variable "uks-vnet1-snet4-range" {
  description = "subnet range"
  type        = string
}

variable "vmsize-domaincontroller" {
  description = "size of vm for domain controller"
  type        = string
}
variable "adminusername" {
  description = "administrator username for virtual machines"
  type        = string
}