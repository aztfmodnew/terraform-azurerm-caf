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
Define a group used to organize API Management users and product access.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): group-name input processed by CAF naming.
- display_name (required string): human-readable group label.
- description (optional string): explanatory text about group membership/purpose.
- type (optional string): custom for an APIM-managed group, external for a group
  backed by an external directory, or system for a built-in group. Omission/null
  is passed through; the provider defaults to custom. Changing type recreates
  the group.
- external_id (optional string): external directory group identifier, commonly
  aad://<tenant>/groups/<object-id>, for external membership.
- api_management (optional object, required by validation): owning service
  reference. key selects remote_objects.api_management[lz_key][key]; name is a
  direct service name. Its optional lz_key defaults to the current landing zone.
  Resolution tries the selected zone's key, the current zone's key, then name.
- resource_group (optional object): owning service's group reference. key selects
  remote_objects.resource_group[lz_key][key], name is a direct group name, and
  lz_key selects its zone with a current-zone fallback. Optional id is accepted
  metadata but is not used by this name lookup. resource_group_key is the
  optional legacy key used only when resource_group.key is null. Lookup tries
  the selected zone, then current zone, then direct name. Validation requires
  a group key, legacy key, or direct name.
- timeouts (optional object): create limits group creation, read limits retrieval,
  update limits membership-group metadata changes, and delete limits removal.
  Each field is an optional duration string; null preserves provider timeouts.
All optional fields remain null unless a lookup fallback is described.
Undeclared attributes are discarded by the settings object type.
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
    condition     = var.settings.type == null || contains(["custom", "external", "system"], var.settings.type)
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
