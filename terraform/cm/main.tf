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

    # The default username for our AMI
    connection {
      host        = "10.2.0.10"
      type        = "ssh"
      user        = "${var.admin_username}"
      password    = "${var.admin_password}"
      timeout     = "2m"
      agent       = false
    }
# INstall Chef Manage Server
  provisioner "remote-exec" {
    inline = [
      "curl -O https://raw.githubusercontent.com/smoreno812/chef-services/master/files/installer.sh > /tmp/chefinstall.sh ",
      "sudo bash /tmp/chefinstall.sh -c ${azurerm_public_ip.public_ips.id} -u ${var.admin_username} -p ${var.admin_password}" ,
    ]
  }
}
