Using Terraform to manage AzureRM

CM \ Builds Resource group for configuation management and deploys Chef server.
Demo \ Builds demo resource group and deploys services using Chef to release configurations and asset.


You will need to create a file named terraform.tfvars for each terraform state location.

Contents of the file are:

#Provider Configuration
subscription_id = ""
client_id = ""
client_secret = ""
tenant_id = ""
#Default server admin credentials
admin_username = ""
admin_password = ""
#Other
environment = ""

The values need to be completed for the target infrastructure.
