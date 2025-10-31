# WAF Policy Configuration
# Following Microsoft Best Practices:
# https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/best-practices
#
# Best Practices Implemented:
# 1. Enable Prevention mode after baseline period
# 2. Enable core rule sets (OWASP)
# 3. Enable bot management rules
# 4. Use latest ruleset versions
# 5. Enable comprehensive logging
# 6. Request body inspection enabled
# 7. Geo-filtering for regional restrictions

application_gateway_waf_policies = {
  production_waf_policy = {
    name               = "wafpolicy-cngfw-appgw-production"
    resource_group_key = "networking_rg"

    tags = {
      environment   = "production"
      security_tier = "high"
      compliance    = "owasp-top-10"
      managed_by    = "security-team"
    }

    # Policy Settings
    # Best Practice: Start with Detection mode, then move to Prevention after tuning
    policy_settings = {
      enabled                     = true
      mode                        = "Prevention" # Use "Detection" initially for tuning
      request_body_check          = true         # Enable request body inspection
      file_upload_limit_in_mb     = 100
      max_request_body_size_in_kb = 128
    }

    # Custom Rules
    # Best Practice: Block malicious IPs and implement geo-filtering
    custom_rules = {
      # Rate Limiting Rule
      rate_limit_rule = {
        name      = "RateLimitRule"
        priority  = 10
        rule_type = "RateLimitRule"
        action    = "Block"

        rate_limit_duration_in_minutes = 1
        rate_limit_threshold           = 100

        match_conditions = {
          mc1 = {
            operator           = "IPMatch"
            negation_condition = false
            match_values       = ["0.0.0.0/0"]
            match_variables = {
              mv1 = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      }

      # Geo-filtering Rule - Allow only specific countries
      # Best Practice: Block traffic from unexpected regions
      geo_filter_allow = {
        name      = "GeoFilterAllowList"
        priority  = 20
        rule_type = "MatchRule"
        action    = "Allow"

        match_conditions = {
          mc1 = {
            operator           = "GeoMatch"
            negation_condition = false
            # Add your allowed countries (ISO 3166-1 alpha-2 codes)
            # US = United States, ES = Spain, FR = France, DE = Germany, GB = United Kingdom
            match_values = ["US", "ES", "FR", "DE", "GB", "ZZ"] # ZZ = Unknown location
            match_variables = {
              mv1 = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      }

      # Block known malicious IP ranges
      block_malicious_ips = {
        name      = "BlockMaliciousIPs"
        priority  = 30
        rule_type = "MatchRule"
        action    = "Block"

        match_conditions = {
          mc1 = {
            operator           = "IPMatch"
            negation_condition = false
            # Example malicious IP ranges - replace with your threat intelligence
            match_values = ["192.0.2.0/24", "198.51.100.0/24", "203.0.113.0/24"]
            match_variables = {
              mv1 = {
                variable_name = "RemoteAddr"
              }
            }
          }
        }
      }

      # Block SQL Injection attempts in query strings
      block_sql_injection_querystring = {
        name      = "BlockSQLInjectionQueryString"
        priority  = 40
        rule_type = "MatchRule"
        action    = "Block"

        match_conditions = {
          mc1 = {
            operator           = "Contains"
            negation_condition = false
            match_values = [
              "union select",
              "drop table",
              "insert into",
              "delete from",
              "'; drop",
              "1=1",
              "' or '1'='1"
            ]
            transforms = ["Lowercase", "UrlDecode"]
            match_variables = {
              mv1 = {
                variable_name = "QueryString"
              }
            }
          }
        }
      }

      # Block XSS attempts
      block_xss_attempts = {
        name      = "BlockXSSAttempts"
        priority  = 50
        rule_type = "MatchRule"
        action    = "Block"

        match_conditions = {
          mc1 = {
            operator           = "Contains"
            negation_condition = false
            match_values = [
              "<script",
              "javascript:",
              "onerror=",
              "onload=",
              "eval(",
              "alert("
            ]
            transforms = ["Lowercase", "HtmlEntityDecode", "UrlDecode"]
            match_variables = {
              mv1 = {
                variable_name = "RequestUri"
              }
              mv2 = {
                variable_name = "QueryString"
              }
            }
          }
        }
      }

      # Block suspicious user agents
      block_suspicious_user_agents = {
        name      = "BlockSuspiciousUserAgents"
        priority  = 60
        rule_type = "MatchRule"
        action    = "Block"

        match_conditions = {
          mc1 = {
            operator           = "Contains"
            negation_condition = false
            match_values = [
              "sqlmap",
              "nikto",
              "nmap",
              "masscan",
              "nessus",
              "burpsuite",
              "metasploit"
            ]
            transforms = ["Lowercase"]
            match_variables = {
              mv1 = {
                variable_name = "RequestHeaders"
                selector      = "User-Agent"
              }
            }
          }
        }
      }
    }

    # Managed Rules Configuration
    # Best Practice: Use latest OWASP CRS and Bot Protection rules
    managed_rules = {
      # Exclusions for known false positives
      # Best Practice: Create exclusions to reduce false positives
      exclusions = {
        # Exclude specific cookies that may trigger false positives
        exclude_session_cookie = {
          match_variable          = "RequestCookieNames"
          selector                = "ASP.NET_SessionId"
          selector_match_operator = "Equals"
        }

        # Exclude specific headers
        exclude_auth_header = {
          match_variable          = "RequestHeaderNames"
          selector                = "Authorization"
          selector_match_operator = "Equals"
        }

        # Exclude specific query string parameters
        exclude_search_param = {
          match_variable          = "RequestArgNames"
          selector                = "search"
          selector_match_operator = "Equals"
        }
      }

      # OWASP Core Rule Set
      # Best Practice: Enable latest OWASP CRS version
      managed_rule_set = {
        # OWASP 3.2 - Latest stable version with best protection
        owasp_3_2 = {
          type    = "OWASP"
          version = "3.2" # Use latest available version

          # Fine-tune specific rule groups
          rule_group_override = {
            # Protocol Enforcement
            protocol_enforcement = {
              rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
              # Disable specific rules that cause false positives
              # disabled_rules = [
              #   "920300", # Request Missing Accept Header
              #   "920440"  # URL file extension is restricted by policy
              # ]
            }

            # SQL Injection Protection
            sql_injection = {
              rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
              # All rules enabled for maximum protection
            }

            # XSS Protection
            xss_protection = {
              rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
              # All rules enabled for maximum protection
            }

            # Remote File Inclusion
            rfi_protection = {
              rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
              # All rules enabled
            }

            # Session Fixation
            session_fixation = {
              rule_group_name = "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"
              # All rules enabled
            }
          }
        }

        # Microsoft Bot Manager Rules
        # Best Practice: Enable bot protection to identify and block bad bots
        bot_protection = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"

          rule_group_override = {
            bad_bots = {
              rule_group_name = "BadBots"
              # Block all bad bots
            }

            good_bots = {
              rule_group_name = "GoodBots"
              # Allow good bots (search engines, monitoring tools)
            }

            unknown_bots = {
              rule_group_name = "UnknownBots"
              # Configure based on your requirements
              # disabled_rules = ["300"] # Optionally allow unknown bots
            }
          }
        }
      }
    }
  }

  # Optional: Separate WAF policy for non-production environments
  # with more permissive rules for testing
  staging_waf_policy = {
    name               = "wafpolicy-cngfw-appgw-staging"
    resource_group_key = "networking_rg"

    tags = {
      environment   = "staging"
      security_tier = "medium"
    }

    policy_settings = {
      enabled                     = true
      mode                        = "Detection" # Detection mode for staging
      request_body_check          = true
      file_upload_limit_in_mb     = 100
      max_request_body_size_in_kb = 128
    }

    managed_rules = {
      managed_rule_set = {
        owasp_3_2 = {
          type    = "OWASP"
          version = "3.2"
        }

        bot_protection = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"
        }
      }
    }
  }
}
