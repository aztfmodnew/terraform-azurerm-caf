# Split from variables.tf - group: core

variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  These are the settings that can be configured:
  - default_region - (Optional) The default region to use for the global settings object, by default it is set to "region1".
  - environment - (Optional) The environment to use for deployments.
  - inherit_tags - (Optional) A boolean value that indicates whether to inherit tags from the global settings object and from the resource group, by default it is set to false.
  - prefix - (Optional) The prefix to append as the first characters of the generated name. The prefix will be separated by the separator character.
  - suffix - (Optional) The suffix to append after the basename of the resource to create. The suffix will be separated by the separator character.
  - prefix_with_hyphen - (Optional) A boolean value that indicates whether to add a hyphen to the prefix.
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name. The prefixes will be separated by the separator character.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource to create. The suffixes will be separated by the separator character.
  - random_length - (Optional) The length of the random string to generate. Defaults to 0.
  - random_seed - (Optional) The seed to be used for the random generator. 0 will not be respected and will generate a seed based on the Unix time of the generation.
  - resource_type - (Optional) The type of Azure resource you are requesting a name from (e.g., Azure Container Registry: azurerm_container_registry). See the Resource Types supported: https://github.com/aztfmodnew/terraform-provider-azurecaf?tab=readme-ov-file#resource-status.
  - resource_types - (Optional) A list of additional resource types should you want to use the same settings for a set of resources.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - passthrough - (Optional) A boolean value that indicates whether to pass through the naming convention. In that case only the clean input option is considered and the prefixes, suffixes, random, and are ignored. The resource prefixe is not added either to the resulting string. Defaults to false.
  - regions - (Optional) A map of regions to use for the global settings object.
    - region1 - The name of the first region.
    - region2 - The name of the second region.
    - regionN - The name of the Nth region.
  - tags - (Optional) A map of tags to be inherited from the global settings object if inherit_tags is set to true.
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name, suffix, or prefix. Defaults to true.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
DESCRIPTION
  type        = any
  /*type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(bool)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number)
    random_seed        = optional(number)
    resource_type      = optional(string)
    resource_types     = optional(list(string))
    separator          = optional(string)
    clean_input        = optional(bool)
    passthrough        = optional(bool)
    regions            = map(string)
    use_slug           = optional(bool)
  })*/
  default = {
    default_region = "region1"
    inherit_tags   = true
    passthrough    = false
    regions = {
      region1 = "eastus2"
      region2 = "centralus"
    }
  }
}

variable "landingzone" {
  description = <<DESCRIPTION
  The landingzone object is a map of landing zone objects. Each landing zone object has the following keys
- backend_type: The type of backend to use for the landing zone object. Possible values are azurerm, s3, gcs, local and remote.
- global_settings_key: The key of the global settings object to use for the landing zone object.
- level: The level of the landing zone object. Possible values are level0, level1, level2 and level3.
- key: The key of the landing zone object.
DESCRIPTION

  type = any
  default = {
    backend_type        = "azurerm"
    global_settings_key = "launchpad"
    level               = "level0"
    key                 = "examples"
  }
}

variable "var_folder_path" {
  description = "The path to the folder containing the variables files"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment in which the resources are deployed."
  default     = "sandpit"
  type        = string
}

variable "rover_version" {
  default = null
  type    = string
}

variable "logged_user_objectId" {
  default = null
  type    = string
}

variable "logged_aad_app_objectId" {
  default = null
  type    = string
}

variable "tags" {
  default = null
  type    = map(any)
}

variable "data_sources" {
  description = <<DESCRIPTION
Configuration object for existing resources used by examples.

`data_sources` allows examples to consume resources that are not created in the same
example execution. The object is merged into root `combined_objects` so dependencies
can be referenced by key.

Supported modes:

1) Explicit ID mode (legacy, always supported)
   - Provide `id` in `data_sources.<object_type>.<key>`.

2) Name-based lookup mode (for centralized lookups)
   - Provide lookup attributes and allow `data_sources_lookup.tf` to resolve IDs.
   - Centralized lookup currently supports:
     - `resource_groups` by `name`
     - `management_groups` by `name` or `display_name`
    - `subscriptions` by `subscription_id` or `display_name` (exact match required)
     - `role_definitions` by `name` or `role_definition_id` (optional `scope`)
     - `azuread_groups` by `display_name`
     - `keyvaults` by `name` + `resource_group_name`
    - `managed_identities` by `name` + `resource_group_name`
    - `private_dns` by `name` (optional `resource_group_name`)
    - `public_ip_addresses` by `name` + `resource_group_name`
    - `virtual_subnets` by `name` + `virtual_network_name` + `resource_group_name`
     - `storage_accounts` by `name` + `resource_group_name`
     - `recovery_vaults` by `name` + `resource_group_name`
     - `vnets` by `name` + `resource_group_name` (with optional subnet lookup by subnet `name`)

Recommendation:
- Keep example keys stable (`existing_keyvault`, `vnet_existing`, etc.) because those
  keys are used by resource references in the same example.
DESCRIPTION
  type        = any
  default     = {}
}

variable "subscriptions" {
  description = "Configuration object - Subscriptions resources."
  default     = {}
}
