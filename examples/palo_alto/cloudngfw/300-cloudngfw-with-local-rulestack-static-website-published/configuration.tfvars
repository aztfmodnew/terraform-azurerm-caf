# Palo Alto Cloud NGFW with Local Rulestack and Static Website Example - Hub and Spoke Architecture
# This example demonstrates:
# 1. Hub and Spoke network architecture with Palo Alto Cloud NGFW as the central hub
# 2. Static website hosted on Azure Storage Account in a spoke network
# 3. Centralized security inspection through NGFW for all traffic flows
# 4. Secure connectivity between hub (NGFW) and spoke (static website) networks
# 5. Traffic routing and security policies managed centrally in the hub

# Architecture Overview:
# ┌─────────────────────────────────────────────────────────────────────┐
# │                           HUB NETWORK                               │
# │  ┌─────────────────────────────────────────────────────────────┐   │
# │  │                 Palo Alto Cloud NGFW                       │   │
# │  │  Management: 10.100.1.0/24                                 │   │
# │  │  Trust:      10.100.2.0/24                                 │   │
# │  │  Untrust:    10.100.3.0/24                                 │   │
# │  └─────────────────────────────────────────────────────────────┘   │
# │                              │                                      │
# │                    VNet Peering / Transit                           │
# │                              │                                      │
# └──────────────────────────────┼──────────────────────────────────────┘
#                                │
# ┌──────────────────────────────┼──────────────────────────────────────┐
# │                         SPOKE NETWORK                               │
# │  ┌─────────────────────────────────────────────────────────────┐   │
# │  │              Static Website Services                        │   │
# │  │  Backend:    10.200.1.0/24                                 │   │
# │  │  Storage:    Azure Storage Account (Static Website)        │   │
# │  └─────────────────────────────────────────────────────────────┘   │
# └─────────────────────────────────────────────────────────────────────┘

resource_groups = {
  # Hub resource group for centralized security services
  hub_ngfw_rg = {
    name     = "hub-ngfw-security-rg"
    location = "westeurope"
    tags = {
      purpose = "Hub Network Security"
      tier    = "hub"
    }
  }
  # Spoke resource group for static website workloads
  spoke_storage_rg = {
    name     = "spoke-staticweb-workload-rg"
    location = "westeurope"
    tags = {
      purpose = "Spoke Static Website"
      tier    = "spoke"
    }
  }
}

vnets = {
  # HUB NETWORK - Central security and transit hub
  hub_ngfw_vnet = {
    resource_group_key = "hub_ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    vnet = {
      name          = "vnet-hub-ngfw-security"
      address_space = ["10.100.0.0/16"]
    }
    subnets = {
      # NGFW Management subnet for firewall administration
      snet_management = {
        name    = "snet-ngfw-mgmt"
        cidr    = ["10.100.1.0/24"]
        nsg_key = "hub_mgmt_nsg"
      }
      # Trust subnet for internal traffic from spokes
      snet_trust = {
        name    = "snet-ngfw-trust"
        cidr    = ["10.100.2.0/24"]
        nsg_key = "hub_trust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }
      # Untrust subnet for internet-facing traffic
      snet_untrust = {
        name    = "snet-ngfw-untrust"
        cidr    = ["10.100.3.0/24"]
        nsg_key = "hub_untrust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }
      # Transit subnet for hub-to-spoke routing
      snet_transit = {
        name    = "snet-hub-transit"
        cidr    = ["10.100.4.0/24"]
        nsg_key = "hub_transit_nsg"
      }
    }
    tags = {
      purpose = "Hub Network - NGFW Security"
      tier    = "hub"
    }
  }

  # SPOKE NETWORK - Static website workload
  spoke_storage_vnet = {
    resource_group_key = "spoke_storage_rg"
    location           = "westeurope"
    vnet = {
      name          = "vnet-spoke-staticweb"
      address_space = ["10.200.0.0/16"]
    }
    subnets = {
      # Backend subnet for storage services with service endpoints
      snet_backend = {
        name    = "snet-backend-services"
        cidr    = ["10.200.1.0/24"]
        nsg_key = "spoke_backend_nsg"
        service_endpoints = [
          "Microsoft.Storage"
        ]
      }
      # Web subnet for potential web-tier services
      snet_web = {
        name    = "snet-web-tier"
        cidr    = ["10.200.2.0/24"]
        nsg_key = "spoke_web_nsg"
      }
    }
    tags = {
      purpose = "Spoke Network - Static Website"
      tier    = "spoke"
    }
  }
}

public_ip_addresses = {
  ngfw_pip_management = {
    name               = "pip-ngfw-mgmt"
    resource_group_key = "hub_ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    allocation_method  = "Static"
    sku                = "Standard"
    tags = {
      purpose = "NGFW Management PIP"
    }
  }
  ngfw_pip_dataplane1 = {
    name               = "pip-ngfw-dp1"
    resource_group_key = "hub_ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    allocation_method  = "Static"
    sku                = "Standard"
    tags = {
      purpose = "NGFW Dataplane PIP for Static Website"
    }
  }
}

# VNet Peering configuration for Hub and Spoke architecture
vnet_peerings = {
  # Hub to Spoke peering
  hub_to_spoke_peering = {
    name = "hub-to-spoke-staticweb"
    from = {
      vnet_key = "hub_ngfw_vnet"
    }
    to = {
      vnet_key = "spoke_storage_vnet"
    }
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true # Allow traffic forwarding through hub
    allow_gateway_transit        = true # Hub acts as gateway for spokes
    use_remote_gateways          = false
  }

  # Spoke to Hub peering
  spoke_to_hub_peering = {
    name = "spoke-to-hub-staticweb"
    from = {
      vnet_key = "spoke_storage_vnet"
    }
    to = {
      vnet_key = "hub_ngfw_vnet"
    }
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true # Allow traffic to be forwarded to hub
    allow_gateway_transit        = false
    use_remote_gateways          = false # No gateway available in hub VNet
  }
}

network_security_group_definition = {
  # Hub Network Security Groups
  hub_mgmt_nsg = {
    nsg = [
      {
        name                       = "AllowSSHFromAdmin"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.0.0/8" # Adjust to your admin network
        destination_address_prefix = "*"
      }
    ]
  }
  hub_trust_nsg = {
    nsg = [
      {
        name                       = "AllowFromSpokes"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.0.0/16" # Spoke networks
        destination_address_prefix = "*"
      }
    ]
  }
  hub_untrust_nsg = {
    nsg = [
      {
        name                       = "AllowHTTP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPS"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
  hub_transit_nsg = {
    nsg = [
      {
        name                       = "AllowTransitTraffic"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.0.0.0/8" # Private networks
        destination_address_prefix = "*"
      }
    ]
  }

  # Spoke Network Security Groups
  spoke_backend_nsg = {
    nsg = [
      {
        name                       = "AllowHTTPFromHub"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPSFromHub"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      }
    ]
  }
  spoke_web_nsg = {
    nsg = [
      {
        name                       = "AllowWebTraffic"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443"]
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      }
    ]
  }
}

# Storage Account for Static Website
storage_accounts = {
  static_website_storage = {
    name                     = "ststaticweb" # Note: Will be made unique by CAF naming
    resource_group_key       = "spoke_storage_rg"
    location                 = "westeurope"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"

    # Configure blob properties
    blob_properties = {
      versioning_enabled  = false
      change_feed_enabled = false
      delete_retention_policy = {
        days = 7
      }
      container_delete_retention_policy = {
        days = 7
      }
      cors_rule = {
        allowed_origins    = ["*"]
        allowed_methods    = ["GET", "HEAD", "OPTIONS"]
        allowed_headers    = ["*"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    }

    # Network access rules to allow access from spoke backend subnet
    network_rules = {
      default_action = "Allow" # Allow for initial setup - can be restricted later
      ip_rules       = []
      virtual_network_subnet_ids = [
        # Allow access from spoke backend subnet with service endpoints
        {
          virtual_network_key = "spoke_storage_vnet"
          subnet_key          = "snet_backend"
        }
      ]
    }

    tags = {
      purpose     = "Static Website Hosting"
      environment = "example"
      tier        = "spoke"
    }
  }
}

# Palo Alto Cloud NGFW Configuration
palo_alto_cloudngfws = {
  static_website_ngfw = {
    name               = "pangfw-staticweb-example"
    resource_group_key = "hub_ngfw_rg" // Key of the resource group defined above
    attachment_type    = "vnet"        // or "vwan" depending on your architecture
    management_mode    = "rulestack"   // or "panorama" depending on your architecture
    # location            = "westeurope" # Optional, will inherit from resource_group if not specified
    plan_id              = "panw-cngfw-payg"
    marketplace_offer_id = "pan_swfw_cloud_ngfw"

    network_profile = {
      vnet_configuration = {
        virtual_network_key = "hub_ngfw_vnet" // Key of the VNet defined above
        // The Palo Alto NGFW module might require specific subnet keys or roles to be identified.
        // For example, if the module expects keys like 'management_subnet_key', 'trust_subnet_key', etc.
        // you would add them here, mapping to the subnet keys defined in virtual_networks.ngfw_vnet.subnets.
        // This depends on how the Palo Alto module is designed to consume subnet information.
        // For now, we assume the module can derive necessary subnets from the virtual_network_key
        // or that specific subnet IDs are not explicitly required at this top level of vnet_configuration.
        // If direct subnet IDs are needed by the resource, the module would need to be adapted
        // to look them up from the VNet object using these keys.

        trusted_subnet_key   = "snet_trust"   // Key of the trusted subnet defined above
        untrusted_subnet_key = "snet_untrust" // Key of the untrusted subnet defined above
        // If the module requires specific subnet IDs, you can also provide them here
        // trusted_subnet_id   = "subnet-trust-id"
        // untrusted_subnet_id = "subnet-untrust-id"
      }
      public_ip_address_keys = [
        {
          # lz_key is optional and can be used to specify the landing zone key
          # lz_key = "my_landingzone" # Optional, if the PIP is in a different landing zone
          key = "ngfw_pip_management" # Keys of PIPs defined above
        },
        {
          # lz_key = "my_landingzone"
          key = "ngfw_pip_dataplane1"
        },
        # Add more PIPs if needed
        # {
        #   lz_key = "another_landingzone"
        #   key    = "some_other_pip_key"
        # }
      ] // Keys of PIPs defined above
      enable_egress_nat = true

      # Configure egress NAT IP address for outbound traffic
      egress_nat_ip_address_keys = [
        {
          key = "ngfw_pip_dataplane1" # Use dataplane IP for egress NAT
        }
      ]
    }

    local_rulestack = {
      name        = "localrules-staticweb-example"
      description = "Local rulestack for static website protection with Palo Alto NGFW."
      # location    = "westeurope" # Optional, will inherit from the NGFW if not specified

      # Security rules to allow static website traffic
      rules = {
        # Rule to allow inbound HTTPS traffic for DNAT (Azure Storage only supports HTTPS)
        "allow-inbound-https" = {
          priority     = 1001
          action       = "Allow"
          applications = ["ssl"]
          description  = "Allow inbound HTTPS traffic for static website DNAT to Azure Storage"
          enabled      = true

          source = {
            cidrs = ["0.0.0.0/0"] # Allow from any source
          }

          destination = {
            cidrs = ["10.200.1.100/32"] # Internal backend service IP
          }

          protocol_ports = ["TCP:443"]
        }

        # Rule to allow outbound traffic from backend to Azure Storage (HTTPS only)
        "allow-outbound-storage" = {
          priority     = 2000
          action       = "Allow"
          applications = ["ssl"]
          description  = "Allow outbound HTTPS traffic from backend to Azure Storage"
          enabled      = true

          source = {
            cidrs = ["10.200.0.0/16"] # Spoke network
          }

          destination = {
            cidrs = ["0.0.0.0/0"] # Allow to any destination (Azure Storage endpoints)
          }

          protocol_ports = ["TCP:443"]
        }
      }
    }

    # DNAT Configuration for Static Website (HTTPS only - Azure Storage requirement)
    # Redirects external HTTPS traffic to internal backend service which proxies to Azure Storage
    destination_nat = {
      name     = "dnat-static-website-https"
      protocol = "TCP"

      # Frontend configuration - External access point (firewall's dataplane public IP)
      frontend_config = {
        public_ip_address_key = "ngfw_pip_dataplane1"
        port                  = "443" # HTTPS port (required for Azure Storage)
      }

      # Backend configuration - Internal service that will proxy to Azure Storage
      backend_config = {
        public_ip_address = "20.60.88.104" # Internal IP in spoke backend subnet
        port              = "443"          # Direct HTTPS port (no proxy needed)
      }
    }

    # DNS Configuration for proper name resolution
    dns_settings = {
      use_azure_dns = true
    }

    # Timeouts for firewall operations
    timeouts = {
      create = "30m"
      update = "30m"
      read   = "5m"
      delete = "30m"
    }

    tags = {
      environment = "example"
      cost_center = "it"
      purpose     = "static-website-protection"
    }
  }
}

# Static Website Configuration (Modern approach using separate module)
storage_account_static_websites = {
  static_website_config = {
    resource_group_key = "spoke_storage_rg"
    storage_account = {
      key = "static_website_storage"
    }
    index_document     = "index.html"
    error_404_document = "404.html"

    tags = {
      purpose = "Static Website Hosting"
      tier    = "spoke"
    }
  }
}
