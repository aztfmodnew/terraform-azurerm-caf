terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.1.0"
    }
  }
}
