
module "storage_accounts" {
  source   = "./modules/storage_account"
  for_each = var.storage_accounts

  client_config             = local.client_config
  diagnostic_profiles       = try(each.value.diagnostic_profiles, {})
  diagnostic_profiles_blob  = try(each.value.diagnostic_profiles_blob, {})
  diagnostic_profiles_queue = try(each.value.diagnostic_profiles_queue, {})
  diagnostic_profiles_table = try(each.value.diagnostic_profiles_table, {})
  diagnostic_profiles_file  = try(each.value.diagnostic_profiles_file, {})
  diagnostics               = local.combined_diagnostics
  global_settings           = local.global_settings
  managed_identities        = local.combined_objects_managed_identities
  private_dns               = local.combined_objects_private_dns
  private_endpoints         = try(each.value.private_endpoints, {})
  recovery_vaults           = local.combined_objects_recovery_vaults
  storage_account           = each.value
  var_folder_path           = var.var_folder_path
  vnets                     = local.combined_objects_networking
  virtual_subnets           = local.combined_objects_virtual_subnets

  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)
}

output "storage_accounts" {
  value     = module.storage_accounts
  sensitive = true
}

locals {
  storage_account_cmk_settings = {
    for key, value in var.storage_accounts : key => value.customer_managed_key
    if try(value.customer_managed_key, null) != null
  }

  storage_account_cmk_key_names = {
    for key, value in local.storage_account_cmk_settings : key => try(coalesce(
      try(value.key_name, null),
      try(local.combined_objects_keyvault_keys[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key_key].name, null)
    ), null)
  }

  storage_account_cmk_referenced_key_uris = {
    for key, value in local.storage_account_cmk_settings : key => (
      try(value.key_name, null) == null || try(value.key_name, "") == "" ? try(coalesce(
        try(local.combined_objects_keyvault_keys[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key_key].versionless_id, null),
        try(regex("^https://[^/]+/keys/[^/]+", local.combined_objects_keyvault_keys[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key_key].id), null)
      ), null) : null
    )
  }

  storage_account_cmk_version_suffixes = {
    for key, value in local.storage_account_cmk_settings : key => (
      try(value.key_version, null) == null ? "" : value.key_version == "" ? "" : "/${value.key_version}"
    )
  }
}

# ARM-only vault references need a lookup to preserve sovereign-cloud and cross-subscription endpoints.
data "azapi_resource" "storage_account_cmk_vault" {
  for_each = {
    for key, value in local.storage_account_cmk_settings : key => value
    if try(value.key_vault_key_id, null) == null &&
    !(try(value.lz_key, local.client_config.landingzone_key) == local.client_config.landingzone_key && contains(keys(var.keyvaults), try(value.keyvault_key, ""))) &&
    !contains(keys(try(var.remote_objects.keyvaults[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key], var.data_sources.keyvaults[value.keyvault_key], {})), "vault_uri") &&
    (
      (try(value.key_name, null) != null && try(value.key_name, "") != "") ||
      !(
        (try(value.lz_key, local.client_config.landingzone_key) == local.client_config.landingzone_key && contains(keys(local.security.keyvault_keys), try(value.keyvault_key_key, ""))) ||
        contains(keys(try(var.remote_objects.keyvault_keys[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key_key], {})), "versionless_id") ||
        contains(keys(try(var.remote_objects.keyvault_keys[try(value.lz_key, local.client_config.landingzone_key)][value.keyvault_key_key], {})), "id")
      )
    )
  }

  type                   = "Microsoft.KeyVault/vaults@2025-05-01"
  resource_id            = local.combined_objects_keyvaults[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.keyvault_key].id
  response_export_values = ["properties.vaultUri"]
  dynamic "timeouts" {
    for_each = try(each.value.vault_lookup_timeouts, null) == null ? [] : [each.value.vault_lookup_timeouts]
    content {
      read = try(timeouts.value.read, null)
    }
  }
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  depends_on = [module.keyvault_access_policies]
  for_each   = local.storage_account_cmk_settings

  storage_account_id = module.storage_accounts[each.key].id
  key_vault_key_id = coalesce(
    try(each.value.key_vault_key_id, null),
    try("${local.storage_account_cmk_referenced_key_uris[each.key]}${local.storage_account_cmk_version_suffixes[each.key]}", null),
    try(format("%s/keys/%s%s",
      trimsuffix(coalesce(
        try(local.combined_objects_keyvaults[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.keyvault_key].vault_uri, null),
        try(data.azapi_resource.storage_account_cmk_vault[each.key].output.properties.vaultUri, null)
      ), "/"),
      local.storage_account_cmk_key_names[each.key],
      local.storage_account_cmk_version_suffixes[each.key]
    ), null)
  )

  user_assigned_identity_id    = try(each.value.user_assigned_identity_id, null)
  federated_identity_client_id = try(each.value.federated_identity_client_id, null)

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

module "encryption_scopes" {
  source = "./modules/storage_account/encryption_scope"
  for_each = {
    for key, value in var.storage_accounts : key => value
    if can(value.encryption_scopes)
  }

  client_config      = local.client_config
  settings           = each.value
  storage_account_id = module.storage_accounts[each.key].id
  keyvault_keys      = local.combined_objects_keyvault_keys
}
