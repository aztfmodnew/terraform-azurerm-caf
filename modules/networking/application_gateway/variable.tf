variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "diagnostics" {}
variable "location" {
  description = "(Required) Resource Location"
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "public_ip_addresses" {
  default = {}
}
variable "application_gateway_applications" {}
variable "linux_web_apps" {
  default = {}
}
variable "windows_web_apps" {
  default = {}
}
variable "vnets" {
  default = {}
}

variable "sku_name" {
  type        = string
  default     = "Standard_v2"
  description = "(Optional) (Default = Standard_v2) The Name of the SKU to use for this Application Gateway. Possible values are Basic, Standard_v2, and WAF_v2."

  validation {
    condition     = contains(["Basic", "Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "Provide an allowed value as defined in the Azure provider documentation. Possible values are Basic, Standard_v2, and WAF_v2."
  }
}

variable "sku_tier" {
  type        = string
  default     = "Standard_v2"
  description = "(Optional) (Default = Standard_v2) The Tier of the SKU to use for this Application Gateway. Possible values are Basic, Standard_v2, and WAF_v2."

  validation {
    condition     = contains(["Basic", "Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "Provide an allowed value as defined in the Azure provider documentation. Possible values are Basic, Standard_v2, and WAF_v2."
  }
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "private_dns" {
  default = {}
}
variable "keyvault_certificates" {
  default = {}
}
variable "keyvault_certificate_requests" {
  default = {}
}
variable "managed_identities" {
  default = {}
}

variable "dns_zones" {
  default = {}
}

variable "keyvaults" {
  default = {}
}

variable "application_gateway_waf_policies" {
  default = {}
}
