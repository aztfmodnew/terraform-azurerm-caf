variable "global_settings" {
  description = <<DESCRIPTION
  Global settings object
  DESCRIPTION
  type        = any
}

variable "client_config" {
  description = "<<DESCRIPTION
  Client configuration object
  DESCRIPTION"
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
