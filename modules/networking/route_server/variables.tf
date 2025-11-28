variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "Azure region override (optional, falls back to resource_group.location)"
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Inherit global and resource group tags (boolean)."
  type        = bool
  default     = true
}

variable "resource_group" {
  description = "Resource group object (expects name, location, tags)."
  type        = any
}

variable "remote_objects" {
  description = "Remote objects map (virtual networks, public_ip_addresses, etc.)."
  type        = any
  default     = {}
}

variable "settings" {
  description = <<DESCRIPTION
Settings object for route_server:

- name                            : (Required) Base name without CAF prefix
- vnet_key                        : (Required) Key of the virtual network containing the RouteServerSubnet
- subnet_key                      : (Required) Key of the dedicated Route Server subnet inside the VNet (typically "RouteServerSubnet")
- lz_key                          : (Optional) Landing zone key for the VNet (defaults to client_config.landingzone_key)
- public_ip_key                   : (Required) Key of the public IP address
- subnet_id                       : (Optional) Direct override for subnet id
- public_ip_address_id            : (Optional) Direct override for public IP id
- sku                             : (Optional) SKU, defaults to Standard
- branch_to_branch_traffic_enabled: (Optional) Enable branch-to-branch traffic, defaults to false
- hub_routing_preference          : (Optional) The routing preference. Possible values are ExpressRoute, ASPath or VpnGateway
- tags                            : (Optional) Additional tags specific to the Route Server

Example:
```hcl
settings = {
	name           = "rs-core"
	vnet_key       = "hub"
	subnet_key     = "RouteServerSubnet"
	public_ip_key  = "rs-pip"
}
```
DESCRIPTION
  type        = any
}

variable "diagnostics" {
  description = "Diagnostics destinations definition"
  type        = any
  default     = {}
}

variable "diagnostic_profiles" {
  description = "Diagnostic profiles definition"
  type        = any
  default     = {}
}
