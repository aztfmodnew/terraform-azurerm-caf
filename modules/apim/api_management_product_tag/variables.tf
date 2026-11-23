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

Attaches an existing service-level tag to a product. Paths are relative to settings.
- api_management_product_id (Optional string, default null): direct short
  product identifier, despite the argument name; not the ARM ID or display
  label. This direct value is passed unchanged.
- product (Optional object, default null): alternative product reference.
  - product.product_id (Optional string, default null): short product identifier.
  - product.name (Optional string, default null): alias for the short product
    identifier, not its display_name.
  - product.id (Optional string, default null): product ARM ID; use its final segment.
  - product.key (Optional string, default null): key in remote_objects.api_management_product.
  - product.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A product must resolve: first non-empty api_management_product_id,
  product.product_id, product.name, product.id final segment, remote product_id,
  then remote id final segment. Remote display_name/name is not used.
- name (Optional string, default null): actual existing service tag name,
  not its display_name and not a CAF naming seed.
- tag (Optional object, default null): alternative service tag reference.
  - tag.name (Optional string, default null): actual short service tag name.
  - tag.id (Optional string, default null): service tag ARM ID; use its final segment.
  - tag.key (Optional string, default null): key in remote_objects.api_management_tag.
  - tag.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A tag name must resolve: first non-empty name, tag.name, tag.id final segment,
  remote name, then remote id final segment. The name is never regenerated.
- api_management_name (Optional string, default null): direct APIM service name.
- api_management (Optional object, default null): alternative service reference.
  - api_management.name (Optional string, default null): short service name.
  - api_management.id (Optional string, default null): service ARM ID; use its final segment.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative group reference.
  - resource_group.name (Optional string, default null): resource group name.
  - resource_group.id (Optional string, default null): group ARM ID; use its final segment.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Service/group must resolve. Service precedence is direct name, alias.name,
  alias.id final segment, remote name, remote id final segment. Group precedence
  is direct name, alias.name, alias.id final segment, var.resource_group.name,
  then remote group.name. First non-empty wins. Tag/product must share APIM;
  do not manage this association from another module or state.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): attach tag; default 30m.
  - timeouts.read (Optional duration string): retrieve association; default 5m.
  - timeouts.delete (Optional duration string): detach tag; default 30m.
  There is no update timeout; changing the association replaces it.
DESCRIPTION
  type = object({
    api_management_product_id = optional(string)
    name                      = optional(string)
    api_management_name       = optional(string)
    resource_group_name       = optional(string)
    product = optional(object({
      product_id = optional(string)
      id         = optional(string)
      name       = optional(string)
      key        = optional(string)
      lz_key     = optional(string)
    }))
    tag = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
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
