resource "azurerm_route_server" "route_server" {
  name                = azurecaf_name.route_server.result
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = try(var.settings.sku, "Standard")
  tags                = local.tags

  # Subnet lookup: try specialsubnets first (where RouteServerSubnet is typically defined), then subnets
  subnet_id = coalesce(
    try(var.settings.subnet_id, null),
    try(var.remote_objects.virtual_networks[local.route_server_vnet_lz_key][local.route_server_vnet_key].specialsubnets[local.route_server_subnet_key].id, null),
    try(var.remote_objects.virtual_networks[local.route_server_vnet_lz_key][local.route_server_vnet_key].subnets[local.route_server_subnet_key].id, null)
  )

  public_ip_address_id = coalesce(
    try(var.settings.public_ip_address_id, null),
    try(var.remote_objects.public_ip_addresses[local.route_server_vnet_lz_key][local.public_ip_key].id, null),
    try(var.remote_objects.public_ip_addresses[var.client_config.landingzone_key][local.public_ip_key].id, null)
  )

  # Optional attributes
  branch_to_branch_traffic_enabled = try(var.settings.branch_to_branch_traffic_enabled, false)
  hub_routing_preference           = try(var.settings.hub_routing_preference, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
