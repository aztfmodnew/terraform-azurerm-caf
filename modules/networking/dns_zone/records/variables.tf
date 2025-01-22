variable "base_tags" {
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "resource_group_name" {}
variable "records" {}
variable "target_resources" {
  default = {}
}
variable "zone_name" {}
variable "resource_ids" {
  default = {}
}