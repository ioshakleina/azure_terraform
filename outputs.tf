output "resource_group_name" {
  value = azurerm_resource_group.lpnu.name
}

output "azure_vm_name" {
  value = azurerm_virtual_machine.example.name
}

output "azure_vm_location" {
  value = azurerm_virtual_machine.example.location
}

output "vm_size" {
  value = azurerm_virtual_machine.example.vm_size
}

output "azure_os_disk_name" {
  value = azurerm_virtual_machine.example.os_profile[0].os_disk[0].name
}

output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

output "tls_private_key" {
  value = tls_private_key.vm_key.private_key_pem
}

