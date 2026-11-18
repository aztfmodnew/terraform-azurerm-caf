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

Standalone workspace gateway configuration, not a self-hosted gateway registration.
All attribute paths below are relative to settings.
- name (Required string): CAF naming seed for the gateway. The generated Azure
  name must be 1-45 characters, start with a letter, end with a letter/number,
  and otherwise contain only letters, numbers or hyphens. Include all generated
  prefixes/suffixes in that limit; naming passthrough does not bypass Azure rules.
- location (Optional string, default null): direct Azure location for deployment.
  First non-empty location source wins: this field, var.location,
  global_settings.regions[region], var.resource_group.location, remote
  resource-group.location, then global_settings.regions[global_settings.default_region].
  A location must resolve; null/empty values fall through rather than selecting
  a provider default.
- region (Optional string, default null): symbolic key into global_settings.regions,
  not a literal Azure location; an absent/null/unresolved key falls through the
  location chain above.
- resource_group_name (Optional string, default null): direct deployment group name.
- resource_group (Optional object, default null): alternative deployment-group reference.
  - resource_group.name (Optional string, default null): group name.
  - resource_group.id (Optional string, default null): group ARM ID; use its final segment.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A group name must resolve: first non-empty resource_group_name, alias.name,
  alias.id final segment, var.resource_group.name, then remote group's name.
  A keyed group's location/tags may also be consumed through the chains described
  here, even when its name is explicitly supplied.
- backend_subnet_id (Optional string, default null): direct backend subnet ARM ID.
- subnet (Optional object, default null): alternative delegated subnet reference.
  - subnet.id (Optional string, default null): full backend subnet ARM ID.
  - subnet.vnet_key (Optional string, default null): VNet key in remote_objects.vnets;
    required together with subnet.key when resolving by key rather than ID.
  - subnet.key (Optional string, default null): subnet key within that VNet's
    subnets map; required together with subnet.vnet_key for key-based resolution.
  - subnet.lz_key (Optional string, default null): zone containing the VNet;
    omission/null uses client_config.landingzone_key.
  Subnet precedence is first non-empty backend_subnet_id, subnet.id, then
  remote_objects.vnets[lz_key][vnet_key].subnets[key].id. An unresolved optional
  subnet remains null. The subnet must satisfy Azure gateway delegation rules.
- virtual_network_type (Optional string, default null): External or Internal.
  Supply it together with a backend subnet input, or omit both; the module
  validates the pair. Null/omitted type plus no subnet leaves networking unset
  for the provider; explicit None is not a supported input value.
- tags (Optional map(string), default null): resource tags applied last, overriding
  inherited and module tags. Omission/null adds no settings tags; a module tag
  is still present. With base_tags=true merge order is global tags, remote group
  tags, caller group tags, module tag, then these settings tags. With false,
  only module/settings tags are included.
- sku (Required object): deployed gateway edition and unit count.
  - sku.name (Required string): only WorkspaceGatewayPremium is supported.
  - sku.capacity (Optional number, module default 1): deployed unit count; must
    be an integer of at least 1. Both omission and explicit null use 1.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members preserve provider defaults.
  - timeouts.create (Optional duration string): provision gateway; default 30m.
  - timeouts.read (Optional duration string): retrieve gateway; default 5m.
  - timeouts.update (Optional duration string): update gateway; default 30m.
  - timeouts.delete (Optional duration string): remove gateway; default 30m.
DESCRIPTION
  type = object({
    name                 = string
    location             = optional(string)
    region               = optional(string)
    resource_group_name  = optional(string)
    backend_subnet_id    = optional(string)
    virtual_network_type = optional(string)
    tags                 = optional(map(string))
    sku = object({
      name     = string
      capacity = optional(number, 1)
    })
    resource_group = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    subnet = optional(object({
      id       = optional(string)
      vnet_key = optional(string)
      key      = optional(string)
      lz_key   = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition = (var.settings.virtual_network_type != null) == (
      var.settings.backend_subnet_id != null ||
      try(var.settings.subnet.id, null) != null ||
      (try(var.settings.subnet.key, null) != null && try(var.settings.subnet.vnet_key, null) != null)
    )
    error_message = "virtual_network_type and a backend subnet (backend_subnet_id, subnet.id, or subnet.vnet_key/key) must be supplied together."
  }
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
variable "location" {
  description = "Location of the resource if different from the resource group."
  type        = string
  default     = null
}
variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
