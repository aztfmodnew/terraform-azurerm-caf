resource "azurerm_container_app_environment" "cae" {
  name                                        = local.final_name
  location                                    = local.location
  resource_group_name                         = local.resource_group_name
  log_analytics_workspace_id                  = can(var.settings.log_analytics_workspace_id) ? var.settings.log_analytics_workspace_id : var.diagnostics.log_analytics[var.settings.log_analytics_key].id
  dapr_application_insights_connection_string = try(var.settings.dapr_application_insights_connection_string, null)
  infrastructure_subnet_id                    = try(var.subnet_id, null)
  internal_load_balancer_enabled              = try(var.settings.internal_load_balancer_enabled, null)
  zone_redundancy_enabled                     = try(var.settings.zone_redundancy_enabled, null)
  tags                                        = merge(local.tags, try(var.settings.tags, null))
}
