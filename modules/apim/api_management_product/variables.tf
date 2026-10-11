variable "global_settings" {
  description = "Global settings object used by the API Management configuration."
  type        = any
}

variable "client_config" {
  description = "Client configuration, including the current landing-zone key."
  type = object({
    landingzone_key = string
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

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "product_id",
      "display_name",
      "published",
      "subscription_required",
      "approval_required",
      "subscriptions_limit",
      "description",
      "terms",
      "api_management",
      "resource_group",
      "resource_group_key",
      "resource_group_name",
      "policy",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management product settings."
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
