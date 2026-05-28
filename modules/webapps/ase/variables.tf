variable "tags" {
  description = "(Required) Map of tags to apply to App Service Environment resources."
}

variable "name" {
  description = "(Required) Name of the App Service Environment"
}

variable "kind" {
  description = "(Required) Kind of resource. Possible value are ASEV2"
}

variable "zone" {
  description = "(Required) Availability Zone of resource. Possible value are 1, 2 or 3"
}

variable "location" {
  description = "(Required) Resource Location"
}

variable "resource_group_name" {
  description = "(Required) Resource group of the ASE"
}

variable "subnet_id" {
  description = "(Required) Name of the Virtual Network for the ASE"
}

variable "subnet_name" {
  description = "(Optional) Name of the subnet for template-based scenarios where subnet name is referenced in addition to subnet ID."
}

variable "internalLoadBalancingMode" {
  description = "(Optional) Internal load balancing mode for the App Service Environment (for example, internal publishing and/or internal web access modes)."
}

variable "diagnostics" {
  description = "(Optional) Diagnostics object consumed by module diagnostics integration when diagnostic profiles are configured."
  default     = null
}

variable "diagnostic_profiles" {
  description = "(Optional) Map of diagnostic profile definitions to configure monitoring and logging for this deployment."
  default     = {}
}

variable "front_end_size" {
  description = "Instance size for the front-end pool."
  default     = "Standard_D1_V2"

  validation {
    condition     = contains(["Medium", "Large", "ExtraLarge", "Standard_D2", "Standard_D3", "Standard_D4", "Standard_D1_V2", "Standard_D2_V2", "Standard_D3_V2", "Standard_D4_V2"], var.front_end_size)
    error_message = "front_end_size must be one of: Medium, Large, ExtraLarge, Standard_D2, Standard_D3, Standard_D4, Standard_D1_V2, Standard_D2_V2, Standard_D3_V2, Standard_D4_V2."
  }
}

variable "front_end_count" {
  description = "Number of instances in the front-end pool.  Minimum of two."
  default     = "2"
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "private_dns" {
  description = "(Optional) Private DNS zones map used to create ASE private DNS A records when `settings.private_dns_records` is configured."
  default     = {}
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}