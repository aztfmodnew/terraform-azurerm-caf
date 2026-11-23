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

Singleton service-wide APIM policy, not an API/product/operation policy.
All attribute paths below are relative to settings.
- api_management_id (Optional string, default null): explicit service ARM ID.
- api_management (Optional object, default null): alternative parent reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The parent must resolve: first non-empty api_management_id, alias.id,
  then the referenced object's id. Explicit IDs override key lookups.
- xml_content (Optional string, default null): complete inline policy XML.
  The module passes the text unchanged; it does not read a file automatically.
- xml_link (Optional string, default null): publicly accessible URL serving the
  complete policy XML document; this is not a local filesystem path.
  Exactly one policy source must be non-null; both/neither fail input validation.
  The unselected source remains null. No policy is merged with existing XML:
  avoid duplicate ownership by an embedded APIM policy or another state.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members preserve provider defaults.
  - timeouts.create (Optional duration string): set service policy; default 30m.
  - timeouts.read (Optional duration string): retrieve policy; default 5m.
  - timeouts.update (Optional duration string): replace policy XML; default 30m.
  - timeouts.delete (Optional duration string): remove service policy; default 30m.
DESCRIPTION
  type = object({
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition     = (var.settings.xml_content != null) != (var.settings.xml_link != null)
    error_message = "Supply exactly one of xml_content and xml_link."
  }
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
