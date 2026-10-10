resource "azapi_resource" "sqlmi_failover_group" {
  type                 = "Microsoft.Sql/locations/instanceFailoverGroups@2025-01-01"
  name                 = var.settings.name
  parent_id            = format("%s/providers/Microsoft.Sql/locations/%s", var.managed_instance.resource_group_id, var.managed_instance.location)
  ignore_null_property = true
  body = {
    properties = {
      managedInstancePairs = [
        {
          primaryManagedInstanceId = var.managed_instance.id
          partnerManagedInstanceId = var.partner_managed_instance.id
        }
      ]
      partnerRegions = [
        {
          location = var.partner_managed_instance.location
        }
      ]
      readWriteEndpoint = {
        failoverPolicy                         = try(var.settings.read_write_endpoint_failover_policy.mode, "Manual")
        failoverWithDataLossGracePeriodMinutes = try(var.settings.read_write_endpoint_failover_policy.mode, "Manual") == "Automatic" ? var.settings.read_write_endpoint_failover_policy.grace_minutes : null
      }
      readOnlyEndpoint = try(var.settings.read_only_endpoint_failover_policy, null) != null ? {
        failoverPolicy = var.settings.read_only_endpoint_failover_policy
        } : try(var.settings.readonly_endpoint_failover_policy_enabled, null) != null ? {
        failoverPolicy = var.settings.readonly_endpoint_failover_policy_enabled ? "Enabled" : "Disabled"
      } : null
      secondaryType = try(var.settings.secondary_type, "Standby")
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
