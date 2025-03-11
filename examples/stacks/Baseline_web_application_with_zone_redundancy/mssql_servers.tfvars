mssql_servers = {
  adventureworks-rg1 = {
    name                = "adventureworks-rg1"
    region              = "region1"
    resource_group_key  = "rg1"
    version             = "12.0"
    administrator_login = "sqladventureworksadmin"

    # Generate a random password and store it in keyvaul secret
    keyvault_key                  = "sql-rg1"
    connection_policy             = "Default"
    system_msi                    = true
    public_network_access_enabled = false
    azuread_administrator = {
      azuread_group_key = "sqlserver_admin"
    }


    tags = {
      segment = "sales"
    }

    # Optional
    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      private-link-level4 = {
        name       = "adventureworks-sql-rg1"
        vnet_key   = "vnet1"
        subnet_key = "private_endpoints"
        #subnet_id          = "/subscriptions/97958dac-f75b-4ee3-9a07-9f436fa73bd4/resourceGroups/ppga-rg-sql-rg1/providers/Microsoft.Network/virtualNetworks/ppga-vnet-testvnet1/subnets/ppga-snet-web-subnet"
        resource_group_key = "rg1"

        private_service_connection = {
          name                 = "adventureworks-sql-rg1"
          is_manual_connection = false
          subresource_names    = ["sqlServer"]
        }

        # private_dns = {
        #   zone_group_name = "privatelink_database_windows_net"
        #   # lz_key          = ""   # If the DNS keys are deployed in a remote landingzone
        #   keys = ["privatelink"]
        # }
      }
    }
  }
}