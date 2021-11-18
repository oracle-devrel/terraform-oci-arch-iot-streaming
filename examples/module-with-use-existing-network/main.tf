## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "atp_admin_password" {}
variable "atp_password" {}
variable "ocir_user_name" {}
variable "ocir_user_password" {}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "oci-arch-iot-streaming" {
  source                = "github.com/oracle-devrel/terraform-oci-arch-iot-streaming"
  tenancy_ocid          = var.tenancy_ocid
  user_ocid             = var.user_ocid
  fingerprint           = var.fingerprint
  region                = var.region
  private_key_path      = var.private_key_path
  compartment_ocid      = var.compartment_ocid
  atp_admin_password    = var.atp_admin_password
  atp_password          = var.atp_password
  ocir_user_name        = var.ocir_user_name
  ocir_user_password    = var.ocir_user_password
  use_existing_vcn      = true
  use_existing_nsg      = true
  vcn_id                = oci_core_virtual_network.my_vcn.id
  fn_subnet_id          = oci_core_subnet.my_public_subnet.id
  compute_subnet_id     = oci_core_subnet.my_public_subnet.id
  compute_nsg_ids       = [oci_core_network_security_group.my_compute_nsg.id]
  atp_subnet_id         = oci_core_subnet.my_private_subnet.id
  atp_nsg_id            = oci_core_network_security_group.my_atp_nsg.id
  apigwsubnet_subnet_id = oci_core_subnet.my_public_subnet.id
}

output "Upload2StreamFn_POST_EndPoint_URL" {
  value = module.oci-arch-iot-streaming.Upload2StreamFn_POST_EndPoint_URL
}

output "Flask_Webserver_URL" {
  value = module.oci-arch-iot-streaming.Flask_Webserver_URL
}

output "generated_ssh_private_key" {
  value     = module.oci-arch-iot-streaming.generated_ssh_private_key
  sensitive = true
}

