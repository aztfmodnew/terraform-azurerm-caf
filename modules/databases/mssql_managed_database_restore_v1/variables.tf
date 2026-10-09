variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "server_id" {}
variable "server_location" {}
variable "base_tags" {
  type = bool
}
variable "server_tags" {
  default  = {}
  nullable = false
}
variable "source_database_id" {
  type    = string
  default = null
}
variable "settings" {
  description = "Managed database restore settings with snake_case properties, cross-subscription IDs, storage identity and ledger options. Existing short_term_retention_days is required. Optional timeouts apply to the database, short_term_retention_timeouts to STR, and long_term_retention_policy.timeouts to LTR. See docs/AZAPI_MODULES.md."
  validation {
    condition = alltrue(
      [
        for k in keys(var.settings) : contains(
          [
            "base_tags",
            "enable_advanced_threat_protection_settings",
            "enable_security_alert_policies",
            "is_source_database_deleted",
            "long_term_retention_policy",
            "mi_server_key",
            "name",
            "properties",
            "short_term_retention_days",
            "short_term_retention_timeouts",
            "timeouts",
            "tags",
            "version",
            "use_legacy_slug"
          ], k
        )
      ]
    )
    error_message = format("The following attributes are not supported. Adjust your configuration file: %s", join(", ",
      setsubtract(
        keys(var.settings),
        [
          "base_tags",
          "enable_advanced_threat_protection_settings",
          "enable_security_alert_policies",
          "is_source_database_deleted",
          "long_term_retention_policy",
          "mi_server_key",
          "name",
          "properties",
          "short_term_retention_days",
          "short_term_retention_timeouts",
          "timeouts",
          "tags",
          "version",
          "use_legacy_slug"
        ]
      )
      )
    )
  }
}
