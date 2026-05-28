# Split from variables.tf - group: security_identity

variable "azuread" {
  description = "Configuration object - Azure Active Directory resources"
  default     = {}
}

variable "security" {
  description = "Configuration object - security resources"
  default     = {}
}

variable "managed_identities" {
  description = "Configuration object - Azure managed identity resources"
  default     = {}
}

variable "keyvaults" {
  description = "Configuration object - Azure Key Vault resources"
  default     = {}
}

variable "keyvault_access_policies" {
  description = "Configuration object - Azure Key Vault policies"
  default     = {}
}

variable "keyvault_access_policies_azuread_apps" {
  description = "Configuration object - Azure Key Vault policy for azure ad applications"
  default     = {}
}

variable "custom_role_definitions" {
  description = "Configuration object - Custom role definitions"
  default     = {}
}

variable "role_mapping" {
  description = "Configuration object - Role mapping"
  default = {
    built_in_role_mapping = {}
    custom_role_mapping   = {}
  }
}

variable "dynamic_keyvault_secrets" {
  default = {}
}

variable "keyvault_certificate_issuers" {
  description = "Configuration object - Azure Key Vault Certificate Issuers resources"
  default     = {}
}

variable "identity" {
  description = <<DESCRIPTION
  Configuration object - Identity resources
  This variable is used to define the settings for Azure Active Directory Domain Services (AAD DS)
  and its replica sets. It allows you to configure the AAD DS instance, including its name, location, resource group,
  domain name, SKU, and other settings. Additionally, it allows you to define replica sets
  for the AAD DS instance, specifying the region, subnet, and other relevant details.

  - active_directory_domain_service: (Optional) A map of AAD DS instances, where each key is a unique identifier for the instance and the value is an object containing the instance settings.
    - name: (Required) The name of the AAD DS instance.
    - location: (Optional) The Azure region where the AAD DS instance will be created. If not defined, it defaults to the current landing zone's location.
    - resource_group_key: (Optional) The key of the resource group in which the AAD DS instance will be created. If not provided, it defaults to the current landing zone's resource group.
    - domain_name: (Required) The domain name for the AAD DS instance.
    - sku: (Required) The SKU for the AAD DS instance, such as "Standard" or "Premium".
    - filtered_sync_enabled: (Optional) Whether filtered sync is enabled for the AAD DS instance. Defaults to false.
    - domain_configuration_type: (Optional) The type of domain configuration, such as "FullySynced". Defaults to "FullySynced".
    - initial_replica_set: (Optional) An object defining the initial replica set for the AAD DS instance, including region and subnet details.
      - region: (Required) The Azure region where the initial replica set will be created.
      - subnet: (Required) An object defining the subnet details for the initial replica set, including the virtual network key and subnet key.
        - vnet_key: (Required) The key of the virtual network in which the initial replica set's subnet is located.
        - key: (Required) The key of the subnet in which the initial replica set will be created.
        - id: (Optional) The ID of the subnet if it is already created and you want to use it directly.
    - notifications: (Optional) An object defining notification settings for the AAD DS instance, such as additional recipients and whether to notify DC admins or global admins.
      - additional_recipients: (Optional) A list of additional email addresses to notify about AAD DS instance events.
      - notify_dc_admins: (Optional) Whether to notify domain controller administrators about AAD DS instance events. Defaults to false.
      - notify_global_admins: (Optional) Whether to notify global administrators about AAD DS instance events. Defaults to false.
    - security: (Optional) An object defining security settings for the AAD DS instance, such as whether to sync Kerberos passwords, NTLM passwords, and on-premises passwords.
      - sync_kerberos_passwords: (Optional) Whether to sync Kerberos passwords. Defaults to true.
      - sync_ntlm_passwords: (Optional) Whether to sync NTLM passwords. Defaults to true.
      - sync_on_prem_passwords: (Optional) Whether to sync on-premises passwords. Defaults to true.
    - tags: (Optional) A map of tags to be applied to the AAD DS instance.

  - active_directory_domain_service_replica_set: (Optional) A map of AAD DS replica sets, where each key is a unique identifier for the replica set and the value is an object containing the replica set settings.
    - region: (Optional) The Azure region where the replica set will be created. If not defined, it defaults to the region of the AAD DS instance.
    - active_directory_domain_service: (Required) An object containing the key of the AAD DS instance that this replica set belongs to.
      - key: (Required) The key of the AAD DS instance in which the replica set will be created.
    - subnet: (Required) An object defining the subnet details for the replica set, including the virtual network key and subnet key.
      - vnet_key: (Required) The key of the virtual network in which the replica set's subnet is located.
      - key: (Required) The key of the subnet in which the replica set will be created.
      - id: (Optional) The ID of the subnet if it is already created and you want to use it directly.

  DESCRIPTION
  /*type = object({
    active_directory_domain_service = optional(map(object({
      name                      = string
      location                  = optional(string)
      resource_group_key        = optional(string)
      domain_name               = string
      sku                       = string
      filtered_sync_enabled     = optional(bool, false)
      domain_configuration_type = optional(string, "FullySynced")
      initial_replica_set = optional(map(object({
        region = string
        subnet = object({
          vnet_key = optional(string)
          key      = optional(string)
          id       = optional(string)
        })
      })), {})
      notifications = optional(object({
        additional_recipients = optional(list(string), [])
        notify_dc_admins      = optional(bool, false)
        notify_global_admins  = optional(bool, false)
      }), {})
      security = optional(object({
        sync_kerberos_passwords = optional(bool, true)
        sync_ntlm_passwords     = optional(bool, true)
        sync_on_prem_passwords  = optional(bool, true)
      }), {})
      tags = optional(map(string), {})
    })))
    active_directory_domain_service_replica_set = optional(map(object({
      region = optional(string)
      active_directory_domain_service = object({
        key = string
      })
      subnet = object({
        vnet_key = optional(string)
        key      = optional(string)
        id       = optional(string)
      })
    })), {})
  })*/
  type = any

  default = {}
}

variable "aadb2c" {
  description = <<DESCRIPTION
  Configuration object - AAD B2C resources
  - aadb2c_directory = Configuration object - AAD B2C directory resources
    - country_code - (Optional) The country code for the AAD B2C directory. This is optional and can be set to null.
    - data_residency_location - (Required) The data residency location for the AAD B2C directory. This is required and cannot be null.
    - display_name - (Optional) The display name for the AAD B2C directory. This is optional and can be set to null.
    - domain_name - (Required) The domain name for the AAD B2C directory. This is required and cannot be null.
    - resource_group_name - (Required if resource_group_key or resource_group is not set) The name of the resource group in which the AAD B2C directory will be created. This is required and cannot be null.
    - sku_name - (Required) The SKU name for the AAD B2C directory. This is required and cannot be null.
    - tags - (Optional) A mapping of tags which should be assigned to the AAD B2C Directory.
    - resource_group_key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
    - resource_group - (Optional) The resource group object in which the AAD B2C directory will be created. This is optional and can be set to null.
      - lz_key - (Optional) The key of the landing zone in which the AAD B2C directory will be created. This is optional and can be set to null.
      - key - (Optional) The key of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
      - name - (Optional) The name of the resource group in which the AAD B2C directory will be created. This is optional and can be set to null.
  DESCRIPTION
  default     = {}
  type = object({
    aadb2c_directory = optional(map(object({
      country_code            = optional(string)
      data_residency_location = string
      display_name            = optional(string)
      domain_name             = string
      resource_group_name     = optional(string)
      sku_name                = string
      tags                    = optional(map(string))
      resource_group_key      = optional(string)
      resource_group = optional(object({
        lz_key = optional(string)
        key    = optional(string)
        name   = optional(string)
      }))
    })), {})
  })
  sensitive = false
  validation {
    # Check if aadb2c_directory is null, empty OR if all keys within each directory object are valid.
    condition = var.aadb2c.aadb2c_directory == null || var.aadb2c.aadb2c_directory == {} || alltrue([
      for dir_key, dir_value in try(var.aadb2c.aadb2c_directory, {}) :
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
    error_message = "One or more entries in aadb2c.aadb2c_directory contain unsupported attributes. Allowed attributes are: country_code, data_residency_location, display_name, domain_name, resource_group_name, sku_name, tags, resource_group_key, resource_group."
  }
}

variable "pim" {
  description = "Configuration object for PIM (Privileged Identity Management) resources."
  type        = any
  default     = {}
}
