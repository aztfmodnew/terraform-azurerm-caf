#
# Managed identities from remote state
# This resource (azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack)
# does not currently support a direct 'identity' block in the Terraform provider.
# This file is included for consistency with the module structure.
# If the resource later supports managed identities, this local can be used.
#

locals {
  # Example structure if identity were supported:
  # managed_local_identities = flatten([
  #   for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
  #     var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
  #   ]
  # ])

  # managed_remote_identities = flatten([
  #   for lz_key, value in try(var.settings.identity.remote, []) : [
  #     for managed_identity_key in value.managed_identity_keys : [
  #       var.remote_objects.managed_identities[lz_key][managed_identity_key].id
  #     ]
  #   ]
  # ])

  # managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)
  managed_identities = [] # Placeholder as not currently supported by the resource
}
