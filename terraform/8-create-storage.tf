variable "storagetier" {
    type = string
    default = "Standard"
}

variable "storagereplicationtype" {
    type = string
    default = "LRS"
}

variable "storagesubnetaddressprefix" {
    type = string
    default = "10.0.3.0/24"
}

resource "random_id" "storage" {
  byte_length                   = 2
}

resource "azurerm_subnet" "storage" {
  name                          = "${var.prefix}STRGSubnet"
  resource_group_name           = "${azurerm_resource_group.main.name}"
  virtual_network_name          = "${azurerm_virtual_network.main.name}"
  address_prefix                = var.storagesubnetaddressprefix
  service_endpoints             = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "main" {
  name                          = lower("${var.prefix}STRG${random_id.storage.hex}")
  resource_group_name           = "${azurerm_resource_group.main.name}"
  location                      = "${azurerm_resource_group.main.location}"
  account_tier                  = var.storagetier
  account_replication_type      = var.storagereplicationtype

  network_rules {
    default_action              = "Deny"
    virtual_network_subnet_ids  = ["${azurerm_subnet.storage.id}"]
  }
}