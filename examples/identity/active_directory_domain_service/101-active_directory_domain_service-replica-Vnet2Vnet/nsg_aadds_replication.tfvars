# NSG rules específicas para replicación entre AADDS Domain Controllers
# Este archivo complementa las reglas existentes en nsg.tfvars

network_security_group_definition = {
  # Reglas adicionales para aadds_re1 - replicación DC
  aadds_re1_replication = {
    version            = 1
    resource_group_key = "rg"
    region             = "region1"
    name               = "aadds-re1-replication"
    tags = {
      application_category = "domain controllers replication"
    }
    nsg = [
      # DNS resolution
      {
        name                       = "DNS-Inbound"
        priority                   = "300"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "10.20.1.0/24"  # Remote AADDS subnet
        destination_address_prefix = "10.10.1.0/24"  # Local AADDS subnet
      },
      {
        name                       = "DNS-Outbound"
        priority                   = "300"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "10.10.1.0/24"  # Local AADDS subnet
        destination_address_prefix = "10.20.1.0/24"  # Remote AADDS subnet
      },
      # Kerberos authentication
      {
        name                       = "Kerberos-Inbound"
        priority                   = "301"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "88"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "Kerberos-Outbound"
        priority                   = "301"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "88"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # RPC Endpoint Mapper
      {
        name                       = "RPC-Endpoint-Mapper-Inbound"
        priority                   = "302"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "RPC-Endpoint-Mapper-Outbound"
        priority                   = "302"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # LDAP
      {
        name                       = "LDAP-Inbound"
        priority                   = "303"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "389"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "LDAP-Outbound"
        priority                   = "303"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "389"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # SMB/CIFS
      {
        name                       = "SMB-Inbound"
        priority                   = "304"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "SMB-Outbound"
        priority                   = "304"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # Kerberos Password Change
      {
        name                       = "Kerberos-Password-Inbound"
        priority                   = "305"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "464"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "Kerberos-Password-Outbound"
        priority                   = "305"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "464"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # Global Catalog
      {
        name                       = "Global-Catalog-Inbound"
        priority                   = "306"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3268-3269"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "Global-Catalog-Outbound"
        priority                   = "306"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3268-3269"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # RPC Dynamic Ports (High ports)
      {
        name                       = "RPC-Dynamic-Inbound"
        priority                   = "307"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "49152-65535"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "RPC-Dynamic-Outbound"
        priority                   = "307"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "49152-65535"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      # ICMP for connectivity testing
      {
        name                       = "ICMP-Inbound"
        priority                   = "308"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "ICMP-Outbound"
        priority                   = "308"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      }
    ]
  }
  
  # Reglas adicionales para aadds_re2 - replicación DC
  aadds_re2_replication = {
    version            = 1
    resource_group_key = "rg_remote"
    region             = "region2"
    name               = "aadds-re2-replication"
    tags = {
      application_category = "domain controllers replication"
    }
    nsg = [
      # DNS resolution
      {
        name                       = "DNS-Inbound"
        priority                   = "300"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "10.10.1.0/24"  # Remote AADDS subnet
        destination_address_prefix = "10.20.1.0/24"  # Local AADDS subnet
      },
      {
        name                       = "DNS-Outbound"
        priority                   = "300"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "10.20.1.0/24"  # Local AADDS subnet
        destination_address_prefix = "10.10.1.0/24"  # Remote AADDS subnet
      },
      # Kerberos authentication
      {
        name                       = "Kerberos-Inbound"
        priority                   = "301"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "88"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "Kerberos-Outbound"
        priority                   = "301"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "88"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # RPC Endpoint Mapper
      {
        name                       = "RPC-Endpoint-Mapper-Inbound"
        priority                   = "302"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "RPC-Endpoint-Mapper-Outbound"
        priority                   = "302"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # LDAP
      {
        name                       = "LDAP-Inbound"
        priority                   = "303"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "389"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "LDAP-Outbound"
        priority                   = "303"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "389"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # SMB/CIFS
      {
        name                       = "SMB-Inbound"
        priority                   = "304"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "SMB-Outbound"
        priority                   = "304"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # Kerberos Password Change
      {
        name                       = "Kerberos-Password-Inbound"
        priority                   = "305"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "464"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "Kerberos-Password-Outbound"
        priority                   = "305"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "464"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # Global Catalog
      {
        name                       = "Global-Catalog-Inbound"
        priority                   = "306"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3268-3269"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "Global-Catalog-Outbound"
        priority                   = "306"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3268-3269"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # RPC Dynamic Ports (High ports)
      {
        name                       = "RPC-Dynamic-Inbound"
        priority                   = "307"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "49152-65535"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "RPC-Dynamic-Outbound"
        priority                   = "307"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "49152-65535"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      # ICMP for connectivity testing
      {
        name                       = "ICMP-Inbound"
        priority                   = "308"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.20.1.0/24"
      },
      {
        name                       = "ICMP-Outbound"
        priority                   = "308"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.20.1.0/24"
        destination_address_prefix = "10.10.1.0/24"
      }
    ]
  }
}
