resource "azurecaf_name" "backup_vault_policy" {
  name          = var.settings.policy_name
  resource_type = "azurerm_data_protection_backup_policy_blob_storage"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_data_protection_backup_policy_blob_storage" "backup_vault_policy" {
  name     = azurecaf_name.backup_vault_policy.result
  vault_id = var.vault_id

  # OperationalStore: retención máx 360 días. Mutuamente excluyente con vault_default_retention_duration.
  operational_default_retention_duration = lookup(var.settings, "operational_default_retention_duration", null)

  # VaultStore: vault_default_retention_duration requiere backup_repeating_time_intervals.
  vault_default_retention_duration    = lookup(var.settings, "vault_default_retention_duration", null)
  backup_repeating_time_intervals     = lookup(var.settings, "backup_repeating_time_intervals", null)
  time_zone                           = lookup(var.settings, "time_zone", null)

  dynamic "retention_rule" {
    for_each = lookup(var.settings, "retention_rules", [])
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority

      life_cycle {
        duration        = retention_rule.value.life_cycle.duration
        data_store_type = retention_rule.value.life_cycle.data_store_type
      }

      criteria {
        absolute_criteria      = lookup(retention_rule.value.criteria, "absolute_criteria", null)
        days_of_week           = lookup(retention_rule.value.criteria, "days_of_week", null)
        days_of_month          = lookup(retention_rule.value.criteria, "days_of_month", null)
        months_of_year         = lookup(retention_rule.value.criteria, "months_of_year", null)
        weeks_of_month         = lookup(retention_rule.value.criteria, "weeks_of_month", null)
        scheduled_backup_times = lookup(retention_rule.value.criteria, "scheduled_backup_times", null)
      }
    }
  }
}
