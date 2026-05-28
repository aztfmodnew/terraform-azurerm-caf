# Split from variables.tf - group: compute

variable "virtual_machines" {
  type    = any
  default = {}
}

variable "virtual_machine_scale_sets" {
  type    = any
  default = {}
}

variable "aks_clusters" {
  type    = any
  default = {}
}

variable "azure_container_registries" {
  type    = any
  default = {}
}

variable "batch_accounts" {
  type    = any
  default = {}
}

variable "batch_applications" {
  type    = any
  default = {}
}

variable "batch_jobs" {
  type    = any
  default = {}
}

variable "batch_pools" {
  type    = any
  default = {}
}

variable "availability_sets" {
  type    = any
  default = {}
}

variable "proximity_placement_groups" {
  type    = any
  default = {}
}

variable "load_balancers" {
  type    = any
  default = {}
}

variable "container_groups" {
  type    = any
  default = {}
}

variable "wvd_application_groups" {
  type    = any
  default = {}
}

variable "wvd_workspaces" {
  type    = any
  default = {}
}

variable "wvd_host_pools" {
  type    = any
  default = {}
}

variable "wvd_applications" {
  type    = any
  default = {}
}

variable "dedicated_host_groups" {
  type    = any
  default = {}
}

variable "dedicated_hosts" {
  type    = any
  default = {}
}

variable "vmware_private_clouds" {
  type    = any
  default = {}
}

variable "vmware_clusters" {
  type    = any
  default = {}
}

variable "vmware_express_route_authorizations" {
  type    = any
  default = {}
}

variable "aro_clusters" {
  type    = any
  default = {}
}
