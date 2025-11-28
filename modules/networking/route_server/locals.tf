locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = var.base_tags ? merge(
    try(var.global_settings.tags, null),
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags, null)
  )

  location            = coalesce(var.location, try(var.resource_group.location, null))
  resource_group_name = try(var.resource_group.name, null)

  route_server_vnet_lz_key = try(var.settings.lz_key, var.client_config.landingzone_key)
  route_server_vnet_key    = try(var.settings.vnet_key, null)
  route_server_subnet_key  = try(var.settings.subnet_key, null)
  public_ip_key            = try(var.settings.public_ip_key, null)
}
