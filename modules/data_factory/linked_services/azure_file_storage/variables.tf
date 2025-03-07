variable "name" {
  description = "(Required) Specifies the name of the Data Factory Linked Service. Changing this forces a new resource to be created. Must be globally unique."
}

variable "data_factory_id" {
  description = "(Required) The Data Factory name in which to associate the Linked Service with. Changing this forces a new resource."
  type        = string
}

variable "description" {
  description = "(Optional) The description for the Data Factory Linked Service."
}

variable "integration_runtime_name" {
  description = "(Optional) The integration runtime reference to associate with the Data Factory Linked Service."
}

variable "annotations" {
  description = "(Optional) List of tags that can be used for describing the Data Factory Linked Service."
}

variable "parameters" {
  description = "(Optional) A map of parameters to associate with the Data Factory Linked Service."
}

variable "additional_properties" {
  description = "(Optional) A map of additional properties to associate with the Data Factory Linked Service."
}

variable "connection_string" {
  description = "(Required) The connection string."
}
