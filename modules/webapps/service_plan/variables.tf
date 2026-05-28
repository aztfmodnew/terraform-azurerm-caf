variable "location" {
  description = "Optional override for the Azure region. If null, the module uses resource_group.location."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object used by the module to resolve resource_group_name and default location."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings object for the Service Plan module.

Supported attributes:
- name - (Required) Base name used by azurecaf naming to generate the final Service Plan name.
- sku_name - (Required) Service Plan SKU. Provider-supported values include B1/B2/B3, D1, F1, I1/I2/I3, I1v2/I1mv2/I2v2/I2mv2/I3v2/I3mv2/I4v2/I4mv2/I5v2/I5mv2/I6v2, P1v2/P2v2/P3v2, P0v3/P1v3/P2v3/P3v3, P1mv3/P2mv3/P3mv3/P4mv3/P5mv3, P0v4/P1v4/P2v4/P3v4, P1mv4/P2mv4/P3mv4/P4mv4/P5mv4, S1/S2/S3, SHARED, EP1/EP2/EP3, FC1, WS1/WS2/WS3, Y1.
- os_type - (Required by provider) O/S type for workloads in the plan: Windows, Linux, or WindowsContainer.
- app_service_environment_id - (Optional) Direct ID of the App Service Environment.
- app_service_environment_v3 - (Optional) Key-based reference object for ASE v3 lookup in remote_objects. Expected shape: { key = string, lz_key = optional(string) }.
- app_service_environment_v3_key - (Optional) Legacy key fallback for ASE v3 lookup when app_service_environment_v3.key is not provided.
- app_service_environment - (Optional) Key-based reference object for App Service Environment lookup in remote_objects. Expected shape: { key = string, lz_key = optional(string) }.
- app_service_environment_key - (Optional) Legacy key fallback for App Service Environment lookup when app_service_environment.key is not provided.
- maximum_elastic_worker_count - (Optional) Maximum workers for Elastic SKU or Premium SKU when premium auto-scale is enabled by platform/provider constraints.
- worker_count - (Optional) Number of workers (instances) allocated to the plan.
- per_site_scaling_enabled - (Optional) Enables per-site scaling behavior.
- zone_balancing_enabled - (Optional) Enables zone balancing for supported SKUs/regions; when enabled with worker_count, use a value aligned to regional availability zone constraints.
- tags - (Optional) Additional tags merged into module tags.
- timeouts - (Optional) Terraform operation timeouts object. Supported keys: create, read, update, delete.

Provider note (azurerm_service_plan): premium_plan_auto_scale_enabled is a provider argument but is not currently exposed by this module version.
DESCRIPTION
  type        = any
}

variable "global_settings" {
  description = "Global settings used by CAF naming and tag composition (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "When true, merge global/resource group tags with module tags."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects used for dependency resolution (for example App Service Environment lookups by key/lz_key)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object used for landing zone context during dependency lookups."
  type        = any
}