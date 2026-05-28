# Split from variables.tf - group: networking

variable "network_managers" {
  default = {}
  type    = any
}

variable "network_manager_admin_rules" {
  default = {}
  type    = any
}

variable "network_manager_admin_rule_collections" {
  default = {}
  type    = any
}

variable "network_manager_connectivity_configurations" {
  default = {}
  type    = any
}

variable "network_manager_deployments" {
  default = {}
  type    = any
}

variable "network_manager_network_groups" {
  default = {}
  type    = any
}

variable "network_manager_management_group_connections" {
  default = {}
  type    = any
}

variable "network_manager_security_admin_configurations" {
  default = {}
  type    = any
}

variable "network_manager_scope_connections" {
  default = {}
  type    = any
}

variable "network_manager_static_members" {
  default = {}
  type    = any
}

variable "network_manager_subscription_connections" {
  default = {}
  type    = any
}

variable "network_security_group_definition" {
  default = {}
  type    = any
}

variable "network_security_perimeters" {
  default = {}
  type    = any
}

variable "network_security_security_rules" {
  type    = any
  default = {}
}

variable "route_tables" {
  type    = any
  default = {}
}

variable "route_servers" {
  type    = any
  default = {}
}

variable "azurerm_routes" {
  type    = any
  default = {}
}

variable "vnets" {
  type    = any
  default = {}
}

variable "virtual_subnets" {
  type    = any
  default = {}
}

variable "bastion_hosts" {
  type    = any
  default = {}
}

variable "public_ip_addresses" {
  type    = any
  default = {}
}

variable "private_dns" {
  type    = any
  default = {}
}

variable "virtual_hubs" {
  type    = any
  default = {}
}

variable "virtual_wans" {
  type    = any
  default = {}
}

variable "application_gateways" {
  type    = any
  default = {}
}

variable "application_gateway_platforms" {
  type    = any
  default = {}
}

variable "application_gateway_applications" {
  type    = any
  default = {}
}

variable "application_gateway_applications_v1" {
  type    = any
  default = {}
}

variable "application_gateway_waf_policies" {
  type    = any
  default = {}
}

variable "network_watchers" {
  type    = any
  default = {}
}

variable "express_route_circuits" {
  type    = any
  default = {}
}

variable "express_route_circuit_authorizations" {
  type    = any
  default = {}
}

variable "vnet_peerings" {
  type    = any
  default = {}
}

variable "vnet_peerings_v1" {
  type    = any
  default = {}
}

variable "dns_zones" {
  type    = any
  default = {}
}

variable "dns_zone_records" {
  type    = any
  default = {}
}

variable "private_endpoints" {
  type    = any
  default = {}
}

variable "domain_name_registrations" {
  type    = any
  default = {}
}

variable "ip_groups" {
  type    = any
  default = {}
}

variable "virtual_hub_connections" {
  type    = any
  default = {}
}

variable "virtual_hub_route_table_routes" {
  type    = any
  default = {}
}

variable "virtual_hub_route_tables" {
  type    = any
  default = {}
}

variable "virtual_hub_er_gateway_connections" {
  type    = any
  default = {}
}

variable "vpn_sites" {
  type    = any
  default = {}
}

variable "vpn_gateway_connections" {
  type    = any
  default = {}
}

variable "vpn_gateway_nat_rules" {
  type    = any
  default = {}
}

variable "nat_gateways" {
  type    = any
  default = {}
}

variable "private_dns_vnet_links" {
  type    = any
  default = {}
}

variable "lb" {
  type    = any
  default = {}
}

variable "lb_backend_address_pool" {
  type    = any
  default = {}
}

variable "lb_backend_address_pool_address" {
  type    = any
  default = {}
}

variable "lb_nat_pool" {
  type    = any
  default = {}
}

variable "lb_nat_rule" {
  type    = any
  default = {}
}

variable "lb_outbound_rule" {
  type    = any
  default = {}
}

variable "lb_probe" {
  type    = any
  default = {}
}

variable "lb_rule" {
  type    = any
  default = {}
}

variable "network_interface_backend_address_pool_association" {
  type    = any
  default = {}
}

variable "public_ip_prefixes" {
  type    = any
  default = {}
}

variable "private_dns_resolvers" {
  type    = any
  default = {}
}

variable "private_dns_resolver_inbound_endpoints" {
  type    = any
  default = {}
}

variable "private_dns_resolver_outbound_endpoints" {
  type    = any
  default = {}
}

variable "private_dns_resolver_dns_forwarding_rulesets" {
  type    = any
  default = {}
}

variable "private_dns_resolver_forwarding_rules" {
  type    = any
  default = {}
}

variable "private_dns_resolver_virtual_network_links" {
  type    = any
  default = {}
}
