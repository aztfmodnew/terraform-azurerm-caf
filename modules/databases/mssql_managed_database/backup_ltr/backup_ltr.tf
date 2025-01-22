resource "azapi_update_resource" "backupltr" {
  type      = "Microsoft.Sql/managedInstances/databases/backupLongTermRetentionPolicies@2024-05-01-preview"
  name      = "default"
  parent_id = var.database_id

  body = {
    properties = {
      backupStorageAccessTier = try(var.settings.backupStorageAccessTier, null)
      monthlyRetention        = try(var.settings.monthlyRetention, "")
      weeklyRetention         = try(var.settings.weeklyRetention, "")
      weekOfYear              = try(var.settings.weekOfYear, 0)
      yearlyRetention         = try(var.settings.yearlyRetention, "")
    }
  }
}