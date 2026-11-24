variable "global_settings" {
  description = "CAF global naming, region, and tag settings."
  type        = any
}

variable "client_config" {
  description = "Landing-zone identity and subscription configuration."
  type        = any
}

variable "settings" {
  description = <<-DESCRIPTION
  Composed Azure API Center service and its catalog hierarchy. The hierarchy is
  service -> workspace -> environment/api -> version/definition/deployment.
  Child collections are maps keyed by CAF business keys.

  A service can be created from name/resource_group, or selected with service_id
  or service.id/key/lz_key from remote_objects.api_centers. Child names and all
  child ARM IDs may be supplied directly; keys resolve objects created in this
  composition. The stable 2024-03-01 ARM contract is used for every resource.
DESCRIPTION
  type        = any

  validation {
    condition = (
      try(var.settings.service_id, null) != null ||
      try(var.settings.service.id, null) != null ||
      try(var.settings.service.key, null) != null ||
      try(var.settings.name, null) != null
    )
    error_message = "Configure a service name, or select an existing service with service_id/service.id/service.key."
  }

  validation {
    condition     = try(var.settings.api_version, "2024-03-01") == "2024-03-01"
    error_message = "Only the stable Microsoft.ApiCenter 2024-03-01 API version is supported by this module."
  }
}

variable "remote_objects" {
  description = "Combined resource groups, API Centers, and managed identities."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited by the API Center service."
  type        = map(any)
  default     = {}
}
