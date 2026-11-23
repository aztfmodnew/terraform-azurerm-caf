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

Adds an existing API to an existing product. Paths below are relative to settings.
- api_name (Optional string, default null): direct short API resource name.
- api (Optional object, default null): alternative API dependency.
  - api.name (Optional string, default null): short API resource name.
  - api.id (Optional string, default null): API ARM ID; use its final segment.
  - api.key (Optional string, default null): key in remote_objects.api_management_api.
  - api.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  An API name must resolve: first non-empty api_name, alias.name, alias.id final
  segment, remote object's name, then its id final segment.
- product_id (Optional string, default null): direct short product identifier,
  not its ARM ID or display label; passed unchanged to the association.
- product (Optional object, default null): alternative product dependency.
  - product.product_id (Optional string, default null): short product identifier.
  - product.name (Optional string, default null): alias for the short product
    identifier, not display_name.
  - product.id (Optional string, default null): product ARM ID; its final segment
    is converted to the short identifier.
  - product.key (Optional string, default null): key in remote_objects.api_management_product.
  - product.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A product must resolve: first non-empty product_id, product.product_id,
  product.name, product.id final segment, remote product_id, then remote id
  final segment. Remote display_name/name is not used as a product identifier.
- api_management_name (Optional string, default null): direct APIM service name.
- api_management (Optional object, default null): alternative service dependency.
  - api_management.name (Optional string, default null): short service name.
  - api_management.id (Optional string, default null): service ARM ID; use its final segment.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative group dependency.
  - resource_group.name (Optional string, default null): resource group name.
  - resource_group.id (Optional string, default null): group ARM ID; use its final segment.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Service/group must resolve. Service precedence is direct name, alias.name,
  alias.id final segment, remote name, remote id final segment. Group precedence
  is direct name, alias.name, alias.id final segment, var.resource_group.name,
  then remote group.name. First non-empty wins. API/product must share APIM;
  do not manage this same association through an embedded parent list.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members leave provider defaults.
  - timeouts.create (Optional duration string): attach API; default 30m.
  - timeouts.read (Optional duration string): retrieve association; default 5m.
  - timeouts.delete (Optional duration string): detach API; default 30m.
  There is no update timeout; changes replace the association.
DESCRIPTION
  type = object({
    api_name            = optional(string)
    product_id          = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    api = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    product = optional(object({
      product_id = optional(string)
      id         = optional(string)
      name       = optional(string)
      key        = optional(string)
      lz_key     = optional(string)
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
      delete = optional(string)
    }))
  })
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
