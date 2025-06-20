variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "settings" {
  description = <<DESCRIPTION
  Settings for azurerm_virtual_network_gateway_connection. Supported fields:
    - name: (Required) The name of the connection. Changing the name forces a new resource to be created.
    - type: (Required) The type of connection. Allowed values: "IPsec", "ExpressRoute", "Vnet2Vnet". Changing this forces a new resource to be created.
    - connection_method: (Optional) The IKE protocol version to use. Allowed values: "IKEv1", "IKEv2". Default: "IKEv2". Only valid for IPSec connections on certain SKUs.
    - dpd_timeout_seconds: (Optional) The dead peer detection timeout in seconds. Changing this forces a new resource to be created.
    - shared_key: (Optional) The shared IPSec key. Used for Site-to-Site, VNet-to-VNet, or ExpressRoute connections.
    - enable_bgp: (Optional) Enable BGP (Border Gateway Protocol) for this connection. Allowed values: true, false. Default: false.
    - routing_weight: (Optional) The routing weight. Default: 10.
    - use_policy_based_traffic_selectors: (Optional) Enable policy-based traffic selectors. Allowed values: true, false. Default: false. Requires ipsec_policy block if true.
    - peer_virtual_network_gateway_id: (Optional) The ID of the peer virtual network gateway for VNet-to-VNet connections.
    - connection_mode: (Optional) Connection mode. Allowed values: "Default", "InitiatorOnly", "ResponderOnly". Default: "Default". Changing this forces a new resource to be created.
    - express_route_gateway_bypass: (Optional) Bypass ExpressRoute Gateway for data forwarding. Allowed values: true, false. Only valid for ExpressRoute connections.
    - private_link_fast_path_enabled: (Optional) Bypass the Express Route gateway when accessing private-links. Allowed values: true, false. express_route_gateway_bypass must be true. Default: false.
    - egress_nat_rule_ids: (Optional) List of egress NAT Rule IDs.
    - ingress_nat_rule_ids: (Optional) List of ingress NAT Rule IDs.
    - local_azure_ip_address_enabled: (Optional) Use private local Azure IP for the connection. Allowed values: true, false.
    - custom_bgp_addresses: (Optional, block) Custom BGP addresses. Fields:
        - primary: (Required) Single IP address (first ip_configuration).
        - secondary: (Optional) Single IP address (second ip_configuration).
    - ipsec_policy: (Optional, block) Only one policy per connection. Fields:
        - dh_group: (Required) Allowed: "DHGroup1", "DHGroup14", "DHGroup2", "DHGroup2048", "DHGroup24", "ECP256", "ECP384", "None".
        - ike_encryption: (Required) Allowed: "AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES256".
        - ike_integrity: (Required) Allowed: "GCMAES128", "GCMAES256", "MD5", "SHA1", "SHA256", "SHA384".
        - ipsec_encryption: (Required) Allowed: "AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES192", "GCMAES256", "None".
        - ipsec_integrity: (Required) Allowed: "GCMAES128", "GCMAES192", "GCMAES256", "MD5", "SHA1", "SHA256".
        - pfs_group: (Required) Allowed: "ECP256", "ECP384", "PFS1", "PFS2", "PFS14", "PFS2048", "PFS24", "PFSMM", "None".
        - sa_datasize: (Optional) Payload size in KB. Min: 1024. Default: 102400000.
        - sa_lifetime: (Optional) Lifetime in seconds. Min: 300. Default: 27000.
    - traffic_selector_policy: (Optional, list of blocks) Each block fields:
        - local_address_cidrs: (Required) List of local CIDRs.
        - remote_address_cidrs: (Required) List of remote CIDRs.
    - timeouts: (Optional, block) Operation timeouts. Fields:
        - create: (Optional) Default: "60m".
        - update: (Optional) Default: "60m".
        - read: (Optional) Default: "5m".
        - delete: (Optional) Default: "60m".

  Example usage:

    settings = {
      name                = "my-connection"
      type                = "IPsec"
      connection_method   = "IKEv2"
      dpd_timeout_seconds = 30
      shared_key          = "my-shared-key"
      enable_bgp          = false
      routing_weight      = 10
      use_policy_based_traffic_selectors = false
      peer_virtual_network_gateway_id    = null
      connection_mode     = "Default"
      express_route_gateway_bypass    = false
      private_link_fast_path_enabled  = false
      egress_nat_rule_ids             = []
      ingress_nat_rule_ids            = []
      local_azure_ip_address_enabled  = false
      custom_bgp_addresses = {
        primary   = "10.0.0.4"
        secondary = "10.0.0.5"
      }
      ipsec_policy = {
        dh_group         = "DHGroup14"
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "PFS2"
        sa_datasize      = 102400000
        sa_lifetime      = 27000
      }
      traffic_selector_policy = [
        {
          local_address_cidrs  = ["10.0.0.0/24"]
          remote_address_cidrs = ["10.1.0.0/24"]
        }
      ]
      timeouts = {
        create = "60m"
        update = "60m"
        read   = "5m"
        delete = "60m"
      }
    }
  DESCRIPTION
  type        = any
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "diagnostics" {}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "express_route_circuit_id" {}
variable "authorization_key" {}
variable "virtual_network_gateway_id" {}
variable "local_network_gateway_id" {}
variable "remote_objects" {
  description = "Remote objects to be used in the module (see module README.md)."
  type        = any
}
