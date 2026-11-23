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
Configure the policy applied to one API operation. Attributes are optional in
the type and default to null, but api_operation must supply id or key.
The settings object itself is required. Leaf fields are strings unless another
type is stated; reference members are optional/null unless marked required.

- api_operation: target-operation reference. id is a direct logical operation
  identifier, not an ARM resource ID. key selects
  remote_objects.api_management_api_operation[lz_key][key]; lz_key defaults to
  client_config.landingzone_key. The referenced object's operation_id wins;
  otherwise the child extracts the final operation segment from its ARM id,
  then falls back to its unqualified id, then the explicit api_operation.id.
  Thus a resolved key takes precedence when both key and id are supplied.
- xml_content: literal XML policy document. xml_link: publicly accessible URL of
  an XML policy document. Supply one source, not both; source checks belong to
  the provider.
- api, api_management, resource_group: CAF references resolved by the root into
  the separate api_name, api_management_name, and resource_group_name inputs.
  For each, name is a direct name preferred over key, key selects the matching
  combined collection, and lz_key selects a landing zone (current zone when
  omitted). id is accepted reference metadata, not a substitute for these
  name-based inputs. These three objects are not resolved inside this child.
- timeouts: optional operation duration strings. create limits policy creation,
  read limits retrieval, update limits XML changes, and delete limits removal.
  Each field defaults to null, leaving that provider timeout in control.
Undeclared attributes are discarded by the settings object type.
  DESCRIPTION
  type = object({
    api_operation = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
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
    condition     = try(var.settings.api_operation.id, null) != null || try(var.settings.api_operation.key, null) != null
    error_message = "settings.api_operation must be provided with either id or key so that operation_id can be resolved."
  }
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
variable "api_management_name" {
  description = " The name of the API Management Service. Changing this forces a new resource to be created."
}
variable "api_name" {
  description = " The name of the API."
}
variable "resource_group_name" {
  description = " The name of the Resource Group in which the API Management Service exists. Changing this forces a new resource to be created."
}
