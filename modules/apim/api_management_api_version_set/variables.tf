variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
Undeclared attributes are ignored by Terraform's object type conversion.

API version-set configuration; paths below are relative to settings.
- name (Required string): CAF naming seed for the short version-set name.
  Azure names allow alphanumeric characters and dashes up to 80 characters;
  naming prefixes/suffixes must also fit the resulting name.
- display_name (Required string): human-readable version-set label.
- versioning_scheme (Required string): exactly Header, Query or Segment.
  Header reads a request header, Query reads a query parameter, and Segment
  reads a URL-path version segment. The module validates these values.
- description (Optional string, default null): version-set explanation;
  omission/null leaves the argument to the provider.
- version_header_name (Optional string, default null): request header carrying
  the version; must be non-empty when versioning_scheme is Header.
- version_query_name (Optional string, default null): request query parameter
  carrying the version; must be non-empty when versioning_scheme is Query.
  The module provides neither header nor query names automatically.
- api_management_name (Optional string, default null): direct APIM service name.
- api_management (Optional object, default null): alternative service reference.
  - api_management.name (Optional string, default null): short service name.
  - api_management.id (Optional string, default null): service ARM ID; its
    final segment supplies the name.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative group reference.
  - resource_group.name (Optional string, default null): group name.
  - resource_group.id (Optional string, default null): group ARM ID; its final
    segment supplies the name.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Both parents must resolve. Service precedence is first non-empty direct
  name, alias.name, alias.id final segment, remote name, then remote id final
  segment. Group precedence is direct name, alias.name, alias.id final segment,
  var.resource_group.name, then remote group.name.
- timeouts (Optional object, default null): custom operation durations;
  omission/null emits no block and null members preserve provider defaults.
  - timeouts.create (Optional duration string): create version set; default 30m.
  - timeouts.read (Optional duration string): retrieve version set; default 5m.
  - timeouts.update (Optional duration string): change version set; default 30m.
  - timeouts.delete (Optional duration string): remove version set; default 30m.
DESCRIPTION
  type = object({
    name                = string
    display_name        = string
    versioning_scheme   = string
    description         = optional(string)
    version_header_name = optional(string)
    version_query_name  = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition     = contains(["Header", "Query", "Segment"], var.settings.versioning_scheme)
    error_message = "versioning_scheme must be Header, Query, or Segment."
  }
  validation {
    condition     = var.settings.versioning_scheme != "Header" || try(length(var.settings.version_header_name) > 0, false)
    error_message = "Header versioning requires version_header_name."
  }
  validation {
    condition     = var.settings.versioning_scheme != "Query" || try(length(var.settings.version_query_name) > 0, false)
    error_message = "Query versioning requires version_query_name."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource."
  type        = any
  default     = null
}
variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
