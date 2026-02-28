variable "global_settings" {
  description = "Global settings object for the CAF framework"
}

variable "client_config" {
  description = "Client configuration object for the CAF framework"
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Chaos Studio Capability. Configuration attributes:
      - capability_type - (Required) The capability type (fault) to enable (e.g., "PodChaos-2.1")
        See: https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library
      - chaos_studio_target_id - (Optional) Direct Chaos Studio Target ID
      - chaos_studio_target - (Optional) Key-based reference to target (alternative to target_id)
        - key - Target key in landing zone
        - lz_key - (Optional) Cross-landing-zone key
    DESCRIPTION
  type = object({
    capability_type        = string
    chaos_studio_target_id = optional(string)
    chaos_studio_target = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  })
  validation {
    condition     = length(setsubtract(keys(var.settings), ["capability_type", "chaos_studio_target_id", "chaos_studio_target", "tags", "timeouts"])) == 0
    error_message = "Unsupported attributes in settings. Allowed: capability_type, chaos_studio_target_id, chaos_studio_target, tags, timeouts."
  }
}

variable "base_tags" {
  description = "Base tags to be applied to all resources"
  type        = bool
  default     = false
}

variable "remote_objects" {
  description = "Remote objects for dependency resolution"
  type = object({
    chaos_studio_targets = optional(map(any), {})
  })
  default = {}
}
