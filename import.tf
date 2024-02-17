resource "azurerm_resource_group" "lpnu" {
  location = var.resource_group_location
  name     = var.resource_group_name
}