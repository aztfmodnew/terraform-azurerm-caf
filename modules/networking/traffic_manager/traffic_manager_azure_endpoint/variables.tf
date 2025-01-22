variable "settings" {
  default = {}
  type    = any
}

variable "profile_id" {
  default = {}
}

variable "target_resource_id" {
  default = {}
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
