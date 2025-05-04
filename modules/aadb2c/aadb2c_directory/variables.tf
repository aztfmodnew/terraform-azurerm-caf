variable "global_settings" {
  description = "Global settings object (see module documentation for details)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Azure B2C Tenant. This is a map of settings that will be used to create the Azure B2C Tenant.
    The settings are:
      - country_code - (Optional) Country code of the B2C tenant. The country_code should be valid for the specified data_residency_location. See official docs for valid country codes. Required when creating a new resource. Changing this forces a new AAD B2C Directory to be created.
      - data_residency_location - (Required) Location in which the B2C tenant is hosted and data resides. The data_residency_location should be valid for the specified country_code. See official docs for more information. Changing this forces a new AAD B2C Directory to be created. Possible values are Asia Pacific, Australia, Europe, Global and United States.
      - display_name - (Optional) The initial display name of the B2C tenant. Required when creating a new resource. Changing this forces a new AAD B2C Directory to be created.
      - domain_name - (Required) Domain name of the B2C tenant, including the .onmicrosoft.com suffix. Changing this forces a new AAD B2C Directory to be created.
      - sku_name - (Required) Billing SKU for the B2C tenant. Must be one of: PremiumP1 or PremiumP2 (Standard is not supported). See official docs for more information.
      - tags - (Optional) A mapping of tags which should be assigned to the AAD B2C Directory.
    DESCRIPTION
  default     = null # This makes the entire variable optional if not provided
  type = object({
    country_code            = optional(string)      # Marked as optional
    data_residency_location = string                # Required
    display_name            = optional(string)      # Marked as optional
    domain_name             = string                # Required
    sku_name                = string                # Required
    tags                    = optional(map(string)) # Marked as optional
  })
  sensitive = false
  validation {
    # Check if all provided keys are within the allowed set.
    condition = length(setsubtract(
      keys(var.settings),
      [
        "country_code",
        "data_residency_location",
        "display_name",
        "domain_name",
        "sku_name",
        "tags"
      ]
    )) == 0
    error_message = format("The following attributes are not supported within settings: %s. Allowed attributes are: country_code, data_residency_location, display_name, domain_name, sku_name, tags.", join(", ",
      setsubtract(
        keys(var.settings),
        [
          "country_code",
          "data_residency_location",
          "display_name",
          "domain_name",
          "sku_name",
          "tags"
        ]
      )
      )
    )
  }
}


variable "resource_group_name" {
  description = "The name of the Resource Group where the AAD B2C Directory should exist. Changing this forces a new AAD B2C Directory to be created."
  default     = null
  type        = string
}

variable "resource_group" {
  description = "Resource group object of the Resource Group where the AAD B2C Directory should exist. Changing this forces a new AAD B2C Directory to be created."
  default     = null
  type        = any

}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
