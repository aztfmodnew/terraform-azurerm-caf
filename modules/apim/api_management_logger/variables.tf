variable "global_settings" {
  description = <<DESCRIPTION
Global CAF settings, as produced by the root module. Supported attributes:
  - default_region, environment - (Optional) Default region key and environment name.
  - inherit_tags - (Optional) Whether resources inherit global tags. Defaults to false.
  - prefix, suffix, prefix_with_hyphen - (Optional) Naming prefix, suffix and hyphenated prefix.
  - prefixes, suffixes - (Optional) Naming prefix and suffix lists used by azurecaf.
  - random_length, random_seed - (Optional) Random suffix length (defaults to 0) and seed.
  - resource_types - (Optional) Additional azurecaf resource types. Defaults to [].
  - separator - (Optional) Naming separator. Defaults to "-".
  - passthrough, use_slug, clean_input - (Optional) azurecaf naming flags. Default to false, true and true.
  - regions - (Optional) Map of region keys to Azure region names.
  - tags - (Optional) Global tags.
DESCRIPTION
  type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool, false)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(string)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number, 0)
    random_seed        = optional(number)
    resource_types     = optional(list(string), [])
    separator          = optional(string, "-")
    passthrough        = optional(bool, false)
    regions            = optional(map(string))
    tags               = optional(map(string))
    use_slug           = optional(bool, true)
    clean_input        = optional(bool, true)
  })
}

variable "client_config" {
  description = <<DESCRIPTION
Client configuration, as produced by the root module. landingzone_key is required;
client_id, object_id, logged_aad_app_objectId, logged_user_objectId, subscription_id
and tenant_id are optional.
DESCRIPTION
  type = object({
    client_id               = optional(string)
    landingzone_key         = string
    logged_aad_app_objectId = optional(string)
    logged_user_objectId    = optional(string)
    object_id               = optional(string)
    subscription_id         = optional(string)
    tenant_id               = optional(string)
  })
}

variable "settings" {
  description = <<DESCRIPTION
Define a telemetry destination referenced by service/API diagnostics.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): logger resource name processed by CAF naming.
- buffered (optional bool): buffer records before transmission. Null is passed
  through; the provider defaults to true, rather than a module-supplied default.
- description (optional string): explanatory text about this logger.
- resource_id (optional string): ARM ID of the associated destination resource.
- resource (optional object): fallback Application Insights resource reference.
  Optional key selects remote_objects.application_insights[lz_key][key].id;
  optional lz_key defaults to the current zone; optional id is a direct ARM ID.
  Resolution prefers resource_id, the selected-zone key, the current-zone key,
  then resource.id.
- application_insights (optional object): Application Insights destination.
  Optional instrumentation_key supplies its sensitive instrumentation key;
  optional connection_string supplies its sensitive ingestion connection string.
  Do not set both directly. Optional key selects the Application Insights
  collection and optional lz_key its zone (current by default), with a second
  lookup in the current zone if the selected-zone lookup fails. Optional name
  is compatibility metadata and is not used for a lookup.
  Optional identity_client_id selects authenticated ingestion: use a
  user-assigned managed identity's client ID, or SystemAssigned for the service's
  system-assigned identity. It is required when the destination disables local
  authentication and requires a direct or key-resolved connection string,
  not an instrumentation key.
  Direct connection_string or instrumentation_key wins over remote values.
  Without a direct source, identity mode prefers the remote connection string;
  non-identity mode prefers a remote instrumentation key when available,
  otherwise a remote connection string.
- eventhub (optional object): Event Hub destination. name is the required Event
  Hub name. Optional connection_string authenticates with an authorization-rule
  connection string; optional endpoint_uri identifies the namespace endpoint
  for identity-based ingestion. At least one must be supplied. Optional
  user_assigned_identity_client_id selects the user-assigned identity used to
  connect to the hub; the provider documents system-assigned identity behavior
  when it is omitted. Identity-based ingestion needs the namespace endpoint and
  Azure Event Hubs Data Sender permissions for the service identity.
  Destination strings are sensitive configuration.
  Exactly one of application_insights and eventhub must be configured.
- api_management / resource_group (optional objects): root parent references;
  all nested fields are optional/null. name is a direct resource name preferred
  over key, key selects its combined CAF collection, and lz_key selects its
  zone (current by default). resource_group_key is the optional legacy key
  preferred before resource_group.key by the root group lookup. The root
  supplies separate parent-name inputs to this child.
- timeouts (optional object): create limits logger creation, read retrieval,
  update destination changes, and delete removal. Each optional duration-string
  field defaults to null, retaining its provider timeout.
All other optional fields default to null; reference resolution only supplies
the fallbacks described above. Undeclared attributes are discarded by the type.
DESCRIPTION
  type = object({
    name        = string
    buffered    = optional(bool)
    description = optional(string)
    resource_id = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key = optional(string)
    resource = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    application_insights = optional(object({
      key                 = optional(string)
      lz_key              = optional(string)
      name                = optional(string)
      instrumentation_key = optional(string)
      connection_string   = optional(string)
      identity_client_id  = optional(string)
    }))
    eventhub = optional(object({
      name                             = string
      connection_string                = optional(string)
      endpoint_uri                     = optional(string)
      user_assigned_identity_client_id = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = try(var.settings.application_insights.connection_string, null) == null || try(
      var.settings.application_insights.instrumentation_key,
      null
    ) == null
    error_message = "application_insights must not set both connection_string and instrumentation_key."
  }

  validation {
    condition = try(var.settings.application_insights.identity_client_id, null) == null || (
      try(var.settings.application_insights.instrumentation_key, null) == null &&
      (
        try(var.settings.application_insights.connection_string, null) != null ||
        try(var.settings.application_insights.key, null) != null
      )
    )
    error_message = "application_insights.identity_client_id requires a connection_string source and cannot be used with instrumentation_key."
  }

  validation {
    condition = try(var.settings.eventhub.name, null) == null || (
      try(var.settings.eventhub.connection_string, null) != null ||
      try(var.settings.eventhub.endpoint_uri, null) != null
    )
    error_message = "eventhub must set at least one of connection_string or endpoint_uri."
  }

  validation {
    condition     = (var.settings.application_insights == null) != (var.settings.eventhub == null)
    error_message = "A logger must configure exactly one of application_insights or eventhub."
  }

  validation {
    condition = var.settings.application_insights == null || (
      try(var.settings.application_insights.key, null) != null ||
      try(var.settings.application_insights.connection_string, null) != null ||
      try(var.settings.application_insights.instrumentation_key, null) != null
    )
    error_message = "application_insights must provide a telemetry source: key, connection_string or instrumentation_key."
  }
}

variable "remote_objects" {
  description = "Application Insights resources and other objects used for logger references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "resource_group_name" {
  description = "The resource group containing the API Management service."
  type        = string
}

variable "api_management_name" {
  description = "The API Management service name."
  type        = string
}
