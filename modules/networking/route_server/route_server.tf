resource "azurerm_route_server" "route_server" {
  name                = azurecaf_name.route_server.result
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = try(var.settings.sku, "Standard")
  tags                = local.tags

  subnet_id = coalesce(
    try(var.settings.subnet_id, null),
    try(var.remote_objects.virtual_networks[local.route_server_vnet_lz_key][local.route_server_vnet_key].subnets[local.route_server_subnet_key].id, null)
  )

  public_ip_address_id = coalesce(
    try(var.settings.public_ip_address_id, null),
    try(var.remote_objects.public_ip_addresses[local.route_server_vnet_lz_key][local.public_ip_key].id, null),
    try(var.remote_objects.public_ip_addresses[var.client_config.landingzone_key][local.public_ip_key].id, null)
  )
}
