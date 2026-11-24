terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.13.0"
    }
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
  }
}
