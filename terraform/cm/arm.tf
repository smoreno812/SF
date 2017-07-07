# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "config_mgmt" {
    name = "control"
    location = "West US"
}

# create a virtual network
resource "azurerm_virtual_network" "config_mgmt" {
    name = "cm_cidr"
    address_space = ["10.2.0.0/16"]
    location = "West US"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
}

# create demo subnet
resource "azurerm_subnet" "config_mgmt_01" {
    name = "demo_01"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    virtual_network_name = "${azurerm_virtual_network.config_mgmt.name}"
    address_prefix = "10.2.0.0/24"
}
# create public IP for demo
resource "azurerm_public_ip" "public_ips" {
    name = "chef"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "config_mgmt"
    }
}

# create network interface
resource "azurerm_network_interface" "chef_svr_01" {
    name = "dni01"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"

    ip_configuration {
        name = "cm01"
        subnet_id = "${azurerm_subnet.config_mgmt_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.2.0.10"
        public_ip_address_id = "${azurerm_public_ip.public_ips.id}"
    }
}

# create storage account
resource "azurerm_storage_account" "confmgmtstorage" {
    name = "confmgmtstorage"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    location = "westus"
    account_type = "Standard_LRS"

    tags {
        environment = "config_mgmt"
    }
}

# create storage container
resource "azurerm_storage_container" "cmstoragecontainer" {
    name = "vhd"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    storage_account_name = "${azurerm_storage_account.confmgmtstorage.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.confmgmtstorage"]
}
