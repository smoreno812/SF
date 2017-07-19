#Create Network for VMs
resource "azurerm_lb_nat_rule" "winrm_nat" {
  location = "${var.region}"
  resource_group_name = "${var.rname}"
  loadbalancer_id = "${azurerm_lb.load_balancer.id}"
  name = "WinRM-HTTPS-vm-${count.index}"
  protocol = "Tcp"
  frontend_port = "${count.index + 10000}"
  backend_port = "${var.vm_winrm_port}"
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
  count = "${var.vm_count}"
}

resource "azurerm_lb_nat_rule" "rdp_nat" {
  location = "${var.region}"
  resource_group_name = "${var.rname}"
  loadbalancer_id = "${azurerm_lb.load_balancer.id}"
  name = "RDP-vm-${count.index}"
  protocol = "Tcp"
  frontend_port = "${count.index + 11000}"
  backend_port = "3389"
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
}

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
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
        load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_rule.winrm_nat.*.id, count.index)}"]
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
    availability_set_id = "${azurerm_availability_set.dr_uswest02_avset01.id}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "${var.vm_name_prefix}-${count.index}-osdisk"
        vhd_uri = "${azurerm_storage_account.DRCMSSTORAGE.primary_blob_endpoint}${azurerm_storage_container.DRCMSSTORAGE01.name}/${var.vm_name_prefix}0${count.index}-osdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.vm_name_prefix}0${count.index}"
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
