## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "Upload2StreamFn_POST_EndPoint_URL" {
  value = [join("", [data.oci_apigateway_deployment.apigateway_deployment.endpoint, "/upload2stream"])]
}

output "Flask_Webserver_URL" {
  value = [join("", ["http://", data.oci_core_vnic.webserver_VNIC1.public_ip_address, "/"])]
}

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
