variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
    Settings for the API Management certificate.

    Required:
      - name - CAF naming input for the certificate.
      - Exactly one certificate source: data, key_vault_secret, key_vault_secret_id, or the legacy key_vault_id alias.

    Optional:
      - api_management - API Management service reference retained for root configuration compatibility.
      - resource_group - Resource group reference retained for root configuration compatibility.
      - data - Base64-encoded PFX certificate data.
      - password - Password for the PFX certificate.
      - key_vault_secret - Key-based reference to a managed Key Vault certificate or certificate request.
      - key_vault_secret_id - Key Vault secret ID containing a PKCS#12 certificate.
      - key_vault_id - Legacy alias for key_vault_secret_id.
      - key_vault_identity_client - Managed identity reference used to retrieve the certificate from Key Vault.
      - key_vault_identity_client_id - Direct client ID for the user-assigned managed identity.
      - timeouts - Create, read, update, and delete operation timeouts.
  DESCRIPTION
  type = object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    data     = optional(string)
    password = optional(string)
    key_vault_secret = optional(object({
      certificate_key         = optional(string)
      certificate_request_key = optional(string)
      lz_key                  = optional(string)
    }))
    key_vault_secret_id = optional(string)
    key_vault_id        = optional(string)
    key_vault_identity_client = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    key_vault_identity_client_id = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length([
      for present in [
        var.settings.data != null,
        var.settings.key_vault_secret != null,
        var.settings.key_vault_secret_id != null,
        var.settings.key_vault_id != null
      ] : present if present
    ]) == 1
    error_message = "Specify exactly one API Management certificate source: data, key_vault_secret, key_vault_secret_id, or key_vault_id."
  }

  validation {
    condition = var.settings.key_vault_secret == null || (
      (try(var.settings.key_vault_secret.certificate_key, null) != null) !=
      (try(var.settings.key_vault_secret.certificate_request_key, null) != null)
    )
    error_message = "When key_vault_secret is specified, set exactly one of certificate_key or certificate_request_key."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_management_name" {
  description = " The Name of the API Management Service where this Service should be created. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The Name of the Resource Group where the API Management Service exists. Changing this forces a new resource to be created."
}
