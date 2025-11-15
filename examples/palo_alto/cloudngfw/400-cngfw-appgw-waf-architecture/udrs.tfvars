# Route Tables
# Best practice: Force traffic through NGFW using User-Defined Routes (UDR)
route_tables = {
  backend_route_table = {
    name               = "backend-via-ngfw"
    resource_group_key = "networking_rg"

    routes = {
      to_internet = {
        name           = "route-to-internet-via-ngfw"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VirtualAppliance"
        # This IP should be the Cloud NGFW trust interface IP
        # Will be populated after NGFW deployment
        next_hop_in_ip_address = "10.200.10.4" # Example IP - adjust based on NGFW deployment
      }
    }
  }

  appgw_route_table = {
    name               = "appgw-via-ngfw"
    resource_group_key = "networking_rg"

    routes = {
      to_backend = {
        name                   = "route-to-backend-via-ngfw"
        address_prefix         = "10.200.20.0/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.200.10.4" # Cloud NGFW trust interface
      }
    }
  }
}
