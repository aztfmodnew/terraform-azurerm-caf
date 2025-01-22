locals {
  tags = var.inherit_tags ? var.tags : try(var.settings.tags, null)
}

