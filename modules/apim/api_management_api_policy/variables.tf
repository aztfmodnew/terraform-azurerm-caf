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
Configure the policy applied to an entire API, rather than one operation.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.
All settings attributes are optional and default to null. The provider requires
one policy source; supply xml_content or xml_link, not both.

- xml_content: literal XML policy document, including its policies element.
- xml_link: publicly accessible URL from which the provider retrieves policy XML.
- api, api_management, resource_group: optional CAF references used by the root
  to supply the separate api_name, api_management_name, and resource_group_name
  inputs. In each object, name is a direct resource name; key selects the
  corresponding combined CAF collection; lz_key selects its landing zone and
  defaults to the current zone in root lookups. A direct name takes precedence
  over a key lookup. id is retained reference metadata, not used to resolve
  these name-based child inputs. This child does not resolve those objects.
- timeouts: optional operation duration overrides. create limits policy creation,
  read limits retrieval, update limits replacement of policy XML, and delete
  limits policy removal. Each is an optional duration string, such as "30m";
  omitted/null values leave the corresponding provider timeout unchanged.
Undeclared attributes are discarded by the settings object type.
  DESCRIPTION
  type = object({
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
variable "api_name" {
  description = " The name of the API"
}
variable "api_management_name" {
  description = " The name of the API Management Service. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The name of the Resource Group in which the API Management Service exists. Changing this forces a new resource to be created."
}
