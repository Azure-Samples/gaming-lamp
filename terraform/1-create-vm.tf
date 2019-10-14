# Configure the input variables. Replace each with your value.
variable "resourcegroupname" {
    type = string
    default = "myResourceGroup"
}

variable "regionname" {
    type = string
    default = "japanwest"
}

variable "prefix" {
    type = string
    default = "myGameBackend"
}

variable "loginusername" {
    type = string
    default = "azureuser"
}

variable "vmname" {
    type = string
    default = "myVirtualMachine"
}

variable "vmsize" {
    type = string
    default = "Standard_B1s"
}

variable "vmdatadisksize" {
    type = string
    default = "5"
}

variable "ubuntuosversion" {
    type = string
    default = "16.04-LTS"
}

variable "authenticationkey" {
    type = string
    default = "ssh-rsa AAAAB3Nzxxxxxxxxxx"
}

variable "addressprefix" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnetprefix" {
    type = string
    default = "10.0.0.0/24"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "main" {
    name     = var.resourcegroupname
    location = var.regionname
}

# Create virtual network
resource "azurerm_virtual_network" "image" {
    name                = "${var.vmname}VNET"
    address_space       = [var.addressprefix]
    location            = var.regionname
    resource_group_name = "${azurerm_resource_group.main.name}"
}

# Create subnet
resource "azurerm_subnet" "image" {
    name                 = "${var.vmname}Subnet"
    resource_group_name  = "${azurerm_resource_group.main.name}"
    virtual_network_name = "${azurerm_virtual_network.image.name}"
    address_prefix       = var.subnetprefix
}

# Create public IPs
resource "azurerm_public_ip" "image" {
    name                         = "${var.vmname}PublicIP"
    location                     = var.regionname
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "image" {
    name                = "${var.vmname}NSG"
    location            = var.regionname
    resource_group_name = "${azurerm_resource_group.main.name}"
    
    security_rule {
        name                       = "HTTP"
        priority                   = 900
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 901
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 902
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "image" {
    name                      = "${var.vmname}NIC"
    location                  = var.regionname
    resource_group_name       = "${azurerm_resource_group.main.name}"
    network_security_group_id = "${azurerm_network_security_group.image.id}"

    ip_configuration {
        name                          = "ipconfig${var.vmname}"
        subnet_id                     = "${azurerm_subnet.image.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.image.id}"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "image" {
    name                  = var.vmname
    location              = var.regionname
    resource_group_name   = "${azurerm_resource_group.main.name}"
    network_interface_ids = ["${azurerm_network_interface.image.id}"]
    vm_size               = var.vmsize

    storage_os_disk {
        name              = "${var.vmname}OSDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = var.ubuntuosversion
        version   = "latest"
    }

    os_profile {
        computer_name  = var.vmname
        admin_username = var.loginusername
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.loginusername}/.ssh/authorized_keys"
            key_data = var.authenticationkey
        }
    }
}

# Create managed disk
resource "azurerm_managed_disk" "data" {
    name                 = "${var.vmname}DataDisk1"
    location             = "${azurerm_resource_group.main.location}"
    resource_group_name  = "${azurerm_resource_group.main.name}"
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
    disk_size_gb         = var.vmdatadisksize
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
    managed_disk_id    = "${azurerm_managed_disk.data.id}"
    virtual_machine_id = "${azurerm_virtual_machine.image.id}"
    lun                = "10"
    caching            = "ReadWrite"
}