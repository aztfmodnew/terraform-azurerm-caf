variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
  default     = {}
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "(Optional) Inherit tags from the resource group. Defaults to false."
  type        = bool
  default     = false
}

variable "resource_group" {
  description = "(Optional) Resource group object for name resolution."
  default     = {}
}

variable "managed_identities" {
  description = "(Optional) Map of managed identity objects for parent identity resolution."
  default     = {}
}

variable "oidc_issuer_url" {
  description = "(Optional) OIDC issuer URL, typically passed from an AKS cluster."
  default     = null
}

variable "resource_group_name" {
  description = "(Optional) Resource group name. Resolved from settings.resource_group.name or resource_group.name."
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for Azure Federated Identity Credential. Configuration attributes:
      - name             - (Required) Name of the federated identity credential.
      - subject          - (Required) Subject for the federated identity credential.
      - audience         - (Optional) Audience list. Defaults to ["api://AzureADTokenExchange"].
      - oidc_issuer_url  - (Optional) OIDC issuer URL.
      - resource_group   - (Optional) Resource group reference (name or key/lz_key).
      - managed_identity - (Required) Reference to the parent managed identity.
        - key    - (Required) Key of the managed identity in the managed_identities map.
        - lz_key - (Optional) Landing zone key for cross-landing-zone references.
        - id     - (Optional) Direct resource ID of the managed identity.
      - timeouts         - (Optional) Timeout overrides for create/read/update/delete.
    DESCRIPTION
  type = object({
    name            = string
    subject         = string
    audience        = optional(list(string))
    oidc_issuer_url = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    managed_identity = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      id     = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default = null
}
