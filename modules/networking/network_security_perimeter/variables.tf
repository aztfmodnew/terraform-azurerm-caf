variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "The location of the resource."
  type        = string
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
  Network security perimeter settings (AzAPI, Microsoft.Network API 2025-07-01).
    - name - Required perimeter name; used unchanged to preserve existing resource names.
    - location, tags - Optional perimeter location and tags.
    - resource_group, resource_group_key, region - Optional CAF root resource group references.
    - profiles - Optional map of profiles with a required name.
    - access_rules - Optional map with name, direction (Inbound/Outbound), and profile_key or profile_id.
      Rule properties: address_prefixes, fully_qualified_domain_names, subscriptions (objects with id),
      email_addresses, phone_numbers, service_tags. The last three are reserved by the API and unavailable.
    - resource_associations - Optional map with name, access_mode (Audit/Enforced/Learning),
      profile_key or profile_id, and private_link_resource_id or a CAF reference to storage_account,
      keyvault, event_hub_namespace, cosmos_db, or mssql_server (key and optional lz_key).
      The legacy event_hub reference remains accepted.
      network_security_perimeter_id optionally overrides the parent perimeter.
    - links - Optional map with name, auto_approved_remote_perimeter_resource_id, description
      (at most 140 characters), local_inbound_profiles, and remote_inbound_profiles.
    - link_references - Optional map with name, used to read references created automatically by Azure.
    - diagnostic_profiles - Optional diagnostic profiles passed to the shared diagnostics module.
    - logging_configurations - Optional map with name, enabled_log_categories, version and timeouts.
    - timeouts - Optional create/read/update/delete durations; also supported on each managed child.
    Legacy child location/tags inputs remain accepted but are not sent: the API does not support them.
  DESCRIPTION
  type = object({
    name               = string
    location           = optional(string)
    region             = optional(string)
    tags               = optional(map(string))
    resource_group_key = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
    }))
    diagnostic_profiles = optional(any)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    profiles = optional(map(object({
      name     = string
      location = optional(string)
      tags     = optional(map(string))
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    access_rules = optional(map(object({
      name                         = string
      direction                    = string
      profile_key                  = optional(string)
      profile_id                   = optional(string)
      location                     = optional(string)
      tags                         = optional(map(string))
      address_prefixes             = optional(list(string))
      fully_qualified_domain_names = optional(list(string))
      email_addresses              = optional(list(string))
      phone_numbers                = optional(list(string))
      service_tags                 = optional(list(string))
      subscriptions                = optional(list(object({ id = string })))
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    resource_associations = optional(map(object({
      name                          = string
      access_mode                   = string
      network_security_perimeter_id = optional(string)
      profile_key                   = optional(string)
      profile_id                    = optional(string)
      private_link_resource_id      = optional(string)
      location                      = optional(string)
      tags                          = optional(map(string))
      storage_account               = optional(object({ key = string, lz_key = optional(string) }))
      keyvault                      = optional(object({ key = string, lz_key = optional(string) }))
      event_hub                     = optional(object({ key = string, lz_key = optional(string) }))
      event_hub_namespace           = optional(object({ key = string, lz_key = optional(string) }))
      cosmos_db                     = optional(object({ key = string, lz_key = optional(string) }))
      mssql_server                  = optional(object({ key = string, lz_key = optional(string) }))
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    links = optional(map(object({
      name                                       = string
      auto_approved_remote_perimeter_resource_id = optional(string)
      description                                = optional(string)
      local_inbound_profiles                     = optional(list(string))
      remote_inbound_profiles                    = optional(list(string))
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    link_references = optional(map(object({
      name     = string
      timeouts = optional(object({ read = optional(string) }))
    })), {})
    logging_configurations = optional(map(object({
      name                   = string
      enabled_log_categories = optional(list(string))
      version                = optional(string)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
  })

  validation {
    condition = alltrue([
      for rule in try(var.settings.access_rules, {}) :
      contains(["Inbound", "Outbound"], try(rule.direction, ""))
    ])
    error_message = "Each access rule must specify direction as Inbound or Outbound."
  }

  validation {
    condition = alltrue([
      for association in try(var.settings.resource_associations, {}) :
      contains(["Audit", "Enforced", "Learning"], try(association.access_mode, ""))
    ])
    error_message = "Each resource association must specify access_mode as Audit, Enforced or Learning."
  }

  validation {
    condition = alltrue([
      for link in try(var.settings.links, {}) :
      try(link.description, null) == null ? true : length(link.description) <= 140
    ])
    error_message = "A perimeter link description must not exceed 140 characters."
  }
}
