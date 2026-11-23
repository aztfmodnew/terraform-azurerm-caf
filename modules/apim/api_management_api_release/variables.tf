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

Publishes a release for an API revision. All fields below are relative to settings.
- name (Required string): CAF naming seed for the release, not the API name.
  Supply a non-empty name; global naming rules produce the resource name.
- api_id (Optional string, default null): explicit API revision ARM ID.
  Include the revision suffix when targeting a particular revision.
- api (Optional object, default null): alternative parent API reference.
  - api.id (Optional string, default null): API revision ARM ID used when
    api_id is absent; this is not a short API name.
  - api.key (Optional string, default null): key in
    remote_objects.api_management_api[lz_key]; needed for key-based resolution.
  - api.lz_key (Optional string, default null): landing zone for api.key;
    omission/null uses client_config.landingzone_key.
  A parent must resolve. First non-empty api_id wins, then api.id, then the
  referenced object's id. Explicit IDs therefore override missing/stale keys.
- notes (Optional string, default null): release notes recorded by APIM;
  omission/null leaves the argument to the provider.
- timeouts (Optional object, default null): custom operation durations.
  Omission/null emits no block; individual null members retain provider defaults.
  - timeouts.create (Optional duration string): release creation; default 30m.
  - timeouts.read (Optional duration string): release retrieval; default 5m.
  - timeouts.update (Optional duration string): release modification; default 30m.
  - timeouts.delete (Optional duration string): release removal; default 30m.
DESCRIPTION
  type = object({
    name   = string
    api_id = optional(string)
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    notes = optional(string)
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
