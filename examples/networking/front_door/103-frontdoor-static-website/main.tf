terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example of using the CAF module
module "caf" {
  source = "Azure/caf/azurerm"
  version = "~> 5.0"

  # Configuración global
  global_settings = var.global_settings
  
  # Resource groups
  resource_groups = var.resource_groups
  
  # Storage accounts for static website
  storage_accounts = var.storage_accounts
  
  # Containers and blobs for web content
  storage_containers = var.storage_containers
  storage_account_blobs = var.storage_account_blobs
  
  # CDN Front Door Profile
  cdn = {
    cdn_frontdoor_profile = var.cdn_frontdoor_profiles
  }
  
  # Log Analytics y diagnósticos
  log_analytics = var.log_analytics
  diagnostics_definition = var.diagnostics_definition
  diagnostics_destinations = var.diagnostics_destinations
}

# Outputs útiles
output "storage_account_primary_web_endpoint" {
  description = "Primary web endpoint of the static website"
  value       = module.caf.storage_accounts.static_website.primary_web_endpoint
}

output "frontdoor_endpoint_url" {
  description = "Front Door endpoint URL"
  value       = try(module.caf.cdn.cdn_frontdoor_profile.static_website.endpoints.main.host_name, "")
}

output "frontdoor_id" {
  description = "Front Door resource ID"
  value       = try(module.caf.cdn.cdn_frontdoor_profile.static_website.id, "")
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.caf.resource_groups.static_website.id
}
