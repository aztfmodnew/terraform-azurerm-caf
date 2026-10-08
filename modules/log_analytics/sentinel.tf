resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  for_each = try(var.log_analytics.sentinel_onboarding, null) == null ? {} : { default = var.log_analytics.sentinel_onboarding }

  workspace_id                 = azurerm_log_analytics_workspace.law.id
  customer_managed_key_enabled = try(each.value.customer_managed_key_enabled, false)

  depends_on = [azurerm_log_analytics_solution.solution]

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
