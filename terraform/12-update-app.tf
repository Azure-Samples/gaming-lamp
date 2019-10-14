variable "sourceurl" {
    type = string
    default = "yoursource.url/xxxx"
}

variable "blobsourceuri" {
    type = string
    default = "/app/package.tar.gz"
}

variable "blobfiledestinationname" {
    type = string
    default = "package.tar.gz"
}

variable "scriptupdatesourceuri" {
    type = string
    default = "/scripts/update-app.sh"
}

variable "scriptupdatefiledestinationame" {
    type = string
    default = "update-app.sh"
}

variable "destinationfolder" {
    type = string
    default = "/var/www/html"
}

variable "servicetorestart" {
    type = string
    default = "apache2.service"
}

resource "azurerm_virtual_machine_scale_set" "update12" {
  name                  = "${var.prefix}VMSS"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"

  # automatic rolling upgrade
  automatic_os_upgrade  = var.automaticupgrade
  upgrade_policy_mode   = var.vmssupgradepolicy

  # required when using rolling upgrade policy
  health_probe_id       = "${azurerm_lb_probe.http.id}"

  sku {
    name                            = var.vmssskusize
    capacity                        = var.vmssvmtocreate
  }

  storage_profile_image_reference {
    id                              = "${azurerm_image.main.id}"
  }

  storage_profile_os_disk {
    caching                         = "ReadWrite"
    create_option                   = "FromImage"
    managed_disk_type               = var.vmssstoragesku
  }

  os_profile {
    computer_name_prefix            = "${var.prefix}VMSS"
    admin_username                  = var.loginusername
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path                                    = "/home/${var.loginusername}/.ssh/authorized_keys"
      key_data                                = var.authenticationkey
    }
  }

  network_profile {
    name                            = "${var.prefix}VMSSNetworkProfile"
    primary                         = true
    accelerated_networking          = var.vmssaceleratednetworking
    ip_configuration {
      name                                    = "${var.prefix}VMSS-ipconfig"
      primary                                 = true
      subnet_id                               = "${azurerm_subnet.compute.id}"
      load_balancer_backend_address_pool_ids  = ["${azurerm_lb_backend_address_pool.main.id}"]
    }
  }

  extension {
    name                            = "UpdateApp"
    publisher                       = "Microsoft.Azure.Extensions"
    type                            = "CustomScript"
    type_handler_version            = "2.0"
    
    settings = <<SETTINGS
        {
            "fileUris": ["${var.sourceurl}${var.blobsourceuri}", "${var.sourceurl}${var.scriptupdatesourceuri}"],
            "commandToExecute": "bash ${var.scriptupdatefiledestinationame} ${var.blobfiledestinationname} ${var.destinationfolder} ${var.servicetorestart}"
        }
    SETTINGS
  }
  depends_on            = ["azurerm_virtual_machine_scale_set.main"]
}