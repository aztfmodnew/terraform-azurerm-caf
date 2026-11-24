module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id = azurerm_api_management.apim.id
  name        = each.value.name
  location = try(
    coalesce(
      try(each.value.location, null),
      try(var.resource_groups[try(each.value.resource_group.lz_key, var.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location, null)
    ),
    local.location
  )
  resource_group_name = try(
    coalesce(
      try(each.value.resource_group.name, null),
      try(each.value.resource_group_name, null),
      try(var.resource_groups[try(each.value.resource_group.lz_key, var.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name, null)
    ),
    local.resource_group_name
  )
  subnet_id = try(
    each.value.subnet_id,
    var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  )
  settings = merge(
    each.value,
    {
      private_service_connection = merge(
        try(each.value.private_service_connection, {}),
        {
          subresource_names = ["Gateway"]
        }
      )
    }
  )
  global_settings = var.global_settings
  tags            = local.tags
  base_tags       = var.base_tags
  private_dns     = var.private_dns
  client_config   = var.client_config
}
