terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.1.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
  }
}

locals {
  tags = merge(
    var.base_tags ? try(var.global_settings.tags, {}) : {},
    try(var.settings.tags, {})
  )
}
