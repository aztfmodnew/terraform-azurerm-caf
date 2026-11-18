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
Create a user account in the service supplied through api_management_name.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- user_id (required string): stable logical user identifier within the service,
  not the full ARM ID returned by the module.
- email (required string): account email address.
- first_name / last_name (required strings): the user's given and family names.
- confirmation (optional string): invite sends an invitation; signup sends an
  email requesting account confirmation.
- note (optional string): administrator-visible account note.
- password (optional sensitive string): account password when managing it
  explicitly; consider Terraform state exposure before providing it.
- state (optional string): active permits access, blocked prevents access, and
  pending represents an unconfirmed account. A pending account can become
  active or blocked; the reverse transition to pending is not supported.
- api_management / resource_group (optional objects): CAF references consumed
  by the root to supply this child's separate service/group name inputs.
  In each object, name is a direct name preferred over key, key selects the
  matching combined collection, and lz_key selects its landing zone (current
  zone when omitted). resource_group_key is the optional legacy group lookup
  key; resource_group_name is the optional direct group-name fallback.
  For groups the root prefers resource_group.name, then resource_group_name,
  then lookup using resource_group_key before resource_group.key.
- timeouts (optional object): create limits account creation, read retrieval,
  update account changes, and delete account removal. Each field is an optional
  duration string and leaves the provider timeout in control when null.
All optional settings default to null; confirmation, password, and state do not
have module-supplied defaults. Undeclared attributes are discarded by the type.
DESCRIPTION
  type = object({
    user_id      = string
    email        = string
    first_name   = string
    last_name    = string
    confirmation = optional(string)
    note         = optional(string)
    password     = optional(string)
    state        = optional(string)
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
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = var.settings.confirmation == null ? true : contains([
      "invite",
      "signup"
    ], var.settings.confirmation)
    error_message = "confirmation must be invite or signup."
  }

  validation {
    condition = var.settings.state == null ? true : contains([
      "active",
      "blocked",
      "pending"
    ], var.settings.state)
    error_message = "state must be active, blocked, or pending."
  }
}

variable "remote_objects" {
  description = "Remote objects used by the root module to resolve API Management and resource-group references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
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
