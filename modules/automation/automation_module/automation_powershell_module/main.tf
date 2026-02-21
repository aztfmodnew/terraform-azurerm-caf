terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)
}
