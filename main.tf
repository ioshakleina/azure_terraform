# Resource Group
resource "azurerm_resource_group" "lpnu" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-${var.resource_group_name}"
}

resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.lpnu.name
  location                 = azurerm_resource_group.lpnu.location
  account_tier             = var.storage_account_type
  account_replication_type = "LRS"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.azurerm_virtual_network_name
  address_space       = var.vnet_range
  location            = azurerm_resource_group.lpnu.location
  resource_group_name = azurerm_resource_group.lpnu.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = var.azurerm_subnet_name
  resource_group_name  = azurerm_resource_group.lpnu.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.subnet_range
}

# Public IP
resource "azurerm_public_ip" "example" {
  name                = var.azurerm_public_ip
  location            = azurerm_resource_group.lpnu.location
  resource_group_name = azurerm_resource_group.lpnu.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.lpnu.location
  resource_group_name = azurerm_resource_group.lpnu.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = var.computer_name
  location              = azurerm_resource_group.lpnu.location
  resource_group_name   = azurerm_resource_group.lpnu.name
  network_interface_ids = [azurerm_network_interface.example.id]

  vm_size              = var.azurerm_vm_size
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }

  os_profile {
    computer_name  = var.computer_name
    admin_username = var.user_name
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.user_name}/.ssh/authorized_keys"
      key_data = tls_private_key.vm_key.public_key_openssh
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.example.primary_blob_endpoint
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
    ]
  }
}
