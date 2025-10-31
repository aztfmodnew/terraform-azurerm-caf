# Virtual Networks Configuration
# Following Microsoft best practice: separate subnets for AppGW, NGFW, and backend
vnets = {
  hub_vnet = {
    resource_group_key = "networking_rg"
    vnet = {
      name          = "hub-cngfw-appgw"
      address_space = ["10.200.0.0/16"]
    }
    subnets = {
      # Application Gateway requires a dedicated subnet
      appgw_subnet = {
        name            = "appgw"
        cidr            = ["10.200.1.0/24"]
        nsg_key         = "appgw_nsg"
        route_table_key = "appgw_route_table"
      }

      # Cloud NGFW Trust subnet (private/trusted side)
      ngfw_trust_subnet = {
        name    = "cngfw-trust"
        cidr    = ["10.200.10.0/24"]
        nsg_key = "ngfw_trust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }

      # Cloud NGFW Untrust subnet (public/untrusted side)
      ngfw_untrust_subnet = {
        name    = "cngfw-untrust"
        cidr    = ["10.200.11.0/24"]
        nsg_key = "ngfw_untrust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }

      # Backend subnet for workloads (web servers, app servers, etc.)
      backend_subnet = {
        name            = "backend-workloads"
        cidr            = ["10.200.20.0/24"]
        nsg_key         = "backend_nsg"
        route_table_key = "backend_route_table"
      }

      # Azure Bastion for secure management access
      bastion_subnet = {
        name    = "AzureBastionSubnet"
        cidr    = ["10.200.250.0/24"]
        nsg_key = "bastion_nsg"
      }
    }
    tags = {
      purpose = "Hub VNet with CNGFW and AppGW"
    }
  }
}