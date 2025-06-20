# security_policy.tf
# Placeholder for azurerm_cdn_frontdoor_security_policy resource implementation
resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  name                     = var.settings.name
  cdn_frontdoor_profile_id = var.remote_objects.cdn_frontdoor_profile_id

  dynamic "security_policies" {
    for_each = try(var.settings.security_policies, [])
    content {
      firewall {
        cdn_frontdoor_firewall_policy_id = security_policies.value.cdn_frontdoor_firewall_policy_id

        dynamic "association" {
          for_each = try(security_policies.value.association, [])
          content {
            dynamic "domain" {
              for_each = try(association.value.domain, [])
              content {
                cdn_frontdoor_domain_id = domain.value.cdn_frontdoor_domain_id
              }
            }

            patterns_to_match = try(association.value.patterns_to_match, ["/*"])
          }
        }
      }
    }
  }
}
