variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
Create a tag on the operation identified by the separate api_operation_id input.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): tag-name input processed by CAF naming; the generated
  value, rather than the unmodified input, becomes the provider resource name.
- display_name (required string): human-readable tag label shown to consumers.
- api_operation (optional object, null by default): root-level operation
  reference. id is a direct operation resource ID and wins over key; key selects
  the combined operation collection; lz_key selects its landing zone and
  defaults to the current zone when omitted. The root supplies the resulting
  ID through api_operation_id; this child does not resolve the object itself.
- timeouts (optional object): create limits tag creation, read limits retrieval,
  update limits changes, and delete limits removal. Each field is an optional
  duration string and defaults to null, preserving the provider timeout.
Undeclared attributes are discarded by the settings object type.
  DESCRIPTION
  type = object({
    name         = string
    display_name = string
    api_operation = optional(object({
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
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_operation_id" {
  description = "The ID of the API Management API Operation Tag."
  type        = string
}
