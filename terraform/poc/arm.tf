# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "DR_WESTUS02_POC_01" {
    name = "${var.rname}"
    location = "${var.region}"
}
# create a virtual network
resource "azurerm_virtual_network" "DR_WESTUS_NET" {
    name = "${var.network_name}"
    address_space = ["${var.network_space}"]
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    depends_on = ["azurerm_resource_group.DR_WESTUS02_POC_01"]
}

# create demo subnet
resource "azurerm_subnet" "DR_NETWORK_01" {
    name = "${var.subnet_name}"
    resource_group_name = "${var.rname}"
    virtual_network_name = "${azurerm_virtual_network.DR_WESTUS_NET.name}"
    address_prefix = "${var.subnet}"
}
# create public IP for demo
resource "azurerm_public_ip" "DR_PUBLIC_IP" {
    name = "DR_PUBLIC_IP"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    public_ip_address_allocation = "static"
    depends_on = ["azurerm_resource_group.DR_WESTUS02_POC_01"]

    tags {
        environment = "${var.environment}"
    }
}

# create storage account
resource "azurerm_storage_account" "DRPOCSTORAGE9" {
    name = "drpocstorage9"
    resource_group_name = "${var.rname}"
    location = "${var.region}"
    account_type = "Standard_LRS"
    depends_on = ["azurerm_resource_group.DR_WESTUS02_POC_01"]
    tags {
        environment = "${var.environment}"
    }
}

# create storage container
resource "azurerm_storage_container" "DRPOCSTORAGE01" {
    name = "drpocvhd01"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRPOCSTORAGE9.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRPOCSTORAGE9"]
}
