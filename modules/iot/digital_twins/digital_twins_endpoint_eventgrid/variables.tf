variable "settings" {
  description = "Optional normalized settings object for the Digital Twins Event Grid endpoint module. When provided, values override the legacy flat inputs."
  type        = any
  default     = {}
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "name" {
  description = "(Required) Name of the Digital Twins Event Grid endpoint."
  type        = string
  default     = null
}

variable "digital_twins_id" {
  description = "(Required) ID of the Digital Twins instance."
  type        = string
  default     = null
}

variable "eventgrid_topic_endpoint" {
  description = "Endpoint URL of the target Event Grid topic."
  type        = string
  default     = null
}

variable "eventgrid_topic_primary_access_key" {
  description = "Primary access key of the target Event Grid topic."
  type        = string
  default     = null
}

variable "eventgrid_topic_secondary_access_key" {
  description = "Secondary access key of the target Event Grid topic."
  type        = string
  default     = null
}

variable "remote_objects" {
  description = "Remote objects configuration used for dependency resolution."
  type        = any
  default     = {}
}

variable "dead_letter_storage_secret" {
  description = "(Optional) Storage secret for dead lettering."
  type        = string
  default     = null
}

variable "timeouts" {
  description = "(Optional) Timeouts for the Digital Twins Event Grid endpoint operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
