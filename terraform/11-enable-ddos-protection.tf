resource "azurerm_network_ddos_protection_plan" "main" {
  name                = "${var.prefix}DdosPlan"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_virtual_network" "update11" {
  name                = "${var.prefix}VNET"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  address_space       = [var.vnetaddressprefix]
  
  ddos_protection_plan {
    id                = "${azurerm_network_ddos_protection_plan.main.id}"
    enable            = true
  }

  subnet {
    name              = "${var.prefix}Subnet"
    address_prefix    = var.subnetaddressprefix
  }

  subnet {
    name              = "${var.prefix}RedisSubnet"
    address_prefix    = var.redissubnetaddressprefix
  }

  subnet {
    name              = "${var.prefix}MySQLSubnet"
    address_prefix    = var.mysqlsubnetaddressprefix
  }

  subnet {
    name              = "${var.prefix}STRGSubnet"
    address_prefix    = var.storagesubnetaddressprefix
  }

  depends_on          = ["azurerm_virtual_network.main"]
}

