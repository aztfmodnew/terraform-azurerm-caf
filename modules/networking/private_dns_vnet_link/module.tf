resource "azurecaf_name" "pnetlk" {
  for_each = var.settings.private_dns_zones

  name          = each.value.name
  resource_type = "azurerm_private_dns_zone_virtual_network_link"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

data "azurerm_private_dns_zone" "private_dns" {
  for_each = {
    for key, value in var.settings.private_dns_zones : key => value
    if try(value.private_dns_zone_id, null) == null && try(value.id, null) == null && try(value.key, null) == null && try(value.private_dns_zone_name, null) != null
  }

  name                = each.value.private_dns_zone_name
  resource_group_name = try(each.value.resource_group_name, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each = var.settings.private_dns_zones

  name = azurecaf_name.pnetlk[each.key].result
  private_dns_zone_id = try(coalesce(
    try(each.value.private_dns_zone_id, null),
    try(each.value.id, null),
    try(var.private_dns[try(each.value.lz_key, var.client_config.landingzone_key)][try(each.value.private_dns_key, each.value.key)].id, null),
    try(data.azurerm_private_dns_zone.private_dns[each.key].id, null)
  ), null)
  virtual_network_id   = var.virtual_network_id
  registration_enabled = try(each.value.registration_enabled, false)
  tags                 = merge(local.tags, try(each.value.tags, null))
}