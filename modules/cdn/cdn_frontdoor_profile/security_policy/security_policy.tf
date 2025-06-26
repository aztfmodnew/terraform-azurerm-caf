# security_policy.tf
# azurerm_cdn_frontdoor_security_policy resource implementation

resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = var.settings.cdn_frontdoor_profile_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = var.settings.security_policies.firewall.cdn_frontdoor_firewall_policy_id

      association {
        dynamic "domain" {
          for_each = try(var.settings.security_policies.firewall.association.domain, [])
          content {
            cdn_frontdoor_domain_id = domain.value.cdn_frontdoor_domain_id
          }
        }

        patterns_to_match = try(var.settings.security_policies.firewall.association.patterns_to_match, ["/*"])
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
