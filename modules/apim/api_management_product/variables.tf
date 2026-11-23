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
Bundle APIs into a published or unpublished product, optionally with its own
product-wide policy.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- product_id (required string): stable product identifier unique in the service;
  distinct from the full ARM ID returned by this module.
- display_name (required string): product label displayed to developers.
- published (required bool): whether the product is published for developers.
- subscription_required (optional bool): whether accessing included APIs requires
  a subscription. The module defaults omission/null to true.
- approval_required (optional bool): whether a new subscription needs approval;
  may only be set when subscription_required is true.
- subscriptions_limit (optional number): maximum simultaneous subscriptions per
  user to this product; may only be set when subscriptions are required.
- description (optional string): product description, which may contain HTML.
- terms (optional string): conditions developers must accept before subscribing.
- policy (optional object): omitted/null creates no embedded policy. xml_content
  supplies literal XML; xml_link supplies a public XML document URL; xml_file
  supplies a readable file relative to the Terraform configuration working
  directory. Choose the file/content source or link, not both. For compatibility,
  xml_file wins when both xml_file and xml_content are provided.
- policy.timeouts (optional object): independent duration overrides for embedded
  policy creation (create), retrieval (read), modification (update), and removal
  (delete). Each field is optional/null, preserving the provider timeout.
- timeouts (optional object): create limits product creation, read retrieval,
  update metadata changes, and delete product removal. Optional duration-string
  fields default to null and do not inherit policy.timeouts.
- api_management / resource_group (optional objects): root parent references;
  name supplies a direct name, key selects the corresponding combined CAF
  collection, and lz_key selects its landing zone (current zone when omitted).
  Direct names precede lookups. resource_group_name is the optional direct-name
  fallback after resource_group.name; resource_group_key is the optional legacy
  key preferred before resource_group.key in root group lookup. The root
  supplies the child's separate service/group name inputs.
Other optional values default to null for provider handling. Undeclared
attributes are discarded by the settings object type.
DESCRIPTION
  type = object({
    product_id            = string
    display_name          = string
    published             = bool
    subscription_required = optional(bool, true)
    approval_required     = optional(bool)
    subscriptions_limit   = optional(number)
    description           = optional(string)
    terms                 = optional(string)
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
    policy = optional(object({
      xml_file    = optional(string)
      xml_content = optional(string)
      xml_link    = optional(string)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = var.settings.subscription_required || var.settings.approval_required == null
    error_message = "approval_required can only be set when subscription_required is true."
  }

  validation {
    condition     = var.settings.subscription_required || var.settings.subscriptions_limit == null
    error_message = "subscriptions_limit can only be set when subscription_required is true."
  }

  validation {
    condition = var.settings.policy == null || (
      (
        try(var.settings.policy.xml_file, null) != null ||
        try(var.settings.policy.xml_content, null) != null
      ) != (try(var.settings.policy.xml_link, null) != null)
    )
    error_message = "policy must configure exactly one source: xml_file/xml_content or xml_link."
  }

  validation {
    condition = try(var.settings.policy.xml_file, null) == null || try(
      can(file("${path.cwd}/${var.settings.policy.xml_file}")),
      false
    )
    error_message = "policy.xml_file must point to a readable file relative to the Terraform configuration directory."
  }
}

variable "remote_objects" {
  description = "Remote objects used by the root module to resolve API Management and resource-group references."
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
