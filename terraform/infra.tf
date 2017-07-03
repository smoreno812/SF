# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "92f8db80-0bb1-4af2-a5ce-1ba5bd0b4a4f"
  client_id       = "733de30c-bf5d-4058-b81c-31cbf09cd821"
  client_secret   = "Aybab2u!"
  tenant_id       = "9a71ac92-8dc1-4522-bd1d-a36110a821d7"
}

# create a resource group
resource "azurerm_resource_group" "core_infrastructure" {
    name = "control"
    location = "West US"
}


# create a virtual network
resource "azurerm_virtual_network" "noc_network" {
    name = "noc_root"
    address_space = ["10.1.0.0/16"]
    location = "West US"
    resource_group_name = "${azurerm_resource_group.helloterraform.name}"
}

# create subnet
resource "azurerm_subnet" "configuration_mgmt" {
    name = "config_mgmt_01"
    resource_group_name = "${azurerm_resource_group.helloterraform.name}"
    virtual_network_name = "${azurermcon_virtual_network.helloterraformnetwork.name}"
    address_prefix = "10.1.0.0/24"
}
