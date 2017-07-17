# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "DR_WESTUS02_DATA_01" {
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

# create network interface
resource "azurerm_network_interface" "DR_DATA_NIC01" {
    name = "DR_DATA_NIC01"
    location = "${var.region}"
    resource_group_name = "${var.rname}"

    ip_configuration {
        name = "DR_DATA_PVT_01"
        subnet_id = "${azurerm_subnet.DR_NETWORK_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.128.11.10"
    }
}

resource "azurerm_network_interface" "DR_DATA_NIC02" {
    name = "DR_DATA_NIC02"
    location = "${var.region}"
    resource_group_name = "${var.rname}"

    ip_configuration {
        name = "DR_DATA_PVT_02"
        subnet_id = "${azurerm_subnet.DR_NETWORK_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.128.11.11"
    }
}
# create storage account
resource "azurerm_storage_account" "DRDATASTORAGE" {
    name = "drdatastorage"
    resource_group_name = "${var.rname}"
    location = "${var.region}"
    account_type = "Standard_LRS"

    tags {
        environment = "${var.environment}"
    }
}

# create storage container
resource "azurerm_storage_container" "DRDATASTORAGE01" {
    name = "drdatavhd01"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRDATASTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRDATASTORAGE"]
}
resource "azurerm_storage_container" "DRDATASTORAGE02" {
    name = "drdatavhd02"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRDATASTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRDATASTORAGE"]
}
