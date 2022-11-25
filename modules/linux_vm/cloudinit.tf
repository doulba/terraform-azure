#############################
# Cloud config configuration#
#############################

data "template_file" "cloud_config_package_install" {
  count    = var.cloud_init_info.enabled ? 1 : 0
  template = file(var.cloud_init_info.script)

  vars = var.cloud_init_info.vars
}

data "template_cloudinit_config" "config" {
  count         = var.cloud_init_info.enabled ? 1 : 0
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.cloud_config_package_install[0].rendered
  }

}
