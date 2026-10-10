resource "azapi_update_resource" "backupltr" {
  type      = "Microsoft.Sql/managedInstances/databases/backupLongTermRetentionPolicies@2025-01-01"
  name      = "default"
  parent_id = var.database_id

  body = {
    properties = {
      for key, value in {
        backupStorageAccessTier = try(var.settings.backupStorageAccessTier, null)
        monthlyRetention        = try(var.settings.monthlyRetention, "")
        weeklyRetention         = try(var.settings.weeklyRetention, "")
        weekOfYear              = try(var.settings.weekOfYear, 0)
        yearlyRetention         = try(var.settings.yearlyRetention, "")
      } : key => value if value != null
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