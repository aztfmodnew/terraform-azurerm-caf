global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast" // You can adjust the Azure Region you want to use to deploy NAT Gateway
    // region2 = "australiacentral" // Optional - Add additional regions
  }
}

provider_azurerm_features_keyvault = {
  // set to true to cleanup the CI
  purge_soft_delete_on_destroy = true
}