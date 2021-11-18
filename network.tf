## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "vcn" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.VCN-CIDR
  dns_label      = "vcn"
  compartment_id = var.compartment_ocid
  display_name   = "vcn"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "igw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_route_table" "rt_transit_routing_sgw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt_transit_routing_sgw"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_service_gateway" "sgw" {
  count = !var.use_existing_vcn ? 1 : 0
  #Required
  compartment_id = var.compartment_ocid

  services {
    service_id = data.oci_core_services.oci_services.services[0]["id"]
  }

  vcn_id = oci_core_virtual_network.vcn[0].id

  #Optional
  display_name   = "ServiceGateway"
  route_table_id = oci_core_route_table.rt_transit_routing_sgw[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_nat_gateway" "natgw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "nat_gateway"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "rt_via_sgw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt_via_sgw"

  route_rules {
    destination       = data.oci_core_services.oci_services.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "rt_via_igw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt_via_igw"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "rt_via_natgw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt_via_natgw"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.natgw[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "seclist1" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "seclist1"
  vcn_id         = oci_core_virtual_network.vcn[0].id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.httpx_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_dhcp_options" "dhcpoptions1" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "dhcpoptions1"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["example.com"]
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "websubnet" {
  count             = !var.use_existing_vcn ? 1 : 0
  cidr_block        = var.websubnet-CIDR
  display_name      = "websubnet"
  dns_label         = "sub1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn[0].id
  route_table_id    = oci_core_route_table.rt_via_igw[0].id
  dhcp_options_id   = oci_core_dhcp_options.dhcpoptions1[0].id
  security_list_ids = [oci_core_security_list.seclist1[0].id]
  defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "atpsubnet" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.atpsubnet-CIDR
  display_name               = "atpSubnet"
  dns_label                  = "sub2"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn[0].id
  route_table_id             = oci_core_route_table.rt_via_natgw[0].id
  dhcp_options_id            = oci_core_dhcp_options.dhcpoptions1[0].id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
