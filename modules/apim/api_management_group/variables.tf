variable "global_settings" {
  description = <<DESCRIPTION
Global CAF settings, as produced by the root module. Supported attributes:
  - default_region, environment - (Optional) Default region key and environment name.
  - inherit_tags - (Optional) Whether resources inherit global tags. Defaults to false.
  - prefix, suffix, prefix_with_hyphen - (Optional) Naming prefix, suffix and hyphenated prefix.
  - prefixes, suffixes - (Optional) Naming prefix and suffix lists used by azurecaf.
  - random_length, random_seed - (Optional) Random suffix length (defaults to 0) and seed.
  - resource_types - (Optional) Additional azurecaf resource types. Defaults to [].
  - separator - (Optional) Naming separator. Defaults to "-".
  - passthrough, use_slug, clean_input - (Optional) azurecaf naming flags. Default to false, true and true.
  - regions - (Optional) Map of region keys to Azure region names.
  - tags - (Optional) Global tags.
DESCRIPTION
  type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool, false)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(string)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number, 0)
    random_seed        = optional(number)
    resource_types     = optional(list(string), [])
    separator          = optional(string, "-")
    passthrough        = optional(bool, false)
    regions            = optional(map(string))
    tags               = optional(map(string))
    use_slug           = optional(bool, true)
    clean_input        = optional(bool, true)
  })
}

variable "client_config" {
  description = <<DESCRIPTION
Client configuration, as produced by the root module. landingzone_key is required;
client_id, object_id, logged_aad_app_objectId, logged_user_objectId, subscription_id
and tenant_id are optional.
DESCRIPTION
  type = object({
    client_id               = optional(string)
    landingzone_key         = string
    logged_aad_app_objectId = optional(string)
    logged_user_objectId    = optional(string)
    object_id               = optional(string)
    subscription_id         = optional(string)
    tenant_id               = optional(string)
  })
}

variable "settings" {
  description = <<DESCRIPTION
Settings for an API Management group. name, display_name, and references to
api_management and resource_group are required. Dependency references support
direct names or local/remote keys. description and external_id are optional;
external_id is typically an Entra group reference such as aad://<tenant>/groups/<object-id>.
type accepts custom, external, or system and defaults to the provider's custom
value. All four provider timeouts are configurable. resource_group_key is
retained as a fallback for legacy CAF configurations.
DESCRIPTION
  type = object({
    name         = string
    display_name = string
    description  = optional(string)
    external_id  = optional(string)
    type         = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
      id     = optional(string)
    }))
    resource_group_key = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = try(contains(["custom", "external", "system"], var.settings.type), true)
    error_message = "type must be custom, external, or system."
  }

  validation {
    condition = try(var.settings.api_management.key, null) != null || try(
      var.settings.api_management.name,
      null
    ) != null
    error_message = "api_management must provide either a key reference or a direct name."
  }

  validation {
    condition = try(var.settings.resource_group.key, null) != null || try(
      var.settings.resource_group.name,
      null
    ) != null || try(var.settings.resource_group_key, null) != null
    error_message = "resource_group must provide a key, a direct name, or the legacy resource_group_key."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "display_name",
      "description",
      "external_id",
      "type",
      "api_management",
      "resource_group",
      "resource_group_key",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management group settings."
  }
}

variable "remote_objects" {
  description = "Remote API Management services and resource groups used to resolve references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
