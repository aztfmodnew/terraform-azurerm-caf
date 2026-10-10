variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "Failover group settings. read_write_endpoint_failover_policy defaults to Manual; Automatic uses grace_minutes. Optional read_only_endpoint_failover_policy takes precedence over the legacy readonly_endpoint_failover_policy_enabled boolean. CRUD timeouts are optional."
  type        = any
}
variable "managed_instance" {
  description = "(Required) The primary SQL Managed Instance object which will be replicated using a SQL Instance Failover Group. Changing this forces a new SQL Instance Failover Group to be created."
}
variable "partner_managed_instance" {
  description = "(Required) The SQL Managed Instance object which will be replicated to. Changing this forces a new resource to be created."
}