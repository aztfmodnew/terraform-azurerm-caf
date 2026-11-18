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

Reusable schema stored at APIM service scope. Paths below are relative to settings.
- schema_id (Required string): non-empty CAF naming seed for the short schema
  identifier within the service, not an ARM ID.
- type (Required string): schema content type; supported values are xml and json.
- value (Required string): schema document serialized as a string appropriate
  to type. It is passed unchanged; the module does not encode or convert XML/JSON.
- description (Optional string, default null): purpose of the schema;
  omission/null delegates the unset value to the provider.
- api_management_name (Optional string, default null): direct service name.
- api_management (Optional object, default null): alternative service reference.
  - api_management.name (Optional string, default null): short APIM service name.
  - api_management.id (Optional string, default null): service ARM ID; use its
    final segment as the service name.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative group reference.
  - resource_group.name (Optional string, default null): group name.
  - resource_group.id (Optional string, default null): group ARM ID; use its final segment.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Both parents must resolve. Service precedence is first non-empty direct name,
  alias.name, alias.id final segment, remote name, then remote id final segment.
  Group precedence is direct name, alias.name, alias.id final segment,
  var.resource_group.name, then remote group.name.
- timeouts (Optional object, default null): custom operation durations;
  omission/null emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): create schema; default 30m.
  - timeouts.read (Optional duration string): retrieve schema; default 5m.
  - timeouts.update (Optional duration string): change schema; default 30m.
  - timeouts.delete (Optional duration string): remove schema; default 30m.
DESCRIPTION
  type = object({
    schema_id           = string
    type                = string
    value               = string
    description         = optional(string)
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
