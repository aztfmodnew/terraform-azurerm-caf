network_security_perimeters = {
  nsp1_re1 = {
    location           = "australiaeast"
    resource_group_key = "nsp_re1"
    name               = "nsp1"
    tags = {
      environment = "dev"
    }
    profiles = {
      profile1 = {
        name = "profile1"
      }
      profile2 = {
        name = "profile2"
      }
    }
    access_rules = {
      access_profile1_rule1 = {
        profile_key      = "profile1"
        name             = "ip_address_prefix_example"
        address_prefixes = ["198.168.99.0/24"]
        direction        = "Inbound"
      }
      access_profile1_rule2 = {
        profile_key                  = "profile1"
        name                         = "fqdn_example"
        fully_qualified_domain_names = ["www.contoso.com"]
        direction                    = "Outbound"
      }
      #access_profile2_rule1 = {
      #  profile_key = "profile2"
      #  name = "subscription_example"
      #  subscriptions = [
      #    {
      #      id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      #    }
      #   ,
      #    {
      #      id = "/subscriptions/11111111-1111-1111-1111-111111111111"
      #    }
      #  ]
      #  direction = "Inbound"
      #}
    }
    # links = {
    #   link1 = {
    #     name = "link1"
    #     auto_approved_remote_perimeter_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/networkSecurityGroups/nsg1"
    #     description = "description"
    #     local_inbound_profiles = ["profile1"]
    #     remote_inbound_profiles = ["profile2"]
    #   }
    # }
    resource_associations = {
      assoc1 = {
        name = "assoc1"
        # Audit(not supported at 12/12/2024), Enforced, Learning
        access_mode = "Learning"
        # The PaaS id resource to be associated.        
        # private_link_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Storage/storageAccounts/accountname"        
        storage_account = {
          key = "sa1"
          #lz_key = ""
          #landingzone_key = ""         
        }
        profile_key = "profile1"
      }
      assoc2 = {
        name        = "assoc2"
        access_mode = "Learning"
        keyvault = {
          key = "stg_byok"
          #lz_key = ""
          #landingzone_key = ""
        }
        profile_key = "profile2"
      }
      assoc3 = {
        name        = "assoc3"
        access_mode = "Learning"
        mssql_server = {
          key = "sql_rg1"
          #lz_key = ""
          #landingzone_key = ""
        }
        profile_key = "profile1"
      }
    }
    diagnostic_profiles = {
      central_logs_region1 = {
        definition_key   = "network_security_perimeter"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
  }
}