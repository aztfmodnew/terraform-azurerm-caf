# Split from variables.tf - group: compute_webapps

variable "compute" {
  description = "Configuration object - Azure compute resources"
  default = {
    virtual_machines = {}
  }
}

variable "webapp" {
  description = "Configuration object - Web Applications"
  default = {
    # app_service_environments     = {}
    # service_plans                = {}
    # azurerm_application_insights = {}
  }
}
