variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Configuration settings for the CDN Front Door Security Policy:
  
  - name: (Required) The name which should be used for this Front Door Security Policy
  - cdn_frontdoor_profile_id: (Required) The Front Door Profile Resource Id
  - security_policies: (Required) Security policies configuration
    - firewall: (Required) Firewall configuration
      - cdn_frontdoor_firewall_policy_id: (Required) The Resource Id of the Front Door Firewall Policy
      - association: (Required) List of association blocks
        - domain: (Required) List of domain blocks
          - cdn_frontdoor_domain_id: (Required) The Resource Id of the Front Door Custom Domain or Endpoint
        - patterns_to_match: (Required) The list of paths to match for this firewall policy
  - timeouts: (Optional) Timeout configuration
    - create: (Optional) Timeout for create operations
    - read: (Optional) Timeout for read operations
    - delete: (Optional) Timeout for delete operations
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
  description = "Remote objects required for the module, such as existing resources."
  type        = any
}