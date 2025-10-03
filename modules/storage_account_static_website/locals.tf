locals {
  tags = var.base_tags ? {
    for key, value in var.resource_group.tags : key => value
    if key != "caf_terraform"
  } : {}

  storage_account_id = coalesce(
    try(var.settings.storage_account_id, null),
    try(var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].id, null)
  )
}