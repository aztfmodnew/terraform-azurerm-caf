data "azurecaf_name" "disk" {
  for_each = lookup(var.settings, "data_disks", {})

  name          = each.value.name
  resource_type = "azurerm_managed_disk"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_managed_disk" "disk" {
  for_each = lookup(var.settings, "data_disks", {})

  name                   = data.azurecaf_name.disk[each.key].result
  location               = local.location
  resource_group_name    = local.resource_group_name
  storage_account_type   = each.value.storage_account_type
  create_option          = each.value.create_option
  disk_size_gb           = try(each.value.disk_size_gb, null)
  max_shares             = try(each.value.max_shares, null)
  source_uri             = try(each.value.source_uri, null)
  storage_account_id = try(coalesce(
    try(each.value.storage_account_id, null),
    try(var.storage_accounts[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.storage_account_key].id, null)
  ), null)
  zone                   = try(each.value.zone, each.value.zones[0], null)
  disk_iops_read_write   = try(each.value.disk_iops_read_write, null)
  disk_mbps_read_write   = try(each.value.disk.disk_mbps_read_write, null)
  tags                   = merge(local.tags, try(each.value.tags, {}))
  disk_encryption_set_id = can(each.value.disk_encryption_set_id) ? each.value.disk_encryption_set_id : can(each.value.disk_encryption_set_key) ? var.disk_encryption_sets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.disk_encryption_set_key].id : null
  lifecycle {
    ignore_changes = [
      name,               #for ASR disk restores
      storage_account_id, #set on creation (Import/ImportSecure), ignored post-creation to prevent ASR drift
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  for_each = lookup(var.settings, "data_disks", {})

  managed_disk_id           = can(azurerm_managed_disk.disk[each.key].id) ? azurerm_managed_disk.disk[each.key].id : each.value.restored_disk_id
  virtual_machine_id        = local.os_type == "linux" ? azurerm_linux_virtual_machine.vm["linux"].id : azurerm_windows_virtual_machine.vm["windows"].id
  lun                       = each.value.lun
  caching                   = lookup(each.value, "caching", "None")
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", false)

}
