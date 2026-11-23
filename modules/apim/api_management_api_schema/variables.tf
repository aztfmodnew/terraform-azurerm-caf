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

Schema document attached to an API. All paths below are relative to settings.
- schema_id (Required string): non-empty CAF naming seed for the schema's short
  identifier within the API; this is not a schema ARM ID.
- content_type (Required string): media type describing the schema document,
  for example application/vnd.oai.openapi.components+json. Select a payload
  representation appropriate to this media type; the module does not convert it.
- value (Optional string, default null): schema document serialized as a string.
- components (Optional string, default null): JSON-serialized type definitions
  for the Swagger/OpenAPI v2/v3 representation.
- definitions (Optional string, default null): JSON-serialized type definitions
  for the Swagger/OpenAPI v1 representation.
  Exactly one of value/components/definitions must be non-null; supplying none,
  all null, or multiple payload fields fails validation. Unselected fields are
  passed as null; payload strings are otherwise forwarded unchanged.
- api_name (Optional string, default null): direct short parent API name.
- api (Optional object, default null): alternative API dependency.
  - api.name (Optional string, default null): short API name.
  - api.id (Optional string, default null): API ARM ID; its final segment is used.
  - api.key (Optional string, default null): key in remote_objects.api_management_api.
  - api.lz_key (Optional string, default null): zone for api.key, defaulting on
    omission/null to client_config.landingzone_key.
- api_management_name (Optional string, default null): direct APIM service name.
- api_management (Optional object, default null): alternative service dependency.
  - api_management.name (Optional string, default null): short service name.
  - api_management.id (Optional string, default null): service ARM ID; use its
    final segment as the service name.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative group dependency.
  - resource_group.name (Optional string, default null): group name.
  - resource_group.id (Optional string, default null): group ARM ID; use its
    final segment as the group name.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  All three parents must resolve. API/APIM precedence is the first non-empty
  direct *_name, alias.name, alias.id final segment, remote object's name,
  then remote id final segment. Group precedence is direct name, alias.name,
  alias.id final segment, var.resource_group.name, then remote group.name.
- timeouts (Optional object, default null): overrides for operation durations;
  omission/null emits no block and null members leave provider defaults.
  - timeouts.create (Optional duration string): schema creation; default 30m.
  - timeouts.read (Optional duration string): schema retrieval; default 5m.
  - timeouts.update (Optional duration string): schema modification; default 30m.
  - timeouts.delete (Optional duration string): schema removal; default 30m.
DESCRIPTION
  type = object({
    schema_id           = string
    content_type        = string
    value               = optional(string)
    components          = optional(string)
    definitions         = optional(string)
    api_name            = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
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
    condition     = length([for payload in [var.settings.value, var.settings.components, var.settings.definitions] : payload if payload != null]) == 1
    error_message = "Exactly one of value, components, or definitions must be supplied."
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
