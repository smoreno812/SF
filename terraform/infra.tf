# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = ""
  client_id       = "733de30c-bf5d-4058-b81c-31cbf09cd821"
  client_secret   = "Aybab2u!"
  tenant_id       = "9a71ac92-8dc1-4522-bd1d-a36110a821d7"
}

# create a resource group
resource "azurerm_resource_group" "core_infrastructure" {
    name = "control"
    location = "West US"
}
