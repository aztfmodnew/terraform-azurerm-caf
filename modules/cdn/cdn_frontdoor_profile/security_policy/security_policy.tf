# security_policy.tf
# azurerm_cdn_frontdoor_security_policy resource implementation

resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  name = azurecaf_name.security_policy.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = coalesce(
        try(var.settings.security_policies.firewall.cdn_frontdoor_firewall_policy_id, null),
        try(var.remote_objects.cdn_frontdoor_firewall_policies[var.settings.security_policies.firewall.firewall_policy_key].id, null),
        try(var.remote_objects.cdn_frontdoor_firewall_policies[try(var.settings.security_policies.firewall.cdn_frontdoor_firewall_policy.lz_key, var.client_config.landingzone_key)][var.settings.security_policies.firewall.cdn_frontdoor_firewall_policy.key].id, null)
      )

      dynamic "association" {
        for_each = try(var.settings.security_policies.firewall.association, [])
        content {
          dynamic "domain" {
            for_each = try(association.value.domain, [])
            content {
              cdn_frontdoor_domain_id = coalesce(
                try(domain.value.cdn_frontdoor_domain_id, null),
                try(var.remote_objects.cdn_frontdoor_endpoints[domain.value.cdn_frontdoor_endpoint.key].id, null),
                try(var.remote_objects.cdn_frontdoor_custom_domains[try(domain.value.cdn_frontdoor_custom_domain.lz_key, var.client_config.landingzone_key)][domain.value.cdn_frontdoor_custom_domain.key].id, null),
                try(var.remote_objects.cdn_frontdoor_endpoints[try(domain.value.cdn_frontdoor_endpoint.lz_key, var.client_config.landingzone_key)][domain.value.cdn_frontdoor_endpoint.key].id, null)
              )
            }
          }

          patterns_to_match = association.value.patterns_to_match
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
