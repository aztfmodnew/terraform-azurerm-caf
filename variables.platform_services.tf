# Split from variables.tf - group: platform_services

variable "cache" {
  description = "Configuration object - Azure cache resources"
  type        = any
  default     = {}
}

variable "cdn" {
  description = <<DESCRIPTION
  Configuration object - Azure CDN resources"

  This variable is used to define the settings for Azure CDN resources, such as profiles, endpoints, origin groups, origins, rule sets, and rules.
  These are the settings that can be configured:
  - profiles: (Optional) A map of CDN profiles, where each key is a unique identifier for the profile and the value is an object containing the profile settings.
    - name: (Required) The name of the CDN profile.
    - location: (Required) The Azure region where the CDN profile will be created.
    - resource_group_key: (Optional) The key of the resource group in which the CDN profile will be created. If not provided, it defaults to the current landing zone's resource group.
    - sku_name: (Required) The SKU name for the CDN profile, such as "Standard_AzureFrontDoor" or "Premium_AzureFrontDoor".
  - base_tags: (Optional) A map of tags to be applied to the CDN resources. If not provided, it defaults to the global settings' inherited tags.
  - location: (Optional) The Azure region where the CDN resources will be created. If not provided, it defaults to the profile's location.
  - endpoints: (Optional) A map of CDN endpoints, where each key is a unique identifier for the endpoint and the value is an object containing the endpoint settings.
  - origin_groups: (Optional) A map of CDN origin groups, where each key is a unique identifier for the origin group and the value is an object containing the origin group settings.
  - origins: (Optional) A map of CDN origins, where each key is a unique identifier for the origin and the value is an object containing the origin settings.
  - rule_sets: (Optional) A map of CDN rule sets, where each key is a unique identifier for the rule set and the value is an object containing the rule set settings.
  - rules: (Optional) A map of CDN rules, where each key is a unique identifier for the rule and the value is an object containing the rule settings.
  - custom_domains: (Optional) A map of custom domains, where each key is a unique identifier for the custom domain and the value is an object containing the custom domain settings.


  For example, you can define a CDN profile with the following structure:
  cdn = {
    profiles = {
      profile1 = {
        name                = "my-cdn-profile"
        location            = "westeurope"
        resource_group_key  = "my_resource_group"
        sku_name            = "Standard_AzureFrontDoor"
        custom_domains      = {}
        endpoints           = {}
        origin_groups       = {}
        origins             = {}
        rule_sets           = {}
        rules               = {}
      }
    }
  }
  This allows you to create and manage Azure CDN resources in a structured way, making it easier to deploy and maintain your CDN configurations.
  DESCRIPTION
  type        = any
  default     = {}
}

variable "user_type" {
  description = "The rover set this value to user or serviceprincipal. It is used to handle Azure AD API consents."
  default     = {}
}

variable "maps" {
  description = "Configuration object - Azure map "
  default     = {}
}

variable "data_protection" {
  description = "Configuration object - data protection"
  default     = {}
}

variable "storage_accounts" {
  description = "Configuration object - Storage account resources"
  default     = {}
}

variable "storage" {
  description = "Configuration object - Storage account resources"
  default     = {}
}

variable "diagnostic_storage_accounts" {
  description = "Configuration object - Storage account for diagnostics resources"
  default     = {}
}

variable "shared_services" {
  description = "Configuration object - Shared services resources"
  default = {
    # automations = {}
    # monitoring = {}
    # recovery_vaults = {}
  }
}

variable "palo_alto" {
  description = "Configuration object - Palo Alto resources"
  default     = {}
}

variable "app_config" {
  default = {}
}

variable "event_hub_auth_rules" {
  description = "Configuration object - Event Hub authentication rules"
  default     = {}
}

variable "event_hub_namespace_auth_rules" {
  description = "Configuration object - Event Hub namespaces authentication rules"
  default     = {}
}

variable "event_hub_consumer_groups" {
  description = "Configuration object - Event Hub consumer group rules"
  default     = {}
}

variable "random_strings" {
  description = "Configuration object - Random string generator resources"
  default     = {}
}

variable "cognitive_services" {
  description = "Configuration object - Cognitive Service Resource "
  default     = {}
}

variable "purview" {
  default = {}
}

variable "sentinel_watchlists" {
  default = {}
}

variable "powerbi_embedded" {
  default = {}
}
