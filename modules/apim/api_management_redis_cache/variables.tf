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

Registers an external Redis cache with APIM; does not provision Redis itself.
All attribute paths below are relative to settings.
- name (Required string): non-empty CAF naming seed for the APIM registration.
- connection_string (Optional string, default null): direct connection string
  for the backing cache, including endpoint/TLS/authentication settings. A
  non-empty direct value wins over the managed cache's primary_connection_string.
  If omitted/null, redis_cache.key must select an object exposing that output.
  The resource input is marked sensitive, is never exported by this module,
  and still exists in Terraform state; do not commit credentials.
- api_management_id (Optional string, default null): direct service ARM ID.
- api_management (Optional object, default null): alternative service reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The service must resolve: first non-empty api_management_id, alias.id,
  then the referenced object's id. Explicit IDs override key lookups.
- cache_location (Optional string, module default default): APIM region where
  this cache is used, either default or a valid Azure region. This is cache
  selection, not the resource's deployment location. Both omission and explicit
  null use the literal default; a supplied region is passed unchanged.
- description (Optional string, default null): registration description;
  omission/null delegates the unset value to the provider.
- redis_cache_id (Optional string, default null): explicit backing Redis ARM ID;
  unlike the connection string, this metadata can be omitted entirely.
- redis_cache (Optional object, default null): backing-cache dependency.
  - redis_cache.id (Optional string, default null): backing Redis ARM ID.
  - redis_cache.key (Optional string, default null): key in remote_objects.redis_caches;
    required when connection_string is omitted/null, otherwise optional.
  - redis_cache.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Backing-ID precedence is first non-empty redis_cache_id, redis_cache.id,
  then remote object's id; if none resolves it remains null. Connection-string
  resolution independently prefers connection_string, then the keyed object's
  primary_connection_string. An ID alone cannot supply credentials. Both
  connection sources absent fails input validation; a supplied key must exist.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): register cache; default 30m.
  - timeouts.read (Optional duration string): retrieve registration; default 5m.
  - timeouts.update (Optional duration string): change registration; default 30m.
  - timeouts.delete (Optional duration string): unregister cache; default 30m.
DESCRIPTION
  type = object({
    name              = string
    connection_string = optional(string)
    api_management_id = optional(string)
    cache_location    = optional(string, "default")
    description       = optional(string)
    redis_cache_id    = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    redis_cache = optional(object({
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
  validation {
    condition     = var.settings.connection_string != null || try(var.settings.redis_cache.key, null) != null
    error_message = "Supply connection_string or redis_cache.key referencing an object with primary_connection_string."
  }
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
