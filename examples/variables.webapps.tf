# Split from variables.tf - group: webapps

variable "app_service_environments" {
  type    = any
  default = {}
}

variable "app_service_environments_v3" {
  type    = any
  default = {}
}

variable "azurerm_application_insights" {
  type    = any
  default = {}
}

variable "azurerm_application_insights_web_test" {
  type    = any
  default = {}
}

variable "azurerm_application_insights_standard_web_test" {
  type    = any
  default = {}
}

variable "linux_function_apps" {
  type    = any
  default = {}
}

variable "service_plans" {
  description = <<DESCRIPTION
The service_plans object is a map of service plan objects. Each service plan object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the service plan.
- location: The location of the service plan. If not provided, the location of the resource group will be used.
- os_type: (Required) The operating system of the service plan. Possible values are Windows, Linux and WindowsContainer.
- sku_name: (Required) The SKU name of the service plan.
- app_service_environment_id: (Optional) The ID of the App Service Environment where the service plan should be created.
- app_service_environment: (Optional) The App Service Environment object where the service plan should be created.
  - lz_key: The key of the landing zone object to deploy the Azure resource.
  - key: The key of the App Service Environment object to deploy the Azure resource.
- app_service_environment_v3: (Optional) The App Service Environment V3 object where the service plan should be created.
  - lz_key: The key of the landing zone object to deploy the Azure resource.
  - key: The key of the App Service Environment V3 object to deploy the Azure resource.
- maximum_elastic_worker_count: (Optional) The maximum number of workers that can be allocated to this App Service Plan.
- worker_count: (Optional) The number of workers to allocate.
- per_site_scaling_enabled: (Optional) Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.
- tags: (Optional) The tags for the service plan.

Example:

service_plans = {
  sp1 = {
    resource_group_key = "test_re1"
    name               = "asp-simple"
    os_type            = "Linux"
    sku_name           = "FC1"

    tags = {
      project = "Test"
    }
  }
}
DESCRIPTION
  default     = {}
  type        = any
}

variable "static_sites" {
  type    = any
  default = {}
}

variable "linux_web_apps" {
  description = <<DESCRIPTION
  The linux_web_apps object is a map of linux web app objects. Each linux web app object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the linux web app.
- service_plan_key: (Required) The key of the service plan object to deploy the Azure resource.
- location: The location of the linux web app. If not provided, the location of the resource group will be used.
- settings: (Optional) The settings for the linux web app.
- app_settings: (Optional) The app settings for the linux web app.
- connection_string: (Optional) The connection string for the linux web app.
- identity: (Optional) The identity for the linux web app.
- identity_type: (Optional) The identity type for the linux web app. Possible values are SystemAssigned, UserAssigned and None.
- identity_ids: (Optional) The identity IDs for the linux web app.
- https_only: (Optional) Should the linux web app enforce HTTPS only. Changing this forces a new resource to be created.
- client_cert_enabled: (Optional) Should the linux web app require client certificates. Changing this forces a new resource to be created.
- client_cert_mode: (Optional) The client certificate mode for the linux web app. Possible values are Require and Allow.
DESCRIPTION
  type        = any
  default     = {}
}

variable "windows_function_apps" {
  description = <<DESCRIPTION
  The windows_function_apps object is a map of Windows Function App objects. Each Windows Function App object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the Windows Function App.
- service_plan_key: (Required) The key of the service plan object to deploy the Azure resource.
- location: The location of the Windows Function App. If not provided, the location of the resource group will be used.
- settings: (Optional) The settings for the Windows Function App.
- app_settings: (Optional) The app settings for the Windows Function App.
- connection_string: (Optional) The connection string for the Windows Function App.
- identity: (Optional) The identity for the Windows Function App.
- identity_type: (Optional) The identity type for the Windows Function App. Possible values are SystemAssigned, UserAssigned and None.
- identity_ids: (Optional) The identity IDs for the Windows Function App.
- https_only: (Optional) Should the Windows Function App enforce HTTPS only.
- storage_account_key: (Optional) The key of the storage account to use for the Function App.
- functions_extension_version: (Optional) The runtime version associated with the Function App.
- slots: (Optional) Configuration for deployment slots.
DESCRIPTION
  type        = any
  default     = {}
}

variable "windows_web_apps" {
  description = <<DESCRIPTION
  The windows_web_appss object is a map of windows web app objects. Each windows web app object has the following keys:
- resource_group_key: The key of the resource group object to deploy the Azure resource.
- name: (Required) The name of the windows web app.
- service_plan_key: (Required) The key of the service plan object to deploy the Azure resource.
- location: The location of the windows web app. If not provided, the location of the resource group will be used.
- settings: (Optional) The settings for the windows web app.
- app_settings: (Optional) The app settings for the windows web app.
- connection_string: (Optional) The connection string for the windows web app.
- identity: (Optional) The identity for the windows web app.
- identity_type: (Optional) The identity type for the windows web app. Possible values are SystemAssigned, UserAssigned and None.
- identity_ids: (Optional) The identity IDs for the windows web app.
- https_only: (Optional) Should the windows web app enforce HTTPS only. Changing this forces a new resource to be created.
- client_cert_enabled: (Optional) Should the windows web app require client certificates. Changing this forces a new resource to be created.
- client_cert_mode: (Optional) The client certificate mode for the windows web app. Possible values are Require and Allow.

  
  

  DESCRIPTION
  type        = any
  default     = {}
}

variable "web_pubsubs" {
  description = "Configuration settings for Azure Web PubSub services."
  type        = any
  default     = {}
}

variable "web_pubsub_hubs" {
  type    = any
  default = {}
}
