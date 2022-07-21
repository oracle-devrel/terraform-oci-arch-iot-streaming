## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_functions_application" "Stream2ATPFnApp" {
  depends_on     = [module.policies]
  compartment_id = var.compartment_ocid
  display_name   = "Stream2ATPFnApp"
  subnet_ids     = [!var.use_existing_vcn ? oci_core_subnet.websubnet[0].id : var.fn_subnet_id]
  defined_tags   = local.defined_tags
}

resource "oci_functions_function" "UpdateSetupATPFn" {
  depends_on     = [null_resource.SetupATPFnPush2OCIR]
  application_id = oci_functions_application.Stream2ATPFnApp.id
  display_name   = "SetupATPFn"
  image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
  memory_in_mbs  = "256"
  defined_tags   = local.defined_tags

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "oci_functions_invoke_function" "UpdateSetupATPFnInvoke" {
  depends_on  = [module.oci-adb.adb_database, oci_functions_function.UpdateSetupATPFn]
  function_id = oci_functions_function.UpdateSetupATPFn.id
}

resource "oci_functions_function" "Stream2ATPFn" {
  depends_on     = [null_resource.Stream2ATPFnPush2OCIR, oci_functions_function.UpdateSetupATPFn]
  application_id = oci_functions_application.Stream2ATPFnApp.id
  display_name   = "Stream2ATPFn"
  image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
  memory_in_mbs  = "256"
  defined_tags   = local.defined_tags
}

resource "oci_functions_application" "Upload2StreamFnApp" {
  depends_on     = [module.policies]
  compartment_id = var.compartment_ocid
  display_name   = "Upload2StreamFnApp"
  subnet_ids     = [!var.use_existing_vcn ? oci_core_subnet.websubnet[0].id : var.fn_subnet_id]
  defined_tags   = local.defined_tags
}

resource "oci_functions_function" "Upload2StreamFn" {
  depends_on     = [null_resource.Upload2StreamFnPush2OCIR]
  application_id = oci_functions_application.Upload2StreamFnApp.id
  display_name   = "Upload2StreamFn"
  image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
  memory_in_mbs  = "256"
  defined_tags   = local.defined_tags
}

