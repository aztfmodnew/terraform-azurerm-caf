global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  grafana_rg = {
    name = "grafana-test-1"
  }
}


grafana = {
  grafana_complete = {
    name                              = "grafana-complete-test"
    grafana_major_version             = 11
    sku                               = "Standard"
    api_key_enabled                   = true
    deterministic_outbound_ip_enabled = true
    public_network_access_enabled     = false
    zone_redundancy_enabled           = true

    resource_group = {
      # accepts either id or key to get resource group id
      # id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourceGroup1"
      # lz_key = "examples"
      key = "grafana_rg"
    }

    identity = {
      type = "SystemAssigned"
    }

    # SMTP configuration (optional)
    smtp = {
      enabled                   = true
      host                      = "smtp.example.com:587"
      user                      = "grafana@example.com"
      password                  = "SecurePassword123!"
      start_tls_policy          = "OpportunisticStartTLS"
      from_address              = "grafana@example.com"
      from_name                 = "Contoso Grafana"
      verification_skip_enabled = false
    }

    # Private endpoints configuration
    private_endpoints = {
      pe1 = {
        name               = "grafana-pe1"
        vnet_key           = "vnet1"
        subnet_key         = "private_endpoints"
        resource_group_key = "grafana_rg"

        tags = {
          networking = "private endpoint"
        }

        private_service_connection = {
          name                 = "grafana-psc"
          is_manual_connection = false
          subresource_names    = ["grafana"]
        }

        private_dns = {
          zone_group_name = "privatelink.grafana.azure.com"
          keys            = ["grafana_dns"]
        }
      }
    }

    # Diagnostic profiles (optional)
    diagnostic_profiles = {
      central_logs = {
        name = "central-logs"
        # Configure diagnostics destination here
      }
    }

    tags = {
      environment = "production"
      purpose     = "monitoring"
      managed_by  = "terraform"
    }
  }
}

# Virtual Network configuration for private endpoints
vnets = {
  vnet1 = {
    resource_group_key = "grafana_rg"
    vnet = {
      name          = "grafana-vnet"
      address_space = ["172.33.0.0/16"]
    }
  }
}

# Subnet configuration
virtual_subnets = {
  subnet1 = {
    name              = "default"
    cidr              = ["172.33.1.0/24"]
    nsg_key           = "empty_nsg"
    service_endpoints = ["Microsoft.Dashboard"]
    vnet = {
      # id = "/subscriptions/xxxx-xxxx-xxxx-xxx/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet"
      # lz_key = ""
      key = "vnet1"
    }
  }
  private_endpoints = {
    name                              = "private-endpoints"
    cidr                              = ["172.33.2.0/24"]
    private_endpoint_network_policies = "Enabled"
    vnet = {
      # id = "/subscriptions/xxxx-xxxx-xxxx-xxx/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet"
      # lz_key = ""
      key = "vnet1"
    }
  }
}

# Network Security Group definition
network_security_group_definition = {
  # This entry is applied to all subnets with no NSG defined
  empty_nsg = {
    nsg = []
  }
}

# Private DNS configuration for Grafana
private_dns = {
  grafana_dns = {
    name               = "privatelink.grafana.azure.com"
    resource_group_key = "grafana_rg"

    tags = {
      resource = "private dns"
    }

    vnet_links = {
      vnlk1 = {
        name = "grafana-vnet-link"
        # lz_key   = ""
        vnet_key = "vnet1"
        tags = {
          net_team = "monitoring"
        }
      }
    }
  }
}
