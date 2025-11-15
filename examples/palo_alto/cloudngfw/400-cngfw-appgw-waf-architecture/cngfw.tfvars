# Cloud NGFW Configuration with Local Rulestack
# Best practices:
# - Use local rulestack for centralized policy management within Azure
# - Enable egress NAT for outbound traffic
# - Configure App-ID, threat prevention, and URL filtering
palo_alto_cloudngfws = {
  production_ngfw = {
    name                 = "cngfw-production-hub"
    resource_group_key   = "networking_rg"
    attachment_type      = "vnet"
    management_mode      = "rulestack"
    plan_id              = "panw-cngfw-payg"
    marketplace_offer_id = "pan_swfw_cloud_ngfw"

    network_profile = {
      vnet_configuration = {
        virtual_network_key  = "hub_vnet"
        trusted_subnet_key   = "ngfw_trust_subnet"
        untrusted_subnet_key = "ngfw_untrust_subnet"
      }

      public_ip_address_keys = [
        {
          key = "ngfw_management_pip"
        },
        {
          key = "ngfw_dataplane_pip"
        }
      ]

      # Egress NAT IP addresses for outbound traffic
      # Best practice: Use dedicated IP for egress NAT
      egress_nat_ip_address_keys = [
        {
          key = "ngfw_dataplane_pip" # Use dataplane PIP for egress NAT
        }
      ]

      enable_egress_nat = true
    }

    # Local Rulestack Configuration
    # Following Microsoft best practices for security policy
    local_rulestack = {
      name        = "rulestack-production-security"
      description = "Production security rulestack for Cloud NGFW with comprehensive threat prevention"

      # Security Services - Enable all advanced features
      security_services = {
        # Advanced Threat Prevention
        vulnerability_profile = "BestPractice"
        anti_spyware_profile  = "strict"
        antivirus_profile     = "strict"
        file_blocking_profile = "strict"

        # Advanced URL Filtering
        url_filtering_profile = "strict"

        # DNS Security
        dns_subscription = "BestPractice"
      }

      # Default mode for rule creation
      # Options: FIREWALL, IPS, NONE
      default_mode = "IPS" # IPS mode for intrusion prevention

      # Security Rules
      rules = {
        "allow-web-traffic" = {
          priority     = 100
          action       = "Allow"
          applications = ["web-browsing", "ssl"]
          description  = "Allow HTTP/HTTPS traffic from Application Gateway to backend"
          enabled      = true
          source = {
            cidrs = ["10.200.1.0/24"] # Application Gateway subnet
          }
          destination = {
            cidrs = ["10.200.20.0/24"] # Backend subnet
          }
          protocol_ports = ["TCP:443", "TCP:80"]
          inspection = {
            vulnerability = true
            anti_spyware  = true
            antivirus     = true
            url_filtering = true
          }
        }

        "allow-dns" = {
          priority     = 110
          action       = "Allow"
          applications = ["any"]
          description  = "Allow DNS queries with DNS security"
          enabled      = true
          source = {
            cidrs = ["10.200.0.0/16"]
          }
          destination = {
            cidrs = ["0.0.0.0/0"]
          }
          protocol_ports = ["UDP:53"]
          inspection = {
            dns_security = true
          }
        }

        "deny-all" = {
          priority     = 4096
          action       = "DenySilent"
          applications = ["any"]
          description  = "Explicit deny all other traffic"
          enabled      = true
          source = {
            cidrs = ["0.0.0.0/0"]
          }
          destination = {
            cidrs = ["0.0.0.0/0"]
          }
          protocol = "application-default"
        }
      }
    }

    tags = {
      environment   = "production"
      security_tier = "high"
      compliance    = "required"
      cost_center   = "security-operations"
    }
  }
}
