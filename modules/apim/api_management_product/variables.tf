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
Settings for an API Management product. product_id, display_name, and
published are required. subscription_required defaults to true. approval_required
and subscriptions_limit can only be set when subscriptions are required.
Optional policy settings create a product policy from exactly one of xml_file,
xml_content, or xml_link. When both xml_file and xml_content are set, xml_file
retains precedence for backwards compatibility. Policy and product timeouts
are configurable independently. api_management and resource_group references
are retained for root-module dependency resolution.
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
