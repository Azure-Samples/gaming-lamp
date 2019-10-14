variable "goldenimagename" {
    type = string
    default = "myGoldenImage"
}

resource "azurerm_image" "main" {
  name                      = var.goldenimagename
  location                  = var.regionname
  resource_group_name       = "${azurerm_resource_group.main.name}"
  source_virtual_machine_id = "${azurerm_virtual_machine.image.id}"
}