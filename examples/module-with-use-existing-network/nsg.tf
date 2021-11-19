## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "my_atp_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "my_atp_nsg"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_network_security_group_security_rule" "my_atp_nsg_egress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_atp_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "192.168.0.0/16"
  destination_type          = "CIDR_BLOCK"
}


resource "oci_core_network_security_group_security_rule" "my_atp_nsg_ingress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_atp_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "192.168.0.0/16"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}

resource "oci_core_network_security_group" "my_compute_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "my_compute_nsg"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_network_security_group_security_rule" "my_compute_nsg_egress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_compute_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.my_atp_nsg.id
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "my_compute_nsg_egress_rule2" {
  network_security_group_id = oci_core_network_security_group.my_compute_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "my_compute_nsg_ingress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_compute_nsg.id
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

resource "oci_core_network_security_group_security_rule" "my_compute_nsg_ingress_rule2" {
  network_security_group_id = oci_core_network_security_group.my_compute_nsg.id
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



