variable "global_settings" {
  description = "CAF global settings used for naming and tags."
  type        = any
}

variable "client_config" {
  description = "Landing-zone identity and client configuration."
  type        = any
}

variable "settings" {
  description = "Managed-identity AI backend. The endpoint may be direct or supplied by one AI service reference."
  type = object({
    name              = string
    url               = optional(string)
    endpoint          = optional(string)
    endpoint_path     = optional(string)
    endpoint_key      = optional(string)
    api_version       = optional(string, "2024-05-01")
    protocol          = optional(string, "http")
    title             = optional(string)
    description       = optional(string)
    resource_id       = optional(string)
    azure_region      = optional(string)
    api_management_id = optional(string)
    api_management = optional(object({
      id                  = optional(string)
      key                 = optional(string)
      lz_key              = optional(string)
      name                = optional(string)
      resource_group_name = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    ai_services = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      endpoint = optional(string)
    }))
    cognitive_services_account = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      endpoint = optional(string)
    }))
    cognitive_account_deployment = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      endpoint = optional(string)
    }))
    cognitive_deployment = optional(object({
      key      = optional(string)
      lz_key   = optional(string)
      endpoint = optional(string)
    }))
    cognitive_account_project = optional(object({
      key          = optional(string)
      lz_key       = optional(string)
      endpoint     = optional(string)
      endpoint_key = optional(string)
    }))
    managed_identity = optional(object({
      client_id = optional(string)
      id        = optional(string)
      key       = optional(string)
      lz_key    = optional(string)
      name      = optional(string)
    }))
    tls = optional(object({
      validate_certificate_chain = optional(bool)
      validate_certificate_name  = optional(bool)
    }))
    reconnect = optional(object({
      enabled = optional(bool, true)
      after   = optional(string, "PT2M")
    }))
    action_timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length([
      for source in [
        try(var.settings.endpoint, null),
        try(var.settings.url, null),
        try(var.settings.ai_services, null),
        try(var.settings.cognitive_services_account, null),
        try(var.settings.cognitive_account_deployment, null),
        try(var.settings.cognitive_deployment, null),
        try(var.settings.cognitive_account_project, null)
      ] : source if source != null
    ]) == 1
    error_message = "Specify exactly one endpoint source: endpoint, url, AI Services, Cognitive account, deployment, or Foundry project."
  }

  validation {
    condition = alltrue([
      for reference in [
        try(var.settings.ai_services, null),
        try(var.settings.cognitive_services_account, null),
        try(var.settings.cognitive_account_deployment, null),
        try(var.settings.cognitive_deployment, null),
        try(var.settings.cognitive_account_project, null)
        ] : reference == null || length([
          for value in [try(reference.endpoint, null), try(reference.key, null)] :
          value if value != null
      ]) == 1
    ])
    error_message = "Endpoint references must supply exactly one of an explicit HTTPS endpoint or a CAF key."
  }

  validation {
    condition = alltrue([
      for endpoint in [try(var.settings.endpoint, null), try(var.settings.url, null)] :
      try(startswith(endpoint, "https://"), true)
    ])
    error_message = "Direct AI backend endpoints must use HTTPS."
  }

  validation {
    condition = alltrue([
      for endpoint in [
        try(var.settings.ai_services.endpoint, null),
        try(var.settings.cognitive_services_account.endpoint, null),
        try(var.settings.cognitive_account_deployment.endpoint, null),
        try(var.settings.cognitive_deployment.endpoint, null),
        try(var.settings.cognitive_account_project.endpoint, null)
      ] : try(startswith(endpoint, "https://"), true)
    ])
    error_message = "Endpoints supplied through AI or Cognitive references must use HTTPS."
  }

  validation {
    condition     = contains(["2024-05-01", "2024-06-01-preview", "2024-10-01-preview", "2025-03-01-preview", "2025-09-01-preview"], var.settings.api_version)
    error_message = "api_version must be a backends API version supported by AzAPI 2.13.0."
  }

  validation {
    condition = (
      try(var.settings.azure_region, null) == null ||
      var.settings.api_version == "2025-03-01-preview" ||
      var.settings.api_version == "2025-09-01-preview"
    )
    error_message = "azure_region requires API version 2025-03-01-preview or later."
  }
}

variable "remote_objects" {
  description = "Combined local and remote objects used to resolve APIM, identity, resource-group, and AI endpoint references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags merged with the module tag."
  type        = map(any)
  default     = {}
}
