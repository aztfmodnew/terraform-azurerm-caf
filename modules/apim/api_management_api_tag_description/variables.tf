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

Descriptive metadata on an API-level tag association. Paths are relative to settings.
- api_tag_id (Optional string, default null): direct ARM ID of the API/tag
  association, including /apis/<api>/tags/<tag>; not the service-level tag ID.
- api_tag (Optional object, default null): alternative association reference.
  - api_tag.id (Optional string, default null): full API/tag association ARM ID.
  - api_tag.key (Optional string, default null): key in remote_objects.api_management_api_tag.
  - api_tag.lz_key (Optional string, default null): zone containing that key;
    omission/null uses client_config.landingzone_key.
  The association must resolve. First non-empty api_tag_id wins, then
  api_tag.id, then the referenced object's id. Direct IDs override key lookups.
- description (Optional string, default null): description of the tag for this
  API; null/omission delegates the unset value to the provider.
- external_documentation_url (Optional string, default null): URL of external
  documentation describing the tag; the module neither fetches nor hosts it.
- external_documentation_description (Optional string, default null): explanatory
  label for that external documentation, independent of the tag description.
  Both external-documentation fields are passed through as null when unset;
  the module supplies no placeholder URL or text.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and each null member preserves the provider default.
  - timeouts.create (Optional duration string): create metadata; default 30m.
  - timeouts.read (Optional duration string): retrieve metadata; default 5m.
  - timeouts.update (Optional duration string): change metadata; default 30m.
  - timeouts.delete (Optional duration string): remove metadata; default 30m.
DESCRIPTION
  type = object({
    api_tag_id = optional(string)
    api_tag = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    description                        = optional(string)
    external_documentation_url         = optional(string)
    external_documentation_description = optional(string)
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
variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
