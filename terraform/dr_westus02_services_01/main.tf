# create virtual machine demo01

resource "azurerm_virtual_machine" "CMSDRP01" {
    name = "CMSDRP01"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    network_interface_ids = ["${azurerm_network_interface.DR_CMS_NIC01.id}"]
    vm_size = "Basic_A1"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "CMSDRP01_SYS"
        vhd_uri = "${azurerm_storage_account.DRCMSSTORAGE.primary_blob_endpoint}${azurerm_storage_container.DRCMSSTORAGE01.name}/CMSDRP01_SYS.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "CMSDRP01"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    #os_profile_linux_config {
    #    disable_password_authentication = false
    #}

    tags {
        environment = "${var.environment}"
    }
}
    resource "azurerm_virtual_machine" "CMSDRP02" {
        name = "CMSDRP02"
        location = "${var.region}"
        resource_group_name = "${var.rname}"
        network_interface_ids = ["${azurerm_network_interface.DR_CMS_NIC02.id}"]
        vm_size = "Basic_A1"

        storage_image_reference {
            publisher = "MicrosoftWindowsServer"
            offer = "WindowsServer"
            sku = "2012-R2-Datacenter"
            version = "latest"
        }

        storage_os_disk {
            name = "CMSDRP02_SYS"
            vhd_uri = "${azurerm_storage_account.DRCMSSTORAGE.primary_blob_endpoint}${azurerm_storage_container.DRCMSSTORAGE02.name}/CMSDRP02_SYS.vhd"
            caching = "ReadWrite"
            create_option = "FromImage"
        }

        os_profile {
            computer_name = "CMSDRP02"
            admin_username = "${var.admin_username}"
            admin_password = "${var.admin_password}"
        }

        #os_profile_linux_config {
        #    disable_password_authentication = false
        #}

        tags {
            environment = "${var.environment}"
        }
# Install Chef Manage Server
#    provisioner "local-exec" {
#      command = "knife bootstrap windows winrm ${azurerm_public_ip.demo01vm.ip_address} -N ${azurerm_virtual_machine.demo01vm.name} -x ${var.admin_username} -P ${var.admin_password} --node-ssl-verify-mode none --bootstrap-version ${var.chef_client_version}"
#  }
}
