locals {
  tags = merge(var.base_tags, try(var.settings.tags, null))
}

