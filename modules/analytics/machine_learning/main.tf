terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      # 4.46.0 is the first release providing service_side_encryption_enabled and
      # the three machine learning workspace network outbound rule resources.
      version = ">= 4.46.0"
    }
  }
}
