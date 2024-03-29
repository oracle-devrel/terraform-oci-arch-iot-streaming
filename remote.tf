## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  flask_atp_py_template = templatefile("${path.module}/flask/flask_atp.py",
    {
      atp_user                            = var.atp_user
      atp_password                        = var.atp_password
      atp_alias                           = join("", [var.atp_database_db_name, "_medium"])
      oracle_instant_client_version_short = var.oracle_instant_client_version_short
      apigw_endpoint_URL                  = data.oci_apigateway_deployment.apigateway_deployment.endpoint
    }
  )

  flask_atp_sh_template = templatefile("${path.module}/flask/flask_atp.sh",
    {
      oracle_instant_client_version_short = var.oracle_instant_client_version_short
    }
  )

  flask_bootstrap_template = templatefile("${path.module}/flask/flask_bootstrap.sh",
    {
      atp_tde_wallet_zip_file             = var.atp_tde_wallet_zip_file
      oracle_instant_client_version       = var.oracle_instant_client_version
      oracle_instant_client_version_short = var.oracle_instant_client_version_short
    }
  )

  sqlnet_ora_template = templatefile("${path.module}/flask/sqlnet.ora",
    {
      oracle_instant_client_version_short = var.oracle_instant_client_version_short
    }
  )

  index_html_template = templatefile("${path.module}/flask/templates/index.html",
    {
      apigw_endpoint_URL = data.oci_apigateway_deployment.apigateway_deployment.endpoint
    }
  )

}

resource "null_resource" "webserver_ConfigMgmt" {
  depends_on = [oci_core_instance.webserver, module.oci-adb.adb_database]

  provisioner "local-exec" {
    command = "echo '${module.oci-adb.adb_database.adb_wallet_content}' >> ${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.atp_tde_wallet_zip_file}_encoded > ${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.atp_tde_wallet_zip_file
    destination = "/tmp/${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = local.sqlnet_ora_template
    destination = "/tmp/sqlnet.ora"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = local.index_html_template
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = local.flask_atp_py_template
    destination = "/tmp/flask_atp.py"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = local.flask_atp_sh_template
    destination = "/tmp/flask_atp.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = local.flask_bootstrap_template
    destination = "/tmp/flask_bootstrap.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "chmod +x /tmp/flask_bootstrap.sh",
    "sudo /tmp/flask_bootstrap.sh"]
  }

}
