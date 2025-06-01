## Global settings
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
  type        = any
  /*type = object({
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
    use_slug           = optional(bool)
  })*/
}
## Client configuration

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
  type        = any

}

variable "location" {
  description = "(Optional) Specifies the supported Azure location where to create the resource. If not provided, the resource group's location will be used. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
  Settings of the module:

  Top-level properties are for azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack:
    name: (Required) The name for the NGFW.
    network_profile: (Required) A network_profile block.
      vnet_configuration: (Required) A vnet_configuration block.
        virtual_network_id: (Required) The ID of the Virtual Network where the NGFW is deployed.
        trusted_address_ranges: (Optional) Specifies a list of trusted Address Ranges.
        ip_of_trust_for_user_defined_routes: (Optional) The IP Address of the Trust for User Defined Routes.
      public_ip_address_ids: (Required) Specifies a list of Public IP Address IDs to be used for the NGFW.
      egress_nat_ip_address_ids: (Optional) Specifies a list of Egress NAT IP Address IDs.
      enable_egress_nat: (Optional) Whether Egress NAT is enabled. Defaults to true. Valid values are `true` or `false`.
    dns_settings: (Optional) A dns_settings block.
      dns_servers: (Optional) A list of DNS server IP addresses.
      enable_proxy: (Optional) Should DNS proxy be enabled? Valid values are `true` or `false`.
    marketplace_details: (Required) A marketplace_details block.
      offer_id: (Required) The Offer ID of the Marketplace Image (e.g., "paloaltonetworks.ngfw-byol").
      publisher_id: (Required) The Publisher ID of the Marketplace Image (e.g., "paloaltonetworks").
      plan_id: (Required) The Plan ID of the Marketplace Image (e.g., "byol").
    tags: (Optional) Tags for the NGFW.
    # identity: (Optional) An identity block if the NGFW resource supports it in future provider versions.

  `local_rulestack` object contains settings for the azurerm_palo_alto_local_rulestack and its components, managed by a sub-module:
    local_rulestack = {
      name: (Required) Name of the Local Rulestack. This will be combined with a CAF name if not passthrough.
      location: (Optional) Location for the Local Rulestack. Defaults to the NGFW's location.
      description: (Optional) Description for the Local Rulestack.
      anti_spyware_profile: (Optional) Name of the Anti Spyware Profile.
      anti_virus_profile: (Optional) Name of the Anti Virus Profile.
      dns_subscription_enabled: (Optional) Whether DNS Subscription is enabled.
      file_blocking_profile: (Optional) Name of the File Blocking Profile.
      min_app_id_version: (Optional) Minimum App ID Version for the Rulestack.
      outbound_trust_certificate_name: (Optional) The name of the Outbound Trust Certificate. Refers to a `azurerm_palo_alto_local_rulestack_certificate`.
      outbound_untrust_certificate_name: (Optional) The name of the Outbound Untrust Certificate. Refers to a `azurerm_palo_alto_local_rulestack_certificate`.
      url_filtering_profile: (Optional) Name of the URL Filtering Profile.
      vulnerability_protection_profile: (Optional) Name of the Vulnerability Protection Profile.
      tags: (Optional) Tags for the Local Rulestack.
      # Components of the rulestack:
      certificates: (Optional) A map of certificate objects for `azurerm_palo_alto_local_rulestack_certificate`. Key is the certificate name.
        # Example:
        # certificates = {
        #   mycert = {
        #     self_signed = true # or false
        #     # audit_comment = "comment"
        #     # description = "desc"
        #   }
        # }
      fqdn_lists: (Optional) A map of FQDN list objects for `azurerm_palo_alto_local_rulestack_fqdn_list`. Key is the list name.
        # Example:
        # fqdn_lists = {
        #   allowed_sites = {
        #     fqdn_entries  = ["*.example.com", "another.domain.net"]
        #     # description   = "Allowed FQDNs"
        #     # audit_comment = "comment"
        #   }
        # }
      prefix_lists: (Optional) A map of Prefix list objects for `azurerm_palo_alto_local_rulestack_prefix_list`. Key is the list name.
        # Example:
        # prefix_lists = {
        #   trusted_ips = {
        #     prefix_entries = ["10.0.0.0/24", "192.168.1.0/24"]
        #     # description    = "Trusted IP Prefixes"
        #     # audit_comment  = "comment"
        #   }
        # }
      rules: (Optional) A map of rule objects for `azurerm_palo_alto_local_rulestack_rule`. Key is the rule name.
        # Example:
        # rules = {
        #   allow_web = {
        #     priority = 100
        #     action   = "Allow"
        #     applications = ["ssl", "web-browsing"]
        #     destination_ports = ["80", "443"]
        #     # ... other rule properties
        #   }
        # }
      outbound_trust_certificate_associations: (Optional) A map for `azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association`. Key is arbitrary.
        # Example:
        # outbound_trust_certificate_associations = {
        #   assoc1 = { certificate_name = "my-trust-cert" }
        # }
      outbound_untrust_certificate_associations: (Optional) A map for `azurerm_palo_alto_local_rulestack_outbound_untrust_certificate_association`. Key is arbitrary.
        # Example:
        # outbound_untrust_certificate_associations = {
        #   assoc1 = { certificate_name = "my-untrust-cert" }
        # }
    }
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resource group object where the NGFW and its Rulestack will be deployed."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited from global settings and resource group."
  type        = bool
  default     = true
}

variable "remote_objects" {
  description = "Remote objects for dependencies like diagnostics, managed identities etc."
  type        = any
  default     = {}
}