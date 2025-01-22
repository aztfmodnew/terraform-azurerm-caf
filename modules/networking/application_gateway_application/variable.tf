variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
# trunk-ignore(tflint/terraform_unused_declarations)
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "application_gateway" {
  type = any
}
variable "app_services" {
  default = {}
  type    = map(any)
}
variable "keyvaults" {
  default = {}
  type    = map(any)
}
variable "keyvault_certificates" {
  default = {}
  type    = map(any)
}
variable "keyvault_certificate_requests" {
  default = {}
  type    = map(any)
}
variable "application_gateway_waf_policies" {
  default = {}
  type    = map(any)
}


