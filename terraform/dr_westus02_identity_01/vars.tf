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
#Software versions
variable "chef_client_version" {}
