# create virtual machine demo01

resource "azurerm_virtual_machine" "chef_server" {
    name = "chef"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    network_interface_ids = ["${azurerm_network_interface.chef_svr_01.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk"
        vhd_uri = "${azurerm_storage_account.confmgmtstorage.primary_blob_endpoint}${azurerm_storage_container.cmstoragecontainer.name}/myosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "sfdemo01"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "staging"
    }
}
