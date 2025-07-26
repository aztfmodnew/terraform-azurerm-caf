global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "diag"

  regions = {
    region1 = "australiaeast"
  }

  inherit_tags = true

  # Hybrid naming configuration - using azurecaf (default)
  naming = {
    use_azurecaf     = true
    use_local_module = false
  }
}

resource_groups = {
  test = {
    name = "test"
  }
}
