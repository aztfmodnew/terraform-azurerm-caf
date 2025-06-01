variable "global_settings" {
  description = "Global settings object, passed from the parent module."
  type        = any
}

variable "client_config" {
  description = "Client configuration object, passed from the parent module."
  type        = any
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the Local Rulestack. Changing this forces a new resource to be created."
  type        = string
}

variable "settings" {
  description = <<DESCRIPTION
  Settings for the Local Rulestack y sus componentes.

  Top-level properties are for azurerm_palo_alto_local_rulestack:
    name: (Required) Name of the Local Rulestack.
    description: (Optional) Description for the Local Rulestack.
    anti_spyware_profile: (Optional) Anti Spyware Profile name.
    anti_virus_profile: (Optional) Anti Virus Profile name.
    dns_subscription_enabled: (Optional) Whether DNS Subscription is enabled. Valid values are `true` or `false`.
    file_blocking_profile: (Optional) File Blocking Profile name.
    min_app_id_version: (Optional) Minimum App ID Version for the Rulestack.
    outbound_trust_certificate_name: (Optional) The name of the Outbound Trust Certificate. This should match a key in the `certificates` map if managed here.
    outbound_untrust_certificate_name: (Optional) The name of the Outbound Untrust Certificate. This should match a key in the `certificates` map if managed here.
    url_filtering_profile: (Optional) URL Filtering Profile name.
    vulnerability_protection_profile: (Optional) Vulnerability Protection Profile name.
    tags: (Optional) Tags for the Local Rulestack.

  Components of the rulestack (maps where key is the component's name/identifier):
    certificates: (Optional) A map of certificate objects for `azurerm_palo_alto_local_rulestack_certificate`.
      Each certificate object can have:
        self_signed: (Required) Boolean, true if self-signed, false otherwise.
        key_vault_certificate_id: (Optional) If not self_signed, the Key Vault Certificate ID for the certificate.
        audit_comment: (Optional) Audit Comment for the certificate.
        description: (Optional) Description for the certificate.

    fqdn_lists: (Optional) A map of FQDN list objects for `azurerm_palo_alto_local_rulestack_fqdn_list`.
      Each FQDN list object can have:
        fully_qualified_domain_names: (Required) A list of FQDNs.
        audit_comment: (Optional) Audit Comment.
        description: (Optional) Description.

    prefix_lists: (Optional) A map of Prefix list objects for `azurerm_palo_alto_local_rulestack_prefix_list`.
      Each Prefix list object can have:
        prefix_list: (Required) A list of IP Prefixes.
        audit_comment: (Optional) Audit Comment.
        description: (Optional) Description.

    rules: (Optional) A map of rule objects for `azurerm_palo_alto_local_rulestack_rule`.
      Each rule object can have properties like:
        priority: (Required) Integer priority.
        action: (Required) e.g., "Allow", "Deny".
        applications: (Required) List of applications.
        # ... and all other arguments supported by the azurerm_palo_alto_local_rulestack_rule resource.

    outbound_trust_certificate_associations: (Optional) A map for `azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association`.
      Key is an arbitrary identifier for the association resource in Terraform.
      Each object must have:
        certificate_key: (Required) The key of the certificate to associate (must exist in `certificates`).

    outbound_untrust_certificate_associations: (Optional) A map for `azurerm_palo_alto_local_rulestack_outbound_untrust_certificate_association`.
      Key is an arbitrary identifier for the association resource in Terraform.
      Each object must have:
        certificate_key: (Required) The key of the certificate to associate (must exist in `certificates`).
  
  Example usage:

  ```	hcl
  settings = {
    name        = "caf-demo-rulestack"
    description = "Demo Palo Alto Local Rulestack"
    anti_spyware_profile = "default"
    anti_virus_profile   = "default"
    dns_subscription_enabled = true
    file_blocking_profile = "default"
    min_app_id_version = "1.0"
    outbound_trust_certificate_name  = "my-trust-cert"
    outbound_untrust_certificate_name = "my-untrust-cert"
    url_filtering_profile = "default"
    vulnerability_protection_profile = "default"
    tags = {
      environment = "dev"
    }
    certificates = {
      my-trust-cert = {
        self_signed = true
        audit_comment = "Trust cert for outbound"
        description  = "Trust certificate"
      }
      my-untrust-cert = {
        self_signed = false
        # key_vault_certificate_id debe usarse, no key_vault_secret_id
        key_vault_certificate_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/xxx/certificates/xxx"
        audit_comment = "Untrust cert for outbound"
        description  = "Untrust certificate"
      }
    }
    fqdn_lists = {
      allowed_sites = {
        fully_qualified_domain_names  = ["*.example.com", "another.domain.net"]
        audit_comment = "Allow these FQDNs"
        description   = "Allowed FQDNs"
      }
    }
    prefix_lists = {
      trusted_ips = {
        prefix_list   = ["10.0.0.0/8", "192.168.0.0/16"]
        audit_comment = "Trusted IPs"
        description   = "Trusted IP ranges"
      }
    }
    rules = {
      allow-web = {
        priority     = 100
        action       = "Allow"
        applications = ["web-browsing"]
        # ... other rule properties ...
      }
    }
    outbound_trust_certificate_associations = {
      trust_assoc = {
        certificate_key = "my-trust-cert"
      }
    }
    outbound_untrust_certificate_associations = {
      untrust_assoc = {
        certificate_key = "my-untrust-cert"
      }
    }
  }
  ```
  DESCRIPTION
  type        = any
}

variable "resource_group" {
  description = "Resource group object, passed from the parent module. The Local Rulestack will be deployed in this resource group."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited, passed from the parent module."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies like diagnostics, passed from the parent module."
  type        = any
  default     = {}
}
