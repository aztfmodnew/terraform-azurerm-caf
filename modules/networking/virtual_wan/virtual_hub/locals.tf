locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(local.module_tag, var.tags, try(var.virtual_hub_config.tags, null))
}
