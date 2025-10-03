variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  
  These are the key naming settings:
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name. Defaults to true.
  DESCRIPTION
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
  Configuration settings for the Azure Bot Service:

  Required arguments:
  - name - (Required) The name which should be used for this Azure Bot Service. Changing this forces a new resource to be created.
  - microsoft_app_id - (Required) The Microsoft Application ID for the Azure Bot Service. Changing this forces a new resource to be created.
  - sku - (Required) The SKU of the Azure Bot Service. Accepted values are F0 or S1. Changing this forces a new resource to be created.

  Optional arguments:
  - developer_app_insights_api_key - (Optional) The Application Insights API Key to associate with this Azure Bot Service.
  - developer_app_insights_application_id - (Optional) The resource ID of the Application Insights instance to associate with this Azure Bot Service.
  - developer_app_insights_key - (Optional) The Application Insight Key to associate with this Azure Bot Service.
  - display_name - (Optional) The name that the Azure Bot Service will be displayed as. This defaults to the value set for name if not specified.
  - endpoint - (Optional) The Azure Bot Service endpoint.
  - icon_url - (Optional) The Icon Url of the Azure Bot Service. Defaults to "https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png".
  - microsoft_app_msi_id - (Optional) The ID of the Microsoft App Managed Identity for this Azure Bot Service. Changing this forces a new resource to be created.
  - microsoft_app_tenant_id - (Optional) The Tenant ID of the Microsoft App for this Azure Bot Service. Changing this forces a new resource to be created.
  - microsoft_app_type - (Optional) The Microsoft App Type for this Azure Bot Service. Possible values are MultiTenant, SingleTenant and UserAssignedMSI. Changing this forces a new resource to be created.
  - local_authentication_enabled - (Optional) Is local authentication enabled? Defaults to true.
  - luis_app_ids - (Optional) A list of LUIS App IDs to associate with this Azure Bot Service.
  - luis_key - (Optional) The LUIS key to associate with this Azure Bot Service.
  - public_network_access_enabled - (Optional) Whether public network access is enabled. Defaults to true.
  - streaming_endpoint_enabled - (Optional) Is the streaming endpoint enabled for this Azure Bot Service. Defaults to false.
  - cmk_key_vault_key_url - (Optional) The CMK Key Vault Key URL that will be used to encrypt the Bot with the Customer Managed Encryption Key.
  - tags - (Optional) A mapping of tags which should be assigned to this Azure Bot Service.
  - timeouts - (Optional) The timeouts block allows you to specify timeouts for certain actions:
    - create - (Defaults to 30 minutes) Used when creating the Azure Bot Service.
    - read - (Defaults to 5 minutes) Used when retrieving the Azure Bot Service.
    - update - (Defaults to 30 minutes) Used when updating the Azure Bot Service.
    - delete - (Defaults to 30 minutes) Used when deleting the Azure Bot Service.

  Example Input:
  ```terraform
  settings = {
    name             = "example-bot"
    microsoft_app_id = "12345678-1234-1234-1234-123456789012"
    sku              = "F0"
    endpoint         = "https://example.com/api/messages"
    display_name     = "Example Bot"
    
    developer_app_insights_application_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Insights/components/example"
    developer_app_insights_api_key        = "api-key-value"
    
    microsoft_app_type      = "MultiTenant"
    microsoft_app_tenant_id = "tenant-id"
    
    local_authentication_enabled   = true
    public_network_access_enabled  = true
    streaming_endpoint_enabled     = false
    
    luis_app_ids = ["luis-app-id-1", "luis-app-id-2"]
    luis_key     = "luis-key-value"
    
    tags = {
      environment = "production"
      purpose     = "chatbot"
    }
    
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
  }
  ```
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resource group object."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Configuration for private endpoints."
  type        = any
  default     = {}
}
