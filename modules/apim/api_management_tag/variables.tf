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

Creates a service-level APIM tag, not an Azure resource tag or API association.
All attribute paths below are relative to settings.
- name (Required string): non-empty CAF naming seed for a resource name unique
  within the APIM service. Use the generated name output, not display_name,
  when associating this tag with APIs/products.
- display_name (Optional string, default null): human-readable tag label.
  Omission/null is passed through; the provider defaults it to the generated
  name. The module does not independently generate a display label.
- api_management_id (Optional string, default null): direct parent service ARM ID.
- api_management (Optional object, default null): alternative service reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The service must resolve: first non-empty api_management_id, alias.id,
  then remote object's id. Explicit IDs override key lookups.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members preserve provider defaults.
  - timeouts.create (Optional duration string): create service tag; default 30m.
  - timeouts.read (Optional duration string): retrieve tag; default 5m.
  - timeouts.update (Optional duration string): change tag label; default 30m.
  - timeouts.delete (Optional duration string): remove tag; default 30m.
DESCRIPTION
  type = object({
    name              = string
    display_name      = optional(string)
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
