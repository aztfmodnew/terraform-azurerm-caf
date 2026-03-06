terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}