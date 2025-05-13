resource "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" "palo_alto_ngfw_vnet_local_rulestack" {
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  location            = local.location
  rulestack_id        = module.local_rulestack.id

  dynamic "network_profile" {
    for_each = [var.settings.network_profile] # network_profile is required
    content {
      public_ip_address_ids     = network_profile.value.public_ip_address_ids
      enable_egress_nat         = try(network_profile.value.enable_egress_nat, true) # Default to true as per docs
      egress_nat_ip_address_ids = try(network_profile.value.egress_nat_ip_address_ids, null)

      dynamic "vnet_configuration" {
        for_each = [network_profile.value.vnet_configuration] # vnet_configuration is required
        content {
          virtual_network_id                  = vnet_configuration.value.virtual_network_id
          trusted_address_ranges              = try(vnet_configuration.value.trusted_address_ranges, null)
          ip_of_trust_for_user_defined_routes = try(vnet_configuration.value.ip_of_trust_for_user_defined_routes, null)
        }
      }
    }
  }

  dynamic "dns_settings" {
    for_each = try(var.settings.dns_settings, null) == null ? [] : [var.settings.dns_settings]
    content {
      dns_servers  = try(dns_settings.value.dns_servers, null)
      enable_proxy = try(dns_settings.value.enable_proxy, null)
    }
  }

  marketplace_details {
    offer_id     = var.settings.marketplace_details.offer_id
    publisher_id = var.settings.marketplace_details.publisher_id
    plan_id      = var.settings.marketplace_details.plan_id
  }

  tags = local.tags

  # Note: The provider documentation does not explicitly list 'identity' or 'timeouts' for this resource as of latest check.
  # If they become available, they can be added using dynamic blocks.
}

module "local_rulestack" {
  source = "./local_rulestack"

  settings        = local.local_rulestack_module_settings
  resource_group  = var.resource_group                             # Pass the whole object as sub-module might need .name and .location
  location        = local.local_rulestack_module_settings.location # Explicitly pass location determined in parent's locals
  client_config   = var.client_config
  global_settings = var.global_settings
  base_tags       = var.base_tags
  remote_objects  = var.remote_objects # For diagnostics or other shared resources if sub-module uses them
}
