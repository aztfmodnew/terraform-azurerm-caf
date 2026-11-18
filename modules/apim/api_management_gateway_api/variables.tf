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
Make an API available through a self-hosted API Management gateway.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- api_management_gateway: optional object in the type, but validation requires
  a non-null id or key. id is a direct gateway ARM ID. key selects
  remote_objects.api_management_gateway[lz_key][key]. lz_key is optional and
  falls back to client_config.landingzone_key when omitted/null.
- api_management_api: optional object in the type, but validation requires a
  non-null id or key. id is a direct API ARM ID. key selects
  remote_objects.api_management_api[lz_key][key]. Its optional lz_key follows
  the same current-zone fallback.
  For both references, id, key, and lz_key default to null; a successfully
  resolved key takes precedence over a direct id. At least one source must
  resolve for each reference; direct IDs require no remote_objects entries.
- timeouts: optional duration overrides. create limits association creation,
  read limits retrieval, and delete limits detaching the API. Each field
  defaults to null, preserving the provider timeout. No update timeout exists.
Undeclared attributes are discarded by the settings object type.
DESCRIPTION
  type = object({
    api_management_gateway = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management_api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = try(var.settings.api_management_gateway.id, null) != null || try(
      var.settings.api_management_gateway.key,
      null
    ) != null
    error_message = "api_management_gateway must provide either an id or a key reference."
  }

  validation {
    condition = try(var.settings.api_management_api.id, null) != null || try(
      var.settings.api_management_api.key,
      null
    ) != null
    error_message = "api_management_api must provide either an id or a key reference."
  }
}

variable "remote_objects" {
  description = "Remote API Management APIs and gateways used to resolve references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
