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

Reusable policy fragment stored in an APIM service. Paths are relative to settings.
- name (Required string): non-empty CAF naming seed for the fragment. Use the
  generated name output, rather than the seed, in include-fragment policies.
- value (Required string): fragment XML content in the representation selected
  by format. It is passed unchanged; creating it does not attach it to a policy.
- format (Optional string, module default xml): supported values xml and rawxml.
  Both omission and explicit null use xml. Match value to this representation;
  changing format can change the provider's returned value and otherwise cause
  persistent differences if the content representation is incorrect.
- description (Optional string, default null): explanation of the fragment;
  omission/null delegates the unset value to the provider.
- api_management_id (Optional string, default null): direct service ARM ID.
- api_management (Optional object, default null): alternative parent reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The parent must resolve: first non-empty api_management_id, alias.id,
  then the referenced object's id. Explicit IDs override key lookups.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): create fragment; default 30m.
  - timeouts.read (Optional duration string): retrieve fragment; default 5m.
  - timeouts.update (Optional duration string): change fragment; default 30m.
  - timeouts.delete (Optional duration string): remove fragment; default 30m.
DESCRIPTION
  type = object({
    name              = string
    value             = string
    format            = optional(string, "xml")
    description       = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
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
variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
