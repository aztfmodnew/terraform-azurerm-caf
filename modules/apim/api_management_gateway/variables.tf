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
Register a self-hosted gateway and describe its physical deployment location.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): CAF naming input for the gateway resource.
- api_management (optional object): identifies the owning service; validation
  requires id or key. id is a direct service ARM ID. key selects
  remote_objects.api_management[lz_key][key]. Optional lz_key defaults to the
  current client_config.landingzone_key. Lookup precedence is the requested
  landing zone, then the current landing zone for the same key, then direct id.
  Its id/key/lz_key/name fields default to null; name is retained metadata and
  is not used by this ID-based child lookup.
- description (optional string): explanatory text about the gateway.
- location_data (required object): geographic information, not an Azure region
  used to deploy a managed resource. name is the required canonical location
  name; city is the optional city, district the optional state/province/district,
  and region the optional country or geographic region.
- resource_group (optional object): compatibility metadata, not used by this
  child. id identifies the group by ARM ID, name by literal name, key by CAF
  collection key, and lz_key by landing-zone key. resource_group_key is an
  optional legacy group-key field; neither reference changes the service.
- timeouts (optional object): create limits gateway registration, read limits
  retrieval, update limits changes, and delete limits removal. Every field is an
  optional duration string; null leaves that provider timeout unchanged.
Optional attributes remain null unless stated otherwise. Undeclared attributes
are discarded by the settings object type.
DESCRIPTION
  type = object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    description = optional(string)
    location_data = object({
      name     = string
      city     = optional(string)
      district = optional(string)
      region   = optional(string)
    })
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
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
    condition = try(var.settings.api_management.id, null) != null || try(
      var.settings.api_management.key,
      null
    ) != null
    error_message = "api_management must provide either an id or a key reference."
  }
}

variable "remote_objects" {
  description = "Remote API Management objects used to resolve gateway dependencies."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
