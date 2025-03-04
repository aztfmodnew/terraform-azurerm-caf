variable "global_settings" {
  description = <<DESCRIPTION
  Global settings object
  DESCRIPTION
  type        = any
}

variable "client_config" {
  description = <<DESCRIPTION
  Client configuration object
  DESCRIPTION
  type        = any
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "settings" {
  description = <<DESCRIPTION
  Settings of the module:
  name - (Required) Specifies the name of the AI Services Account. Changing this forces a new resource to be created.
  resource_group_name - (Required) The name of the resource group in which the AI Services Account is created. Changing this forces a new resource to be created.
  location - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
  sku_name - (Required) Specifies the SKU Name for this AI Services Account. Possible values are F0, F1, S0, S, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0 and DC0.
  custom_subdomain_name - (Optional) The subdomain name used for token-based authentication. This property is required when network_acls is specified. Changing this forces a new resource to be created.
  customer_managed_key - (Optional) A customer_managed_key block as documented below.
    - key_vault_key_id - (Optional) The ID of the Key Vault Key which should be used to encrypt the data in this AI Services Account. Exactly one of key_vault_key_id, managed_hsm_key_id must be specified.
    - managed_hsm_key_id - (Optional) The ID of the managed HSM Key which should be used to encrypt the data in this AI Services Account. Exactly one of key_vault_key_id, managed_hsm_key_id must be specified.
    - identity_client_id - (Optional) The Client ID of the User Assigned Identity that has access to the key. This property only needs to be specified when there are multiple identities attached to the Azure AI Service.   
  fqdns - (Optional) List of FQDNs allowed for the AI Services Account.
  identity - (Optional) An identity block as defined below.
    - type - (Required) Specifies the type of Managed Service Identity that should be configured on this AI Services Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned
    - identity_ids - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this AI Services Account.
  local_authentication_enabled - (Optional) Whether local authentication is enabled for the AI Services Account. Defaults to true.
  network_acls - (Optional) A network_acls block as defined below. When this property is specified, custom_subdomain_name is also required to be set.
    - default_action - (Required) The Default Action to use when no rules match from ip_rules / virtual_network_rules. Possible values are Allow and Deny.
    - ip_rules - (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the AI Services Account.
    - virtual_network_rules - (Optional) A virtual_network_rules block as defined below.
      - subnet_id - (Required) The ID of the subnet which should be able to access this AI Services Account.
      - ignore_missing_vnet_service_endpoint - (Optional) Whether to ignore a missing Virtual Network Service Endpoint or not. Default to false.
  outbound_network_access_restricted - (Optional) Whether outbound network access is restricted for the AI Services Account. Defaults to false.
  public_network_access - (Optional) Whether public network access is allowed for the AI Services Account. Possible values are Enabled and Disabled. Defaults to Enabled. 
  storage - (Optional) A storage block as defined below.
    - storage_account_id - (Required) The ID of the Storage Account.
    - identity_client_id - (Optional) The client ID of the Managed Identity associated with the Storage Account.
  
  tags - (Optional) A mapping of tags to assign to the resource.
  timeouts - (Optional) The timeouts block allows you to specify timeouts for certain actions:
    - create - (Defaults to 30 minutes) Used when creating the AI Services Account.
    - update - (Defaults to 30 minutes) Used when updating the AI Services Account.
    - read - (Defaults to 5 minutes) Used when retrieving the AI Services Account.
    - delete - (Defaults to 30 minutes) Used when deleting the AI Services Account.
  
  Example Input:
    ```terraform
    settings = {
      name = "example-ai-services-account"
      resource_group_name = "example-resources"
      location = "eastus"
      sku_name = "S0"
      custom_subdomain_name = "example"
      customer_managed_key = {
        key_vault_key_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-resources/providers/Microsoft.KeyVault/vaults/example-keyvault/keys/example-key"
      }
      fqdns = [
        "example.com",
        "example.net"
      ]
      identity = {
        type = "SystemAssigned"
      }
      local_authentication_enabled = false
      network_acls = {
        default_action = "Deny"
        ip_rules = [
          "10.0.0.0/8"
        ]
        virtual_network_rules = [
          {
            subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-subnet"
          }
        ]
      }
      outbound_network_access_restricted = true
      public_network_access = "Disabled"
      storage = {
        storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-resources/providers/Microsoft.Storage/storageAccounts/examplestorage"
        identity_client_id = "00000000-0000-0000-0000-000000000000"
      }
      tags = {
        environment = "production"
      }
      timeouts = {
        create = "30m"
        update = "30m"
        read = "5m"
        delete = "30m"
      }
    }
    ```
  DESCRIPTION
  type        = any

}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "Flag to determine if tags should be inherited"
}

variable "remote_objects" {
  type        = any
  description = "Remote objects"
}
