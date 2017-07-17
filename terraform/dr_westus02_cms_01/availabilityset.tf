resource "azurerm_availability_set" "dr_uswest02_avset01" {
  name                         = "${var.vm_name_prefix}-avset"
  location                     = "${var.region}"
  resource_group_name          = "${var.rname}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}
