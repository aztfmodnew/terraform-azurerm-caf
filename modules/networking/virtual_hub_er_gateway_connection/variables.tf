variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "virtual_hub_route_tables" {
  default = {}
}
variable "authorization_key" {}
variable "express_route_circuit_id" {}
variable "express_route_gateway_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "virtual_hub_id" {}
variable "virtual_network_gateway_id" {}
