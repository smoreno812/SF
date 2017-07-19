
# create network interface
resource "azurerm_network_interface" "vm_nic" {
    name = "${var.vm_name_prefix}0${count.index}-nic"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    network_security_group_id = "${azurerm_network_security_group.vm_security_group.id}"
    count = "${var.vm_count}"

    ip_configuration {
        name = "${var.vm_name_prefix}-${count.index}-ipConfig"
        subnet_id = "${azurerm_subnet.DR_NETWORK_01.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.DR_PUBLIC_IP.id}"
    }
}

# create virtual machine DR CMS

resource "azurerm_virtual_machine" "virtual_machine" {
    name = "${var.vm_name_prefix}0${count.index}"
    location = "${var.region}"
    resource_group_name = "${var.rname}"
    network_interface_ids = ["${element(azurerm_network_interface.vm_nic.*.id, count.index)}"]
    vm_size = "${var.vm_size}"
    count = "${var.vm_count}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "${var.vm_name_prefix}0${count.index}-osdisk"
        vhd_uri = "${azurerm_storage_account.DRPOCSTORAGE9.primary_blob_endpoint}${azurerm_storage_container.DRPOCSTORAGE01.name}/${var.vm_name_prefix}0${count.index}-osdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.vm_name_prefix}0${count.index}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        custom_data = "${base64encode("Param($RemoteHostName = \"${null_resource.intermediates.triggers.full_vm_dns_name}\", $ComputerName = \"${var.vm_name_prefix}0${count.index}\", $WinRmPort = ${var.vm_winrm_port}) ${file("Deploy.PS1")}")}"
    }

    tags {
        environment = "${var.environment}"
    }

    os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true

        additional_unattend_config {
          pass = "oobeSystem"
          component = "Microsoft-Windows-Shell-Setup"
          setting_name = "AutoLogon"
          content = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
        }
        #Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
        additional_unattend_config {
          pass = "oobeSystem"
          component = "Microsoft-Windows-Shell-Setup"
          setting_name = "FirstLogonCommands"
          content = "${file("FirstLogonCommands.xml")}"
        }
    }
# Install Chef Manage Server
  provisioner "local-exec" {
    command = "knife bootstrap windows winrm ${azurerm_public_ip.DR_PUBLIC_IP.id} -N ${var.vm_name_prefix}0${count.index} -x ${var.admin_username} -P ${var.admin_password} --node-ssl-verify-mode none --bootstrap-version ${var.chef_client_version} -r 'recipe[sf-application-cms]' --yes"
  }
}
