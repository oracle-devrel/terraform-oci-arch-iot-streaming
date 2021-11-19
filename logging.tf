## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "log_group"
}

resource "oci_logging_log" "log_on_fn_invoke_Stream2ATPFnApp" {
  display_name = "log_on_fn_invoke_Stream2ATPFnApp"
  log_group_id = oci_logging_log_group.log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "invoke"
      resource    = oci_functions_application.Stream2ATPFnApp.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled = true
}

resource "oci_logging_log" "log_on_fn_invoke_Upload2StreamFnApp" {
  display_name = "log_on_fn_invoke_Upload2StreamFnApp"
  log_group_id = oci_logging_log_group.log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "invoke"
      resource    = oci_functions_application.Upload2StreamFnApp.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled = true
}
