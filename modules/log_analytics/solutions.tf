resource "azurerm_log_analytics_solution" "solution" {
  for_each = lookup(var.log_analytics, "solutions_maps", {})

  solution_name         = each.key
  location              = local.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  tags                  = merge(local.tags, try(each.value.tags, {}))

  plan {
    publisher      = lookup(each.value, "publisher")
    product        = lookup(each.value, "product")
    promotion_code = lookup(each.value, "promotion_code", null)
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
