terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0"
    }
  }
}