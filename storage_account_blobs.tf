#
# Storage account blobs can be created as a nested object or isolated to allow RBAC to be set before writing the blob
#

resource "time_sleep" "delay" {
  depends_on = [azurerm_role_assignment.for_deferred]
  for_each   = local.storage.storage_account_blobs

  create_duration = try(each.value.dealy.create_duration, "300s")
}

data "azurerm_storage_container" "storage_account_blobs" {
  for_each = {
    for key, value in local.storage.storage_account_blobs : key => value
    if can(value.storage_container_name)
  }

  name               = each.value.storage_container_name
  storage_account_id = module.storage_accounts[each.value.storage_account_key].id

  depends_on = [module.storage_accounts]
}

module "storage_account_blobs" {
  source   = "./modules/storage_account/blob"
  for_each = local.storage.storage_account_blobs

  depends_on = [time_sleep.delay]

  storage_container_id = can(each.value.storage_container_name) ? data.azurerm_storage_container.storage_account_blobs[each.key].id : local.combined_objects_storage_containers[try(each.value.storage_container.lz_key, local.client_config.landingzone_key)][each.value.storage_container.key].id
  settings             = each.value
  var_folder_path      = var.var_folder_path
}

output "storage_account_blobs" {
  value = module.storage_account_blobs

}
