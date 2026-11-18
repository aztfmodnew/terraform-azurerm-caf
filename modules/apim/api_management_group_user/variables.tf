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

Assigns an existing APIM user to an existing group. Paths are relative to settings.
- user_id (Optional string, default null): direct logical APIM user identifier
  or full user ARM ID. The final path segment is sent to AzureRM; logical IDs
  without slashes are unchanged. The resulting identifier must contain only
  alphanumeric characters, underscores or dashes and be at most 80 characters.
- user (Optional object, default null): alternative user dependency.
  - user.id (Optional string, default null): logical user identifier or user
    ARM ID, normalized in the same way as user_id.
  - user.key (Optional string, default null): key in remote_objects.api_management_user.
  - user.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A user must resolve. The first non-empty user_id wins, then user.id, then
  remote object's id; only after this selection is the final segment extracted.
- group_name (Optional string, default null): direct existing APIM group name.
- group (Optional object, default null): alternative APIM group reference.
  - group.name (Optional string, default null): short group resource name.
  - group.id (Optional string, default null): APIM group ARM ID; use its final segment.
  - group.key (Optional string, default null): key in remote_objects.api_management_group.
  - group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- api_management_name (Optional string, default null): direct APIM service name.
- api_management (Optional object, default null): alternative service reference.
  - api_management.name (Optional string, default null): short service name.
  - api_management.id (Optional string, default null): service ARM ID; use its final segment.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- resource_group_name (Optional string, default null): direct parent group name.
- resource_group (Optional object, default null): alternative resource-group reference.
  - resource_group.name (Optional string, default null): resource group name.
  - resource_group.id (Optional string, default null): resource-group ARM ID;
    its final segment is used.
  - resource_group.key (Optional string, default null): key in remote_objects.resource_groups.
  - resource_group.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Group/APIM names must resolve: first non-empty direct *_name, alias.name,
  alias.id final segment, remote name, then remote id final segment. Resource
  group precedence is direct name, alias.name, alias.id final segment,
  var.resource_group.name, then remote group.name. User/group must share APIM.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): add membership; default 30m.
  - timeouts.read (Optional duration string): retrieve membership; default 5m.
  - timeouts.delete (Optional duration string): remove membership; default 30m.
  There is no update timeout; changing the association replaces it.
DESCRIPTION
  type = object({
    user_id             = optional(string)
    group_name          = optional(string)
    api_management_name = optional(string)
    resource_group_name = optional(string)
    user = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    group = optional(object({
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
