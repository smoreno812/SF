# create virtual machine demo01

resource "azurerm_virtual_machine" "chefserver" {
    name = "chef"
    location = "${var.region}"
    resource_group_name = "${azurerm_resource_group.config_mgmt.name}"
    network_interface_ids = ["${azurerm_network_interface.chef_svr_01.id}"]
    vm_size = "Standard_D1_v2"

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
        computer_name = "chefserver"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "${var.environment}"
    }

    # The default username for our AMI
    connection {
      host        = "${azurerm_public_ip.chefserver.ip_address}"
      type        = "ssh"
      user        = "${var.admin_username}"
      password    = "${var.admin_password}"
      timeout     = "2m"
      agent       = false
    }
# Install Chef Manage Server
  provisioner "remote-exec" {
    inline = [
      "sudo curl https://raw.githubusercontent.com/smoreno812/chef-services/master/files/installer.sh > /tmp/chefinstall.sh",
      "sudo bash /tmp/chefinstall.sh -c ${azurerm_public_ip.chefserver.ip_address} -u ${var.admin_username} -p ${var.admin_password}" ,
    ]
  }
}
