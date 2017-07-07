# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

}

# create a resource group
resource "azurerm_resource_group" "core_infrastructure" {
    name = "control"
    location = "West US"
}

# create a virtual network
resource "azurerm_virtual_network" "nocnetwork" {
    name = "noc_network"
    address_space = ["10.1.0.0/16"]
    location = "West US"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
}

# create demo subnet
resource "azurerm_subnet" "demo_net_01" {
    name = "demo_01"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
    virtual_network_name = "${azurerm_virtual_network.nocnetwork.name}"
    address_prefix = "10.1.75.0/24"
}
# create public IP for demo
resource "azurerm_public_ip" "public_ips" {
    name = "demo01_publicip"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "TerraformDemo"
    }
}

# create network interface
resource "azurerm_network_interface" "demo_nic_01" {
    name = "dni01"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"

    ip_configuration {
        name = "democonfiguration01"
        subnet_id = "${azurerm_subnet.demo_net_01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.1.75.5"
        public_ip_address_id = "${azurerm_public_ip.public_ips.id}"
    }
}

# create storage account
resource "azurerm_storage_account" "smdemo01storage" {
    name = "smdemo01storage"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
    location = "westus"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

# create storage container
resource "azurerm_storage_container" "demostoragecontainer" {
    name = "vhd"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
    storage_account_name = "${azurerm_storage_account.smdemo01storage.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.smdemo01storage"]
}
