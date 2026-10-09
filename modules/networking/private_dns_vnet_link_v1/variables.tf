variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "virtual_network_id" {
}

variable "private_dns" {
}

variable "settings" {
  description = "Private DNS link settings. Each private_dns_zones entry accepts resolution_policy (Default or NxDomainRedirect), registration_enabled, and CRUD timeouts; settings.timeouts is the fallback. Existing ID and CAF key references remain supported."
}

variable "inherit_tags" {
  description = "Inherit base tags for the resource from the resource group."
  type        = bool
}
