variable "mysqlusername" {
    type = string
    default = "azuremysqluser"
}

variable "mysqlpassword" {
    type = string
    default = "CHang3thisP4Ssw0rD"
}

variable "mysqldbname" {
    type = string
    default = "gamedb"
}

variable "mysqlbackupretaineddays" {
    type = number
    default = 7
}

variable "mysqlgeoredundantbackup" {
    type = string
    default = "Disabled"
}

variable "mysqlsku" {
    type = string
    default = "GP_Gen5_2"
}

variable "mysqlskucapacity" {
    type = number
    default = 2
}

variable "mysqlskutier" {
    type = string
    default = "GeneralPurpose"
}

variable "mysqlskufamily" {
    type = string
    default = "Gen5"
}

variable "mysqlstoragembsize" {
    type = number
    default = 51200
}

variable "mysqlversion" {
    type = string
    default = "5.7"
}

variable "mysqlsubnetaddressprefix" {
    type = string
    default = "10.0.2.0/24"
}

resource "azurerm_subnet" "mysql" {
  name                 = "${var.prefix}MySQLSubnet"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = var.mysqlsubnetaddressprefix
  service_endpoints    = ["Microsoft.Sql"]
}

resource "random_id" "mysql" {
  byte_length = 2
}

resource "azurerm_mysql_server" "main" {
  name                = lower("${var.prefix}MySQL${random_id.mysql.hex}")
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  sku {
    name     = var.mysqlsku
    capacity = var.mysqlskucapacity
    tier     = var.mysqlskutier
    family   = var.mysqlskufamily
  }

  storage_profile {
    storage_mb            = var.mysqlstoragembsize
    backup_retention_days = var.mysqlbackupretaineddays
    geo_redundant_backup  = var.mysqlgeoredundantbackup
  }

  administrator_login          = var.mysqlusername
  administrator_login_password = var.mysqlpassword
  version                      = var.mysqlversion
  ssl_enforcement              = "Enabled"
}

resource "azurerm_mysql_database" "main" {
  name                = var.mysqldbname
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.main.name}"
  charset             = "utf8"
  collation           = "utf8_general_ci"
}


resource "azurerm_mysql_virtual_network_rule" "main" {
  name                = "mysql-vnet-rule"
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.main.name}"
  subnet_id           = "${azurerm_subnet.mysql.id}"
}

resource "azurerm_mysql_firewall_rule" "rule1" {
  name                = "mysql-firewall-rule1"
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.main.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}