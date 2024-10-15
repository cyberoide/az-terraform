provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources-test"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-network-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet-test"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic-test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Smallest Virtual Machine (Standard_D2s_v3)
resource "azurerm_virtual_machine" "example" {
  name                  = "example-machine"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_D2s_v3"  # Use a smaller VM size if necessary

  # Ubuntu 22.04 LTS Image
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # OS Disk
  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Admin Account
  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "P@ssword1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
