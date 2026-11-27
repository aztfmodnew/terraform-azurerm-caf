// resource "azurecaf_name" "service" {
//   name          = var.settings.name
//   prefixes      = var.global_settings.prefixes
//   resource_type = "azurerm_cognitive_deployment"
//   random_length = var.global_settings.random_length
//   clean_input   = true
//   passthrough   = var.global_settings.passthrough
//   use_slug      = var.global_settings.use_slug
// }

resource "azurerm_cognitive_deployment" "service" {
  name                 = var.settings.name
  cognitive_account_id = var.cognitive_account_id
  model {
    format  = var.settings.model.format
    name    = var.settings.model.name
    version = try(var.settings.model.version, null)
  }
  sku {
    name     = var.settings.sku.name
    tier     = try(var.settings.sku.tier, null)
    size     = try(var.settings.sku.size, null)
    family   = try(var.settings.sku.family, null)
    capacity = try(var.settings.sku.capacity, 1)
  }

  dynamic_throttling_enabled = try(var.settings.dynamic_throttling_enabled, null)
  rai_policy_name            = try(var.settings.rai_policy_name, null)
  spillover_deployment_name  = try(var.settings.spillover_deployment_name, null)
  version_upgrade_option     = try(var.settings.version_upgrade_option, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
