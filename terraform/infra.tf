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
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
}

# create demo subnet
resource "azurerm_subnet" "demo_net_01" {
    name = "demo_01"
    resource_group_name = "${azurerm_resource_group.core_infrastructure.name}"
    virtual_network_name = "${azurermcon_virtual_network.noc_network.name}"
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
resource "azurerm_storage_account" "demostorage" {
    name = "demostorage"
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
    storage_account_name = "${azurerm_storage_account.demostorage.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.demostorage"]
}

# create virtual machine demo01
resource "azurerm_virtual_machine" "demo01vm" {
    name = "l_demo01_vm"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.coe_infrastructure.name}"
    network_interface_ids = ["${azurerm_network_interface.demo_nic_01.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk"
        vhd_uri = "${azurerm_storage_account.demostorage.primary_blob_endpoint}${azurerm_storage_container.demostoragecontainer.name}/myosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "hostname"
        admin_username = "steve"
        admin_password = "Boko812!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "staging"
    }
}
