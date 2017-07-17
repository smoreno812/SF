# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "DR_WESTUS02_CMS_01" {
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
# create public IP for demo
resource "azurerm_public_ip" "DR_PUBLIC_IP" {
    name = "DR_PUBLIC_IP"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    public_ip_address_allocation = "static"

    tags {
        environment = "${var.environment}"
    }
}

# create network interface
resource "azurerm_network_interface" "DR_CMS_NIC01" {
    name = "DR_CMS_NIC01"
    location = "${var.region}"
    resource_group_name = "${var.rname}"

    ip_configuration {
        name = "DR_CMS_PVT_01"
        subnet_id = "${azurerm_subnet.DR_NETWORK_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.128.10.10"
        public_ip_address_id = "${azurerm_public_ip.DR_PUBLIC_IP.id}"
    }
}

resource "azurerm_network_interface" "DR_CMS_NIC02" {
    name = "DR_CMS_NIC02"
    location = "${var.region}"
    resource_group_name = "${var.rname}"

    ip_configuration {
        name = "DR_CMS_PVT_02"
        subnet_id = "${azurerm_subnet.DR_NETWORK_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.128.10.11"
    }
}
# create storage account
resource "azurerm_storage_account" "DRCMSSTORAGE" {
    name = "drcmsstorage"
    resource_group_name = "${var.rname}"
    location = "${var.region}"
    account_type = "Standard_LRS"

    tags {
        environment = "${var.environment}"
    }
}

# create storage container
resource "azurerm_storage_container" "DRCMSSTORAGE01" {
    name = "drcmsvhd01"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRCMSSTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRCMSSTORAGE"]
}
resource "azurerm_storage_container" "DRCMSSTORAGE02" {
    name = "drcmsvhd02"
    resource_group_name = "${var.rname}"
    storage_account_name = "${azurerm_storage_account.DRCMSSTORAGE.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.DRCMSSTORAGE"]
}
