## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "atp_nsg" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "atp_nsg"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_network_security_group" "web_nsg" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "web_nsg"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_network_security_group" "ssh_nsg" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "ssh_nsg"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_network_security_group_security_rule" "atp_nsg_egress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.atp_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.VCN-CIDR
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "atp_nsg_ingress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.atp_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.VCN-CIDR
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}

resource "oci_core_network_security_group_security_rule" "web_nsg_egress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.atp_nsg[0].id
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "web_nsg_egress_rule2" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "web_nsg_ingress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ssh_nsg_egress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ssh_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "ssh_nsg_ingress_rule1" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ssh_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}
