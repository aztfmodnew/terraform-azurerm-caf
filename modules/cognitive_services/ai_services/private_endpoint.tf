#
# Private endpoint configuration
#

module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_cognitive_account.ai_services.id
  name                = each.value.name
  location            = try(each.value.location, local.location)
  resource_group_name = try(each.value.resource_group_name, local.resource_group_name)
  subnet_id = try(
    coalesce(
      try(each.value.subnet_id, null),
      try(var.remote_objects.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id, null),
      try(var.remote_objects.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.subnet_key].id, null)
    ),
    null
  )
  settings = merge(
    each.value,
    {
      private_service_connection = merge(
        try(each.value.private_service_connection, {}),
        {
          subresource_names = ["account"]
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
