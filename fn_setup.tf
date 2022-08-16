## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "Login2OCIR" {
  depends_on = [oci_functions_application.Stream2ATPFnApp,
    module.oci-adb.adb_database,
  module.policies]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }
}

resource "null_resource" "SetupATPFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR,
    oci_functions_application.Stream2ATPFnApp,
  module.oci-adb.adb_database]

  provisioner "local-exec" {
    command = "echo '${module.oci-adb.adb_database.adb_wallet_content}' >> ${path.module}/functions/SetupATPFn/${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${path.module}/functions/SetupATPFn/${var.atp_tde_wallet_zip_file}_encoded > ${path.module}/functions/SetupATPFn/${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/functions/SetupATPFn/${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "${path.module}/functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command     = "rm -rf /home/orm/.fn ; fn build --verbose --build-arg ARG_ADMIN_ATP_PASSWORD=${var.atp_admin_password} --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.atp_database_db_name}_medium"
    working_dir = "${path.module}/functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "${path.module}/functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "${path.module}/functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/functions/SetupATPFn/${var.atp_tde_wallet_zip_file}"
  }
}


resource "null_resource" "Stream2ATPFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR,
    oci_streaming_stream.stream,
    oci_streaming_stream_pool.streamPool,
    oci_functions_application.Stream2ATPFnApp,
    module.oci-adb.adb_database,
    #               null_resource.atp_download_and_decode,
  null_resource.SetupATPFnPush2OCIR]

  provisioner "local-exec" {
    command = "echo '${module.oci-adb.adb_database.adb_wallet_content}' >> ${path.module}/functions/Stream2ATPFn/${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${path.module}/functions/Stream2ATPFn/${var.atp_tde_wallet_zip_file}_encoded > ${path.module}/functions/Stream2ATPFn/${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/functions/Stream2ATPFn/${var.atp_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "${path.module}/functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command     = "rm -rf /home/orm/.fn ; fn build --verbose --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.atp_database_db_name}_medium --build-arg ARG_STREAM_OCID=${oci_streaming_stream.stream.id} --build-arg ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}"
    working_dir = "${path.module}/functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "${path.module}/functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "${path.module}/functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/functions/Stream2ATPFn/${var.atp_tde_wallet_zip_file}"
  }
}


resource "null_resource" "Upload2StreamFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR,
    oci_streaming_stream.stream,
    oci_streaming_stream_pool.streamPool,
  oci_functions_application.Upload2StreamFnApp]

  provisioner "local-exec" {
    command     = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "${path.module}/functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_OCID=${oci_streaming_stream.stream.id}' "

  }

  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}'"

  }

  provisioner "local-exec" {
    command     = "rm -rf /home/orm/.fn ; fn build --verbose --build-arg ARG_STREAM_OCID='${oci_streaming_stream.stream.id}' --build-arg ARG_STREAM_ENDPOINT='${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}'"
    working_dir = "${path.module}/functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "${path.module}/functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "${path.module}/functions/Upload2StreamFn"
  }

}
