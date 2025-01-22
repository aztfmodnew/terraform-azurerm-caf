variable "global_settings" {
  type = any
}

# trunk-ignore(tflint/terraform_unused_declarations)
variable "client_config" {
  type = any
}

variable "name" {
  description = "(Required) Specifies the name of the Data Factory Linked Service Key Vault. Changing this forces a new resource to be created. Must be globally unique."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  The settings for the Azure resource.

  - name = (Required) Specifies the name of the Data Factory Linked Service Key Vault. Changing this forces a new resource to be created. Must be globally unique.
DESCRIPTION
  type        = any
}

variable "data_factory_id" {
  description = "(Required) The Data Factory ID in which to associate the Linked Service with. Changing this forces a new resource."
  type        = string
}

variable "description" {
  description = "(Optional) The description for the Data Factory Linked Service Key Vault."
  type        = string
  default     = null
}

variable "integration_runtime_name" {
  description = "(Optional) The integration runtime reference to associate with the Data Factory Linked Service Key Vault."
  type        = string
  default     = null
}

variable "annotations" {
  description = "(Optional) List of tags that can be used for describing the Data Factory Linked Service Key Vault."
  type        = list(string)
  default     = null
}

variable "parameters" {
  description = "(Optional) A map of parameters to associate with the Data Factory Linked Service Key Vault."
  type        = map(any)
  default     = null
}

variable "additional_properties" {
  description = "(Optional) A map of additional properties to associate with the Data Factory Linked Service Key Vault."
  type        = map(any)
  default     = null
}

variable "key_vault_id" {
  description = "(Required) The ID the Azure Key Vault resource."
  type        = string
}