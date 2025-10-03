# Palo Alto Cloud NGFW with Local Rulestack, Static Website, and Virtual Machine Example
# This example demonstrates:
# 1. Hub and Spoke network architecture with Palo Alto Cloud NGFW as the central hub
# 2. Static website hosted on Azure Storage Account in a spoke network
# 3. Linux virtual machine with web server in the spoke network
# 4. Centralized security inspection through NGFW for all traffic flows
# 5. Secure connectivity between hub (NGFW) and spoke (static website + VM) networks
# 6. Traffic routing and security policies managed centrally in the hub
# 7. DNAT configuration for external access to both static website and VM services

# Architecture Overview:
# ┌─────────────────────────────────────────────────────────────────────┐
# │                           HUB NETWORK                               │
# │  ┌─────────────────────────────────────────────────────────────┐   │
# │  │                 Palo Alto Cloud NGFW                       │   │
# │  │  Management: 10.100.1.0/24                                 │   │
# │  │  Trust:      10.100.2.0/24  ← Traffic Inspection          │   │
# │  │  Untrust:    10.100.3.0/24  ← Internet Access             │   │
# │  └─────────────────────────────────────────────────────────────┘   │
# │                              │                                      │
# │                    VNet Peering / Transit                           │
# │                              │                                      │
# └──────────────────────────────┼──────────────────────────────────────┘
#                                │
# ┌──────────────────────────────┼──────────────────────────────────────┐
# │                         SPOKE NETWORK                               │
# │  ┌─────────────────────────────────────────────────────────────┐   │
# │  │              Workload Services                              │   │
# │  │  Backend:    10.200.1.0/24  ← Azure Storage (Static Web)   │   │
# │  │  Web Tier:   10.200.2.0/24  ← Reserved for web services    │   │
# │  │  VM Subnet:  10.200.3.0/24  ← Linux VM with Nginx          │   │
# │  └─────────────────────────────────────────────────────────────┘   │
# │                                                                     │
# │  External Access through NGFW:                                     │
# │  • Static Website:  NGFW_IP:443 → Storage Private Endpoint         │
# │  • VM SSH Access:   NGFW_IP:2022 → VM:22                          │
# │  • VM HTTP:         NGFW_IP:8080 → VM:80                          │
# │  • VM HTTPS:        NGFW_IP:8443 → VM:443                         │
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
      # Backend subnet for storage services, now configured for Private Endpoints
      snet_backend = {
        name                                      = "snet-backend-services"
        cidr                                      = ["10.200.1.0/24"]
        nsg_key                                   = "spoke_backend_nsg"
        route_table_key                           = "backend_subnet_rt"
        private_endpoint_network_policies_enabled = true
        # Disable default outbound access to make this a private subnet for private endpoints
        default_outbound_access_enabled = false
      }
      # Web subnet for potential web-tier services
      snet_web = {
        name    = "snet-web-tier"
        cidr    = ["10.200.2.0/24"]
        nsg_key = "spoke_web_nsg"
      }
      # Virtual Machine subnet for compute workloads
      snet_vm = {
        name            = "snet-vm-workload"
        cidr            = ["10.200.3.0/24"]
        nsg_key         = "spoke_vm_nsg"
        route_table_key = "vm_subnet_rt"
      }
    }
    tags = {
      purpose = "Spoke Network - Static Website and VM Workloads"
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
      },
      {
        name                       = "AllowSSHDNAT"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "2022"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPDNAT"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPSDNAT"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8443"
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
        destination_port_range     = "80"
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPSTraffic"
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
  spoke_vm_nsg = {
    nsg = [
      {
        name                       = "AllowSSHFromHub"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPFromHub"
        priority                   = 1001
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
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.100.0.0/16" # Hub network
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowOutboundToInternet"
        priority                   = 1000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
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

    # Network access rules to allow access via Private Endpoint
    public_network_access_enabled = false
    network_rules = {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      ip_rules                   = []
      virtual_network_subnet_ids = []
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
      description = "Local rulestack for static website and VM protection with Palo Alto NGFW - Rules target NGFW public IP for DNAT processing."
      # location    = "westeurope" # Optional, will inherit from the NGFW if not specified

      # Security rules to allow traffic to NGFW public IP for DNAT processing
      rules = {
        # Rule to allow inbound HTTPS traffic to NGFW public IP for static website DNAT
        "allow-inbound-https" = {
          priority     = 1001
          action       = "Allow"
          applications = ["ssl"]
          description  = "Allow inbound HTTPS traffic to NGFW public IP for static website DNAT"
          enabled      = true

          source = {
            cidrs = ["0.0.0.0/0"] # Allow from any source
          }

          destination = {
            public_ip_address_keys = ["ngfw_pip_dataplane1"] # Target NGFW public IP specifically
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

        # VM ACCESS RULES - SSH and web traffic to NGFW public IP for DNAT processing
        "allow-inbound-ssh-vm" = {
          priority     = 1100
          action       = "Allow"
          applications = ["ssh"]
          description  = "Allow inbound SSH traffic to NGFW public IP for VM access via DNAT"
          enabled      = true

          source = {
            cidrs = ["0.0.0.0/0"] # Allow from any source
          }

          destination = {
            public_ip_address_keys = ["ngfw_pip_dataplane1"] # Target NGFW public IP specifically
          }

          protocol_ports = ["TCP:2022"] # Custom SSH port for DNAT
        }

        "allow-inbound-http-vm" = {
          priority     = 1101
          action       = "Allow"
          applications = ["web-browsing"]
          description  = "Allow inbound HTTP traffic to NGFW public IP for VM web services via DNAT"
          enabled      = true

          source = {
            cidrs = ["0.0.0.0/0"] # Allow from any source
          }

          destination = {
            public_ip_address_keys = ["ngfw_pip_dataplane1"] # Target NGFW public IP specifically
          }

          protocol_ports = ["TCP:8080"] # Custom HTTP port for DNAT
        }

        "allow-inbound-https-vm" = {
          priority     = 1102
          action       = "Allow"
          applications = ["ssl"]
          description  = "Allow inbound HTTPS traffic to NGFW public IP for VM web services via DNAT"
          enabled      = true

          source = {
            cidrs = ["0.0.0.0/0"] # Allow from any source
          }

          destination = {
            public_ip_address_keys = ["ngfw_pip_dataplane1"] # Target NGFW public IP specifically
          }

          protocol_ports = ["TCP:8443"] # Custom HTTPS port for DNAT
        }

        # VM outbound traffic rules
        "allow-outbound-vm-internet" = {
          priority     = 2100
          action       = "Allow"
          applications = ["any"]
          description  = "Allow outbound internet traffic from VM subnet"
          enabled      = true

          source = {
            cidrs = ["10.200.3.0/24"] # VM subnet
          }

          destination = {
            cidrs = ["0.0.0.0/0"] # Allow to any destination
          }

          protocol_ports = ["any"]
        }

        # VM to spoke network communication
        "allow-vm-to-spoke" = {
          priority     = 2200
          action       = "Allow"
          applications = ["any"]
          description  = "Allow communication between VM and other spoke services"
          enabled      = true

          source = {
            cidrs = ["10.200.3.0/24"] # VM subnet
          }

          destination = {
            cidrs = ["10.200.0.0/16"] # Entire spoke network
          }

          protocol_ports = ["any"]
        }
      }
    }

    # DNAT Configuration for Static Website (HTTPS only - Azure Storage requirement)
    # Redirects external HTTPS traffic to private endpoint IP (automatically resolved)
    destination_nat = {
      # Static Website DNAT
      "dnat-static-website-https" = {
        name     = "dnat-static-website-https"
        protocol = "TCP"

        # Frontend configuration - External access point (firewall's dataplane public IP)
        frontend_config = {
          public_ip_address_key = "ngfw_pip_dataplane1"
          port                  = "443" # HTTPS port (required for Azure Storage)
        }

        # Backend configuration - Private endpoint IP (automatically resolved from private endpoint)
        backend_config = {
          private_endpoint = {
            vnet_key         = "spoke_storage_vnet"
            subnet_key       = "snet_backend"
            resource_type    = "storage_accounts"
            resource_key     = "static_website_storage"
            subresource_name = "blob"
          }
          # Temporary fallback until dynamic remote_objects path is confirmed.
          # Replace with resolved dynamic IP or remove after verifying private_endpoints structure.
          fallback_private_ip = "10.200.1.4"
          port                = "443"
        }
      }

      # VM DNAT RULES - SSH and web access through NGFW
      "dnat-vm-ssh" = {
        name     = "dnat-vm-ssh"
        protocol = "TCP"

        # Frontend configuration - SSH access via NGFW dataplane IP on port 2022
        frontend_config = {
          public_ip_address_key = "ngfw_pip_dataplane1"
          port                  = "2022" # Custom SSH port to avoid conflicts
        }

        # Backend configuration - VM private IP (dynamically resolved)
        backend_config = {
          virtual_machine = {
            vm_key = "spoke_web_vm"
            # Will resolve to VM's primary NIC private IP
          }
          # Fallback static IP configuration
          fallback_private_ip = "10.200.3.10" # Expected VM IP in VM subnet
          port                = "22"          # Standard SSH port on VM
        }
      }

      "dnat-vm-http" = {
        name     = "dnat-vm-http"
        protocol = "TCP"

        # Frontend configuration - HTTP access via NGFW dataplane IP on port 8080
        frontend_config = {
          public_ip_address_key = "ngfw_pip_dataplane1"
          port                  = "8080" # Custom HTTP port to avoid conflicts
        }

        # Backend configuration - VM private IP (dynamically resolved)
        backend_config = {
          virtual_machine = {
            vm_key = "spoke_web_vm"
            # Will resolve to VM's primary NIC private IP
          }
          # Fallback static IP configuration
          fallback_private_ip = "10.200.3.10" # Expected VM IP in VM subnet
          port                = "80"          # Standard HTTP port on VM
        }
      }

      "dnat-vm-https" = {
        name     = "dnat-vm-https"
        protocol = "TCP"

        # Frontend configuration - HTTPS access via NGFW dataplane IP on port 8443
        frontend_config = {
          public_ip_address_key = "ngfw_pip_dataplane1"
          port                  = "8443" # Custom HTTPS port to avoid conflicts
        }

        # Backend configuration - VM private IP (dynamically resolved)
        backend_config = {
          virtual_machine = {
            vm_key = "spoke_web_vm"
            # Will resolve to VM's primary NIC private IP
          }
          # Fallback static IP configuration
          fallback_private_ip = "10.200.3.10" # Expected VM IP in VM subnet
          port                = "443"         # Standard HTTPS port on VM
        }
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

# ========================================
# TESTING INSTRUCTIONS - DNAT FUNCTIONALITY
# ========================================
#
# After deployment, get the dynamic values from Terraform outputs:
#
# STEP 1: Get deployment-specific values
#    NGFW_IP=$(terraform output -raw objects | jq -r '.public_ip_addresses.ngfw_pip_dataplane1.ip_address')
#    STORAGE_NAME=$(terraform output -raw objects | jq -r '.storage_accounts.static_website_storage.name')
#    STORAGE_WEB_URL=$(terraform output -raw objects | jq -r '.storage_accounts.static_website_storage.primary_web_endpoint')
#    PE_IP=$(terraform output -raw objects | jq -r '.private_endpoints.spoke_storage_vnet.subnet.snet_backend.storage_account.static_website_storage.pep.blob.private_service_connection[0].private_ip_address')
#
# STEP 2: Display values for verification
#    echo "NGFW Public IP: $NGFW_IP"
#    echo "Storage Account: $STORAGE_NAME"
#    echo "Storage Web URL: $STORAGE_WEB_URL"
#    echo "Private Endpoint IP: $PE_IP"
#
# STEP 3: Run connectivity tests
#
# 1. BASIC CONNECTIVITY TEST (should show SSL handshake + HTTP 400):
#    curl -k -v --connect-timeout 10 https://$NGFW_IP/
#
#    Expected result: SSL connection established, HTTP 400 Bad Request (hostname invalid)
#    This confirms DNAT is working - traffic reaches the backend Storage Account
#
# 2. PROPER HOSTNAME TEST (with blob endpoint):
#    curl -k -v -H "Host: $STORAGE_NAME.blob.core.windows.net" https://$NGFW_IP/
#
#    Expected result: HTTP 400 with Azure Storage error (InvalidQueryParameterValue)
#    This confirms backend Storage Account is responding
#
# 3. STATIC WEBSITE TEST (with web endpoint):
#    WEB_HOST=$(echo $STORAGE_WEB_URL | sed 's|https://||' | sed 's|/||')
#    curl -k -v -H "Host: $WEB_HOST" https://$NGFW_IP/
#
#    Expected result:
#    - If content exists: HTTP 200 + HTML content
#    - If no content: HTTP 400 InvalidUri (still confirms DNAT working)
#
# 4. PORT SCAN TEST (validate which ports are open):
#    nmap -p 80,443 $NGFW_IP
#
#    Expected result: Port 443 open, port 80 filtered/closed
#
# 5. DIAGNOSTIC SCRIPT (comprehensive validation - edit script with current values):
#    # Update script variables first:
#    sed -i "s/NGFW_PUBLIC_IP=\".*\"/NGFW_PUBLIC_IP=\"$NGFW_IP\"/" ./examples/borrame/diagnose_static_site.sh
#    sed -i "s/STORAGE_ACCOUNT=\".*\"/STORAGE_ACCOUNT=\"$STORAGE_NAME\"/" ./examples/borrame/diagnose_static_site.sh
#    sed -i "s/PE_IP=\".*\"/PE_IP=\"$PE_IP\"/" ./examples/borrame/diagnose_static_site.sh
#    # Run diagnostic
#    ./examples/borrame/diagnose_static_site.sh
#
# ALTERNATIVE: ONE-LINER TEST COMMAND
#    NGFW_IP=$(terraform output -raw objects | jq -r '.public_ip_addresses.ngfw_pip_dataplane1.ip_address') && \
#    STORAGE_NAME=$(terraform output -raw objects | jq -r '.storage_accounts.static_website_storage.name') && \
#    echo "Testing DNAT: $NGFW_IP -> $STORAGE_NAME" && \
#    curl -k -v --connect-timeout 10 https://$NGFW_IP/
#
# BROWSER TESTING:
#    echo "For browser testing, use: https://$NGFW_IP"
#    echo "Note: You'll see SSL certificate warnings - this is expected"
#    echo "You should reach the Azure Storage backend (may show errors, but confirms DNAT works)"
#
# TROUBLESHOOTING:
# - Connection timeout = NGFW security rules blocking (check destination = 0.0.0.0/0)
# - SSL errors = Certificate mismatch (use -k flag or proper hostname)
# - HTTP 400 = Normal for Azure Storage without proper hostname/path
# - HTTP 404 = Missing static website content in $web container
# - "terraform output" fails = Run from correct directory with deployed state
#
# CRITICAL CONFIGURATION NOTES:
# - NGFW security rules MUST use destination = "0.0.0.0/0" for DNAT
# - Security rules are evaluated BEFORE DNAT translation
# - Private Endpoint IP is resolved dynamically via CAF remote_objects
# - Storage Account public access should be disabled for security
# - IP addresses and URLs change with each deployment - always use terraform outputs
#
# ========================================

# Private DNS and Private Endpoint Configuration for Static Website Storage
private_dns = {
  blob_private_dns_zone = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "spoke_storage_rg"
  }
}

private_dns_vnet_links = {
  hub_vnet_link = {
    vnet_key = "hub_ngfw_vnet"

    private_dns_zones = {
      blob_zone = {
        name                 = "hub-vnet-link"
        key                  = "blob_private_dns_zone"
        registration_enabled = false
      }
    }
  }
  spoke_vnet_link = {
    vnet_key = "spoke_storage_vnet"

    private_dns_zones = {
      blob_zone = {
        name                 = "spoke-vnet-link"
        key                  = "blob_private_dns_zone"
        registration_enabled = false
      }
    }
  }
}

private_endpoints = {
  spoke_storage_vnet = {
    vnet_key           = "spoke_storage_vnet"
    subnet_keys        = ["snet_backend"]
    resource_group_key = "spoke_storage_rg"

    storage_accounts = {
      static_website_storage = {
        private_service_connection = {
          name              = "psc-static-website-storage"
          subresource_names = ["blob"]
        }
        private_dns = {
          zone_group_name = "default"
          keys            = ["blob_private_dns_zone"]
        }
      }
    }
  }
}

# ========================================
# VIRTUAL MACHINE CONFIGURATION
# ========================================
# Linux Virtual Machine in spoke network for web application workloads
# Configured with proper networking, security, and CNGFW integration

# Virtual Machine Configuration
virtual_machines = {
  spoke_web_vm = {
    resource_group_key = "spoke_storage_rg"
    provision_vm_agent = true

    # Use Azure managed storage for boot diagnostics
    boot_diagnostics_storage_account_key = "vm_bootdiag_storage"

    os_type = "linux"

    # SSH key management through Key Vault
    keyvault_key = "spoke_vm_keyvault"

    # Auto-shutdown schedule for cost optimization
    shutdown_schedule = {
      enabled               = true
      daily_recurrence_time = "2200" # 10 PM
      timezone              = "UTC"
      notification_settings = {
        enabled         = false
        time_in_minutes = "30"
        # webhook_url   = "https://example.com/webhook"  # Optional - enable and set when needed
      }
    }

    networking_interfaces = {
      nic0 = {
        vnet_key                = "spoke_storage_vnet"
        subnet_key              = "snet_vm"
        primary                 = true
        name                    = "0"
        enable_ip_forwarding    = false
        internal_dns_name_label = "spokevmnic0"
      }
    }

    virtual_machine_settings = {
      linux = {
        name                            = "spoke-web-vm"
        size                            = "Standard_B2s" # Cost-effective for web workloads
        admin_username                  = "azureuser"
        disable_password_authentication = true

        # Custom data for web server setup
        custom_data = <<CUSTOM_DATA
#!/bin/bash
# Update system
apt-get update -y

# Install nginx web server
apt-get install -y nginx

# Create simple web page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Spoke VM Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #2E86AB; color: white; padding: 20px; border-radius: 5px; }
        .content { margin: 20px 0; }
        .info { background: #F5F5F5; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ Spoke VM Web Server</h1>
        <p>Virtual Machine in Spoke Network behind Palo Alto Cloud NGFW</p>
    </div>
    <div class="content">
        <h2>VM Information</h2>
        <div class="info">
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>IP Address:</strong> $(hostname -I)</p>
            <p><strong>Date:</strong> $(date)</p>
            <p><strong>Uptime:</strong> $(uptime)</p>
        </div>
        <h2>Network Architecture</h2>
        <p>This virtual machine is deployed in the spoke network (10.200.0.0/16) and all traffic flows through the Palo Alto Cloud NGFW in the hub network (10.100.0.0/16) for security inspection.</p>
        <h2>Access</h2>
        <p>External access is provided through DNAT configuration on the NGFW, routing traffic from the public IP to this VM's private IP.</p>
    </div>
</body>
</html>
EOF

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Configure nginx for both HTTP and HTTPS
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Restart nginx to apply configuration
systemctl restart nginx

# Install firewall and configure it
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable

echo "VM setup completed successfully" > /tmp/setup-complete.log
CUSTOM_DATA

        # Use Standard priority (non-Spot) for better availability
        priority   = "Regular"
        patch_mode = "ImageDefault"

        # Network interface configuration
        network_interface_keys = ["nic0"]

        os_disk = {
          name                 = "spoke-web-vm-os"
          caching              = "ReadWrite"
          storage_account_type = "Premium_LRS" # Better performance for web server
        }

        # System-assigned managed identity for Azure services access
        identity = {
          type = "SystemAssigned"
        }

        # Use latest Ubuntu LTS image
        source_image_reference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-focal"
          sku       = "20_04-lts-gen2"
          version   = "latest"
        }
      }
    }

    # Optional data disk for application data
    data_disks = {
      data1 = {
        name                 = "spoke-web-vm-data1"
        storage_account_type = "Premium_LRS"
        create_option        = "Empty"
        disk_size_gb         = "32"
        lun                  = 1
      }
    }
  }
}

# Key Vault for VM SSH keys and secrets
keyvaults = {
  spoke_vm_keyvault = {
    name                        = "spokevm-kv"
    resource_group_key          = "spoke_storage_rg"
    sku_name                    = "standard"
    soft_delete_enabled         = true
    purge_protection_enabled    = true
    enabled_for_disk_encryption = true
    tags = {
      purpose = "VM SSH Keys and Secrets"
    }
    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
        key_permissions    = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge"]
      }
    }
  }
}

# Boot diagnostics storage account for VM
diagnostic_storage_accounts = {
  vm_bootdiag_storage = {
    name                     = "vmbootdiag"
    resource_group_key       = "spoke_storage_rg"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Hot"
    tags = {
      purpose = "VM Boot Diagnostics"
    }
  }
}

# Public IP for VM external access through NGFW
# (Added to existing public_ip_addresses block above)

# ========================================
# ROUTE TABLES CONFIGURATION
# ========================================
# Route tables to ensure traffic flows through NGFW for inspection

route_tables = {
  # Route table for VM subnet - routes traffic through NGFW Trust interface
  vm_subnet_rt = {
    name               = "rt-vm-subnet-via-ngfw"
    resource_group_key = "spoke_storage_rg"

    # Routes for VM subnet traffic
    routes = {
      # Default route to NGFW Trust interface for internet-bound traffic
      default_to_ngfw = {
        name           = "default-via-ngfw"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VirtualAppliance"
        # This should point to the NGFW Trust interface IP
        # The NGFW Trust interface will be dynamically assigned in the Trust subnet (10.100.2.0/24)
        next_hop_in_ip_address = "10.100.2.4" # Expected NGFW Trust interface IP
      }

      # Route to hub network through NGFW
      hub_via_ngfw = {
        name                   = "hub-via-ngfw"
        address_prefix         = "10.100.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.100.2.4" # NGFW Trust interface IP
      }

      # Local spoke traffic can go direct (within same VNet)
      local_spoke_direct = {
        name           = "local-spoke-direct"
        address_prefix = "10.200.0.0/16"
        next_hop_type  = "VnetLocal"
      }
    }

    tags = {
      purpose = "VM subnet routing via NGFW"
    }
  }

  # Route table for backend subnet (storage services)
  backend_subnet_rt = {
    name               = "rt-backend-subnet-via-ngfw"
    resource_group_key = "spoke_storage_rg"

    # Routes for backend subnet traffic
    routes = {
      # Default route to NGFW Trust interface for internet-bound traffic
      default_to_ngfw = {
        name                   = "default-via-ngfw"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.100.2.4" # NGFW Trust interface IP
      }

      # Route to hub network through NGFW
      hub_via_ngfw = {
        name                   = "hub-via-ngfw"
        address_prefix         = "10.100.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.100.2.4" # NGFW Trust interface IP
      }

      # Local spoke traffic can go direct (within same VNet)
      local_spoke_direct = {
        name           = "local-spoke-direct"
        address_prefix = "10.200.0.0/16"
        next_hop_type  = "VnetLocal"
      }
    }

    tags = {
      purpose = "Backend subnet routing via NGFW"
    }
  }
}

# ========================================
# DEPLOYMENT AND TESTING GUIDE
# ========================================

# DEPLOYMENT INSTRUCTIONS:
# 1. Deploy the configuration from the examples directory:
#    cd /path/to/terraform-azurerm-caf/examples
#    terraform plan -var-file="./palo_alto/cloudngfw/300-cloudngfw-with-local-rulestack-static-website-published/configuration.tfvars"
#    terraform apply -var-file="./palo_alto/cloudngfw/300-cloudngfw-with-local-rulestack-static-website-published/configuration.tfvars"
#
# 2. Wait for deployment to complete (typically 15-20 minutes)
#
# 3. Upload static website content:
#    Upload website_content/* files to the $web container in the storage account

# POST-DEPLOYMENT TESTING:

# STATIC WEBSITE TESTING:
# Get the NGFW dataplane public IP and test static website access:
#    NGFW_IP=$(terraform output -raw objects | jq -r '.public_ip_addresses.ngfw_pip_dataplane1.ip_address')
#    echo "Testing Static Website: https://$NGFW_IP/"
#    curl -k -v --connect-timeout 10 https://$NGFW_IP/

# VIRTUAL MACHINE TESTING:
# 1. SSH Access (via DNAT port 2022):
#    ssh -p 2022 azureuser@$NGFW_IP
#
# 2. HTTP Web Server Test (via DNAT port 8080):
#    curl -v --connect-timeout 10 http://$NGFW_IP:8080/
#
# 3. HTTPS Web Server Test (via DNAT port 8443):
#    curl -k -v --connect-timeout 10 https://$NGFW_IP:8443/

# CONNECTIVITY VERIFICATION:
# 1. Verify VM can reach internet through NGFW:
#    ssh -p 2022 azureuser@$NGFW_IP "curl -s ifconfig.me"
#
# 2. Check VM web server status:
#    ssh -p 2022 azureuser@$NGFW_IP "sudo systemctl status nginx"
#
# 3. Verify internal connectivity:
#    ssh -p 2022 azureuser@$NGFW_IP "ping 10.200.1.4"  # Storage private endpoint

# BROWSER TESTING:
# Open a web browser and navigate to:
# - Static Website: https://$NGFW_IP (expect SSL warnings)
# - VM Web Server: http://$NGFW_IP:8080
# Note: SSL certificate warnings are expected since we're using the NGFW's IP

# TROUBLESHOOTING:
# - Connection timeout = NGFW security rules blocking (check rules allow 0.0.0.0/0 destination)
# - SSH connection refused = VM not ready or DNAT misconfigured
# - HTTP 400/403 errors = Normal for Azure Storage without proper hostname
# - Nginx not responding = Check VM custom data execution: ssh and run 'tail -f /var/log/cloud-init-output.log'

# ARCHITECTURE VALIDATION:
# 1. Verify traffic flows through NGFW:
#    - Check NGFW logs in Azure portal
#    - Verify route tables are applied to subnets
#    - Test connectivity from VM to internet (should route via NGFW)
#
# 2. Verify security policies:
#    - All external access goes through NGFW DNAT rules
#    - Internal traffic between subnets is controlled
#    - VM internet access is inspected by NGFW

# COST OPTIMIZATION:
# - VM auto-shutdown is configured for 10 PM UTC daily
# - Storage account uses LRS replication
# - VM uses B-series for cost efficiency
# - Boot diagnostics use managed storage (no additional cost)

# CLEANUP:
# terraform destroy -var-file="./palo_alto/cloudngfw/300-cloudngfw-with-local-rulestack-static-website-published/configuration.tfvars"
