## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


module "oci-adb" {
  source                                = "github.com/oracle-devrel/terraform-oci-arch-adb"
  adb_password                          = var.atp_password
  compartment_ocid                      = var.compartment_ocid
  adb_database_cpu_core_count           = var.atp_database_cpu_core_count
  adb_database_data_storage_size_in_tbs = var.atp_database_data_storage_size_in_tbs
  adb_database_db_name                  = var.atp_database_db_name
  adb_database_db_version               = var.atp_database_db_version
  adb_database_display_name             = var.atp_database_display_name
  adb_database_freeform_tags            = var.atp_database_freeform_tags
  adb_database_license_model            = var.atp_database_license_model
  adb_database_db_workload              = "OLTP"
  use_existing_vcn                      = var.atp_private_endpoint
  adb_private_endpoint                  = var.atp_private_endpoint
  vcn_id                                = var.atp_private_endpoint ? local.vcn_id : null
  adb_nsg_id                            = var.atp_private_endpoint ? local.atp_nsg_id : null
  adb_private_endpoint_label            = var.atp_private_endpoint ? var.atp_database_atp_private_endpoint_label : null
  adb_subnet_id                         = var.atp_private_endpoint ? local.atp_subnet_id : null
  defined_tags                          = local.defined_tags
}

