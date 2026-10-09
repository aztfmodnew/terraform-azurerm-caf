resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "root_dbfs" {
  for_each = try(var.settings.root_dbfs_customer_managed_key, null) == null ? {} : {
    root_dbfs = var.settings.root_dbfs_customer_managed_key
  }

  workspace_id     = azurerm_databricks_workspace.ws.id
  key_vault_key_id = local.root_dbfs_customer_managed_key_key_vault_key_id
  key_vault_id     = try(each.value.key_vault_id, null)

  lifecycle {
    precondition {
      condition     = local.root_dbfs_customer_managed_key_key_vault_key_id != null
      error_message = "root_dbfs_customer_managed_key requires key_vault_key_id or a resolvable key_vault_key reference."
    }

    precondition {
      condition     = try(var.settings.customer_managed_key_enabled, false) == true
      error_message = "root_dbfs_customer_managed_key requires customer_managed_key_enabled = true on the workspace."
    }
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
