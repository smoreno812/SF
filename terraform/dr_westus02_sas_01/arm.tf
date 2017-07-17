# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "DR_WESTUS02_SAS_01" {
    name = "${var.rname}"
    location = "${var.region}"
}
# create a virtual network
resource "azurerm_virtual_network" "DR_WESTUS_NET" {
    name = "${var.network_name}"
    address_space = ["${var.network_space}"]
    location = "${var.region}"
    resource_group_name = "${var.rname}"
}

# create demo subnet
resource "azurerm_subnet" "DR_NETWORK_01" {
    name = "${var.subnet_name}"
    resource_group_name = "${var.rname}"
    virtual_network_name = "${azurerm_virtual_network.DR_WESTUS_NET.name}"
    address_prefix = "${var.subnet}"
}

# create storage account
resource "azurerm_storage_account" "DRSASSTORAGE" {
    name = "drsasstorage"
    resource_group_name = "${var.rname}"
    location = "${var.region}"
    account_type = "Standard_LRS"

    tags {
        environment = "${var.environment}"
    }
}

# create storage container
resource "azurerm_storage_container" "DRSASSTORAGE01" {
    name = "drsasvhd01"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRSASSTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRSASSTORAGE"]
}
resource "azurerm_storage_container" "DRSASSTORAGE02" {
    name = "drsasvhd02"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRSASSTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRSASSTORAGE"]
}
