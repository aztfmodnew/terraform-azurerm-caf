# Network Security Groups
# Best practice: Implement least-privilege access controls
network_security_group_definition = {
  appgw_nsg = {
    nsg = [
      {
        name                       = "Allow-Internet-HTTP-HTTPS-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443"]
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow HTTP/HTTPS from Internet"
      },
      {
        name                       = "Allow-GatewayManager-Inbound"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
        description                = "Allow Azure infrastructure communication"
      },
      {
        name                       = "Allow-AzureLoadBalancer-Inbound"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
        description                = "Allow Azure Load Balancer health probes"
      }
    ]
  }

  ngfw_trust_nsg = {
    # Trust subnet - restrictive rules
    nsg = [
      {
        name                       = "Allow-AppGW-to-NGFW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.1.0/24"
        destination_address_prefix = "*"
        description                = "Allow traffic from Application Gateway"
      }
    ]
  }

  ngfw_untrust_nsg = {
    # Untrust subnet - allow outbound, restrict inbound
    nsg = []
  }

  backend_nsg = {
    nsg = [
      {
        name                       = "Allow-NGFW-to-Backend"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443", "8080"]
        source_address_prefix      = "10.200.10.0/24"
        destination_address_prefix = "*"
        description                = "Allow traffic from NGFW trust subnet"
      },
      {
        name                       = "Deny-All-Inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Explicit deny all other inbound"
      }
    ]
  }

  bastion_nsg = {
    nsg = [
      {
        name                       = "Allow-Bastion-Inbound-443"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow HTTPS to Bastion"
      },
      {
        name                       = "Allow-Bastion-Inbound-4443"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "4443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow Bastion TCP 4443"
      },
      {
        name                       = "Allow-Bastion-Outbound-All"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Allow all outbound from Bastion"
      }
    ]
  }
}
