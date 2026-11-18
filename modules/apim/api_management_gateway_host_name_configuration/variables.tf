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

TLS hostname binding on an APIM gateway. Paths below are relative to settings.
- name (Required string): non-empty CAF naming seed for the binding resource;
  independent of the public DNS hostname.
- host_name (Required string): DNS host served by the gateway, such as
  api.example.com. The TLS certificate must cover it; DNS is configured separately.
- api_management_id (Optional string, default null): direct service ARM ID.
- api_management (Optional object, default null): alternative service reference.
  - api_management.id (Optional string, default null): full service ARM ID.
  - api_management.key (Optional string, default null): key in remote_objects.api_management.
  - api_management.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  The service must resolve: first non-empty api_management_id, alias.id,
  then the referenced object's id.
- gateway_name (Optional string, default null): direct existing gateway name.
- gateway (Optional object, default null): alternative gateway reference.
  - gateway.name (Optional string, default null): short gateway name.
  - gateway.id (Optional string, default null): gateway ARM ID; use its final segment.
  - gateway.key (Optional string, default null): key in remote_objects.api_management_gateway.
  - gateway.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A gateway must resolve: direct gateway_name, alias.name, alias.id final
  segment, remote name, then remote id final segment; first non-empty wins.
- certificate_id (Optional string, default null): direct APIM certificate ARM
  ID used for TLS, not a Key Vault secret URI.
- certificate (Optional object, default null): alternative certificate reference.
  - certificate.id (Optional string, default null): full APIM certificate ARM ID.
  - certificate.key (Optional string, default null): key in remote_objects.api_management_certificate.
  - certificate.lz_key (Optional string, default null): zone for that key;
    omission/null uses client_config.landingzone_key.
  A certificate must resolve: first non-empty certificate_id, alias.id,
  then remote object's id. Certificate and gateway must share the APIM service.
- request_client_certificate_enabled (Optional bool, default null): true asks
  clients for a certificate; false disables the request. Omission/null is
  delegated to the provider; the module does not select a default.
- http2_enabled (Optional bool, module default true): enables HTTP/2 support;
  false disables it. Both omission and explicit null use the module's true default.
- tls10_enabled (Optional bool, default null): true permits legacy TLS 1.0;
  false disables it. Omission/null is passed to the provider without a module
  default; prefer explicit false for new deployments.
- tls11_enabled (Optional bool, default null): true permits legacy TLS 1.1;
  false disables it. Omission/null is passed to the provider without a module
  default; prefer explicit false for new deployments.
- timeouts (Optional object, default null): duration overrides; omission/null
  emits no block and null members preserve provider defaults.
  - timeouts.create (Optional duration string): create binding; default 30m.
  - timeouts.read (Optional duration string): retrieve binding; default 5m.
  - timeouts.update (Optional duration string): change binding/flags; default 30m.
  - timeouts.delete (Optional duration string): remove binding; default 30m.
DESCRIPTION
  type = object({
    name                               = string
    host_name                          = string
    api_management_id                  = optional(string)
    gateway_name                       = optional(string)
    certificate_id                     = optional(string)
    request_client_certificate_enabled = optional(bool)
    http2_enabled                      = optional(bool, true)
    tls10_enabled                      = optional(bool)
    tls11_enabled                      = optional(bool)
    api_management = optional(object({
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
    certificate = optional(object({
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
