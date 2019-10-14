variable "lbsku" {
    type = string
    default = "Standard"
}

variable "publicipallocation" {
    type = string
    default = "Static"
}

variable "publicipversion" {
    type = string
    default = "IPv4"
}

variable "vnetaddressprefix" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnetaddressprefix" {
    type = string
    default = "10.0.0.0/24"
}

variable "lbfeportrangestart" {
    type = string
    default = "50000"
}

variable "lbfeportrangeend" {
    type = string
    default = "50119"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}VNET"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  address_space       = [var.vnetaddressprefix]
}

resource "azurerm_subnet" "compute" {
  name                 = "${var.prefix}Subnet"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = var.subnetaddressprefix
}

resource "azurerm_public_ip" "lbpip" {
  name                = "${var.prefix}PublicIP"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  sku                 = var.lbsku
  allocation_method   = var.publicipallocation
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}LB"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  sku                 = var.lbsku

  frontend_ip_configuration {
    name                 = "${var.prefix}LBFE"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.main.id}"
  name                = "${var.prefix}LBBEPool"
}

resource "azurerm_lb_rule" "http" {
  resource_group_name             = "${azurerm_resource_group.main.name}"
  loadbalancer_id                 = "${azurerm_lb.main.id}"
  name                            = "${var.prefix}LBHTTPRule"
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = "${azurerm_lb.main.frontend_ip_configuration[0].name}"
  backend_address_pool_id         = "${azurerm_lb_backend_address_pool.main.id}"
  probe_id                        = "${azurerm_lb_probe.http.id}"
}

resource "azurerm_lb_rule" "https" {
  resource_group_name             = "${azurerm_resource_group.main.name}"
  loadbalancer_id                 = "${azurerm_lb.main.id}"
  name                            = "${var.prefix}LBHTTPSRule"
  protocol                        = "Tcp"
  frontend_port                   = 443
  backend_port                    = 443
  frontend_ip_configuration_name  = "${azurerm_lb.main.frontend_ip_configuration[0].name}"
  backend_address_pool_id         = "${azurerm_lb_backend_address_pool.main.id}"
  probe_id                        = "${azurerm_lb_probe.https.id}"
}

resource "azurerm_lb_nat_pool" "main" {
  resource_group_name             = "${azurerm_resource_group.main.name}"
  loadbalancer_id                 = "${azurerm_lb.main.id}"
  name                            = "${var.prefix}LBNATPool"
  protocol                        = "Tcp"
  frontend_port_start             = var.lbfeportrangestart
  frontend_port_end               = var.lbfeportrangeend
  backend_port                    = 22
  frontend_ip_configuration_name  = "${azurerm_lb.main.frontend_ip_configuration[0].name}"
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.main.id}"
  name                = "${var.prefix}LBHTTPProbe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}

resource "azurerm_lb_probe" "https" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.main.id}"
  name                = "${var.prefix}LBHTTPSProbe"
  protocol            = "Https"
  port                = 443
  request_path        = "/"
}