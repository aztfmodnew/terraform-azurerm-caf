locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    var.server_tags
  ) : null



}

