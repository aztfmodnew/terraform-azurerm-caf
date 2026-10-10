variable "group_object_id" {
  description = "The object ID of the group."
  type        = string
}

variable "member_object_id" {
  description = "The object ID of the member."
  type        = string
  default     = null
}

variable "timeouts" {
  description = "Optional create, read and delete membership operation timeouts."
  type = object({
    create = optional(string)
    read   = optional(string)
    delete = optional(string)
  })
  default = null
}