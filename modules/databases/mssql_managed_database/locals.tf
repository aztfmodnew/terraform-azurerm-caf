locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }


  tags         = merge(var.base_tags, local.module_tag, try(var.settings.tags, null))
  arm_filename = "${path.module}/arm_managed_db.json"

}