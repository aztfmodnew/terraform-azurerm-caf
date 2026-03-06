# terraform provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_site

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}




