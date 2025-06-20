resource_groups = {
  caf_frontdoor_rg = {
    name     = "caf-frontdoor-rg"
    location = "westeurope"
  }
}

cdn_frontdoor_profiles = {
  full = {
    name               = "caf-frontdoor-full"
    location           = "westeurope"
    resource_group_key = "caf_frontdoor_rg"
    sku_name           = "Premium_AzureFrontDoor"
    custom_domains = {
      domain1 = {
        name      = "caf-custom-domain"
        host_name = "myapp.example.com"
      }
    }
    endpoints = {
      endpoint1 = {
        name    = "caf-endpoint1"
        enabled = true
      }
    }
    origin_groups = {
      og1 = {
        name                     = "caf-og1"
        session_affinity_enabled = true
        load_balancing = {
          additional_latency_in_milliseconds = 0
          sample_size                        = 4
          successful_samples_required        = 3
        }
        health_probe = {
          interval_in_seconds = 120
          protocol            = "Https"
        }
      }
    }
    origins = {
      origin1 = {
        name                           = "caf-origin1"
        cdn_frontdoor_origin_group_key = "og1"
        host_name                      = "myapp-backend.example.com"
        certificate_name_check_enabled = false
      }
    }
    rule_sets = {
      ruleset1 = {
        name = "caf-ruleset1"
      }
    }
    rules = {
      rule1 = {
        name                       = "caf-rule1"
        cdn_frontdoor_rule_set_key = "ruleset1"
        order                      = 1
        actions = [{
          route_configuration_override_action = {
            cdn_frontdoor_origin_group_key = "og1"
            forwarding_protocol            = "HttpsOnly"
          }
        }]
      }
    }
    secrets = {
      secret1 = {
        name = "caf-secret1"
        secret = {
          customer_certificate = {
            key_vault_certificate_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv/certificates/cert1"
          }
        }
      }
    }
    security_policies = {
      policy1 = {
        name = "caf-policy1"
        security_policies = [{
          firewall = {
            cdn_frontdoor_firewall_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Cdn/profiles/profile1/firewallPolicies/policy1"
            association = [{
              domain = [{
                cdn_frontdoor_domain_key = "domain1"
              }]
              patterns_to_match = ["/*"]
            }]
          }
        }]
      }
    }
    custom_domain_associations = {
      assoc1 = {
        cdn_frontdoor_custom_domain_key = "domain1"
        cdn_frontdoor_route_keys        = ["route1"]
      }
    }
    # Agrega más configuraciones según sea necesario
  }
}
