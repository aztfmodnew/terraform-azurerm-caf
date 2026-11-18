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

Associates an APIM certificate authority with a gateway. Paths are relative to settings.
- api_management_id (Optional string, default null): direct service ARM ID.
- api_management (Optional object, default null): alternative service reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The service ID must resolve: first non-empty api_management_id, alias.id,
  then the referenced service object's id.
- certificate_name (Optional string, default null): actual existing APIM
  certificate resource name, not a Key Vault URI or certificate thumbprint.
- certificate (Optional object, default null): alternative APIM certificate reference.
  - certificate.name (Optional string, default null): short APIM certificate name.
  - certificate.id (Optional string, default null): APIM certificate ARM ID;
    its final segment supplies the name.
  - certificate.key (Optional string, default null): key in remote_objects.api_management_certificate.
  - certificate.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
- gateway_name (Optional string, default null): actual existing gateway name.
- gateway (Optional object, default null): alternative gateway reference.
  - gateway.name (Optional string, default null): short gateway resource name.
  - gateway.id (Optional string, default null): gateway ARM ID; use its final segment.
  - gateway.key (Optional string, default null): key in remote_objects.api_management_gateway.
  - gateway.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  Both names must resolve. For each, the first non-empty direct *_name wins,
  followed by alias.name, alias.id final segment, remote object's name, then
  its id final segment. All three parents must belong to the same APIM service.
- is_trusted (Optional bool, default null): true trusts this authority on the
  gateway; false explicitly disables trust. Omission/null is passed through
  to the provider; the module does not choose a trust default.
- timeouts (Optional object, default null): operation-duration overrides;
  omission/null emits no block and null members retain provider defaults.
  - timeouts.create (Optional duration string): associate authority; default 30m.
  - timeouts.read (Optional duration string): retrieve association; default 5m.
  - timeouts.update (Optional duration string): change trust; default 30m.
  - timeouts.delete (Optional duration string): remove association; default 30m.
DESCRIPTION
  type = object({
    api_management_id = optional(string)
    certificate_name  = optional(string)
    gateway_name      = optional(string)
    is_trusted        = optional(bool)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    certificate = optional(object({
      name   = optional(string)
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    gateway = optional(object({
      name   = optional(string)
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
