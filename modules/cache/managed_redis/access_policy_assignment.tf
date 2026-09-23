resource "azurerm_managed_redis_access_policy_assignment" "role_assignments" {
  for_each = {
    for assignment in local.redis_role_assignments_merged : assignment.assignment_key => assignment
  }

  managed_redis_id = azurerm_managed_redis.managed_redis.id
  object_id        = each.value.principal_id

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}