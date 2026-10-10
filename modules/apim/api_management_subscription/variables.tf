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
Settings for an API Management subscription. display_name is required.
Optional provider arguments include api_id, user_id, primary_key,
secondary_key, subscription_id, state, allow_tracing, and timeouts. state
defaults to submitted and allow_tracing defaults to true. Only one of api_id
and the resolved product_id may be set; if neither is set the subscription
uses the service-wide API scope. api_management, resource_group, and product
references are retained for root-module dependency resolution.
DESCRIPTION
  type = object({
    display_name    = string
    api_id          = optional(string)
    user_id         = optional(string)
    primary_key     = optional(string)
    secondary_key   = optional(string)
    subscription_id = optional(string)
    state           = optional(string, "submitted")
    allow_tracing   = optional(bool, true)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    product = optional(object({
      key        = optional(string)
      lz_key     = optional(string)
      product_id = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = contains([
      "active",
      "cancelled",
      "expired",
      "rejected",
      "submitted",
      "suspended"
    ], var.settings.state)
    error_message = "state must be active, cancelled, expired, rejected, submitted, or suspended."
  }
}

variable "remote_objects" {
  description = "Remote objects used by the root module to resolve API Management, resource-group, and product references."
  type        = any
  default     = {}
}

variable "api_management_name" {
  description = "The name of the API Management service."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group containing the API Management service."
  type        = string
}

variable "product_id" {
  description = "Optional resolved API Management product ID. Cannot be set together with settings.api_id."
  type        = string
  default     = null
}
