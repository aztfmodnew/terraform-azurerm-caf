terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
  }
}
