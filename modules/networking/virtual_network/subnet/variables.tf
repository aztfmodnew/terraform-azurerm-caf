variable "name" {
  description = "(Required) The name of the subnet. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the subnet."
  type        = string
}
variable "virtual_network_name" {
  description = "(Required) The name of the virtual network to which to attach the subnet."
}
variable "address_prefixes" {
  description = "(Optional) The address prefixes to use for the subnet."
  default     = []
}
variable "private_endpoint_network_policies" {
  description = "(Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled and RouteTableEnabled. Defaults to Disabled."
  nullable    = true
}
variable "private_link_service_network_policies_enabled" {
  description = "(Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true."
  nullable    = true
}

variable "default_outbound_access_enabled" {
  description = "(Optional) Controls whether the subnet should have default outbound access enabled. Setting to false creates a private subnet without default outbound access. Defaults to null (provider default)."
  type        = bool
  nullable    = true
  default     = null
}
# Retired
# variable "enforce_private_link_endpoint_network_policies" {
#   description = "(Optional) Enable or Disable network policies for the private link endpoint on the subnet. Default value is false. Conflicts with enforce_private_link_service_network_policies."
#   default     = null
# }
# variable "enforce_private_link_service_network_policies" {
#   description = "(Optional) Enable or Disable network policies for the private link service on the subnet. Default valule is false. Conflicts with enforce_private_link_endpoint_network_policies."
#   default     = null
# }
variable "service_endpoints" {
  description = "(Optional) The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
  default     = []
  # validation {
  #   condition     = var.service_endpoints == [] || contains(["Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"], var.service_endpoints)
  #   error_message = "Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
  # }
}

variable "service_endpoint_policy_ids" {
  description = "(Optional) The list of IDs of Service Endpoint Policies to associate with the subnet."
  type        = list(string)
  default     = null
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
  default     = {}
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
  default     = {}
}