terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.7.0"
    }
  }
}