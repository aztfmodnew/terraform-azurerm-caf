active_directory_domain_service = {
  adds = {
    name   = "aadds-demo"
    region = "region1"
    resource_group = {
      key = "rg"
    }
    domain_name               = "demo.local"
    sku                       = "Enterprise"
    filtered_sync_enabled     = false
    domain_configuration_type = "FullySynced"
    initial_replica_set = {
      region = "region1"
      subnet = {
        vnet_key = "vnet_aadds_re1"
        key      = "aadds"
      }
    }
    tags = {
      Environment = "demo"
    }
  }
}
