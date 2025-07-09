cdn_frontdoor_profiles = {
  full = {
    name               = "caf-frontdoor-full"
    location           = "westeurope"
    resource_group_key = "cdn_rg"
    sku_name           = "Premium_AzureFrontDoor"

    # Enable managed identity for secure Key Vault access
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["cdn_identity"]
    }

    custom_domains = {
      domain1 = {
        name      = "caf-custom-domain"
        host_name = "myapp.example.com"
        tls = {
          certificate_type         = "CustomerCertificate"
          minimum_tls_version      = "TLS12"
          cdn_frontdoor_secret_key = "secret1" # Reference to the certificate secret
        }
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
        origin_group_key               = "og1"
        host_name                      = "myapp-backend.example.com"
        certificate_name_check_enabled = false
      }
    }
    rule_sets = {
      ruleset1 = {
        name = "cafruleset1"
      }
    }
    rules = {
      rule1 = {
        name         = "cafrule1"
        rule_set_key = "ruleset1"
        order        = 1
        actions = [{
          route_configuration_override_action = {
            origin_group_key              = "og1"
            forwarding_protocol           = "HttpsOnly"
            cache_behavior                = "HonorOrigin"
            query_string_caching_behavior = "IgnoreQueryString"
          }
        }]
      }
    }

    # Routes to associate custom domains with endpoints
    routes = {
      route1 = {
        name                = "caf-route1"
        endpoint_key        = "endpoint1"
        origin_group_key    = "og1"
        supported_protocols = ["Http", "Https"]
        patterns_to_match   = ["/*"]
        forwarding_protocol = "HttpsOnly"

        # Associate with custom domain
        custom_domain_keys = ["domain1"]

        # Specify origin IDs explicitly
        origin_ids = ["origin1"]

        # Associate rule set to apply rules to this route
        rule_set_keys = ["ruleset1"]

        cache = {
          query_string_caching_behavior = "IgnoreQueryString"
          compression_enabled           = true
          content_types_to_compress = [
            "application/javascript",
            "application/json",
            "text/css",
            "text/html",
            "text/javascript",
            "text/plain"
          ]
        }
      }
    }

    secrets = {
      secret1 = {
        name = "caf-secret1"
        secret = {
          customer_certificate = {
            certificate_request = {
              key = "cdn_certificate"
              # lz_key = "remote_lz"  # Optional for remote landing zone
            }
          }
        }
      }
    }
    # Agrega más configuraciones según sea necesario
  }
}
