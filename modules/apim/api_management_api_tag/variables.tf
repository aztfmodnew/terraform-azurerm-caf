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

Associates an existing service-level tag with an API; it creates neither parent.
All attribute paths below are relative to settings.
- api_id (Optional string, default null): direct parent API ARM ID.
- api (Optional object, default null): alternative API reference.
  - api.id (Optional string, default null): full API ARM ID.
  - api.key (Optional string, default null): key in remote_objects.api_management_api.
  - api.lz_key (Optional string, default null): zone for api.key; omission/null
    uses client_config.landingzone_key.
  An API must resolve. Precedence is first non-empty api_id, api.id, then the
  referenced API object's id; a direct ID overrides any key reference.
- name (Optional string, default null): actual existing service tag name,
  not its display_name and not a CAF naming seed.
- tag (Optional object, default null): alternative existing service tag reference.
  - tag.name (Optional string, default null): actual short tag name.
  - tag.id (Optional string, default null): service tag ARM ID; its final
    segment is used as the name.
  - tag.key (Optional string, default null): key in remote_objects.api_management_tag.
  - tag.lz_key (Optional string, default null): zone for tag.key; omission/null
    uses client_config.landingzone_key.
  A tag name must resolve. Precedence is first non-empty name, tag.name,
  tag.id final segment, referenced object's name, then its id final segment.
  The resolved name is never regenerated; API and tag must share an APIM service.
- timeouts (Optional object, default null): custom durations; omission/null
  emits no block and null members leave the provider defaults unchanged.
  - timeouts.create (Optional duration string): attach the tag; default 30m.
  - timeouts.read (Optional duration string): retrieve the association; default 5m.
  - timeouts.delete (Optional duration string): detach the tag; default 30m.
  There is no update timeout because the association is replaced when changed.
DESCRIPTION
  type = object({
    api_id = optional(string)
    name   = optional(string)
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    tag = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
