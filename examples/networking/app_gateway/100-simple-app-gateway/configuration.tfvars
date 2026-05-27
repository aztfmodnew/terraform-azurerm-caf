global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
  inherit_tags = true
  tags = {
    example = "app_gateway/100-simple-app-gateway"
  }
}


resource_groups = {
  agw_region1 = {
    name   = "example-agw"
    region = "region1"
  }
}

application_gateways = {
  agw1 = {
    resource_group_key = "agw_region1"
    name               = "app_gateway_example"
    vnet_key           = "vnet_region1"
    subnet_key         = "app-gateway-subnet"
    sku_name           = "WAF_v2"
    sku_tier           = "WAF_v2"
    waf_policy = {
      key = "waf1"
    }
    capacity = {
      autoscale = {
        minimum_scale_unit = 0
        maximum_scale_unit = 10
      }
    }
    zones        = ["1"]
    enable_http2 = true
    tags = {
      project = "demo"
    }

    front_end_ip_configurations = {
      public = {
        name          = "public"
        public_ip_key = "example_agw_pip1_rg1"
        #subnet_id = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/vupf-rg-example-agw/providers/Microsoft.Network/virtualNetworks/vupf-vnet-app_gateway_vnet/subnets/vupf-snet-app_gateway_subnet"
        #public_ip_id = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/vupf-rg-example-agw/providers/Microsoft.Network/publicIPAddresses/vupf-pip-example_agw_pip1"
      }
      private = {
        name       = "private"
        vnet_key   = "vnet_region1"
        subnet_key = "app-gateway-subnet"
        #subnet_id                     = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/vupf-rg-example-agw/providers/Microsoft.Network/virtualNetworks/vupf-vnet-app_gateway_vnet/subnets/vupf-snet-app_gateway_subnet"
        #subnet_cidr                   = "10.100.100.0/25"
        subnet_cidr_index             = 0 # It is possible to have more than one cidr block per subnet
        private_ip_offset             = 4 # e.g. cidrhost(10.10.0.0/25,4) = 10.10.0.4 => AGW private IP address
        private_ip_address_allocation = "Static"
      }
    }

    front_end_ports = {
      80 = {
        name     = "http"
        port     = 80
        protocol = "Http"
      }
      443 = {
        name     = "https"
        port     = 443
        protocol = "Https"
      }
    }

  }
}

vnets = {
  vnet_region1 = {
    resource_group_key = "agw_region1"
    vnet = {
      name          = "app_gateway_vnet"
      address_space = ["10.100.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      app-gateway-subnet = {
        name    = "app_gateway_subnet"
        cidr    = ["10.100.100.0/25"]
        nsg_key = "application_gateway"
      }
    }

  }
}

public_ip_addresses = {
  example_agw_pip1_rg1 = {
    name                    = "example_agw_pip1"
    resource_group_key      = "agw_region1"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    zones                   = ["1"]
    idle_timeout_in_minutes = "4"

  }
}

application_gateway_waf_policies = {
  waf1 = {
    name               = "example-waf-policy"
    resource_group_key = "agw_region1"

    tags = {
      project = "demo"
    }

    policy_settings = {
      enabled                     = true
      mode                        = "Prevention"
      request_body_check          = true
      file_upload_limit_in_mb     = 100
      max_request_body_size_in_kb = 128
    }

    managed_rules = {
      exclusions = {
        exc1 = {
          match_variable          = "RequestHeaderNames"
          selector_match_operator = "Equals"
          selector                = "SomeHeader"
        }
      }

      managed_rule_set = {
        owasp = {
          type    = "OWASP"
          version = "3.2"
          rule_group_override = {
            general = {
              rule_group_name = "General"
              rules = {
                r200004 = {
                  id      = "200004"
                  enabled = false
                }
              }
            }
            scanner_detection = {
              rule_group_name = "REQUEST-913-SCANNER-DETECTION"
              rules = {
                r913102 = {
                  id      = "913102"
                  enabled = false
                }
              }
            }
            lfi = {
              rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
            }
          }
        }
      }
    }
  }
}
