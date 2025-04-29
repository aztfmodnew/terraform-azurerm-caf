# Global settings
variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  These are the settings that can be configured:
  - default_region - (Optional) The default region to use for the global settings object, by default it is set to "region1".
  - environment - (Optional) The environment to use for deployments.
  - inherit_tags - (Optional) A boolean value that indicates whether to inherit tags from the global settings object and from the resource group, by default it is set to false.
  - prefix - (Optional) The prefix to append as the first characters of the generated name. The prefix will be separated by the separator character.
  - suffix - (Optional) The suffix to append after the basename of the resource to create. The suffix will be separated by the separator character.
  - prefix_with_hyphen - (Optional) A boolean value that indicates whether to add a hyphen to the prefix.
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name. The prefixes will be separated by the separator character.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource to create. The suffixes will be separated by the separator character.
  - random_length - (Optional) The length of the random string to generate. Defaults to 0.
  - random_seed - (Optional) The seed to be used for the random generator. 0 will not be respected and will generate a seed based on the Unix time of the generation.
  - resource_type - (Optional) The type of Azure resource you are requesting a name from (e.g., Azure Container Registry: azurerm_container_registry). See the Resource Types supported: https://github.com/aztfmod/terraform-provider-azurecaf?tab=readme-ov-file#resource-status.
  - resource_types - (Optional) A list of additional resource types should you want to use the same settings for a set of resources.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - passthrough - (Optional) A boolean value that indicates whether to pass through the naming convention. In that case only the clean input option is considered and the prefixes, suffixes, random, and are ignored. The resource prefixe is not added either to the resulting string. Defaults to false.
  - regions - (Optional) A map of regions to use for the global settings object.
    - region1 - The name of the first region.
    - region2 - The name of the second region.
    - regionN - The name of the Nth region.
  - tags - (Optional) A map of tags to be inherited from the global settings object if inherit_tags is set to true.
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name, suffix, or prefix. Defaults to true.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
DESCRIPTION  
  type = map(object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(bool)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number)
    random_seed        = optional(number)
    resource_type      = optional(string)
    resource_types     = optional(list(string))
    separator          = optional(string)
    clean_input        = optional(bool)
    passthrough        = optional(bool)
    regions            = map(string)
  }))
  default = {
    passthrough    = false
    random_length  = 4
    default_region = "region1"
    inherit_tags   = true
    regions = {
      region1 = "southeastasia"
      region2 = "eastasia"
    }
  }
}

variable "client_config" {

  description = <<DESCRIPTION
    Client configuration object primarily used for specifying the Azure client context in non-interactive environments,
    such as CI/CD pipelines running under a Service Principal.

    If this variable is left as an empty map (the default), the module will attempt to derive the client configuration
    (like client_id, tenant_id, subscription_id, object_id) from the current Azure provider context
    (e.g., credentials from Azure CLI, VS Code Azure login, or environment variables).

    If you provide a map, it should contain the necessary authentication and context details. The structure used
    when the default is derived includes keys like:
    - client_id
    - landingzone_key
    - logged_aad_app_objectId
    - logged_user_objectId
    - object_id
    - subscription_id
    - tenant_id

    Example of providing explicit configuration (e.g., for a Service Principal):
    client_config = {
      client_id       = "your-service-principal-client-id"
      object_id       = "your-service-principal-object-id"
      subscription_id = "your-target-subscription-id"
      tenant_id       = "your-azure-ad-tenant-id"
      landingzone_key = "my_landingzone" # Optional, defaults to var.current_landingzone_key if needed elsewhere
      # Add other relevant keys if needed by the specific module context
    }
  DESCRIPTION
  type        = map(any)
  default     = {}

}

## Cloud variables
variable "cloud" {
  description = <<DESCRIPTION
  Configuration object for Azure cloud environment settings.

    This variable allows you to specify or override the default endpoints and resource IDs for various Azure services.
    It's primarily used to target Azure environments other than the default Azure Public Cloud, such as Azure Government,
    Azure China, or custom Azure Stack environments.

    If left as an empty map (the default `{}`), the module will use its built-in default values, which typically correspond
    to the Azure Public Cloud environment (e.g., `.vault.azure.net` for Key Vault, `core.windows.net` for Storage).

    You can provide a map with specific keys to override these defaults. The module merges your provided map with its
    internal defaults, with your values taking precedence.

    Example keys include:
    - acrLoginServerEndpoint
    - keyvaultDns
    - storageEndpoint
    - resourceManager (ARM endpoint)
    - activeDirectory (Microsoft Entra endpoint)
    - microsoftGraphResourceId
    - etc.

    Example for Azure Government:
    cloud = {
      keyvaultDns     = ".vault.usgovcloudapi.net"
      storageEndpoint = "core.usgovcloudapi.net"
      resourceManager = "https://management.usgovcloudapi.net/"
      activeDirectory = "https://login.microsoftonline.us"
      # ... other Gov-specific endpoints
    }
  DESCRIPTION
  type        = map(string)
  default = {
    acrLoginServerEndpoint                      = ".azurecr.io"
    attestationEndpoint                         = ".attest.azure.net"
    azureDatalakeAnalyticsCatalogAndJobEndpoint = "azuredatalakeanalytics.net"
    azureDatalakeStoreFileSystemEndpoint        = "azuredatalakestore.net"
    keyvaultDns                                 = ".vault.azure.net"
    mhsmDns                                     = ".managedhsm.azure.net"
    mysqlServerEndpoint                         = ".mysql.database.azure.com"
    postgresqlServerEndpoint                    = ".postgres.database.azure.com"
    sqlServerHostname                           = ".database.windows.net"
    storageEndpoint                             = "core.windows.net"
    storageSyncEndpoint                         = "afs.azure.net"
    synapseAnalyticsEndpoint                    = ".dev.azuresynapse.net"
    communicationEndpoint                       = ".communication.azure.com"
    cosmosdbEndpoint                            = ".documents.azure.com"
    cognitiveServicesEndpoint                   = ".cognitiveservices.azure.com"
    containerAppsEndpoint                       = ".azurecontainerapps.io"
    eventgridEndpoint                           = ".eventgrid.azure.net"
    iotCentralEndpoint                          = ".azureiotcentral.com"
    iotHubEndpoint                              = ".azure-devices.net"
    iotDpsEndpoint                              = ".azure-devices-provisioning.net"
    kustoEndpoint                               = ".kusto.windows.net"
    mapsEndpoint                                = "atlas.microsoft.com"
    powerbiEndpoint                             = "api.powerbi.com"
    purviewEndpoint                             = ".purview.azure.com"
    redisCacheHostname                          = ".redis.cache.windows.net"
    searchServiceEndpoint                       = ".search.windows.net"
    servicebusEndpoint                          = ".servicebus.windows.net"
    signalrEndpoint                             = ".service.signalr.net"
    trafficManagerEndpoint                      = ".trafficmanager.net"
    webPubsubEndpoint                           = ".webpubsub.azure.com"
    digitalTwinsEndpoint                        = ".digitaltwins.azure.net"
    activeDirectory                             = "https://login.microsoftonline.com"
    activeDirectoryDataLakeResourceId           = "https://datalake.azure.net/"
    activeDirectoryGraphResourceId              = "https://graph.windows.net/"
    activeDirectoryResourceId                   = "https://management.core.windows.net/"
    appInsightsResourceId                       = "https://api.applicationinsights.io"
    appInsightsTelemetryChannelResourceId       = "https://dc.applicationinsights.azure.com/v2/track"
    attestationResourceId                       = "https://attest.azure.net"
    azmirrorStorageAccountResourceId            = "null"
    batchResourceId                             = "https://batch.core.windows.net/"
    gallery                                     = "https://gallery.azure.com/"
    logAnalyticsResourceId                      = "https://api.loganalytics.io"
    management                                  = "https://management.core.windows.net/"
    mediaResourceId                             = "https://rest.media.azure.net"
    microsoftGraphResourceId                    = "https://graph.microsoft.com/"
    ossrdbmsResourceId                          = "https://ossrdbms-aad.database.windows.net"
    portal                                      = "https://portal.azure.com"
    resourceManager                             = "https://management.azure.com/"
    sqlManagement                               = "https://management.core.windows.net:8443/"
    synapseAnalyticsResourceId                  = "https://dev.azuresynapse.net"
    vmImageAliasDoc                             = "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json"
  }
}

variable "tenant_id" {
  description = "Azure AD Tenant ID for the current deployment."
  type        = string
  default     = null
}

variable "current_landingzone_key" {
  description = "Key for the current landing zones where the deployment is executed. Used in the context of landing zone deployment."
  default     = "local"
  type        = string
}

variable "tfstates" {
  description = "Terraform states configuration object. Used in the context of landing zone deployment."
  default     = {}
}

variable "enable" {
  description = "Map of services defined in the configuration file you want to disable during a deployment."
  default = {
    # bastion_hosts    = true
    # virtual_machines = true
  }
}

variable "environment" {
  description = "Name of the CAF environment."
  type        = string
  default     = "sandpit"
}

variable "logged_user_objectId" {
  description = "Used to set access policies based on the value 'logged_in_user'. Can only be used in interactive execution with vscode."
  type        = string
  default     = null
}
variable "logged_aad_app_objectId" {
  description = "Used to set access policies based on the value 'logged_in_aad_app'"
  type        = string
  default     = null
}

variable "use_msi" {
  description = "Deployment using an MSI for authentication."
  default     = false
  type        = bool
}

variable "tags" {
  description = "Tags to be used for this resource deployment."
  type        = map(any)
  default     = null
}

variable "resource_groups" {
  description = "Configuration object - Resource groups."
  default     = {}
}

variable "subscriptions" {
  description = "Configuration object - Subscriptions resources."
  default     = {}
}

variable "connectivity_subscription_id" {
  description = "Connectivity subscription id"
  default     = null
}

variable "connectivity_tenant_id" {
  description = "Connectivity tenant id"
  default     = null
}

variable "subscription_billing_role_assignments" {
  description = "Configuration object - subscription billing roleassignments."
  default     = {}
}

variable "billing" {
  description = "Configuration object - Billing information."
  default     = {}
}

variable "remote_objects" {
  description = "Allow the landing zone to retrieve remote tfstate objects and pass them to the CAF module."
  default     = {}
}

variable "data_sources" {
  description = "Data gathering for resources not managed by CAF Module"
  default     = {}
}

## Diagnostics settings
variable "diagnostics_definition" {
  default     = null
  description = "Configuration object - Shared diadgnostics settings that can be used by the services to enable diagnostics."
}

variable "diagnostics_destinations" {
  description = "Configuration object - Describes the destinations for the diagnostics."
  default     = null
}

variable "log_analytics" {
  description = "Configuration object - Log Analytics resources."
  default     = {}
}

variable "diagnostics" {
  description = "Configuration object - Diagnostics object."
  default     = {}
}

variable "event_hub_namespaces" {
  description = "Configuration object - Diagnostics object."
  default     = {}
}

# variable "subnet_id" {
#   default = {}
# }

variable "user_type" {
  description = "The rover set this value to user or serviceprincipal. It is used to handle Azure AD API consents."
  default     = {}
}

## Azure Maps
variable "maps" {
  description = "Configuration object - Azure map "
  default     = {}
}
## Azure AD
variable "azuread" {
  description = "Configuration object - Azure Active Directory resources"
  default     = {}
}

# variable "azuread_api_permissions" {
#   default = {}
# }

## Compute variables
variable "compute" {
  description = "Configuration object - Azure compute resources"
  default = {
    virtual_machines = {}
  }
}

variable "webapp" {
  description = "Configuration object - Web Applications"
  default = {
    # app_services                 = {}
    # app_service_environments     = {}
    # app_service_plans            = {}
    # azurerm_application_insights = {}
  }
}

variable "data_factory" {
  description = "Configuration object - Azure Data Factory resources"
  default     = {}
}

variable "logic_app" {
  description = "Configuration object - Azure Logic App resources"
  default     = {}
}

## Databases variables
variable "database" {
  description = "Configuration object - databases resources"
  default     = {}
}

variable "messaging" {
  description = "Configuration object - messaging resources"
  default     = {}
}

## DataProtection variables
variable "data_protection" {
  description = "Configuration object - data protection"
  default     = {}
}

## Networking variables
variable "networking" {
  description = "Configuration object - networking resources"
  default     = {}
}

## Security variables
variable "security" {
  description = "Configuration object - security resources"
  default     = {}
}

variable "managed_identities" {
  description = "Configuration object - Azure managed identity resources"
  default     = {}
}

variable "keyvaults" {
  description = "Configuration object - Azure Key Vault resources"
  default     = {}
}

variable "keyvault_access_policies" {
  description = "Configuration object - Azure Key Vault policies"
  default     = {}
}

variable "keyvault_access_policies_azuread_apps" {
  description = "Configuration object - Azure Key Vault policy for azure ad applications"
  default     = {}
}

variable "custom_role_definitions" {
  description = "Configuration object - Custom role definitions"
  default     = {}
}

variable "role_mapping" {
  description = "Configuration object - Role mapping"
  default = {
    built_in_role_mapping = {}
    custom_role_mapping   = {}
  }
}

variable "dynamic_keyvault_secrets" {
  default = {}
}

## Storage variables
variable "storage_accounts" {
  description = "Configuration object - Storage account resources"
  default     = {}
}
variable "storage" {
  description = "Configuration object - Storage account resources"
  default     = {}
}
variable "diagnostic_storage_accounts" {
  description = "Configuration object - Storage account for diagnostics resources"
  default     = {}
}

# Shared services
variable "shared_services" {
  description = "Configuration object - Shared services resources"
  default = {
    # automations = {}
    # monitoring = {}
    # recovery_vaults = {}
  }
}

variable "var_folder_path" {
  default = ""
}

# variable "virtual_network_gateways" {
#   default = {}
# }

# variable "virtual_network_gateway_connections" {
#   default = {}
# }

# variable "shared_image_galleries" {
#   default = {}
# }

# variable "image_definitions" {
#   default = {}
# }

# variable "packer_service_principal" {
#   default = {}
# }

# variable "packer_managed_identity" {
#   default = {}
# }

variable "keyvault_certificate_issuers" {
  description = "Configuration object - Azure Key Vault Certificate Issuers resources"
  default     = {}
}
# variable "cosmos_dbs" {
#   default = {}
# }

variable "app_config" {
  default = {}
}

# variable "local_network_gateways" {
#   default = {}
# }

# variable "application_security_groups" {
#   default = {}
# }
variable "event_hubs" {
  description = "Configuration object - Event Hub resources"
  default     = {}
}

variable "event_hub_auth_rules" {
  description = "Configuration object - Event Hub authentication rules"
  default     = {}
}

variable "event_hub_namespace_auth_rules" {
  description = "Configuration object - Event Hub namespaces authentication rules"
  default     = {}
}

variable "event_hub_consumer_groups" {
  description = "Configuration object - Event Hub consumer group rules"
  default     = {}
}

variable "random_strings" {
  description = "Configuration object - Random string generator resources"
  default     = {}
}

variable "cognitive_services" {
  description = "Configuration object - Cognitive Service Resource "
  default     = {}
}

variable "communication" {
  description = "Configuration object - communication resources"
  default     = {}
}

variable "identity" {
  description = "Configuration object - identity resources"
  default     = {}
}
variable "apim" {
  default = {}
}

variable "purview" {
  default = {}
}

variable "sentinel_watchlists" {
  default = {}
}
variable "iot" {
  description = "Configuration object - IoT"
  default = {
    # digital_twins_instances                 = {}
    # digital_twins_endpoint_eventhubs                 = {}
    # digital_twins_endpoint_eventgrids = {}
    # digital_twins_endpoint_servicebuses = {}

  }
}
variable "resource_provider_registration" {
  default = {}
}
variable "aadb2c" {
  description = "Configuration object - AAD B2C resources"
  default     = {}
}
variable "preview_features" {
  default = {}
}
variable "powerbi_embedded" {
  default = {}
}
variable "maintenance" {
  default = {}
}
variable "search_services" {
  description = "Configuration object - Search service Resource "
  default     = {}
}
variable "load_test" {
  description = "Configuration object - Load Test resources"
  default     = {}
}
