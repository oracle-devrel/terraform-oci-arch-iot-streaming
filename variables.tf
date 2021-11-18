## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "atp_password" {}
variable "atp_admin_password" {}

variable "availability_domain_name" {
  default = ""
}

variable "availability_domain_number" {
  default = 0
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.1.1"
}

variable "oracle_instant_client_version" {
  default = "21.1"
}

variable "oracle_instant_client_version_short" {
  default = "21"
}

variable "use_existing_vcn" {
  default = false
}

variable "use_existing_nsg" {
  default = false
}

variable "vcn_id" {
  default = ""
}

variable "fn_subnet_id" {
  default = ""
}

variable "apigwsubnet_subnet_id" {
  default = ""
}

variable "compute_subnet_id" {
  default = ""
}

variable "compute_nsg_ids" {
  default = []
}

variable "atp_subnet_id" {
  default = ""
}

variable "atp_nsg_id" {
  default = ""
}

variable "atp_admin_user" {
  default = "admin"
}

variable "atp_user" {
  default = "iotuser"
}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "websubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "atpsubnet-CIDR" {
  default = "10.0.2.0/24"
}

variable "VCNname" {
  default = "VCN"
}

variable "httpx_ports" {
  type    = list(string)
  default = ["80", "443"]
}

variable "Shape" {
  default = "VM.Standard.E3.Flex"
}

variable "Shape_flex_ocpus" {
  default = 1
}

variable "Shape_flex_memory" {
  default = 10
}

variable "ssh_public_key" {
  default = ""
}

variable "atp_private_endpoint" {
  default = true
}

variable "atp_database_cpu_core_count" {
  default = 1
}

variable "atp_database_data_storage_size_in_tbs" {
  default = 1
}

variable "atp_database_db_name" {
  default = "iotpdb"
}

variable "atp_database_db_version" {
  default = "19c"
}

variable "atp_database_defined_tags_value" {
  default = ""
}

variable "atp_database_display_name" {
  default = "atp"
}

variable "atp_database_freeform_tags" {
  default = {
    "Owner" = ""
  }
}

variable "atp_database_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "atp_tde_wallet_zip_file" {
  default = "tde_wallet.zip"
}

variable "atp_database_atp_private_endpoint_label" {
  default = "atpPrivateEndpoint"
}

#variable "ocir_namespace" {
#  default = ""
#}

variable "ocir_repo_name" {
  default = "iotfunctions"
}

#variable "ocir_docker_repository" {
#  default = ""
#}

variable "ocir_user_name" {
  default = ""
}

variable "ocir_user_password" {
  default = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
  #  default     = "8"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
}

locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.Shape)
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  #ocir_namespace = lookup(data.oci_identity_tenancy.oci_tenancy, "name" )
  ocir_namespace           = lookup(data.oci_objectstorage_namespace.test_namespace, "namespace")
  availability_domain_name = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number], "name") : var.availability_domain_name
  atp_nsg_id               = !var.use_existing_nsg ? oci_core_network_security_group.atp_nsg[0].id : var.atp_nsg_id
  atp_subnet_id            = !var.use_existing_vcn ? oci_core_subnet.atpsubnet[0].id : var.atp_subnet_id
  vcn_id                   = !var.use_existing_vcn ? oci_core_virtual_network.vcn[0].id : var.vcn_id
}
