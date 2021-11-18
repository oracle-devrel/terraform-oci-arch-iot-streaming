## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_apigateway_gateway" "apigateway" {
  depends_on = [oci_identity_policy.ManageAPIGWFamilyPolicy,
    oci_identity_policy.ManageVCNFamilyPolicy,
    oci_identity_policy.UseFnFamilyPolicy,
  oci_identity_policy.AnyUserUseFnPolicy]
  compartment_id = var.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = !var.use_existing_vcn ? oci_core_subnet.websubnet[0].id : var.apigwsubnet_subnet_id
  display_name   = "apigateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_apigateway_deployment" "apigateway_deployment" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.apigateway.id
  path_prefix    = "/v1"
  display_name   = "apigateway_deployment"

  specification {
    routes {
      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.Upload2StreamFn.id
      }
      methods = ["POST"]
      path    = "/upload2stream"
    }

    routes {
      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.Stream2ATPFn.id
      }
      methods = ["GET"]
      path    = "/stream2atp"
    }
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

