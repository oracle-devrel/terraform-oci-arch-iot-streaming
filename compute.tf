## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "key_script" {
  template = file("${path.module}/scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}

resource "oci_core_instance" "webserver" {
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "webserver"
  shape               = var.Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.Shape_flex_memory
      ocpus         = var.Shape_flex_ocpus
    }
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  create_vnic_details {
    subnet_id = !var.use_existing_vcn ? oci_core_subnet.websubnet[0].id : var.compute_subnet_id
    nsg_ids   = !var.use_existing_nsg ? [oci_core_network_security_group.web_nsg[0].id, oci_core_network_security_group.ssh_nsg[0].id] : var.compute_nsg_ids
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
