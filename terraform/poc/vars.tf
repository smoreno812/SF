#Provider Configuration
variable "subscription_id" {}
variable "client_id"       {}
variable "client_secret"   {}
variable "tenant_id"       {}
# Default server admin credentials
variable "admin_username" {}
variable "admin_password" {}
#Other
variable "region"          {}
variable "environment"     {}
#Resource group
variable "rgroup" {}
variable "rname"  {}
#virtual network
variable "network_id" {}
variable "network_name" {}
variable "network_space"  {}
#Subnet
variable "subnet_id"  {}
variable "subnet_name"  {}
variable "subnet" {}
#Vm Build
variable "vm_name_prefix" {}
variable "vm_size" {}
variable "vm_count" {}
variable "vm_winrm_port" {}

#Software versions
variable "chef_client_version" {}

#Null resource
variable "azure_dns_suffix" {
    description = "Azure DNS suffix for the Public IP"
    default = "cloudapp.azure.com"
}
resource "null_resource" "intermediates" {
    triggers = {
        full_vm_dns_name = "${var.vm_name_prefix}0${count.index}.${var.rname}.${var.azure_dns_suffix}"
    }
}

output "full_vm_dns_name" {
    value = "${null_resource.intermediates.triggers.full_vm_dns_name}"
}
