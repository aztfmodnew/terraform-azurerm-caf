resource "azurecaf_name" "cae" {
  name          = var.settings.name
  resource_type = "azurerm_container_app_environment"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_container_app_environment" "cae" {
  name                                        = azurecaf_name.cae.result
  location                                    = local.location
  resource_group_name                         = local.resource_group_name
  logs_destination                            = try(var.settings.logs_destination, "log-analytics")
  log_analytics_workspace_id                  = try(var.settings.logs_destination, "log-analytics") == "log-analytics" ? (can(var.settings.log_analytics_workspace_id) ? var.settings.log_analytics_workspace_id : var.diagnostics.log_analytics[var.settings.log_analytics_key].id) : null
  dapr_application_insights_connection_string = try(var.settings.dapr_application_insights_connection_string, null)
  infrastructure_subnet_id                    = try(var.subnet_id, null)
  internal_load_balancer_enabled              = try(var.settings.internal_load_balancer_enabled, null)
  zone_redundancy_enabled                     = try(var.settings.zone_redundancy_enabled, null)
  tags                                        = merge(local.tags, try(var.settings.tags, null))

  dynamic "workload_profile" {
    for_each = try(var.settings.workload_profiles, [])
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      maximum_count         = try(workload_profile.value.maximum_count, null)
      minimum_count         = try(workload_profile.value.minimum_count, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
