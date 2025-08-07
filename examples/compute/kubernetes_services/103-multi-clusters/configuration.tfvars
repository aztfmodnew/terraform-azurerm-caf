global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"  # Changed from northeurope to westeurope for better quota availability
    region2 = "northeurope" # Changed from westeurope to northeurope
  }
}

resource_groups = {
  aks_re1 = {
    name   = "aks-re1"
    region = "region1"
  }
  aks_re2 = {
    name   = "aks-re2"
    region = "region2"
  }
}



#
role_mapping = {
  custom_role_mapping = {}

  built_in_role_mapping = {
    azure_container_registries = {
      acr1 = {
        "AcrPull" = {
          aks_clusters = {
            keys = ["cluster_re1", "cluster_re2"]
          }
        }
      }
    }
  }
}