provider "azurerm" {
  features {}
  # subscription_id = "subscription-id"
}

# Use existing Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = "monitoringproject"
}

# Use existing Virtual Network
data "azurerm_virtual_network" "existing_vnet" {
  name                = "monitorvm1-vnet"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Use existing Subnet
data "azurerm_subnet" "existing_subnet" {
  name                 = "default"
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# Create Public IP Address with Static Allocation (required for Standard SKU)
resource "azurerm_public_ip" "example" {
  name                = "terraformtest-public-ip"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Static"  # Must be Static for Standard SKU

  sku = "Standard"  # Specify the SKU
}

# Network Interface
resource "azurerm_network_interface" "example" {
  name                = "terraformtest-nic"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id # Associate public IP
  }
}

# Virtual Machine (SUSE Enterprise Linux for SAP 15 SP6 + 24x7 Support)
resource "azurerm_virtual_machine" "example" {
  name                  = "terraformtest"
  location              = data.azurerm_resource_group.existing_rg.location
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_D2s_v3"  # Adjust VM size as needed

  # SUSE Enterprise Linux for SAP 15 SP6 + 24x7 Support Image
  storage_image_reference {
    publisher = "SUSE"
    offer     = "sles-sap-15-sp6"
    sku       = "gen1"
    version   = "latest"
  }

  # OS Disk
  storage_os_disk {
    name              = "terraformtest-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Admin Account
  os_profile {
    computer_name  = "terraformtest"
    admin_username = "adminuser"
    admin_password = "P@ssword1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
