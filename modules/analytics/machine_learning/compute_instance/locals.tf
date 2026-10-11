locals {

  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(var.tags, var.settings.tags, local.module_tag)

}