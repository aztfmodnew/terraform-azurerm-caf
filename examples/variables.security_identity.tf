# Split from variables.tf - group: security_identity

variable "azuread_credential_policies" {
  type    = any
  default = {}
}

variable "azuread_applications" {
  type    = any
  default = {}
}

variable "azuread_credentials" {
  type    = any
  default = {}
}

variable "azuread_groups_membership" {
  type    = any
  default = {}
}

variable "azuread_service_principals" {
  type    = any
  default = {}
}

variable "azuread_service_principal_names" {
  description = "Configuration object for Azure AD service principals resolved by display name"
  type        = any
  default     = {}
}

variable "azuread_service_principal_passwords" {
  type    = any
  default = {}
}

variable "azuread_groups" {
  type    = any
  default = {}
}

variable "azuread_roles" {
  type    = any
  default = {}
}

variable "azuread_administrative_units" {
  type    = any
  default = {}
}

variable "azuread_administrative_unit_members" {
  type    = any
  default = {}
}

variable "keyvaults" {
  type    = any
  default = {}
}

variable "keyvault_access_policies" {
  type    = any
  default = {}
}

variable "keyvault_certificate_issuers" {
  type    = any
  default = {}
}

variable "keyvault_keys" {
  type    = any
  default = {}
}

variable "keyvault_certificate_requests" {
  type    = any
  default = {}
}

variable "keyvault_certificates" {
  type    = any
  default = {}
}

variable "managed_identities" {
  type    = any
  default = {}
}

variable "role_mapping" {
  type    = any
  default = {}
}

variable "azuread_api_permissions" {
  type    = any
  default = {}
}

variable "keyvault_access_policies_azuread_apps" {
  type    = any
  default = {}
}

variable "azuread_apps" {
  default = {}
  type    = map(any)
}

variable "azuread_users" {
  default = {}
  type    = map(any)
}

variable "custom_role_definitions" {
  type    = any
  default = {}
}

variable "disk_encryption_sets" {
  type    = any
  default = {}
}

variable "lighthouse_definitions" {
  type    = any
  default = {}
}

variable "sentinel" {
  type    = any
  default = {}
}

variable "sentinel_automation_rules" {
  type    = any
  default = {}
}

variable "sentinel_watchlists" {
  type    = any
  default = {}
}

variable "sentinel_watchlist_items" {
  type    = any
  default = {}
}

variable "sentinel_ar_fusions" {
  type    = any
  default = {}
}

variable "sentinel_ar_ml_behavior_analytics" {
  type    = any
  default = {}
}

variable "sentinel_ar_ms_security_incidents" {
  type    = any
  default = {}
}

variable "sentinel_ar_scheduled" {
  type    = any
  default = {}
}

variable "sentinel_dc_aad" {
  type    = any
  default = {}
}

variable "sentinel_dc_app_security" {
  type    = any
  default = {}
}

variable "sentinel_dc_aws" {
  type    = any
  default = {}
}

variable "sentinel_dc_azure_threat_protection" {
  type    = any
  default = {}
}

variable "sentinel_dc_ms_threat_protection" {
  type    = any
  default = {}
}

variable "sentinel_dc_office_365" {
  type    = any
  default = {}
}

variable "sentinel_dc_security_center" {
  type    = any
  default = {}
}

variable "sentinel_dc_threat_intelligence" {
  type    = any
  default = {}
}

variable "aadb2c_directory" {
  description = <<DESCRIPTION
  The aadb2c_directory object is a map of AAD B2C directory objects. Each AAD B2C directory object has the following keys:
    - country_code - (Optional) The country code for the AAD B2C directory. This is optional and can be set to null.
    - data_residency_location - (Required) The data residency location for the AAD B2C directory. This is required and cannot be null.
    - display_name - (Optional) The display name for the AAD B2C directory. This is optional and can be set to null.
    - domain_name - (Required) The domain name for the AAD B2C directory. This is required and cannot be null.
    - sku_name - (Required) The SKU name for the AAD B2C directory. This is required and cannot be null.
    - tags - (Optional) A mapping of tags which should be assigned to the AAD B2C Directory.
    - resource_group_name - (Required if resource_group_key and resource_group is not set) The name of the resource group in which the AAD B2C directory will be created. This is required and cannot be null.
    - resource_group_key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
    - resource_group - (Optional) The resource group object in which the AAD B2C directory will be created. This is optional and can be set to null.
      - lz_key - (Optional) The key of the landing zone in which the AAD B2C directory will be created. This is optional and can be set to null.
      - key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
      - name - (Optional) The name of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
  DESCRIPTION
  default     = {} # Make the variable nullable by default
  type = map(object({
    country_code            = optional(string)
    data_residency_location = string # Required if object is provided
    display_name            = optional(string)
    domain_name             = string # Required if object is provided
    resource_group_name     = optional(string)
    sku_name                = string # Required if object is provided
    tags                    = optional(map(string))
    resource_group_key      = optional(string)
    resource_group = optional(object({
      lz_key = optional(string)
      key    = optional(string)
      name   = optional(string)
    }))
  }))
  sensitive = false
  validation {
    # Check if aadb2c_directory is {} OR if all keys within each directory object are valid.
    condition = var.aadb2c_directory == {} || alltrue([
      for dir_key, dir_value in var.aadb2c_directory :
      length(setsubtract(keys(dir_value), [
        "country_code",
        "data_residency_location",
        "display_name",
        "domain_name",
        "resource_group_name",
        "sku_name",
        "tags",
        "resource_group_key",
        "resource_group"
      ])) == 0
    ])
    error_message = "One or more entries in aadb2c_directory contain unsupported attributes. Allowed attributes are: country_code, data_residency_location, display_name, domain_name, resource_group_name, sku_name, tags, resource_group_key, resource_group."
  }
}

variable "pim" {
  description = "Configuration object for PIM (Privileged Identity Management) resources."
  type        = any
  default     = {}
}
