# This module creates a Palo Alto Next Generation Firewall in Azure using the local rulestack deployment mode.
resource "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" "palo_alto_ngfw_vnet_local_rulestack" {
  count                = var.settings.attachment_type == "vnet" && var.settings.management_mode == "rulestack" ? 1 : 0
  name                 = var.settings.name
  resource_group_name  = local.resource_group_name
  rulestack_id         = module.local_rulestack.id
  marketplace_offer_id = try(var.settings.marketplace_offer_id, "pan_swfw_cloud_ngfw")
  plan_id              = try(var.settings.plan_id, "panw-cloud-ngfw-payg")

  dynamic "network_profile" {
    for_each = [var.settings.network_profile] # network_profile is required
    content {
      public_ip_address_ids     = local.final_public_ip_address_ids # Use resolved IDs      
      egress_nat_ip_address_ids = try(network_profile.value.egress_nat_ip_address_ids, null)
      trusted_address_ranges    = try(network_profile.value.trusted_address_ranges, null)
      dynamic "vnet_configuration" {
        for_each = [network_profile.value.vnet_configuration] # vnet_configuration is required
        content {
          virtual_network_id  = local.virtual_network_id  # Use resolved ID
          trusted_subnet_id   = local.trusted_subnet_id   # Use resolved ID
          untrusted_subnet_id = local.untrusted_subnet_id # Use resolved ID
        }
      }
    }
  }
  dynamic "destination_nat" {
    for_each = try(var.settings.destination_nat, null) == null ? [] : [var.settings.destination_nat]
    content {
      name     = try(destination_nat.value.name, null)
      protocol = try(lower(destination_nat.value.protocol), null) == "tcp" || try(lower(destination_nat.value.protocol), null) == "udp" ? lower(destination_nat.value.protocol) : null
      dynamic "backend_config" {
        for_each = try(destination_nat.value.backend_config, null) == null ? [] : [destination_nat.value.backend_config]
        content {
          public_ip_address = try(backend_config.value.public_ip_address, null)
          port              = try(backend_config.value.port, null)
        }
      }
      dynamic "frontend_config" {
        for_each = try(destination_nat.value.frontend_config, null) == null ? [] : [destination_nat.value.frontend_config]
        content {
          public_ip_address_id = contains(local.final_public_ip_address_ids, try(frontend_config.value.public_ip_address_id, null)) ? try(frontend_config.value.public_ip_address_id, null) : null
          port                 = try(frontend_config.value.port, null)
        }
      }
    }
  }


  dynamic "dns_settings" {
    for_each = try(var.settings.dns_settings, null) == null ? [] : [var.settings.dns_settings]
    content {
      dns_servers   = try(dns_settings.value.dns_servers, null)
      use_azure_dns = try(dns_settings.value.use_azure_dns, null)
    }
  }

  tags = local.tags

  # Note: The provider documentation does not explicitly list 'identity' or 'timeouts' for this resource as of latest check.
  # If they become available, they can be added using dynamic blocks.
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

module "local_rulestack" {
  source = "../local_rulestack"

  settings        = local.local_rulestack_module_settings
  resource_group  = var.resource_group                             # Pass the whole object as sub-module might need .name and .location
  location        = local.local_rulestack_module_settings.location # Explicitly pass location determined in parent's locals
  client_config   = var.client_config
  global_settings = var.global_settings
  base_tags       = var.base_tags
  remote_objects  = var.remote_objects # For diagnostics or other shared resources if sub-module uses them
}

resource "azurerm_palo_alto_next_generation_firewall_virtual_network_panorama" "palo_alto_ngfw_vnet_panorama" {
  count               = var.settings.attachment_type == "vnet" && var.settings.management_mode == "panorama" ? 1 : 0
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  location            = local.location


  plan_id                = try(var.settings.plan_id, "panw-cloud-ngfw-payg")
  marketplace_offer_id   = try(var.settings.marketplace_offer_id, "pan_swfw_cloud_ngfw")
  panorama_base64_config = try(var.settings.panorama_base64_config, null)

  dynamic "network_profile" {
    for_each = [var.settings.network_profile] # network_profile is required
    content {
      public_ip_address_ids     = local.final_public_ip_address_ids # Use resolved IDs      
      egress_nat_ip_address_ids = try(network_profile.value.egress_nat_ip_address_ids, null)
      trusted_address_ranges    = try(network_profile.value.trusted_address_ranges, null)
      dynamic "vnet_configuration" {
        for_each = [network_profile.value.vnet_configuration] # vnet_configuration is required
        content {
          virtual_network_id  = local.virtual_network_id  # Use resolved ID
          trusted_subnet_id   = local.trusted_subnet_id   # Use resolved ID
          untrusted_subnet_id = local.untrusted_subnet_id # Use resolved ID
        }
      }
    }
  }
  dynamic "destination_nat" {
    for_each = try(var.settings.destination_nat, null) == null ? [] : [var.settings.destination_nat]
    content {
      name     = try(destination_nat.value.name, null)
      protocol = try(lower(destination_nat.value.protocol), null) == "tcp" || try(lower(destination_nat.value.protocol), null) == "udp" ? lower(destination_nat.value.protocol) : null
      dynamic "backend_config" {
        for_each = try(destination_nat.value.backend_config, null) == null ? [] : [destination_nat.value.backend_config]
        content {
          public_ip_address = try(backend_config.value.public_ip_address, null)
          port              = try(backend_config.value.port, null)
        }
      }
      dynamic "frontend_config" {
        for_each = try(destination_nat.value.frontend_config, null) == null ? [] : [destination_nat.value.frontend_config]
        content {
          public_ip_address_id = contains(local.final_public_ip_address_ids, try(frontend_config.value.public_ip_address_id, null)) ? try(frontend_config.value.public_ip_address_id, null) : null
          port                 = try(frontend_config.value.port, null)
        }
      }
    }
  }

  dynamic "dns_settings" {
    for_each = try(var.settings.dns_settings, null) == null ? [] : [var.settings.dns_settings]
    content {
      dns_servers   = try(dns_settings.value.dns_servers, null)
      use_azure_dns = try(dns_settings.value.use_azure_dns, null)
    }
  }

  tags = local.tags


  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_palo_alto_virtual_network_appliance" "palo_alto_virtual_network_appliance" {
  count          = var.settings.attachment_type == "vwan" ? 1 : 0
  name           = var.settings.name
  virtual_hub_id = var.settings.virtual_hub_id
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }

}

