locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null),
    local.module_tag
  ) : merge(try(var.settings.tags, null), local.module_tag)

  location            = coalesce(var.location, try(var.settings.location, null), try(var.global_settings.regions[var.settings.region], null), var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, try(var.settings.resource_group_name, null), var.resource_group.name)

  machine_learning_workspace_reference = (
    try(var.settings.custom_parameters.machine_learning_workspace, null) != null ? var.settings.custom_parameters.machine_learning_workspace :
    try(var.settings.custom_parameters.machine_learning, null) != null ? var.settings.custom_parameters.machine_learning :
    try(var.settings.machine_learning, null)
  )

  machine_learning_workspace_id = try(coalesce(
    try(var.settings.custom_parameters.machine_learning_workspace_id, null),
    try(local.machine_learning_workspace_reference.id, null),
    try(
      var.aml[
        coalesce(try(local.machine_learning_workspace_reference.lz_key, null), var.client_config.landingzone_key)
      ][local.machine_learning_workspace_reference.key].id,
      null
    )
  ), null)

  databricks_network_lz_key = coalesce(
    try(var.settings.custom_parameters.lz_key, null),
    var.client_config.landingzone_key
  )

  managed_services_cmk_key_vault_key_id = try(coalesce(
    try(var.settings.managed_services_cmk_key_vault_key_id, null),
    try(
      var.remote_objects.keyvault_keys[
        coalesce(try(var.settings.managed_services_cmk_key.lz_key, null), var.client_config.landingzone_key)
      ][var.settings.managed_services_cmk_key.key].id,
      null
    )
  ), null)

  managed_disk_cmk_key_vault_key_id = try(coalesce(
    try(var.settings.managed_disk_cmk_key_vault_key_id, null),
    try(
      var.remote_objects.keyvault_keys[
        coalesce(try(var.settings.managed_disk_cmk_key.lz_key, null), var.client_config.landingzone_key)
      ][var.settings.managed_disk_cmk_key.key].id,
      null
    )
  ), null)

  access_connector_id = try(coalesce(
    try(var.settings.access_connector_id, null),
    try(
      var.remote_objects.databricks_access_connectors[
        coalesce(try(var.settings.access_connector.lz_key, null), var.client_config.landingzone_key)
      ][var.settings.access_connector.key].id,
      null
    )
  ), null)

  root_dbfs_customer_managed_key_key_vault_key_id = try(coalesce(
    try(var.settings.root_dbfs_customer_managed_key.key_vault_key_id, null),
    try(
      var.remote_objects.keyvault_keys[
        coalesce(
          try(var.settings.root_dbfs_customer_managed_key.key_vault_key.lz_key, null),
          var.client_config.landingzone_key
        )
      ][var.settings.root_dbfs_customer_managed_key.key_vault_key.key].id,
      null
    )
  ), null)
}
