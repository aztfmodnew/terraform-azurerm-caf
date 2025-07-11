cdn_frontdoor_profiles = {
  static_website = {
    name               = "fd-static-website"
    location           = "global"
    resource_group_key = "static_website"
    sku_name           = "Standard_AzureFrontDoor"

    response_timeout_seconds = 120

    # Main endpoint for the website
    endpoints = {
      main = {
        name    = "static-website-endpoint"
        enabled = true
        tags = {
          purpose = "static website endpoint"
        }
      }
    }

    # Origin group for the Storage Account
    origin_groups = {
      storage_origin_group = {
        name                     = "storage-origin-group"
        session_affinity_enabled = false

        load_balancing = {
          additional_latency_in_milliseconds = 50
          sample_size                        = 4
          successful_samples_required        = 3
        }

        health_probe = {
          interval_in_seconds = 100
          path                = "/"
          protocol            = "Https"
          request_type        = "HEAD"
        }
      }
    }

    # Origin pointing to the Storage Account static website
    origins = {
      storage_origin = {
        name             = "storage-static-website"
        origin_group_key = "storage_origin_group"
        storage_account = {
          key = "static_website"
        }
        certificate_name_check_enabled = true
        enabled                        = true
        http_port                      = 80
        https_port                     = 443
        priority                       = 1
        weight                         = 1000
      }
    }

    # Rule set for cache optimization
    rule_sets = {
      cache_optimization = {
        name = "cache-optimization-rules"
      }
    }

    # Cache rules for different content types
    rules = {
      # Rule for static content (CSS, JS, images)
      static_content_cache = {
        name         = "static-content-cache"
        rule_set_key = "cache_optimization"
        order        = 1

        conditions = [{
          request_uri_condition = [{
            operator         = "Contains"
            negate_condition = false
            match_values     = [".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".ico", ".svg", ".woff", ".woff2"]
            transforms       = ["Lowercase"]
          }]
        }]

        actions = [{
          route_configuration_override_action = {
            origin_group_key              = "storage_origin_group"
            forwarding_protocol           = "HttpsOnly"
            cache_behavior                = "OverrideAlways"
            cache_duration                = "7.00:00:00" # Cache for 7 days
            query_string_caching_behavior = "IgnoreQueryString"
          }
        }]
      }

      # Rule for HTML (shorter cache)
      html_content_cache = {
        name         = "html-content-cache"
        rule_set_key = "cache_optimization"
        order        = 2

        conditions = [{
          request_uri_condition = [{
            operator         = "EndsWith"
            negate_condition = false
            match_values     = [".html", "/"]
            transforms       = ["Lowercase"]
          }]
        }]

        actions = [{
          route_configuration_override_action = {
            origin_group_key              = "storage_origin_group"
            forwarding_protocol           = "HttpsOnly"
            cache_behavior                = "OverrideAlways"
            cache_duration                = "01:00:00" # Cache for 1 hour
            query_string_caching_behavior = "IgnoreQueryString"
          }
        }]
      }

      # Rule for security headers
      security_headers = {
        name         = "security-headers"
        rule_set_key = "cache_optimization"
        order        = 3

        conditions = [{
          request_method_condition = [{
            operator         = "Equal"
            negate_condition = false
            match_values     = ["GET", "HEAD"]
          }]
        }]

        actions = [{
          response_header_action = [
            {
              header_action = "Append"
              header_name   = "X-Content-Type-Options"
              value         = "nosniff"
            },
            {
              header_action = "Append"
              header_name   = "X-Frame-Options"
              value         = "DENY"
            },
            {
              header_action = "Append"
              header_name   = "X-XSS-Protection"
              value         = "1; mode=block"
            },
            {
              header_action = "Append"
              header_name   = "Strict-Transport-Security"
              value         = "max-age=31536000; includeSubDomains"
            },
            {
              header_action = "Append"
              header_name   = "Referrer-Policy"
              value         = "strict-origin-when-cross-origin"
            }
          ]
        }]
      }
    }

    # Main route for the website
    routes = {
      main_route = {
        name                = "main-website-route"
        endpoint_key        = "main"
        origin_group_key    = "storage_origin_group"
        supported_protocols = ["Http", "Https"]
        patterns_to_match   = ["/*"]
        forwarding_protocol = "HttpsOnly"

        # Specify origins explicitly
        origin_ids = ["storage_origin"]

        # Associate optimization rules
        rule_set_keys = ["cache_optimization"]

        # Default cache configuration
        cache = {
          query_string_caching_behavior = "IgnoreQueryString"
          compression_enabled           = true
          content_types_to_compress = [
            "application/javascript",
            "application/json",
            "application/xml",
            "text/css",
            "text/html",
            "text/javascript",
            "text/plain",
            "text/xml"
          ]
        }
      }
    }

    # Diagnostics configuration for monitoring
    diagnostic_profiles = {
      central_logs_region1 = {
        definition_key   = "cdn_frontdoor_profile"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

    tags = {
      purpose = "static website cdn"
      tier    = "standard"
    }
  }
}
