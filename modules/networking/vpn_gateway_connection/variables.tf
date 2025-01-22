variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "vpn_gateway_id" {}
variable "vpn_sites" {}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "route_tables" {}
variable "nat_rules" {}
variable "default_route_table_id" {}
