active_directory_domain_service = {
  adds = {
    name   = "aadds-demo"
    region = "region1"
    resource_group = {
      key = "rg"
      # lz_key = "<your-landingzone-key>" # opcional, si tu módulo lo requiere
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
    notifications = {
      additional_recipients = ["notifyA@example.net", "notifyB@example.org"]
      notify_dc_admins      = true
      notify_global_admins  = true
    }

    security = {
      sync_kerberos_passwords = true
      sync_ntlm_passwords     = true
      sync_on_prem_passwords  = true
    }

    tags = {
      Environment = "prod"
    }
  }
}


# You need Enteprise - Premium SKU for replicat_sets
active_directory_domain_service_replica_set = {
  aadds_region2 = {
    region = "region2"
    active_directory_domain_service = {
      key = "adds"
    }
    subnet = {
      vnet_key = "vnet_aadds_re2"
      key      = "aadds"
    }
  }
}