module "private_endpoint" {
  source   = "../../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_linux_web_app_slot.linux_web_app_slot.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) ? each.value.subnet_id : var.remote_objects.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  private_dns         = var.remote_objects.private_dns
  client_config       = var.client_config
}
