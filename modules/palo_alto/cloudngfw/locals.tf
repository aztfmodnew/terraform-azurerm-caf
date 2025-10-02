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

  # Build per-rule maps for DNAT entries when `destination_nat` is provided as a map in examples.
  # For each key in var.settings.destination_nat we attempt to resolve frontend PIP id and backend IP.
  dnat_frontend_public_ip_ids = {
    for k, v in try(var.settings.destination_nat, {}) : k => (
      // prefer explicit id, then key lookup into remote_objects
      try(v.frontend_config.public_ip_address_id, null) != null ? try(v.frontend_config.public_ip_address_id, null) : (
        try(v.frontend_config.public_ip_address_key, null) != null ? try(var.remote_objects.public_ip_addresses[try(v.frontend_config.lz_key, var.client_config.landingzone_key)][v.frontend_config.public_ip_address_key].id, null) : null
      )
    )
  }

  dnat_backend_ips = {
    for k, v in try(var.settings.destination_nat, {}) : k => coalesce(
      try(v.backend_config.public_ip_address, null),
      try(v.backend_config.private_ip_address, null),
      # Try resolving VM private IP from remote_objects first, before fallback
      # The VM private_ip_address output is a map (nic_key => ip), so get the first value
      (
        try(v.backend_config.virtual_machine.vm_key, null) != null ?
        try(values(var.remote_objects.virtual_machines[try(v.backend_config.virtual_machine.lz_key, var.client_config.landingzone_key)][v.backend_config.virtual_machine.vm_key].private_ip_address)[0], null) :
        null
      ),
      # Only use fallback after trying to resolve VM IP
      try(v.backend_config.fallback_private_ip, null),
      null
    )
  }

  # Resolve egress NAT IP address IDs from keys or use direct IDs
  resolved_egress_nat_ip_address_ids = try(var.settings.network_profile.egress_nat_ip_address_ids, null) != null ? var.settings.network_profile.egress_nat_ip_address_ids : [
    for key_map in try(var.settings.network_profile.egress_nat_ip_address_keys, []) :
    try(var.remote_objects.public_ip_addresses[try(key_map.lz_key, var.client_config.landingzone_key)][key_map.key].id, null)
  ]
  # Filter out any nulls that might result from failed lookups if a key is provided but not found
  final_egress_nat_ip_address_ids = [for id in local.resolved_egress_nat_ip_address_ids : id if id != null]

  # Normalized management_mode: lowercase and trim to avoid accidental mismatches
  management_mode_normalized = trimspace(lower(coalesce(try(var.settings.management_mode, null), "")))

  # Settings for the local_rulestack sub-module.
  # To avoid inconsistent conditional result types we always produce a map here.
  # Consumers can check management mode if they only want to act when it's actually 'rulestack'.
  local_rulestack_module_settings = merge(
    try(var.settings.local_rulestack, {}),
    { location = try(var.settings.local_rulestack.location, local.location) }
  )
}
