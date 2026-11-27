module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = try(var.settings.private_endpoints, {})

  resource_id         = azurerm_monitor_private_link_scope.scope.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id = try(
    each.value.subnet_id,
    try(
      var.remote_objects.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id,
      var.remote_objects.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
    )
  )
  settings = merge(
    each.value,
    {
      private_service_connection = merge(
        try(each.value.private_service_connection, {}),
        {
          subresource_names = ["azuremonitor"]
        }
      )
    }
  )
  global_settings = var.global_settings
  tags            = local.tags
  base_tags       = var.base_tags
  private_dns     = try(var.remote_objects.private_dns, {})
  client_config   = var.client_config
}
