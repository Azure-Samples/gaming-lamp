resource "azurerm_virtual_machine_extension" "image" {
    name                 = "config-apache-php"
    location             = var.regionname
    resource_group_name  = "${azurerm_resource_group.main.name}"
    virtual_machine_name = "${azurerm_virtual_machine.image.name}"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/Azure-Samples/gaming-lamp/master/scripts/lampinstall.sh"],
            "commandToExecute": "sudo sh lampinstall.sh"
        }
    SETTINGS
}