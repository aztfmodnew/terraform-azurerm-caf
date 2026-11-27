variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "log_analytics" {
  description = <<DESCRIPTION
Log Analytics workspace and optional solutions configuration. Supported workspace
attributes include name, daily_quota_gb, internet_ingestion_access_type,
internet_query_access_type, reservation_capacity_in_gb_per_day, sku,
retention_in_days, allow_resource_only_permissions, cmk_for_query_forced,
data_collection_rule_id, immediate_data_purge_on_30_days_enabled, and
local_authentication_enabled. The legacy internet_ingestion_enabled,
internet_query_enabled, and reservation_capcity_in_gb_per_day spellings remain
supported. identity accepts type and optional identity_ids. timeouts accepts
create, read, update, and delete duration strings. solutions_maps remains a map
of solution configurations, with optional tags and the same timeout fields.
DESCRIPTION
}
variable "location" {
  description = "location of the resource if different from the resource group."
  type        = string
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
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
