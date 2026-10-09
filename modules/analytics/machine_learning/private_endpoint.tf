module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  tags            = local.tags
  base_tags       = try(var.global_settings.inherit_tags, false)
  client_config   = var.client_config
  global_settings = var.global_settings
  location = coalesce(
    try(each.value.location, null),
    try(var.resource_groups[try(each.value.resource_group.lz_key, var.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location, null),
    local.location
  )
  name        = each.value.name
  private_dns = var.private_dns
  resource_group_name = coalesce(
    try(each.value.resource_group.name, null),
    try(each.value.resource_group_name, null),
    try(var.resource_groups[try(each.value.resource_group.lz_key, var.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name, null),
    local.resource_group_name
  )
  resource_id = azurerm_machine_learning_workspace.ws.id
  settings = merge(
    each.value,
    {
      private_service_connection = try(
        merge(
          each.value.private_service_connection,
          {
            subresource_names = coalesce(
              try(each.value.private_service_connection.subresource_names, null),
              ["amlworkspace"]
            )
          }
        ),
        { subresource_names = ["amlworkspace"] }
      )
    }
  )
  subnet_id = try(coalesce(
    try(each.value.subnet_id, null),
    var.vnets[
      try(each.value.subnet.lz_key, each.value.lz_key, var.client_config.landingzone_key)
      ][
      try(each.value.subnet.vnet_key, each.value.vnet_key)
      ].subnets[
      try(each.value.subnet.key, each.value.subnet_key)
    ].id
  ), null)
}
