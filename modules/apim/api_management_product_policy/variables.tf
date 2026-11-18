variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Configures the policy applied to an APIM product independently of creating that
product. Do not manage the same policy with both this module and the product
module's embedded policy settings. Undeclared attributes are ignored by Terraform.

Parent service and resource group:
- api_management (object, optional; default null): Selects the APIM service.
  A parent service must resolve through name or the reference key.
  - name (string, optional; default null): Explicit service name, used before
    looking up the api_management remote collection.
  - key (string, optional; default null): Business key in api_management when
    name is omitted.
  - lz_key (string, optional; default null): Service namespace; null selects
    client_config.landingzone_key.
- resource_group_name (string, optional; default null): Explicit name of the
  service's resource group. Overrides settings.resource_group and the
  module-level resource_group argument.
- resource_group (object, optional; default null): Alternative group selector.
  A resource group must resolve.
  - name (string, optional; default null): Explicit group name, used after
    resource_group_name and before the module-level resource_group argument.
  - key (string, optional; default null): Business key in resource_groups,
    consulted when neither an explicit nor a module-level group name resolves.
  - lz_key (string, optional; default null): Group namespace; null selects
    client_config.landingzone_key.

Product selection:
- product_id (string, optional; default null): Logical product identifier within
  APIM, not its ARM resource ID. Takes precedence over product.
- product (object, optional; default null): Product reference used when
  product_id is omitted. One of these selectors must resolve a product.
  - key (string, required within product): Business key in
    api_management_product; the referenced object must expose product_id.
  - lz_key (string, optional; default null): Product namespace; null selects
    client_config.landingzone_key.

Policy source; supply exactly one:
- xml_content (string, optional; default null): Inline APIM policy XML containing
  the product-scope inbound, backend, outbound or error-handling configuration.
- xml_link (string, optional; default null): Publicly accessible URL of the XML
  policy document, used instead of embedding the policy in xml_content.

Operation limits:
- timeouts (object, optional; default null): Terraform operation time limits.
  Omission or explicit null omits the block and leaves defaults to the provider.
  - create (string, optional; default null): Maximum policy creation duration;
    provider default 30m.
  - read (string, optional; default null): Maximum refresh/retrieval duration;
    provider default 5m.
  - update (string, optional; default null): Maximum policy update duration;
    provider default 30m.
  - delete (string, optional; default null): Maximum policy deletion duration;
    provider default 30m.
DESCRIPTION
  type = object({
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    product_id = optional(string)
    product = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    xml_content = optional(string)
    xml_link    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = (var.settings.xml_content == null) != (var.settings.xml_link == null)
    error_message = "Supply exactly one of xml_content or xml_link."
  }
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}

variable "resource_group" {
  description = "Resource group object to deploy the Azure resource."
  type        = any
  default     = null
}

variable "location" {
  description = "Location of the resource if different from the resource group."
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
  default     = false
}
