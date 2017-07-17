# create virtual machine demo01

resource "azurerm_virtual_machine" "SQL01" {
    name = "DATADRP01"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    network_interface_ids = ["${azurerm_network_interface.DR_DATA_NIC01.id}"]
    vm_size = "Basic_A1"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "SQL01_SYS"
        vhd_uri = "${azurerm_storage_account.DRDATASTORAGE.primary_blob_endpoint}${azurerm_storage_container.DRDATASTORAGE01.name}/SQL01_SYS.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "SQL01"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    tags {
        environment = "${var.environment}"
    }
}
    resource "azurerm_virtual_machine" "CMSDRP02" {
        name = "SQL02"
        location = "${var.region}"
        resource_group_name = "${var.rname}"
        network_interface_ids = ["${azurerm_network_interface.DR_DATA_NIC02.id}"]
        vm_size = "Basic_A1"

        storage_image_reference {
            publisher = "MicrosoftWindowsServer"
            offer = "WindowsServer"
            sku = "2012-R2-Datacenter"
            version = "latest"
        }

        storage_os_disk {
            name = "SQL02_SYS"
            vhd_uri = "${azurerm_storage_account.DRDATASTORAGE.primary_blob_endpoint}${azurerm_storage_container.DRDATASTORAGE02.name}/SQL02_SYS.vhd"
            caching = "ReadWrite"
            create_option = "FromImage"
        }

        os_profile {
            computer_name = "SQL02"
            admin_username = "${var.admin_username}"
            admin_password = "${var.admin_password}"
        }

        tags {
            environment = "${var.environment}"
        }
