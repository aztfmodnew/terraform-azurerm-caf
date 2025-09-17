# WAF Policy Configuration for Azure Bot Protection
application_gateway_waf_policies = {
  bot_waf_policy = {
    name               = "secure-bot-waf-policy"
    resource_group_key = "networking_rg"

    # Policy Settings
    policy_settings = {
      enabled                     = true
      mode                        = "Prevention" # Change to "Detection" for testing
      request_body_check          = true
      file_upload_limit_in_mb     = 10
      max_request_body_size_in_kb = 128
    }

    # Custom Rules for Bot Protection
    custom_rules = {
      # Allow specific IP ranges (adjust according to your requirements)
      allow_trusted_ips = {
        name      = "AllowTrustedIPs"
        priority  = 1
        rule_type = "MatchRule"
        action    = "Allow"
        match_conditions = {
          trusted_ips = {
            operator           = "IPMatch"
            negation_condition = false
            match_values = [
              "203.0.113.0/24", # Example: Your office IP range
              "198.51.100.0/24" # Example: Your data center IP range
            ]
            match_variables = {
              remote_addr = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      },

      # Block known malicious IP ranges
      block_malicious_ips = {
        name      = "BlockMaliciousIPs"
        priority  = 10
        rule_type = "MatchRule"
        action    = "Block"
        match_conditions = {
          malicious_ips = {
            operator           = "IPMatch"
            negation_condition = false
            match_values = [
              "192.0.2.0/24",     # Example: Known malicious IP range
              "198.51.100.100/32" # Example: Specific blocked IP
            ]
            match_variables = {
              remote_addr = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      },

      # Block requests with suspicious user agents
      block_suspicious_agents = {
        name      = "BlockSuspiciousUserAgents"
        priority  = 20
        rule_type = "MatchRule"
        action    = "Block"
        match_conditions = {
          suspicious_agents = {
            operator           = "Contains"
            negation_condition = false
            match_values = [
              "sqlmap",
              "nikto",
              "nmap",
              "masscan",
              "dirbuster"
            ]
            match_variables = {
              user_agent = {
                variable_name = "RequestHeaders"
                selector      = "User-Agent"
              }
            }
            transforms = ["Lowercase"]
          }
        }
      },

      # Geo-blocking rule (block requests from specific countries)
      geo_blocking = {
        name      = "GeoBlocking"
        priority  = 30
        rule_type = "MatchRule"
        action    = "Block"
        match_conditions = {
          blocked_countries = {
            operator           = "GeoMatch"
            negation_condition = false
            match_values = [
              "CN", # China
              "RU", # Russia
              "KP"  # North Korea
            ]
            match_variables = {
              remote_addr = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      },

      # Block requests with large query strings (potential DoS)
      block_large_query_strings = {
        name      = "BlockLargeQueryStrings"
        priority  = 40
        rule_type = "MatchRule"
        action    = "Block"
        match_conditions = {
          large_query = {
            operator           = "GreaterThan"
            negation_condition = false
            match_values       = ["2048"] # 2KB limit for query strings
            match_variables = {
              query_string = {
                variable_name = "QueryString"
              }
            }
          }
        }
      }
    }

    # Managed Rule Sets
    managed_rules = {
      # Global exclusions for Bot Framework traffic
      exclusions = {
        bot_framework_headers = {
          match_variable          = "RequestHeaderNames"
          selector                = "Authorization"
          selector_match_operator = "Equals"
        },
        bot_connector_headers = {
          match_variable          = "RequestHeaderNames"
          selector                = "MsConversationId"
          selector_match_operator = "Equals"
        },
        activity_id_headers = {
          match_variable          = "RequestHeaderNames"
          selector                = "X-MsBot-ActivityId"
          selector_match_operator = "Equals"
        },
        conversation_headers = {
          match_variable          = "RequestHeaderNames"
          selector                = "X-MsBot-ConversationId"
          selector_match_operator = "Equals"
        }
      }

      # OWASP Core Rule Set
      managed_rule_set = {
        owasp_crs = {
          type    = "OWASP"
          version = "3.2"

          # Rule Group Overrides
          rule_group_override = {
            # Allow some SQL-like patterns in bot messages
            sql_injection_protection = {
              rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
              disabled_rules = [
                "942100", # SQL Injection Attack Detected via libinjection
                "942110"  # SQL Injection Attack: Common Injection Testing Detected
              ]
            },

            # Allow some XSS-like patterns in bot conversations
            xss_protection = {
              rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
              disabled_rules = [
                "941100", # XSS Attack Detected via libinjection
                "941110"  # XSS Filter - Category 1: Script Tag Vector
              ]
            },

            # Protocol enforcement adjustments for bot framework
            protocol_enforcement = {
              rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
              disabled_rules = [
                "920300", # Request Missing an Accept Header
                "920440"  # URL file extension is restricted by policy
              ]
            }
          }
        },

        # Microsoft Bot Protection Rule Set
        bot_protection = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "0.1"
        }
      }
    }

    tags = {
      service     = "waf"
      purpose     = "bot-protection"
      environment = "production"
      compliance  = "security-required"
    }
  }
}
