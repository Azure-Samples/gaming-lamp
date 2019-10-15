variable "redisvmfamily" {
    type = string
    default = "C"
}

variable "redisvmcapacity" {
    type = number
    default = 1
}

variable "redissku" {
    type = string
    default = "Standard"
}

variable "redisshardstocreate" {
    type = number
    default = 0
}

variable "redissubnetaddressprefix" {
    type = string
    default = "10.0.1.0/24"
}

resource "azurerm_subnet" "redis" {
  name                 = "${var.prefix}RedisSubnet"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = var.redissubnetaddressprefix
}

resource "random_id" "redis" {
  byte_length = 2
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "standard" {
  count = "${var.redissku == "Standard" ? 1 : 0}"

  name                = "${var.prefix}Redis${random_id.redis.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  capacity            = var.redisvmcapacity
  family              = var.redisvmfamily
  sku_name            = var.redissku
}

resource "azurerm_redis_cache" "premium" {
  count = "${var.redissku == "Premium" ? 1 : 0}"
  
  name                = "${var.prefix}Redis${random_id.redis.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  capacity            = var.redisvmcapacity
  family              = var.redisvmfamily
  sku_name            = var.redissku
  shard_count         = var.redisshardstocreate
  subnet_id           = "${azurerm_subnet.redis.id}"
}
