locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  # Tags for the main NGFW resource
  tags = var.base_tags ? merge(
    try(var.global_settings.tags, {}),
    try(var.resource_group.tags, {}),
    local.module_tag,
    try(var.settings.tags, {})
    ) : merge(
    local.module_tag,
    try(var.settings.tags, {})
  )

  # Location for the NGFW resource
  location = coalesce(var.location, var.resource_group.location)

  # Resource group name for the NGFW resource
  resource_group_name = var.resource_group.name

  # Resolve Virtual Network ID
  virtual_network_id = try(var.settings.network_profile.vnet_configuration.virtual_network_id, null) != null ? var.settings.network_profile.vnet_configuration.virtual_network_id : try(var.remote_objects.virtual_networks[try(var.settings.network_profile.vnet_configuration.virtual_network.lz_key, var.client_config.landingzone_key)][try(var.settings.network_profile.vnet_configuration.virtual_network.key, var.settings.network_profile.vnet_configuration.virtual_network_key)].id, null)

  # Resolve Trusted Subnet ID
  #[try(each.value.vnet.lz_key, local.client_config.landingzone_key)][each.value.vnet.key].subnets[each.value.vnet.subnet_key].id : null
  trusted_subnet_id = try(var.settings.network_profile.vnet_configuration.trusted_subnet_id, null) != null ? var.settings.network_profile.vnet_configuration.trusted_subnet_id : try(var.remote_objects.virtual_networks[try(var.settings.network_profile.vnet_configuration.virtual_network.lz_key, var.client_config.landingzone_key)][try(var.settings.network_profile.vnet_configuration.virtual_network.key, var.settings.network_profile.vnet_configuration.virtual_network_key)].subnets[try(var.settings.network_profile.vnet_configuration.trusted_subnet.key, var.settings.network_profile.vnet_configuration.trusted_subnet_key)].id, null)
  # Resolve Untrusted Subnet ID
  untrusted_subnet_id = try(var.settings.network_profile.vnet_configuration.untrusted_subnet_id, null) != null ? var.settings.network_profile.vnet_configuration.untrusted_subnet_id : try(var.remote_objects.virtual_networks[try(var.settings.network_profile.vnet_configuration.virtual_network.lz_key, var.client_config.landingzone_key)][try(var.settings.network_profile.vnet_configuration.virtual_network.key, var.settings.network_profile.vnet_configuration.virtual_network_key)].subnets[try(var.settings.network_profile.vnet_configuration.untrusted_subnet.key, var.settings.network_profile.vnet_configuration.untrusted_subnet_key)].id, null)


  # Resolve Public IP Address IDs
  resolved_public_ip_address_ids = try(var.settings.network_profile.public_ip_address_ids, null) != null ? var.settings.network_profile.public_ip_address_ids : [
    for key_map in try(var.settings.network_profile.public_ip_address_keys, []) :
    try(var.remote_objects.public_ip_addresses[try(key_map.lz_key, var.client_config.landingzone_key)][key_map.key].id, null)
  ]
  # Filter out any nulls that might result from failed lookups if a key is provided but not found
  final_public_ip_address_ids = [for id in local.resolved_public_ip_address_ids : id if id != null]

  # Settings for the local_rulestack sub-module
  # Ensure that the sub-module also receives necessary context like client_config, global_settings, base_tags, remote_objects
  local_rulestack_module_settings = merge(
    var.settings.local_rulestack,
    {
      # Pass down location and resource_group_name if the sub-module needs them explicitly,
      # or it can derive them from its own var.resource_group and var.location if structured that way.
      # For now, assume sub-module's variables.tf will define how it gets these.
      # If sub-module's `location` is null, it should default to this main module's location.
      location = try(var.settings.local_rulestack.location, local.location)
    }
  )
}
